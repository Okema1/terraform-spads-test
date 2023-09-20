terraform {
  required_providers {
    lxd = {
      source  = "terraform-lxd/lxd"
      version = "1.10.2"
    }
  }
}

resource "random_password" "password" {
  length           = 16
  special          = false
}

resource "lxd_instance" "instances" {
  name     = each.key
  image    = var.image
  profiles = ["default", "${lxd_profile.spads.name}"]
  type     = var.type
  
  for_each = var.instances
}

resource "lxd_instance" "ansible" {
  name     = "ansible"
  image    = var.image
  profiles = ["default", "${lxd_profile.spads.name}"]
  type     = var.type
}

resource "lxd_profile" "spads" {
  name = "spads"
  
  device {
    type = "disk"
    name = "root"
    properties = {
      pool = "default"
      path = "/"
      size = var.disk
    }
  }
  
  config = {
    "limits.cpu"           = var.cpu
    "limits.memory"        = var.memory
    "cloud-init.user-data" = <<-EOT
    #cloud-config
     packages:
      - openssh-server
      - sshpass
      - git
      - sd
      - dnsutils
      - python3
     write_files:    
      - path: /root/inventory
        content: |
          au1.lxd ansible_user=debian
          eu1.lxd ansible_user=debian
          us1.lxd ansible_user=debian
          
          # add each server to the matching region below
          [au]
          au1.lxd
          
          [eu]
          eu1.lxd
          
          [us]
          us1.lxd
          
          # the group containing each region
          [spads:children]
          au
          eu
          us
      - path: /root/main.sh
        content: |
          #!/bin/bash
          runuser -l debian -c 'ssh-keygen -t ed25519 -q -N "" -f ~/.ssh/id_ed25519'
          runuser -l debian -c 'sleep 5'
          
          for host in "au1" "eu1" "us1" ;
            do
              runuser -l debian -c "ssh-keyscan $host.lxd >> ~/.ssh/known_hosts"
              runuser -l debian -c "echo ${random_password.password.result} | sshpass ssh-copy-id debian@$host.lxd"
              sd "$(echo $host)changeme" "$(dig +short $host.lxd)" /root/inventory      
            done

          if [ $(hostnamectl --static) == "ansible" ]; then
            runuser -l debian -c 'git clone https://github.com/beyond-all-reason/ansible-spads-setup.git'
            cp -f /root/inventory /home/debian/ansible-spads-setup/inventory
            chown debian /home/debian/ansible-spads-setup/inventory
            apt install ansible -y
          fi
     chpasswd:
        expire: false
     users:
      - name: debian
        lock_passwd: false
        plain_text_passwd: ${random_password.password.result} 
        gecos: Debian
        groups: [adm, audio, cdrom, dialout, dip, floppy, netdev, plugdev, sudo, video]
        sudo: ["ALL=(ALL) NOPASSWD:ALL"]
        shell: /bin/bash
     ssh_pwauth: true
     runcmd:
      - bash /root/main.sh
  EOT
  }
}