alter table PRD_LotNoScan add ItemDesc varchar(50) null
go
alter table PRD_LotNoTrace add ItemDesc varchar(50) null
go
update SYS_Menu set Desc1='��������ά��',Name='��������ά��' where Code='Url_Quota_View'
go
insert into SYS_Menu values('Url_QuotaCycleQty_View','���ѭ����ά��','Menu.Procurement.Setup',30,'���ѭ����ά��','~/Quota/CycleQtyIndex','~/Content/Images/Nav/Default.png',1)
go
insert into ACC_Permission values('Url_QuotaCycleQty_View','���ѭ����ά��','Procurement')
go
update sys_menu set isactive=0 where code='Url_FlowDetailImport_View'
go

update SYS_Menu set Desc1='�ɹ�·����ϸȱʧ����',Name='�ɹ�·����ϸȱʧ����',Parent='Menu.Procurement.Setup',Seq=5 where Code='Url_Cust_ScheduleLineItem'
go
update ACC_Permission set Category='Procurement' where Code='Url_Cust_ScheduleLineItem'
go
update SYS_Menu set Desc1='�ƿ�·����ϸȱʧ����',name='�ƿ�·����ϸȱʧ����',Parent='Menu.Inventory.Setup',Seq=350 where Code='Url_SnapshotFlowDet4LeanEngine_View'
go
update ACC_Permission set Category='Inventory' where Code='Url_SnapshotFlowDet4LeanEngine_View'
go
set identity_insert BAT_Job on
insert into BAT_Job(Id, Name, Desc1, ServiceType) values(260,'ImportSAPQuotaJob','����SAP���','ImportSAPQuotaJob')
set identity_insert BAT_Job off
insert into BAT_JobParam values(260,'UserCode','su')
go
set identity_insert BAT_Trigger on
insert into BAT_Trigger(Id, JobId, Name, Desc1, PrevFireTime, NextFireTime, RepeatCount, Interval, IntervalType, TimesTriggered, Status) values(260,260,'ImportSAPQuotaJob','����SAP���','2013-09-04 11:00:00.000','2013-09-05 01:00:00.000',0,1,4,0,1)
set identity_insert BAT_Trigger off
go
insert into BAT_TriggerParam values(260,'Plant','0084')
go
insert into ACC_Permission values('Url_QuotaCycleQty_Edit','���ѭ����ά��-�༭','Procurement')
go
update ACC_Permission set Desc1='���ѭ����ά��-��ѯ' where Code='Url_QuotaCycleQty_View'
go
insert into ACC_Permission values('Client_LotNoScan','���Ź���','Terminal')
go
 insert into ACC_Permission  values('Url_Distribution_PickShipConfirmation','�����鷢��-ȷ��','Distribution')
go
insert into SYS_Menu values('Url_Scheduling_DemandPlan','����ƻ�','Menu.ProcurementInfo',50,'����ƻ�','~/SupplierScheduling/DemandPlanIndex','~/Content/Images/Nav/Default.png',1)
go
insert into ACC_Permission values('Url_Scheduling_DemandPlan','�ƻ�Э��-����ƻ�','SupplierMenu')
go
update SYS_Menu set PageUrl='~/TransferOrder/Index/10' where Code='Url_TransferOrder_View'
go
update SYS_Menu set PageUrl='~/TransferOrder/Index/20' where Code='Url_OrderMstr_Procurement_Import'
go
update SYS_Menu set PageUrl='~/TransferOrder/Index/30' where Code='Url_OrderMstr_Procurement_ReturnNew'
go
update SYS_Menu set PageUrl='~/TransferOrder/Index/40' where Code='Url_OrderMstr_Procurement_ReturnQuickNew'

