#!/bin/bash
NREQUESTS=100

echo "Current Cluster: $(kubectl config current-context)"

for affinity in local remote none; do
  rm -f $affinity.txt
  echo "Making $NREQUESTS requests to service-affinity=$affinity service"
  for i in $(seq 1 $NREQUESTS); do
    kubectl -n demo exec -it ds/netshoot -- \
      curl -q "http://echoserver-service-$affinity.demo.svc.cluster.local?echo_env_body=NODE" |
        sed -r 's/"(service-affinity[0-9])-.*/kind-\1\n/g' - >> $affinity.txt
  done
  echo "  Number of responses from clusters"
  cat $affinity.txt | sort | uniq -c
done
