apiVersion: v1
kind: Secret
metadata:
  name: ${ name }
  namespace: ${ namespace }
data:
%{ for d in data ~}
  ${ d.key }: ${ base64encode(d.value) }
%{ endfor ~}