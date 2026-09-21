using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Microsoft.IdentityModel.Tokens;
using Mahfazti.Core.Entities;
using Mahfazti.Core.Interfaces;

namespace Mahfazti.Core.Services
{
    public class TokenService : ITokenService
    {
        private readonly IConfiguration _config;
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly RoleManager<ApplicationRole> _roleManager;
        private readonly ILogger<TokenService> _logger;

        public TokenService(
            IConfiguration config,
            UserManager<ApplicationUser> userManager,
            RoleManager<ApplicationRole> roleManager,
            ILogger<TokenService> logger)
        {
            _config = config ?? throw new ArgumentNullException(nameof(config));
            _userManager = userManager ?? throw new ArgumentNullException(nameof(userManager));
            _roleManager = roleManager ?? throw new ArgumentNullException(nameof(roleManager));
            _logger = logger ?? throw new ArgumentNullException(nameof(logger));
        }

        public async Task<string> GenerateAccessToken(ApplicationUser user)
        {
            try
            {
                if (user == null)
                    throw new ArgumentNullException(nameof(user));

                _logger.LogInformation("Generating access token for user {UserId}", user.Id);

                var jwtKey = _config["Jwt:Key"] ?? _config["JWT:Key"];
                var jwtAudience = _config["Jwt:Audience"] ?? _config["JWT:Audience"];
                var jwtIssuer = _config["Jwt:Issuer"] ?? _config["JWT:Issuer"];

                if (string.IsNullOrEmpty(jwtKey))
                    throw new ArgumentException("JWT Key is not configured properly.");

                var tokenHandler = new JwtSecurityTokenHandler();
                var key = Encoding.UTF8.GetBytes(jwtKey);

                var claims = new List<Claim>
                {
                    new Claim(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
                    new Claim(JwtRegisteredClaimNames.Email, user.Email ?? ""),
                    new Claim(JwtRegisteredClaimNames.Name, user.UserName ?? ""),
                    new Claim("fullName", user.FullName ?? ""),
                    new Claim("phoneNumber", user.PhoneNumber ?? ""),
                    new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
                };

                // Add user roles and role claims
                var roles = await _userManager.GetRolesAsync(user);
                foreach (var roleName in roles)
                {
                    claims.Add(new Claim(ClaimTypes.Role, roleName));

                    var role = await _roleManager.FindByNameAsync(roleName);
                    if (role != null)
                    {
                        var roleClaims = await _roleManager.GetClaimsAsync(role);
                        claims.AddRange(roleClaims);
                    }
                }

                // Add user direct claims
                var userClaims = await _userManager.GetClaimsAsync(user);
                claims.AddRange(userClaims);

                var expiryStr = _config["Jwt:AccessTokenExpiryMinutes"] ?? _config["JWT:AccessTokenExpiryMinutes"];
                var accessTokenExpiryMinutes = int.TryParse(expiryStr, out var m) ? m : 10080; // default 7 days

                var tokenDescriptor = new SecurityTokenDescriptor
                {
                    Subject = new ClaimsIdentity(claims),
                    Expires = DateTime.UtcNow.AddMinutes(accessTokenExpiryMinutes),
                    NotBefore = DateTime.UtcNow,
                    IssuedAt = DateTime.UtcNow,
                    Issuer = jwtIssuer,
                    Audience = jwtAudience,
                    SigningCredentials = new SigningCredentials(
                        new SymmetricSecurityKey(key),
                        SecurityAlgorithms.HmacSha256Signature)
                };

                var token = tokenHandler.CreateToken(tokenDescriptor);
                var tokenString = tokenHandler.WriteToken(token);

                _logger.LogInformation("Access token generated successfully for user {UserId}", user.Id);
                return tokenString;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error occurred while generating access token for user {UserId}", user?.Id);
                throw;
            }
        }

        public string GenerateRefreshToken()
        {
            try
            {
                _logger.LogInformation("Generating refresh token");
                var randomNumber = new byte[32];
                using var rng = RandomNumberGenerator.Create();
                rng.GetBytes(randomNumber);
                return Convert.ToBase64String(randomNumber);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error generating refresh token");
                throw;
            }
        }

        public ClaimsPrincipal GetPrincipalFromExpiredToken(string token)
        {
            try
            {
                if (string.IsNullOrEmpty(token))
                    throw new ArgumentException("Token cannot be null or empty.", nameof(token));

                _logger.LogInformation("Extracting principal from expired token");

                var jwtKey = _config["Jwt:Key"] ?? _config["JWT:Key"];
                if (string.IsNullOrEmpty(jwtKey))
                    throw new ArgumentException("JWT Key is not configured properly.");

                var tokenValidationParameters = new TokenValidationParameters
                {
                    ValidateAudience = false,
                    ValidateIssuer = false,
                    ValidateIssuerSigningKey = true,
                    IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey)),
                    ValidateLifetime = false
                };

                var tokenHandler = new JwtSecurityTokenHandler();
                var principal = tokenHandler.ValidateToken(token, tokenValidationParameters, out var securityToken);

                if (securityToken is not JwtSecurityToken jwtSecurityToken)
                {
                    _logger.LogWarning("Invalid token security algorithm");
                    throw new SecurityTokenException("Invalid token");
                }

                var headerAlg = jwtSecurityToken.Header.Alg;
                var isValidAlg = headerAlg.Equals(SecurityAlgorithms.HmacSha256, StringComparison.InvariantCultureIgnoreCase)
                              || headerAlg.Equals("HS256", StringComparison.InvariantCultureIgnoreCase);

                if (!isValidAlg)
                {
                    _logger.LogWarning("Invalid token security algorithm");
                    throw new SecurityTokenException("Invalid token");
                }

                _logger.LogInformation("Principal extracted successfully from expired token");
                return principal;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error occurred while extracting principal from token");
                throw;
            }
        }
    }
}
