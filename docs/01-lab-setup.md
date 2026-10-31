# 01 – Lab Setup

## Requirements
| Item | Detail |
|---|---|
| Identity provider | Microsoft Entra ID **Free** tenant (or an Okta free developer/integrator org) |
| Workstation | Windows 10/11 or Linux/macOS with PowerShell 7 |
| Modules | `Microsoft.Graph` PowerShell SDK |
| Data | CSV files in `/data` (fictional) |
| Cost | $0 |

## Step 1 – Create a tenant
1. Sign in at <https://entra.microsoft.com> with a personal Microsoft account and create a new (free) tenant for the lab, or use an existing lab tenant.
2. Note the tenant domain: `yourtenant.onmicrosoft.com`.
3. Use a dedicated lab tenant – **never run these scripts in a production tenant**.

## Step 2 – Create security groups
Create the following **Security** groups (membership type: *Assigned*):

`GRP-All-Employees`, `GRP-IT-Staff`, `GRP-VPN-Users`, `GRP-HR-Staff`, `GRP-HRMS-Access`, `GRP-Finance-Staff`, `GRP-ERP-Finance`, `GRP-Sales-Staff`, `GRP-CRM-Users`

> Entra ID Free supports assigned groups. Dynamic-membership groups need Entra ID P1/P2.

## Step 3 – Install tooling
```powershell
Install-Module Microsoft.Graph -Scope CurrentUser
Connect-MgGraph -Scopes "User.ReadWrite.All","Group.ReadWrite.All","Directory.ReadWrite.All"
```
Sign in as the tenant's Global Administrator (lab only) and consent to the permissions.

## Step 4 – Enable MFA baseline
Enable **Security Defaults** (Entra admin center → Properties → Manage security defaults) so new users must register for MFA.

## Step 5 – Dry-run
```powershell
.\scripts\jml_graph.ps1 -Mode Joiner -Domain "yourtenant.onmicrosoft.com" -DryRun
```
Verify the output, then run without `-DryRun`.

## Security notes
- Do not commit tenant IDs, secrets, or real employee data.
- Temporary passwords are generated at runtime and shown once – they are not stored.
