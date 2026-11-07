# actions-runner-image

The official [`ghcr.io/actions/actions-runner`](https://github.com/actions/runner/pkgs/container/actions-runner)
image plus the tools that workflows expect from GitHub's hosted `ubuntu-latest`, so jobs
behave the same on self-hosted runners (Actions Runner Controller, `mm503/containers`
`arc-runners/*`) and on GitHub-hosted ones.

Adds: `gh`, `docker compose`, `zstd`, `build-essential`, `xz-utils`, `zip`, `rsync`, `wget`,
`openssh-client`, and a system Node.js 22 (the major hosted ubuntu-24.04 ships; some actions,
like `pnpm/action-setup`, need a `node` before `setup-node` runs). The base already has git,
jq, curl, unzip, python3, Docker CLI + buildx and passwordless sudo. Specific toolchain
versions (Node, Go, Python, …) still come from the `setup-*` actions, as on hosted runners.

## Image

`ghcr.io/mm503/actions-runner-image:<runner version>` (and `:latest`), linux/amd64.

- A push to `main` that touches the `Dockerfile` builds, smoke-tests and pushes it.
- A weekly scheduled rebuild refreshes the apt packages under the same tag. Consumers pin
  `tag@digest`, so Renovate turns each rebuild into a digest update there.
- Renovate bumps the runner base image here (automerged: GitHub refuses to send jobs to
  runners that fall too far behind) and the compose version.

## Rules

- This repo is **public**: its own workflows must stay on GitHub-hosted runners. Never point
  them at the self-hosted runners.
- Add a tool only when a workflow needs it, and add it to the smoke test.
