update sys_menu set name ='�˻�',desc1='�˻�' where code ='Url_OrderMstr_Procurement_ReturnNew'
update acc_permission set desc1='Ҫ���˻����˻�' where code ='Url_OrderMstr_Procurement_ReturnNew'
go

insert into sys_menu values
('Url_OrderMstr_Procurement_ReturnQuickNew','�����˻�','Url_OrderMstr_Procurement_Return',21,'�����˻�','~/ProcurementOrder/ReturnQuickNew','~/Content/Images/Nav/Default.png',1)
go
insert into acc_permission values
('Url_OrderMstr_Procurement_ReturnQuickNew','Ҫ���˻��������˻�','Procurement')
go

update sys_menu set name ='�˻�',desc1='�˻�' where code ='Url_OrderMstr_Distribution_ReturnNew'
update acc_permission set desc1='�����˻����˻�' where code ='Url_OrderMstr_Distribution_ReturnNew'
go

insert into sys_menu values
('Url_OrderMstr_Distribution_ReturnQuickNew','�����˻�','Url_OrderMstr_Distribution_Return',21,'�����˻�','~/DistributionOrder/ReturnQuickNew','~/Content/Images/Nav/Default.png',1)
go
insert into acc_permission values
('Url_OrderMstr_Distribution_ReturnQuickNew','�����˻��������˻�','Distribution')
go


set Identity_Insert BAT_Job on
insert into BAT_Job(Id, Name, Desc1, ServiceType) values(210, 'LesLocationDATJob', 'LesLocationDATJob', 'LesLocationDATJob')
set Identity_Insert BAT_Job off
go
insert into BAT_JobParam(JobId, ParamKey, ParamValue) values(210, 'UserCode', 'su')
go
set Identity_Insert BAT_Trigger on
insert into BAT_Trigger(Id, JobId, Name, Desc1, PrevFireTime, NextFireTime, RepeatCount, Interval, IntervalType, TimesTriggered, Status) 
values(210, 210, 'LesLocationDAT', 'Les������λ�ļ�', GETDATE(), GETDATE(), 0, 10, 2, 0, 1)
set Identity_Insert BAT_Trigger off
go
insert into BAT_TriggerParam(TriggerId,ParamKey,ParamValue) values (210,'SystemCodes','PPC006')
go

insert into FIS_FtpCtrl values
('10.86.128.128',21,'infuser','infuser','INTERFACE/TNT/FILEOUT/Location/OutTemp','INTERFACE/TNT/FILEOUT/Location','*.DAT','C:\\DAT\\Location\\OutTemp','C:\\DAT\\Location','OUT',null,null,null)
go

insert into FIS_OutboundCtrl values
('PPC006','C:\DAT\Location','com.Sconit.Service.FIS.Impl.LocationDATMgrImpl','C:\DAT\LocationFolder',4,'C:\Temp','UTF-8',null,null,1,0,null,null,null,null,null)
go

insert into acc_permission values ('Url_AssemblyProductionFlow_Edit','���������߱༭','Production')
insert into acc_permission values ('Url_AssemblyProductionFlow_Delete','����������ɾ��','Production')
go

if exists(select * from sysobjects where name ='FIS_CreateBarCode')
	drop table FIS_CreateBarCode
go
CREATE TABLE FIS_CreateBarCode
(
	Id int identity(1,1) not null primary key,
	HuId varchar(50) not null,
	LotNo varchar(50) not null,
	Item varchar(50) not null,
	Qty decimal(18,8) not null,
	ManufactureParty varchar(50) not null,
	ASN varchar(50) null,
	CreateDate datetime not null,
	CreateDATDate datetime null,
	DATFileName varchar(255)
)
GO

if exists(select * from sysobjects where name ='FIS_CancelReceiptMaster')
	drop table FIS_CancelReceiptMaster
go
create table FIS_CancelReceiptMaster
(
	Id int identity(1,1) not null primary key,
	WMSNo varchar(50) not null,
	WMSSeq int null,
	RecQty decimal(18,8) not null,
	CreateDate datetime not null,
	CreateDATDate datetime null,
	DATFileName varchar(255) 
)
go

set Identity_Insert BAT_Job on
insert into BAT_Job(Id, Name, Desc1, ServiceType) values(220, 'LesCancelReceiptMasterDATJob', 'LesCancelReceiptMasterDATJob', 'LesCancelReceiptMasterDATJob')
set Identity_Insert BAT_Job off
go
insert into BAT_JobParam(JobId, ParamKey, ParamValue) values(220, 'UserCode', 'su')
go
set Identity_Insert BAT_Trigger on
insert into BAT_Trigger(Id, JobId, Name, Desc1, PrevFireTime, NextFireTime, RepeatCount, Interval, IntervalType, TimesTriggered, Status) 
values(220, 220, 'LesCancelReceiptMasterDAT', 'Les�����������ļ�', GETDATE(), GETDATE(), 0, 10, 2, 0, 1)
set Identity_Insert BAT_Trigger off
go
insert into BAT_TriggerParam(TriggerId,ParamKey,ParamValue) values (220,'SystemCodes','PPC007')
go

insert into FIS_FtpCtrl values
('10.86.128.128',21,'infuser','infuser','INTERFACE/TNT/FILEOUT/CancelReceiptMaster/OutTemp','INTERFACE/TNT/FILEOUT/CancelReceiptMaster','*.DAT','C:\\DAT\\CancelReceiptMaster\\OutTemp','C:\\DAT\\CancelReceiptMaster','OUT',null,null,null)
go

insert into FIS_OutboundCtrl values
('PPC007','C:\DAT\CancelReceiptMaster','com.Sconit.Service.FIS.Impl.CancelReceiptMasterDATMgrImpl','C:\DAT\CancelReceiptMasterFolder',4,'C:\Temp','UTF-8',null,null,1,0,null,null,null,null,null)
go







