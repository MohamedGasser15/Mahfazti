using Microsoft.Extensions.Logging;
using Mahfazti.Core.DTOs.Budget;
using Mahfazti.Core.Interfaces;
using Mahfazti.Core.Entities;

namespace Mahfazti.Core.Services
{
    public class BudgetService : IBudgetService
    {
        private readonly IRepository<UserBudget> _budgetRepository;
        private readonly IRepository<WalletTransaction> _transactionRepository;
        private readonly IRepository<Category> _categoryRepository;
        private readonly IRepository<CategoryBudget> _categoryBudgetRepository;
        private readonly ILogger<BudgetService> _logger;

        public BudgetService(
            IRepository<UserBudget> budgetRepository,
            IRepository<WalletTransaction> transactionRepository,
            IRepository<Category> categoryRepository,
            IRepository<CategoryBudget> categoryBudgetRepository,
            ILogger<BudgetService> logger)
        {
            _budgetRepository = budgetRepository;
            _transactionRepository = transactionRepository;
            _categoryRepository = categoryRepository;
            _categoryBudgetRepository = categoryBudgetRepository;
            _logger = logger;
        }

        public async Task<BudgetDto> GetBudgetAsync(string userId, int? month = null, int? year = null)
        {
            var now = DateTime.UtcNow;
            var currentMonth = (month.HasValue && month.Value >= 1 && month.Value <= 12) ? month.Value : now.Month;
            var currentYear = (year.HasValue && year.Value >= 2000) ? year.Value : now.Year;

            var budgetEntity = await _budgetRepository.GetAsync(
                filter: b => b.UserId == userId && b.Month == currentMonth && b.Year == currentYear,
                isTracking: false
            );

            // If user explicitly configured this month, use it.
            // Otherwise, roll over their most recently configured monthly budget amount.
            decimal monthlyBudget = 0m;
            if (budgetEntity != null)
            {
                monthlyBudget = budgetEntity.MonthlyBudget;
            }
            else
            {
                var userBudgets = await _budgetRepository.GetAllAsync(
                    filter: b => b.UserId == userId,
                    orderBy: q => q.OrderByDescending(b => b.Year).ThenByDescending(b => b.Month),
                    take: 1,
                    isTracking: false
                );
                var latestBudget = userBudgets?.FirstOrDefault();
                monthlyBudget = latestBudget?.MonthlyBudget ?? 0m;
            }

            var startOfMonth = new DateTime(currentYear, currentMonth, 1, 0, 0, 0, DateTimeKind.Utc);
            var endOfMonth = startOfMonth.AddMonths(1).AddTicks(-1);

            var transactions = await _transactionRepository.GetAllAsync(
                filter: t => t.UserId == userId && !t.IsDeleted &&
                             t.TransactionDate >= startOfMonth &&
                             t.TransactionDate <= endOfMonth,
                includeProperties: "Category",
                isTracking: false
            );

            var currentSpending = transactions
                .Where(t => t.Type == "Withdrawal")
                .Sum(t => t.Amount);

            var expensesByCategory = transactions
                .Where(t => t.Type == "Withdrawal" && t.CategoryId.HasValue)
                .GroupBy(t => t.CategoryId!.Value)
                .Select(g => new
                {
                    CategoryId = g.Key,
                    Total = g.Sum(t => t.Amount)
                })
                .ToDictionary(x => x.CategoryId, x => x.Total);

            var allCategories = await _categoryRepository.GetAllAsync(
                filter: c => (c.UserId == userId || c.UserId == null) && c.IsActive && c.Type != "Income",
                orderBy: q => q.OrderBy(c => c.NameEn),
                isTracking: false
            );

            int? userBudgetId = budgetEntity?.Id;
            var categoryBudgets = new List<CategoryBudget>();

            if (userBudgetId.HasValue)
            {
                categoryBudgets = (await _categoryBudgetRepository.GetAllAsync(
                    filter: cb => cb.UserBudgetId == userBudgetId.Value,
                    includeProperties: "Category",
                    isTracking: false
                )) ?? new List<CategoryBudget>();
            }

            var categoryBudgetDtos = new List<CategoryBudgetDto>();

            if (categoryBudgets.Any())
            {
                foreach (var cb in categoryBudgets)
                {
                    categoryBudgetDtos.Add(new CategoryBudgetDto
                    {
                        Id = cb.Id,
                        CategoryId = cb.CategoryId,
                        CategoryNameAr = cb.Category.NameAr,
                        CategoryNameEn = cb.Category.NameEn,
                        BudgetAmount = cb.BudgetAmount,
                        Spent = expensesByCategory.ContainsKey(cb.CategoryId) ? expensesByCategory[cb.CategoryId] : 0
                    });
                }
            }
            else
            {
                foreach (var category in allCategories)
                {
                    categoryBudgetDtos.Add(new CategoryBudgetDto
                    {
                        Id = 0,
                        CategoryId = category.Id,
                        CategoryNameAr = category.NameAr,
                        CategoryNameEn = category.NameEn,
                        BudgetAmount = 0m,
                        Spent = expensesByCategory.ContainsKey(category.Id) ? expensesByCategory[category.Id] : 0
                    });
                }
            }

            return new BudgetDto
            {
                MonthlyBudget = monthlyBudget,
                CurrentSpending = currentSpending,
                CategoryBudgets = categoryBudgetDtos
            };
        }
        public async Task UpdateCategoryBudgetAsync(string userId, int categoryId, decimal budgetAmount)
        {
            var now = DateTime.UtcNow;
            var budgetEntity = await _budgetRepository.GetAsync(
                filter: b => b.UserId == userId && b.Month == now.Month && b.Year == now.Year,
                isTracking: true
            );

            if (budgetEntity == null)
            {
                throw new Exception("No monthly budget found for current month");
            }

            var categoryBudget = await _categoryBudgetRepository.GetAsync(
                filter: cb => cb.UserBudgetId == budgetEntity.Id && cb.CategoryId == categoryId,
                isTracking: true
            );

            if (categoryBudget == null)
            {
                categoryBudget = new CategoryBudget
                {
                    UserBudgetId = budgetEntity.Id,
                    CategoryId = categoryId,
                    BudgetAmount = budgetAmount
                };
                await _categoryBudgetRepository.CreateAsync(categoryBudget);
            }
            else
            {
                categoryBudget.BudgetAmount = budgetAmount;
                await _categoryBudgetRepository.UpdateAsync(categoryBudget);
            }
        }
        public async Task<UserBudget?> GetUserBudgetAsync(string userId, int month, int year)
        {
            return await _budgetRepository.GetAsync(
                filter: b => b.UserId == userId && b.Month == month && b.Year == year,
                isTracking: false
            );
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

        public async Task UpdateCategoryBudgetAsync(int userBudgetId, int categoryId, decimal budgetAmount)
        {
            var categoryBudget = await _categoryBudgetRepository.GetAsync(
                filter: cb => cb.UserBudgetId == userBudgetId && cb.CategoryId == categoryId,
                isTracking: true
            );

            if (categoryBudget == null)
            {
                categoryBudget = new CategoryBudget
                {
                    UserBudgetId = userBudgetId,
                    CategoryId = categoryId,
                    BudgetAmount = budgetAmount
                };
                await _categoryBudgetRepository.CreateAsync(categoryBudget);
            }
            else
            {
                categoryBudget.BudgetAmount = budgetAmount;
                await _categoryBudgetRepository.UpdateAsync(categoryBudget);
            }
        }
    }
}