using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Mahfazti.Core.DTOs.Currency;
using Mahfazti.Core.Interfaces;

namespace Mahfazti.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class CurrenciesController : ControllerBase
    {
        private readonly ICurrencyService _currencyService;

        public CurrenciesController(ICurrencyService currencyService)
        {
            _currencyService = currencyService;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll([FromQuery] bool includeInactive = true)
        {
            var result = await _currencyService.GetAllCurrenciesAsync(includeInactive);
            return StatusCode((int)result.StatusCode, result);
        }

        [HttpGet("{code}")]
        public async Task<IActionResult> GetByCode(string code)
        {
            var result = await _currencyService.GetCurrencyByCodeAsync(code);
            return StatusCode((int)result.StatusCode, result);
        }

        [HttpPost("sync-rates")]
        [Authorize(Policy = "AdminPolicy")]
        public async Task<IActionResult> SyncLiveRates()
        {
            var result = await _currencyService.SyncLiveRatesAsync();
            return StatusCode((int)result.StatusCode, result);
        }

        [HttpPut("{code}/toggle-status")]
        [Authorize(Policy = "AdminPolicy")]
        public async Task<IActionResult> ToggleStatus(string code)
        {
            var result = await _currencyService.ToggleActiveAsync(code);
            return StatusCode((int)result.StatusCode, result);
        }

        [HttpPut("{code}/toggle-featured")]
        [Authorize(Policy = "AdminPolicy")]
        public async Task<IActionResult> ToggleFeatured(string code)
        {
            var result = await _currencyService.ToggleFeaturedAsync(code);
            return StatusCode((int)result.StatusCode, result);
        }

        [HttpPut("{code}/set-base")]
        [Authorize(Policy = "AdminPolicy")]
        public async Task<IActionResult> SetBase(string code)
        {
            var result = await _currencyService.SetBaseCurrencyAsync(code);
            return StatusCode((int)result.StatusCode, result);
        }

        [HttpPut("{code}/rate")]
        [Authorize(Policy = "AdminPolicy")]
        public async Task<IActionResult> UpdateRate(string code, [FromBody] UpdateCurrencyRateDto dto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var result = await _currencyService.UpdateRateAsync(code, dto.ExchangeRateToEgp);
            return StatusCode((int)result.StatusCode, result);
        }

        [HttpPost]
        [Authorize(Policy = "AdminPolicy")]
        public async Task<IActionResult> Create([FromBody] CreateCurrencyDto dto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var result = await _currencyService.AddCurrencyAsync(dto);
            return StatusCode((int)result.StatusCode, result);
        }
    }
}
