import React, { useState, useEffect } from 'react';
import './App.css';
import LoginPage from './LoginPage'; // Import ไฟล์หน้า Login ที่เราเขียนไว้
import { auth } from './firebase'; // Import auth มาเพื่อเช็คสถานะการล็อคอิน
import { onAuthStateChanged, signOut } from 'firebase/auth';

function App() {
  const [user, setUser] = useState(null);

  // ตรวจสอบสถานะการล็อคอินตลอดเวลา
  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, (currentUser) => {
      setUser(currentUser);
    });
    return () => unsubscribe();
  }, []);

  const handleLogout = () => {
    signOut(auth);
  };

  return (
    <div className="App">
      {/* ถ้ายังไม่ได้ Login ให้แสดงหน้า LoginPage แต่ถ้า Login แล้วให้แสดงหน้า Dashboard */}
      {!user ? (
        <LoginPage />
      ) : (
        <div style={{ padding: "20px" }}>
          <h1>Smart Niti - Juristic Dashboard</h1>
          <p>ยินดีต้อนรับ: {user.email}</p>
          <p>สถานะ: Admin (นิติบุคคล)</p>
          <button onClick={handleLogout} style={{ backgroundColor: '#ff4444', color: 'white' }}>
            Logout
          </button>
          <hr />
        </div>
      )}
    </div>
  );
}

export default App;