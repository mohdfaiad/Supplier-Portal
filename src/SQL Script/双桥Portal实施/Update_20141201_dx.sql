set identity_insert BAT_Job on
insert into BAT_Job(Id, Name, Desc1, ServiceType) values(320, 'CreateDNJob', '创建DN', 'CreateDNJob')
set identity_insert BAT_Job off
go
insert into BAT_JobParam(JobId, ParamKey, ParamValue) values(320, 'UserCode', 'su')
go
set identity_insert BAT_Trigger on
insert into BAT_Trigger(Id, JobId, Name, Desc1, RepeatCount, Interval, IntervalType, TimesTriggered, [Status] ) 
values(320, 320, 'CreateDNTriger', '创建DN', 0, 30, 1, 0, 0)
set identity_insert BAT_Trigger off
go

insert into SYS_MsgSubscirber(Id, Desc1, Emails, MaxMsgSize) values(10708, '创建DN', 'dingxin@sconit.com', 10)
go