insert into SYS_EntityPreference(Id, Seq, Value, Desc1, CreateUser, CreateUserNm, CreateDate, LastModifyUser, LastModifyUserNm, LastModifyDate)
values(11057, 206, 'A', '��������Ĭ��SAP������', 2603,	'�û� ����', '2011-01-01 00:00:00.000', 2603,	'�û� ����', '2011-01-01 00:00:00.000')
go

alter table CUST_OpRefMap add Location varchar(50)
go