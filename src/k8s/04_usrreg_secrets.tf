resource "kubernetes_secret" "usrreg-application-insights" {
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
    POSTGRES_USR = local.postgres_user_registry_connection_username
    POSTGRES_PSW = local.postgres_user_registry_connection_username_password
  }

  type = "Opaque"
}
