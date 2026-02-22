using Microsoft.Extensions.Logging;
using MyWallet.Application.DTOs.Category;
using MyWallet.Application.ServiceInterfaces;
using MyWallet.Domain.Entites;
using MyWallet.Infrastructure.Persistence.IRepository;

namespace MyWallet.Application.Services
{
    public class CategoryService : ICategoryService
    {
        private readonly IRepository<Category> _categoryRepository;
        private readonly ILogger<CategoryService> _logger;

        public CategoryService(
            IRepository<Category> categoryRepository,
            ILogger<CategoryService> logger)
        {
            _categoryRepository = categoryRepository;
            _logger = logger;
        }

        public async Task<IEnumerable<CategoryDto>> GetAllCategoriesAsync()
        {
            var categories = await _categoryRepository.GetAllAsync(
                orderBy: q => q.OrderBy(c => c.NameEn)
            );
            return categories.Select(c => new CategoryDto
            {
                Id = c.Id,
                NameAr = c.NameAr,
                NameEn = c.NameEn,
            });
        }

        public async Task<CategoryDto?> GetCategoryByIdAsync(int id)
        {
            var category = await _categoryRepository.GetAsync(c => c.Id == id);
            if (category == null) return null;
            return new CategoryDto
            {
                Id = category.Id,
                NameAr = category.NameAr,
                NameEn = category.NameEn,
            };
        }

        public async Task<CategoryDto> CreateCategoryAsync(CreateCategoryDto dto)
        {
            var category = new Category
            {
                NameAr = dto.NameAr,
                NameEn = dto.NameEn,
            };
            await _categoryRepository.CreateAsync(category);
            return new CategoryDto
            {
                Id = category.Id,
                NameAr = category.NameAr,
                NameEn = category.NameEn,
            };
        }

        public async Task<CategoryDto?> UpdateCategoryAsync(UpdateCategoryDto dto)
        {
            var category = await _categoryRepository.GetAsync(c => c.Id == dto.Id, isTracking: true);
            if (category == null) return null;

            category.NameAr = dto.NameAr;
            category.NameEn = dto.NameEn;
            category.UpdatedAt = DateTime.UtcNow;

            await _categoryRepository.UpdateAsync(category);
            return new CategoryDto
            {
                Id = category.Id,
                NameAr = category.NameAr,
                NameEn = category.NameEn,
            };
        }

        public async Task<bool> DeleteCategoryAsync(int id)
        {
            var category = await _categoryRepository.GetAsync(c => c.Id == id, isTracking: true);
            if (category == null) return false;

            // Hard delete أو Soft delete حسب رغبتك (ملاحظة: إذا كان هناك معاملات مرتبطة بهذا التصنيف، قد تحتاج لتعامل مختلف)
            await _categoryRepository.DeleteAsync(category);
            return true;
        }

        // تم إزالة ActivateCategoryAsync نهائياً لأنه لا يوجد حقل IsActive
    }
}