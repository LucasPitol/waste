import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { UserService } from "./services/user-service";
import { MockService } from "./services/mock-service";
admin.initializeApp();
export const db = admin.firestore()
// const cors = require('cors')({ origin: true });
const express = require('express');
const cors = require('cors');

const app = express();

// Automatically allow cross-origin requests
app.use(cors({ origin: true }));
const mockService = new MockService()
mockService.mockData()

const userService = new UserService()

// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//
// export const helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

// user
export const logIn = functions.https.onRequest(async (req, res) => {

  var body = req.body

  var email = body.email
  var password = body.password

  var ret = await userService.logInByEmailAndPasswordRes(email, password)

  console.log(ret)
  res.send(ret)

});

