# 05 – Test Cases & Results

Run the simulator (`python scripts/jml_simulator.py`) or the Graph script, then verify each case. Mark **Pass/Fail** and add screenshots to `/evidence`.

| ID | Scenario | Steps | Expected result | Result | Evidence |
|---|---|---|---|---|---|
| TC-01 | Joiner – account created | Run Joiner mode | 8 accounts exist with correct dept/title | ☐ | `evidence/tc01-users.png` |
| TC-02 | Joiner – baseline group | Check `GRP-All-Employees` | Contains all 8 joiners | ☐ | `evidence/tc02-baseline.png` |
| TC-03 | Joiner – dept groups | Check IT group | Only IT staff present | ☐ | `evidence/tc03-it-group.png` |
| TC-04 | Joiner – forced pwd change | First sign-in as a new user | Prompted to change password and register MFA | ☐ | `evidence/tc04-first-signin.png` |
| TC-05 | Mover – dept change | Run Mover mode for E1003 | Sales groups removed, Finance groups added | ☐ | `evidence/tc05-mover.png` |
| TC-06 | Mover – no stale access | List groups of E1006 | No HR groups remain | ☐ | `evidence/tc06-no-stale.png` |
| TC-07 | Mover – promotion only | Run Mover for E1001 | Title changes, groups unchanged | ☐ | `evidence/tc07-promo.png` |
| TC-08 | Leaver – disabled | Run Leaver mode | E1002 and E1007 show *Blocked sign-in = Yes* | ☐ | `evidence/tc08-disabled.png` |
| TC-09 | Leaver – groups removed | List groups of E1002 | Empty | ☐ | `evidence/tc09-groups.png` |
| TC-10 | Leaver – sessions revoked | Try using an existing session | Session invalid after revocation | ☐ | `evidence/tc10-session.png` |
| TC-11 | Negative – unknown user | Add an unknown ID to movers.csv | Simulator logs `ERROR user not found` | ☐ | `output/audit_log.csv` |
| TC-12 | Audit trail | Open `output/audit_log.csv` | Every event has date, user, action | ☐ | `output/audit_log.csv` |

## Simulator results (sample data)
```
Events logged : 55
Active users  : 6
Disabled users: 2
```
Expected final state is in [`output/final_state.csv`](../output/final_state.csv).
