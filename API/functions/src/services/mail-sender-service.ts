import { VerificationCodeType } from "../models/enums/enums";
import * as sgMail from "@sendgrid/mail";

export class MailSenderService {
  constructor() {}

  async sendVerificationCode(
    userMail: string,
    code: string,
    verificationCodeType: VerificationCodeType,
    expireDate: Date
  ) {
    const useMock = process.env.USE_SEND_GRID_MOCK == "true";

    if (!useMock) {
      const apiKey = process.env.SEND_GRID_API_KEY;

      if (apiKey) {
        sgMail.setApiKey(apiKey);

        const subject =
          verificationCodeType == VerificationCodeType.newUser
            ? "Bem vindo ao Meudin!"
            : "Meudin - Recuperação de senha";

        const html = this.getMailTemplateString(code, expireDate);

        const msg = {
          to: userMail,
          from: "app.meudin@gmail.com",
          subject: subject,
          html: html,
        };

        sgMail.send(msg).catch((error: any) => {
          console.error(error);
        });
      }
    }
  }

  getMailTemplateString(code: string, expireDate: Date) {
    const expireDateStr = expireDate.toISOString();

    return `<!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Verification Code</title>
        <style>
            /* Reset styles for email clients */
            body, table, td, div, p {
                margin: 0;
                padding: 0;
                font-family: Arial, sans-serif;
                line-height: 1.4;
            }
        </style>
    </head>
    <body style="background-color: #f4f4f4; margin: 0; padding: 20px;">
        <table role="presentation" style="width: 100%; max-width: 600px; margin: 0 auto; background-color: #ffffff; border-radius: 8px; overflow: hidden;">
            <tr>
                <td style="padding: 40px 20px; text-align: center; background-color: #AC6CFF;">
                    <h1 style="color: #ffffff; margin: 0; font-size: 24px;">Meudin</h1>
                </td>
            </tr>
            <tr>
                <td style="padding: 40px 20px;">
                    <p style="margin-bottom: 20px; color: #333333; font-size: 16px;">Ola!,</p>
                    <p style="margin-bottom: 20px; color: #333333; font-size: 16px;">Aqui esta seu codigo de verificação:</p>
                    <div style="background-color: #f8f8f8; padding: 20px; border-radius: 6px; text-align: center; margin-bottom: 20px;">
                        <span style="font-size: 32px; font-weight: bold; letter-spacing: 5px; color: #AC6CFF;">${code}</span>
                    </div>
                    <p style="margin-bottom: 20px; color: #333333; font-size: 16px;">Este código expira em ${expireDateStr}.</p>
                    <p style="color: #666666; font-size: 14px;">Por razões de seguraça, não compartilhe este código.</p>
                </td>
            </tr>
            <tr>
        </tr>
            <tr>
                <td style="padding: 20px; text-align: center; background-color: #f8f8f8; border-top: 1px solid #eeeeee;">
                    <p style="color: #666666; font-size: 12px;">This is an automated message, please do not reply.</p>
                </td>
            </tr>
        </table>
    </body>
    </html>`;
  }
}
