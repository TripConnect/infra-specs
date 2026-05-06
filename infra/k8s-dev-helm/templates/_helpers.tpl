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

{{ define "k8s-dev-helm.consulAnnotations" }}
{{- if .Values.consul.inject -}}
consul.hashicorp.com/connect-inject: {{ .Values.consul.inject | quote }}
consul.hashicorp.com/connect-service: {{ required "image.name is required" .Values.image.name | quote }}
consul.hashicorp.com/connect-service-port: {{ printf "%v" .Values.containerPort | quote }}
consul.hashicorp.com/transparent-proxy: {{ ternary "true" "false" .Values.consul.transparentProxy | quote }}
{{- end }}
{{- end }}

{{ define "k8s-dev-helm.containerPort" -}}
{{ required ".containerPort is required" .Values.containerPort }}
{{- end }}

{{ define "k8s-dev-helm.image" -}}
{{ printf "%s/%s:%s" .Values.image.namespace (required "image.name is required" .Values.image.name) .Values.image.tag | quote }}
{{- end }}

{{ define "k8s-dev-helm.otelResourceAttributes" -}}
{{- $attrs := list (printf "deployment.environment=%s" .Values.env) (printf "service.namespace=%s" (include "k8s-dev-helm.namespace" .)) (printf "k8s.namespace.name=%s" (include "k8s-dev-helm.namespace" .)) -}}
{{- range $name, $value := .Values.observability.instrumentation.resourceAttributes }}
{{- $attrs = append $attrs (printf "%s=%v" $name $value) -}}
{{- end -}}
{{ join "," $attrs }}
{{- end }}

{{ define "k8s-dev-helm.otelEnv" -}}
{{- if and .Values.observability.enabled .Values.observability.instrumentation.enabled }}
- name: OTEL_SERVICE_NAME
  value: {{ include "k8s-dev-helm.deployment-name" . | quote }}
- name: OTEL_RESOURCE_ATTRIBUTES
  value: {{ include "k8s-dev-helm.otelResourceAttributes" . | quote }}
- name: OTEL_EXPORTER_OTLP_ENDPOINT
  value: {{ .Values.observability.instrumentation.endpoint | quote }}
- name: OTEL_EXPORTER_OTLP_PROTOCOL
  value: {{ .Values.observability.instrumentation.protocol | quote }}
- name: OTEL_TRACES_EXPORTER
  value: {{ .Values.observability.instrumentation.tracesExporter | quote }}
- name: OTEL_METRICS_EXPORTER
  value: {{ .Values.observability.instrumentation.metricsExporter | quote }}
- name: OTEL_LOGS_EXPORTER
  value: {{ .Values.observability.instrumentation.logsExporter | quote }}
- name: OTEL_PROPAGATORS
  value: {{ .Values.observability.instrumentation.propagators | quote }}
- name: OTEL_TRACES_SAMPLER
  value: {{ .Values.observability.instrumentation.tracesSampler | quote }}
{{- end }}
{{- end }}
