deploy:
	kind create cluster --config cluster1.yaml
	kind create cluster --config cluster2.yaml
	subctl deploy-broker --kubecontext kind-cluster1
	mv broker-info.subm broker-info.subm.bak
	cat broker-info.subm.bak | base64 -d | sed -r "s/127.0.0.1:[0-9]+/$$(docker inspect cluster1-control-plane -f '{{.NetworkSettings.Networks.kind.IPAddress}}'):6443/" | base64 > broker-info.subm
	subctl join --kubecontext kind-cluster1 broker-info.subm --clusterid=cluster1 --natt=false
	subctl join --kubecontext kind-cluster2 broker-info.subm --clusterid=cluster2 --natt=false
	kubectl --context kind-cluster1 create ns demo
	kubectl --context kind-cluster2 create ns demo
	kubectl --context kind-cluster1 -n demo apply -f netshoot-ds.yaml
	kubectl --context kind-cluster2 -n demo apply -f netshoot-ds.yaml

destroy:
	kind delete clusters cluster1 cluster2
	rm -f broker-info.subm broker-info.subm.bak

demo:
	./connectivity-test.sh mesh
