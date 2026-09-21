import React, { useState, useMemo } from 'react';
import {
  Search,
  X,
  UserPlus,
  RotateCcw,
  CheckCircle2,
  AlertCircle,
  Shield,
  Mail,
  Wallet,
  ChevronLeft,
  ChevronRight,
  Eye,
  Edit2,
  Trash2,
  Users,
  LayoutList,
  LayoutGrid,
} from 'lucide-react';
import { toast } from 'sonner';
import { useLocale } from '../../../core/context/LocaleContext';
import { useViewMode } from '../../../core/context/ViewModeContext';
import { useAuth } from '../../auth/context/AuthContext';
import { useUsers, type UserStatusTab, type UserRoleFilter } from '../hooks/useUsers';
import { Card } from '../../../core/components/ui/Card';
import { Badge } from '../../../core/components/ui/Badge';
import { Button } from '../../../core/components/ui/Button';
import { formatDate } from '../../../core/utils/formatters';
import type { UserItem } from '../types';
import { UserDetailsModal } from '../components/UserDetailsModal';
import { EditUserModal } from '../components/EditUserModal';
import { DeleteUserModal } from '../components/DeleteUserModal';
import { AddUserModal } from '../components/AddUserModal';
import { UserActionsMenu } from '../components/UserActionsMenu';
import { UsersTableSkeleton, UsersCardsSkeleton } from '../components/UsersSkeleton';
import { UsersKpiCards } from '../components/UsersKpiCards';
import { UsersBulkBar } from '../components/UsersBulkBar';

export const UsersPage: React.FC = () => {
  const { isAr, t } = useLocale();
  const { user: currentAdmin } = useAuth();

  const {
    allUsers,
    paginatedUsers,
    stats,
    searchTerm,
    setSearchTerm,
    statusTab,
    setStatusTab,
    roleFilter,
    setRoleFilter,
    selectedIds,
    toggleSelect,
    selectAll,
    clearSelection,
    isAllSelected,
    currentPage,
    totalPages,
    pageSize,
    totalFilteredCount,
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
  } = useUsers();

  const { viewMode, setViewMode } = useViewMode();
  const [selectedUserForDetails, setSelectedUserForDetails] = useState<UserItem | null>(null);
  const [selectedUserForEdit, setSelectedUserForEdit] = useState<UserItem | null>(null);
  const [usersToDelete, setUsersToDelete] = useState<UserItem[]>([]);
  const [isDeletingUser, setIsDeletingUser] = useState(false);
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);
  const [isBulkProcessing, setIsBulkProcessing] = useState(false);
  const [openActionMenuId, setOpenActionMenuId] = useState<string | null>(null);

  // Check if a target user is the currently logged in admin/user
  const isCurrentUser = (targetUser: UserItem) => {
    if (!currentAdmin) return false;
    const adminIdStr = String(currentAdmin.id).replace('u-', '');
    const targetIdStr = String(targetUser.id).replace('u-', '');
    return (
      adminIdStr === targetIdStr ||
      currentAdmin.email?.trim().toLowerCase() === targetUser.email.trim().toLowerCase()
    );
  };

  // Delete user(s) handler with permanent cascading feedback
  const handleConfirmDelete = async (userIds: string[]) => {
    setIsDeletingUser(true);
    try {
      if (userIds.length === 1) {
        await deleteUser(userIds[0]);
        toast.success(t.users.deleteModal.successSingle);
      } else {
        await bulkDeleteUsers(userIds);
        toast.success(`(${userIds.length}) ${t.users.deleteModal.successMultiple}`);
      }
      setUsersToDelete([]);
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : String(err);
      toast.error(msg || t.users.deleteModal.errorToast);
    } finally {
      setIsDeletingUser(false);
    }
  };

  // Selected users analysis for smart bulk actions
  const selectedUsers = useMemo(() => {
    const list = allUsers && allUsers.length > 0 ? allUsers : paginatedUsers;
    return list.filter((u) => selectedIds.includes(u.id));
  }, [allUsers, paginatedUsers, selectedIds]);

  const hasSuspendedSelected = selectedUsers.some((u) => !u.isActive);
  const hasActiveSelected = selectedUsers.some((u) => u.isActive);
  const activeSelectedCount = selectedUsers.filter((u) => u.isActive).length;
  const suspendedSelectedCount = selectedUsers.filter((u) => !u.isActive).length;

  // Single status toggle
  const handleToggleStatus = async (user: UserItem) => {
    try {
      await toggleStatus(user.id);
      toast.success(
        user.isActive
          ? `${t.users.toasts.userSuspended} (${user.fullName})`
          : `${t.users.toasts.userActivated} (${user.fullName})`
      );
      // update detail modal user reference if open
      if (selectedUserForDetails && selectedUserForDetails.id === user.id) {
        setSelectedUserForDetails((prev) => (prev ? { ...prev, isActive: !prev.isActive } : null));
      }
    } catch {
      toast.error(t.users.toasts.statusFailed);
    }
  };

  // Smart bulk actions: only targets users needing the action
  const handleBulkStatusChange = async (activate: boolean) => {
    const targetIds = selectedUsers
      .filter((u) => (activate ? !u.isActive : u.isActive))
      .map((u) => u.id);

    if (targetIds.length === 0) return;
    setIsBulkProcessing(true);
    try {
      await bulkUpdateStatus(targetIds, activate);
      toast.success(
        activate
          ? `${t.users.bulk.successActivated} (${targetIds.length})`
          : `${t.users.bulk.successSuspended} (${targetIds.length})`
      );
      clearSelection();
    } catch {
      toast.error(t.users.bulk.failed);
    } finally {
      setIsBulkProcessing(false);
    }
  };

  const handleRoleChange = async (userId: string, newRole: 'SuperAdmin' | 'Admin' | 'User') => {
    await updateUserRole(userId, newRole);
    if (selectedUserForDetails && selectedUserForDetails.id === userId) {
      setSelectedUserForDetails((prev) => (prev ? { ...prev, role: newRole } : null));
    }
  };

  const getRoleBadgeVariant = (role: string) => {
    switch (role) {
      case 'SuperAdmin':
        return 'purple';
      case 'Admin':
        return 'info';
      default:
        return 'default';
    }
  };

  const startRecord = totalFilteredCount === 0 ? 0 : (currentPage - 1) * pageSize + 1;
  const endRecord = Math.min(currentPage * pageSize, totalFilteredCount);

  return (
    <div className="space-y-6">
      {/* 1. Page Header */}
      <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <div className="flex items-center gap-2.5">
            <div className="flex h-10 w-10 items-center justify-center rounded-2xl bg-zinc-950 dark:bg-white text-white dark:text-zinc-950 font-bold shadow-xs">
              <Users className="h-5 w-5" />
            </div>
            <div>
              <h1 className="text-xl sm:text-2xl font-black tracking-tight text-zinc-950 dark:text-white">
                {t.users.pageTitle}
              </h1>
              <p className="text-xs text-zinc-500 dark:text-zinc-400 mt-0.5">
                {t.users.pageSubtitle}
              </p>
            </div>
          </div>
        </div>

        <div className="flex items-center gap-2">
          <Button
            type="button"
            variant="outline"
            size="sm"
            onClick={refetch}
            disabled={isLoading}
            className="font-bold border-zinc-200 dark:border-zinc-800 text-zinc-700 dark:text-zinc-300"
          >
            <RotateCcw className={`h-4 w-4 ${isLoading ? 'animate-spin' : ''} me-1.5`} />
            <span>{t.users.refresh}</span>
          </Button>

          <Button
            type="button"
            variant="primary"
            size="sm"
            onClick={() => setIsAddModalOpen(true)}
            className="font-bold shadow-xs"
          >
            <UserPlus className="h-4 w-4 me-1.5" />
            <span>{t.users.addNewUser}</span>
          </Button>
        </div>
      </div>

      {/* 2. Top KPI Metrics Summary Cards */}
      <UsersKpiCards
        stats={stats}
        isLoading={isLoading}
        hasUsers={allUsers.length > 0}
      />

      {/* 3. Filter Tabs & Search Bar */}
      <div className="space-y-3">
        {/* Status Tabs Bar */}
        <div className="flex items-center justify-between gap-2 overflow-x-auto pb-1">
          <div className="flex items-center gap-1.5 p-1 rounded-2xl bg-zinc-200/50 dark:bg-zinc-900 border border-zinc-200/80 dark:border-zinc-800">
            {(
              [
                { id: 'all', label: t.users.tabs.all, count: stats.total },
                { id: 'active', label: t.users.tabs.active, count: stats.active },
                { id: 'inactive', label: t.users.tabs.inactive, count: stats.inactive },
                { id: 'admins', label: t.users.tabs.admins, count: stats.admins },
              ] as const
            ).map((tab) => {
              const isActive = statusTab === tab.id;
              return (
                <button
                  key={tab.id}
                  type="button"
                  onClick={() => setStatusTab(tab.id as UserStatusTab)}
                  className={`flex items-center gap-2 px-3.5 py-1.5 rounded-xl text-xs font-bold transition-all ${
                    isActive
                      ? 'bg-zinc-950 dark:bg-white text-white dark:text-zinc-950 shadow-xs'
                      : 'text-zinc-600 dark:text-zinc-400 hover:text-zinc-950 dark:hover:text-white hover:bg-zinc-200/60 dark:hover:bg-zinc-800/60'
                  }`}
                >
                  <span>{tab.label}</span>
                  <span
                    className={`px-1.5 py-0.2 rounded-full text-[10px] font-mono ${
                      isActive
                        ? 'bg-zinc-800 dark:bg-zinc-200 text-zinc-100 dark:text-zinc-900'
                        : 'bg-zinc-300/60 dark:bg-zinc-800 text-zinc-600 dark:text-zinc-400'
                    }`}
                  >
                    {tab.count}
                  </span>
                </button>
              );
            })}
          </div>

          {/* View Mode Toggle (Table / Grid) */}
          <div className="flex items-center gap-1 p-1 rounded-2xl bg-zinc-200/50 dark:bg-zinc-900 border border-zinc-200/80 dark:border-zinc-800">
            <button
              type="button"
              onClick={() => setViewMode('table')}
              title={t.users.views.table}
              className={`p-1.5 rounded-xl text-xs transition-all ${
                viewMode === 'table'
                  ? 'bg-zinc-950 dark:bg-white text-white dark:text-zinc-950 shadow-xs'
                  : 'text-zinc-600 dark:text-zinc-400 hover:text-zinc-950 dark:hover:text-white'
              }`}
            >
              <LayoutList className="h-4 w-4" />
            </button>
            <button
              type="button"
              onClick={() => setViewMode('cards')}
              title={t.users.views.cards}
              className={`p-1.5 rounded-xl text-xs transition-all ${
                viewMode === 'cards'
                  ? 'bg-zinc-950 dark:bg-white text-white dark:text-zinc-950 shadow-xs'
                  : 'text-zinc-600 dark:text-zinc-400 hover:text-zinc-950 dark:hover:text-white'
              }`}
            >
              <LayoutGrid className="h-4 w-4" />
            </button>
          </div>
        </div>

        {/* Search & Role Filter Bar */}
        <Card className="flex flex-col sm:flex-row sm:items-center gap-3 p-3 bg-white dark:bg-[#121215] border-zinc-200 dark:border-zinc-800/80 shadow-2xs">
          <div className="relative flex-1">
            <Search className="absolute top-1/2 left-3.5 h-4 w-4 -translate-y-1/2 text-zinc-400 dark:text-zinc-500" />
            <input
              type="text"
              placeholder={t.users.searchPlaceholder}
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full rounded-xl border border-zinc-200 dark:border-zinc-800 bg-zinc-50 dark:bg-zinc-900/80 py-2 pr-9 pl-10 text-xs text-zinc-900 dark:text-white placeholder-zinc-400 dark:placeholder-zinc-500 focus:border-zinc-950 dark:focus:border-white focus:outline-none transition-colors"
            />
            {searchTerm && (
              <button
                type="button"
                onClick={() => setSearchTerm('')}
                className="absolute top-1/2 right-3 -translate-y-1/2 text-zinc-400 hover:text-zinc-600 dark:hover:text-zinc-200"
              >
                <X className="h-3.5 w-3.5" />
              </button>
            )}
          </div>

          <div className="flex items-center gap-2">
            <div className="flex items-center gap-2">
              <span className="text-xs font-semibold text-zinc-500 dark:text-zinc-400 whitespace-nowrap">
                {t.users.roleFilterLabel}
              </span>
              <select
                value={roleFilter}
                onChange={(e) => setRoleFilter(e.target.value as UserRoleFilter)}
                className="rounded-xl border border-zinc-200 dark:border-zinc-800 bg-zinc-50 dark:bg-zinc-900/80 px-3 py-2 text-xs font-bold text-zinc-900 dark:text-white focus:border-zinc-950 dark:focus:border-white focus:outline-none cursor-pointer"
              >
                <option value="all">{t.users.allRoles}</option>
                <option value="User">{t.users.roles.user}</option>
                <option value="Admin">{t.users.roles.admin}</option>
                <option value="SuperAdmin">{t.users.roles.superAdmin}</option>
              </select>
            </div>
          </div>
        </Card>
      </div>

      {/* 4. Content Area: Table View or Cards View */}
      {isLoading ? (
        viewMode === 'table' ? (
          <UsersTableSkeleton count={pageSize} />
        ) : (
          <UsersCardsSkeleton count={pageSize} />
        )
      ) : paginatedUsers.length === 0 ? (
        <Card className="p-12 text-center bg-white dark:bg-[#121215] border-zinc-200 dark:border-zinc-800 space-y-3">
          <div className="mx-auto flex h-12 w-12 items-center justify-center rounded-2xl bg-zinc-100 dark:bg-zinc-800 text-zinc-400">
            <Users className="h-6 w-6" />
          </div>
          <h3 className="text-sm font-bold text-zinc-950 dark:text-white">
            {t.users.emptyState.title}
          </h3>
          <p className="text-xs text-zinc-500 dark:text-zinc-400 max-w-sm mx-auto">
            {t.users.emptyState.description}
          </p>
          {(searchTerm || statusTab !== 'all' || roleFilter !== 'all') && (
            <Button
              type="button"
              variant="outline"
              size="sm"
              onClick={() => {
                setSearchTerm('');
                setStatusTab('all');
                setRoleFilter('all');
              }}
              className="mt-2 text-xs font-bold"
            >
              {t.users.emptyState.resetFilters}
            </Button>
          )}
        </Card>
      ) : viewMode === 'table' ? (
        /* TABLE VIEW */
        <Card className="p-0 overflow-hidden bg-white dark:bg-[#121215] border-zinc-200 dark:border-zinc-800/80 shadow-2xs min-h-[380px]">
          <div className="overflow-x-auto">
            <table className="w-full text-left rtl:text-right text-xs">
              <thead className="border-b border-zinc-200 dark:border-zinc-800 bg-zinc-50/80 dark:bg-zinc-900/50 text-[11px] font-bold uppercase tracking-wider text-zinc-500 dark:text-zinc-400">
                <tr>
                  <th className="py-3.5 px-4 w-10 text-center">
                    <input
                      type="checkbox"
                      checked={isAllSelected}
                      onChange={selectAll}
                      className="h-4 w-4 rounded-md border-zinc-300 text-zinc-950 focus:ring-zinc-950 cursor-pointer"
                    />
                  </th>
                  <th className="py-3.5 px-4">{t.users.table.user}</th>
                  <th className="py-3.5 px-4">{t.users.table.role}</th>
                  <th className="py-3.5 px-4">{t.users.table.currencyWallets}</th>
                  <th className="py-3.5 px-4">{t.users.table.emailStatus}</th>
                  <th className="py-3.5 px-4">{t.users.table.status}</th>
                  <th className="py-3.5 px-4">{t.users.table.joined}</th>
                  <th className="py-3.5 px-4 text-center">{t.users.table.actions}</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-zinc-200/70 dark:divide-zinc-800/60 text-zinc-700 dark:text-zinc-300">
                {paginatedUsers.map((user, index) => {
                  const isSelected = selectedIds.includes(user.id);
                  return (
                    <tr
                      key={user.id}
                      className={`hover:bg-zinc-50/80 dark:hover:bg-zinc-800/40 transition-colors ${
                        isSelected ? 'bg-zinc-50 dark:bg-zinc-900/60' : ''
                      }`}
                    >
                      <td className="py-3 px-4 text-center">
                        <input
                          type="checkbox"
                          checked={isSelected}
                          onChange={() => toggleSelect(user.id)}
                          className="h-4 w-4 rounded-md border-zinc-300 text-zinc-950 focus:ring-zinc-950 cursor-pointer"
                        />
                      </td>

                      {/* User Avatar & Info */}
                      <td className="py-3 px-4">
                        <div className="flex items-center gap-3">
                          <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-xl bg-zinc-900 dark:bg-zinc-800 text-white font-bold text-xs shadow-2xs">
                            {user.fullName.charAt(0).toUpperCase()}
                          </div>
                          <div>
                            <button
                              type="button"
                              onClick={() => setSelectedUserForDetails(user)}
                              className="font-bold text-zinc-950 dark:text-white hover:underline text-start"
                            >
                              {user.fullName}
                            </button>
                            <div className="text-[11px] text-zinc-500 dark:text-zinc-400 flex items-center gap-1 font-mono">
                              <Mail className="h-3 w-3 shrink-0" />
                              <span className="truncate max-w-[170px]">{user.email}</span>
                            </div>
                          </div>
                        </div>
                      </td>

                      {/* Role */}
                      <td className="py-3 px-4">
                        <Badge
                          variant={getRoleBadgeVariant(user.role)}
                          className="text-[11px] font-semibold gap-1"
                        >
                          {user.role === 'SuperAdmin' && <Shield className="h-3 w-3" />}
                          {user.role}
                        </Badge>
                      </td>

                      {/* Currency & Wallets */}
                      <td className="py-3 px-4">
                        <div className="flex items-center gap-2">
                          <span className="font-mono text-xs font-bold text-zinc-800 dark:text-zinc-200">
                            {user.currency}
                          </span>
                          <span className="text-zinc-300 dark:text-zinc-700">&bull;</span>
                          <span className="inline-flex items-center gap-1 text-[11px] text-zinc-500 dark:text-zinc-400">
                            <Wallet className="h-3 w-3 text-blue-500" />
                            {user.walletsCount} {t.users.table.walletsCount}
                          </span>
                        </div>
                      </td>

                      {/* Email Status */}
                      <td className="py-3 px-4">
                        {user.emailConfirmed ? (
                          <span className="inline-flex items-center gap-1 text-[11px] font-bold text-emerald-600 dark:text-emerald-400">
                            <CheckCircle2 className="h-3.5 w-3.5" />
                            {t.users.table.verified}
                          </span>
                        ) : (
                          <span className="inline-flex items-center gap-1 text-[11px] font-bold text-amber-600 dark:text-amber-400">
                            <AlertCircle className="h-3.5 w-3.5" />
                            {t.users.table.unverified}
                          </span>
                        )}
                      </td>

                      {/* Status */}
                      <td className="py-3 px-4">
                        <Badge variant={user.isActive ? 'success' : 'danger'} className="text-[11px] font-bold">
                          {user.isActive ? t.users.table.active : t.users.table.suspended}
                        </Badge>
                      </td>

                      {/* Joined Date */}
                      <td className="py-3 px-4 text-zinc-500 dark:text-zinc-400 text-[11px]">
                        {formatDate(user.createdAt)}
                      </td>

                      {/* Actions: Quick View + Quick Edit + Quick Delete + 3-Dots Menu */}
                      <td className="py-3 px-4 text-center">
                        <div className="flex items-center justify-center gap-1">
                          <button
                            type="button"
                            onClick={() => setSelectedUserForDetails(user)}
                            title={t.users.actionsMenu.viewDetails}
                            className="flex h-8 w-8 items-center justify-center rounded-xl border border-zinc-200 dark:border-zinc-800 bg-zinc-50 hover:bg-zinc-100 dark:bg-zinc-900 dark:hover:bg-zinc-800 text-zinc-600 dark:text-zinc-400 hover:text-zinc-950 dark:hover:text-white transition-colors"
                          >
                            <Eye className="h-4 w-4" />
                          </button>

                          <button
                            type="button"
                            onClick={() => setSelectedUserForEdit(user)}
                            title={t.users.actionsMenu.editProfile}
                            className="flex h-8 w-8 items-center justify-center rounded-xl border border-zinc-200 dark:border-zinc-800 bg-zinc-50 hover:bg-zinc-100 dark:bg-zinc-900 dark:hover:bg-zinc-800 text-zinc-600 dark:text-zinc-400 hover:text-zinc-950 dark:hover:text-white transition-colors"
                          >
                            <Edit2 className="h-4 w-4" />
                          </button>

                          <button
                            type="button"
                            disabled={isCurrentUser(user)}
                            onClick={() => {
                              if (isCurrentUser(user)) return;
                              setUsersToDelete([user]);
                            }}
                            title={
                              isCurrentUser(user)
                                ? t.users.actionsMenu.protectedAccountTooltip
                                : t.users.actionsMenu.deleteAccount
                            }
                            className={`flex h-8 w-8 items-center justify-center rounded-xl border transition-colors ${
                              isCurrentUser(user)
                                ? 'border-zinc-200/50 dark:border-zinc-800/50 opacity-30 cursor-not-allowed text-zinc-400'
                                : 'border-zinc-200 dark:border-zinc-800 bg-zinc-50 hover:bg-rose-50 dark:bg-zinc-900 dark:hover:bg-rose-950/40 text-zinc-600 hover:text-rose-600 dark:text-zinc-400 dark:hover:text-rose-400'
                            }`}
                          >
                            <Trash2 className="h-4 w-4" />
                          </button>

                          <UserActionsMenu
                            user={user}
                            isOpen={openActionMenuId === user.id}
                            onToggle={() =>
                              setOpenActionMenuId(openActionMenuId === user.id ? null : user.id)
                            }
                            onClose={() => setOpenActionMenuId(null)}
                            onViewDetails={() => setSelectedUserForDetails(user)}
                            onEditUser={() => setSelectedUserForEdit(user)}
                            onDeleteUser={() => setUsersToDelete([user])}
                            onToggleStatus={() => handleToggleStatus(user)}
                            onChangeRole={(role) => handleRoleChange(user.id, role)}
                            isCurrentUser={isCurrentUser(user)}
                            isNearBottom={index >= paginatedUsers.length - 2}
                          />
                        </div>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        </Card>
      ) : (
        /* CARDS VIEW */
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
          {paginatedUsers.map((user) => {
            const isSelected = selectedIds.includes(user.id);
            return (
              <Card
                key={user.id}
                className={`p-4 relative transition-all bg-white dark:bg-[#121215] border flex flex-col justify-between space-y-4 shadow-2xs ${
                  isSelected
                    ? 'border-zinc-950 dark:border-white ring-2 ring-zinc-950/10 dark:ring-white/10'
                    : 'border-zinc-200 dark:border-zinc-800'
                }`}
              >
                {/* Checkbox top-right / top-left */}
                <div className="absolute top-3.5 ltr:right-3.5 rtl:left-3.5">
                  <input
                    type="checkbox"
                    checked={isSelected}
                    onChange={() => toggleSelect(user.id)}
                    className="h-4 w-4 rounded-md border-zinc-300 text-zinc-950 focus:ring-zinc-950 cursor-pointer"
                  />
                </div>

                {/* Profile Header */}
                <div className="flex items-start gap-3">
                  <div className="relative flex h-12 w-12 shrink-0 items-center justify-center rounded-2xl bg-zinc-950 dark:bg-zinc-800 text-white font-bold text-base shadow-xs">
                    {user.fullName.charAt(0).toUpperCase()}
                    <span
                      className={`absolute -bottom-0.5 -right-0.5 h-3.5 w-3.5 rounded-full border-2 border-white dark:border-zinc-900 ${
                        user.isActive ? 'bg-emerald-500' : 'bg-rose-500'
                      }`}
                    />
                  </div>
                  <div className="min-w-0 pr-5 rtl:pr-0 rtl:pl-5">
                    <button
                      type="button"
                      onClick={() => setSelectedUserForDetails(user)}
                      className="text-sm font-bold text-zinc-950 dark:text-white hover:underline truncate block max-w-[150px] text-start"
                    >
                      {user.fullName}
                    </button>
                    <p className="text-[11px] text-zinc-500 dark:text-zinc-400 font-mono truncate max-w-[160px]">
                      {user.email}
                    </p>
                    <div className="mt-1.5 flex items-center gap-1.5">
                      <Badge
                        variant={getRoleBadgeVariant(user.role)}
                        className="text-[10px] py-0 px-1.5 font-semibold"
                      >
                        {user.role}
                      </Badge>
                    </div>
                  </div>
                </div>

                {/* Card Meta Stats */}
                <div className="p-2.5 rounded-xl bg-zinc-50/80 dark:bg-zinc-900/60 border border-zinc-200/80 dark:border-zinc-800 grid grid-cols-2 gap-2 text-[11px]">
                  <div>
                    <span className="text-zinc-400 dark:text-zinc-500 block text-[10px]">
                      {t.users.cards.walletsAndCurrency}
                    </span>
                    <span className="font-bold text-zinc-800 dark:text-zinc-200">
                      {user.walletsCount} &bull; {user.currency}
                    </span>
                  </div>
                  <div>
                    <span className="text-zinc-400 dark:text-zinc-500 block text-[10px]">
                      {t.users.cards.email}
                    </span>
                    <span
                      className={`font-bold ${
                        user.emailConfirmed
                          ? 'text-emerald-600 dark:text-emerald-400'
                          : 'text-amber-600 dark:text-amber-400'
                      }`}
                    >
                      {user.emailConfirmed ? t.users.table.verified : t.users.table.unverified}
                    </span>
                  </div>
                </div>

                {/* Action Buttons */}
                <div className="flex items-center gap-1.5 pt-1 border-t border-zinc-100 dark:border-zinc-800/80">
                  <Button
                    type="button"
                    variant="outline"
                    size="sm"
                    onClick={() => setSelectedUserForDetails(user)}
                    className="flex-1 text-xs font-bold"
                  >
                    <Eye className="h-3.5 w-3.5 me-1" />
                    <span>{t.users.cards.view}</span>
                  </Button>

                  <Button
                    type="button"
                    variant="outline"
                    size="sm"
                    onClick={() => setSelectedUserForEdit(user)}
                    className="flex-1 text-xs font-bold"
                  >
                    <Edit2 className="h-3.5 w-3.5 me-1" />
                    <span>{t.users.cards.edit}</span>
                  </Button>

                  <UserActionsMenu
                    user={user}
                    isOpen={openActionMenuId === `card-${user.id}`}
                    onToggle={() =>
                      setOpenActionMenuId(
                        openActionMenuId === `card-${user.id}` ? null : `card-${user.id}`
                      )
                    }
                    onClose={() => setOpenActionMenuId(null)}
                    onViewDetails={() => setSelectedUserForDetails(user)}
                    onEditUser={() => setSelectedUserForEdit(user)}
                    onDeleteUser={() => setUsersToDelete([user])}
                    onToggleStatus={() => handleToggleStatus(user)}
                    onChangeRole={(role) => handleRoleChange(user.id, role)}
                    isCurrentUser={isCurrentUser(user)}
                    isNearBottom={true}
                  />
                </div>
              </Card>
            );
          })}
        </div>
      )}

      {/* 5. Pagination Toolbar */}
      {!isLoading && totalFilteredCount > 0 && (
        <Card className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3 p-3.5 bg-white dark:bg-[#121215] border-zinc-200 dark:border-zinc-800/80 shadow-2xs">
          <p className="text-xs text-zinc-500 dark:text-zinc-400 text-center sm:text-start">
            {t.users.pagination.showing}{' '}
            <strong className="text-zinc-900 dark:text-white font-mono">{startRecord}</strong>{' '}
            {t.users.pagination.to}{' '}
            <strong className="text-zinc-900 dark:text-white font-mono">{endRecord}</strong>{' '}
            {t.users.pagination.of}{' '}
            <strong className="text-zinc-900 dark:text-white font-mono">{totalFilteredCount}</strong>{' '}
            {t.users.pagination.users}
          </p>

          <div className="flex items-center justify-center gap-1.5">
            <Button
              type="button"
              variant="outline"
              size="sm"
              onClick={prevPage}
              disabled={currentPage === 1}
              className="text-xs font-bold px-2.5"
            >
              {isAr ? <ChevronRight className="h-4 w-4" /> : <ChevronLeft className="h-4 w-4" />}
              <span className="ms-1">{t.users.pagination.prev}</span>
            </Button>

            <div className="flex items-center gap-1">
              {Array.from({ length: totalPages }, (_, i) => i + 1).map((p) => (
                <button
                  key={p}
                  type="button"
                  onClick={() => goToPage(p)}
                  className={`h-8 w-8 rounded-xl text-xs font-bold transition-colors ${
                    currentPage === p
                      ? 'bg-zinc-950 dark:bg-white text-white dark:text-zinc-950 shadow-xs'
                      : 'border border-zinc-200 dark:border-zinc-800 text-zinc-600 dark:text-zinc-400 hover:bg-zinc-100 dark:hover:bg-zinc-800'
                  }`}
                >
                  {p}
                </button>
              ))}
            </div>

            <Button
              type="button"
              variant="outline"
              size="sm"
              onClick={nextPage}
              disabled={currentPage === totalPages}
              className="text-xs font-bold px-2.5"
            >
              <span className="me-1">{t.users.pagination.next}</span>
              {isAr ? <ChevronLeft className="h-4 w-4" /> : <ChevronRight className="h-4 w-4" />}
            </Button>
          </div>
        </Card>
      )}

      {/* 6. Floating Bulk Actions Bar */}
      <UsersBulkBar
        selectedIds={selectedIds}
        selectedUsers={selectedUsers}
        isBulkProcessing={isBulkProcessing}
        isDeletingUser={isDeletingUser}
        hasSuspendedSelected={hasSuspendedSelected}
        hasActiveSelected={hasActiveSelected}
        activeSelectedCount={activeSelectedCount}
        suspendedSelectedCount={suspendedSelectedCount}
        onBulkStatusChange={handleBulkStatusChange}
        onStartBulkDelete={() => setUsersToDelete(selectedUsers)}
        onClearSelection={clearSelection}
      />

      {/* 7. Inspection, Edit, and Add Modals */}
      <UserDetailsModal
        user={selectedUserForDetails}
        isOpen={Boolean(selectedUserForDetails)}
        onClose={() => setSelectedUserForDetails(null)}
        onToggleStatus={async (userId) => {
          const user = paginatedUsers.find((u) => u.id === userId);
          if (user) await handleToggleStatus(user);
        }}
        onChangeRole={handleRoleChange}
        onEdit={(userToEdit) => setSelectedUserForEdit(userToEdit)}
        onDelete={(userToDelete) => setUsersToDelete([userToDelete])}
        isCurrentUser={selectedUserForDetails ? isCurrentUser(selectedUserForDetails) : false}
      />

      <EditUserModal
        user={selectedUserForEdit}
        isOpen={Boolean(selectedUserForEdit)}
        onClose={() => setSelectedUserForEdit(null)}
        onUpdateUser={async (userId, updateData) => {
          await updateUser(userId, updateData);
        }}
      />

      <DeleteUserModal
        users={usersToDelete}
        isOpen={usersToDelete.length > 0}
        onClose={() => setUsersToDelete([])}
        onConfirmDelete={handleConfirmDelete}
        isDeleting={isDeletingUser}
        currentUserId={currentAdmin ? String(currentAdmin.id) : undefined}
      />

      <AddUserModal
        isOpen={isAddModalOpen}
        onClose={() => setIsAddModalOpen(false)}
        onAddUser={async (userData) => {
          await addUser(userData);
        }}
      />
    </div>
  );
};
