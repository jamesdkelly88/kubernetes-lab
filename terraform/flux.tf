# resource "flux_bootstrap_git" "this" {
#   count              = local.cluster.fluxcd == true ? 1 : 0
#   embedded_manifests = true
#   path               = "clusters/${var.cluster}/flux"

#   depends_on = [time_sleep.wait_for_cluster]
# }

# resource "helm_release" "fluxcd" {
#   count            = local.cluster.fluxcd == true ? 1 : 0
#   depends_on       = [time_sleep.wait_for_cluster]
#   repository       = "https://fluxcd-community.github.io/helm-charts"
#   chart            = "flux2"
#   name             = "flux2"
#   namespace        = "flux-system"
#   create_namespace = true
# }

# resource "time_sleep" "wait_for_fluxcd" {
#   count      = local.cluster.fluxcd == true ? 1 : 0
#   depends_on = [helm_release.fluxcd]

#   create_duration = "2m"
# }

# data "kubectl_file_documents" "flux-setup" {
#     count      = local.cluster.fluxcd == true ? 1 : 0
#     content = file("../clusters/${var.cluster}/flux.yaml")
# }

# resource "kubectl_manifest" "flux-setup" {
#     count      = local.cluster.fluxcd == true ? 1 : 0
#     depends_on = [time_sleep.wait_for_fluxcd]
#     for_each  = data.kubectl_path_documents.flux-setup[0].manifests
#     yaml_body = each.value
# }