Task: Create multi-stage Dockerfile equivalent to Earthfile
=============================================================

Context
-------

The project uses an Earthfile to build a multi-platform debug container image.
We need a standard Dockerfile that produces the same final image, coexisting alongside the Earthfile.

Objective
---------

Create a ``Dockerfile`` at the project root with multi-stage builds mirroring the Earthfile stages.

Stages
------

1. ``tools`` (FROM alpine:3): installs all apk packages, copies bash config files, sets default CMD.
2. ``mise`` (FROM tools): installs mise, cosign, uv, rust, build-base, python3-dev.
3. ``mise-tools`` (FROM mise): copies ``mise.tools.toml`` as ``/mise.toml``, trusts it, sets ``MISE_DATA_DIR=/mise_data``, runs ``mise install`` with GITHUB_TOKEN secret, copies installed binaries to ``/usr/local/bin``.
4. ``mise-pipx`` (FROM mise): copies ``mise.pipx.toml``, trusts it, sets ``MISE_DATA_DIR=/mise_pipx``, runs ``mise install --env pipx`` with GITHUB_TOKEN secret.
5. ``kubetail`` (FROM tools): downloads and installs kubetail 1.6.20.
6. Final stage (FROM tools): copies artifacts from mise-tools (``/usr/local/bin``), mise-pipx (``/mise_pipx``), and kubetail (``/usr/local/bin/kubetail``). Sets ``WORKDIR /tmp``.

Key details
-----------

- Use ``RUN --mount=type=secret,id=GITHUB_TOKEN`` for secret access. Inside the RUN, export the secret from the mounted file: ``export GITHUB_TOKEN=$(cat /run/secrets/GITHUB_TOKEN)``.
- The ``KUBETAIL_VERSION`` should be an ``ARG`` defaulting to ``1.6.20``.
- The final stage should not include mise, rust, build-base, or python3-dev — only the ``tools`` base plus the built artifacts.
- Do NOT modify the Earthfile or any other existing files.

Non-goals
---------

- No CI changes.
- No build scripts.
- No removal of the Earthfile.
