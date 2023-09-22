#!/bin/bash

# deploy stuff: https://cloud.google.com/service-mesh/docs/unified-install/install-anthos-service-mesh-command#local-computer

GATEWAY_NS=gateway

kubectl create namespace $GATEWAY_NS

kubectl apply -f samples/gateways/istio-ingressgateway -n $GATEWAY_NS
kubectl apply -f samples/online-boutique/kubernetes-manifests/namespaces

for ns in ad cart checkout currency email frontend loadgenerator payment product-catalog recommendation shipping; do
  kubectl label namespace $ns istio-injection=enabled istio.io/rev-
done;

kubectl apply -f samples/online-boutique/kubernetes-manifests/deployments
kubectl apply -f samples/online-boutique/istio-manifests/allow-egress-googleapis.yaml
kubectl apply -f samples/online-boutique/istio-manifests/frontend-gateway.yaml

kubectl get service -n $GATEWAY_NS
kubectl get pod -n $GATEWAY_NS
