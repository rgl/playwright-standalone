#!/bin/bash
set -euo pipefail

# reset the PATH to ensure we only use our standalone binaries.
export PATH='/usr/bin'

# install.
echo 'Installing...'
rm -rf tmp/playwright-standalone
unzip dist/playwright-standalone-ubuntu.zip -d tmp/playwright-standalone

# test.
cd tmp/playwright-standalone
echo 'Getting the playwright version...'
./playwright --version
