using AutoMapper;
using Mahfazti.Core.DTOs.Auth;
using Mahfazti.Core.Entities;

namespace Mahfazti.Api.MappingConfig
{
    public class MappingConfig : Profile
    {
        public MappingConfig()
        {
            CreateMap<ApplicationUser, UserDTO>()
                .ForMember(dest => dest.Id, opt => opt.MapFrom(src => src.Id.ToString()))
                .ForMember(dest => dest.Role, opt => opt.Ignore());
        }
    }
}