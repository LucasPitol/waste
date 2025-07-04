import * as functions from "firebase-functions";
import { GetTransactionsUseCase } from "../../use-cases/transactions/get-transactions-use-case";

export const getTransactionsByWalletIdAndDateInterval = functions.https.onRequest(async (req, res) => {
  try {
    const { walletId, startDate, endDate, userId } = req.body;

    if (!walletId || !startDate || !endDate || !userId) {
      res.status(400).send({ success: false, errorMsg: "Wallet ID, start date, end date, and user ID are required" });
      return;
    }

    const getTransactionsUseCase = new GetTransactionsUseCase();
    const result = await getTransactionsUseCase.execute(
      walletId, 
      new Date(startDate), 
      new Date(endDate),
      userId
    );

    res.send(result);
  } catch (error) {
    console.error("Get transactions error:", error);
    res.status(500).send({ success: false, errorMsg: "Internal server error" });
  }
});
