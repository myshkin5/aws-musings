#!/usr/bin/env bash

set -e

SCRIPTS_DIR=$(dirname $0)

>&2 echo -e "\033[1m\033[42m Starting...   \033[0m"
>&2 echo "Deleting private..."
$SCRIPTS_DIR/private.sh delete
>&2 echo "Deleting public..."
$SCRIPTS_DIR/public.sh delete
>&2 echo "Deleting internal-dns..."
$SCRIPTS_DIR/internal-dns.sh delete
>&2 echo "Deleting vpc..."
$SCRIPTS_DIR/vpc.sh delete
>&2 echo -e "\033[1m\033[42m Complete.     \033[0m"
