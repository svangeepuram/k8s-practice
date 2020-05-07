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
