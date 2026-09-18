import { useState, useEffect } from 'react';
import type { UserItem } from '../types';
import { usersService } from '../services/usersService';

export const useUsers = () => {
  const [users, setUsers] = useState<UserItem[]>([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState<'all' | 'active' | 'inactive'>('all');
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    usersService.getUsers().then((res) => {
      setUsers(res);
      setIsLoading(false);
    });
  }, []);

  const toggleStatus = async (userId: string) => {
    const updated = await usersService.toggleUserStatus(userId);
    setUsers((prev) => prev.map((u) => (u.id === userId ? updated : u)));
  };

  const filteredUsers = users.filter((u) => {
    const matchesSearch =
      u.fullName.toLowerCase().includes(searchTerm.toLowerCase()) ||
      u.email.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesStatus =
      statusFilter === 'all'
        ? true
        : statusFilter === 'active'
        ? u.isActive
        : !u.isActive;
    return matchesSearch && matchesStatus;
  });

  return {
    users: filteredUsers,
    searchTerm,
    setSearchTerm,
    statusFilter,
    setStatusFilter,
    toggleStatus,
    isLoading,
  };
};
