# Azure Subscription Setup with GitHub Actions

This guide explains how to connect an Azure subscription to GitHub
Actions using Microsoft Entra ID OpenID Connect (OIDC).

## Architecture

``` text
GitHub Repository
       |
       | GitHub Actions OIDC Token
       v
Microsoft Entra ID
       |
       | Federated Identity Credential
       v
Azure App Registration / Service Principal
       |
       | Azure RBAC
       v
Azure Subscription
       |
       v
Terraform / Azure Resources
```

## 1. Prerequisites

You need:

-   An Azure subscription
-   Permission to create an App Registration
-   Permission to assign Azure RBAC roles
-   A GitHub repository
-   GitHub Actions enabled

## 2. Create an Azure App Registration

Azure Portal:

**Microsoft Entra ID → App registrations → New registration**

Example name:

``` text
github-actions-azure-deployment
```

After registration, copy:

``` text
Application (client) ID
Directory (tenant) ID
```

## 3. Get the Azure Subscription ID

Azure Portal:

**Subscriptions → Select your subscription**

Copy:

``` text
Subscription ID
```

## 4. Assign Azure RBAC Permission

Go to:

**Subscriptions → Your Subscription → Access control (IAM) → Add role
assignment**

Select the required role.

For initial testing, `Contributor` can be used if appropriate. Use the
minimum permissions required for the deployment.

Select the App Registration/service principal as the member.

## 5. Create a Federated Credential

Open:

**Microsoft Entra ID → App registrations →
github-actions-azure-deployment**

Go to:

**Certificates & secrets → Federated credentials → Add credential**

Select:

``` text
Federated credential scenario:
GitHub Actions deploying Azure resources
```

Example values:
``` text
Federated credential scenario:
GitHub Actions deploying Azure resources
```

Orginization ID values:

``` Invoke-RestMethod "https://api.github.com/users/<username>" | Select-Object login,id ```

Repo ID values:

``` Invoke-RestMethod "https://api.github.com/repos/anoop4686/<Git Hub Repo>" | Select-Object full_name,id ```

Repository:
azure-resources-deployment

Entity type:
Branch

Branch:
main

Audience:
api://AzureADTokenExchange
```

Example credential name:

``` text
github-actions-azure-resources-main
```

Click **Add**.

The federated credential must match the GitHub repository identity
exactly.

## 6. Add GitHub Repository Secrets

Open:

**GitHub → Repository → Settings → Secrets and variables → Actions**

Click:

**New repository secret**

Create:

  Secret                    Value
  ------------------------- ----------------------------------
  `AZURE_CLIENT_ID`         Azure Application (client) ID
  `AZURE_TENANT_ID`         Azure Directory (tenant) ID
  `AZURE_SUBSCRIPTION_ID`   Azure Subscription ID
  `VM_ADMIN_PASSWORD`       Ubuntu VM administrator password

Do not put passwords or client secrets directly in Git.

## 7. Azure Login Test Workflow

Create:

``` text
.github/workflows/azure-login-test.yml
```

Use:

``` yaml
name: Azure Login Test

on:
  workflow_dispatch:

permissions:
  id-token: write
  contents: read

jobs:
  azure-login:
    runs-on: ubuntu-latest

    steps:
      - name: Azure Login
        uses: azure/login@v2
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}

      - name: Check Azure Subscription
        run: az account show
```
