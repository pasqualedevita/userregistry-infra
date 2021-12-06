resource "kubernetes_secret" "selc-application-insights" {
  metadata {
    name      = "application-insights"
    namespace = kubernetes_namespace.usrreg.metadata[0].name
  }

  data = {
    APPLICATIONINSIGHTS_CONNECTION_STRING = local.appinsights_instrumentation_key
  }

  type = "Opaque"
}

resource "kubernetes_secret" "postgres" {
  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.usrreg.metadata[0].name
  }

  data = {
    #principal database name
    POSTGRES_DB = "usrreg"
    #principal database hostname or ip
    POSTGRES_HOST = local.postgres_hostname
    #principal database hostname or ip
    POSTGRES_PORT = "5432"
  }

  type = "Opaque"
}

resource "kubernetes_secret" "uservice-user-registry-management" {
  metadata {
    name      = "uservice-user-registry-management"
    namespace = kubernetes_namespace.usrreg.metadata[0].name
  }

  data = {
    POSTGRES_USR = format("%s@%s", "USRREG_REGISTRY_USER", local.postgres_hostname)
    POSTGRES_PSW = module.key_vault_secrets_query.values["postgres-user-registry-user-password"].value
  }

  type = "Opaque"
}