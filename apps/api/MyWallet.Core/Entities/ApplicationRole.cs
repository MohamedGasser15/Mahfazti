using Microsoft.AspNetCore.Identity;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyWallet.Core.Entities
{
    public class ApplicationRole : IdentityRole<int>
    {
        public bool IsDeleted { get; set; } = false;
    }
}
