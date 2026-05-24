# Smartniti Management System

> แพลตฟอร์มบริหารจัดการที่อยู่อาศัย มุ่งเน้นระบบแจ้งซ่อมและการจัดการงานบำรุงรักษาแบบครบวงจร

---
## Members

1. Thanawan Phongphaew (6610685171)  
2. Netchanok Yindee (6610685221)  
3. Punnawat Namkum (6610685247)  
4. Siranat Phimphicharn (6610685353)  
5. Ultimata Sangrungruang (6610685387)
---

## Tech Stack

### Frontend
![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)

### Backend
![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54)
![FastAPI](https://img.shields.io/badge/FastAPI-009688?style=for-the-badge&logo=fastapi&logoColor=white)

### Database & Infrastructure
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/postgres-%23316192.svg?style=for-the-badge&logo=postgresql&logoColor=white)
![Firebase](https://img.shields.io/badge/firebase-%23039BE5.svg?style=for-the-badge&logo=firebase)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![DigitalOcean](https://img.shields.io/badge/DigitalOcean-0080FF?style=for-the-badge&logo=digitalocean&logoColor=white)
![Vercel](https://img.shields.io/badge/Vercel-000000?style=for-the-badge&logo=vercel&logoColor=white)

---

## ภาพรวม

**Smartniti Management System** พัฒนาขึ้นเพื่อยกระดับ **ระบบแจ้งซ่อมและการจัดการงานบำรุงรักษา (e-Repair & Task Dispatch)** โดยนำแนวคิดของ **Traffy Fondue** มาประยุกต์ใช้ เพื่อเพิ่มความสะดวก รวดเร็ว และโปร่งใสในการดำเนินงาน

### ปัญหาที่พบ

- การแจ้งซ่อมต้องอาศัยเอกสารหรือหลายช่องทาง ทำให้เกิดความล่าช้าและข้อมูลตกหล่น
- ลูกบ้านไม่สามารถติดตามสถานะงานซ่อมได้ว่าถึงขั้นตอนใดหรือช่างคนใดรับผิดชอบ
- นิติบุคคลขาดระบบกลางในการประเมิน Workload และแจกจ่ายงานให้ช่างอย่างมีประสิทธิภาพ
- การสื่อสารระหว่างลูกบ้าน ช่าง และนิติบุคคลไม่เชื่อมโยงกัน

### แนวทางแก้ไข

โครงงานนี้มีวัตถุประสงค์เพื่อพัฒนาระบบ **Smart Niti** ซึ่งเป็นแพลตฟอร์มบริหารจัดการที่อยู่อาศัยแบบครบวงจร โดยนำแนวคิดของระบบ **Traffy Fondue** มาประยุกต์ใช้ในกระบวนการแจ้งซ่อม เพื่อเพิ่มความสะดวก รวดเร็ว และสามารถตรวจสอบสถานะได้อย่างโปร่งใส พร้อมผสานแนวทางการดำเนินงานของธุรกิจด้านการบริหารจัดการอสังหาริมทรัพย์ เช่น Smart Service และ LPN

นอกจากนี้ ระบบถูกออกแบบโดยใช้สถาปัตยกรรมซอฟต์แวร์ที่มีความยืดหยุ่น สามารถรองรับการขยายตัวและการพัฒนาเพิ่มเติมในอนาคต เพื่อให้สอดคล้องกับการเติบโตของโครงการที่อยู่อาศัยและความต้องการของผู้ใช้งาน


---

## Feature

### ลูกบ้าน — Resident Mobile App

| ฟีเจอร์ | รายละเอียด |
|---------|-----------|
| **e-Repair** | แจ้งซ่อม ระบุตำแหน่ง และแนบรูปภาพประกอบได้อย่างรวดเร็ว |
| **Real-time Tracking** | ติดตามสถานะการดำเนินงานแบบ Real-time |
| **Review & Feedback** | ให้คะแนนความพึงพอใจเมื่อการซ่อมแซมเสร็จสิ้น |

### นิติบุคคลและช่าง — Admin Web Portal & Technician App

| ฟีเจอร์ | รายละเอียด |
|---------|-----------|
| **Dashboard** | สรุปภาพรวมงานซ่อมทั้งหมด แบ่งตามสถานะและหมวดหมู่ |
| **Task Assignment & Dispatch** | มองเห็น Workload ของช่างแต่ละคน และ Assign/Unassign งานได้อย่างมีประสิทธิภาพ |
| **Technician Task Management** | กดรับงาน อัปเดตสถานะ และดูรายละเอียดพร้อมรูปภาพได้ทันที |

---

## Deployed Applications

- [Resident (ลูกบ้าน) – Web Application](https://your-resident-app.vercel.app)

- [Technician (ช่าง) – Web Application](https://your-technician-app.vercel.app)

- [Juristic (นิติบุคคล) – Web Application](https://smart-niti-juristic.vercel.app)

---

## วิธีรันโปรเจกต์

> เปิด Terminal แยกตามโฟลเดอร์ของแต่ละแอปพลิเคชัน

```bash
git clone https://github.com/6610685353/niti-cn332.git
```

### Backend API (FastAPI)

```bash
cd smart_niti_app/
docker-compose up -d --build
```

ระบบจะทำงานที่ `http://localhost:8000`
สามารถดู API Document ได้ที่ `http://localhost:8000/docs`

### Resident App (ลูกบ้าน)

```bash
cd smart_niti_app/mobile_app
flutter pub get
flutter run
```

### Technician App (ช่าง)

```bash
cd smart_niti_app/technician_app
flutter pub get
flutter run
```

### Juristic Web App (นิติบุคคล)

```bash
cd smart_niti_app/juristic_app
flutter pub get
flutter run -d chrome
```


---

## Figma Design

- [Juristics (นิติบุคคล) – GUI Design](https://www.figma.com/proto/gkOWhsQL69FxR5yKzM1Lew/Smart-Niti?node-id=216-38&t=VBFV1Pgk1Pzm8ASV-1&starting-point-node-id=216%3A38)
- [Resident (ลูกบ้าน) – GUI Design](https://www.figma.com/proto/gkOWhsQL69FxR5yKzM1Lew/Smart-Niti?node-id=18-273&t=VBFV1Pgk1Pzm8ASV-1&starting-point-node-id=18%3A273)
- [Technician (ช่าง) – GUI Design](https://www.figma.com/proto/gkOWhsQL69FxR5yKzM1Lew/Smart-Niti?node-id=215-1131&t=VBFV1Pgk1Pzm8ASV-1&starting-point-node-id=215%3A1131)

---

## Live Demo Videos

- [Resident (ลูกบ้าน) – Video Presentation](https://drive.google.com/drive/folders/1z7impwBif7HZRWsYC_VMSHCZ1VWik6bP)

- [Technician (ช่าง) – Video Presentation](https://drive.google.com/file/d/1Nnr4fpn-csTD8xransCy42NKI4lnaGGQ/view?usp=drive_link)

- [Juristic (นิติบุคคล) – Video Presentation](https://drive.google.com/file/d/10gJiyqQ8gKgFf8Giu7AiGaH-sEo27X4V/view?usp=sharing)


---

## Presentation

Iteration 1: [Smart Niti Iteration 1 (Overview)](https://www.canva.com/design/DAG9j5cVbZM/s2VGLTmDyO-tVZuwIA3GKQ/view?utm_content=DAG9j5cVbZM&utm_campaign=designshare&utm_medium=link2&utm_source=uniquelinks&utlId=h6855267cc5)

Iteration 2: [Smart Niti Iteration 2 (OOAD)](https://www.canva.com/design/DAG-ZIxc_Ec/n5DSKT7VxDGbUFimRyXj2A/view?utm_content=DAG-ZIxc_Ec&utm_campaign=designshare&utm_medium=link2&utm_source=uniquelinks&utlId=h8e43ac45ba)

Iteration 3: [Smart Niti Iteration 3 (UML & Use Case Diagram)](https://www.canva.com/design/DAG-9YcwmlM/vXnmnIzaPboW5ytps6bGcg/edit?utm_content=DAG-9YcwmlM&utm_campaign=designshare&utm_medium=link2&utm_source=sharebutton)

Iteration 4: [Smart Niti Iteration 4 (GUI & CLI)](https://www.canva.com/design/DAG_6U_QGbM/5OUIlhVV47TdG_l52uNbGw/view?utm_content=DAG_6U_QGbM&utm_campaign=designshare&utm_medium=link2&utm_source=uniquelinks&utlId=h55eb72a5e0)

Iteration 5: [Smart Niti Iteration 5 (Mapping & Facade)](https://www.canva.com/design/DAHAV7eVrww/OvPVbpCJ1JZD_p6Y8md8mA/view?utm_content=DAHAV7eVrww&utm_campaign=designshare&utm_medium=link2&utm_source=uniquelinks&utlId=hfa68559e68)

Iteration 6: [Smart Niti Iteration 6 (Facade & Adapter Pattern)](https://www.canva.com/design/DAHA7fIy_Kk/Uz59xdVQxBhtIOsbQnOuYA/view?utm_content=DAHA7fIy_Kk&utm_campaign=designshare&utm_medium=link&utm_source=viewer)

Iteration 7: [Smart Niti Iteration 7 (Implement Plan)](https://www.canva.com/design/DAHDFrfeymw/zgIoPW6FiC3qV7l1JkCUzA/view?utm_content=DAHDFrfeymw&utm_campaign=designshare&utm_medium=link2&utm_source=uniquelinks&utlId=h3529507806)

Iteration 8: [Smart Niti Iteration 8 (Final Iteration)](https://canva.link/i74fbv76wpma8j8)

---

## ประวัติการนำเสนอ

- **12 มกราคม 2569**  
  - Smart Niti Iteration 1 (Overview)
  - Smart Niti Iteration 2 (OOAD)

- **30 มีนาคม 2569**
  - Smart Niti Iteration 3 (UML & Use Case Diagram)
  - Smart Niti Iteration 4 (GUI & CLI)
  - Smart Niti Iteration 5 (Mapping & Facade)
  - Smart Niti Iteration 6 (Facade & Adapter Pattern)
  - Smart Niti Iteration 7 (Implement Plan)
 
- **18 พฤกษภาคม 2569**
  - Smart Niti Iteration 8 (Final Iteration)
---
