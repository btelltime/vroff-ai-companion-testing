#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

# Load only the version helper, so this test does not parse CLI arguments or
# access GitHub/Vroff state.
source <(sed -n '/^next_minor_version() {/,/^}/p' "$script_dir/release-companion")

actual=$(next_minor_version 1.0.9)
[[ $actual == 1.1.0 ]] || {
  printf 'expected 1.0.9 to become 1.1.0; got %s\n' "$actual" >&2
  exit 1
}
