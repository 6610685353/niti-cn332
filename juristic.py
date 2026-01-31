def divider():
    print("=" * 51)


# ---------- LOGIN ----------
def admin_login():
    divider()
    print("SMART NITI")
    divider()
    print("🔐 Login")
    email = input("Email    : ")
    password = input("Password : ")
    print("\n✅ Admin login success\n")


# ---------- DASHBOARD ----------
def dashboard():
    divider()
    print("📊 DASHBOARD OVERVIEW")
    divider()
    print("Total repair requests        : 142")
    print("Billing summary              : 20 / 250 paid")
    print("Parcel pending pickup        : 28")
    print("Scheduled facility booking   : 142\n")

    print("E-Repair overview:")
    print("- Pending request   : 2")
    print("- Pending approval  : 2")
    print("- In progress       : 4")
    print("- Complete          : 10")
    print("Total tickets       : 18\n")


# ---------- TASK ASSIGNMENT ----------
def task_assignment():
    divider()
    print("🛠 TASK ASSIGNMENT & DISPATCH")
    divider()

    print("Repair status summary:")
    print("- Pending request   : 2")
    print("- Pending approval  : 2")
    print("- In progress       : 4")
    print("- Complete          : 10")
    print("- Technician active : 5 / 15\n")

    print("Unassigned tickets:")
    print("1) Ticket #1023 - Electric")
    print("2) Ticket #1024 - Plumbing")

    print("\nTechnician availability:")
    print("1) Jane Doe (Plumbing)")
    print("   Current workload: 3 / 5 tasks (60%)")
    print("2) John Smith (Electric)")
    print("   Current workload: 2 / 5 tasks (40%)")

    assign = input("\nAssign task now? (yes/no): ")
    if assign.lower() == "yes":
        tech = input("Assign to technician: ")
        ticket = input("Select ticket ID: ")
        print(f"\n✅ Ticket {ticket} assigned successfully\n")
    else:
        print("\n↩ Back to menu\n")


# ---------- ANNOUNCEMENT ----------
def announcement():
    divider()
    print("📢 ANNOUNCEMENT")
    divider()

    headline = input("Headline        : ")
    body = input("Message body    : ")
    attachment = input("Attachment/img : ")

    print("\nTargeting options:")
    print("1) Building A")
    print("2) Building B")
    print("3) Building C")
    print("4) Select all")
    target = input("> ")

    print("\nPublish option:")
    print("1) Publish now")
    print("2) Schedule for later")
    publish = input("> ")

    if publish == "2":
        print("\n📅 Schedule announcement")
        schedule_date = input("Date (YYYY-MM-DD): ")
        schedule_time = input("Time (HH:MM)     : ")
        print(f"\n⏰ Announcement scheduled on {schedule_date} at {schedule_time}")

    elif publish == "1":
        print("\n🚀 Announcement published now")

    else:
        print("\n❌ Invalid publish option")
        return

    print("\n✅ Announcement created successfully\n")
    print("")
    print("")


def manage_announcement():
    divider()
    print("🗂 MANAGE ANNOUNCEMENTS")
    divider()
    print("1) Fire Drill Notice")
    print("2) Water Maintenance\n")

    action = input("Select announcement to delete: ")
    print("\n✏ Announcement deleted successfully\n")


# ---------- PARCEL MANAGEMENT ----------
def parcel_management():
    divider()
    print("📦 PARCEL MANAGEMENT")
    divider()

    print("Select option:")
    print("1) Search resident")
    print("2) Browse resident list")
    option = input("> ")

    residents = [
        {
            "name": "Somchai Jaidee",
            "email": "somchai@email.com",
            "building": "A",
            "room": "1203",
            "phone": "089-123-4567",
        },
        {
            "name": "Jane Doe",
            "email": "jane@email.com",
            "building": "B",
            "room": "0507",
            "phone": "081-555-8888",
        },
    ]

    # ---------- SEARCH ----------
    if option == "1":
        print("\nSearch by name / email / building / room / phone")
        keyword = input("> ").lower()

        result = None
        for r in residents:
            if (
                keyword in r["name"].lower()
                or keyword in r["email"].lower()
                or keyword in r["building"].lower()
                or keyword in r["room"]
                or keyword in r["phone"]
            ):
                result = r
                break

        if not result:
            print("\n❌ Resident not found\n")
            return

        show_resident_detail(result)

    # ---------- BROWSE ----------
    elif option == "2":
        print("\nResident list:")
        for idx, r in enumerate(residents, start=1):
            print(f"{idx}) {r['name']} | Bldg {r['building']} | Room {r['room']}")

        select = input("\nSelect resident number (or back): ")
        if not select.isdigit() or int(select) < 1 or int(select) > len(residents):
            print("\n↩ Back to menu\n")
            return

        show_resident_detail(residents[int(select) - 1])

    else:
        print("\n❌ Invalid option\n")


def show_resident_detail(resident):
    divider()
    print("👤 RESIDENT DETAIL")
    divider()
    print(f"Name     : {resident['name']}")
    print(f"Email    : {resident['email']}")
    print(f"Building : {resident['building']}")
    print(f"Room     : {resident['room']}")
    print(f"Phone    : {resident['phone']}")

    gen = input("\nGenerate QR code for parcel pickup? (yes/no): ")
    if gen.lower() == "yes":
        print("\n🔳 QR Code generated successfully\n")
    else:
        print("\n↩ Back to menu\n")


# ---------- MAIN MENU ----------
def admin_main_menu():
    while True:
        divider()
        print("🏠 ADMIN MAIN MENU")
        divider()
        print(
            """
1) View dashboard
2) Task assignment & dispatch
3) Create announcement
4) Manage announcement
5) Parcel management
6) Logout
"""
        )
        choice = input("> ")

        if choice == "1":
            dashboard()
        elif choice == "2":
            task_assignment()
        elif choice == "3":
            announcement()
        elif choice == "4":
            manage_announcement()
        elif choice == "5":
            parcel_management()
        elif choice == "6":
            print("\n👋 Logged out successfully")
            break
        else:
            print("\n❌ Invalid choice\n")


# ---------- RUN ----------
if __name__ == "__main__":
    admin_login()
    admin_main_menu()
