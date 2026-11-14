#!/bin/sh
set -eu

tag=$1
if ! printf '%s\n' "$tag" | grep -Eq '^v(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$'; then
    printf 'Expected a stable release tag, got %s\n' "$tag" >&2
    exit 1
fi

major="refs/tags/${tag%%.*}"
minor="refs/tags/${tag%.*}"
refs=$(git ls-remote origin "$major" "$minor")
old_major=$(printf '%s\n' "$refs" | awk -v ref="$major" '$2 == ref {print $1}')
old_minor=$(printf '%s\n' "$refs" | awk -v ref="$minor" '$2 == ref {print $1}')
git push --atomic --force-with-lease="$major:$old_major" --force-with-lease="$minor:$old_minor" \
    origin "HEAD:$major" "HEAD:$minor"
