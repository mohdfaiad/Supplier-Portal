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
go

 update SYS_Menu set IsActive=0 where Code='Url_SequenceOrder_Detail_Distribution'
 go
 update SYS_Menu set IsActive=1 where Code='Url_SequenceOrder_Distribution'
 go
 update SYS_Menu set PageUrl='~/SequenceMaster/Index/10' where Code='Url_SequenceOrder_View'
 go
 update SYS_Menu set PageUrl='~/SequenceMaster/Index/20' where Code='Url_SequenceOrder_View_Distribution'
 go 
 update SYS_Menu set PageUrl='~/SequenceMaster/Index/30' where Code='Url_Supplier_SequenceOrder_View'
 go
 update ACC_Permission set Desc1='����-��ѯ' where Code='Url_SequenceOrder_View_Distribution'
 go

 