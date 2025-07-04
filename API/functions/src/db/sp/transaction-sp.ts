import { Transaction } from "../../models/transaction";
import { supabase } from "../supabase";
import { NewTransactionDto } from "../../models/dtos/new-transaction-dto";

export class TransactionSP {
  tableName = "transactions";

  async saveTransaction(newTransactionDto: NewTransactionDto) {
    // Validate required fields
    if (!newTransactionDto.userId) {
      throw new Error('User ID is required');
    }
    if (!newTransactionDto.walletId) {
      throw new Error('Wallet ID is required');
    }
    if (!newTransactionDto.type) {
      throw new Error('Transaction type is required');
    }
    if (typeof newTransactionDto.amount !== 'number') {
      throw new Error('Amount is required');
    }

    // Determine amount and type for storage
    let amount = Math.abs(newTransactionDto.amount!);
    let type = newTransactionDto.type;
    if (type === 'waste') {
      amount = amount * -1;
    }

    // Prepare object for insertion
    const insertObj: any = {
      user_id: newTransactionDto.userId,
      wallet_id: newTransactionDto.walletId,
      amount: amount,
      reason: newTransactionDto.reason,
      type: type === 'waste' ? 'expense' : 'income',
      transaction_date: newTransactionDto.transactionDate || new Date(),
      creation_date: new Date(),
    };
    if (type === 'waste' && newTransactionDto.categoryId) {
      insertObj.spending_category_id = newTransactionDto.categoryId;
    }

    // Insert transaction into database
    const { data, error } = await supabase
      .from(this.tableName)
      .insert(insertObj)
      .select("id")
      .single();

    if (error) {
      throw new Error(`Error saving transaction: ${error.message}`);
    }

    return data.id;
  }

  async getTransactionsByWalletIdAndDateInterval(
    walletId: string,
    startDate: Date,
    endDate: Date
  ): Promise<Transaction[]> {
    const { data, error } = await supabase
      .from("transactions")
      .select("*")
      .eq("wallet_id", walletId)
      .gte("transaction_date", startDate.toISOString())
      .lte("transaction_date", endDate.toISOString())
      .order("transaction_date", { ascending: false }); // DESCENDING order

    if (error) {
      throw new Error(`Error fetching transactions: ${error.message}`);
    }

    if (!data || data.length === 0) {
      return [];
    }

    return data.map((row) => new Transaction(row));
  }
}
