insert into SYS_Menu values('Url_MessageSubscirber_View','�ʼ�ά��','Menu.MasterData',500,'�ʼ�ά��','~/MessageSubscirber/Index','~/Content/Images/Nav/Default.png',1)
go
insert into ACC_Permission values('Url_MessageSubscirber_View','�ʼ�ά��','MasterData')
go
update SYS_Menu set Parent=null,PageUrl=null where Code='Menu.Kanban'
go
alter table  CUST_ItemTrace add ItemDesc varchar(100) null
go
update c set c.ItemDesc=i.Desc1 from  CUST_ItemTrace c,MD_Item i where c.Item=i.Code 
go
go
update SYS_Menu set Seq=150 where Code='Url_OrderMstr_Production_Receive'
go
insert into SYS_Menu values('Url_Production_ForceReceive','����������ǿ������','Url_OrderMstr_Production',160,'����������ǿ������','~/ProductionOrder/ForceReceiveIndex','~/Content/Images/Nav/Default.png',1)
go
insert into ACC_Permission values('Url_Production_ForceReceive','����������ǿ������','Production')