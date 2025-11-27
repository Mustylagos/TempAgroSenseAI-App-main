<#
PowerShell deployment helper for AgroSense demo (runs Azure CLI commands).
Edit the variables at the top before running. You must be signed in via `az login` and have the correct subscription selected.
This script will:
 - create a Storage Account (required for Function App)
 - create a Function App (Node runtime)
 - assign a system-assigned managed identity to the Function App
 - create an Azure Key Vault and store OPENAI/SEARCH/COSMOS secrets (if environment variables provided)
 - grant the Function App access to Key Vault secrets
 - set App Settings to reference Key Vault secrets (KeyVault references)

WARNING: Replace placeholder values before running. Do not paste secrets into source control.
#>

# === Configuration (EDIT THESE) ===
$subscriptionId = '' # optional: set to your subscription id
$rgName = 'agrosense-rg'
$location = 'EastUS'
$storageName = 'agrosensedemostore01' # must be globally unique, letters and numbers, 3-24 chars
$funcAppName = 'agrosense-func-mustyh1249' # e.g. 'agrosense-func-<you>' (must be globally unique)
$keyVaultName = 'agrosense-kv-mustyh1249' # replace with your unique Key Vault name, e.g. 'agrosense-kv-<you>'

# Optional: the script can pick up secrets from environment variables instead of hardcoding them.
# It checks a few common names so you can use AZURE_OPENAI_KEY, OPENAI_KEY, AZURE_SEARCH_KEY, SEARCH_KEY,
# COSMOSDB_KEY or COSMOS_CONN depending on your environment.
$openaiKey = $env:AZURE_OPENAI_KEY
if (-not $openaiKey) { $openaiKey = $env:OPENAI_KEY }

$searchKey = $env:AZURE_SEARCH_KEY
if (-not $searchKey) { $searchKey = $env:SEARCH_KEY }

$cosmosConn = $env:COSMOSDB_KEY
if (-not $cosmosConn) { $cosmosConn = $env:COSMOS_CONN }

# Optional: an explicit search endpoint may be provided as AZURE_SEARCH_ENDPOINT
$searchEndpoint = $env:AZURE_SEARCH_ENDPOINT

npm install @azure/cosmos csv-parse
$searchEndpoint = $env:https://agrosense-search.search.windows.net

if ($subscriptionId) { az account set --subscription $subscriptionId }

Write-Host "Using resource group: $rgName in $location"

# Create storage account
az storage account create --name $storageName --resource-group $rgName --location $location --sku Standard_LRS | Out-Null

# Create Function App (consumption plan)
az functionapp create --resource-group $rgName --consumption-plan-location $location --name $funcAppName --storage-account $storageName --runtime node --runtime-version 18 | Out-Null

# Assign system-managed identity to Function App
$identity = az functionapp identity assign --name $funcAppName --resource-group $rgName | ConvertFrom-Json
$principalId = $identity.principalId
Write-Host "Assigned managed identity principalId: $principalId"

# Create Key Vault if not exists
az keyvault create --name $keyVaultName --resource-group $rgName --location $location | Out-Null

# If we have secrets in environment variables, set them in Key Vault
if ($openaiKey) { az keyvault secret set --vault-name $keyVaultName --name OPENAI_KEY --value $openaiKey | Out-Null; Write-Host 'OPENAI_KEY set in Key Vault' }
if ($searchKey) { az keyvault secret set --vault-name $keyVaultName --name SEARCH_KEY --value $searchKey | Out-Null; Write-Host 'SEARCH_KEY set in Key Vault' }
if ($cosmosConn) { az keyvault secret set --vault-name $keyVaultName --name COSMOS_CONN --value $cosmosConn | Out-Null; Write-Host 'COSMOS_CONN set in Key Vault' }

# Grant the Function App access to Key Vault secrets
az keyvault set-policy --name $keyVaultName --object-id $principalId --secret-permissions get list | Out-Null
Write-Host 'Granted Function App access to Key Vault (get,list)'

# Configure Function App settings to read secrets from Key Vault via references
$openaiRef = "@Microsoft.KeyVault(SecretUri=https://${keyVaultName}.vault.azure.net/secrets/OPENAI_KEY)"
$searchRef = "@Microsoft.KeyVault(SecretUri=https://${keyVaultName}.vault.azure.net/secrets/SEARCH_KEY)"
$cosmosRef = "@Microsoft.KeyVault(SecretUri=https://${keyVaultName}.vault.azure.net/secrets/COSMOS_CONN)"

# Build app settings. Use Key Vault references for secrets and optionally include a plain SEARCH_ENDPOINT if provided.
$settings = @(
	'USE_AZURE=true',
	"OPENAI_KEY=$openaiRef",
	"SEARCH_KEY=$searchRef",
	"COSMOS_CONN=$cosmosRef"
)
if ($searchEndpoint) { $settings += "SEARCH_ENDPOINT=$searchEndpoint" }

az functionapp config appsettings set --name $funcAppName --resource-group $rgName --settings $settings | Out-Null
Write-Host 'App settings configured (USE_AZURE=true and Key Vault reference settings). If AZURE_SEARCH_ENDPOINT was set in your environment it was added as SEARCH_ENDPOINT.'

# Output function endpoint
$defaultHostName = az functionapp show --name $funcAppName --resource-group $rgName --query defaultHostName -o tsv
Write-Host "Function App created: https://$defaultHostName/api/handleMessage"

Write-Host 'Deployment helper finished. Test the endpoint or deploy your code from this working directory (zip deploy or VS Code).'
