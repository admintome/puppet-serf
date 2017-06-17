# puppet server
#
resource "openstack_compute_instance_v2" "puppet" {
  name = "puppet"
  image_name = "ubuntu-16-04"
  availability_zone = "nova"
  flavor_id = "cfe2cfe1-0731-4fbc-99b7-076b8a2d4724"
  key_pair = "oskey"
  security_groups = ["default","puppet","serf"]
  network {
    name = "provider"
  }

  ## Puppet provisioning
  ##

  connection {
    user        = "ubuntu"
    private_key = "${file("file/oskey.pem")}"
    agent       = false
  }

  provisioner "file" {
    source = "site.pp"
    destination = "/tmp/site.pp"

    connection {
      user        = "ubuntu"
      private_key = "${file("file/oskey.pem")}"
      agent       = false
    }
  }

  provisioner "file" {
    source = "puppet-install.sh"
    destination = "/tmp/puppet-install.sh"

    connection {
      user        = "ubuntu"
      private_key = "${file("file/oskey.pem")}"
      agent       = false
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod a+x /tmp/puppet-install.sh",
      "/tmp/puppet-install.sh ${openstack_compute_instance_v2.puppet.network.0.fixed_ip_v4}",
    ]
  }

  ## Serf Provisioning
  ##
  
  provisioner "file" {
    source = "serf-bootstrap.sh"
    destination = "/tmp/serf-bootstrap.sh"

    connection {
      user        = "ubuntu"
      private_key = "${file("file/oskey.pem")}"
      agent       = false
    }
  }

  provisioner "file" {
    source = "serf.service"
    destination = "/tmp/serf.service"

    connection {
      user        = "ubuntu"
      private_key = "${file("file/oskey.pem")}"
      agent       = false
    }
  }

  provisioner "file" {
    source ="file/serf"
    destination = "/tmp/serf"

    connection {
      user = "ubuntu"
      private_key = "${file("file/oskey.pem")}"
      agent = false
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod a+x /tmp/serf-bootstrap.sh",
      "/tmp/serf-bootstrap.sh",
    ]
  }

  
}

# puppet agents
#

variable "count" {
  default = 3
}

data "template_file" "init" {
  template = "${file("file/serf-agent.service.tpl")}"

  vars {
    serf_server_ip = "${openstack_compute_instance_v2.puppet.network.0.fixed_ip_v4}"
  }
}

resource "openstack_compute_instance_v2" "agent" {
  count = "${var.count}"
  depends_on = ["openstack_compute_instance_v2.puppet"]
  name = "${format("agent-%02d", count.index+1)}"
  image_name = "centos-7"
  availability_zone = "nova"
  flavor_id = "6605094c-a5ee-454b-beec-3c4ba723c85d"
  key_pair = "oskey"
  security_groups = ["default","puppet","serf"]
  network {
    name = "provider"
  }

  connection {
    user        = "centos"
    private_key = "${file("file/oskey.pem")}"
    agent       = false
  }

  provisioner "file" {
    source = "puppet-bootstrap.sh"
    destination = "/tmp/puppet-bootstrap.sh"

    connection {
      user        = "centos"
      private_key = "${file("file/oskey.pem")}"
      agent       = false
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod a+x /tmp/puppet-bootstrap.sh",
      "/tmp/puppet-bootstrap.sh ${openstack_compute_instance_v2.puppet.network.0.fixed_ip_v4} ${self.network.0.fixed_ip_v4} ${format("agent-%02d", count.index+1)}",
    ]
  }

  ## Serf Provisioning
  ##

  provisioner "file" {
    source = "file/serf"
    destination = "/tmp/serf"

    connection {
      user        = "centos"
      private_key = "${file("file/oskey.pem")}"
      agent       = false
    }
  }
  
  provisioner "file" {
    content = "${data.template_file.init.rendered}"
    #source = "serf-agent.service"
    destination = "/tmp/serf-agent.service"

    connection {
      user        = "centos"
      private_key = "${file("file/oskey.pem")}"
      agent       = false
    }
  }

  provisioner "file" {
    source      = "handler-dirs/agent/serf-dirs"
    destination = "/tmp"

    connection {
      user        = "centos"
      private_key = "${file("file/oskey.pem")}"
      agent       = false
    }
  }

  provisioner "file" {
    source = "file/runpuppet.sh"
    destination = "/tmp/runpuppet.sh"

    connection {
      user        = "centos"
      private_key = "${file("file/oskey.pem")}"
      agent       = false
    }
  }

  provisioner "file" {
    source = "serf-agent-bootstrap.sh"
    destination = "/tmp/serf-agent-bootstrap.sh"

    connection {
      user        = "centos"
      private_key = "${file("file/oskey.pem")}"
      agent       = false
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod a+x /tmp/serf-agent-bootstrap.sh",
      "/tmp/serf-agent-bootstrap.sh",
    ]
  }
  
}

output "puppet-server-address" {
  value = "${openstack_compute_instance_v2.puppet.network.0.fixed_ip_v4}"
}


output "puppet-agent-addresses" {
  value = "${openstack_compute_instance_v2.agent.*.network.0.fixed_ip_v4}"
}
