using System.ComponentModel.DataAnnotations;

namespace Mahfazti.Core.DTOs.Auth
{
    public class RefreshTokenRequestDTO
    {
        [Required(ErrorMessage = "Access token is required")]
        public string AccessToken { get; set; } = string.Empty;

        [Required(ErrorMessage = "Refresh token is required")]
        public string RefreshToken { get; set; } = string.Empty;
    }
}
