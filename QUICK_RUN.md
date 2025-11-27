Quick run (fastest path for judges)

Goal: Run a local demo in ~2 minutes using the sample data.

Prerequisites
- Node.js installed (LTS)
- PowerShell (Windows) or a compatible shell

Steps (copy/paste into PowerShell from the repo root)

1) Install dependencies (one time)

```powershell
npm install
```

2) Start the local server

```powershell
# starts the express wrapper which calls the function handler
npm start
# by default the server listens at http://localhost:3000/api/handleMessage
```

3) Send a sample request (in a second terminal or PowerShell window)

```powershell
# Example: ask for current price of maize in Kano
$body = '{"text":"What is the price of maize in Kano?","lang":"en"}'
curl -H "Content-Type: application/json" -d $body http://localhost:3000/api/handleMessage
```

Expected output (JSON or plain text)
- A bilingual reply (English + Hausa) with a current price, a short 7-day forecast stub, and, if requested, a list of verified buyers.

Optional: Run the full Azure setup (only if you want a cloud-backed demo)

• Create a local `.env` (not committed) with your secrets — this repo ignores `.env`.

Example `.env` (placeholders — do not commit real keys):

```text
AZURE_OPENAI_KEY=your_real_key_here
AZURE_SEARCH_KEY=your_real_key_here
COSMOSDB_KEY=your_real_key_here
AZURE_ENDPOINT=your_azure_endpoint_here
AZURE_KEY=your_azure_key_here
```

• For a temporary PowerShell session you can set environment variables like this (current session only):

```powershell
$env:AZURE_OPENAI_KEY = "your_real_key_here"
$env:AZURE_SEARCH_KEY = "your_real_key_here"
$env:COSMOSDB_KEY = "your_real_key_here"
```

The tools and helpers in this repo will read the keys from environment variables (recommended) or from Key Vault when using the Azure deploy flow.

- Run the automated helper (this will seed Cosmos and call the deploy script):git filter-branch --force --index-filter `
"git rm --cached --ignore-unmatch QUICK_RUN.md deploy_azure.ps1" `
--prune-empty --tag-name-filter cat -- --all


```powershell
.\	emplates\run_full_setup.ps1 -CosmosAccountName 'your-account-name' -KeyVaultName 'your-keyvault-name'
```

(If you prefer, use `.\
un_full_setup.ps1` from `scripts` folder — follow prompts.)

Notes
- The local mode is fully functional and sufficient for judging; cloud mode shows deployment readiness and secure secret management via Key Vault.
- If anything errors, copy the terminal output and paste it into the repo issue tracker or share it with the dev for fast help.