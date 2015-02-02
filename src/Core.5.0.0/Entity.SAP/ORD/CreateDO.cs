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
                        return "δִ��";
                    case 1:
                        return "�����ɹ�";
                    case 2:
                        return "����ʧ��";
                    case 3:
                        return "�䵥���ظ�";
                    default:
                        return "δִ��";
                }
            }
        }

        #endregion
    }
}