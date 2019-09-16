{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "gateway.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "gateway.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "gateway.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create java args to apply.
*/}}
{{- define "gateway.java.args" -}}
{{- default .Values.gateway.javaArgs  "-Dcom.l7tech.bootstrap.autoTrustSslKey=trustAnchor,TrustedFor.SSL,TrustedFor.SAML_ISSUER -Dcom.l7tech.server.config.mode=RUNTIME -Dcom.l7tech.server.audit.message.saveToInternal=false -Dcom.l7tech.server.audit.admin.saveToInternal=false -Dcom.l7tech.server.audit.system.saveToInternal=false -Dcom.l7tech.server.audit.log.format=json -Djava.util.logging.config.file=/opt/SecureSpan/Gateway/node/default/etc/conf/log-override.properties -Dcom.l7tech.server.pkix.useDefaultTrustAnchors=true -Dcom.l7tech.security.ssl.hostAllowWildcard=true" -}}
{{- end -}}

