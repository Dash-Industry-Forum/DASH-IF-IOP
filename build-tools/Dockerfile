FROM ubuntu:24.04

# Install the basic dependencies we have
RUN apt update -y && apt install -y \
    python3.12 \
    python3-pip \
    plantuml \
    wkhtmltopdf \
    make \
    git && \
    rm -rf /var/lib/apt/lists/*

# Install bikeshed and update it
RUN pip install --break-system-packages bikeshed && bikeshed update

COPY boilerplate/dashif /usr/local/lib/python3.12/dist-packages/bikeshed/spec-data/boilerplate/dashif

RUN mkdir /build
COPY Makefile /build/

RUN mkdir /data
WORKDIR /data

COPY entrypoint.sh /build/
ENTRYPOINT ["/build/entrypoint.sh"]
