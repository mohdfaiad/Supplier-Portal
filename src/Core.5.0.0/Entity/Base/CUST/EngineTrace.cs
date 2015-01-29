using System;
using System.ComponentModel.DataAnnotations;

namespace com.Sconit.Entity.CUST
{
    [Serializable]
    public partial class EngineTrace : EntityBase, IAuditable
    {
        #region O/R Mapping Properties

        public string TraceCode { get; set; }
        public string VHVIN { get; set; }
        public string ZENGINE { get; set; }
		public string CabItem { get; set; }
		public Int32 CreateUserId { get; set; }
		public string CreateUserName { get; set; }
		public DateTime CreateDate { get; set; }
		public Int32 LastModifyUserId { get; set; }
		public string LastModifyUserName { get; set; }
		public DateTime LastModifyDate { get; set; }
        
        #endregion

		public override int GetHashCode()
        {
            if (TraceCode != null)
            {
                return TraceCode.GetHashCode();
            }
            else
            {
                return base.GetHashCode();
            }
        }

        public override bool Equals(object obj)
        {
            EngineTrace another = obj as EngineTrace;

            if (another == null)
            {
                return false;
            }
            else
            {
                return (this.TraceCode == another.TraceCode);
            }
        } 
    }
	
}
