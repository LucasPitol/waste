import * as functions from "firebase-functions";
import { UserService } from "../../services/user-service";

export const loginByUid = functions.https.onRequest(async (req, res) => {
  try {
    const { uid } = req.body;

    if (!uid) {
      res.status(400).send({ success: false, errorMsg: "User ID is required" });
      return;
    }

    const userService = new UserService();
    const result = await userService.logInByUidRes(uid);

    res.send(result);
  } catch (error) {
    console.error("Login by UID error:", error);
    res.status(500).send({ success: false, errorMsg: "Internal server error" });
  }
});
