import * as functions from "firebase-functions";
import { SignInUseCase } from "../../use-cases/user/sign-in-use-case";

export const logIn = functions.https.onRequest(async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      res.status(400).send({ success: false, errorMsg: "Email and password are required" });
      return;
    }

    const signInUseCase = new SignInUseCase();
    const result = await signInUseCase.execute(email, password);

    res.send(result);
  } catch (error) {
    console.error("Login error:", error);
    res.status(500).send({ success: false, errorMsg: "Internal server error" });
  }
});
