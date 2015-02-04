using System;
using System.ComponentModel.DataAnnotations;
using com.Sconit.Entity.SYS;
namespace com.Sconit.Entity.MD
{
    [Serializable]
    public partial class Supplier : EntityBase, IAuditable
    {
        #region O/R Mapping Properties
        [Display(Name = "Party_Code", ResourceType = typeof(Resources.MD.Party))]
        public string Code { get; set; }

        [Display(Name = "Party_Name", ResourceType = typeof(Resources.MD.Party))]
        public string Name { get; set; }

        [Display(Name = "Party_Address", ResourceType = typeof(Resources.MD.Party))]
        public string Address { get; set; }

        [Display(Name = "Party_ContactPerson", ResourceType = typeof(Resources.MD.Party))]
        public string ContactPerson { get; set; }

        [Display(Name = "Party_ContactPhone", ResourceType = typeof(Resources.MD.Party))]
        public string ContactPhone { get; set; }

        [Display(Name = "Party_Email", ResourceType = typeof(Resources.MD.Party))]
        [DataType(DataType.EmailAddress)]
        public string Email { get; set; }

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
            Supplier another = obj as Supplier;

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
