using System;
using System.ComponentModel.DataAnnotations;
using com.Sconit.Entity.SYS;

namespace com.Sconit.Entity.ORD
{
    [Serializable]
    public partial class TyreOrderMaster : EntityBase, IAuditable
    {
        #region O/R Mapping Properties
        [Display(Name = "TyreOrderDetail_OrderNo", ResourceType = typeof(Resources.ORD.TyreOrderDetail))]
        public string TyreOrderNo { get; set; }


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
            if (TyreOrderNo  != null)
            {
                return TyreOrderNo.GetHashCode();
            }
            else
            {
                return base.GetHashCode();
            }
        }

        public override bool Equals(object obj)
        {
            TyreOrderMaster another = obj as TyreOrderMaster;

            if (another == null)
            {
                return false;
            }
            else
            {
                return (this.TyreOrderNo == another.TyreOrderNo);
            }
        }
    }

}
