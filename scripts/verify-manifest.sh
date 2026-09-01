#!/usr/bin/env bash
set -euo pipefail

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "${value}"
}

IFS=',' read -r -a platform_values <<< "${EXPECTED_PLATFORMS:-}"

platform_count=0
platforms=()
for raw_platform in "${platform_values[@]}"; do
  platform="$(trim "${raw_platform}")"
  if [[ -z "${platform}" ]]; then
    continue
  fi
  if [[ ! "${platform}" =~ ^[a-z0-9][a-z0-9._-]*/[a-z0-9][a-z0-9._-]*(/[a-z0-9][a-z0-9._-]*)?$ ]]; then
    printf 'Invalid platform value: %s\n' "${platform}" >&2
    exit 1
  fi
  platforms+=("${platform}")
  platform_count=$((platform_count + 1))
done

if [[ "${platform_count}" -eq 0 ]]; then
  echo "No target platforms were available to verify." >&2
  exit 1
fi

tag_count=0
while IFS= read -r raw_image_tag; do
  image_tag="$(trim "${raw_image_tag}")"
  if [[ -z "${image_tag}" ]]; then
    continue
  fi

  tag_count=$((tag_count + 1))
  printf 'Inspecting %s\n' "${image_tag}"
  docker buildx imagetools inspect "${image_tag}"

  for platform in "${platforms[@]}"; do
    format="{{json (index .Image \"${platform}\")}}"
    image_config="$(docker buildx imagetools inspect --format "${format}" "${image_tag}")"
    if [[ -z "${image_config}" || "${image_config}" == "null" ]]; then
      printf '%s does not include required platform %s\n' "${image_tag}" "${platform}" >&2
      exit 1
    fi
    printf '%s includes %s\n' "${image_tag}" "${platform}"
  done
done <<< "${IMAGE_TAGS:-}"

if [[ "${tag_count}" -eq 0 ]]; then
  echo "No published image tags were available to verify." >&2
  exit 1
fi

printf 'Verified %d published image tag(s) across %d platform(s).\n' "${tag_count}" "${platform_count}"
