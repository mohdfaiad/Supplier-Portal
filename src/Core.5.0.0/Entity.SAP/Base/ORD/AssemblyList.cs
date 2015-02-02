using System;
using System.ComponentModel.DataAnnotations;

namespace com.Sconit.Entity.SAP.ORD
{
    [Serializable]
    public partial class AssemblyList : EntityBase
    {
        #region O/R Mapping Properties
		
		public Int64 IDENT { get; set; }
		public string MANDT { get; set; }
		public string AUFNR { get; set; }
		public string RSNUM { get; set; }
		public string RSPOS { get; set; }
		public string RSART { get; set; }
		public string XLOEX { get; set; }
		public string WERKS { get; set; }
		public string MATNR { get; set; }
		public string LGORT { get; set; }
		public string PRVBE { get; set; }
		public string CHARG { get; set; }
		public Decimal? BDMNG { get; set; }
		public Boolean? BDMNGSpecified { get; set; }
		public string MEINS { get; set; }
		public Decimal? MENGE { get; set; }
		public Boolean? MENGESpecified { get; set; }
		public string SHKZG { get; set; }
		public string BAUGR { get; set; }
		public string BWART { get; set; }
		public string POSTP { get; set; }
		public string POSNR { get; set; }
		public string STLTY { get; set; }
		public string STLNR { get; set; }
		public string STLKN { get; set; }
		public string STPOZ { get; set; }
		public string DUMPS { get; set; }
		public string AUFST { get; set; }
		public string AUFWG { get; set; }
		public string BAUST { get; set; }
		public string BAUWG { get; set; }
		public string AUFPL { get; set; }
		public string PLNFL { get; set; }
		public string VORNR { get; set; }
		public string APLZL { get; set; }
		public string OBJNR { get; set; }
		public string RGEKZ { get; set; }
		public string LIFNR { get; set; }
		public string KZ { get; set; }
		public string GW { get; set; }
		public string WZ { get; set; }
		public string ZOPID { get; set; }
		public string ZOPDS { get; set; }
		public string BISMT { get; set; }
		public string MAKTX { get; set; }
		public string DISPO { get; set; }
		public string BESKZ { get; set; }
		public string SOBSL { get; set; }
		public string ZZPPKITFLG { get; set; }
		public string ZZPPVIRFLG { get; set; }
		public string MARK { get; set; }
        
        #endregion

		public override int GetHashCode()
        {
			if (IDENT != null)
            {
                return IDENT.GetHashCode();
            }
            else
            {
                return base.GetHashCode();
            }
        }

        public override bool Equals(object obj)
        {
            AssemblyList another = obj as AssemblyList;

            if (another == null)
            {
                return false;
            }
            else
            {
            	return (this.IDENT == another.IDENT);
            }
        } 
    }
	
}
