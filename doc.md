# UK's split infrastructure

As the instance with the largest traffic and the most scalibility issues UK's server has been chosen to pilot a new infrastructure setup with the changes introduced by https://github.com/openfoodfoundation/ofn-install/pull/734.

As opposed to all the other instance, UK has now a web server and a DB hosted by its service provider, Digital Ocean, using a VPC. We go into detail on how this is achieved below.

## Terraform

### Infrastructure as Code

The infrastructure is defined declaratively in code using [Terraform](https://www.terraform.io/) in `terraform/uk/main.tf`. Changes to that file, like increasing the count of app servers or creating a new DB user, need to be provisioned using Terraform's CLI and they will be immediately applied in Digital Ocean without any manual intervention. 

### State management

Terraform keeps track of the actual state of the infrastructure so it can compare the changes in `terraform/uk/main` against it. That information is transaprently managed by Terraform but its kept in S3, in the backups backet. A number of stores can be used but we chose S3 for convenience.

## How to run

In https://github.com/openfoodfoundation/ofn-install/pull/734 we set up a `bin/cli`. Running it will log you into a docker container with the source code mounted as a volume from where you can run Terraform and Ansible commands. Of course, the first time it will pull a new Ubuntu base image.

### Requirements

You'll need to provide the listed env vars in your shell for `bin/cli` to work:

* DIGITALOCEAN_TOKEN: The token to authenticate against UK's DO account.
* AWS_ACCESS_KEY_ID: Access key of the S3 bucket used by Terraform to store the state.
* AWS_SECRET_ACCESS_KEY: Secret key of the S3 bucket used by Terraform to store the state.

### Bootstrap

The `terraform-bootstrap` key in `terraform/uk/main.tf` is the one needed to issue commands against Digital Ocean, as we would do from its UI or logging in through SSH into the server. Note that you can generate a new key pair under `secrets/terraform-bootstrap` and provision it with Terraform. It will propagate the key in the DO's account.

### Changing the infrastructure

To apply any changes to the infrastructure you just need to:

* Modify the `terraform/uk/main.tf` file as needed.
* Run `./bin/cli`.
* Run `terraform plan` to see which changes are going to be applied
* Run `terraform apply` to perform them.

Also, you can infer a Terraform file or individual resource from the actual infrastructure using the command `terraform import`.

### Provisioning and deployment

Nothing changes in terms of configuration management. Since https://github.com/openfoodfoundation/ofn-install/pull/734 our Ansible playbooks are able to distinguish DB servers and webserver transparently.
