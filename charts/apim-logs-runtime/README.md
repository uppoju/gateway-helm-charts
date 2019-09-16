# apim-logs-runtime

This umbrella chart installs Elastic Search and Kibana.

## Install apim-logs-runtime

### Download dependencies and install
`helm dep build`

`helm install . --name=apim-logs-runtime --values values.yaml`

## elasticsearch
Parameters that has been changed in values.yaml

| Parameter                        | New                               | Default                                                      |
| -----------------------------    | -----------------------------------       | -----------------------------------------------------------  |
| `serviceType`                   | 'LoadBalancer'                     | `ClusterIP`                                                          |

## kibana

### Changes to the values file

This change will point kibana to elasticsearch so it can retrieve log information.
```
files:
    kibana.yml:
      elasticsearch.url: http://apim-logs-runtime-elasticsearch-client:9200
```
Ingress
```$xslt
  service:
    type: NodePort
  ...
  ingress:
    enabled: true
    path: /*
    annotations:
      kubernetes.io/ingress.class: gce
      kubernetes.io/ingress.global-static-ip-name: "apim-kibana-ip"
    hosts:
      - kibana.example.com/*
    tls:
      - secretName: apim-kibana-tls
```
