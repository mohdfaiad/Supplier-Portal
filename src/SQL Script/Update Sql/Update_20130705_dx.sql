insert into ACC_Permission values('Client_ForceScanMaterialIn','�ؼ���ǿ��ɨ��','Terminal')
go 
insert into SYS_Menu values('Url_OrderItemTrace_FrameBarCode','����ɨ��','Menu.Quality.Trans',700,'����ɨ��','~/OrderItemTrace/FrameBarCode','~/Content/Images/Nav/Default.png',1)
go
insert into ACC_Permission values('Url_OrderItemTrace_FrameBarCode','����ɨ��','Quality')
go
alter table SAP_ProdOrder add [VERSION] varchar(50)
go