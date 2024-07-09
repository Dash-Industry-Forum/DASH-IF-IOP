#!/bin/sh

# Call make with the right makefile and pass all arguments
exec make -f /tools/Makefile $@
