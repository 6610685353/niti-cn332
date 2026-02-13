// import React, { useState } from "react";
// import { auth, db } from "./firebase";
// import { signInWithPopup, GoogleAuthProvider, FacebookAuthProvider, signInWithEmailAndPassword } from "firebase/auth";
// import { doc, getDoc } from "firebase/firestore";

// const LoginPage = () => {
//   const [email, setEmail] = useState("");
//   const [password, setPassword] = useState("");

//   // ฟังก์ชันเช็คสิทธิ์หลังจากล็อคอินสำเร็จ
//   const verifyAdmin = async (user) => {
//   // 1. ตรวจสอบก่อนว่า user.email มีค่าหรือไม่
//   if (!user || !user.email) {
//     await auth.signOut();
//     alert("ไม่สามารถเข้าสู่ระบบได้ เนื่องจากบัญชีของคุณไม่มีข้อมูลอีเมลกรุณาตรวจสอบการตั้งค่า Facebook");
//     return; // หยุดการทำงานทันที
//   }

//   try {
//     // 2. เมื่อมั่นใจว่ามี email จึงค่อยเรียก doc()
//     const docRef = doc(db, "users", user.email);
//     const docSnap = await getDoc(docRef);

//     if (docSnap.exists() && docSnap.data().role === "admin") {
//       alert("Login Success: ยินดีต้อนรับนิติบุคคล");
//     } else {
//       await auth.signOut();
//       alert("ไม่มีสิทธิ์เข้าถึง: อีเมลนี้ไม่ใช่นิติบุคคล");
//     }
//   } catch (error) {
//     console.error("Firestore Error:", error);
//   }
// };

//   const loginGoogle = () => signInWithPopup(auth, new GoogleAuthProvider()).then(res => verifyAdmin(res.user));
//   const loginFB = () => signInWithPopup(auth, new FacebookAuthProvider()).then(res => verifyAdmin(res.user));
//   const loginEmail = (e) => {
//     e.preventDefault();
//     signInWithEmailAndPassword(auth, email, password).then(res => verifyAdmin(res.user)).catch(err => alert("อีเมลหรือรหัสผ่านผิด"));
//   };

//   return (
//     <div style={{ textAlign: 'center', marginTop: '50px' }}>
//       <h2>Smart Niti (Web for Juristic)</h2>
//       <form onSubmit={loginEmail}>
//         <input type="email" placeholder="Email" onChange={e => setEmail(e.target.value)} /><br/>
//         <input type="password" placeholder="Password" onChange={e => setPassword(e.target.value)} /><br/>
//         <button type="submit">Login with Email</button>
//       </form>
//       <p>OR</p>
//       <button onClick={loginGoogle} style={{background: '#dd4b39', color: 'white'}}>Google</button>
//       <button onClick={loginFB} style={{background: '#3b5998', color: 'white'}}>Facebook</button>
//     </div>
//   );
// };

// export default LoginPage;

// import React, { useState } from "react";
// import { auth, db } from "./firebase";
// import {
//   signInWithPopup,
//   GoogleAuthProvider,
//   FacebookAuthProvider,
//   signInWithEmailAndPassword
// } from "firebase/auth";
// import { doc, getDoc } from "firebase/firestore";

// const LoginPage = () => {
//   const [email, setEmail] = useState("");
//   const [password, setPassword] = useState("");

//   const verifyAdmin = async (user) => {
//     if (!user || !user.email) {
//       await auth.signOut();
//       alert("ไม่สามารถเข้าสู่ระบบได้ เนื่องจากบัญชีของคุณไม่มีข้อมูลอีเมล กรุณาตรวจสอบการตั้งค่า Facebook");
//       return;
//     }

//     try {
//       const docRef = doc(db, "users", user.email);
//       const docSnap = await getDoc(docRef);

//       if (docSnap.exists() && docSnap.data().role === "admin") {
//         alert("Login Success: ยินดีต้อนรับนิติบุคคล");
//       } else {
//         await auth.signOut();
//         alert("ไม่มีสิทธิ์เข้าถึง: อีเมลนี้ไม่ใช่นิติบุคคล");
//       }
//     } catch (error) {
//       console.error("Firestore Error:", error);
//     }
//   };

//   const loginGoogle = () => signInWithPopup(auth, new GoogleAuthProvider()).then(res => verifyAdmin(res.user));

//   // --- แก้ไขฟังก์ชัน Login Facebook ตรงนี้ ---
//   const loginFB = () => {
//     const provider = new FacebookAuthProvider();
//     provider.addScope('email'); // เพิ่มการขอสิทธิ์เข้าถึงอีเมล
    
//     signInWithPopup(auth, provider)
//       .then(res => {
//         console.log("Facebook User:", res.user); // ดูข้อมูลที่ได้ใน Console
//         verifyAdmin(res.user);
//       })
//       .catch(err => {
//         if (err.code === 'auth/account-exists-with-different-credential') {
//           alert("อีเมลนี้ถูกใช้งานแล้วด้วยช่องทางอื่น (เช่น Google) กรุณาเข้าสู่ระบบด้วยช่องทางเดิม");
//         } else {
//           console.error("FB Login Error:", err);
//         }
//       });
//   };
//   // ---------------------------------------

//   const loginEmail = (e) => {
//     e.preventDefault();
//     signInWithEmailAndPassword(auth, email, password)
//       .then(res => verifyAdmin(res.user))
//       .catch(err => alert("อีเมลหรือรหัสผ่านผิด"));
//   };

//   return (
//     <div style={{ textAlign: 'center', marginTop: '50px' }}>
//       <h2>Smart Niti (Web for Juristic)</h2>
//       <form onSubmit={loginEmail}>
//         <input type="email" placeholder="Email" onChange={e => setEmail(e.target.value)} style={{marginBottom: '5px'}} /><br/>
//         <input type="password" placeholder="Password" onChange={e => setPassword(e.target.value)} style={{marginBottom: '5px'}} /><br/>
//         <button type="submit">Login with Email</button>
//       </form>
//       <p>OR</p>
//       <button onClick={loginGoogle} style={{background: '#dd4b39', color: 'white', padding: '10px', marginRight: '5px', cursor: 'pointer'}}>Google</button>
//       <button onClick={loginFB} style={{background: '#3b5998', color: 'white', padding: '10px', cursor: 'pointer'}}>Facebook</button>
//     </div>
//   );
// };

// export default LoginPage;
import React, { useState } from "react";
import { auth, db } from "./firebase";
import { signInWithEmailAndPassword } from "firebase/auth";
import { doc, getDoc } from "firebase/firestore";

const LoginPage = () => {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);

  // ฟังก์ชันตรวจสอบสิทธิ์จาก Firestore หลังจาก Auth ผ่านแล้ว
  const verifyAdmin = async (user) => {
    try {
      const docRef = doc(db, "users", user.email);
      const docSnap = await getDoc(docRef);

      if (docSnap.exists() && docSnap.data().role === "admin") {
        alert("Login Success: ยินดีต้อนรับนิติบุคคล");
      } else {
        // หากไม่ใช่ admin หรือไม่พบข้อมูลใน Firestore ให้บังคับ Logout
        await auth.signOut();
        alert("ไม่มีสิทธิ์เข้าถึง: บัญชีนี้ไม่ได้รับอนุญาตให้เข้าใช้งานระบบนิติบุคคล");
      }
    } catch (error) {
      console.error("Firestore Error:", error);
      alert("เกิดข้อผิดพลาดในการตรวจสอบข้อมูลในระบบ");
    }
  };

  // ฟังก์ชันการล็อกอินหลัก
  const handleLogin = async (e) => {
    e.preventDefault();
    setLoading(true);

    try {
      // ขั้นตอนที่ 1: ตรวจสอบอีเมลและรหัสผ่านผ่าน Firebase Authentication
      const userCredential = await signInWithEmailAndPassword(auth, email, password);
      
      // ขั้นตอนที่ 2: ตรวจสอบบทบาท (Role) ใน Firestore ต่อทันที
      await verifyAdmin(userCredential.user);
    } catch (error) {
      console.error("Login Error:", error);
      // จัดการแจ้งเตือนตามประเภท Error
      if (error.code === 'auth/wrong-password' || error.code === 'auth/user-not-found') {
        alert("อีเมลหรือรหัสผ่านไม่ถูกต้อง");
      } else {
        alert("ไม่สามารถเข้าสู่ระบบได้ กรุณาลองใหม่อีกครั้ง");
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={styles.container}>
      <div style={styles.card}>
        <h2 style={styles.title}>Smart Niti</h2>
        <h4 style={styles.subtitle}>Juristic Admin Portal</h4>
        <p style={styles.desc}>เข้าสู่ระบบด้วยบัญชีเจ้าหน้าที่นิติบุคคล</p>
        
        <form onSubmit={handleLogin} style={styles.form}>
          <div style={styles.inputGroup}>
            <label style={styles.label}>Email Address</label>
            <input 
              type="email" 
              placeholder="example@gmail.com" 
              value={email}
              onChange={e => setEmail(e.target.value)} 
              style={styles.input}
              required
            />
          </div>
          
          <div style={styles.inputGroup}>
            <label style={styles.label}>Password</label>
            <input 
              type="password" 
              placeholder="••••••••" 
              value={password}
              onChange={e => setPassword(e.target.value)} 
              style={styles.input}
              required
            />
          </div>

          <button 
            type="submit" 
            disabled={loading} 
            style={loading ? {...styles.btn, opacity: 0.7} : styles.btn}
          >
            {loading ? "กำลังตรวจสอบข้อมูล..." : "Sign In"}
          </button>
        </form>
        
        <div style={styles.footer}>
          <small>© 2026 Smart Niti Platform</small>
        </div>
      </div>
    </div>
  );
};

// CSS-in-JS สำหรับหน้าจอ Admin
const styles = {
  container: { display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100vh', backgroundColor: '#f4f7f6', fontFamily: 'Arial, sans-serif' },
  card: { padding: '40px', backgroundColor: '#ffffff', borderRadius: '12px', boxShadow: '0 8px 24px rgba(0,0,0,0.1)', textAlign: 'center', width: '380px' },
  title: { margin: '0', color: '#2c3e50', fontSize: '28px', fontWeight: 'bold' },
  subtitle: { margin: '5px 0 20px', color: '#34495e', fontSize: '16px', textTransform: 'uppercase', letterSpacing: '1px' },
  desc: { color: '#7f8c8d', fontSize: '14px', marginBottom: '30px' },
  form: { textAlign: 'left' },
  inputGroup: { marginBottom: '20px' },
  label: { display: 'block', marginBottom: '8px', fontSize: '13px', color: '#2c3e50', fontWeight: 'bold' },
  input: { width: '100%', padding: '12px', borderRadius: '8px', border: '1px solid #dcdde1', boxSizing: 'border-box', outline: 'none', transition: 'border 0.3s' },
  btn: { width: '100%', padding: '14px', backgroundColor: '#2980b9', color: 'white', border: 'none', borderRadius: '8px', cursor: 'pointer', fontSize: '16px', fontWeight: 'bold', marginTop: '10px' },
  footer: { marginTop: '30px', color: '#bdc3c7' }
};

export default LoginPage;