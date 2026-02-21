// Application/Services/BudgetService.cs
using Microsoft.Extensions.Logging;
using MyWallet.Application.DTOs.Budget;
using MyWallet.Application.ServiceInterfaces;
using MyWallet.Domain.Entites;
using MyWallet.Infrastructure.Entities;
using MyWallet.Infrastructure.Persistence.IRepository;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace MyWallet.Application.Services
{
    public class BudgetService : IBudgetService
    {
        private readonly IRepository<UserBudget> _budgetRepository;
        private readonly IRepository<WalletTransaction> _transactionRepository;
        private readonly ILogger<BudgetService> _logger;

        public BudgetService(
            IRepository<UserBudget> budgetRepository,
            IRepository<WalletTransaction> transactionRepository,
            ILogger<BudgetService> logger)
        {
            _budgetRepository = budgetRepository;
            _transactionRepository = transactionRepository;
            _logger = logger;
        }

        public async Task<BudgetDto> GetBudgetAsync(string userId)
        {
            var now = DateTime.UtcNow;
            var currentMonth = now.Month;
            var currentYear = now.Year;

            // 1. جلب الميزانية المسجلة لهذا الشهر (إن وجدت)
            var budgetEntity = await _budgetRepository.GetAsync(
                filter: b => b.UserId == userId && b.Month == currentMonth && b.Year == currentYear,
                isTracking: false
            );

            decimal monthlyBudget = budgetEntity?.MonthlyBudget ?? 3000m; // قيمة افتراضية

            // 2. حساب المصروفات لهذا الشهر
            var startOfMonth = new DateTime(currentYear, currentMonth, 1);
            var endOfMonth = startOfMonth.AddMonths(1).AddDays(-1);

            var transactions = await _transactionRepository.GetAllAsync(
                filter: t => t.UserId == userId && !t.IsDeleted &&
                             t.TransactionDate >= startOfMonth &&
                             t.TransactionDate <= endOfMonth,
                isTracking: false
            );

            var currentSpending = transactions
                .Where(t => t.Type == "Withdrawal")
                .Sum(t => t.Amount);

            // 3. تجميع المصروفات حسب الفئة
            var expensesByCategory = transactions
                .Where(t => t.Type == "Withdrawal")
                .GroupBy(t => t.Category)
                .Select(g => new
                {
                    Category = g.Key,
                    Total = g.Sum(t => t.Amount)
                })
                .ToDictionary(x => x.Category, x => x.Total);

            // 4. إعداد قائمة الفئات مع الميزانية (يمكن أن تكون من إعدادات المستخدم لاحقاً)
            // سنستخدم ميزانيات افتراضية لكل فئة (أو يمكن تخزينها في جدول منفصل)
            var defaultCategoryBudgets = new Dictionary<string, decimal>
            {
                ["Food"] = 500,
                ["Shopping"] = 400,
                ["Transportation"] = 200,
                ["Entertainment"] = 300,
                ["Bills"] = 800,
                ["Other"] = 800
            };

            var categoryBudgets = new List<CategoryBudgetDto>();
            foreach (var kv in defaultCategoryBudgets)
            {
                categoryBudgets.Add(new CategoryBudgetDto
                {
                    Category = kv.Key,
                    Budget = kv.Value,
                    Spent = expensesByCategory.ContainsKey(kv.Key) ? expensesByCategory[kv.Key] : 0
                });
            }

            return new BudgetDto
            {
                MonthlyBudget = monthlyBudget,
                CurrentSpending = currentSpending,
                CategoryBudgets = categoryBudgets
            };
        }

        public async Task UpdateMonthlyBudgetAsync(string userId, decimal monthlyBudget)
        {
            var now = DateTime.UtcNow;
            var currentMonth = now.Month;
            var currentYear = now.Year;

            var budgetEntity = await _budgetRepository.GetAsync(
                filter: b => b.UserId == userId && b.Month == currentMonth && b.Year == currentYear,
                isTracking: true
            );

            if (budgetEntity == null)
            {
                budgetEntity = new UserBudget
                {
                    UserId = userId,
                    Month = currentMonth,
                    Year = currentYear,
                    MonthlyBudget = monthlyBudget,
                    CreatedAt = now
                };
                await _budgetRepository.CreateAsync(budgetEntity);
            }
            else
            {
                budgetEntity.MonthlyBudget = monthlyBudget;
                budgetEntity.UpdatedAt = now;
                await _budgetRepository.UpdateAsync(budgetEntity);
            }
        }
    }
}