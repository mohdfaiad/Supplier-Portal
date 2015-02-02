using System;
using System.ComponentModel.DataAnnotations;

namespace com.Sconit.Entity.SAP.ORD
{
    [Serializable]
    public partial class CancelCreateDN : EntityBase
    {
        #region O/R Mapping Properties
		
		public Int32 CancelIpDetConfirmId { get; set; }
		public Int32? IpDetConfirmId { get; set; }
		public string OrderNo { get; set; }
		public string IpNo { get; set; }
		public Int32? IpDetSeq { get; set; }
		public string MATNR { get; set; }
		public string ItemDesc { get; set; }
		public string Uom { get; set; }
		public Decimal? G_LFIMG { get; set; }
		public string WERKS { get; set; }
		public string LGORT { get; set; }
		public string EBELN { get; set; }
		public string EBELP { get; set; }
		public DateTime? EffDate { get; set; }
		public string CreateUser { get; set; }
		public DateTime? CreateDate { get; set; }
		public string LastModifyUser { get; set; }
		public DateTime? LastModifyDate { get; set; }
        public string DNSTR { get; set; }
        public string GISTR { get; set; }
        public string VBELN_VL { get; set; }
		public Int32? ErrorCount { get; set; }
		public string Message { get; set; }
		public Int32? Version { get; set; }
        
        #endregion

		public override int GetHashCode()
        {
			if (CancelIpDetConfirmId != 0)
            {
                return CancelIpDetConfirmId.GetHashCode();
            }
            else
            {
                return base.GetHashCode();
            }
        }

        public override bool Equals(object obj)
        {
            CancelCreateDN another = obj as CancelCreateDN;

            if (another == null)
            {
                return false;
            }
            else
            {
            	return (this.CancelIpDetConfirmId == another.CancelIpDetConfirmId);
            }
        } 
    }
	
}
