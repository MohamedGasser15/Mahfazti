using Mahfazti.Core.DTOs.User;

namespace Mahfazti.Core.Interfaces
{
    public interface IAdminUserService
    {
        Task<List<AdminUserDto>> GetAllUsersAsync();
        Task<AdminUserDto?> GetUserByIdAsync(int id);
        Task<AdminUserDto> CreateUserAsync(CreateAdminUserDto dto);
        Task<AdminUserDto?> UpdateUserAsync(int id, UpdateAdminUserDto dto);
        Task<AdminUserDto?> ToggleUserStatusAsync(int id);
        Task<AdminUserDto?> UpdateUserRoleAsync(int id, string role);
        Task<int> BulkUpdateUserStatusAsync(List<int> userIds, bool isActive);
        Task<bool> DeleteUserAsync(int id, int? currentUserId = null);
        Task<int> BulkDeleteUsersAsync(List<int> userIds, int? currentUserId = null);
    }
}
