import { WalletService } from "./services/wallet-service";
import { UserService } from "./services/user-service";
import { MockService } from "./services/mock-service";
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
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
const walletService = new WalletService()

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

export const loginByUid = functions.https.onRequest(async (req, res) => {

  var body = req.body

  var uid = body.uid

  var ret = await userService.logInByUidRes(uid)

  console.log(ret)
  res.send(ret)

});

// wallet
export const getUserWallets = functions.https.onRequest(async (req, res) => {

  var body = req.body

  var uid = body.uid

  var ret = await walletService.getWalletsByUserIdRes(uid)

  console.log(ret)
  res.send(ret)

});
