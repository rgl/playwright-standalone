# About

[![build](https://github.com/rgl/playwright-standalone/actions/workflows/build.yml/badge.svg)](https://github.com/rgl/playwright-standalone/actions/workflows/build.yml)

This is a standalone distribution of [Playwright](https://github.com/microsoft/playwright).

It includes the binaries for Node.js, Playwright, Chromium, and Firefox.

# Usage (from a Ubuntu machine)

Download the [latest playwright-standalone-ubuntu.zip release](https://github.com/rgl/playwright-standalone/releases/latest), extract it, and open a shell session at the extracted directory.

Start playing with it:

```bash
./playwright codegen --browser cr wikipedia.org
./playwright codegen --browser ff wikipedia.org
./playwright cr wikipedia.org
./playwright ff wikipedia.org
```

# Usage (from a Windows machine)

Download the [latest playwright-standalone-windows.zip release](https://github.com/rgl/playwright-standalone/releases/latest), extract it, and open a shell session at the extracted directory.

Start playing with it:

```powershell
.\playwright.cmd codegen --browser cr wikipedia.org
.\playwright.cmd codegen --browser ff wikipedia.org
.\playwright.cmd cr wikipedia.org
.\playwright.cmd ff wikipedia.org
```

# Develop

See the [build workflow](.github/workflows/build.yml).

List this repository dependencies (and which have newer versions):

```bash
export GITHUB_COM_TOKEN='YOUR_GITHUB_PERSONAL_TOKEN'
./renovate.sh
```

Build and install the base images from:

* [ubuntu-22.04-amd64](https://github.com/rgl/ubuntu-vagrant)
* [windows-2022-amd64](https://github.com/rgl/windows-vagrant)

Build and test the binaries in a libvirt virtual machine:

```bash
vagrant up --no-destroy-on-error --no-tty --provider=libvirt
```
