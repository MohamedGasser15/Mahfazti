using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Mahfazti.Core.Common;
using Mahfazti.Core.DTOs.FinancialInstitution;
using Mahfazti.Core.Entities;
using Mahfazti.Core.Interfaces;
using Microsoft.Extensions.Logging;

namespace Mahfazti.Core.Services
{
    public class FinancialInstitutionService : IFinancialInstitutionService
    {
        private readonly IRepository<FinancialInstitution> _repository;
        private readonly ILogger<FinancialInstitutionService> _logger;

        public FinancialInstitutionService(
            IRepository<FinancialInstitution> repository,
            ILogger<FinancialInstitutionService> logger)
        {
            _repository = repository;
            _logger = logger;
        }

        public async Task<ApiResponse<List<FinancialInstitutionDto>>> GetAllAsync(
            string? query = null,
            string? category = null,
            string? country = null,
            bool? isPopular = null,
            bool includeInactive = false)
        {
            try
            {
                var queryLower = query?.Trim().ToLowerInvariant();
                var categoryLower = category?.Trim().ToLowerInvariant();
                var countryUpper = country?.Trim().ToUpperInvariant();

                var list = await _repository.GetAllAsync(
                    filter: fi =>
                        (includeInactive || fi.IsActive) &&
                        (isPopular == null || fi.IsPopular == isPopular.Value) &&
                        (string.IsNullOrEmpty(categoryLower) || fi.Category.ToLower() == categoryLower) &&
                        (string.IsNullOrEmpty(countryUpper) || fi.CountryCode == countryUpper),
                    orderBy: q => q.OrderByDescending(fi => fi.IsPopular)
                                   .ThenBy(fi => fi.NameEn)
                );

                if (!string.IsNullOrEmpty(queryLower))
                {
                    list = list.Where(fi =>
                        fi.NameAr.ToLower().Contains(queryLower) ||
                        fi.NameEn.ToLower().Contains(queryLower) ||
                        fi.ShortName.ToLower().Contains(queryLower) ||
                        fi.Id.ToLower().Contains(queryLower) ||
                        (fi.SwiftCode != null && fi.SwiftCode.ToLower().Contains(queryLower))
                    ).ToList();
                }

                var dtos = list.Select(MapToDto).ToList();
                return ApiResponse<List<FinancialInstitutionDto>>.SuccessResponse(dtos);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to retrieve financial institutions");
                return ApiResponse<List<FinancialInstitutionDto>>.FailResponse("Failed to load institutions: " + ex.Message);
            }
        }

        public async Task<ApiResponse<FinancialInstitutionDto>> GetByIdAsync(string id)
        {
            try
            {
                var idLower = id.Trim().ToLowerInvariant();
                var institution = await _repository.GetAsync(fi => fi.Id.ToLower() == idLower);

                if (institution == null)
                {
                    return ApiResponse<FinancialInstitutionDto>.FailResponse($"Institution with ID '{id}' was not found.");
                }

                return ApiResponse<FinancialInstitutionDto>.SuccessResponse(MapToDto(institution));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to retrieve institution with ID {Id}", id);
                return ApiResponse<FinancialInstitutionDto>.FailResponse("Error: " + ex.Message);
            }
        }

        private static FinancialInstitutionDto MapToDto(FinancialInstitution fi)
        {
            var logoUrl = fi.LogoUrl;
            if (string.IsNullOrWhiteSpace(logoUrl) || logoUrl.Contains("google.com/s2/favicons"))
            {
                logoUrl = $"https://mahfazati.runasp.net/images/banks/{fi.Id}.png";
            }

            return new FinancialInstitutionDto
            {
                Id = fi.Id,
                NameAr = fi.NameAr,
                NameEn = fi.NameEn,
                ShortName = fi.ShortName,
                SwiftCode = fi.SwiftCode,
                Category = fi.Category,
                CountryCode = fi.CountryCode,
                LogoAsset = fi.LogoAsset,
                LogoUrl = logoUrl,
                Website = fi.Website,
                IsPopular = fi.IsPopular,
                IsActive = fi.IsActive,
            };
        }
    }
}
