{{/*
Expand the name of the chart.
*/}}
{{- define "3scale.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "3scale.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "3scale.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "3scale.labels" -}}
helm.sh/chart: {{ include "3scale.chart" . }}
{{ include "3scale.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "3scale.selectorLabels" -}}
app.kubernetes.io/name: {{ include "3scale.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "3scale.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "3scale.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Define policies dynamically based on values.yaml
*/}}
{{- define "3scale.policies" -}}
{{- range .Values.product.policies }}
  - name: {{ .name | quote }}
    version: {{ .version | quote }}
    enabled: {{ .enabled }}
    configuration:
      {{- if .configuration.response }}
      response:
        {{- range .configuration.response }}
        - header: {{ .header | quote }}
          op: {{ .op | quote }}
          value: {{ .value | quote }}
          value_type: {{ .value_type | quote }}
        {{- end }}
      {{- end }}

      {{- if .configuration.allow_headers }}
      allow_headers:
        {{- range .configuration.allow_headers }}
        - {{ . | quote }}
        {{- end }}
      {{- end }}

      {{- if .configuration.allow_methods }}
      allow_methods:
        {{- range .configuration.allow_methods }}
        - {{ . | quote }}
        {{- end }}
      {{- end }}

      {{- if .configuration.max_age }}
      max_age: {{ .configuration.max_age | quote }}
      {{- end }}

      {{- if .configuration.allow_credentials }}
      allow_credentials: {{ .configuration.allow_credentials | quote }}
      {{- end }}

      {{- if .configuration.allow_origin }}
      allow_origin: {{ .configuration.allow_origin | quote }}
      {{- end }}

      {{- range $k, $v := .configuration }}
      {{- if and (ne $k "response") (ne $k "allow_headers") (ne $k "allow_methods") (ne $k "max_age") (ne $k "allow_credentials") (ne $k "allow_origin") }}
      {{ $k }}: {{ $v | quote }}
      {{- end }}
      {{- end }}
{{- end }}
{{- end }}
