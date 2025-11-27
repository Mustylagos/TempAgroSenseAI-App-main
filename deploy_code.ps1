# Deploy code to Function App using zip deploy.
# Edit $funcAppName and $rgName or pass them as parameters.
param(
  [string]$funcAppName = '<YOUR_FUNC_APP_NAME>',
  [string]$rgName = 'agrosense-rg'
)

# Create zip of current workspace (exclude node_modules to make smaller)
$zipName = "agrosense_deploy.zip"
if (Test-Path $zipName) { Remove-Item $zipName }

# Use Compress-Archive (Windows PowerShell)
# Exclude node_modules
$files = Get-ChildItem -Path . -Recurse -Force | Where-Object { $_.FullName -notmatch "\\node_modules\\" -and $_.Name -ne $zipName }
$tempDir = Join-Path $env:TEMP "agrosense_deploy_temp"
if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
New-Item -ItemType Directory -Path $tempDir | Out-Null
foreach ($f in $files) {
  $dest = Join-Path $tempDir ($f.FullName.Substring((Get-Location).Path.Length).TrimStart('\\'))
  $destDir = Split-Path $dest -Parent
  if (!(Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
  if ($f.PSIsContainer) { continue }
  Copy-Item $f.FullName -Destination $dest -Force
}
Compress-Archive -Path (Join-Path $tempDir '*') -DestinationPath $zipName -Force

Write-Host "Created $zipName — deploying to $funcAppName in $rgName"
az functionapp deployment source config-zip --resource-group $rgName --name $funcAppName --src $zipName

Write-Host 'Deployment finished. Check Function logs in Azure Portal or use az webapp log tail.'
