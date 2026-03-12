param(
    [Parameter(Mandatory = $true)]
    [string]$Name,

    [Parameter(Mandatory = $true)]
    [string]$RepositoryUrl,

    [Parameter(Mandatory = $false)]
    [string]$Purpose = "Application repository",

    [Parameter(Mandatory = $false)]
    [switch]$SkipIndexUpdate
)

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$applicationsFile = Join-Path $repoRoot "APPLICATIONS.md"
Push-Location $repoRoot

try {
    $existingPath = Join-Path $repoRoot $Name
    if (Test-Path $existingPath) {
        throw "A folder or submodule already exists at '$Name'."
    }

    git submodule add $RepositoryUrl $Name
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to add submodule '$Name'."
    }

    git add .gitmodules $Name
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to stage submodule changes for '$Name'."
    }

    if (-not $SkipIndexUpdate) {
        if (-not (Test-Path $applicationsFile)) {
            throw "APPLICATIONS.md was not found at '$applicationsFile'."
        }

        $entry = "| $Name | $Name | $RepositoryUrl | $Purpose |"
        $content = Get-Content -Path $applicationsFile -Raw
        if ($content.Contains($entry)) {
            throw "APPLICATIONS.md already contains an entry for '$Name'."
        }

        $marker = "## Notes"
        if (-not $content.Contains($marker)) {
            throw "APPLICATIONS.md does not contain the expected '$marker' section."
        }

        $updatedContent = $content.Replace($marker, "$entry`r`n`r`n$marker")
        Set-Content -Path $applicationsFile -Value $updatedContent
        git add APPLICATIONS.md
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to stage APPLICATIONS.md changes for '$Name'."
        }
    }

    git commit -m "Add $Name submodule"
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to commit submodule '$Name'."
    }

    Write-Output "Submodule '$Name' added and committed successfully."
}
finally {
    Pop-Location
}
