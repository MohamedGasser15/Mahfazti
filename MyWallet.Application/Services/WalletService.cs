// Application/Services/WalletService.cs
using Microsoft.Extensions.Logging;
using MyWallet.Application.DTOs.Wallet;
using MyWallet.Application.ServiceInterfaces;
using MyWallet.Infrastructure.Entities;
using MyWallet.Infrastructure.Persistence.IRepository;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Threading.Tasks;

namespace MyWallet.Application.Services
{
    public class WalletService : IWalletService
    {
        private readonly IRepository<WalletTransaction> _transactionRepository;
        private readonly ILogger<WalletService> _logger;

        public WalletService(
            IRepository<WalletTransaction> transactionRepository,
            ILogger<WalletService> logger)
        {
            _transactionRepository = transactionRepository;
            _logger = logger;
        }

        public async Task<WalletHomeDataDto> GetHomeDataAsync(string userId)
        {
            try
            {
                _logger.LogInformation("Getting home data for user {UserId}", userId);

                var balance = await GetBalanceAsync(userId);

                // احسب العدد الإجمالي للمعاملات (غير المحذوفة)
                var totalCount = (await _transactionRepository.GetAllAsync(
                    filter: t => t.UserId == userId && !t.IsDeleted,
                    isTracking: false
                )).Count;

                // جلب آخر 5 معاملات فقط
                var recentTransactions = await _transactionRepository.GetAllAsync(
                    filter: t => t.UserId == userId && !t.IsDeleted,
                    orderBy: q => q.OrderByDescending(t => t.TransactionDate),
                    take: 5,
                    isTracking: false
                );

                return new WalletHomeDataDto
                {
                    Balance = balance,
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

        public async Task<WalletBalanceDto> GetBalanceAsync(string userId)
        {
            try
            {
                // Get all non-deleted transactions for the user
                var transactions = await _transactionRepository.GetAllAsync(
                    filter: t => t.UserId == userId && !t.IsDeleted,
                    isTracking: false
                );

                var totalDeposits = transactions
                    .Where(t => t.Type == "Deposit")
                    .Sum(t => t.Amount);

                var totalWithdrawals = transactions
                    .Where(t => t.Type == "Withdrawal")
                    .Sum(t => t.Amount);

                return new WalletBalanceDto
                {
                    TotalDeposits = totalDeposits,
                    TotalWithdrawals = totalWithdrawals,
                    TotalBalance = totalDeposits - totalWithdrawals
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
                isTracking: false
            );
            return transaction == null ? null : MapToDto(transaction);
        }

        public async Task<TransactionListResponseDto> GetTransactionsAsync(string userId, TransactionFilterDto filter)
        {
            // Build filter expression
            Expression<Func<WalletTransaction, bool>> predicate = t =>
                t.UserId == userId && !t.IsDeleted;

            if (!string.IsNullOrEmpty(filter.Type))
            {
                var type = filter.Type;
                predicate = predicate.AndAlso(t => t.Type == type);
            }

            if (!string.IsNullOrEmpty(filter.Category))
            {
                predicate = predicate.AndAlso(t => t.Category == filter.Category);
            }

            if (filter.FromDate.HasValue)
            {
                predicate = predicate.AndAlso(t => t.TransactionDate >= filter.FromDate.Value);
            }

            if (filter.ToDate.HasValue)
            {
                predicate = predicate.AndAlso(t => t.TransactionDate <= filter.ToDate.Value);
            }

            // Get total count
            var totalCount = await _transactionRepository.GetAllAsync(
                filter: predicate,
                isTracking: false
            );
            var count = totalCount.Count;

            // Get paged results
            var transactions = await _transactionRepository.GetAllAsync(
                filter: predicate,
                orderBy: q => q.OrderByDescending(t => t.TransactionDate),
                take: filter.PageSize,
                isTracking: false
            // Note: Skip not implemented in generic repo; we need to implement pagination.
            // For now, we'll fetch all and then skip/take in memory (not ideal).
            // Better to enhance generic repo with pagination support.
            );

            // Apply pagination in memory (temporary)
            var paged = transactions
                .Skip((filter.Page - 1) * filter.PageSize)
                .Take(filter.PageSize)
                .ToList();

            return new TransactionListResponseDto
            {
                Transactions = paged.Select(MapToDto).ToList(),
                TotalCount = count,
                Page = filter.Page,
                PageSize = filter.PageSize
            };
        }

        public async Task<WalletTransactionDto> AddTransactionAsync(string userId, AddTransactionDto dto)
        {
            var transaction = new WalletTransaction
            {
                UserId = userId,
                Title = dto.Title,
                Description = dto.Description,
                Amount = dto.Amount,
                Type = dto.Type,
                Category = dto.Category,
                TransactionDate = dto.TransactionDate,
                IsRecurring = dto.IsRecurring,
                RecurringInterval = dto.RecurringInterval,
                RecurringEndDate = dto.RecurringEndDate,
                CreatedAt = DateTime.UtcNow
            };

            await _transactionRepository.CreateAsync(transaction);
            return MapToDto(transaction);
        }

        public async Task<bool> DeleteTransactionAsync(int id, string userId)
        {
            var transaction = await _transactionRepository.GetAsync(
                filter: t => t.Id == id && t.UserId == userId && !t.IsDeleted,
                isTracking: true // need tracking to update
            );

            if (transaction == null)
                return false;

            // Soft delete
            transaction.IsDeleted = true;
            transaction.UpdatedAt = DateTime.UtcNow;

            await _transactionRepository.SaveAsync();
            return true;
        }

        public async Task<object> GetSummaryAsync(string userId, DateTime? fromDate, DateTime? toDate)
        {
            // Build filter
            Expression<Func<WalletTransaction, bool>> predicate = t =>
                t.UserId == userId && !t.IsDeleted;

            if (fromDate.HasValue)
                predicate = predicate.AndAlso(t => t.TransactionDate >= fromDate.Value);
            if (toDate.HasValue)
                predicate = predicate.AndAlso(t => t.TransactionDate <= toDate.Value);

            var transactions = await _transactionRepository.GetAllAsync(
                filter: predicate,
                isTracking: false
            );

            // Group by category for expenses (withdrawals)
            var expensesByCategory = transactions
                .Where(t => t.Type == "Withdrawal")
                .GroupBy(t => t.Category)
                .Select(g => new
                {
                    Category = g.Key,
                    Total = g.Sum(t => t.Amount),
                    Count = g.Count()
                })
                .OrderByDescending(g => g.Total)
                .ToList();

            // Income by category (deposits)
            var incomeByCategory = transactions
                .Where(t => t.Type == "Deposit")
                .GroupBy(t => t.Category)
                .Select(g => new
                {
                    Category = g.Key,
                    Total = g.Sum(t => t.Amount),
                    Count = g.Count()
                })
                .OrderByDescending(g => g.Total)
                .ToList();

            var totalIncome = transactions.Where(t => t.Type == "Deposit").Sum(t => t.Amount);
            var totalExpenses = transactions.Where(t => t.Type == "Withdrawal").Sum(t => t.Amount);

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

        // Helper mapping
        private static WalletTransactionDto MapToDto(WalletTransaction entity)
        {
            return new WalletTransactionDto
            {
                Id = entity.Id,
                Title = entity.Title,
                Description = entity.Description,
                Amount = entity.Amount,
                Type = entity.Type,
                Category = entity.Category,
                TransactionDate = entity.TransactionDate,
                IsRecurring = entity.IsRecurring,
                RecurringInterval = entity.RecurringInterval,
                RecurringEndDate = entity.RecurringEndDate
            };
        }
    }

    // Predicate builder helper
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
                Expression.AndAlso(left, right), parameter);
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

            public override Expression Visit(Expression node)
            {
                return node == _oldValue ? _newValue : base.Visit(node);
            }
        }
    }
}