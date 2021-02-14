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

# join a cluster
kubeadm join $MASTER_HOST --token $JOIN_TOKEN     --discovery-token-ca-cert-hash sha256: $SHA_256
