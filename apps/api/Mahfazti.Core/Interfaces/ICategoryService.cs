using Mahfazti.Core.DTOs.Category;

namespace Mahfazti.Core.Interfaces
{
    public interface ICategoryService
    {
        Task<IEnumerable<CategoryDto>> GetAllCategoriesAsync(string? userId = null);
        Task<CategoryDto?> GetCategoryByIdAsync(int id, string? userId = null);
        Task<CategoryDto> CreateCategoryAsync(CreateCategoryDto dto, string? userId = null);
        Task<CategoryDto?> UpdateCategoryAsync(UpdateCategoryDto dto, string? userId = null);
        Task<bool> DeleteCategoryAsync(int id, string? userId = null);
        Task<bool> RestoreCategoryAsync(int id, string? userId = null);
        Task<int> BulkRestoreCategoriesAsync(IEnumerable<int> ids, string? userId = null);
        Task<BulkDeleteResultDto> BulkDeleteCategoriesAsync(IEnumerable<int> ids, string? userId = null);
        Task SeedDefaultCategoriesForUserAsync(string userId);
        /// <summary>Returns the top N categories used most by this user, ordered by transaction count descending.</summary>
        Task<IEnumerable<CategoryDto>> GetMostUsedCategoriesAsync(string userId, int limit = 5);
    }
}
