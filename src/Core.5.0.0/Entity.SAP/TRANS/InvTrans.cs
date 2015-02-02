using System;
using System.Collections.Generic;

//TODO: Add other using statements here

namespace com.Sconit.Entity.SAP.TRANS
{
    public partial class InvTrans
    {
        #region Non O/R Mapping Properties
        public Int64 LocTransId { get; set; }
        public string CheckList { get; set; }
        public string StatusName { get; set; }
        public IList<InvTrans> InvTransList { get; set; }

        public enum ErrorIdEnum
        {
            E000 = 0,     //û�д���
            E100 = 100,   //ϵͳ����
            E101 = 101,   //�������{0}��PO����/�ƻ�Э���Ϊ�ա�
            E102 = 102,   //�������{0}��PO�����к�/�ƻ�Э���к�Ϊ�ա�
            E103 = 103,   //�����ƻ����ջ�ʱ�������{0}�ļƻ�Э���кŲ������ָ���{1}��
            E104 = 104,   //�ƿ�/�ƿ��˻���������С��0��
            E105 = 105,   //�ƿ�/�ƿ��˻���������С��0��
            E106 = 106,   //�ƿ�/�ƿ��˻�������������С��0��
            E107 = 107,   //�ƿ�/�ƿ��˻�������������С��0��
            E108 = 108,   //����δ֪�Ľ��㡣
            E199 = 199,   //�����ƶ�����ʱ��������
            E201 = 201,   //����SAP�ƶ����ͽӿڷ��ؽ�����ɹ���
            E202 = 202    //����SAP�ƶ����ͽӿڷ���Exception��Ϣ��
        }
        #endregion
    }
}