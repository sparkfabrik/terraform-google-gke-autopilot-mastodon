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

helm-dep-update:
	helm dependency update .

install:
	helm upgrade --wait --install peertube . -f tests/values.yaml
	k apply -f tests/k8s || true

uninstall:
	helm uninstall peertube || true
	kubectl delete pvc data-peertube-postgresql-0 || true
	k delete -f tests/k8s || true

minio-forward:
	kubectl port-forward svc/peertube-minio-console 9001:9001

peertube-forward:
	kubectl port-forward svc/peertube 9000:80

peertube-cli:
	kubectl exec -it deploy/peertube -- bash

peertube-change-root:
	kubectl exec -it deploy/peertube -- bash -c "NODE_ENV=production npm run reset-password -- -u root"