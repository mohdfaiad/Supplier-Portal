using System;
using com.Sconit.Entity.ORD;
using System.ComponentModel.DataAnnotations;
using com.Sconit.Entity.SYS;

//TODO: Add other using statements here

namespace com.Sconit.Entity.SCM
{
    public partial class FlowDetail : IComparable
    {
        #region Non O/R Mapping Properties
        [Display(Name = "FlowDetail_HuQty", ResourceType = typeof(Resources.SCM.FlowDetail))]
        public decimal HuQty { get; set; }
        
        [Display(Name = "FlowDetail_LotNo", ResourceType = typeof(Resources.SCM.FlowDetail))]
        public String LotNo { get; set; }

        [Display(Name = "FlowDetail_SupplierLotNo", ResourceType = typeof(Resources.SCM.FlowDetail))]
        public String SupplierLotNo { get; set; }

        [Export(ExportSeq = 40, ExportName = "ExportListT")]
        [Export(ExportSeq = 40, ExportName = "ExportKanbanScanXLS")]
        [Export(ExportSeq = 100, ExportName = "ExportCheckFlowXLS")]
        [Export(ExportSeq = 25, ExportName = "ExportList")]
        [Display(Name = "FlowDetail_ItemDescription", ResourceType = typeof(Resources.SCM.FlowDetail))]
        public String ItemDescription { get; set; }

        [Export(ExportSeq = 30, ExportName = "ExportCheckFlowXLS")]
        [Export(ExportSeq = 110, ExportName = "ExportList")]
        [Display(Name = "FlowDetail_PartyFrom", ResourceType = typeof(Resources.SCM.FlowDetail))]
        public string PartyFrom { get; set; }

        [Export(ExportSeq = 40, ExportName = "ExportCheckFlowXLS")]
        [Export(ExportSeq = 120, ExportName = "ExportList")]
        [Display(Name = "FlowDetail_PartyTo", ResourceType = typeof(Resources.SCM.FlowDetail))]
        public string PartyTo { get; set; }

        public decimal OrderQty { get; set; }

        public BindDemand BindDemand { get; set; }

        public FlowMaster CurrentFlowMaster { get; set; }

        public FlowStrategy CurrentFlowStrategy { get; set; }

        [Export(ExportSeq = 90, ExportName = "ExportListT")]
        [Export(ExportSeq = 70, ExportName = "ExportCheckFlowXLS")]
        [Export(ExportSeq = 150, ExportName = "ExportList")]
        [Display(Name = "FlowDetail_FlowStrategy", ResourceType = typeof(Resources.SCM.FlowDetail))]
        public string FlowStrategy { get; set; }

        public int ExternalSequence { get; set; }

        [Export(ExportSeq = 1, ExportName = "ExportListT")]
        [Export(ExportSeq = 1, ExportName = "ExportList")]
        [Display(Name = "FlowMaster_Type", ResourceType = typeof(Resources.SCM.FlowMaster))]
        public string Type { get; set; }

        [Display(Name = "FlowDetail_ManufacturePartyShortCode", ResourceType = typeof(Resources.SCM.FlowDetail))]
        public string ManufacturePartyShortCode { get; set; }
        [Display(Name = "FlowDetail_ManufacturePartyDesc", ResourceType = typeof(Resources.SCM.FlowDetail))]
        public string ManufacturePartyDesc { get; set; }
        [Display(Name = "FlowDetail_SapLocation", ResourceType = typeof(Resources.SCM.FlowDetail))]
        public string SapLocation { get; set; }
        [Display(Name = "FlowDetail_AverageRatio", ResourceType = typeof(Resources.SCM.FlowDetail))]
        public string AverageRatio { get;set;}
        public bool IsCreate { get; set; }
        public bool IsUpdate { get; set; }
        public int? FlowMasterStrategy { get; set; }

        [Export(ExportSeq = 145, ExportName = "ExportList")]
        [CodeDetailDescriptionAttribute(CodeMaster = com.Sconit.CodeMaster.CodeMaster.RoundUpOption, ValueField = "RoundUpOption")]
        [Display(Name = "FlowDetail_RoundUpOption", ResourceType = typeof(Resources.SCM.FlowDetail))]
        public string RoundUpOptionDescription { get; set; }

        [Export(ExportSeq = 20, ExportName = "ExportCheckFlowXLS")]
        [Display(Name = "FlowMaster_Description", ResourceType = typeof(Resources.SCM.FlowMaster))]
        public string FlowDescription { get; set; }

        [Export(ExportSeq = 115, ExportName = "ExportCheckFlowXLS")]
        public int ErrorType { get; set; }

        [Export(ExportSeq = 120, ExportName = "ExportCheckFlowXLS")]
        [Display(Name = "FlowDetail_ErrorTypeDesc", ResourceType = typeof(Resources.SCM.FlowDetail))]
        public string ErrorTypeDesc
        {
            get
            {
                switch (this.ErrorType)
                {
                    case 1:
                        return "物料为空";
                    case 2:
                        return "区域不一致";
                    case 3:
                        return "库位不一致";
                    case 4:
                        return "上线包装为0";
                    case 5:
                        return "策略不同";
                    case 6:
                        return "路线不完整";
                    case 7:
                        return "EKB没有安全库存";
                    case 8:
                        return "JIT有安全库存";
                    default:
                        return string.Empty;
                }
            }
        }


        [Export(ExportSeq = 25, ExportName = "ExportKanbanScanXLS")]
        [Display(Name = "KanbanCard_OpRefSequence", ResourceType = typeof(Resources.KB.KanbanCard))]
        public string KanbanNo { get; set; }


        [Export(ExportSeq = 60, ExportName = "ExportListT")]
        [Display(Name = "Item_BESKZ", ResourceType = typeof(Resources.MD.Item))]
        public string BESKZ { get; set; }
        [Export(ExportSeq = 70, ExportName = "ExportListT")]
        [Display(Name = "Item_SOBSL", ResourceType = typeof(Resources.MD.Item))]
        public string SOBSL { get; set; }
        [Export(ExportSeq = 80, ExportName = "ExportListT")]
        [Display(Name = "Item_EXTWG", ResourceType = typeof(Resources.MD.Item))]
        public string EXTWG { get; set; }

        [Export(ExportSeq = 55, ExportName = "ExportListT")]
        [Display(Name = "FlowDetail_SumQty", ResourceType = typeof(Resources.SCM.FlowDetail))]
        public string SumQty { get; set; }
        [Export(ExportSeq = 52, ExportName = "ExportListT")]
        [Display(Name = "FlowDetail_SingleQty", ResourceType = typeof(Resources.SCM.FlowDetail))]
        public string SingleQty { get; set; }

        [Export(ExportSeq = 200, ExportName = "ExportList")]
        [Display(Name = "FlowMaster_IsAsnAutoConfirm", ResourceType = typeof(Resources.SCM.FlowMaster))]
        public Boolean IsAsnAutoConfirm { get; set; }

        [Export(ExportSeq = 230, ExportName = "ExportList")]
        [Display(Name = "FlowMaster_CancelAsnConfirmMoveType", ResourceType = typeof(Resources.SCM.FlowMaster))]
        public string CancelAsnConfirmMoveType { get; set; }

        [Export(ExportSeq = 220, ExportName = "ExportList")]
        [Display(Name = "FlowMaster_AsnConfirmMoveType", ResourceType = typeof(Resources.SCM.FlowMaster))]
        public string AsnConfirmMoveType { get; set; }

        [Export(ExportSeq = 210, ExportName = "ExportList")]
        [Display(Name = "FlowMaster_IsAsnConfirmCreateDN", ResourceType = typeof(Resources.SCM.FlowMaster))]
        public Boolean IsAsnConfirmCreateDN { get; set; }

        [Export(ExportSeq = 190, ExportName = "ExportList")]
        [Display(Name = "FlowMaster_ShipPlant", ResourceType = typeof(Resources.SCM.FlowMaster))]
        public string ShipPlant { get; set; }

        #endregion

        public int CompareTo(object obj)
        {
            FlowDetail another = obj as FlowDetail;

            if (another == null)
            {
                return -1;
            }
            else
            {
                return this.Id.CompareTo(another.Id);
            }
        }
    }
}