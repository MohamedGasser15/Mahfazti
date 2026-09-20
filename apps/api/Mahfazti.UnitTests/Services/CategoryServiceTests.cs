using System.Linq.Expressions;
using Microsoft.Extensions.Logging;
using Moq;
using Mahfazti.Core.DTOs.Category;
using Mahfazti.Core.Entities;
using Mahfazti.Core.Interfaces;
using Mahfazti.Core.Services;

namespace Mahfazti.UnitTests.Services;

public class CategoryServiceTests
{
    private readonly Mock<IRepository<Category>> _repoMock;
    private readonly Mock<IRepository<WalletTransaction>> _transRepoMock;
    private readonly CategoryService _sut;

    public CategoryServiceTests()
    {
        _repoMock = new Mock<IRepository<Category>>();
        _transRepoMock = new Mock<IRepository<WalletTransaction>>();
        _sut = new CategoryService(_repoMock.Object, _transRepoMock.Object, Mock.Of<ILogger<CategoryService>>());
    }

    [Fact]
    public async Task GetAllCategoriesAsync_ShouldReturnAll()
    {
        var categories = new List<Category>
        {
            new() { Id = 1, NameAr = "طعام", NameEn = "Food" },
            new() { Id = 2, NameAr = "مواصلات", NameEn = "Transport" },
        };

        _repoMock.Setup(x => x.GetAllAsync(
            It.IsAny<Expression<Func<Category, bool>>?>(),
            It.IsAny<string?>(),
            It.IsAny<bool>(),
            It.IsAny<Func<IQueryable<Category>, IOrderedQueryable<Category>>?>(),
            It.IsAny<int?>(),
            It.IsAny<CancellationToken>()))
            .ReturnsAsync(categories);

        var result = await _sut.GetAllCategoriesAsync();

        Assert.Equal(2, result.Count());
    }

    [Fact]
    public async Task GetCategoryByIdAsync_WhenExists_ShouldReturnCategory()
    {
        var category = new Category { Id = 1, NameAr = "طعام", NameEn = "Food" };
        _repoMock.Setup(x => x.GetAsync(
            It.IsAny<Expression<Func<Category, bool>>>(),
            It.IsAny<string?>(),
            It.IsAny<bool>(),
            It.IsAny<CancellationToken>()))
            .ReturnsAsync(category);

        var result = await _sut.GetCategoryByIdAsync(1);

        Assert.NotNull(result);
        Assert.Equal("Food", result.NameEn);
    }

    [Fact]
    public async Task GetCategoryByIdAsync_WhenNotExists_ShouldReturnNull()
    {
        _repoMock.Setup(x => x.GetAsync(
            It.IsAny<Expression<Func<Category, bool>>>(),
            It.IsAny<string?>(),
            It.IsAny<bool>(),
            It.IsAny<CancellationToken>()))
            .ReturnsAsync((Category?)null);

        var result = await _sut.GetCategoryByIdAsync(999);

        Assert.Null(result);
    }

    [Fact]
    public async Task CreateCategoryAsync_ShouldCreateAndReturn()
    {
        var dto = new CreateCategoryDto { NameAr = "صحة", NameEn = "Health" };

        _repoMock.Setup(x => x.CreateAsync(It.IsAny<Category>(), default))
            .Callback<Category, CancellationToken>((c, _) => c.Id = 3)
            .Returns(Task.CompletedTask);

        var result = await _sut.CreateCategoryAsync(dto);

        Assert.NotNull(result);
        Assert.Equal(3, result.Id);
        Assert.Equal("Health", result.NameEn);
        Assert.Equal("صحة", result.NameAr);
    }

    [Fact]
    public async Task UpdateCategoryAsync_WhenExists_ShouldUpdate()
    {
        var existing = new Category { Id = 1, NameAr = "قديم", NameEn = "Old" };
        var dto = new UpdateCategoryDto { Id = 1, NameAr = "جديد", NameEn = "New" };

        _repoMock.Setup(x => x.GetAsync(It.IsAny<Expression<Func<Category, bool>>>(), null, true, default))
            .ReturnsAsync(existing);
        _repoMock.Setup(x => x.UpdateAsync(It.IsAny<Category>(), default))
            .Returns(Task.CompletedTask);

        var result = await _sut.UpdateCategoryAsync(dto);

        Assert.NotNull(result);
        Assert.Equal("New", result.NameEn);
        Assert.Equal("جديد", result.NameAr);
    }

    [Fact]
    public async Task UpdateCategoryAsync_WhenNotExists_ShouldReturnNull()
    {
        var dto = new UpdateCategoryDto { Id = 999, NameAr = "جديد", NameEn = "New" };
        _repoMock.Setup(x => x.GetAsync(It.IsAny<Expression<Func<Category, bool>>>(), null, true, default))
            .ReturnsAsync((Category?)null);

        var result = await _sut.UpdateCategoryAsync(dto);

        Assert.Null(result);
    }

    [Fact]
    public async Task DeleteCategoryAsync_WhenExists_ShouldDelete()
    {
        var category = new Category { Id = 1 };
        _repoMock.Setup(x => x.GetAsync(It.IsAny<Expression<Func<Category, bool>>>(), null, true, default))
            .ReturnsAsync(category);
        _repoMock.Setup(x => x.DeleteAsync(category, default))
            .Returns(Task.CompletedTask);

        var result = await _sut.DeleteCategoryAsync(1);

        Assert.True(result);
    }

    [Fact]
    public async Task DeleteCategoryAsync_WhenNotExists_ShouldReturnFalse()
    {
        _repoMock.Setup(x => x.GetAsync(It.IsAny<Expression<Func<Category, bool>>>(), null, true, default))
            .ReturnsAsync((Category?)null);

        var result = await _sut.DeleteCategoryAsync(999);

        Assert.False(result);
    }

    [Fact]
    public async Task DeleteCategoryAsync_WhenTransactionsExist_ShouldArchiveCategory()
    {
        var category = new Category { Id = 1, IsActive = true };
        _repoMock.Setup(x => x.GetAsync(It.IsAny<Expression<Func<Category, bool>>>(), null, true, default))
            .ReturnsAsync(category);
        _transRepoMock.Setup(x => x.AnyAsync(It.IsAny<Expression<Func<WalletTransaction, bool>>>(), default))
            .ReturnsAsync(true);
        _repoMock.Setup(x => x.UpdateAsync(It.IsAny<Category>(), default))
            .Returns(Task.CompletedTask);

        var result = await _sut.DeleteCategoryAsync(1);

        Assert.True(result);
        Assert.False(category.IsActive);
        _repoMock.Verify(x => x.UpdateAsync(category, default), Times.Once);
        _repoMock.Verify(x => x.DeleteAsync(It.IsAny<Category>(), default), Times.Never);
    }

    [Fact]
    public async Task RestoreCategoryAsync_WhenArchived_ShouldReactivate()
    {
        var category = new Category { Id = 1, IsActive = false };
        _repoMock.Setup(x => x.GetAsync(It.IsAny<Expression<Func<Category, bool>>>(), null, true, default))
            .ReturnsAsync(category);
        _repoMock.Setup(x => x.UpdateAsync(It.IsAny<Category>(), default))
            .Returns(Task.CompletedTask);

        var result = await _sut.RestoreCategoryAsync(1);

        Assert.True(result);
        Assert.True(category.IsActive);
        _repoMock.Verify(x => x.UpdateAsync(category, default), Times.Once);
    }

    [Fact]
    public async Task BulkDeleteCategoriesAsync_ShouldDeleteUnusedAndArchiveUsed()
    {
        var cat1 = new Category { Id = 1, IsActive = true };
        var cat2 = new Category { Id = 2, IsActive = true };

        _repoMock.Setup(x => x.GetAsync(It.IsAny<Expression<Func<Category, bool>>>(), null, true, default))
            .Returns<Expression<Func<Category, bool>>, string?, bool, CancellationToken>((predicate, _, _, _) =>
            {
                var compiled = predicate.Compile();
                if (compiled(cat1)) return Task.FromResult<Category?>(cat1);
                if (compiled(cat2)) return Task.FromResult<Category?>(cat2);
                return Task.FromResult<Category?>(null);
            });

        _transRepoMock.Setup(x => x.AnyAsync(It.IsAny<Expression<Func<WalletTransaction, bool>>>(), default))
            .Returns<Expression<Func<WalletTransaction, bool>>, CancellationToken>((predicate, _) =>
            {
                var compiled = predicate.Compile();
                bool hasTx = compiled(new WalletTransaction { CategoryId = 1, IsDeleted = false });
                return Task.FromResult(hasTx);
            });

        _repoMock.Setup(x => x.UpdateAsync(It.IsAny<Category>(), default))
            .Returns(Task.CompletedTask);
        _repoMock.Setup(x => x.DeleteAsync(It.IsAny<Category>(), default))
            .Returns(Task.CompletedTask);

        var result = await _sut.BulkDeleteCategoriesAsync(new[] { 1, 2 });

        Assert.Equal(1, result.DeletedCount);
        Assert.Equal(1, result.ArchivedCount);
        Assert.False(cat1.IsActive);
        _repoMock.Verify(x => x.UpdateAsync(cat1, default), Times.Once);
        _repoMock.Verify(x => x.DeleteAsync(cat2, default), Times.Once);
    }

    [Fact]
    public async Task BulkRestoreCategoriesAsync_ShouldReactivateAllArchived()
    {
        var cat1 = new Category { Id = 1, IsActive = false };
        var cat2 = new Category { Id = 2, IsActive = false };

        _repoMock.Setup(x => x.GetAsync(It.IsAny<Expression<Func<Category, bool>>>(), null, true, default))
            .Returns<Expression<Func<Category, bool>>, string?, bool, CancellationToken>((predicate, _, _, _) =>
            {
                var compiled = predicate.Compile();
                if (compiled(cat1)) return Task.FromResult<Category?>(cat1);
                if (compiled(cat2)) return Task.FromResult<Category?>(cat2);
                return Task.FromResult<Category?>(null);
            });

        _repoMock.Setup(x => x.UpdateAsync(It.IsAny<Category>(), default))
            .Returns(Task.CompletedTask);

        var restoredCount = await _sut.BulkRestoreCategoriesAsync(new[] { 1, 2 });

        Assert.Equal(2, restoredCount);
        Assert.True(cat1.IsActive);
        Assert.True(cat2.IsActive);
        _repoMock.Verify(x => x.UpdateAsync(cat1, default), Times.Once);
        _repoMock.Verify(x => x.UpdateAsync(cat2, default), Times.Once);
    }
}
