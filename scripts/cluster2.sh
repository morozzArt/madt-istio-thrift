#!/usr/bin/env bash
kubectl config use-context kind-kind-2

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

kubectl label --context=kine-kind-2 namespace default istio-injection=enabled

kubectl apply --context=kind-kind-2 -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: currency
  labels:
    app: currency
spec:
  ports:
  - port: 9080
    name: http
  selector:
    app: currency
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: currency
  labels:
    app: currency
spec:
  replicas: 1
  selector:
    matchLabels:
      app: currency
  template:
    metadata:
      labels:
        app: currency
    spec:
      containers:
      - name: currency
        image: serv/currency
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 9080

EOF
