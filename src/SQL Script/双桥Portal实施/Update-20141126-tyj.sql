insert into SYS_Menu values('Url_Supplier_IpMater_ShipConfirm','����ȷ��','Url_Supplier_Deliveryorder',500,'����ȷ��','~/SupplierIpMaster/ShipConfirmIndex','~/Content/Images/Nav/Default.png',1)
go
insert into ACC_Permission values('Url_Supplier_IpMater_ShipConfirm','�ͻ���-����ȷ��','SupplierMenu')
go
insert into SYS_Menu values('Url_Supplier_IpMater_CancelShipConfirm','��������','Url_Supplier_Deliveryorder',510,'��������','~/SupplierIpMaster/CancelShipConfirmIndex','~/Content/Images/Nav/Default.png',1)
go
insert into ACC_Permission values('Url_Supplier_IpMater_CancelShipConfirm','�ͻ���-��������','SupplierMenu')
go
update sys_menu set isactive=0 where exists(select 1 from acc_permission a where a.code=sys_menu.code and a.category='SQSupplierMenu')
go
insert into SYS_Menu values('Url_SAP_CreateDN_View','����DN����������','Url_SI_SAP',530,'����DN����������','~/CreateDN/Index','~/Content/Images/Nav/Default.png',1)
go
insert into ACC_Permission values('Url_SAP_CreateDN_View','����DN����������','SI_SAP')
go
update SYS_SNRule set prefixed='E1' where prefixed='A1'
go
update SYS_SNRule set prefixed='E2' where prefixed='A2'
go
update SYS_SNRule set prefixed='E3' where prefixed='A3'
go
update SYS_SNRule set prefixed='E4' where prefixed='A4'
go
update SYS_SNRule set prefixed='E5' where prefixed='A5'
go
update SYS_SNRule set prefixed='E6' where prefixed='A6'
go
update SYS_SNRule set prefixed='E7' where prefixed='A7'
go
update SYS_SNRule set prefixed='E8' where prefixed='A8'
go
Update r set r.IsCreateInvTrans=0 from MD_Region r where exists(select 1 from MD_Location as l where l.Region=r.Code and l.SAPLocation in('R000','R001','R600','R601','R800','R801'))