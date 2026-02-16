// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
import { getAuth } from "firebase/auth";
import { getFirestore } from "firebase/firestore";
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyA7Mr28C8JZQatxYQAM9a3esTBZiSUcUUI",
  authDomain: "smart-niti-e2de6.firebaseapp.com",
  projectId: "smart-niti-e2de6",
  storageBucket: "smart-niti-e2de6.firebasestorage.app",
  messagingSenderId: "825941701407",
  appId: "1:825941701407:web:53c95486893adedb97f62a",
  measurementId: "G-SYQ4EMSNQ7"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);
export const auth = getAuth(app);
export const db = getFirestore(app);