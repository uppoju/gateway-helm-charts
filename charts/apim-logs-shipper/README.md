# apim-logs-shipper

This umbrella chart installs a log shipper to forward and centralize logs to elasticsearch 

## Install apim-logs-shipper

### Download dependencies and install
`helm dep build`

`helm install . --name=apim-logs-shipper`

### Changes to the values file
Add following parameters in values.yaml file to deploy filebeat on Google Cloud. 
```
config  
  filebeat.autodiscover:
    providers:
      - type: kubernetes
        hints.enabled: true

  filebeat.modules:
    - module: elasticsearch
      # Server log
      server:
        enabled: true
        
  output.file:
    # Make sure to add this property and set it to false otherwise logs will be sent to local file system instead of elasticsearch  
    enabled: false


  #Point this to elasticsearch endpoint.
  output.elasticsearch:
    hosts: "http://35.235.71.99:9200"        

#To use the sample Kibana dashboards provided with Filebeat, configure the Kibana endpoint.
setup.kibana:
  host: "http://35.236.57.19:5601"   
``` 