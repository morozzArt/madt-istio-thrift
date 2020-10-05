#!/usr/bin/env bash
kubectl config use-context kind-kind-1

kubectl create namespace istio-system
kubectl create secret generic cacerts -n istio-system \
    --from-file=samples/certs/ca-cert.pem \
    --from-file=samples/certs/ca-key.pem \
    --from-file=samples/certs/root-cert.pem \
    --from-file=samples/certs/cert-chain.pem
istioctl manifest apply \
    -f manifests/examples/multicluster/values-istio-multicluster-gateways.yaml

kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: kube-dns
  namespace: kube-system
data:
  stubDomains: |
    {"global": ["$(kubectl get svc -n istio-system istiocoredns -o jsonpath={.spec.clusterIP})"]}
EOF

kubectl label --context=kind-kind-1 namespace default istio-injection=enabled
kubectl apply --context=kind-kind-1 --validate=false -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: countrypage
  labels:
    app: countrypage
spec:
  ports:
  - port: 9080
    name: http
  selector:
    app: countrypage
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: countrypage-v1
  labels:
    app: countrypage
spec:
  replicas: 1
  selector:
    matchLabels:
      app: countrypage
      version: v1
  template:
    metadata:
      labels:
        app: countrypage
        version: v1
    spec:
      containers:
      - name: countrypage
        image: client/client
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 9080
---
apiVersion: v1
kind: Service
metadata:
  name: country
  labels:
    app: country
spec:
  ports:
  - port: 9080
    name: http
  selector:
    app: country
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: country-v1
  labels:
    app: country
spec:
  replicas: 1
  selector:
    matchLabels:
      app: country
      version: v1
  template:
    metadata:
      labels:
        app: country
        version: v1
    spec:
      containers:
      - name: country
        image: serv/country
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 9080

EOF

kubectl apply --context=kind-kind-1 -f /configs/gateway.yaml
