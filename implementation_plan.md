# Sprint 1 – Code Review & Merge Plan

## สรุปสถานะ Branch ปัจจุบัน

```
* main (HEAD)  ← target branch สำหรับ merge ทุกอย่าง
│
├── origin/technician  ← ⚠️ ยังไม่ merge (มี 1 commit: "Home and Schedule")
│
└── [merged แล้ว]:
    ├── authentication
    ├── meen-authentication
    └── origin/UI/task_dispatch  ← merge เข้า main แล้ว (0 commit ต่างกัน)
```

---

## ✅ งานที่ Merge เข้า main แล้ว (ไม่ต้อง review อีก)

| งาน Sprint 1 | สถานะใน main | หลักฐาน |
|---|---|---|
| สร้าง UI Login (แอปลูกบ้าน) + ผูกปุ่ม ResidentFacade | ✅ อยู่ใน main | `mobile_app/lib/auth/login/login_page.dart` + `resident_facade.dart` |
| เซ็ตอัป Firebase Project + Config | ✅ อยู่ใน main | commit `e8c8b62 setup firebase auth for juristic_app and technician_app` |
| AuthAdapter + ResidentFacade (งานมีน) | ✅ อยู่ใน main | commit `0b16049 feat: implement AuthAdapter pattern...` |
| สร้าง UI Login (เว็บนิติบุคคล) | ✅ อยู่ใน main | `juristic_app/lib/features/auth/login/` |
| ตารางแสดงรายการ task_dispatch (Mock Data) | ✅ อยู่ใน main | commit `227c9c7 Complete task_dispatch` |

---

## ⚠️ งานที่ยังต้อง Review & Merge

### `origin/technician` → ยังไม่ merge เข้า main

**Commit ที่ต้อง merge:** `9ddb8ed Home and Schedule`

**ไฟล์ใหม่ใน branch นี้:**
| ไฟล์ | เนื้อหา |
|------|---------|
| `technician_app/lib/schedule/models/schedule_model.dart` | Model ข้อมูล schedule |
| `technician_app/lib/schedule/screens/schedule.dart` | หน้า Schedule screen |
| `technician_app/lib/schedule/widgets/date_selector.dart` | Widget เลือกวันที่ |
| `technician_app/lib/schedule/widgets/task_card.dart` | Task card สำหรับ schedule |
| `technician_app/lib/schedule/widgets/timeline_line.dart` | Timeline UI |
| `technician_app/lib/home/screens/home.dart` | *(อัปเดต)* Home screen |
| `technician_app/lib/home/widgets/task_card.dart` | *(อัปเดต)* Task card |
| `technician_app/pubspec.yaml` / `pubspec.lock` | *(อัปเดต)* dependencies |

> [!IMPORTANT]
> Branch `origin/technician` ยังไม่ merge — ต้องทำ PR หรือ merge เข้า main

---

## Checklist Code Review แต่ละงาน

### 1. UI Login แอปลูกบ้าน (mobile_app) — อยู่ใน main แล้ว
- [x] มีหน้า `login_page.dart`
- [x] มีปุ่ม Google/Facebook Login
- [x] ผูกปุ่มเข้า `ResidentFacade` ✅
- [ ] **ตรวจ:** `LoginController` เรียก `ResidentFacade` แทน `AuthService` โดยตรงหรือยัง?

### 2. UI Login แอปช่างซ่อม (technician_app) — อยู่ใน main แล้ว
- [x] มีหน้า `login/screens/login.dart`
- [x] UI สวยงาม มี Staff ID + Password field
- [ ] **ตรวจ:** login ต่อ Firebase Auth จริงหรือแค่ UI? (ดู `login_form.dart`)
- [ ] **ตรวจ:** Home screen (`9ddb8ed`) ใน branch `technician` มีข้อมูลใหม่ที่ยังไม่ merge

### 3. UI Login เว็บนิติบุคคล (juristic_app) — อยู่ใน main แล้ว
- [x] มีหน้า `login_page.dart` (Flutter Web layout, width 440)
- [x] Login form ครบ
- [ ] **ตรวจ:** `LoginController.login()` มีแค่ `// TODO` — **ยังไม่ต่อ Firebase Auth จริง**

### 4. เซ็ตอัป Firebase + Config — อยู่ใน main แล้ว
- [x] commit `e8c8b62` setup Firebase ทั้ง juristic_app และ technician_app
- [ ] **ตรวจ:** `google-services.json` / `GoogleService-Info.plist` commit เข้า repo หรือ gitignore?

### 5. หน้าตารางรายการแจ้งซ่อม (task_dispatch) — อยู่ใน main แล้ว
- [x] `juristic_app/lib/features/task_dispatch/` มีครบ
- [x] ใช้ Mock Data
- [ ] **ตรวจ:** Layout รองรับ Flutter Web (responsive) หรือยัง?

---

## แผนการ Merge

### ขั้นตอนที่ต้องทำ

```
1. Merge origin/technician → main
   git checkout main
   git merge origin/technician
   # ตรวจ conflict ใน pubspec.yaml (ถ้ามี)
   git push origin main

2. ตรวจ LoginController (mobile_app)
   - เปลี่ยนจากเรียก AuthService โดยตรง
   - ให้เรียก ResidentFacade แทน

3. แจ้งทีม juristic (Frontend 2)
   - LoginController ยัง TODO อยู่ ต่อ Firebase Auth ด้วย
```

---

## User Review Required

> [!IMPORTANT]
> Branch **`origin/technician`** ยังไม่ merge — มี 1 commit ที่เพิ่ม Schedule feature และอัปเดต Home screen

> [!WARNING]
> **Juristic LoginController** ยังเป็น `// TODO` อยู่ — login ยังไม่ต่อ Firebase จริง  
> ต้องแจ้งทีม Frontend 2 หรือทำให้เองก่อน merge

> [!NOTE]
> หลัง merge `technician` branch อาจมี conflict ที่ `pubspec.yaml` และ `pubspec.lock`  
> เพราะ branch นี้แยกออกมาก่อน commit `e8c8b62` (firebase setup)

---

## Verification Plan

1. `git merge origin/technician` — ไม่มี conflict หรือแก้ conflict ได้
2. `cd technician_app && flutter pub get && flutter analyze` — ไม่มี error
3. ดู `LoginController` ใน mobile_app — ตรวจว่าเรียก `ResidentFacade` หรือ `AuthService` โดยตรง
4. `git log --oneline --graph` — ยืนยันว่า technician branch merge เข้า main แล้ว
