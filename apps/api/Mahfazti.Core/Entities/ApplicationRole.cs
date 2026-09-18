using Microsoft.AspNetCore.Identity;

namespace Mahfazti.Core.Entities
{
    public class ApplicationRole : IdentityRole<int>
    {
        public bool IsDeleted { get; set; } = false;
    }
}
