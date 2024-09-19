FROM alpine:3.20

RUN apk add --no-cache \
      chromium-swiftshader \
      git \
      make \
      plantuml \
      py-pip \
      && pip install --break-system-packages bikeshed \
      && bikeshed update

COPY data/boilerplate/dashif /usr/lib/python3.12/site-packages/bikeshed/spec-data/boilerplate/dashif
COPY build-tools/tools /tools

RUN mkdir /data
WORKDIR /data

ENTRYPOINT ["/tools/entrypoint.sh"]
