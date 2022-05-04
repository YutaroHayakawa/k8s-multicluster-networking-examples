#!/bin/bash
CLUSTER1=kind-cluster1
CLUSTER2=kind-cluster2
CLUSTER1_PODS=$(kubectl --context $CLUSTER1 -n demo get pods -o jsonpath='{range .items[*]}{@.metadata.name}{"\n"}')
CLUSTER2_PODS=$(kubectl --context $CLUSTER2 -n demo get pods -o jsonpath='{range .items[*]}{@.metadata.name}{"\n"}')
CLUSTER1_IPS=$(kubectl --context $CLUSTER1 -n demo get pods -o jsonpath='{range .items[*]}{@.status.podIP}{"\n"}')
CLUSTER2_IPS=$(kubectl --context $CLUSTER2 -n demo get pods -o jsonpath='{range .items[*]}{@.status.podIP}{"\n"}')

function mesh() {
  for pod in $CLUSTER1_PODS; do
    for ip in $CLUSTER2_IPS; do
      echo "==== cluster1:$pod -> $ip (cluster2) ===="
      kubectl --context $CLUSTER1 -n demo exec -it $pod -- ping -R -c 1 $ip
      echo ""
    done
  done
  
  for pod in $CLUSTER2_PODS; do
    for ip in $CLUSTER1_IPS; do
      echo "==== cluster2:$pod -> $ip (cluster2) ===="
      kubectl --context $CLUSTER2 -n demo exec -it $pod -- ping -R -c 1 $ip
      echo ""
    done
  done
}

function c1-c2() {
  for pod in $CLUSTER1_PODS; do
    for ip in $CLUSTER2_IPS; do
      echo "==== cluster1:$pod -> $ip (cluster2) ===="
      kubectl --context $CLUSTER1 -n demo exec -it $pod -- ping -R $ip
      echo ""
      return
    done
  done
}

function c2-c1() {
  for pod in $CLUSTER2_PODS; do
    for ip in $CLUSTER1_IPS; do
      echo "==== cluster2:$pod -> $ip (cluster2) ===="
      kubectl --context $CLUSTER2 -n demo exec -it $pod -- ping -R $ip
      echo ""
      return
    done
  done
}

if [ -z $1 ]; then
  echo "Usage: $0 [mesh|c1-c2|c2-c]"
  echo "  mesh  : Verifies full mesh connectivity between nodes in cluster1 and cluster2"
  echo "  c1-c2 : Verifies connectivity from one node in cluster1 to one node in cluster2"
  echo "  c2-c1 : Verifies connectivity from one node in cluster2 to one node in cluster1"
fi

$1
