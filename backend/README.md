# SmarterBMS AI backend (prototype)

Backend FastAPI that calls the OpenAI Responses API to produce an operational explanation from **aggregate synthetic bed counts only**. It does not predict future occupancy yet; there is no timestamped historical dataset.

## 1. Requirements

- Python 3.10+
- An OpenAI API key with API billing/model access enabled

## 2. Run locally

From the repository root:

```bash
cd backend
python -m venv .venv
# Windows PowerShell
.venv\Scripts\Activate.ps1
# macOS/Linux: source .venv/bin/activate
pip install -r requirements.txt
copy .env.example .env
```

Edit `backend/.env` and set `OPENAI_API_KEY`. The key must stay in this backend `.env`; do not place it in Flutter source, `--dart-define`, or an APK. Change `OPENAI_MODEL` if the model configured for your API project differs.

Start the API:

```bash
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

Verify `http://127.0.0.1:8000/health`. The endpoint reports whether a key is configured, never the key itself. Interactive API docs are at `/docs`.

## 3. Connect Flutter

- Android emulator: `http://10.0.2.2:8000` is the default.
- Physical phone: connect phone and laptop to the same trusted Wi-Fi. Find the laptop's LAN IPv4 address, then run Flutter with the LAN URL, for example:

```bash
flutter run --dart-define=SMARTERBMS_API_BASE_URL=http://192.168.1.10:8000
```

Replace `192.168.1.10` with the laptop's actual LAN IP. Allow inbound TCP port 8000 in the laptop firewall for the private network only if needed. For Flutter Web, use `http://localhost:8000` on the same computer or set the define explicitly.

This local setup uses HTTP and Android cleartext traffic for development. Do not deploy it to the public internet. Production deployment must use HTTPS, restrict CORS, add authentication/authorization, rate limits, and audit logging.

## Endpoint

`POST /api/ai/occupancy-insight`

Request fields: `ward_name`, `total_beds`, `available_beds`, `occupied_beds`, `booked_beds`, `cleaning_beds`, `maintenance_beds`, `data_mode: "synthetic_demo"`.

The service calculates occupied/total BOR and a simple rule-based risk band, then asks the LLM for a short Indonesian explanation and operational checks. It intentionally rejects invalid counts and never receives patient names, IDs, or diagnoses.

## Limitations

- Mock/synthetic data only.
- This is an LLM explanation, not a validated occupancy forecast.
- Recommendations are for human review, not automated bed assignment or clinical decisions.
- OpenAI API usage may incur charges. Check current model availability and pricing in your API account.
