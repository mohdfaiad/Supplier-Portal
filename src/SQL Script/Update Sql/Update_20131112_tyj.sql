if exists(select * from sys.objects where type='U' AND name='LOG_DistributionRequisition') 
drop table LOG_DistributionRequisition
go
create table LOG_DistributionRequisition
(
	[Id] [int] NOT NULL identity(1,1),
	[OrderDetId] [int] not null ,
	[OrderNo] [varchar](50) NOT NULL,
	[Priority] [tinyint] NOT NULL,
	[ExtNo] [varchar](50) NULL,
	[ExtSeq] [varchar](50) NULL,
	[Item] [varchar](50) NOT NULL,
	[ItemDesc] [varchar](100) NOT NULL,
	[RefItemCode] [varchar](50) NULL,
	[Uom] [varchar](5) NOT NULL,
	[BaseUom] [varchar](5) NOT NULL,
	[UC] [decimal](18, 8) NOT NULL,
	[UCDesc] [varchar](50) NULL,
	[MinUC] [decimal](18, 8) NOT NULL,
	[Container] [varchar](50) NULL,
	[ContainerDesc] [varchar](50) NULL,
	[OrderQty] [decimal](18, 8) NOT NULL,
	[RecQty] [decimal](18, 8) NOT NULL,
	PartyFrom  [varchar](50) NULL,
	PartyFromNm  [varchar](50) NULL,
	PartyTo  [varchar](50) NULL,
	PartyToNm  [varchar](50) NULL,
	[LocFrom] [varchar](50) NULL,
	[LocFromNm] [varchar](100) NULL,
	[LocTo] [varchar](50) NULL,
	[LocToNm] [varchar](100) NULL,
	Flow  [varchar](50) NULL,
	FlowDesc  [varchar](50) NULL,
	[CreateUser] [int] NOT NULL,
	[CreateUserNm] [varchar](100) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[LastModifyUser] [int] NOT NULL,
	[LastModifyUserNm] [varchar](100) NOT NULL,
	[LastModifyDate] [datetime] NOT NULL,
	[Version] [int] NOT NULL,
	[BinTo] [varchar](50) NULL,
)
go
insert into SYS_Menu values('Url_Distribution_Requisition','���۵��ֹ�����','Menu.Distribution.Trans',80,'���۵��ֹ�����',null,'~/Content/Images/Nav/Default.png',1)
go
insert into SYS_Menu values('Url_DistributionRequisition_NewIndex','����','Url_Distribution_Requisition',10,'�����ֹ�����','~/DistributionRequisition/NewIndex','~/Content/Images/Nav/Default.png',1)
go
insert into ACC_Permission values('Url_DistributionRequisition_NewIndex','�����ֹ�����','Distribution')
insert into SYS_Menu values('Url_DistributionRequisition_Log','�ֹ�������־','Url_Distribution_Requisition',20,'�ֹ�������־','~/DistributionRequisition/LogIndex','~/Content/Images/Nav/Default.png',1)
go
insert into ACC_Permission values('Url_DistributionRequisition_Log','�ֹ�������־','Distribution')