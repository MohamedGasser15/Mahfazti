using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using Mahfazti.Core.DTOs.Accounts;
using Mahfazti.Core.Entities;
using Mahfazti.Core.Interfaces;

namespace Mahfazti.Core.Services
{
    public class AccountService : IAccountService
    {
        private readonly IRepository<Account> _accountRepo;
        private readonly IRepository<FinancialInstitution> _institutionRepo;
        private readonly ILogger<AccountService> _logger;

        public AccountService(
            IRepository<Account> accountRepo,
            IRepository<FinancialInstitution> institutionRepo,
            ILogger<AccountService> logger)
        {
            _accountRepo = accountRepo;
            _institutionRepo = institutionRepo;
            _logger = logger;
        }

        public async Task<List<AccountDto>> GetAccountsAsync(string userId)
        {
            try
            {
                await EnsureDefaultAccountAsync(userId);
                var accounts = await _accountRepo.GetAllAsync(
                    filter: a => a.UserId == userId && !a.IsDeleted,
                    includeProperties: "Institution",
                    orderBy: q => q.OrderByDescending(a => a.IsMain).ThenBy(a => a.CreatedAt),
                    isTracking: false
                );

                return accounts.Select(MapToDto).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting accounts for user {UserId}", userId);
                throw;
            }
        }

        public async Task<AccountDto> EnsureDefaultAccountAsync(string userId, string currency = "EGP", string? preferredLanguage = null)
        {
            var accounts = await _accountRepo.GetAllAsync(
                filter: a => a.UserId == userId && !a.IsDeleted,
                orderBy: q => q.OrderBy(a => a.CreatedAt),
                isTracking: true
            ) ?? new List<Account>();

            var main = accounts.FirstOrDefault(a => a.IsMain) ?? accounts.FirstOrDefault();
            if (main == null)
            {
                return await CreateAccountAsync(userId, new CreateAccountDto
                {
                    Name = preferredLanguage?.StartsWith("en", StringComparison.OrdinalIgnoreCase) == true
                        ? "Main Account"
                        : "الحساب الرئيسي",
                    Type = "cash",
                    Currency = string.IsNullOrWhiteSpace(currency) ? "EGP" : currency,
                    IsMain = true
                });
            }

            if (string.Equals(main.Name, "كاش البيت", StringComparison.Ordinal))
            {
                main.Name = preferredLanguage?.StartsWith("en", StringComparison.OrdinalIgnoreCase) == true
                    ? "Main Account"
                    : "الحساب الرئيسي";
                await _accountRepo.UpdateAsync(main);
                await _accountRepo.SaveAsync();
            }

            foreach (var account in accounts)
            {
                var shouldBeMain = account.Id == main.Id;
                if (account.IsMain != shouldBeMain)
                {
                    account.IsMain = shouldBeMain;
                    await _accountRepo.UpdateAsync(account);
                }
            }

            return MapToDto(main);
        }

        public async Task<AccountDto?> GetAccountByIdAsync(int id, string userId)
        {
            var account = await _accountRepo.GetAsync(
                filter: a => a.Id == id && a.UserId == userId && !a.IsDeleted,
                includeProperties: "Institution",
                isTracking: false
            );

            return account != null ? MapToDto(account) : null;
        }

        public async Task<AccountDto> CreateAccountAsync(string userId, CreateAccountDto dto)
        {
            try
            {
                var existingAccounts = await _accountRepo.GetAllAsync(
                    a => a.UserId == userId && !a.IsDeleted,
                    isTracking: true
                ) ?? new List<Account>();
                var shouldBeMain = dto.IsMain || !existingAccounts.Any(a => a.IsMain);
                var firstExistingMainId = existingAccounts.FirstOrDefault(a => a.IsMain)?.Id;

                // Only one account can be the default.
                foreach (var acc in existingAccounts.Where(a => a.IsMain &&
                             (shouldBeMain || a.Id != firstExistingMainId)))
                {
                    acc.IsMain = false;
                    await _accountRepo.UpdateAsync(acc);
                }

                var entity = new Account
                {
                    UserId = userId,
                    Name = dto.Name.Trim(),
                    Type = dto.Type.ToLowerInvariant(),
                    Currency = string.IsNullOrWhiteSpace(dto.Currency) ? "EGP" : dto.Currency.ToUpperInvariant(),
                    Balance = dto.Balance,
                    InitialBalance = dto.Balance,
                    InstitutionId = dto.InstitutionId,
                    AccountNumber = dto.AccountNumber,
                    IconCode = dto.IconCode,
                    IsMain = shouldBeMain,
                    ExcludeFromTotal = dto.ExcludeFromTotal,
                    NotificationMethod = dto.NotificationMethod,
                    CardNumbersJson = dto.CardNumbersJson,
                    ReceiveAtmWithdrawals = dto.ReceiveAtmWithdrawals,
                    CreditLimit = dto.CreditLimit,
                    BillingDay = dto.BillingDay,
                    DueDay = dto.DueDay,
                    MinPaymentPercentage = dto.MinPaymentPercentage,
                    AutoAddInstapayFee = dto.AutoAddInstapayFee,
                    MetalKarat = dto.MetalKarat,
                    MetalWeightGrams = dto.MetalWeightGrams,
                    MetalPurchasePricePerGram = dto.MetalPurchasePricePerGram,
                    MetalPurchaseDate = dto.MetalPurchaseDate,
                    AutoUpdateMetalPrice = dto.AutoUpdateMetalPrice,
                    PropertyCategory = dto.PropertyCategory,
                    InvestmentPlatform = dto.InvestmentPlatform,
                    TotalInvestedAmount = dto.TotalInvestedAmount,
                    AnnualYieldRate = dto.AnnualYieldRate,
                    AutoEstimateValue = dto.AutoEstimateValue,
                    TargetSavingsGoal = dto.TargetSavingsGoal,
                    Note = dto.Note,
                    CreatedAt = DateTime.UtcNow
                };

                await _accountRepo.CreateAsync(entity);
                await _accountRepo.SaveAsync();

                if (!string.IsNullOrEmpty(entity.InstitutionId))
                {
                    entity.Institution = await _institutionRepo.GetAsync(i => i.Id == entity.InstitutionId);
                }

                return MapToDto(entity);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating account for user {UserId}", userId);
                throw;
            }
        }

        public async Task<AccountDto?> UpdateAccountAsync(int id, string userId, UpdateAccountDto dto)
        {
            var entity = await _accountRepo.GetAsync(
                filter: a => a.Id == id && a.UserId == userId && !a.IsDeleted,
                isTracking: true
            );

            if (entity == null) return null;

            await EnsureDefaultAccountAsync(userId);

            if (dto.IsMain && !entity.IsMain)
            {
                var others = await _accountRepo.GetAllAsync(a => a.UserId == userId && a.Id != id && a.IsMain && !a.IsDeleted);
                foreach (var acc in others)
                {
                    acc.IsMain = false;
                    await _accountRepo.UpdateAsync(acc);
                }
            }

            entity.Name = dto.Name.Trim();
            entity.Type = dto.Type.ToLowerInvariant();
            entity.Currency = string.IsNullOrWhiteSpace(dto.Currency) ? "EGP" : dto.Currency.ToUpperInvariant();
            entity.Balance = dto.Balance;
            entity.InstitutionId = dto.InstitutionId;
            entity.AccountNumber = dto.AccountNumber;
            entity.IconCode = dto.IconCode;
            // A default can only be replaced by promoting another account.
            entity.IsMain = dto.IsMain || entity.IsMain;
            entity.ExcludeFromTotal = dto.ExcludeFromTotal;
            entity.NotificationMethod = dto.NotificationMethod;
            entity.CardNumbersJson = dto.CardNumbersJson;
            entity.ReceiveAtmWithdrawals = dto.ReceiveAtmWithdrawals;
            entity.CreditLimit = dto.CreditLimit;
            entity.BillingDay = dto.BillingDay;
            entity.DueDay = dto.DueDay;
            entity.MinPaymentPercentage = dto.MinPaymentPercentage;
            entity.AutoAddInstapayFee = dto.AutoAddInstapayFee;
            entity.MetalKarat = dto.MetalKarat;
            entity.MetalWeightGrams = dto.MetalWeightGrams;
            entity.MetalPurchasePricePerGram = dto.MetalPurchasePricePerGram;
            entity.MetalPurchaseDate = dto.MetalPurchaseDate;
            entity.AutoUpdateMetalPrice = dto.AutoUpdateMetalPrice;
            entity.PropertyCategory = dto.PropertyCategory;
            entity.InvestmentPlatform = dto.InvestmentPlatform;
            entity.TotalInvestedAmount = dto.TotalInvestedAmount;
            entity.AnnualYieldRate = dto.AnnualYieldRate;
            entity.AutoEstimateValue = dto.AutoEstimateValue;
            entity.TargetSavingsGoal = dto.TargetSavingsGoal;
            entity.Note = dto.Note;
            entity.UpdatedAt = DateTime.UtcNow;

            await _accountRepo.UpdateAsync(entity);
            await _accountRepo.SaveAsync();

            if (!string.IsNullOrEmpty(entity.InstitutionId))
            {
                entity.Institution = await _institutionRepo.GetAsync(i => i.Id == entity.InstitutionId);
            }

            return MapToDto(entity);
        }

        public async Task<bool> DeleteAccountAsync(int id, string userId)
        {
            var entity = await _accountRepo.GetAsync(
                filter: a => a.Id == id && a.UserId == userId && !a.IsDeleted,
                isTracking: true
            );

            if (entity == null) return false;

            await EnsureDefaultAccountAsync(userId);

            if (entity.IsMain)
                throw new InvalidOperationException("The default account cannot be deleted.");

            entity.IsDeleted = true;
            entity.UpdatedAt = DateTime.UtcNow;

            await _accountRepo.UpdateAsync(entity);
            await _accountRepo.SaveAsync();
            return true;
        }

        public async Task<TotalWealthSummaryDto> GetTotalWealthSummaryAsync(string userId)
        {
            var accounts = await _accountRepo.GetAllAsync(
                filter: a => a.UserId == userId && !a.IsDeleted && !a.ExcludeFromTotal,
                isTracking: false
            );

            decimal liquid = 0m;
            decimal assets = 0m;
            decimal debt = 0m;

            foreach (var acc in accounts)
            {
                var type = acc.Type.ToLowerInvariant();
                if (type == "credit_card")
                {
                    debt += Math.Abs(acc.Balance);
                }
                else if (type is "investment" or "gold" or "silver" or "certificate")
                {
                    assets += acc.Balance;
                }
                else
                {
                    liquid += acc.Balance;
                }
            }

            return new TotalWealthSummaryDto
            {
                NetWorth = (liquid + assets) - debt,
                TotalLiquidBalance = liquid,
                TotalAssetsValue = assets,
                TotalDebtsAndCredit = debt,
                AccountsCount = accounts.Count,
                BaseCurrency = "EGP"
            };
        }

        private static AccountDto MapToDto(Account a)
        {
            return new AccountDto
            {
                Id = a.Id,
                Name = a.Name,
                Type = a.Type,
                Currency = a.Currency,
                Balance = a.Balance,
                InitialBalance = a.InitialBalance,
                InstitutionId = a.InstitutionId,
                InstitutionNameAr = a.Institution?.NameAr,
                InstitutionNameEn = a.Institution?.NameEn,
                InstitutionLogoUrl = a.Institution?.LogoUrl ?? a.Institution?.LogoAsset,
                AccountNumber = a.AccountNumber,
                IconCode = a.IconCode,
                IsMain = a.IsMain,
                ExcludeFromTotal = a.ExcludeFromTotal,
                NotificationMethod = a.NotificationMethod,
                CardNumbersJson = a.CardNumbersJson,
                ReceiveAtmWithdrawals = a.ReceiveAtmWithdrawals,
                CreditLimit = a.CreditLimit,
                BillingDay = a.BillingDay,
                DueDay = a.DueDay,
                MinPaymentPercentage = a.MinPaymentPercentage,
                AutoAddInstapayFee = a.AutoAddInstapayFee,
                MetalKarat = a.MetalKarat,
                MetalWeightGrams = a.MetalWeightGrams,
                MetalPurchasePricePerGram = a.MetalPurchasePricePerGram,
                MetalPurchaseDate = a.MetalPurchaseDate,
                AutoUpdateMetalPrice = a.AutoUpdateMetalPrice,
                PropertyCategory = a.PropertyCategory,
                InvestmentPlatform = a.InvestmentPlatform,
                TotalInvestedAmount = a.TotalInvestedAmount,
                AnnualYieldRate = a.AnnualYieldRate,
                AutoEstimateValue = a.AutoEstimateValue,
                TargetSavingsGoal = a.TargetSavingsGoal,
                Note = a.Note,
                CreatedAt = a.CreatedAt
            };
        }
    }
}
