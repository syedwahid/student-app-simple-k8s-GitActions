output "vm_public_ip" {
  value = google_compute_instance.student_app_vm.network_interface[0].access_config[0].nat_ip
}

output "vm_instance_name" {
  value = google_compute_instance.student_app_vm.name
}

output "app_url" {
  value = "http://${google_compute_instance.student_app_vm.network_interface[0].access_config[0].nat_ip}:9393"
}