resource "aws_instance" "server" {
    ami = "${lookup(var.ami, "${var.region}-${var.platform}")}"
    instance_type = "${var.instance_type}"
    key_name = "${var.key_name}"
    count = "${var.servers}"
    security_groups = ["${aws_security_group.consul.name}"]

    connection {
        user = "${lookup(var.user, var.platform)}"
        private_key = "${file("${var.key_path}")}"
    }

    #Instance tags
    tags {
        Name = "${var.tagName}-${count.index}"
        ConsulRole = "Server"
    }

    provisioner "file" {
        source = "${path.module}/../shared/scripts/${lookup(var.service_conf, var.platform)}"
        destination = "/tmp/${lookup(var.service_conf_dest, var.platform)}"
    }

    # Add nomad start services
    provisioner "file" {
        source = "${path.module}/../shared/scripts/debian_nomad_upstart.conf"
        destination = "/tmp/debian_nomad_upstart.conf"
    }

    # Add nomad client start services
    provisioner "file" {
        source = "${path.module}/../shared/scripts/debian_nomad_client_upstart.conf"
        destination = "/tmp/debian_nomad_client_upstart.conf"
    }
    # Add vault start services
    provisioner "file" {
        source = "${path.module}/../shared/scripts/debian_vault_upstart.conf"
        destination = "/tmp/debian_vault_upstart.conf"
    }

    provisioner "remote-exec" {
        inline = [
            "echo ${var.servers} > /tmp/consul-server-count",
            "echo ${aws_instance.server.0.private_dns} > /tmp/consul-server-addr",
        ]
    }

    provisioner "remote-exec" {
        scripts = [
            "${path.module}/../shared/scripts/install.sh",
            "${path.module}/../shared/scripts/install-nomad.sh",
            "${path.module}/../shared/scripts/install-vault.sh",
            "${path.module}/../shared/scripts/service.sh",
            "${path.module}/../shared/scripts/service-nomad.sh",
            "${path.module}/../shared/scripts/service-nomad-client.sh",
#           "${path.module}/../shared/scripts/install-docker.sh",
            "${path.module}/../shared/scripts/service-vault.sh",
            "${path.module}/../shared/scripts/ip_tables.sh",
            "${path.module}/../shared/scripts/init-nomad.sh",
        ]
    }
}

resource "aws_security_group" "consul" {
    name = "consul_${var.platform}"
    description = "Consul internal traffic + maintenance."

    // These are for internal traffic
    ingress {
        from_port = 0
        to_port = 65535
        protocol = "tcp"
        self = true
    }

    ingress {
        from_port = 0
        to_port = 65535
        protocol = "udp"
        self = true
    }

    ingress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 8
        to_port = 0
        protocol = "icmp"
        self = true
    }

    // These are for maintenance
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    // This is for outbound internet access
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
