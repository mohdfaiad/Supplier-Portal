SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
--drop table SAP_CreateDN
CREATE TABLE [dbo].[SAP_CreateDN](
	[IpDetConfirmId] [int] NOT NULL,
	[OrderNo] [varchar](50) NULL,
	[IpNo] [varchar](50) NULL,
	[IpDetSeq] [int] NULL,
	[MATNR] [varchar](50) NULL,
	[ItemDesc] [varchar](100) NULL,
	[Uom] [varchar](5) NULL,
	[G_LFIMG] [decimal](18, 8) NULL,
	[WERKS] [varchar](50) NULL,
	[LGORT] [varchar](50) NULL,
	[EBELN] [varchar](50) NULL,
	[EBELP] [varchar](50) NULL,
	[EffDate] [datetime] NULL,
	[CreateUser] [varchar](50) NULL,
	[CreateDate] [datetime] NULL,
	[LastModifyUser] [varchar](50) NULL,
	[LastModifyDate] [datetime] NULL,
	[DNSTR] [varchar](50) NULL,
	[GISTR] [varchar](50) NULL,
	[VBELN_VL] [varchar](50) NULL,
	[ErrorCount] [int] NULL,
	[Message] [varchar](2000) NULL,
	[Version] [int] NULL,
 CONSTRAINT [PK_SAP_CreateDN_1] PRIMARY KEY CLUSTERED 
(
	[IpDetConfirmId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

/****** Object:  Table [dbo].[SAP_CancelCreateDN]    Script Date: 2014/11/27 15:55:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
--drop table SAP_CancelCreateDN
CREATE TABLE [dbo].[SAP_CancelCreateDN](
	[CancelIpDetConfirmId] [int] NOT NULL,
	[IpDetConfirmId] [int] NULL,
	[OrderNo] [varchar](50) NULL,
	[IpNo] [varchar](50) NULL,
	[IpDetSeq] [int] NULL,
	[MATNR] [varchar](50) NULL,
	[ItemDesc] [varchar](100) NULL,
	[Uom] [varchar](5) NULL,
	[G_LFIMG] [decimal](18, 8) NULL,
	[WERKS] [varchar](50) NULL,
	[LGORT] [varchar](50) NULL,
	[EBELN] [varchar](50) NULL,
	[EBELP] [varchar](50) NULL,
	[EffDate] [datetime] NULL,
	[CreateUser] [varchar](50) NULL,
	[CreateDate] [datetime] NULL,
	[LastModifyUser] [varchar](50) NULL,
	[LastModifyDate] [datetime] NULL,
	[DNSTR] [varchar](50) NULL,
	[GISTR] [varchar](50) NULL,
	[VBELN_VL] [varchar](50) NULL,
	[ErrorCount] [int] NULL,
	[Message] [varchar](2000) NULL,
	[Version] [int] NULL,
 CONSTRAINT [PK_SAP_CancelCreateDN] PRIMARY KEY CLUSTERED 
(
	[CancelIpDetConfirmId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


