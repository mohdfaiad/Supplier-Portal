using System;
using System.ComponentModel.DataAnnotations;

namespace com.Sconit.Entity.SCM
{
    [Serializable]
    public partial class SCMSupplierPlant : EntityBase
    {
        #region O/R Mapping Properties

        [Required(AllowEmptyStrings = false, ErrorMessageResourceName = "Errors_Common_FieldRequired", ErrorMessageResourceType = typeof(Resources.ErrorMessage))]
        [StringLength(50, ErrorMessageResourceName = "Errors_Common_FieldLengthExceed", ErrorMessageResourceType = typeof(Resources.ErrorMessage))]
        [Display(Name = "SCMSupplierPlant_Code", ResourceType = typeof(Resources.SCM.SCMSupplierPlant))]
		public string Code { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessageResourceName = "Errors_Common_FieldRequired", ErrorMessageResourceType = typeof(Resources.ErrorMessage))]
        [StringLength(50, ErrorMessageResourceName = "Errors_Common_FieldLengthExceed", ErrorMessageResourceType = typeof(Resources.ErrorMessage))]
        [Display(Name = "SCMSupplierPlant_Desc1", ResourceType = typeof(Resources.SCM.SCMSupplierPlant))]
		public string Description { get; set; }

        [Display(Name = "SCMSupplierPlant_SupplierCode", ResourceType = typeof(Resources.SCM.SCMSupplierPlant))]
        public string SupplierCode { get; set; }

        [Display(Name = "SCMSupplierPlant_SupplierName", ResourceType = typeof(Resources.SCM.SCMSupplierPlant))]
        public string SupplierName { get; set; }

        [Display(Name = "SCMSupplierPlant_SupplierAddress", ResourceType = typeof(Resources.SCM.SCMSupplierPlant))]
        public string SupplierAddress { get; set; }

        [Display(Name = "SCMSupplierPlant_SupplierContactPerson", ResourceType = typeof(Resources.SCM.SCMSupplierPlant))]
        public string SupplierContactPerson { get; set; }

        [Display(Name = "SCMSupplierPlant_SupplierContactPhone", ResourceType = typeof(Resources.SCM.SCMSupplierPlant))]
        public string SupplierContactPhone { get; set; }

        [Display(Name = "SCMSupplierPlant_PlantCode", ResourceType = typeof(Resources.SCM.SCMSupplierPlant))]
        public string PlantCode { get; set; }

        [Display(Name = "SCMSupplierPlant_PlantName", ResourceType = typeof(Resources.SCM.SCMSupplierPlant))]
        public string PlantName { get; set; }

        [Display(Name = "SCMSupplierPlant_PlantAddress", ResourceType = typeof(Resources.SCM.SCMSupplierPlant))]
        public string PlantAddress { get; set; }

        [Display(Name = "SCMSupplierPlant_PlantContactPerson", ResourceType = typeof(Resources.SCM.SCMSupplierPlant))]
        public string PlantContactPerson { get; set; }

        [Display(Name = "SCMSupplierPlant_PlantContactPhone", ResourceType = typeof(Resources.SCM.SCMSupplierPlant))]
        public string PlantContactPhone { get; set; }

        [Display(Name = "SCMSupplierPlant_Dock", ResourceType = typeof(Resources.SCM.SCMSupplierPlant))]
        public string Dock { get; set; }
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
            SCMSupplierPlant another = obj as SCMSupplierPlant;

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
