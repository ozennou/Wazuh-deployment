#!/bin/bash

set -e

docker run --rm \
  --name wazuh-certs-generator \
  --hostname wazuh-certs-generator \
  -v "$(pwd)/stack/security/tls/wazuh_ssl_certs/:/certificates/" \
  -v "$(pwd)/stack/security/tls/certs.yml:/config/certs.yml" \
  wazuh/wazuh-certs-generator:0.0.2

echo "Generating nginx SSL certificates..."

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout $(pwd)/stack/security/tls/wazuh_ssl_certs/nginx.key \
    -out $(pwd)/stack/security/tls/wazuh_ssl_certs/nginx.crt \
    -subj "/CN=localhost"

echo "Certificates generated"

chown -R 1000:1000 "$(pwd)/stack/security/tls/wazuh_ssl_certs/"
chmod -R -600 "$(pwd)/stack/security/tls/wazuh_ssl_certs/"