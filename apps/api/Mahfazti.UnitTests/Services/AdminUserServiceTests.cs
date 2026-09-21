using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Logging;
using Moq;
using Mahfazti.Core.Constants;
using Mahfazti.Core.DTOs.User;
using Mahfazti.Core.Entities;
using Mahfazti.Core.Interfaces;
using Mahfazti.Core.Services;

namespace Mahfazti.UnitTests.Services;

public class AdminUserServiceTests
{
    private readonly Mock<UserManager<ApplicationUser>> _userManagerMock;
    private readonly Mock<RoleManager<ApplicationRole>> _roleManagerMock;
    private readonly Mock<ILogger<AdminUserService>> _loggerMock;
    private readonly Mock<IRepository<WalletTransaction>> _transactionRepoMock;
    private readonly Mock<IRepository<UserBudget>> _budgetRepoMock;
    private readonly AdminUserService _sut;

    public AdminUserServiceTests()
    {
        _userManagerMock = MockUserManager();
        _roleManagerMock = MockRoleManager();
        _loggerMock = new Mock<ILogger<AdminUserService>>();
        _transactionRepoMock = new Mock<IRepository<WalletTransaction>>();
        _budgetRepoMock = new Mock<IRepository<UserBudget>>();

        _sut = new AdminUserService(
            _userManagerMock.Object,
            _roleManagerMock.Object,
            _loggerMock.Object,
            _transactionRepoMock.Object,
            _budgetRepoMock.Object
        );
    }

    [Fact]
    public async Task CreateUserAsync_WhenValid_ShouldCreateUserAndAssignRole()
    {
        var dto = new CreateAdminUserDto
        {
            FullName = "New Admin",
            Email = "newadmin@example.com",
            Role = Roles.Admin,
            Currency = "USD",
            EmailConfirmed = true
        };

        _userManagerMock.Setup(x => x.FindByEmailAsync(dto.Email))
            .ReturnsAsync((ApplicationUser?)null);
        _userManagerMock.Setup(x => x.CreateAsync(It.IsAny<ApplicationUser>(), It.IsAny<string>()))
            .ReturnsAsync(IdentityResult.Success);
        _roleManagerMock.Setup(x => x.RoleExistsAsync(It.IsAny<string>()))
            .ReturnsAsync(true);
        _userManagerMock.Setup(x => x.AddToRoleAsync(It.IsAny<ApplicationUser>(), It.IsAny<string>()))
            .ReturnsAsync(IdentityResult.Success);
        _userManagerMock.Setup(x => x.GetRolesAsync(It.IsAny<ApplicationUser>()))
            .ReturnsAsync(new List<string> { Roles.Admin });

        var result = await _sut.CreateUserAsync(dto);

        Assert.NotNull(result);
        Assert.Equal(dto.FullName, result.FullName);
        Assert.Equal(dto.Email, result.Email);
        Assert.Equal(dto.Currency, result.Currency);
        Assert.True(result.IsActive);
        Assert.Equal(Roles.Admin, result.Role);
    }

    [Fact]
    public async Task CreateUserAsync_WhenEmailAlreadyExists_ShouldThrow()
    {
        var dto = new CreateAdminUserDto
        {
            FullName = "Existing User",
            Email = "existing@example.com",
            Role = Roles.User
        };

        _userManagerMock.Setup(x => x.FindByEmailAsync(dto.Email))
            .ReturnsAsync(new ApplicationUser { Email = dto.Email });

        await Assert.ThrowsAsync<InvalidOperationException>(() => _sut.CreateUserAsync(dto));
    }

    [Fact]
    public async Task DeleteUserAsync_WhenSelfDeletion_ShouldThrow()
    {
        await Assert.ThrowsAsync<InvalidOperationException>(() => _sut.DeleteUserAsync(5, 5));
    }

    [Fact]
    public async Task DeleteUserAsync_WhenValid_ShouldDeleteUserDataAndUser()
    {
        var targetUserId = 10;
        var currentAdminId = 1;
        var user = new ApplicationUser { Id = targetUserId, FullName = "To Delete" };

        _userManagerMock.Setup(x => x.FindByIdAsync(targetUserId.ToString()))
            .ReturnsAsync(user);
        _userManagerMock.Setup(x => x.DeleteAsync(user))
            .ReturnsAsync(IdentityResult.Success);

        var transactions = new List<WalletTransaction>
        {
            new() { Id = 1, UserId = targetUserId.ToString(), Title = "Tx1" }
        };
        var budgets = new List<UserBudget>
        {
            new() { Id = 1, UserId = targetUserId.ToString(), MonthlyBudget = 1000 }
        };

        _transactionRepoMock.Setup(x => x.GetAllAsync(It.IsAny<System.Linq.Expressions.Expression<System.Func<WalletTransaction, bool>>>(), null, false, null, null, default))
            .ReturnsAsync(transactions);
        _budgetRepoMock.Setup(x => x.GetAllAsync(It.IsAny<System.Linq.Expressions.Expression<System.Func<UserBudget, bool>>>(), null, false, null, null, default))
            .ReturnsAsync(budgets);

        var result = await _sut.DeleteUserAsync(targetUserId, currentAdminId);

        Assert.True(result);
        _transactionRepoMock.Verify(x => x.DeleteRangeAsync(transactions, default), Times.Once);
        _budgetRepoMock.Verify(x => x.DeleteRangeAsync(budgets, default), Times.Once);
        _userManagerMock.Verify(x => x.DeleteAsync(user), Times.Once);
    }

    [Fact]
    public async Task BulkDeleteUsersAsync_ShouldExcludeSelf_And_DeleteOthers()
    {
        var targetUser = new ApplicationUser { Id = 20, FullName = "Other User" };
        _userManagerMock.Setup(x => x.FindByIdAsync("20"))
            .ReturnsAsync(targetUser);
        _userManagerMock.Setup(x => x.DeleteAsync(targetUser))
            .ReturnsAsync(IdentityResult.Success);
        _transactionRepoMock.Setup(x => x.GetAllAsync(It.IsAny<System.Linq.Expressions.Expression<System.Func<WalletTransaction, bool>>>(), null, false, null, null, default))
            .ReturnsAsync(new List<WalletTransaction>());
        _budgetRepoMock.Setup(x => x.GetAllAsync(It.IsAny<System.Linq.Expressions.Expression<System.Func<UserBudget, bool>>>(), null, false, null, null, default))
            .ReturnsAsync(new List<UserBudget>());

        var userIds = new List<int> { 5, 20 }; // 5 is current admin, 20 is other user
        var currentAdminId = 5;

        var count = await _sut.BulkDeleteUsersAsync(userIds, currentAdminId);

        Assert.Equal(1, count);
        _userManagerMock.Verify(x => x.DeleteAsync(targetUser), Times.Once);
    }

    private static Mock<UserManager<ApplicationUser>> MockUserManager()
    {
        var store = new Mock<IUserStore<ApplicationUser>>();
        return new Mock<UserManager<ApplicationUser>>(
            store.Object, null!, null!, null!, null!, null!, null!, null!, null!);
    }

    private static Mock<RoleManager<ApplicationRole>> MockRoleManager()
    {
        var store = new Mock<IRoleStore<ApplicationRole>>();
        return new Mock<RoleManager<ApplicationRole>>(
            store.Object, null!, null!, null!, null!);
    }
}
