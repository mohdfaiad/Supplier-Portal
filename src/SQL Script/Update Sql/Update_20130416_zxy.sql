SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[PRD_StandardWorkingCalendar](
	[Id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Region] [varchar](50) NULL,
	[Shift] [varchar](50) NOT NULL,
	[DayOfWeek] [tinyint] NOT NULL,
	[Type] [tinyint] NOT NULL,
	[FlowStrategy] [tinyint] NOT NULL,
	[CreateUser] [int] NOT NULL,
	[CreateUserNm] [varchar](100) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[LastModifyUser] [int] NOT NULL,
	[LastModifyUserNm] [varchar](100) NOT NULL,
	[LastModifyDate] [datetime] NOT NULL,
	[RegionName] [varchar](100) NOT NULL,
 CONSTRAINT [PK_PRD_STANDARDWORKINGCALENDAR] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[PRD_StandardWorkingCalendar]  WITH CHECK ADD  CONSTRAINT [FK_PRD_STAN_REFERENCE_MD_REGIO] FOREIGN KEY([Region])
REFERENCES [dbo].[MD_Region] ([Code])
GO

ALTER TABLE [dbo].[PRD_StandardWorkingCalendar] CHECK CONSTRAINT [FK_PRD_STAN_REFERENCE_MD_REGIO]
GO

ALTER TABLE [dbo].[PRD_StandardWorkingCalendar]  WITH CHECK ADD  CONSTRAINT [FK_PRD_STAN_REFERENCE_PRD_SHIF] FOREIGN KEY([Shift])
REFERENCES [dbo].[PRD_ShiftMstr] ([Code])
GO

ALTER TABLE [dbo].[PRD_StandardWorkingCalendar] CHECK CONSTRAINT [FK_PRD_STAN_REFERENCE_PRD_SHIF]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[PRD_WorkingCalendar](
	[Id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Region] [varchar](50) NOT NULL,
	[Shift] [varchar](50) NOT NULL,
	[WorkingDate] [date] NOT NULL,
	[Type] [tinyint] NOT NULL,
	[FlowStrategy] [tinyint] NOT NULL,
	[CreateUser] [int] NOT NULL,
	[CreateUserNm] [varchar](100) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[LastModifyUser] [int] NOT NULL,
	[LastModifyUserNm] [varchar](100) NOT NULL,
	[LastModifyDate] [datetime] NOT NULL,
	[DayOfWeek] [tinyint] NOT NULL,
	[RegionName] [varchar](100) NOT NULL,
 CONSTRAINT [PK_PRD_WORKINGCALENDAR] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[PRD_WorkingCalendar]  WITH CHECK ADD  CONSTRAINT [FK_PRD_WORK_REFERENCE_MD_REGIO] FOREIGN KEY([Region])
REFERENCES [dbo].[MD_Region] ([Code])
GO

ALTER TABLE [dbo].[PRD_WorkingCalendar] CHECK CONSTRAINT [FK_PRD_WORK_REFERENCE_MD_REGIO]
GO

ALTER TABLE [dbo].[PRD_WorkingCalendar]  WITH CHECK ADD  CONSTRAINT [FK_PRD_WORKingCalendar_REFERENCE_PRD_SHIFMSTR_CODE] FOREIGN KEY([Shift])
REFERENCES [dbo].[PRD_ShiftMstr] ([Code])
GO

ALTER TABLE [dbo].[PRD_WorkingCalendar] CHECK CONSTRAINT [FK_PRD_WORKingCalendar_REFERENCE_PRD_SHIF]
GO

insert into sys_menu  values
('Url_ShiftMaster_View','���','Menu.Production.Setup',50400,'���','~/ShiftMaster/Index','~/Content/Images/Nav/Default.png',1)
insert into acc_permission values('Url_ShiftMaster_View','�鿴���','Production')
insert into acc_permission values('Url_ShiftMaster_Edit','�༭���','Production')
go

insert into sys_menu  values
('Url_StandardWorkingCalendar_View','��׼��������','Menu.Production.Setup',50400,'��׼��������','~/StandardWorkingCalendar/Index','~/Content/Images/Nav/Default.png',1)
insert into acc_permission values('Url_StandardWorkingCalendar_View','�鿴��׼��������','Production')
insert into acc_permission values('Url_StandardWorkingCalendar_Edit','�༭��׼��������','Production')
insert into acc_permission values('Url_StandardWorkingCalendar_Delete','ɾ����׼��������','Production')
go

delete from dbo.ACC_UserPermission where permissionid in (10148,10149,10150)
delete from dbo.ACC_RolePermission where permissionid in (10148,10149,10150)
delete from dbo.sys_menu where code='Url_WorkingCalendar_View'
delete from dbo.acc_permission where code in ('Url_WorkingCalendar_View','Url_WorkingCalendar_Edit','Url_WorkingCalendar_Delete')
go

insert into sys_menu  values
('Url_WorkingCalendar_View','��������','Menu.Production.Setup',50401,'��������','~/WorkingCalendar/Index','~/Content/Images/Nav/Default.png',1)
insert into acc_permission values('Url_WorkingCalendar_View','�鿴��������','Production')
insert into acc_permission values('Url_WorkingCalendar_Edit','�༭��������','Production')
insert into acc_permission values('Url_WorkingCalendar_Delete','ɾ����������','Production')
go

insert into sys_menu  values
('Url_SpecialTime_RestView','ͣ��ʱ��','Menu.Production.Setup',50402,'ͣ��ʱ��','~/SpecialTime/Index','~/Content/Images/Nav/Default.png',1)
insert into acc_permission values('Url_SpecialTime_RestView','�鿴ͣ��ʱ��','Production')
insert into acc_permission values('Url_SpecialTime_RestEdit','�༭ͣ��ʱ��','Production')
insert into acc_permission values('Url_SpecialTime_RestDelete','ɾ��ͣ��ʱ��','Production')
go
insert into sys_menu  values
('Url_SpecialTime_WorkView','�Ӱ�ʱ��','Menu.Production.Setup',50403,'�Ӱ�ʱ��','~/SpecialTime/WorkIndex','~/Content/Images/Nav/Default.png',1)
insert into acc_permission values('Url_SpecialTime_WorkView','�鿴�Ӱ�ʱ��','Production')
insert into acc_permission values('Url_SpecialTime_WorkEdit','�༭�Ӱ�ʱ��','Production')
insert into acc_permission values('Url_SpecialTime_WorkDelete','ɾ���Ӱ�ʱ��','Production')
go
insert into sys_menu  values
('Url_FlowTaktAjust_View','�����߽��ĵ���','Menu.Production.Setup',50404,'�����߽��ĵ���','~/FlowTaktAjust/Index','~/Content/Images/Nav/Default.png',1)
insert into acc_permission values('Url_FlowTaktAjust_View','�鿴�����߽��ĵ���','Production')
insert into acc_permission values('Url_FlowTaktAjust_Edit','�༭�����߽��ĵ���','Production')
go
alter table PRD_ShiftMstr add ShiftCount int null
go
update m set ShiftCount =(select count(*) from PRD_ShiftDet  d where m.Code=d.Shift)
from PRD_ShiftMstr m
go
alter table PRD_ShiftMstr alter column ShiftCount int not null
go


alter table PRD_ShiftDet add StartTime varchar(5) null
go
update PRD_ShiftDet set StartTime=StartDate 
go
alter table PRD_ShiftDet alter column StartTime varchar(5) not null
go
alter table PRD_ShiftDet drop column StartDate 
go

alter table PRD_ShiftDet add EndTime varchar(5) null
go
update PRD_ShiftDet set EndTime=EndDate 
go
alter table PRD_ShiftDet alter column EndTime varchar(5) not null
go
alter table PRD_ShiftDet drop column EndDate 
go

alter table PRD_ShiftDet add IsOvernight int null
go
update PRD_ShiftDet set IsOvernight =0
go
alter table PRD_ShiftDet alter column IsOvernight int not null
go


alter table PRD_ShiftDet drop column ShiftTime 
go
alter table PRD_ShiftDet add Seq int null
go
update PRD_ShiftDet set Seq =0
go
alter table PRD_ShiftDet alter column Seq int not null
go
update PRD_ShiftDet set StartTime ='08:00' ,EndTime ='10:00',seq =1 where StartDate is null and EndDate is null
go

alter table scm_flowstrategy add WinTimeInternal int 
alter table scm_flowstrategy drop column WaitTime  
alter table scm_flowstrategy drop column WaitBatch  
alter table scm_flowstrategy add SeqGroup varchar(50) null
alter table scm_flowstrategy add QiTiaoBian varchar(10)  null
alter table scm_flowstrategy add SupplierGroup varchar(50) null
alter table scm_flowstrategy add KBCalc tinyint null
alter table scm_flowstrategy add SupplierGroupSeq int null
alter table scm_flowstrategy add NextWinTime2 datetime null
alter table scm_flowstrategy add PreOrderTime datetime null
alter table scm_flowstrategy add PreWinTime datetime null
alter table scm_flowstrategy add PreWinTime2 datetime null
go