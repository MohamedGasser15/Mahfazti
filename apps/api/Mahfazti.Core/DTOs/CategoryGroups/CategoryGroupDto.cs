using System;
using System.Collections.Generic;

namespace Mahfazti.Core.DTOs.CategoryGroups
{
    public class CategoryGroupDto
    {
        public string Id { get; set; } = string.Empty;
        public string Name { get; set; } = string.Empty;
        public int ColorValue { get; set; }
        public int IconIndex { get; set; }
        public int DisplayOrder { get; set; }
        public DateTime CreatedAt { get; set; }
        public int CategoriesCount { get; set; }
        public List<int> CategoryIds { get; set; } = new();
    }

    public class CreateCategoryGroupDto
    {
        public string? Id { get; set; } // Can pass client GUID or generated
        public string Name { get; set; } = string.Empty;
        public int ColorValue { get; set; } = unchecked((int)0xFF6366F1);
        public int IconIndex { get; set; } = 0;
        public int DisplayOrder { get; set; } = 0;
    }

    public class UpdateCategoryGroupDto
    {
        public string Name { get; set; } = string.Empty;
        public int ColorValue { get; set; }
        public int IconIndex { get; set; }
        public int DisplayOrder { get; set; }
    }

    public class AssignCategoryGroupDto
    {
        public int CategoryId { get; set; }
        public string? GroupId { get; set; } // null to unassign
    }
}
