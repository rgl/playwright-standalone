#!/bin/bash
set -euo pipefail

# see https://nodejs.org
# see https://github.com/nodejs/node
# renovate: datasource=node depName=node versioning=node
NODEJS_VERSION='20.11.1'

# see https://playwright.dev
# see https://github.com/microsoft/playwright
# see https://www.npmjs.com/package/@playwright/test
# renovate: datasource=npm depName=@playwright/test
PLAYWRIGHT_TEST_VERSION='1.42.1'

# reset the PATH to ensure we only use our standalone binaries.
export PATH="$PWD/build/.node/bin:/usr/bin"

# install the zip dependency.
if ! command -v zip &> /dev/null; then
    apt-get update
    apt-get install -y zip
fi

# prepare.
mkdir -p tmp

# download the node.js binaries.
nodejs_archive_url="https://nodejs.org/dist/v$NODEJS_VERSION/node-v$NODEJS_VERSION-linux-x64.tar.xz"
nodejs_archive="tmp/$(basename "$nodejs_archive_url")"
if [ ! -f "$nodejs_archive" ]; then
    echo "Downloading Node.js from $nodejs_archive_url..."
    wget -qO "$nodejs_archive" "$nodejs_archive_url"
fi

# build.
echo "Extracting Node.js..."
rm -rf build
mkdir -p build/.node
tar xf "$nodejs_archive" -C build/.node --strip-components 1
pushd build
echo "Installing @playwright/test@$PLAYWRIGHT_TEST_VERSION..."
./.node/bin/npm install "@playwright/test@$PLAYWRIGHT_TEST_VERSION"
echo "Installing the playwright browsers..."
# see https://playwright.dev/docs/next/browsers#managing-browser-binaries
# see https://playwright.dev/docs/next/browsers#hermetic-install
export PLAYWRIGHT_BROWSERS_PATH=0
./.node/bin/npx playwright install chromium firefox
cat >playwright <<'EOF'
#!/bin/bash
set -eu
SCRIPT_PATH="$(cd -- "$(dirname "$0")" >/dev/null 2>&1; pwd -P)"
export PATH="$SCRIPT_PATH/.node/bin:$PATH"
exec npx playwright "$@"
EOF
chmod +x playwright
popd

# bundle.
echo "Bundling..."
rm -rf dist
mkdir dist
pushd build
zip --symlinks -9 -r ../dist/playwright-standalone-ubuntu.zip .
popd
