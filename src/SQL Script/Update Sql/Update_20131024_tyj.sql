insert into SYS_Menu values('Url_CheckFlowList_View','����·�߼��','Menu.Inventory.Setup',400,'����·�߼��','~/ItemFlow/CheckFlowList','~/Content/Images/Nav/Default.png',1)
go
insert into ACC_Permission values('Url_CheckFlowList_View','����·�߼��','Inventory')
go
insert into ACC_Permission values('Url_PickList_New_button','������½�-��ť','Distribution')
go
update ACC_Permission set Desc1='������½�-�鿴' where code='Url_PickList_New'
go
update ACC_Permission set Desc1='������½�-�½�' where code='Url_PickList_New_button'