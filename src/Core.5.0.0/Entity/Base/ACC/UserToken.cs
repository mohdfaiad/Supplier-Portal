using System;

namespace com.Sconit.Entity.ACC
{
    [Serializable]
    public partial class UserToken : EntityBase
    {
        #region O/R Mapping Properties
		
		public String Code { get; set; }
        public String Token { get; set; }
        public DateTime ExpireDate { get; set; }
        
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
            UserToken another = obj as UserToken;

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
