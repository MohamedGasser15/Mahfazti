// Application/Services/WalletService.cs
using Microsoft.Extensions.Logging;
using MyWallet.Application.DTOs.Wallet;
using MyWallet.Application.ServiceInterfaces;
using MyWallet.Domain.Entites;
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
        private readonly IRepository<Category> _categoryRepository;  
        private readonly ILogger<WalletService> _logger;

        public WalletService(
            IRepository<WalletTransaction> transactionRepository,
            IRepository<Category> categoryRepository,              
            ILogger<WalletService> logger)
        {
            _transactionRepository = transactionRepository;
            _categoryRepository = categoryRepository;             
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

                // جلب آخر 5 معاملات مع تحميل التصنيفات
                var recentTransactions = await _transactionRepository.GetAllAsync(
                    filter: t => t.UserId == userId && !t.IsDeleted,
                    includeProperties: "Category", // تحميل التصنيف
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
                includeProperties: "Category",
                isTracking: false
            );
            return transaction == null ? null : MapToDto(transaction);
        }

        public async Task<TransactionListResponseDto> GetTransactionsAsync(string userId, TransactionFilterDto filter)
        {
            // بناء الفلتر
            Expression<Func<WalletTransaction, bool>> predicate = t =>
                t.UserId == userId && !t.IsDeleted;

            if (!string.IsNullOrEmpty(filter.Type))
            {
                var type = filter.Type;
                predicate = predicate.AndAlso(t => t.Type == type);
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

            // الحصول على العدد الكلي
            var totalCount = (await _transactionRepository.GetAllAsync(
                filter: predicate,
                isTracking: false
            )).Count;

            // الحصول على المعاملات مع التصنيفات
            var transactions = await _transactionRepository.GetAllAsync(
                filter: predicate,
                includeProperties: "Category",
                orderBy: q => q.OrderByDescending(t => t.TransactionDate),
                isTracking: false
            );

            // تطبيق pagination في الذاكرة (مؤقتاً)
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
            var category = await _categoryRepository.GetAsync(
                filter: c => c.Id == dto.CategoryId,
                isTracking: false
            );

            var transaction = new WalletTransaction
            {
                UserId = userId,
                Title = GenerateTitle(dto.Type, category),
                Description = dto.Description,
                Amount = dto.Amount,
                Type = dto.Type,
                CategoryId = dto.CategoryId,
                TransactionDate = DateTime.UtcNow,
                IsRecurring = false,
                CreatedAt = DateTime.UtcNow
            };

            await _transactionRepository.CreateAsync(transaction);

            var created = await _transactionRepository.GetAsync(
                filter: t => t.Id == transaction.Id,
                includeProperties: "Category",
                isTracking: false
            );

            return MapToDto(created!);
        }

        public async Task<WalletTransactionDto> UpdateTransactionAsync(
            int id, string userId, AddTransactionDto dto)
        {
            var transaction = await _transactionRepository.GetAsync(
                filter: t => t.Id == id && t.UserId == userId && !t.IsDeleted,
                isTracking: true
            );

            if (transaction == null)
                throw new KeyNotFoundException("Transaction not found");

            var category = await _categoryRepository.GetAsync(
                filter: c => c.Id == dto.CategoryId,
                isTracking: false
            );

            transaction.Title = GenerateTitle(dto.Type, category);
            transaction.Description = dto.Description;
            transaction.Amount = dto.Amount;
            transaction.Type = dto.Type;
            transaction.CategoryId = dto.CategoryId;
            transaction.UpdatedAt = DateTime.UtcNow;

            await _transactionRepository.SaveAsync();

            var updated = await _transactionRepository.GetAsync(
                filter: t => t.Id == transaction.Id,
                includeProperties: "Category",
                isTracking: false
            );

            return MapToDto(updated!);
        }

        // ✅ دالة توليد العنوان الذكي
        private static string GenerateTitle(string type, Category? category)
        {
            if (category == null)
                return type == "Deposit" ? "General Income" : "General Expense";

            return category.NameEn switch
            {
                // ===== Income Categories =====
                "Salary" => "Work Income",
                "Bonus" => "Extra Earnings",
                "Income" => "Money Received",

                // ===== Expense Categories =====
                "Food" => "Food & Drinks",
                "Transport" => "Transport",
                "Shopping" => "Shopping",
                "Entertainment" => "Entertainment",
                "Health" => "Health & Care",
                "Bills" => "Bills & Utilities",
                "Education" => "Education",
                "Other" => type == "Deposit" ? "Other Income" : "Other Expense",

                // fallback
                _ => type == "Deposit" ? "Income" : "Expense"
            };
        }
        public async Task<bool> DeleteTransactionAsync(int id, string userId)
        {
            var transaction = await _transactionRepository.GetAsync(
                filter: t => t.Id == id && t.UserId == userId && !t.IsDeleted,
                isTracking: true
            );

            if (transaction == null)
                return false;

            transaction.IsDeleted = true;
            transaction.UpdatedAt = DateTime.UtcNow;

            await _transactionRepository.SaveAsync();
            return true;
        }

        public async Task<object> GetSummaryAsync(string userId, DateTime? fromDate, DateTime? toDate)
        {
            Expression<Func<WalletTransaction, bool>> predicate = t =>
                t.UserId == userId && !t.IsDeleted;

            if (fromDate.HasValue)
                predicate = predicate.AndAlso(t => t.TransactionDate >= fromDate.Value);
            if (toDate.HasValue)
                predicate = predicate.AndAlso(t => t.TransactionDate <= toDate.Value);

            // جلب المعاملات مع التصنيفات لتجميعها حسب الفئة
            var transactions = await _transactionRepository.GetAllAsync(
                filter: predicate,
                includeProperties: "Category",
                isTracking: false
            );

            // تجميع المصروفات حسب الفئة
            var expensesByCategory = transactions
                .Where(t => t.Type == "Withdrawal")
                .GroupBy(t => new { t.CategoryId, t.Category!.NameAr, t.Category!.NameEn })
                .Select(g => new
                {
                    CategoryId = g.Key.CategoryId,
                    CategoryNameAr = g.Key.NameAr,
                    CategoryNameEn = g.Key.NameEn,
                    Total = g.Sum(t => t.Amount),
                    Count = g.Count()
                })
                .OrderByDescending(g => g.Total)
                .ToList();

            // تجميع الإيرادات حسب الفئة
            var incomeByCategory = transactions
                .Where(t => t.Type == "Deposit")
                .GroupBy(t => new { t.CategoryId, t.Category!.NameAr, t.Category!.NameEn })
                .Select(g => new
                {
                    CategoryId = g.Key.CategoryId,
                    CategoryNameAr = g.Key.NameAr,
                    CategoryNameEn = g.Key.NameEn,
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

        // دالة التحويل مع تعبئة أسماء التصنيفات
        private static WalletTransactionDto MapToDto(WalletTransaction entity)
        {
            return new WalletTransactionDto
            {
                Id = entity.Id,
                Title = entity.Title,
                Description = entity.Description,
                Amount = entity.Amount,
                Type = entity.Type,
                CategoryId = entity.CategoryId,
                CategoryNameAr = entity.Category?.NameAr,
                CategoryNameEn = entity.Category?.NameEn,
                TransactionDate = entity.TransactionDate,
            };
        }
    }

    // Predicate builder helper (كما هو)
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