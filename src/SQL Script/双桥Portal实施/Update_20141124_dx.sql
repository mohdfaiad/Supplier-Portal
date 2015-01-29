SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
create table ACC_UserToken
(
	Code varchar(50) Primary Key,
	Token varchar(50),
	[ExpireDate] datetime
)
go
drop table SYS_PortalSetting
go

CREATE TABLE [dbo].[SYS_PortalSetting](
	[Id] [int] NOT NULL,
	[Name] [varchar](50) NULL,
	[Seq] [int] NULL,
	[ServerAddr] [varchar](50) NULL,
	[SIPort] [int] NULL,
	[WebPort] [int] NULL,
	[WebVirtualPath] varchar(50),
	[IsPrimary] bit not null,
 CONSTRAINT [PK_SYS_PortalSetting] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

insert into SYS_EntityPreference(Id, Seq, Value, Desc1, CreateUser, CreateUserNm, CreateDate, LastModifyUser, LastModifyUserNm, LastModifyDate)
values(11064, 100, 'localhost', 'Portal地址', 2603, '用户 超级', '2011-01-01 00:00:00.000',  2603, '用户 超级', '2011-01-01 00:00:00.000')
go

insert into SYS_EntityPreference(Id, Seq, Value, Desc1, CreateUser, CreateUserNm, CreateDate, LastModifyUser, LastModifyUserNm, LastModifyDate)
values(11065, 100, '789', 'Portal端口', 2603, '用户 超级', '2011-01-01 00:00:00.000',  2603, '用户 超级', '2011-01-01 00:00:00.000')
go