using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using Mahfazti.Core.DTOs.CategoryGroups;
using Mahfazti.Core.Entities;
using Mahfazti.Core.Interfaces;

namespace Mahfazti.Core.Services
{
    public class CategoryGroupService : ICategoryGroupService
    {
        private readonly IRepository<UserCategoryGroup> _groupRepo;
        private readonly IRepository<Category> _categoryRepo;
        private readonly ILogger<CategoryGroupService> _logger;

        public CategoryGroupService(
            IRepository<UserCategoryGroup> groupRepo,
            IRepository<Category> categoryRepo,
            ILogger<CategoryGroupService> logger)
        {
            _groupRepo = groupRepo;
            _categoryRepo = categoryRepo;
            _logger = logger;
        }

        public async Task<List<CategoryGroupDto>> GetGroupsAsync(string userId)
        {
            var groups = await _groupRepo.GetAllAsync(
                filter: g => g.UserId == userId,
                includeProperties: "Categories",
                orderBy: q => q.OrderBy(g => g.DisplayOrder).ThenBy(g => g.CreatedAt),
                isTracking: false
            );

            return groups.Select(g => new CategoryGroupDto
            {
                Id = g.Id,
                Name = g.Name,
                ColorValue = g.ColorValue,
                IconIndex = g.IconIndex,
                DisplayOrder = g.DisplayOrder,
                CreatedAt = g.CreatedAt,
                CategoriesCount = g.Categories?.Count ?? 0,
                CategoryIds = g.Categories?.Select(c => c.Id).ToList() ?? new List<int>()
            }).ToList();
        }

        public async Task<CategoryGroupDto> CreateGroupAsync(string userId, CreateCategoryGroupDto dto)
        {
            var entity = new UserCategoryGroup
            {
                Id = !string.IsNullOrWhiteSpace(dto.Id) ? dto.Id : Guid.NewGuid().ToString(),
                UserId = userId,
                Name = dto.Name.Trim(),
                ColorValue = dto.ColorValue,
                IconIndex = dto.IconIndex,
                DisplayOrder = dto.DisplayOrder,
                CreatedAt = DateTime.UtcNow
            };

            await _groupRepo.CreateAsync(entity);
            await _groupRepo.SaveAsync();

            return new CategoryGroupDto
            {
                Id = entity.Id,
                Name = entity.Name,
                ColorValue = entity.ColorValue,
                IconIndex = entity.IconIndex,
                DisplayOrder = entity.DisplayOrder,
                CreatedAt = entity.CreatedAt,
                CategoriesCount = 0,
                CategoryIds = new List<int>()
            };
        }

        public async Task<CategoryGroupDto?> UpdateGroupAsync(string id, string userId, UpdateCategoryGroupDto dto)
        {
            var entity = await _groupRepo.GetAsync(g => g.Id == id && g.UserId == userId, includeProperties: "Categories", isTracking: true);
            if (entity == null) return null;

            entity.Name = dto.Name.Trim();
            entity.ColorValue = dto.ColorValue;
            entity.IconIndex = dto.IconIndex;
            entity.DisplayOrder = dto.DisplayOrder;
            entity.UpdatedAt = DateTime.UtcNow;

            await _groupRepo.UpdateAsync(entity);
            await _groupRepo.SaveAsync();

            return new CategoryGroupDto
            {
                Id = entity.Id,
                Name = entity.Name,
                ColorValue = entity.ColorValue,
                IconIndex = entity.IconIndex,
                DisplayOrder = entity.DisplayOrder,
                CreatedAt = entity.CreatedAt,
                CategoriesCount = entity.Categories?.Count ?? 0,
                CategoryIds = entity.Categories?.Select(c => c.Id).ToList() ?? new List<int>()
            };
        }

        public async Task<bool> DeleteGroupAsync(string id, string userId)
        {
            var entity = await _groupRepo.GetAsync(g => g.Id == id && g.UserId == userId, isTracking: true);
            if (entity == null) return false;

            // Unlink any categories assigned to this group
            var linkedCategories = await _categoryRepo.GetAllAsync(c => c.GroupId == id, isTracking: true);
            foreach (var cat in linkedCategories)
            {
                cat.GroupId = null;
                await _categoryRepo.UpdateAsync(cat);
            }

            await _groupRepo.DeleteAsync(entity);
            await _groupRepo.SaveAsync();
            return true;
        }

        public async Task<bool> AssignCategoryToGroupAsync(string userId, AssignCategoryGroupDto dto)
        {
            var category = await _categoryRepo.GetAsync(
                c => c.Id == dto.CategoryId && (c.UserId == null || c.UserId == userId),
                isTracking: true);
            if (category == null) return false;

            if (!string.IsNullOrEmpty(dto.GroupId))
            {
                var groupExists = await _groupRepo.AnyAsync(g => g.Id == dto.GroupId && g.UserId == userId);
                if (!groupExists) return false;
            }

            category.GroupId = dto.GroupId;
            category.UpdatedAt = DateTime.UtcNow;

            await _categoryRepo.UpdateAsync(category);
            await _categoryRepo.SaveAsync();
            return true;
        }

        public async Task<Dictionary<int, string>> GetCategoryGroupMappingsAsync(string userId)
        {
            var groups = await _groupRepo.GetAllAsync(g => g.UserId == userId, includeProperties: "Categories", isTracking: false);
            var mappings = new Dictionary<int, string>();

            foreach (var g in groups)
            {
                if (g.Categories != null)
                {
                    foreach (var c in g.Categories)
                    {
                        mappings[c.Id] = g.Id;
                    }
                }
            }

            return mappings;
        }
    }
}
