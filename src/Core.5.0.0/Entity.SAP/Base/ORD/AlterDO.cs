using System;
using System.Xml.Serialization;

namespace com.Sconit.Entity.SAP.ORD
{
    [Serializable]
    public partial class AlterDO : SAPEntityBase, ITraceable
    {
        #region O/R Mapping Properties

        [XmlIgnore]
        public Int32 Id { get; set; }
        /// <summary>
        /// LIKP-VBELN ��������
        /// </summary>
        public string OrderNo { get; set; }
        /// <summary>
        /// LIPS-POSNR ����Ŀ��
        /// </summary>
        public Int32 Sequence { get; set; }
        /// <summary>
        /// LIPS-MATNR ���Ϻ�
        /// </summary>
        public string Item { get; set; }
        /// <summary>
        /// LIPS-WERKS ����
        /// </summary>
        public string Plant { get; set; }
        /// <summary>
        /// LIPS-LGORT ���ص�
        /// </summary>
        public string Location { get; set; }
        /// <summary>
        /// LIPS-LFIMG �ƻ�����
        /// </summary>
        public Decimal Qty { get; set; }
        /// <summary>
        /// LIPS-VRKME ��λ
        /// </summary>
        public string Uom { get; set; }
        /// <summary>
        ///�۴﷽���� KUNAG
        /// </summary>
        public string KUNAG { get; set; }
        /// <summary>
        /// �ʹ﷽���� KUNNR
        /// </summary>
        public string KUNNR { get; set; }
        /// <summary>
        /// �����ʶ ZDEL
        /// </summary>
        public string Action { get; set; }
        /// <summary>
        /// �ƻ�����ʱ��
        /// </summary>
        public DateTime WindowTime { get; set; }
        /// <summary>
        /// �ɹ���������
        /// </summary>
        public string ExternalOrderNo { get; set; }

        [XmlIgnore]
        public StatusEnum Status { get; set; }
        [XmlIgnore]
        public DateTime CreateDate { get; set; }
        [XmlIgnore]
        public DateTime LastModifyDate { get; set; }
        [XmlIgnore]
        public Int32 ErrorCount { get; set; }

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
            AlterDO another = obj as AlterDO;

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
