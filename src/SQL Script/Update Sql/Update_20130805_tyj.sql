go
alter table INV_LocationDetPref add ItemDesc varchar(100) null
go
insert into SYS_Menu values('Url_LocationDetailPref_View','��ȫ���','Menu.MasterData',600,'��ȫ���','~/LocationDetailPref/Index','~/Content/Images/Nav/Default.png',1)
go
insert into ACC_Permission values('Url_LocationDetailPref_View','��ȫ���','MasterData')
go

insert into SYS_Menu values('Url_LocationDetailPref_View','��ȫ���','Menu.MasterData',600,'��ȫ���','~/LocationDetailPref/Index','~/Content/Images/Nav/Default.png',1)
go
insert into ACC_Permission values('Url_LocationDetailPref_View','��ȫ���','MasterData')