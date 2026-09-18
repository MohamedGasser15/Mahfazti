export interface AiLogItem {
  id: string;
  userEmail: string;
  rawText: string;
  parsedAmount?: number;
  parsedCategory?: string;
  parsedType?: 'Income' | 'Expense';
  isSuccess: boolean;
  confidenceScore?: number;
  errorMessage?: string;
  durationMs: number;
  createdAt: string;
}
