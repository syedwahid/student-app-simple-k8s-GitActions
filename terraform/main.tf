provider "google" {
  project     = var.gcp_project_id
  region      = var.gcp_region
  credentials = file(var.gcp_credentials_file)
}

# Generate random ID for resources
resource "random_id" "instance_id" {
  byte_length = 4
}

resource "google_compute_instance" "student_app_vm" {
  name         = "student-app-vm-${random_id.instance_id.hex}"
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

  # Allow time for SSH to be ready
  provisioner "remote-exec" {
    inline = [
      "echo 'VM is ready for SSH connections'"
    ]
    
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_file)
      host        = self.network_interface[0].access_config[0].nat_ip
    }
  }
}

resource "google_compute_firewall" "allow_http" {
  name    = "allow-http-${random_id.instance_id.hex}"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "3000", "7373", "9393", "22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}

# Store SSH key in local file for use in deployment step
resource "local_file" "ssh_private_key" {
  content  = file(var.ssh_private_key_file)
  filename = "${path.module}/generated_ssh_key"
  
  provisioner "local-exec" {
    command = "chmod 600 ${path.module}/generated_ssh_key"
  }
}