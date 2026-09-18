using System.ComponentModel.DataAnnotations.Schema;

namespace Mahfazti.Core.Entities
{
    /// <summary>
    /// Represents a refresh token issued to a user for authentication
    /// </summary>
    public class RefreshToken
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public string Token { get; set; } = string.Empty;
        public DateTime Expiry { get; set; }
        public DateTime CreatedAt { get; set; }
        public bool IsRevoked { get; set; }

        [ForeignKey("UserId")]
        public ApplicationUser? User { get; set; }
    }
}
