alter table CUST_ProductLineMap add EndVanOrder varchar(50)
go

alter table SCM_FlowStrategy add LeadTimeOpt tinyint
go

update SCM_FlowStrategy set LeadTimeOpt = 0
go

alter table SCM_FlowShiftDet add OrderLeadTime tinyint
go

alter table SCM_FlowShiftDet add OrderEMLeadTime tinyint
go

alter table SCM_FlowShiftDet add UnloadLeadTime tinyint
go

alter table SCM_FlowShiftDet add SafeTime tinyint
go

insert into SYS_CodeMstr(Code, Desc1, [Type]) values('LeadTimeOption',	'提前期选项',	0)
insert into SYS_CodeDet(Code, Value, Desc1, IsDefault, Seq) values('LeadTimeOption',	0,	'CodeDetail_LeadTimeOption_Strategy',	1,	1)
insert into SYS_CodeDet(Code, Value, Desc1, IsDefault, Seq) values('LeadTimeOption',	1,	'CodeDetail_LeadTimeOption_ShiftDetail',	0,	2)
go
