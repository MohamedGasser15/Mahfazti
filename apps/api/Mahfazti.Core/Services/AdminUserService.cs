using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Mahfazti.Core.Constants;
using Mahfazti.Core.DTOs.User;
using Mahfazti.Core.Entities;
using Mahfazti.Core.Interfaces;

namespace Mahfazti.Core.Services
{
    public class AdminUserService : IAdminUserService
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly RoleManager<ApplicationRole> _roleManager;
        private readonly ILogger<AdminUserService> _logger;
        private readonly IRepository<WalletTransaction>? _transactionRepository;
        private readonly IRepository<UserBudget>? _budgetRepository;

        public AdminUserService(
            UserManager<ApplicationUser> userManager,
            RoleManager<ApplicationRole> roleManager,
            ILogger<AdminUserService> logger,
            IRepository<WalletTransaction>? transactionRepository = null,
            IRepository<UserBudget>? budgetRepository = null)
        {
            _userManager = userManager ?? throw new ArgumentNullException(nameof(userManager));
            _roleManager = roleManager ?? throw new ArgumentNullException(nameof(roleManager));
            _logger = logger ?? throw new ArgumentNullException(nameof(logger));
            _transactionRepository = transactionRepository;
            _budgetRepository = budgetRepository;
        }

        public async Task<List<AdminUserDto>> GetAllUsersAsync()
        {
            _logger.LogInformation("Fetching all users for admin management");

            var users = await _userManager.Users
                .Where(u => !u.IsDeleted)
                .OrderByDescending(u => u.CreatedAt)
                .ToListAsync();

            var dtos = new List<AdminUserDto>();
            foreach (var user in users)
            {
                dtos.Add(await MapToAdminUserDtoAsync(user));
            }

            return dtos;
        }

        public async Task<AdminUserDto?> GetUserByIdAsync(int id)
        {
            var user = await _userManager.Users
                .FirstOrDefaultAsync(u => u.Id == id && !u.IsDeleted);

            if (user == null)
            {
                _logger.LogWarning("User with ID {UserId} not found or deleted", id);
                return null;
            }

            return await MapToAdminUserDtoAsync(user);
        }

        public async Task<AdminUserDto> CreateUserAsync(CreateAdminUserDto dto)
        {
            var normalizedEmail = dto.Email.Trim().ToLowerInvariant();
            _logger.LogInformation("Admin creating user with email {Email} and role {Role}", normalizedEmail, dto.Role);

            var existingByEmail = await _userManager.FindByEmailAsync(normalizedEmail);
            var existingByName = await _userManager.FindByNameAsync(normalizedEmail);
            if (existingByEmail != null || existingByName != null)
            {
                throw new InvalidOperationException($"هذا البريد الإلكتروني مسجل بالفعل لمستخدم آخر (User with email '{normalizedEmail}' already exists).");
            }

            var user = new ApplicationUser
            {
                UserName = normalizedEmail,
                Email = normalizedEmail,
                FullName = dto.FullName.Trim(),
                Currency = string.IsNullOrWhiteSpace(dto.Currency) ? "EGP" : dto.Currency.Trim().ToUpperInvariant(),
                EmailConfirmed = dto.EmailConfirmed,
                IsBanned = false,
                CreatedAt = DateTime.UtcNow
            };

            var password = string.IsNullOrWhiteSpace(dto.Password) ? "User@123456" : dto.Password;
            var result = await _userManager.CreateAsync(user, password);
            if (!result.Succeeded)
            {
                var isDuplicate = result.Errors.Any(e => e.Code.Contains("Duplicate", StringComparison.OrdinalIgnoreCase) ||
                                                         e.Description.Contains("already taken", StringComparison.OrdinalIgnoreCase));
                if (isDuplicate)
                {
                    throw new InvalidOperationException($"هذا البريد الإلكتروني مسجل بالفعل لمستخدم آخر (User with email '{normalizedEmail}' already exists).");
                }

                var errors = string.Join("; ", result.Errors.Select(e => e.Description));
                throw new InvalidOperationException($"Failed to create user: {errors}");
            }

            // Ensure role exists and assign
            var targetRole = NormalizeRole(dto.Role);
            if (!await _roleManager.RoleExistsAsync(targetRole))
            {
                await _roleManager.CreateAsync(new ApplicationRole { Name = targetRole });
            }
            await _userManager.AddToRoleAsync(user, targetRole);

            return await MapToAdminUserDtoAsync(user);
        }

        public async Task<AdminUserDto?> UpdateUserAsync(int id, UpdateAdminUserDto dto)
        {
            var user = await _userManager.Users
                .FirstOrDefaultAsync(u => u.Id == id && !u.IsDeleted);

            if (user == null) return null;

            var normalizedEmail = dto.Email.Trim().ToLowerInvariant();

            // Check if email is being changed and conflicts with another user
            if (!string.Equals(user.Email, normalizedEmail, StringComparison.OrdinalIgnoreCase))
            {
                var conflictEmail = await _userManager.FindByEmailAsync(normalizedEmail);
                var conflictName = await _userManager.FindByNameAsync(normalizedEmail);
                if ((conflictEmail != null && conflictEmail.Id != id) || (conflictName != null && conflictName.Id != id))
                {
                    throw new InvalidOperationException($"هذا البريد الإلكتروني مسجل بالفعل لمستخدم آخر (User with email '{normalizedEmail}' already exists).");
                }

                user.Email = normalizedEmail;
                user.UserName = normalizedEmail;
            }

            user.FullName = dto.FullName.Trim();
            user.Currency = string.IsNullOrWhiteSpace(dto.Currency) ? "EGP" : dto.Currency.Trim().ToUpperInvariant();
            user.EmailConfirmed = dto.EmailConfirmed;

            var result = await _userManager.UpdateAsync(user);
            if (!result.Succeeded)
            {
                var errors = string.Join("; ", result.Errors.Select(e => e.Description));
                throw new InvalidOperationException($"Failed to update user: {errors}");
            }

            // Update role if changed
            var targetRole = NormalizeRole(dto.Role);
            if (!await _roleManager.RoleExistsAsync(targetRole))
            {
                await _roleManager.CreateAsync(new ApplicationRole { Name = targetRole });
            }

            var currentRoles = await _userManager.GetRolesAsync(user);
            if (!currentRoles.Contains(targetRole))
            {
                if (currentRoles.Any())
                {
                    await _userManager.RemoveFromRolesAsync(user, currentRoles);
                }
                await _userManager.AddToRoleAsync(user, targetRole);
            }

            _logger.LogInformation("User {UserId} updated successfully by admin", id);
            return await MapToAdminUserDtoAsync(user);
        }

        public async Task<AdminUserDto?> ToggleUserStatusAsync(int id)
        {
            var user = await _userManager.Users
                .FirstOrDefaultAsync(u => u.Id == id && !u.IsDeleted);

            if (user == null) return null;

            user.IsBanned = !user.IsBanned;
            var result = await _userManager.UpdateAsync(user);
            if (!result.Succeeded)
            {
                var errors = string.Join("; ", result.Errors.Select(e => e.Description));
                throw new InvalidOperationException($"Failed to toggle user status: {errors}");
            }

            _logger.LogInformation("User {UserId} IsBanned toggled to {IsBanned}", id, user.IsBanned);
            return await MapToAdminUserDtoAsync(user);
        }

        public async Task<AdminUserDto?> UpdateUserRoleAsync(int id, string role)
        {
            var user = await _userManager.Users
                .FirstOrDefaultAsync(u => u.Id == id && !u.IsDeleted);

            if (user == null) return null;

            var targetRole = NormalizeRole(role);
            if (!await _roleManager.RoleExistsAsync(targetRole))
            {
                await _roleManager.CreateAsync(new ApplicationRole { Name = targetRole });
            }

            var currentRoles = await _userManager.GetRolesAsync(user);
            if (currentRoles.Any())
            {
                await _userManager.RemoveFromRolesAsync(user, currentRoles);
            }

            await _userManager.AddToRoleAsync(user, targetRole);
            _logger.LogInformation("User {UserId} role updated to {Role}", id, targetRole);

            return await MapToAdminUserDtoAsync(user);
        }

        public async Task<int> BulkUpdateUserStatusAsync(List<int> userIds, bool isActive)
        {
            if (userIds == null || !userIds.Any()) return 0;

            var distinctIds = userIds.Distinct().ToList();
            var users = await _userManager.Users
                .Where(u => distinctIds.Contains(u.Id) && !u.IsDeleted)
                .ToListAsync();

            var updatedCount = 0;
            foreach (var user in users)
            {
                user.IsBanned = !isActive;
                var res = await _userManager.UpdateAsync(user);
                if (res.Succeeded)
                {
                    updatedCount++;
                }
            }

            _logger.LogInformation("Bulk updated {Count} users to IsActive={IsActive}", updatedCount, isActive);
            return updatedCount;
        }

        public async Task<bool> DeleteUserAsync(int id, int? currentUserId = null)
        {
            if (currentUserId.HasValue && currentUserId.Value == id)
            {
                _logger.LogWarning("Self-deletion prevented for user {UserId}", id);
                throw new InvalidOperationException("لا يمكنك حذف حسابك الخاص (You cannot delete your own account)");
            }

            var user = await _userManager.FindByIdAsync(id.ToString());
            if (user == null) return false;

            var userIdString = id.ToString();

            // 1. Delete all wallet transactions related to this user
            if (_transactionRepository != null)
            {
                var transactions = await _transactionRepository.GetAllAsync(t => t.UserId == userIdString);
                if (transactions != null && transactions.Any())
                {
                    await _transactionRepository.DeleteRangeAsync(transactions);
                    await _transactionRepository.SaveAsync();
                    _logger.LogInformation("Deleted {Count} wallet transactions for user {UserId}", transactions.Count, id);
                }
            }

            // 2. Delete all user budgets related to this user
            if (_budgetRepository != null)
            {
                var budgets = await _budgetRepository.GetAllAsync(b => b.UserId == userIdString);
                if (budgets != null && budgets.Any())
                {
                    await _budgetRepository.DeleteRangeAsync(budgets);
                    await _budgetRepository.SaveAsync();
                    _logger.LogInformation("Deleted {Count} user budgets for user {UserId}", budgets.Count, id);
                }
            }

            // 3. Delete the user via UserManager (cascades Identity tables and refresh tokens)
            var result = await _userManager.DeleteAsync(user);
            if (result.Succeeded)
            {
                _logger.LogInformation("Permanently deleted user {UserId} and all associated data", id);
                return true;
            }

            _logger.LogError("Failed to delete user {UserId}: {Errors}", id, string.Join(", ", result.Errors.Select(e => e.Description)));
            return false;
        }

        public async Task<int> BulkDeleteUsersAsync(List<int> userIds, int? currentUserId = null)
        {
            if (userIds == null || !userIds.Any()) return 0;

            // Automatically exclude self-deletion from bulk delete
            var safeIds = userIds
                .Distinct()
                .Where(id => !currentUserId.HasValue || id != currentUserId.Value)
                .ToList();

            if (!safeIds.Any()) return 0;

            var deletedCount = 0;
            foreach (var id in safeIds)
            {
                try
                {
                    var deleted = await DeleteUserAsync(id, currentUserId);
                    if (deleted) deletedCount++;
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Failed to bulk delete user {UserId}", id);
                }
            }

            _logger.LogInformation("Bulk deleted {Count} users permanently", deletedCount);
            return deletedCount;
        }

        private async Task<AdminUserDto> MapToAdminUserDtoAsync(ApplicationUser user)
        {
            var role = await ResolveUserRoleAsync(user);
            return new AdminUserDto
            {
                Id = user.Id.ToString(),
                FullName = user.FullName ?? string.Empty,
                Email = user.Email ?? string.Empty,
                EmailConfirmed = user.EmailConfirmed,
                Currency = string.IsNullOrWhiteSpace(user.Currency) ? "EGP" : user.Currency,
                Role = role,
                IsActive = !user.IsBanned,
                CreatedAt = user.CreatedAt,
                LastLoginAt = null,
                WalletsCount = 1
            };
        }

        private async Task<string> ResolveUserRoleAsync(ApplicationUser user)
        {
            var roles = await _userManager.GetRolesAsync(user);
            if (roles.Any(r => r.Equals(Roles.SuperAdmin, StringComparison.OrdinalIgnoreCase)))
                return Roles.SuperAdmin;
            if (roles.Any(r => r.Equals(Roles.Admin, StringComparison.OrdinalIgnoreCase)))
                return Roles.Admin;
            return Roles.User;
        }

        private static string NormalizeRole(string role)
        {
            if (string.Equals(role, Roles.SuperAdmin, StringComparison.OrdinalIgnoreCase))
                return Roles.SuperAdmin;
            if (string.Equals(role, Roles.Admin, StringComparison.OrdinalIgnoreCase))
                return Roles.Admin;
            return Roles.User;
        }
    }
}
