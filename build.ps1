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

# see https://nodejs.org/en/
# see https://github.com/nodejs/node
# renovate: datasource=node depName=node versioning=node
$NODEJS_VERSION='20.11.1'

# see https://playwright.dev
# see https://github.com/microsoft/playwright
# see https://www.npmjs.com/package/@playwright/test
# renovate: datasource=npm depName=@playwright/test
$PLAYWRIGHT_TEST_VERSION='1.42.1'

# reset the PATH to ensure we only use our standalone binaries.
$env:PATH = "$PWD\build\.node;C:\Windows\System32;C:\Windows"

# prepare.
mkdir -Force tmp | Out-Null

# download the node.js binaries.
$nodejsArchiveUrl="https://nodejs.org/dist/v$NODEJS_VERSION/node-v$NODEJS_VERSION-win-x64.zip"
$nodejsArchive="tmp/$(Split-Path -Leaf $nodejsArchiveUrl)"
if (!(Test-Path $nodejsArchive)) {
    Write-Output "Downloading Node.js from $nodejsArchiveUrl..."
    (New-Object System.Net.WebClient).DownloadFile($nodejsArchiveUrl, $nodejsArchive)
}

# build.
Write-Output "Extracting Node.js..."
if (Test-Path build) {
    Remove-Item -Recurse build
}
mkdir -Force build/.node | Out-Null
Expand-Archive -Path $nodejsArchive -DestinationPath build/.node
$componentDirectoryPath = Resolve-Path build/.node/node-*
Move-Item "$componentDirectoryPath/*" build/.node
Remove-Item $componentDirectoryPath
Push-Location build
Write-Output "Installing @playwright/test@$PLAYWRIGHT_TEST_VERSION..."
./.node/npm.cmd install "@playwright/test@$PLAYWRIGHT_TEST_VERSION"
if ($LASTEXITCODE) {
    throw "failed with exit code $LASTEXITCODE"
}
Write-Output "Installing the playwright browsers..."
# see https://playwright.dev/docs/next/browsers#managing-browser-binaries
# see https://playwright.dev/docs/next/browsers#hermetic-install
$env:PLAYWRIGHT_BROWSERS_PATH='0'
./.node/npx.cmd playwright install chromium firefox
if ($LASTEXITCODE) {
    throw "failed with exit code $LASTEXITCODE"
}
Set-Content -Encoding ascii -Path playwright.cmd -Value @'
@echo off
set SCRIPT_PATH=%~dp0
set PLAYWRIGHT_BROWSERS_PATH=%SCRIPT_PATH%\node_modules\playwright-core\.local-browsers
call %SCRIPT_PATH%\node_modules\.bin\playwright.cmd %*
'@
Pop-Location

# bundle.
Write-Output "Bundling..."
if (Test-Path dist) {
    Remove-Item -Recurse dist
}
mkdir dist | Out-Null
Push-Location build
Compress-Archive `
    -CompressionLevel Optimal `
    -DestinationPath ../dist/playwright-standalone-windows.zip `
    -Path *
Pop-Location
