prefix = "usrreg"

# ingress
nginx_helm_version               = "4.0.12"
ingress_replica_count            = "2"
ingress_load_balancer_public_ip  = ""
ingress_load_balancer_private_ip = "10.1.0.250"

# RBAC
rbac_namespaces_for_deployer_binding = ["usrreg"]
# Gateway
api_gateway_url = "https://api.userregistry.pagopa.it"

# configs/secrets
configmaps_uservice-user-registry-management = {
  JAVA_OPTS                                         = "-javaagent:/applicationinsights-agent.jar"
  APPLICATIONINSIGHTS_INSTRUMENTATION_LOGGING_LEVEL = "OFF"
}
