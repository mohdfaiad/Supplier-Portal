insert into sys_codemstr values ('SapOrderType','Sap����������',0)

insert into sys_codedet values ('SapOrderType','Z902','������',0,1)
insert into sys_codedet values ('SapOrderType','ZP01','����',0,2)
insert into sys_codedet values ('SapOrderType','Z90R','����',0,3)
insert into sys_codedet values ('SapOrderType','Z903','����',0,4)
insert into sys_codedet values ('SapOrderType','Z901','����',0,5)

update sys_menu set name = '�������' where code = 'Url_OrderMstr_Production_Receive'

update sys_menu set name = '������������ά��' where code = 'Url_ProductionFlow_View'

insert into acc_permission values ('Client_VanOrderReceive','��������','Terminal')
