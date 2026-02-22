# Power Platform ALM with GitHub Actions

Automate the full Application Lifecycle Management (ALM) process for Microsoft Power Platform solutions using GitHub Actions.

## Overview

This repository provides three GitHub Actions workflows that implement a complete ALM pipeline for Power Platform solutions:

| Workflow | Trigger | Purpose |
|---|---|---|
| `export-and-branch-solution` | Manual (`workflow_dispatch`) | Export an unmanaged solution from the development environment, unpack it to source files, and open a pull request |
| `build-deploy-solution-to-test` | Push to `main` (under `solutions/`) | Pack the solution from source and import it into the test environment |
| `release-solution-to-prod` | GitHub Release published | Pack the solution as managed and import it into the production environment |

## Prerequisites

- Three Power Platform environments: **Development**, **Test**, and **Production**
- An Azure Active Directory **App Registration** with the following:
  - A client secret
  - The **Dynamics CRM** (`user_impersonation`) API permission
  - Added as an Application User in each Power Platform environment with the **System Administrator** security role

## Repository Secrets

Configure the following secrets in **Settings → Secrets and variables → Actions**:

| Secret | Description |
|---|---|
| `DEV_ENVIRONMENT_URL` | URL of the development environment (e.g. `https://org.crm.dynamics.com`) |
| `TEST_ENVIRONMENT_URL` | URL of the test environment |
| `PROD_ENVIRONMENT_URL` | URL of the production environment |
| `CLIENT_ID` | Application (client) ID of the Azure AD App Registration |
| `CLIENT_SECRET` | Client secret of the Azure AD App Registration |
| `TENANT_ID` | Directory (tenant) ID of the Azure AD App Registration |

## Workflows

### 1. Export and Branch Solution

**File:** `.github/workflows/export-and-branch-solution.yml`

Run this workflow manually from the **Actions** tab whenever you want to pull the latest changes from the development environment into source control.

**Inputs:**

| Input | Default | Description |
|---|---|---|
| `solution_name` | `MySolution` | Internal name of the solution to export |
| `solution_exported_folder` | `out/exported/` | Temporary folder for the exported zip file |
| `solution_folder` | `out/solutions/` | Temporary staging folder for unpacked files |
| `solution_target_folder` | `solutions/` | Source-controlled folder where unpacked files are committed |

The workflow will:
1. Export the unmanaged solution from the development environment
2. Unpack the solution zip into individual source files
3. Create a new branch and open a pull request against `main`

### 2. Build and Deploy to Test

**File:** `.github/workflows/build-deploy-solution-to-test.yml`

Triggered automatically when changes under the `solutions/` folder are merged into `main`.

Before using this workflow, update the `env` block at the top of the file to match your solution name:

```yaml
env:
  solution_name: MySolution   # <-- change to your solution's internal name
```

The workflow will:
1. Pack the unpacked solution source files into an unmanaged solution zip
2. Import the solution into the test environment with `force-overwrite` and `publish-changes`
3. Upload the unmanaged solution zip as a workflow artifact

### 3. Release Solution to Production

**File:** `.github/workflows/release-solution-to-prod.yml`

Triggered automatically when a GitHub Release is **published**.

Before using this workflow, update the `env` block at the top of the file to match your solution name:

```yaml
env:
  solution_name: MySolution   # <-- change to your solution's internal name
```

The workflow will:
1. Pack the solution source files into a **managed** solution zip
2. Import the managed solution into the production environment
3. Attach the managed solution zip as an asset on the GitHub Release

## Getting Started

1. Clone or fork this repository.
2. Add your solution source files under `solutions/<YourSolutionName>/` (or use the **Export and Branch Solution** workflow to populate them automatically).
3. Configure the six repository secrets listed above.
4. Update `solution_name` in the `build-deploy-solution-to-test.yml` and `release-solution-to-prod.yml` files to match your solution's internal name.
5. Merge a change to `main` to trigger a test deployment, or publish a release to trigger a production deployment.

## References

- [Microsoft Power Platform Build Tools for Azure DevOps](https://learn.microsoft.com/en-us/power-platform/alm/devops-build-tools)
- [GitHub Actions for Microsoft Power Platform](https://learn.microsoft.com/en-us/power-platform/alm/devops-github-actions)
- [microsoft/powerplatform-actions](https://github.com/microsoft/powerplatform-actions)