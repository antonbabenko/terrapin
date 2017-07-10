#!/bin/bash

#
# This script runs all module tests
#

set -e

# Locate the directory in which this script is located
readonly SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

function run_module_tests {
  local module=""

  while [[ $# > 0 ]]; do
    local key="$1"

    case "$key" in
    --module)
      module="$2"
      shift
      ;;
    *)
      echo "ERROR: Unrecognized argument: $key"
      exit 1
      ;;
    esac

    shift
  done

  cd "$SCRIPT_PATH/../output/modules/$module/tests"

  # Make test provider configuration before running tests
  local test_provider_file="../test_provider.tf"
  echo 'provider "aws" { region = "eu-west-1" }' > "$test_provider_file"

  # "kitchen test" - do all this at once
  kitchen converge
  kitchen verify
  kitchen destroy

  # Remove test provider
  rm "$test_provider_file"
}

run_module_tests "$@"

