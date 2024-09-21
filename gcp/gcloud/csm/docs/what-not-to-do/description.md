
1. Create GKE with CSM enabled
2. launch Cloud Run into this mesh.

This didn't work. I could see mesh installed in GKE, but it wasn't the "Traffic Director" mesh at the cloud level:

```bash
gcloud container fleet mesh describe --project $PROJECT_ID | yq .
```

Output:

```yaml
% gcloud container fleet mesh describe --project $PROJECT_ID | yq .
createTime: '2024-09-20T23:23:26.004395714Z'
membershipSpecs:
  projects/$PROJECT_NUMBER/locations/$REGION/memberships/$CLUSTER_NAME:
    mesh:
      management: MANAGEMENT_AUTOMATIC
membershipStates:
  projects/$PROJECT_NUMBER/locations/$REGION/memberships/$CLUSTER_NAME:
    servicemesh:
      conditions:
        - code: VPCSC_GA_SUPPORTED
          details: This control plane supports VPC-SC GA.
          documentationLink: http://cloud.google.com/service-mesh/docs/managed/vpc-sc
          severity: INFO
      controlPlaneManagement:
        details:
          - code: REVISION_READY
            details: 'Ready: asm-managed-stable'
        implementation: ISTIOD
        state: ACTIVE
      dataPlaneManagement:
        details:
          - code: OK
            details: Service is running.
        state: ACTIVE
    state:
      code: OK
      description: 'Revision ready for use: asm-managed-stable.'
      updateTime: '2024-09-20T23:29:40.583694518Z'
name: projects/$PROJECT_ID/locations/global/features/servicemesh
resourceState:
  state: ACTIVE
spec: {}
updateTime: '2024-09-20T23:26:57.768315267Z'
```

And I didn't have meshes at this point:

```terminal
% gcloud network-services meshes list --location=global
Listed 0 items.
```

## Move from ASM to CSM

I didn't complete the process, but after disabling the management, nothing else seems to have changed:

```
createTime: '2024-09-20T23:23:26.004395714Z'
membershipSpecs:
  projects/$PROJECT_NUMBER/locations/$REGION/memberships/$CLUSTER_NAME:
    mesh:
      management: MANAGEMENT_MANUAL
membershipStates:
  projects/$PROJECT_NUMBER/locations/$REGION/memberships/$CLUSTER_NAME:
    servicemesh:
      conditions:
        - code: VPCSC_GA_SUPPORTED
          details: This control plane supports VPC-SC GA.
          documentationLink: http://cloud.google.com/service-mesh/docs/managed/vpc-sc
          severity: INFO
      controlPlaneManagement:
        details:
          - code: REVISION_READY
            details: 'Ready: asm-managed-stable'
        implementation: ISTIOD
        state: ACTIVE
      dataPlaneManagement:
        details:
          - code: OK
            details: Service is running.
        state: ACTIVE
    state:
      code: OK
      description: 'Revision ready for use: asm-managed-stable.'
      updateTime: '2024-09-21T01:39:38.954489101Z'
name: projects/$PROJECT_ID/locations/global/features/servicemesh
resourceState:
  state: ACTIVE
spec: {}
updateTime: '2024-09-21T01:00:02.278719441Z'
```

## Cluster Dump

### networking api-resources

```
 % k api-resources | grep networking
gatewayclasses                      gc                  gateway.networking.k8s.io/v1        false        GatewayClass
gateways                            gtw                 gateway.networking.k8s.io/v1        true         Gateway
httproutes                                              gateway.networking.k8s.io/v1        true         HTTPRoute
referencegrants                     refgrant            gateway.networking.k8s.io/v1beta1   true         ReferenceGrant
frontendconfigs                                         networking.gke.io/v1beta1           true         FrontendConfig
gcpbackendpolicies                                      networking.gke.io/v1                true         GCPBackendPolicy
gcpgatewaypolicies                                      networking.gke.io/v1                true         GCPGatewayPolicy
gkenetworkparamsets                                     networking.gke.io/v1                false        GKENetworkParamSet
healthcheckpolicies                                     networking.gke.io/v1                true         HealthCheckPolicy
lbpolicies                                              networking.gke.io/v1                true         LBPolicy
managedcertificates                 mcrt                networking.gke.io/v1                true         ManagedCertificate
networkloggings                     nl                  networking.gke.io/v1alpha1          false        NetworkLogging
networks                                                networking.gke.io/v1                false        Network
redirectservices                    rds                 networking.gke.io/v1alpha1          true         RedirectService
remotenodes                         rn                  networking.gke.io/v1alpha1          false        RemoteNode
serviceattachments                                      networking.gke.io/v1                true         ServiceAttachment
servicefunctionchains                                   networking.gke.io/v1                false        ServiceFunctionChain
servicenetworkendpointgroups        svcneg              networking.gke.io/v1beta1           true         ServiceNetworkEndpointGroup
trafficselectors                                        networking.gke.io/v1                false        TrafficSelector
destinationrules                    dr                  networking.istio.io/v1beta1         true         DestinationRule
envoyfilters                                            networking.istio.io/v1alpha3        true         EnvoyFilter
gateways                            gw                  networking.istio.io/v1beta1         true         Gateway
proxyconfigs                                            networking.istio.io/v1beta1         true         ProxyConfig
serviceentries                      se                  networking.istio.io/v1beta1         true         ServiceEntry
sidecars                                                networking.istio.io/v1beta1         true         Sidecar
virtualservices                     vs                  networking.istio.io/v1beta1         true         VirtualService
workloadentries                     we                  networking.istio.io/v1beta1         true         WorkloadEntry
workloadgroups                      wg                  networking.istio.io/v1beta1         true         WorkloadGroup
ingressclasses                                          networking.k8s.io/v1                false        IngressClass
ingresses                           ing                 networking.k8s.io/v1                true         Ingress
networkpolicies                     netpol              networking.k8s.io/v1                true         NetworkPolicy
```

### Pods

```
% k get po -A
NAMESPACE         NAME                                                     READY   STATUS    RESTARTS   AGE
gke-managed-cim   kube-state-metrics-0                                     2/2     Running   0          3h4m
gmp-system        collector-5jcxb                                          2/2     Running   0          3h3m
gmp-system        gmp-operator-54fccd6f64-srn7k                            1/1     Running   0          3h5m
kube-system       anetd-brlm6                                              2/2     Running   0          3h3m
kube-system       antrea-controller-horizontal-autoscaler-5fc5bddc-bqs57   1/1     Running   0          3h5m
kube-system       event-exporter-gke-78fb679b7b-br6lp                      2/2     Running   0          3h6m
kube-system       fluentbit-gke-75vc5                                      3/3     Running   0          3h3m
kube-system       gke-metadata-server-tkwrx                                1/1     Running   0          3h3m
kube-system       gke-metrics-agent-ndwwk                                  3/3     Running   0          3h3m
kube-system       istio-cni-node-24bct                                     1/1     Running   0          131m
kube-system       konnectivity-agent-5cb57f7878-5d2cm                      2/2     Running   0          3h3m
kube-system       konnectivity-agent-autoscaler-897d4f648-8xjl4            1/1     Running   0          3h5m
kube-system       kube-dns-5fbf8db568-ng58j                                5/5     Running   0          3h6m
kube-system       kube-dns-autoscaler-6f896b6968-r59nc                     1/1     Running   0          3h5m
kube-system       l7-default-backend-6697bb6dfd-smg4r                      1/1     Running   0          3h6m
kube-system       mdp-controller-66dbdb74c8-82r2z                          1/1     Running   0          138m
kube-system       metrics-server-v1.30.3-d474c4cfd-lzh88                   1/1     Running   0          3h2m
kube-system       netd-brpqs                                               3/3     Running   0          3h3m
kube-system       pdcsi-node-sqm5c                                         2/2     Running   0          3h3m
%
% k logs -n kube-system
2024-09-20T23:27:32.519321Z     info    ControlZ available at 127.0.0.1:9876
2024-09-20T23:27:32.519735Z     info    mdp     Creating MDP metrics exporter
2024-09-20T23:27:32.623197Z     info    mdp     using max reconcile time of 12h0m0s
2024-09-20T23:27:32.623951Z     info    mdp     Starting the server.
2024-09-20T23:27:32.624638Z     info    mdp     Starting EventSource    source=kind source: *v1alpha1.DataPlaneControl
2024-09-20T23:27:32.624809Z     info    mdp     Starting EventSource    source=kind source: *v1.Pod
2024-09-20T23:27:32.624877Z     info    mdp     Starting EventSource    source=kind source: *v1.Namespace
2024-09-20T23:27:32.624969Z     info    mdp     Starting EventSource    source=kind source: *v1alpha1.ControlPlaneRevision
2024-09-20T23:27:32.624989Z     info    mdp     Starting Controller
2024-09-20T23:27:32.813239Z     info    mdp     Starting workers        worker count=1
2024-09-20T23:27:32.813404Z     info    no pods in revision asm-managed-rapid, nothing to upgrade
2024-09-20T23:27:32.813502Z     info    no pods in revision asm-managed-stable, nothing to upgrade
2024-09-20T23:27:32.813560Z     info    no pods in revision asm-managed, nothing to upgrade
```
