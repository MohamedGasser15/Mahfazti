import type { TransactionItem } from '../types';

let mockTransactions: TransactionItem[] = [
  {
    id: 'tx-101',
    userId: 'u-1',
    userEmail: 'ahmed@example.com',
    walletName: 'Main Cash Wallet',
    amount: 1450.0,
    type: 'Expense',
    category: 'Shopping',
    note: 'Winter Clothes',
    createdAt: '2026-09-18T03:30:00Z',
  },
  {
    id: 'tx-102',
    userId: 'u-2',
    userEmail: 'sarah@example.com',
    walletName: 'CIB Bank Account',
    amount: 8500.0,
    type: 'Income',
    category: 'Salary',
    note: 'September Paycheck',
    createdAt: '2026-09-18T01:15:00Z',
  },
  {
    id: 'tx-103',
    userId: 'u-1',
    userEmail: 'ahmed@example.com',
    walletName: 'Main Cash Wallet',
    amount: 320.0,
    type: 'Expense',
    category: 'Food & Dining',
    note: 'Family Dinner',
    createdAt: '2026-09-17T21:40:00Z',
  },
  {
    id: 'tx-104',
    userId: 'u-3',
    userEmail: 'omar@example.com',
    walletName: 'Vodafone Cash',
    amount: 600.0,
    type: 'Expense',
    category: 'Bills & Utilities',
    note: 'Internet Bill',
    createdAt: '2026-09-17T18:10:00Z',
  },
];

export const transactionsService = {
  getTransactions: async (): Promise<TransactionItem[]> => {
    return new Promise((resolve) => {
      setTimeout(() => resolve([...mockTransactions]), 100);
    });
  },
};
