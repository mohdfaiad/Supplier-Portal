

insert into sys_menu values
('Url_OrderMstr_Production_VanView','������������ѯ','Url_OrderMstr_Production',104,'������������ѯ','~/ProductionOrder/VanIndex','~/Content/Images/Nav/Default.png',1)
go

insert into acc_permission values('Url_OrderMstr_Production_VanView','������������ѯ','Production')
go

update sys_menu set name='��������������ѯ',desc1='��������������ѯ' where code ='Url_OrderMstr_Production_View'
go

