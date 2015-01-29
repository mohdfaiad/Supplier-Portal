using com.Sconit.Entity.SYS;
using System.Collections.Generic;

namespace com.Sconit.Service
{
    public interface IPortalSettingMgr : ICastleAwarable
    {
        PortalSetting GetPortalSetting(int siteId);

        IList<PortalSetting> GetNonePrimaryPortalSetting();

        IList<PortalSetting> GetAllPortalSettings();
    }
}
