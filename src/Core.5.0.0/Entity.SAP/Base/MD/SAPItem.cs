using System;
using System.Xml.Serialization;

namespace com.Sconit.Entity.SAP.MD
{
    [Serializable]
    public partial class SAPItem : SAPEntityBase
    {
        #region O/R Mapping Properties
        [XmlIgnore]
        public Int32 Id { get; set; }
        /// <summary>
        /// ���Ϻ�
        /// </summary>
        public string Code { get; set; }
        /// <summary>
        /// ��ͼ��
        /// </summary>
        public string ReferenceCode { get; set; }
        /// <summary>
        /// �̺���
        /// </summary>
        public string ShortCode { get; set; }
        /// <summary>
        /// ����
        /// </summary>
        public string Description { get; set; }
        /// <summary>
        /// ��λ
        /// </summary>
        public string Uom { get; set; }
        /// <summary>
        /// ����
        /// </summary>
        public string Plant { get; set; }
        /// <summary>
        /// MRP������
        /// </summary>
        public string DISPO { get; set; }
        /// <summary>
        /// �ƻ�����ʱ��
        /// </summary>
        public string PLIFZ { get; set; }
        /// <summary>
        /// �ɹ�����
        /// </summary>
        public string BESKZ { get; set; }
        /// <summary>
        /// ����ɹ�����
        /// </summary>
        public string SOBSL { get; set; }
        /// <summary>
        /// �ⲿ������
        /// </summary>
        public string EXTWG { get; set; }
        [XmlIgnore]
        public Int32 BatchNo { get; set; }

        [XmlIgnore]
        public DateTime? CreateDate { get; set; }
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
            SAPItem another = obj as SAPItem;

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