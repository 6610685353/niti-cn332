// ==========================================
// PART 1: SUBSYSTEMS (ระบบย่อยหลังบ้านที่ซับซ้อน)
// (Mock!!! จำลองการทำงานของ Database และ External Services ต้องไปเขียนcodeจริงทีหลัง)
// ==========================================

class Database {
    constructor() {
        this.tickets = []; // เก็บใบแจ้งซ่อม
        this.bills = [ // จำลองบิลค้างจ่าย
            { id: "B-101", type: "Water", amount: 150, status: "Unpaid" },
            { id: "B-102", type: "Common Fee", amount: 1200, status: "Unpaid" }
        ];
        this.parcels = []; // เก็บพัสดุ
    }
    
    saveTicket(data) { console.log(`   [DB] 💾 Saved Ticket: ${JSON.stringify(data)}`); return "TK-" + Math.floor(Math.random()*10000); }
    updateTicket(id, status, data) { console.log(`   [DB] 📝 Update Ticket ${id}: Status=${status} | Data=${JSON.stringify(data)}`); }
    
    getUnpaidBills(userId) { return this.bills.filter(b => b.status === "Unpaid"); }
    markBillPaid(billId) { console.log(`   [DB] 💰 Bill ${billId} marked as PAID`); }
    
    checkRoomAvailability(roomId, time) { console.log(`   [Schedule] 📅 Checking ${roomId} at ${time}... OK (Available)`); return true; }
    saveBooking(data) { console.log(`   [DB] 📅 Booking Saved: ${JSON.stringify(data)}`); }
    
    saveParcel(data) { console.log(`   [DB] 📦 Parcel Saved: ${JSON.stringify(data)}`); return "P-" + Math.floor(Math.random()*1000); }
    getParcel(userId) { return "P-999"; } // Mock
}

class NotificationSystem {
    send(target, msg) { console.log(`   [Notification] 🔔 To ${target}: ${msg}`); }
    broadcast(building, msg) { console.log(`   [Broadcast] 📢 To Building ${building}: ${msg}`); }
}

class PaymentGateway {
    processPayment(amount, method) { 
        console.log(`   [Bank API] 💳 Processing ${amount} THB via ${method}... Success!`);
        return "TXN-" + Date.now();
    }
}

class AccessControl {
    generateQRCode(type, refId) {
        console.log(`   [Security] 🔳 Generating QR Code for ${type} (${refId})`);
        return `|| QR-CODE-FOR-${refId} ||`;
    }
}

// Global Instances (เพื่อให้ทุก Facade ใช้ระบบเดียวกัน)
const db = new Database();
const notif = new NotificationSystem();
const bank = new PaymentGateway();
const access = new AccessControl();

// ==========================================
// PART 2: FACADES (ตัวกลางแยกตาม Actor)
// ==========================================

// 🏠 1. RESIDENT FACADE (สำหรับลูกบ้าน)
class ResidentFacade {
    constructor(userId) { this.userId = userId; }

    // 1.1 Authentication (ข้ามไปเพราะทำในระดับ Route ได้ แต่ใส่ไว้ให้เห็นภาพ)
    login(email, password) { console.log(`[Auth] User ${email} logged in.`); }

    // 1.2 Create Repair Request
    submitRepairRequest(type, details, location, timeSlot) {
        console.log(`\n--- 🏠 Resident: Submit Repair ---`);
        const ticketData = { owner: this.userId, type, details, location, timeSlot, status: 'Pending' };
        const ticketId = db.saveTicket(ticketData);
        notif.send("Juristic Admin", `New Repair Request: ${ticketId}`);
        return ticketId;
    }

    // 1.3 Track Repair & History
    trackRepairStatus(ticketId) {
        // ในจริงต้องดึงจาก DB
        console.log(`\n--- 🏠 Resident: Tracking ${ticketId} ---`);
        return { id: ticketId, status: "In Progress", technician: "Somchai" };
    }

    // 1.4 Bill Payment
    payBills(billIds, paymentMethod) {
        console.log(`\n--- 🏠 Resident: Pay Bills ---`);
        // 1. คำนวณยอดรวม
        const bills = db.getUnpaidBills(this.userId).filter(b => billIds.includes(b.id));
        const totalAmount = bills.reduce((sum, b) => sum + b.amount, 0);
        
        // 2. ตัดเงินผ่าน Bank
        const txnId = bank.processPayment(totalAmount, paymentMethod);
        
        // 3. อัปเดตสถานะบิลและสร้างใบเสร็จ
        bills.forEach(b => db.markBillPaid(b.id));
        console.log(`   [Receipt] 📄 Receipt Generated: REF-${txnId}`);
        return { success: true, transactionId: txnId };
    }

    // 1.5 Parcel Retrieval
    getParcelPickupCode(parcelId) {
        console.log(`\n--- 🏠 Resident: Get Parcel QR ---`);
        return access.generateQRCode("Parcel Pickup", parcelId);
    }

    // 1.6 Facility Booking
    bookFacility(roomId, dateTime, addOns) {
        console.log(`\n--- 🏠 Resident: Book Facility ---`);
        if (db.checkRoomAvailability(roomId, dateTime)) {
            db.saveBooking({ user: this.userId, room: roomId, time: dateTime, addOns });
            return access.generateQRCode("Facility Access", roomId);
        }
        return null;
    }
}

// 👮‍♂️ 2. JURISTIC FACADE (สำหรับนิติบุคคล)
class JuristicFacade {
    // 2.1 Dashboard
    getDashboardStats() {
        console.log(`\n--- 👮‍♂️ Juristic: Dashboard ---`);
        return { pendingRepairs: 5, overdueBills: 12, parcelsLeft: 8 };
    }

    // 2.2 Task Assignment
    assignTaskToTechnician(ticketId, technicianId) {
        console.log(`\n--- 👮‍♂️ Juristic: Assign Task ---`);
        db.updateTicket(ticketId, "Assigned", { technician: technicianId });
        notif.send(technicianId, `You have been assigned to Ticket ${ticketId}`);
        notif.send("ResidentOwner", `Ticket ${ticketId} assigned to ${technicianId}`);
    }

    // 2.3 Announcement Management
    publishAnnouncement(headline, body, targetBuilding, scheduleTime) {
        console.log(`\n--- 👮‍♂️ Juristic: Publish Announcement ---`);
        if (scheduleTime) {
            console.log(`   [Scheduler] ⏰ Scheduled for ${scheduleTime}`);
        } else {
            notif.broadcast(targetBuilding, `New Announcement: ${headline}`);
        }
    }

    // 2.4 Parcel Management (รับของเข้า)
    registerIncomingParcel(residentId, logisticsCompany) {
        console.log(`\n--- 👮‍♂️ Juristic: Register Parcel ---`);
        const parcelId = db.saveParcel({ owner: residentId, carrier: logisticsCompany, status: 'Arrived' });
        notif.send(residentId, `Your parcel from ${logisticsCompany} has arrived! (Ref: ${parcelId})`);
        return parcelId;
    }
}

// 👷 3. TECHNICIAN FACADE (สำหรับช่าง)
class TechnicianFacade {
    constructor(techId) { this.techId = techId; }

    // 3.1 & 3.2 View Schedule & Accept Job
    acceptJob(ticketId) {
        console.log(`\n--- 👷 Technician: Accept Job ---`);
        db.updateTicket(ticketId, "Accepted", { by: this.techId });
        notif.send("Juristic Admin", `Technician ${this.techId} accepted ${ticketId}`);
    }

    // 3.3 Job Execution & Update
    updateRepairStatus(ticketId, status, evidenceImage) {
        console.log(`\n--- 👷 Technician: Update Status (${status}) ---`);
        db.updateTicket(ticketId, status, { evidence: evidenceImage });
        
        if (status === "Done") {
            notif.send("ResidentOwner", `Repair ${ticketId} is Completed!`);
        } else {
            notif.send("ResidentOwner", `Repair Update: ${status}`);
        }
    }
}

// ==========================================
// PART 3: SCENARIO TESTING (จำลองเหตุการณ์จริง)
// ==========================================

// 1. สร้าง Actor
const resident = new ResidentFacade("User-A502");
const admin = new JuristicFacade();
const tech = new TechnicianFacade("Tech-Somchai");

// --- SCENARIO A: การแจ้งซ่อมจนจบ ---
console.log("\n📍 SCENARIO A: Full Repair Cycle");
const ticket = resident.submitRepairRequest("Plumbing", "ท่อรั่ว", "ห้องครัว", "10:00"); // 1.1
admin.assignTaskToTechnician(ticket, "Tech-Somchai"); // 2.2
tech.acceptJob(ticket); // 3.2
tech.updateRepairStatus(ticket, "On Way", null); // 3.3
tech.updateRepairStatus(ticket, "Done", "after_fix.jpg"); // 3.3

// --- SCENARIO B: การจ่ายบิล ---
console.log("\n📍 SCENARIO B: Bill Payment");
resident.payBills(["B-101", "B-102"], "CreditCard"); // 1.4

// --- SCENARIO C: จองห้องประชุม ---
console.log("\n📍 SCENARIO C: Facility Booking");
resident.bookFacility("Meeting Room 1", "2026-02-14 09:00", ["Projector"]); // 1.6

// --- SCENARIO D: นิติประกาศข่าว ---
console.log("\n📍 SCENARIO D: Announcement");
admin.publishAnnouncement("น้ำประปาไม่ไหล", "ปิดซ่อมบำรุง 2 ชม.", "Building A", null); // 2.3

// --- SCENARIO E: พัสดุมาส่ง ---
console.log("\n📍 SCENARIO E: Parcel Process");
const parcel = admin.registerIncomingParcel("User-A502", "Kerry Express"); // 2.4
resident.getParcelPickupCode(parcel); // 1.5