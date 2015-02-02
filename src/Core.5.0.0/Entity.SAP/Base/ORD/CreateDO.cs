using System;
using System.ComponentModel.DataAnnotations;

namespace com.Sconit.Entity.SAP.ORD
{
    [Serializable]
    public partial class CreateDO : EntityBase
    {
        #region O/R Mapping Properties
		
		public Int32 Id { get; set; }
        [Display(Name = "CreateDO_DoNo", ResourceType = typeof(Resources.SI.CreateDO))]
        public string DoNo { get; set; }
        [Display(Name = "CreateDO_DoLine", ResourceType = typeof(Resources.SI.CreateDO))]
        public string DoLine { get; set; }
        [Display(Name = "CreateDO_Plant", ResourceType = typeof(Resources.SI.CreateDO))]
        public string Plant { get; set; }
        [Display(Name = "CreateDO_LocationFrom", ResourceType = typeof(Resources.SI.CreateDO))]
        public string LocationFrom { get; set; }
        [Display(Name = "CreateDO_LocationTo", ResourceType = typeof(Resources.SI.CreateDO))]
        public string LocationTo { get; set; }
        [Display(Name = "CreateDO_Item", ResourceType = typeof(Resources.SI.CreateDO))]
        public string Item { get; set; }
        [Display(Name = "CreateDO_Uom", ResourceType = typeof(Resources.SI.CreateDO))]
        public string Uom { get; set; }
        [Display(Name = "CreateDO_Qty", ResourceType = typeof(Resources.SI.CreateDO))]
        public string Qty { get; set; }
        [Display(Name = "CreateDO_WindowTime", ResourceType = typeof(Resources.SI.CreateDO))]
        public string WindowTime { get; set; }
        [Display(Name = "CreateDO_OpReference", ResourceType = typeof(Resources.SI.CreateDO))]
        public string OpReference { get; set; }
        [Display(Name = "CreateDO_SAPCreateDate", ResourceType = typeof(Resources.SI.CreateDO))]
        public string SAPCreateDate { get; set; }
        [System.Xml.Serialization.XmlIgnore]
        [Display(Name = "CreateDO_CreateDate", ResourceType = typeof(Resources.SI.CreateDO))]
        public DateTime CreateDate { get; set; }
        [System.Xml.Serialization.XmlIgnore]
        [Display(Name = "CreateDO_CreateUser", ResourceType = typeof(Resources.SI.CreateDO))]
        public string CreateUser { get; set; }
        [System.Xml.Serialization.XmlIgnore]
        [Display(Name = "CreateDO_LastModifyDate", ResourceType = typeof(Resources.SI.CreateDO))]
        public DateTime LastModifyDate { get; set; }
        [System.Xml.Serialization.XmlIgnore]
        [Display(Name = "CreateDO_LastModifyUser", ResourceType = typeof(Resources.SI.CreateDO))]
        public string LastModifyUser { get; set; }
        [System.Xml.Serialization.XmlIgnore]
        [Display(Name = "CreateDO_ErrorCount", ResourceType = typeof(Resources.SI.CreateDO))]
        public Int32 ErrorCount { get; set; }
        [System.Xml.Serialization.XmlIgnore]
        [Display(Name = "CreateDO_ErrorMessage", ResourceType = typeof(Resources.SI.CreateDO))]
        public string ErrorMessage { get; set; }
        [System.Xml.Serialization.XmlIgnore]
        public Int32 Version { get; set; }
        [System.Xml.Serialization.XmlIgnore]
        [Display(Name = "CreateDO_Status", ResourceType = typeof(Resources.SI.CreateDO))]
        public Int16 Status { get; set; }
        [System.Xml.Serialization.XmlIgnore]
        [Display(Name = "CreateDO_OrderNo", ResourceType = typeof(Resources.SI.CreateDO))]
        public string OrderNo { get; set; }
        
        #endregion

		public override int GetHashCode()
        {
			if (Id != 0)
            {
                return Id.GetHashCode();
            }
            else
            {
                return base.GetHashCode();
            }
        }

        public override bool Equals(object obj)
        {
            CreateDO another = obj as CreateDO;

            if (another == null)
            {
                return false;
            }
            else
            {
            	return (this.Id == another.Id);
            }
        } 
    }
	
}
