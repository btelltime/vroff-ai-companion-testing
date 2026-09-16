#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

# Load only the version helper, so this test does not parse CLI arguments or
# access GitHub/Vroff state.
source <(sed -n '/^next_patch_version() {/,/^}/p' "$script_dir/release-companion")

assert_next_version() {
  local current=$1 expected=$2 actual
  actual=$(next_patch_version "$current")
  [[ $actual == "$expected" ]] || {
    printf 'expected %s to become %s; got %s\n' "$current" "$expected" "$actual" >&2
    exit 1
  }
}

assert_next_version 1.1.0 1.1.1
assert_next_version 1.0.9 1.1.0
assert_next_version 1.1.9 1.2.0
assert_next_version 1.9.9 2.0.0
