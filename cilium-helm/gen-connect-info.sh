#!/bin/bash

CLUSTER1_ADDR=$(docker inspect cluster1-control-plane | jq -r '.[0].NetworkSettings.Networks.kind.IPAddress')
CLUSTER2_ADDR=$(docker inspect cluster2-control-plane | jq -r '.[0].NetworkSettings.Networks.kind.IPAddress')
CA_CRT=$(kubectl --context kind-cluster1 -n kube-system get secrets clustermesh-apiserver-remote-cert -o jsonpath='{.data.ca\.crt}')
CLUSTER1_CRT=$(kubectl --context kind-cluster1 -n kube-system get secrets clustermesh-apiserver-remote-cert -o jsonpath='{.data.tls\.crt}')
CLUSTER1_CRT=$(kubectl --context kind-cluster1 -n kube-system get secrets clustermesh-apiserver-remote-cert -o jsonpath='{.data.tls\.crt}')
CLUSTER1_KEY=$(kubectl --context kind-cluster1 -n kube-system get secrets clustermesh-apiserver-remote-cert -o jsonpath='{.data.tls\.key}')
CLUSTER2_CRT=$(kubectl --context kind-cluster2 -n kube-system get secrets clustermesh-apiserver-remote-cert -o jsonpath='{.data.tls\.crt}')
CLUSTER2_KEY=$(kubectl --context kind-cluster2 -n kube-system get secrets clustermesh-apiserver-remote-cert -o jsonpath='{.data.tls\.key}')

cat << EOF > values3.yaml
clustermesh:
  apiserver:
    tls:
      ca:
        cert: ${CA_CRT}
  config:
    enabled: true
    clusters:
    - name: cluster1
      address: cluster1.mesh.cilium.io
      port: 32379
      tls:
        cert: ${CLUSTER1_CRT}
        key: ${CLUSTER1_KEY}
    - name: cluster2
      address: cluster2.mesh.cilium.io
      port: 32379
      tls:
        cert: ${CLUSTER2_CRT}
        key: ${CLUSTER2_KEY}
EOF

cat << EOF > host-aliases.patch.yaml
spec:
  template:
    spec:
      hostAliases:
      - ip: ${CLUSTER1_ADDR}
        hostnames:
        - cluster1.mesh.cilium.io
      - ip: ${CLUSTER2_ADDR}
        hostnames:
        - cluster2.mesh.cilium.io
EOF
