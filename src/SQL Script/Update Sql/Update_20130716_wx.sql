insert into sys_menu values ('Menu.Kanban.Trans','����','Menu.Kanban',4000,'����','','~/Content/Images/Nav/Trans.png',1)
insert into sys_menu values ('Url_KanbanCard_Kanban_View','���忨��ѯ','Menu.Kanban.Info',1000,'Url_KanbanCard_Kanban_View','~/KanbanCard/Index','~/Content/Images/Nav/Default.png',1)
insert into sys_menu values ('Url_KanbanCard_New','�������忨','Menu.Kanban.Trans',6000,'�������忨','~/KanbanCard/New','~/Content/Images/Nav/Default.png',1)
insert into sys_menu values ('Url_KanbanCard_Scan','ɨ�迴�忨','Menu.Kanban.Trans',4000,'ɨ�迴�忨','~/KanbanCard/Scan','~/Content/Images/Nav/Default.png',1)
insert into sys_menu values ('Url_KanbanScan_View','ɨ���¼','Menu.Kanban.Info',2000,'ɨ���¼','~/KanbanScan/Index','~/Content/Images/Nav/Default.png',1)
insert into sys_menu values ('Menu.Kanban.Info','��Ϣ','Menu.Kanban',5000,'��Ϣ','','~/Content/Images/Nav/Info.png',1)
insert into sys_menu values ('Menu.Kanban','ʵ�忴��',NULL,6000,'ʵ�忴��',null,'~/Content/Images/Nav/Procurement.png',1)
go
insert into acc_permissioncategory  values('Kanban','ʵ�忴��',1)
go

insert into acc_permission values('Url_KanbanCard_Kanban_View','���忨��ѯ','Kanban')
insert into acc_permission values('Url_KanbanCard_New','�������忨','Kanban')
insert into acc_permission values('Url_KanbanCard_Scan','ɨ�迴�忨','Kanban')
insert into acc_permission values('Url_KanbanScan_View','ɨ���¼','Kanban')
go

alter table scm_flowdet add CycloidAmount int null
go
update scm_flowdet set cycloidamount=0 where cycloidamount is null
go



