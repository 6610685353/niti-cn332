# Smart Niti Web Application (CN332)



## 1. Overview (บทนำและที่มา)

### 1.1 Pain Points (ปัญหาที่พบ)

ในปัจจุบัน การบริหารจัดการหมู่บ้านจัดสรรและคอนโดมิเนียมยังคงประสบกับปัญหาหลายประการ อันเนื่องมาจากกระบวนการทำงานที่ล่าช้าและขาดความโปร่งใส โดยปัญหาที่พบบ่อยประกอบด้วย

- การแจ้งซ่อมแซมยังต้องอาศัยการกรอกเอกสารหรือแจ้งผ่านหลายช่องทาง ทำให้เกิดความล่าช้า
- ลูกบ้านไม่สามารถติดตามสถานะของงานซ่อมได้อย่างชัดเจน
- การจองพื้นที่ส่วนกลางมีความยุ่งยากและขาดระบบจัดการที่เป็นมาตรฐาน
- ลูกบ้านลืมชำระค่าส่วนกลาง ส่งผลให้ถูกระงับสิทธิ์การใช้งานโดยไม่รู้ตัว
- การสื่อสารระหว่างนิติบุคคลและลูกบ้านไม่ทั่วถึง เช่น ข่าวสารหรือประกาศสำคัญไม่ถูกส่งถึงทุกคน

ปัญหาเหล่านี้ส่งผลให้ลูกบ้านเกิดความไม่พึงพอใจ และในระยะยาวอาจลดทอนคุณค่าและภาพลักษณ์ของโครงการที่อยู่อาศัย

---

### 1.2 Solution (แนวทางแก้ไข)

โครงงานนี้มีวัตถุประสงค์เพื่อพัฒนาระบบ **Smart Niti** ซึ่งเป็นแพลตฟอร์มบริหารจัดการที่อยู่อาศัยแบบครบวงจร โดยนำแนวคิดของระบบ **Traffy Fondue** มาประยุกต์ใช้ในกระบวนการแจ้งซ่อม เพื่อเพิ่มความสะดวก รวดเร็ว และสามารถตรวจสอบสถานะได้อย่างโปร่งใส พร้อมผสานแนวทางการดำเนินงานของธุรกิจด้านการบริหารจัดการอสังหาริมทรัพย์ เช่น Smart Service และ LPN

ระบบ Smart Niti มุ่งเน้นการทำงานในลักษณะ **Proactive** โดยสามารถแจ้งเตือนลูกบ้านและนิติบุคคลก่อนเกิดปัญหา เช่น การแจ้งเตือนการชำระค่าส่วนกลาง หรือการบำรุงรักษาเชิงป้องกัน อีกทั้งยังให้ความสำคัญกับความโปร่งใสในการดำเนินงาน ผ่านการแสดงสถานะงานและประวัติการดำเนินการอย่างชัดเจน

นอกจากนี้ ระบบถูกออกแบบโดยใช้สถาปัตยกรรมซอฟต์แวร์ที่มีความยืดหยุ่น สามารถรองรับการขยายตัวและการพัฒนาเพิ่มเติมในอนาคต เพื่อให้สอดคล้องกับการเติบโตของโครงการที่อยู่อาศัยและความต้องการของผู้ใช้งาน

---

## 2. Features (ฟังก์ชันการทำงาน)

### 2.1 ส่วนลูกบ้าน  
*(Resident Mobile App / LINE OA)*

- **e-Repair**  
  แจ้งซ่อมพร้อมระบุตำแหน่งและแนบรูปภาพ สามารถติดตามสถานะการดำเนินงานได้แบบ Real-time

- **e-Payment**  
  ชำระค่าส่วนกลางและค่าน้ำผ่าน QR Payment หรือ Credit Card รองรับการตัดยอดอัตโนมัติ

- **Smart Parcel**  
  ระบบแจ้งเตือนเมื่อมีพัสดุเข้ามาถึงโครงการ

- **Reservation**  
  ระบบจองพื้นที่ส่วนกลาง เช่น ห้องประชุม ฟิตเนส หรือพื้นที่ส่วนรวมอื่น ๆ

---

### 2.2 ส่วนนิติบุคคลและช่าง  
*(Admin Web Portal & Staff App)*

- **Dashboard**  
  แสดงสรุปภาพรวมของงานซ่อม รายรับ-รายจ่าย และเรื่องร้องเรียนประจำวัน

- **Task Assignment**  
  ระบบมอบหมายงานให้ช่างและเจ้าหน้าที่รักษาความปลอดภัย

- **Asset Management**  
  ระบบจัดการทะเบียนทรัพย์สินส่วนกลาง พร้อมตารางการบำรุงรักษา

- **Announcements**  
  ระบบประกาศข่าวสารที่สามารถเลือกกลุ่มเป้าหมายได้  
  (เช่น ประกาศเฉพาะลูกบ้านอาคาร A)

---

## Figma Design

- [Juristics (นิติบุคคล) – GUI Design](https://www.figma.com/proto/gkOWhsQL69FxR5yKzM1Lew/Smart-Niti?node-id=216-38&t=VBFV1Pgk1Pzm8ASV-1&starting-point-node-id=216%3A38)
- [Resident (ลูกบ้าน) – GUI Design](https://www.figma.com/proto/gkOWhsQL69FxR5yKzM1Lew/Smart-Niti?node-id=18-273&t=VBFV1Pgk1Pzm8ASV-1&starting-point-node-id=18%3A273)
- [Technician (ช่าง) – GUI Design](https://www.figma.com/proto/gkOWhsQL69FxR5yKzM1Lew/Smart-Niti?node-id=215-1131&t=VBFV1Pgk1Pzm8ASV-1&starting-point-node-id=215%3A1131)

---

## Presentation

Iteration 1: [Smart Niti Iteration 1 (Overview)](https://www.canva.com/design/DAG9j5cVbZM/s2VGLTmDyO-tVZuwIA3GKQ/view?utm_content=DAG9j5cVbZM&utm_campaign=designshare&utm_medium=link2&utm_source=uniquelinks&utlId=h6855267cc5)

Iteration 2: [Smart Niti Iteration 2 (OOAD)](https://www.canva.com/design/DAG-ZIxc_Ec/n5DSKT7VxDGbUFimRyXj2A/view?utm_content=DAG-ZIxc_Ec&utm_campaign=designshare&utm_medium=link2&utm_source=uniquelinks&utlId=h8e43ac45ba)

Iteration 3: [Smart Niti Iteration 3 (UML & Use Case Diagram)](https://www.canva.com/design/DAG-9YcwmlM/vXnmnIzaPboW5ytps6bGcg/edit?utm_content=DAG-9YcwmlM&utm_campaign=designshare&utm_medium=link2&utm_source=sharebutton)

Iteration 4: [Smart Niti Iteration 4 (GUI & CLI)](https://www.canva.com/design/DAG_6U_QGbM/5OUIlhVV47TdG_l52uNbGw/view?utm_content=DAG_6U_QGbM&utm_campaign=designshare&utm_medium=link2&utm_source=uniquelinks&utlId=h55eb72a5e0)

Iteration 5: [Smart Niti Iteration 5 (Mapping & Facade)](https://www.canva.com/design/DAHAV7eVrww/OvPVbpCJ1JZD_p6Y8md8mA/view?utm_content=DAHAV7eVrww&utm_campaign=designshare&utm_medium=link2&utm_source=uniquelinks&utlId=hfa68559e68)

Iteration 6: [Smart Niti Iteration 6 (Facade & Adapter Pattern)](https://www.canva.com/design/DAHA7fIy_Kk/Uz59xdVQxBhtIOsbQnOuYA/view?utm_content=DAHA7fIy_Kk&utm_campaign=designshare&utm_medium=link&utm_source=viewer)

Iteration 7: [Smart Niti Iteration 7 (Implement Plan)](https://www.canva.com/design/DAHDFrfeymw/zgIoPW6FiC3qV7l1JkCUzA/view?utm_content=DAHDFrfeymw&utm_campaign=designshare&utm_medium=link2&utm_source=uniquelinks&utlId=h3529507806)

---

## Live Demo Videos

- [Resident (ลูกบ้าน) – Video Presentation](https://drive.google.com/drive/folders/1z7impwBif7HZRWsYC_VMSHCZ1VWik6bP)

- [Technician (ช่าง) – Video Presentation](https://drive.google.com/file/d/1Nnr4fpn-csTD8xransCy42NKI4lnaGGQ/view?usp=drive_link)

- [Juristic (นิติบุคคล) – Video Presentation](https://drive.google.com/file/d/10gJiyqQ8gKgFf8Giu7AiGaH-sEo27X4V/view?usp=sharing)

---

## Deployed Applications

- [Resident (ลูกบ้าน) – Web Application](https://your-resident-app.vercel.app)

- [Technician (ช่าง) – Web Application](https://your-technician-app.vercel.app)

- [Juristic (นิติบุคคล) – Web Application](https://smart-niti-juristic.vercel.app)

---

## Members

1. Thanawan Phongphaew (6610685171)  
2. Netchanok Yindee (6610685221)  
3. Punnawat Namkum (6610685247)  
4. Siranat Phimphicharn (6610685353)  
5. Ultimata Sangrungruang (6610685387)

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


