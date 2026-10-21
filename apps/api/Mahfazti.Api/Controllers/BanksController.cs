using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Mahfazti.Core.Interfaces;

namespace Mahfazti.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Route("api/financial-institutions")]
    [AllowAnonymous]
    public class BanksController : ControllerBase
    {
        private readonly IFinancialInstitutionService _institutionService;

        public BanksController(IFinancialInstitutionService institutionService)
        {
            _institutionService = institutionService;
        }

        /// <summary>
        /// Retrieves all banks, neo-banks, and fintech applications with optional filtering.
        /// </summary>
        /// <param name="query">Search term in Arabic, English, or short name/SWIFT</param>
        /// <param name="category">Filter by category: egyptian, fintech, international</param>
        /// <param name="country">Filter by country code (e.g. EG, SA, AE, US, GB)</param>
        /// <param name="isPopular">Filter only popular/featured institutions</param>
        /// <param name="includeInactive">Whether to include inactive institutions</param>
        [HttpGet]
        public async Task<IActionResult> GetAll(
            [FromQuery] string? query = null,
            [FromQuery] string? category = null,
            [FromQuery] string? country = null,
            [FromQuery] bool? isPopular = null,
            [FromQuery] bool includeInactive = false)
        {
            var result = await _institutionService.GetAllAsync(query, category, country, isPopular, includeInactive);
            return StatusCode((int)result.StatusCode, result);
        }

        /// <summary>
        /// Retrieves details of a specific financial institution by ID.
        /// </summary>
        /// <param name="id">Unique identifier (e.g. nbe, cib, telda, revolut)</param>
        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(string id)
        {
            var result = await _institutionService.GetByIdAsync(id);
            return StatusCode((int)result.StatusCode, result);
        }
    }
}
