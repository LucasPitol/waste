import * as functions from "firebase-functions";
import { AddMemberToWalletUseCase } from "../../use-cases/wallet/add-member-to-wallet-use-case";

export const addMemberToWallet = functions.https.onRequest(async (req, res) => {
  try {
    const { memberMail, walletId, ownerId } = req.body;

    if (!memberMail || !walletId || !ownerId) {
      res.status(400).send({ success: false, errorMsg: "Member email, wallet ID, and owner ID are required" });
      return;
    }

    const addMemberToWalletUseCase = new AddMemberToWalletUseCase();
    const result = await addMemberToWalletUseCase.execute(memberMail, walletId, ownerId);

    res.send(result);
  } catch (error) {
    console.error("Add member error:", error);
    res.status(500).send({ success: false, errorMsg: "Internal server error" });
  }
});
