using System;

//TODO: Add other using statements here

namespace com.Sconit.Entity.ORD
{
    public partial class IpLocationDetail
    {
        #region Non O/R Mapping Properties

        public decimal RemainReceiveQty
        {
            get
            {
                return this.Qty - this.ReceivedQty;
            }
        }

        //���������ʱ���õ�
        public IpDetail IpDetail
        {
            get;
            set;
        }

        #endregion
    }
}