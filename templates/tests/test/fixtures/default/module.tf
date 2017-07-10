# we only need to add provider here and not wrap it in the module, really
provider "aws" {
  region = "eu-west-1"
}

module "default" {
  source  = "../../../../"
}
