## 1. Terraform Deployment Workflow

For Terraform stored under `ubuntu-vm/`, create:

``` text
.github/workflows/terraform-deploy.yml
```

Example:

``` yaml
name: Terraform Azure VM Deployment

on:
  workflow_dispatch:

permissions:
  id-token: write
  contents: read

jobs:
  terraform:
    name: Deploy Ubuntu VM
    runs-on: ubuntu-latest

    defaults:
      run:
        working-directory: ./ubuntu-vm

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Azure Login
        uses: azure/login@v2
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3

      - name: Terraform Init
        run: terraform init

      - name: Terraform Format Check
        run: terraform fmt -check

      - name: Terraform Validate
        run: terraform validate

      - name: Terraform Plan
        run: terraform plan
        env:
          TF_VAR_subscription_id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
          TF_VAR_admin_password: ${{ secrets.VM_ADMIN_PASSWORD }}

      - name: Terraform Apply
        run: terraform apply -auto-approve
        env:
          TF_VAR_subscription_id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
          TF_VAR_admin_password: ${{ secrets.VM_ADMIN_PASSWORD }}
```

## 2. Repository Structure

``` text
azure-resources-deployment/
│
├── .github/
│   └── workflows/
│       ├── azure-login-test.yml
│       └── terraform-deploy.yml
│
├── ubuntu-vm/
│   ├── README.md
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
│
├── .gitignore
└── README.md
```

GitHub Actions workflows must be under:

``` text
.github/workflows/
```

Terraform can remain under:

``` text
ubuntu-vm/
```

## 3. Test Azure Authentication

Go to:

**GitHub → Actions → Azure Login Test → Run workflow**

Select:

``` text
Branch: main
```

Click **Run workflow**.

A successful run should show the Azure Login and Azure subscription
check steps as successful.

## 4. Run Terraform

After Azure Login succeeds:

**GitHub → Actions → Terraform Azure VM Deployment → Run workflow**

Select:

``` text
Branch: main
```

The workflow runs:

``` text
Checkout
   ↓
Azure Login
   ↓
Terraform Init
   ↓
Terraform Format Check
   ↓
Terraform Validate
   ↓
Terraform Plan
   ↓
Terraform Apply
```

## 5. Security

### Do not commit passwords

Do not hard-code:

``` hcl
admin_password = "password"
```

Use the GitHub Secret:

``` text
VM_ADMIN_PASSWORD
```

### Do not commit Terraform state

Use this `.gitignore`:

``` gitignore
.terraform/
*.tfstate
*.tfstate.*
crash.log
crash.*.log
*.tfvars
*.tfvars.json
```

### Prefer OIDC

For GitHub Actions, use:

``` text
OIDC + Federated Credential
```

instead of storing an Azure client secret.

## 6. Troubleshooting

### Azure Login fails

Check:

``` text
AZURE_CLIENT_ID
AZURE_TENANT_ID
AZURE_SUBSCRIPTION_ID
```

Also verify that the federated credential exactly matches the GitHub
organization, repository, and branch.

### Terraform Format Check fails

Run:

``` powershell
cd ubuntu-vm
terraform fmt
terraform fmt -check
```

Then:

``` powershell
git add .
git commit -m "Format Terraform configuration"
git push origin main
```

### Terraform Validate fails

Run:

``` powershell
terraform validate
```

from the Terraform directory and fix the reported configuration error.

### Terraform Apply fails

Check the **Terraform Apply** section of the GitHub Actions run.

Common causes include:

-   Incorrect Azure region
-   Invalid VM image
-   Insufficient Azure quota
-   Invalid resource configuration
-   Missing Azure RBAC permission
-   Resource name conflict

## Official References

Microsoft Learn - Authenticate to Azure from GitHub Actions using OIDC:

https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure-openid-connect

GitHub Actions - Using secrets:

https://docs.github.com/en/actions/how-tos/write-workflows/choose-what-workflows-do/use-secrets

Microsoft Entra - Federated identity credentials:

https://learn.microsoft.com/en-us/entra/workload-id/workload-identity-federation-create-trust
