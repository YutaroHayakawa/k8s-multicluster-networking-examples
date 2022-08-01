CHART?=cilium/cilium
CILIUM_REPO?=quay.io/cilium/cilium
CLUSTERMESH_APISERVER_REPO?=quay.io/cilium/clustermesh-apiserver
CILIUM_TAG?=v1.12.0
CERT_MANAGER_VERSION=v1.8.2

deploy:
	# Generate CA certificate
	cfssl gencert -initca csr.json | cfssljson -bare
	# Cluster1 Phase1
	kind create cluster --config cluster1.yaml
	helm -n kube-system install cilium ${CHART} \
		--set image.repository=${CILIUM_REPO} \
		--set image.tag=${CILIUM_TAG} \
		--set image.useDigest=false \
		--set image.pullPolicy=Always \
		--set k8sServiceHost=`docker inspect cluster1-control-plane | jq -r '.[0].NetworkSettings.Networks.kind.IPAddress'` \
		--set tls.ca.cert="`cat cert.pem | base64`" \
		--set tls.ca.key="`cat cert-key.pem | base64`" \
		-f values.yaml
	kubectl -n kube-system rollout status ds cilium --timeout=300s
	kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/${CERT_MANAGER_VERSION}/cert-manager.yaml
	kubectl -n cert-manager rollout status deploy cert-manager-webhook --timeout=300s
	kubectl -n cert-manager create secret tls cilium-ca-key-pair --cert=cert.pem --key=cert-key.pem
	kubectl apply -f ca-issuer.yaml
	# Cluster2 Phase1
	kind create cluster --config cluster2.yaml
	helm -n kube-system install cilium ${CHART} \
		--set image.repository=${CILIUM_REPO} \
		--set image.tag=${CILIUM_TAG} \
		--set image.useDigest=false \
		--set image.pullPolicy=Always \
		--set k8sServiceHost=`docker inspect cluster2-control-plane | jq -r '.[0].NetworkSettings.Networks.kind.IPAddress'` \
		--set tls.ca.cert="`cat cert.pem | base64`" \
		--set tls.ca.key="`cat cert-key.pem | base64`" \
		-f values.yaml
	kubectl -n kube-system rollout status ds cilium --timeout=300s
	kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/${CERT_MANAGER_VERSION}/cert-manager.yaml
	kubectl -n cert-manager rollout status deploy cert-manager-webhook --timeout=300s
	kubectl -n cert-manager create secret tls cilium-ca-key-pair --cert=cert.pem --key=cert-key.pem
	kubectl apply -f ca-issuer.yaml
	# Cluster1 Phase2
	kubectl ctx kind-cluster1
	helm -n kube-system upgrade cilium ${CHART} \
		--reuse-values \
		--set clustermesh.apiserver.image.repository=${CLUSTERMESH_APISERVER_REPO} \
		--set clustermesh.apiserver.image.tag=${CILIUM_TAG} \
		--set clustermesh.apiserver.image.useDigest=false \
		--set clustermesh.apiserver.image.pullPolicy=Always \
		--set cluster.name=cluster1 \
		--set cluster.id=1 \
		-f values2.yaml
	kubectl -n kube-system rollout status deploy clustermesh-apiserver --timeout=300s
	# Cluster2 Phase2
	kubectl ctx kind-cluster2
	helm -n kube-system upgrade cilium ${CHART} \
		--reuse-values \
		--set clustermesh.apiserver.image.repository=${CLUSTERMESH_APISERVER_REPO} \
		--set clustermesh.apiserver.image.tag=${CILIUM_TAG} \
		--set clustermesh.apiserver.image.useDigest=false \
		--set clustermesh.apiserver.image.pullPolicy=Always \
		--set cluster.name=cluster2 \
		--set cluster.id=2 \
		-f values2.yaml
	kubectl -n kube-system rollout status deploy clustermesh-apiserver --timeout=300s
	# Connect clusters
	./gen-connect-info.sh
	kubectl ctx kind-cluster1
	helm -n kube-system upgrade cilium ${CHART} \
		--reuse-values \
		-f values3.yaml
	kubectl -n kube-system patch ds cilium --patch-file host-aliases.patch.yaml
	kubectl ctx kind-cluster2
	helm -n kube-system upgrade cilium ${CHART} \
		--reuse-values \
		-f values3.yaml
	kubectl -n kube-system patch ds cilium --patch-file host-aliases.patch.yaml
	# Deploy services
	kubectl ctx kind-cluster1
	kubectl apply -f echoserver-service.yaml
	kubectl ctx kind-cluster2
	kubectl apply -f echoserver-service.yaml
	

destroy:
	kind delete clusters cluster1 cluster2
