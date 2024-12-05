export enum SubscriptionStatus {
  Inactive = "INACTIVE",
  PaymentPending = "PAYMENT_PENDING",
  Paid = "PAID",
}

export enum PlanCodes {
  beginnerMonthly = 'BEGINNER_MONTHLY',
  intermediaryMonthly = 'INTERMEDIARY_MONTHLY',
  advancedMonthly = 'ADVANCED_MONTHLY',
}

export enum VerificationCodeType {
  newUser = 'NEW_USER',
  changePassword = 'CHANGE_PASSWORD',
}

export enum BillingType {
  creditCard = 'CREDIT_CARD',
  pix = 'PIX',
  boleto = 'BOLETO',
  btc = 'BTC',
}