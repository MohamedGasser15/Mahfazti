import { useState, useEffect } from 'react';
import type { SupportTicket } from '../types';
import { supportService } from '../services/supportService';

export const useSupport = () => {
  const [tickets, setTickets] = useState<SupportTicket[]>([]);
  const [statusFilter, setStatusFilter] = useState<'all' | 'Open' | 'In Progress' | 'Resolved'>('all');
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    supportService.getTickets().then((res) => {
      setTickets(res);
      setIsLoading(false);
    });
  }, []);

  const updateStatus = async (ticketId: string, status: SupportTicket['status']) => {
    const updated = await supportService.updateStatus(ticketId, status);
    setTickets((prev) => prev.map((t) => (t.id === ticketId ? updated : t)));
  };

  const filtered = tickets.filter((t) => (statusFilter === 'all' ? true : t.status === statusFilter));

  return {
    tickets: filtered,
    statusFilter,
    setStatusFilter,
    updateStatus,
    isLoading,
  };
};
