import * as functions from "firebase-functions";
import { CreateNewUserUseCase } from "../../use-cases/user/create-new-user-use-case";

export const createNewUser = functions.https.onRequest(async (req, res) => {
  try {
    const { newUserDto } = req.body;

    if (!newUserDto) {
      res.status(400).send({ success: false, errorMsg: "User data is required" });
      return;
    }

    const createUserUseCase = new CreateNewUserUseCase();
    const result = await createUserUseCase.execute(newUserDto);

    res.send(result);
  } catch (error) {
    console.error("Create user error:", error);
    res.status(500).send({ success: false, errorMsg: "Internal server error" });
  }
});
