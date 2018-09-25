#!/usr/bin/env bash

set -e

SCRIPTS_DIR=$(dirname $0)

>&2 echo -e "\033[1m\033[42m Starting...   \033[0m"
$SCRIPTS_DIR/private.sh delete
$SCRIPTS_DIR/public.sh delete
$SCRIPTS_DIR/internal-dns.sh delete
$SCRIPTS_DIR/external-dns.sh delete
$SCRIPTS_DIR/vpc.sh delete
>&2 echo -e "\033[1m\033[42m Complete.     \033[0m"
