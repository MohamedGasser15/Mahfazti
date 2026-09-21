using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using Moq;
using Xunit;
using Mahfazti.Core.DTOs.AuditLog;
using Mahfazti.Core.Entities;
using Mahfazti.Core.Interfaces;
using Mahfazti.Core.Services;

namespace Mahfazti.UnitTests.Services;

public class AuditLogServiceTests
{
    private readonly Mock<IRepository<AuditLog>> _auditLogRepoMock;
    private readonly Mock<ILogger<AuditLogService>> _loggerMock;
    private readonly AuditLogService _sut;

    public AuditLogServiceTests()
    {
        _auditLogRepoMock = new Mock<IRepository<AuditLog>>();
        _loggerMock = new Mock<ILogger<AuditLogService>>();
        _sut = new AuditLogService(_auditLogRepoMock.Object, _loggerMock.Object);
    }

    [Fact]
    public async Task LogAsync_ShouldCreateAndSaveAuditLog()
    {
        // Arrange
        AuditLog? capturedEntry = null;
        _auditLogRepoMock.Setup(r => r.CreateAsync(It.IsAny<AuditLog>(), It.IsAny<CancellationToken>()))
            .Callback<AuditLog, CancellationToken>((entry, _) => capturedEntry = entry)
            .Returns(Task.CompletedTask);

        _auditLogRepoMock.Setup(r => r.SaveAsync(It.IsAny<CancellationToken>()))
            .Returns(Task.CompletedTask);

        // Act
        await _sut.LogAsync(
            action: "Created User",
            targetResource: "Users / omar@example.com",
            category: "User Management",
            adminId: 1,
            adminName: "Super Admin",
            adminEmail: "admin@mahfazti.app",
            ipAddress: "192.168.1.1",
            status: "Success",
            details: "Role: Admin");

        // Assert
        _auditLogRepoMock.Verify(r => r.CreateAsync(It.IsAny<AuditLog>(), It.IsAny<CancellationToken>()), Times.Once);
        _auditLogRepoMock.Verify(r => r.SaveAsync(It.IsAny<CancellationToken>()), Times.Once);
        Assert.NotNull(capturedEntry);
        Assert.Equal("Created User", capturedEntry.Action);
        Assert.Equal("Users / omar@example.com", capturedEntry.TargetResource);
        Assert.Equal("User Management", capturedEntry.Category);
        Assert.Equal("Super Admin", capturedEntry.AdminName);
        Assert.Equal("192.168.1.1", capturedEntry.IpAddress);
        Assert.Equal("Success", capturedEntry.Status);
    }

    [Fact]
    public async Task GetLogsAsync_WithCategoryFilter_ShouldReturnFilteredLogs()
    {
        // Arrange
        var testLogs = new List<AuditLog>
        {
            new() { Id = 1, Action = "Action 1", Category = "User Management", CreatedAt = DateTime.UtcNow },
            new() { Id = 2, Action = "Action 2", Category = "Security", CreatedAt = DateTime.UtcNow },
            new() { Id = 3, Action = "Action 3", Category = "User Management", CreatedAt = DateTime.UtcNow }
        };

        _auditLogRepoMock.Setup(r => r.GetAllAsync(
            It.IsAny<Expression<Func<AuditLog, bool>>>(),
            It.IsAny<string>(),
            It.IsAny<bool>(),
            It.IsAny<Func<IQueryable<AuditLog>, IOrderedQueryable<AuditLog>>>(),
            It.IsAny<int?>(),
            It.IsAny<CancellationToken>()))
            .ReturnsAsync(testLogs);

        var filter = new AuditLogFilterDto { Category = "User Management", Page = 1, PageSize = 10 };

        // Act
        var result = await _sut.GetLogsAsync(filter);

        // Assert
        Assert.Equal(2, result.TotalCount);
        Assert.All(result.Items, item => Assert.Equal("User Management", item.Category));
    }

    [Fact]
    public async Task GetLogsAsync_WithSearchTerm_ShouldReturnMatchingLogs()
    {
        // Arrange
        var testLogs = new List<AuditLog>
        {
            new() { Id = 1, Action = "Deleted User", TargetResource = "Users / sara@example.com", Category = "User Management", CreatedAt = DateTime.UtcNow },
            new() { Id = 2, Action = "Reset Password", TargetResource = "Users / john@example.com", Category = "Security", CreatedAt = DateTime.UtcNow }
        };

        _auditLogRepoMock.Setup(r => r.GetAllAsync(
            It.IsAny<Expression<Func<AuditLog, bool>>>(),
            It.IsAny<string>(),
            It.IsAny<bool>(),
            It.IsAny<Func<IQueryable<AuditLog>, IOrderedQueryable<AuditLog>>>(),
            It.IsAny<int?>(),
            It.IsAny<CancellationToken>()))
            .ReturnsAsync(testLogs);

        var filter = new AuditLogFilterDto { SearchTerm = "sara", Page = 1, PageSize = 10 };

        // Act
        var result = await _sut.GetLogsAsync(filter);

        // Assert
        Assert.Equal(1, result.TotalCount);
        Assert.Equal("Deleted User", result.Items[0].Action);
    }

    [Fact]
    public async Task GetStatsAsync_ShouldCalculateCorrectMetricCounts()
    {
        // Arrange
        var testLogs = new List<AuditLog>
        {
            new() { Id = 1, Category = "User Management", Status = "Success" },
            new() { Id = 2, Category = "Security", Status = "Warning" },
            new() { Id = 3, Category = "Security", Status = "Failed" },
            new() { Id = 4, Category = "System", Status = "Success" }
        };

        _auditLogRepoMock.Setup(r => r.GetAllAsync(
            It.IsAny<Expression<Func<AuditLog, bool>>>(),
            It.IsAny<string>(),
            It.IsAny<bool>(),
            It.IsAny<Func<IQueryable<AuditLog>, IOrderedQueryable<AuditLog>>>(),
            It.IsAny<int?>(),
            It.IsAny<CancellationToken>()))
            .ReturnsAsync(testLogs);

        // Act
        var stats = await _sut.GetStatsAsync();

        // Assert
        Assert.Equal(4, stats.TotalLogs);
        Assert.Equal(1, stats.UserManagementCount);
        Assert.Equal(2, stats.SecurityCount);
        Assert.Equal(2, stats.WarningsAndFailuresCount);
    }

    [Fact]
    public async Task LogAsync_WhenRepositoryThrows_ShouldCatchAndNotThrow()
    {
        // Arrange
        _auditLogRepoMock.Setup(r => r.CreateAsync(It.IsAny<AuditLog>(), It.IsAny<CancellationToken>()))
            .ThrowsAsync(new Exception("Database connection error"));

        // Act & Assert (Should not throw)
        var exception = await Record.ExceptionAsync(() => _sut.LogAsync(
            action: "Failing Action",
            targetResource: "Resource",
            category: "System"));

        Assert.Null(exception);
    }
}
