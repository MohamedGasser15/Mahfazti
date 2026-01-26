using AutoMapper;

namespace FujPolice.API.MappingConfig
{
    /// <summary>
    /// AutoMapper configuration profile for entity to DTO mappings
    /// </summary>
    public class MappingConfig : Profile
    {
        /// <summary>
        /// Initializes a new instance of the MappingConfig class
        /// </summary>
        public MappingConfig()
        {
            ConfigureUserMappings();
        }

        #region Private Configuration Methods

        private void ConfigureUserMappings()
        {
           
        }

        #endregion
    }
}