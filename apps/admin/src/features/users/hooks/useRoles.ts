import { useState, useEffect, useMemo, useCallback } from 'react';
import type {
  RoleDefinition,
  PermissionGroup,
  CreateRoleData,
  UpdateRoleData,
  RoleStats,
} from '../types';
import { rolesService } from '../services/rolesService';

export type RoleTabFilter = 'all' | 'system' | 'custom';

export const useRoles = () => {
  const [roles, setRoles] = useState<RoleDefinition[]>([]);
  const [permissionGroups, setPermissionGroups] = useState<PermissionGroup[]>([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [tabFilter, setTabFilter] = useState<RoleTabFilter>('all');
  const [currentPage, setCurrentPage] = useState(1);
  const [isLoading, setIsLoading] = useState(true);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const pageSize = 8;

  const loadData = useCallback(async () => {
    try {
      const [rolesData, permsData] = await Promise.all([
        rolesService.getRoles(),
        rolesService.getAvailablePermissions(),
      ]);
      setRoles(rolesData);
      setPermissionGroups(permsData);
    } finally {
      setIsLoading(false);
    }
  }, []);

  useEffect(() => {
    loadData();
  }, [loadData]);

  const refetch = useCallback(async () => {
    setIsLoading(true);
    await loadData();
  }, [loadData]);

  // Overall Statistics
  const stats = useMemo<RoleStats>(() => {
    const totalRoles = roles.length;
    const systemRolesCount = roles.filter((r) => r.isSystem).length;
    const customRolesCount = totalRoles - systemRolesCount;
    const assignedUsersCount = roles.reduce((acc, r) => acc + (r.usersCount || 0), 0);
    const allUniquePerms = new Set<string>();
    roles.forEach((r) => r.permissions?.forEach((p) => allUniquePerms.add(p)));

    return {
      totalRoles,
      systemRolesCount,
      customRolesCount,
      assignedUsersCount,
      totalPermissionsCount: allUniquePerms.size,
    };
  }, [roles]);

  // Instant In-Memory Filtering (0ms)
  const filteredRoles = useMemo(() => {
    const query = searchTerm.toLowerCase().trim();

    return roles.filter((role) => {
      // Tab filter
      if (tabFilter === 'system' && !role.isSystem) return false;
      if (tabFilter === 'custom' && role.isSystem) return false;

      // Search query
      if (query) {
        const matchesName = role.name.toLowerCase().includes(query);
        const matchesDesc = (role.description || '').toLowerCase().includes(query);
        const matchesPerms = role.permissions?.some((p) => p.toLowerCase().includes(query));
        if (!matchesName && !matchesDesc && !matchesPerms) {
          return false;
        }
      }

      return true;
    });
  }, [roles, tabFilter, searchTerm]);

  // Pagination calculations
  const totalCount = filteredRoles.length;
  const totalPages = Math.max(1, Math.ceil(totalCount / pageSize));
  const validCurrentPage = Math.min(Math.max(1, currentPage), totalPages);

  const paginatedRoles = useMemo(() => {
    const startIndex = (validCurrentPage - 1) * pageSize;
    return filteredRoles.slice(startIndex, startIndex + pageSize);
  }, [filteredRoles, validCurrentPage, pageSize]);

  // Filter handlers
  const handleSearchTerm = (term: string) => {
    setSearchTerm(term);
    setCurrentPage(1);
  };

  const handleTabFilter = (tab: RoleTabFilter) => {
    setTabFilter(tab);
    setCurrentPage(1);
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

  // Mutations
  const createRole = async (data: CreateRoleData): Promise<RoleDefinition> => {
    setIsSubmitting(true);
    try {
      const created = await rolesService.createRole(data);
      setRoles((prev) => [...prev, created]);
      return created;
    } finally {
      setIsSubmitting(false);
    }
  };

  const updateRole = async (
    id: number | string,
    data: UpdateRoleData
  ): Promise<RoleDefinition> => {
    setIsSubmitting(true);
    try {
      const updated = await rolesService.updateRole(id, data);
      setRoles((prev) => prev.map((r) => (String(r.id) === String(id) ? updated : r)));
      return updated;
    } finally {
      setIsSubmitting(false);
    }
  };

  const deleteRole = async (id: number | string): Promise<void> => {
    setIsSubmitting(true);
    try {
      await rolesService.deleteRole(id);
      setRoles((prev) => prev.filter((r) => String(r.id) !== String(id)));
    } finally {
      setIsSubmitting(false);
    }
  };

  return {
    roles: paginatedRoles,
    allRoles: roles,
    filteredRoles,
    permissionGroups,
    stats,
    searchTerm,
    setSearchTerm: handleSearchTerm,
    tabFilter,
    setTabFilter: handleTabFilter,
    currentPage: validCurrentPage,
    totalPages,
    totalCount,
    pageSize,
    goToPage,
    nextPage,
    prevPage,
    isLoading,
    isSubmitting,
    refetch,
    createRole,
    updateRole,
    deleteRole,
  };
};
