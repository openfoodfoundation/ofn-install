terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
    }
  }

  backend "s3" {
    bucket = "ofn-uk-production-backups-new"
    key    = "terraform/terraform.tfstate"
    region = "us-east-1"
  }
}

locals {
  do_region = "lon1"
}

resource "digitalocean_ssh_key" "terraform" {
  name       = "terraform-bootstrap"
  public_key = file("/opt/ofn-install/secrets/terraform-bootstrap.pub")
}

resource "digitalocean_vpc" "production" {
  name     = "ofn-production"
  region   = local.do_region
  ip_range = "10.0.0.0/24"
}

resource "digitalocean_droplet" "appservers_production" {
  count    = 1
  image    = "ubuntu-18-04-x64"
  name     = "app0${count.index + 1}"
  region   = local.do_region
  size     = "s-4vcpu-8gb"
  ssh_keys = [digitalocean_ssh_key.terraform.fingerprint]
  vpc_uuid = digitalocean_vpc.production.id
}

resource "digitalocean_database_cluster" "production" {
  name                 = "ofn-db"
  engine               = "pg"
  version              = "12"
  size                 = "db-s-2vcpu-4gb"
  region               = local.do_region
  node_count           = 1
  private_network_uuid = digitalocean_vpc.production.id
}

resource "digitalocean_database_firewall" "production" {
  cluster_id = digitalocean_database_cluster.production.id

  rule {
    type  = "ip_addr"
    value = "10.0.0.0/24"
  }

}

resource "digitalocean_database_db" "ofn_database" {
  cluster_id = digitalocean_database_cluster.production.id
  name       = "openfoodnetwork"
}

resource "digitalocean_database_user" "ofn_user" {
  cluster_id = digitalocean_database_cluster.production.id
  name       = "ofn_user"
}

resource "digitalocean_database_user" "ofn_data" {
  cluster_id = digitalocean_database_cluster.production.id
  name       = "ofn_data"
}

resource "digitalocean_database_user" "zapier" {
  cluster_id = digitalocean_database_cluster.production.id
  name       = "zapier"
}

resource "digitalocean_database_user" "datadog" {
  cluster_id = digitalocean_database_cluster.production.id
  name       = "datadog"
}

resource "digitalocean_project" "uk" {
  name        = "ofn-uk"
  description = "Open Food Network UK"
  purpose     = "Web Application"
  environment = "Production"
  resources = flatten([
    digitalocean_droplet.appservers_production[*].urn,
    digitalocean_database_cluster.production.urn
  ])
}
