insert into sys_menu values
('Url_AliquotStartTask_View','��װ��������','Menu.Production.Info',202,'��װ��������','~/AliquotStartTask/Index','~/Content/Images/Nav/Default.png',1)

insert into acc_permission values('Url_AliquotStartTask_View','��װ��������','Production')

go


update sys_menu set isactive =0 where code ='Url_OrderMstr_Distribution_ReturnNew'
go

 
insert into sys_menu values
('Url_OrderMstr_Distribution_ReturnShip','����','Url_OrderMstr_Distribution_Return',21,'����','~/DistributionOrder/ReturnShipIndex','~/Content/Images/Nav/Default.png',1)


insert into acc_permission values
('Url_OrderMstr_Distribution_ReturnShip','�����˻�������','Distribution')
go