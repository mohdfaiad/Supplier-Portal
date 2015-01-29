using System;
using System.ComponentModel.DataAnnotations;
using com.Sconit.Entity.SYS;

//TODO: Add other using statements here

namespace com.Sconit.Entity.SCM
{
    public partial class OpReferenceBalance
    {
        [Export(ExportName = "ExporOpReferenceBalancetMap", ExportSeq = 30)]
        [Export(ExportName = "ExporOpReferenceBalancetList", ExportSeq = 30)]
        [Display(Name = "OpReferenceBalance_ItemDescription", ResourceType = typeof(Resources.SCM.OpReferenceBalance))]
        public string ItemDescription { get; set; }
        [Export(ExportName = "ExporOpReferenceBalancetMap", ExportSeq = 20)]
        [Export(ExportName = "ExporOpReferenceBalancetList", ExportSeq = 20)]
        [Display(Name = "OpReferenceBalance_ReferenceItemCode", ResourceType = typeof(Resources.SCM.OpReferenceBalance))]
        public string ReferenceItemCode { get; set; }

        public decimal CurrentAdjustQty { get; set; }

        [Export(ExportName = "ExporOpReferenceBalancetMap", ExportSeq = 40)]
        [Display(Name = "OpReferenceBalance_IsOpRefMap", ResourceType = typeof(Resources.SCM.OpReferenceBalance))]
        public bool IsOpRefMap { get; set; }

        [Export(ExportName = "ExporOpReferenceBalancetMap", ExportSeq = 70)]
        [Display(Name = "OpReferenceBalance_StockQty", ResourceType = typeof(Resources.SCM.OpReferenceBalance))]
        public decimal StockQty { get; set; }
        
       
    }
}