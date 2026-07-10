using Microsoft.Extensions.Logging;
using Moq;
using MyWallet.Core.Entities;
using MyWallet.Core.Interfaces;
using MyWallet.Core.Services;

namespace MyWallet.UnitTests.Services;

public class BudgetServiceTests
{
    private readonly Mock<IRepository<UserBudget>> _budgetRepoMock;
    private readonly Mock<IRepository<WalletTransaction>> _txRepoMock;
    private readonly Mock<IRepository<Category>> _catRepoMock;
    private readonly Mock<IRepository<CategoryBudget>> _catBudgetRepoMock;
    private readonly BudgetService _sut;

    public BudgetServiceTests()
    {
        _budgetRepoMock = new Mock<IRepository<UserBudget>>();
        _txRepoMock = new Mock<IRepository<WalletTransaction>>();
        _catRepoMock = new Mock<IRepository<Category>>();
        _catBudgetRepoMock = new Mock<IRepository<CategoryBudget>>();
        _sut = new BudgetService(
            _budgetRepoMock.Object,
            _txRepoMock.Object,
            _catRepoMock.Object,
            _catBudgetRepoMock.Object,
            Mock.Of<ILogger<BudgetService>>());
    }

    [Fact]
    public async Task GetBudgetAsync_WithNoSavedBudget_ShouldReturnDefaults()
    {
        var userId = "user1";

        _budgetRepoMock.Setup(x => x.GetAsync(
                It.IsAny<System.Linq.Expressions.Expression<System.Func<UserBudget, bool>>>(),
                null, false, default))
            .ReturnsAsync((UserBudget?)null);

        _txRepoMock.Setup(x => x.GetAllAsync(
                It.IsAny<System.Linq.Expressions.Expression<System.Func<WalletTransaction, bool>>>(),
                "Category", false, null, null, default))
            .ReturnsAsync(new List<WalletTransaction>());

        var categories = new List<Category>
        {
            new() { Id = 1, NameAr = "طعام", NameEn = "Food" },
            new() { Id = 2, NameAr = "مواصلات", NameEn = "Transport" },
        };

        _catRepoMock.Setup(x => x.GetAllAsync(
                null, null, false,
                It.IsAny<Func<IQueryable<Category>, IOrderedQueryable<Category>>?>(),
                null, default))
            .ReturnsAsync(categories);

        var result = await _sut.GetBudgetAsync(userId);

        Assert.Equal(3000m, result.MonthlyBudget);
        Assert.Equal(0, result.CurrentSpending);
        Assert.Equal(2, result.CategoryBudgets.Count);
    }

    [Fact]
    public async Task GetBudgetAsync_WithSavedBudget_ShouldReturnIt()
    {
        var userId = "user1";
        var budget = new UserBudget { Id = 1, UserId = userId, MonthlyBudget = 5000m, Month = DateTime.UtcNow.Month, Year = DateTime.UtcNow.Year };

        _budgetRepoMock.Setup(x => x.GetAsync(
                It.IsAny<System.Linq.Expressions.Expression<System.Func<UserBudget, bool>>>(),
                null, false, default))
            .ReturnsAsync(budget);

        _txRepoMock.Setup(x => x.GetAllAsync(
                It.IsAny<System.Linq.Expressions.Expression<System.Func<WalletTransaction, bool>>>(),
                "Category", false, null, null, default))
            .ReturnsAsync(new List<WalletTransaction>());

        _catBudgetRepoMock.Setup(x => x.GetAllAsync(
                It.IsAny<System.Linq.Expressions.Expression<System.Func<CategoryBudget, bool>>>(),
                "Category", false, null, null, default))
            .ReturnsAsync(new List<CategoryBudget>
            {
                new() { Id = 1, UserBudgetId = 1, CategoryId = 1, BudgetAmount = 1000, Category = new Category { Id = 1, NameAr = "طعام", NameEn = "Food" } },
            });

        var result = await _sut.GetBudgetAsync(userId);

        Assert.Equal(5000m, result.MonthlyBudget);
        Assert.Single(result.CategoryBudgets);
        Assert.Equal(1000m, result.CategoryBudgets[0].BudgetAmount);
    }

    [Fact]
    public async Task UpdateCategoryBudgetAsync_WhenNoMonthlyBudget_ShouldThrow()
    {
        _budgetRepoMock.Setup(x => x.GetAsync(
                It.IsAny<System.Linq.Expressions.Expression<System.Func<UserBudget, bool>>>(),
                null, true, default))
            .ReturnsAsync((UserBudget?)null);

        await Assert.ThrowsAsync<Exception>(() =>
            _sut.UpdateCategoryBudgetAsync("user1", 1, 500));
    }

    [Fact]
    public async Task UpdateMonthlyBudgetAsync_WhenNoExisting_ShouldCreate()
    {
        _budgetRepoMock.Setup(x => x.GetAsync(
                It.IsAny<System.Linq.Expressions.Expression<System.Func<UserBudget, bool>>>(),
                null, true, default))
            .ReturnsAsync((UserBudget?)null);

        _budgetRepoMock.Setup(x => x.CreateAsync(It.IsAny<UserBudget>(), default))
            .Returns(Task.CompletedTask);

        await _sut.UpdateMonthlyBudgetAsync("user1", 4000m);

        _budgetRepoMock.Verify(x => x.CreateAsync(It.Is<UserBudget>(b =>
            b.UserId == "user1" && b.MonthlyBudget == 4000m), default), Times.Once);
    }

    [Fact]
    public async Task UpdateMonthlyBudgetAsync_WhenExisting_ShouldUpdate()
    {
        var existing = new UserBudget { Id = 1, UserId = "user1", MonthlyBudget = 3000m };
        _budgetRepoMock.Setup(x => x.GetAsync(
                It.IsAny<System.Linq.Expressions.Expression<System.Func<UserBudget, bool>>>(),
                null, true, default))
            .ReturnsAsync(existing);
        _budgetRepoMock.Setup(x => x.UpdateAsync(existing, default))
            .Returns(Task.CompletedTask);

        await _sut.UpdateMonthlyBudgetAsync("user1", 5000m);

        Assert.Equal(5000m, existing.MonthlyBudget);
    }

    [Fact]
    public async Task GetUserBudgetAsync_ShouldReturnBudget()
    {
        var budget = new UserBudget { Id = 1, UserId = "user1", Month = 7, Year = 2026 };
        _budgetRepoMock.Setup(x => x.GetAsync(
                It.IsAny<System.Linq.Expressions.Expression<System.Func<UserBudget, bool>>>(),
                null, false, default))
            .ReturnsAsync(budget);

        var result = await _sut.GetUserBudgetAsync("user1", 7, 2026);

        Assert.NotNull(result);
        Assert.Equal(7, result.Month);
    }
}
