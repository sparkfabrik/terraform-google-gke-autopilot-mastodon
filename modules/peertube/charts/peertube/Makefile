KINDEST_NODE_VERSION=1.27.3

init-cluster: create-kind-cluster install-nginx-ingress-controller

create-kind-cluster:
	kind create cluster --config kind-config.yaml --name peertube --wait 30s --image kindest/node:v${KINDEST_NODE_VERSION} || true

install-nginx-ingress-controller:
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
	kubectl wait --namespace ingress-nginx \
  	--for=condition=ready pod \
  	--selector=app.kubernetes.io/component=controller \
  	--timeout=90s

install-chart:
	helm dependency update .
	helm upgrade --install peertube . --set postgres.enabled=true --set postgres.image.tag=12.16.0-debian-11-r5