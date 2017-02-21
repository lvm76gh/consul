provider "aws" {
  access_key = "AKIAI7ZE7FSYPL3ULGNQ"
  secret_key = "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"
  region     = "us-west-2"
}

module "consul" {
    source = "github.com/lvm76gh/consul/terraform/aws"
    key_name = "consul"
    key_path = "/vagrant/Terra/consul.key"
    region = "us-west-2"
    servers = "3"
}


