#!/usr/bin/env bash

set -e

SCRIPTS_DIR=$(dirname $0)

>&2 echo -e "\033[1m\033[42m Starting...   \033[0m"
>&2 echo "Executing $SCRIPTS_DIR/delete-private-infrastructure.sh..."
$SCRIPTS_DIR/delete-private-infrastructure.sh
>&2 echo "Executing $SCRIPTS_DIR/delete-public-infrastructure.sh..."
$SCRIPTS_DIR/delete-public-infrastructure.sh
>&2 echo "Executing $SCRIPTS_DIR/delete-internal-dns.sh..."
$SCRIPTS_DIR/delete-internal-dns.sh
>&2 echo "Executing $SCRIPTS_DIR/delete-vpc.sh..."
$SCRIPTS_DIR/delete-vpc.sh
>&2 echo -e "\033[1m\033[42m Complete.     \033[0m"
