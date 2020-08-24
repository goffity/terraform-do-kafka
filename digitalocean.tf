data "digitalocean_ssh_key" "default" {
 name = var.ssh_key_name
}

data "digitalocean_project" "AIS-Realtime" {
  name = "AIS-Realtime"
}

resource "digitalocean_droplet" "ais_kafka" {
  image              = "centos-7-x64"
  name               = "kafka"
  region             = "sgp1"
  size               = "s-1vcpu-2gb"
  monitoring         = true
  private_networking = true
  ssh_keys           = [data.digitalocean_ssh_key.default.fingerprint]
  connection {
    host        = self.ipv4_address
    user        = "root"
    type        = "ssh"
    private_key = file(var.pvt_key)
    timeout     = "2m"
  }

  provisioner "file" {
    source      = "conf/"
    destination = "/etc/systemd/system"
  }

  provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin",
      "yum update -y",
      "yum install java-1.8.0-openjdk wget -y",
      "wget http://downloads.lightbend.com/scala/2.11.8/scala-2.11.8.rpm",
      "yum install scala-2.11.8.rpm -y",
      "wget https://downloads.apache.org/kafka/2.6.0/kafka_2.13-2.6.0.tgz -O /opt/kafka_2.13-2.6.0.tgz",
      "cd /opt",
      "tar -xvf kafka_2.13-2.6.0.tgz",
      "ln -s /opt/kafka_2.13-2.6.0 /opt/kafka",
      "useradd kafka",
      "chown -R kafka:kafka /opt/kafka*",
      "systemctl enable zookeeper.service",
      "systemctl enable kafka.service",
      "systemctl start zookeeper.service",
      "systemctl start kafka.service"
    ]
  }
 }

resource "digitalocean_project_resources" "AIS-Realtime" {
  project = data.digitalocean_project.AIS-Realtime.id
  resources = [
    digitalocean_droplet.ais_kafka.urn
  ]
}