{{/*
Expand the name of the chart.
*/}}
{{- define "KubeVote.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "KubeVote.name" -}}
{{- default .Chart.Name .Values.nameOverride | lower | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{- define "KubeVote.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | lower | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride | lower -}}
{{- if contains $name (.Release.Name | lower) -}}
{{- .Release.Name | lower | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" (.Release.Name | lower) $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "KubeVote.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/*
Common labels for all resources (Service, Deployment, ConfigMap, etc.)
NOTE: Do NOT include component here. Component is workload-specific and should live
in pod labels + selectors only.
*/}}
{{- define "KubeVote.labels" -}}
helm.sh/chart: {{ include "KubeVote.chart" . }}
app.kubernetes.io/name: {{ include "KubeVote.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels (used for Deployment.spec.selector.matchLabels and Service.spec.selector)
Requires a component to be provided in the context: .component
*/}}
{{- define "KubeVote.selectorLabels" -}}
app.kubernetes.io/name: {{ include "KubeVote.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: {{ .component }}
{{- end }}

{{/*
Pod labels: common labels + component (workload-specific)
Pass component via dict:
  {{ include "KubeVote.podLabels" (dict "component" "vote" "Release" .Release "Chart" .Chart "Values" .Values) }}
*/}}
{{- define "KubeVote.podLabels" -}}
{{ include "KubeVote.labels" . }}
app.kubernetes.io/component: {{ .component }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "KubeVote.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "KubeVote.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end }}