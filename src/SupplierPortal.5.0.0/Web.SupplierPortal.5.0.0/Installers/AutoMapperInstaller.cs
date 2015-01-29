using System.Web.Mvc;
using AutoMapper;
using Castle.MicroKernel.Registration;
using Castle.MicroKernel.SubSystems.Configuration;
using Castle.Windsor;
using com.Sconit.Entity.SYS;
using com.Sconit.Web.Models;

/// <summary>
/// Summary description for AutoMapperInstaller
/// </summary>
namespace com.Sconit.Web.Installer
{
    public class AutoMapperInstaller : IWindsorInstaller
    {
        public void Install(IWindsorContainer container, IConfigurationStore store)
        {
            Mapper.CreateMap<Menu, MenuModel>();

            Mapper.CreateMap<CodeDetail, SelectListItem>()
                .ForMember(d => d.Value, opt => opt.MapFrom(s => s.Value))
                .ForMember(d => d.Text, opt => opt.MapFrom(s => s.Description));

            Mapper.CreateMap<com.Sconit.Entity.ORD.OrderDetail, com.Sconit.Entity.LOG.SeqOrderChange>();
            Mapper.CreateMap<com.Sconit.Entity.ORD.OrderDetail, com.Sconit.Entity.LOG.DistributionRequisition>()
                .ForMember(d => d.OrderDetId, opt => opt.MapFrom(s => s.Id))
                .ForMember(d => d.Flow, opt => opt.MapFrom(s => s.Flow))
                .ForMember(d => d.FlowDescription, opt => opt.MapFrom(s => s.FlowDescription))
                .ForMember(d => d.PartyFrom, opt => opt.MapFrom(s => s.MastPartyFrom))
                .ForMember(d => d.PartyTo, opt => opt.MapFrom(s => s.MastPartyTo));

        }
    }
}