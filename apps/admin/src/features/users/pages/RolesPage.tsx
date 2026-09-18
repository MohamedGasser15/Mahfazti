import React, { useState, useEffect } from 'react';
import { ShieldCheck, Plus, Users, Check, Key } from 'lucide-react';
import { usersService } from '../services/usersService';
import type { RoleDefinition } from '../types';
import { Card } from '../../../core/components/ui/Card';
import { Badge } from '../../../core/components/ui/Badge';
import { Button } from '../../../core/components/ui/Button';

export const RolesPage: React.FC = () => {
  const [roles, setRoles] = useState<RoleDefinition[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    usersService.getRoles().then((data) => {
      setRoles(data);
      setIsLoading(false);
    });
  }, []);

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-zinc-900 dark:text-white flex items-center gap-2">
            <ShieldCheck className="h-6 w-6 text-blue-600 dark:text-blue-500" />
            Roles & Permissions Matrix
          </h1>
          <p className="text-sm text-zinc-500 dark:text-zinc-400">
            Configure administrative roles, granular access levels, and team capabilities.
          </p>
        </div>
        <Button variant="primary" size="md">
          <Plus className="h-4 w-4" />
          <span>Create Custom Role</span>
        </Button>
      </div>

      {/* Roles Grid */}
      {isLoading ? (
        <div className="p-8 text-center text-zinc-400 text-xs">Loading roles...</div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {roles.map((role) => (
            <Card key={role.id} className="p-6 flex flex-col justify-between space-y-4">
              <div>
                <div className="flex items-start justify-between gap-2">
                  <div className="flex items-center gap-2.5">
                    <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-zinc-100 dark:bg-zinc-800 text-zinc-900 dark:text-white font-bold">
                      <Key className="h-5 w-5 text-blue-600 dark:text-blue-400" />
                    </div>
                    <div>
                      <h3 className="text-base font-bold text-zinc-900 dark:text-white">
                        {role.name}
                      </h3>
                      <div className="flex items-center gap-2 mt-0.5">
                        <span className="text-xs font-mono text-zinc-400 dark:text-zinc-500">
                          @{role.slug}
                        </span>
                        <span className="text-zinc-300 dark:text-zinc-700">&bull;</span>
                        <div className="flex items-center gap-1 text-xs text-zinc-500 dark:text-zinc-400 font-medium">
                          <Users className="h-3.5 w-3.5" />
                          <span>{role.usersCount} assigned</span>
                        </div>
                      </div>
                    </div>
                  </div>

                  <Badge variant={role.isSystem ? 'info' : 'default'}>
                    {role.isSystem ? 'System Default' : 'Custom'}
                  </Badge>
                </div>

                <p className="text-xs text-zinc-600 dark:text-zinc-400 mt-3 leading-relaxed">
                  {role.description}
                </p>

                {/* Permissions Badges */}
                <div className="mt-4 pt-3 border-t border-zinc-100 dark:border-zinc-800">
                  <span className="text-[11px] font-bold uppercase tracking-wider text-zinc-400 dark:text-zinc-500 block mb-2">
                    Granted Permissions ({role.permissions.length})
                  </span>
                  <div className="flex flex-wrap gap-1.5">
                    {role.permissions.map((perm) => (
                      <span
                        key={perm}
                        className="inline-flex items-center gap-1 rounded-md bg-zinc-100 dark:bg-zinc-800/80 px-2 py-1 font-mono text-[10px] font-medium text-zinc-700 dark:text-zinc-300 border border-zinc-200/50 dark:border-zinc-700/50"
                      >
                        <Check className="h-2.5 w-2.5 text-emerald-500" />
                        {perm}
                      </span>
                    ))}
                  </div>
                </div>
              </div>

              {/* Actions Footer */}
              <div className="flex items-center justify-between pt-2 border-t border-zinc-100 dark:border-zinc-800">
                <span className="text-[11px] text-zinc-400">
                  {role.isSystem ? 'Built-in role (Protected)' : 'Editable permissions'}
                </span>
                <div className="flex items-center gap-2">
                  <Button size="sm" variant="outline">
                    Edit Capabilities
                  </Button>
                </div>
              </div>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
};
