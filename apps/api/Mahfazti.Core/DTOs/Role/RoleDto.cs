using System;
using System.Collections.Generic;

namespace Mahfazti.Core.DTOs.Role
{
    public class RoleDto
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        public bool IsSystem { get; set; }
        public int UsersCount { get; set; }
        public DateTime CreatedAt { get; set; }
        public List<string> Permissions { get; set; } = new();
    }
}
