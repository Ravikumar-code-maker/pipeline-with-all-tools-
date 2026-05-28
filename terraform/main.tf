provider "google" {

  project = var.project

  region  = var.region
}

resource "google_compute_address" "static_ip" {

  name = "my-static-ip"
}

resource "google_container_cluster" "primary" {

  name = "gke-cluster"

  location = var.region

  initial_node_count = 2
}
