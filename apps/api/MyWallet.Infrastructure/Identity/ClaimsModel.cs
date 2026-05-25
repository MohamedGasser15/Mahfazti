
using MyWallet.Core.Entities;

namespace MyWallet.Infrastructure.Identity
{
    public class ClaimsModel
    {
        public int RoleId { get; set; }

        public List<ClaimSelection> HistoryClaimList { get; set; } = new();
        public List<ClaimSelection> UserClaimList { get; set; } = new();
        public List<ClaimSelection> RoleClaimList { get; set; } = new();


        public ClaimsModel()
        {
            HistoryClaimList = new();
            UserClaimList = new();
            RoleClaimList = new();
        }
    }
}
