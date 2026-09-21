using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace Mahfazti.Core.DTOs.Role
{
    public class UpdateRoleDto
    {
        [Required(ErrorMessage = "Role name is required")]
        [StringLength(50, MinimumLength = 2, ErrorMessage = "Role name must be between 2 and 50 characters")]
        public string Name { get; set; } = string.Empty;

        [StringLength(250, ErrorMessage = "Description cannot exceed 250 characters")]
        public string? Description { get; set; }

        public List<string> Permissions { get; set; } = new();
    }
}
