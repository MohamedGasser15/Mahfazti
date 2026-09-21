using System.Collections.Generic;
using System.Threading.Tasks;

namespace Mahfazti.Core.Interfaces
{
    public interface IExchangeRateService
    {
        /// <summary>
        /// Fetches official live exchange rates of currencies against EGP.
        /// Returns a dictionary where Key is Currency Code (e.g. "USD", "SAR") and Value is Valuation in EGP (e.g. 48.75).
        /// </summary>
        Task<Dictionary<string, decimal>?> FetchLiveRatesAgainstEgpAsync();
    }
}
