using System.Linq.Expressions;
using Microsoft.Extensions.Logging;
using Moq;
using MyWallet.Core.DTOs.Category;
using MyWallet.Core.Entities;
using MyWallet.Core.Interfaces;
using MyWallet.Core.Services;

namespace MyWallet.UnitTests.Services;

public class CategoryServiceTests
{
    private readonly Mock<IRepository<Category>> _repoMock;
    private readonly CategoryService _sut;

    public CategoryServiceTests()
    {
        _repoMock = new Mock<IRepository<Category>>();
        _sut = new CategoryService(_repoMock.Object, Mock.Of<ILogger<CategoryService>>());
    }

    [Fact]
    public async Task GetAllCategoriesAsync_ShouldReturnAll()
    {
        var categories = new List<Category>
        {
            new() { Id = 1, NameAr = "طعام", NameEn = "Food" },
            new() { Id = 2, NameAr = "مواصلات", NameEn = "Transport" },
        };

        _repoMock.Setup(x => x.GetAllAsync(null, null, false, It.IsAny<Func<IQueryable<Category>, IOrderedQueryable<Category>>?>(), null, default))
            .ReturnsAsync(categories);

        var result = await _sut.GetAllCategoriesAsync();

        Assert.Equal(2, result.Count());
    }

    [Fact]
    public async Task GetCategoryByIdAsync_WhenExists_ShouldReturnCategory()
    {
        var category = new Category { Id = 1, NameAr = "طعام", NameEn = "Food" };
        _repoMock.Setup(x => x.GetAsync(It.IsAny<Expression<Func<Category, bool>>>(), null, false, default))
            .ReturnsAsync(category);

        var result = await _sut.GetCategoryByIdAsync(1);

        Assert.NotNull(result);
        Assert.Equal("Food", result.NameEn);
    }

    [Fact]
    public async Task GetCategoryByIdAsync_WhenNotExists_ShouldReturnNull()
    {
        _repoMock.Setup(x => x.GetAsync(It.IsAny<Expression<Func<Category, bool>>>(), null, false, default))
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
}
