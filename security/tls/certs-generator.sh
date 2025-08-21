#!/bin/bash

docker run --rm \
  --name wazuh-certs-generator \
  --hostname wazuh-certs-generator \
  -v "$(pwd)/wazuh_ssl_certs/:/certificates/" \
  -v "$(pwd)/certs.yml:/config/certs.yml" \
  wazuh/wazuh-certs-generator:0.0.2