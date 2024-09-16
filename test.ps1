# enable strict mode.
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
trap {
    Write-Host
    Write-Host "ERROR: $_"
    ($_.ScriptStackTrace -split '\r?\n') -replace '^(.*)$','ERROR: $1' | Write-Host
    ($_.Exception.ToString() -split '\r?\n') -replace '^(.*)$','ERROR EXCEPTION: $1' | Write-Host
    Exit 1
}

if (Test-Path env:WORKING_DIRECTORY) {
    Set-Location $env:WORKING_DIRECTORY
    [System.IO.Directory]::SetCurrentDirectory($env:WORKING_DIRECTORY)
}

# reset the PATH to ensure we only use our standalone binaries.
$env:PATH = 'C:\Windows\System32;C:\Windows'

# install.
Write-Output 'Installing...'
@('tmp/playwright-standalone') | ForEach-Object {
    if (Test-Path $_) {
        Remove-Item -Recurse -Force $_
    }
}
mkdir tmp/playwright-standalone | Out-Null
Expand-Archive `
    -Path dist/playwright-standalone-windows.zip `
    -DestinationPath tmp/playwright-standalone

# wrap playwright.
function playwright {
    ./playwright.cmd @Args
    if ($LASTEXITCODE) {
        throw "failed with exit code $LASTEXITCODE"
    }
}

# test.
Set-Location tmp/playwright-standalone
Write-Output 'Getting the playwright version...'
playwright --version
