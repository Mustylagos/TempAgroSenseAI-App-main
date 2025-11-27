# AgroSense — Judge & Demo Runbook

This runbook helps you run the demo quickly (local) and describes optional Azure deploy steps.

Quick local demo (5–10 minutes)
1. Install dependencies and start server:
```powershell
cd C:\path\to\workspace
npm install
npm start
```
2. Open a browser to `presentation/agrosense_slides.html` and press Right arrow to navigate slides.
3. Open one of the screenshot HTML pages in `screenshots/` for high-quality stills:
  - `screenshots/chat_price.html`
  - `screenshots/chat_forecast.html`
  - `screenshots/chat_buyers.html`
4. Or run sample queries from PowerShell (these show real responses from handler):
```powershell
$body = '{"farmerId":"f001","text":"How much is maize in Kano?","language":"en"}'
Invoke-RestMethod -Uri http://localhost:3000/api/handleMessage -Method Post -Body $body -ContentType 'application/json'
```

Recording tips (90s)
- Start with slide 1 (title) — 5s
- Move to demo slide and switch to browser/terminal to send the query — ~40s
- Show buyer lookup and mention technical stack briefly — ~25s
- Close with ask & contact — ~10s
- Use the `speaker_script.md` for verbatim lines. Record with Win+G (Xbox Game Bar) or a phone camera.

Azure deploy (optional, for live cloud demo)
- Edit `deploy_azure.ps1` top variables (unique storage, function name, key vault). Set your keys as env vars in PowerShell before running the script:
```powershell
$env:OPENAI_KEY = '...'
$env:SEARCH_KEY = '...'
$env:COSMOS_CONN = 'AccountEndpoint=...;AccountKey=...;'
az login
.\deploy_azure.ps1
.\deploy_code.ps1 -funcAppName '<YOUR_FUNCAPP>' -rgName 'agrosense-rg'
```
- After deployment, test the HTTPS function URL printed by `deploy_azure.ps1`.

GitHub Actions CI/CD (optional)
- There is a workflow in `.github/workflows/deploy.yml` (auto-deploy template). Add `AZURE_CREDENTIALS` as a repo secret (JSON from Azure service principal) to enable automatic deployment.

Files of interest
- `function/index.js` — serverless handler (supports USE_AZURE toggle)
- `integration/azure_integration_template.js` — helper template (replace placeholders with real keys/endpoints)
- `presentation/agrosense_slides.html` — HTML slide deck
- `one_pager.md` — judges one-pager
- `run_instructions.md` — detailed run + deploy instructions

If you want, I will:
- produce a PPTX (native) and PDF export for judges, or
- walk you through the Azure deploy step-by-step now and troubleshoot any errors you paste here.

Choose next action: `PPTX`, `DeployNow`, or `RecordHelp` and I’ll proceed.