using System;
using System.ComponentModel.DataAnnotations;

//TODO: Add other using statements here

namespace com.Sconit.Entity.SAP.ORD
{
    public partial class CreateDO
    {
        #region Non O/R Mapping Properties

        //TODO: Add Non O/R Mapping Properties here. 

        [Display(Name = "CreateDO_Status", ResourceType = typeof(Resources.SI.CreateDO))]
        public string StatusDesc
        {
            get
            {
                switch (this.Status)
                {
                    case 0:
                        return "未执行";
                    case 1:
                        return "创建成功";
                    case 2:
                        return "创建失败";
                    case 3:
                        return "配单号重复";
                    default:
                        return "未执行";
                }
            }
        }

        #endregion
    }
}