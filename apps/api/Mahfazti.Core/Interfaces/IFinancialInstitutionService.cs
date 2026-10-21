using System.Collections.Generic;
using System.Threading.Tasks;
using Mahfazti.Core.Common;
using Mahfazti.Core.DTOs.FinancialInstitution;

namespace Mahfazti.Core.Interfaces
{
    public interface IFinancialInstitutionService
    {
        Task<ApiResponse<List<FinancialInstitutionDto>>> GetAllAsync(
            string? query = null,
            string? category = null,
            string? country = null,
            bool? isPopular = null,
            bool includeInactive = false);

        Task<ApiResponse<FinancialInstitutionDto>> GetByIdAsync(string id);
    }
}
