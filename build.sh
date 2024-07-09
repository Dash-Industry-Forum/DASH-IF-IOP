#!/bin/bash

# Here is the command that can be used to debug or develop with the
# local resources.
#
# docker run --rm -ti -v `pwd`:/data -v `pwd`/build-tools/tools:/tools -v `pwd`/data/boilerplate/dashif:/usr/local/lib/python3.12/dist-packages/bikeshed/spec-data/boilerplate/dashif dashif-specs:latest
#

# Run the docker container and pass all the arguments
IMG=thasso/dashif-specs:latest
docker run --rm -ti -v `pwd`:/data ${IMG} $@
