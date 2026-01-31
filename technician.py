def divider():
    print("-" * 41)


# ---------- LOGIN ----------
def technician_login():
    divider()
    print("SMART NITI")
    divider()
    print("🔐 Login")
    email = input("Email    : ")
    password = input("Password : ")
    print("\n✅ Technician login success\n")


# ---------- WORK SUMMARY ----------
def work_summary():
    divider()
    print("📊 WORK SUMMARY")
    divider()
    print("Assigned tasks : 8")
    print("Pending tasks  : 3")
    print("Resolved tasks : 5\n")


# ---------- TODAY TASK ----------
def today_task():
    divider()
    print("🗓 MY TASK")
    divider()

    tasks = [
        {
            "id": "T-2001",
            "title": "Air conditioner not cooling",
            "type": "HVAC",
            "priority": "High",
            "location": "Building A - Room 1203",
            "date": "2026-02-02",
            "time": "10:00–12:00",
            "status": "Accepted",
        },
        {
            "id": "T-2002",
            "title": "Light not working",
            "type": "Electric",
            "priority": "Medium",
            "location": "Building B - Room 0507",
            "date": "2026-02-02",
            "time": "13:00–15:00",
            "status": "Pending",
        },
    ]

    for idx, t in enumerate(tasks, start=1):
        print(f"{idx}) {t['title']} | {t['status']}")

    select = input("\nSelect task (or back): ")
    if not select.isdigit():
        print("\n↩ Back\n")
        return

    task = tasks[int(select) - 1]

    divider()
    print("🧾 TASK DETAIL")
    divider()
    print(f"Issue title  : {task['title']}")
    print(f"Description  : AC not cold, unusual noise")
    print(f"Job type     : {task['type']}")
    print(f"Priority     : {task['priority']}")
    print(f"Location     : {task['location']}")
    print(f"Date / Time  : {task['date']} {task['time']}")

    if task["status"] == "Pending":
        accept = input("\nAccept this task? (yes/no): ")
        if accept.lower() == "yes":
            print("\n✅ Task accepted\n")
        else:
            print("\n↩ Back\n")

    else:
        before = input("\nUpload BEFORE image path: ")
        after = input("Upload AFTER image path : ")

        print("\nAction:")
        print("1) Save and update progress")
        print("2) Finish and close job")
        action = input("> ")

        if action == "1":
            print("\n🔄 Progress updated successfully\n")
        elif action == "2":
            print("\n✅ Job finished and closed\n")
        else:
            print("\n↩ Back\n")


# ---------- SCHEDULE ----------
def view_schedule():
    divider()
    print("📅 WORK SCHEDULE")
    divider()
    print("2026-02-02")
    print("- 10:00–12:00 | HVAC | Room 1203")
    print("- 13:00–15:00 | Electric | Room 0507\n")
    divider()
    print("2026-02-04")
    print("- 10:00–12:00 | Plumbing | Room 1111")
    print("- 13:00–15:00 | Electric | Room 2222\n")


# ---------- REPAIR HISTORY ----------
def repair_history():
    divider()
    print("📜 REPAIR HISTORY")
    divider()

    print("Filter:")
    print("1) All")
    print("2) Pending")
    print("3) Repairing")
    print("4) Done")
    choice = input("> ")

    print("\nHistory result:")
    print("- Air conditioner repair | Done")
    print("- Lighting repair | Repairing")
    print("- Plumbing leak | Pending\n")


# ---------- PROFILE ----------
def technician_profile():
    divider()
    print("👤 UPDATE PROFILE")
    divider()
    print("1) Update email")
    print("2) Update phone number")
    choice = input("> ")

    if choice == "1":
        email = input("New email        : ")
    else:
        phone = input("New phone number : ")

    password = input("Confirm password : ")
    print("\n✅ Profile updated successfully\n")


# ---------- MAIN MENU ----------
def technician_main_menu():
    while True:
        divider()
        print("🏠 TECHNICIAN MENU")
        divider()
        print(
            """
1) Work summary
2) Today tasks
3) View schedule
4) Repair history
5) Update profile
6) Logout
"""
        )
        choice = input("> ")

        if choice == "1":
            work_summary()
        elif choice == "2":
            today_task()
        elif choice == "3":
            view_schedule()
        elif choice == "4":
            repair_history()
        elif choice == "5":
            technician_profile()
        elif choice == "6":
            print("\n👋 Logged out successfully")
            break
        else:
            print("\n❌ Invalid choice\n")


# ---------- RUN ----------
if __name__ == "__main__":
    technician_login()
    technician_main_menu()
