update acc_permission set desc1 = '��������������������' where code = 'Url_OrderMstr_Production_BatchProcess'

update sys_menu set name = '��������������������',desc1 = '��������������������' where code = 'Url_OrderMstr_Production_BatchProcess'

update acc_permission set desc1 = '�����������ջ�' where code = 'Url_OrderMstr_Production_Receive'

update sys_menu set name = '�����������ջ�',desc1 = '�����������ջ�' where code = 'Url_OrderMstr_Production_Receive'
go
insert into ACC_Permission values('Client_ForceScanMaterialIn','ǿ��ɨ��','Terminal')
go	
insert into SYS_Menu values('Url_OrderItemTrace_FrameBarCode','����ɨ��','Menu.Quality.Trans',700,'����ɨ��','~/OrderItemTrace/FrameBarCode','~/Content/Images/Nav/Default.png',1)
go
insert into ACC_Permission values('Url_OrderItemTrace_FrameBarCode','����ɨ��','Quality')