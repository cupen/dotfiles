#!/usr/bin/env bash
source base/require.sh
source base/logger.sh
set -euo pipefail

require gcc
require make
require ctags
require python3

info "all_is_OK!"
