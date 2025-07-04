import * as functions from "firebase-functions";
import { SaveTransactionUseCase } from "../../use-cases/transactions/save-transaction-use-case";

export const saveTransaction = functions.https.onRequest(async (req, res) => {
  try {
    const { newTransactionDto } = req.body;

    if (!newTransactionDto) {
      res.status(400).send({ success: false, errorMsg: "Transaction data is required" });
      return;
    }

    const saveTransactionUseCase = new SaveTransactionUseCase();
    const result = await saveTransactionUseCase.execute(newTransactionDto);

    res.send(result);
  } catch (error) {
    console.error("Save transaction error:", error);
    res.status(500).send({ success: false, errorMsg: "Internal server error" });
  }
});
