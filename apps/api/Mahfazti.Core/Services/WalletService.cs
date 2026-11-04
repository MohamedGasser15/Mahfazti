// Application/Services/WalletService.cs
using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using Mahfazti.Core.DTOs.Wallet;
using Mahfazti.Core.Entities;
using Mahfazti.Core.Interfaces;

namespace Mahfazti.Core.Services
{
    public class WalletService : IWalletService
    {
        private readonly IRepository<WalletTransaction> _transactionRepository;
        private readonly IRepository<Category> _categoryRepository;
        private readonly IRepository<Account> _accountRepository;
        private readonly ILogger<WalletService> _logger;

        public WalletService(
            IRepository<WalletTransaction> transactionRepository,
            IRepository<Category> categoryRepository,
            IRepository<Account> accountRepository,
            ILogger<WalletService> logger)
        {
            _transactionRepository = transactionRepository;
            _categoryRepository = categoryRepository;
            _accountRepository = accountRepository;
            _logger = logger;
        }

        public async Task<WalletHomeDataDto> GetHomeDataAsync(
            string userId,
            int? accountId = null,
            DateTime? fromDate = null,
            DateTime? toDate = null)
        {
            try
            {
                _logger.LogInformation("Getting home data for user {UserId}, account: {AccountId}, from: {From}, to: {To}",
                    userId, accountId, fromDate, toDate);

                var now = DateTime.UtcNow;
                var start = fromDate ?? new DateTime(now.Year, now.Month, 1, 0, 0, 0, DateTimeKind.Utc);
                var end = toDate ?? new DateTime(start.Year, start.Month, 1, 0, 0, 0, DateTimeKind.Utc).AddMonths(1).AddTicks(-1);

                var totalBalance = await GetHomeTotalBalanceAsync(userId, accountId);

                Expression<Func<WalletTransaction, bool>> filter = t =>
                    t.UserId == userId && !t.IsDeleted &&
                    t.TransactionDate >= start &&
                    t.TransactionDate <= end;

                if (accountId.HasValue)
                {
                    filter = filter.AndAlso(t => t.AccountId == accountId || t.ToAccountId == accountId);
                }

                var allMatching = (await _transactionRepository.GetAllAsync(filter: filter, isTracking: false)) ?? new List<WalletTransaction>();
                var totalCount = allMatching.Count;

                var recentTransactions = (await _transactionRepository.GetAllAsync(
                    filter: filter,
                    includeProperties: "Category,Account,ToAccount",
                    orderBy: q => q.OrderByDescending(t => t.TransactionDate).ThenByDescending(t => t.CreatedAt),
                    take: 5,
                    isTracking: false
                )) ?? new List<WalletTransaction>();

                var periodDeposits = allMatching
                    .Where(t => IsType(t.Type, "Deposit") || IsType(t.Type, "Income") || (IsType(t.Type, "Transfer") && accountId.HasValue && t.ToAccountId == accountId))
                    .Sum(t => t.Amount);

                var periodWithdrawals = allMatching
                    .Where(t => IsType(t.Type, "Withdrawal") || IsType(t.Type, "Expense") || (IsType(t.Type, "Transfer") && accountId.HasValue && t.AccountId == accountId))
                    .Sum(t => t.Amount + t.TransferFee);

                return new WalletHomeDataDto
                {
                    Balance = new WalletBalanceDto
                    {
                        TotalBalance = totalBalance,
                        TotalDeposits = periodDeposits,
                        TotalWithdrawals = periodWithdrawals
                    },
                    RecentTransactions = recentTransactions.Select(MapToDto).ToList(),
                    TotalTransactionCount = totalCount
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting home data for user {UserId}", userId);
                throw;
            }
        }

        private async Task<decimal> GetHomeTotalBalanceAsync(string userId, int? accountId)
        {
            if (accountId.HasValue)
            {
                var account = await _accountRepository.GetAsync(
                    a => a.Id == accountId.Value && a.UserId == userId && !a.IsDeleted,
                    isTracking: false);
                if (account != null) return account.Balance;
            }

            var accounts = (await _accountRepository.GetAllAsync(
                a => a.UserId == userId && !a.IsDeleted && !a.ExcludeFromTotal,
                isTracking: false)) ?? new List<Account>();

            if (accounts.Count == 0)
                return (await GetBalanceAsync(userId, accountId)).TotalBalance;

            return accounts
                       .Where(a => !string.Equals(a.Type, "credit_card", StringComparison.OrdinalIgnoreCase))
                       .Sum(a => a.Balance)
                   - accounts
                       .Where(a => string.Equals(a.Type, "credit_card", StringComparison.OrdinalIgnoreCase))
                       .Sum(a => Math.Abs(a.Balance));
        }

        public async Task<WalletBalanceDto> GetBalanceAsync(string userId, int? accountId = null)
        {
            try
            {
                if (accountId.HasValue)
                {
                    var account = await _accountRepository.GetAsync(
                        a => a.Id == accountId.Value && a.UserId == userId && !a.IsDeleted,
                        isTracking: false
                    );

                    if (account != null)
                    {
                        var accTx = await _transactionRepository.GetAllAsync(
                            t => t.UserId == userId && !t.IsDeleted && (t.AccountId == accountId || t.ToAccountId == accountId),
                            isTracking: false
                        );

                        var deposits = accTx.Where(t => (IsType(t.Type, "Deposit") || IsType(t.Type, "Income") || (IsType(t.Type, "Transfer") && t.ToAccountId == accountId))).Sum(t => t.Amount);
                        var withdrawals = accTx.Where(t => (IsType(t.Type, "Withdrawal") || IsType(t.Type, "Expense") || (IsType(t.Type, "Transfer") && t.AccountId == accountId))).Sum(t => t.Amount + t.TransferFee);

                        return new WalletBalanceDto
                        {
                            TotalBalance = account.Balance,
                            TotalDeposits = deposits,
                            TotalWithdrawals = withdrawals
                        };
                    }
                }

                // Overall balance from non-excluded accounts
                var accounts = (await _accountRepository.GetAllAsync(
                    a => a.UserId == userId && !a.IsDeleted && !a.ExcludeFromTotal,
                    isTracking: false
                )) ?? new List<Account>();

                decimal totalBalance = 0m;
                if (accounts.Any())
                {
                    totalBalance = accounts.Where(a => a.Type != "credit_card").Sum(a => a.Balance)
                                 - accounts.Where(a => a.Type == "credit_card").Sum(a => Math.Abs(a.Balance));
                }

                var allTx = (await _transactionRepository.GetAllAsync(
                    t => t.UserId == userId && !t.IsDeleted,
                    isTracking: false
                )) ?? new List<WalletTransaction>();

                var totalDep = allTx.Where(t => IsType(t.Type, "Deposit") || IsType(t.Type, "Income")).Sum(t => t.Amount);
                var totalWth = allTx.Where(t => IsType(t.Type, "Withdrawal") || IsType(t.Type, "Expense")).Sum(t => t.Amount + t.TransferFee);

                if (!accounts.Any())
                {
                    totalBalance = totalDep - totalWth;
                }

                return new WalletBalanceDto
                {
                    TotalDeposits = totalDep,
                    TotalWithdrawals = totalWth,
                    TotalBalance = totalBalance
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting balance for user {UserId}", userId);
                throw;
            }
        }

        public async Task<WalletTransactionDto?> GetTransactionByIdAsync(int id, string userId)
        {
            var transaction = await _transactionRepository.GetAsync(
                filter: t => t.Id == id && t.UserId == userId && !t.IsDeleted,
                includeProperties: "Category,Account,ToAccount",
                isTracking: false
            );
            return transaction == null ? null : MapToDto(transaction);
        }

        public async Task<TransactionListResponseDto> GetTransactionsAsync(string userId, TransactionFilterDto filter)
        {
            Expression<Func<WalletTransaction, bool>> predicate = t =>
                t.UserId == userId && !t.IsDeleted;

            if (filter.AccountId.HasValue)
            {
                var accId = filter.AccountId.Value;
                predicate = predicate.AndAlso(t => t.AccountId == accId || t.ToAccountId == accId);
            }

            if (!string.IsNullOrEmpty(filter.Type))
            {
                var type = filter.Type;
                if (type.Equals("Income", StringComparison.OrdinalIgnoreCase))
                {
                    predicate = predicate.AndAlso(t => t.Type == "Deposit" || t.Type == "Income");
                }
                else if (type.Equals("Expense", StringComparison.OrdinalIgnoreCase))
                {
                    predicate = predicate.AndAlso(t => t.Type == "Withdrawal" || t.Type == "Expense");
                }
                else
                {
                    predicate = predicate.AndAlso(t => t.Type == type);
                }
            }

            if (filter.CategoryId.HasValue)
            {
                predicate = predicate.AndAlso(t => t.CategoryId == filter.CategoryId.Value);
            }

            if (filter.FromDate.HasValue)
            {
                predicate = predicate.AndAlso(t => t.TransactionDate >= filter.FromDate.Value);
            }

            if (filter.ToDate.HasValue)
            {
                predicate = predicate.AndAlso(t => t.TransactionDate <= filter.ToDate.Value);
            }

            var allMatches = (await _transactionRepository.GetAllAsync(filter: predicate, isTracking: false)) ?? new List<WalletTransaction>();
            var totalCount = allMatches.Count;

            var transactions = (await _transactionRepository.GetAllAsync(
                filter: predicate,
                includeProperties: "Category,Account,ToAccount",
                orderBy: q => q.OrderByDescending(t => t.TransactionDate).ThenByDescending(t => t.CreatedAt),
                isTracking: false
            )) ?? new List<WalletTransaction>();

            var paged = transactions
                .Skip((filter.Page - 1) * filter.PageSize)
                .Take(filter.PageSize)
                .ToList();

            return new TransactionListResponseDto
            {
                Transactions = paged.Select(MapToDto).ToList(),
                TotalCount = totalCount,
                Page = filter.Page,
                PageSize = filter.PageSize
            };
        }

        public async Task<WalletTransactionDto> AddTransactionAsync(string userId, AddTransactionDto dto)
        {
            var category = dto.CategoryId.HasValue
                ? await _categoryRepository.GetAsync(c => c.Id == dto.CategoryId.Value, isTracking: false)
                : null;

            var title = !string.IsNullOrWhiteSpace(dto.Title)
                ? dto.Title.Trim()
                : GenerateTitle(dto.Type, category);

            var transaction = new WalletTransaction
            {
                UserId = userId,
                AccountId = dto.AccountId,
                ToAccountId = dto.ToAccountId,
                Title = title,
                Description = dto.Description,
                Amount = dto.Amount,
                TransferFee = dto.TransferFee,
                Currency = string.IsNullOrWhiteSpace(dto.Currency) ? "EGP" : dto.Currency.ToUpperInvariant(),
                ExchangeRate = dto.ExchangeRate > 0 ? dto.ExchangeRate : 1.0m,
                Type = dto.Type,
                CategoryId = dto.CategoryId,
                TransactionDate = dto.TransactionDate ?? DateTime.UtcNow,
                ReceiptImageUrl = dto.ReceiptImageUrl,
                RecurringBillId = dto.RecurringBillId,
                IsRecurring = dto.IsRecurring,
                RecurringInterval = dto.RecurringInterval,
                RecurringEndDate = dto.RecurringEndDate,
                Tags = dto.Tags,
                CreatedAt = DateTime.UtcNow
            };

            // Update account balance
            if (dto.AccountId.HasValue)
            {
                var account = await _accountRepository.GetAsync(a => a.Id == dto.AccountId.Value && a.UserId == userId, isTracking: true);
                if (account != null)
                {
                    if (dto.Type.Equals("Withdrawal", StringComparison.OrdinalIgnoreCase) || dto.Type.Equals("Expense", StringComparison.OrdinalIgnoreCase))
                    {
                        account.Balance -= (dto.Amount + dto.TransferFee);
                    }
                    else if (dto.Type.Equals("Deposit", StringComparison.OrdinalIgnoreCase) || dto.Type.Equals("Income", StringComparison.OrdinalIgnoreCase))
                    {
                        account.Balance += dto.Amount;
                    }
                    else if (dto.Type.Equals("Transfer", StringComparison.OrdinalIgnoreCase))
                    {
                        account.Balance -= (dto.Amount + dto.TransferFee);
                        if (dto.ToAccountId.HasValue)
                        {
                            var toAccount = await _accountRepository.GetAsync(a => a.Id == dto.ToAccountId.Value && a.UserId == userId, isTracking: true);
                            if (toAccount != null)
                            {
                                toAccount.Balance += dto.Amount;
                                await _accountRepository.UpdateAsync(toAccount);
                            }
                        }
                    }
                    account.UpdatedAt = DateTime.UtcNow;
                    await _accountRepository.UpdateAsync(account);
                }
            }

            await _transactionRepository.CreateAsync(transaction);
            await _transactionRepository.SaveAsync();

            var created = await _transactionRepository.GetAsync(
                filter: t => t.Id == transaction.Id,
                includeProperties: "Category,Account,ToAccount",
                isTracking: false
            );

            return MapToDto(created ?? transaction);
        }

        public async Task<WalletTransactionDto> UpdateTransactionAsync(int id, string userId, AddTransactionDto dto)
        {
            var transaction = await _transactionRepository.GetAsync(
                filter: t => t.Id == id && t.UserId == userId && !t.IsDeleted,
                isTracking: true
            );

            if (transaction == null)
                throw new KeyNotFoundException("Transaction not found");

            // Revert old account impact
            if (transaction.AccountId.HasValue)
            {
                var oldAccount = await _accountRepository.GetAsync(a => a.Id == transaction.AccountId.Value && a.UserId == userId, isTracking: true);
                if (oldAccount != null)
                {
                    if (transaction.Type.Equals("Withdrawal", StringComparison.OrdinalIgnoreCase) || transaction.Type.Equals("Expense", StringComparison.OrdinalIgnoreCase))
                        oldAccount.Balance += (transaction.Amount + transaction.TransferFee);
                    else if (transaction.Type.Equals("Deposit", StringComparison.OrdinalIgnoreCase) || transaction.Type.Equals("Income", StringComparison.OrdinalIgnoreCase))
                        oldAccount.Balance -= transaction.Amount;
                    else if (transaction.Type.Equals("Transfer", StringComparison.OrdinalIgnoreCase))
                    {
                        oldAccount.Balance += (transaction.Amount + transaction.TransferFee);
                        if (transaction.ToAccountId.HasValue)
                        {
                            var oldTo = await _accountRepository.GetAsync(a => a.Id == transaction.ToAccountId.Value && a.UserId == userId, isTracking: true);
                            if (oldTo != null)
                            {
                                oldTo.Balance -= transaction.Amount;
                                await _accountRepository.UpdateAsync(oldTo);
                            }
                        }
                    }
                    await _accountRepository.UpdateAsync(oldAccount);
                }
            }

            var category = dto.CategoryId.HasValue
                ? await _categoryRepository.GetAsync(c => c.Id == dto.CategoryId.Value, isTracking: false)
                : null;

            transaction.Title = !string.IsNullOrWhiteSpace(dto.Title) ? dto.Title.Trim() : GenerateTitle(dto.Type, category);
            transaction.Description = dto.Description;
            transaction.Amount = dto.Amount;
            transaction.TransferFee = dto.TransferFee;
            transaction.Type = dto.Type;
            transaction.CategoryId = dto.CategoryId;
            transaction.AccountId = dto.AccountId;
            transaction.ToAccountId = dto.ToAccountId;
            transaction.Currency = string.IsNullOrWhiteSpace(dto.Currency) ? "EGP" : dto.Currency.ToUpperInvariant();
            transaction.ExchangeRate = dto.ExchangeRate > 0 ? dto.ExchangeRate : 1.0m;
            transaction.ReceiptImageUrl = dto.ReceiptImageUrl;
            transaction.Tags = dto.Tags;
            if (dto.TransactionDate.HasValue)
            {
                transaction.TransactionDate = dto.TransactionDate.Value;
            }
            transaction.UpdatedAt = DateTime.UtcNow;

            // Apply new account impact
            if (dto.AccountId.HasValue)
            {
                var newAccount = await _accountRepository.GetAsync(a => a.Id == dto.AccountId.Value && a.UserId == userId, isTracking: true);
                if (newAccount != null)
                {
                    if (dto.Type.Equals("Withdrawal", StringComparison.OrdinalIgnoreCase) || dto.Type.Equals("Expense", StringComparison.OrdinalIgnoreCase))
                        newAccount.Balance -= (dto.Amount + dto.TransferFee);
                    else if (dto.Type.Equals("Deposit", StringComparison.OrdinalIgnoreCase) || dto.Type.Equals("Income", StringComparison.OrdinalIgnoreCase))
                        newAccount.Balance += dto.Amount;
                    else if (dto.Type.Equals("Transfer", StringComparison.OrdinalIgnoreCase))
                    {
                        newAccount.Balance -= (dto.Amount + dto.TransferFee);
                        if (dto.ToAccountId.HasValue)
                        {
                            var toAcc = await _accountRepository.GetAsync(a => a.Id == dto.ToAccountId.Value && a.UserId == userId, isTracking: true);
                            if (toAcc != null)
                            {
                                toAcc.Balance += dto.Amount;
                                await _accountRepository.UpdateAsync(toAcc);
                            }
                        }
                    }
                    await _accountRepository.UpdateAsync(newAccount);
                }
            }

            await _transactionRepository.UpdateAsync(transaction);
            await _transactionRepository.SaveAsync();

            var updated = await _transactionRepository.GetAsync(
                filter: t => t.Id == transaction.Id,
                includeProperties: "Category,Account,ToAccount",
                isTracking: false
            );

            return MapToDto(updated ?? transaction);
        }

        public async Task<WalletTransactionDto> TransferAsync(string userId, TransferRequestDto dto)
        {
            var fromAccount = await _accountRepository.GetAsync(a => a.Id == dto.FromAccountId && a.UserId == userId, isTracking: true);
            var toAccount = await _accountRepository.GetAsync(a => a.Id == dto.ToAccountId && a.UserId == userId, isTracking: true);

            if (fromAccount == null || toAccount == null)
                throw new InvalidOperationException("Source or destination account was not found.");

            fromAccount.Balance -= (dto.Amount + dto.TransferFee);
            toAccount.Balance += dto.Amount;

            fromAccount.UpdatedAt = DateTime.UtcNow;
            toAccount.UpdatedAt = DateTime.UtcNow;

            await _accountRepository.UpdateAsync(fromAccount);
            await _accountRepository.UpdateAsync(toAccount);

            var title = !string.IsNullOrWhiteSpace(dto.Title)
                ? dto.Title.Trim()
                : $"تحويل من {fromAccount.Name} إلى {toAccount.Name}";

            var tx = new WalletTransaction
            {
                UserId = userId,
                AccountId = dto.FromAccountId,
                ToAccountId = dto.ToAccountId,
                Title = title,
                Description = dto.Note,
                Amount = dto.Amount,
                TransferFee = dto.TransferFee,
                Currency = fromAccount.Currency,
                Type = "Transfer",
                TransactionDate = dto.TransactionDate ?? DateTime.UtcNow,
                CreatedAt = DateTime.UtcNow
            };

            await _transactionRepository.CreateAsync(tx);
            await _transactionRepository.SaveAsync();

            var created = await _transactionRepository.GetAsync(t => t.Id == tx.Id, includeProperties: "Account,ToAccount", isTracking: false);
            return MapToDto(created!);
        }

        public async Task<bool> DeleteTransactionAsync(int id, string userId)
        {
            var transaction = await _transactionRepository.GetAsync(
                filter: t => t.Id == id && t.UserId == userId && !t.IsDeleted,
                isTracking: true
            );

            if (transaction == null)
                return false;

            // Revert balance impact
            if (transaction.AccountId.HasValue)
            {
                var account = await _accountRepository.GetAsync(a => a.Id == transaction.AccountId.Value && a.UserId == userId, isTracking: true);
                if (account != null)
                {
                    if (transaction.Type.Equals("Withdrawal", StringComparison.OrdinalIgnoreCase) || transaction.Type.Equals("Expense", StringComparison.OrdinalIgnoreCase))
                        account.Balance += (transaction.Amount + transaction.TransferFee);
                    else if (transaction.Type.Equals("Deposit", StringComparison.OrdinalIgnoreCase) || transaction.Type.Equals("Income", StringComparison.OrdinalIgnoreCase))
                        account.Balance -= transaction.Amount;
                    else if (transaction.Type.Equals("Transfer", StringComparison.OrdinalIgnoreCase))
                    {
                        account.Balance += (transaction.Amount + transaction.TransferFee);
                        if (transaction.ToAccountId.HasValue)
                        {
                            var toAcc = await _accountRepository.GetAsync(a => a.Id == transaction.ToAccountId.Value && a.UserId == userId, isTracking: true);
                            if (toAcc != null)
                            {
                                toAcc.Balance -= transaction.Amount;
                                await _accountRepository.UpdateAsync(toAcc);
                            }
                        }
                    }
                    await _accountRepository.UpdateAsync(account);
                }
            }

            transaction.IsDeleted = true;
            transaction.UpdatedAt = DateTime.UtcNow;

            await _transactionRepository.UpdateAsync(transaction);
            await _transactionRepository.SaveAsync();
            return true;
        }

        public async Task<object> GetSummaryAsync(string userId, DateTime? fromDate, DateTime? toDate, int? accountId = null)
        {
            Expression<Func<WalletTransaction, bool>> predicate = t =>
                t.UserId == userId && !t.IsDeleted;

            if (accountId.HasValue)
            {
                var accId = accountId.Value;
                predicate = predicate.AndAlso(t => t.AccountId == accId || t.ToAccountId == accId);
            }

            if (fromDate.HasValue)
                predicate = predicate.AndAlso(t => t.TransactionDate >= fromDate.Value);
            if (toDate.HasValue)
                predicate = predicate.AndAlso(t => t.TransactionDate <= toDate.Value);

            var transactions = await _transactionRepository.GetAllAsync(
                filter: predicate,
                includeProperties: "Category",
                isTracking: false
            );

            var expensesByCategory = transactions
                .Where(t => IsType(t.Type, "Withdrawal") || IsType(t.Type, "Expense"))
                .GroupBy(t => new { t.CategoryId, NameAr = t.Category?.NameAr ?? "أخرى", NameEn = t.Category?.NameEn ?? "Other" })
                .Select(g => new
                {
                    CategoryId = g.Key.CategoryId ?? 0,
                    CategoryNameAr = g.Key.NameAr,
                    CategoryNameEn = g.Key.NameEn,
                    Total = g.Sum(t => t.Amount),
                    Count = g.Count()
                })
                .OrderByDescending(g => g.Total)
                .ToList();

            var incomeByCategory = transactions
                .Where(t => IsType(t.Type, "Deposit") || IsType(t.Type, "Income"))
                .GroupBy(t => new { t.CategoryId, NameAr = t.Category?.NameAr ?? "أخرى", NameEn = t.Category?.NameEn ?? "Other" })
                .Select(g => new
                {
                    CategoryId = g.Key.CategoryId ?? 0,
                    CategoryNameAr = g.Key.NameAr,
                    CategoryNameEn = g.Key.NameEn,
                    Total = g.Sum(t => t.Amount),
                    Count = g.Count()
                })
                .OrderByDescending(g => g.Total)
                .ToList();

            var totalIncome = transactions.Where(t => IsType(t.Type, "Deposit") || IsType(t.Type, "Income")).Sum(t => t.Amount);
            var totalExpenses = transactions.Where(t => IsType(t.Type, "Withdrawal") || IsType(t.Type, "Expense")).Sum(t => t.Amount + t.TransferFee);

            return new
            {
                TotalIncome = totalIncome,
                TotalExpenses = totalExpenses,
                NetSavings = totalIncome - totalExpenses,
                ExpensesByCategory = expensesByCategory,
                IncomeByCategory = incomeByCategory,
                TransactionCount = transactions.Count
            };
        }

        private static bool IsType(string? actual, string expected) =>
            string.Equals(actual, expected, StringComparison.OrdinalIgnoreCase);

        private static string GenerateTitle(string type, Category? category)
        {
            if (category == null)
                return (type == "Deposit" || type == "Income") ? "دخل عام" : "مصروف عام";

            return !string.IsNullOrEmpty(category.NameAr) ? category.NameAr : category.NameEn;
        }

        private static WalletTransactionDto MapToDto(WalletTransaction entity)
        {
            return new WalletTransactionDto
            {
                Id = entity.Id,
                UserId = entity.UserId,
                AccountId = entity.AccountId,
                AccountName = entity.Account?.Name,
                ToAccountId = entity.ToAccountId,
                ToAccountName = entity.ToAccount?.Name,
                Title = entity.Title,
                Description = entity.Description,
                Amount = entity.Amount,
                TransferFee = entity.TransferFee,
                Currency = entity.Currency,
                ExchangeRate = entity.ExchangeRate,
                Type = entity.Type,
                CategoryId = entity.CategoryId,
                CategoryNameAr = entity.Category?.NameAr,
                CategoryNameEn = entity.Category?.NameEn,
                ReceiptImageUrl = entity.ReceiptImageUrl,
                RecurringBillId = entity.RecurringBillId,
                IsRecurring = entity.IsRecurring,
                RecurringInterval = entity.RecurringInterval,
                RecurringEndDate = entity.RecurringEndDate,
                Tags = entity.Tags,
                TransactionDate = entity.TransactionDate,
                CreatedAt = entity.CreatedAt,
                UpdatedAt = entity.UpdatedAt
            };
        }
    }

    public static class PredicateBuilder
    {
        public static Expression<Func<T, bool>> AndAlso<T>(
            this Expression<Func<T, bool>> expr1,
            Expression<Func<T, bool>> expr2)
        {
            var parameter = Expression.Parameter(typeof(T));
            var leftVisitor = new ReplaceExpressionVisitor(expr1.Parameters[0], parameter);
            var left = leftVisitor.Visit(expr1.Body);
            var rightVisitor = new ReplaceExpressionVisitor(expr2.Parameters[0], parameter);
            var right = rightVisitor.Visit(expr2.Body);

            return Expression.Lambda<Func<T, bool>>(
                Expression.AndAlso(left!, right!), parameter);
        }

        private class ReplaceExpressionVisitor : ExpressionVisitor
        {
            private readonly Expression _oldValue;
            private readonly Expression _newValue;

            public ReplaceExpressionVisitor(Expression oldValue, Expression newValue)
            {
                _oldValue = oldValue;
                _newValue = newValue;
            }

            public override Expression? Visit(Expression? node)
            {
                return node == _oldValue ? _newValue : base.Visit(node);
            }
        }
    }
}
