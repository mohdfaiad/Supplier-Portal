
if exists(select * from sysobjects where name ='FIS_YieldReturn')
	drop table FIS_YieldReturn
go
Create table FIS_YieldReturn
(
	Id int identity(1,1) primary key,
	IpNo varchar(50) not null, --�ͻ�����/�˻�����
	ArriveTime DateTime not	null, --Ԥ�Ƶ���ʱ��
	PartyFrom varchar(50) not null, --Buff�˻�ΪBuff���롣	����������		
	PartyTo	varchar(50) not	null,--LOC����	���շ�����
	Dock varchar(100)  null,--		�ջ�����
	IpCreateDate DateTime not null,--	��������
	Seq	varchar(50)	not null,--	�к� 
	Item varchar(50) not null,-- �����
	ManufactureParty varchar(50)  null,-- ������/Ʒ��
	Qty	Decimal(18,8) not null,-- �ͻ���
	IsConsignment bit not null ,--�Ƿ����
	CreateDate datetime not null,
	CreateDATDate datetime  null,
	DATFileName varchar(255)
)
go


insert into sys_menu values
('Url_OrderMstr_Procurement_Ship','����','Url_OrderMstr_Procurement_Return',25,'����','~/ProcurementOrder/ShipIndex','~/Content/Images/Nav/Default.png',1)
go
insert into acc_permission values
('Url_OrderMstr_Procurement_Ship','����','Procurement')
go

set Identity_Insert BAT_Job on
insert into BAT_Job(Id, Name, Desc1, ServiceType) values(230, 'LesYieldReturnDATJob', 'LesYieldReturnDATJob', 'LesYieldReturnDATJob')
set Identity_Insert BAT_Job off
go
insert into BAT_JobParam(JobId, ParamKey, ParamValue) values(230, 'UserCode', 'su')
go
set Identity_Insert BAT_Trigger on
insert into BAT_Trigger(Id, JobId, Name, Desc1, PrevFireTime, NextFireTime, RepeatCount, Interval, IntervalType, TimesTriggered, Status) 
values(230, 230, 'LesYieldReturnDAT', 'Les�����˻����ļ�', GETDATE(), GETDATE(), 0, 10, 2, 0, 1)
set Identity_Insert BAT_Trigger off
go
insert into BAT_TriggerParam(TriggerId,ParamKey,ParamValue) values (230,'SystemCodes','PPC008')
go

insert into FIS_FtpCtrl values
('10.86.128.128',21,'infuser','infuser','INTERFACE/TNT/FILEOUT/YieldReturn/OutTemp','INTERFACE/TNT/FILEOUT/YieldReturn','*.DAT','C:\\DAT\\YieldReturn\\OutTemp','C:\\DAT\\YieldReturn','OUT',null,null,null)
go

insert into FIS_OutboundCtrl values
('PPC008','C:\DAT\YieldReturn','com.Sconit.Service.FIS.Impl.YieldReturnDATMgrImpl','C:\DAT\YieldReturnFolder',4,'C:\Temp','UTF-8',null,null,1,0,null,null,null,null,null)
go