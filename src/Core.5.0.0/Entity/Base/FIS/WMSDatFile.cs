using System;
using System.ComponentModel.DataAnnotations;
using com.Sconit.Entity.SYS;

namespace com.Sconit.Entity.FIS
{
    [Serializable]
    public partial class WMSDatFile : EntityBase
    {
        #region O/R Mapping Properties

        public Int32 Id { get; set; }
        /// <summary>
        /// �ƶ�����
        /// </summary>
        [Export(ExportName = "ExportWMSDatFile", ExportSeq = 130)]
        [Display(Name = "WMSDatFile_MoveType", ResourceType = typeof(Resources.FIS.WMSDatFile))]
        public string MoveType { get; set; }

        /// <summary>
        /// ƾ֤����
        /// </summary>
        public string BLDAT { get; set; }

        /// <summary>
        /// ��������
        /// </summary>
        public string BUDAT { get; set; }
        /// <summary>
        /// Po
        /// </summary>
        public string PO { get; set; }

        /// <summary>
        /// Po�к�
        /// </summary>
        public string POLine { get; set; }

        /// <summary>
        /// DN����
        /// </summary>
        public string VBELN { get; set; }

        /// <summary>
        /// DN����
        /// </summary>
        public string POSNR { get; set; }

        /// <summary>
        /// ���̴���
        /// </summary>
        public string LIFNR { get; set; }

        /// <summary>
        /// ����
        /// </summary>
        public string WERKS { get; set; }

        /// <summary>
        /// ���ص�
        /// </summary>
        [Export(ExportName = "ExportWMSDatFile", ExportSeq = 150)]
        public string LGORT { get; set; }

        /// <summary>
        /// �������־
        /// </summary>
        public string SOBKZ { get; set; }

        /// <summary>
        /// ���Ϻ���
        /// </summary>
        [Export(ExportName = "ExportWMSDatFile", ExportSeq = 10)]
        [Display(Name = "WMSDatFile_Item", ResourceType = typeof(Resources.FIS.WMSDatFile))]
        public string Item { get; set; }

        /// <summary>
        /// ���� 
        /// </summary>
        [Export(ExportName = "ExportWMSDatFile", ExportSeq = 60)]
        [Display(Name = "WMSDatFile_Qty", ResourceType = typeof(Resources.FIS.WMSDatFile))]
        public decimal Qty { get; set; }

        /// <summary>
        /// ��λ
        /// </summary>
         [Export(ExportName = "ExportWMSDatFile", ExportSeq = 40)]
         [Display(Name = "WMSDatFile_Uom", ResourceType = typeof(Resources.FIS.WMSDatFile))]
        public string Uom { get; set; }

        /// <summary>
        /// �ջ��ص�
        /// </summary>
         [Export(ExportName = "ExportWMSDatFile", ExportSeq = 160)]
         [Display(Name = "WMSDatFile_UMLGO", ResourceType = typeof(Resources.FIS.WMSDatFile))]
        public string UMLGO { get; set; }

        /// <summary>
        /// �ƶ�ԭ��
        /// </summary>
        public string GRUND { get; set; }

        /// <summary>
        /// �ɱ�����
        /// </summary>
        public string KOSTL { get; set; }

        /// <summary>
        /// ����֪ͨ  ��Ӧ����������� 
        /// </summary>
        [Export(ExportName="ExportWMSDatFile",ExportSeq=120)]
        [Display(Name = "WMSDatFile_WmsNo", ResourceType = typeof(Resources.FIS.WMSDatFile))]
        public string WmsNo { get; set; }

        /// <summary>
        /// Ԥ������
        /// </summary>
        public string RSNUM { get; set; }

        /// <summary>
        /// Ԥ������
        /// </summary>
        public string RSPOS { get; set; }

        /// <summary>
        /// WMS���� ����Ψһ��ʶ
        /// </summary>
        [Export(ExportName = "ExportWMSDatFile", ExportSeq = 140)]
        [Display(Name = "WMSDatFile_WMSId", ResourceType = typeof(Resources.FIS.WMSDatFile))]
        public string WMSId { get; set; }

        /// <summary>
        /// WMS����  ��Ӧ���ǵ�orderDetail ID
        /// </summary>
        public string WmsLine { get; set; }


        /// <summary>
        /// ��������
        /// </summary>
        public string OLD { get; set; }


        /// <summary>
        /// �������
        /// </summary>
        public string INSMK { get; set; }

        /// <summary>
        ///�ͻ�����
        /// </summary>
        public string XABLN { get; set; }

        /// <summary>
        /// �ڲ�����
        /// </summary>
        public string AUFNR { get; set; }


        /// <summary>
        /// �ջ�����
        /// </summary>
        public string UMMAT { get; set; }


        /// <summary>
        /// �ջ�����
        /// </summary>
        public string UMWRK { get; set; }

        /// <summary>
        /// ��F����
        /// </summary>
        [Display(Name = "WMSDatFile_IsHand", ResourceType = typeof(Resources.FIS.WMSDatFile))]
        public Boolean IsHand { get; set; }


        /// <summary>
        /// ����ʱ��
        /// </summary>
        [Export(ExportName = "ExportWMSDatFile", ExportSeq = 150)]
        [Display(Name = "WMSDatFile_CreateDate", ResourceType = typeof(Resources.FIS.WMSDatFile))]
        public DateTime CreateDate { get; set; }

        public string FileName { get; set; }

        /// <summary>
        /// WBSԪ��
        /// </summary>
        public string WBS { get; set; }

        /// <summary>
        /// HuId
        /// </summary>
        public string HuId { get; set; }


        [Display(Name = "OrderMaster_Version", ResourceType = typeof(Resources.ORD.OrderMaster))]
        public Int32 Version { get; set; }

        /// <summary>
        /// ������
        /// </summary>
        [Export(ExportName = "ExportWMSDatFile", ExportSeq = 70)]
        [Display(Name = "WMSDatFile_ReceiveTotal", ResourceType = typeof(Resources.FIS.WMSDatFile))]
        public decimal ReceiveTotal { get; set; }
        /// <summary>
        /// ������
        /// </summary>
        [Export(ExportName = "ExportWMSDatFile", ExportSeq = 80)]
        [Display(Name = "WMSDatFile_CancelQty", ResourceType = typeof(Resources.FIS.WMSDatFile))]
        public decimal CancelQty { get; set; }
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
            WMSDatFile another = obj as WMSDatFile;

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
