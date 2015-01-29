using System;
using System.ComponentModel.DataAnnotations;
//TODO: Add other using statements here

namespace com.Sconit.Entity.SYS
{
    public partial class EntityPreference
    {
        #region Non O/R Mapping Properties

        public enum CodeEnum
        {
            DefaultPageSize = 10001,
            SessionCachedSearchStatementCount = 10002,
            ItemFilterMode = 10003,
            ItemFilterMinimumChars = 10004,
            InProcessIssueWaitingTime = 10005,
            CompleteIssueWaitingTime = 10006,
            SMTPEmailAddr = 10007,
            SMTPEmailHost = 10008,
            SMTPEmailPasswd = 10009,
            IsRecordLocatoinTransactionDetail = 10010,
            DecimalLength = 10011,
            DefaultPickStrategy = 10012,
            AllowManualCreateProcurementOrder = 10016,
            WMSAnjiRegion = 10017,
            MaxRowSizeOnPage = 10018,
            DefaultBarCodeTemplate = 10019,
            StandardWorkTime = 10020,
            ExceptionMailTo = 11020,
            SAPServiceUserName = 11001,
            SAPServicePassword = 11002,
            SAPServiceTimeOut = 11003,
            SAPServiceAddress = 11005,
            SAPServicePort = 11006,
            SAPTransSave2TempTableBatchSize = 11007,
            SAPTransPost2SAPBatchSize = 11008,
            SAPDataExchangeMaxFailCount = 11009,
            ExportMaxRows = 10123,
            SIServiceTimeOut = 11050,
            SIServiceAddress = 11051,
            SIServicePort = 11052,
            CoveredDaysOfCabOut = 11053,
            CoveredDaysOfKitProduction = 11054,
            CheckItemTrace = 11055,
            FilterVanLogistic = 11056,
            SystemFlag = 11040,
            DefaultSAPProdLine = 11057,
            ImportVanProdOrderInRestTime = 11058,
            SendMailServiceAddress = 11059,
            SendMailServicePort = 11060,
            MSWebServiceAddress = 11061,
            MSWebServicePort = 11062,
            SAPPlant = 11063,
            PortalAddress = 11064,
            PortalPort = 11065,
            SystemTitle = 11066,
            PortalPlant = 11067,
        }

        [Display(Name = "EntityPreference_Desc", ResourceType = typeof(Resources.SYS.EntityPreference))]
        public string EntityPreferenceDesc { get; set; }
        #endregion
    }
}