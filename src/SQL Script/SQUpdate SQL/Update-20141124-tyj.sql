SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SAP_IpShipInfo]') AND type in (N'U'))
DROP TABLE [dbo].[SAP_IpShipInfo]
CREATE TABLE [dbo].[SAP_IpShipInfo](
	Id int identity(1,1) primary key,
	EBELN [varchar](50)  NULL,
	EBELP [varchar](50)  NULL,
	LESID  int NULL,
	ASNNR [varchar](50)  NULL,
	MATNR [varchar](50)  NULL,
	LGORT [varchar](50)  NULL,--发货仓库
	G_LFIMG decimal(18,8)  NULL,--数量
	VBELN_VL [varchar](50)  NULL,--交货单号
	DNSTR [varchar](50)  NULL,--创建状态
	GISTR [varchar](50)  NULL,--交货状态
	IsDelivery bit not null,
	DeliveryDate datetime null,
	CreateOrCancel tinyint not null,
	ErrorCount int not null,
	ErrorMessage [varchar](50)  NULL,--错误消息
	[CreateUserName] [varchar](100) NOT NULL,
	[CreateDate] datetime NOT NULL,
	[LastModifyUserName] [varchar](100) NOT NULL,
	[LastModifyDate] datetime NOT NULL,
) 


alter table SCM_FlowMstr add IsAutoAsnShipConfirm bit default(0) not null
go
alter table SCM_FlowMstr add AsnShipConfirmMoveType varchar(50) 
go
alter table SCM_FlowMstr add IsAsnShipConfirmCreateDN bit default(0)  not null
go 

