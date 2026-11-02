using System;
using System.ComponentModel.DataAnnotations;

namespace Mahfazti.Core.Entities
{
    /// <summary>
    /// User device & UI preferences (biometric lock, hide balance, banner dismissals).
    /// </summary>
    public class UserPreference
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public string UserId { get; set; } = string.Empty;

        public bool IsBiometricEnabled { get; set; } = false;

        public bool IsBalanceHidden { get; set; } = false;

        [MaxLength(200)]
        public string? AppLockPinHash { get; set; }

        public bool NotificationsEnabled { get; set; } = true;

        public bool ShowAutoTrackingBanner { get; set; } = true;

        public string? DismissedCardsJson { get; set; } = "[]";

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public DateTime? UpdatedAt { get; set; }
    }
}
