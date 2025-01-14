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
COPY data/boilerplate/dashif.kdl /tmp/dashif.kdl
RUN cat /tmp/dashif.kdl >> /usr/lib/python3.12/site-packages/bikeshed/spec-data/boilerplate/doctypes.kdl

RUN mkdir /data
WORKDIR /data

ENTRYPOINT ["/tools/entrypoint.sh"]
