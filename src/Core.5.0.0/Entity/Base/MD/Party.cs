using System;
using System.ComponentModel.DataAnnotations;
using com.Sconit.Entity.SYS;
namespace com.Sconit.Entity.MD
{
    [Serializable]
    public partial class Party : EntityBase, IAuditable
    {
        #region O/R Mapping Properties
        [Export(ExportName = "ExportSupplierXLS", ExportSeq = 10)]
        [Required(AllowEmptyStrings = false, ErrorMessageResourceName = "Errors_Common_FieldRequired", ErrorMessageResourceType = typeof(Resources.ErrorMessage))]
        [StringLength(50, ErrorMessageResourceName = "Errors_Common_FieldLengthExceed", ErrorMessageResourceType = typeof(Resources.ErrorMessage))]
        [Display(Name = "Party_Code", ResourceType = typeof(Resources.MD.Party))]
        public string Code { get; set; }
        [Export(ExportName = "ExportSupplierXLS", ExportSeq = 20)]
        [Required(AllowEmptyStrings = false, ErrorMessageResourceName = "Errors_Common_FieldRequired", ErrorMessageResourceType = typeof(Resources.ErrorMessage))]
        [StringLength(100, ErrorMessageResourceName = "Errors_Common_FieldLengthExceed", ErrorMessageResourceType = typeof(Resources.ErrorMessage))]
        [Display(Name = "Party_Name", ResourceType = typeof(Resources.MD.Party))]
        public string Name { get; set; }
        [Export(ExportName = "ExportSupplierXLS", ExportSeq = 40)]
        [Display(Name = "Party_IsActive", ResourceType = typeof(Resources.MD.Party))]
        public Boolean IsActive { get; set; }
        public Int32 CreateUserId { get; set; }
        public string CreateUserName { get; set; }
        public DateTime CreateDate { get; set; }
        public Int32 LastModifyUserId { get; set; }
        public string LastModifyUserName { get; set; }
        public DateTime LastModifyDate { get; set; }

        #endregion

        public override int GetHashCode()
        {
            if (Code != null)
            {
                return Code.GetHashCode();
            }
            else
            {
                return base.GetHashCode();
            }
        }

        public override bool Equals(object obj)
        {
            Party another = obj as Party;

            if (another == null)
            {
                return false;
            }
            else
            {
                return (this.Code == another.Code);
            }
        }
    }

}
