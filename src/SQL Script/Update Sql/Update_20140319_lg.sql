-----------------------new table-----------------------------------
/****** Object:  Table [dbo].[SAP_AssemblyHead]    Script Date: 03/19/2014 16:19:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[SAP_AssemblyHead]
    (
      [IDENT] [bigint] IDENTITY(1, 1)
                       NOT NULL ,
      [AUFNR] [varchar](12) NOT NULL ,
      [CHARG] [varchar](10) NULL ,
      [WERKS] [varchar](4) NULL ,
      [AUART] [varchar](4) NULL ,
      [PLNBEZ] [varchar](18) NULL ,
      [CY_SEQNR] [varchar](14) NULL ,
      [GSTRS] [varchar](10) NULL ,
      [GAMNGSpecified] [bit] NULL ,
      [GAMNG] [decimal](17, 3) NULL ,
      [RSNUM] [varchar](10) NULL ,
      [ZLINE] [varchar](1) NULL ,
      [KDAUF] [varchar](10) NULL ,
      [KDPOS] [varchar](6) NULL ,
      [LGORT] [varchar](4) NULL ,
      [VERID] [varchar](4) NULL ,
      [ZZSVANR] [varchar](5) NULL ,
      [AUGRU] [varchar](3) NULL ,
      [KUNNR] [varchar](10) NULL ,
      [BSTNK] [varchar](20) NULL ,
      [MANDT] [varchar](3) NULL ,
      CONSTRAINT [PK_SAP_AssemblyHead] PRIMARY KEY CLUSTERED ( [AUFNR] ASC )
        WITH ( PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF,
               IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
               ALLOW_PAGE_LOCKS = ON ) ON [PRIMARY]
    )
ON  [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

/****** Object:  Table [dbo].[SAP_AssemblyList]    Script Date: 03/19/2014 16:19:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[SAP_AssemblyList]
    (
      [IDENT] [bigint] IDENTITY(1, 1)
                       NOT NULL ,
      [MANDT] [varchar](3) NULL ,
      [AUFNR] [varchar](12) NULL ,
      [RSNUM] [varchar](10) NULL ,
      [RSPOS] [varchar](4) NULL ,
      [RSART] [varchar](1) NULL ,
      [XLOEX] [varchar](1) NULL ,
      [WERKS] [varchar](4) NULL ,
      [MATNR] [varchar](18) NULL ,
      [LGORT] [varchar](4) NULL ,
      [PRVBE] [varchar](10) NULL ,
      [CHARG] [varchar](10) NULL ,
      [BDMNG] [decimal](17, 3) NULL ,
      [BDMNGSpecified] [bit] NULL ,
      [MEINS] [varchar](3) NULL ,
      [MENGE] [decimal](17, 3) NULL ,
      [MENGESpecified] [bit] NULL ,
      [SHKZG] [varchar](1) NULL ,
      [BAUGR] [varchar](18) NULL ,
      [BWART] [varchar](3) NULL ,
      [POSTP] [varchar](1) NULL ,
      [POSNR] [varchar](4) NULL ,
      [STLTY] [varchar](1) NULL ,
      [STLNR] [varchar](8) NULL ,
      [STLKN] [varchar](8) NULL ,
      [STPOZ] [varchar](8) NULL ,
      [DUMPS] [varchar](1) NULL ,
      [AUFST] [varchar](2) NULL ,
      [AUFWG] [varchar](4) NULL ,
      [BAUST] [varchar](2) NULL ,
      [BAUWG] [varchar](4) NULL ,
      [AUFPL] [varchar](10) NULL ,
      [PLNFL] [varchar](6) NULL ,
      [VORNR] [varchar](4) NULL ,
      [APLZL] [varchar](8) NULL ,
      [OBJNR] [varchar](22) NULL ,
      [RGEKZ] [varchar](1) NULL ,
      [LIFNR] [varchar](10) NULL ,
      [KZ] [varchar](18) NULL ,
      [GW] [varchar](6) NULL ,
      [WZ] [varchar](6) NULL ,
      [ZOPID] [varchar](18) NULL ,
      [ZOPDS] [varchar](40) NULL ,
      [BISMT] [varchar](48) NULL ,
      [MAKTX] [varchar](80) NULL ,
      [DISPO] [varchar](3) NULL ,
      [BESKZ] [varchar](1) NULL ,
      [SOBSL] [varchar](2) NULL ,
      [ZZPPKITFLG] [varchar](1) NULL ,
      [ZZPPVIRFLG] [varchar](1) NULL ,
      [MARK] [varchar](80) NULL ,
      CONSTRAINT [PK_SAP_AssemblyList] PRIMARY KEY CLUSTERED ( [IDENT] ASC )
        WITH ( PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF,
               IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
               ALLOW_PAGE_LOCKS = ON ) ON [PRIMARY]
    )
ON  [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


/****** Object:  Table [dbo].[CUST_Documentary]    Script Date: 03/19/2014 16:19:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[CUST_Documentary]
    (
      [OPref] [varchar](10) NOT NULL ,
      [OPDesc] [varchar](50) NULL ,
      [CHARG] [varchar](10) NULL ,
      [AUFNR] [varchar](12) NULL ,
      [GSTRS] [datetime] NULL ,
      [ChangeTime] [datetime] NULL ,
      CONSTRAINT [PK_CUST_Documentary] PRIMARY KEY CLUSTERED ( [OPref] ASC )
        WITH ( PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF,
               IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
               ALLOW_PAGE_LOCKS = ON ) ON [PRIMARY]
    )
ON  [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

---------------------batch job-------------------------------
DECLARE @ident INT
DECLARE @trigger1 INT ,
    @trigger2 INT
INSERT  INTO dbo.BAT_Job
        ( Name ,
          Desc1 ,
          ServiceType 
        )
VALUES  ( 'GetStationAssemblyListJob' , -- Name - varchar(100)
          'GetStationAssemblyListJob' , -- Desc1 - varchar(256)
          'GetStationAssemblyListJob'  -- ServiceType - varchar(256)
          
        )
SELECT  @ident = @@IDENTITY


INSERT  INTO dbo.BAT_JobParam
        ( JobId, ParamKey, ParamValue )
VALUES  ( @ident, -- JobId - int
          'UserCode', -- ParamKey - varchar(50)
          'su'  -- ParamValue - varchar(256)
          )

          
SELECT  *
FROM    dbo.BAT_Trigger
INSERT  INTO dbo.BAT_Trigger
        ( JobId ,
          Name ,
          Desc1 ,
          PrevFireTime ,
          NextFireTime ,
          RepeatCount ,
          Interval ,
          IntervalType ,
          TimesTriggered ,
          Status
                  
        )
VALUES  ( @ident , -- JobId - int
          'GetStationAssemblyListJob' , -- Name - varchar(100)
          '车辆物料A线' , -- Desc1 - varchar(256)
          '2014-03-03 09:11:36' , -- PrevFireTime - datetime
          '2014-03-03 09:11:36' , -- NextFireTime - datetime
          0 , -- RepeatCount - int
          1 , -- Interval - int
          0 , -- IntervalType - tinyint
          0 , -- TimesTriggered - int
          1  -- Status - tinyint
        )
SELECT  @trigger1 = @@IDENTITY
INSERT  INTO dbo.BAT_JobParam
        ( JobId, ParamKey, ParamValue )
VALUES  ( @trigger1, -- JobId - int
          'ProductLine', -- ParamKey - varchar(50)
          'RAA00'  -- ParamValue - varchar(256)
          )            
                  

SELECT  *
FROM    dbo.BAT_Trigger
INSERT  INTO dbo.BAT_Trigger
        ( JobId ,
          Name ,
          Desc1 ,
          PrevFireTime ,
          NextFireTime ,
          RepeatCount ,
          Interval ,
          IntervalType ,
          TimesTriggered ,
          Status
                  
        )
VALUES  ( @ident , -- JobId - int
          'GetStationAssemblyListJob' , -- Name - varchar(100)
          '车辆物料B线' , -- Desc1 - varchar(256)
          '2014-03-03 09:11:36' , -- PrevFireTime - datetime
          '2014-03-03 09:11:36' , -- NextFireTime - datetime
          0 , -- RepeatCount - int
          1 , -- Interval - int
          0 , -- IntervalType - tinyint
          0 , -- TimesTriggered - int
          1  -- Status - tinyint
                  
        )
SELECT  @trigger2 = @@IDENTITY
INSERT  INTO dbo.BAT_JobParam
        ( JobId, ParamKey, ParamValue )
VALUES  ( @trigger2, -- JobId - int
          'ProductLine', -- ParamKey - varchar(50)
          'RAB00'  -- ParamValue - varchar(256)
          )
------------------------menu & permission------------------------------
INSERT  dbo.ACC_Permission
        ( Code ,
          Desc1 ,
          Category 
        )
VALUES  ( 'Url_Documentary_View' , -- Code - varchar(50)
          '跟单' , -- Desc1 - varchar(100)
          'Production'  -- Category - varchar(50)
          
        )

SELECT  *
FROM    dbo.ACC_RolePermission

INSERT  INTO dbo.SYS_Menu
        ( Code ,
          Name ,
          Parent ,
          Seq ,
          Desc1 ,
          PageUrl ,
          ImageUrl ,
          IsActive
        )
VALUES  ( 'Url_Documentary_View' , -- Code - varchar(50)
          '跟单' , -- Name - varchar(50)
          'Menu.Production.Info' , -- Parent - varchar(50)
          206 , -- Seq - int
          '跟单' , -- Desc1 - varchar(50)
          '~/Documentary/Index' , -- PageUrl - varchar(256)
          '~/Content/Images/Nav/Default.png' , -- ImageUrl - varchar(256)
          1  -- IsActive - bit
        )