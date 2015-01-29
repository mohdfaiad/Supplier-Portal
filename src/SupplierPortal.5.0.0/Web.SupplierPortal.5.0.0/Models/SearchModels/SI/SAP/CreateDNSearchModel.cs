using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace com.Sconit.Web.Models.SearchModels.SI.SAP
{
    public class CreateDNSearchModel : SearchModelBase
    {
        public string IpNo { get; set; }
        public string MATNR { get; set; }
        public string EBELN { get; set; }
        public string EBELP { get; set; }
        public string LGORT { get; set; }//发货仓库
        public string DNSTR { get; set; }//创建状态
        public string GISTR { get; set; }//交货状态
        public string VBELN_VL { get; set; }//交货单号
        public string ErrorCount { get; set; }
        public DateTime? CreateDateFrom { get; set; }
        public DateTime? CreateDateTo { get; set; }

        public string CancelDNSTR { get; set; }//创建状态
        public string CancelGISTR { get; set; }//交货状态
        public DateTime? CancelCreateDateFrom { get; set; }
        public DateTime? CancelCreateDateTo { get; set; }
    }
}