# Official ARC runner image plus the tools workflows expect from GitHub's hosted
# ubuntu-latest image, so jobs behave the same on self-hosted and hosted runners.
# The image tag is the runner version below.
FROM ghcr.io/actions/actions-runner:2.338.2

# renovate: datasource=github-releases depName=docker/compose
ARG COMPOSE_VERSION=v5.7.0
# System Node, the major hosted ubuntu-24.04 ships. Some actions need a node on PATH
# before setup-node runs (e.g. pnpm/action-setup's self-installer).
# renovate: datasource=node-version depName=node
ARG NODE_VERSION=22.23.4

USER root

# gh comes from GitHub's own apt repo; Ubuntu's package lags far behind
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        -o /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        # Hosted's font set: without DejaVu, fontconfig resolves sans-serif/monospace to
        # whatever's left (e.g. a CJK font from playwright install-deps), and screenshot
        # tests drift from snapshots taken on hosted runners
        fontconfig \
        fonts-dejavu \
        fonts-dejavu-core \
        fonts-dejavu-extra \
        fonts-dejavu-mono \
        fonts-lato \
        fonts-noto-color-emoji \
        fonts-ubuntu-console \
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

# setup-node puts its own version ahead of this on PATH, as on hosted runners
RUN cd /tmp \
    && curl -fsSLO "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz" \
    && curl -fsSL "https://nodejs.org/dist/v${NODE_VERSION}/SHASUMS256.txt" \
        | grep " node-v${NODE_VERSION}-linux-x64.tar.xz\$" | sha256sum -c - \
    && tar -xJf "node-v${NODE_VERSION}-linux-x64.tar.xz" -C /usr/local --strip-components=1 \
        --exclude='*/CHANGELOG.md' --exclude='*/LICENSE' --exclude='*/README.md' --exclude='*/share/doc' \
    && rm "node-v${NODE_VERSION}-linux-x64.tar.xz"

USER runner
