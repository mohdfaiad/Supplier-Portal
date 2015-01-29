using System;
using System.ComponentModel.DataAnnotations;
//TODO: Add other using statements here

namespace com.Sconit.Entity.INP
{
    public partial class InspectDetail
    {
        #region Non O/R Mapping Properties

        //TODO: Add Non O/R Mapping Properties here. 
        [Display(Name = "InspectDetail_CurrentQualifyQty", ResourceType = typeof(Resources.INP.InspectDetail))]
        public decimal CurrentQualifyQty { get; set; }
        [Display(Name = "InspectDetail_CurrentRejectQty", ResourceType = typeof(Resources.INP.InspectDetail))]
        public decimal CurrentRejectQty { get; set; }
        [Display(Name = "InspectDetail_CurrentReturnQty", ResourceType = typeof(Resources.INP.InspectDetail))]
        public decimal CurrentReturnQty { get; set; }
        /// <summary>
        /// �ò�ʹ����
        /// </summary>
        public decimal CurrentConcessionQty { get; set; }
        /// <summary>
        /// �ж�ʧЧģʽ
        /// </summary>
        [Display(Name = "InspectDetail_JudgeFailCode", ResourceType = typeof(Resources.INP.InspectDetail))]
        public string JudgeFailCode { get; set; }
        [Display(Name = "InspectDetail_Defect", ResourceType = typeof(Resources.INP.InspectDetail))]
        public string Defect { get; set; }
        [Display(Name = "InspectDetail_InspectQty", ResourceType = typeof(Resources.INP.InspectDetail))]
        public decimal CurrentInspectQty
        {
            get
            {
                decimal currentInspectQty = this.InspectQty - this.QualifyQty - this.RejectQty;
                return currentInspectQty > 0 ? currentInspectQty : 0;
            }
        }
        [Display(Name = "InspectResult_JudgeResult", ResourceType = typeof(Resources.INP.InspectResult))]
        public com.Sconit.CodeMaster.JudgeResult JudgeResult { get; set; }
        [Display(Name = "InspectDetail_HandledQty", ResourceType = typeof(Resources.INP.InspectDetail))]
        public decimal HandledQty { get; set; }

        public string WMSResNo { get; set; }
        public string WMSResSeq { get; set; }
        public Boolean IsConsignment { get; set; }
        public Int32? PlanBill { get; set; }
        [Display(Name = "InspectResult_Note", ResourceType = typeof(Resources.INP.InspectResult))]
        public string CurrentInspectResultNote { get; set; }

        //PPM���ʹ��
        [Display(Name = "InspectDetail_IpNo", ResourceType = typeof(Resources.INP.InspectDetail))]
        public string IpNo { get; set; }
        [Display(Name = "InspectDetail_ManufacturePartyName", ResourceType = typeof(Resources.INP.InspectDetail))]
        public string ManufacturePartyName { get; set; }

        [Display(Name = "InspectMaster_Status", ResourceType = typeof(Resources.INP.InspectMaster))]
        public string InspectStatusDescription { get; set; }

        public decimal CurrentTransferQty
        {
            get
            {
                decimal currentTransferQty = this.InspectQty - this.QualifyQty - this.RejectQty;
                return currentTransferQty > 0 ? currentTransferQty : 0;
            }
        }

        public decimal CurrentQty
        {
            get
            {
                return CurrentQualifyQty + CurrentConcessionQty+CurrentReturnQty;
            }
        }
        #endregion
    }
}