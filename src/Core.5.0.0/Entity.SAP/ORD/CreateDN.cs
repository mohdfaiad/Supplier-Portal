using System;
using System.ComponentModel.DataAnnotations;

//TODO: Add other using statements here

namespace com.Sconit.Entity.SAP.ORD
{
    public partial class CreateDN
    {
        #region Non O/R Mapping Properties

        //TODO: Add Non O/R Mapping Properties here. 

        #endregion

        [Display(Name = "CreateDN_CancelCreateDate", ResourceType = typeof(Resources.SI.CreateDN))]
        public DateTime? CancelCreateDate { get; set; }
        [Display(Name = "CreateDN_DNSTRDesc", ResourceType = typeof(Resources.SI.CreateDN))]
        public string DNSTRDesc { get; set; }
        [Display(Name = "CreateDN_GISTRDesc", ResourceType = typeof(Resources.SI.CreateDN))]
        public string GISTRDesc { get; set; }
        [Display(Name = "CreateDN_CancelMessage", ResourceType = typeof(Resources.SI.CreateDN))]
        public string CancelMessage { get; set; }
        [Display(Name = "CreateDN_CancelDNSTRDesc", ResourceType = typeof(Resources.SI.CreateDN))]
        public string CancelDNSTRDesc { get; set; }
        [Display(Name = "CreateDN_CancelGISTRDesc", ResourceType = typeof(Resources.SI.CreateDN))]
        public string CancelGISTRDesc { get; set; }
        [Display(Name = "CreateDN_CancelErrorCount", ResourceType = typeof(Resources.SI.CreateDN))]
        public Int32? CancelErrorCount { get; set; }

        public Int32 CancelIpDetConfirmId { get; set; }

    }
}