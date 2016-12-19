#!/bin/bash
set -e
echo "--- BUILDING PRODUCTION IMAGE ---"
docker build -t registry.wellmatchhealth.com/accounts-nomad -f Dockerfile .
echo "--- BUILDING BASE IMAGE ---"
docker build -t registry.wellmatchhealth.com/accounts-nomad_dev -f Dockerfile.development .
echo "--- DONE ---"
