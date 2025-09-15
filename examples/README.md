# Examples

This directory contains example workflows demonstrating different ways to use the Docker Release Action.

## Available Examples

### [basic-usage.yml](./basic-usage.yml)
Shows the simplest possible usage with minimal configuration.

### [reusable-workflow.yml](./reusable-workflow.yml)
Demonstrates how to use the reusable workflow to build multiple images with consistent configuration.

### [docker-hub-usage.yml](./docker-hub-usage.yml)
Shows how to configure the action for Docker Hub instead of GitHub Container Registry, including custom prefixes.

## Usage

To use any of these examples in your repository:

1. Copy the desired example file to `.github/workflows/` in your repository
2. Modify the configuration as needed for your specific use case
3. Ensure you have the necessary permissions and secrets configured
4. Commit and push the workflow file

## Required Permissions

Most examples require these permissions:
```yaml
permissions:
  contents: read
  packages: write
```

For Docker Hub usage, you'll also need to set up these repository secrets:
- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`