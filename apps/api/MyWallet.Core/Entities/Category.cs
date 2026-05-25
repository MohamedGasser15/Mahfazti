using System;
using System.Collections.Generic;

namespace MyWallet.Core.Entities
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
