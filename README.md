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

## What does Terrapin mean?

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

## Getting started

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
