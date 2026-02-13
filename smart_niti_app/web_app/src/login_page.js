import React, { useState } from "react";
import { auth, db } from "./firebase";
import { signInWithPopup, GoogleAuthProvider, FacebookAuthProvider, signInWithEmailAndPassword } from "firebase/auth";
import { doc, getDoc } from "firebase/firestore";

const LoginPage = () => {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  // ฟังก์ชันเช็คสิทธิ์หลังจากล็อคอินสำเร็จ
  const verifyAdmin = async (user) => {
    const docRef = doc(db, "users", user.email);
    const docSnap = await getDoc(docRef);

    if (docSnap.exists() && docSnap.data().role === "admin") {
      alert("Login Success: ยินดีต้อนรับนิติบุคคล");
      // window.location.href = "/admin-dashboard"; 
    } else {
      await auth.signOut();
      alert("ไม่มีสิทธิ์เข้าถึง: อีเมลนี้ไม่ใช่นิติบุคคล หรือยังไม่ได้ลงทะเบียน");
    }
  };

  const loginGoogle = () => signInWithPopup(auth, new GoogleAuthProvider()).then(res => verifyAdmin(res.user));
  const loginFB = () => signInWithPopup(auth, new FacebookAuthProvider()).then(res => verifyAdmin(res.user));
  const loginEmail = (e) => {
    e.preventDefault();
    signInWithEmailAndPassword(auth, email, password).then(res => verifyAdmin(res.user)).catch(err => alert("อีเมลหรือรหัสผ่านผิด"));
  };

  return (
    <div style={{ textAlign: 'center', marginTop: '50px' }}>
      <h2>Smart Niti (Web for Juristic)</h2>
      <form onSubmit={loginEmail}>
        <input type="email" placeholder="Email" onChange={e => setEmail(e.target.value)} /><br/>
        <input type="password" placeholder="Password" onChange={e => setPassword(e.target.value)} /><br/>
        <button type="submit">Login with Email</button>
      </form>
      <p>OR</p>
      <button onClick={loginGoogle} style={{background: '#dd4b39', color: 'white'}}>Google</button>
      <button onClick={loginFB} style={{background: '#3b5998', color: 'white'}}>Facebook</button>
    </div>
  );
};

export default LoginPage;