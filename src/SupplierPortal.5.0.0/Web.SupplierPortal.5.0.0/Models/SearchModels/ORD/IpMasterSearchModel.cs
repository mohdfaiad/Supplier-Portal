﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace com.Sconit.Web.Models.SearchModels.ORD
{
    public class IpMasterSearchModel:SearchModelBase
    {
        public string IpNo { get; set; }
        public int? Status { get; set; }
        public string PartyFrom { get; set; }
        public string PartyTo { get; set; }
        public int? IpOrderType { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public string ShipFromAddress { get; set; }
        public string type { get; set; }
        public string Dock { get; set; }
        public string Item { get; set; }
        public string OrderNo { get; set; }
        public string WMSNo { get; set; }
        public string ManufactureParty { get; set; }
        public string Flow { get; set; }
        public Boolean IsShowGap { get; set; }
        public string ExternalOrderNo { get; set; }
        public string ExternalSequence { get; set; }
        public bool IsPrintAsn { get; set; }
        public string Success { get; set; }

    }
}