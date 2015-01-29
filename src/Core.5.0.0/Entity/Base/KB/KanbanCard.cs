using System;
using System.ComponentModel.DataAnnotations;
using com.Sconit.Entity.SYS;

namespace com.Sconit.Entity.KB
{
    [Serializable]
    public partial class KanbanCard : EntityBase, IAuditable
    {
        #region O/R Mapping Properties


        [Export(ExportName = "ExportKanbanCard", ExportSeq = 10)]
        [Display(Name = "KanbanCard_CardNo", ResourceType = typeof(Resources.KB.KanbanCard))]
        public string CardNo { get; set; }

        [Display(Name = "KanbanCard_Sequence", ResourceType = typeof(Resources.KB.KanbanCard))]
        public string Sequence { get; set; }

        [Display(Name = "KanbanCard_Flow", ResourceType = typeof(Resources.KB.KanbanCard))]
        public string Flow { get; set; }
        public Int32 FlowDetailId { get; set; }

        [Export(ExportName = "ExportKanbanCard", ExportSeq = 50)]
        [Display(Name = "KanbanCard_Region", ResourceType = typeof(Resources.KB.KanbanCard))]
        public string Region { get; set; }

        [Display(Name = "KanbanCard_RegionName", ResourceType = typeof(Resources.KB.KanbanCard))]
        public string RegionName { get; set; }

        [Export(ExportName = "ExportKanbanCard", ExportSeq = 120, ExportTitle = "KanbanCard_LogisticCenterCode1", ExportTitleResourceType = typeof(Resources.KB.KanbanCard))]
        [Display(Name = "KanbanCard_LogisticCenterCode", ResourceType = typeof(Resources.KB.KanbanCard))]
        public string LogisticCenterCode { get; set; }

        [Export(ExportName = "ExportKanbanCard", ExportSeq = 110)]
        [Display(Name = "KanbanCard_Supplier", ResourceType = typeof(Resources.KB.KanbanCard))]
        public string Supplier { get; set; }

        [Display(Name = "KanbanCard_SupplierName", ResourceType = typeof(Resources.KB.KanbanCard))]
        public string SupplierName { get; set; }

        [Export(ExportName = "ExportKanbanCard", ExportSeq = 20)]
        [Display(Name = "KanbanCard_Item", ResourceType = typeof(Resources.KB.KanbanCard))]
        public string Item { get; set; }

        [Display(Name = "KanbanCard_ItemDescription", ResourceType = typeof(Resources.KB.KanbanCard))]
        public string ItemDescription { get; set; }

        public com.Sconit.CodeMaster.KBStatus Status { get; set; }

        [Display(Name = "KanbanCard_MultiSupplyGroup", ResourceType = typeof(Resources.KB.KanbanCard))]
        public string MultiSupplyGroup { get; set; }

        [Export(ExportName = "ExportKanbanCard", ExportSeq = 160)]
        [Display(Name = "KanbanCard_EffectiveDate", ResourceType = typeof(Resources.KB.KanbanCard))]
        public DateTime EffectiveDate { get; set; }

        [Display(Name = "KanbanCard_FreezeDate", ResourceType = typeof(Resources.KB.KanbanCard))]
        public DateTime FreezeDate { get; set; }

        //[Export(ExportName = "ExportKanbanCard", ExportSeq = 180)]
        [Export(ExportName = "ExportKanbanCard", ExportSeq = 170, ExportTitle = "KanbanCard_LastUseDate1", ExportTitleResourceType = typeof(Resources.KB.KanbanCard))]
        [Display(Name = "KanbanCard_LastUseDate", ResourceType = typeof(Resources.KB.KanbanCard))]
        public DateTime? LastUseDate { get; set; }

        [Display(Name = "KanbanCard_NeedReprint", ResourceType = typeof(Resources.KB.KanbanCard))]
        public Boolean NeedReprint { get; set; }

        [Display(Name = "KanbanCard_PONo", ResourceType = typeof(Resources.KB.KanbanCard))]
        public string PONo { get; set; }

        [Display(Name = "KanbanCard_POLineNo", ResourceType = typeof(Resources.KB.KanbanCard))]
        public string POLineNo { get; set; }

        // uc
        [Export(ExportName = "ExportKanbanCard", ExportSeq = 150)]
        [Display(Name = "KanbanCard_Qty", ResourceType = typeof(Resources.KB.KanbanCard))]
        public Decimal Qty { get; set; }

        // ucdesc
        [Export(ExportName = "ExportKanbanCard", ExportSeq = 140)]
        [Display(Name = "KanbanCard_Container", ResourceType = typeof(Resources.KB.KanbanCard))]
        public string Container { get; set; }

        // location bin
        [Export(ExportName = "ExportKanbanCard", ExportSeq = 70)]
        [Display(Name = "KanbanCard_LocBin", ResourceType = typeof(Resources.KB.KanbanCard))]
        public string LocBin { get; set; }

        // shelf
        [Export(ExportName = "ExportKanbanCard", ExportSeq = 90)]
        [Display(Name = "KanbanCard_Shelf", ResourceType = typeof(Resources.KB.KanbanCard))]
        public string Shelf { get; set; }

        // qitiaobian
        [Export(ExportName = "ExportKanbanCard", ExportSeq = 130)]
        [Display(Name = "KanbanCard_QiTiaoBian", ResourceType = typeof(Resources.KB.KanbanCard))]
        public string QiTiaoBian { get; set; }

        [Display(Name = "KanbanCard_IsKit", ResourceType = typeof(Resources.KB.KanbanCard))]
        public Boolean IsKit { get; set; }

        [Display(Name = "KanbanCard_KBCalc", ResourceType = typeof(Resources.KB.KanbanCard))]
        public CodeMaster.KBCalculation? KBCalc { get; set; }

        [Export(ExportName = "ExportKanbanCard", ExportSeq = 190)]
        [Display(Name = "KanbanCard_TotalCount", ResourceType = typeof(Resources.KB.KanbanCard))]
        public Int32 TotalCount { get; set; }

        [Display(Name = "KanbanCard_KitCount", ResourceType = typeof(Resources.KB.KanbanCard))]
        public Int32 KitCount { get; set; }

        public Int32 Number { get; set; }

        [Export(ExportName = "ExportKanbanCard", ExportSeq = 60)]
        [Display(Name = "KanbanCard_Location", ResourceType = typeof(Resources.KB.KanbanCard))]
        public string Location { get; set; }

        [Export(ExportName = "ExportKanbanCard", ExportSeq = 80)]
        [Display(Name = "KanbanCard_OpRef", ResourceType = typeof(Resources.KB.KanbanCard))]
        public string OpRef { get; set; }

        [Display(Name = "KanbanCard_IsTrace", ResourceType = typeof(Resources.KB.KanbanCard))]
        public Boolean IsTrace { get; set; }

        [Display(Name = "KanbanCard_IsLost", ResourceType = typeof(Resources.KB.KanbanCard))]
        public Boolean IsLost { get; set; }

        //[Display(Name = "KanbanCard_LostCount", ResourceType = typeof(Resources.KB.KanbanCard))]
        public Int32 LostCount { get; set; }

        [Display(Name = "KanbanCard_GroupNo", ResourceType = typeof(Resources.KB.KanbanCard))]
        public string GroupNo { get; set; }

        [Display(Name = "KanbanCard_GroupDesc", ResourceType = typeof(Resources.KB.KanbanCard))]
        public string GroupDesc { get; set; }

        [Display(Name = "KanbanCard_LogisticCenterName", ResourceType = typeof(Resources.KB.KanbanCard))]
        public string LogisticCenterName { get; set; }

        public Int32 CreateUserId { get; set; }
        public string CreateUserName { get; set; }
        public DateTime CreateDate { get; set; }
        public Int32 LastModifyUserId { get; set; }
        public string LastModifyUserName { get; set; }

        [Display(Name = "KanbanCard_LastModifyDate", ResourceType = typeof(Resources.KB.KanbanCard))]
        public DateTime LastModifyDate { get; set; }

        [Display(Name = "KanbanCard_ReferenceItemCode", ResourceType = typeof(Resources.KB.KanbanCard))]
        public string ReferenceItemCode { get; set; }

        [Display(Name = "KanbanCard_MultiStation", ResourceType = typeof(Resources.KB.KanbanCard))]
        public string MultiStation { get; set; }

        [Display(Name = "KanbanCard_ItemType", ResourceType = typeof(Resources.KB.KanbanCard))]
        public string ItemType { get; set; }

        [Display(Name = "KanbanCard_OpRefSequence", ResourceType = typeof(Resources.KB.KanbanCard))]
        public string OpRefSequence { get; set; }

        public int ScanId { get; set; }

        public Int32 Version { get; set; }
        #endregion

        public override int GetHashCode()
        {
            if (CardNo != null)
            {
                return CardNo.GetHashCode();
            }
            else
            {
                return base.GetHashCode();
            }
        }

        public override bool Equals(object obj)
        {
            KanbanCard another = obj as KanbanCard;

            if (another == null)
            {
                return false;
            }
            else
            {
                return (this.CardNo == another.CardNo);
            }
        }
    }

}
