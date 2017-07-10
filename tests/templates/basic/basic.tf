resource "aws_security_group" "bastion" {
  name = "${var.name}"

  vpc_id = "${var.vpc_id}"

  tags = "${var.tags}"
}

variable "name" {
  description = "Name of VPC"

  default = ""
}

variable "tags" {
  type = "map"

  default = {}
}

variable "vpc_id" {
  default = ""
}

# aws_security_group.bastion
output "aws_security_group_bastion_id" {
  value = "${aws_security_group.bastion.id}"
}

output "aws_security_group_bastion_vpc_id" {
  value = "${aws_security_group.bastion.vpc_id}"
}

output "aws_security_group_bastion_owner_id" {
  value = "${aws_security_group.bastion.owner_id}"
}

output "aws_security_group_bastion_name" {
  value = "${aws_security_group.bastion.name}"
}

output "aws_security_group_bastion_description" {
  value = "${aws_security_group.bastion.description}"
}

output "aws_security_group_bastion_ingress" {
  value = "${aws_security_group.bastion.ingress}"
}

output "aws_security_group_bastion_egress" {
  value = "${aws_security_group.bastion.egress}"
}

output "aws_security_group_bastion_name_prefix" {
  value = "${aws_security_group.bastion.name_prefix}"
}

output "aws_security_group_bastion_tags" {
  value = "${aws_security_group.bastion.tags}"
}