{% call resource("aws_security_group", "bastion") %}

  {{ variable("name", description="Name of VPC") }}
  {{ variable("vpc_id") }}

  {% if include_description %}
    description = "Bastion security group (only SSH inbound access is allowed)"
  {% endif %}

  {{ variable("tags") }}

{% endcall %}


{% call resource("aws_security_group_rule", "allow_outbound_all") %}

  {{ variable("type", "egress") }}
  {{ variable("from_port", 0) }}
  {{ variable("to_port", 0) }}
  {{ variable("protocol", "-1") }}

  {{ variable("cidr_blocks", ["0.0.0.0/0"]) }}

  {{ variable("security_group_id", "${aws_security_group.bastion.id}") }}

  lifecycle {
    create_before_destroy = true
  }

{% endcall %}


{% call resource("aws_security_group_rule", "allow_inbound_ssh_access") %}

  {{ variable("type", "ingress") }}
  {{ variable("from_port", 22) }}
  {{ variable("to_port", 22) }}
  {{ variable("protocol", "tcp") }}

  {{ variable("cidr_blocks", ["0.0.0.0/0"]) }}

  {{ variable("security_group_id", "${aws_security_group.bastion.id}") }}

  lifecycle {
    create_before_destroy = true
  }

{% endcall %}

{% call data("template_file", "user_data") %}
  {{ variable("template", "${file(\"${path.module}/${var.user_data_file}\")}") }}

  vars {
    s3_bucket_name              = "${var.s3_bucket_name}"
    s3_bucket_uri               = "${var.s3_bucket_uri}"
    ssh_user                    = "${var.ssh_user}"
    keys_update_frequency       = "${var.keys_update_frequency}"
    enable_hourly_cron_updates  = "${var.enable_hourly_cron_updates}"
    additional_user_data_script = "${var.additional_user_data_script}"
  }

  {{ define_variable("user_data_file", default="\"user_data.sh\"") }}
  {{ define_variable("s3_bucket_name") }}
  {{ define_variable("s3_bucket_uri") }}
  {{ define_variable("ssh_user") }}
  {{ define_variable("keys_update_frequency") }}
  {{ define_variable("enable_hourly_cron_updates") }}
  {{ define_variable("additional_user_data_script") }}

{% endcall %}

{% call resource("aws_launch_configuration", "bastion") %}
  {{ variable("name_prefix", "${var.name}-") }}
  {{ variable("image_id") }}
  {{ variable("instance_type") }}
  {{ variable("user_data", "${data.template_file.user_data.rendered}") }}

  {{ variable("security_groups", ["${compact(concat(list(aws_security_group.bastion.id), var.security_group_ids))}"]) }}
  {{ define_variable("security_group_ids", "list") }}

  {{ variable("iam_instance_profile") }}

  lifecycle {
    create_before_destroy = true
  }
{% endcall %}

{% call resource("aws_autoscaling_group", "bastion") %}
  {{ variable("name") }}
  {{ variable("vpc_zone_identifier", ["${var.subnet_ids}"]) }}
  {{ define_variable("subnet_ids", "list", set_default=false) }}

  {{ variable("desired_capacity", "1") }}
  {{ variable("min_size", "1") }}
  {{ variable("max_size", "1") }}
  {{ variable("health_check_grace_period", "60") }}
  {{ variable("health_check_type", "EC2") }}
  {{ variable("force_delete", false, set_default=false) }} {# @todo: do not render in variables() when static values are provided, because it is not customizable #}

  {{ variable("wait_for_capacity_timeout", "0") }}
  {{ variable("launch_configuration", "${aws_launch_configuration.bastion.name}") }}

  tag {
    key                 = "Name"
    value               = "${var.name}"
    propagate_at_launch = true
  }

  tag {
    key                 = "EIP"
    value               = "${var.eip}"
    propagate_at_launch = true
  }
  {{ define_variable("eip") }}

  lifecycle {
    create_before_destroy = true
  }
{% endcall %}
