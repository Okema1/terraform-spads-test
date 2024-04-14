# terraform-spads-test
This repo contains a terraform plan that:
- creates four VMs (au1, eu1, us1, ansible)
- creates the debian user on all VMs
- sets up ssh key auth between anisble and the other VMs
- checks out the ansible-spads-setup repo under the debian user on ansible
- installs ansible so everything is ready to be tested

Install the prerequisites:\
sudo apt install incus\
and [terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

Initlize lxd with the following command:\
incus admin init --minimal


To use:\
terraform init\
terraform plan\
terraform apply

To get into the ansible vm the best way is to use:\
incus exec ansible su - debian

To start fresh either use terraform apply with the destroy flag or:\
incus rm -f au1 eu1 us1 ansible\
terraform apply

Note:\
When using hostnames append .incus to the host, for example us1.incus.
