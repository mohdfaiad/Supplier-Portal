delete from sys_menu where code ='Url_CabProductionView_View'
delete from acc_permission where code ='Url_CabProductionView_View'
go
delete from sys_menu where code ='Url_CabGuideOutSoureView_View'
delete from acc_permission where code ='Url_CabGuideOutSoureView_View'
go

insert into sys_menu values
('Url_CabGuideHomeMadeView_View','��ʻ�ҵ���������ͼ','Menu.Production.Info',202,'��ʻ�ҵ���������ͼ','~/CabGuide/HomeMadeViewIndex','~/Content/Images/Nav/Default.png',1)
go
insert into acc_permission values('Url_CabGuideHomeMadeView_View','��ʻ�ҵ���������ͼ','Production')
go

insert into sys_menu values
('Url_CabGuideOutSoureView_View','��ʻ�ҵ����⹺��ͼ','Menu.Production.Info',203,'��ʻ�ҵ����⹺��ͼ','~/CabGuide/OutSoureViewIndex','~/Content/Images/Nav/Default.png',1)
go
insert into acc_permission values('Url_CabGuideOutSoureView_View','��ʻ�ҵ����⹺��ͼ','Production')
go

insert into sys_menu values
('Url_VehicleProductionSubLineView_View','��������������ͼ','Menu.Production.Info',204,'��������������ͼ','~/VehicleProductionSubLine/Index','~/Content/Images/Nav/Default.png',1)
go
insert into acc_permission values('Url_VehicleProductionSubLineView_View','��������������ͼ','Production')
go
