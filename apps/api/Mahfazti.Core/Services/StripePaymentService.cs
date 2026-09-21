using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Mahfazti.Core.Common;
using Mahfazti.Core.DTOs.Payment;
using Mahfazti.Core.Entities;
using Mahfazti.Core.Interfaces;
using Mahfazti.Core.Settings;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Stripe;

namespace Mahfazti.Core.Services
{
    public class StripePaymentService : IStripePaymentService
    {
        private readonly StripeSettings _settings;
        private readonly IRepository<PricingPlan> _planRepo;
        private readonly IRepository<UserSubscription> _subRepo;
        private readonly IRepository<PaymentLog> _paymentRepo;
        private readonly IRepository<PromoCode> _promoRepo;
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly ILogger<StripePaymentService> _logger;

        public StripePaymentService(
            IOptions<StripeSettings> settings,
            IRepository<PricingPlan> planRepo,
            IRepository<UserSubscription> subRepo,
            IRepository<PaymentLog> paymentRepo,
            IRepository<PromoCode> promoRepo,
            UserManager<ApplicationUser> userManager,
            ILogger<StripePaymentService> logger)
        {
            _settings = settings.Value;
            _planRepo = planRepo;
            _subRepo = subRepo;
            _paymentRepo = paymentRepo;
            _promoRepo = promoRepo;
            _userManager = userManager;
            _logger = logger;

            if (!string.IsNullOrWhiteSpace(_settings.SecretKey))
            {
                StripeConfiguration.ApiKey = _settings.SecretKey;
            }
        }

        public Task<ApiResponse<StripeConfigDto>> GetConfigAsync()
        {
            var config = new StripeConfigDto
            {
                PublishableKey = _settings.PublishableKey
            };
            return Task.FromResult(ApiResponse<StripeConfigDto>.SuccessResponse(config));
        }

        public async Task<ApiResponse<StripePaymentSheetResponseDto>> CreatePaymentSheetIntentAsync(
            int userId,
            StripePaymentIntentRequestDto dto)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(_settings.SecretKey))
                {
                    return ApiResponse<StripePaymentSheetResponseDto>.FailResponse("Stripe is not configured on the server.");
                }

                var user = await _userManager.FindByIdAsync(userId.ToString());
                if (user == null)
                {
                    return ApiResponse<StripePaymentSheetResponseDto>.FailResponse("User not found.");
                }

                var plan = await _planRepo.GetAsync(p => p.Id == dto.PlanId);
                if (plan == null)
                {
                    return ApiResponse<StripePaymentSheetResponseDto>.FailResponse($"Plan with ID '{dto.PlanId}' not found.");
                }

                if (!plan.IsActive)
                {
                    return ApiResponse<StripePaymentSheetResponseDto>.FailResponse("This pricing plan is currently inactive.");
                }

                // Calculate price and discounts
                decimal originalPrice = plan.PriceEgp;
                decimal discountAmount = 0m;
                string? appliedPromo = null;

                if (!string.IsNullOrWhiteSpace(dto.PromoCode))
                {
                    var cleanPromo = dto.PromoCode.Trim().ToUpperInvariant();
                    var promo = await _promoRepo.GetAsync(p => p.Code == cleanPromo && p.IsActive);
                    if (promo != null)
                    {
                        if (!promo.ExpiresAt.HasValue || promo.ExpiresAt.Value > DateTime.UtcNow)
                        {
                            if (promo.MaxUses <= 0 || promo.UsedCount < promo.MaxUses)
                            {
                                discountAmount = originalPrice * (promo.DiscountPercentage / 100m);
                                appliedPromo = promo.Code;
                            }
                        }
                    }
                }

                decimal finalPrice = Math.Max(0, originalPrice - discountAmount);

                // Handle 100% free bypass
                if (finalPrice <= 0m)
                {
                    return ApiResponse<StripePaymentSheetResponseDto>.FailResponse("This plan or promotion is completely free. Please activate directly without payment.");
                }

                // 1. Create or Find Stripe Customer
                var customerService = new CustomerService();
                Customer? customer = null;

                if (!string.IsNullOrWhiteSpace(user.Email))
                {
                    var customerList = await customerService.ListAsync(new CustomerListOptions
                    {
                        Email = user.Email,
                        Limit = 1
                    });
                    customer = customerList.Data.FirstOrDefault();
                }

                if (customer == null)
                {
                    customer = await customerService.CreateAsync(new CustomerCreateOptions
                    {
                        Email = user.Email,
                        Name = user.FullName ?? user.UserName ?? $"User #{user.Id}",
                        Metadata = new Dictionary<string, string>
                        {
                            { "UserId", userId.ToString() }
                        }
                    });
                }

                // 2. Create Ephemeral Key for Mobile SDK (PaymentSheet)
                var ephemeralKeyService = new EphemeralKeyService();
                var ephemeralKey = await ephemeralKeyService.CreateAsync(
                    new EphemeralKeyCreateOptions
                    {
                        Customer = customer.Id,
                        StripeVersion = "2024-06-20"
                    }
                );

                // 3. Create PaymentIntent
                var invoiceNumber = $"INV-{DateTime.UtcNow:yyyyMMdd}-{Guid.NewGuid().ToString().Substring(0, 6).ToUpper()}";
                var currency = string.IsNullOrWhiteSpace(dto.Currency) ? "egp" : dto.Currency.Trim().ToLowerInvariant();

                // Stripe expects smallest currency unit (e.g., piastres / cents * 100)
                long amountInSmallestUnit = (long)Math.Round(finalPrice * 100, MidpointRounding.AwayFromZero);

                var paymentIntentService = new PaymentIntentService();
                var paymentIntent = await paymentIntentService.CreateAsync(new PaymentIntentCreateOptions
                {
                    Amount = amountInSmallestUnit,
                    Currency = currency,
                    Customer = customer.Id,
                    AutomaticPaymentMethods = new PaymentIntentAutomaticPaymentMethodsOptions
                    {
                        Enabled = true,
                    },
                    Metadata = new Dictionary<string, string>
                    {
                        { "UserId", userId.ToString() },
                        { "UserEmail", user.Email ?? "" },
                        { "PlanId", plan.Id },
                        { "PlanName", plan.Name },
                        { "PromoCode", appliedPromo ?? "" },
                        { "InvoiceNumber", invoiceNumber }
                    }
                });

                var response = new StripePaymentSheetResponseDto
                {
                    PaymentIntentClientSecret = paymentIntent.ClientSecret,
                    PaymentIntentId = paymentIntent.Id,
                    EphemeralKeySecret = ephemeralKey.Secret,
                    CustomerId = customer.Id,
                    PublishableKey = _settings.PublishableKey,
                    Amount = finalPrice,
                    Currency = currency.ToUpperInvariant(),
                    PlanId = plan.Id,
                    PlanName = plan.Name,
                    OriginalPrice = originalPrice,
                    DiscountAmount = discountAmount,
                    AppliedPromoCode = appliedPromo
                };

                _logger.LogInformation("Created Stripe PaymentSheet Intent {IntentId} for User {UserId}, Plan {PlanId}", paymentIntent.Id, userId, plan.Id);

                return ApiResponse<StripePaymentSheetResponseDto>.SuccessResponse(response, "Payment intent created successfully.");
            }
            catch (StripeException ex)
            {
                _logger.LogError(ex, "Stripe error during CreatePaymentSheetIntentAsync for User {UserId}", userId);
                return ApiResponse<StripePaymentSheetResponseDto>.FailResponse($"Stripe Error: {ex.StripeError?.Message ?? ex.Message}");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error in CreatePaymentSheetIntentAsync for User {UserId}", userId);
                return ApiResponse<StripePaymentSheetResponseDto>.FailResponse("Failed to initiate payment session.");
            }
        }

        public async Task<ApiResponse<bool>> ConfirmPaymentAsync(int userId, StripeConfirmPaymentDto dto)
        {
            try
            {
                var paymentIntentService = new PaymentIntentService();
                var paymentIntent = await paymentIntentService.GetAsync(dto.PaymentIntentId);

                if (paymentIntent == null)
                {
                    return ApiResponse<bool>.FailResponse("Payment intent not found.");
                }

                if (paymentIntent.Status != "succeeded")
                {
                    return ApiResponse<bool>.FailResponse($"Payment is not completed. Current status: {paymentIntent.Status}");
                }

                var processed = await ProcessSuccessfulPaymentIntentAsync(paymentIntent);
                if (!processed)
                {
                    return ApiResponse<bool>.FailResponse("Payment could not be processed.");
                }

                return ApiResponse<bool>.SuccessResponse(true, "Payment verified and subscription activated successfully.");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error confirming payment {IntentId} for user {UserId}", dto.PaymentIntentId, userId);
                return ApiResponse<bool>.FailResponse("Failed to confirm payment.");
            }
        }

        public async Task<ApiResponse<bool>> HandleWebhookAsync(string json, string? stripeSignature)
        {
            try
            {
                Event stripeEvent;

                if (!string.IsNullOrWhiteSpace(_settings.WebhookSecret) && !string.IsNullOrWhiteSpace(stripeSignature))
                {
                    stripeEvent = EventUtility.ConstructEvent(json, stripeSignature, _settings.WebhookSecret);
                }
                else
                {
                    stripeEvent = EventUtility.ParseEvent(json);
                }

                if (stripeEvent.Type == EventTypes.PaymentIntentSucceeded || stripeEvent.Type == "payment_intent.succeeded")
                {
                    var paymentIntent = stripeEvent.Data.Object as PaymentIntent;
                    if (paymentIntent != null)
                    {
                        await ProcessSuccessfulPaymentIntentAsync(paymentIntent);
                    }
                }

                return ApiResponse<bool>.SuccessResponse(true, "Webhook processed successfully.");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error handling Stripe webhook");
                return ApiResponse<bool>.FailResponse("Webhook processing error.");
            }
        }

        #region Internal Helper

        private async Task<bool> ProcessSuccessfulPaymentIntentAsync(PaymentIntent paymentIntent)
        {
            try
            {
                // 1. Idempotency Check: Check if PaymentLog with this TransactionRef already exists
                var existingLog = await _paymentRepo.GetAsync(p => p.TransactionRef == paymentIntent.Id);
                if (existingLog != null)
                {
                    _logger.LogInformation("PaymentIntent {Id} already recorded in PaymentLog.", paymentIntent.Id);
                    return true;
                }

                // 2. Extract Metadata
                paymentIntent.Metadata.TryGetValue("UserId", out var userIdStr);
                paymentIntent.Metadata.TryGetValue("PlanId", out var planId);
                paymentIntent.Metadata.TryGetValue("PromoCode", out var promoCode);
                paymentIntent.Metadata.TryGetValue("InvoiceNumber", out var invoiceNumber);

                if (!int.TryParse(userIdStr, out int userId) || string.IsNullOrWhiteSpace(planId))
                {
                    _logger.LogWarning("PaymentIntent {Id} missing UserId or PlanId metadata.", paymentIntent.Id);
                    return false;
                }

                var user = await _userManager.FindByIdAsync(userId.ToString());
                var plan = await _planRepo.GetAsync(p => p.Id == planId);

                if (user == null || plan == null)
                {
                    _logger.LogWarning("User or Plan not found when processing PaymentIntent {Id}", paymentIntent.Id);
                    return false;
                }

                decimal amountPaid = paymentIntent.Amount / 100m;
                var now = DateTime.UtcNow;

                // 3. Create PaymentLog
                var paymentLog = new PaymentLog
                {
                    Id = Guid.NewGuid().ToString(),
                    InvoiceNumber = !string.IsNullOrWhiteSpace(invoiceNumber) ? invoiceNumber : $"INV-{now:yyyyMMdd}-{Guid.NewGuid().ToString().Substring(0, 6).ToUpper()}",
                    UserId = user.Id,
                    UserEmail = user.Email ?? "N/A",
                    PlanName = plan.Name,
                    Amount = amountPaid,
                    Currency = paymentIntent.Currency?.ToUpperInvariant() ?? "EGP",
                    Gateway = "Stripe",
                    Status = "Success",
                    TransactionRef = paymentIntent.Id,
                    CreatedAt = now
                };

                await _paymentRepo.CreateAsync(paymentLog);

                // 4. Update / Extend User Subscription
                DateTime startDate = now;
                DateTime endDate;

                if (string.Equals(plan.BillingCycle, "Yearly", StringComparison.OrdinalIgnoreCase))
                {
                    endDate = startDate.AddYears(1);
                }
                else if (string.Equals(plan.BillingCycle, "Lifetime", StringComparison.OrdinalIgnoreCase))
                {
                    endDate = startDate.AddYears(100);
                }
                else
                {
                    endDate = startDate.AddDays(30);
                }

                var activeSub = await _subRepo.GetAsync(s => s.UserId == user.Id && s.Status == "Active", isTracking: true);
                if (activeSub != null)
                {
                    // Extend subscription if it was still active
                    if (activeSub.EndDate > now)
                    {
                        startDate = activeSub.StartDate;
                        if (string.Equals(plan.BillingCycle, "Yearly", StringComparison.OrdinalIgnoreCase))
                        {
                            endDate = activeSub.EndDate.AddYears(1);
                        }
                        else
                        {
                            endDate = activeSub.EndDate.AddDays(30);
                        }
                    }

                    activeSub.PlanId = plan.Id;
                    activeSub.Status = "Active";
                    activeSub.AmountPaidEgp = amountPaid;
                    activeSub.Gateway = "Stripe";
                    activeSub.StartDate = startDate;
                    activeSub.EndDate = endDate;
                    activeSub.AutoRenew = true;

                    await _subRepo.UpdateAsync(activeSub);
                    _logger.LogInformation("Extended subscription for user {UserId} with plan {PlanId}", user.Id, plan.Id);
                }
                else
                {
                    var newSub = new UserSubscription
                    {
                        Id = Guid.NewGuid().ToString(),
                        UserId = user.Id,
                        PlanId = plan.Id,
                        Status = "Active",
                        AmountPaidEgp = amountPaid,
                        Gateway = "Stripe",
                        StartDate = startDate,
                        EndDate = endDate,
                        AutoRenew = true,
                        CreatedAt = now
                    };

                    await _subRepo.CreateAsync(newSub);
                    _logger.LogInformation("Created new subscription for user {UserId} with plan {PlanId}", user.Id, plan.Id);
                }

                // 5. Update PromoCode counter if used
                if (!string.IsNullOrWhiteSpace(promoCode))
                {
                    var promo = await _promoRepo.GetAsync(p => p.Code == promoCode.ToUpperInvariant(), isTracking: true);
                    if (promo != null)
                    {
                        promo.UsedCount += 1;
                        await _promoRepo.UpdateAsync(promo);
                    }
                }

                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error executing ProcessSuccessfulPaymentIntentAsync for PaymentIntent {Id}", paymentIntent.Id);
                return false;
            }
        }

        #endregion
    }
}
