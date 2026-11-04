using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using Mahfazti.Core.DTOs.RecurringBills;
using Mahfazti.Core.Entities;
using Mahfazti.Core.Interfaces;

namespace Mahfazti.Core.Services
{
    public class RecurringBillService : IRecurringBillService
    {
        private readonly IRepository<UserRecurringBill> _billRepo;
        private readonly IRepository<Account> _accountRepo;
        private readonly IRepository<WalletTransaction> _transactionRepo;
        private readonly ILogger<RecurringBillService> _logger;

        public RecurringBillService(
            IRepository<UserRecurringBill> billRepo,
            IRepository<Account> accountRepo,
            IRepository<WalletTransaction> transactionRepo,
            ILogger<RecurringBillService> logger)
        {
            _billRepo = billRepo;
            _accountRepo = accountRepo;
            _transactionRepo = transactionRepo;
            _logger = logger;
        }

        public async Task<List<RecurringBillDto>> GetBillsAsync(string userId)
        {
            var bills = await _billRepo.GetAllAsync(
                filter: b => b.UserId == userId && !b.IsDeleted,
                includeProperties: "Account,Category",
                orderBy: q => q.OrderBy(b => b.RenewalDay),
                isTracking: false
            );

            return bills.Select(MapToDto).ToList();
        }

        public async Task<RecurringBillDto?> GetBillByIdAsync(int id, string userId)
        {
            var bill = await _billRepo.GetAsync(
                filter: b => b.Id == id && b.UserId == userId && !b.IsDeleted,
                includeProperties: "Account,Category",
                isTracking: false
            );

            return bill != null ? MapToDto(bill) : null;
        }

        public async Task<RecurringBillDto> CreateBillAsync(string userId, CreateRecurringBillDto dto)
        {
            var nextDue = dto.NextDueDate ?? CalculateNextDueDate(dto.RenewalDay, dto.BillingCycle);

            var entity = new UserRecurringBill
            {
                UserId = userId,
                Title = dto.Title.Trim(),
                Amount = dto.Amount,
                Currency = string.IsNullOrWhiteSpace(dto.Currency) ? "EGP" : dto.Currency.ToUpperInvariant(),
                BillingCycle = dto.BillingCycle.ToLowerInvariant(),
                RenewalDay = dto.RenewalDay,
                NextDueDate = nextDue,
                AccountId = dto.AccountId,
                CategoryId = dto.CategoryId,
                IconCode = dto.IconCode,
                IsActive = dto.IsActive,
                AutoRecordTransaction = dto.AutoRecordTransaction,
                CreatedAt = DateTime.UtcNow
            };

            await _billRepo.CreateAsync(entity);
            await _billRepo.SaveAsync();

            return await GetBillByIdAsync(entity.Id, userId) ?? MapToDto(entity);
        }

        public async Task<RecurringBillDto?> UpdateBillAsync(int id, string userId, UpdateRecurringBillDto dto)
        {
            var entity = await _billRepo.GetAsync(
                filter: b => b.Id == id && b.UserId == userId && !b.IsDeleted,
                isTracking: true
            );

            if (entity == null) return null;

            entity.Title = dto.Title.Trim();
            entity.Amount = dto.Amount;
            entity.Currency = string.IsNullOrWhiteSpace(dto.Currency) ? "EGP" : dto.Currency.ToUpperInvariant();
            entity.BillingCycle = dto.BillingCycle.ToLowerInvariant();
            entity.RenewalDay = dto.RenewalDay;
            entity.NextDueDate = dto.NextDueDate ?? CalculateNextDueDate(dto.RenewalDay, dto.BillingCycle);
            entity.AccountId = dto.AccountId;
            entity.CategoryId = dto.CategoryId;
            entity.IconCode = dto.IconCode;
            entity.IsActive = dto.IsActive;
            entity.AutoRecordTransaction = dto.AutoRecordTransaction;
            entity.UpdatedAt = DateTime.UtcNow;

            await _billRepo.UpdateAsync(entity);
            await _billRepo.SaveAsync();

            return await GetBillByIdAsync(entity.Id, userId);
        }

        public async Task<bool> DeleteBillAsync(int id, string userId)
        {
            var entity = await _billRepo.GetAsync(
                filter: b => b.Id == id && b.UserId == userId && !b.IsDeleted,
                isTracking: true
            );

            if (entity == null) return false;

            entity.IsDeleted = true;
            entity.UpdatedAt = DateTime.UtcNow;

            await _billRepo.UpdateAsync(entity);
            await _billRepo.SaveAsync();
            return true;
        }

        public async Task<bool> MarkBillPaidAsync(int id, string userId)
        {
            var bill = await _billRepo.GetAsync(
                filter: b => b.Id == id && b.UserId == userId && !b.IsDeleted,
                isTracking: true
            );

            if (bill == null) return false;

            // Record transaction if requested
            if (bill.AccountId.HasValue)
            {
                var account = await _accountRepo.GetAsync(a => a.Id == bill.AccountId.Value && a.UserId == userId, isTracking: true);
                if (account != null)
                {
                    account.Balance -= bill.Amount;
                    await _accountRepo.UpdateAsync(account);
                }
            }

            var transaction = new WalletTransaction
            {
                UserId = userId,
                AccountId = bill.AccountId,
                CategoryId = bill.CategoryId,
                RecurringBillId = bill.Id,
                Title = bill.Title,
                Description = $"سداد اشتراك: {bill.Title}",
                Amount = bill.Amount,
                Currency = bill.Currency,
                Type = "Withdrawal",
                TransactionDate = DateTime.UtcNow,
                IsRecurring = true,
                RecurringInterval = bill.BillingCycle,
                CreatedAt = DateTime.UtcNow
            };

            await _transactionRepo.CreateAsync(transaction);

            // Advance next due date
            bill.NextDueDate = CalculateNextDueDate(bill.RenewalDay, bill.BillingCycle, DateTime.UtcNow.AddDays(5));
            bill.UpdatedAt = DateTime.UtcNow;

            await _billRepo.UpdateAsync(bill);
            await _billRepo.SaveAsync();
            return true;
        }

        private static DateTime CalculateNextDueDate(int renewalDay, string cycle, DateTime? fromDate = null)
        {
            var baseDate = fromDate ?? DateTime.UtcNow;
            int year = baseDate.Year;
            int month = baseDate.Month;

            // clamp day
            int daysInMonth = DateTime.DaysInMonth(year, month);
            int day = Math.Clamp(renewalDay, 1, daysInMonth);

            var candidate = new DateTime(year, month, day, 12, 0, 0, DateTimeKind.Utc);
            if (candidate <= baseDate)
            {
                if (cycle.Equals("yearly", StringComparison.OrdinalIgnoreCase))
                {
                    candidate = candidate.AddYears(1);
                }
                else
                {
                    candidate = candidate.AddMonths(1);
                }
            }

            return candidate;
        }

        private static RecurringBillDto MapToDto(UserRecurringBill b)
        {
            return new RecurringBillDto
            {
                Id = b.Id,
                Title = b.Title,
                Amount = b.Amount,
                Currency = b.Currency,
                BillingCycle = b.BillingCycle,
                RenewalDay = b.RenewalDay,
                NextDueDate = b.NextDueDate,
                AccountId = b.AccountId,
                AccountName = b.Account?.Name,
                CategoryId = b.CategoryId,
                CategoryNameAr = b.Category?.NameAr,
                CategoryNameEn = b.Category?.NameEn,
                IconCode = b.IconCode,
                IsActive = b.IsActive,
                AutoRecordTransaction = b.AutoRecordTransaction,
                CreatedAt = b.CreatedAt
            };
        }
    }
}
