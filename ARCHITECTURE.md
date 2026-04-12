# Architecture

toolbox is a multi-tool debug container image for Kubernetes and Kafka troubleshooting.
It bundles network, database, messaging, and cluster diagnostic tools into a single Alpine-based image, built for both `linux/amd64` and `linux/arm64`.

## Project Structure

```
.
├── Earthfile              # Primary build system (Earthly)
├── Dockerfile             # Alternative build system (standard Docker)
├── mise.toml              # Local dev tooling (earthly version)
├── mise.tools.toml        # Tools installed via mise in the image (grpcurl, kafkactl, kubeseal, kubespy)
├── mise.pipx.toml         # Python tools installed via pipx in the image (pgcli, mycli)
├── files/
│   └── bash/
│       ├── bash-aliases.sh   # Shell aliases (ls, ll, etc.)
│       ├── bash-path.sh      # Adds mise/pipx bin dirs to PATH
│       └── bash-prompt.sh    # Custom bash prompt
├── .github/
│   └── workflows/
│       └── main.yml       # CI/CD pipeline
├── CODEOWNERS
└── README.md
```

## Build Stages

Both the Earthfile and Dockerfile use the same multi-stage structure:

```
alpine:3
  └── tools          # apk packages + bash config + CMD
        ├── mise     # mise, cosign, uv, rust, build-base, python3-dev (builder only)
        │   ├── mise-tools   # grpcurl, kafkactl, kubeseal, kubespy → /usr/local/bin
        │   └── mise-pipx    # pgcli, mycli → /mise_pipx
        └── kubetail         # kubetail binary → /usr/local/bin/kubetail

Final image = tools + artifacts from mise-tools, mise-pipx, kubetail
```

The final image does **not** contain mise, rust, build-base, or python3-dev.
Only the `tools` base layer plus the compiled/installed binaries are shipped.

## Tool Inventory

### Alpine packages (apk)

Network/debug: bind-tools, busybox-extras, curl, hey, httpie, iperf, iputils, mtr, nano, netcat-openbsd, nmap, openssl, socat, strace, tcpdump, tcptraceroute, wget.

Kubernetes: k9s, kubectl.

Database clients: postgresql16-client, postgresql17-client, postgresql18-client, redis, valkey-cli.

Messaging: mosquitto-clients.

Utilities: bash, ca-certificates, coreutils, jq, libcurl, libsasl, lz4-libs, micro, vim, yq, zstd-dev.

### Mise-managed tools (mise.tools.toml)

grpcurl, kafkactl, kubeseal, kubespy.

### Pipx-managed tools (mise.pipx.toml)

pgcli, mycli.

### Standalone

kubetail (downloaded from GitHub release archive).

## Secrets

`GITHUB_TOKEN` is required for `mise install` to fetch tools from GitHub without rate limiting.

- **Local Earthly builds:** Provide via a `.secret` file containing `GITHUB_TOKEN=<token>`.
- **Dockerfile builds:** Pass via `docker buildx build --secret id=GITHUB_TOKEN`.
- **CI:** Injected from GitHub Actions secrets.

## Building

### Earthly (primary)

```bash
earthly +deploy
```

Builds for both `linux/amd64` and `linux/arm64`.

### Docker

```bash
docker buildx build --platform=linux/amd64,linux/arm64 \
    --secret id=GITHUB_TOKEN \
    -t ghcr.io/mortenlj/toolbox:latest .
```

## CI/CD

GitHub Actions (`.github/workflows/main.yml`):

1. Generates a version string from timestamp + git hash.
2. Sets up QEMU for cross-platform builds.
3. Runs `earthly +deploy` with remote caching against GHCR.
4. Creates a GitHub Release on push to `master`.
