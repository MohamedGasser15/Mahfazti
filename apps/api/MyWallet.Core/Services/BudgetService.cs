using Microsoft.Extensions.Logging;
using MyWallet.Core.DTOs.Budget;
using MyWallet.Core.Interfaces;
using MyWallet.Core.Entities;

namespace MyWallet.Core.Services
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

        public async Task<BudgetDto> GetBudgetAsync(string userId)
        {
            var now = DateTime.UtcNow;
            var currentMonth = now.Month;
            var currentYear = now.Year;

            var budgetEntity = await _budgetRepository.GetAsync(
                filter: b => b.UserId == userId && b.Month == currentMonth && b.Year == currentYear,
                isTracking: false
            );

            decimal monthlyBudget = budgetEntity?.MonthlyBudget ?? 3000m;

            var startOfMonth = new DateTime(currentYear, currentMonth, 1);
            var endOfMonth = startOfMonth.AddMonths(1).AddDays(-1);

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
                orderBy: q => q.OrderBy(c => c.NameEn),
                isTracking: false
            );

            int? userBudgetId = budgetEntity?.Id;
            var categoryBudgets = new List<CategoryBudget>();

            if (userBudgetId.HasValue)
            {
                categoryBudgets = await _categoryBudgetRepository.GetAllAsync(
                    filter: cb => cb.UserBudgetId == userBudgetId.Value,
                    includeProperties: "Category",
                    isTracking: false
                );
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
                var defaultBudgets = new Dictionary<string, decimal>
                {
                    ["Food"] = 500,
                    ["Shopping"] = 400,
                    ["Transportation"] = 200,
                    ["Entertainment"] = 300,
                    ["Bills"] = 800,
                    ["Other"] = 800
                };

                foreach (var category in allCategories)
                {
                    decimal budgetAmount = defaultBudgets.ContainsKey(category.NameEn)
                        ? defaultBudgets[category.NameEn]
                        : 100;

                    categoryBudgetDtos.Add(new CategoryBudgetDto
                    {
                        Id = 0,
                        CategoryId = category.Id,
                        CategoryNameAr = category.NameAr,
                        CategoryNameEn = category.NameEn,
                        BudgetAmount = budgetAmount,
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