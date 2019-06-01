provider "google" {
  credentials = "${file("prontotools-9ee97f835c35.json")}"
  project = "prontotools-212000"
  region  = "asia-northeast2"
  zone    = "asia-northeast2-a"
}

resource "google_compute_instance" "tf_instance" {
  name         = "tf-instance-${count.index}"
  machine_type = "n1-standard-1"
  count        = 3

  boot_disk {
    initialize_params {
      image = "ubuntu-1804-bionic-v20190514"
      size  = 30
    }
  }

  metadata = {
    sshKeys = "${var.gce_ssh_user}:${file("~/.ssh/rocket.pub")}"
  }

  network_interface {
    network       = "default"
    access_config = {}
  }

  tags = ["my-web"]
}

resource "google_compute_firewall" "my-http-server" {
  name    = "tf-default-allow-http"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["my-web"]
}

output "ip" {
  value = "${google_compute_instance.tf_instance.*.network_interface.0.access_config.0.nat_ip}"
}
