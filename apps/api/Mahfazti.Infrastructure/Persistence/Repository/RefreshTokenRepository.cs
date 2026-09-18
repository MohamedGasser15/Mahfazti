using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Mahfazti.Core.Entities;
using Mahfazti.Core.Interfaces;
using Mahfazti.Infrastructure.Data;

namespace Mahfazti.Infrastructure.Persistence.Repository
{
    /// <summary>
    /// Repository implementation for managing refresh tokens in the database.
    /// </summary>
    public class RefreshTokenRepository : IRefreshTokenRepository
    {
        private readonly ApplicationDbContext _context;
        private readonly ILogger<RefreshTokenRepository> _logger;

        public RefreshTokenRepository(ApplicationDbContext context, ILogger<RefreshTokenRepository> logger)
        {
            _context = context ?? throw new ArgumentNullException(nameof(context));
            _logger = logger ?? throw new ArgumentNullException(nameof(logger));
        }

        public async Task SaveRefreshTokenAsync(string userId, string refreshToken, DateTime expiry)
        {
            try
            {
                if (string.IsNullOrEmpty(userId))
                    throw new ArgumentException("User ID cannot be null or empty.", nameof(userId));

                if (string.IsNullOrEmpty(refreshToken))
                    throw new ArgumentException("Refresh token cannot be null or empty.", nameof(refreshToken));

                if (expiry <= DateTime.UtcNow)
                    throw new ArgumentException("Expiry date must be in the future.", nameof(expiry));

                if (!int.TryParse(userId, out int parsedUserId))
                    throw new ArgumentException("Invalid user ID format.", nameof(userId));

                _logger.LogInformation("Saving refresh token for user {UserId}", userId);

                var token = new RefreshToken
                {
                    UserId = parsedUserId,
                    Token = refreshToken,
                    Expiry = expiry,
                    CreatedAt = DateTime.UtcNow,
                    IsRevoked = false
                };

                _context.RefreshTokens.Add(token);
                await _context.SaveChangesAsync();

                _logger.LogInformation("Refresh token saved successfully for user {UserId}", userId);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error while saving refresh token for user {UserId}", userId);
                throw;
            }
        }

        public async Task<bool> ValidateRefreshTokenAsync(string userId, string refreshToken)
        {
            try
            {
                if (string.IsNullOrEmpty(userId) || string.IsNullOrEmpty(refreshToken))
                    return false;

                if (!int.TryParse(userId, out int parsedUserId))
                    return false;

                _logger.LogInformation("Validating refresh token for user {UserId}", userId);

                var token = await _context.RefreshTokens
                    .Where(rt => rt.UserId == parsedUserId &&
                                 rt.Token == refreshToken &&
                                 rt.Expiry > DateTime.UtcNow &&
                                 !rt.IsRevoked)
                    .FirstOrDefaultAsync();

                bool isValid = token != null;
                _logger.LogInformation("Refresh token validation for user {UserId}: {IsValid}", userId, isValid);

                return isValid;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error occurred while validating refresh token for user {UserId}", userId);
                throw;
            }
        }

        public async Task UpdateRefreshTokenAsync(string userId, string oldRefreshToken, string newRefreshToken, DateTime newExpiry)
        {
            try
            {
                if (string.IsNullOrEmpty(userId) || string.IsNullOrEmpty(oldRefreshToken) || string.IsNullOrEmpty(newRefreshToken))
                    throw new ArgumentException("Invalid parameters for update refresh token");

                if (!int.TryParse(userId, out int parsedUserId))
                    throw new ArgumentException("Invalid user ID format.", nameof(userId));

                _logger.LogInformation("Updating refresh token for user {UserId}", userId);

                var oldToken = await _context.RefreshTokens
                    .Where(rt => rt.UserId == parsedUserId && rt.Token == oldRefreshToken)
                    .FirstOrDefaultAsync();

                if (oldToken != null)
                {
                    oldToken.IsRevoked = true;
                }

                var newToken = new RefreshToken
                {
                    UserId = parsedUserId,
                    Token = newRefreshToken,
                    Expiry = newExpiry,
                    CreatedAt = DateTime.UtcNow,
                    IsRevoked = false
                };

                _context.RefreshTokens.Add(newToken);
                await _context.SaveChangesAsync();

                _logger.LogInformation("Refresh token updated successfully for user {UserId}", userId);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error occurred while updating refresh token for user {UserId}", userId);
                throw;
            }
        }

        public async Task RevokeRefreshTokenAsync(string userId, string refreshToken)
        {
            try
            {
                if (string.IsNullOrEmpty(userId) || string.IsNullOrEmpty(refreshToken))
                    return;

                if (!int.TryParse(userId, out int parsedUserId))
                    return;

                _logger.LogInformation("Revoking refresh token for user {UserId}", userId);

                var token = await _context.RefreshTokens
                    .Where(rt => rt.UserId == parsedUserId && rt.Token == refreshToken)
                    .FirstOrDefaultAsync();

                if (token != null)
                {
                    token.IsRevoked = true;
                    await _context.SaveChangesAsync();
                    _logger.LogInformation("Refresh token revoked successfully for user {UserId}", userId);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error occurred while revoking refresh token for user {UserId}", userId);
                throw;
            }
        }

        public async Task RevokeAllRefreshTokensAsync(string userId)
        {
            try
            {
                if (string.IsNullOrEmpty(userId))
                    return;

                if (!int.TryParse(userId, out int parsedUserId))
                    return;

                _logger.LogInformation("Revoking all refresh tokens for user {UserId}", userId);

                var tokens = await _context.RefreshTokens
                    .Where(rt => rt.UserId == parsedUserId && !rt.IsRevoked)
                    .ToListAsync();

                if (tokens.Any())
                {
                    foreach (var token in tokens)
                    {
                        token.IsRevoked = true;
                    }

                    await _context.SaveChangesAsync();
                    _logger.LogInformation("All {TokenCount} refresh tokens revoked for user {UserId}", tokens.Count, userId);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error occurred while revoking all refresh tokens for user {UserId}", userId);
                throw;
            }
        }
    }
}
