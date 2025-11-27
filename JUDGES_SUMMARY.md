AgroSense — Judges' One-Page Summary

Elevator pitch
AgroSense helps smallholder farmers in Northern Nigeria get market prices, 7‑day price forecasts, and verified buyer contacts in Hausa and English via SMS/WhatsApp/Web — reducing information asymmetry and improving bargaining power.

Top 3 features (MVP)
- Market price lookup: natural-language queries return the latest market price for a commodity and market (English + Hausa).
- 7‑day price forecast stub: short forecasts with explanation of confidence and recommended actions.
- Verified buyer directory: quick lookup of vetted buyers by commodity and region.

Technical highlights
- Hybrid demo: local server + Azure-ready wiring (Azure Cognitive Search + Azure OpenAI + Cosmos DB placeholders). Toggle `USE_AZURE` to switch between local CSV mode and cloud-backed mode.
- Secure-by-design: keys stored in Azure Key Vault and referenced by the Function App (managed identity). Deploy script `deploy_azure.ps1` configures Key Vault references for App Settings.
- Lightweight, reproducible demo: Node.js function + Express local wrapper, seeder for Cosmos (`scripts/seed_cosmos.js`), and automated setup helper (`scripts/run_full_setup.ps1`).

What to look for during the demo (90–120s)
1. Short intro (15s): Problem + Impact for smallholder farmers.
2. Live demo (60–75s): Ask in Hausa and English for a commodity price, show forecast, then request verified buyers — show how responses cite sources and include action items.
3. Tech callout (15–30s): Mention RAG pattern, Key Vault, managed identity, and seeding/indexing process.

Scoring cues for judges
- Impact: Clear value to farmers (relevance, bilingual support, local channels).
- Innovation & Technical Complexity: RAG architecture, multi-channel support (SMS/WhatsApp), and secure secret handling for cloud deployment.
- Feasibility & Scalability: Demonstrated local prototype + Azure deployment scripts and seeder for realistic data.

Deliverables included in this repo
- `function/index.js` — core HTTP handler (local + Azure toggle)
- `local_server.js` — express wrapper for quick demo
- `sample_data/markets.csv`, `sample_data/buyers.csv` — demo datasets
- `scripts/seed_cosmos.js` — Cosmos seeder
- `scripts/run_full_setup.ps1` — full setup helper (retrieves secrets, seeds DB, runs `deploy_azure.ps1`)
- `deploy_azure.ps1` & `deploy_code.ps1` — deployment helpers (Key Vault, Function App)
- Presentation assets: `presentation/agrosense_slides.html`, `one_pager.md`, `README_for_judges.md` (this file)

How judges can run the demo (fast)
- Option A (Live URL): Visit the deployed Function App URL (if available) and interact via the web chat UI (link in repo README).
- Option B (Local quick run): open PowerShell, set required env vars, start local server and query with curl. See `/submission/QUICK_RUN.md` for exact one-liners.

Contact / Submission
- GitHub: (include repo URL)
- Video: (include demo video link)
- Short notes: The repo includes a short speaker script and Hausa phrases for bilingual presentation.

Notes for reviewers
- If cloud resources are not accessible from your region, the local server reproduces the core flows. `USE_AZURE=false` in the Function App will use sample CSVs.
- For security, keys are not stored in the repo. The deploy scripts read keys from environment variables and write them into Key Vault only.

Thank you for reviewing AgroSense — we focused on measurable farmer impact, bilingual accessibility, and a secure, deployable architecture.