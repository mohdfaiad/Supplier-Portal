update acc_permission set desc1 ='������������ӳ��' where code ='Url_CUST_ProductLineMap_View'
go
insert into acc_permission values('Url_CUST_ProductLineMap_Edit','�༭������������ӳ��','Production')
go
insert into acc_permission values('Url_CUST_VanProductLineMap_Edit','�༭����������ӳ��','Production')
go

delete from ACC_RolePermission where permissionid = (select id from acc_permission where code ='Url_WorkingCalendar_Delete')
go
delete from acc_userpermission where permissionid = (select id from acc_permission where code ='Url_WorkingCalendar_Delete')
go
delete from acc_permission where code ='Url_WorkingCalendar_Delete'
go
delete from ACC_RolePermission where permissionid = (select id from acc_permission where code ='Url_ProdLineWorkingCalendar_Delete')
go
delete from acc_userpermission where permissionid = (select id from acc_permission where code ='Url_ProdLineWorkingCalendar_Delete')
go
delete from acc_permission where code ='Url_ProdLineWorkingCalendar_Delete'
go

update acc_permission set Category ='Production',Desc1 ='����'+Desc1 where code in ('Url_WorkingCalendar_Edit','Url_WorkingCalendar_View')
go


alter table PRD_MultiSupplySupplier add Proportion varchar(100)
go
alter table PRD_MultiSupplyItem add SubstituteGroup varchar(50) null
go