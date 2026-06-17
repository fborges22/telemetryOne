#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SSL_DIR="${SCRIPT_DIR}/.ssl"
KEEP_SSL="${KEEP_SSL:-false}"

if ! command -v docker >/dev/null 2>&1; then
  echo "docker is required but was not found in PATH." >&2
  exit 1
fi

cd "${SCRIPT_DIR}"

docker compose down --remove-orphans

if [[ "${KEEP_SSL}" != "true" ]]; then
  rm -rf "${SSL_DIR}"
fi

echo "Stack stopped."

if [[ "${KEEP_SSL}" == "true" ]]; then
  echo "TLS assets kept in ${SSL_DIR}."
else
  echo "TLS assets removed from ${SSL_DIR}."
fi
