terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

provider "docker" {}

resource "docker_image" "nodered_image" {
  name = "nodered/node-red:latest"
}

resource "random_string" "random" {
  count   = 2
  length  = 4
  special = false
}

resource "docker_container" "nodered_container" {
  count = 2
  name  = join("-", ["nodered", random_string.random[count.index].result])
  image = docker_image.nodered_image.name
  ports {
    internal = 1880
    # external = 1880
  }
}

output "ip_address" {
  value       = [for i in docker_container.nodered_container[*] : join(":", [i.network_data[0].ip_address], i.ports[*]["external"])]
  description = "The IP address of the container"
}

output "container_name" {
  value       = docker_container.nodered_container[*].name
  description = "The name of the container"
}