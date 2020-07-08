import { Component, OnInit } from '@angular/core';
import * as firebase from 'firebase';

const firebaseConfig = {
  apiKey: "AIzaSyBd-XOJXkEMiFMi__ojGwNuqtFfgz4aJf0",
  authDomain: "waste-dev.firebaseapp.com",
  databaseURL: "https://waste-dev.firebaseio.com",
  projectId: "waste-dev",
  storageBucket: "waste-dev.appspot.com",
  messagingSenderId: "198796091575",
  appId: "1:198796091575:web:ec9d7037c5448755d8ad32"
};

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent implements OnInit {
  title = 'account-service-app';

  ngOnInit(): void {
    firebase.initializeApp(firebaseConfig);
  }
}
