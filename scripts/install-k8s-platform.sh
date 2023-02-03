# https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack#kube-prometheus-stack

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# https://github.com/prometheus-community/helm-charts/blob/main/charts/kube-prometheus-stack/values.yaml
helm install prom prometheus-community/kube-prometheus-stack


helm repo add cilium https://helm.cilium.io
helm repo update
helm install tetragon cilium/tetragon -n kube-system
kubectl rollout status -n kube-system ds/tetragon -w
