# apim-service-metrics-runtime

This umbrella chart installs the influxdb and grafana charts to provide a view for Gateway service metrics. 

## Install apim-service-metrics-runtime

### Create values override file (Optional)
* Create a file `override.yaml`
* Set the Grafana admin password in `override.yaml`. If this is not set then a random password will be generated.
* Override the Ingress definition in `override.yaml`.
```
grafana:
  
  adminPassword: <secure password>

  ingress:
    annotations:
      kubernetes.io/ingress.class: gce
      kubernetes.io/ingress.global-static-ip-name: "<your static IP name>"
    hosts:
      - <your grafana domain name>
    tls:
      - secretName: <your tls secret>
        hosts:
          - <your grafana domain name>
```

### Download dependencies
`helm dep build apim-service-metrics-runtime`

### Install
Use one of the following commands.

* With values override file:

  `helm install apim-service-metrics-runtime --name=apim-service-metrics-runtime --values override.yml`

OR

* Without values override file:

  `helm install apim-service-metrics-runtime --name=apim-service-metrics-runtime --set grafana.adminPassword="<secure password>" --set grafana.ingress.hosts[0]="<your grafana domain name>" --set grafana.ingress.tls[0].hosts[0]="<your grafana domain name>" --set grafana.ingress.tls[0].secretName="<your tls secret>" --set grafana.ingress.annotations."kubernetes\.io\/ingress\.global-static-ip-name"=<your static IP name>`

## influxdb

InfluxDB has a default hostname 'apim-service-metrics-runtime', which is used by the gateway (needs to be set under the influxDB field) and grafana to retrieve and send information to influxdb.

### Changes to the values file

The default database configuration helm chart provides does not allow configuration changes to retention duration. This is an alternative configuration to create a database with the necessary parameters. If changed, it needs to be changed on gateway and grafana as well to be consistent.
```
serviceMetrics:
  databaseName: serviceMetricsDb
  retentionPolicyDuration: 2w
  shardGroupDuration: 1d
```

This image is used to call curl commands to create database for service metrics.
```
curlImage:
  repository: appropriate/curl
  tag: latest
  pullPolicy: IfNotPresent
```

Persistence for influxdb is set to true to store data on the container.
```
persistence:
  enabled: true
```

## grafana

### Retrieving Admin Password

If the admin password is randomly set dynamically, you can run the following Kubernetes command to retrieve it:
```
kubectl get secret --namespace <namespace> apim-service-metrics-runtime-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```


### Changes to the values file

#### Ingress

The Ingress for Grafana is enabled and the Service type has been changed from ClusterIP to NodePort. This allows association of a domain name with Grafana.
```
service:
    type: NodePort
    port: 80
    annotations: {}
    labels: {}

  ingress:
    enabled: true
    path: /*
    annotations:
      kubernetes.io/ingress.class: gce
      kubernetes.io/ingress.global-static-ip-name: "apim-grafana-ip"
    hosts:
      - grafana.example.com
    tls:
      - secretName: apim-grafana-tls
        hosts:
          - grafana.example.com
```

#### Connect to influxdb with these configurations.

This retrieves information from influxdb to grafana.
```
datasources:
  datasources.yaml:
    apiVersion: 1
    datasources:
    - name: serviceMetrics
      type: influxdb
      database: serviceMetricsDb
      user:
      password:
      access: proxy
      url: http://apim-service-metrics-runtime-influxdb:8086
      isDefault: true
      tlsSkipVerify: true
      editable: true
```

It is mounted inside grafana container to /etc/grafana/provisioning/datasources/datasources.yaml.
The Database name and url field should match with InfluxDB url and database name.
```
      database: serviceMetricsDb
      url: http://apim-service-metrics-runtime-influxdb:8086
```

```
dashboardProviders:
  dashboardproviders.yaml:
    apiVersion: 1
    providers:
    - name: 'GatewayServiceMetrics'
      orgId: 1
      folder: ''
      type: file
      disableDeletion: false
      editable: true
      options:
        path: /var/lib/grafana/dashboards/default
```
It is mounted inside grafana container to /etc/grafana/provisioning/dashboards/dashboardproviders.yaml

This is the configuration of the dashboard graphs in json format.
```
dashboards:
  default:
    gateway-dashboard:
      json: |+
        {
          "__inputs": [
            {
              "name": "DS_SERVICEMETRICS",
              "label": "serviceMetrics",
              "description": "",
              "type": "datasource",
              "pluginId": "influxdb",
              "pluginName": "InfluxDB"
            }
          ],

          ...

          "timezone": "",
          "title": "Gateway Service Metrics",
          "uid": "-0QQRAWiz",
          "version": 3
        }
    gateway-stats:
      gnetId: 2
      revision: 2
      datasource: serviceMetrics
```
