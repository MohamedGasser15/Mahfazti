using System.Linq.Expressions;
using MyWallet.Core.Services;

namespace MyWallet.UnitTests.Services;

public class PredicateBuilderTests
{
    [Fact]
    public void AndAlso_ShouldCombineTwoPredicates()
    {
        Expression<Func<int, bool>> expr1 = x => x > 5;
        Expression<Func<int, bool>> expr2 = x => x < 10;

        var combined = expr1.AndAlso(expr2);
        var func = combined.Compile();

        Assert.True(func(7));
        Assert.False(func(3));
        Assert.False(func(12));
    }

    [Fact]
    public void AndAlso_WithMatchingFilter_ShouldReturnTrue()
    {
        Expression<Func<string, bool>> expr1 = s => !string.IsNullOrEmpty(s);
        Expression<Func<string, bool>> expr2 = s => s.Length > 3;

        var combined = expr1.AndAlso(expr2);
        var func = combined.Compile();

        Assert.True(func("hello"));
        Assert.False(func(""));
        Assert.False(func("ab"));
    }

    [Fact]
    public void AndAlso_Chained_ShouldWork()
    {
        Expression<Func<int, bool>> expr1 = x => x >= 0;
        Expression<Func<int, bool>> expr2 = x => x <= 100;
        Expression<Func<int, bool>> expr3 = x => x % 2 == 0;

        var combined = expr1.AndAlso(expr2).AndAlso(expr3);
        var func = combined.Compile();

        Assert.True(func(50));
        Assert.False(func(-1));
        Assert.False(func(101));
        Assert.False(func(51));
    }
}
