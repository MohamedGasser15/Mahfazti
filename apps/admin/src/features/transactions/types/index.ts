export interface TransactionItem {
  id: string;
  userId: string;
  userEmail: string;
  walletName: string;
  amount: number;
  type: 'Income' | 'Expense';
  category: string;
  note?: string;
  createdAt: string;
}
