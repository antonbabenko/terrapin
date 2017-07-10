Put testing requirements here in yaml-like format, for eg:
* Required version of Terraform
* Required version of testing framework

terraform_version: latest
terraform_kitchen: latest

# Install dependencies

sudo gem install -n /usr/local/bin test-kitchen kitchen-terraform awspec kitchen-verifier-awspec

Some examples:
https://github.com/search?utf8=%E2%9C%93&q=spec_helper+terraform+vpc&type=Code
https://github.com/johnrengelman/terraform-spec/blob/master/example-module/Makefile
https://github.com/tobyclemson/terraform-aws-base-networking/

Working example:
https://github.com/howdoicomputer/terrashovel/tree/master/templates

Action plan
-----------
* During template rendering generate list of resources, variables, types, outputs in cached-meta-file
* Using cached-meta-file generate kitchen-terraform files, terraform.tfvars
* Run tests using specific version of Terraform (using docker, or not)

Tests should verify that requested resources were created properly with correct values.

Extra: Add acceptance tests which act more as smoke tests

Use kitchen.ci + awsspec or terraform-kitchen

Generate report, which should be included in the documentation