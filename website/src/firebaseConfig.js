// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
import { getFirestore} from "firebase/firestore"
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyCuDaoZ9jKuYR92HOuuFckB3nUeQLZytBQ",
  authDomain: "enigma-52a13.firebaseapp.com",
  projectId: "enigma-52a13",
  storageBucket: "enigma-52a13.appspot.com",
  messagingSenderId: "223024396601",
  appId: "1:223024396601:web:814e0769945750284790e8",
  measurementId: "G-Q8YK7E6R21"
};

// Initialize Firebase
export const app = initializeApp(firebaseConfig);
export const analytics = getAnalytics(app);
export const database = getFirestore(app);