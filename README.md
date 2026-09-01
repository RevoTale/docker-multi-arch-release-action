# docker-multi-arch-release-action

Build and push multi-architecture Docker images with ref-based tagging.

## Quick start

```yaml
name: Build and Push Docker

on:
  push:
    branches: [main]

jobs:
  build-and-push-docker:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v6
      - uses: revotale/docker-multi-arch-release-action@v1
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          image-name: ${{ github.repository }}
          password: ${{ secrets.GITHUB_TOKEN }}
          platforms: linux/amd64,linux/arm64
```

## Inputs

- `registry` (required): Registry host, for example `ghcr.io`.
- `platforms` (required): Comma-separated platforms, for example `linux/amd64,linux/arm64`.
- `username` (required): Registry username.
- `image-name` (required): Image name without registry prefix.
- `password` (required): Registry password or token.
- `file` (optional): Dockerfile path.
- `context` (optional): Build context. Default: `.`.
- `tags` (optional): Tag rules for `docker/metadata-action`. Default: ref-based tags.
- `build-args` (optional): Build arguments passed to `docker/build-push-action`.
- `provenance` (optional): Provenance setting, for example `mode=max` or `false`. Empty by default, which preserves Docker's repository-aware default.
- `sbom` (optional): SBOM setting passed to `docker/build-push-action`. Default: `false`.
- `verify-manifest` (optional): Verify every requested platform in every published tag. Default: `false`.

## Outputs

- `digest`: Digest of the published image or manifest list.

## Recommended release settings

```yaml
- name: Build and push Docker image
  id: push
  uses: revotale/docker-multi-arch-release-action@v1
  with:
    registry: ghcr.io
    username: ${{ github.actor }}
    image-name: ${{ github.repository }}
    password: ${{ secrets.GITHUB_TOKEN }}
    platforms: linux/amd64,linux/arm64
    provenance: mode=max
    sbom: true
    verify-manifest: true
```

These options are explicit to keep the `v1` defaults backward compatible. `verify-manifest` runs after publication and fails when any requested platform is absent from any generated tag.

> [!WARNING]
> Max-mode provenance can publish build argument values. Never pass secrets through `build-args`; use BuildKit secret mounts.

Use the moving major tag (`@v1`) for backward-compatible updates, or pin a release tag for reproducibility.
