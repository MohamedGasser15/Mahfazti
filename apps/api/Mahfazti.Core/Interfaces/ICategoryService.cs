using Mahfazti.Core.DTOs.Category;

namespace Mahfazti.Core.Interfaces
{
    public interface ICategoryService
    {
        Task<IEnumerable<CategoryDto>> GetAllCategoriesAsync();
        Task<CategoryDto?> GetCategoryByIdAsync(int id);
        Task<CategoryDto> CreateCategoryAsync(CreateCategoryDto dto);
        Task<CategoryDto?> UpdateCategoryAsync(UpdateCategoryDto dto);
        Task<bool> DeleteCategoryAsync(int id);
        Task<bool> RestoreCategoryAsync(int id);
        Task<int> BulkRestoreCategoriesAsync(IEnumerable<int> ids);
        Task<BulkDeleteResultDto> BulkDeleteCategoriesAsync(IEnumerable<int> ids);
    }
}
