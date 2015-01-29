SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF EXISTS(SELECT * FROM sys.objects WHERE type='P' AND name='USP_Busi_CancelStartEmptyVanProdOrder') 
     DROP PROCEDURE USP_Busi_CancelStartEmptyVanProdOrder
GO

CREATE PROCEDURE [dbo].[USP_Busi_CancelStartEmptyVanProdOrder] 
(
	@ProdLine varchar(50),
	@OrderSeqId int,
	@CancelUserId int,
	@CancelUserNm varchar(50)
) --WITH ENCRYPTION
AS 
BEGIN 
/*
USP_Busi_CancelStartEmptyVanProdOrder 'RAC00',4,3088,'jey'
*/
	set nocount on
	declare @DateTimeNow datetime = GetDate()
	declare @ErrorMsg nvarchar(MAX)
	declare @trancount int = @@trancount
		
	begin try
		if @trancount = 0
		begin
            begin tran
        end
      
		if exists(select top 1 * from SCM_FlowMstr where Code = @ProdLine and IsPause = 1)
		begin
			set @ErrorMsg = N'����������' + @ProdLine + N'�Ѿ���ͣ������ȡ���ճ����ߡ�'
			RAISERROR(@ErrorMsg, 16, 1)
		end
		
		Declare @Seq bigint	
		Declare @SubSeq int	
		select @Seq = seq.Seq, @SubSeq = SubSeq from ORD_OrderSeq as seq where Id=@OrderSeqId
		
		delete from ORD_OrderSeq where Id =@OrderSeqId
		
		--��˳��Ŵ�����һ̨������������˳�� - 1
		update ORD_OrderSeq set SubSeq = SubSeq - 1, LastModifyUser = @CancelUserId, LastModifyUserNm = @CancelUserNm, 
		LastModifyDate = @DateTimeNow, [Version] = [Version] + 1
		where ProdLine = @ProdLine and Seq = @Seq and SubSeq > @SubSeq
		
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
	
	--begin try
	--	--������������ʱ��
	--	exec USP_Busi_UpdateOrderBomConsumeTime @ProdLine, @CancelUserId, @CancelUserNm
	--end try
	--begin catch
	--	set @ErrorMsg = Error_Message() 
	--	RAISERROR(@ErrorMsg, 16, 1) 
	--end catch 
END 
