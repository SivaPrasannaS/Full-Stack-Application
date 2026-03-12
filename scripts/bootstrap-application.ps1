param(
    [Parameter(Mandatory = $true)]
    [string]$Name,

    [Parameter(Mandatory = $false)]
    [string]$RepositoryName,

    [Parameter(Mandatory = $false)]
    [string]$Purpose = "Full-stack application",

    [Parameter(Mandatory = $false)]
    [ValidateSet("public", "private", "internal")]
    [string]$Visibility = "public",

    [Parameter(Mandatory = $false)]
    [string]$Owner,

    [Parameter(Mandatory = $false)]
    [string]$Description
)

function Get-RepositorySlug {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Value
    )

    $slug = $Value.ToLowerInvariant()
    $slug = $slug -replace "[^a-z0-9]+", "-"
    $slug = $slug.Trim("-")

    if ([string]::IsNullOrWhiteSpace($slug)) {
        throw "Unable to derive a valid repository slug from '$Value'."
    }

    return $slug
}

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$workspaceRoot = Split-Path $repoRoot -Parent
$childPath = Join-Path $workspaceRoot $Name

if (-not $RepositoryName) {
    $RepositoryName = Get-RepositorySlug -Value $Name
}

if (-not $Description) {
    $Description = $Purpose
}

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    throw "GitHub CLI is required but was not found on PATH."
}

gh auth status --hostname github.com | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw "GitHub CLI is not authenticated. Run 'gh auth login' first."
}

if (-not $Owner) {
    $Owner = (gh api user --jq .login).Trim()
    if ([string]::IsNullOrWhiteSpace($Owner)) {
        throw "Failed to determine the authenticated GitHub owner."
    }
}

if (Test-Path $childPath) {
    throw "Target child repository path already exists: '$childPath'."
}

New-Item -ItemType Directory -Path $childPath | Out-Null
New-Item -ItemType Directory -Path (Join-Path $childPath "frontend") | Out-Null
New-Item -ItemType Directory -Path (Join-Path $childPath "backend") | Out-Null

Set-Content -Path (Join-Path $childPath ".gitignore") -Value @(
    "frontend/node_modules/",
    "frontend/build/",
    "backend/target/",
    ".vscode/"
)

Set-Content -Path (Join-Path $childPath "README.md") -Value @(
    "# $Name",
    "",
    $Purpose,
    "",
    "## Structure",
    "",
    "- frontend/",
    "- backend/"
)

Set-Content -Path (Join-Path $childPath "frontend" ".gitkeep") -Value ""
Set-Content -Path (Join-Path $childPath "backend" ".gitkeep") -Value ""

Push-Location $childPath

try {
    git init -b main
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to initialize child repository at '$childPath'."
    }

    git add .
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to stage initial child repository contents."
    }

    git commit -m "Initial $Name commit"
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to commit initial child repository contents."
    }

    gh repo create "$Owner/$RepositoryName" --$Visibility --source . --remote origin --push --description "$Description"
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to create and push GitHub repository '$Owner/$RepositoryName'."
    }
}
finally {
    Pop-Location
}

$repositoryUrl = "https://github.com/$Owner/$RepositoryName.git"
& (Join-Path $PSScriptRoot "add-application-submodule.ps1") -Name $Name -RepositoryUrl $repositoryUrl -Purpose $Purpose
if ($LASTEXITCODE -ne 0) {
    throw "Child repository was created, but parent submodule registration failed."
}

Write-Output "Application '$Name' bootstrapped successfully."