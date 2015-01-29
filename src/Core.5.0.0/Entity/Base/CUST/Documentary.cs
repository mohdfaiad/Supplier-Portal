using System;
using System.ComponentModel.DataAnnotations;

namespace com.Sconit.Entity.CUST
{
    [Serializable]
    public partial class Documentary : EntityBase
    {
        #region O/R Mapping Properties
		
		public string OPref { get; set; }
		public string OPDesc { get; set; }
		public string CHARG { get; set; }
		public string AUFNR { get; set; }
		public DateTime? GSTRS { get; set; }
		public DateTime? ChangeTime { get; set; }
        
        #endregion

		public override int GetHashCode()
        {
			if (OPref != null)
            {
                return OPref.GetHashCode();
            }
            else
            {
                return base.GetHashCode();
            }
        }

        public override bool Equals(object obj)
        {
            Documentary another = obj as Documentary;

            if (another == null)
            {
                return false;
            }
            else
            {
            	return (this.OPref == another.OPref);
            }
        } 
    }
	
}
