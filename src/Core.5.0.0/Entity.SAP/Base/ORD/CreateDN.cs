using System;
using System.ComponentModel.DataAnnotations;

namespace com.Sconit.Entity.SAP.ORD
{
    [Serializable]
    public partial class CreateDN : EntityBase
    {
        #region O/R Mapping Properties
		
		public Int32 IpDetConfirmId { get; set; }
        [Display(Name = "CreateDN_OrderNo", ResourceType = typeof(Resources.SI.CreateDN))]
        public string OrderNo { get; set; }
        [Display(Name = "CreateDN_IpNo", ResourceType = typeof(Resources.SI.CreateDN))]
        public string IpNo { get; set; }
		public Int32? IpDetSeq { get; set; }
        [Display(Name = "CreateDN_MATNR", ResourceType = typeof(Resources.SI.CreateDN))]
        public string MATNR { get; set; }
        [Display(Name = "CreateDN_ItemDesc", ResourceType = typeof(Resources.SI.CreateDN))]
        public string ItemDesc { get; set; }
        [Display(Name = "CreateDN_Uom", ResourceType = typeof(Resources.SI.CreateDN))]
        public string Uom { get; set; }
        [Display(Name = "CreateDN_G_LFIMG", ResourceType = typeof(Resources.SI.CreateDN))]
        public Decimal? G_LFIMG { get; set; }
        [Display(Name = "CreateDN_WERKS", ResourceType = typeof(Resources.SI.CreateDN))]
        public string WERKS { get; set; }
        [Display(Name = "CreateDN_LGORT", ResourceType = typeof(Resources.SI.CreateDN))]
        public string LGORT { get; set; }
        [Display(Name = "CreateDN_EBELN", ResourceType = typeof(Resources.SI.CreateDN))]
        public string EBELN { get; set; }
        [Display(Name = "CreateDN_EBELP", ResourceType = typeof(Resources.SI.CreateDN))]
        public string EBELP { get; set; }
        [Display(Name = "CreateDN_EffDate", ResourceType = typeof(Resources.SI.CreateDN))]
        public DateTime? EffDate { get; set; }
		public string CreateUser { get; set; }
        [Display(Name = "CreateDN_CreateDate", ResourceType = typeof(Resources.SI.CreateDN))]
        public DateTime? CreateDate { get; set; }
		public string LastModifyUser{ get; set; }
        [Display(Name = "CreateDN_LastModifyDate", ResourceType = typeof(Resources.SI.CreateDN))]
        public DateTime? LastModifyDate { get; set; }
        public string DNSTR { get; set; }
        public string GISTR { get; set; }
        [Display(Name = "CreateDN_VBELN_VL", ResourceType = typeof(Resources.SI.CreateDN))]
        public string VBELN_VL { get; set; }
        [Display(Name = "CreateDN_ErrorCount", ResourceType = typeof(Resources.SI.CreateDN))]
        public Int32? ErrorCount { get; set; }
        [Display(Name = "CreateDN_Message", ResourceType = typeof(Resources.SI.CreateDN))]
        public string Message { get; set; }
		public Int32? Version { get; set; }
        
        #endregion

		public override int GetHashCode()
        {
			if (IpDetConfirmId != 0)
            {
                return IpDetConfirmId.GetHashCode();
            }
            else
            {
                return base.GetHashCode();
            }
        }

        public override bool Equals(object obj)
        {
            CreateDN another = obj as CreateDN;

            if (another == null)
            {
                return false;
            }
            else
            {
            	return (this.IpDetConfirmId == another.IpDetConfirmId);
            }
        } 
    }
	
}
