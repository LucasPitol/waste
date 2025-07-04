import * as functions from "firebase-functions";
import { RemoveMemberFromWalletUseCase } from "../../use-cases/wallet/remove-member-from-wallet-use-case";

export const removeMemberFromWallet = functions.https.onRequest(async (req, res) => {
  try {
    const { memberId, walletId, ownerId } = req.body;

    if (!memberId || !walletId || !ownerId) {
      res.status(400).send({ success: false, errorMsg: "Member ID, wallet ID, and owner ID are required" });
      return;
    }

    const removeMemberFromWalletUseCase = new RemoveMemberFromWalletUseCase();
    const result = await removeMemberFromWalletUseCase.execute(memberId, walletId, ownerId);

    res.send(result);
  } catch (error) {
    console.error("Remove member error:", error);
    res.status(500).send({ success: false, errorMsg: "Internal server error" });
  }
});
