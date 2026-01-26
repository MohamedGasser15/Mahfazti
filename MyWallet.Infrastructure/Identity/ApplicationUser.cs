using Microsoft.AspNetCore.Identity;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyWallet.Infrastructure.Identity
{
    public class ApplicationUser : IdentityUser<int>
    {
        public string FullName { get; set; } = string.Empty;

        public char Gender { get; set; } = 'M';

        public bool IsDeleted { get; set; } = false;

        public string? ImagePath { get; set; }
    }
}
