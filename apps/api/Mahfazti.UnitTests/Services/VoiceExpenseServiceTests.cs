using System.Linq.Expressions;
using Microsoft.Extensions.Logging;
using Moq;
using Mahfazti.Core.Entities;
using Mahfazti.Core.Interfaces;
using Mahfazti.Core.Services;

namespace Mahfazti.UnitTests.Services;

public class VoiceExpenseServiceTests
{
    private readonly Mock<IRepository<Category>> _catRepoMock;
    private readonly VoiceExpenseService _sut;

    public VoiceExpenseServiceTests()
    {
        _catRepoMock = new Mock<IRepository<Category>>();
        _sut = new VoiceExpenseService(_catRepoMock.Object, Mock.Of<ILogger<VoiceExpenseService>>());
    }

    private void SetupCategoryLookup(string nameEn, int id = 1)
    {
        var category = new Category { Id = id, NameAr = nameEn, NameEn = nameEn };
        _catRepoMock
            .Setup(x => x.GetAsync(It.IsAny<Expression<Func<Category, bool>>>(), null, false, default))
            .ReturnsAsync(category);
    }

    [Fact]
    public async Task ParseVoiceTextAsync_ArabicExpenseWithNumber_ShouldParseAmount()
    {
        SetupCategoryLookup("Food", 2);
        var result = await _sut.ParseVoiceTextAsync("اشتريت أكل ب 200 جنيه", "ar");

        Assert.True(result.IsSuccess);
        Assert.Equal(200m, result.Amount);
        Assert.Equal("Withdrawal", result.TransactionType);
        Assert.Equal("Food", result.CategoryNameEn);
    }

    [Fact]
    public async Task ParseVoiceTextAsync_ArabicExpenseWithoutNumber_ShouldReturnError()
    {
        var result = await _sut.ParseVoiceTextAsync("اشتريت حاجة من السوبر ماركت", "ar");

        Assert.False(result.IsSuccess);
        Assert.Contains("المبلغ", result.ErrorMessage);
    }

    [Fact]
    public async Task ParseVoiceTextAsync_ArabicIncomeWithSalary_ShouldDetectDeposit()
    {
        SetupCategoryLookup("Salary", 10);
        var result = await _sut.ParseVoiceTextAsync("استلمت راتب 5000 جنيه", "ar");

        Assert.True(result.IsSuccess);
        Assert.Equal(5000m, result.Amount);
        Assert.Equal("Deposit", result.TransactionType);
        Assert.Equal("Salary", result.CategoryNameEn);
    }

    [Fact]
    public async Task ParseVoiceTextAsync_ArabicIncomeWithBonus_ShouldDetectDeposit()
    {
        SetupCategoryLookup("Bonus", 11);
        var result = await _sut.ParseVoiceTextAsync("اخدت بونص 1000", "ar");

        Assert.True(result.IsSuccess);
        Assert.Equal(1000m, result.Amount);
        Assert.Equal("Deposit", result.TransactionType);
        Assert.Equal("Bonus", result.CategoryNameEn);
    }

    [Fact]
    public async Task ParseVoiceTextAsync_EnglishExpense_ShouldParse()
    {
        SetupCategoryLookup("Food", 2);
        var result = await _sut.ParseVoiceTextAsync("spent 50 on food", "en");

        Assert.True(result.IsSuccess);
        Assert.Equal(50m, result.Amount);
        Assert.Equal("Withdrawal", result.TransactionType);
        Assert.Equal("Food", result.CategoryNameEn);
    }

    [Fact]
    public async Task ParseVoiceTextAsync_EnglishIncome_ShouldDetectDeposit()
    {
        SetupCategoryLookup("Salary", 10);
        var result = await _sut.ParseVoiceTextAsync("received my salary 3000", "en");

        Assert.True(result.IsSuccess);
        Assert.Equal(3000m, result.Amount);
        Assert.Equal("Deposit", result.TransactionType);
        Assert.Equal("Salary", result.CategoryNameEn);
    }

    [Fact]
    public async Task ParseVoiceTextAsync_TransportExpense_ShouldDetectCategory()
    {
        SetupCategoryLookup("Transport", 3);
        var result = await _sut.ParseVoiceTextAsync("دفعت تاكسي 50", "ar");

        Assert.True(result.IsSuccess);
        Assert.Equal("Transport", result.CategoryNameEn);
        Assert.Equal("Withdrawal", result.TransactionType);
    }

    [Fact]
    public async Task ParseVoiceTextAsync_BillsExpense_ShouldDetectCategory()
    {
        SetupCategoryLookup("Bills", 7);
        var result = await _sut.ParseVoiceTextAsync("فاتورة الكهربا 350", "ar");

        Assert.True(result.IsSuccess);
        Assert.Equal(350m, result.Amount);
        Assert.Equal("Bills", result.CategoryNameEn);
    }

    [Fact]
    public async Task ParseVoiceTextAsync_EntertainmentExpense_ShouldDetectCategory()
    {
        SetupCategoryLookup("Entertainment", 4);
        var result = await _sut.ParseVoiceTextAsync("سينما ب 200", "ar");

        Assert.True(result.IsSuccess);
        Assert.Equal("Entertainment", result.CategoryNameEn);
    }

    [Fact]
    public async Task ParseVoiceTextAsync_HealthExpense_ShouldDetectCategory()
    {
        SetupCategoryLookup("Health", 6);
        var result = await _sut.ParseVoiceTextAsync("دكتور 500", "ar");

        Assert.True(result.IsSuccess);
        Assert.Equal("Health", result.CategoryNameEn);
    }

    [Fact]
    public async Task ParseVoiceTextAsync_ShoppingExpense_ShouldDetectCategory()
    {
        SetupCategoryLookup("Shopping", 5);
        var result = await _sut.ParseVoiceTextAsync("اشتريت هدوم 1000", "ar");

        Assert.True(result.IsSuccess);
        Assert.Equal("Shopping", result.CategoryNameEn);
    }

    [Fact]
    public async Task ParseVoiceTextAsync_EducationExpense_ShouldDetectCategory()
    {
        SetupCategoryLookup("Education", 8);
        var result = await _sut.ParseVoiceTextAsync("كورس 1500", "ar");

        Assert.True(result.IsSuccess);
        Assert.Equal("Education", result.CategoryNameEn);
    }

    [Fact]
    public async Task ParseVoiceTextAsync_UnknownCategory_ShouldDefaultToOther()
    {
        var result = await _sut.ParseVoiceTextAsync("حاجة غريبة 100", "ar");

        Assert.True(result.IsSuccess);
        Assert.Equal(100m, result.Amount);
    }

    [Fact]
    public async Task ParseVoiceTextAsync_EnglishTransportExpense_ShouldDetect()
    {
        SetupCategoryLookup("Transport", 3);
        var result = await _sut.ParseVoiceTextAsync("uber ride 75", "en");

        Assert.True(result.IsSuccess);
        Assert.Equal(75m, result.Amount);
        Assert.Equal("Transport", result.CategoryNameEn);
    }

    [Fact]
    public async Task ParseVoiceTextAsync_EnglishHealthExpense_ShouldDetect()
    {
        SetupCategoryLookup("Health", 6);
        var result = await _sut.ParseVoiceTextAsync("doctor appointment 200", "en");

        Assert.True(result.IsSuccess);
        Assert.Equal("Health", result.CategoryNameEn);
    }

    [Fact]
    public async Task ParseVoiceTextAsync_EnglishBillsExpense_ShouldDetect()
    {
        SetupCategoryLookup("Bills", 7);
        var result = await _sut.ParseVoiceTextAsync("internet bill 150", "en");

        Assert.True(result.IsSuccess);
        Assert.Equal("Bills", result.CategoryNameEn);
    }

    [Fact]
    public async Task ParseVoiceTextAsync_ArabicNumbersAsWords_ShouldConvert()
    {
        var result = await _sut.ParseVoiceTextAsync("دفعت عشرين جنيه مواصلات", "ar");

        Assert.True(result.IsSuccess);
        Assert.Equal(20m, result.Amount);
    }

    [Fact]
    public async Task ParseVoiceTextAsync_ArabicHundredAsWord_ShouldConvert()
    {
        var result = await _sut.ParseVoiceTextAsync("اكل ب مية جنيه", "ar");

        Assert.True(result.IsSuccess);
        Assert.Equal(100m, result.Amount);
    }

    [Fact]
    public async Task ParseVoiceTextAsync_WithCategoryInDatabase_ShouldSetCategoryId()
    {
        var category = new Category { Id = 5, NameAr = "صحة", NameEn = "Health" };
        _catRepoMock
            .Setup(x => x.GetAsync(It.IsAny<Expression<Func<Category, bool>>>(), null, false, default))
            .ReturnsAsync(category);

        var result = await _sut.ParseVoiceTextAsync("دكتور 500", "ar");

        Assert.Equal(5, result.CategoryId);
        Assert.Equal("Health", result.CategoryNameEn);
        Assert.Equal("صحة", result.CategoryNameAr);
    }

    [Fact]
    public async Task ParseVoiceTextAsync_MultipleDigits_ShouldExtractFirstNumber()
    {
        var result = await _sut.ParseVoiceTextAsync("اكل ب 200 و شربت حاجة ب 50", "ar");

        Assert.True(result.IsSuccess);
        Assert.Equal(200m, result.Amount);
    }

    [Fact]
    public async Task ParseVoiceTextAsync_EnglishIncomeWordReceived_ShouldBeDeposit()
    {
        var result = await _sut.ParseVoiceTextAsync("received 1000 from client", "en");

        Assert.True(result.IsSuccess);
        Assert.Equal("Deposit", result.TransactionType);
        Assert.Equal(1000m, result.Amount);
    }

    [Fact]
    public async Task ParseVoiceTextAsync_EnglishIncomeWordEarned_ShouldBeDeposit()
    {
        var result = await _sut.ParseVoiceTextAsync("earned 500 this week", "en");

        Assert.True(result.IsSuccess);
        Assert.Equal("Deposit", result.TransactionType);
    }
}
