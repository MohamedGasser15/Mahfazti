import { useState, useEffect, useMemo, useCallback } from 'react';
import type { UserItem } from '../types';
import { usersService, type CreateUserData, type UpdateUserData } from '../services/usersService';

export type UserStatusTab = 'all' | 'active' | 'inactive' | 'admins';
export type UserRoleFilter = 'all' | 'SuperAdmin' | 'Admin' | 'User';

export const useUsers = () => {
  const [users, setUsers] = useState<UserItem[]>([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [statusTab, setStatusTab] = useState<UserStatusTab>('all');
  const [roleFilter, setRoleFilter] = useState<UserRoleFilter>('all');
  const [selectedIds, setSelectedIds] = useState<string[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [currentPage, setCurrentPage] = useState(1);
  const pageSize = 8;

  useEffect(() => {
    let ignore = false;
    usersService.getUsers().then((res) => {
      if (!ignore) {
        setUsers(res);
        setIsLoading(false);
      }
    });
    return () => {
      ignore = true;
    };
  }, []);

  const refetch = useCallback(async () => {
    setIsLoading(true);
    try {
      const res = await usersService.getUsers();
      setUsers(res);
    } finally {
      setIsLoading(false);
    }
  }, []);

  // Overall Statistics (unaffected by filters)
  const stats = useMemo(() => {
    const total = users.length;
    const active = users.filter((u) => u.isActive).length;
    const inactive = total - active;
    const admins = users.filter((u) => u.role === 'SuperAdmin' || u.role === 'Admin').length;
    const verified = users.filter((u) => u.emailConfirmed).length;
    const activePercentage = total > 0 ? Math.round((active / total) * 100) : 0;

    return {
      total,
      active,
      inactive,
      admins,
      verified,
      activePercentage,
    };
  }, [users]);

  // Filtered Users
  const filteredUsers = useMemo(() => {
    return users.filter((u) => {
      // Search term
      const query = searchTerm.toLowerCase().trim();
      const matchesSearch =
        !query ||
        u.fullName.toLowerCase().includes(query) ||
        u.email.toLowerCase().includes(query) ||
        u.id.toLowerCase().includes(query) ||
        u.currency.toLowerCase().includes(query);

      // Status Tab
      let matchesTab = true;
      if (statusTab === 'active') {
        matchesTab = u.isActive;
      } else if (statusTab === 'inactive') {
        matchesTab = !u.isActive;
      } else if (statusTab === 'admins') {
        matchesTab = u.role === 'SuperAdmin' || u.role === 'Admin';
      }

      // Role Filter dropdown
      const matchesRole = roleFilter === 'all' ? true : u.role === roleFilter;

      return matchesSearch && matchesTab && matchesRole;
    });
  }, [users, searchTerm, statusTab, roleFilter]);

  // Pagination calculation
  const totalPages = Math.max(1, Math.ceil(filteredUsers.length / pageSize));

  // Reset pagination when filter criteria change
  const handleSetSearchTerm = (term: string) => {
    setSearchTerm(term);
    setCurrentPage(1);
    setSelectedIds([]);
  };

  const handleSetStatusTab = (tab: UserStatusTab) => {
    setStatusTab(tab);
    setCurrentPage(1);
    setSelectedIds([]);
  };

  const handleSetRoleFilter = (role: UserRoleFilter) => {
    setRoleFilter(role);
    setCurrentPage(1);
    setSelectedIds([]);
  };

  const paginatedUsers = useMemo(() => {
    const startIndex = (currentPage - 1) * pageSize;
    return filteredUsers.slice(startIndex, startIndex + pageSize);
  }, [filteredUsers, currentPage, pageSize]);

  // Selection handlers
  const toggleSelect = useCallback((userId: string) => {
    setSelectedIds((prev) =>
      prev.includes(userId) ? prev.filter((id) => id !== userId) : [...prev, userId]
    );
  }, []);

  const selectAll = useCallback(() => {
    const currentPageIds = paginatedUsers.map((u) => u.id);
    setSelectedIds((prev) => {
      const allCurrentSelected = currentPageIds.every((id) => prev.includes(id));
      if (allCurrentSelected) {
        return prev.filter((id) => !currentPageIds.includes(id));
      }
      return Array.from(new Set([...prev, ...currentPageIds]));
    });
  }, [paginatedUsers]);

  const clearSelection = useCallback(() => {
    setSelectedIds([]);
  }, []);

  const isAllSelected =
    paginatedUsers.length > 0 && paginatedUsers.every((u) => selectedIds.includes(u.id));

  // Mutation handlers
  const toggleStatus = async (userId: string) => {
    const updated = await usersService.toggleUserStatus(userId);
    setUsers((prev) => prev.map((u) => (u.id === userId ? updated : u)));
    return updated;
  };

  const bulkUpdateStatus = async (targetIds: string[], isActive: boolean) => {
    const updatedList = await usersService.bulkUpdateStatus(targetIds, isActive);
    setUsers(updatedList);
    setSelectedIds([]);
    return updatedList;
  };

  const updateUserRole = async (userId: string, role: 'SuperAdmin' | 'Admin' | 'User') => {
    const updated = await usersService.updateUserRole(userId, role);
    setUsers((prev) => prev.map((u) => (u.id === userId ? updated : u)));
    return updated;
  };

  const addUser = async (data: CreateUserData) => {
    const created = await usersService.addUser(data);
    setUsers((prev) => [created, ...prev]);
    return created;
  };

  const updateUser = async (userId: string, data: UpdateUserData) => {
    const updated = await usersService.updateUser(userId, data);
    setUsers((prev) => prev.map((u) => (u.id === userId ? updated : u)));
    return updated;
  };

  const goToPage = (page: number) => {
    setCurrentPage(Math.max(1, Math.min(page, totalPages)));
  };

  const nextPage = () => {
    setCurrentPage((prev) => Math.min(prev + 1, totalPages));
  };

  const prevPage = () => {
    setCurrentPage((prev) => Math.max(prev - 1, 1));
  };

  const deleteUser = async (userId: string) => {
    await usersService.deleteUser(userId);
    setUsers((prev) => prev.filter((u) => u.id !== userId));
    setSelectedIds((prev) => prev.filter((id) => id !== userId));
  };

  const bulkDeleteUsers = async (userIds: string[]) => {
    await usersService.bulkDeleteUsers(userIds);
    const set = new Set(userIds);
    setUsers((prev) => prev.filter((u) => !set.has(u.id)));
    setSelectedIds((prev) => prev.filter((id) => !set.has(id)));
  };

  return {
    users: filteredUsers,
    allUsers: users,
    paginatedUsers,
    stats,
    searchTerm,
    setSearchTerm: handleSetSearchTerm,
    statusTab,
    setStatusTab: handleSetStatusTab,
    roleFilter,
    setRoleFilter: handleSetRoleFilter,
    selectedIds,
    toggleSelect,
    selectAll,
    clearSelection,
    isAllSelected,
    currentPage,
    totalPages,
    pageSize,
    totalFilteredCount: filteredUsers.length,
    goToPage,
    nextPage,
    prevPage,
    toggleStatus,
    bulkUpdateStatus,
    updateUserRole,
    addUser,
    updateUser,
    deleteUser,
    bulkDeleteUsers,
    refetch,
    isLoading,
  };
};
