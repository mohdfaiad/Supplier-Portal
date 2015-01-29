using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using com.Sconit.Entity.BIL;
using com.Sconit.Entity.MD;
using System;
using com.Sconit.Entity.SYS;
//TODO: Add other using statements here

namespace com.Sconit.Entity.ORD
{
    public partial class OrderDetail
    {
        public IList<OrderTracer> OrderTracerList { get; set; }

        #region Non O/R Mapping Properties
        public decimal ShipQtyInput
        {
            get
            {
                if (OrderDetailInputs != null
                    && OrderDetailInputs.Count > 0)
                {
                    return OrderDetailInputs.Sum(i => i.ShipQty);
                }
                return 0;
            }
        }

        public decimal ReceiveQtyInput
        {
            get
            {
                if (OrderDetailInputs != null
                    && OrderDetailInputs.Count > 0)
                {
                    return OrderDetailInputs.Sum(i => i.ReceiveQty);
                }
                return 0;
            }
        }

        public decimal PickQtyInput
        {
            get
            {
                if (OrderDetailInputs != null
                    && OrderDetailInputs.Count > 0)
                {
                    return OrderDetailInputs.Sum(i => i.PickQty);
                }
                return 0;
            }
        }

        //public decimal ReceiveQualifiedQtyInput
        //{
        //    get
        //    {
        //        if (OrderDetailInputs != null
        //            && OrderDetailInputs.Count > 0)
        //        {
        //            return OrderDetailInputs.Where(i => i.QualityType == com.Sconit.CodeMaster.QualityType.Qualified).Sum(i => i.ReceiveQty);
        //        }
        //        return 0;
        //    }
        //}

        //public decimal ReceiveRejectQtyInput
        //{
        //    get
        //    {
        //        if (OrderDetailInputs != null
        //            && OrderDetailInputs.Count > 0)
        //        {
        //            return OrderDetailInputs.Where(i => i.QualityType == com.Sconit.CodeMaster.QualityType.Reject).Sum(i => i.ReceiveQty);
        //        }
        //        return 0;
        //    }
        //}

        //public decimal ReceiveInspectQtyInput
        //{
        //    get
        //    {
        //        if (OrderDetailInputs != null
        //            && OrderDetailInputs.Count > 0)
        //        {
        //            return OrderDetailInputs.Where(i => i.QualityType == com.Sconit.CodeMaster.QualityType.Inspect).Sum(i => i.ReceiveQty);
        //        }
        //        return 0;
        //    }
        //}

        public decimal ScrapQtyInput
        {
            get
            {
                if (OrderDetailInputs != null
                    && OrderDetailInputs.Count > 0)
                {
                    return OrderDetailInputs.Sum(i => i.ScrapQty);
                }
                return 0;
            }
        }

        [Export(ExportName = "ExportShipDetail", ExportSeq = 1)]
        [Display(Name = "OrderDetail_CurrentShipQty", ResourceType = typeof(Resources.ORD.OrderDetail))]
        public decimal CurrentShipQty { get; set; }

        [Display(Name = "OrderDetail_CurrentReceiveQty", ResourceType = typeof(Resources.ORD.OrderDetail))]
        public decimal CurrentReceiveQty
        {
            get
            {
                return this.OrderedQty > this.ReceivedQty ? this.OrderedQty - this.ReceivedQty : 0;
            }
        }

        [Display(Name = "OrderDetail_CurrentScrapQty", ResourceType = typeof(Resources.ORD.OrderDetail))]
        public decimal CurrentScrapQty { get; set; }

        [Display(Name = "OrderDetail_CurrentPickQty", ResourceType = typeof(Resources.ORD.OrderDetail))]
        public decimal CurrentPickQty { get; set; }

        public IList<OrderBomDetail> OrderBomDetails { get; set; }
        public IList<OrderOperation> OrderOperations { get; set; }
        //public IList<OrderDetailTrace> OrderDetailTraces { get; set; }
        public IList<OrderDetailInput> OrderDetailInputs { get; set; }
        public Item CurrentItem { get; set; }
        #endregion

        #region �����ֶ�
        public OrderMaster CurrentOrderMaster { get; set; }
        public decimal RemainShippedQty
        {
            get
            {
                decimal remainShippedQty = this.OrderedQty > 0 ?
                    (this.OrderedQty > this.ShippedQty ? this.OrderedQty - this.ShippedQty : 0)
                    : (this.OrderedQty < this.ShippedQty ? this.OrderedQty - this.ShippedQty : 0);
                return remainShippedQty;
            }
        }

        public decimal RemainReceivedQty
        {
            get
            {
                decimal remainReceivedQty = this.OrderedQty > 0 ?
                    (this.OrderedQty > this.ReceivedQty ? this.OrderedQty - this.ReceivedQty : 0)
                    : (this.OrderedQty < this.ReceivedQty ? this.OrderedQty - this.ReceivedQty : 0);
                return remainReceivedQty;
            }
        }

        public PriceListMaster CurrentPriceListMaster { get; set; }

        public BindDemand BindDemand { get; set; }

         [Display(Name = "OrderDetail_LocationQty", ResourceType = typeof(Resources.ORD.OrderDetail))]
        public decimal LocationQty { get; set; }
        /// <summary>
        /// ȡMaster ����Ĵ���ʱ��
        /// </summary>
         [Display(Name = "OrderMaster_WindowTime", ResourceType = typeof(Resources.ORD.OrderMaster))]
        public DateTime? WindowTime { get; set; }


        [Display(Name = "OrderMaster_PartyFromName", ResourceType = typeof(Resources.ORD.OrderMaster))]
        public string PartyFromName { get; set; }


        [Display(Name = "OrderMaster_PartyToName", ResourceType = typeof(Resources.ORD.OrderMaster))]
        public string PartyToName { get; set; }

        [Display(Name = "OrderDetail_CurrentPickListQty", ResourceType = typeof(Resources.ORD.OrderDetail))]
        public decimal CurrentPickListQty
        {
            get
            {
                return this.OrderedQty - this.ShippedQty - this.PickedQty;
            }
        }

        [Display(Name = "OrderDetail_HuQty", ResourceType = typeof(Resources.ORD.OrderDetail))]
        public decimal HuQty { get; set; }

        [Display(Name = "OrderDetail_LotNo", ResourceType = typeof(Resources.ORD.OrderDetail))]
        public string LotNo { get; set; }

        public int FreezeDays { get; set; }

        public string ScheduleLineSeq
        {
            get
            {
                string scheduleLineSeq = string.Empty;
                if (!string.IsNullOrEmpty(this.ExternalSequence))
                {
                    string[] scheduleLineSeqArray = this.ExternalSequence.Split('-');
                    scheduleLineSeq = scheduleLineSeqArray[0];
                }
                return scheduleLineSeq;
            }
        }

        [Display(Name = "OrderDetail_SupplierLotNo", ResourceType = typeof(Resources.ORD.OrderDetail))]
        public String SupplierLotNo { get; set; }
        //public String EBELN { get; set; }   //�ƻ�Э���
        //public String EBELP { get; set; }   //�ƻ�Э���к�

        [Export(ExportName = "ExportSeqDet", ExportSeq = 20)]
        [Display(Name = "OrderDetail_Flow", ResourceType = typeof(Resources.ORD.OrderDetail))]
        public string Flow { get; set; }

        [Export(ExportName = "ExportSeqDet", ExportSeq = 30)]
        [Display(Name = "OrderMaster_FlowDescription", ResourceType = typeof(Resources.ORD.OrderMaster))]
        public string FlowDescription { get; set; }

        [Export(ExportName = "ExportSeqDet", ExportSeq = 40)]
        [Display(Name = "OrderMaster_SequenceGroup", ResourceType = typeof(Resources.ORD.OrderMaster))]
        public string SequenceGroup { get; set; }

        [Export(ExportName = "ExportSeqDet", ExportSeq = 50)]
        [Display(Name = "OrderMaster_TraceCode_Export", ResourceType = typeof(Resources.ORD.OrderMaster))]
        public string TraceCode { get; set; }

       // [Display(Name = "OrderDetail_Flow", ResourceType = typeof(Resources.ORD.OrderDetail))]
        /// <summary>
        /// ������ȡ������Ψһ��ʶ
        /// </summary>
        public string WmsFileID { get; set; }

        [Display(Name = "OrderDetail_OpRef", ResourceType = typeof(Resources.ORD.OrderDetail))]
        public string OpRef { get; set; }

        [Display(Name = "OrderDetail_CPTime", ResourceType = typeof(Resources.ORD.OrderDetail))]
        public DateTime? CPTime { get; set; }

        [Display(Name = "OrderDetail_IsCreateSeq", ResourceType = typeof(Resources.ORD.OrderDetail))]
        public Boolean IsCreateSeq { get; set; }

        [Export(ExportName = "ExportPreviewXLS", ExportSeq = 110)]
        [Display(Name = "OrderDetail_ZENGINE", ResourceType = typeof(Resources.ORD.OrderDetail))]
        public string ZENGINE { get; set; }

        public string ProdNo { get; set; }
        public string ProdLine { get; set; }
        public string ProdLineDescription { get; set; }
        public DateTime? CompleteDate { get; set; }
        public string RefOrderNo { get; set; }
        

        
        #endregion

        #region methods
        public void AddOrderBomDetail(OrderBomDetail orderBomDetail)
        {
            if (OrderBomDetails == null)
            {
                OrderBomDetails = new List<OrderBomDetail>();
            }
            OrderBomDetails.Add(orderBomDetail);
        }

        public void AddOrderDetailInput(OrderDetailInput orderDetailInput)
        {
            if (OrderDetailInputs == null)
            {
                OrderDetailInputs = new List<OrderDetailInput>();
            }
            OrderDetailInputs.Add(orderDetailInput);
        }
        //public void AddOrderOperation(OrderOperation orderOperation)
        //{
        //    if (OrderOperations == null)
        //    {
        //        OrderOperations = new List<OrderOperation>();
        //    }
        //    OrderOperations.Add(orderOperation);
        //}        
        #endregion

        #region ��ѯ������ʾ�� �����ֶ�
        //[Export(ExportName = "ExportSeqDet", ExportSeq = 85)]
        //[Display(Name = "OrderMaster_StartDate_Export", ResourceType = typeof(Resources.ORD.OrderMaster))]
        //public string StartDateFormat { get { return this.StartDate.HasValue ? StartDate.Value.ToString("yyyy-MM-dd HH:mm:dd") : ""; } }

        [Export(ExportName = "ExportPreviewXLS", ExportSeq = 90)]
        [Export(ExportName = "ExportSeqDet", ExportSeq = 85)]
        [Display(Name = "OrderMaster_StartDate_Export", ResourceType = typeof(Resources.ORD.OrderMaster))]
        public string StartDateFormat { get; set; }

        [Display(Name = "OrderMaster_ReferenceOrderNo", ResourceType = typeof(Resources.ORD.OrderMaster))]
        public string MastRefOrderNo { get; set; }

        [Display(Name = "OrderMaster_ExternalOrderNo", ResourceType = typeof(Resources.ORD.OrderMaster))]
        public string MastExtOrderNo { get; set; }

        [Export(ExportName = "ExportDetailRec", ExportSeq = 50)]
        [Export(ExportName = "ProcurementDetailXls", ExportSeq = 160)]//Ҫ����ϸ
        [Export(ExportName = "ExportShipDetail", ExportSeq = 150)]
        [Display(Name = "OrderMaster_PartyFrom", ResourceType = typeof(Resources.ORD.OrderMaster))]
        public string MastPartyFrom { get; set; }

        [Export(ExportName = "ExportSupplierDetXLS", ExportSeq = 100)]
        [Export(ExportName = "ProcurementDetailXls", ExportSeq = 170)]//Ҫ����ϸ
        [Export(ExportName = "ExportShipDetail", ExportSeq = 160)]
        [Display(Name = "OrderMaster_PartyTo", ResourceType = typeof(Resources.ORD.OrderMaster))]
        public string MastPartyTo { get; set; }

        [Export(ExportName = "ExportSupplierDetXLS", ExportSeq = 90)]
        [Export(ExportName = "ProcurementDetailXls", ExportSeq = 180)]//Ҫ����ϸ
        [Export(ExportName = "ExportShipDetail", ExportSeq = 170)]
        [Display(Name = "OrderMaster_Flow", ResourceType = typeof(Resources.ORD.OrderMaster))]
        public string MastFlow { get; set; }

        [Export(ExportName = "ExportDetailRec", ExportSeq = 140)]
        [Export(ExportName = "ProcurementDetailXls", ExportSeq = 190)]//Ҫ����ϸ
        [Export(ExportName = "ExportShipDetail", ExportSeq = 180)]
        [Display(Name = "OrderMaster_Type", ResourceType = typeof(Resources.ORD.OrderMaster))]
        public string MastType { get; set; }

        [Export(ExportName = "ExportDetailRec", ExportSeq = 150)]
        [Export(ExportName = "ProcurementDetailXls", ExportSeq = 200)]//Ҫ����ϸ
        [Export(ExportName = "ExportShipDetail", ExportSeq = 190)]
        [Display(Name = "OrderMaster_Status", ResourceType = typeof(Resources.ORD.OrderMaster))]
        public string MastStatus { get; set; }
        [Export(ExportName = "ExportDetailRec", ExportSeq = 170)]
        [Export(ExportName = "ExportSupplierDetXLS", ExportSeq = 160)]
        [Export(ExportName = "ProcurementDetailXls", ExportSeq = 230)]//Ҫ����ϸ
        [Export(ExportName = "ExportShipDetail", ExportSeq = 220)]
        [Display(Name = "OrderMaster_CreateDate", ResourceType = typeof(Resources.ORD.OrderMaster))]
        public DateTime MastCreateDate { get; set; }

        [Export(ExportName = "ExportDetailRec", ExportSeq = 180)]
        [Export(ExportName = "ExportSupplierDetXLS", ExportSeq = 80)]
        [Export(ExportName = "ProcurementDetailXls", ExportSeq = 240)]//Ҫ����ϸ
        [Export(ExportName = "ExportShipDetail", ExportSeq = 230)]
        [Display(Name = "OrderMaster_WindowTime", ResourceType = typeof(Resources.ORD.OrderMaster))]
        public DateTime MastWindowTime { get; set; }

        [Export(ExportName = "ExportDetailRec", ExportSeq = 80)]
        [Export(ExportName = "ExportSupplierDetXLS", ExportSeq = 120)]
        [Export(ExportName = "ProcurementDetailXls", ExportSeq = 120)]//Ҫ����ϸ
        [Export(ExportName = "ExportShipDetail", ExportSeq = 110)]
        [Display(Name = "Location_SAPLocation", ResourceType = typeof(Resources.MD.Location))]
        public string SAPLocation { get; set; }

        [Export(ExportName = "ExportDetailRec", ExportSeq = 160)]
        [Export(ExportName = "ProcurementDetailXls", ExportSeq = 220)]//Ҫ����ϸ
        [Export(ExportName = "ExportShipDetail", ExportSeq = 210)]
        [Display(Name = "OrderMaster_OrderStrategy", ResourceType = typeof(Resources.ORD.OrderMaster))]
        public string OrderStrategyDescription { get; set; }
        public bool IsChangeDetail { get; set; }

        [Display(Name = "OrderDetail_Item", ResourceType = typeof(Resources.ORD.OrderDetail))]
        public string ItemCode { get; set; }

        [Export(ExportName = "ProcurementDetailXls", ExportSeq = 195)]//Ҫ����ϸ
        [Display(Name = "OrderMaster_Priority", ResourceType = typeof(Resources.ORD.OrderMaster))]
        public string OrderPriorityDescription { get; set; }

        [Display(Name = "OrderDetail_InventoryQty", ResourceType = typeof(Resources.ORD.OrderDetail))]
        public decimal InventoryQty { get; set; }


        [Display(Name = "PickRule_Picker", ResourceType = typeof(@Resources.MD.Picker))]
        public string Picker { get; set; }
        [Display(Name = "PickRule_Picker", ResourceType = typeof(@Resources.MD.Picker))]
        public string PickerDesc { get; set; }


        public decimal OccupyQty { get; set; }

        public decimal AllowRecQty { get; set; }

        [Export(ExportName = "ProcurementDetailXls", ExportSeq = 245)]//Ҫ����ϸ
        [Display(Name = "OrderMaster_Shift_CreateOrderCode", ResourceType = typeof(Resources.ORD.OrderMaster))]
        public string CreateOrderCode { get; set; }

        [Export(ExportName = "ProcurementDetailXls", ExportSeq = 241)]//Ҫ����ϸ
        [Display(Name = "OrderMaster_CloseDate", ResourceType = typeof(Resources.ORD.OrderMaster))]
        public DateTime? MasterCloseDate { get; set; }

        [Export(ExportName = "ExportDetailRec", ExportSeq = 130)]
        [Display(Name = "OrderDetail_CurrentRecQty", ResourceType = typeof(Resources.ORD.OrderDetail))]
        public decimal? CurrentRecQty { get; set; }

        [Export(ExportName = "ExportDetailRec", ExportSeq = 190)]
        [Display(Name = "OrderDetail_ReceiveDate", ResourceType = typeof(Resources.ORD.OrderDetail))]
        public DateTime? ReceiveDate { get; set; }

        //[Display(Name = "OrderDetail_ReceiveDate", ResourceType = typeof(Resources.ORD.OrderDetail))]
        //[Export(ExportName = "ExportDetailRec", ExportSeq = 1200)]
        public DateTime? IpCreateDate { get; set; }

        [Export(ExportName = "ExportDetailRec", ExportSeq = 200)]
        [Display(Name = "OrderMaster_IpCreateDate", ResourceType = typeof(Resources.ORD.OrderDetail))]
        public string IpCreateDateFormat { get { return this.IpCreateDate != null ? this.IpCreateDate.Value.ToString() : (IsPrintOrder.HasValue && IsPrintOrder.Value ? "�Ѵ�ӡ" : string.Empty); } }


        [Export(ExportName = "ProcurementDetailXls", ExportSeq = 260)]//Ҫ����ϸ
        [Display(Name = "OrderMaster_ShipToContact", ResourceType = typeof(Resources.ORD.OrderMaster))]
        public string MasterMark { get; set; }

        public bool? IsPrintOrder { get; set; }


        #endregion
    }

    public class OrderDetailInput
    {
        [Display(Name = "OrderDetail_CurrentShipQty", ResourceType = typeof(Resources.ORD.OrderDetail))]
        public decimal ShipQty { get; set; }

        [Display(Name = "OrderDetail_CurrentReceiveQty", ResourceType = typeof(Resources.ORD.OrderDetail))]
        public decimal ReceiveQty { get; set; }

        public decimal ScrapQty { get; set; }

        public decimal PickQty { get; set; }

        public decimal HuQty { get; set; }

        //�������ջ���
        public com.Sconit.CodeMaster.QualityType QualityType { get; set; }
        //public decimal RejectQty { get; set; }

        public string HuId { get; set; }

        public string LotNo { get; set; }

        //�ջ�ʱָ����Van�ţ��س�����Ʒʱ��ֻ�س�ָ��Van�ŵ�����Ʒ
        public string TraceCode { get; set; }

        public ReceiptDetail ReceiptDetail { get; set; }

        public string Bin { get; set; }

        public string WMSIpNo { get; set; }

        public string WMSIpSeq { get; set; }

        public bool IsConsignment { get; set; }
        public string ConsignmentParty { get; set; }

        public com.Sconit.CodeMaster.OccupyType OccupyType { get; set; }

        public string OccupyReferenceNo { get; set; }

        public string MoveType { get; set; }//��¼�������datʱ���ƶ�����

    }

    public class ScheduleLineInput
    {
        public string EBELN { get; set; }
        public string EBELP { get; set; }
        public decimal ShipQty { get; set; }
        public decimal SureShipQty { get; set; }
    }
}