import { useState, useEffect, useCallback } from 'react';
import type { RoleDefinition, PermissionGroup } from '../types';
import { rolesService } from '../services/rolesService';

export const useRolePermissions = (roleId: string | number | undefined) => {
  const [role, setRole] = useState<RoleDefinition | null>(null);
  const [permissionGroups, setPermissionGroups] = useState<PermissionGroup[]>([]);
  const [isLoading, setIsLoading] = useState(Boolean(roleId));
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    let isMounted = true;

    if (!roleId) {
      return;
    }

    Promise.all([
      rolesService.getRoleById(roleId),
      rolesService.getAvailablePermissions(),
    ])
      .then(([roleData, permsData]) => {
        if (isMounted) {
          setRole(roleData);
          setPermissionGroups(permsData);
        }
      })
      .catch(() => {
        if (isMounted) {
          setRole(null);
        }
      })
      .finally(() => {
        if (isMounted) {
          setIsLoading(false);
        }
      });

    return () => {
      isMounted = false;
    };
  }, [roleId]);

  const updatePermissions = useCallback(
    async (permissions: string[]): Promise<RoleDefinition> => {
      if (!role) throw new Error('Role not loaded');
      setIsSubmitting(true);
      try {
        const updated = await rolesService.updateRole(role.id, {
          name: role.name,
          description: role.description || '',
          permissions,
        });
        setRole(updated);
        return updated;
      } finally {
        setIsSubmitting(false);
      }
    },
    [role]
  );

  return {
    role,
    permissionGroups,
    isLoading,
    isSubmitting,
    updatePermissions,
  };
};
