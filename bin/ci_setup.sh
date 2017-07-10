#!/bin/bash

# not in use since CircleCI 2.0
exit 0

# Installing dependencies
pip install --quiet --upgrade pip jinja2-cli shyaml

# Test Kitchen
gem install test-kitchen kitchen-terraform awspec

# Install Terraform, Packer, jq and hub
mkdir -p ~/bin/{$TF_VERSION,$JQ_VERSION}
if [[ ! -e ~/bin/${TF_VERSION}/terraform ]]; then wget --no-verbose https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip -O t.zip && unzip -qq t.zip -d ~/bin/${TF_VERSION}; fi
if [[ ! -e ~/bin/${JQ_VERSION}/jq ]]; then wget --no-verbose https://github.com/stedolan/jq/releases/download/jq-${JQ_VERSION}/jq-linux64 -O ~/bin/${JQ_VERSION}/jq && chmod +x ~/bin/${JQ_VERSION}/jq; fi

# Print versions
echo
terraform version
jq --version
pip --version
echo
