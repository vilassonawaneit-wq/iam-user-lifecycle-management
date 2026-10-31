# 03 – Mover Process (SOP)

**Trigger:** HR submits a transfer, promotion or title change. **Owner:** IAM Analyst.

## Principle
> Access follows the **current** job, not the job history. Always remove before (or together with) adding.

## Procedure
| # | Step | Control |
|---|---|---|
| 1 | Receive change record (old → new department/title, effective date) | Source of truth |
| 2 | Compare old vs. new group sets | Calculates delta |
| 3 | **Remove** groups only the old department needed | Prevents privilege creep |
| 4 | **Add** groups the new department needs | Least privilege |
| 5 | Update department, job title, manager attributes | Data accuracy |
| 6 | Notify the new manager; ask the old manager to confirm no special exceptions are needed | Accountability |
| 7 | Log all changes | Audit evidence |

## Scenarios covered in sample data
| Employee | Change | Expected result |
|---|---|---|
| E1003 | Sales → Finance | Lose `GRP-Sales-Staff`, `GRP-CRM-Users`; gain `GRP-Finance-Staff`, `GRP-ERP-Finance` |
| E1006 | HR → IT | Lose HR groups; gain IT + VPN groups |
| E1001 | Promotion within IT | Groups unchanged; title updated |

## Common pitfalls
- Adding new access but forgetting to remove the old (privilege creep).
- Temporary project access that is never revoked – give it an expiry date.
