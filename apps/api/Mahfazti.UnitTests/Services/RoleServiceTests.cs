using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Logging;
using Moq;
using Xunit;
using Mahfazti.Core.Constants;
using Mahfazti.Core.DTOs.Role;
using Mahfazti.Core.Entities;
using Mahfazti.Core.Services;

namespace Mahfazti.UnitTests.Services;

public class RoleServiceTests
{
    private readonly Mock<RoleManager<ApplicationRole>> _roleManagerMock;
    private readonly Mock<UserManager<ApplicationUser>> _userManagerMock;
    private readonly Mock<ILogger<RoleService>> _loggerMock;
    private readonly RoleService _sut;

    public RoleServiceTests()
    {
        var roleStoreMock = new Mock<IRoleStore<ApplicationRole>>();
        _roleManagerMock = new Mock<RoleManager<ApplicationRole>>(
            roleStoreMock.Object, null!, null!, null!, null!);

        var userStoreMock = new Mock<IUserStore<ApplicationUser>>();
        _userManagerMock = new Mock<UserManager<ApplicationUser>>(
            userStoreMock.Object, null!, null!, null!, null!, null!, null!, null!, null!);

        _loggerMock = new Mock<ILogger<RoleService>>();

        _sut = new RoleService(_roleManagerMock.Object, _userManagerMock.Object, _loggerMock.Object);
    }

    [Fact]
    public void GetAvailablePermissions_ShouldReturnAllPermissionGroups()
    {
        // Act
        var groups = _sut.GetAvailablePermissions();

        // Assert
        Assert.NotNull(groups);
        Assert.NotEmpty(groups);
        Assert.Contains(groups, g => g.GroupKey == "users");
        Assert.Contains(groups, g => g.GroupKey == "categories");
        Assert.Contains(groups, g => g.GroupKey == "roles");
        Assert.Contains(groups, g => g.GroupKey == "audit_logs");
    }

    [Fact]
    public async Task CreateRoleAsync_WhenRoleExists_ShouldThrowInvalidOperationException()
    {
        // Arrange
        var dto = new CreateRoleDto { Name = "SuperAdmin", Description = "Existing role" };
        _roleManagerMock.Setup(r => r.RoleExistsAsync("SuperAdmin"))
            .ReturnsAsync(true);

        // Act & Assert
        await Assert.ThrowsAsync<InvalidOperationException>(() => _sut.CreateRoleAsync(dto));
    }

    [Theory]
    [InlineData("SuperAdmin")]
    [InlineData("Admin")]
    [InlineData("User")]
    public async Task DeleteRoleAsync_WhenSystemRole_ShouldThrowInvalidOperationException(string systemRole)
    {
        // Arrange
        var role = new ApplicationRole { Id = 1, Name = systemRole };
        _roleManagerMock.Setup(r => r.Roles)
            .Returns(new List<ApplicationRole> { role }.AsQueryable());

        // Act & Assert
        await Assert.ThrowsAsync<InvalidOperationException>(() => _sut.DeleteRoleAsync(1));
    }
}
