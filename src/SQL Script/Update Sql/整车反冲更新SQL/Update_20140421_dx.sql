IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CUST_OrderBomDetOnLine]') AND type in (N'U'))
DROP TABLE [dbo].[CUST_OrderBomDetOnLine]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[CUST_OrderBomDetOnLine](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Effdate] [datetime] NULL,
	[Region] [varchar](50) NULL,
	[Location] [varchar](50) NULL,
	[AUFNR] [varchar](50) NULL,
	[Item] [varchar](50) NULL,
	[ItemDesc] [varchar](100) NULL,
	[Uom] [varchar](5) NULL,
	[Qty] [decimal](18, 8) NULL,
	[FGItem] [varchar](50) NULL,
	[ProdLine] [varchar](50) NULL,
	[MoveType] [varchar](50) NULL,
	[CreateDate] [datetime] NULL,
	[CreateUser] [int] NULL,
	[CreateUserNm] [varchar](100) NULL,
	[LastModifyDate] [datetime] NULL,
	[LastModifyUser] [int] NULL,
	[LastModifyUserNm] [varchar](100) NULL,
	[Version] [int] NULL,
	[ErrorCount] [int] NULL,
	[Status] [tinyint] NULL,
	[ReserveNo] [varchar](50) NULL,
	[ReserveLine] [varchar](50) NULL,
	[GW] [varchar](50) NULL,
	[PLNFL] [varchar](50) NULL,
	[VORNR] [varchar](50) NULL,
	[AUFPL] [varchar](50) NULL,
	[SAPStatus] [tinyint] NULL,
	[SAPErrorCount] [int] NULL
 CONSTRAINT [PK_CUST_OrderBomDetOnLine] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


