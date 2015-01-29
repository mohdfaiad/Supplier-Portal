using System;
using System.ComponentModel.DataAnnotations;

namespace com.Sconit.Entity.CUST
{
    [Serializable]
    public partial class FlowRelationship : EntityBase, IAuditable
    {
        #region O/R Mapping Properties

        public Int32 Id { get; set; }

        [Display(Name = "TyreOrderDetail_ProdLine", ResourceType = typeof(Resources.ORD.TyreOrderDetail))]
        public string ProdLine { get; set; }

        [Display(Name = "TyreOrderDetail_Flow", ResourceType = typeof(Resources.ORD.TyreOrderDetail))]
        public string Flow { get; set; }

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
            if (ProdLine != null)
            {
                return ProdLine.GetHashCode();
            }
            else
            {
                return base.GetHashCode();
            }
        }

        public override bool Equals(object obj)
        {
            FlowRelationship another = obj as FlowRelationship;

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
