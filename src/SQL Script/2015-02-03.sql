insert into acc_permissioncategory values('Application','Ӧ�ù���',1)
go
insert into acc_permissioncategory values('MasterData','��������',1)
go
insert into ACC_PermissionCategory values('Supplier','��Ӧ��',4)
go
insert into acc_user values('su','E10ADC3949BA59ABBE56E057F20F883E','����','�û�',0,null,null,null,'zh-CN',1,0,0,0,1,'�û� ����',GETDATE(),1,'�û� ����',getdate())
go
insert into sys_menu values('Menu_MasterData','��������',null,10,'��������',null,'~/Content/Images/Nav/MasterData.png',1)
go
insert into sys_menu values('Url_Supplier_View','��Ӧ��','Menu_MasterData',20,'��Ӧ��','~/Supplier/Index','~/Content/Images/Nav/Default.png',1)
go
insert into sys_menu values('Menu_Application','Ӧ�ù���',null,1,'Ӧ�ù���',null,'~/Content/Images/Nav/MasterData.png',1)
go
insert into sys_menu values('Url_UserFav_View','�û�ƫ��','Menu_Application',10,'�û�ƫ��','~/UserFavorite/Index','~/Content/Images/Nav/Default.png',1)
go
insert into SYS_CodeMstr values('Language','����',0)
go
insert into SYS_CodeDet values('Language','zh-CN','CodeDetail_Language_zh_CN',1,1)
go
insert into SYS_CodeDet values('Language','en-US','CodeDetail_Language_en_US',0,2)
go
insert into SYS_EntityPreference values('10001',1,'20','DefaultPageSize',1,'�û� ����',getdate(),1,'�û� ����',getdate())
go
insert into SYS_EntityPreference values('10002',2,'5','SessionCachedSearchStatementCount',1,'�û� ����',getdate(),1,'�û� ����',getdate())
go
insert into SYS_EntityPreference values('10003',3,'0','����ϵͳ��ʶ',1,'�û� ����',getdate(),1,'�û� ����',getdate())
go
insert into SYS_EntityPreference values('10004',4,'1000','MaxRowSizeOnPage',1,'�û� ����',getdate(),1,'�û� ����',getdate())
go
insert into sys_menu values('Menu_Application_Permission','���ʿ���','Menu_Application',20,'���ʿ���',NULL,'~/Content/Images/Nav/Default.png',1)
go
insert into sys_menu values('Url_PermissionGroup_View','Ȩ����','Menu_Application_Permission',10,'Ȩ����','~/PermissionGroup/Index','~/Content/Images/Nav/Default.png',1)
go
insert into acc_permission values('Url_PermissionGroup_View','Ȩ����','Application')
go
insert into sys_menu values('Url_Role_View','��ɫ','Menu_Application_Permission',20,'��ɫ','~/Role/Index','~/Content/Images/Nav/Default.png',1)
go
insert into acc_permission values('Url_Role_View','��ɫ','Application')
go
insert into sys_menu values('Url_User_View','�û�','Menu_Application_Permission',30,'�û�','~/User/Index','~/Content/Images/Nav/Default.png',1)
go
insert into acc_permission values('Url_User_Delete','�û�ɾ��','Application')
go
insert into acc_permission values('Url_User_Edit','�û��༭','Application')
go 
insert into acc_permission values('Url_User_View','�û��鿴','Application')
go
insert into acc_permission values('Url_UserFav_Delete','�û�ƫ��ɾ��','Application')
go
insert into acc_permission values('Url_UserFav_Edit','�û�ƫ�ñ༭','Application')
go
insert into acc_permission values('Url_UserFav_View','�û�ƫ�ò鿴','Application')
go
insert into acc_permission values('Url_Supplier_New','��Ӧ���½�','MasterData')
go
insert into acc_permission values('Url_Supplier_Delete','��Ӧ��ɾ��','MasterData')
go
insert into acc_permission values('Url_Supplier_Edit','��Ӧ�̱༭','MasterData')
go
insert into acc_permission values('Url_Supplier_View','��Ӧ�̲鿴','MasterData')
go
insert into acc_permission values('Url_Location_Delete','��λɾ��','MasterData')
go
insert into acc_permission values('Url_Location_Edit','��λ�༭','MasterData')
go
insert into acc_permission values('Url_Location_View','��λ�鿴','MasterData')
go
insert into acc_permission values('Url_Uom_Delete','��λɾ��','MasterData')
go
insert into acc_permission values('Url_Uom_Edit','��λ�༭','MasterData')
go
insert into acc_permission values('Url_Uom_View','��λ�鿴','MasterData')
go
insert into sys_menu values('Url_Location_View','��λ','Menu_MasterData',40,'��λ','~/Location/Index','~/Content/Images/Nav/Default.png',1)
go
insert into sys_menu values('Url_Uom_View','������λ','Menu_MasterData',30,'������λ','~/Uom/Index','~/Content/Images/Nav/Default.png',1)
go
insert into acc_permission values('Url_Plant_New','�����½�','MasterData')
go
insert into acc_permission values('Url_Plant_Delete','����ɾ��','MasterData')
go
insert into acc_permission values('Url_Plant_Edit','�����༭','MasterData')
go
insert into acc_permission values('Url_Plant_View','�����鿴','MasterData')
go
insert into sys_menu values('Url_Plant_View','����','Menu_MasterData',25,'����','~/Plant/Index','~/Content/Images/Nav/Default.png',1)
go



