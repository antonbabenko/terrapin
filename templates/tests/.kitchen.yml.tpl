---
driver:
  name: terraform

platforms:
  - name: aws

suites:
  - name: default
    verifier:
      name: terraform
      format: doc
      groups:
        - name: default
          attributes:
            sg_name: aws_security_group_bastion_id

    provisioner:
      name: terraform
      apply_timeout: 600
      color: true
      variable_files:
        - testing.tfvars
      directory:   ../
