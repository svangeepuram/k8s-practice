#!/bin/bash

apt-get update
sleep 2
apt-get install     apt-transport-https     ca-certificates     curl     gnupg-agent     software-properties-common -y
sleep 1
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
sleep 2
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" >> /etc/apt/sources.list.d/kubernetes.list
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sleep 1
apt-get update
sleep 2
apt-get install docker-ce docker-ce-cli containerd.io -y
docker --version
sleep 1
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl
echo "source <(kubectl completion bash)" >> ~/.bashrc
source ~/.bashrc
sleep 1
kubeadm config images pull
kubeadm init --pod-network-cidr=192.168.0.0/16 --apiserver-cert-extra-sans vangeepuram.org,www.vangeepuram.org,k8s.vangeepuram.org

#############
celanup:

kubeadm reset
rm -rf /etc/cni
rm -rf /opt/cni
sudo rm -rf ~/.kube
sudo rm -rf /home/chary/.kube
sudo apt-get purge kubeadm kubectl kubelet kubernetes-cni kube* 
sudo apt-get autoremove


ufw allow 2379/tcp
ufw allow 2380/tcp
ufw allow 6443/tcp
ufw allow 10250/tcp
ufw allow 10251/tcp
ufw allow 22
ufw allow 80
ufw allow 443
ufw allow 8080

worker:
ufw allow 10250/tcp
ufw allow 30000:32767/tcp

lsmod | grep br_netfilter.
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system

apt-get update
apt-get install     apt-transport-https     ca-certificates     curl     gnupg-agent     software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install docker-ce docker-ce-cli containerd.io -y
#https://kubernetes.io/docs/setup/production-environment/container-runtimes/#docker

cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "log-level":        "error"
}
EOF

#mkdir -p /etc/systemd/system/docker.service.d

# Restart docker.
systemctl daemon-reload
systemctl restart docker

echo "source <(kubectl completion bash)" >> ~/.bashrc
source ~/.bashrc
kubectl version

sudo kubeadm config images pull
sudo swapoff -a
sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --apiserver-cert-extra-sans krishi.net,www.krishi.net,k8s.krishi.net,localhost
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl get nodes -n kube-admin
kubectl apply -f https://docs.projectcalico.org/v3.3/getting-started/kubernetes/installation/hosted/rbac-kdd.yaml
#kubectl apply -f https://docs.projectcalico.org/v3.9/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calico-networking/1.7/calico.yaml
kubectl get nodes -n kube-admin
kubectl get nodes -w
openssl x509  -noout -text -in /etc/kubernetes/pki/apiserver.crt
kubectl get nodes
sudo kubectl taint nodes --all node-role.kubernetes.io/master-

sudo kubectl get pods -A
#sudo ufw default allow incoming

export KUBECONFIG=$HOME/.kube/config
kubectl get pods -A
sudo kubectl taint nodes --all node-role.kubernetes.io/master-
echo $KUBERNETES_MASTER

sudo swapoff -a
kubeadm init --pod-network-cidr=192.168.0.0/16 --apiserver-advertise-address=192.168.0.22  --apiserver-cert-extra-sans krishi.net,www.krishi.net,k8s.krishi.net,localhost
sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --apiserver-cert-extra-sans krishi.net,www.krishi.net,k8s.krishi.net,localhost
mkdir -p $HOME/.kube
kubectl get nodes -n kube-admin

export KUBERNETES_MASTER=http://192.168.0.22:6443
kubectl get nodes -n kube-admin

openssl x509  -noout -text -in /etc/kubernetes/pki/apiserver.crt
kubectl config view
curl https://192.168.0.22:6443
kubectl -n kube-system get cm kubeadm-config -oyaml
openssl version
sudo vi /etc/hosts
ping krishi
ping krishi.tk
vi generate-certs.sh
sudo bash generate-certs.sh 
cd /home/chary
ls
rm ca-key.pem ca.pem ca.srl cert.pem key.* openssl.cnf 
y
vi generate-certs.sh
sudo bash generate-certs.sh 
cd /certs


kubectl describe pod ingress-nginx-admission-create-hcj7c -n ingress-nginx

vi calico.yaml 
kubectl apply -f ./calico.yaml 
kubectl get pods --all-namespaces
kubectl logs calico-node-dmjbg -n kube-system -c calico-node
kubectl -n kube-system set env daemonset/calico-node FELIX_IGNORELOOSERPF=true

sysctl -a 2>/dev/null | grep "\.rp_filter"

kubectl get ds --all-namespaces
kubectl get ds calico-node -n kube-system
kubectl describe ds calico-node -n kube-system
kubectl get sa --all-namespaces
kubectl get pods --all-namespaces
