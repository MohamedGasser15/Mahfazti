namespace Mahfazti.Core.DTOs.FinancialInstitution
{
    public class FinancialInstitutionDto
    {
        public string Id { get; set; } = string.Empty;
        public string NameAr { get; set; } = string.Empty;
        public string NameEn { get; set; } = string.Empty;
        public string ShortName { get; set; } = string.Empty;
        public string? SwiftCode { get; set; }
        public string Category { get; set; } = "egyptian";
        public string CountryCode { get; set; } = "EG";
        public string? LogoAsset { get; set; }
        public string? LogoUrl { get; set; }
        public string? Website { get; set; }
        public bool IsPopular { get; set; }
        public bool IsActive { get; set; }
    }
}
