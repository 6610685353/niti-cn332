def divider():
    print("-" * 40)


def login():
    divider()
    print("SMART NITI")
    divider()
    print("🔐 Login")
    email = input("Email    : ")
    password = input("Password : ")
    print("\n✅ Client login success\n")


# ---------- REPAIR ----------
def repair_create():
    divider()
    print("🛠 CREATE REPAIR REQUEST")
    divider()

    print("Select repair type:")
    print("1) Plumbing")
    print("2) Electric")
    print("3) HVAC")
    print("4) Other")
    repair_type = input("> ")

    title = input("\nIssue title       : ")
    description = input("Issue description : ")
    location = input("Location          : ")
    image = input("Upload image      : ")

    print("\nAvailable technician slots:")
    print("1) 2026-02-02 10:00–12:00")
    print("2) 2026-02-02 13:00–15:00")
    slot = input("> ")

    confirm = input("\nConfirm repair request? (yes/no): ")
    if confirm.lower() == "yes":
        print("✅ Repair request submitted successfully\n")
    else:
        print("❌ Repair cancelled\n")


# ---------- REPAIR TRACKING ----------
def repair_tracking():
    divider()
    print("🔍 REPAIR TRACKING")
    divider()

    repairs = [
        {
            "id": "R-1001",
            "title": "Air conditioner not cooling",
            "location": "Building A - Room 1203",
            "date": "2026-02-02",
            "time": "10:00–12:00",
            "status": "In progress (60%)",
            "cost": 1500,
            "technician": "Jane Doe (HVAC)",
        },
        {
            "id": "R-1002",
            "title": "Light not working",
            "location": "Building B - Room 0507",
            "date": "2026-02-01",
            "time": "13:00–15:00",
            "status": "Completed (100%)",
            "cost": 500,
            "technician": "John Smith (Electric)",
        },
    ]

    print("Your repair requests:")
    for idx, r in enumerate(repairs, start=1):
        print(f"{idx}) {r['title']} | {r['status']}")

    select = input("\nSelect repair to view detail (or back): ")

    if not select.isdigit():
        print("\n↩ Back to menu\n")
        return

    index = int(select) - 1
    if index < 0 or index >= len(repairs):
        print("\n❌ Invalid selection\n")
        return

    r = repairs[index]

    divider()
    print("🧾 REPAIR DETAIL")
    divider()
    print(f"Repair ID     : {r['id']}")
    print(f"Issue         : {r['title']}")
    print(f"Location      : {r['location']}")
    print(f"Date          : {r['date']}")
    print(f"Time          : {r['time']}")
    print(f"Status        : {r['status']}")
    print(f"Cost          : {r['cost']} THB")
    print(f"Technician    : {r['technician']}\n")


# ---------- PAYMENT ----------
def payment_create():
    divider()
    print("💳 PAYMENT")
    divider()

    bills = {
        "Common fee": 2000,
        "Water bill": 350,
        "Electricity bill": 1200,
    }

    print("Outstanding bills:")
    for name, amount in bills.items():
        print(f"- {name:<18} : {amount} THB")

    print("\nPayment option:")
    print("1) Pay all bills")
    print("2) Pay selected bills")
    option = input("> ")

    selected_bills = {}
    total_amount = 0

    if option == "1":
        selected_bills = bills
        total_amount = sum(bills.values())

    elif option == "2":
        print("\nSelect bills to pay:")
        for name, amount in bills.items():
            choice = input(f"Pay {name} ({amount} THB)? (y/n): ")
            if choice.lower() == "y":
                selected_bills[name] = amount
                total_amount += amount

        if not selected_bills:
            print("\n⚠ No bill selected. Payment cancelled\n")
            return
    else:
        print("\n❌ Invalid option\n")
        return

    divider()
    print("🧾 PAYMENT SUMMARY")
    divider()
    for name, amount in selected_bills.items():
        print(f"- {name:<18} : {amount} THB")
    print(f"TOTAL AMOUNT       : {total_amount} THB")

    print("\nSelect payment method:")
    print("1) PromptPay")
    print("2) Bank Transfer")
    print("3) Credit Card")
    method = input("> ")

    success = input("\nSimulate payment success? (yes/no): ")

    if success.lower() == "yes":
        print("\n✅ Payment successful")
        download = input("Download receipt? (yes/no): ")
        if download.lower() == "yes":
            print("📄 Receipt saved as receipt.pdf\n")
    else:
        retry = input("\n❌ Payment failed. Retry? (yes/no): ")
        if retry.lower() == "yes":
            print("🔄 Retrying payment...\n")
        else:
            print("❌ Payment cancelled\n")


# ---------- PARCEL ----------
def parcel_receive():
    divider()
    print("📦 PARCEL RECEIVE")
    divider()
    print("[ QR CODE DISPLAYED ]")
    print("✅ Parcel received successfully\n")


# ---------- BOOKING ----------
def booking_create():
    divider()
    print("📅 FACILITY BOOKING")
    divider()

    print("Available rooms:")
    print("1) Meeting Room 1")
    print("2) Meeting Room 2")
    room = input("> ")

    date = input("\nDate (YYYY-MM-DD)      : ")
    time = input("Time (HH:MM–HH:MM)     : ")

    print("\nAdd Amenities:")
    print("1) Projector")
    print("2) Printer")
    addons = input("Select add-ons (comma separated / none): ")

    confirm = input("\nConfirm booking? (yes/no): ")
    if confirm.lower() == "yes":
        print("\n✅ Booking confirmed")
        print("[ QR CODE GENERATED ]\n")
    else:
        print("\n❌ Booking cancelled\n")


# ---------- HISTORY ----------
def divider():
    print("-" * 41)


def history_menu():
    divider()
    print("📜 HISTORY")
    divider()
    print("1) Booking history")
    print("2) Payment history")
    print("3) Repair history")
    print("4) Parcel history")
    choice = input("> ")

    divider()

    if choice == "1":
        print("📅 BOOKING HISTORY")
        divider()
        print("• Meeting Room 1 | 12 Jan 2026 | 18:00 - 19:00 | Completed")
        print("• Meeting Room 2 | 20 Jan 2026 | 10:00 - 12:00 | Cancelled")
        print("• Meeting Room 3 | 25 Jan 2026 | 07:00 - 08:00 | Completed")

    elif choice == "2":
        print("💳 PAYMENT HISTORY")
        divider()
        print("• Common Fee | Jan 2026 | 2,500 THB | Paid")
        print("• Water Bill | Dec 2025 | 320 THB | Paid")
        print("• Electricity Bill | Dec 2025 | 1,450 THB | Paid")

    elif choice == "3":
        print("🛠️ REPAIR HISTORY")
        divider()
        print("• Air Conditioner Leak | 10 Jan 2026 | Done")
        print("• Light Bulb Replacement | 18 Jan 2026 | Done")
        print("• Water Pipe Repair | 22 Jan 2026 | In Progress")

    elif choice == "4":
        print("📦 PARCEL HISTORY")
        divider()
        print("• TH123456 | Received | 15 Jan 2026")
        print("• TH789456 | Received | 19 Jan 2026")
        print("• TH00000 | Pending Pickup | 28 Jan 2026")

    else:
        print("❌ Invalid choice")
    divider()


# ---------- PROFILE ----------
def profile_update():
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
def main_menu():
    while True:
        divider()
        print("🏠 MAIN MENU")
        divider()
        print(
            """
1) Create repair request
2) Repair Tracking
3) Payment
4) Receive parcel
5) Facility booking
6) View history
7) Update profile
8) Logout
"""
        )
        choice = input("> ")

        if choice == "1":
            repair_create()
        elif choice == "2":
            repair_tracking()
        elif choice == "3":
            payment_create()
        elif choice == "4":
            parcel_receive()
        elif choice == "5":
            booking_create()
        elif choice == "6":
            history_menu()
        elif choice == "7":
            profile_update()
        elif choice == "8":
            print("\n👋 Goodbye!")
            break
        else:
            print("\n❌ Invalid choice\n")


# ---------- RUN ----------
if __name__ == "__main__":
    login()
    main_menu()
