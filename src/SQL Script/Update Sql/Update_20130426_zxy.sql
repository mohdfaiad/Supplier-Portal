
update sys_menu set name ='��������',desc1 ='��������' where code ='Url_OrderMstr_Production_Receive'
update acc_permission set desc1 ='��������' where code ='Url_OrderMstr_Production_Receive'
go

insert into sys_menu values
('Url_OrderMstr_Production_NonVanReceive','����������������','Url_OrderMstr_Production',199,'����������������','~/ProductionOrder/NonVanReceiveIndex','~/Content/Images/Nav/Default.png',1)
insert into acc_permission values('Url_OrderMstr_Production_NonVanReceive','����������������','Production')
go
