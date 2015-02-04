using System;
using System.Collections;
using System.Collections.Generic;
using com.Sconit.Entity.MD;
using System.Linq;
using Castle.Services.Transaction;
using com.Sconit.Entity.ACC;
using com.Sconit.Entity;

namespace com.Sconit.Service.Impl
{
    [Transactional]
    public class PlantMgrImpl : BaseMgr, IPlantMgr
    {

        public IGenericMgr genericMgr { get; set; }

        #region public methods

        [Transaction(TransactionMode.Requires)]
        public void Create(Plant plant)
        {
            genericMgr.Create(plant);
        }

        #endregion

    }
}