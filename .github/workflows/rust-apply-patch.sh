#!/bin/bash

set -euo pipefail

UPDATE_NEEDED=1

. .github/workflows/common.sh

checkout_branches "rust-${VERSION_NEW}-${CHANNEL}" || UPDATE_NEEDED=0 && exit 0

pushd "${SDK_OUTER_SRCDIR}/third_party/coreos-overlay" >/dev/null || exit

VERSION_OLD=$(sed -n "s/^DIST rustc-\(1.[0-9]*.[0-9]*\).*/\1/p" dev-lang/rust/Manifest | sort -ruV | head -n1)
[[ "${VERSION_NEW}" = "${VERSION_OLD}" ]] && echo "already the latest Rust, nothing to do" && UPDATE_NEEDED=0 && exit 0

pushd "dev-lang/rust" >/dev/null || exit
git mv $(ls -1 rust-${VERSION_OLD}*.ebuild | sort -ruV | head -n1) "rust-${VERSION_NEW}.ebuild"
popd >/dev/null || exit

popd >/dev/null || exit

generate_patches dev-lang rust Rust

apply_patches

echo ::set-output name=VERSION_OLD::"${VERSION_OLD}"
echo ::set-output name=UPDATE_NEEDED::"${UPDATE_NEEDED}"
