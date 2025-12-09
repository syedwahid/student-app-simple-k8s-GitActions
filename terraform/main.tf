terraform {
  required_version = ">= 1.0.0"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project     = var.gcp_project_id
  region      = var.gcp_region
  credentials = file(var.gcp_credentials_file)
}

resource "google_compute_instance" "student_app_vm" {
  name         = "student-app-vm-${formatdate("YYYYMMDD-hhmmss", timestamp())}"
  machine_type = "e2-medium"
  zone         = var.gcp_zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 30
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_pub_key_file)}"
  }

tags = ["student-app", "http-server"]
}

resource "google_compute_firewall" "allow_app_ports" {
  name    = "allow-student-app-ports"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "9393"]
  }

  source_ranges = ["0.0.0.0/0"]
target_tags   = ["http-server"]
}

output "vm_public_ip" {
  value = google_compute_instance.student_app_vm.network_interface[0].access_config[0].nat_ip
}

output "vm_name" {
  value = google_compute_instance.student_app_vm.name
}

output "app_url" {
  value = "http://${google_compute_instance.student_app_vm.network_interface[0].access_config[0].nat_ip}:9393"
}
