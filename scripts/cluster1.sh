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
  name: countrypage-cluster-ip
  labels:
    app: countrypage
spec:
  ports:
  - port: 9080
   targetPort: 9080
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
  template:
    metadata:
      labels:
        app: countrypage
    spec:
      containers:
      - name: countrypage
        image: client/client:v1
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 9080
        env:
          - name: SERVICE_COUNTRY_HOST
            value: country-cluster-ip
---
apiVersion: v1
kind: Service
metadata:
  name: country-cluster-ip
  labels:
    app: country
spec:
  ports:
  - port: 9080
   targetPort: 9080
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
  template:
    metadata:
      labels:
        app: country
    spec:
      containers:
      - name: country
        image: serv/country:v1
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 9080

EOF

kubectl apply --context=kind-kind-1 -f /configs/gateway.yaml
