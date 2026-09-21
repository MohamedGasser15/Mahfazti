using System.Collections.Generic;

namespace Mahfazti.Core.DTOs.Role
{
    public class PermissionItemDto
    {
        public string Code { get; set; } = string.Empty;
        public string NameEn { get; set; } = string.Empty;
        public string NameAr { get; set; } = string.Empty;
        public string DescriptionEn { get; set; } = string.Empty;
        public string DescriptionAr { get; set; } = string.Empty;
    }

    public class PermissionGroupDto
    {
        public string GroupKey { get; set; } = string.Empty;
        public string GroupNameEn { get; set; } = string.Empty;
        public string GroupNameAr { get; set; } = string.Empty;
        public List<PermissionItemDto> Permissions { get; set; } = new();
    }
}
