using System;
using System.Security.AccessControl;

namespace com.Sconit.Entity.SAP.TRANS
{
    [Serializable]
    public partial class InvTrans : SAPEntityBase, ITraceable
    {
        #region O/R Mapping Properties
        /// <summary>
        /// TCODE
        /// ȫ������
        /// </summary>
        //[Display(Name = "Hu_HuId", ResourceType = typeof(Resources.INV.Hu))]
        public string TCODE { get; set; }
        /// <summary>
        /// �ƶ�����1
        /// ȫ������
        /// </summary>
        public string BWART { get; set; }
        /// <summary>
        /// ƾ֤����
        /// ȫ������
        /// </summary>
        public string BLDAT { get; set; }
        /// <summary>
        /// ��������1
        /// ȫ������
        /// </summary>
        public string BUDAT { get; set; }
        /// <summary>
        /// PO����1 �ɹ�����ƻ�Э���
        /// 101/102
        /// </summary>
        public string EBELN { get; set; }
        /// <summary>
        /// PO�к�1 �ɹ�����ƻ�Э���к�
        /// 101/102
        /// </summary>
        public string EBELP { get; set; }
        /// <summary>
        /// DN���� ��Ч
        /// </summary>
        public string VBELN { get; set; }
        /// <summary>
        /// DN���� ��Ч
        /// </summary>
        public string POSNR { get; set; }
        /// <summary>
        /// ���̴��� 1��Ӧ��
        /// �ɹ�101/102/161/162/ZR1/ZR2/ZR5/ZR6 �������� K
        /// </summary>
        public string LIFNR { get; set; }
        /// <summary>
        /// ��������
        /// ȫ������
        /// </summary>
        public string WERKS { get; set; }
        /// <summary>
        /// ���ص�1 �ɹ���Ŀ�Ŀ�λ���� �ƿ⣺��Դ��λ����
        /// ȫ������
        /// </summary>
        public string LGORT { get; set; }
        /// <summary>
        /// �����־
        /// ����K/���ɹ������ջ��ͳ�������(!101/!102)
        /// </summary>
        public string SOBKZ { get; set; }
        /// <summary>
        /// �������� ��Ч I/O
        /// </summary>
        public string OLD { get; set; }
        /// <summary>
        /// ���Ϻ�1
        /// ȫ������
        /// </summary>
        public string MATNR { get; set; }
        /// <summary>
        /// ����
        /// ȫ������
        /// </summary>
        public Decimal ERFMG { get; set; }
        /// <summary>
        /// ��λ
        /// ȫ������
        /// </summary>
        public string ERFME { get; set; }
        /// <summary>
        /// �ջ��ص� �ƿ�Ŀ�Ŀ�λ/�ʼ�
        /// 311/312/411/412/343/309/310/321/301/302/Z01/Z02/303/304/305/306
        /// </summary>
        public string UMLGO { get; set; }
        /// <summary>
        /// �ƶ�ԭ�� �ɹ��ͳ���
        /// 101/102/551/552
        /// </summary>
        public string GRUND { get; set; }
        /// <summary>
        /// �ɱ����� �������ƻ��Գ������
        /// Z05/Z06/Z76/Z75
        /// </summary>
        public string KOSTL { get; set; }
        /// <summary>
        /// ����֪ͨ1 ��ִ������
        /// �ɹ�/����
        /// </summary>
        public string XBLNR { get; set; }
        /// <summary>
        /// Ԥ����1 ������������-���
        /// 201/202
        /// </summary>
        public string RSNUM { get; set; }
        /// <summary>
        /// Ԥ���к� 1������������-���
        /// 201/202
        /// </summary>
        public string RSPOS { get; set; }
        /// <summary>
        /// WMS��1
        /// ����
        /// </summary>
        public string FRBNR { get; set; }
        /// <summary>
        /// WMS�к�1
        /// ����
        /// </summary>
        public string SGTXT { get; set; }
        /// <summary>
        /// ������� 3������ 2���ʼ� �գ�������ʹ�� LESֻ���õ�3�Ϳ�
        /// 101/102/161/162
        /// </summary>
        public string INSMK { get; set; }
        /// <summary>
        /// �ͻ�����1 ASN
        /// 101/102
        /// </summary>
        public string XABLN { get; set; }
        /// <summary>
        /// �ڲ����� �ƻ������� ���ڲ������ŵĲ������ã��������ļƻ������ã�
        /// Z03/Z04
        /// </summary>
        public string AUFNR { get; set; }
        /// <summary>
        /// �ջ����� �����滻
        /// 309/310
        /// </summary>
        public string UMMAT { get; set; }
        /// <summary>
        /// �ջ����� �繤���ƿ�
        /// 301/302/303/304/305/306
        /// </summary>
        public string UMWRK { get; set; }
        /// <summary>
        /// WBSԪ�� �ƻ������� ���ڲ������ŵĲ������ã��������ļƻ������ã�
        /// Z03/Z04
        /// </summary>
        public string POSID { get; set; }

        /// <summary>
        /// �����ջ�����ȷ�ϱ�ʶ
        /// </summary>
        public string KZEAR { get; set; }

        /// <summary>
        /// SAP���κ�
        /// </summary>
        public string CHARG { get; set; }

        public StatusEnum Status { get; set; }
        public DateTime CreateDate { get; set; }
        public DateTime LastModifyDate { get; set; }
        public Int32 ErrorCount { get; set; }
        public ErrorIdEnum ErrorId { get; set; }

        public Int32 BatchNo { get; set; }
        public string ErrorMessage { get; set; }

        public string OrderNo { get; set; }
        public Int32 DetailId { get; set; }
        public Int32 Version { get; set; }
        #endregion

        public override int GetHashCode()
        {
            if (FRBNR != null && SGTXT != null)
            {
                return FRBNR.GetHashCode() ^ SGTXT.GetHashCode();
            }
            else
            {
                return base.GetHashCode();
            }
        }

        public override bool Equals(object obj)
        {
            InvTrans another = obj as InvTrans;

            if (another == null)
            {
                return false;
            }
            else
            {
                return (this.FRBNR == another.FRBNR) && (this.SGTXT == another.SGTXT);
            }
        }
    }

}
