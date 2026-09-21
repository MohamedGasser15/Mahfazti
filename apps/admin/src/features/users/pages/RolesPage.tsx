import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Key,
  ShieldCheck,
  Plus,
  RotateCcw,
  Search,
  X,
  Edit2,
  Trash2,
  Check,
  LayoutList,
  LayoutGrid,
  ChevronLeft,
  ChevronRight,
} from 'lucide-react';
import { toast } from 'sonner';
import { useLocale } from '../../../core/context/LocaleContext';
import { useViewMode } from '../../../core/context/ViewModeContext';
import { useRoles, type RoleTabFilter } from '../hooks/useRoles';
import { Card } from '../../../core/components/ui/Card';
import { Badge } from '../../../core/components/ui/Badge';
import { Button } from '../../../core/components/ui/Button';
import type { RoleDefinition } from '../types';
import { RolesKpiCards } from '../components/RolesKpiCards';
import { RolesTable } from '../components/RolesTable';
import { RoleFormModal } from '../components/RoleFormModal';
import { DeleteRoleModal } from '../components/DeleteRoleModal';
import { RolesSkeleton } from '../components/RolesSkeleton';

export const RolesPage: React.FC = () => {
  const navigate = useNavigate();
  const { isAr, t } = useLocale();
  const { viewMode, setViewMode } = useViewMode();

  const {
    roles,
    stats,
    searchTerm,
    setSearchTerm,
    tabFilter,
    setTabFilter,
    currentPage,
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
  } = useRoles();

  // Modals state
  const [isFormOpen, setIsFormOpen] = useState(false);
  const [roleToEdit, setRoleToEdit] = useState<RoleDefinition | null>(null);
  const [roleToDelete, setRoleToDelete] = useState<RoleDefinition | null>(null);

  const openCreateModal = () => {
    setRoleToEdit(null);
    setIsFormOpen(true);
  };

  const openEditModal = (role: RoleDefinition) => {
    setRoleToEdit(role);
    setIsFormOpen(true);
  };

  const handleManagePermissions = (role: RoleDefinition) => {
    navigate(`/roles/${role.id}/permissions`);
  };

  const handleFormSubmit = async (formData: {
    name: string;
    description: string;
  }) => {
    if (roleToEdit) {
      await updateRole(roleToEdit.id, {
        name: formData.name,
        description: formData.description,
        permissions: roleToEdit.permissions || [],
      });
      toast.success(t.roles.toasts.roleUpdated);
    } else {
      await createRole({
        name: formData.name,
        description: formData.description,
        permissions: [],
      });
      toast.success(t.roles.toasts.createSuccess);
    }
  };

  const handleDeleteConfirm = async (role: RoleDefinition) => {
    try {
      await deleteRole(role.id);
      toast.success(t.roles.toasts.deleteSuccess);
      setRoleToDelete(null);
    } catch (err: any) {
      toast.error(err?.message || (isAr ? 'فشل حذف الرتبة' : 'Failed to delete role'));
    }
  };

  const startRecord = totalCount > 0 ? (currentPage - 1) * pageSize + 1 : 0;
  const endRecord = Math.min(currentPage * pageSize, totalCount);

  return (
    <div className="space-y-6 pb-12">
      {/* 1. Executive Page Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <div className="flex items-center gap-3">
            <div className="flex h-11 w-11 shrink-0 items-center justify-center rounded-2xl bg-zinc-900 dark:bg-zinc-100 text-white dark:text-zinc-950 shadow-md">
              <Key className="h-5 w-5" />
            </div>
            <div>
              <h1 className="text-xl sm:text-2xl font-black tracking-tight text-zinc-950 dark:text-white">
                {t.roles.pageTitle}
              </h1>
              <p className="text-xs text-zinc-500 dark:text-zinc-400 mt-0.5">
                {t.roles.pageSubtitle}
              </p>
            </div>
          </div>
        </div>

        <div className="flex items-center gap-2 self-start sm:self-auto">
          <Button
            type="button"
            variant="outline"
            size="sm"
            onClick={refetch}
            disabled={isLoading}
            className="font-bold border-zinc-200 dark:border-zinc-800 text-zinc-700 dark:text-zinc-300"
          >
            <RotateCcw className={`h-4 w-4 me-1.5 ${isLoading ? 'animate-spin' : ''}`} />
            <span>{t.roles.refresh}</span>
          </Button>

          <Button
            type="button"
            variant="primary"
            size="sm"
            onClick={openCreateModal}
            className="font-bold shadow-xs"
          >
            <Plus className="h-4 w-4 me-1.5" />
            <span>{t.roles.createNewRole}</span>
          </Button>
        </div>
      </div>

      {/* 2. Top KPI Metrics Summary Cards */}
      <RolesKpiCards stats={stats} isLoading={isLoading} isAr={isAr} />

      {/* 3. Filter Tabs, View Mode Toggle & Search Bar */}
      <div className="space-y-3">
        {/* Status / Category Tabs Bar & View Mode Toggle */}
        <div className="flex items-center justify-between gap-2 overflow-x-auto pb-1">
          <div className="flex items-center gap-1.5 p-1 rounded-2xl bg-zinc-200/50 dark:bg-zinc-900 border border-zinc-200/80 dark:border-zinc-800">
            {[
              { id: 'all', label: t.roles.tabs.all, count: stats.totalRoles },
              { id: 'system', label: t.roles.tabs.system, count: stats.systemRolesCount },
              { id: 'custom', label: t.roles.tabs.custom, count: stats.customRolesCount },
            ].map((tab) => {
              const isActive = tabFilter === tab.id;
              return (
                <button
                  key={tab.id}
                  type="button"
                  onClick={() => setTabFilter(tab.id as RoleTabFilter)}
                  className={`flex items-center gap-2 px-3.5 py-1.5 rounded-xl text-xs font-bold transition-all cursor-pointer whitespace-nowrap ${
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

          {/* View Mode Toggle (Table / Cards Grid) */}
          <div className="flex items-center gap-1 p-1 rounded-2xl bg-zinc-200/50 dark:bg-zinc-900 border border-zinc-200/80 dark:border-zinc-800 shrink-0">
            <button
              type="button"
              onClick={() => setViewMode('table')}
              title={isAr ? 'عرض الجدول' : 'Table View'}
              className={`p-1.5 rounded-xl text-xs transition-all cursor-pointer ${
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
              title={isAr ? 'عرض الكروت' : 'Cards View'}
              className={`p-1.5 rounded-xl text-xs transition-all cursor-pointer ${
                viewMode === 'cards'
                  ? 'bg-zinc-950 dark:bg-white text-white dark:text-zinc-950 shadow-xs'
                  : 'text-zinc-600 dark:text-zinc-400 hover:text-zinc-950 dark:hover:text-white'
              }`}
            >
              <LayoutGrid className="h-4 w-4" />
            </button>
          </div>
        </div>

        {/* Search Bar */}
        <Card className="flex items-center gap-3 p-3 bg-white dark:bg-[#121215] border-zinc-200 dark:border-zinc-800/80 shadow-2xs">
          <div className="relative flex-1 w-full">
            <Search className="absolute top-1/2 start-3.5 h-4 w-4 -translate-y-1/2 text-zinc-400" />
            <input
              type="text"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              placeholder={t.roles.searchPlaceholder}
              className="w-full rounded-xl border border-zinc-200/80 dark:border-zinc-800 bg-zinc-50/50 dark:bg-zinc-900 py-2 ps-10 pe-9 text-xs font-semibold text-zinc-900 dark:text-white placeholder-zinc-400 focus:outline-none focus:ring-2 focus:ring-zinc-900 dark:focus:ring-white transition"
            />
            {searchTerm && (
              <button
                type="button"
                onClick={() => setSearchTerm('')}
                className="absolute top-1/2 end-3 -translate-y-1/2 text-zinc-400 hover:text-zinc-600 dark:hover:text-zinc-200"
              >
                <X className="h-3.5 w-3.5" />
              </button>
            )}
          </div>
        </Card>
      </div>

      {/* 4. Roles Content: Table View vs Cards View */}
      {isLoading ? (
        <RolesSkeleton count={pageSize} viewMode={viewMode} isAr={isAr} />
      ) : roles.length === 0 ? (
        <div className="p-12 text-center rounded-3xl border border-dashed border-zinc-200 dark:border-zinc-800 bg-white/60 dark:bg-zinc-900/60 backdrop-blur-xs space-y-3">
          <ShieldCheck className="h-12 w-12 text-zinc-300 dark:text-zinc-600 mx-auto" />
          <h3 className="text-base font-bold text-zinc-900 dark:text-white">
            {isAr ? 'لم يتم العثور على أي رتب مطابقة' : 'No Roles Found'}
          </h3>
          <p className="text-xs text-zinc-500 max-w-sm mx-auto">
            {searchTerm
              ? isAr
                ? `لا توجد نتائج مطابقة لبحثك عن "${searchTerm}". جرب مصطلح بحث مختلف.`
                : `No roles match your search "${searchTerm}".`
              : isAr
              ? 'لم يتم إنشاء أي رتب مخصصة بعد. ابدأ بإنشاء أول رتبة مخصصة.'
              : 'No custom roles have been defined yet.'}
          </p>
          {searchTerm && (
            <Button variant="outline" size="sm" onClick={() => setSearchTerm('')}>
              {isAr ? 'مسح البحث' : 'Clear Search'}
            </Button>
          )}
        </div>
      ) : viewMode === 'table' ? (
        <RolesTable
          roles={roles}
          onManagePermissions={handleManagePermissions}
          onEdit={(role) => openEditModal(role)}
          onDelete={(role) => setRoleToDelete(role)}
          isAr={isAr}
        />
      ) : (
        /* Cards Grid View */
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
          {roles.map((role) => {
            const permsCount = role.permissions?.length || 0;
            const displayPerms = (role.permissions || []).slice(0, 3);
            const remainingCount = permsCount - displayPerms.length;

            return (
              <Card
                key={role.id}
                className="p-5 bg-white dark:bg-[#121215] border-zinc-200 dark:border-zinc-800/80 shadow-2xs hover:shadow-xs transition-shadow flex flex-col justify-between space-y-4"
              >
                <div>
                  {/* Top Bar: Icon & Type Badge */}
                  <div className="flex items-start justify-between gap-2">
                    <div className="flex items-center gap-2.5">
                      <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-zinc-100 dark:bg-zinc-800 text-zinc-900 dark:text-white font-bold shadow-2xs">
                        <Key className="h-5 w-5 text-blue-500" />
                      </div>
                      <div>
                        <h3 className="text-sm font-black text-zinc-900 dark:text-white">
                          {role.name}
                        </h3>
                        <span className="text-[10px] font-mono text-zinc-400 block mt-0.5">
                          {role.usersCount} {isAr ? 'مشرف معين' : 'assigned'}
                        </span>
                      </div>
                    </div>

                    <Badge variant={role.isSystem ? 'success' : 'purple'} className="text-[10px] font-semibold">
                      {role.isSystem ? (isAr ? 'أساسي' : 'System') : (isAr ? 'مخصص' : 'Custom')}
                    </Badge>
                  </div>

                  {/* Description */}
                  <p className="text-xs text-zinc-600 dark:text-zinc-400 mt-3 line-clamp-2 leading-relaxed">
                    {role.description || (isAr ? 'لا يوجد وصف مخصص' : 'No description provided')}
                  </p>

                  {/* Permissions Pills */}
                  <div className="mt-4 pt-3 border-t border-zinc-100 dark:border-zinc-800/80">
                    <span className="text-[10px] font-bold uppercase tracking-wider text-zinc-400 block mb-2">
                      {isAr ? 'الصلاحيات الممنوحة' : 'Granted Claims'} ({permsCount})
                    </span>

                    {permsCount === 0 ? (
                      <span className="text-[11px] text-zinc-400 italic">
                        {isAr ? 'لا توجد صلاحيات إدارية' : 'No permissions assigned'}
                      </span>
                    ) : (
                      <div className="flex flex-wrap gap-1.5">
                        {displayPerms.map((p) => (
                          <span
                            key={p}
                            className="inline-flex items-center gap-1 rounded-md bg-zinc-100 dark:bg-zinc-800/80 px-2 py-0.5 font-mono text-[10px] font-medium text-zinc-700 dark:text-zinc-300 border border-zinc-200/50 dark:border-zinc-700/50"
                          >
                            <Check className="h-2.5 w-2.5 text-emerald-500" />
                            {p}
                          </span>
                        ))}
                        {remainingCount > 0 && (
                          <button
                            type="button"
                            onClick={() => handleManagePermissions(role)}
                            className="inline-flex items-center px-1.5 py-0.5 rounded-md text-[10px] font-mono font-bold bg-blue-50 dark:bg-blue-950/40 text-blue-600 dark:text-blue-400 hover:underline cursor-pointer border border-blue-200/60 dark:border-blue-800/60"
                          >
                            +{remainingCount} {isAr ? 'المزيد' : 'more'}
                          </button>
                        )}
                      </div>
                    )}
                  </div>
                </div>

                {/* Card Action Buttons */}
                <div className="pt-3 border-t border-zinc-100 dark:border-zinc-800/80 flex items-center justify-between gap-1.5">
                  <Button
                    type="button"
                    variant="outline"
                    size="sm"
                    onClick={() => handleManagePermissions(role)}
                    className="flex-1 text-xs font-bold text-blue-600 dark:text-blue-400 hover:text-blue-700"
                  >
                    <ShieldCheck className="h-3.5 w-3.5 me-1" />
                    <span>{t.roles.cards.permissions}</span>
                  </Button>

                  <button
                    type="button"
                    onClick={() => openEditModal(role)}
                    title={t.roles.cards.edit}
                    className="flex h-8 w-8 items-center justify-center rounded-xl border border-zinc-200 dark:border-zinc-800 bg-zinc-50 hover:bg-zinc-100 dark:bg-zinc-900 dark:hover:bg-zinc-800 text-zinc-600 dark:text-zinc-400 hover:text-zinc-950 dark:hover:text-white transition-colors shrink-0"
                  >
                    <Edit2 className="h-3.5 w-3.5" />
                  </button>

                  <button
                    type="button"
                    disabled={role.isSystem}
                    onClick={() => {
                      if (role.isSystem) return;
                      setRoleToDelete(role);
                    }}
                    title={
                      role.isSystem
                        ? (isAr ? 'رتبة نظام أساسية محمية' : 'Protected system role')
                        : (isAr ? 'حذف الرتبة' : 'Delete Role')
                    }
                    className={`flex h-8 w-8 items-center justify-center rounded-xl border transition-colors shrink-0 ${
                      role.isSystem
                        ? 'border-zinc-200/50 dark:border-zinc-800/50 opacity-30 cursor-not-allowed text-zinc-400'
                        : 'border-zinc-200 dark:border-zinc-800 bg-zinc-50 hover:bg-rose-50 dark:bg-zinc-900 dark:hover:bg-rose-950/40 text-zinc-600 hover:text-rose-600 dark:text-zinc-400 dark:hover:text-rose-400'
                    }`}
                  >
                    <Trash2 className="h-4 w-4" />
                  </button>
                </div>
              </Card>
            );
          })}
        </div>
      )}

      {/* 5. Pagination Toolbar */}
      {!isLoading && totalCount > 0 && (
        <Card className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3 p-3.5 bg-white dark:bg-[#121215] border-zinc-200 dark:border-zinc-800/80 shadow-2xs">
          <p className="text-xs text-zinc-500 dark:text-zinc-400 text-center sm:text-start">
            {t.roles.pagination.showing}{' '}
            <strong className="text-zinc-900 dark:text-white font-mono">{startRecord}</strong>{' '}
            {t.roles.pagination.to}{' '}
            <strong className="text-zinc-900 dark:text-white font-mono">{endRecord}</strong>{' '}
            {t.roles.pagination.of}{' '}
            <strong className="text-zinc-900 dark:text-white font-mono">{totalCount}</strong>{' '}
            {t.roles.pagination.roles}
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
              <span className="ms-1">{t.roles.pagination.prev}</span>
            </Button>

            <div className="flex items-center gap-1">
              {Array.from({ length: totalPages }, (_, i) => i + 1).map((p) => (
                <button
                  key={p}
                  type="button"
                  onClick={() => goToPage(p)}
                  className={`h-8 w-8 rounded-xl text-xs font-bold transition-colors cursor-pointer ${
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
              <span className="me-1">{t.roles.pagination.next}</span>
              {isAr ? <ChevronLeft className="h-4 w-4" /> : <ChevronRight className="h-4 w-4" />}
            </Button>
          </div>
        </Card>
      )}

      {/* 6. Modals */}
      <RoleFormModal
        isOpen={isFormOpen}
        onClose={() => setIsFormOpen(false)}
        onSubmit={handleFormSubmit}
        roleToEdit={roleToEdit}
        isSubmitting={isSubmitting}
        isAr={isAr}
      />

      <DeleteRoleModal
        isOpen={Boolean(roleToDelete)}
        onClose={() => setRoleToDelete(null)}
        onConfirm={handleDeleteConfirm}
        roleToDelete={roleToDelete}
        isSubmitting={isSubmitting}
        isAr={isAr}
      />
    </div>
  );
};
