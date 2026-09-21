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

  const [currentPage, setCurrentPage] = useState(1);
  const pageSize = 10;

  const handleSearchTerm = (term: string) => {
    setSearchTerm(term);
    setCurrentPage(1);
  };

  const handleTypeFilter = (type: 'all' | 'Income' | 'Expense') => {
    setTypeFilter(type);
    setCurrentPage(1);
  };

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

  const totalCount = filtered.length;
  const totalPages = Math.max(1, Math.ceil(totalCount / pageSize));
  const validCurrentPage = Math.min(Math.max(1, currentPage), totalPages);

  const paginatedTransactions = useMemo(() => {
    const start = (validCurrentPage - 1) * pageSize;
    return filtered.slice(start, start + pageSize);
  }, [filtered, validCurrentPage, pageSize]);

  const goToPage = (page: number) => {
    setCurrentPage(Math.max(1, Math.min(page, totalPages)));
  };

  const nextPage = () => {
    setCurrentPage((p) => Math.min(p + 1, totalPages));
  };

  const prevPage = () => {
    setCurrentPage((p) => Math.max(p - 1, 1));
  };

  return {
    transactions: paginatedTransactions,
    allTransactions: filtered,
    totalCount,
    currentPage: validCurrentPage,
    pageSize,
    totalPages,
    goToPage,
    nextPage,
    prevPage,
    searchTerm,
    setSearchTerm: handleSearchTerm,
    typeFilter,
    setTypeFilter: handleTypeFilter,
    isLoading,
  };
};
