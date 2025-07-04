import * as functions from "firebase-functions";
import { UserSP } from "../db/sp/user-sp";

export const test = functions.https.onRequest(async (req, res) => {
  try {
    const { name, email, password } = req.body;

    if (!name || !email || !password) {
      res.status(400).send({ success: false, errorMsg: "Name, email and password are required" });
      return;
    }

    const userSp = new UserSP();
    const result = await userSp.createUser(name, email, password);

    console.log("Test result:", result);
    res.send({ success: true, data: result });
  } catch (error) {
    console.error("Test error:", error);
    res.status(500).send({ success: false, errorMsg: "Internal server error" });
  }
});
