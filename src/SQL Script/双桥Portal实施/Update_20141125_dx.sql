ALTER TABLE [dbo].[ORD_OrderMstr] DROP CONSTRAINT [FK_ORD_ORDE_REFERENCE_MD_CURRE2]
ALTER TABLE [dbo].[ORD_OrderMstr_0] DROP CONSTRAINT [FK_ORD_OrderMstr0_Currency_REFERENCE_MD_Currency_Code]
ALTER TABLE [dbo].[ORD_OrderMstr_1] DROP CONSTRAINT [FK_ORD_OrderMstr1_Currency_REFERENCE_MD_Currency_Code]
ALTER TABLE [dbo].[ORD_OrderMstr_2] DROP CONSTRAINT [FK_ORD_OrderMstr2_Currency_REFERENCE_MD_Currency_Code]
ALTER TABLE [dbo].[ORD_OrderMstr_3] DROP CONSTRAINT [FK_ORD_OrderMstr3_Currency_REFERENCE_MD_Currency_Code]
ALTER TABLE [dbo].[ORD_OrderMstr_4] DROP CONSTRAINT [FK_ORD_OrderMstr4_Currency_REFERENCE_MD_Currency_Code]
ALTER TABLE [dbo].[ORD_OrderMstr_5] DROP CONSTRAINT [FK_ORD_OrderMstr5_Currency_REFERENCE_MD_Currency_Code]
ALTER TABLE [dbo].[ORD_OrderMstr_6] DROP CONSTRAINT [FK_ORD_OrderMstr6_Currency_REFERENCE_MD_Currency_Code]
ALTER TABLE [dbo].[ORD_OrderMstr_7] DROP CONSTRAINT [FK_ORD_OrderMstr7_Currency_REFERENCE_MD_Currency_Code]
ALTER TABLE [dbo].[ORD_OrderMstr_8] DROP CONSTRAINT [FK_ORD_OrderMstr8_Currency_REFERENCE_MD_Currency_Code]
go

/****** Object:  Table [dbo].[ORD_IpDetConfirm]    Script Date: 2014/11/25 14:31:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
--drop table ORD_IpDetConfirm
CREATE TABLE [dbo].[ORD_IpDetConfirm](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[OrderNo] [varchar](50) NULL,
	[OrderType] [tinyint] NULL,
	[OrderSubType] [tinyint] NULL,
	[OrderDetId] [int] NULL,
	[OrderDetSeq] [int] NULL,
	[IpNo] [varchar](50) NULL,
	[IpDetId] [int] NULL,
	[IpDetSeq] [int] NULL,
	[Item] [varchar](50) NULL,
	[ItemDesc] [varchar](100) NULL,
	[Uom] [varchar](5) NULL,
	[BaseUom] [varchar](5) NULL,
	[UnitQty] [decimal](18, 8) NULL,
	[Qty] [decimal](18, 8) NULL,
	[PartyFrom] [varchar](50) NULL,
	[PartyTo] [varchar](50) NULL,
	[LocFrom] [varchar](50) NULL,
	[LocTo] [varchar](50) NULL,
	[ShipPlant] [varchar](50) NULL,
	[ShipLocation] [varchar](50) NULL,
	[IsCancel] [bit] NULL,
	[IsCreateDN] [bit] NULL,
	[MoveType] [varchar](50) NULL,
	[EBELN] [varchar](50) NULL,
	[EBELP] [varchar](50) NULL,
	[EffDate] [datetime] NULL,
	[CreateUser] [varchar](50) NULL,
	[CreateDate] [datetime] NULL,
 CONSTRAINT [PK_ORD_IpDetConfirm] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

CREATE NONCLUSTERED INDEX [IX_ORD_IpDetConfirm_IpDetId] ON [dbo].[ORD_IpDetConfirm]
(
	[IpDetId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

--drop table ORD_CancelIpDetConfirm
CREATE TABLE [dbo].[ORD_CancelIpDetConfirm](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IpDetConfirmId] [int],
	[OrderNo] [varchar](50) NULL,
	[OrderType] [tinyint] NULL,
	[OrderSubType] [tinyint] NULL,
	[OrderDetId] [int] NULL,
	[OrderDetSeq] [int] NULL,
	[IpNo] [varchar](50) NULL,
	[IpDetId] [int] NULL,
	[IpDetSeq] [int] NULL,
	[Item] [varchar](50) NULL,
	[ItemDesc] [varchar](100) NULL,
	[Uom] [varchar](5) NULL,
	[BaseUom] [varchar](5) NULL,
	[UnitQty] [decimal](18, 8) NULL,
	[Qty] [decimal](18, 8) NULL,
	[PartyFrom] [varchar](50) NULL,
	[PartyTo] [varchar](50) NULL,
	[LocFrom] [varchar](50) NULL,
	[LocTo] [varchar](50) NULL,
	[ShipPlant] [varchar](50) NULL,
	[ShipLocation] [varchar](50) NULL,
	[IsCreateDN] [bit] NULL,
	[MoveType] [varchar](50) NULL,
	[EBELN] [varchar](50) NULL,
	[EBELP] [varchar](50) NULL,
	[EffDate] [datetime] NULL,
	[CreateUser] [varchar](50) NULL,
	[CreateDate] [datetime] NULL,
 CONSTRAINT [PK_ORD_CancelIpDetConfirm] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO