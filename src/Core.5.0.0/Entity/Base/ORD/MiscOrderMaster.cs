using System;
using System.ComponentModel.DataAnnotations;

namespace com.Sconit.Entity.ORD
{
    [Serializable]
    public partial class MiscOrderMaster : EntityBase, IAuditable
    {
        #region O/R Mapping Properties

        /// <summary>
        /// //�ƻ������ⵥ��
        /// </summary>
        [Display(Name = "MiscOrderMstr_MiscOrderNo", ResourceType = typeof(Resources.ORD.MiscOrderMstr))]
        public string MiscOrderNo { get; set; }

        /// <summary>
        /// //�ƻ�����������
        /// </summary>
        [Display(Name = "MiscOrderMstr_Type", ResourceType = typeof(Resources.ORD.MiscOrderMstr))]
        public com.Sconit.CodeMaster.MiscOrderType Type { get; set; }

        /// <summary>
        /// //״̬
        /// </summary>
        [Display(Name = "MiscOrderMstr_Status", ResourceType = typeof(Resources.ORD.MiscOrderMstr))]
        public com.Sconit.CodeMaster.MiscOrderStatus Status { get; set; }

        /// <summary>
        /// //�Ƿ�ɨ������
        /// </summary>
        [Display(Name = "MiscOrderMstr_IsScanHu", ResourceType = typeof(Resources.ORD.MiscOrderMstr))]
        public Boolean IsScanHu { get; set; }

        /// <summary>
        /// //����״̬
        /// </summary>
        [Required(AllowEmptyStrings = false, ErrorMessageResourceName = "Errors_Common_FieldRequired", ErrorMessageResourceType = typeof(Resources.ErrorMessage))]
        [Display(Name = "MiscOrderMstr_QualityType", ResourceType = typeof(Resources.ORD.MiscOrderMstr))]
        public CodeMaster.QualityType QualityType { get; set; }

        /// <summary>
        /// //�ƶ�����
        /// </summary>
         [Required(AllowEmptyStrings = false, ErrorMessageResourceName = "Errors_Common_FieldRequired", ErrorMessageResourceType = typeof(Resources.ErrorMessage))]
        [Display(Name = "MiscOrderMstr_MoveType", ResourceType = typeof(Resources.ORD.MiscOrderMstr))]
        public string MoveType { get; set; }

        /// <summary>
        /// //����ʱ���ƶ�����
        /// </summary>
        public string CancelMoveType { get; set; }

        /// <summary>
        /// //����������Ӧ�����򣬿繤���ƿ�ʱ�����������
        /// </summary>
        [Required(AllowEmptyStrings = false, ErrorMessageResourceName = "Errors_Common_FieldRequired", ErrorMessageResourceType = typeof(Resources.ErrorMessage))]
        [Display(Name = "MiscOrderMstr_Region", ResourceType = typeof(Resources.ORD.MiscOrderMstr))]
        public string Region { get; set; }

        /// <summary>
        ///  //���ص��Ӧ�Ŀ�λ
        /// </summary>
        [Required(AllowEmptyStrings = false, ErrorMessageResourceName = "Errors_Common_FieldRequired", ErrorMessageResourceType = typeof(Resources.ErrorMessage))]
        [Display(Name = "MiscOrderMstr_Location", ResourceType = typeof(Resources.ORD.MiscOrderMstr))]              
        public string Location { get; set; }

        /// <summary>
        /// //�ջ��ص㣬ΪSAP��λ���÷���
        /// </summary>
        [Display(Name = "MiscOrderMstr_ReceiveLocation", ResourceType = typeof(Resources.ORD.MiscOrderMstr))]
        public string ReceiveLocation { get; set; }

        /// <summary>
        /// //�ƶ�ԭ��
        /// </summary>
        [Display(Name = "MiscOrderMstr_Note", ResourceType = typeof(Resources.ORD.MiscOrderMstr))]
        public string Note { get; set; }

        /// <summary>
        /// //�ɱ�����
        /// </summary>
        [Display(Name = "MiscOrderMstr_CostCenter", ResourceType = typeof(Resources.ORD.MiscOrderMstr))]
        public string CostCenter { get; set; }

        /// <summary>
        /// //����֪ͨ
        /// </summary>
        [Display(Name = "MiscOrderMstr_Asn", ResourceType = typeof(Resources.ORD.MiscOrderMstr))]
        public string Asn { get; set; }

        /// <summary>
        /// //�ڲ�������
        /// </summary>
        [Display(Name = "MiscOrderMstr_ReferenceNo", ResourceType = typeof(Resources.ORD.MiscOrderMstr))]
        public string ReferenceNo { get; set; }

        /// <summary>
        /// �繤���ƿ�ʱ,�����ջ�����
        /// �������룬ΪSAP���룬�ǿ繤���ƿ�ʱ�����Region�ֶ��ҵ���Ӧ��Plant����ֶ�����
        /// </summary>
        [Display(Name = "MiscOrderMstr_DeliverRegion", ResourceType = typeof(Resources.ORD.MiscOrderMstr))]
        public string DeliverRegion { get; set; }

        /// <summary>
        /// WBSԪ��
        /// </summary>
        [Display(Name = "MiscOrderMstr_WBS", ResourceType = typeof(Resources.ORD.MiscOrderMstr))]
        public string WBS { get; set; }

        /// <summary>
        /// ��Ӧ��
        /// </summary>
        [Display(Name = "MiscOrderMstr_ManufactureParty", ResourceType = typeof(Resources.ORD.MiscOrderMstr))]
        public string ManufactureParty { get; set; }

        public bool Consignment { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessageResourceName = "Errors_Common_FieldRequired", ErrorMessageResourceType = typeof(Resources.ErrorMessage))]
        [Display(Name = "MiscOrderMstr_EffectiveDate", ResourceType = typeof(Resources.ORD.MiscOrderMstr))]
        public DateTime EffectiveDate { get; set; }

        //[Display(Name = "CreateUserId", ResourceType = typeof(Resources.ORD.MiscOrderMstr))]
        public Int32 CreateUserId { get; set; }

        [Display(Name = "MiscOrderMstr_CreateUserName", ResourceType = typeof(Resources.ORD.MiscOrderMstr))]
        public string CreateUserName { get; set; }

        [Display(Name = "MiscOrderMstr_CreateDate", ResourceType = typeof(Resources.ORD.MiscOrderMstr))]
        public DateTime CreateDate { get; set; }

        //[Display(Name = "LastModifyUserId", ResourceType = typeof(Resources.ORD.MiscOrderMstr))]
        public Int32 LastModifyUserId { get; set; }

        //[Display(Name = "LastModifyUserName", ResourceType = typeof(Resources.ORD.MiscOrderMstr))]
        public string LastModifyUserName { get; set; }

        //[Display(Name = "LastModifyDate", ResourceType = typeof(Resources.ORD.MiscOrderMstr))]
        public DateTime LastModifyDate { get; set; }

        public DateTime? CloseDate { get; set; }

        public Int32? CloseUserId { get; set; }

        public string CloseUserName { get; set; }

        public DateTime? CancelDate { get; set; }

        public Int32? CancelUserId { get; set; }

        public string CancelUserName { get; set; }

        //[Display(Name = "Version", ResourceType = typeof(Resources.ORD.MiscOrderMstr))]
        public Int32 Version { get; set; }
        [Display(Name = "MiscOrderMstr_WMSNo", ResourceType = typeof(Resources.ORD.MiscOrderMstr))]
        public string WMSNo { get; set; }

        [Display(Name = "MiscOrderDetail_ReserveNo", ResourceType = typeof(Resources.ORD.MiscOrderDetail))]
        public string ReserveNo { get; set; }
        [Display(Name = "MiscOrderDetail_ReserveLine", ResourceType = typeof(Resources.ORD.MiscOrderDetail))]
        public string ReserveLine { get; set; }

        #endregion

        public override int GetHashCode()
        {
            if (MiscOrderNo != null)
            {
                return MiscOrderNo.GetHashCode();
            }
            else
            {
                return base.GetHashCode();
            }
        }

        public override bool Equals(object obj)
        {
            MiscOrderMaster another = obj as MiscOrderMaster;

            if (another == null)
            {
                return false;
            }
            else
            {
                return (this.MiscOrderNo == another.MiscOrderNo);
            }
        }
    }

}
