#!/usr/bin/env bash
set -euo pipefail

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
action_file="${repository_root}/action.yml"

echo "Checking custom action metadata fields"
if grep -nE '^[[:space:]]+type:' "${action_file}"; then
  echo "Custom action inputs do not support a type field." >&2
  exit 1
fi

echo "Checking that every executable action dependency uses a full commit SHA"
uses_lines="$(grep -E '^[[:space:]]+uses:' "${action_file}")"
if unpinned="$(grep -Ev '@[0-9a-f]{40}([[:space:]]+#.*)?$' <<< "${uses_lines}")"; then
  echo "Unpinned action dependencies:" >&2
  printf '%s\n' "${unpinned}" >&2
  exit 1
fi

echo "Checking attestation, verification, and digest contracts"
grep -Fq 'provenance:' "${action_file}"
grep -Fq 'sbom:' "${action_file}"
grep -Fq 'verify-manifest:' "${action_file}"
grep -Fq 'digest:' "${action_file}"

echo "Action metadata contract is valid"
