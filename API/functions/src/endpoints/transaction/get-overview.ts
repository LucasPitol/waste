import * as functions from "firebase-functions";
import { GetOverviewDataUseCase } from "../../use-cases/transactions/get-overview-data-use-case";

export const getOverviewPageData = functions.https.onRequest(async (req, res) => {
  try {
    const { walletId, startDate, endDate, userId } = req.body;

    if (!walletId || !startDate || !endDate || !userId) {
      res.status(400).send({ success: false, errorMsg: "Wallet ID, start date, end date, and user ID are required" });
      return;
    }

    const getOverviewDataUseCase = new GetOverviewDataUseCase();
    const result = await getOverviewDataUseCase.execute(
      walletId, 
      new Date(startDate), 
      new Date(endDate),
      userId
    );

    res.send(result);
  } catch (error) {
    console.error("Get overview data error:", error);
    res.status(500).send({ success: false, errorMsg: "Internal server error" });
  }
});
