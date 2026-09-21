import React, { useState, useMemo } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import {
  ArrowLeft,
  ArrowRight,
  ShieldCheck,
  Check,
  RotateCcw,
  Search,
  X,
  Users,
  CreditCard,
  Layers,
  FolderTree,
  Headphones,
  Code2,
  Cpu,
  Shield,
  Key,
  Lock,
  Sparkles,
} from 'lucide-react';
import { toast } from 'sonner';
import { useLocale } from '../../../core/context/LocaleContext';
import { useRolePermissions } from '../hooks/useRolePermissions';
import { Card } from '../../../core/components/ui/Card';
import { Badge } from '../../../core/components/ui/Badge';
import { Button } from '../../../core/components/ui/Button';
import { RolePermissionsSkeleton } from '../components/RolePermissionsSkeleton';
import type { RoleDefinition, PermissionGroup } from '../types';

type FilterTab = 'all' | 'granted' | 'denied';

const getModuleMeta = (groupKey: string) => {
  switch (groupKey.toLowerCase()) {
    case 'users':
      return { icon: Users, iconColor: 'text-blue-500', iconBg: 'bg-blue-50 dark:bg-blue-950/50' };
    case 'roles':
      return { icon: ShieldCheck, iconColor: 'text-purple-500', iconBg: 'bg-purple-50 dark:bg-purple-950/50' };
    case 'transactions':
      return { icon: CreditCard, iconColor: 'text-emerald-500', iconBg: 'bg-emerald-50 dark:bg-emerald-950/50' };
    case 'subscriptions':
      return { icon: Layers, iconColor: 'text-amber-500', iconBg: 'bg-amber-50 dark:bg-amber-950/50' };
    case 'categories':
      return { icon: FolderTree, iconColor: 'text-teal-500', iconBg: 'bg-teal-50 dark:bg-teal-950/50' };
    case 'support':
      return { icon: Headphones, iconColor: 'text-sky-500', iconBg: 'bg-sky-50 dark:bg-sky-950/50' };
    case 'developer':
      return { icon: Code2, iconColor: 'text-rose-500', iconBg: 'bg-rose-50 dark:bg-rose-950/50' };
    case 'audit_logs':
    case 'auditlogs':
    case 'audit':
      return { icon: Shield, iconColor: 'text-indigo-500', iconBg: 'bg-indigo-50 dark:bg-indigo-950/50' };
    case 'notifications':
      return { icon: Sparkles, iconColor: 'text-amber-500', iconBg: 'bg-amber-50 dark:bg-amber-950/50' };
    case 'system':
    case 'ai':
      return { icon: Cpu, iconColor: 'text-slate-500', iconBg: 'bg-zinc-100 dark:bg-zinc-800' };
    default:
      return { icon: Key, iconColor: 'text-zinc-500', iconBg: 'bg-zinc-100 dark:bg-zinc-800' };
  }
};

interface RolePermissionsEditorProps {
  role: RoleDefinition;
  permissionGroups: PermissionGroup[];
  isSubmitting: boolean;
  onSave: (permissions: string[]) => Promise<RoleDefinition>;
}

const RolePermissionsEditor: React.FC<RolePermissionsEditorProps> = ({
  role,
  permissionGroups,
  isSubmitting,
  onSave,
}) => {
  const navigate = useNavigate();
  const { isAr, t } = useLocale();
  const pI18n = t.roles.permissionsPage;

  const isSuperAdmin = role.name === 'SuperAdmin';

  // Permission selection state initialized directly and cleanly from role
  const [selectedPermissions, setSelectedPermissions] = useState<Set<string>>(
    () => new Set(role.permissions || [])
  );
  const [isDirty, setIsDirty] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');
  const [activeTab, setActiveTab] = useState<FilterTab>('all');

  const totalPermissionsCount = useMemo(() => {
    return permissionGroups.reduce((acc, g) => acc + g.permissions.length, 0);
  }, [permissionGroups]);

  const selectedCount = selectedPermissions.size;
  const percentage =
    totalPermissionsCount > 0
      ? Math.round((selectedCount / totalPermissionsCount) * 100)
      : 0;

  // Filter groups and permissions based on search term & activeTab
  const filteredGroups = useMemo(() => {
    const term = searchTerm.toLowerCase().trim();

    return permissionGroups
      .map((group) => {
        const matchingPerms = group.permissions.filter((p) => {
          const isSelected = selectedPermissions.has(p.code);

          if (activeTab === 'granted' && !isSelected) return false;
          if (activeTab === 'denied' && isSelected) return false;

          if (term) {
            const matchesName =
              p.nameEn.toLowerCase().includes(term) ||
              p.nameAr.includes(term);
            const matchesCode = p.code.toLowerCase().includes(term);
            const matchesDesc =
              p.descriptionEn.toLowerCase().includes(term) ||
              p.descriptionAr.includes(term);
            const matchesGroup =
              group.groupNameEn.toLowerCase().includes(term) ||
              group.groupNameAr.includes(term) ||
              group.groupKey.toLowerCase().includes(term);

            return matchesName || matchesCode || matchesDesc || matchesGroup;
          }

          return true;
        });

        if (matchingPerms.length > 0) {
          return { ...group, permissions: matchingPerms };
        }
        return null;
      })
      .filter((g): g is PermissionGroup => g !== null);
  }, [permissionGroups, selectedPermissions, searchTerm, activeTab]);

  const togglePermission = (code: string) => {
    if (isSuperAdmin) return;

    setSelectedPermissions((prev) => {
      const next = new Set(prev);
      if (next.has(code)) {
        next.delete(code);
      } else {
        next.add(code);
      }
      return next;
    });
    setIsDirty(true);
  };

  const toggleGroup = (group: PermissionGroup) => {
    if (isSuperAdmin) return;

    const groupCodes = group.permissions.map((p) => p.code);
    const allSelected = groupCodes.every((c) => selectedPermissions.has(c));

    setSelectedPermissions((prev) => {
      const next = new Set(prev);
      if (allSelected) {
        groupCodes.forEach((c) => next.delete(c));
      } else {
        groupCodes.forEach((c) => next.add(c));
      }
      return next;
    });
    setIsDirty(true);
  };

  const selectAllPermissions = () => {
    if (isSuperAdmin) return;
    const all = permissionGroups.flatMap((g) => g.permissions.map((p) => p.code));
    setSelectedPermissions(new Set(all));
    setIsDirty(true);
  };

  const clearAllPermissions = () => {
    if (isSuperAdmin) return;
    setSelectedPermissions(new Set());
    setIsDirty(true);
  };

  const resetChanges = () => {
    setSelectedPermissions(new Set(role.permissions || []));
    setIsDirty(false);
  };

  const handleSave = async () => {
    try {
      await onSave(Array.from(selectedPermissions));
      setIsDirty(false);
      toast.success(t.roles.toasts.permissionsUpdated);
    } catch (err: any) {
      toast.error(err?.message || (isAr ? 'فشل حفظ الصلاحيات' : 'Failed to save permissions'));
    }
  };

  return (
    <div className="space-y-6 pb-16">
      {/* 1. Page Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div className="flex items-center gap-3">
          <button
            type="button"
            onClick={() => navigate('/roles')}
            className="flex h-11 w-11 shrink-0 items-center justify-center rounded-2xl border border-zinc-200 dark:border-zinc-800 bg-white dark:bg-[#121215] text-zinc-700 dark:text-zinc-300 hover:text-zinc-950 dark:hover:text-white hover:bg-zinc-100 dark:hover:bg-zinc-800 transition shadow-2xs cursor-pointer"
            title={pI18n.backToRoles}
          >
            {isAr ? <ArrowRight className="h-5 w-5" /> : <ArrowLeft className="h-5 w-5" />}
          </button>

          <div>
            <div className="flex items-center flex-wrap gap-2">
              <h1 className="text-xl sm:text-2xl font-black tracking-tight text-zinc-950 dark:text-white">
                {isAr ? `صلاحيات: ${role.name}` : `Permissions: ${role.name}`}
              </h1>
              <Badge variant={role.isSystem ? 'success' : 'purple'} className="text-xs font-semibold">
                {role.isSystem ? pI18n.systemRoleBadge : pI18n.customRoleBadge}
              </Badge>
              {isSuperAdmin && (
                <span className="px-2 py-0.5 rounded-full text-[10px] font-mono font-bold bg-amber-500/10 text-amber-600 dark:text-amber-400 border border-amber-500/20">
                  {isAr ? 'صلاحيات كاملة غير قابلة للتعديل' : 'Full Immutable Access'}
                </span>
              )}
            </div>
            <p className="text-xs text-zinc-500 dark:text-zinc-400 mt-0.5">
              {role.description || (isAr ? 'تخصيص مصفوفة الصلاحيات وتفويض المهام الإدارية' : 'Configure granular capability matrix')}
            </p>
          </div>
        </div>

        {/* Top Header Actions */}
        <div className="flex items-center gap-2 self-start sm:self-auto">
          {isDirty && !isSuperAdmin && (
            <Button
              type="button"
              variant="outline"
              size="sm"
              onClick={resetChanges}
              disabled={isSubmitting}
              className="font-bold border-zinc-200 dark:border-zinc-800 text-zinc-600 dark:text-zinc-300"
            >
              <RotateCcw className="h-4 w-4 me-1.5" />
              <span>{pI18n.resetChanges}</span>
            </Button>
          )}

          <Button
            type="button"
            variant="primary"
            size="sm"
            onClick={handleSave}
            isLoading={isSubmitting}
            disabled={isSuperAdmin || !isDirty}
            className="font-bold shadow-xs"
          >
            <Check className="h-4 w-4 me-1.5" />
            <span>{isSubmitting ? pI18n.saving : pI18n.saveChanges}</span>
          </Button>
        </div>
      </div>

      {/* 2. Top KPI Metrics Summary (4 Cards) */}
      <div className="grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-4">
        {/* Card 1: Total Platform Capabilities */}
        <Card className="p-4 bg-white dark:bg-[#121215] border-zinc-200 dark:border-zinc-800/80 shadow-2xs hover:shadow-xs transition-shadow">
          <div className="flex items-center justify-between">
            <span className="text-xs font-bold text-zinc-500 dark:text-zinc-400">
              {pI18n.allClaims}
            </span>
            <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-blue-50 dark:bg-blue-950/50">
              <Key className="h-5 w-5 text-blue-600 dark:text-blue-400" />
            </div>
          </div>
          <div className="mt-2 flex items-baseline gap-2">
            <span className="text-2xl font-black text-zinc-950 dark:text-white font-mono">
              {totalPermissionsCount}
            </span>
            <span className="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-bold bg-zinc-100 dark:bg-zinc-800 text-zinc-700 dark:text-zinc-300">
              {permissionGroups.length} {isAr ? 'أقسام' : 'modules'}
            </span>
          </div>
        </Card>

        {/* Card 2: Active Granted Claims */}
        <Card className="p-4 bg-white dark:bg-[#121215] border-zinc-200 dark:border-zinc-800/80 shadow-2xs hover:shadow-xs transition-shadow">
          <div className="flex items-center justify-between">
            <span className="text-xs font-bold text-zinc-500 dark:text-zinc-400">
              {pI18n.grantedClaims}
            </span>
            <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-emerald-50 dark:bg-emerald-950/50">
              <ShieldCheck className="h-5 w-5 text-emerald-600 dark:text-emerald-400" />
            </div>
          </div>
          <div className="mt-2 flex items-baseline gap-2">
            <span className="text-2xl font-black text-zinc-950 dark:text-white font-mono">
              {selectedCount}
            </span>
            <span className="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-bold bg-emerald-50 dark:bg-emerald-950/60 text-emerald-700 dark:text-emerald-400">
              {percentage}% {isAr ? 'من الإجمالي' : 'granted'}
            </span>
          </div>
        </Card>

        {/* Card 3: Unassigned / Denied Capabilities */}
        <Card className="p-4 bg-white dark:bg-[#121215] border-zinc-200 dark:border-zinc-800/80 shadow-2xs hover:shadow-xs transition-shadow">
          <div className="flex items-center justify-between">
            <span className="text-xs font-bold text-zinc-500 dark:text-zinc-400">
              {pI18n.deniedClaims}
            </span>
            <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-purple-50 dark:bg-purple-950/50">
              <Lock className="h-5 w-5 text-purple-600 dark:text-purple-400" />
            </div>
          </div>
          <div className="mt-2 flex items-baseline gap-2">
            <span className="text-2xl font-black text-zinc-950 dark:text-white font-mono">
              {totalPermissionsCount - selectedCount}
            </span>
            <span className="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-bold bg-purple-50 dark:bg-purple-950/60 text-purple-700 dark:text-purple-400">
              {100 - percentage}% {isAr ? 'مقيدة' : 'restricted'}
            </span>
          </div>
        </Card>

        {/* Card 4: Role Assignment Scope */}
        <Card className="p-4 bg-white dark:bg-[#121215] border-zinc-200 dark:border-zinc-800/80 shadow-2xs hover:shadow-xs transition-shadow">
          <div className="flex items-center justify-between">
            <span className="text-xs font-bold text-zinc-500 dark:text-zinc-400">
              {t.roles.table.assignedUsers}
            </span>
            <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-zinc-100 dark:bg-zinc-800">
              <Users className="h-5 w-5 text-zinc-700 dark:text-zinc-300" />
            </div>
          </div>
          <div className="mt-2 flex items-baseline gap-2">
            <span className="text-2xl font-black text-zinc-950 dark:text-white font-mono">
              {role.usersCount || 0}
            </span>
            <span className="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-bold bg-blue-50 dark:bg-blue-950/60 text-blue-700 dark:text-blue-400">
              {isAr ? 'حساب نشط' : 'active users'}
            </span>
          </div>
        </Card>
      </div>

      {/* 3. Search Bar, Tabs & Quick Batch Actions Bar */}
      <div className="space-y-3">
        {/* Status Tabs Bar */}
        <div className="flex items-center justify-between gap-2 overflow-x-auto pb-1">
          <div className="flex items-center gap-1.5 p-1 rounded-2xl bg-zinc-200/50 dark:bg-zinc-900 border border-zinc-200/80 dark:border-zinc-800">
            {[
              { id: 'all', label: pI18n.allClaims, count: totalPermissionsCount },
              { id: 'granted', label: pI18n.grantedClaims, count: selectedCount },
              { id: 'denied', label: pI18n.deniedClaims, count: totalPermissionsCount - selectedCount },
            ].map((tab) => {
              const isActive = activeTab === tab.id;
              return (
                <button
                  key={tab.id}
                  type="button"
                  onClick={() => setActiveTab(tab.id as FilterTab)}
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

          {/* Quick Select/Deselect All buttons */}
          {!isSuperAdmin && (
            <div className="flex items-center gap-2 shrink-0">
              <Button
                type="button"
                variant="outline"
                size="sm"
                onClick={selectAllPermissions}
                className="text-xs font-bold text-emerald-600 dark:text-emerald-400 border-zinc-200 dark:border-zinc-800"
              >
                {pI18n.selectAll}
              </Button>
              <Button
                type="button"
                variant="outline"
                size="sm"
                onClick={clearAllPermissions}
                className="text-xs font-bold text-zinc-500 hover:text-rose-600 dark:hover:text-rose-400 border-zinc-200 dark:border-zinc-800"
              >
                {pI18n.clearAll}
              </Button>
            </div>
          )}
        </div>

        {/* Search Input Card */}
        <Card className="flex items-center gap-3 p-3 bg-white dark:bg-[#121215] border-zinc-200 dark:border-zinc-800/80 shadow-2xs">
          <div className="relative flex-1 w-full">
            <Search className="absolute top-1/2 start-3.5 h-4 w-4 -translate-y-1/2 text-zinc-400" />
            <input
              type="text"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              placeholder={pI18n.searchPlaceholder}
              className="w-full rounded-xl border border-zinc-200/80 dark:border-zinc-800 bg-zinc-50/50 dark:bg-zinc-900 py-2 ps-10 pe-9 text-xs font-semibold text-zinc-900 dark:text-white placeholder-zinc-400 focus:outline-none focus:ring-2 focus:ring-zinc-900 dark:focus:ring-white transition"
            />
            {searchTerm && (
              <button
                type="button"
                onClick={() => setSearchTerm('')}
                className="absolute top-1/2 end-3 -translate-y-1/2 text-zinc-400 hover:text-zinc-600 dark:hover:text-zinc-200 cursor-pointer"
              >
                <X className="h-3.5 w-3.5" />
              </button>
            )}
          </div>
        </Card>
      </div>

      {/* 4. Responsive Grid of Module Cards */}
      {filteredGroups.length === 0 ? (
        <div className="p-12 text-center rounded-3xl border border-dashed border-zinc-200 dark:border-zinc-800 bg-white/60 dark:bg-zinc-900/60 backdrop-blur-xs space-y-3">
          <Sparkles className="h-10 w-10 text-zinc-300 dark:text-zinc-600 mx-auto" />
          <h3 className="text-base font-bold text-zinc-900 dark:text-white">
            {pI18n.emptySearchTitle}
          </h3>
          <p className="text-xs text-zinc-500 max-w-sm mx-auto">
            {pI18n.emptySearchDesc}
          </p>
          {(searchTerm || activeTab !== 'all') && (
            <Button
              variant="outline"
              size="sm"
              onClick={() => {
                setSearchTerm('');
                setActiveTab('all');
              }}
            >
              {isAr ? 'إعادة ضبط الفلاتر' : 'Reset Filters'}
            </Button>
          )}
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
          {filteredGroups.map((group) => {
            const meta = getModuleMeta(group.groupKey);
            const ModuleIcon = meta.icon;
            const groupCodes = group.permissions.map((p) => p.code);
            const selectedInGroup = groupCodes.filter((c) => selectedPermissions.has(c)).length;
            const totalInGroup = groupCodes.length;
            const isAllSelected = selectedInGroup === totalInGroup && totalInGroup > 0;

            return (
              <Card
                key={group.groupKey}
                className="p-0 overflow-hidden bg-white dark:bg-[#121215] border-zinc-200/80 dark:border-zinc-800/80 rounded-2xl shadow-2xs hover:shadow-xs transition-all flex flex-col"
              >
                {/* Module Header */}
                <div className="p-4 border-b border-zinc-100 dark:border-zinc-800/80 bg-zinc-50/50 dark:bg-zinc-900/40 flex items-center justify-between gap-3">
                  <div className="flex items-center gap-3 min-w-0">
                    <div className={`flex h-10 w-10 items-center justify-center rounded-xl ${meta.iconBg} shrink-0`}>
                      <ModuleIcon className={`h-5 w-5 ${meta.iconColor}`} />
                    </div>
                    <div className="min-w-0">
                      <h3 className="text-xs sm:text-sm font-bold text-zinc-950 dark:text-white truncate">
                        {isAr ? group.groupNameAr : group.groupNameEn}
                      </h3>
                      <span className="text-[11px] font-mono text-zinc-400 dark:text-zinc-500 block mt-0.5">
                        {selectedInGroup} / {totalInGroup} {isAr ? 'مفعلة' : 'active'}
                      </span>
                    </div>
                  </div>

                  {/* Master Group Switch */}
                  <div className="shrink-0" onClick={(e) => e.stopPropagation()}>
                    <button
                      type="button"
                      role="switch"
                      aria-checked={isAllSelected}
                      disabled={isSuperAdmin}
                      onClick={() => toggleGroup(group)}
                      title={
                        isAllSelected
                          ? isAr
                            ? 'إلغاء تحديد القسم بالكامل'
                            : 'Deselect entire group'
                          : isAr
                          ? 'تفعيل القسم بالكامل'
                          : 'Select entire group'
                      }
                      className={`relative inline-flex h-5 w-9 shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none ${
                        isAllSelected ? 'bg-emerald-500' : 'bg-zinc-200 dark:bg-zinc-700'
                      } ${isSuperAdmin ? 'opacity-30 cursor-not-allowed' : ''}`}
                    >
                      <span
                        aria-hidden="true"
                        className={`pointer-events-none inline-block h-4 w-4 transform rounded-full bg-white shadow-xs ring-0 transition duration-200 ease-in-out ${
                          isAllSelected
                            ? isAr
                              ? '-translate-x-4'
                              : 'translate-x-4'
                            : 'translate-x-0'
                        }`}
                      />
                    </button>
                  </div>
                </div>

                {/* Permissions List */}
                <div className="p-3 space-y-1 max-h-[340px] overflow-y-auto">
                  {group.permissions.map((perm) => {
                    const isChecked = selectedPermissions.has(perm.code);

                    return (
                      <div
                        key={perm.code}
                        onClick={() => togglePermission(perm.code)}
                        className={`flex items-center justify-between gap-2.5 px-3 py-2.5 rounded-xl transition-colors cursor-pointer select-none ${
                          isChecked
                            ? 'bg-zinc-100/60 dark:bg-zinc-800/40 hover:bg-zinc-100 dark:hover:bg-zinc-800/60'
                            : 'hover:bg-zinc-50 dark:hover:bg-zinc-800/30'
                        }`}
                      >
                        <div className="min-w-0 flex-1">
                          <div className="flex items-center gap-2">
                            <span
                              className={`h-1.5 w-1.5 rounded-full shrink-0 transition-colors ${
                                isChecked ? 'bg-emerald-500' : 'bg-zinc-300 dark:bg-zinc-600'
                              }`}
                            />
                            <span className="text-xs font-semibold text-zinc-900 dark:text-white truncate">
                              {isAr ? perm.nameAr : perm.nameEn}
                            </span>
                          </div>
                          <p className="text-[10px] font-mono text-zinc-400 dark:text-zinc-500 truncate mt-0.5 ps-3.5">
                            {perm.code}
                          </p>
                        </div>

                        {/* Individual Item Toggle Switch */}
                        <div className="shrink-0 ms-2" onClick={(e) => e.stopPropagation()}>
                          <button
                            type="button"
                            role="switch"
                            aria-checked={isChecked}
                            disabled={isSuperAdmin}
                            onClick={() => togglePermission(perm.code)}
                            className={`relative inline-flex h-4 w-7 shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none ${
                              isChecked ? 'bg-emerald-500' : 'bg-zinc-200 dark:bg-zinc-700'
                            } ${isSuperAdmin ? 'opacity-30 cursor-not-allowed' : ''}`}
                          >
                            <span
                              aria-hidden="true"
                              className={`pointer-events-none inline-block h-3 w-3 transform rounded-full bg-white shadow-xs ring-0 transition duration-200 ease-in-out ${
                                isChecked
                                  ? isAr
                                    ? '-translate-x-3'
                                    : 'translate-x-3'
                                  : 'translate-x-0'
                              }`}
                            />
                          </button>
                        </div>
                      </div>
                    );
                  })}
                </div>
              </Card>
            );
          })}
        </div>
      )}

      {/* 5. Bottom Sticky Action Bar */}
      {isDirty && !isSuperAdmin && (
        <div className="fixed bottom-6 start-1/2 -translate-x-1/2 z-40 w-full max-w-lg px-4">
          <Card className="p-3 bg-zinc-950/90 dark:bg-zinc-900/95 backdrop-blur-md border-zinc-800 shadow-2xl flex items-center justify-between text-white rounded-2xl">
            <div className="flex items-center gap-2 text-xs ps-1">
              <span className="flex h-2 w-2 rounded-full bg-emerald-400 animate-pulse" />
              <span className="font-semibold">
                {isAr ? 'لديك تعديلات غير محفوظة' : 'Unsaved changes'}
              </span>
            </div>

            <div className="flex items-center gap-2">
              <Button
                type="button"
                variant="ghost"
                size="sm"
                onClick={resetChanges}
                disabled={isSubmitting}
                className="text-xs text-zinc-300 hover:text-white"
              >
                {isAr ? 'تراجع' : 'Discard'}
              </Button>
              <Button
                type="button"
                variant="primary"
                size="sm"
                onClick={handleSave}
                isLoading={isSubmitting}
                className="text-xs font-bold shadow-xs"
              >
                <Check className="h-3.5 w-3.5 me-1" />
                <span>{isSubmitting ? pI18n.saving : pI18n.saveChanges}</span>
              </Button>
            </div>
          </Card>
        </div>
      )}
    </div>
  );
};

export const RolePermissionsPage: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { t } = useLocale();
  const pI18n = t.roles.permissionsPage;

  const {
    role,
    permissionGroups,
    isLoading,
    isSubmitting,
    updatePermissions,
  } = useRolePermissions(id);

  // 1. Loading Skeleton matching Mahfazti layout
  if (isLoading) {
    return <RolePermissionsSkeleton />;
  }

  // 2. Role Not Found State
  if (!role) {
    return (
      <div className="p-12 text-center rounded-3xl border border-dashed border-zinc-200 dark:border-zinc-800 bg-white dark:bg-[#121215] space-y-4 my-8">
        <Shield className="h-12 w-12 text-zinc-400 mx-auto" />
        <h2 className="text-lg font-bold text-zinc-900 dark:text-white">
          {pI18n.roleNotFound}
        </h2>
        <p className="text-xs text-zinc-500 max-w-sm mx-auto">
          {pI18n.roleNotFoundDesc}
        </p>
        <Button variant="primary" size="sm" onClick={() => navigate('/roles')}>
          {pI18n.backToRoles}
        </Button>
      </div>
    );
  }

  // 3. Render editor keyed by role.id for clean, unpolluted state management
  return (
    <RolePermissionsEditor
      key={role.id}
      role={role}
      permissionGroups={permissionGroups}
      isSubmitting={isSubmitting}
      onSave={updatePermissions}
    />
  );
};
