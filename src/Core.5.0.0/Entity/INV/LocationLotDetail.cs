using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using com.Sconit.Entity.BIL;
using com.Sconit.Entity.MD;
using com.Sconit.Entity.VIEW;
using com.Sconit.Entity.SYS;

//TODO: Add other using statements here

namespace com.Sconit.Entity.INV
{
    public partial class LocationLotDetail
    {
        #region Non O/R Mapping Properties
     
        #endregion
        [Display(Name = "LocationLotDetail_ItemDescription", ResourceType = typeof(Resources.INV.LocationLotDetail))]
        public string ItemDescription { get; set; }
        [Display(Name = "LocationLotDetail_ReferenceItemCode", ResourceType = typeof(Resources.INV.LocationLotDetail))]
        public string ReferenceItemCode { get; set; }

    }

    public class InventoryIO
    {
        public string Location { get; set; }
        public string Bin { get; set; }
        public string Item { get; set; }
        public string HuId { get; set; }
        public string LotNo { get; set; }
        //public string ManufactureParty { get; set; }
        public Decimal Qty { get; set; }   //���ǿ�浥λ������
        public Boolean IsCreatePlanBill { get; set; }  //Ϊ�������ǵ�ǰ������PlanBill���Ǵӿ����ȡ�õ�PlanBill��������ʹ��
        public Boolean IsConsignment { get; set; }
        public Int32? PlanBill { get; set; }
        public Int32? ActingBill { get; set; }
        public com.Sconit.CodeMaster.QualityType QualityType { get; set; }
        public bool IsFreeze { get; set; }
        public bool IsATP { get; set; }
        public com.Sconit.CodeMaster.OccupyType OccupyType { get; set; }
        public string OccupyReferenceNo { get; set; }
        public com.Sconit.CodeMaster.TransactionType TransactionType { get; set; }
        public bool IsVoid { get; set; }
        public string ConsignmentSupplier { get; set; }    //ָ����Ӧ�����ϳ���
        public Int32? LocationLotDetailId { get; set; }    //ָ�������ϸID����

        public DateTime EffectiveDate { get; set; }

        public Item CurrentItem { get; set; }
        public Location CurrentLocation { get; set; }
        public PlanBill CurrentPlanBill { get; set; }
        public ActingBill CurrentActingBill { get; set; }
        public BillTransaction CurrentBillTransaction { get; set; }
        public Hu CurrentHu { get; set; }

        public string WMSIpSeq { get; set; }
    }

    public class InventoryTransaction
    {
        public int LocationLotDetailId { get; set; }
        public string Location { get; set; }
        public string Bin { get; set; }
        public string Item { get; set; }
        public string HuId { get; set; }
        public string LotNo { get; set; }
        public decimal Qty { get; set; }
        public Boolean IsCreatePlanBill { get; set; }
        public Boolean IsConsignment { get; set; }
        public Int32? PlanBill { get; set; }
        public decimal PlanBillQty { get; set; }
        public Int32? ActingBill { get; set; }
        public decimal ActingBillQty { get; set; }
        public com.Sconit.CodeMaster.QualityType QualityType { get; set; }
        public bool IsFreeze { get; set; }
        public bool IsATP { get; set; }
        public com.Sconit.CodeMaster.OccupyType OccupyType { get; set; }
        public string OccupyReferenceNo { get; set; }
        public Int32 BillTransactionId { get; set; }
        public Int32 PlanBackflushId { get; set; }

        #region �����ֶ�
        public decimal RemainQty { get; set; }
        public decimal RemainActingBillQty { get; set; }
        public int? Operation { get; set; }
        public string OpReference { get; set; }
        public string OrgLocation { get; set; }  //Ϊ�˼�¼������Ͷ�ϻس�ԭ��λ����
        public string WMSIpSeq { get; set; }  //Ϊ�˼�¼WMS�����к�
        public string WMSRecSeq { get; set; }  //Ϊ�˼�¼WMS�ջ��к�

        public string ReserveNo { get; set; }    //Ԥ����
        public string ReserveLine { get; set; }  //Ԥ���к�
        public string AUFNR { get; set; }        //SAP��������
        public string BWART { get; set; }        //�ƶ�����
        public string ICHARG { get; set; }       //SAP����
        public bool NotReport { get; set; }      //������SAP
        #endregion
    }

    public class InventoryPack
    {
        public string Location { get; set; }
        public string HuId { get; set; }
        public CodeMaster.OccupyType OccupyType { get; set; }
        public string OccupyReferenceNo { get; set; }
        public IList<Int32> LocationLotDetailIdList { get; set; }

        public HuStatus CurrentHu { get; set; }
        public Location CurrentLocation { get; set; }
    }

    public class InventoryUnPack
    {
        public string HuId { get; set; }

        public HuStatus CurrentHu { get; set; }
    }

    public class InventoryRePack
    {
        public CodeMaster.RePackType Type { get; set; }
        public string HuId { get; set; }

        public HuStatus CurrentHu { get; set; }
        public string Location { get; set; }
        public Location CurrentLocation { get; set; }
    }

    public class InventoryPick
    {
        public string HuId { get; set; }
    }

    public class InventoryPut
    {
        public string HuId { get; set; }
        public string Bin { get; set; }

        public HuStatus CurrentHu { get; set; }
        public LocationBin CurrentBin { get; set; }
    }

    public class InventoryOccupy
    {
        public string HuId { get; set; }
        public string Location { get; set; }
        public CodeMaster.QualityType QualityType { get; set; }
        public CodeMaster.OccupyType OccupyType { get; set; }
        public string OccupyReferenceNo { get; set; }
    }

    public class HuHistoryInventory
    {
        public string Location { get; set; }
        public string Item { get; set; }
        public string HuId { get; set; }
        public string LotNo { get; set; }
        public Decimal Qty { get; set; }
        public CodeMaster.QualityType QualityType { get; set; }
    }
    //��������
    public class HistoryInventory
    {
        [Display(Name = "HistoryInventoryView_Location", ResourceType = typeof(Resources.Report.HistoryInventoryView))]
        public string Location { get; set; }
        [Display(Name = "HistoryInventoryView_ItemFrom", ResourceType = typeof(Resources.Report.HistoryInventoryView))]
        public string Item { get; set; }
        [Display(Name = "HistoryInventoryView_Qty", ResourceType = typeof(Resources.Report.HistoryInventoryView))]
        public Decimal Qty { get; set; }
        [Display(Name = "HistoryInventoryView_ConsignmentQty", ResourceType = typeof(Resources.Report.HistoryInventoryView))]
        public Decimal ConsignmentQty { get; set; }
        [Display(Name = "HistoryInventoryView_QualifyQty", ResourceType = typeof(Resources.Report.HistoryInventoryView))]
        public Decimal QualifyQty { get; set; }
        [Display(Name = "HistoryInventoryView_InspectQty", ResourceType = typeof(Resources.Report.HistoryInventoryView))]
        public Decimal InspectQty { get; set; }
        [Display(Name = "HistoryInventoryView_RejectQty", ResourceType = typeof(Resources.Report.HistoryInventoryView))]
        public Decimal RejectQty { get; set; }
        [Display(Name = "HistoryInventoryView_ATPQty", ResourceType = typeof(Resources.Report.HistoryInventoryView))]
        public Decimal ATPQty { get; set; }
        [Display(Name = "HistoryInventoryView_FreezeQty", ResourceType = typeof(Resources.Report.HistoryInventoryView))]
        public Decimal FreezeQty { get; set; }

        [Display(Name = "HistoryInventoryView_LotNo", ResourceType = typeof(Resources.Report.HistoryInventoryView))]
        public string LotNo { get; set; }

        [Display(Name = "HistoryInventoryView_ManufactureParty", ResourceType = typeof(Resources.Report.HistoryInventoryView))]
        public string ManufactureParty { get; set; }
        [Display(Name = "HistoryInventoryView_CsQty", ResourceType = typeof(Resources.Report.HistoryInventoryView))]
        public Decimal CsQty { get; set; }
        public Decimal TobeQualifyQty { get; set; }
        
        public Decimal TobeInspectQty { get; set; }
      
        public Decimal TobeRejectQty { get; set; }
    }
    //��������
    public class InventoryAge
    {
        [Display(Name = "InventoryAge_locationFrom", ResourceType = typeof(Resources.Report.InventoryAge))]
        public string Location { get; set; }
        [Display(Name = "InventoryAge_itemFrom", ResourceType = typeof(Resources.Report.InventoryAge))]
        public string Item { get; set; }
        [Display(Name = "InventoryAge_Range0", ResourceType = typeof(Resources.Report.InventoryAge))]
        public string Range0 { get; set; }
         [Display(Name = "InventoryAge_Range1", ResourceType = typeof(Resources.Report.InventoryAge))]
        public string Range1 { get; set; }
         [Display(Name = "InventoryAge_Range2", ResourceType = typeof(Resources.Report.InventoryAge))]
         public string Range2 { get; set; }
         [Display(Name = "InventoryAge_Range3", ResourceType = typeof(Resources.Report.InventoryAge))]
         public string Range3 { get; set; }
         [Display(Name = "InventoryAge_Range4", ResourceType = typeof(Resources.Report.InventoryAge))]
         public string Range4 { get; set; }
         [Display(Name = "InventoryAge_Range5", ResourceType = typeof(Resources.Report.InventoryAge))]
         public string Range5 { get; set; }
         [Display(Name = "InventoryAge_Range6", ResourceType = typeof(Resources.Report.InventoryAge))]
         public string Range6 { get; set; }
         [Display(Name = "InventoryAge_Range7", ResourceType = typeof(Resources.Report.InventoryAge))]
         public string Range7 { get; set; }
         [Display(Name = "InventoryAge_Range8", ResourceType = typeof(Resources.Report.InventoryAge))]
         public string Range8 { get; set; }
         [Display(Name = "InventoryAge_Range9", ResourceType = typeof(Resources.Report.InventoryAge))]
         public string Range9 { get; set; }
         [Display(Name = "InventoryAge_Range10", ResourceType = typeof(Resources.Report.InventoryAge))]
         public string Range10 { get; set; }
         [Display(Name = "InventoryAge_Range11", ResourceType = typeof(Resources.Report.InventoryAge))]
         public string Range11 { get; set; }
    }
    //���������շ���
    public class Transceivers
    {
        [Export(ExportName="Transceivers",ExportSeq=10)]
       [Display(Name = "Transceivers_itemFrom", ResourceType = typeof(Resources.Report.Transceivers))]
        public string Item { get; set; }
        [Export(ExportName = "Transceivers", ExportSeq = 20)]
        [Display(Name = "Transceivers_locationFrom", ResourceType = typeof(Resources.Report.Transceivers))]
        public string Location { get; set; }
        [Display(Name = "Transceivers_SAPLocation", ResourceType = typeof(Resources.Report.Transceivers))]
        public string SAPLocation { get; set; }
        [Export(ExportName = "Transceivers", ExportSeq = 40)]
        [Display(Name = "Transceivers_InputQty", ResourceType = typeof(Resources.Report.Transceivers))]
        public Decimal InputQty { get; set; }
        [Export(ExportName = "Transceivers", ExportSeq = 50)]
        [Display(Name = "Transceivers_OutputQty", ResourceType = typeof(Resources.Report.Transceivers))]
        public Decimal OutputQty { get; set; }
        [Export(ExportName = "Transceivers", ExportSeq = 60)]
        [Display(Name = "Transceivers_EOPQty", ResourceType = typeof(Resources.Report.Transceivers))]
        public Decimal EOPQty { get; set; }
        [Export(ExportName = "Transceivers", ExportSeq = 30)]
        [Display(Name = "Transceivers_BOPQty", ResourceType = typeof(Resources.Report.Transceivers))]
        public Decimal BOPQty { get; set; }
    }
}