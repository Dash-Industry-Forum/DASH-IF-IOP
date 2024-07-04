#!/bin/bash

# Call make with the right makefile and pass all arguments
exec make -f /build/Makefile $@
