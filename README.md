# Docker Release Action

A GitHub CI Action to deploy multi-platform Docker images with configurable prefixes and reusable workflows.

## Features

- 🐳 **Multi-platform builds** - Supports linux/amd64 and linux/arm64 by default
- 🏷️ **Configurable image prefixes** - Add custom prefixes to your image names
- 🔄 **Reusable workflows** - Easily integrate into any repository
- 🔐 **Flexible registry support** - Works with GitHub Container Registry, Docker Hub, and others
- ⚡ **Composite action** - Fast execution with minimal overhead

## Usage

### Basic Usage

```yaml
name: Build and Push Docker Image
on:
  release:
    types: [published]

jobs:
  docker:
    runs-on: ubuntu-latest
    steps:
      - uses: RevoTale/docker-release-action@v1
        with:
          image-name: my-app
```

### Advanced Usage with Prefix

```yaml
name: Build and Push Docker Image
on:
  release:
    types: [published]

jobs:
  docker:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
    steps:
      - uses: RevoTale/docker-release-action@v1
        with:
          registry: ghcr.io
          image-name: my-app
          image-prefix: my-org-
          context: ./docker
          dockerfile: ./docker/Dockerfile
          platforms: linux/amd64,linux/arm64,linux/arm/v7
```

### Multiple Images with Different Prefixes

```yaml
name: Build Multiple Images
on:
  release:
    types: [published]

jobs:
  build-api:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
    steps:
      - uses: RevoTale/docker-release-action@v1
        with:
          image-name: api
          image-prefix: myproject-
          context: ./api
          dockerfile: ./api/Dockerfile
          
  build-frontend:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
    steps:
      - uses: RevoTale/docker-release-action@v1
        with:
          image-name: frontend
          image-prefix: myproject-
          context: ./frontend
          dockerfile: ./frontend/Dockerfile
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `registry` | Container registry to push to | No | `ghcr.io` |
| `image-name` | Name of the Docker image (without prefix) | Yes | - |
| `image-prefix` | Prefix to add to the image name | No | `""` |
| `context` | Build context path | No | `.` |
| `dockerfile` | Path to Dockerfile | No | `./Dockerfile` |
| `platforms` | Target platforms for build | No | `linux/amd64,linux/arm64` |
| `push` | Push the image to registry | No | `true` |
| `registry-username` | Username for registry authentication | No | `${{ github.actor }}` |
| `registry-password` | Password for registry authentication | No | `${{ github.token }}` |

## Outputs

| Output | Description |
|--------|-------------|
| `image` | Full image name with tags |
| `digest` | Image digest |

## Examples

### Using with Docker Hub

```yaml
- uses: RevoTale/docker-release-action@v1
  with:
    registry: docker.io
    image-name: my-app
    image-prefix: myusername/
    registry-username: ${{ secrets.DOCKERHUB_USERNAME }}
    registry-password: ${{ secrets.DOCKERHUB_TOKEN }}
```

### Build Only (No Push)

```yaml
- uses: RevoTale/docker-release-action@v1
  with:
    image-name: my-app
    push: false
```

### Custom Platforms

```yaml
- uses: RevoTale/docker-release-action@v1
  with:
    image-name: my-app
    platforms: linux/amd64,linux/arm64,linux/arm/v7,linux/ppc64le
```

## Image Naming

The final image name is constructed as: `{registry}/{image-prefix}{image-name}`

Examples:
- `ghcr.io/my-app` (no prefix)
- `ghcr.io/myorg-my-app` (with prefix "myorg-")
- `docker.io/myusername/my-app` (Docker Hub with username as prefix)

## Examples

For more usage examples, see the [examples directory](./examples/) which contains:
- [Basic usage](./examples/basic-usage.yml)
- [Reusable workflow example](./examples/reusable-workflow.yml) 
- [Docker Hub usage](./examples/docker-hub-usage.yml)

## License

MIT License - see [LICENSE](LICENSE) file for details.
