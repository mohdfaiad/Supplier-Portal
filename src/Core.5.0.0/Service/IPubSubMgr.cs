using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace com.Sconit.Service
{
    public interface IPubSubMgr : ICastleAwarable
    {
        IPublishing CreateProxy();
    }
}
