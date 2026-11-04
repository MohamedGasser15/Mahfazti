using System.Collections.Generic;
using System.Threading.Tasks;
using Mahfazti.Core.DTOs.CategoryGroups;

namespace Mahfazti.Core.Interfaces
{
    public interface ICategoryGroupService
    {
        Task<List<CategoryGroupDto>> GetGroupsAsync(string userId);
        Task<CategoryGroupDto> CreateGroupAsync(string userId, CreateCategoryGroupDto dto);
        Task<CategoryGroupDto?> UpdateGroupAsync(string id, string userId, UpdateCategoryGroupDto dto);
        Task<bool> DeleteGroupAsync(string id, string userId);
        Task<bool> AssignCategoryToGroupAsync(string userId, AssignCategoryGroupDto dto);
        Task<Dictionary<int, string>> GetCategoryGroupMappingsAsync(string userId);
    }
}
