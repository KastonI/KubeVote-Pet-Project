{{/*
========================================================
 Chart / Release helpers
========================================================
*/}}

{{/*
Chart name
*/}}
{{- define "karpenter.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Full name (Release + Chart)
*/}}
{{- define "karpenter.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name (include "karpenter.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Standard Kubernetes labels
*/}}
{{- define "karpenter.labels" -}}
app.kubernetes.io/name: {{ include "karpenter.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

---

{{/*
========================================================
 Karpenter naming
========================================================
*/}}

{{/*
EC2NodeClass name
*/}}
{{- define "karpenter.nodeClassName" -}}
{{- .Values.nodeClass.name | default (include "karpenter.fullname" .) -}}
{{- end -}}

{{/*
NodePool name
*/}}
{{- define "karpenter.nodePoolName" -}}
{{- .Values.nodePool.name | default (include "karpenter.fullname" .) -}}
{{- end -}}

---

{{/*
========================================================
 Generic render helpers
========================================================
*/}}

{{/*
Render key/value map (labels, tags, annotations)
*/}}
{{- define "karpenter.renderMap" -}}
{{- range $key, $value := . }}
{{ $key }}: {{ $value | quote }}
{{- end -}}
{{- end -}}

---

{{/*
========================================================
 AWS / Karpenter specific helpers
========================================================
*/}}

{{/*
AWS tags
*/}}
{{- define "karpenter.awsTags" -}}
{{- include "karpenter.renderMap" . -}}
{{- end -}}

{{/*
Node labels
*/}}
{{- define "karpenter.nodeLabels" -}}
{{- include "karpenter.renderMap" . -}}
{{- end -}}

{{/*
NodeClass reference
*/}}
{{- define "karpenter.nodeClassRef" -}}
group: {{ .group }}
kind: {{ .kind }}
name: {{ .name }}
{{- end -}}

{{/*
Karpenter requirements
*/}}
{{- define "karpenter.requirements" -}}
{{- range . }}
- key: {{ .key }}
  operator: {{ .operator }}
{{- if .values }}
  values:
{{- range .values }}
    - {{ . | quote }}
{{- end }}
{{- end }}
{{- end }}
{{- end -}}
