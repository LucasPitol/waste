import * as functions from "firebase-functions";
import * as jwt from "jsonwebtoken";
import { UserService } from "../../services/user-service";

const JWT_SECRET = process.env.JWT_SECRET || "your-secret-key";

export const me = functions.https.onRequest(async (req, res) => {
  const authHeader = req.headers.authorization;
  if (!authHeader) {
    res.status(401).json({ error: "No token" });
    return;
  }
  const token = authHeader.replace("Bearer ", "");
  try {
    const payload: any = jwt.verify(token, JWT_SECRET);
    const userService = new UserService();
    const userRes = await userService.logInByUidRes(payload.userId);
    if (!userRes.success) {
      res.status(404).json({ error: "User not found" });
      return;
    }
    res.json({ user: userRes.data });
  } catch (err) {
    res.status(401).json({ error: "Invalid or expired token" });
  }
});
