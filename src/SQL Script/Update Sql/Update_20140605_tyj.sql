SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CUST_FlowRelationship]') AND type in (N'U'))
DROP TABLE [dbo].[CUST_FlowRelationship]
CREATE TABLE [dbo].[CUST_FlowRelationship](
	[Id] [int]  identity(1,1) primary key,
	[ProdLine] [varchar](50) NOT NULL,
	[Flow] [varchar](50) NOT NULL ,
	[CreateUser] [int] NOT NULL,
	[CreateUserNm] [varchar](100) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[LastModifyUser] [int] NOT NULL,
	[LastModifyUserNm] [varchar](100) NOT NULL,
	[LastModifyDate] [datetime] NOT NULL,
)
---------------------
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ORD_TyreOrderMaster]') AND type in (N'U'))
DROP TABLE [dbo].[ORD_TyreOrderMaster]
CREATE TABLE [dbo].[ORD_TyreOrderMaster](
	[TyreOrderNo] [varchar](50) NOT NULL primary key,
	[CreateUser] [int] NOT NULL,
	[CreateUserNm] [varchar](100) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[LastModifyUser] [int] NOT NULL,
	[LastModifyUserNm] [varchar](100) NOT NULL,
	[LastModifyDate] [datetime] NOT NULL,
)




------------------------------



/****** Object:  Table [dbo].[ORD_OrderDet]    Script Date: 05/27/2014 14:45:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ORD_TyreOrderDet]') AND type in (N'U'))
DROP TABLE [dbo].[ORD_TyreOrderDet]
CREATE TABLE [dbo].[ORD_TyreOrderDet](
	[Id] [int] IDENTITY(1,1) primary key,
	DetId int not null,
	[TyreOrderNo] [varchar](50) NOT NULL,
	[ProdNo] [varchar](50) NOT NULL,
	[RefOrderNo] [varchar](50) NOT NULL,
	[Flow] [varchar](50) NOT NULL,
	[FlowDescription] [varchar](50) NOT NULL,
	[ProdLine] [varchar](50) NOT NULL,
	[ProdLineDescription] [varchar](50) NOT NULL,
	[SeqGroup] [varchar](50)  NULL,
	[VanNo] [varchar](50) NOT NULL,
	[Item] [varchar](50) NOT NULL,
	[ItemDesc] [varchar](100) NOT NULL,
	[RefItemCode] [varchar](50) NULL,
	[Uom] [varchar](5) NOT NULL,
	[UC] [decimal](18, 8) NOT NULL,
	[OrderQty] [decimal](18, 8) NOT NULL,
	[ShipQty] [decimal](18, 8) NOT NULL,
	[RecQty] [decimal](18, 8) NOT NULL,
	[LocFrom] [varchar](50) NULL,
	[LocFromNm] [varchar](100) NULL,
	[LocTo] [varchar](50) NULL,
	[LocToNm] [varchar](100) NULL,
	[CompleteDate] [datetime] NOT NULL,
	[CreateUser] [int] NOT NULL,
	[CreateUserNm] [varchar](100) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[LastModifyUser] [int] NOT NULL,
	[LastModifyUserNm] [varchar](100) NOT NULL,
	[LastModifyDate] [datetime] NOT NULL,
) 

GO

-------------------
--------------------
insert into SYS_Menu values('Url_TyreOrder','��̥���߽���','Menu.Production.Trans',220,'��̥���߽���',null,'~/Content/Images/Nav/Default.png',1)
go
insert into SYS_Menu values('Url_FlowRelationshipList_View','��̥·��������ά��','Url_TyreOrder',60,'��̥·��������ά��','~/TyreOrder/FlowRelationshipList','~/Content/Images/Nav/Default.png',1)
go
insert into ACC_Permission values('Url_FlowRelationshipList_View','��̥·��������ά��','Production')
go
insert into SYS_Menu values('Url_TyreOrder_Receive','����','Url_TyreOrder',60,'����','~/TyreOrder/ReceiveIndex','~/Content/Images/Nav/Default.png',1)
go
insert into ACC_Permission values('Url_TyreOrder_Receive','��̥����-����','Production')
go
insert into SYS_Menu values('Url_TyreOrder_View','��ѯ','Url_TyreOrder',10,'��ѯ-��̥�ջ�','~/TyreOrder/Index','~/Content/Images/Nav/Default.png',1)
go
insert into ACC_Permission values('Url_TyreOrder_View','��̥���߽���-��ѯ','Production')
go
insert into SYS_Menu values('Url_TyreDetailOrder_View','��ϸ��ѯ','Url_TyreOrder',20,'��ϸ��ѯ','~/TyreOrder/DetailIndex','~/Content/Images/Nav/Default.png',1)
go
insert into ACC_Permission values('Url_TyreDetailOrder_View','��̥���߽���-��ϸ��ѯ','Production')
