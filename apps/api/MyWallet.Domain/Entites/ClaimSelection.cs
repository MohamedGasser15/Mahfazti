using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyWallet.Domain.Entites
{
    public class ClaimSelection
    {
        public string ClaimType { get; set; }

        public string? Label { get; set; }

        public bool IsSelected { get; set; }
    }
}
