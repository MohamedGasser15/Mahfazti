using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Mahfazti.Core.Entities;

namespace Mahfazti.Infrastructure.Data.Seeders
{
    public static class SubscriptionSeeder
    {
        public static async Task SeedAsync(ApplicationDbContext context)
        {
            var now = DateTime.UtcNow;

            // 1. Seed Pricing Plans
            if (!await context.PricingPlans.AnyAsync())
            {
                var plans = new List<PricingPlan>
                {
                    new()
                    {
                        Id = "plan-free",
                        Name = "Free Basic",
                        NameAr = "الباقة المجانية",
                        PriceEgp = 0m,
                        BillingCycle = "Monthly",
                        Description = "Essential features for personal budget tracking",
                        DescriptionAr = "الميزات الأساسية والمثالية لتتبع الميزانية الشخصية والمصروفات اليومية",
                        FeaturesJson = JsonSerializer.Serialize(new List<string>
                        {
                            "1 Cash Wallet",
                            "15 AI Voice Expenses / Month",
                            "Basic Categories",
                            "Standard Analytics"
                        }),
                        FeaturesArJson = JsonSerializer.Serialize(new List<string>
                        {
                            "محفظة نقدية واحدة",
                            "15 معاملة صوتية بالذكاء الاصطناعي شهرياً",
                            "تصنيفات أساسية ومخصصة",
                            "تحليلات وتقارير مالية قياسية"
                        }),
                        IsPopular = false,
                        IsActive = true,
                        MaxWallets = 1,
                        MaxAiRequestsPerMonth = 15,
                        CanExportReports = false,
                        CanUseMultiCurrency = false,
                        CreatedAt = now
                    },
                    new()
                    {
                        Id = "plan-pro-monthly",
                        Name = "Mahfazti Pro (Monthly)",
                        NameAr = "باقة المحترفين (شهري)",
                        PriceEgp = 89m,
                        BillingCycle = "Monthly",
                        Description = "For power users needing multiple wallets & unlimited AI",
                        DescriptionAr = "للمستخدمين المتقدمين الباحثين عن محافظ وحسابات غير محدودة وذكاء اصطناعي فائق",
                        FeaturesJson = JsonSerializer.Serialize(new List<string>
                        {
                            "Unlimited Multi-Wallets & Banks",
                            "Unlimited Voice AI Recognition",
                            "Export PDF & Excel Reports",
                            "Multi-Currency Exchange Sync",
                            "Priority Customer Support"
                        }),
                        FeaturesArJson = JsonSerializer.Serialize(new List<string>
                        {
                            "محافظ وحسابات بنكية غير محدودة",
                            "تسجيل المصروفات بالصوت بالذكاء الاصطناعي بلا حدود",
                            "تصدير تقارير PDF و Excel احترافية",
                            "دعم ومزامنة تعدد العملات والأسعار الحية",
                            "دعم فني متميز وأولوية في الاستجابة"
                        }),
                        IsPopular = true,
                        IsActive = true,
                        MaxWallets = 999,
                        MaxAiRequestsPerMonth = 999999,
                        CanExportReports = true,
                        CanUseMultiCurrency = true,
                        CreatedAt = now
                    },
                    new()
                    {
                        Id = "plan-pro-yearly",
                        Name = "Mahfazti Pro (Annual)",
                        NameAr = "باقة المحترفين (سنوي - وفر 35%)",
                        PriceEgp = 699m,
                        BillingCycle = "Yearly",
                        Description = "Best value for year-round financial freedom",
                        DescriptionAr = "أفضل قيمة وأعلى توفير للتحكم المالي الذكي على مدار العام بالكامل",
                        FeaturesJson = JsonSerializer.Serialize(new List<string>
                        {
                            "All Monthly Pro Features Included",
                            "2 Months Free (Save 35%)",
                            "Early access to new AI models",
                            "Family sharing (up to 3 members)"
                        }),
                        FeaturesArJson = JsonSerializer.Serialize(new List<string>
                        {
                            "جميع مميزات باقة المحترفين الشهرية",
                            "شهران مجاناً (توفير 35% من القيمة)",
                            "وصول مبكر لنماذج وميزات الذكاء الاصطناعي الجديدة",
                            "مشاركة عائلية للمحفظة (حتى 3 مستخدمين)"
                        }),
                        IsPopular = false,
                        IsActive = true,
                        MaxWallets = 999,
                        MaxAiRequestsPerMonth = 999999,
                        CanExportReports = true,
                        CanUseMultiCurrency = true,
                        CreatedAt = now
                    }
                };

                await context.PricingPlans.AddRangeAsync(plans);
                await context.SaveChangesAsync();
            }
            else
            {
                // Backfill Arabic descriptions and features for existing default plans if missing
                var existingPlans = await context.PricingPlans.ToListAsync();
                bool modified = false;

                foreach (var p in existingPlans)
                {
                    if (p.Id == "plan-free" && (string.IsNullOrWhiteSpace(p.DescriptionAr) || p.FeaturesArJson == "[]" || string.IsNullOrWhiteSpace(p.FeaturesArJson)))
                    {
                        p.DescriptionAr = "الميزات الأساسية والمثالية لتتبع الميزانية الشخصية والمصروفات اليومية";
                        p.FeaturesArJson = JsonSerializer.Serialize(new List<string>
                        {
                            "محفظة نقدية واحدة",
                            "15 معاملة صوتية بالذكاء الاصطناعي شهرياً",
                            "تصنيفات أساسية ومخصصة",
                            "تحليلات وتقارير مالية قياسية"
                        });
                        modified = true;
                    }
                    else if (p.Id == "plan-pro-monthly" && (string.IsNullOrWhiteSpace(p.DescriptionAr) || p.FeaturesArJson == "[]" || string.IsNullOrWhiteSpace(p.FeaturesArJson)))
                    {
                        p.DescriptionAr = "للمستخدمين المتقدمين الباحثين عن محافظ وحسابات غير محدودة وذكاء اصطناعي فائق";
                        p.FeaturesArJson = JsonSerializer.Serialize(new List<string>
                        {
                            "محافظ وحسابات بنكية غير محدودة",
                            "تسجيل المصروفات بالصوت بالذكاء الاصطناعي بلا حدود",
                            "تصدير تقارير PDF و Excel احترافية",
                            "دعم ومزامنة تعدد العملات والأسعار الحية",
                            "دعم فني متميز وأولوية في الاستجابة"
                        });
                        modified = true;
                    }
                    else if (p.Id == "plan-pro-yearly" && (string.IsNullOrWhiteSpace(p.DescriptionAr) || p.FeaturesArJson == "[]" || string.IsNullOrWhiteSpace(p.FeaturesArJson)))
                    {
                        p.DescriptionAr = "أفضل قيمة وأعلى توفير للتحكم المالي الذكي على مدار العام بالكامل";
                        p.FeaturesArJson = JsonSerializer.Serialize(new List<string>
                        {
                            "جميع مميزات باقة المحترفين الشهرية",
                            "شهران مجاناً (توفير 35% من القيمة)",
                            "وصول مبكر لنماذج وميزات الذكاء الاصطناعي الجديدة",
                            "مشاركة عائلية للمحفظة (حتى 3 مستخدمين)"
                        });
                        modified = true;
                    }
                }

                if (modified)
                {
                    await context.SaveChangesAsync();
                }
            }

            // 2. Seed Promo Codes
            if (!await context.PromoCodes.AnyAsync())
            {
                var promoCodes = new List<PromoCode>
                {
                    new()
                    {
                        Id = "promo-launch50",
                        Code = "LAUNCH50",
                        DiscountPercentage = 50,
                        MaxUses = 100,
                        UsedCount = 42,
                        ExpiresAt = now.AddMonths(6),
                        IsActive = true,
                        CreatedAt = now
                    },
                    new()
                    {
                        Id = "promo-mahfazti2026",
                        Code = "MAHFAZTI2026",
                        DiscountPercentage = 25,
                        MaxUses = 500,
                        UsedCount = 118,
                        ExpiresAt = now.AddMonths(12),
                        IsActive = true,
                        CreatedAt = now
                    }
                };

                await context.PromoCodes.AddRangeAsync(promoCodes);
                await context.SaveChangesAsync();
            }

            // 3. Seed Sample Payments & Subscriptions if empty
            if (!await context.UserSubscriptions.AnyAsync())
            {
                var adminUser = await context.Users.FirstOrDefaultAsync();
                var proPlan = await context.PricingPlans.FirstOrDefaultAsync(p => p.Id == "plan-pro-monthly");

                if (adminUser != null && proPlan != null)
                {
                    var sampleSub = new UserSubscription
                    {
                        Id = Guid.NewGuid().ToString(),
                        UserId = adminUser.Id,
                        PlanId = proPlan.Id,
                        Status = "Active",
                        AmountPaidEgp = proPlan.PriceEgp,
                        Gateway = "Paymob",
                        StartDate = now.AddDays(-10),
                        EndDate = now.AddDays(20),
                        AutoRenew = true,
                        CreatedAt = now.AddDays(-10)
                    };

                    var samplePayment = new PaymentLog
                    {
                        Id = Guid.NewGuid().ToString(),
                        InvoiceNumber = "INV-2026-0001",
                        UserId = adminUser.Id,
                        UserEmail = adminUser.Email ?? "admin@mahfazti.app",
                        PlanName = proPlan.Name,
                        Amount = proPlan.PriceEgp,
                        Currency = "EGP",
                        Gateway = "Paymob",
                        Status = "Success",
                        TransactionRef = "PMB_" + Guid.NewGuid().ToString().Substring(0, 8).ToUpper(),
                        CreatedAt = now.AddDays(-10)
                    };

                    await context.UserSubscriptions.AddAsync(sampleSub);
                    await context.PaymentLogs.AddAsync(samplePayment);
                    await context.SaveChangesAsync();
                }
            }
        }
    }
}
