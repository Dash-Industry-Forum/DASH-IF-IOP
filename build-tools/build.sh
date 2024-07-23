#!/bin/bash

# Note that we need to copy some files from the folder below
# so set the context to that folder. The Dockerfile also
# assumes that.
docker build -t dashif/specs-builder:latest -f ./Dockerfile ../
