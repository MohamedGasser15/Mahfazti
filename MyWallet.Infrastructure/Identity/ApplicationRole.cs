using Microsoft.AspNetCore.Identity;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyWallet.Infrastructure.Identity
{
    public class ApplicationRole : IdentityRole<int>
    {
        public bool IsDeleted { get; set; } = false;
    }
}
