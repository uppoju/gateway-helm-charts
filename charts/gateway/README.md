# gateway

This chart deploys the API Gateway.

## Install gateway

The API Gateway requires a license for its installation. 
`helm dep build`

`helm install gateway --name "<release name>" --set-file "gateway.license.value=<license file>" --set-file "gateway.license.accept=<true>"  --set imageCredentials.password=<nexus password>`


To delete gateway installation: (Use the release name that you previously specified to install the gateway along with the --name parameter)

`helm del --purge <release name>`


## Configuration

The following table lists the configurable parameters of the Nexus chart and their default values.

| Parameter                        | Description                               | Default                                                      |
| -----------------------------    | -----------------------------------       | -----------------------------------------------------------  |
| `replicaCount`                   | Number of Gateway service replicas        | `1`                                                          |
| `deploymentStrategy`             | Deployment Strategy                       | `rollingUpdate`                                              |
| `nexus.imageName`                | Nexus Docker Private Repository Gateway   | `docker.k8s.apimsvc.ca.com/repository/docker-hosted/gateway` |
| `nexus.tag`                      | Version of Gateway                        | `latest`                                                     |
| `nexus.imagePullPolicy`          | Nexus image pull policy                   | `Always`                                                     |
| `imageCredentials.name`          | Image Secret credentials to fetch image from private repo | `docker.k8s.apimsvc.ca.com`  |
| `imageCredentials.registry`          | Image Secret repo name to fetch image from private repo | `docker.k8s.apimsvc.ca.com`  |
| `imageCredentials.username`          | Image Secret username credential | `nil`  |
| `imageCredentials.password`          | Image Secret password credential | `nil`  |
| `gateway.heapSize`          | Gateway application heap size | 3g  |
| `gateway.license.value`          | Gateway license file | `nil`  |
| `gateway.license.accept`          | Accept Gateway license EULA | `false`  |
| `gateway.javaArgs`          | Additional gateway application java args | `nil`  |
| `service.ports`    | List of http external port mappings               | http: 80 -> 8080, https: 443->8443 |
| `hazelcast.enable`    | Provision Hazelcast               | true |
| `influxdb.host`    | influxdb host               | 'influx-influxdb.<namespace>' |

### Logs & Audit Configuration

The API Gateway containers are configured to output logs and audits as JSON events, and to never write audits to the in-memory Derby database:

- System properties in the default template for the `gateway.javaArgs` value configure the log and audit behaviour:
  - Auditing to the database is disabled: `-Dcom.l7tech.server.audit.message.saveToInternal=false -Dcom.l7tech.server.audit.admin.saveToInternal=false -Dcom.l7tech.server.audit.system.saveToInternal=false`
  - JSON formatting is enabled: `-Dcom.l7tech.server.audit.log.format=json`
  - Default log output configuration is overridden by specifying an alternative configuration properties file: `-Djava.util.logging.config.file=/opt/SecureSpan/Gateway/node/default/etc/conf/log-override.properties`
- The alternative log configuration properties file `log-override.properties` is mounted on the container, via the `gateway-config` ConfigMap.
- System property to include well known Certificate Authorities Trust Anchors 
    - API Gateway does not implicitly trust certificates without importing it but If you want to avoid import step then configure Gateway to accept any certificate signed by well known CA's (Certificate Authorities)
      configure following property to true -
      Set '-Dcom.l7tech.server.pkix.useDefaultTrustAnchors=true' for well known Certificate Authorities be included as Trust Anchors (true/false)
- Allow wildcards when verifying hostnames (true/false)
    - Set '-Dcom.l7tech.security.ssl.hostAllowWildcard=true' to allow wildcards when verifying hostnames (true/false)