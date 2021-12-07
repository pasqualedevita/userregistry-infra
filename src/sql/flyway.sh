#!/usr/bin/env bash

#
# Apply the configuration relative to a given ENV
# Usage:
#  ./flyway.sh info|validate|migrate ENV usrreg
#
#  ./flyway.sh migrate ENV usrreg
#  ./flyway.sh migrate ENV usrreg
#  ./flyway.sh migrate ENV  usrreg

BASHDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
WORKDIR="$BASHDIR"

set -e

COMMAND=$1
ENV=$2
DATABASE=$3
shift 3
other=$@

#
# Pre checks
#
if [ -z "${COMMAND}" ]; then
    printf "\e[1;31mYou must provide a COMMAND for flyway as first argument.\n"
    exit 1
fi

if [ -z "${ENV}" ]; then
    printf "\e[1;31mYou must provide a ENV as second argument.\n"
    exit 1
fi

if [ -z "${DATABASE}" ]; then
    printf "\e[1;31mYou must provide a DATABASE for flyway as third argument.\n"
    exit 1
fi

if [[ $WORKDIR == /cygdrive/* ]]; then
  WORKDIR=$(cygpath -w "${WORKDIR}")
  WORKDIR=${WORKDIR//\\//}
fi

#
# 🏁 Setup
#

# must be subscription in lower case
subscription=""
# shellcheck source=/dev/null
source "../.env/$ENV/backend.ini"

az account set -s "${subscription}"

echo "COMMAND: ${COMMAND}"
echo "ENV: ${ENV}"
echo "DATABASE: ${DATABASE}"

#
# Azure
#
kv_key_postgres_administrator_login="postgres-administrator-login"
kv_key_postgres_administrator_login_password="postgres-administrator-login-password"
kv_key_postgres_user_registry_user_password="postgres-user-registry-user-password"
kv_key_postgres_monitoring_user_password="postgres-monitoring-user-password"
kv_key_postgres_monitoring_external_user_password="postgres-monitoring-external-user-password"

psql_server_name=$(az postgres server list -o tsv --query "[?contains(name,'postgres')].{Name:name}" | head -1)
echo "[INFO] psql_server_name: ${psql_server_name}"
psql_server_private_fqdn=$(az postgres server list -o tsv --query "[?contains(name,'postgres')].{Name:fullyQualifiedDomainName}" | head -1)
echo "[INFO] psql_server_private_fqdn: ${psql_server_private_fqdn}"
keyvault_name=$(az keyvault list -o tsv --query "[?contains(name,'kv')].{Name:name}")
echo "[INFO] keyvault_name: ${keyvault_name}"

# in widows, even if using cygwin, these variables will contain a landing \r character
psql_server_name=${psql_server_name//[$'\r']}
psql_server_private_fqdn=${psql_server_private_fqdn//[$'\r']}
keyvault_name=${keyvault_name//[$'\r']}

administrator_login=$(az keyvault secret show --name ${kv_key_postgres_administrator_login} --vault-name "${keyvault_name}" -o tsv --query value)
echo "[INFO] administrator_login: ${administrator_login}"
administrator_login_password=$(az keyvault secret show --name ${kv_key_postgres_administrator_login_password} --vault-name "${keyvault_name}" -o tsv --query value)
echo "[INFO] administrator_login_password result code: $?"

# in widows, even if using cygwin, these variables will contain a landing \r character
administrator_login=${administrator_login//[$'\r']}
administrator_login_password=${administrator_login_password//[$'\r']}

user_registry_user_password=$(az keyvault secret show --name ${kv_key_postgres_user_registry_user_password} --vault-name "${keyvault_name}" -o tsv --query value)
echo "[INFO] user_registry_user_password result code: $?"
monitoring_user_password=$(az keyvault secret show --name ${kv_key_postgres_monitoring_user_password} --vault-name "${keyvault_name}" -o tsv --query value)
echo "[INFO] monitoring_user_password result code: $?"
monitoring_external_user_password=$(az keyvault secret show --name ${kv_key_postgres_monitoring_external_user_password} --vault-name "${keyvault_name}" -o tsv --query value)
echo "[INFO] monitoring_external_user_password result code: $?"

# in widows, even if using cygwin, these variables will contain a landing \r character
user_registry_user_password=${user_registry_user_password//[$'\r']}
monitoring_user_password=${monitoring_user_password//[$'\r']}
monitoring_external_user_password=${monitoring_external_user_password//[$'\r']}

#
# Flyway
#
export FLYWAY_URL="jdbc:postgresql://${psql_server_private_fqdn}:5432/${DATABASE}?sslmode=require"
export FLYWAY_USER="${administrator_login}@${psql_server_name}"
export FLYWAY_PASSWORD="${administrator_login_password}"
export SERVER_NAME="${psql_server_name}"
export FLYWAY_DOCKER_TAG="7.11.1-alpine"

export USER_REGISTRY_USER_PASSWORD="${user_registry_user_password}"
export MONITORING_USER_PASSWORD="${monitoring_user_password}"
export MONITORING_EXTERNAL_USER_PASSWORD="${monitoring_external_user_password}"

docker run --rm --network=host -v "${WORKDIR}/migrations/${DATABASE}":/flyway/sql \
  flyway/flyway:"${FLYWAY_DOCKER_TAG}" \
  -url="${FLYWAY_URL}" -user="${FLYWAY_USER}" -password="${FLYWAY_PASSWORD}" \
  -validateMigrationNaming=true \
  -placeholders.flywayUser="${administrator_login}" \
  -placeholders.userRegistryUserPassword="${USER_REGISTRY_USER_PASSWORD}" \
  -placeholders.monitoringUserPassword="${MONITORING_USER_PASSWORD}" \
  -placeholders.monitoringExternalUserPassword="${MONITORING_EXTERNAL_USER_PASSWORD}" \
  -placeholders.serverName="${SERVER_NAME}" "${COMMAND}" ${other}
