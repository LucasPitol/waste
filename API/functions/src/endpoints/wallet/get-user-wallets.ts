import * as functions from "firebase-functions";
import { GetUserWalletsUseCase } from "../../use-cases/wallet/get-user-wallets-use-case";

export const getUserWallets = functions.https.onRequest(async (req, res) => {
  try {
    const { uid } = req.body;

    if (!uid) {
      res.status(400).send({ success: false, errorMsg: "User ID is required" });
      return;
    }

    const getUserWalletsUseCase = new GetUserWalletsUseCase();
    const result = await getUserWalletsUseCase.execute(uid);

    res.send(result);
  } catch (error) {
    console.error("Get user wallets error:", error);
    res.status(500).send({ success: false, errorMsg: "Internal server error" });
  }
});
