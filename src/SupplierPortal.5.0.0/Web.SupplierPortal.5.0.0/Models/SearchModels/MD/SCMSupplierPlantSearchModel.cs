using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace com.Sconit.Web.Models.SearchModels.MD
{
    public class SCMSupplierPlantSearchModel : SearchModelBase
    {
        public string Code { get; set; }
        public string Description { get; set; }
        public string SupplierCode { get; set; }
        public string SupplierName { get; set; }
        public string PlantCode { get; set; }
        public string PlantName { get; set; }
    }
}