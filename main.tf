terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# Create VM instance
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
    access_config {
      // Ephemeral public IP
    }
  }

  # Metadata for SSH - using GitHub Actions generated key
  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_pub_key_file)}"
  }

  # Startup script to install Docker
  metadata_startup_script = <<-EOF
    #!/bin/bash
    
    # Update and install Docker
    apt-get update
    apt-get install -y docker.io
    systemctl enable docker
    systemctl start docker
    usermod -aG docker ubuntu
    
    # Create app directory
    mkdir -p /opt/student-app
    chown -R ubuntu:ubuntu /opt/student-app
    
    echo "VM setup completed at $(date)" >> /var/log/startup.log
  EOF

  tags = ["http-server", "https-server", "student-app"]

  service_account {
    scopes = ["cloud-platform"]
  }
}

# Firewall rules for application ports
resource "google_compute_firewall" "allow_web" {
  name    = "allow-student-app-ports"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "9393"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["student-app"]
}

# Static IP for the VM
resource "google_compute_address" "static_ip" {
  name   = "student-app-ip-${formatdate("YYYYMMDD", timestamp())}"
  region = var.gcp_region
}

output "vm_public_ip" {
  value = google_compute_address.static_ip.address
  description = "Public IP address of the VM"
}

output "vm_name" {
  value = google_compute_instance.student_app_vm.name
  description = "Name of the VM instance"
}

output "app_url" {
  value = "http://${google_compute_address.static_ip.address}:9393"
  description = "Application URL"
}
