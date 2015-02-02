using System;
using System.ComponentModel.DataAnnotations;

namespace com.Sconit.Entity.SAP.ORD
{
    [Serializable]
    public partial class AssemblyHead : EntityBase
    {
        #region O/R Mapping Properties
		
		public Int64 IDENT { get; set; }
		public string AUFNR { get; set; }
		public string CHARG { get; set; }
		public string WERKS { get; set; }
		public string AUART { get; set; }
		public string PLNBEZ { get; set; }
		public string CY_SEQNR { get; set; }
		public string GSTRS { get; set; }
		public Boolean? GAMNGSpecified { get; set; }
		public Decimal? GAMNG { get; set; }
		public string RSNUM { get; set; }
		public string ZLINE { get; set; }
		public string KDAUF { get; set; }
		public string KDPOS { get; set; }
		public string LGORT { get; set; }
		public string VERID { get; set; }
		public string ZZSVANR { get; set; }
		public string AUGRU { get; set; }
		public string KUNNR { get; set; }
		public string BSTNK { get; set; }
		public string MANDT { get; set; }
        
        #endregion

		public override int GetHashCode()
        {
			if (AUFNR != null)
            {
                return AUFNR.GetHashCode();
            }
            else
            {
                return base.GetHashCode();
            }
        }

        public override bool Equals(object obj)
        {
            AssemblyHead another = obj as AssemblyHead;

            if (another == null)
            {
                return false;
            }
            else
            {
            	return (this.AUFNR == another.AUFNR);
            }
        } 
    }
	
}
