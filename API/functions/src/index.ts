import { SpendingCategoryService } from "./services/spending-category-service";
import { TransactionService } from "./services/transaction-service";
import { WalletService } from "./services/wallet-service";
import { UserService } from "./services/user-service";
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { CreateNewUserUseCase } from "./use-cases/user/create-new-user-use-case";
import { SignInUseCase } from "./use-cases/user/sign-in-use-case";
import { SendVerificationCodeUseCase } from "./use-cases/user/send-verification-code-use-case";
admin.initializeApp();
export const db = admin.firestore()
// const cors = require('cors')({ origin: true });
const express = require('express');
const cors = require('cors');

const app = express();

// Automatically allow cross-origin requests
app.use(cors({ origin: true }));

const userService = new UserService()
const walletService = new WalletService()
const transactionService = new TransactionService()
const spendingCategoryService = new SpendingCategoryService()
const signInUseCase = new SignInUseCase();
const createUserUseCase = new CreateNewUserUseCase();
const sendVerificationCodeUseCase = new SendVerificationCodeUseCase();

// user
export const logIn = functions.https.onRequest(async (req, res) => {

  var body = req.body

  var email = body.email
  var password = body.password

  var ret = await signInUseCase.execute(email, password)

  res.send(ret)
});

export const createNewUser = functions.https.onRequest(async (req, res) => {

  var body = req.body
  var newUserDto = body.newUserDto

  var ret = await createUserUseCase.execute(newUserDto)

  res.send(ret)
});

export const sendVerificationCode = functions.https.onRequest(async (req, res) => {

  var body = req.body
  var userMail = body.userMail
  var verificationType = body.verificationType

  var ret = await sendVerificationCodeUseCase.execute(userMail, verificationType)

  res.send(ret)
});

export const changePassword = functions.https.onRequest(async (req, res) => {

  var body = req.body
  var uid = body.uid
  var password = body.password

  var ret = await userService.changePasswordRes(uid, password)

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

export const createNewWallet = functions.https.onRequest(async (req, res) => {

  var body = req.body

  var walletName = body.walletName
  var ownerId = body.userId

  var ret = await walletService.createNewWalletRes(ownerId, walletName)

  console.log(ret)
  res.send(ret)

});

export const removeMemberFromWallet = functions.https.onRequest(async (req, res) => {

  var body = req.body

  var memberId = body.memberId
  var walletId = body.walletId

  var ret = await walletService.removeMemberFromWalletRes(memberId, walletId)

  console.log(ret)
  res.send(ret)

});

// transactions
export const getTransactionsByWalletIdAndDateInterval = functions.https.onRequest(async (req, res) => {

  var body = req.body

  var walletId = body.walletId
  var startDate = new Date(body.startDate)
  var endDate = new Date(body.endDate)

  var ret = await transactionService.getTransactionsByWalletIdAndDateIntervalRes(walletId, startDate, endDate)

  console.log(ret)
  res.send(ret)

});

export const saveNewWaste = functions.https.onRequest(async (req, res) => {

  var body = req.body

  var newWasteDto = body.newWasteDto

  var ret = await transactionService.saveNewWasteRes(newWasteDto)

  res.send(ret)

});

export const saveNewRevenue = functions.https.onRequest(async (req, res) => {

  var body = req.body

  var newRevenueDto = body.newRevenueDto

  var ret = await transactionService.saveNewRevenueRes(newRevenueDto)

  res.send(ret)

});

export const getOverviewPageData = functions.https.onRequest(async (req, res) => {

  var body = req.body

  var walletId = body.walletId
  var startDate = new Date(body.startDate)
  var endDate = new Date(body.endDate)

  var ret = await transactionService.getOverviewPageDataRes(walletId, startDate, endDate)

  console.log(ret)
  res.send(ret)

});

export const getSpendingCategories = functions.https.onRequest(async (req, res) => {

  var ret = await spendingCategoryService.getSpendingCategoriesRes()

  console.log(ret)
  res.send(ret)

});

// members
export const getMembersByMemberIds = functions.https.onRequest(async (req, res) => {

  var body = req.body

  var memberIdList = body.memberIdList

  var ret = await userService.getWalletMembersRes(memberIdList)

  console.log(ret)
  res.send(ret)

});

export const addMemberToWallet = functions.https.onRequest(async (req, res) => {

  var body = req.body

  var memberMail = body.memberMail
  var walletId = body.walletId

  var ret = await userService.addMemberToWalletRes(memberMail, walletId)

  console.log(ret)
  res.send(ret)

});


//////////////// DEV ////////////////

// export const setUpDevData = functions.https.onRequest(async (req, res) => {

//   var body = req.body
//   var newUserDto = body.newUserDto

//   var ret = await userService.createNewUserRes(newUserDto)

//   console.log(ret)
//   res.send(ret)

// });
