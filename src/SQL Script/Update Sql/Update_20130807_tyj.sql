
alter table md_item add ContainerDesc varchar(50) null
go
insert into ACC_Permission values('Url_Production_ForceResume','ǿ�ƻָ�','Production')
go

insert into SYS_Menu values('Url_OrderTrace_View','����������־','Menu.Procurement.Info',420,'����������־','~/OrderTrace/Index','~/Content/Images/Nav/Default.png',1)
go
insert into ACC_Permission values('Url_OrderTrace_View','����������־','Procurement')
go
insert into SYS_Menu values('Url_SequenceOrder_Receive','�ջ�','Url_SequenceOrder',300,'�ջ�','~/SequenceMaster/ReceiveIndex/10','~/Content/Images/Nav/Default.png',1)
go
insert into ACC_Permission values('Url_SequenceOrder_Receive','�ջ�','Procurement')
go
insert into SYS_Menu values('Url_SequenceOrder_Receive','�ջ�','Url_SequenceOrder',300,'�ջ�','~/SequenceMaster/ReceiveIndex/10','~/Content/Images/Nav/Default.png',1)
go
insert into ACC_Permission values('Url_SequenceOrder_Receive','�����ջ�','Procurement')
go
insert into SYS_Menu values('Url_SequenceOrder_Receive_Distribution','�ջ�','Url_SequenceOrder_Distribution',200,'�ջ�','~/SequenceMaster/ReceiveIndex/20','~/Content/Images/Nav/Default.png',1)
go
insert into ACC_Permission values('Url_SequenceOrder_Receive_Distribution','�����ջ�','Distribution')
go

alter table FIS_WMSDatFile add ReceiveTotal decimal(18,8) default(0) null 
go

alter table FIS_WMSDatFile add CancelQty decimal(18,8) default(0)  null 
go
alter table FIS_WMSDatFile add Version int default(1) not null
go
update  FIS_WMSDatFile set ReceiveTotal=Qty,CancelQty=0,Version=1 
