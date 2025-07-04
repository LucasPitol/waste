import * as functions from "firebase-functions";
import { GetSpendingCategoriesUseCase } from "../use-cases/spending-categories/get-spending-categories-use-case";

export const getSpendingCategories = functions.https.onRequest(async (req, res) => {
  try {
    const getSpendingCategoriesUseCase = new GetSpendingCategoriesUseCase();
    const result = await getSpendingCategoriesUseCase.execute();

    res.send(result);
  } catch (error) {
    console.error("Get spending categories error:", error);
    res.status(500).send({ success: false, errorMsg: "Internal server error" });
  }
});
