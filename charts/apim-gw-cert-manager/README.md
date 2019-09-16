# apim-gw-cert-manager

Installs [cert-manager](https://github.com/helm/charts/tree/master/stable/cert-manager), and creates ClusterIssuers and Certificates to generate TLS keys with [Let's Encrypt](https://letsencrypt.org).

## Reserve a static IP address
Create: `gcloud compute addresses create example-ingress-ip --global`
 
Describe (to find IP address): `gcloud compute addresses describe example-ingress-ip --global`

## Add DNS record for IP address
https://cloud.google.com/dns/records/

For an example domain of `example.apimgcp.com` and a static IP `35.227.218.215`:

| DNS name               | Type | TTL | Data             |
| ---------------------- | ---- | --- | ---------------- |
| *.example.apimgcp.com. | A    | 60  | `35.227.218.215` |

## Create service account for DNS administration and create key
https://cloud.google.com/iam/docs/creating-managing-service-accounts

## Install Chart
`helm install . --name=apim-gw-cert-manager --set acmeEmail=<your email address> --set-file clouddnsServiceAccountKeyFile=<key file path>`
