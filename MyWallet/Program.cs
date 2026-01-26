using FujPolice.API.MappingConfig;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using MyWallet.Application.Configurations;
using MyWallet.Infrastructure.Configurations;
using MyWallet.Infrastructure.Data;
using MyWallet.Infrastructure.Identity;
using Scalar.AspNetCore;
using System.Security.Claims;

var builder = WebApplication.CreateBuilder(args);

// =======================
// Services
// =======================

builder.Services.AddControllers();

// DbContext
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(
        builder.Configuration.GetConnectionString("DefaultConnection")));

// Identity
builder.Services.AddIdentity<ApplicationUser, ApplicationRole>(options =>
{
    options.Password.RequireDigit = true;
    options.Password.RequireLowercase = true;
    options.Password.RequiredLength = 6;
    options.Password.RequireNonAlphanumeric = false;
})
.AddEntityFrameworkStores<ApplicationDbContext>()
.AddDefaultTokenProviders();

// AutoMapper
builder.Services.AddAutoMapper(typeof(MappingConfig));

// =======================
// JWT Authentication
// =======================

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = "JwtBearer";
    options.DefaultChallengeScheme = "JwtBearer";
})
.AddJwtBearer("JwtBearer", options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidIssuer = builder.Configuration["Jwt:Issuer"],
        ValidAudience = builder.Configuration["Jwt:Audience"],
        IssuerSigningKey = new SymmetricSecurityKey(
            System.Text.Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"]!)
        ),
        NameClaimType = ClaimTypes.Name,
        RoleClaimType = ClaimTypes.Role
    };
});

// MemoryCache
builder.Services.AddMemoryCache();

// Authorization (يمكن تعديل السياسات حسب احتياجك)
builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("AdminPolicy", policy => policy.RequireRole("Admin"));
    options.AddPolicy("UserPolicy", policy => policy.RequireRole("User"));
});

// =======================
// Application & Infrastructure DI
// =======================

builder.Services.AddApplicationServices();
builder.Services.AddInfrastructureRepositories();

// =======================
// OpenAPI + Scalar
// =======================

builder.Services.AddOpenApi(options =>
{
    options.AddDocumentTransformer((document, context, cancellationToken) =>
    {
        document.Info = new OpenApiInfo
        {
            Title = "My Wallet API",
            Version = "v1",
            Description = "Simple Wallet Management API"
        };

        document.Components ??= new OpenApiComponents();
        document.Components.SecuritySchemes = new Dictionary<string, OpenApiSecurityScheme>
        {
            ["Bearer"] = new OpenApiSecurityScheme
            {
                Type = SecuritySchemeType.Http,
                Scheme = "bearer",
                BearerFormat = "JWT",
                In = ParameterLocation.Header,
                Description = "Bearer {your JWT token}"
            }
        };

        foreach (var path in document.Paths.Values)
        {
            foreach (var operation in path.Operations)
            {
                operation.Value.Security = new List<OpenApiSecurityRequirement>
                {
                    new OpenApiSecurityRequirement
                    {
                        {
                            new OpenApiSecurityScheme
                            {
                                Reference = new OpenApiReference
                                {
                                    Type = ReferenceType.SecurityScheme,
                                    Id = "Bearer"
                                }
                            },
                            new[] { "Admin", "User" }
                        }
                    }
                };
            }
        }

        return Task.CompletedTask;
    });
});

// CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

var app = builder.Build();

// =======================
// Middleware
// =======================

app.UseHttpsRedirection();
app.UseCors("AllowAll");

app.UseAuthentication();
app.UseAuthorization();

// =======================
// Endpoints
// =======================

app.MapControllers();

// Scalar + OpenAPI
app.MapOpenApi();

app.MapScalarApiReference(options =>
{
    options.Title = "My Wallet API Docs";
    options.Theme = ScalarTheme.BluePlanet;
});

app.MapGet("/", context =>
{
    context.Response.Redirect("/scalar");
    return Task.CompletedTask;
});

app.Run();
