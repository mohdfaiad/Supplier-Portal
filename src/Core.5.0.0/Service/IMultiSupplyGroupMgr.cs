using System;
using System.IO;
using com.Sconit.Entity.PRD;
using com.Sconit.Service.Impl;

namespace com.Sconit.Service
{
    public interface IMultiSupplyGroupMgr : ICastleAwarable
    {
        string CreateMultiSupplyItemXlsx(Stream inputStream);
        void DeleteMultiSupplyGroup(string groupNo);
    }
}
