<#
.SYNOPSIS
  Joiner / Mover / Leaver automation for Microsoft Entra ID using Microsoft Graph PowerShell.

.EXAMPLE
  Install-Module Microsoft.Graph -Scope CurrentUser
  .\jml_graph.ps1 -Mode Joiner -Domain "yourtenant.onmicrosoft.com" -DryRun
  .\jml_graph.ps1 -Mode Joiner -Domain "yourtenant.onmicrosoft.com"
  .\jml_graph.ps1 -Mode Mover  -Domain "yourtenant.onmicrosoft.com"
  .\jml_graph.ps1 -Mode Leaver -Domain "yourtenant.onmicrosoft.com"

.NOTES
  Run ONLY in a lab tenant. Use -DryRun first. Groups listed in data/role_group_map.csv
  must already exist (create them as Security groups with assigned membership).
#>
param(
  [Parameter(Mandatory)][ValidateSet("Joiner","Mover","Leaver")][string]$Mode,
  [Parameter(Mandatory)][string]$Domain,
  [switch]$DryRun
)

$root = Split-Path -Parent $PSScriptRoot
$map  = @{}
Import-Csv "$root\data\role_group_map.csv" | ForEach-Object { $map[$_.department] = $_.groups -split ";" }

function Get-TargetGroups($dept) { @($map["ALL"]) + @($map[$dept]) | Where-Object { $_ } }
function Get-Upn($u) { "$($u.first_name).$($u.last_name)@$Domain".ToLower() }
function New-TempPassword { -join ((48..57)+(65..90)+(97..122)+(33,35,36,37) | Get-Random -Count 16 | ForEach-Object {[char]$_}) }
function Get-GroupId($name) { (Get-MgGroup -Filter "displayName eq '$name'").Id }

if (-not $DryRun) {
  Connect-MgGraph -Scopes "User.ReadWrite.All","Group.ReadWrite.All","Directory.ReadWrite.All"
}

switch ($Mode) {

  "Joiner" {
    foreach ($u in Import-Csv "$root\data\joiners.csv") {
      $upn = Get-Upn $u
      Write-Host "[JOINER] $upn  ($($u.department) / $($u.job_title))"
      if ($DryRun) { Get-TargetGroups $u.department | ForEach-Object { Write-Host "   + would add to $_" }; continue }

      $pwd  = New-TempPassword
      $user = New-MgUser -DisplayName "$($u.first_name) $($u.last_name)" `
                -GivenName $u.first_name -Surname $u.last_name `
                -UserPrincipalName $upn -MailNickname "$($u.first_name).$($u.last_name)".ToLower() `
                -Department $u.department -JobTitle $u.job_title -EmployeeId $u.employee_id `
                -AccountEnabled:$true -UsageLocation "IN" `
                -PasswordProfile @{ Password = $pwd; ForceChangePasswordNextSignIn = $true }
      foreach ($g in Get-TargetGroups $u.department) {
        New-MgGroupMember -GroupId (Get-GroupId $g) -DirectoryObjectId $user.Id
        Write-Host "   + added to $g"
      }
      Write-Host "   temp password (share securely, shown once): $pwd"
    }
  }

  "Mover" {
    foreach ($m in Import-Csv "$root\data\movers.csv") {
      $user = if ($DryRun) { $null } else { Get-MgUser -Filter "employeeId eq '$($m.employee_id)'" }
      $old  = Get-TargetGroups $m.old_department
      $new  = Get-TargetGroups $m.new_department
      Write-Host "[MOVER] $($m.employee_id): $($m.old_department) -> $($m.new_department)"
      foreach ($g in $old | Where-Object { $_ -notin $new }) {
        Write-Host "   - remove $g"
        if (-not $DryRun) { Remove-MgGroupMemberByRef -GroupId (Get-GroupId $g) -DirectoryObjectId $user.Id }
      }
      foreach ($g in $new | Where-Object { $_ -notin $old }) {
        Write-Host "   + add $g"
        if (-not $DryRun) { New-MgGroupMember -GroupId (Get-GroupId $g) -DirectoryObjectId $user.Id }
      }
      if (-not $DryRun) { Update-MgUser -UserId $user.Id -Department $m.new_department -JobTitle $m.new_title }
    }
  }

  "Leaver" {
    foreach ($l in Import-Csv "$root\data\leavers.csv") {
      Write-Host "[LEAVER] $($l.employee_id) ($($l.leaver_type))"
      if ($DryRun) { Write-Host "   would disable, revoke sessions, remove all groups"; continue }
      $user = Get-MgUser -Filter "employeeId eq '$($l.employee_id)'"
      Update-MgUser -UserId $user.Id -AccountEnabled:$false              # 1. disable
      Revoke-MgUserSignInSession -UserId $user.Id | Out-Null              # 2. kill active sessions
      Get-MgUserMemberOf -UserId $user.Id | Where-Object { $_.AdditionalProperties.'@odata.type' -eq '#microsoft.graph.group' } |
        ForEach-Object { Remove-MgGroupMemberByRef -GroupId $_.Id -DirectoryObjectId $user.Id; Write-Host "   - removed from $($_.AdditionalProperties.displayName)" }
      Write-Host "   disabled; schedule deletion after retention period (30 days)"
    }
  }
}
