
gcloud container clusters create $CLUSTER_NAME \
    --enable-dataplane-v2 \
    --system-config-from-file=system-config.yaml
