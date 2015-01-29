using System;
using System.ComponentModel.DataAnnotations;
using com.Sconit.Entity.SYS;

//TODO: Add other using statements here

namespace com.Sconit.Entity.LOG
{
    public partial class OpRefBalanceChange
    {
        [Export(ExportName = "ExportChangeXLS", ExportSeq = 30)]
        [Display(Name = "OpReferenceBalance_ItemDescription", ResourceType = typeof(Resources.SCM.OpReferenceBalance))]
        public string ItemDescription { get; set; }

        [Export(ExportName = "ExportChangeXLS", ExportSeq = 40)]
        [Display(Name = "OpReferenceBalance_ReferenceItemCode", ResourceType = typeof(Resources.SCM.OpReferenceBalance))]
        public string ReferenceItemCode { get; set; }


        [Export(ExportName = "ExportChangeXLS", ExportSeq = 100)]
        [Display(Name = "OpReferenceBalance_StatusDesc", ResourceType = typeof(Resources.SCM.OpReferenceBalance))]
        public string StatusDesc { get { return this.Status == 0 ? "ÐÂÔö" : "ÐÞ¸Ä"; } }
       
    }
}
