delete from acc_userpermission where permissionid = (select id from acc_permission where code ='Url_InSequenceGroup_View')
delete from acc_Rolepermission where permissionid = (select id from acc_permission where code ='Url_InSequenceGroup_View')
delete from acc_permission where code ='Url_InSequenceGroup_View'
delete from sys_menu where code ='Url_InSequenceGroup_View'
go

update sys_menu set name ='������',desc1='������' where code ='Url_SequenceGroup_View'
update acc_permission set desc1='������' where code ='Url_SequenceGroup_View'
go

insert into sys_menu values
('Url_OrderSeq_View','�����ѯ','Menu.Production.Info',205,'�����ѯ','~/OrderSeq/Index','~/Content/Images/Nav/Default.png',1)
go
insert into acc_permission values('Url_OrderSeq_View','�����ѯ','Production')
go







