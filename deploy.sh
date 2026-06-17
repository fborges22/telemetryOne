#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SSL_ARCHIVE="${SSL_ARCHIVE:-$HOME/Downloads/magicssl.tgz}"
SSL_DIR="${SCRIPT_DIR}/.ssl"
TMP_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "${TMP_DIR}"
}

trap cleanup EXIT

require_file() {
  local file_path="$1"

  if [[ ! -f "${file_path}" ]]; then
    echo "Missing required file: ${file_path}" >&2
    exit 1
  fi
}

if ! command -v docker >/dev/null 2>&1; then
  echo "docker is required but was not found in PATH." >&2
  exit 1
fi

if [[ ! -f "${SSL_ARCHIVE}" ]]; then
  echo "SSL archive not found at ${SSL_ARCHIVE}." >&2
  echo "Set SSL_ARCHIVE=/path/to/magicssl.tgz to override the default location." >&2
  exit 1
fi

mkdir -p "${SSL_DIR}"
tar -xzf "${SSL_ARCHIVE}" -C "${TMP_DIR}"

require_file "${TMP_DIR}/ca-bundle.pem"
require_file "${TMP_DIR}/cacert.pem"
require_file "${TMP_DIR}/cert.pem"
require_file "${TMP_DIR}/key.pem"

install -m 0644 "${TMP_DIR}/ca-bundle.pem" "${SSL_DIR}/ca-bundle.pem"
install -m 0644 "${TMP_DIR}/cacert.pem" "${SSL_DIR}/cacert.pem"
install -m 0644 "${TMP_DIR}/cert.pem" "${SSL_DIR}/cert.pem"
install -m 0600 "${TMP_DIR}/key.pem" "${SSL_DIR}/key.pem"
cat "${TMP_DIR}/cert.pem" "${TMP_DIR}/ca-bundle.pem" > "${SSL_DIR}/fullchain.pem"
chmod 0644 "${SSL_DIR}/fullchain.pem"

cd "${SCRIPT_DIR}"

docker compose config >/dev/null
docker compose up -d --remove-orphans
docker compose ps

echo
echo "TLS assets installed in ${SSL_DIR}."
echo "HTTPS UI: https://<host>/grafana/, https://<host>/prometheus/, https://<host>/jaeger/"
echo "OTLP gRPC over TLS: <host>:4317"
echo "OTLP HTTP over TLS: https://<host>:4318"
