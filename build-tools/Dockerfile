FROM ubuntu:24.04

# Install the basic dependencies we have
RUN apt update -y && apt install -y \
    software-properties-common \
    python3.12 \
    python3-pip \
    make \
    plantuml \
    git && \
    rm -rf /var/lib/apt/lists/*

RUN add-apt-repository ppa:xtradeb/apps -y && \
    apt update && \
    apt install -y chromium && \
    rm -rf /var/lib/apt/lists/*

# Install bikeshed and update it
RUN pip install --break-system-packages bikeshed && bikeshed update

COPY data/boilerplate/dashif /usr/local/lib/python3.12/dist-packages/bikeshed/spec-data/boilerplate/dashif


COPY build-tools/tools /tools

RUN mkdir /data
WORKDIR /data

ENTRYPOINT ["/tools/entrypoint.sh"]
