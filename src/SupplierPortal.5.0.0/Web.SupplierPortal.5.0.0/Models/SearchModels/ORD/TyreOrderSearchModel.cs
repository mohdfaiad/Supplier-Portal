using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace com.Sconit.Web.Models.SearchModels.ORD
{
    public class TyreOrderSearchModel : SearchModelBase
    {
        public string ProdLines { get; set; }
        public string ProdLine { get; set; }
        public string Flow { get; set; }
        public string ProdNo { get; set; }
        public string TyreOrderNo { get; set; }
        public string RefOrderNo { get; set; }
        public string SeqGroup { get; set; }
        public string Item { get; set; }
        public string VanNo { get; set; }
        public string ids { get; set; }
        public DateTime? CompleteDateFrom { get; set; }
        public DateTime? CompleteDateTo { get; set; }
        public DateTime? CreateDateFrom { get; set; }
        public DateTime? CreateDateTo { get; set; }
    }
}