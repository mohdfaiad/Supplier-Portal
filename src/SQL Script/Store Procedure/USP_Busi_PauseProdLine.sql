SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF EXISTS(SELECT * FROM sys.objects WHERE type='P' AND name='USP_Busi_PauseProdLine') 
     DROP PROCEDURE USP_Busi_PauseProdLine
GO

CREATE PROCEDURE [dbo].[USP_Busi_PauseProdLine] 
(
	@ProdLine varchar(50),
	@CreateUserId int,
	@CreateUserNm varchar(50)
) --WITH ENCRYPTION
AS 
BEGIN 
	set nocount on
	declare @DateTimeNow datetime = GetDate()
	declare @ErrorMsg nvarchar(MAX)
	declare @trancount int = @@trancount
		
	begin try
		if @trancount = 0
		begin
            begin tran
        end
      
		declare @IsPause bit
		declare @ProdLineType tinyint
		
		select @IsPause = IsPause, @ProdLineType = ProdLineType from SCM_FlowMstr WITH (UPDLOCK,SERIALIZABLE) where Code = @ProdLine
		
		if @ProdLineType <>  1 and @ProdLineType <>  2 and @ProdLineType <>  3 and @ProdLineType <>  4
		begin
			set @ErrorMsg = N'������' + @ProdLine + N'�������������ߡ�'
			RAISERROR(@ErrorMsg, 16, 1)
		end
		
		if @IsPause = 1
		begin
			set @ErrorMsg = N'����������' + @ProdLine + N'�Ѿ���ͣ��'
			RAISERROR(@ErrorMsg, 16, 1)
		end
		
		--��������ͣ
		update SCM_FlowMstr set IsPause = 1, LastModifyDate = @DateTimeNow, LastModifyUser = @CreateUserId, LastModifyUserNm = @CreateUserNm where Code = @ProdLine
		
		--ɾ�������߶�Ӧ�Ĺ���������������ʱ��
		delete from ORD_OrderOpCPTime where VanProdLine = @ProdLine
		--delete from ORD_OrderBomCPTime where VanProdLine = @ProdLine
		
		if @trancount = 0 
		begin  
            commit
        end
	end try
	begin catch
        if @trancount = 0
        begin
            rollback
        end 
		
		set @ErrorMsg = Error_Message() 
		RAISERROR(@ErrorMsg, 16, 1) 
	end catch 
END 