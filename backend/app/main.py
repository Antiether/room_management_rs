import os
import json
from typing import Literal

import httpx
from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

load_dotenv()
app = FastAPI(title="SmarterBMS AI API", version="0.1.0")

# Demo-only CORS. Restrict allowed origins before any public deployment.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["GET", "POST"],
    allow_headers=["Content-Type"],
)


class WardSnapshot(BaseModel):
    ward_name: str = Field(min_length=1, max_length=120)
    total_beds: int = Field(ge=0, le=10000)
    available_beds: int = Field(ge=0, le=10000)
    occupied_beds: int = Field(ge=0, le=10000)
    booked_beds: int = Field(ge=0, le=10000)
    cleaning_beds: int = Field(ge=0, le=10000)
    maintenance_beds: int = Field(default=0, ge=0, le=10000)
    data_mode: Literal["synthetic_demo"] = "synthetic_demo"


class InsightResponse(BaseModel):
    ward_name: str
    data_mode: str
    occupancy_rate: float
    risk_level: Literal["low", "moderate", "high"]
    summary: str
    recommended_actions: list[str]
    limitations: list[str]
    model: str


def calculate_risk(snapshot: WardSnapshot) -> tuple[float, str]:
    if snapshot.total_beds == 0:
        return 0.0, "low"
    # BOR in this prototype is occupied / total beds; booked beds are reported separately.
    rate = snapshot.occupied_beds / snapshot.total_beds * 100
    if rate >= 85:
        risk = "high"
    elif rate >= 70:
        risk = "moderate"
    else:
        risk = "low"
    return round(rate, 1), risk


@app.get("/health")
def health():
    return {"status": "ok", "service": "smarterbms-ai", "llm_configured": bool(os.getenv("OPENAI_API_KEY"))}


@app.post("/api/ai/occupancy-insight", response_model=InsightResponse)
async def occupancy_insight(snapshot: WardSnapshot):
    if snapshot.total_beds == 0:
        raise HTTPException(status_code=422, detail="Bangsal belum memiliki data bed.")
    counts = (
        snapshot.available_beds + snapshot.occupied_beds + snapshot.booked_beds
        + snapshot.cleaning_beds + snapshot.maintenance_beds
    )
    if counts > snapshot.total_beds:
        raise HTTPException(status_code=422, detail="Jumlah status bed melebihi total bed.")

    occupancy_rate, risk = calculate_risk(snapshot)
    api_key = os.getenv("OPENAI_API_KEY", "").strip()
    model = os.getenv("OPENAI_MODEL", "gpt-6-luna").strip()
    if not api_key or api_key == "replace_with_your_api_key":
        raise HTTPException(
            status_code=503,
            detail="LLM belum dikonfigurasi. Isi OPENAI_API_KEY pada backend/.env lalu restart backend.",
        )

    # Send aggregate operational counts only. Never send patient names, diagnoses, or identifiers.
    payload = {
        "ward_name": snapshot.ward_name,
        "total_beds": snapshot.total_beds,
        "available_beds": snapshot.available_beds,
        "occupied_beds": snapshot.occupied_beds,
        "booked_beds": snapshot.booked_beds,
        "cleaning_beds": snapshot.cleaning_beds,
        "maintenance_beds": snapshot.maintenance_beds,
        "occupancy_rate_percent": occupancy_rate,
        "rule_based_risk_level": risk,
        "data_mode": "synthetic_demo",
    }
    instructions = (
        "Anda adalah asisten analisis operasional untuk prototype manajemen tempat tidur rumah sakit. "
        "Jawab dalam Bahasa Indonesia yang ringkas untuk staf rumah sakit. Gunakan hanya data agregat JSON. "
        "Jangan mengarang tren historis atau memprediksi masa depan karena tidak ada data time-series. "
        "Jangan memberi keputusan klinis atau menugaskan pasien ke bed. Jelaskan bahwa data sintetis hanya untuk demo. "
        "Kembalikan JSON valid dengan keys summary (string, 2-4 kalimat) dan recommended_actions (array 2-4 tindakan praktis). "
        "Tindakan harus berupa pemeriksaan operasional yang aman, bukan instruksi klinis."
    )
    request_body = {
        "model": model,
        "instructions": instructions,
        "input": "Analisis snapshot okupansi ini untuk demo dan berikan ringkasan operasional. Data JSON: " + json.dumps(payload, ensure_ascii=False),
        "max_output_tokens": 350,
    }
    try:
        async with httpx.AsyncClient(timeout=35.0) as client:
            response = await client.post(
                "https://api.openai.com/v1/responses",
                headers={"Authorization": f"Bearer {api_key}", "Content-Type": "application/json"},
                json=request_body,
            )
        if response.status_code >= 400:
            # Avoid returning provider response bodies which may contain internal details.
            raise HTTPException(status_code=502, detail=f"LLM provider returned HTTP {response.status_code}.")
        result = response.json()
        output_text = result.get("output_text", "").strip()
        if not output_text:
            for item in result.get("output", []):
                for content in item.get("content", []):
                    if content.get("type") == "output_text":
                        output_text += content.get("text", "")
        parsed = json.loads(output_text)
        summary = str(parsed.get("summary", "Ringkasan tidak tersedia."))[:1200]
        actions = [str(x)[:240] for x in parsed.get("recommended_actions", [])[:4]]
        if not actions:
            actions = ["Verifikasi status bed pada sistem operasional sebelum mengambil tindakan."]
        return InsightResponse(
            ward_name=snapshot.ward_name,
            data_mode="synthetic_demo",
            occupancy_rate=occupancy_rate,
            risk_level=risk,
            summary=summary,
            recommended_actions=actions,
            limitations=[
                "Menggunakan data sintetis untuk demonstrasi, bukan data rumah sakit aktual.",
                "Tidak tersedia riwayat bertimestamp, sehingga ini bukan prediksi okupansi.",
                "Verifikasi status aktual dan SOP rumah sakit sebelum mengambil tindakan.",
            ],
            model=model,
        )
    except HTTPException:
        raise
    except httpx.TimeoutException:
        raise HTTPException(status_code=504, detail="Permintaan LLM melewati batas waktu. Coba lagi.")
    except (httpx.HTTPError, ValueError, KeyError, TypeError):
        raise HTTPException(status_code=502, detail="Respons LLM gagal diproses. Periksa konfigurasi model/backend.")
