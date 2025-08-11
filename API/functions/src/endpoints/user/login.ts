import * as functions from "firebase-functions";
import * as jwt from "jsonwebtoken";
import { SignInUseCase } from "../../use-cases/user/sign-in-use-case";

const JWT_SECRET = process.env.JWT_SECRET || "your-secret-key";

export const logIn = functions.https.onRequest(async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      res
        .status(400)
        .send({ success: false, errorMsg: "Email and password are required" });
      return;
    }

    const signInUseCase = new SignInUseCase();
    const result = await signInUseCase.execute(email, password);

    if (result.success && result.data && result.data.id) {
      // Issue JWT token
      const token = jwt.sign({ userId: result.data.id }, JWT_SECRET, {
        expiresIn: "7d",
      });
      result.data.token = token;
      console.log(result);
      res.send(result);
    } else {
      res.send(result);
    }
  } catch (error) {
    console.error("Login error:", error);
    res.status(500).send({ success: false, errorMsg: "Internal server error" });
  }
});
