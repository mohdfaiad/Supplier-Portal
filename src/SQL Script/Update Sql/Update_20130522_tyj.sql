delete from SYS_Menu where code = 'Url_OrderItemTrace_New'
insert into SYS_Menu values('Url_OrderItemTrace_New','�ؼ���ɨ��','Menu.Quality.Trans',500,'�ؼ���ɨ��','~/OrderItemTrace/New','~/Content/Images/Nav/Default.png',1)
go
delete from ACC_Permission where code = 'Url_OrderItemTrace_New'
insert into ACC_Permission values('Url_OrderItemTrace_New','�ؼ���ɨ��','Quality')
go
