using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Mahfazti.Core.Entities;

namespace Mahfazti.Infrastructure.Data.Seeders
{
    public static class CurrencySeeder
    {
        public static async Task SeedAsync(ApplicationDbContext context)
        {
            var now = DateTime.UtcNow;

            var catalog = new List<Currency>
            {
                // Core Active & Featured Currencies
                new() { Code = "EGP", NameEn = "Egyptian Pound", NameAr = "الجنيه المصري", Symbol = "EGP", ExchangeRateToEgp = 1.0m, IsDefault = true, IsActive = true, IsFeatured = true, LastUpdated = now },
                new() { Code = "USD", NameEn = "US Dollar", NameAr = "الدولار الأمريكي", Symbol = "$", ExchangeRateToEgp = 48.75m, IsDefault = false, IsActive = true, IsFeatured = true, LastUpdated = now },
                new() { Code = "SAR", NameEn = "Saudi Riyal", NameAr = "الريال السعودي", Symbol = "SAR", ExchangeRateToEgp = 13.00m, IsDefault = false, IsActive = true, IsFeatured = true, LastUpdated = now },
                new() { Code = "AED", NameEn = "UAE Dirham", NameAr = "الدرهم الإماراتي", Symbol = "AED", ExchangeRateToEgp = 13.27m, IsDefault = false, IsActive = true, IsFeatured = true, LastUpdated = now },
                new() { Code = "EUR", NameEn = "Euro", NameAr = "اليورو الأوروبي", Symbol = "€", ExchangeRateToEgp = 53.50m, IsDefault = false, IsActive = true, IsFeatured = true, LastUpdated = now },
                new() { Code = "KWD", NameEn = "Kuwaiti Dinar", NameAr = "الدينار الكويتي", Symbol = "KWD", ExchangeRateToEgp = 159.20m, IsDefault = false, IsActive = true, IsFeatured = true, LastUpdated = now },

                // Arab & Middle East Currencies (Catalog ready to be toggled)
                new() { Code = "QAR", NameEn = "Qatari Riyal", NameAr = "الريال القطري", Symbol = "QAR", ExchangeRateToEgp = 13.38m, IsDefault = false, IsActive = false, LastUpdated = now },
                new() { Code = "BHD", NameEn = "Bahraini Dinar", NameAr = "الدينار البحريني", Symbol = "BHD", ExchangeRateToEgp = 129.30m, IsDefault = false, IsActive = false, LastUpdated = now },
                new() { Code = "OMR", NameEn = "Omani Rial", NameAr = "الريال العماني", Symbol = "OMR", ExchangeRateToEgp = 126.60m, IsDefault = false, IsActive = false, LastUpdated = now },
                new() { Code = "JOD", NameEn = "Jordanian Dinar", NameAr = "الدينار الأردني", Symbol = "JOD", ExchangeRateToEgp = 68.75m, IsDefault = false, IsActive = false, LastUpdated = now },
                new() { Code = "MAD", NameEn = "Moroccan Dirham", NameAr = "الدرهم المغربي", Symbol = "MAD", ExchangeRateToEgp = 4.90m, IsDefault = false, IsActive = false, LastUpdated = now },
                new() { Code = "DZD", NameEn = "Algerian Dinar", NameAr = "الدينار الجزائري", Symbol = "DZD", ExchangeRateToEgp = 0.36m, IsDefault = false, IsActive = false, LastUpdated = now },
                new() { Code = "TND", NameEn = "Tunisian Dinar", NameAr = "الدينار التونسي", Symbol = "TND", ExchangeRateToEgp = 15.80m, IsDefault = false, IsActive = false, LastUpdated = now },
                new() { Code = "LYD", NameEn = "Libyan Dinar", NameAr = "الدينار الليبي", Symbol = "LYD", ExchangeRateToEgp = 10.15m, IsDefault = false, IsActive = false, LastUpdated = now },
                new() { Code = "IQD", NameEn = "Iraqi Dinar", NameAr = "الدينار العراقي", Symbol = "IQD", ExchangeRateToEgp = 0.037m, IsDefault = false, IsActive = false, LastUpdated = now },
                new() { Code = "LBP", NameEn = "Lebanese Pound", NameAr = "الليرة اللبنانية", Symbol = "LBP", ExchangeRateToEgp = 0.00054m, IsDefault = false, IsActive = false, LastUpdated = now },
                new() { Code = "SDG", NameEn = "Sudanese Pound", NameAr = "الجنيه السوداني", Symbol = "SDG", ExchangeRateToEgp = 0.081m, IsDefault = false, IsActive = false, LastUpdated = now },

                // Major Global Currencies
                new() { Code = "GBP", NameEn = "British Pound", NameAr = "الجنيه الإسترليني", Symbol = "£", ExchangeRateToEgp = 64.20m, IsDefault = false, IsActive = false, LastUpdated = now },
                new() { Code = "CAD", NameEn = "Canadian Dollar", NameAr = "الدولار الكندي", Symbol = "CA$", ExchangeRateToEgp = 35.80m, IsDefault = false, IsActive = false, LastUpdated = now },
                new() { Code = "CHF", NameEn = "Swiss Franc", NameAr = "الفرنك السويسري", Symbol = "CHF", ExchangeRateToEgp = 56.70m, IsDefault = false, IsActive = false, LastUpdated = now },
                new() { Code = "JPY", NameEn = "Japanese Yen", NameAr = "الين الياباني", Symbol = "¥", ExchangeRateToEgp = 0.34m, IsDefault = false, IsActive = false, LastUpdated = now },
                new() { Code = "CNY", NameEn = "Chinese Yuan", NameAr = "اليوان الصيني", Symbol = "¥", ExchangeRateToEgp = 6.90m, IsDefault = false, IsActive = false, LastUpdated = now },
                new() { Code = "TRY", NameEn = "Turkish Lira", NameAr = "الليرة التركية", Symbol = "₺", ExchangeRateToEgp = 1.42m, IsDefault = false, IsActive = false, LastUpdated = now },
                new() { Code = "AUD", NameEn = "Australian Dollar", NameAr = "الدولار الأسترالي", Symbol = "A$", ExchangeRateToEgp = 32.80m, IsDefault = false, IsActive = false, LastUpdated = now },
                new() { Code = "INR", NameEn = "Indian Rupee", NameAr = "الروبية الهندية", Symbol = "₹", ExchangeRateToEgp = 0.58m, IsDefault = false, IsActive = false, LastUpdated = now },
                new() { Code = "RUB", NameEn = "Russian Ruble", NameAr = "الروبل الروسي", Symbol = "₽", ExchangeRateToEgp = 0.52m, IsDefault = false, IsActive = false, LastUpdated = now },
                new() { Code = "BRL", NameEn = "Brazilian Real", NameAr = "الريال البرازيلي", Symbol = "R$", ExchangeRateToEgp = 8.85m, IsDefault = false, IsActive = false, LastUpdated = now },
            };

            var existingCodes = await context.Currencies.Select(c => c.Code).ToListAsync();
            var missingCurrencies = catalog.Where(c => !existingCodes.Contains(c.Code)).ToList();

            if (missingCurrencies.Count > 0)
            {
                await context.Currencies.AddRangeAsync(missingCurrencies);
                await context.SaveChangesAsync();
            }
        }
    }
}
