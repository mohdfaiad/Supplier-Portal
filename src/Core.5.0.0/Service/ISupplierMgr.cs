using System.Collections.Generic;
using com.Sconit.Entity.MD;

//TODO: Add other using statements here.

namespace com.Sconit.Service
{
    public interface ISupplierMgr : ICastleAwarable
    {
        #region Customized Methods

        IList<Supplier> GetOrderFromSupplier(com.Sconit.CodeMaster.OrderType type);

        IList<Supplier> GetOrderToSupplier(com.Sconit.CodeMaster.OrderType type);

        void Create(Supplier party);

        //void AddPartyAddress(PartyAddress partyAddress);

        //void UpdatePartyAddress(PartyAddress partyAddress);

        #endregion Customized Methods
    }
}
