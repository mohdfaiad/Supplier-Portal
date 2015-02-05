using System.Collections.Generic;
using com.Sconit.Entity.MD;

//TODO: Add other using statements here.

namespace com.Sconit.Service
{
    public interface IPlantMgr : ICastleAwarable
    {
        #region Customized Methods

        void Create(Plant plant);

        #endregion Customized Methods
    }
}
