alter table LE_OrderPlanSnapshot add RefLocation varchar(50)
go
update SYS_Menu set Desc1='��ֱ�͹�Ӧ��Ҫ��',Name='��ֱ�͹�Ӧ��Ҫ��' where Code='Url_OrderMstr_Procurement_New'
go
update ACC_Permission set Desc1='��ֱ�͹�Ӧ��Ҫ��' where Code='Url_OrderMstr_Procurement_New'
go
insert into SYS_Menu values('Url_Procurement_MergeReceive','�ջ��ܲ˵�','Menu.Procurement.Trans',5,'�ջ��ܲ˵�','~/ProcurementOrder/MergeIndex','~/Content/Images/Nav/Default.png',1)
go
insert into ACC_Permission values('Url_Procurement_MergeReceive','�ջ��ܲ˵�','procurement')
go
insert into SYS_Menu values('Url_ProcurementOrder_CloseDetail','Ҫ������ر�','Url_OrderMstr_Procurement',400,'Ҫ������ر�','~/ProcurementOrder/CloseDetailIndex','~/Content/Images/Nav/Default.png',1)
go
insert into ACC_Permission values('Url_ProcurementOrder_CloseDetail','Ҫ������ر�','Procurement')