
create table FIS_CreateProcurementOrderDAT
(
Id				int identity(1,1) primary key not null,
OrderNo			varchar(50)					  not null,
Van				varchar(50)						  null,
OrderStrategy	int							 not null,
StartTime		datetime					not null,
WindowTime		datetime					not null,
Priority		int							not null,
Sequence		varchar(50)					null,
PartyFrom		varchar(50)					not null,
PartyTo			varchar(50)					not null,
Dock			varchar(100)				null,
CreateDate		datetime					not null,
Flow			varchar(50)					not null,
LineSeq			int							not null,
Item			varchar(50)					not null,
ManufactureParty varchar(50)				null,
LocationTo		 varchar(50)				null,
Bin				varchar(50)					null,
OrderedQty		decimal(18,8)				not null,
IsShipExceed	bit							not null,
FileName		varchar(50)					 null,
IsCreateDat		bit							not null
)
---------------- job
/* ���� */
go
insert into BAT_Job values('LesCreateSeqOrderDATJob','LES��������DAT','LesCreateSeqOrderDATJob')
go
insert into BAT_JobParam values(241,'UserCode','su')
go
insert into BAT_Trigger values(241,'LesCreateSeqOrderDATJob','LES��������DAT','2013-07-05 12:10:00.000','2013-07-05 12:15:00.000',0,5,2,0,1) 
go
insert into BAT_TriggerParam values(241,'SystemCodes','PPC010')
go
/* �¸�ʽҪ���� */
insert into BAT_Job values('LesCreateProcurementOrderDATJob','�¸�ʽҪ����','LesCreateProcurementOrderDATJob')
go
insert into BAT_JobParam values(242,'UserCode','su')
go
insert into BAT_Trigger values(242,'LesCreateProcurementOrderDATJob','LES����Ҫ����DAT','2013-07-04 20:00:00.000','2013-07-04 20:00:00.000',0,5,2,0,1)
go
insert into BAT_TriggerParam values(242,'SystemCodes','PPC011')
go
/* ·�ߴ���� */
insert into BAT_Job values('SeqKitFlowDATJob','����KIT��·�ߴ����','SeqKitFlowDATJob')
go
insert into BAT_JobParam values(243,'UserCode','su')
go
insert into BAT_Trigger values(243,'SeqKitFlowDATJob','·�ߴ����DAT','2013-07-04 20:00:00.000','2013-07-05 20:00:00.000',0,1,4,0,1)
go
insert into BAT_TriggerParam values(243,'SystemCodes','PPC012')
go
insert into BAT_Job values('LesCreateSeqOrderDATJob','LES��������DAT','LesCreateSeqOrderDATJob')
go
/*�ϴ�����DAT�ļ�*/
go
insert into BAT_Job values('UploadAllDATJob','�ϴ�����DAT�ļ�','UploadAllDATJob')
go
insert into BAT_Trigger values(244,'UploadAllDATJob','�ϴ�����DAT�ļ�','2013-07-05 12:10:00.000','2013-07-05 12:15:00.000',0,5,2,0,1) 
go
---------------����ļ�������
/*�˻���*/
insert into FIS_OutboundCtrl values
('PPC008','C:\DAT\ASN','com.Sconit.Service.FIS.Impl.YieldReturnDATMgrImpl','C:\DAT\YieldReturnFolder',5,'C:\Temp','UTF-8',null,null,1,0,null,null,null,null,null)
go
/* Ҫ���� */
insert into FIS_OutboundCtrl values('PPC011','C:\DAT\LESORD','com.Sconit.Service.FIS.Impl.CreateProcurementOrderDATOutMgrImpl','C:\DAT\ORDFolder',6,'C:\Temp','UTF-8',null,null,1,0,null,null,null,null,null)
/* ���� */
insert into FIS_OutboundCtrl values('PPC010','C:\DAT\LESORD','com.Sconit.Service.FIS.Impl.CreateSeqOrderDATOutboundMgrImpl','C:\\DAT\\SEQFolder',7,'C:\Temp','UTF-8',null,null,1,0,null,null,null,null,null)
go
update FIS_OutboundCtrl set ArchiveFolder='C:\DAT\ORDFolder' where id=2
go
--/* �ջ��� */
--insert into FIS_OutboundCtrl values('PPC005','C:\DAT\LESLog','com.Sconit.Service.FIS.Impl.CreateSeqOrderDATOutboundMgrImpl','C:\\DAT\\SEQFolder',7,'C:\Temp','UTF-8',null,null,1,0,null,null,null,null,null)
/* ������ */
insert into FIS_OutboundCtrl values('PPC007','C:\DAT\LESLog','com.Sconit.Service.FIS.Impl.CancelReceiptMasterDATMgrImpl','C:\\DAT\\CancelFolder',8,'C:\Temp','UTF-8',null,null,1,0,null,null,null,null,null)
/* ���� */
insert into FIS_FtpCtrl values
('10.86.128.128',21,'infuser','infuser','INTERFACE_TEST/TNT/FILEOUT/LESbarcode/OutTemp','INTERFACE_TEST/TNT/FILEOUT/LESbarcode','*.DAT','C:\\DAT\\LESbarcode\\OutTemp','C:\\DAT\\LESbarcode','OUT',null,null,null)
go
insert into FIS_OutboundCtrl values('PPC005','C:\DAT\LESbarcode','com.Sconit.Service.FIS.Impl.CreateBarCodeDATMgrImpl','C:\DAT\BarCodeFolder',9,'C:\Temp','UTF-8',null,null,1,0,null,null,null,null,null)
go
/*�����׼��װ*/
insert into FIS_FtpCtrl values
('10.86.128.128',21,'infuser','infuser','INTERFACE_TEST/TNT/FILEOUT/LESMASTERDATA/OutTemp','INTERFACE_TEST/TNT/FILEOUT/LESMASTERDATA','*.DAT','C:\\DAT\\LESMASTERDATA\\OutTemp','C:\\DAT\\LESMASTERDATA','OUT',null,null,null)
go
insert into FIS_OutboundCtrl values
('PPC009','C:\DAT\LESMASTERDATA','com.Sconit.Service.FIS.Impl.ItemStandardPackDATMgrImpl','C:\DAT\LESMASTERDATAFolder',10,'C:\Temp','UTF-8',null,null,1,0,null,null,null,null,null)
go
/*��λ��*/
insert into FIS_OutboundCtrl values
('PPC006','C:\DAT\LESMASTERDATA','com.Sconit.Service.FIS.Impl.LocationDATMgrImpl','C:\DAT\LESMASTERDATAFolder',11,'C:\Temp','UTF-8',null,null,1,0,null,null,null,null,null)
go
/*����KIT��·�ߴ����*/
insert into FIS_OutboundCtrl values
('PPC012','C:\DAT\LESMASTERDATA','com.Sconit.Service.FIS.Impl.SeqKitFlowDATMgrImpl','C:\DAT\LESMASTERDATAFolder',12,'C:\Temp','UTF-8',null,null,1,0,null,null,null,null,null)
go
insert into SYS_Menu values('Url_Supplier_SequenceOrder','����','Menu.SupplierMenu',65,'����',null,'~/Content/Images/Nav/Default.png',1)
go	
insert into SYS_Menu values('Url_Supplier_SequenceOrder_View','�鿴','Url_Supplier_SequenceOrder',100,'�鿴','~/SequenceMaster/Index','~/Content/Images/Nav/Default.png',1)
go	
insert into ACC_Permission values('Url_Supplier_SequenceOrder_View','����-�鿴','SupplierMenu')
go
update  BAT_Trigger set Interval=1 ,IntervalType=4 where id =210
go
alter table FIS_CreateSeqOrderDAT alter column uploadDate datetime null
go
alter table FIS_CreateSeqOrderDAT alter column IsCreateDat bit not null
