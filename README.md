# terraform-spads-test
This repo contains a terraform plan that:
- creates four VMs (au1, eu1, us1, ansible)
- creates the debian user on all VMs
- sets up ssh key auth between anisble and the other VMs
- checks out the ansible-spads-setup repo under the debian user on ansible
- installs ansible so everything is ready to be tested

Install the prerequisites:
sudo apt install snapd
sudo snap install lxd
and terraform (from deb-get, install the binary manually, or install their official repo )

Initlize lxd with the following command:
lxd init
then accept all the defaults

To use:
terraform init
terraform plan
terraform apply

To get into the ansible vm the best way is to use:
lxc exec ansible su - debian

To start fresh either use terraform apply with the destroy flag or:
lxc rm -f au1 eu1 us1 ansible
terraform apply

Note:
When using hostnames append .lxd to the host, for example us1.lxd.
