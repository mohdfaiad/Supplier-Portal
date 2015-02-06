
/****** Object:  Table [dbo].[[ACC_Permission]]    Script Date: 2015/2/3 11:09:35 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE type='U' and name='ACC_Permission')
DROP TABLE [dbo].[ACC_Permission]
CREATE TABLE [dbo].[ACC_Permission](
	[Id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Code] [varchar](50) NOT NULL,
	[Desc1] [varchar](100) NOT NULL,
	[Category] [varchar](50) NOT NULL,
 CONSTRAINT [PK_ACC_PERMISSION] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[ACC_Permission]  WITH NOCHECK ADD  CONSTRAINT [FK_ACC_PERM_REFERENCE_ACC_PERM2] FOREIGN KEY([Category])
REFERENCES [dbo].[ACC_PermissionCategory] ([Code])
GO

ALTER TABLE [dbo].[ACC_Permission] CHECK CONSTRAINT [FK_ACC_PERM_REFERENCE_ACC_PERM2]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'自增标示' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ACC_Permission', @level2type=N'COLUMN',@level2name=N'Id'
GO
/****** Object:  Table [dbo].[ACC_PermissionGroup]    Script Date: 2015/2/3 11:09:35 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE type='U' and name='ACC_PermissionCategory')
DROP TABLE [dbo].[ACC_PermissionCategory]
CREATE TABLE [dbo].[ACC_PermissionCategory](
	[Code] [varchar](50) NOT NULL,
	[Desc1] [varchar](100) NOT NULL,
	[Type] [tinyint] NOT NULL,
 CONSTRAINT [PK_ACC_PERMISSIONCATEGORY] PRIMARY KEY CLUSTERED 
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
go
/****** Object:  Table [dbo].[ACC_PermissionGroupPermission]    Script Date: 2015/2/3 11:09:44 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE type='U' and name='ACC_PermissionGroupPermission')
DROP TABLE [dbo].[ACC_PermissionGroupPermission]
CREATE TABLE [dbo].[ACC_PermissionGroupPermission](
	[Id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[GroupId] [int] NOT NULL,
	[PermissionId] [int] NOT NULL,
	[CreateUser] [int] NOT NULL,
	[CreateUserNm] [varchar](100) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[LastModifyUser] [int] NOT NULL,
	[LastModifyUserNm] [varchar](100) NOT NULL,
	[LastModifyDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ACC_PERMISSIONGROUPPERMISSI] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[ACC_PermissionGroupPermission]  WITH CHECK ADD  CONSTRAINT [FK_ACC_PERM_REFERENCE_ACC_PERM] FOREIGN KEY([PermissionId])
REFERENCES [dbo].[ACC_Permission] ([Id])
GO

ALTER TABLE [dbo].[ACC_PermissionGroupPermission] CHECK CONSTRAINT [FK_ACC_PERM_REFERENCE_ACC_PERM]
GO

ALTER TABLE [dbo].[ACC_PermissionGroupPermission]  WITH CHECK ADD  CONSTRAINT [FK_ACC_PERM_REFERENCE_ACC_PERM3] FOREIGN KEY([GroupId])
REFERENCES [dbo].[ACC_PermissionGroup] ([Id])
GO

ALTER TABLE [dbo].[ACC_PermissionGroupPermission] CHECK CONSTRAINT [FK_ACC_PERM_REFERENCE_ACC_PERM3]
GO
/****** Object:  Table [dbo].[[ACC_PermissionGroup]]    Script Date: 2015/2/3 11:09:44 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE type='U' and name='ACC_PermissionGroup')
DROP TABLE [dbo].[ACC_PermissionGroup]
CREATE TABLE [dbo].[ACC_PermissionGroup](
	[Id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Code] [varchar](50) NOT NULL,
	[Desc1] [varchar](100) NOT NULL,
	[CreateUser] [int] NOT NULL,
	[CreateUserNm] [varchar](100) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[LastModifyUser] [int] NOT NULL,
	[LastModifyUserNm] [varchar](100) NOT NULL,
	[LastModifyDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ACC_PERMISSIONGROUP] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
go


/****** Object:  Table [dbo].[[ACC_Role]]    Script Date: 2015/2/3 11:13:03 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE type='U' and name='ACC_Role')
DROP TABLE [dbo].[ACC_Role]
CREATE TABLE [dbo].[ACC_Role](
	[Id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Code] [varchar](50) NOT NULL,
	[Desc1] [varchar](100) NOT NULL,
	[Type] [tinyint] NOT NULL,
	[CreateUser] [int] NOT NULL,
	[CreateUserNm] [varchar](100) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[LastModifyUser] [int] NOT NULL,
	[LastModifyUserNm] [varchar](100) NOT NULL,
	[LastModifyDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ACC_ROLE] PRIMARY KEY NONCLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]


/****** Object:  Table [dbo].[ACC_RolePermission]    Script Date: 2015/2/3 11:13:03 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE type='U' and name='AC_RolePermission]')
DROP TABLE [dbo].[ACC_RolePermission]
CREATE TABLE [dbo].[ACC_RolePermission](
	[Id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[RoleId] [int] NOT NULL,
	[PermissionId] [int] NOT NULL,
	[CreateUser] [int] NOT NULL,
	[CreateUserNm] [varchar](100) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[LastModifyUser] [int] NOT NULL,
	[LastModifyUserNm] [varchar](100) NOT NULL,
	[LastModifyDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ACC_ROLEPERMISSION] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[ACC_RolePermission]  WITH NOCHECK ADD  CONSTRAINT [FK_ACC_ROLE_REFERENCE_ACC_PERM2] FOREIGN KEY([PermissionId])
REFERENCES [dbo].[ACC_Permission] ([Id])
GO

ALTER TABLE [dbo].[ACC_RolePermission] CHECK CONSTRAINT [FK_ACC_ROLE_REFERENCE_ACC_PERM2]
GO

ALTER TABLE [dbo].[ACC_RolePermission]  WITH NOCHECK ADD  CONSTRAINT [FK_ACC_ROLE_REFERENCE_ACC_ROLE2] FOREIGN KEY([RoleId])
REFERENCES [dbo].[ACC_Role] ([Id])
GO

ALTER TABLE [dbo].[ACC_RolePermission] CHECK CONSTRAINT [FK_ACC_ROLE_REFERENCE_ACC_ROLE2]
GO


/****** Object:  Table [dbo].[ACC_RolePermissionGroup]    Script Date: 2015/2/3 11:13:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE type='U' and name='ACC_RolePermissionGroup')
DROP TABLE [dbo].[ACC_RolePermissionGroup]
CREATE TABLE [dbo].[ACC_RolePermissionGroup](
	[Id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[RoleId] [int] NOT NULL,
	[GroupId] [int] NOT NULL,
	[CreateUser] [int] NOT NULL,
	[CreateUserNm] [varchar](100) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[LastModifyUser] [int] NOT NULL,
	[LastModifyUserNm] [varchar](100) NOT NULL,
	[LastModifyDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ACC_ROLEPERMISSIONGROUP] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[ACC_RolePermissionGroup]  WITH CHECK ADD  CONSTRAINT [FK_ACC_ROLE_REFERENCE_ACC_PERM] FOREIGN KEY([GroupId])
REFERENCES [dbo].[ACC_PermissionGroup] ([Id])
GO

ALTER TABLE [dbo].[ACC_RolePermissionGroup] CHECK CONSTRAINT [FK_ACC_ROLE_REFERENCE_ACC_PERM]
GO

ALTER TABLE [dbo].[ACC_RolePermissionGroup]  WITH CHECK ADD  CONSTRAINT [FK_ACC_ROLE_REFERENCE_ACC_ROLE] FOREIGN KEY([RoleId])
REFERENCES [dbo].[ACC_Role] ([Id])
GO

ALTER TABLE [dbo].[ACC_RolePermissionGroup] CHECK CONSTRAINT [FK_ACC_ROLE_REFERENCE_ACC_ROLE]
GO




/****** Object:  Table [dbo].[ACC_RolePermissionGroup]    Script Date: 2015/2/3 11:13:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE type='U' and name='ACC_RolePermissionGroup')
DROP TABLE [dbo].[ACC_RolePermissionGroup]
CREATE TABLE [dbo].[ACC_RolePermissionGroup](
	[Id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[RoleId] [int] NOT NULL,
	[GroupId] [int] NOT NULL,
	[CreateUser] [int] NOT NULL,
	[CreateUserNm] [varchar](100) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[LastModifyUser] [int] NOT NULL,
	[LastModifyUserNm] [varchar](100) NOT NULL,
	[LastModifyDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ACC_ROLEPERMISSIONGROUP] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[ACC_RolePermissionGroup]  WITH CHECK ADD  CONSTRAINT [FK_ACC_ROLE_REFERENCE_ACC_PERM] FOREIGN KEY([GroupId])
REFERENCES [dbo].[ACC_PermissionGroup] ([Id])
GO

ALTER TABLE [dbo].[ACC_RolePermissionGroup] CHECK CONSTRAINT [FK_ACC_ROLE_REFERENCE_ACC_PERM]
GO

ALTER TABLE [dbo].[ACC_RolePermissionGroup]  WITH CHECK ADD  CONSTRAINT [FK_ACC_ROLE_REFERENCE_ACC_ROLE] FOREIGN KEY([RoleId])
REFERENCES [dbo].[ACC_Role] ([Id])
GO

ALTER TABLE [dbo].[ACC_RolePermissionGroup] CHECK CONSTRAINT [FK_ACC_ROLE_REFERENCE_ACC_ROLE]
GO




/****** Object:  Table [dbo].[ACC_User]    Script Date: 2015/2/3 11:14:24 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE type='U' and name='ACC_User')
DROP TABLE [dbo].[ACC_User]
CREATE TABLE [dbo].[ACC_User](
	[Id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Code] [varchar](50) NOT NULL,
	[Password] [varchar](50) NOT NULL,
	[FirstName] [varchar](50) NOT NULL,
	[LastName] [varchar](50) NOT NULL,
	[Type] [tinyint] NOT NULL,
	[Email] [varchar](50) NULL,
	[TelPhone] [varchar](50) NULL,
	[MobilePhone] [varchar](50) NULL,
	[Language] [varchar](50) NULL,
	[IsActive] [bit] NOT NULL,
	[AccountExpired] [bit] NOT NULL,
	[AccountLocked] [bit] NOT NULL,
	[PasswordExpired] [bit] NOT NULL,
	[CreateUser] [int] NOT NULL,
	[CreateUserNm] [varchar](100) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[LastModifyUser] [int] NOT NULL,
	[LastModifyUserNm] [varchar](100) NOT NULL,
	[LastModifyDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ACC_USER] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO



/****** Object:  Table [dbo].[ACC_UserFav]    Script Date: 2015/2/3 11:14:44 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE type='U' and name='ACC_UserFav')
DROP TABLE [dbo].[ACC_UserFav]
CREATE TABLE [dbo].[ACC_UserFav](
	[Id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[UserId] [int] NOT NULL,
	[Menu] [varchar](50) NULL,
 CONSTRAINT [PK_ACC_USERFAV] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[ACC_UserFav]  WITH CHECK ADD  CONSTRAINT [FK_ACC_USER_REFERENCE_ACC_USER] FOREIGN KEY([UserId])
REFERENCES [dbo].[ACC_User] ([Id])
GO

ALTER TABLE [dbo].[ACC_UserFav] CHECK CONSTRAINT [FK_ACC_USER_REFERENCE_ACC_USER]
GO

ALTER TABLE [dbo].[ACC_UserFav]  WITH CHECK ADD  CONSTRAINT [FK_ACC_USER_REFERENCE_SYS_MENU] FOREIGN KEY([Menu])
REFERENCES [dbo].[SYS_Menu] ([Code])
GO

ALTER TABLE [dbo].[ACC_UserFav] CHECK CONSTRAINT [FK_ACC_USER_REFERENCE_SYS_MENU]
GO


/****** Object:  Table [dbo].[ACC_UserPermission]    Script Date: 2015/2/3 11:15:18 ******/

IF  EXISTS (SELECT * FROM sys.objects WHERE type='U' and name='ACC_UserPermission')
DROP TABLE [dbo].[ACC_UserPermission]
CREATE TABLE [dbo].[ACC_UserPermission](
	[Id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[UserId] [int] NOT NULL,
	[PermissionId] [int] NOT NULL,
	[CreateUser] [int] NOT NULL,
	[CreateUserNm] [varchar](100) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[LastModifyUser] [int] NOT NULL,
	[LastModifyUserNm] [varchar](100) NOT NULL,
	[LastModifyDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ACC_USERPERMISSION] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[ACC_UserPermission]  WITH NOCHECK ADD  CONSTRAINT [FK_ACC_USER_REFERENCE_ACC_PERM] FOREIGN KEY([PermissionId])
REFERENCES [dbo].[ACC_Permission] ([Id])
GO

ALTER TABLE [dbo].[ACC_UserPermission] CHECK CONSTRAINT [FK_ACC_USER_REFERENCE_ACC_PERM]
GO

ALTER TABLE [dbo].[ACC_UserPermission]  WITH NOCHECK ADD  CONSTRAINT [FK_ACC_USER_REFERENCE_ACC_USER4] FOREIGN KEY([UserId])
REFERENCES [dbo].[ACC_User] ([Id])
GO

ALTER TABLE [dbo].[ACC_UserPermission] CHECK CONSTRAINT [FK_ACC_USER_REFERENCE_ACC_USER4]
GO



/****** Object:  Table [dbo].[ACC_UserPermissionGroup]    Script Date: 2015/2/3 11:15:38 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE type='U' and name='ACC_UserPermissionGroup')
DROP TABLE [dbo].[ACC_UserPermissionGroup]
CREATE TABLE [dbo].[ACC_UserPermissionGroup](
	[Id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[UserId] [int] NOT NULL,
	[GroupId] [int] NOT NULL,
	[CreateUser] [int] NOT NULL,
	[CreateUserNm] [varchar](100) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[LastModifyUser] [int] NOT NULL,
	[LastModifyUserNm] [varchar](100) NOT NULL,
	[LastModifyDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ACC_USERPERMISSIONGROUP] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[ACC_UserPermissionGroup]  WITH CHECK ADD  CONSTRAINT [FK_ACC_USER_REFERENCE_ACC_PERM2] FOREIGN KEY([GroupId])
REFERENCES [dbo].[ACC_PermissionGroup] ([Id])
GO

ALTER TABLE [dbo].[ACC_UserPermissionGroup] CHECK CONSTRAINT [FK_ACC_USER_REFERENCE_ACC_PERM2]
GO

ALTER TABLE [dbo].[ACC_UserPermissionGroup]  WITH CHECK ADD  CONSTRAINT [FK_ACC_USER_REFERENCE_ACC_USER3] FOREIGN KEY([UserId])
REFERENCES [dbo].[ACC_User] ([Id])
GO

ALTER TABLE [dbo].[ACC_UserPermissionGroup] CHECK CONSTRAINT [FK_ACC_USER_REFERENCE_ACC_USER3]
GO


/****** Object:  Table [dbo].[ACC_UserRole]    Script Date: 2015/2/3 11:16:08 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE type='U' and name='ACC_UserRole')
DROP TABLE [dbo].[ACC_UserRole]
CREATE TABLE [dbo].[ACC_UserRole](
	[Id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[UserId] [int] NOT NULL,
	[RoleId] [int] NOT NULL,
	[CreateUser] [int] NOT NULL,
	[CreateUserNm] [varchar](100) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[LastModifyUser] [int] NOT NULL,
	[LastModifyUserNm] [varchar](100) NOT NULL,
	[LastModifyDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ACC_USERROLE] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[ACC_UserRole]  WITH NOCHECK ADD  CONSTRAINT [FK_ACC_USER_REFERENCE_ACC_ROLE] FOREIGN KEY([RoleId])
REFERENCES [dbo].[ACC_Role] ([Id])
GO

ALTER TABLE [dbo].[ACC_UserRole] CHECK CONSTRAINT [FK_ACC_USER_REFERENCE_ACC_ROLE]
GO

ALTER TABLE [dbo].[ACC_UserRole]  WITH NOCHECK ADD  CONSTRAINT [FK_ACC_USER_REFERENCE_ACC_USER2] FOREIGN KEY([UserId])
REFERENCES [dbo].[ACC_User] ([Id])
GO

ALTER TABLE [dbo].[ACC_UserRole] CHECK CONSTRAINT [FK_ACC_USER_REFERENCE_ACC_USER2]
GO


/****** Object:  Table [dbo].[SYS_CodeDet]    Script Date: 2015/2/3 11:24:16 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE type='U' and name='SYS_CodeDet')
DROP TABLE [dbo].[SYS_CodeDet]
CREATE TABLE [dbo].[SYS_CodeDet](
	[Id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Code] [varchar](50) NOT NULL,
	[Value] [varchar](100) NOT NULL,
	[Desc1] [varchar](100) NOT NULL,
	[IsDefault] [bit] NOT NULL,
	[Seq] [int] NOT NULL,
 CONSTRAINT [PK_SYS_CODEDET] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[SYS_CodeDet]  WITH NOCHECK ADD  CONSTRAINT [FK_SYS_CODE_REFERENCE_SYS_CODE] FOREIGN KEY([Code])
REFERENCES [dbo].[SYS_CodeMstr] ([Code])
GO

ALTER TABLE [dbo].[SYS_CodeDet] CHECK CONSTRAINT [FK_SYS_CODE_REFERENCE_SYS_CODE]
GO


/****** Object:  Table [dbo].[SYS_CodeMstr]    Script Date: 2015/2/3 11:24:40 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE type='U' and name='SYS_CodeMstr')
DROP TABLE [dbo].[SYS_CodeMstr]
CREATE TABLE [dbo].[SYS_CodeMstr](
	[Code] [varchar](50) NOT NULL,
	[Desc1] [varchar](100) NOT NULL,
	[Type] [tinyint] NOT NULL,
 CONSTRAINT [PK_SYS_CODEMSTR] PRIMARY KEY CLUSTERED 
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


/****** Object:  Table [dbo].[SYS_EntityPreference]    Script Date: 2015/2/3 11:24:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE type='U' and name='SYS_EntityPreference')
DROP TABLE [dbo].[SYS_EntityPreference]
CREATE TABLE [dbo].[SYS_EntityPreference](
	[Id] [int] NOT NULL,
	[Seq] [int] NOT NULL,
	[Value] [varchar](100) NOT NULL,
	[Desc1] [varchar](100) NOT NULL,
	[CreateUser] [int] NOT NULL,
	[CreateUserNm] [varchar](100) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[LastModifyUser] [int] NOT NULL,
	[LastModifyUserNm] [varchar](100) NOT NULL,
	[LastModifyDate] [datetime] NOT NULL,
 CONSTRAINT [PK_SYS_ENTITYPREFERENCE] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


/****** Object:  Table [dbo].[SYS_Menu]    Script Date: 2015/2/3 11:25:17 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE type='U' and name='SYS_Menu')
DROP TABLE [dbo].[SYS_Menu]
CREATE TABLE [dbo].[SYS_Menu](
	[Code] [varchar](50) NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[Parent] [varchar](50) NULL,
	[Seq] [int] NOT NULL,
	[Desc1] [varchar](50) NOT NULL,
	[PageUrl] [varchar](256) NULL,
	[ImageUrl] [varchar](256) NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_SYS_MENU] PRIMARY KEY CLUSTERED 
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO



/****** Object:  Table [dbo].[[[MD_Supplier]]]    Script Date: 2015/2/3 11:09:35 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE type='U' and name='MD_Supplier')
DROP TABLE [dbo].[MD_Supplier]
CREATE TABLE [dbo].[MD_Supplier](
	[Code] [varchar](50) NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[Address] [varchar](50) NULL,
	[Email] [varchar](50) NULL,
	[ContactPerson][varchar](50) NULL,
	[ContactPhone] [varchar](50) NULL,
	[IsActive] [bit] NOT NULL,
	[CreateUser] [int] NOT NULL,
	[CreateUserNm] [varchar](100) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[LastModifyUser] [int] NOT NULL,
	[LastModifyUserNm] [varchar](100) NOT NULL,
	[LastModifyDate] [datetime] NOT NULL,
 CONSTRAINT [PK_MD_Supplier] PRIMARY KEY CLUSTERED 
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
go


/****** Object:  Table [dbo].[[[MD_Supplier]]]    Script Date: 2015/2/3 11:09:35 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE type='U' and name='MD_Plant')
DROP TABLE [dbo].[MD_Plant]
CREATE TABLE [dbo].[MD_Plant](
	[Code] [varchar](50) NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[Address] [varchar](50) NULL,
	[Email] [varchar](50) NULL,
	[ContactPerson][varchar](50) NULL,
	[ContactPhone] [varchar](50) NULL,
	[IsActive] [bit] NOT NULL,
	[CreateUser] [int] NOT NULL,
	[CreateUserNm] [varchar](100) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[LastModifyUser] [int] NOT NULL,
	[LastModifyUserNm] [varchar](100) NOT NULL,
	[LastModifyDate] [datetime] NOT NULL,
 CONSTRAINT [PK_MD_Plant] PRIMARY KEY CLUSTERED 
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
go


/****** Object:  Table [dbo].[MD_Uom]    Script Date: 2015/2/4 14:48:52 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE type='U' and name='MD_Uom')
DROP TABLE [dbo].[MD_Uom]
CREATE TABLE [dbo].[MD_Uom](
	[Code] [varchar](5) NOT NULL,
	[Desc1] [varchar](20) NOT NULL,
	[CreateUser] [int] NOT NULL,
	[CreateUserNm] [varchar](100) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[LastModifyUser] [int] NOT NULL,
	[LastModifyUserNm] [varchar](100) NOT NULL,
	[LastModifyDate] [datetime] NOT NULL,
 CONSTRAINT [PK_MD_UOM] PRIMARY KEY CLUSTERED 
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO


/****** Object:  Table [dbo].[MD_Uom]    Script Date: 2015/2/4 14:48:52 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE type='U' and name='MD_UomConv')
DROP TABLE [dbo].[MD_UomConv]
CREATE TABLE [dbo].[MD_UomConv](
	[Id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Item] [varchar](50) NULL,
	[BaseUom] [varchar](5) NOT NULL,
	[AltUom] [varchar](5) NOT NULL,
	[BaseQty] [decimal](18, 8) NOT NULL,
	[AltQty] [decimal](18, 8) NOT NULL,
	[CreateUser] [int] NOT NULL,
	[CreateUserNm] [varchar](100) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[LastModifyUser] [int] NOT NULL,
	[LastModifyUserNm] [varchar](100) NOT NULL,
	[LastModifyDate] [datetime] NOT NULL,
 CONSTRAINT [PK_MD_UOMCONV] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[MD_UomConv]  WITH NOCHECK ADD  CONSTRAINT [FK_MD_UOMCO_REFERENCE_MD_ITEM] FOREIGN KEY([Item])
REFERENCES [dbo].[MD_Item] ([Code])
GO

ALTER TABLE [dbo].[MD_UomConv] CHECK CONSTRAINT [FK_MD_UOMCO_REFERENCE_MD_ITEM]
GO

ALTER TABLE [dbo].[MD_UomConv]  WITH NOCHECK ADD  CONSTRAINT [FK_MD_UOMCO_REFERENCE_MD_UOM] FOREIGN KEY([BaseUom])
REFERENCES [dbo].[MD_Uom] ([Code])
GO

ALTER TABLE [dbo].[MD_UomConv] CHECK CONSTRAINT [FK_MD_UOMCO_REFERENCE_MD_UOM]
GO

ALTER TABLE [dbo].[MD_UomConv]  WITH NOCHECK ADD  CONSTRAINT [FK_MD_UOMCO_REFERENCE_MD_UOM2] FOREIGN KEY([AltUom])
REFERENCES [dbo].[MD_Uom] ([Code])
GO

ALTER TABLE [dbo].[MD_UomConv] CHECK CONSTRAINT [FK_MD_UOMCO_REFERENCE_MD_UOM2]
GO



/****** Object:  Table [dbo].[MD_Location]    Script Date: 2015/2/4 16:37:19 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE type='U' and name='MD_Location')
DROP TABLE [dbo].[MD_Location]
CREATE TABLE [dbo].[MD_Location](
	[Code] [varchar](50) NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[Plant] [varchar](50),
	[IsActive] [bit] NOT NULL,
	[SAPLocation] [varchar](50) NOT NULL,
	[CreateUser] [int] NOT NULL,
	[CreateUserNm] [varchar](100) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[LastModifyUser] [int] NOT NULL,
	[LastModifyUserNm] [varchar](100) NOT NULL,
	[LastModifyDate] [datetime] NOT NULL,
 CONSTRAINT [PK_MD_LOCATION] PRIMARY KEY CLUSTERED 
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[MD_Location]  WITH NOCHECK ADD  CONSTRAINT [FK_MD_LOCATION_REFERENCE_MD_PLANT] FOREIGN KEY([PLANT])
REFERENCES [dbo].[MD_Plant] ([Code])



/****** Object:  Table [dbo].[MD_Location]    Script Date: 2015/2/4 16:37:19 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE type='U' and name='SCM_SupplierPlant')
DROP TABLE [dbo].[SCM_SupplierPlant]
CREATE TABLE [dbo].[SCM_SupplierPlant](
	[Code] [varchar](50) NOT NULL primary key,
	[Desc1] [varchar](50) NOT NULL,
	[SupplierCode] [varchar](50) NOT NULL,
	[SupplierName] [varchar](50) NULL,
	[SupplierAddress] [varchar](50) NULL,
	[SupplierContactPerson] [varchar](50) NULL,
	[SupplierContactPhone] [varchar](50) NULL,
	[PlantCode] [varchar](50) NOT NULL,
	[PlantName] [varchar](50) NULL,
	[PlantAddress] [varchar](50) NULL,
	[PlantContactPerson] [varchar](50) NULL,
	[PlantContactPhone] [varchar](50) NULL,
	[Dock] [varchar](50) NULL,
)
ALTER TABLE [dbo].[SCM_SupplierPlant]  WITH NOCHECK ADD  CONSTRAINT [FK_SCM_SUPPLIERPLANT_REFERENCE_MD_SUPPLIER] FOREIGN KEY([SupplierCode])
REFERENCES [dbo].[MD_Supplier] ([Code])
GO
ALTER TABLE [dbo].[SCM_SupplierPlant]  WITH NOCHECK ADD  CONSTRAINT [FK_SCM_SUPPLIERPLANT_REFERENCE_MD_PLANT] FOREIGN KEY([PlantCode])
REFERENCES [dbo].[MD_Plant] ([Code])
GO

/****** Object:  Table [dbo].[MD_Location]    Script Date: 2015/2/4 16:37:19 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE type='U' and name='SCM_SupplierItem')
DROP TABLE [dbo].[SCM_SupplierItem]
CREATE TABLE [dbo].[SCM_SupplierItem](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[SupplierPlant] [varchar](50) NOT NULL,
	[ItemCode] [varchar](50) NOT NULL,
	[ItemDesc] [varchar](50) NULL,
	[Uom] [varchar](5) NOT NULL,
	[UnitCount][numeric](9, 2) NOT NULL,
	[SupplierCode] [varchar](50) NOT NULL,
	[SupplierDesc] [varchar](50) NULL,
	[Location] [varchar](50) NOT NULL,
	[LocationDesc] [varchar](50) NULL,
	[Dock] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[ItemCode] ASC,
	[SupplierCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[SCM_SupplierItem]  WITH NOCHECK ADD  CONSTRAINT [FK_SCM_SUPPLIERITEM_REFERENCE_SCM_SUPPLIERPLANT] FOREIGN KEY([SupplierPlant])
REFERENCES [dbo].[SCM_SupplierPlant] ([Code])
go
ALTER TABLE [dbo].[SCM_SupplierItem]  WITH NOCHECK ADD  CONSTRAINT [FK_SCM_SUPPLIERITEM_REFERENCE_MD_ITEM] FOREIGN KEY([ItemCode])
REFERENCES [dbo].[MD_Item] ([Code])
GO
ALTER TABLE [dbo].[SCM_SupplierItem]  WITH NOCHECK ADD  CONSTRAINT [FK_SCM_SUPPLIERITEM_REFERENCE_MD_Supplier] FOREIGN KEY([SupplierCode])
REFERENCES [dbo].[MD_Supplier] ([Code])
GO

