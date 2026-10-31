# 04 – Leaver Process (SOP)

**Trigger:** HR confirms termination/resignation. **Owner:** IAM Analyst.

## Timing
| Leaver type | When to revoke |
|---|---|
| Voluntary | End of last working day |
| Involuntary | **Immediately**, before the employee is informed |

## Procedure
| # | Step | Control |
|---|---|---|
| 1 | Disable the account (`accountEnabled = false`) | Stops new sign-ins |
| 2 | Revoke all sign-in sessions / refresh tokens | Stops existing sessions |
| 3 | Remove from all security groups | Removes entitlements |
| 4 | Remove/reset MFA methods; retrieve company devices | Credential hygiene |
| 5 | Transfer mailbox/files to the manager | Business continuity |
| 6 | Keep the disabled account 30 days, then delete | Retention / recovery window |
| 7 | Log all actions and confirm with HR | Audit evidence |

## Verification
- Sign-in attempt with the leaver's credentials fails.
- User shows **Blocked sign-in = Yes**.
- Group membership list is empty.
- No sign-in activity after termination time in the sign-in logs.

## Common pitfalls
- Disabling the account but leaving active sessions/tokens.
- Forgetting non-directory access (shared mailboxes, SaaS local accounts, API keys).
