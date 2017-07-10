#!/bin/bash

#
# This script saves Terraform models and documentation (arguments and attributes) from other repositories.
#

set -e

# Locate the directory in which this script is located
readonly SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

function log {
  local readonly message="$1"
  local readonly script_name="$(basename "$0")"

  >&2 echo -e "[$script_name] $message"
}

####################################################################

function generate_resources_from_json {

  local providers_dir="resources/providers/"
  local providers_doc_dir="resources/providers_doc/"

  mkdir -p "$providers_dir" "$providers_doc_dir"

  log "Updating models for all providers (using github repo VladRassokhin/intellij-hcl)"

  local tmp_dir=$(mktemp -d)
  git clone git@github.com:VladRassokhin/intellij-hcl.git "$tmp_dir"

  # force overwrite without asking
  \cp -f ${tmp_dir}/res/terraform/model/providers/*.json "$providers_dir"

  rm -rf "$tmp_dir"

  log "Updating documentation for all providers (using github repo juliosueiras/vim-terraform-completion)"
  local tmp_dir=$(mktemp -d)

  git clone git@github.com:juliosueiras/vim-terraform-completion.git "$tmp_dir"

  # force overwrite without asking
  \cp -f ${tmp_dir}/provider_json/*.json "$providers_doc_dir"

  rm -rf "$tmp_dir"

  log "Done!"

}

generate_resources_from_json
