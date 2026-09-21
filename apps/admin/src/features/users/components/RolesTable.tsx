import React from 'react';
import { Key, Shield, ShieldCheck, Users, Edit2, Trash2, Check } from 'lucide-react';
import { Card } from '../../../core/components/ui/Card';
import { Badge } from '../../../core/components/ui/Badge';
import type { RoleDefinition } from '../types';

interface RolesTableProps {
  roles: RoleDefinition[];
  onManagePermissions: (role: RoleDefinition) => void;
  onEdit: (role: RoleDefinition) => void;
  onDelete: (role: RoleDefinition) => void;
  isAr: boolean;
}

export const RolesTable: React.FC<RolesTableProps> = ({
  roles,
  onManagePermissions,
  onEdit,
  onDelete,
  isAr,
}) => {
  return (
    <Card className="p-0 overflow-hidden bg-white dark:bg-[#121215] border-zinc-200 dark:border-zinc-800/80 shadow-2xs min-h-[360px]">
      <div className="overflow-x-auto">
        <table className="w-full text-left rtl:text-right text-xs">
          <thead className="border-b border-zinc-200 dark:border-zinc-800 bg-zinc-50/80 dark:bg-zinc-900/50 text-[11px] font-bold uppercase tracking-wider text-zinc-500 dark:text-zinc-400">
            <tr>
              <th className="py-3.5 px-6">{isAr ? 'الرتبة والدور' : 'Role Name'}</th>
              <th className="py-3.5 px-6">{isAr ? 'النوع والحماية' : 'System Status'}</th>
              <th className="py-3.5 px-6">{isAr ? 'الصلاحيات الممنوحة' : 'Granted Capabilities'}</th>
              <th className="py-3.5 px-6 text-center">{isAr ? 'المستخدمين المعينين' : 'Assigned Users'}</th>
              <th className="py-3.5 px-6 text-center">{isAr ? 'الإجراءات' : 'Actions'}</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-zinc-200/70 dark:divide-zinc-800/60 text-zinc-700 dark:text-zinc-300">
            {roles.map((role) => {
              const permsCount = role.permissions?.length || 0;
              const displayPerms = (role.permissions || []).slice(0, 3);
              const remainingCount = permsCount - displayPerms.length;

              return (
                <tr
                  key={role.id}
                  className="hover:bg-zinc-50/80 dark:hover:bg-zinc-800/40 transition-colors"
                >
                  {/* Role Name & Icon */}
                  <td className="py-3.5 px-6">
                    <div className="flex items-center gap-3">
                      <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-xl bg-zinc-900 dark:bg-zinc-800 text-white font-bold text-xs shadow-2xs">
                        <Key className="h-4 w-4 text-blue-400" />
                      </div>
                      <div>
                        <div className="font-bold text-zinc-950 dark:text-white flex items-center gap-1.5">
                          <span>{role.name}</span>
                          {role.isSystem && (
                            <span title="System Protected">
                              <Shield className="h-3 w-3 text-emerald-500" />
                            </span>
                          )}
                        </div>
                        <p className="text-[11px] text-zinc-500 dark:text-zinc-400 line-clamp-1 max-w-xs mt-0.5">
                          {role.description || (isAr ? 'لا يوجد وصف مخصص' : 'No description provided')}
                        </p>
                      </div>
                    </div>
                  </td>

                  {/* System vs Custom Badge */}
                  <td className="py-3.5 px-6 whitespace-nowrap">
                    <Badge variant={role.isSystem ? 'success' : 'purple'} className="text-[11px] font-semibold">
                      {role.isSystem
                        ? isAr
                          ? 'أساسي ومحمي'
                          : 'System Protected'
                        : isAr
                        ? 'رتبة مخصصة'
                        : 'Custom Role'}
                    </Badge>
                  </td>

                  {/* Permissions Caps */}
                  <td className="py-3.5 px-6">
                    <div className="flex items-center flex-wrap gap-1.5">
                      {permsCount === 0 ? (
                        <span className="text-[11px] text-zinc-400 italic">
                          {isAr ? 'لا توجد صلاحيات إدارية' : 'No administrative permissions'}
                        </span>
                      ) : (
                        <>
                          {displayPerms.map((p) => (
                            <span
                              key={p}
                              className="inline-flex items-center gap-1 px-2 py-0.5 rounded-md text-[10px] font-mono font-medium bg-zinc-100 dark:bg-zinc-800 text-zinc-700 dark:text-zinc-300 border border-zinc-200/60 dark:border-zinc-700/60"
                            >
                              <Check className="h-2.5 w-2.5 text-emerald-500" />
                              {p}
                            </span>
                          ))}
                          {remainingCount > 0 && (
                            <button
                              type="button"
                              onClick={() => onManagePermissions(role)}
                              className="inline-flex items-center px-1.5 py-0.5 rounded-md text-[10px] font-mono font-bold bg-blue-50 dark:bg-blue-950/40 text-blue-600 dark:text-blue-400 hover:underline cursor-pointer border border-blue-200/60 dark:border-blue-800/60"
                            >
                              +{remainingCount} {isAr ? 'المزيد' : 'more'}
                            </button>
                          )}
                        </>
                      )}
                    </div>
                  </td>

                  {/* Users Count */}
                  <td className="py-3.5 px-6 text-center whitespace-nowrap">
                    <span className="inline-flex items-center gap-1 text-xs font-mono font-bold text-zinc-800 dark:text-zinc-200 bg-zinc-100 dark:bg-zinc-800/80 px-2.5 py-1 rounded-lg">
                      <Users className="h-3 w-3 text-zinc-400" />
                      {role.usersCount} {isAr ? 'مشرف' : 'users'}
                    </span>
                  </td>

                  {/* Actions */}
                  <td className="py-3.5 px-6 text-center whitespace-nowrap">
                    <div className="flex items-center justify-center gap-1">
                      {/* Manage Claims & Permissions */}
                      <button
                        type="button"
                        onClick={() => onManagePermissions(role)}
                        title={isAr ? 'إدارة الصلاحيات والـ Claims' : 'Manage Capabilities & Claims'}
                        className="flex h-8 w-8 items-center justify-center rounded-xl border border-zinc-200 dark:border-zinc-800 bg-zinc-50 hover:bg-blue-50 dark:bg-zinc-900 dark:hover:bg-blue-950/40 text-blue-600 dark:text-blue-400 hover:text-blue-700 transition-colors"
                      >
                        <ShieldCheck className="h-4 w-4" />
                      </button>

                      {/* Edit Role Info */}
                      <button
                        type="button"
                        onClick={() => onEdit(role)}
                        title={isAr ? 'تعديل بيانات الرتبة' : 'Edit Role Info'}
                        className="flex h-8 w-8 items-center justify-center rounded-xl border border-zinc-200 dark:border-zinc-800 bg-zinc-50 hover:bg-zinc-100 dark:bg-zinc-900 dark:hover:bg-zinc-800 text-zinc-600 dark:text-zinc-400 hover:text-zinc-950 dark:hover:text-white transition-colors"
                      >
                        <Edit2 className="h-4 w-4" />
                      </button>

                      {/* Delete */}
                      <button
                        type="button"
                        disabled={role.isSystem}
                        onClick={() => {
                          if (role.isSystem) return;
                          onDelete(role);
                        }}
                        title={
                          role.isSystem
                            ? (isAr ? 'رتبة نظام أساسية محمية من الحذف' : 'System role protected from deletion')
                            : (isAr ? 'حذف الرتبة' : 'Delete Role')
                        }
                        className={`flex h-8 w-8 items-center justify-center rounded-xl border transition-colors ${
                          role.isSystem
                            ? 'border-zinc-200/50 dark:border-zinc-800/50 opacity-30 cursor-not-allowed text-zinc-400'
                            : 'border-zinc-200 dark:border-zinc-800 bg-zinc-50 hover:bg-rose-50 dark:bg-zinc-900 dark:hover:bg-rose-950/40 text-zinc-600 hover:text-rose-600 dark:text-zinc-400 dark:hover:text-rose-400'
                        }`}
                      >
                        <Trash2 className="h-4 w-4" />
                      </button>
                    </div>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </Card>
  );
};
