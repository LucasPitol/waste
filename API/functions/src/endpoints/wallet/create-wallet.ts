import * as functions from "firebase-functions";
import { CreateWalletUseCase } from "../../use-cases/wallet/create-wallet-use-case";

export const createNewWallet = functions.https.onRequest(async (req, res) => {
  try {
    const { walletName, userId } = req.body;

    if (!walletName || !userId) {
      res.status(400).send({ success: false, errorMsg: "Wallet name and user ID are required" });
      return;
    }

    const createWalletUseCase = new CreateWalletUseCase();
    const result = await createWalletUseCase.execute(userId, walletName);

    res.send(result);
  } catch (error) {
    console.error("Create wallet error:", error);
    res.status(500).send({ success: false, errorMsg: "Internal server error" });
  }
});
