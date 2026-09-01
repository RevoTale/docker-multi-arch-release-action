#!/usr/bin/env bash
set -euo pipefail

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
verifier="${repository_root}/scripts/verify-manifest.sh"
temporary_directory="$(mktemp -d)"
trap 'rm -rf "${temporary_directory}"' EXIT

if [[ ! -x "${verifier}" ]]; then
  echo "Expected executable verifier at ${verifier}" >&2
  exit 1
fi

mkdir -p "${temporary_directory}/bin"
cat > "${temporary_directory}/bin/docker" <<'FAKE_DOCKER'
#!/usr/bin/env bash
set -euo pipefail

if [[ "$#" -lt 4 || "$1" != "buildx" || "$2" != "imagetools" || "$3" != "inspect" ]]; then
  echo "Unexpected docker invocation: $*" >&2
  exit 64
fi

arguments="$*"
image_tag="${!#}"

if [[ "${arguments}" != *" --format "* ]]; then
  printf 'Name: %s\nManifests:\n  Platform: linux/amd64\n  Platform: linux/arm64\n' "${image_tag}"
  exit 0
fi

if [[ "${image_tag}" == *"missing-arm64"* && "${arguments}" == *"linux/arm64"* ]]; then
  printf 'null\n'
  exit 0
fi

printf '{"architecture":"verified"}\n'
FAKE_DOCKER
chmod +x "${temporary_directory}/bin/docker"

run_verifier() {
  PATH="${temporary_directory}/bin:${PATH}" \
    IMAGE_TAGS="$1" \
    EXPECTED_PLATFORMS="$2" \
    "${verifier}"
}

echo "Checking every requested platform for every published tag"
success_output="$(run_verifier $'ghcr.io/example/app:v1\nghcr.io/example/app:latest' 'linux/amd64, linux/arm64')"
grep -Fq 'ghcr.io/example/app:v1 includes linux/amd64' <<< "${success_output}"
grep -Fq 'ghcr.io/example/app:v1 includes linux/arm64' <<< "${success_output}"
grep -Fq 'ghcr.io/example/app:latest includes linux/amd64' <<< "${success_output}"
grep -Fq 'ghcr.io/example/app:latest includes linux/arm64' <<< "${success_output}"

echo "Rejecting a manifest that lacks a requested platform"
if missing_output="$(run_verifier 'ghcr.io/example/app:missing-arm64' 'linux/amd64,linux/arm64' 2>&1)"; then
  echo "Verifier unexpectedly accepted a missing platform." >&2
  exit 1
fi
grep -Fq 'does not include required platform linux/arm64' <<< "${missing_output}"

echo "Rejecting empty tags"
if empty_output="$(run_verifier '' 'linux/amd64,linux/arm64' 2>&1)"; then
  echo "Verifier unexpectedly accepted an empty tag list." >&2
  exit 1
fi
grep -Fq 'No published image tags were available to verify.' <<< "${empty_output}"

echo "Rejecting unsafe platform values before template construction"
if unsafe_output="$(run_verifier 'ghcr.io/example/app:v1' 'linux/amd64;echo-unsafe' 2>&1)"; then
  echo "Verifier unexpectedly accepted an unsafe platform value." >&2
  exit 1
fi
grep -Fq 'Invalid platform value' <<< "${unsafe_output}"

echo "Manifest verifier behavior is valid"
