alter table scm_flowmstr add VirtualOpRef varchar(50) null
go

alter table scm_flowstrategy add WaitTime decimal(18,8) null
go

alter table scm_flowstrategy add WaitBatch int null
go


update sys_menu set name ='����������',desc1 ='����������' where code ='Url_WorkingCalendar_View'
update acc_permission set desc1 ='�鿴����׼��������' where code ='Url_WorkingCalendar_View'
update acc_permission set desc1 ='�༭����������' where code ='Url_WorkingCalendar_Edit'
update acc_permission set desc1 ='ɾ������������' where code ='Url_WorkingCalendar_Delete'
go

update CUST_ProductLineMap set IsActive = 1 where IsActive is null
go
alter table CUST_ProductLineMap alter column IsActive bit not null
go

update sys_menu set name ='������������ӳ��',desc1='������������ӳ��' where code ='Url_CUST_ProductLineMap_View'
update acc_permission set desc1='������������ӳ��' where code ='Url_CUST_ProductLineMap_View'
go

insert into sys_menu values
('Url_CUST_VanProductLineMap_View','����������ӳ��','Menu.Production.Setup',491,'����������ӳ��','~/VanProductLineMap/Index','~/Content/Images/Nav/Default.png',1)
insert into acc_permission values('Url_CUST_VanProductLineMap_View','����������ӳ��','Production')
go
