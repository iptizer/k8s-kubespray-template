#!/bin/sh

# check whether script is sourced
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && echo "script is  executed, but needs to be sourced" && exit 1

echo "######################################################################################"
echo "##  Reinit repository"
rm -rf kubespray
VERSION="release-2.24"
git clone --branch $VERSION https://github.com/kubernetes-sigs/kubespray.git

echo "######################################################################################"
echo "##  Activating pyenv venv"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
pyenv virtualenv 3.10.8 infrapuzzle-bootstrap
pyenv activate infrapuzzle-bootstrap
python -m pip install -r kubespray/requirements.txt


echo "######################################################################################"
echo "##  Customizing vagrant dev env"
mkdir -p kubespray/vagrant
cat << EOF > kubespray/vagrant/config.rb
\$instance_name_prefix = "k8s"
\$vm_cpus = 4
\$num_instances = 1
\$os = "ubuntu2204"
\$subnet = "10.0.20"
\$network_plugin = "calico"
\$kube_node_instances_with_disks_number = 0
EOF

##\$shared_folders = { 'temp/docker_rpms' => "/var/cache/yum/x86_64/7/docker-ce/packages" }

# make the rpm cache
mkdir -p kubespray/temp/docker_rpms

echo "###############"
echo "Execute 'vagrant up' to start the VM + install Kubernetes on the VM with Kubespray"
echo ""
echo "Execute the following command to make kubectl and other tools working in the current shell"
echo "export KUBECONFIG=\"$( pwd )/kubespray/inventory/sample/artifacts/admin.conf\""


echo "######################################################################################"
echo "## * syncing config in kubespray dir"
rsync -a ./inventory/ ./kubespray/inventory/
echo "## * changing into kubespray dir"
cd kubespray
echo "## * execute the following command to force new settings"
echo "ansible-playbook -i inventory/prod/inventory.ini cluster.yml"
echo "## * execute the following command to force new settings with forced cluster upgrade"
echo "ansible-playbook -i inventory/prod/inventory.ini -e upgrade_cluster_setup=true cluster.yml"
