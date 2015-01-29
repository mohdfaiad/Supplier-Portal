using System;
using System.ComponentModel.DataAnnotations;
using com.Sconit.Entity.SYS;

namespace com.Sconit.Entity.LOG
{
    [Serializable]
    public partial class OpRefBalanceChange : EntityBase
    {
        #region O/R Mapping Properties
        //Id, Item, OpRef, Qty, Status, Version, CreateDate, CreateUserId, CreateUserNm
		public Int32 Id { get; set; }

        [Export(ExportName = "ExportChangeXLS", ExportSeq = 10)]
        [Display(Name = "OpReferenceBalance_Item", ResourceType = typeof(Resources.SCM.OpReferenceBalance))]
        public string Item { get; set; }
        [Export(ExportName = "ExportChangeXLS", ExportSeq = 20)]
        [Display(Name = "OpReferenceBalance_OpReference", ResourceType = typeof(Resources.SCM.OpReferenceBalance))]
        public string OpReference { get; set; }
        [Export(ExportName = "ExportChangeXLS", ExportSeq = 50)]
        [Display(Name = "OpReferenceBalance_Qty", ResourceType = typeof(Resources.SCM.OpReferenceBalance))]
        public Decimal Qty { get; set; }
		public Int32 CreateUserId { get; set; }
        [Export(ExportName = "ExportChangeXLS", ExportSeq = 70)]
        [Display(Name = "OpReferenceBalance_CreateUserName", ResourceType = typeof(Resources.SCM.OpReferenceBalance))]
        public string CreateUserName { get; set; }
        [Export(ExportName = "ExportChangeXLS", ExportSeq = 60)]
        [Display(Name = "OpReferenceBalance_CreateDate", ResourceType = typeof(Resources.SCM.OpReferenceBalance))]
        public DateTime CreateDate { get; set; }
		
		public Int32? Version { get; set; }

        public Int16 Status { get; set; }
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
            OpRefBalanceChange another = obj as OpRefBalanceChange;

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
