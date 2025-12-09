provider "google" {
  project     = var.gcp_project_id
  region      = var.gcp_region
  credentials = file(var.gcp_credentials_file)
}

resource "google_compute_instance" "student_app" {
  name         = "student-app-${formatdate("YYYYMMDD-hhmmss", timestamp())}"
  machine_type = "e2-medium"
  zone         = var.gcp_zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 20
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

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_firewall" "allow_app_ports" {
  name    = "allow-student-app-${formatdate("YYYYMMDD", timestamp())}"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "9393"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}