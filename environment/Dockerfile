# hash:sha256:bc84e43dd9612d6277ab9bc1c252b02675d5804732a595d2e7dfcbc45e8f27a2
FROM registry.codeocean.com/codeocean/matlab:2015b-ubuntu16.04

ARG DEBIAN_FRONTEND=noninteractive
ARG MLM_LICENSE_FILE

RUN apt-get update \
    && apt-get install -y octave \
    && rm -rf /var/lib/apt/lists/* \