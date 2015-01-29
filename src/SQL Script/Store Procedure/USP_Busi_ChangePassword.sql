SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF EXISTS(SELECT * FROM sys.objects WHERE type='P' AND name='USP_Busi_ChangePassword') 
     DROP PROCEDURE USP_Busi_ChangePassword 
GO

CREATE PROCEDURE [dbo].[USP_Busi_ChangePassword] 
( 
	@UserId int, 
	@Password varchar(50)
) 
AS 
BEGIN 
	set nocount on
	declare @ErrorMsg nvarchar(MAX)
	declare @Trancount int = @@Trancount
	declare @UserCode varchar(50)
	declare @LinkServer varchar(50)
	declare @DBName varchar(50)
	DECLARE @Statement nvarchar(4000)
	DECLARE @Parameters nvarchar(4000)

	begin try
		begin try
			select @UserCode = Code from ACC_User where Id = @UserId
			select @LinkServer = LinkServer, @DBName = DBName from SYS_PortalSetting where IsPrimary = 0
			SET @Statement='Set ARITHABORT ON;UPDATE ' + CASE WHEN ISNULL(@LinkServer, '') = '' THEN '' ELSE (@LinkServer + '.') END + @DBName + '.dbo.ACC_User set Password = @Password_1 where Code = @UserCode_1'
			SET @Parameters='@Password_1 varchar(50), @UserCode_1 varchar(50)'
		end try
		begin catch
			set @ErrorMsg = N'数据准备出现异常：' + Error_Message()
			RAISERROR(@ErrorMsg, 16, 1) 
		end catch
		
		begin try
			if @Trancount = 0
			begin
				SET XACT_abort ON
				begin distributed tran
			end

			UPDATE ACC_User set Password = @Password where Id = @UserId
			EXEC SP_EXECUTESQL @Statement,@Parameters,@Password_1=@Password,@UserCode_1=@UserCode
	
			if @Trancount = 0 
			begin  
				commit
			end
		end try
		begin catch
			if @Trancount = 0
			begin
				rollback
			end 

			set @ErrorMsg = N'数据更新出现异常：' + Error_Message()
			RAISERROR(@ErrorMsg, 16, 1) 
		end catch
	end try
	begin catch
		set @ErrorMsg = N'更新用户密码出现异常：' + Error_Message()
		RAISERROR(@ErrorMsg, 16, 1) 
	end catch
END