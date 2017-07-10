####################################
# Value was set, so argument can not be parametrized and there should not be variable block
####################################

# Terraform resource name as value
# variable("security_group_id", "${aws_security_group.group.id}", resource_type="aws_security_group_rule")

security_group_id = "${aws_security_group.group.id}"

# Formatting according to variable's type
# aws_security_group name (string):
# variable("name", "value", resource_type="aws_security_group")

name = "value"

# aws_security_group_rule cidr_blocks (list), given value as empty list:
# variable("cidr_blocks", [], resource_type="aws_security_group_rule")

cidr_blocks = []

# aws_security_group_rule cidr_blocks (list), given value as list:
# variable("cidr_blocks", ["10.20.30.40/32", "127.0.0.1/32"], resource_type="aws_security_group_rule")

cidr_blocks = ["10.20.30.40/32", "127.0.0.1/32"]

# aws_security_group_rule cidr_blocks (list), given value as string:
# variable("cidr_blocks", "10.20.30.40/32", resource_type="aws_security_group_rule")

cidr_blocks = ["10.20.30.40/32"]

# Print variables. Should not output anything.

####################################
# Value was not set, so argument can be parametrized and there should be variable block
####################################

# Omitting value should use terraform variable
# variable("from_port", resource_type="aws_security_group_rule")

from_port = "${var.from_port}"

# aws_security_group_rule cidr_blocks (list), no value:
# variable("cidr_blocks", resource_type="aws_security_group_rule")

cidr_blocks = "${var.cidr_blocks}"

# Print variables

variable "cidr_blocks" {
  type = "list"

  default = []
}

variable "from_port" {
  default = ""
}

####################################
# Meta arguments
####################################

# Include variable's description and value
# variable("vpc_id", "value", resource_type="aws_security_group", description="VPC ID")

vpc_id = "value"

# Print variables. Should not output anything.

####################################
# Enable default values
####################################

# Set default value for variable (depending on type)
# aws_security_group tags (map):
# variable("tags", resource_type="aws_security_group", set_default=true)

tags = "${var.tags}"

# aws_security_group name (string):
# variable("name", resource_type="aws_security_group", set_default=true)

name = "${var.name}"

# aws_security_group cidr_blocks (list):
# variable("cidr_blocks", resource_type="aws_security_group_rule", set_default=true)

cidr_blocks = "${var.cidr_blocks}"

# Print variables

variable "cidr_blocks" {
  type = "list"

  default = []
}

variable "name" {
  default = ""
}

variable "tags" {
  type = "map"

  default = {}
}

####################################
# Disable default values
####################################

# Do not set default value for variable
# variable("tags", resource_type="aws_security_group", description="Tags for security group", set_default=false)

tags = "${var.tags}"

# Print variables

variable "tags" {
  type = "map"

  description = "Tags for security group"
}

####################################
# Only define_variable()
####################################

# Define variable type string
# define_variable("var1")

variable "var1" {
  default = ""
}

# Define variable type string with default value in double quotes
# define_variable("var2", default="\"user_data.sh\"")

variable "var2" {
  default = "user_data.sh"
}

# Define variable type list
# define_variable("var_list", "list")

variable "var_list" {
  type = "list"

  default = []
}

# Define variable type boolean should either disable set_default or set boolean default value.
# define_variable("var_boolean", "boolean", set_default=false)

variable "var_boolean" {}

# Define variable type boolean with default value as boolean
# define_variable("var_boolean_with_default_true", "boolean", default=true)
# define_variable("var_boolean_with_default_false", "boolean", default=false)

variable "var_boolean_with_default_false" {
  default = false
}

variable "var_boolean_with_default_true" {
  default = true
}

# This is incorrect, because boolean variables should either have set_default=false, default=false or default=true:
# define_variable("var_boolean", "boolean")

# Define variable type map
# define_variable("var_map", "map")

variable "var_map" {
  type = "map"

  default = {}
}

# Define variable which with default value overridden
# define_variable("var_map_overide", "map")
# define_variable("var_map_overide", "map", default="{\"yo\" = \"man\", key = \"value\"}")

variable "var_map_overide" {
  type = "map"

  default = {
    "yo" = "man"

    key = "value"
  }
}

# Define variable without default value set
# define_variable("var_list_no_default", "list", set_default=false)

variable "var_list_no_default" {
  type = "list"
}

# Define variable type list with default value and set_default is fals
# define_variable("var_list_with_default1", "list", default="[\"a\", \"b\"]", set_default=false)

variable "var_list_with_default1" {
  type = "list"
}

# Define variable type list with default value and set_default is true
# define_variable("var_list_with_default2", "list", default="[\"a\", \"b\"]", set_default=true)

variable "var_list_with_default2" {
  type = "list"

  default = ["a", "b"]
}

# Define variable with default and description
# define_variable("var_string_with_description_and_default", default="\"default-value\"", description="This is my description")

variable "var_string_with_description_and_default" {
  description = "This is my description"

  default = "default-value"
}
