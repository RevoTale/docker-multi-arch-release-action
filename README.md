# docker-multi-arch-release-action
Build and push multi-architecture Docker images in one friendly, reliable action. Tagging works out of the box from git refs and can be customized whenever a release needs a little extra sparkle.

**Quickstart (push on `main`)**
```yaml
name: Build and Push Docker

on:
  push:
    branches:
      - main

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

**Inputs**
- `registry` (required): Registry host, for example `ghcr.io`.
- `platforms` (required): Comma-separated platforms, for example `linux/amd64,linux/arm64`.
- `username` (required): Registry username.
- `image-name` (required): Image name without registry prefix.
- `password` (required): Registry password or token.
- `context` (optional): Build context path. Default: `.`.
- `tags` (optional): Newline-separated tags for `docker/metadata-action`. Defaults to ref-based tags.
- `build-args` (optional): Newline- or comma-separated build arguments passed to `docker/build-push-action`.

**Tips**
- Pin to a release tag (for example `@v1.0.5`) for repeatable builds.
- Use `tags` to ship both a versioned tag and `latest` on releases.
- Add `build-args` when Dockerfile build arguments are needed.

**Extended Example (Release Please + gated build)**
```yaml
name: Semver Release

on:
  push:
    branches:
      - main
permissions:
  contents: write
  pull-requests: write
  packages: write
jobs:
  release-please:
    runs-on: ubuntu-latest
    outputs:
      release_created: ${{ steps.release.outputs.release_created }}
      tag_name: ${{ steps.release.outputs.tag_name }}
    steps:
      # use fork to work around https://github.com/googleapis/release-please/issues/2265
      - uses: gvillo/release-please-action@93642002875a0df65de8abeeeabcaeacb7c735f4 # v4.2.1-gvillo
      # - uses: google-github-actions/release-please-action@v4
        id: release
        with:
          release-type: simple
          token: ${{ secrets.RELEASE_PLEASE_TOKEN }}

  test:
    uses: ./.github/workflows/test.yml

  build-and-push-docker:
    runs-on: ubuntu-latest
    needs: [release-please, test]
    if: needs.release-please.outputs.release_created == 'true'
    steps:
      - name: Checkout repository
        uses: actions/checkout@v6
      - name: Build and push Docker image
        id: push
        uses: revotale/docker-multi-arch-release-action@v1.0.5
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          image-name: ${{ github.repository }}
          password: ${{ secrets.GITHUB_TOKEN }}
          tags: |
            ${{ needs.release-please.outputs.tag_name }}
            latest
          platforms: linux/amd64,linux/arm64
```
