using Microsoft.Extensions.Logging;
using Mahfazti.Core.DTOs.Category;
using Mahfazti.Core.Interfaces;
using Mahfazti.Core.Entities;

namespace Mahfazti.Core.Services
{
    public class CategoryService : ICategoryService
    {
        private readonly IRepository<Category> _categoryRepository;
        private readonly IRepository<WalletTransaction>? _transactionRepository;
        private readonly ILogger<CategoryService> _logger;

        public CategoryService(
            IRepository<Category> categoryRepository,
            ILogger<CategoryService> logger)
        {
            _categoryRepository = categoryRepository;
            _transactionRepository = null;
            _logger = logger;
        }

        public CategoryService(
            IRepository<Category> categoryRepository,
            IRepository<WalletTransaction> transactionRepository,
            ILogger<CategoryService> logger)
        {
            _categoryRepository = categoryRepository;
            _transactionRepository = transactionRepository;
            _logger = logger;
        }

        public async Task<IEnumerable<CategoryDto>> GetAllCategoriesAsync()
        {
            var categories = await _categoryRepository.GetAllAsync(
                includeProperties: "Transactions",
                orderBy: q => q.OrderBy(c => c.NameEn)
            );
            return categories.Select(c => new CategoryDto
            {
                Id = c.Id,
                NameAr = c.NameAr,
                NameEn = c.NameEn,
                Type = c.Type,
                Icon = c.Icon,
                IsActive = c.IsActive,
                TransactionCount = c.Transactions?.Count(t => !t.IsDeleted) ?? 0,
            });
        }

        public async Task<CategoryDto?> GetCategoryByIdAsync(int id)
        {
            var category = await _categoryRepository.GetAsync(c => c.Id == id, includeProperties: "Transactions");
            if (category == null) return null;
            return new CategoryDto
            {
                Id = category.Id,
                NameAr = category.NameAr,
                NameEn = category.NameEn,
                Type = category.Type,
                Icon = category.Icon,
                IsActive = category.IsActive,
                TransactionCount = category.Transactions?.Count(t => !t.IsDeleted) ?? 0,
            };
        }

        public async Task<CategoryDto> CreateCategoryAsync(CreateCategoryDto dto)
        {
            var category = new Category
            {
                NameAr = dto.NameAr,
                NameEn = dto.NameEn,
                Type = string.IsNullOrWhiteSpace(dto.Type) ? "Expense" : dto.Type,
                Icon = string.IsNullOrWhiteSpace(dto.Icon) ? "layers" : dto.Icon,
                IsActive = true,
            };
            await _categoryRepository.CreateAsync(category);
            return new CategoryDto
            {
                Id = category.Id,
                NameAr = category.NameAr,
                NameEn = category.NameEn,
                Type = category.Type,
                Icon = category.Icon,
                IsActive = category.IsActive,
                TransactionCount = 0,
            };
        }

        public async Task<CategoryDto?> UpdateCategoryAsync(UpdateCategoryDto dto)
        {
            var category = await _categoryRepository.GetAsync(c => c.Id == dto.Id, isTracking: true);
            if (category == null) return null;

            category.NameAr = dto.NameAr;
            category.NameEn = dto.NameEn;
            if (!string.IsNullOrWhiteSpace(dto.Type))
            {
                category.Type = dto.Type;
            }
            if (!string.IsNullOrWhiteSpace(dto.Icon))
            {
                category.Icon = dto.Icon;
            }
            category.UpdatedAt = DateTime.UtcNow;

            await _categoryRepository.UpdateAsync(category);
            return new CategoryDto
            {
                Id = category.Id,
                NameAr = category.NameAr,
                NameEn = category.NameEn,
                Type = category.Type,
                Icon = category.Icon,
                IsActive = category.IsActive,
            };
        }

        public async Task<bool> DeleteCategoryAsync(int id)
        {
            var category = await _categoryRepository.GetAsync(c => c.Id == id, isTracking: true);
            if (category == null) return false;

            // Check if category has any active transactions
            bool hasTransactions = false;
            if (_transactionRepository != null)
            {
                hasTransactions = await _transactionRepository.AnyAsync(t => t.CategoryId == id && !t.IsDeleted);
            }

            if (hasTransactions)
            {
                // Soft delete / Archive to protect historical financial integrity
                category.IsActive = false;
                category.UpdatedAt = DateTime.UtcNow;
                await _categoryRepository.UpdateAsync(category);
                _logger.LogInformation("Category #{Id} has transactions; archived (IsActive=false).", id);
            }
            else
            {
                // Permanent delete because no transactions exist
                await _categoryRepository.DeleteAsync(category);
                _logger.LogInformation("Category #{Id} has 0 transactions; permanently deleted.", id);
            }

            return true;
        }

        public async Task<bool> RestoreCategoryAsync(int id)
        {
            var category = await _categoryRepository.GetAsync(c => c.Id == id, isTracking: true);
            if (category == null) return false;

            category.IsActive = true;
            category.UpdatedAt = DateTime.UtcNow;
            await _categoryRepository.UpdateAsync(category);
            _logger.LogInformation("Category #{Id} restored to active state.", id);
            return true;
        }

        public async Task<int> BulkRestoreCategoriesAsync(IEnumerable<int> ids)
        {
            if (ids == null) return 0;
            var distinctIds = ids.Distinct().ToList();
            if (distinctIds.Count == 0) return 0;

            int restoredCount = 0;
            foreach (var id in distinctIds)
            {
                var category = await _categoryRepository.GetAsync(c => c.Id == id, isTracking: true);
                if (category != null && !category.IsActive)
                {
                    category.IsActive = true;
                    category.UpdatedAt = DateTime.UtcNow;
                    await _categoryRepository.UpdateAsync(category);
                    restoredCount++;
                }
            }
            _logger.LogInformation("Bulk restored {Count} categories.", restoredCount);
            return restoredCount;
        }

        public async Task<BulkDeleteResultDto> BulkDeleteCategoriesAsync(IEnumerable<int> ids)
        {
            var distinctIds = ids?.Distinct().ToList() ?? new List<int>();
            var result = new BulkDeleteResultDto
            {
                TotalRequested = distinctIds.Count
            };

            foreach (var id in distinctIds)
            {
                var category = await _categoryRepository.GetAsync(c => c.Id == id, isTracking: true);
                if (category == null) continue;

                bool hasTransactions = false;
                if (_transactionRepository != null)
                {
                    hasTransactions = await _transactionRepository.AnyAsync(t => t.CategoryId == id && !t.IsDeleted);
                }

                if (hasTransactions)
                {
                    category.IsActive = false;
                    category.UpdatedAt = DateTime.UtcNow;
                    await _categoryRepository.UpdateAsync(category);
                    result.ArchivedCount++;
                }
                else
                {
                    await _categoryRepository.DeleteAsync(category);
                    result.DeletedCount++;
                }

                result.ProcessedIds.Add(id);
            }

            result.Message = $"Successfully processed {result.ProcessedIds.Count} categories ({result.DeletedCount} deleted, {result.ArchivedCount} archived).";
            return result;
        }

    }
}