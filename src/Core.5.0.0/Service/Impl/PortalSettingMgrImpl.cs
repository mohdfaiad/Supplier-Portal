using System.Collections.Generic;
using System.Linq;
using com.Sconit.Entity.SYS;

namespace com.Sconit.Service.Impl
{
    public class PortalSettingMgrImpl : IPortalSettingMgr
    {
        public IGenericMgr genericMgr { get; set; }
        private static IList<PortalSetting> PortalSettingCacheList;        

        public PortalSetting GetPortalSetting(int siteId)
        {
            if (PortalSettingCacheList == null)
            {
                LoadPortalSettingCache();
            }

            return PortalSettingCacheList.Where(c => c.Id == siteId).SingleOrDefault();
        }

        public IList<PortalSetting> GetAllPortalSettings()
        {
            if (PortalSettingCacheList == null)
            {
                LoadPortalSettingCache();
            }
            return PortalSettingCacheList;
        }

        private static object LoadPortalSettingCacheLock = new object();
        public void LoadPortalSettingCache()
        {
            lock (LoadPortalSettingCacheLock)
            {
                PortalSettingCacheList = genericMgr.FindAll<PortalSetting>("from PortalSetting");
            }
        }

        public IList<PortalSetting> GetNonePrimaryPortalSetting()
        {
            if (PortalSettingCacheList == null)
            {
                LoadPortalSettingCache();
            }
            return PortalSettingCacheList.Where(p => !p.IsPrimary).ToList();
        }
    }
}
