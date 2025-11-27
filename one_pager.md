# AgroSense — One-page Summary

AgroSense: bilingual (Hausa + English) assistant delivering real-time market prices, short-term price forecasts, and verified buyer contacts to smallholder farmers.

Why it matters
- Farmers often lack timely price signals and trusted buyers, causing revenue loss.
- Simple, local-language access to price info and verified buyers increases farmer bargaining power.

MVP (tonight)
- Market price query via chat (text)
- 7-day price forecast stub (rule-based/ML later)
- Verified buyer lookup (demo registry)

Tech (MVP)
- Bot → Azure Function (local demo uses CSV) → (Azure mode) Cognitive Search + Azure OpenAI + Azure ML + Cosmos DB
- Secrets: Key Vault + Managed Identity (templates included)

Demo checklist (90s)
1. Ask: "How much is maize in Kano?" → show price + forecast + recommendation
2. Ask: "Will maize price rise this week in Kano?" → show forecast
3. Ask: "Show verified buyers for maize in Kano" → show buyer list

How to run locally
```powershell
npm install
npm start
# then run sample queries from run_instructions.md or use local UI
```

Cloud deployment (instructions included)
- Use `deploy_azure.ps1` and `deploy_code.ps1` to create Function App, Key Vault, and deploy code. Set environment variables for OPENAI_KEY, SEARCH_KEY, COSMOS_CONN locally before running.

Contact & ask
- Pilot request: cloud credits, telco partner for USSD, mentor for ML forecast improvement.

Repo: include this one-pager, the slides (`presentation/agrosense_slides.html`), and a short video showing the local demo and one cloud endpoint (if deployed).