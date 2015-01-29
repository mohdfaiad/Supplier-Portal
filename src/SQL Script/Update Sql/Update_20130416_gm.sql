CREATE TABLE [dbo].[ORD_PickTask](
	[PickId] [varchar](50) NOT NULL,
	[OrderNo] [varchar](50) NOT NULL,
	[OrdDetId] [int] NOT NULL,
	[DemandType] [tinyint] NOT NULL,
	[IsHold] [bit] NOT NULL,
	[Flow] [varchar](50) NULL,
	[FlowDesc] [varchar](100) NULL,
	[Item] [varchar](50) NULL,
	[ItemDesc] [varchar](100) NULL,
	[Uom] [varchar](5) NULL,
	[BaseUom] [varchar](5) NULL,
	[PartyFrom] [varchar](50) NULL,
	[PartyFromName] [varchar](100) NULL,
	[PartyTo] [varchar](50) NULL,
	[PartyToName] [varchar](100) NULL,
	[LocationFrom] [varchar](50) NULL,
	[LocationFromName] [varchar](100) NULL,
	[LocationTo] [varchar](50) NULL,
	[LocationToName] [varchar](100) NULL,
	[WindowTime] [datetime] NULL,
	[ReleaseDate] [datetime] NULL,
	[Supplier] [varchar](50) NULL,
	[SupplierName] [varchar](100) NULL,
	[UnitCount] [decimal](18, 8) NULL,
	[OrderedQty] [decimal](18, 8) NULL,
	[PickedQty] [decimal](18, 8) NULL,
	[Picker] [varchar](50) NULL,
	[PrintCount] [int] NOT NULL,
	[Memo] [varchar](256) NULL,
	[CreateUser] [int] NOT NULL,
	[CreateUserNm] [varchar](100) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[LastModifyUser] [int] NOT NULL,
	[LastModifyUserNm] [varchar](100) NOT NULL,
	[LastModifyDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ORD_PickTask] PRIMARY KEY CLUSTERED 
(
	[PickId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[ORD_PickHu](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[PickId] [varchar](50) NOT NULL,
	[RepackHu] [varchar](50) NOT NULL,
	[CreateUser] [int] NOT NULL,
	[CreateUserNm] [varchar](100) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[LastModifyUser] [int] NOT NULL,
	[LastModifyUserNm] [varchar](100) NOT NULL,
	[LastModifyDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ORD_PickHu] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[ORD_PickResult](
	[ResultId] [varchar](50) NOT NULL,
	[PickId] [varchar](50) NOT NULL,
	[PickedHu] [varchar](50) NULL,
	[HuQty] [decimal](18, 8) NULL,
	[PickedQty] [decimal](18, 8) NULL,
	[Picker] [varchar](50) NULL,
	[PickDate] [datetime] NULL,
	[AsnNo] [varchar](50) NULL,
	[Memo] [varchar](256) NULL,
	[CreateUser] [int] NOT NULL,
	[CreateUserNm] [varchar](100) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[LastModifyUser] [int] NOT NULL,
	[LastModifyUserNm] [varchar](100) NOT NULL,
	[LastModifyDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ORD_PickResult] PRIMARY KEY CLUSTERED 
(
	[ResultId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[ORD_ShipList](
	[ShipNo] [varchar](50) NOT NULL,
	[Vehicle] [varchar](50) NULL,
	[Shipper] [varchar](50) NULL,
	[Status] [tinyint] NULL,
	[CreateUser] [int] NOT NULL,
	[CreateUserNm] [varchar](100) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[LastModifyUser] [int] NOT NULL,
	[LastModifyUserNm] [varchar](100) NOT NULL,
	[LastModifyDate] [datetime] NOT NULL,
	[CloseDate] [datetime] NULL,
	[CloseUser] [int] NULL,
	[CloseUserNm] [varchar](100) NULL,
	[CancelDate] [datetime] NULL,
	[CancelUser] [int] NULL,
	[CancelUserNm] [varchar](100) NULL,
 CONSTRAINT [PK_ORD_ShipList] PRIMARY KEY CLUSTERED 
(
	[ShipNo] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

alter table SCM_FlowDet add IsCreatePickList bit null
update SCM_FlowDet set IsCreatePickList = 0

alter table ORD_OrderDet add IsCreatePickList bit null
go
alter table ORD_OrderDet_0 add IsCreatePickList bit null
go
alter table ORD_OrderDet_1 add IsCreatePickList bit null
go
alter table ORD_OrderDet_2 add IsCreatePickList bit null
go
alter table ORD_OrderDet_3 add IsCreatePickList bit null
go
alter table ORD_OrderDet_4 add IsCreatePickList bit null
go
alter table ORD_OrderDet_5 add IsCreatePickList bit null
go
alter table ORD_OrderDet_6 add IsCreatePickList bit null
go
alter table ORD_OrderDet_7 add IsCreatePickList bit null
go
alter table ORD_OrderDet_8 add IsCreatePickList bit null
go

insert into sys_menu values
('Url_PickTask_View','��ѯ�������','Url_PickList',200,'��ѯ�������','~/PickTask/Index','~/Content/Images/Nav/Default.png',1)
go
insert into acc_permission values('Url_PickTask_View','��ѯ�������','Distribution')
go

insert into sys_menu values
('Url_PickTask_Handle','�����������','Url_PickList',203,'�����������','~/PickTask/Handle','~/Content/Images/Nav/Default.png',1)
go
insert into acc_permission values('Url_PickTask_Handle','�����������','Distribution')
go

insert into sys_menu values
('Url_PickTask_New','�����������','Url_PickList',205,'�����������','~/PickTask/New','~/Content/Images/Nav/Default.png',1)
go
insert into acc_permission values('Url_PickTask_New','�����������','Distribution')
go

insert into sys_menu values
('Url_PickResult_View','������','Url_PickList',210,'������','~/PickResult/Index','~/Content/Images/Nav/Default.png',1)
go
insert into acc_permission values('Url_PickResult_View','������','Distribution')
go

insert into sys_menu values
('Url_ShipList_View','�˵�','Url_PickList',220,'�˵�','~/ShipList/Index','~/Content/Images/Nav/Default.png',1)
go
insert into acc_permission values('Url_ShipList_View','�˵�','Distribution')
go

insert into acc_permission values('Url_PickTask_Hold','������','Distribution')
go
insert into acc_permission values('Url_PickTask_Unhold','�ⶳ���','Distribution')
go
insert into acc_permission values('Url_PickTask_Assign','���ɼ��','Distribution')
go
insert into acc_permission values('Url_PickTask_Print','��ӡ��������','Distribution')
go
insert into acc_permission values('Url_PickTask_Pick','���','Distribution')
go
insert into acc_permission values('Url_PickTask_Move','�ֲ�','Distribution')
go
insert into acc_permission values('Url_PickTask_Ship','����','Distribution')
go
insert into acc_permission values('Url_PickResult_Cancel','ȡ�����','Distribution')
go
insert into acc_permission values('Url_ShipList_New','�����˵�','Distribution')
go
insert into acc_permission values('Url_ShipList_Print','��ӡ�˵�','Distribution')
go
insert into acc_permission values('Url_ShipList_Cancel','ȡ���˵�','Distribution')
go
insert into acc_permission values('Url_ShipList_Close','�ر��˵�','Distribution')
go

alter table ORD_IpMstr add ShipNo varchar(50) null
go
alter table ORD_IpMstr add Vehicle varchar(50) null
go
alter table ORD_IpMstr_0 add ShipNo varchar(50) null
go
alter table ORD_IpMstr_0 add Vehicle varchar(50) null
go
alter table ORD_IpMstr_1 add ShipNo varchar(50) null
go
alter table ORD_IpMstr_1 add Vehicle varchar(50) null
go
alter table ORD_IpMstr_2 add ShipNo varchar(50) null
go
alter table ORD_IpMstr_2 add Vehicle varchar(50) null
go
alter table ORD_IpMstr_3 add ShipNo varchar(50) null
go
alter table ORD_IpMstr_3 add Vehicle varchar(50) null
go
alter table ORD_IpMstr_4 add ShipNo varchar(50) null
go
alter table ORD_IpMstr_4 add Vehicle varchar(50) null
go
alter table ORD_IpMstr_5 add ShipNo varchar(50) null
go
alter table ORD_IpMstr_5 add Vehicle varchar(50) null
go
alter table ORD_IpMstr_6 add ShipNo varchar(50) null
go
alter table ORD_IpMstr_6 add Vehicle varchar(50) null
go
alter table ORD_IpMstr_7 add ShipNo varchar(50) null
go
alter table ORD_IpMstr_7 add Vehicle varchar(50) null
go
alter table ORD_IpMstr_8 add ShipNo varchar(50) null
go
alter table ORD_IpMstr_8 add Vehicle varchar(50) null
go

insert into SYS_EntityPreference values(11040,70,0,'����ϵͳ��ʶ',1,'�û� ����','2011-01-01 00:00:00.000',1,'�û� ����','2011-01-01 00:00:00.000')

insert into SYS_Menu values('Url_OrderItemTrace_New','����ˢ��','Menu.Quality.Trans',500,'����ˢ��',null,'~/Content/Images/Nav/Default.png',1)

insert into ACC_Permission values('Url_OrderItemTrace_New','����ˢ��','Quality')
