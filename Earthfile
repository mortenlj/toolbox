VERSION 0.8

ARG --global TARGETARCH

tools:
    FROM alpine:3

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

mise:
    FROM +tools

    RUN apk add --no-cache \
            mise \
            cosign \
            uv \
            rust \
            build-base \
            python3-dev

    SAVE IMAGE --cache-hint

mise-tools:
    FROM +mise
    COPY mise.tools.toml /
    RUN mise trust /mise.tools.toml

    ENV MISE_DATA_DIR=/mise_data
    RUN --secret GITHUB_TOKEN mise install --env tools
    RUN find ${MISE_DATA_DIR}/installs/*/latest/ -executable -type f -exec cp {} /usr/local/bin +

    SAVE ARTIFACT /usr/local/bin localbin
    SAVE IMAGE --cache-hint

mise-pipx:
    FROM +mise
    COPY mise.pipx.toml /
    RUN mise trust /mise.pipx.toml

    ENV MISE_DATA_DIR=/mise_pipx
    RUN --secret GITHUB_TOKEN mise install --env pipx

    SAVE ARTIFACT /mise_pipx pipx
    SAVE IMAGE --cache-hint

kubetail:
    FROM +tools
    ARG KUBETAIL_VERSION=1.6.20

    RUN mkdir -p /tmp/kubetail
    RUN curl -SL https://github.com/johanhaleby/kubetail/archive/${KUBETAIL_VERSION}.tar.gz | tar -xzC /tmp/kubetail
    RUN mv /tmp/kubetail/kubetail-${KUBETAIL_VERSION}/kubetail /usr/local/bin/
    RUN chmod a+x /usr/local/bin/kubetail

    SAVE ARTIFACT /usr/local/bin/kubetail kubetail
    SAVE IMAGE --cache-hint

docker:
    FROM +tools
    COPY +mise-tools/localbin /usr/local/bin
    COPY --dir +mise-pipx/pipx /mise_pipx
    COPY +kubetail/kubetail /usr/local/bin/kubetail

    # builtins must be declared
    ARG EARTHLY_GIT_PROJECT_NAME
    ARG EARTHLY_GIT_SHORT_HASH

    # Override from command-line on CI
    ARG main_image=ghcr.io/$EARTHLY_GIT_PROJECT_NAME
    ARG VERSION=$EARTHLY_GIT_SHORT_HASH

    WORKDIR /tmp
    SAVE IMAGE --push ${main_image}:${VERSION} ${main_image}:latest

deploy:
    BUILD --platform=linux/amd64 --platform=linux/arm64 +docker
