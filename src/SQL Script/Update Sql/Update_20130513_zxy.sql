
alter table PRD_MultiSupplyItem drop column [Proportion] 
go
alter table PRD_MultiSupplySupplier add [Proportion] varchar(100) NULL
go


alter table FIS_LesINLog add Qty decimal(18,8) null
go
alter table FIS_LesINLog add QtyMark bit null
go


if exists(select * from sysobjects where name ='FIS_ItemStandardPack')
	drop table FIS_ItemStandardPack
go
Create table FIS_ItemStandardPack
(
	Id int identity(1,1) primary key,
	FlowDetId int not null,
	Item varchar(50) not null, --���ϱ��(FlowDetail.Item)
	Pack varchar(50) null, --��װ����(FlowDetail.UCDesc)
	UC decimal(18,8) not null, --��װ����(FlowDetail.UC)
	IOType varchar(50) not null, -- O:�����װ I:����װ (LocationTo=1000 ��⣻ LocationFrom=1000 ����)
	Location char(4) not null,
	Plant char(4) not null,
	CreateDate datetime not null,
	CreateDATDate datetime  null,
	DATFileName varchar(255)
)
go


set Identity_Insert BAT_Job on
insert into BAT_Job(Id, Name, Desc1, ServiceType) values(240, 'LesItemStandardPackDATJob', 'LesItemStandardPackDATJob', 'LesItemStandardPackDATJob')
set Identity_Insert BAT_Job off
go
insert into BAT_JobParam(JobId, ParamKey, ParamValue) values(240, 'UserCode', 'su')
go
set Identity_Insert BAT_Trigger on
insert into BAT_Trigger(Id, JobId, Name, Desc1, PrevFireTime, NextFireTime, RepeatCount, Interval, IntervalType, TimesTriggered, Status) 
values(240, 240, 'LesItemStandardPackDAT', 'Les���������׼��װ�ļ�', GETDATE(), GETDATE(), 0, 10, 2, 0, 1)
set Identity_Insert BAT_Trigger off
go
insert into BAT_TriggerParam(TriggerId,ParamKey,ParamValue) values (240,'SystemCodes','PPC009')
go

insert into FIS_FtpCtrl values
('10.86.128.128',21,'infuser','infuser','INTERFACE/TNT/FILEOUT/ItemStandardPack/OutTemp','INTERFACE/TNT/FILEOUT/ItemStandardPack','*.DAT','C:\\DAT\\ItemStandardPack\\OutTemp','C:\\DAT\\ItemStandardPack','OUT',null,null,null)
go

insert into FIS_OutboundCtrl values
('PPC009','C:\DAT\ItemStandardPack','com.Sconit.Service.FIS.Impl.ItemStandardPackDATMgrImpl','C:\DAT\ItemStandardPackFolder',4,'C:\Temp','UTF-8',null,null,1,0,null,null,null,null,null)
go
