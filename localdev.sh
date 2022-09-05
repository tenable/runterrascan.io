#!/bin/sh

# This script builds a container image within which a development server
# will run, then launches a container to build the working directory and
# serve it on http://localhost:1313/.
#
# Usage:
# $ git clone https://github.com/tenable/runterrascan.io
# $ ./localdev.sh
# <Open http://localhost:1313/ in browser>
# <changes to working directory will hot reload in the dev server>
#
# Prerequisites: Docker

docker build -t runterrascan-devserver -f Dockerfile.dev .

docker run --name runterrascan-devserver --rm -it -e HUGO_ENV=production -v "$(pwd):/app" -p 1313:1313 runterrascan-devserver
