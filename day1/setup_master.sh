# install docker, easy way
curl -sfSL get.docker.com | bash

# change default cgroup manager to systemd
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
# create folder that will be used by docker + systemd
sudo mkdir -p /etc/systemd/system/docker.service.d

# restar docker service
systemctl daemon-reload
systemctl restart docker

# verify if systemd is in use
docker info | grep -i cgroup

# install kubernets dependencies
apt-get update && apt-get install -y apt-transport-https gnupg2 jq

# add key to apt-get
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list

# install kubelet, kubeadm, and kubect
apt-get update
apt-get install -y kubelet kubeadm kubectl

# pull all images before init
kubeadm config images pull

# init master node
kubeadm init

# move config to ./kube/config, used by kubectl to connect to kube-api
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# enable kernel modules required by weave pod network
modprobe br_netfilter ip_vs_rr ip_vs_wrr ip_vs_sh nf_conntrack_ipv4 ip_vs

# deploy weave pod network
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

# verify how many processors we have
cat /proc/cpuinfo 

# install bash completion and jq
apt-get install -y bash-completion jq

# enable bash completion
kubectl completion bash > /etc/bash_completion.d/kubectl
source <(kubectl completion bash)

