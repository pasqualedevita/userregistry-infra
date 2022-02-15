[![Static Analysis](https://github.com/pagopa/userregistry-infra/actions/workflows/static_analysis.yml/badge.svg?branch=main)](https://github.com/pagopa/userregistry-infra/actions/workflows/static_analysis.yml)

# userregistry-infra

UserRegistry infra project

## Flow of installation

1. Run terraform on ´pillar´ folder, to generate all the resources that are pillar for other resources
2. Run on ´core´ folder this command, to generate the secrets mandatory for pipelines
   ´´´bash
   sh terraform.sh apply [dev|uat|prod] -target azurerm_key_vault_secret.aks_apiserver_url
   ´´´
3. Generate all the pipelines usign project <https://github.com/pagopa/userregistry-devops>

   1. Launch the pipelines to allow the generation of the certificate, mandatory for apim and app gateway

4. Check that the new certificates are created inside the keyvault

5. Run terraform on ´core´ folder to complete all the resources

6. (Only via VPN for UAT and PROD) Run terraform on ´k8s´ folder to setup kubernetes cluster

## Requirements

### 1. terraform

In order to manage the suitable version of terraform it is strongly recommended to install the following tool:

- [tfenv](https://github.com/tfutils/tfenv): **Terraform** version manager inspired by rbenv.

Once these tools have been installed, install the terraform version shown in:

- .terraform-version

After installation install terraform:

```sh
tfenv install
```

## Terraform modules

As PagoPA we build our standard Terraform modules, check available modules:

- [PagoPA Terraform modules](https://github.com/search?q=topic%3Aterraform-modules+org%3Apagopa&type=repositories)

## Apply changes

To apply changes follow the standard terraform lifecycle once the code in this repository has been changed:

```sh
terraform.sh init [dev|uat|prod]

terraform.sh plan [dev|uat|prod]

terraform.sh apply [dev|uat|prod]
```

## Terraform lock.hcl

We have both developers who work with your Terraform configuration on their Linux, macOS or Windows workstations and automated systems that apply the configuration while running on Linux.
<https://www.terraform.io/docs/cli/commands/providers/lock.html#specifying-target-platforms>

So we need to specify this in terraform lock providers:

```sh
terraform init

rm .terraform.lock.hcl

terraform providers lock \
  -platform=windows_amd64 \
  -platform=darwin_amd64 \
  -platform=darwin_arm64 \
  -platform=linux_amd64
```

## Precommit checks

Check your code before commit.

<https://github.com/antonbabenko/pre-commit-terraform#how-to-install>

```sh
pre-commit run -a
```

Install the pre-commit hook globally

```sh
DIR=~/.git-template
git config --global init.templateDir ${DIR}
pre-commit init-templatedir -t pre-commit ${DIR}
```
