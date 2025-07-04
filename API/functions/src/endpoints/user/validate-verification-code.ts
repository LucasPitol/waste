import * as functions from "firebase-functions";
import { ValidateVerificationCodeUseCase } from "../../use-cases/user/validate-verification-code-use-case";

export const validateVerificationCode = functions.https.onRequest(async (req, res) => {
  try {
    const { userMail, verificationCode } = req.body;

    if (!userMail || !verificationCode) {
      res.status(400).send({ success: false, errorMsg: "User email and verification code are required" });
      return;
    }

    const validateVerificationCodeUseCase = new ValidateVerificationCodeUseCase();
    const result = await validateVerificationCodeUseCase.execute(userMail, verificationCode);

    res.send(result);
  } catch (error) {
    console.error("Validate verification code error:", error);
    res.status(500).send({ success: false, errorMsg: "Internal server error" });
  }
});
