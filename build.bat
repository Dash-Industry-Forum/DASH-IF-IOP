@echo off
docker run --rm -ti -v %cd%:/data dashif/specs-builder:latest %*