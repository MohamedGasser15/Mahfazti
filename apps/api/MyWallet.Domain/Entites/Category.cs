using MyWallet.Infrastructure.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyWallet.Domain.Entites
{
    public class Category
    {
        public int Id { get; set; }
        public string NameAr { get; set; } = string.Empty; 
        public string NameEn { get; set; } = string.Empty; 
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }

        public ICollection<WalletTransaction>? Transactions { get; set; }
    }
}
