FROM ubuntu:24.04

RUN apt update -y && apt install -y \
    python3.12 \
    python3-pip \
    plantuml \
    wkhtmltopdf \
    make

RUN pip install --break-system-packages bikeshed && bikeshed update

