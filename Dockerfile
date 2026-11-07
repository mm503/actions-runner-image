# Official ARC runner image plus the tools workflows expect from GitHub's hosted
# ubuntu-latest image, so jobs behave the same on self-hosted and hosted runners.
# The image tag is the runner version below.
FROM ghcr.io/actions/actions-runner:2.338.2

# renovate: datasource=github-releases depName=docker/compose
ARG COMPOSE_VERSION=v5.7.0

USER root

# gh comes from GitHub's own apt repo; Ubuntu's package lags far behind
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        -o /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        gh \
        openssh-client \
        rsync \
        wget \
        xz-utils \
        zip \
        zstd \
    && rm -rf /var/lib/apt/lists/*

# Same plugin dir the base image uses for buildx
RUN curl -fsSL -o /usr/local/lib/docker/cli-plugins/docker-compose \
        "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-linux-x86_64" \
    && chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

USER runner
