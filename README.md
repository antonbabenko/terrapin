# Terrapin

[![CircleCI](https://circleci.com/gh/antonbabenko/terrapin.svg?style=svg&circle-token=5017cf1aa95e1b88eb769da64721be1277e2d796)](https://circleci.com/gh/antonbabenko/terrapin)
[![MIT license](https://img.shields.io/github/license/antonbabenko/terrapin.svg)]()

***CODE IN THIS REPOSITORY IS NOT READY TO BE USED PUBLICLY, BUT IT WILL BE GOOD AFTER SUMMER BREAK!***

<img src="https://raw.githubusercontent.com/antonbabenko/terrapin/master/terrapin.png" alt="Terrapin - Terraform modules generator" align="right" />

Terrapin is a [Terraform](http://terraform.io/) module generator which supports creation of Terraform configuration files, automated tests, usage examples and documentation.

Terrapin process source files and generates complete module. At its simplest, a command-line call

```bash
./bin/generate_module.sh --module aws_bastion_s3_keys
```

will create complete module inside `./output/modules/aws_bastion_s3_keys`.

Terrapin is designed with a goal to generate canonical code for [terraform-community-modules](https://github.com/terraform-community-modules/). Read my blog post about [common traits in modules](https://medium.com/@anton.babenko/using-terraform-continuously-common-traits-in-modules-8036b71764db).

## What Terrapin is NOT?

It is not going to take your job (at least not yet). Developers should still design infrastructure components and understand how Terraform works.

## Then why should I use Terrapin?

Using Terrapin developers focus on creating rather DRY template files, which is then used to generate the rest. All Terraform properties like variables, outputs, tfvars and defaults are generated from source templates, type of attributes is validated.

See code inside `modules/aws_bastion_s3_keys` for reference.

## Prerequisites

* Terraform ~> 0.9
* Python 2.7+ with PIP `jinja2-cli`

To run acceptance tests you will need to have Ruby 2.4+ with these gems: `test-kitchen kitchen-terraform awspec`.

## Getting started

You know what Terrapin is you can read further or [start hacking](#start-hacking).

/// ## Directories and files structure

Source code of modules is inside `modules` directory. For example, single module is inside `modules/aws_bastion_s3_keys`  and source templates are inside `templates` directory. `meta.yml` is not in currently in use, so you can skip it. `templates` directory should contain at least one template file with extension `.tf.tpl`.

## Getting started - where to change what

## Template syntax

Terraform templates are being generating from Jinja templates, where [full power of Jinja](http://jinja.pocoo.org/docs/2.9/templates/) and several custom macros are available. For more detailed examples on usage of Jinja macros check tests in `tests/templates/basic`.

Jinja macros are inside `templates/macros/macros.jinja2`. There are there custom macros which developers should use in Jinja templates:

* resource
* data
* variable
* define_variable
* variables
* outputs
 
### {{ resource(type, name) }}

Generates [Terraform's resource configuration](https://www.terraform.io/docs/configuration/resources.html). Use [call block](http://jinja.pocoo.org/docs/2.9/templates/#call) to call `resource` macros.

Example:
```jinja2
{% call resource("aws_security_group", "bastion") %}
...
{% endcall %}
```

### {{ data(type, name) }}

Generates [Terraform's data source configuration](https://www.terraform.io/docs/configuration/data-sources.html). Use [call block](http://jinja.pocoo.org/docs/2.9/templates/#call) to call `data` macros.

Example:
```jinja2
{% call data("template_file", "user_data") %}
...
{% endcall %}
```

### {{ variable(argument_name [, argument_value] [, description=...] [, default=...] [, set_default=...] [, resource_type=...] [, data_type=...]) }}

Generates Terraform configuration code for an argument named `argument_name` of `resource` or `data` block where this macros is called from.

Macro arguments:
- `argument_name` - Name of the argument to render (required)
- `argument_value` - Value of the argument (optional)
- `description` - [A human-friendly description for the variable](https://www.terraform.io/docs/configuration/variables.html#description-1) (optional)
- `default` - [Default value for the variable](https://www.terraform.io/docs/configuration/variables.html#default) (optional)
- `set_default` - Whether to set `default` value for thу variable (optional, enabled by default)
- `resource_type` - Resource type to use for this variable. Set this when calling this macros outside of `resource` call block (eg, in tests) (optional)
- `data_type` - Data source type to use for this variable. Set this when calling this macros outside of `data` call block (eg, in tests) (optional)

Example 1:
```jinja2
{% call resource("aws_security_group", "bastion") %}
  {{ variable("vpc_id") }}
{% endcall %}
```
will render:
```hcl-terraform
resource "aws_security_group" "bastion" {
  vpc_id = "${var.vpc_id}"
}
```

Example 2 (set default value in `name` parameter, `name` is parametrized):
```hcl-terraform
{{ variable("name", default="bastion-vpc") }}
```
will render:
```hcl-terraform
resource ... {
  name = "${var.name}"
}

// variables() macro will render this:
variable "name" {}
```

Example 3 (set argument value, `name` can't be parametrized):
```hcl-terraform
{{ variable("name", "bastion-vpc") }}
```
will render:
```hcl-terraform
resource ... {
  name = "bastion-vpc"
}

// variables() macro will not render anything
```

Notes:
1. When `argument_value` is not specified:
    1. It is rendered as `${var.argument_name}`.
    1. The variable is considered required and Terraform module will error if it is not set.
    1. Value will be formatted according to Terraform type this argument has:
       - list: `["${var.argument_name}"]`
       - boolean and integer: `${var.argument_name}`
       - string and map: `"${var.argument_name}"`
    1. `argument_name` will be appended to [Terraform's variables](https://www.terraform.io/docs/configuration/variables.html)


### {{ define_variable(variable_name [, variable_type] [, description=...] [, default=...] [, set_default=...]) }}

Generates Terraform configuration code for a parametrized variable named `variable_name` which has type `variable_type`.

Macro arguments:
- `variable_name` - Name of the variable to parametrize (required)
- `variable_type` - Type of the variable (optional). Available values: `boolean`, `list`, `map` or `string` (default).
- `description` - [A human-friendly description for the variable](https://www.terraform.io/docs/configuration/variables.html#description-1) (optional)
- `default` - [Default value for the variable](https://www.terraform.io/docs/configuration/variables.html#default) (optional)
- `set_default` - Whether to set `default` value for thу variable (optional, enabled by default)

The differences between `define_variable` and `variable` macros are:
1. `define_variable` only define `variable_name` as a parameter, so that it appears in the list of [Terraform's variables](https://www.terraform.io/docs/configuration/variables.html) (see `variables()` macros) and does not render any code
1. `define_variable` does not relate `variable_name` to specific resource or data source type, therefore it requires to provide `variable_type` for each variable (default is string).

`define_variable` allows variable to be parametrized and be used as a part of another variable. In the following example `user_data_file` is a parametrized variable with default value (note escaped double quotes). `user_data_file` is used as a value inside interpolation of `template` value:

```jinja2
{% call data("template_file", "user_data") %}
  {{ variable("template", "${file(\"${path.module}/${var.user_data_file}\")}") }}

  {{ define_variable("user_data_file", default="\"user_data.sh\"") }}
{% endcall %}
```

It renders as:
```hcl-terraform
data "template_file" "user_data" {
  template = "${file("${path.module}/${var.user_data_file}")}"
}

// variables() macro will render this:
variable "user_data_file" {
  default = "user_data.sh"
}
```

### {{ variables() }}

Generates [Terraform's variables configuration](https://www.terraform.io/docs/configuration/variables.html).

This macros in explicitly invoked only in tests, but in real templates it is appended by helper script (such as `./bin/generate_module.sh`) and developers should not call it into templates.

### {{ outputs() }}

Generates [Terraform's outputs configuration](https://www.terraform.io/docs/configuration/outputs.html).

This macros in explicitly invoked only in tests, but in real templates it is appended by helper script (such as `./bin/generate_module.sh`) and developers should not call it into templates.

### Template composition


## Complete example code

## Contribute code

## Example with loops, ifs, etc

## Limitations

# Start hacking

Terrapin currently has a bit more dependencies than it can have. The complete list of dependencies is inside `.circleci/images/antonbabenko/terrapin/Dockerfile`.

## What does "terrapin" mean?

Terrapin (wiki: [portable building](https://en.wikipedia.org/wiki/Portable_building)) is a type of prefabricated one-storey building for temporary use.

.....................................
... @todo below ....
.....................................

## Content

This repo contains code which generates Terraform modules (together with some important extras):

* Terraform module code generator (shell scripts)
* Jinja helpers and macros, which can be used inside terraform module templates
* Terraform module templates (source)
* Misc templates (readme, documentation, examples, tests, etc)
* Auto-generated modules
* Web-site (github pages from docs dir)

## To-do for pre-release (open source)

* Write static documentation describing all the process, structure, workflow
* Write documentation describing generated modules and complete examples (AWS and not-AWS specifics)
* Cleanup folders, merge previous commits and make it public

An open-source tool for generating Terraform modules.
Our goal is to provide a comprehensive and extensible framework for generating Terraform modules according to best-practices [*].

## Key components include:

1. Everything what user change often is located inside `modules` (see more "[Community managed modules](#community-managed-modules)")
1. Terraform module generator internals:
    1. Various templates in `templates` (docs, examples, macros, tests)
    2. Extracted resources in `resources` (Terraform variables and outputs)

# Community managed modules 

* modules
  * Template source: *.tf.tpl
  * Module helpers (shell scripts or other files)
* templates
* tests/templates: templates functional tests

## Credits

* Documentation fetched from https://github.com/juliosueiras/vim-terraform-completion/tree/master/provider_json
* Model's arguments fetched from https://github.com/VladRassokhin/intellij-hcl/tree/master/res/terraform/model
* Terrapin photo from http://tinyhouseswoon.com/the-terrapin/

## License

See the [LICENSE](LICENSE) file for license rights and limitations (MIT).
