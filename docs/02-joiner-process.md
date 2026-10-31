# 02 – Joiner Process (SOP)

**Trigger:** HR confirms a new hire. **Owner:** IAM Analyst. **SLA:** account ready ≥ 1 business day before start date.

## Required inputs
`employee_id`, `first_name`, `last_name`, `department`, `job_title`, `manager`, `start_date`

## Procedure
| # | Step | Control |
|---|---|---|
| 1 | Receive HR record; validate all fields are present | Data quality |
| 2 | Check the employee ID does not already exist | Prevents duplicates |
| 3 | Build UPN `first.last@domain` (add a number on collision) | Naming standard |
| 4 | Create the account with a random temporary password; force change at first sign-in | Secure default |
| 5 | Add to `GRP-All-Employees` | Baseline access |
| 6 | Add to department groups per `role_group_map.csv` | RBAC / least privilege |
| 7 | Confirm MFA registration is required | Strong authentication |
| 8 | Log the actions; send credentials to the manager via a secure channel | Accountability |

## Manual portal steps (alternative to the script)
Entra admin center → **Users → New user → Create new user** → fill profile → **Assignments → Add group** → Review + create.

## Evidence to capture
- User profile page (department, title, employee ID)
- Group membership of the new user
- Audit log entry "Add user" / "Add member to group"
