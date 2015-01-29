using System;
using System.ComponentModel.DataAnnotations;

namespace com.Sconit.Entity.CUST
{
    [Serializable]
    public partial class OrderBomDetOnLine : EntityBase, IAuditable
    {
        #region O/R Mapping Properties
		
		public Int32 Id { get; set; }
		public DateTime Effdate { get; set; }
		public string Region { get; set; }
		public string Location { get; set; }
		public string AUFNR { get; set; }
		public string Item { get; set; }
		public string ItemDesc { get; set; }
		public string Uom { get; set; }
		public Decimal Qty { get; set; }
		public string FGItem { get; set; }
		public string ProdLine { get; set; }
		public string MoveType { get; set; }
		public DateTime CreateDate { get; set; }
		public Int32 CreateUserId { get; set; }
		public string CreateUserName { get; set; }
		public DateTime LastModifyDate { get; set; }
		public Int32 LastModifyUserId { get; set; }
		public string LastModifyUserName { get; set; }
		public Int32 Version { get; set; }
		public Int32 ErrorCount { get; set; }
		public Int16 Status { get; set; }
		public string ReserveNo { get; set; }
		public string ReserveLine { get; set; }
		public string GW { get; set; }
		public string PLNFL { get; set; }
		public string VORNR { get; set; }
		public string AUFPL { get; set; }
		public Int16 SAPStatus { get; set; }
        public Int32 SAPErrorCount { get; set; }
        
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
            OrderBomDetOnLine another = obj as OrderBomDetOnLine;

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
