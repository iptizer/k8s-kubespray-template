# Bootstrap

The following lines document how to initalize a fresh cluster. On a real cluster, or using Vagrant. Todo so, the kubespray project will be clones to this directory. It will be excluded in *.gitignore* and all files are in this folder.

## How to use this repository?

This repository is intended to be used as a template repository to run the whole infrastructure. It may have the following folders:

```txt
├── README.md      # Documentation on setup
├── init.sh        # Init script
├── .gitattributes # Setting up git-crypt for secret storage
├── inventory      # Inventory and kubespray config to be synced to kubespray directory
├── k8s     
│   ├── namespace1 # Kubernetes manifests for different namespaces
│   ├── namespace2
│   └── README.md # Documentation for Kubernetes objects
└── kubespray     # Checked out kubespray project. WARNING: Content will remove regularly.
```

## Prerequisits

Using this approach requires a lot of tools and not all may work on a Windows computer. The following software is required:

* python
* pyenv
* Virtualbox (for the local vm setup)
* vagrant (for the local vm setup)

## Tools used

See [kubespray.io](https://kubespray.io/) on detailed information about kubespray. Kubespray is a set of ansible playbooks to setup even complex Kubernetes environments.

See [https://developer.hashicorp.com/vagrant/docs](https://developer.hashicorp.com/vagrant/docs) for details. Vagrant may be used to set up local development environments.

## Vagrant

These lines explain details about the local setup.

```sh
# execute init script. This will also chdir to the kubespray folder.
. ./init.sh
# the following commnd will spin up a vm with virtualbox and provision with kubespray
vagrant up
# in case provisioning did not success, retry with the following command
vagrant provision
# ssh to your worker node
vagrant ssh k8s-1
```

## Prod

Prepare server:

* deactivate swap on the remote server
* `youruser username     ALL=(ALL) NOPASSWD:ALL`

```sh
ssh centos@<ip>
# auth via pw
sudo su - root
adduser youruser
visudo # add as sudo user
su - youruser
sudo yum -y install vim python3
ssh-keygen
vim .ssh/authorized_users # paste key
chmod 644 .ssh/authorized_keys
# check whether login works with ssh key
sudo vim /etc/ssh/sshd_config # remove pw auth & root login
sudo yum upgrade -y && sudo reboot
```

Install Kubernetes:

```sh
. ./init.sh
# follow instructions from output, sth like:
cd kubespray
ansible-playbook -i inventory/prod/inventory.ini cluster.yml
```

And get credentials:

```sh
ssh <ip>
sudo su - root
cd
cp -r .kube /home/youruser/
chown -R youruser. /home/youruser/.kube
#ctrl + d
kubectl get ns # test connection
#ctrl + d
scp yourdomain.de:/home/youruser/.kube/config .kube/config
```

## Upgrade cluster

Check the current default value of `kube_version` in cloned repository.

**FOR K8S VERSION - Edit ./inventory/prod/group_vars/k8s-cluster/k8s-cluster.yml**

```sh
cd kubespray
ansible-playbook -i inventory/prod/inventory.ini -e kube_version=v1.22.10 -e upgrade_cluster_setup=true cluster.yml
# or just the newest version
ansible-playbook -i inventory/prod/inventory.ini -e upgrade_cluster_setup=true cluster.yml
# upgrade to specific calico version (did not trigger/ failed)
ansible-playbook -i inventory/prod/inventory.ini -e upgrade_cluster_setup=true -e calico_version=v3.15.2 cluster.yml --tags=network
```