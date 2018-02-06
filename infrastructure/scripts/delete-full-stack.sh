#!/usr/bin/env bash

set -e

SCRIPTS_DIR=$(dirname $0)

>&2 echo -e "\033[1m\033[42m Starting...   \033[0m"
>&2 echo "Deleting infrastructure-private..."
$SCRIPTS_DIR/../../scripts/delete-stack.sh infrastructure-private
>&2 echo "Deleting infrastructure-public..."
$SCRIPTS_DIR/../../scripts/delete-stack.sh infrastructure-public
>&2 echo "Deleting infrastructure-internal-dns..."
$SCRIPTS_DIR/../../scripts/delete-stack.sh infrastructure-internal-dns
>&2 echo "Deleting infrastructure-vpc..."
$SCRIPTS_DIR/../../scripts/delete-stack.sh infrastructure-vpc
>&2 echo -e "\033[1m\033[42m Complete.     \033[0m"
