# we only need to add provider here and not wrap it in the module, really
provider "aws" {
  region = "eu-west-1"
}

module "default" {
  source = "../../src"

  # @todo: iterate through the whole set of variables required by this module and print them
}
