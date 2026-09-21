using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Mahfazti.Core.Constants;
using Mahfazti.Core.DTOs.Role;
using Mahfazti.Core.Entities;
using Mahfazti.Core.Interfaces;

namespace Mahfazti.Core.Services
{
    public class RoleService : IRoleService
    {
        private readonly RoleManager<ApplicationRole> _roleManager;
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly ILogger<RoleService> _logger;
        private readonly IRepository<IdentityRoleClaim<int>>? _roleClaimRepository;
        private readonly IRepository<IdentityUserRole<int>>? _userRoleRepository;

        public RoleService(
            RoleManager<ApplicationRole> roleManager,
            UserManager<ApplicationUser> userManager,
            ILogger<RoleService> logger,
            IRepository<IdentityRoleClaim<int>>? roleClaimRepository = null,
            IRepository<IdentityUserRole<int>>? userRoleRepository = null)
        {
            _roleManager = roleManager ?? throw new ArgumentNullException(nameof(roleManager));
            _userManager = userManager ?? throw new ArgumentNullException(nameof(userManager));
            _logger = logger ?? throw new ArgumentNullException(nameof(logger));
            _roleClaimRepository = roleClaimRepository;
            _userRoleRepository = userRoleRepository;
        }

        public async Task<List<RoleDto>> GetAllRolesAsync()
        {
            _logger.LogInformation("Retrieving all roles with permissions and user counts");

            var roles = await _roleManager.Roles
                .Where(r => !r.IsDeleted)
                .OrderBy(r => r.Id)
                .ToListAsync();

            if (roles.Count == 0)
            {
                return new List<RoleDto>();
            }

            // High-performance batch query path: 3-4 flat queries total instead of 2N queries
            if (_roleClaimRepository != null && _userRoleRepository != null)
            {
                var allRoleClaims = await _roleClaimRepository.GetAllAsync(rc => rc.ClaimType == Permissions.ClaimType);
                var claimsByRoleId = allRoleClaims
                    .Where(rc => !string.IsNullOrEmpty(rc.ClaimValue))
                    .GroupBy(rc => rc.RoleId)
                    .ToDictionary(
                        g => g.Key,
                        g => g.Select(rc => rc.ClaimValue!).Distinct().ToList()
                    );

                var activeUserIds = await _userManager.Users
                    .Where(u => !u.IsDeleted)
                    .Select(u => u.Id)
                    .ToListAsync();
                var activeUserSet = activeUserIds.ToHashSet();

                var allUserRoles = await _userRoleRepository.GetAllAsync();
                var userCountByRoleId = allUserRoles
                    .Where(ur => activeUserSet.Contains(ur.UserId))
                    .GroupBy(ur => ur.RoleId)
                    .ToDictionary(g => g.Key, g => g.Count());

                return roles.Select(role => new RoleDto
                {
                    Id = role.Id,
                    Name = role.Name!,
                    Description = role.Description ?? GetDefaultDescription(role.Name!),
                    IsSystem = IsSystemRole(role.Name!),
                    UsersCount = userCountByRoleId.TryGetValue(role.Id, out var count) ? count : 0,
                    CreatedAt = role.CreatedAt != default ? role.CreatedAt : DateTime.UtcNow,
                    Permissions = claimsByRoleId.TryGetValue(role.Id, out var perms) ? perms : new List<string>()
                }).ToList();
            }

            // Fallback path (e.g. unit tests without mocked generic repositories)
            var result = new List<RoleDto>();
            foreach (var role in roles)
            {
                var claims = await _roleManager.GetClaimsAsync(role);
                var permissions = claims
                    .Where(c => c.Type == Permissions.ClaimType)
                    .Select(c => c.Value)
                    .Distinct()
                    .ToList();

                var users = await _userManager.GetUsersInRoleAsync(role.Name!);

                result.Add(new RoleDto
                {
                    Id = role.Id,
                    Name = role.Name!,
                    Description = role.Description ?? GetDefaultDescription(role.Name!),
                    IsSystem = IsSystemRole(role.Name!),
                    UsersCount = users.Count(u => !u.IsDeleted),
                    CreatedAt = role.CreatedAt != default ? role.CreatedAt : DateTime.UtcNow,
                    Permissions = permissions
                });
            }

            return result;
        }

        public async Task<RoleDto?> GetRoleByIdAsync(int id)
        {
            var role = await _roleManager.Roles
                .FirstOrDefaultAsync(r => r.Id == id && !r.IsDeleted);

            if (role == null) return null;

            var claims = await _roleManager.GetClaimsAsync(role);
            var permissions = claims
                .Where(c => c.Type == Permissions.ClaimType)
                .Select(c => c.Value)
                .Distinct()
                .ToList();

            var users = await _userManager.GetUsersInRoleAsync(role.Name!);

            return new RoleDto
            {
                Id = role.Id,
                Name = role.Name!,
                Description = role.Description ?? GetDefaultDescription(role.Name!),
                IsSystem = IsSystemRole(role.Name!),
                UsersCount = users.Count(u => !u.IsDeleted),
                CreatedAt = role.CreatedAt,
                Permissions = permissions
            };
        }

        public async Task<RoleDto> CreateRoleAsync(CreateRoleDto dto)
        {
            var trimmedName = dto.Name.Trim();
            _logger.LogInformation("Creating new role with name {RoleName}", trimmedName);

            if (await _roleManager.RoleExistsAsync(trimmedName))
            {
                throw new InvalidOperationException($"الرتبة '{trimmedName}' مسجلة بالفعل في النظام (Role already exists).");
            }

            var role = new ApplicationRole
            {
                Name = trimmedName,
                Description = dto.Description?.Trim(),
                CreatedAt = DateTime.UtcNow,
                IsDeleted = false
            };

            var createResult = await _roleManager.CreateAsync(role);
            if (!createResult.Succeeded)
            {
                var errors = string.Join("; ", createResult.Errors.Select(e => e.Description));
                throw new InvalidOperationException($"فشل إنشاء الرتبة: {errors}");
            }

            // Assign claims
            if (dto.Permissions != null && dto.Permissions.Count > 0)
            {
                var validPermissions = dto.Permissions
                    .Where(p => Permissions.All.Contains(p))
                    .Distinct();

                foreach (var perm in validPermissions)
                {
                    await _roleManager.AddClaimAsync(role, new Claim(Permissions.ClaimType, perm));
                }
            }

            return await GetRoleByIdAsync(role.Id) ?? new RoleDto
            {
                Id = role.Id,
                Name = role.Name,
                Description = role.Description,
                IsSystem = false,
                UsersCount = 0,
                CreatedAt = role.CreatedAt,
                Permissions = dto.Permissions ?? new List<string>()
            };
        }

        public async Task<RoleDto> UpdateRoleAsync(int id, UpdateRoleDto dto)
        {
            var role = await _roleManager.Roles
                .FirstOrDefaultAsync(r => r.Id == id && !r.IsDeleted);

            if (role == null)
            {
                throw new KeyNotFoundException($"الرتبة رقم {id} غير موجودة في النظام (Role not found).");
            }

            var isSystem = IsSystemRole(role.Name!);
            var trimmedName = dto.Name.Trim();

            // Prevent renaming system roles
            if (isSystem && !role.Name!.Equals(trimmedName, StringComparison.OrdinalIgnoreCase))
            {
                throw new InvalidOperationException("لا يمكن تغيير الاسم البرمجي لرتب النظام الأساسية (Cannot rename system roles).");
            }

            if (!isSystem && !role.Name!.Equals(trimmedName, StringComparison.OrdinalIgnoreCase))
            {
                if (await _roleManager.RoleExistsAsync(trimmedName))
                {
                    throw new InvalidOperationException($"الاسم '{trimmedName}' مستخدم بالفعل لرتبة أخرى.");
                }
                role.Name = trimmedName;
            }

            role.Description = dto.Description?.Trim();
            var updateResult = await _roleManager.UpdateAsync(role);
            if (!updateResult.Succeeded)
            {
                var errors = string.Join("; ", updateResult.Errors.Select(e => e.Description));
                throw new InvalidOperationException($"فشل تحديث بيانات الرتبة: {errors}");
            }

            // Sync claims
            var currentClaims = await _roleManager.GetClaimsAsync(role);
            var currentPermClaims = currentClaims.Where(c => c.Type == Permissions.ClaimType).ToList();
            var currentPerms = currentPermClaims.Select(c => c.Value).ToHashSet();

            var requestedPerms = (dto.Permissions ?? new List<string>())
                .Where(p => Permissions.All.Contains(p))
                .ToHashSet();

            // SuperAdmin always retains all permissions
            if (role.Name!.Equals(Roles.SuperAdmin, StringComparison.OrdinalIgnoreCase))
            {
                requestedPerms = Permissions.All.ToHashSet();
            }

            // Remove unselected claims
            foreach (var existingClaim in currentPermClaims)
            {
                if (!requestedPerms.Contains(existingClaim.Value))
                {
                    var removeResult = await _roleManager.RemoveClaimAsync(role, existingClaim);
                    if (!removeResult.Succeeded)
                    {
                        _logger.LogWarning("Failed to remove claim {Claim} from role {RoleId}", existingClaim.Value, role.Id);
                    }
                }
            }

            // Add newly selected claims
            foreach (var perm in requestedPerms)
            {
                if (!currentPerms.Contains(perm))
                {
                    var addResult = await _roleManager.AddClaimAsync(role, new Claim(Permissions.ClaimType, perm));
                    if (!addResult.Succeeded)
                    {
                        _logger.LogWarning("Failed to add claim {Claim} to role {RoleId}", perm, role.Id);
                    }
                }
            }

            return (await GetRoleByIdAsync(role.Id))!;
        }

        public async Task<bool> DeleteRoleAsync(int id)
        {
            var role = await _roleManager.Roles
                .FirstOrDefaultAsync(r => r.Id == id && !r.IsDeleted);

            if (role == null)
            {
                throw new KeyNotFoundException($"الرتبة رقم {id} غير موجودة في النظام (Role not found).");
            }

            if (IsSystemRole(role.Name!))
            {
                throw new InvalidOperationException($"لا يمكن حذف رتبة النظام الأساسية '{role.Name}' (System roles cannot be deleted).");
            }

            var assignedUsers = await _userManager.GetUsersInRoleAsync(role.Name!);
            var activeCount = assignedUsers.Count(u => !u.IsDeleted);
            if (activeCount > 0)
            {
                throw new InvalidOperationException($"لا يمكن حذف الرتبة '{role.Name}' لأنها مسندة حالياً إلى {activeCount} مستخدم. يرجى نقلهم أولاً.");
            }

            // Soft-delete role
            role.IsDeleted = true;
            var result = await _roleManager.UpdateAsync(role);
            return result.Succeeded;
        }

        private static readonly List<PermissionGroupDto> CachedPermissionGroups = new()
        {
            new()
            {
                GroupKey = "users",
                GroupNameEn = "User Management",
                GroupNameAr = "إدارة المستخدمين",
                Permissions = new List<PermissionItemDto>
                {
                    new() { Code = Permissions.UsersView, NameEn = "View Users", NameAr = "عرض المستخدمين", DescriptionEn = "Access users directory and view profile details", DescriptionAr = "استعراض دليل المستخدمين وملفاتهم الشخصية" },
                    new() { Code = Permissions.UsersCreate, NameEn = "Create Users", NameAr = "إضافة مستخدمين", DescriptionEn = "Register and create new user accounts", DescriptionAr = "إنشاء وتسجيل حسابات مستخدمين جدد" },
                    new() { Code = Permissions.UsersEdit, NameEn = "Edit Users", NameAr = "تعديل المستخدمين", DescriptionEn = "Update profile information and toggle account status", DescriptionAr = "تعديل بيانات المستخدمين وتفعيل أو إيقاف الحسابات" },
                    new() { Code = Permissions.UsersDelete, NameEn = "Delete Users", NameAr = "حذف المستخدمين", DescriptionEn = "Permanently remove or wipe user records", DescriptionAr = "الحذف النهائي لحسابات المستخدمين وسجلاتهم" },
                    new() { Code = Permissions.UsersRoles, NameEn = "Assign Roles", NameAr = "تعيين الرتب للمستخدمين", DescriptionEn = "Promote or change administrator and user roles", DescriptionAr = "ترقية رتب المشرفين وصلاحياتهم الإدارية" }
                }
            },
            new()
            {
                GroupKey = "categories",
                GroupNameEn = "Financial Categories",
                GroupNameAr = "التصنيفات المالية",
                Permissions = new List<PermissionItemDto>
                {
                    new() { Code = Permissions.CategoriesView, NameEn = "View Categories", NameAr = "عرض التصنيفات", DescriptionEn = "View system expense and income categories", DescriptionAr = "استعراض تصنيفات المصروفات والإيرادات" },
                    new() { Code = Permissions.CategoriesCreate, NameEn = "Create Categories", NameAr = "إضافة تصنيفات", DescriptionEn = "Create new spending and earning categories", DescriptionAr = "إضافة تصنيفات جديدة للمصروفات والإيرادات" },
                    new() { Code = Permissions.CategoriesEdit, NameEn = "Edit Categories", NameAr = "تعديل التصنيفات", DescriptionEn = "Modify category icons, names, and types", DescriptionAr = "تعديل أيقونات ومسميات وأنواع التصنيفات" },
                    new() { Code = Permissions.CategoriesDelete, NameEn = "Delete Categories", NameAr = "أرشفة وحذف التصنيفات", DescriptionEn = "Archive or permanently delete categories", DescriptionAr = "أرشفة التصنيفات المالية أو حذفها نهائياً" }
                }
            },
            new()
            {
                GroupKey = "transactions",
                GroupNameEn = "Transactions & Wallets",
                GroupNameAr = "المعاملات والمحافظ",
                Permissions = new List<PermissionItemDto>
                {
                    new() { Code = Permissions.TransactionsView, NameEn = "View Transactions", NameAr = "مراقبة المعاملات", DescriptionEn = "Inspect financial movements and wallet balances", DescriptionAr = "متابعة الحركات المالية وأرصدة المحافظ" },
                    new() { Code = Permissions.TransactionsExport, NameEn = "Export Transactions", NameAr = "تصدير المعاملات", DescriptionEn = "Download CSV and Excel financial reports", DescriptionAr = "تصدير تقارير العمليات المالية بصيغ الجداول" }
                }
            },
            new()
            {
                GroupKey = "subscriptions",
                GroupNameEn = "Subscriptions & Plans",
                GroupNameAr = "الاشتراكات والخطط",
                Permissions = new List<PermissionItemDto>
                {
                    new() { Code = Permissions.SubscriptionsView, NameEn = "View Subscriptions", NameAr = "عرض الاشتراكات", DescriptionEn = "Monitor user subscriptions and MRR revenue", DescriptionAr = "متابعة اشتراكات المستخدمين وإيرادات الـ MRR" },
                    new() { Code = Permissions.SubscriptionsManage, NameEn = "Manage Subscriptions", NameAr = "إدارة الاشتراكات", DescriptionEn = "Cancel, refund, or extend memberships", DescriptionAr = "إلغاء وتمديد اشتراكات العضويات" },
                    new() { Code = Permissions.PlansManage, NameEn = "Manage Plans", NameAr = "إدارة خطط الأسعار", DescriptionEn = "Create and configure pricing tiers and promo codes", DescriptionAr = "إنشاء وتعديل باقات الاشتراك وكوبونات الخصم" }
                }
            },
            new()
            {
                GroupKey = "audit_logs",
                GroupNameEn = "Security & Audit Trail",
                GroupNameAr = "سجل النشاط والأمان",
                Permissions = new List<PermissionItemDto>
                {
                    new() { Code = Permissions.AuditLogsView, NameEn = "View Audit Trail", NameAr = "عرض سجل النشاط", DescriptionEn = "Inspect administrative actions and security history", DescriptionAr = "مراقبة كافة عمليات المشرفين وسجل الأمان" },
                    new() { Code = Permissions.AuditLogsExport, NameEn = "Export Audit Trail", NameAr = "تصدير سجل النشاط", DescriptionEn = "Export security compliance logs and IP history", DescriptionAr = "تصدير تقارير الرقابة وسجلات عناوين الـ IP" }
                }
            },
            new()
            {
                GroupKey = "notifications",
                GroupNameEn = "Push Notifications",
                GroupNameAr = "الإشعارات والبث",
                Permissions = new List<PermissionItemDto>
                {
                    new() { Code = Permissions.NotificationsView, NameEn = "View Notifications", NameAr = "عرض سجل الإشعارات", DescriptionEn = "Inspect broadcast delivery rates and analytics", DescriptionAr = "استعراض نسب وصول الإشعارات والتفاعل" },
                    new() { Code = Permissions.NotificationsSend, NameEn = "Broadcast Notifications", NameAr = "إرسال إشعارات عامة", DescriptionEn = "Send promotional messages and alerts to users", DescriptionAr = "إرسال رسائل وتنبيهات جماعية لأجهزة المستخدمين" }
                }
            },
            new()
            {
                GroupKey = "roles",
                GroupNameEn = "Roles & Permissions",
                GroupNameAr = "الأدوار والصلاحيات",
                Permissions = new List<PermissionItemDto>
                {
                    new() { Code = Permissions.RolesView, NameEn = "View Roles", NameAr = "استعراض الأدوار", DescriptionEn = "Inspect access control roles and assigned claims", DescriptionAr = "استعراض مصفوفة الرتب الإدارية والصلاحيات" },
                    new() { Code = Permissions.RolesManage, NameEn = "Manage Roles", NameAr = "إدارة الأدوار والصلاحيات", DescriptionEn = "Create custom roles and configure permissions matrix", DescriptionAr = "إنشاء رتب مخصصة وتعديل مصفوفة الصلاحيات" }
                }
            },
            new()
            {
                GroupKey = "system",
                GroupNameEn = "System & Settings",
                GroupNameAr = "النظام والإعدادات",
                Permissions = new List<PermissionItemDto>
                {
                    new() { Code = Permissions.SystemSettings, NameEn = "Platform Settings", NameAr = "إعدادات المنصة", DescriptionEn = "Configure global application settings and currencies", DescriptionAr = "ضبط الإعدادات العامة للمنصة والعملات" },
                    new() { Code = Permissions.SystemHealth, NameEn = "System Health", NameAr = "صحة النظام والخوادم", DescriptionEn = "Monitor server metrics, latency, and cache", DescriptionAr = "مراقبة أداء الخوادم ومعدلات الاستجابة والذاكرة" },
                    new() { Code = Permissions.SystemAiLogs, NameEn = "AI Analytics", NameAr = "سجلات الذكاء الاصطناعي", DescriptionEn = "Inspect AI advisor usage and token consumption", DescriptionAr = "متابعة استهلاك واستجابات مستشار الذكاء الاصطناعي" }
                }
            }
        };

        public List<PermissionGroupDto> GetAvailablePermissions()
        {
            return CachedPermissionGroups;
        }

        private static bool IsSystemRole(string roleName)
        {
            return roleName.Equals(Roles.SuperAdmin, StringComparison.OrdinalIgnoreCase) ||
                   roleName.Equals(Roles.Admin, StringComparison.OrdinalIgnoreCase) ||
                   roleName.Equals(Roles.User, StringComparison.OrdinalIgnoreCase);
        }

        private static string GetDefaultDescription(string roleName)
        {
            return roleName switch
            {
                Roles.SuperAdmin => "المالك الرئيسي للنظام بكافة الصلاحيات والجذور الإدارية وإدارة التكوينات وسجلات الأمان.",
                Roles.Admin => "مشرف تشغيلي مع صلاحيات إدارة المستخدمين والتصنيفات ومراقبة العمليات المالية وسجل النشاط.",
                Roles.User => "مستخدم قياسي للمحفظة وتتبع المصروفات والمعاملات الشخصية.",
                _ => "رتبة مخصصة محددة الصلاحيات من قبل الإدارة."
            };
        }
    }
}
