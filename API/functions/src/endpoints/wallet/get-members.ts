import * as functions from "firebase-functions";
import { GetWalletMembersUseCase } from "../../use-cases/wallet/get-wallet-members-use-case";

export const getMembersByMemberIds = functions.https.onRequest(async (req, res) => {
  try {
    const { walletId, requesterId } = req.body;

    if (!walletId || !requesterId) {
      res.status(400).send({ success: false, errorMsg: "Wallet ID and requester ID are required" });
      return;
    }

    const getWalletMembersUseCase = new GetWalletMembersUseCase();
    const result = await getWalletMembersUseCase.execute(walletId, requesterId);

    res.send(result);
  } catch (error) {
    console.error("Get members error:", error);
    res.status(500).send({ success: false, errorMsg: "Internal server error" });
  }
});
