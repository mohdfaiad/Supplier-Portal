
alter table dbo.MD_SpecialTime add Category tinyint null
go
update  MD_SpecialTime set Category =0 
go
alter table dbo.MD_SpecialTime alter column Category tinyint not null
go

update sys_menu set name ='����ͣ��ʱ��',desc1 ='����ͣ��ʱ��' where code ='Url_SpecialTime_RestView'
update sys_menu set name ='����Ӱ�ʱ��',desc1 ='����Ӱ�ʱ��' where code ='Url_SpecialTime_WorkView'
go
update acc_permission set desc1= '�鿴����ͣ��ʱ��' where code ='Url_SpecialTime_RestView' 
update acc_permission set desc1= '�༭����ͣ��ʱ��' where code ='Url_SpecialTime_RestEdit' 
update acc_permission set desc1= 'ɾ������ͣ��ʱ��' where code ='Url_SpecialTime_RestDelete' 
update acc_permission set desc1= '�鿴����Ӱ�ʱ��' where code ='Url_SpecialTime_WorkView' 
update acc_permission set desc1= '�༭����Ӱ�ʱ��' where code ='Url_SpecialTime_WorkEdit' 
update acc_permission set desc1= 'ɾ������Ӱ�ʱ��' where code ='Url_SpecialTime_WorkDelete' 
go

insert into sys_menu values
('Url_ProdLineSpecialTime_RestView','������ͣ��ʱ��','Menu.Production.Setup',50404,'������ͣ��ʱ��','~/ProdLineSpecialTime/Index','~/Content/Images/Nav/Default.png',1)
go
insert into sys_menu values
('Url_ProdLineSpecialTime_WorkView','�����߼Ӱ�ʱ��','Menu.Production.Setup',50405,'�����߼Ӱ�ʱ��','~/ProdLineSpecialTime/WorkIndex','~/Content/Images/Nav/Default.png',1)
go

insert into acc_permission values('Url_ProdLineSpecialTime_RestView','�鿴������ͣ��ʱ��','Production')
insert into acc_permission values('Url_ProdLineSpecialTime_RestEdit','�༭������ͣ��ʱ��','Production')
insert into acc_permission values('Url_ProdLineSpecialTime_RestDelete','ɾ��������ͣ��ʱ��','Production')
go
insert into acc_permission values('Url_ProdLineSpecialTime_WorkView','�鿴�����߼Ӱ�ʱ��','Production')
insert into acc_permission values('Url_ProdLineSpecialTime_WorkEdit','�༭�����߼Ӱ�ʱ��','Production')
insert into acc_permission values('Url_ProdLineSpecialTime_WorkDelete','ɾ�������߼Ӱ�ʱ��','Production')
go

