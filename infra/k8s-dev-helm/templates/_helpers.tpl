{{- define "k8s-dev-helm.deployment-name" -}}
{{ required "image.name is required" .Values.image.name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{ define "k8s-dev-helm.chart" -}}
{{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{ define "k8s-dev-helm.labels" -}}
helm.sh/chart: {{ include "k8s-dev-helm.chart" . }}
{{ include "k8s-dev-helm.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{ define "k8s-dev-helm.selectorLabels" -}}
app.kubernetes.io/name: {{ include "k8s-dev-helm.deployment-name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{ define "k8s-dev-helm.namespace" -}}
{{ default .Release.Namespace .Values.namespace }}
{{- end }}

{{ define "k8s-dev-helm.componentLabels" -}}
{{ include "k8s-dev-helm.labels" .root }}
app.kubernetes.io/component: {{ .component }}
{{- end }}

{{ define "k8s-dev-helm.renderEnvMap" -}}
{{- range $name, $value := . }}
- name: {{ $name }}
  value: {{ $value | quote }}
{{- end }}
{{- end }}

{{ define "k8s-dev-helm.consulAnnotations" -}}
{{- if .Values.consul.inject }}
consul.hashicorp.com/connect-inject: {{ .Values.consul.inject | quote }}
consul.hashicorp.com/connect-service: {{ required "image.name is required" .Values.image.name | quote }}
consul.hashicorp.com/connect-service-port: {{ printf "%v" .Values.containerPort | quote }}
consul.hashicorp.com/transparent-proxy: {{ ternary "true" "false" .Values.consul.transparentProxy | quote }}
{{- end }}
{{- end }}

{{ define "k8s-dev-helm.containerPort" -}}
{{ .Values.containerPort | quote}}
{{- end }}

{{ define "k8s-dev-helm.image" -}}
{{ printf "%s/%s:%s" .Values.image.namespace (required "image.name is required" .Values.image.name) .Values.image.tag | quote }}
{{- end }}
