using System;
using System.ComponentModel.DataAnnotations;
using com.Sconit.Entity.SYS;

//TODO: Add other using statements here

namespace com.Sconit.Entity.MD
{
    public partial class Supplier 
    {
        #region Non O/R Mapping Properties
        public string CodeDescription
        {
            get
            {
                return this.Code + " [" + this.Name + "]";
            }
        }

        public string UserPassword { get; set; }
        #endregion
    }
}