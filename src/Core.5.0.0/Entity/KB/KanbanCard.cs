using System;
using System.ComponentModel.DataAnnotations;
using System.Collections.Generic;
using com.Sconit.Entity.MD;
using com.Sconit.Entity.SYS;

namespace com.Sconit.Entity.KB
{
    public partial class KanbanCard
    {
        #region Non O/R Mapping Properties
        // ������: ��������, ����(ɾ��)����
        // ɨ����: ��ɨ�裬����ɨ��
        // ��ת���: 
        // ��������
        public CodeMaster.KBProcessCode Ret { get; set; }
        [Display(Name = "Msg", ResourceType = typeof(Resources.KB.KanbanCard))]
        public string Msg { get; set; }

        [Display(Name = "OpTime", ResourceType = typeof(Resources.KB.KanbanCard))]
        public DateTime OpTime { get; set; }

        [Display(Name = "KanbanNum", ResourceType = typeof(Resources.KB.KanbanCard))]
        public Int32 KanbanNum { get; set; }

        //[Display(Name = "KanbanDeltaNum", ResourceType = typeof(Resources.KB.KanbanCard))]
        public Int32 KanbanDeltaNum { get; set; }

        public Decimal CalcKanbanNum { get; set; }

        public DateTime CalcConsumeDate { get; set; }

        public Decimal CalcConsumeQty { get; set; }

        public string BatchNo { get; set; }
        //ʹ��qty,container,locbin�ֶ�
        //[Display(Name = "KanbanCard_UnitCount", ResourceType = typeof(Resources.KB.KanbanCard))]
        //public decimal? UnitCount { get; set; }
        //[Display(Name = "KanbanCard_UnitCountDescription", ResourceType = typeof(Resources.KB.KanbanCard))]
        //public string UnitCountDescription { get; set; }

        //[Display(Name = "KanbanCard_Bin", ResourceType = typeof(Resources.KB.KanbanCard))]
        //public string Bin { get; set; }

        public IList<ItemKit> ItemKitList { get; set; }

        public Boolean IsFreeze { get; set; }

        public string CheckedCardNo { get; set; }

        [Export(ExportName = "ExportKanbanCard", ExportSeq = 8)]
        [CodeDetailDescriptionAttribute(CodeMaster = com.Sconit.CodeMaster.CodeMaster.KBCalculation, ValueField = "KBCalc")]
        [Display(Name = "KanbanCard_KBCalc", ResourceType = typeof(Resources.KB.KanbanCard))]
        public string KBCalcDescription { get; set; }

        /// <summary>
        /// ����
        /// </summary>
        [Export(ExportName = "ExportKanbanCard", ExportSeq = 30)]
        [Display(Name = "KanbanCard_Type", ResourceType = typeof(Resources.KB.KanbanCard))]
        public string Type
        {
            get { return this.Sequence != null ? this.Sequence.Substring(0, 1) : string.Empty; }
        }

        /// <summary>
        /// ���
        /// </summary>
        [Export(ExportName = "ExportKanbanCard", ExportSeq = 40)]
        [Display(Name = "KanbanCard_SequenceNo", ResourceType = typeof(Resources.KB.KanbanCard))]
        public string SequenceNo
        {
            get
            {
                return this.Sequence != null ? this.Sequence.Substring(1) : string.Empty;
            }
        }

        public DateTime? ScanDate { get; set; }

        public int? ScanCount { get; set; }

        public List<RowCellK> RowCellList { get; set; }

        public string Container1 { get; set; }
        public string ContainerDescription { get; set; }
        #endregion
    }

    public class RowCellK
    {
        public int ScanCount { get; set; }
    }
}