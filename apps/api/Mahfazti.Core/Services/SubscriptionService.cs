using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;
using Mahfazti.Core.Common;
using Mahfazti.Core.DTOs.Subscription;
using Mahfazti.Core.Entities;
using Mahfazti.Core.Interfaces;
using Microsoft.Extensions.Logging;

namespace Mahfazti.Core.Services
{
    public class SubscriptionService : ISubscriptionService
    {
        private readonly IRepository<PricingPlan> _planRepo;
        private readonly IRepository<UserSubscription> _subRepo;
        private readonly IRepository<PaymentLog> _paymentRepo;
        private readonly IRepository<PromoCode> _promoRepo;
        private readonly ILogger<SubscriptionService> _logger;

        public SubscriptionService(
            IRepository<PricingPlan> planRepo,
            IRepository<UserSubscription> subRepo,
            IRepository<PaymentLog> paymentRepo,
            IRepository<PromoCode> promoRepo,
            ILogger<SubscriptionService> logger)
        {
            _planRepo = planRepo;
            _subRepo = subRepo;
            _paymentRepo = paymentRepo;
            _promoRepo = promoRepo;
            _logger = logger;
        }

        #region Pricing Plans

        public async Task<ApiResponse<List<PricingPlanDto>>> GetAllPlansAsync(bool includeInactive = true)
        {
            try
            {
                var plans = await _planRepo.GetAllAsync(
                    filter: includeInactive ? null : (p => p.IsActive),
                    orderBy: q => q.OrderBy(p => p.DisplayOrder).ThenBy(p => p.PriceEgp)
                );

                var dtos = plans.Select(MapPlanToDto).ToList();
                return ApiResponse<List<PricingPlanDto>>.SuccessResponse(dtos);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving pricing plans.");
                return ApiResponse<List<PricingPlanDto>>.FailResponse("Failed to load pricing plans.");
            }
        }

        public async Task<ApiResponse<PricingPlanDto>> GetPlanByIdAsync(string id)
        {
            try
            {
                var plan = await _planRepo.GetAsync(p => p.Id == id);
                if (plan == null)
                {
                    return ApiResponse<PricingPlanDto>.FailResponse($"Plan with ID '{id}' not found.");
                }

                return ApiResponse<PricingPlanDto>.SuccessResponse(MapPlanToDto(plan));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving plan {Id}", id);
                return ApiResponse<PricingPlanDto>.FailResponse("Error retrieving plan.");
            }
        }

        public async Task<ApiResponse<PricingPlanDto>> CreatePlanAsync(CreatePricingPlanDto dto)
        {
            try
            {
                var planId = string.IsNullOrWhiteSpace(dto.Id)
                    ? $"plan-{dto.Name.Trim().ToLower().Replace(" ", "-")}-{DateTime.UtcNow.Ticks % 10000}"
                    : dto.Id.Trim();

                var exists = await _planRepo.AnyAsync(p => p.Id == planId);
                if (exists)
                {
                    return ApiResponse<PricingPlanDto>.FailResponse($"Plan with ID '{planId}' already exists.");
                }

                var entity = new PricingPlan
                {
                    Id = planId,
                    Name = dto.Name.Trim(),
                    NameAr = dto.NameAr.Trim(),
                    PriceEgp = dto.PriceEgp,
                    BillingCycle = dto.BillingCycle.Trim(),
                    Description = dto.Description?.Trim() ?? string.Empty,
                    DescriptionAr = dto.DescriptionAr?.Trim() ?? string.Empty,
                    FeaturesJson = JsonSerializer.Serialize(dto.Features ?? new List<string>()),
                    FeaturesArJson = JsonSerializer.Serialize(dto.FeaturesAr ?? new List<string>()),
                    IsPopular = dto.IsPopular,
                    IsActive = dto.IsActive,
                    DisplayOrder = dto.DisplayOrder,
                    MaxWallets = dto.MaxWallets,
                    MaxAiRequestsPerMonth = dto.MaxAiRequestsPerMonth,
                    CanExportReports = dto.CanExportReports,
                    CanUseMultiCurrency = dto.CanUseMultiCurrency,
                    CreatedAt = DateTime.UtcNow
                };

                await _planRepo.CreateAsync(entity);
                _logger.LogInformation("Created new pricing plan: {Id}", planId);

                return ApiResponse<PricingPlanDto>.SuccessResponse(MapPlanToDto(entity), "Pricing plan created successfully.");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating pricing plan {Name}", dto.Name);
                return ApiResponse<PricingPlanDto>.FailResponse("Failed to create pricing plan.");
            }
        }

        public async Task<ApiResponse<PricingPlanDto>> UpdatePlanAsync(string id, UpdatePricingPlanDto dto)
        {
            try
            {
                var plan = await _planRepo.GetAsync(p => p.Id == id, isTracking: true);
                if (plan == null)
                {
                    return ApiResponse<PricingPlanDto>.FailResponse($"Plan with ID '{id}' not found.");
                }

                plan.Name = dto.Name.Trim();
                plan.NameAr = dto.NameAr.Trim();
                plan.PriceEgp = dto.PriceEgp;
                plan.BillingCycle = dto.BillingCycle.Trim();
                plan.Description = dto.Description?.Trim() ?? string.Empty;
                plan.DescriptionAr = dto.DescriptionAr?.Trim() ?? string.Empty;
                plan.FeaturesJson = JsonSerializer.Serialize(dto.Features ?? new List<string>());
                plan.FeaturesArJson = JsonSerializer.Serialize(dto.FeaturesAr ?? new List<string>());
                plan.IsPopular = dto.IsPopular;
                plan.IsActive = dto.IsActive;
                plan.DisplayOrder = dto.DisplayOrder;
                plan.MaxWallets = dto.MaxWallets;
                plan.MaxAiRequestsPerMonth = dto.MaxAiRequestsPerMonth;
                plan.CanExportReports = dto.CanExportReports;
                plan.CanUseMultiCurrency = dto.CanUseMultiCurrency;
                plan.UpdatedAt = DateTime.UtcNow;

                await _planRepo.UpdateAsync(plan);
                _logger.LogInformation("Updated pricing plan: {Id}", id);

                return ApiResponse<PricingPlanDto>.SuccessResponse(MapPlanToDto(plan), "Pricing plan updated successfully.");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating plan {Id}", id);
                return ApiResponse<PricingPlanDto>.FailResponse("Failed to update pricing plan.");
            }
        }

        public async Task<ApiResponse<bool>> ReorderPlansAsync(List<string> orderedPlanIds)
        {
            try
            {
                if (orderedPlanIds == null || orderedPlanIds.Count == 0)
                {
                    return ApiResponse<bool>.FailResponse("No plan IDs provided.");
                }

                var allPlans = await _planRepo.GetAllAsync(isTracking: true);
                var planMap = allPlans.ToDictionary(p => p.Id);

                for (int i = 0; i < orderedPlanIds.Count; i++)
                {
                    var planId = orderedPlanIds[i];
                    if (planMap.TryGetValue(planId, out var plan))
                    {
                        plan.DisplayOrder = i;
                        plan.UpdatedAt = DateTime.UtcNow;
                        await _planRepo.UpdateAsync(plan);
                    }
                }

                _logger.LogInformation("Successfully reordered {Count} pricing plans.", orderedPlanIds.Count);
                return ApiResponse<bool>.SuccessResponse(true, "Plans reordered successfully.");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error reordering pricing plans.");
                return ApiResponse<bool>.FailResponse("Failed to reorder plans.");
            }
        }

        public async Task<ApiResponse<bool>> DeletePlanAsync(string id)
        {
            try
            {
                var plan = await _planRepo.GetAsync(p => p.Id == id, isTracking: true);
                if (plan == null)
                {
                    return ApiResponse<bool>.FailResponse($"Plan with ID '{id}' not found.");
                }

                // If active subscriptions exist, soft delete/archive instead of hard delete
                var hasActiveSubs = await _subRepo.AnyAsync(s => s.PlanId == id && s.Status == "Active");
                if (hasActiveSubs)
                {
                    plan.IsActive = false;
                    plan.UpdatedAt = DateTime.UtcNow;
                    await _planRepo.UpdateAsync(plan);
                    return ApiResponse<bool>.SuccessResponse(true, "Plan has active subscribers so it was archived.");
                }

                await _planRepo.DeleteAsync(plan);
                _logger.LogInformation("Deleted pricing plan: {Id}", id);

                return ApiResponse<bool>.SuccessResponse(true, "Pricing plan deleted successfully.");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting plan {Id}", id);
                return ApiResponse<bool>.FailResponse("Failed to delete pricing plan.");
            }
        }

        #endregion

        #region User Subscriptions & Stats

        public async Task<ApiResponse<List<UserSubscriptionDto>>> GetSubscriptionsAsync(string? status = null, string? search = null)
        {
            try
            {
                var subscriptions = await _subRepo.GetAllAsync(
                    includeProperties: "User,Plan",
                    orderBy: q => q.OrderByDescending(s => s.CreatedAt)
                );

                var query = subscriptions.AsEnumerable();

                if (!string.IsNullOrWhiteSpace(status) && !status.Equals("all", StringComparison.OrdinalIgnoreCase))
                {
                    query = query.Where(s => s.Status.Equals(status.Trim(), StringComparison.OrdinalIgnoreCase));
                }

                if (!string.IsNullOrWhiteSpace(search))
                {
                    var q = search.Trim().ToLowerInvariant();
                    query = query.Where(s =>
                        (s.User?.FullName?.ToLowerInvariant().Contains(q) ?? false) ||
                        (s.User?.Email?.ToLowerInvariant().Contains(q) ?? false) ||
                        (s.Plan?.Name.ToLowerInvariant().Contains(q) ?? false) ||
                        s.Gateway.ToLowerInvariant().Contains(q)
                    );
                }

                var dtos = query.Select(MapSubToDto).ToList();
                return ApiResponse<List<UserSubscriptionDto>>.SuccessResponse(dtos);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving user subscriptions.");
                return ApiResponse<List<UserSubscriptionDto>>.FailResponse("Failed to load user subscriptions.");
            }
        }

        public async Task<ApiResponse<SubscriptionStatsDto>> GetSubscriptionStatsAsync()
        {
            try
            {
                var allSubs = await _subRepo.GetAllAsync(includeProperties: "Plan");
                var activeSubs = allSubs.Where(s => s.Status == "Active").ToList();
                var expiredSubs = allSubs.Where(s => s.Status == "Expired" || s.Status == "Canceled").ToList();

                // Calculate MRR
                decimal mrr = 0;
                foreach (var sub in activeSubs)
                {
                    if (sub.Plan != null)
                    {
                        if (sub.Plan.BillingCycle.Equals("Yearly", StringComparison.OrdinalIgnoreCase))
                        {
                            mrr += sub.Plan.PriceEgp / 12m;
                        }
                        else if (sub.Plan.BillingCycle.Equals("Monthly", StringComparison.OrdinalIgnoreCase))
                        {
                            mrr += sub.Plan.PriceEgp;
                        }
                    }
                    else
                    {
                        mrr += sub.AmountPaidEgp;
                    }
                }

                var totalCount = allSubs.Count;
                var churnRate = totalCount > 0 ? ((decimal)expiredSubs.Count / totalCount) * 100m : 0m;

                var stats = new SubscriptionStatsDto
                {
                    MonthlyRecurringRevenue = Math.Round(mrr, 2),
                    ActivePaidSubscribers = activeSubs.Count,
                    ExpiredSubscribers = expiredSubs.Count,
                    TotalSubscribers = totalCount,
                    ChurnRatePercentage = Math.Round(churnRate, 1)
                };

                return ApiResponse<SubscriptionStatsDto>.SuccessResponse(stats);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error calculating subscription statistics.");
                return ApiResponse<SubscriptionStatsDto>.FailResponse("Failed to calculate subscription stats.");
            }
        }

        #endregion

        #region Payment Logs

        public async Task<ApiResponse<List<PaymentLogDto>>> GetPaymentLogsAsync(string? search = null, string? status = null)
        {
            try
            {
                var logs = await _paymentRepo.GetAllAsync(
                    orderBy: q => q.OrderByDescending(p => p.CreatedAt)
                );

                var query = logs.AsEnumerable();

                if (!string.IsNullOrWhiteSpace(status) && !status.Equals("all", StringComparison.OrdinalIgnoreCase))
                {
                    query = query.Where(p => p.Status.Equals(status.Trim(), StringComparison.OrdinalIgnoreCase));
                }

                if (!string.IsNullOrWhiteSpace(search))
                {
                    var q = search.Trim().ToLowerInvariant();
                    query = query.Where(p =>
                        p.InvoiceNumber.ToLowerInvariant().Contains(q) ||
                        p.UserEmail.ToLowerInvariant().Contains(q) ||
                        p.PlanName.ToLowerInvariant().Contains(q) ||
                        p.TransactionRef.ToLowerInvariant().Contains(q) ||
                        p.Gateway.ToLowerInvariant().Contains(q)
                    );
                }

                var dtos = query.Select(p => new PaymentLogDto
                {
                    Id = p.Id,
                    InvoiceNumber = p.InvoiceNumber,
                    UserEmail = p.UserEmail,
                    PlanName = p.PlanName,
                    Amount = p.Amount,
                    Currency = p.Currency,
                    Gateway = p.Gateway,
                    Status = p.Status,
                    TransactionRef = p.TransactionRef,
                    CreatedAt = p.CreatedAt
                }).ToList();

                return ApiResponse<List<PaymentLogDto>>.SuccessResponse(dtos);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving payment logs.");
                return ApiResponse<List<PaymentLogDto>>.FailResponse("Failed to load payment logs.");
            }
        }

        #endregion

        #region Promo Codes

        public async Task<ApiResponse<List<PromoCodeDto>>> GetPromoCodesAsync()
        {
            try
            {
                var codes = await _promoRepo.GetAllAsync(
                    orderBy: q => q.OrderByDescending(p => p.CreatedAt)
                );

                var dtos = codes.Select(MapPromoToDto).ToList();
                return ApiResponse<List<PromoCodeDto>>.SuccessResponse(dtos);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving promo codes.");
                return ApiResponse<List<PromoCodeDto>>.FailResponse("Failed to load promo codes.");
            }
        }

        public async Task<ApiResponse<PromoCodeDto>> CreatePromoCodeAsync(CreatePromoCodeDto dto)
        {
            try
            {
                var codeUpper = dto.Code.Trim().ToUpperInvariant();
                var exists = await _promoRepo.AnyAsync(p => p.Code == codeUpper);
                if (exists)
                {
                    return ApiResponse<PromoCodeDto>.FailResponse($"Promo code '{codeUpper}' already exists.");
                }

                var entity = new PromoCode
                {
                    Id = Guid.NewGuid().ToString(),
                    Code = codeUpper,
                    DiscountPercentage = dto.DiscountPercentage,
                    MaxUses = dto.MaxUses,
                    UsedCount = 0,
                    ExpiresAt = dto.ExpiresAt,
                    IsActive = dto.IsActive,
                    CreatedAt = DateTime.UtcNow
                };

                await _promoRepo.CreateAsync(entity);
                _logger.LogInformation("Created promo code: {Code}", codeUpper);

                return ApiResponse<PromoCodeDto>.SuccessResponse(MapPromoToDto(entity), "Promo code created successfully.");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating promo code {Code}", dto.Code);
                return ApiResponse<PromoCodeDto>.FailResponse("Failed to create promo code.");
            }
        }

        public async Task<ApiResponse<PromoCodeDto>> TogglePromoCodeStatusAsync(string id)
        {
            try
            {
                var promo = await _promoRepo.GetAsync(p => p.Id == id, isTracking: true);
                if (promo == null)
                {
                    return ApiResponse<PromoCodeDto>.FailResponse($"Promo code with ID '{id}' not found.");
                }

                promo.IsActive = !promo.IsActive;
                await _promoRepo.UpdateAsync(promo);
                _logger.LogInformation("Toggled promo code {Code} status to {IsActive}", promo.Code, promo.IsActive);

                return ApiResponse<PromoCodeDto>.SuccessResponse(
                    MapPromoToDto(promo),
                    promo.IsActive ? "Promo code activated." : "Promo code deactivated."
                );
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error toggling promo code status {Id}", id);
                return ApiResponse<PromoCodeDto>.FailResponse("Failed to update promo code.");
            }
        }

        public async Task<ApiResponse<bool>> DeletePromoCodeAsync(string id)
        {
            try
            {
                var promo = await _promoRepo.GetAsync(p => p.Id == id);
                if (promo == null)
                {
                    return ApiResponse<bool>.FailResponse($"Promo code with ID '{id}' not found.");
                }

                await _promoRepo.DeleteAsync(promo);
                _logger.LogInformation("Deleted promo code: {Code}", promo.Code);

                return ApiResponse<bool>.SuccessResponse(true, "Promo code deleted successfully.");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting promo code {Id}", id);
                return ApiResponse<bool>.FailResponse("Failed to delete promo code.");
            }
        }

        #endregion

        #region Helpers & Mappers

        private static PricingPlanDto MapPlanToDto(PricingPlan p)
        {
            List<string> features;
            List<string> featuresAr;
            try
            {
                features = JsonSerializer.Deserialize<List<string>>(p.FeaturesJson) ?? new List<string>();
            }
            catch
            {
                features = new List<string>();
            }

            try
            {
                featuresAr = string.IsNullOrWhiteSpace(p.FeaturesArJson)
                    ? new List<string>()
                    : JsonSerializer.Deserialize<List<string>>(p.FeaturesArJson) ?? new List<string>();
            }
            catch
            {
                featuresAr = new List<string>();
            }

            return new PricingPlanDto
            {
                Id = p.Id,
                Name = p.Name,
                NameAr = p.NameAr,
                PriceEgp = p.PriceEgp,
                BillingCycle = p.BillingCycle,
                Description = p.Description,
                DescriptionAr = p.DescriptionAr,
                Features = features,
                FeaturesAr = featuresAr,
                IsPopular = p.IsPopular,
                IsActive = p.IsActive,
                DisplayOrder = p.DisplayOrder,
                MaxWallets = p.MaxWallets,
                MaxAiRequestsPerMonth = p.MaxAiRequestsPerMonth,
                CanExportReports = p.CanExportReports,
                CanUseMultiCurrency = p.CanUseMultiCurrency
            };
        }

        private static UserSubscriptionDto MapSubToDto(UserSubscription s)
        {
            return new UserSubscriptionDto
            {
                Id = s.Id,
                UserId = s.UserId?.ToString() ?? string.Empty,
                UserName = s.User?.FullName ?? "Unknown User",
                UserEmail = s.User?.Email ?? "N/A",
                PlanId = s.PlanId,
                PlanName = s.Plan?.Name ?? "Custom Plan",
                Status = s.Status,
                AmountPaidEgp = s.AmountPaidEgp,
                Gateway = s.Gateway,
                StartDate = s.StartDate,
                EndDate = s.EndDate,
                AutoRenew = s.AutoRenew
            };
        }

        private static PromoCodeDto MapPromoToDto(PromoCode p)
        {
            return new PromoCodeDto
            {
                Id = p.Id,
                Code = p.Code,
                DiscountPercentage = p.DiscountPercentage,
                MaxUses = p.MaxUses,
                UsedCount = p.UsedCount,
                ExpiresAt = p.ExpiresAt,
                IsActive = p.IsActive,
                CreatedAt = p.CreatedAt
            };
        }

        #endregion
    }
}
