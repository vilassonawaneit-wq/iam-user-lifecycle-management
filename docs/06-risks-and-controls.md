# 06 – Risks and Controls

| Risk | Impact | Control implemented in this lab |
|---|---|---|
| Delayed onboarding | Lost productivity | Scripted, repeatable joiner process |
| Excess access at hire | Over-privileged users | Department-based groups only |
| Privilege creep after transfers | Segregation-of-duties issues | Mover process removes old-department groups |
| Orphaned accounts after exit | Unauthorized access, audit finding | Disable + revoke + remove groups on termination day |
| Active sessions after exit | Continued access | Session/refresh-token revocation |
| Weak initial credentials | Account takeover | Random temp password, forced change, MFA |
| No evidence for auditors | Failed audit | `audit_log.csv` + screenshots |
| Test data leaking | Privacy breach | Fictional data; `.gitignore` for secrets |

## Framework mapping (informational)
| Framework | Related control area |
|---|---|
| ISO/IEC 27001:2022 Annex A | Identity management, access rights, access control |
| NIST SP 800-53 | AC-2 (Account Management), PS-4 (Personnel Termination), PS-5 (Personnel Transfer) |
| SOC 2 | Logical access controls (CC6) |
