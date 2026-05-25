using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyWallet.Core.Entities
{
    public class ClaimSelection
    {
        public string ClaimType { get; set; }

        public string? Label { get; set; }

        public bool IsSelected { get; set; }
    }
}
