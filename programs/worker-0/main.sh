#!/usr/bin/bash

set -eo pipefail

readonly HOSTNAME=$(hostname)
readonly TIME_NOW=$(date +"%Y-%m-%d %T")

set -u

echo "Hello from ${HOSTNAME} at ${TIME_NOW}"