import { Constants } from "../utils/constants";

const bcrypt = require('bcrypt');

export class EncryptionService {
  async hashString(userPassword: string): Promise<string> {
    const saltRound = Constants.saltRound
    return await bcrypt.hash(userPassword, saltRound);
  }

  async verifyPassword(plainPassword: string, hashedPassword: string): Promise<boolean> {
    return await bcrypt.compare(plainPassword, hashedPassword);
  }
}