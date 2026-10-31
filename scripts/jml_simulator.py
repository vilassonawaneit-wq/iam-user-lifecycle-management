#!/usr/bin/env python3
"""
JML (Joiner-Mover-Leaver) simulator.

Reads the CSV files in /data, applies the lifecycle rules and writes:
  output/audit_log.csv     - every action taken (audit evidence)
  output/final_state.csv   - state of every account after all events

No cloud credentials needed - safe to run anywhere.
Usage:  python scripts/jml_simulator.py
"""
import csv
import pathlib
from datetime import datetime, timedelta

BASE = pathlib.Path(__file__).resolve().parent.parent
DATA, OUT = BASE / "data", BASE / "output"
DOMAIN = "contoso-lab.onmicrosoft.com"
RETENTION_DAYS = 30  # disabled account kept this long before deletion


def read(name):
    with open(DATA / name, newline="", encoding="utf-8") as f:
        return list(csv.DictReader(f))


def load_group_map():
    return {r["department"]: [g for g in r["groups"].split(";") if g] for r in read("role_group_map.csv")}


def groups_for(dept, gmap):
    return set(gmap.get("ALL", [])) | set(gmap.get(dept, []))


def main():
    gmap = load_group_map()
    users, log = {}, []

    def record(date, event, emp, upn, action, detail=""):
        log.append({"date": date, "event": event, "employee_id": emp,
                    "upn": upn, "action": action, "detail": detail})

    # ---- JOINERS -------------------------------------------------
    for j in read("joiners.csv"):
        upn = f"{j['first_name']}.{j['last_name']}@{DOMAIN}".lower()
        grp = groups_for(j["department"], gmap)
        users[j["employee_id"]] = {**j, "upn": upn, "groups": grp,
                                   "status": "Active", "delete_on": ""}
        record(j["start_date"], "JOINER", j["employee_id"], upn, "CREATE_ACCOUNT",
               f"{j['department']} / {j['job_title']}")
        for g in sorted(grp):
            record(j["start_date"], "JOINER", j["employee_id"], upn, "ADD_GROUP", g)

    # ---- MOVERS --------------------------------------------------
    for m in read("movers.csv"):
        u = users.get(m["employee_id"])
        if not u:
            record(m["effective_date"], "MOVER", m["employee_id"], "-", "ERROR", "user not found")
            continue
        old_g, new_g = groups_for(m["old_department"], gmap), groups_for(m["new_department"], gmap)
        for g in sorted(old_g - new_g):
            u["groups"].discard(g)
            record(m["effective_date"], "MOVER", m["employee_id"], u["upn"], "REMOVE_GROUP", g)
        for g in sorted(new_g - old_g):
            u["groups"].add(g)
            record(m["effective_date"], "MOVER", m["employee_id"], u["upn"], "ADD_GROUP", g)
        u["department"], u["job_title"] = m["new_department"], m["new_title"]
        record(m["effective_date"], "MOVER", m["employee_id"], u["upn"], "UPDATE_ATTRIBUTES",
               f"{m['old_department']}/{m['old_title']} -> {m['new_department']}/{m['new_title']}")

    # ---- LEAVERS -------------------------------------------------
    for l in read("leavers.csv"):
        u = users.get(l["employee_id"])
        if not u:
            record(l["termination_date"], "LEAVER", l["employee_id"], "-", "ERROR", "user not found")
            continue
        d = l["termination_date"]
        record(d, "LEAVER", l["employee_id"], u["upn"], "DISABLE_ACCOUNT", l["leaver_type"])
        record(d, "LEAVER", l["employee_id"], u["upn"], "REVOKE_SESSIONS", "refresh tokens revoked")
        for g in sorted(u["groups"]):
            record(d, "LEAVER", l["employee_id"], u["upn"], "REMOVE_GROUP", g)
        u["groups"], u["status"] = set(), "Disabled"
        u["delete_on"] = (datetime.strptime(d, "%Y-%m-%d") + timedelta(days=RETENTION_DAYS)).strftime("%Y-%m-%d")
        record(d, "LEAVER", l["employee_id"], u["upn"], "SCHEDULE_DELETE", u["delete_on"])

    # ---- OUTPUT --------------------------------------------------
    OUT.mkdir(exist_ok=True)
    log.sort(key=lambda r: r["date"])
    with open(OUT / "audit_log.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=list(log[0].keys()))
        w.writeheader(); w.writerows(log)

    with open(OUT / "final_state.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["employee_id", "upn", "department", "job_title", "status", "groups", "delete_on"])
        for eid, u in users.items():
            w.writerow([eid, u["upn"], u["department"], u["job_title"], u["status"],
                        ";".join(sorted(u["groups"])), u["delete_on"]])

    active = sum(1 for u in users.values() if u["status"] == "Active")
    print(f"Events logged : {len(log)}")
    print(f"Active users  : {active}")
    print(f"Disabled users: {len(users) - active}")
    print(f"Files written : {OUT / 'audit_log.csv'}, {OUT / 'final_state.csv'}")


if __name__ == "__main__":
    main()
