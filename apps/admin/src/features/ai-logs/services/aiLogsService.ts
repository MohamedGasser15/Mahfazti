import type { AiLogItem } from '../types';

let mockLogs: AiLogItem[] = [
  {
    id: 'ai-1',
    userEmail: 'ahmed@example.com',
    rawText: 'صرفت ميتين وخمسين جنيه على السوبر ماركت',
    parsedAmount: 250.0,
    parsedCategory: 'Food & Dining',
    parsedType: 'Expense',
    isSuccess: true,
    confidenceScore: 0.98,
    durationMs: 420,
    createdAt: '2026-09-18T04:20:00Z',
  },
  {
    id: 'ai-2',
    userEmail: 'sarah@example.com',
    rawText: 'استلمت بونص الشغل خمس الاف جنيه',
    parsedAmount: 5000.0,
    parsedCategory: 'Salary',
    parsedType: 'Income',
    isSuccess: true,
    confidenceScore: 0.95,
    durationMs: 380,
    createdAt: '2026-09-18T02:11:00Z',
  },
  {
    id: 'ai-3',
    userEmail: 'omar@example.com',
    rawText: 'نزلت اشتريت حاجات غريبة مش فاكر بكام',
    isSuccess: false,
    confidenceScore: 0.2,
    errorMessage: 'Failed to extract valid numeric amount or category',
    durationMs: 510,
    createdAt: '2026-09-17T22:30:00Z',
  },
];

export const aiLogsService = {
  getLogs: async (): Promise<AiLogItem[]> => {
    return new Promise((resolve) => {
      setTimeout(() => resolve([...mockLogs]), 100);
    });
  },
};
