IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SAP_ProdBomDetUpdate]') AND type in (N'U'))
DROP TABLE [dbo].[SAP_ProdBomDetUpdate]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[SAP_ProdBomDetUpdate](
	[Id] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[BatchNo] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[Status] [tinyint] NOT NULL,
	[ErrorMessage] [varchar](500) NULL,
	[AUFNR] [varchar](50) NULL,
	[RSNUM] [int] NULL,
	[RSPOS] [int] NULL,
	[WERKS] [varchar](50) NULL,
	[MATERIAL] [varchar](50) NULL,
	[BISMT] [varchar](50) NULL,
	[MAKTX] [varchar](100) NULL,
	[DISPO] [varchar](50) NULL,
	[BESKZ] [varchar](50) NULL,
	[SOBSL] [varchar](50) NULL,
	[MEINS] [varchar](50) NULL,
	[MDMNG] [decimal](18, 8) NULL,
	[LGORT] [varchar](50) NULL,
	[BWART] [varchar](50) NULL,
	[AUFPL] [int] NULL,
	[PLNFL] [varchar](50) NULL,
	[VORNR] [varchar](50) NULL,
	[GW] [varchar](50) NULL,
	[WZ] [varchar](50) NULL,
	[ZOPID] [varchar](50) NULL,
	[ZOPDS] [varchar](50) NULL,
	[LIFNR] [varchar](50) NULL,
	[ICHARG] [varchar](50) NULL,
	[MDMNG_ORG] [decimal](18, 8) NULL,
	[RGEKZ] [varchar](50) NULL,
 CONSTRAINT [PK_SAP_ProdBomDetUpdate] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[SAP_ProdBomDetUpdate] ADD  DEFAULT (getdate()) FOR [CreateDate]
GO

ALTER TABLE [dbo].[SAP_ProdBomDetUpdate] ADD  DEFAULT (0) FOR [Status]
GO


