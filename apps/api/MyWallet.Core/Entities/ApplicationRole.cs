using Microsoft.AspNetCore.Identity;

namespace MyWallet.Core.Entities
{
    public class ApplicationRole : IdentityRole<int>
    {
        public bool IsDeleted { get; set; } = false;
    }
}
