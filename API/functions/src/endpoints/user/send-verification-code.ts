import * as functions from "firebase-functions";
import { SendVerificationCodeUseCase } from "../../use-cases/user/send-verification-code-use-case";

export const sendVerificationCode = functions.https.onRequest(async (req, res) => {
  try {
    const { userMail } = req.body;

    if (!userMail) {
      res.status(400).send({ success: false, errorMsg: "User email is required" });
      return;
    }

    const sendVerificationCodeUseCase = new SendVerificationCodeUseCase();
    const result = await sendVerificationCodeUseCase.execute(userMail);

    res.send(result);
  } catch (error) {
    console.error("Send verification code error:", error);
    res.status(500).send({ success: false, errorMsg: "Internal server error" });
  }
});
