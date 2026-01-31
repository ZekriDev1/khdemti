// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyCRWwfL9pVT1-DGZVPKshcbBTwldZmVOac",
  authDomain: "khdemti-ma.firebaseapp.com",
  projectId: "khdemti-ma",
  storageBucket: "khdemti-ma.firebasestorage.app",
  messagingSenderId: "137053449392",
  appId: "1:137053449392:web:7502b4e79c308afe235f75",
  measurementId: "G-1L9WTDC4WB"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);
