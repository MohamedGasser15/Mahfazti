using Microsoft.Extensions.Logging;
using Moq;
using Mahfazti.Core.DTOs.Wallet;
using Mahfazti.Core.Entities;
using Mahfazti.Core.Interfaces;
using Mahfazti.Core.Services;

namespace Mahfazti.UnitTests.Services;

public class WalletServiceTests
{
    private readonly Mock<IRepository<WalletTransaction>> _txRepoMock;
    private readonly Mock<IRepository<Category>> _catRepoMock;
    private readonly Mock<ILogger<WalletService>> _loggerMock;
    private readonly WalletService _sut;

    public WalletServiceTests()
    {
        _txRepoMock = new Mock<IRepository<WalletTransaction>>();
        _catRepoMock = new Mock<IRepository<Category>>();
        _loggerMock = new Mock<ILogger<WalletService>>();
        _sut = new WalletService(_txRepoMock.Object, _catRepoMock.Object, _loggerMock.Object);
    }

    [Fact]
    public async Task GetBalanceAsync_WithTransactions_ShouldCalculateCorrectly()
    {
        var userId = "user1";
        var transactions = new List<WalletTransaction>
        {
            new() { UserId = userId, Type = "Deposit", Amount = 1000, IsDeleted = false },
            new() { UserId = userId, Type = "Deposit", Amount = 500, IsDeleted = false },
            new() { UserId = userId, Type = "Withdrawal", Amount = 300, IsDeleted = false },
            new() { UserId = userId, Type = "Withdrawal", Amount = 200, IsDeleted = false },
        };

        _txRepoMock.Setup(x => x.GetAllAsync(
                It.IsAny<System.Linq.Expressions.Expression<System.Func<WalletTransaction, bool>>>(),
                null, false, null, null, default))
            .ReturnsAsync(transactions);

        var result = await _sut.GetBalanceAsync(userId);

        Assert.Equal(1500m, result.TotalDeposits);
        Assert.Equal(500m, result.TotalWithdrawals);
        Assert.Equal(1000m, result.TotalBalance);
    }

    [Fact]
    public async Task GetBalanceAsync_WithNoTransactions_ShouldReturnZero()
    {
        _txRepoMock.Setup(x => x.GetAllAsync(
                It.IsAny<System.Linq.Expressions.Expression<System.Func<WalletTransaction, bool>>>(),
                null, false, null, null, default))
            .ReturnsAsync(new List<WalletTransaction>());

        var result = await _sut.GetBalanceAsync("user1");

        Assert.Equal(0, result.TotalBalance);
        Assert.Equal(0, result.TotalDeposits);
        Assert.Equal(0, result.TotalWithdrawals);
    }

    [Fact]
    public async Task GetHomeDataAsync_ShouldReturnBalanceAndRecentTransactions()
    {
        var userId = "user1";
        var transactions = new List<WalletTransaction>
        {
            new() { Id = 1, UserId = userId, Type = "Deposit", Amount = 500, Title = "Income", TransactionDate = DateTime.UtcNow, IsDeleted = false, Category = new Category { Id = 1, NameAr = "راتب", NameEn = "Salary" } },
            new() { Id = 2, UserId = userId, Type = "Withdrawal", Amount = 100, Title = "Food", TransactionDate = DateTime.UtcNow.AddHours(-1), IsDeleted = false, Category = new Category { Id = 2, NameAr = "طعام", NameEn = "Food" } },
        };

        _txRepoMock.Setup(x => x.GetAllAsync(
                It.Is<System.Linq.Expressions.Expression<System.Func<WalletTransaction, bool>>>(e => true),
                null, false, null, null, default))
            .ReturnsAsync(transactions);

        _txRepoMock.Setup(x => x.GetAllAsync(
                It.Is<System.Linq.Expressions.Expression<System.Func<WalletTransaction, bool>>>(e => true),
                It.Is<string?>(s => s == "Category"),
                false,
                It.IsAny<System.Func<IQueryable<WalletTransaction>, IOrderedQueryable<WalletTransaction>>?>(),
                5,
                default))
            .ReturnsAsync(transactions.OrderByDescending(t => t.TransactionDate).Take(5).ToList());

        var result = await _sut.GetHomeDataAsync(userId);

        Assert.NotNull(result);
        Assert.Equal(2, result.TotalTransactionCount);
        Assert.Equal(400m, result.Balance.TotalBalance);
    }

    [Fact]
    public async Task GetTransactionByIdAsync_WhenExists_ShouldReturnTransaction()
    {
        var tx = new WalletTransaction
        {
            Id = 1, UserId = "user1", Title = "Test", Amount = 100, Type = "Withdrawal",
            IsDeleted = false, Category = new Category { Id = 1, NameAr = "طعام", NameEn = "Food" }
        };

        _txRepoMock.Setup(x => x.GetAsync(
                It.IsAny<System.Linq.Expressions.Expression<System.Func<WalletTransaction, bool>>>(),
                "Category", false, default))
            .ReturnsAsync(tx);

        var result = await _sut.GetTransactionByIdAsync(1, "user1");

        Assert.NotNull(result);
        Assert.Equal(100, result.Amount);
        Assert.Equal("Food", result.CategoryNameEn);
    }

    [Fact]
    public async Task GetTransactionByIdAsync_WhenNotExists_ShouldReturnNull()
    {
        _txRepoMock.Setup(x => x.GetAsync(
                It.IsAny<System.Linq.Expressions.Expression<System.Func<WalletTransaction, bool>>>(),
                "Category", false, default))
            .ReturnsAsync((WalletTransaction?)null);

        var result = await _sut.GetTransactionByIdAsync(999, "user1");

        Assert.Null(result);
    }

    [Fact]
    public async Task AddTransactionAsync_ShouldCreateAndReturnTransaction()
    {
        var userId = "user1";
        var dto = new AddTransactionDto { Amount = 200, Type = "Withdrawal", CategoryId = 1, Description = "Lunch" };
        var category = new Category { Id = 1, NameAr = "طعام", NameEn = "Food" };

        _catRepoMock.Setup(x => x.GetAsync(
                It.IsAny<System.Linq.Expressions.Expression<System.Func<Category, bool>>>(),
                null, false, default))
            .ReturnsAsync(category);

        WalletTransaction? created = null;
        _txRepoMock.Setup(x => x.CreateAsync(It.IsAny<WalletTransaction>(), default))
            .Callback<WalletTransaction, CancellationToken>((tx, _) => { tx.Id = 1; created = tx; })
            .Returns(Task.CompletedTask);

        _txRepoMock.Setup(x => x.GetAsync(
                It.IsAny<System.Linq.Expressions.Expression<System.Func<WalletTransaction, bool>>>(),
                "Category", false, default))
            .ReturnsAsync(() => created!);

        var result = await _sut.AddTransactionAsync(userId, dto);

        Assert.NotNull(result);
        Assert.Equal(200, result.Amount);
        Assert.Equal("Withdrawal", result.Type);
    }

    [Fact]
    public async Task DeleteTransactionAsync_WhenExists_ShouldSoftDelete()
    {
        var tx = new WalletTransaction { Id = 1, UserId = "user1", IsDeleted = false };
        _txRepoMock.Setup(x => x.GetAsync(
                It.IsAny<System.Linq.Expressions.Expression<System.Func<WalletTransaction, bool>>>(),
                null, true, default))
            .ReturnsAsync(tx);
        _txRepoMock.Setup(x => x.SaveAsync(default)).Returns(Task.CompletedTask);

        var result = await _sut.DeleteTransactionAsync(1, "user1");

        Assert.True(result);
        Assert.True(tx.IsDeleted);
    }

    [Fact]
    public async Task DeleteTransactionAsync_WhenNotExists_ShouldReturnFalse()
    {
        _txRepoMock.Setup(x => x.GetAsync(
                It.IsAny<System.Linq.Expressions.Expression<System.Func<WalletTransaction, bool>>>(),
                null, true, default))
            .ReturnsAsync((WalletTransaction?)null);

        var result = await _sut.DeleteTransactionAsync(999, "user1");

        Assert.False(result);
    }

    [Fact]
    public async Task UpdateTransactionAsync_WhenExists_ShouldUpdate()
    {
        var existing = new WalletTransaction
        {
            Id = 1, UserId = "user1", Title = "Old", Amount = 50, Type = "Withdrawal",
            CategoryId = 1, IsDeleted = false
        };

        var dto = new AddTransactionDto { Amount = 100, Type = "Withdrawal", CategoryId = 2, Description = "Updated" };
        var category = new Category { Id = 2, NameAr = "مواصلات", NameEn = "Transport" };

        _txRepoMock.Setup(x => x.GetAsync(
                It.IsAny<System.Linq.Expressions.Expression<System.Func<WalletTransaction, bool>>>(),
                null, true, default))
            .ReturnsAsync(existing);

        _catRepoMock.Setup(x => x.GetAsync(
                It.IsAny<System.Linq.Expressions.Expression<System.Func<Category, bool>>>(),
                null, false, default))
            .ReturnsAsync(category);

        _txRepoMock.Setup(x => x.SaveAsync(default)).Returns(Task.CompletedTask);

        _txRepoMock.Setup(x => x.GetAsync(
                It.IsAny<System.Linq.Expressions.Expression<System.Func<WalletTransaction, bool>>>(),
                "Category", false, default))
            .ReturnsAsync(existing);
        existing.Category = category;

        var result = await _sut.UpdateTransactionAsync(1, "user1", dto);

        Assert.NotNull(result);
        Assert.Equal("Transport", result.CategoryNameEn);
    }

    [Fact]
    public async Task GetTransactionsAsync_WithFilters_ShouldFilterCorrectly()
    {
        var userId = "user1";
        var filter = new TransactionFilterDto { Type = "Withdrawal", Page = 1, PageSize = 10 };

        var allTxs = new List<WalletTransaction>
        {
            new() { Id = 1, UserId = userId, Type = "Withdrawal", Amount = 100, IsDeleted = false, TransactionDate = DateTime.UtcNow },
            new() { Id = 2, UserId = userId, Type = "Deposit", Amount = 300, IsDeleted = false, TransactionDate = DateTime.UtcNow },
        };

        _txRepoMock.Setup(x => x.GetAllAsync(
                It.IsAny<System.Linq.Expressions.Expression<System.Func<WalletTransaction, bool>>>(),
                null, false, null, null, default))
            .ReturnsAsync(allTxs);

        _txRepoMock.Setup(x => x.GetAllAsync(
                It.IsAny<System.Linq.Expressions.Expression<System.Func<WalletTransaction, bool>>>(),
                "Category",
                false,
                It.IsAny<System.Func<IQueryable<WalletTransaction>, IOrderedQueryable<WalletTransaction>>?>(),
                null,
                default))
            .ReturnsAsync(allTxs.OrderByDescending(t => t.TransactionDate).ToList());

        var result = await _sut.GetTransactionsAsync(userId, filter);

        Assert.NotNull(result);
        Assert.Equal(2, result.TotalCount);
    }

    [Fact]
    public async Task GetSummaryAsync_ShouldAggregateCorrectly()
    {
        var userId = "user1";
        var transactions = new List<WalletTransaction>
        {
            new() { UserId = userId, Type = "Deposit", Amount = 1000, IsDeleted = false, TransactionDate = DateTime.UtcNow, CategoryId = 1, Category = new Category { Id = 1, NameAr = "راتب", NameEn = "Salary" } },
            new() { UserId = userId, Type = "Deposit", Amount = 200, IsDeleted = false, TransactionDate = DateTime.UtcNow, CategoryId = 1, Category = new Category { Id = 1, NameAr = "راتب", NameEn = "Salary" } },
            new() { UserId = userId, Type = "Withdrawal", Amount = 300, IsDeleted = false, TransactionDate = DateTime.UtcNow, CategoryId = 2, Category = new Category { Id = 2, NameAr = "طعام", NameEn = "Food" } },
            new() { UserId = userId, Type = "Withdrawal", Amount = 150, IsDeleted = false, TransactionDate = DateTime.UtcNow, CategoryId = 3, Category = new Category { Id = 3, NameAr = "مواصلات", NameEn = "Transport" } },
        };

        _txRepoMock.Setup(x => x.GetAllAsync(
                It.IsAny<System.Linq.Expressions.Expression<System.Func<WalletTransaction, bool>>>(),
                "Category", false, null, null, default))
            .ReturnsAsync(transactions);

        var result = await _sut.GetSummaryAsync(userId, null, null);

        var dict = ((object)result).GetType().GetProperties()
            .ToDictionary(p => p.Name, p => p.GetValue(result));

        Assert.Equal(1200m, dict["TotalIncome"]);
        Assert.Equal(450m, dict["TotalExpenses"]);
        Assert.Equal(750m, dict["NetSavings"]);
        Assert.Equal(4, dict["TransactionCount"]);
    }
}
