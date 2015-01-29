using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace com.Sconit.Web.Models.CUST
{
    public class DocumentaryViewModel
    {
        [Display(Name = "AssemblyList_ZOPID", ResourceType = typeof(Resources.ORD.AssemblyList))]
        public string ZOPID { get; set; }

        [Display(Name = "AssemblyList_ZOPDS", ResourceType = typeof(Resources.ORD.AssemblyList))]
        public string ZOPDS { get; set; }

        [Display(Name = "AssemblyList_MATNR", ResourceType = typeof(Resources.ORD.AssemblyList))]
        public string MATNR { get; set; }

        [Display(Name = "AssemblyList_BISMT", ResourceType = typeof(Resources.ORD.AssemblyList))]
        public string BISMT { get; set; }

        [Display(Name = "AssemblyList_MAKTX", ResourceType = typeof(Resources.ORD.AssemblyList))]
        public string MAKTX { get; set; }

        [Display(Name = "AssemblyList_MENGE", ResourceType = typeof(Resources.ORD.AssemblyList))]
        public decimal MENGE { get; set; }

        [Display(Name = "AssemblyList_MEINS", ResourceType = typeof(Resources.ORD.AssemblyList))]
        public string MEINS { get; set; }
    }
}