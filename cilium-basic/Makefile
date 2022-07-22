deploy:
	kind create cluster --config cluster1.yaml
	kind create cluster --config cluster2.yaml
	kind create cluster --config cluster3.yaml
	cilium install --context kind-cluster1 --cluster-name cluster1 --cluster-id 1
	cilium status --context kind-cluster1 --wait
	cilium install --context kind-cluster2 --cluster-name cluster2 --cluster-id 2 --inherit-ca kind-cluster1
	cilium status --context kind-cluster2 --wait
	cilium install --context kind-cluster3 --cluster-name cluster3 --cluster-id 3 --inherit-ca kind-cluster1
	cilium status --context kind-cluster3 --wait
	cilium clustermesh enable --context kind-cluster1 --service-type NodePort
	cilium clustermesh enable --context kind-cluster2 --service-type NodePort
	cilium clustermesh enable --context kind-cluster3 --service-type NodePort
	cilium clustermesh connect --context kind-cluster1 --destination-context kind-cluster2
	cilium clustermesh connect --context kind-cluster2 --destination-context kind-cluster3
	cilium clustermesh connect --context kind-cluster3 --destination-context kind-cluster1
	cilium clustermesh status --context kind-cluster1 --wait
	cilium clustermesh status --context kind-cluster2 --wait
	cilium clustermesh status --context kind-cluster3 --wait

destroy:
	kind delete clusters cluster1 cluster2 cluster3
