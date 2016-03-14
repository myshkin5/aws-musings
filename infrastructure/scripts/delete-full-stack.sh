#!/usr/bin/env bash

set -e

SCRIPTS_DIR=$(dirname $0)

$SCRIPTS_DIR/delete-private-infrastructure.sh
$SCRIPTS_DIR/delete-public-infrastructure.sh
$SCRIPTS_DIR/delete-vpc.sh
