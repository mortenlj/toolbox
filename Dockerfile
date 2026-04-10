ARG TARGETARCH

FROM alpine:3 AS tools

RUN apk add --no-cache \
    bash \
    bind-tools \
    busybox-extras \
    ca-certificates \
    coreutils \
    curl \
    hey \
    httpie \
    iperf \
    iputils \
    jq \
    k9s \
    kubectl \
    libcurl \
    libsasl \
    lz4-libs \
    micro \
    mosquitto-clients \
    mtr \
    nano \
    netcat-openbsd \
    nmap \
    openssl \
    postgresql16-client \
    postgresql17-client \
    postgresql18-client \
    redis \
    socat \
    strace \
    tcpdump \
    tcptraceroute \
    valkey-cli \
    vim \
    wget \
    yq \
    zstd-dev

COPY files/bash/bash-*.sh /etc/bash/

CMD ["tail", "-f", "/dev/null"]

FROM tools AS mise

RUN apk add --no-cache \
    mise \
    cosign \
    uv \
    rust \
    build-base \
    python3-dev

FROM mise AS mise-tools

COPY mise.tools.toml /mise.toml

RUN mise trust /mise.toml

ENV MISE_DATA_DIR=/mise_data

RUN --mount=type=secret,id=GITHUB_TOKEN \
    export GITHUB_TOKEN=$(cat /run/secrets/GITHUB_TOKEN) && \
    mise install

RUN find ${MISE_DATA_DIR}/installs/*/latest/ -executable -type f -exec cp {} /usr/local/bin +

FROM mise AS mise-pipx

COPY mise.pipx.toml /

RUN mise trust /mise.pipx.toml

ENV MISE_DATA_DIR=/mise_pipx

RUN --mount=type=secret,id=GITHUB_TOKEN \
    export GITHUB_TOKEN=$(cat /run/secrets/GITHUB_TOKEN) && \
    mise install --env pipx

FROM tools AS kubetail

ARG KUBETAIL_VERSION=1.6.20

RUN mkdir -p /tmp/kubetail
RUN curl -SL https://github.com/johanhaleby/kubetail/archive/${KUBETAIL_VERSION}.tar.gz | tar -xzC /tmp/kubetail
RUN mv /tmp/kubetail/kubetail-${KUBETAIL_VERSION}/kubetail /usr/local/bin/
RUN chmod a+x /usr/local/bin/kubetail

FROM tools AS final

COPY --from=mise-tools /usr/local/bin /usr/local/bin
COPY --from=mise-pipx /mise_pipx /mise_pipx
COPY --from=kubetail /usr/local/bin/kubetail /usr/local/bin/kubetail

WORKDIR /tmp