import { useState, useEffect, useMemo } from 'react';
import type { TransactionItem } from '../types';
import { transactionsService } from '../services/transactionsService';

export const useTransactions = () => {
  const [transactions, setTransactions] = useState<TransactionItem[]>([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [typeFilter, setTypeFilter] = useState<'all' | 'Income' | 'Expense'>('all');
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    transactionsService.getTransactions().then((res) => {
      setTransactions(res);
      setIsLoading(false);
    });
  }, []);

  const filtered = useMemo(() => {
    return transactions.filter((tx) => {
      const matchesSearch =
        tx.userEmail.toLowerCase().includes(searchTerm.toLowerCase()) ||
        tx.category.toLowerCase().includes(searchTerm.toLowerCase()) ||
        (tx.note && tx.note.toLowerCase().includes(searchTerm.toLowerCase()));
      const matchesType = typeFilter === 'all' ? true : tx.type === typeFilter;
      return matchesSearch && matchesType;
    });
  }, [transactions, searchTerm, typeFilter]);

  return {
    transactions: filtered,
    searchTerm,
    setSearchTerm,
    typeFilter,
    setTypeFilter,
    isLoading,
  };
};
