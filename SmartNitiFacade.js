// ==========================================
// PART 1: DOMAIN MODELS & SERVICES (The "Hidden" Subsystems)
// อิงตาม Class Diagram Iteration 2 แต่นำมา Upgrade ให้รับค่าจาก UI ใหม่ได้จริง
// ==========================================

class Ticket {
    constructor(id, ownerId, type, details, location, timeSlot) {
        this.id = id;
        this.ownerId = ownerId;
        this.type = type;           // e.g. "Plumbing"
        this.details = details;     // e.g. "ท่อรั่วใต้ซิงค์"
        this.gps = location;        // e.g. "Room 502"
        this.timeSlot = timeSlot;   // e.g. "10:00-12:00"
        this.status = "Pending";
        this.technicianId = null;
        this.image = null;
        console.log(`   [Domain:Ticket] Created #${id}: ${type} @ ${location}`);
    }
    
    assign(techId) { this.technicianId = techId; this.status = "Assigned"; }
    accept() { this.status = "Accepted"; }
    updateStatus(newStatus) { this.status = newStatus; }
}

class Parcel {
    constructor(id, roomNumber, carrier) {
        this.barcodeID = id;
        this.roomNumber = roomNumber;
        this.carrier = carrier;     // e.g. "Kerry", "Flash"
        this.status = "Arrived";
        this.qrImage = null;
        console.log(`   [Domain:Parcel] New parcel from ${carrier} for ${roomNumber}`);
    }
    
    generateQR() {
        this.qrImage = `QR-${this.barcodeID}`;
        return this.qrImage;
    }
}

class Booking {
    constructor(id, userId, roomId, dateTime, addOns) {
        this.id = id;
        this.userId = userId;
        this.roomId = roomId;
        this.dateTime = dateTime;
        this.addOns = addOns; // e.g. ["Projector", "Snack"]
        this.status = "Confirmed";
        console.log(`   [Domain:Booking] Confirmed ${roomId} for ${dateTime}`);
    }
}

class MeetingRoom {
    constructor(name) { this.name = name; this.status = "Available"; }
    
    reserve(userId, dateTime, addOns) {
        if (this.status === "Available") {
            return new Booking("BK-"+Date.now(), userId, this.name, dateTime, addOns);
        }
        return null;
    }
}

class PaymentSystem {
    processCreditCard(amount) {
        console.log(`   [Service:Payment] 💳 Charging Credit Card: ${amount} THB... Success`);
        return "TXN-" + Math.floor(Math.random() * 100000);
    }
    generateQR(amount) {
        console.log(`   [Service:Payment] 📱 Generated ThaiQR for ${amount} THB`);
        return "QR-PAY-IMAGE";
    }
    generateReceipt(txnId) {
        console.log(`   [Service:Receipt] 📄 Generated Receipt PDF for ${txnId}`);
    }
}

class NotificationService {
    pushMessage(target, msg) {
        console.log(`   [Service:Notification] 🔔 Push to [${target}]: "${msg}"`);
    }
}

// Global Instances (Mock Database/Services)
const paymentSys = new PaymentSystem();
const notifService = new NotificationService();
const rooms = { "MeetingRoom1": new MeetingRoom("Meeting Room 1") };

// ==========================================
// PART 2: THE FACADES (API Gateways)
// ==========================================

// 🏠 1. RESIDENT FACADE
class ResidentFacade {
    constructor(userId) { this.userId = userId; }

    // --- Auth & Profile ---
    registerUser(email, password, role) { console.log(`[Auth] Register: ${email}`); return true; }
    login(username, password) { console.log(`[Auth] Login success`); return "TOKEN-123"; }
    logout() { console.log(`[Auth] Logout success`); }
    updateProfile(data) { console.log(`[Profile] Updated: ${JSON.stringify(data)}`); }
    getUserProfile() { return { id: this.userId, name: "Somchai", unit: "A-502" }; }

    // --- Dashboard & Notifications ---
    getHomeSummary() { return { pendingBills: 1, waitingParcels: 2 }; }
    getNotifications() { return ["Bill Due", "Parcel Arrived"]; }

    // --- Maintenance (แจ้งซ่อม) ---
    submitRepairRequest(type, details, location, timeSlot) {
        console.log(`\n--- 🏠 Resident: Submit Repair ---`);
        // 1. Create Domain Object
        const ticket = new Ticket("TK-"+Date.now(), this.userId, type, details, location, timeSlot);
        // 2. Notify Juristic
        notifService.pushMessage("JuristicAdmin", `New Repair Request: ${ticket.id}`);
        return ticket.id;
    }
    trackRepairStatus(ticketId) { return { id: ticketId, status: "In Progress" }; }
    getRepairHistory() { return [{ id: "TK-888", status: "Done" }]; }

    // --- Payment (จ่ายบิล) ---
    payBills(billIds, paymentMethod) {
        console.log(`\n--- 🏠 Resident: Pay Bills ---`);
        const amount = 1500; // Mock amount
        let txnId;
        
        // 1. Process Payment
        if (paymentMethod === "CreditCard") txnId = paymentSys.processCreditCard(amount);
        else txnId = paymentSys.generateQR(amount);
        
        // 2. Generate Receipt
        paymentSys.generateReceipt(txnId);
        
        // 3. Notify User
        notifService.pushMessage(this.userId, `Payment Successful! Ref: ${txnId}`);
        return { success: true, txn: txnId };
    }
    getUnpaidBills() { return [{ id: "B-1", amount: 500 }]; }
    getPaymentHistory() { return [{ id: "B-0", amount: 500, status: "Paid" }]; }
    downloadReceipt(txnId) { console.log(`[File] Downloading Receipt-${txnId}.pdf`); }

    // --- Parcel (รับพัสดุ) ---
    getParcelPickupCode(parcelId) {
        console.log(`\n--- 🏠 Resident: Get Parcel QR ---`);
        // In real app, we fetch Parcel object from DB
        const parcel = new Parcel(parcelId, "A-502", "Kerry"); 
        return parcel.generateQR();
    }
    getParcelHistory() { return [{ id: "P-1", courier: "Kerry", date: "2026-02-01" }]; }

    // --- Facility Booking (จองห้อง) ---
    bookFacility(roomId, dateTime, addOns) {
        console.log(`\n--- 🏠 Resident: Book Facility ---`);
        const room = rooms["MeetingRoom1"]; // Mock DB lookup
        if (room) {
            const booking = room.reserve(this.userId, dateTime, addOns);
            if (booking) {
                notifService.pushMessage(this.userId, `Booking Confirmed: ${booking.id}`);
                return booking.id;
            }
        }
        return null;
    }
    verifyFacilityAccess(qrCode) { console.log(`[Access] Verify QR: ${qrCode}`); return true; }
    getBookingDetail(bookingId) { return { id: bookingId, room: "Gym" }; }
    getBookingHistory() { return [{ id: "BOOK-555", room: "Pool", status: "Used" }]; }
    repeatBooking(oldBookingId) { console.log(`Re-booking based on ${oldBookingId}`); }
}

// 👮‍♂️ 2. JURISTIC FACADE
class JuristicFacade {
    // --- Dashboard ---
    getDashboardStats() { return { pendingRepairs: 5, overdueBills: 12 }; }
    getAllTickets(filter) { return ["TK-1", "TK-2"]; }

    // --- Task Dispatch ---
    getTicketDetail(ticketId) { return { id: ticketId, issue: "Water Leak", priority: "High" }; }
    
    assignTaskToTechnician(ticketId, techId) {
        console.log(`\n--- 👮‍♂️ Juristic: Assign Task ---`);
        // In real app: Find ticket -> ticket.assign(techId)
        console.log(`   [DB] Updated Ticket ${ticketId} -> Assigned to ${techId}`);
        notifService.pushMessage(techId, `New Job Assigned: ${ticketId}`);
    }

    // --- Announcement ---
    publishAnnouncement(headline, body, target, time) {
        console.log(`\n--- 👮‍♂️ Juristic: Publish Announcement ---`);
        notifService.pushMessage(target, `📢 ${headline}`);
    }

    // --- Parcel Management ---
    registerIncomingParcel(residentId, carrier) {
        console.log(`\n--- 👮‍♂️ Juristic: Register Parcel ---`);
        const newParcel = new Parcel("P-"+Date.now(), "UnknownRoom", carrier);
        const qr = newParcel.generateQR();
        notifService.pushMessage(residentId, `Parcel Arrived from ${carrier}! Use QR to pickup.`);
        return newParcel.barcodeID;
    }
}

// 👷 3. TECHNICIAN FACADE
class TechnicianFacade {
    constructor(techId) { this.techId = techId; }

    // --- Schedule & Tasks ---
    getMySchedule() { return ["10:00 - Fix A502", "14:00 - Fix B101"]; }
    getAllAssignedTasks() { return ["TK-999", "TK-888"]; }
    getRepairDetail(ticketId) { return { id: ticketId, desc: "Broken Pipe", contact: "081-xxxx" }; }

    // --- Action ---
    acceptJob(ticketId) {
        console.log(`\n--- 👷 Technician: Accept Job ---`);
        console.log(`   [DB] Ticket ${ticketId} status -> Accepted`);
        notifService.pushMessage("Juristic", `Technician ${this.techId} accepted job ${ticketId}`);
    }
    
    rejectJob(ticketId, reason) {
        console.log(`\n--- 👷 Technician: Reject Job ---`);
        console.log(`   [DB] Ticket ${ticketId} rejected. Reason: ${reason}`);
    }

    updateRepairStatus(ticketId, status, img) {
        console.log(`\n--- 👷 Technician: Update Status ---`);
        console.log(`   [DB] Ticket ${ticketId} status -> ${status}`);
        // Notify Resident
        notifService.pushMessage("ResidentOwner", `Your repair status: ${status}`);
    }
}

// ==========================================
// PART 3: TEST RUN (ตัวอย่างการใช้งาน)
// ==========================================
const user = new ResidentFacade("User-A502");
user.submitRepairRequest("Plumbing", "ท่อรั่ว", "ห้องครัว", "10:00-12:00");
user.payBills(["B1", "B2"], "CreditCard");

const juristic = new JuristicFacade();
juristic.assignTaskToTechnician("TK-1234", "Tech-Somchai");

const tech = new TechnicianFacade("Tech-Somchai");
tech.acceptJob("TK-1234");