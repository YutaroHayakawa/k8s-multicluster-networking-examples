NAME := service-affinity
AGENT := yutarohayakawa/cilium:clustermesh-service-affinity
APISERVER := yutarohayakawa/clustermesh-apiserver
APISERVER_VERSION := clustermesh-service-affinity

deploy:
	kind create cluster --config cluster1.yaml
	kind create cluster --config cluster2.yaml
	cilium install --context kind-${NAME}1 --cluster-name ${NAME}1 --cluster-id 1 --agent-image ${AGENT}
	cilium status --context kind-${NAME}1 --wait
	cilium install --context kind-${NAME}2 --cluster-name ${NAME}2 --cluster-id 2 --inherit-ca kind-${NAME}1 --agent-image ${AGENT}
	cilium status --context kind-${NAME}2 --wait
	cilium clustermesh enable --context kind-${NAME}1 --service-type NodePort --apiserver-image ${APISERVER} --apiserver-version ${APISERVER_VERSION}
	cilium clustermesh enable --context kind-${NAME}2 --service-type NodePort --apiserver-image ${APISERVER} --apiserver-version ${APISERVER_VERSION}
	cilium clustermesh connect --context kind-${NAME}1 --destination-context kind-${NAME}2
	kubectl --context kind-${NAME}1 create ns demo
	kubectl --context kind-${NAME}2 create ns demo
	kubectl --context kind-${NAME}1 -n demo apply -f netshoot-ds.yaml
	kubectl --context kind-${NAME}2 -n demo apply -f netshoot-ds.yaml
	kubectl --context kind-${NAME}1 -n demo apply -f echoserver-service.yaml
	kubectl --context kind-${NAME}2 -n demo apply -f echoserver-service.yaml
	cilium clustermesh status --context kind-${NAME}1 --wait
	cilium clustermesh status --context kind-${NAME}2 --wait

destroy:
	kind delete clusters ${NAME}1 ${NAME}2

demo:
	./demo.sh
