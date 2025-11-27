<#
Helper to push this local repository to an existing empty GitHub repository.

Usage (PowerShell):
  1) Ensure Git is installed and you're in the repo root.
  2) Run: .\scripts\push_to_github.ps1

What the script does (interactive):
 - Detects whether a .git repo exists; if not, it initializes one
 - Prompts for preferred auth method: (1) gh (recommended), (2) SSH, (3) HTTPS+PAT
 - Adds all files, makes an initial commit, sets main as branch, adds remote, and pushes

Security notes:
 - If you use PAT (personal access token) the script will not store it; it will use it only for the single push command during the script run.
 - Using `gh auth login` (GitHub CLI) or SSH keys is recommended for safer authentication.

Please review the script before running. This script executes local git/az/gh commands on your machine; I cannot run them for you.
#>
[CmdletBinding()]
param()

function Check-Command([string]$cmd) {
    try { & $cmd --version > $null 2>&1; return $true } catch { return $false }
}

if (-not (Check-Command 'git')) { Write-Host 'Git not found. Please install Git first: https://git-scm.com/downloads' -ForegroundColor Red; exit 1 }

# Ensure we're in repo root (script's parent is scripts/)
$repoRoot = Join-Path $PSScriptRoot '..' | Resolve-Path
Set-Location $repoRoot
Write-Host "Working in repo: $($repoRoot)"

# Initialize git if needed
if (-not (Test-Path .git)) {
    Write-Host 'No git repo found. Initializing git repository...' -ForegroundColor Cyan
    git init
} else {
    Write-Host 'Git repository already initialized.' -ForegroundColor Green
}

# Ensure branch name is main
try { git branch -M main } catch {}

# Add remote if not present
$existingRemote = git remote | Out-String
if ($existingRemote.Trim()) {
    Write-Host "Existing remote(s): $existingRemote" -ForegroundColor Yellow
    $useExisting = Read-Host 'Use existing remote (press Enter) or enter new remote URL to replace it'
    if ($useExisting) {
        git remote remove origin 2>$null
        git remote add origin $useExisting
        Write-Host "Remote set to $useExisting"
    }
} else {
    Write-Host 'No git remote configured.'
}

Write-Host 'Choose authentication method to push to GitHub:'
Write-Host '  1) GitHub CLI (gh) - recommended (interactive auth, secure)'
Write-Host '  2) SSH (requires your SSH key added to GitHub account)'
Write-Host '  3) HTTPS with Personal Access Token (PAT)'
$choice = Read-Host 'Enter 1, 2 or 3'

# Stage & commit
git add .
$commitMsg = Read-Host 'Enter commit message for initial commit (default: "Initial commit — AgroSense demo")'
if (-not $commitMsg) { $commitMsg = 'Initial commit — AgroSense demo' }
# If there are no changes to commit, skip commit
$changes = git status --porcelain
if ($changes) { git commit -m "$commitMsg" } else { Write-Host 'No changes to commit.' }

if ($choice -eq '1') {
    if (-not (Check-Command 'gh')) {
        Write-Host 'GitHub CLI (gh) is not installed. Installing is recommended: https://cli.github.com/' -ForegroundColor Yellow
        $proceed = Read-Host 'Press Enter to continue and use another method, or Ctrl+C to cancel'
    } else {
        Write-Host 'Using gh CLI: ensure you are logged in. If not, the script will open an auth flow.'
        try {
            gh auth status -h github.com 2>$null
            $loggedIn = $LASTEXITCODE -eq 0
        } catch { $loggedIn = $false }
        if (-not $loggedIn) {
            Write-Host 'You are not logged in with gh. Logging in now...'
            gh auth login
        }
        $remoteUrl = Read-Host 'Enter your repository full name (owner/repo), e.g. youruser/AgroSenseAI-App'
        if (-not $remoteUrl) { Write-Host 'Repository name required.'; exit 1 }
        # set remote and push using gh
        git remote remove origin 2>$null
        git remote add origin https://github.com/$remoteUrl.git
        Write-Host 'Pushing to origin/main using gh authentication...'
        git push -u origin main
        Write-Host 'Push completed.' -ForegroundColor Green
        exit 0
    }
}

if ($choice -eq '2') {
    $sshUrl = Read-Host 'Enter your SSH remote URL (e.g. git@github.com:youruser/AgroSenseAI-App.git)'
    if (-not $sshUrl) { Write-Host 'SSH URL required.'; exit 1 }
    git remote remove origin 2>$null
    git remote add origin $sshUrl
    Write-Host 'Pushing to origin/main via SSH...'
    git push -u origin main
    Write-Host 'Push completed (SSH).' -ForegroundColor Green
    exit 0
}

if ($choice -eq '3') {
    $httpsUrl = Read-Host 'Enter your HTTPS remote URL (e.g. https://github.com/youruser/AgroSenseAI-App.git)'
    if (-not $httpsUrl) { Write-Host 'HTTPS URL required.'; exit 1 }
    $token = Read-Host 'Enter a GitHub Personal Access Token (PAT) with repo scope (input hidden)' -AsSecureString
    $ptr = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($token))
    # construct URL with token for one-time push
    $pushUrl = $httpsUrl -replace '^https://', "https://$($ptr)@"
    git remote remove origin 2>$null
    git remote add origin $httpsUrl
    Write-Host 'Pushing to origin/main via HTTPS+PAT...'
    try {
        git push $pushUrl main:main
        Write-Host 'Push completed (HTTPS+PAT).' -ForegroundColor Green
    } catch {
        Write-Host 'Push failed. Ensure the PAT is valid and has repo scope.' -ForegroundColor Red
    }
    exit 0
}

Write-Host 'No valid option chosen. Exiting.' -ForegroundColor Yellow
exit 1
