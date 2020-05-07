#!/bin/bash
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
kubectl get nodes -n kube-admin
sleep 1
kubectl apply -f https://docs.projectcalico.org/v3.3/getting-started/kubernetes/installation/hosted/rbac-kdd.yaml
sleep 1
kubectl apply -f https://docs.projectcalico.org/v3.9/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calico-networking/1.7/calico.yaml
sleep 1
kubectl apply -f https://docs.projectcalico.org/v3.9/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calico-networking/1.7/calico.yaml
sleep 1
kubectl taint nodes --all node-role.kubernetes.io/master-
kubectl get nodes -n kube-admin
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-0.32.0/deploy/static/provider/baremetal/deploy.yaml
echo "deployment done"
sleep 2
#my_cmd="kubectl get pods -n ingress-nginx |grep ingress-nginx-controller |grep Running"
my_cmd="kubectl get pods -n ingress-nginx"
echo $my_cmd
ready_str="1/1"
echo $ready_str
until ( ${my_cmd} ) | grep ingress-nginx-controller |grep Running | grep -m 1 ${ready_str}; do : echo "waiting..." && sleep 1; done

