param(
    [Parameter(Mandatory = $true)]
    [string]$Name,

    [Parameter(Mandatory = $true)]
    [string]$RepositoryUrl
)

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
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

    git commit -m "Add $Name submodule"
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to commit submodule '$Name'."
    }

    Write-Output "Submodule '$Name' added and committed successfully."
}
finally {
    Pop-Location
}