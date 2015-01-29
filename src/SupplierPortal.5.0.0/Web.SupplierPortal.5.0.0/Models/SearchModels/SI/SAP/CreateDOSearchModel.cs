using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace com.Sconit.Web.Models.SearchModels.SI.SAP
{
    public class CreateDOSearchModel : SearchModelBase
    {
        // DoNo, DoLine, Plant, LocFrom, LocTo, Item, Uom, Qty, WindowTime, OpRef, CreateDate, CreateUser, 
        //LastModifyDate, LastModifyUser, ErrorCount, ErrorMsg, Version, Status, SAPCreateDate, OrderNo
        public string DoNo { get; set; }
        public string DoLine { get; set; }
        public string Plant { get; set; }
        public string LocationFrom { get; set; }
        public string LocationTo { get; set; }
        public string Item { get; set; }
        public string Status { get; set; }
        public string OrderNo { get; set; }

        public DateTime? CreateDateFrom { get; set; }
        public DateTime? CreateDateTo { get; set; }

        public DateTime? LastModifyDateFrom { get; set; }
        public DateTime? LastModifyDateTo { get; set; }
    }
}