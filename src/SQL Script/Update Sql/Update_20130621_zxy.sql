insert sys_menu(Code,Name,Parent,Seq,Desc1,PageUrl,ImageUrl,IsActive) values
('Url_CabGuideHomeMadeSubView_View','���Ƽ�ʻ�ҳ��������ͼ','Menu.Production.Trans',202,'���Ƽ�ʻ�ҳ��������ͼ','~/CabGuide/HomeMadeSubViewIndex','~/Content/Images/Nav/Default.png',1)
go

insert into acc_permission values('Url_CabGuideHomeMadeSubView_View','���Ƽ�ʻ�ҳ��������ͼ','Production')
go


insert sys_menu(Code,Name,Parent,Seq,Desc1,PageUrl,ImageUrl,IsActive) values
('Url_CabGuideOutSoureSubView_View','�⹺��ʻ�ҳ��������ͼ','Menu.Production.Trans',203,'�⹺��ʻ�ҳ��������ͼ','~/CabGuide/OutSoureSubViewIndex','~/Content/Images/Nav/Default.png',1)
go

insert into acc_permission values('Url_CabGuideOutSoureSubView_View','�⹺��ʻ�ҳ��������ͼ','Production')
go


insert into sys_codemstr values('DateOption','����ѡ��',0)
go
insert into sys_codedet values('DateOption','EQ','����',1,1)
insert into sys_codedet values('DateOption','GT','����',0,2)
insert into sys_codedet values('DateOption','GE','���ڵ���',0,3)
insert into sys_codedet values('DateOption','LT','С��',0,4)
insert into sys_codedet values('DateOption','LE','С�ڵ���',0,5)
insert into sys_codedet values('DateOption','BT','���ڵ�����С�ڵ���',0,6)
go


insert sys_menu(Code,Name,Parent,Seq,Desc1,PageUrl,ImageUrl,IsActive) values
('Url_OrderMstr_Production_ConditionImport','��������������������','Url_OrderMstr_Production',108,'��������������������','~/ProductionOrder/ConditionImport','~/Content/Images/Nav/Default.png',1)
go
insert into acc_permission values('Url_OrderMstr_Production_ConditionImport','��������������������','Production')
go
