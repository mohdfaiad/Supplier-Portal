using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace com.Sconit.Web.Models.SearchModels.SI.SAP
{
    public class IpShipInfoSearchModel : SearchModelBase
    {
        public string EBELN { get; set; }
        public string EBELP { get; set; }
        public string ASNNR { get; set; }
        public string MATNR { get; set; }
        public string LGORT { get; set; }
        public string DNSTR { get; set; }
        public string GISTR { get; set; }
        public bool IsDelivery { get; set; }
        public DateTime? CreateDateFrom { get; set; }
        public DateTime? CreateDateTo { get; set; }
        public string ErrorCount { get; set; }
        public string VBELN_VL { get; set; }
    }
}