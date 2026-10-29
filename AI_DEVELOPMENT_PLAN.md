# SmarterBMS AI Prototype Plan

## Current status

The current application uses mock hospital data. It does not yet include a production LLM integration or a validated bed-occupancy forecasting model. Do not describe AI-generated outputs as operational predictions until they have been evaluated against real historical data.

## Recommended design

1. **Forecasting service (Python)**: estimate ward-level occupancy and available-bed counts over a defined horizon. Start with a simple baseline (last-known occupancy / moving average), then compare against a supervised model such as LightGBM or XGBoost when enough timestamped history exists.
2. **Decision-support rules**: apply explicit constraints and operational rules to forecasts. This layer should be deterministic and testable.
3. **LLM explanation service**: convert validated forecast results and approved operational context into concise explanations for authorized hospital staff. The LLM must not invent current bed status or independently assign patients to beds.
4. **Flutter client**: display forecast, uncertainty, timestamp, contributing factors, and a clear demo-data label.

## Mock-data demo

A demo can use synthetic time-series data to exercise the end-to-end UI and API contract. Synthetic results must be labeled as simulated and must not be presented as clinically or operationally validated.

## Suggested API contract

`GET /api/wards/{ward_id}/occupancy-forecast?horizon_hours=24`

Example response:

```json
{
  "ward_id": "ward-demo-a",
  "generated_at": "2026-10-30T00:00:00Z",
  "data_mode": "synthetic_demo",
  "horizon_hours": 24,
  "forecast": [
    {"at": "2026-10-30T06:00:00Z", "occupancy_rate": 0.72, "available_beds": 14}
  ],
  "limitations": ["Synthetic demo data; not validated for operational use."]
}
```

## Security and deployment notes

- Never ship an LLM provider API key inside a Flutter application or APK.
- Call the LLM through a backend service, with authentication, authorization, rate limits, and audit logs.
- Do not send patient names, medical record numbers, or diagnoses to an external LLM unless the hospital has approved the data flow and appropriate safeguards are in place.
- Evaluate forecasting against chronological holdout data and compare it with simple baselines before claiming value.
