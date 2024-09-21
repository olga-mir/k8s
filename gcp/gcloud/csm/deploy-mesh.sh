#!/bin/bash

: "${MESH_NAME:?Variable MESH_NAME is not set}"
: "${PROJECT_ID:?Variable PROJECT_ID is not set}"
: "${PROJECT_NUMBER:?Variable PROJECT_NUMBER is not set}"

envsubst < manifests/templates/csm_mesh.yaml > manifests/rendered/csm_mesh.yaml

gcloud network-services meshes import $MESH_NAME \
  --source=manifests/rendered/csm_mesh.yaml \
  --location=global
