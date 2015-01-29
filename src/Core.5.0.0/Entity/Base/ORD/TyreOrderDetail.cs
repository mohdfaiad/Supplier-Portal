using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using com.Sconit.Entity.INV;
using com.Sconit.Entity.SYS;

namespace com.Sconit.Entity.ORD
{
    [Serializable]
    public partial class TyreOrderDetail : EntityBase, IAuditable
    {
        #region O/R Mapping Properties

        public Int32 Id { get; set; }

        public Int32 DetId { get; set; }

        [Display(Name = "TyreOrderDetail_OrderNo", ResourceType = typeof(Resources.ORD.TyreOrderDetail))]
        public string TyreOrderNo { get; set; }

        [Display(Name = "TyreOrderDetail_RefOrderNo", ResourceType = typeof(Resources.ORD.TyreOrderDetail))]
        public string RefOrderNo { get; set; }

        [Display(Name = "TyreOrderDetail_ProdNo", ResourceType = typeof(Resources.ORD.TyreOrderDetail))]
        public string ProdNo { get; set; }

        [Display(Name = "TyreOrderDetail_Flow", ResourceType = typeof(Resources.ORD.TyreOrderDetail))]
        public string Flow { get; set; }

        [Display(Name = "TyreOrderDetail_FlowDescription", ResourceType = typeof(Resources.ORD.TyreOrderDetail))]
        public string FlowDescription { get; set; }

        [Display(Name = "TyreOrderDetail_ProdLine", ResourceType = typeof(Resources.ORD.TyreOrderDetail))]
        public string ProdLine { get; set; }

        [Display(Name = "TyreOrderDetail_ProdLineDescription", ResourceType = typeof(Resources.ORD.TyreOrderDetail))]
        public string ProdLineDescription { get; set; }

        [Display(Name = "TyreOrderDetail_SeqGroup", ResourceType = typeof(Resources.ORD.TyreOrderDetail))]
        public string SeqGroup { get; set; }

        [Display(Name = "TyreOrderDetail_VanNo", ResourceType = typeof(Resources.ORD.TyreOrderDetail))]
        public string VanNo { get; set; }

        [Display(Name = "TyreOrderDetail_Item", ResourceType = typeof(Resources.ORD.TyreOrderDetail))]
        public string Item { get; set; }

        [Display(Name = "TyreOrderDetail_ItemDescription", ResourceType = typeof(Resources.ORD.TyreOrderDetail))]
        public string ItemDescription { get; set; }

        [Display(Name = "TyreOrderDetail_ReferenceItemCode", ResourceType = typeof(Resources.ORD.TyreOrderDetail))]
        public string ReferenceItemCode { get; set; }

        [Display(Name = "TyreOrderDetail_Uom", ResourceType = typeof(Resources.ORD.TyreOrderDetail))]
        public string Uom { get; set; }

        [Display(Name = "TyreOrderDetail_UnitCount", ResourceType = typeof(Resources.ORD.TyreOrderDetail))]
        public Decimal UnitCount { get; set; }

        [Display(Name = "TyreOrderDetail_OrderedQty", ResourceType = typeof(Resources.ORD.TyreOrderDetail))]
        public Decimal OrderedQty { get; set; }

        [Display(Name = "TyreOrderDetail_ShippedQty", ResourceType = typeof(Resources.ORD.TyreOrderDetail))]
        public Decimal ShippedQty { get; set; }

        [Display(Name = "TyreOrderDetail_ReceivedQty", ResourceType = typeof(Resources.ORD.TyreOrderDetail))]
        public Decimal ReceivedQty { get; set; }

        [Display(Name = "TyreOrderDetail_LocationFrom", ResourceType = typeof(Resources.ORD.TyreOrderDetail))]
        public string LocationFrom { get; set; }

        public string LocationFromName { get; set; }

        [Display(Name = "TyreOrderDetail_LocationTo", ResourceType = typeof(Resources.ORD.TyreOrderDetail))]
        public string LocationTo { get; set; }

        public string LocationToName { get; set; }

        [Display(Name = "TyreOrderDetail_CompleteDate", ResourceType = typeof(Resources.ORD.TyreOrderDetail))]
        public DateTime CompleteDate { get; set; }

        public Int32 CreateUserId { get; set; }

        public string CreateUserName { get; set; }

        public DateTime CreateDate { get; set; }

        public Int32 LastModifyUserId { get; set; }

        [Display(Name = "TyreOrderDetail_LastModifyUserName", ResourceType = typeof(Resources.ORD.TyreOrderDetail))]
        public string LastModifyUserName { get; set; }

        [Display(Name = "TyreOrderDetail_LastModifyDate", ResourceType = typeof(Resources.ORD.TyreOrderDetail))]
        public DateTime LastModifyDate { get; set; }

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
            TyreOrderDetail another = obj as TyreOrderDetail;

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
