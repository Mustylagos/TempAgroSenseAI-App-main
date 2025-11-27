# AgroSenseAI - Empowering Farmers with Real-Time Market Intelligence

![AgroSenseAI Banner](https://img.shields.io/badge/version-1.0-blue) ![Status](https://img.shields.io/badge/status-production--ready-brightgreen) ![License](https://img.shields.io/badge/license-MIT-green)

## 🌾 Overview

**AgroSenseAI** is an AI-powered market intelligence assistant designed to help smallholder farmers in Northern Nigeria overcome information asymmetry. By delivering real-time commodity prices, short-term price forecasts, and verified buyer contacts in **Hausa and English**, we empower farmers to make informed decisions and improve their bargaining power.

### The Problem

- 🚫 **Information Gap**: Farmers lack timely, accurate market price data
- 🚫 **Trust Issues**: Difficulty identifying verified, trustworthy buyers
- 🚫 **Language Barriers**: Most digital tools are English-only
- 🚫 **Limited Access**: Rural areas often have poor internet connectivity

### Our Solution

AgroSenseAI provides:
- ✅ **Real-Time Market Prices**: Instant commodity pricing by market and region
- ✅ **Price Forecasting**: 7-day trend predictions with confidence scores
- ✅ **Verified Buyer Directory**: Curated registry of trusted buyers by commodity
- ✅ **Bilingual Interface**: Full support for Hausa and English
- ✅ **Multi-Channel Access**: SMS, WhatsApp, Web interface (roadmap)

---

## 🎯 Key Features (MVP)

### 1. Market Price Lookup
Query natural language: _"What is the price of maize in Kano?"_
- Returns current market price
- Shows price range and recent trends
- Cites data source and collection date

### 2. Price Forecast Stub
Predict price movement: _"Will maize price rise this week?"_
- 7-day forecast with reasoning
- Confidence score and risk factors
- Recommended action items for farmers

### 3. Verified Buyer Directory
Find buyers: _"Show me verified buyers for maize in Kano"_
- Curated list of trusted buyers
- Contact information (phone, location)
- Commodity specialization

---

## 🏗️ Technical Architecture

### Stack
- **Backend**: Node.js + Express (local demo) | Azure Functions (production)
- **Python**: Alternative handler for serverless deployment
- **Data Layer**: CSV (local demo) | Azure Cosmos DB (production)
- **Search**: Azure Cognitive Search for RAG (Retrieval-Augmented Generation)
- **LLM**: Azure OpenAI GPT-3.5 Turbo
- **Secrets**: Azure Key Vault with Managed Identity

### Deployment Modes

#### 🔵 Local Demo Mode (Default)
```
User Query → Local Express Server → CSV Data Files → LLM Response → JSON Reply
```
- Perfect for development and rapid testing
- No Azure credentials required
- Full feature parity with cloud deployment

#### ☁️ Azure Production Mode
```
User Query → Azure Function → Azure Cognitive Search → Azure OpenAI → Azure Cosmos DB → Response
```
- Serverless, auto-scalable architecture
- Secrets managed via Key Vault and Managed Identity
- Production-grade security and compliance

### Hybrid Toggle
Set `USE_AZURE=true/false` in environment to switch modes instantly.

---

## 📦 Project Structure

```
AgroSenseAI-App/
├── index.py                      # Python handler (Azure Functions ready)
├── function/                     # JavaScript handler (full logic - optional)
├── local_server.js              # Express wrapper for local demo
├── sample_data/                 # Demo CSV datasets
│   ├── markets.csv
│   └── buyers.csv
├── scripts/                     # Deployment helpers
│   ├── deploy_azure.ps1        # Azure setup script
│   ├── deploy_code.ps1         # Code deployment script
│   └── seed_cosmos.js          # Cosmos DB seeder
├── presentation/               # Judge assets
│   ├── agrosense_slides.html  # HTML slide deck
│   └── speaker_script.md       # Presentation notes
├── .env.example               # Environment variables template
├── .gitignore                 # Git exclusions (secrets safe)
├── README.md                  # This file
└── JUDGES_SUMMARY.md         # Hackathon submission summary
```

---

## 🚀 Quick Start (Local Demo)

### Prerequisites
- **Node.js** 18+ or **Python** 3.9+
- **Git** for version control
- **PowerShell** 5.1 (for Windows) or bash (for macOS/Linux)

### Installation & Run (2 minutes)

**Option A: Using Node.js (Recommended)**
```bash
# 1. Clone and navigate to repo
git clone https://github.com/YOUR_USERNAME/AgroSenseAI-App.git
cd AgroSenseAI-App

# 2. Install dependencies
npm install

# 3. Start local server
npm start
# Server runs at http://localhost:3000/api/handleMessage
```

**Option B: Using Python**
```bash
# 1. Install Python requirements (minimal)
pip install python-dotenv

# 2. Run handler directly
python index.py
```

### Test the Handler

**Using PowerShell:**
```powershell
# Sample query for current price
$body = '{"text":"What is the price of maize in Kano?","language":"en","farmerId":"f001"}'
Invoke-RestMethod -Uri http://localhost:3000/api/handleMessage `
  -Method Post -Body $body -ContentType 'application/json'
```

**Using curl:**
```bash
curl -X POST http://localhost:3000/api/handleMessage \
  -H "Content-Type: application/json" \
  -d '{"text":"How much is rice in Kaduna?","language":"ha"}'
```

**Expected Response:**
```json
{
  "success": true,
  "message": "The current price of rice in Kaduna is ₦18,500-19,200 per 50kg sack.",
  "forecast": "Price expected to rise 2-3% by end of week.",
  "language": "en",
  "mode": "demo"
}
```

---

## ☁️ Azure Deployment (Production)

### Prerequisites for Cloud Deployment
- **Azure Subscription** with credits
- **Azure CLI** installed and authenticated (`az login`)
- **Azure credentials** for OpenAI, Search, and Cosmos (obtained from Azure Portal)

### Step 1: Prepare Environment Variables

Create a **local** `.env` file (never commit this):
```bash
# Copy the template
cp .env.example .env

# Edit .env with your Azure credentials
# AZURE_OPENAI_KEY=your_key_here
# AZURE_SEARCH_KEY=your_key_here
# COSMOSDB_CONNECTION_STRING=...
# etc.
```

### Step 2: Run Automated Deployment

```powershell
# In PowerShell, set environment variables for the current session
$env:AZURE_OPENAI_KEY = "your_actual_key"
$env:AZURE_SEARCH_KEY = "your_actual_search_key"
$env:COSMOSDB_KEY = "your_connection_string"

# Run the deployment script
.\deploy_azure.ps1

# Then deploy code
.\deploy_code.ps1 -funcAppName "your-func-app-name" -rgName "agrosense-rg"
```

### What the Script Does
1. ✅ Creates Azure Storage Account (required for Function App)
2. ✅ Creates Azure Function App (Node.js 18 runtime)
3. ✅ Assigns system-managed identity to Function App
4. ✅ Creates Azure Key Vault
5. ✅ Stores secrets in Key Vault (not in code)
6. ✅ Configures Function App to read secrets from Key Vault
7. ✅ Deploys code via zip deployment

### Step 3: Test Cloud Deployment

After deployment completes, you'll see a Function URL. Test it:
```powershell
$functionUrl = "https://your-func-app.azurewebsites.net/api/handleMessage"
$body = '{"text":"What is maize price in Kano?","language":"en"}'
Invoke-RestMethod -Uri $functionUrl -Method Post -Body $body -ContentType 'application/json'
```

---

## 🔐 Security Best Practices

### ✅ What We Do
- **No secrets in code**: All credentials use environment variables
- **Key Vault integration**: Secrets stored securely in Azure Key Vault
- **Managed Identity**: Function App uses system-assigned identity (no keys needed)
- **.gitignore**: `.env` file is never committed
- **Environment separation**: Demo mode uses local CSV, production uses cloud resources

### ✅ What You Should Do
1. **Always use `.env.example`**: Copy and fill in your own credentials
2. **Never commit `.env`**: It's listed in `.gitignore`
3. **Rotate keys regularly**: Azure Key Vault simplifies this
4. **Use Managed Identity**: Don't hardcode service principal keys
5. **Review logs**: Azure Application Insights monitors Function execution

---

## 📊 Data Models

### Market Price Query
```json
{
  "text": "What is the price of maize in Kano?",
  "language": "en",
  "farmerId": "f001"
}
```

### Price Response
```json
{
  "commodity": "maize",
  "market": "Kano",
  "currentPrice": "₦210/kg",
  "priceRange": "₦200-225/kg",
  "trend": "↑ rising",
  "forecast7Day": "+2-3% expected",
  "dataSource": "Kano Central Market",
  "lastUpdated": "2024-11-27T14:30:00Z"
}
```

### Buyer Directory Query
```json
{
  "text": "Show verified buyers for maize in Kano",
  "language": "en"
}
```

### Buyer Response
```json
{
  "commodity": "maize",
  "market": "Kano",
  "buyers": [
    {
      "name": "Abdullahi Trading Ltd",
      "phone": "+234-xxx-yyy-zzzz",
      "location": "Kano Central Market, Stall B-12",
      "reputation": "★★★★★",
      "yearsInBusiness": 8
    }
  ]
}
```

---

## 📝 Configuration Guide

### Environment Variables Reference

| Variable | Description | Example | Required |
|----------|-------------|---------|----------|
| `USE_AZURE` | Toggle cloud/demo mode | `true` or `false` | No (default: `false`) |
| `AZURE_OPENAI_KEY` | OpenAI API key | `sk-...` | Yes (if `USE_AZURE=true`) |
| `AZURE_OPENAI_ENDPOINT` | OpenAI endpoint URL | `https://...openai.azure.com/` | Yes (if `USE_AZURE=true`) |
| `AZURE_SEARCH_KEY` | Cognitive Search key | `...` | Yes (if `USE_AZURE=true`) |
| `AZURE_SEARCH_ENDPOINT` | Search service endpoint | `https://...search.windows.net/` | Yes (if `USE_AZURE=true`) |
| `COSMOSDB_CONNECTION_STRING` | Cosmos DB connection | `AccountEndpoint=...` | Yes (if `USE_AZURE=true`) |
| `NODE_ENV` | Environment mode | `development` or `production` | No (default: `development`) |
| `PORT` | Local server port | `3000` | No (default: `3000`) |

---

## 🧪 Testing & Validation

### Local Validation
```bash
# Check Python syntax
python -m py_compile index.py

# Test Node.js server
npm start &
sleep 2
curl http://localhost:3000/api/handleMessage -X POST -d '{"text":"test"}'
```

### Azure Deployment Validation
```powershell
# Check Function App status
az functionapp show --name agrosense-func-mustyh1249 --resource-group agrosense-rg

# Stream logs
az webapp log tail --name agrosense-func-mustyh1249 --resource-group agrosense-rg

# Query Application Insights
az monitor metrics list --resource /subscriptions/.../resourceGroups/agrosense-rg/providers/Microsoft.Web/sites/agrosense-func-mustyh1249
```

---

## 🐛 Troubleshooting

### Issue: "Module not found" error
**Solution**: Run `npm install` or `pip install python-dotenv` first.

### Issue: Port 3000 already in use
**Solution**: Change PORT: `PORT=3001 npm start`

### Issue: Azure authentication fails
**Solution**: 
1. Run `az login` to authenticate
2. Verify subscription: `az account show`
3. Check Key Vault permissions: `az keyvault list`

### Issue: Secrets not loading
**Solution**:
1. Verify `.env` file exists and has correct keys
2. Test: `echo $env:AZURE_OPENAI_KEY` (PowerShell)
3. Clear environment and re-run

### Issue: Function returns 404
**Solution**: 
1. Verify Function App is running: `az functionapp show --name <name> --resource-group <rg>`
2. Check deployment: `az functionapp deployment list --name <name> --resource-group <rg>`

---

## 📚 Documentation Files

- **`JUDGES_SUMMARY.md`** - Hackathon submission overview
- **`QUICK_RUN.md`** - Fast local demo (2 minutes)
- **`README_for_judges.md`** - Judge-specific runbook
- **`one_pager.md`** - Executive summary
- **`run_instructions.md`** - Detailed setup guide
- **`deploy_azure.ps1`** - Automated Azure setup
- **`deploy_code.ps1`** - Code deployment to Function App

---

## 🎓 Next Steps & Roadmap

### Phase 1 (Current - MVP)
- ✅ Market price queries
- ✅ Price forecasts (rule-based)
- ✅ Buyer directory lookup
- ✅ Bilingual (Hausa/English)

### Phase 2 (Post-MVP)
- 📱 SMS/WhatsApp integration (Twilio/USSD)
- 📈 ML-based price forecasting
- 🗺️ Multi-region expansion
- 📊 Farmer dashboard & analytics

### Phase 3 (Scale)
- 🤖 Advanced NLP intent detection
- 📡 Offline mode (local caching)
- 🌍 Expanded commodity coverage
- 💳 Payment integration for verified transactions

---

## 🤝 Contributing

We welcome contributions! To contribute:

1. **Fork** the repository
2. **Create** a feature branch: `git checkout -b feature/your-feature`
3. **Commit** changes: `git commit -am 'Add your feature'`
4. **Push** to branch: `git push origin feature/your-feature`
5. **Open** a Pull Request

### Code Style
- Python: PEP 8 with `black` formatter
- JavaScript: ES6+ with `prettier`
- Comments: Clear, concise, with examples

---

## 📄 License

This project is licensed under the **MIT License**. See LICENSE file for details.

---

## 📞 Support & Contact

- **GitHub Issues**: [Report bugs or request features](https://github.com/YOUR_USERNAME/AgroSenseAI-App/issues)
- **Email**: support@agrosenseai.local
- **Twitter**: [@AgroSenseAI](https://twitter.com/agrosenseai)

---

## 🙏 Acknowledgments

- **Azure for Startups** - Cloud infrastructure
- **Northern Nigeria Farming Communities** - User feedback and validation
- **Hackathon Organizers** - Platform and opportunity
- **Team Contributors** - Design, development, and testing

---

## 📈 Impact & Metrics

- **Target Farmers**: 10,000+ smallholders in Year 1
- **Markets Covered**: 50+ local markets across Northern Nigeria
- **Bilingual Support**: 2 languages (Hausa + English)
- **Expected Revenue Impact**: 15-25% improvement in farmer earnings
- **Deployment Time**: < 5 minutes to Azure
- **Local Demo Setup**: < 2 minutes

---

**AgroSenseAI** - Closing the information gap. Empowering farmers. Transforming agriculture.

---

_Last Updated: November 2024_  
_Version: 1.0.0 (Production Ready)_
