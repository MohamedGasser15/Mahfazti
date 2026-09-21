using System.Collections.Generic;
using System.Threading.Tasks;
using Mahfazti.Core.DTOs.Role;

namespace Mahfazti.Core.Interfaces
{
    public interface IRoleService
    {
        Task<List<RoleDto>> GetAllRolesAsync();
        Task<RoleDto?> GetRoleByIdAsync(int id);
        Task<RoleDto> CreateRoleAsync(CreateRoleDto dto);
        Task<RoleDto> UpdateRoleAsync(int id, UpdateRoleDto dto);
        Task<bool> DeleteRoleAsync(int id);
        List<PermissionGroupDto> GetAvailablePermissions();
    }
}
