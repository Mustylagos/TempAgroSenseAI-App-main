# Run instructions (Windows PowerShell)

Prereqs (local demo):
- Node.js 18+ installed
- (Optional) Azure Functions Core Tools if you want to run as a Function App locally

Quick local run (simple Node script)
1. From the repository root, run PowerShell and start a simple HTTP server using `node` and the sample function wrapper below.

# Start a very small Express wrapper for testing
# Save `local_server.js` (optional) and run `node local_server.js`

local_server.js example (quick):
```javascript
const express = require('express');
const app = express();
app.use(express.json());
const handler = require('./function/index');
app.post('/api/handleMessage', (req, res) => {
  // mimic Azure Function context
  const context = { res: null, log: console.log };
  handler(context, { body: req.body }).then(() => {
    res.json(context.res.body);
  }).catch(e => res.status(500).send(e.message));
});
app.listen(3000, ()=>console.log('Listening http://localhost:3000'));
```

PowerShell commands:
```powershell
# install express for quick test
npm init -y
npm install express
# then run server
node local_server.js
```

Test with curl (PowerShell):
```powershell
$body = '{"farmerId":"f001","text":"How much is maize in Kano?","language":"en"}'
Invoke-RestMethod -Uri http://localhost:3000/api/handleMessage -Method Post -Body $body -ContentType 'application/json'
```

Azure Function run (optional)
- If you prefer to run as an Azure Function locally, install Azure Functions Core Tools and create a function project and copy `function/index.js` into an HTTP trigger function template.

Notes
- This demo uses local CSVs and templated prompt responses. Replace with Cognitive Search + Azure OpenAI + ML endpoints for production. I can generate that integration next if you want.

Twilio / WhatsApp demo (optional)
1. Start the local server (from above) and then run the Twilio webhook demo in another terminal:

```powershell
# from repository root
npm install axios body-parser
node integration/twilio_sample.js
```

2. Configure Twilio (or simulate a POST) to `http://localhost:4000/twilio/webhook`.

Azure integration notes
- I added `integration/azure_integration_template.js` with helper functions and TODOs. To wire real services, set environment variables for keys and replace the CSV logic in `function/index.js` to call those helpers. I can do the wiring and a PR if you give me permission to add your keys or if you run deploy steps locally.

Quick checklist before judges
- Run `npm install` and `npm start`.
- Run the Twilio webhook (optional) if you want to demo WhatsApp/SMS.
- Have sample Hausa phrases ready (see `hausa_phrases.md`).

If you want, I can also create small screenshot images of the flows or export the slide deck to PPTX now.
 
Deploying to Azure (quick)
1. Edit `deploy_azure.ps1` at the top and set unique names for storage, function app and key vault. Optionally set `OPENAI_KEY`, `SEARCH_KEY`, `COSMOS_CONN` as environment variables before running so the script will store them in Key Vault.

2. Run the deployment helper in PowerShell (you must be signed in via `az login`):

```powershell
# in repository root
.\deploy_azure.ps1
```

3. After the Function App is created, deploy the code with the helper (edit the function name or pass as param):

```powershell
.\deploy_code.ps1 -funcAppName '<YOUR_FUNCAPP_NAME>' -rgName 'agrosense-rg'
```

4. Test the endpoint returned by `deploy_azure.ps1` (it prints the API URL). Use `Invoke-RestMethod` as shown earlier.

Notes on secrets & security
- The helper sets Key Vault references for App Settings; Managed Identity is used so the Function reads secrets securely. If you prefer to set raw App Settings, use `az functionapp config appsettings set` with key values (not recommended for secrets).

If you want me to prepare a ready-to-run GitHub Actions workflow to automate build + deploy, tell me and I'll add it.