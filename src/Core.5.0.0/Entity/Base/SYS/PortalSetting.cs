using System;

namespace com.Sconit.Entity.SYS
{
    [Serializable]
    public partial class PortalSetting : EntityBase
    {
        #region O/R Mapping Properties
		
		public Int32 Id { get; set; }
		public string Name { get; set; }
        public Int32 Seq { get; set; }
        public string WebServerAddress { get; set; }
        public string SIServerAddress { get; set; }
        public Int32 SIPort { get; set; }
        public Int32 WebPort { get; set; }
        public string WebVirtualPath { get; set; }
        public bool IsPrimary { get; set; }
        
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
            PortalSetting another = obj as PortalSetting;

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
