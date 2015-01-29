using System;
using System.ComponentModel.DataAnnotations;

namespace com.Sconit.Entity.ORD
{
    [Serializable]
    public partial class IpDetailConfirm : EntityBase
    {
        #region O/R Mapping Properties
		
		public Int32 Id { get; set; }
		public string OrderNo { get; set; }
		public CodeMaster.OrderType OrderType { get; set; }
        public CodeMaster.OrderSubType OrderSubType { get; set; }
		public Int32? OrderDetailId { get; set; }
		public Int32? OrderDetailSequence { get; set; }
		public string IpNo { get; set; }
		public Int32? IpDetailId { get; set; }
		public Int32? IpDetailSequence { get; set; }
		public string Item { get; set; }
		public string ItemDescription { get; set; }
		public string Uom { get; set; }
		public string BaseUom { get; set; }
		public Decimal UnitQty { get; set; }
		public Decimal Qty { get; set; }
		public string PartyFrom { get; set; }
		public string PartyTo { get; set; }
		public string LocationFrom { get; set; }
		public string LocationTo { get; set; }
        public Boolean IsCancel { get; set; }
        public Boolean IsCreateDN { get; set; }
        public string MoveType { get; set; }
        public string EBELN { get; set; }
        public string EBELP { get; set; }
		public DateTime EffectiveDate { get; set; }
		public string CreateUser { get; set; }
		public DateTime CreateDate { get; set; }
        public string ShipPlant { get; set; }
        public string ShipLocation { get; set; }

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
            IpDetailConfirm another = obj as IpDetailConfirm;

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
