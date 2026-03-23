using System;

namespace MyWallet.Application.Common.Constants
{
    public static class SD
    {
        public const string JwtScheme = "JwtBearer";
        public const string AllowAllCors = "AllowAll";
        public const string DefaultPolicy = "DefaultPolicy";
        public const string AdminPolicy = "AdminOnly";
        public const string OfficerPolicy = "OfficerOnly";
        public const string MedicPolicy = "MedicOnly";

        public const string JwtIssuerConfig = "Jwt:Issuer";
        public const string JwtAudienceConfig = "Jwt:Audience";
        public const string JwtKeyConfig = "Jwt:Key";
        public const string BearerScheme = "Bearer";

        public const string ApiTitle = "Fujuirah Police Services API Docs";
        public const string ApiVersion = "v1.0.0";
        public const string ApiDescription = "This is the API documentation for Fujuirah Police Services API.";

        public static readonly string[] AllowedOrigins = new[]
{
            "https://localhost:7141",
            "http://localhost:63054",
            "http://localhost:3000",
            "http://localhost:5500",
            "https://nahaatik.runasp.net",
            "https://nhaatek.fujpolice.org",
            "https://permit.fujpolice.org"
        };

    }
}
