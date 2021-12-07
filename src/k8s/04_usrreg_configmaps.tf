resource "kubernetes_config_map" "uservice-user-registry-management" {
  metadata {
    name      = "uservice-user-registry-management"
    namespace = kubernetes_namespace.usrreg.metadata[0].name
  }

  data = merge({
    APPLICATIONINSIGHTS_ROLE_NAME = "uservice-user-registry-management"
    POSTGRES_SCHEMA               = "user_registry"
    },
    var.configmaps_uservice-user-registry-management
  )
}
