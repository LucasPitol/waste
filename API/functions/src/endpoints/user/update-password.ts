import * as functions from "firebase-functions";
import { UpdatePasswordUseCase } from "../../use-cases/user/update-password";

export const updatePassword = functions.https.onRequest(async (req, res) => {
  try {
    const { userMail, newPassword } = req.body;

    if (!userMail || !newPassword) {
      res.status(400).send({ success: false, errorMsg: "User email and new password are required" });
      return;
    }

    const updatePasswordUseCase = new UpdatePasswordUseCase();
    const result = await updatePasswordUseCase.execute(userMail, newPassword);

    res.send(result);
  } catch (error) {
    console.error("Update password error:", error);
    res.status(500).send({ success: false, errorMsg: "Internal server error" });
  }
});
