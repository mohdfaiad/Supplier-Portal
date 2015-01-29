SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF EXISTS(SELECT * FROM sys.objects WHERE type='P' AND name='USP_Busi_PauseVanProdOrder') 
     DROP PROCEDURE USP_Busi_PauseVanProdOrder
GO

CREATE PROCEDURE [dbo].[USP_Busi_PauseVanProdOrder] 
(
	@OrderNo varchar(50),
	@PauseSeq int,
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
		
		declare @Status tinyint
		declare @PauseStatus tinyint
		declare @Version int
		declare @ProdLine varchar(50)
		declare @ProdLineType tinyint
		declare @IsPLPause bit
		declare @CurrentOp int
		declare @TraceCode varchar(50) ---Van��
		declare @ProdLineDesc varchar(50)
		declare @Seq bigint
		declare @SubSeq int
		declare @NormalPause int = 0 --������ͣ
		
		select @Status = mstr.[Status], @PauseStatus = mstr.PauseStatus, @Version = mstr.[Version], @ProdLine = mstr.Flow, @ProdLineType = mstr.ProdLineType, 
		@CurrentOp = mstr.CurtOp, @TraceCode = mstr.TraceCode, @ProdLineDesc = mstr.FlowDesc, @Seq = seq.Seq, @SubSeq = seq.SubSeq
		from ORD_OrderMstr_4 as mstr inner join ORD_OrderSeq as seq on mstr.OrderNo = seq.OrderNo where mstr.OrderNo = @OrderNo
		
		select @IsPLPause = IsPause from SCM_FlowMstr where Code = @ProdLine
	
		if @ProdLineType <> 1 and @ProdLineType <> 2 and @ProdLineType <> 3 and @ProdLineType <> 4
		begin
			set @ErrorMsg = N'������' + @OrderNo + N'�Ĳ���������������'
			RAISERROR(@ErrorMsg, 16, 1)
		end
		
		if @Status = 3 or @Status = 4
		begin
			set @ErrorMsg = N'����������' + @OrderNo + N'�Ѿ����߲�����ͣ��'
			RAISERROR(@ErrorMsg, 16, 1)
		end
		
		if @PauseStatus <> 0
		begin
			set @ErrorMsg = N'����������' + @OrderNo + N'�Ѿ���ͣ��'
			RAISERROR(@ErrorMsg, 16, 1)
		end
		
		if @IsPLPause = 1
		begin
			set @ErrorMsg = N'����������' + @ProdLine + N'�Ѿ���ͣ��������ͣ������������'
			RAISERROR(@ErrorMsg, 16, 1)
		end
		
		if @Status = 1
		begin  --����������δ���ߣ�ֱ����ͣ
			update ORD_OrderMstr_4 set PauseStatus = 2, PauseSeq = 0, LastModifyDate = @DateTimeNow, LastModifyUser = @CreateUserId, LastModifyUserNm = @CreateUserNm, [Version] = [Version] + 1
			where OrderNo = @OrderNo and [Version] = @Version
			
			if @@ROWCOUNT <> 1
			begin
				set @ErrorMsg = N'����������' + @OrderNo + N'�Ѿ����£���������ͣ��'
				RAISERROR(@ErrorMsg, 16, 1)
			end
			
			--ɾ���������ʱ��
			delete from ORD_OrderOpCPTime where OrderNo = @OrderNo
			
			--ɾ����������ʱ��
			--delete from ORD_OrderBomCPTime where OrderNo = @OrderNo
		end
		else
		begin  --���������������ߣ�����ͣ������ͣ
			if @PauseSeq is null
			begin
				set @ErrorMsg = N'����������' + @OrderNo + N'�Ѿ����ߣ���������ͣ����'
				RAISERROR(@ErrorMsg, 16, 1)
			end
			
			if @PauseSeq < @CurrentOp
			begin  --��ͣ����С�ڵ�ǰ���򣬱���
				set @ErrorMsg =  N'����������' + @OrderNo + N'����ͣ����С�ڵ�ǰ���ڹ���'
				RAISERROR(@ErrorMsg, 16, 1)
			end
			else if @PauseSeq = @CurrentOp
			begin  --��ͣ������ڵ�ǰ����ֱ����ͣ
				update ORD_OrderMstr_4 set PauseStatus = 2, LastModifyDate = @DateTimeNow, LastModifyUser = @CreateUserId, LastModifyUserNm = @CreateUserNm, [Version] = [Version] + 1
				where OrderNo = @OrderNo and [Version] = @Version
				
				if @@ROWCOUNT <> 1
				begin
					set @ErrorMsg = N'����������' + @OrderNo + N'�Ѿ����£���������ͣ��'
					RAISERROR(@ErrorMsg, 16, 1)
				end
				
				set @NormalPause=0--ֱ����ͣ
				
				--ɾ���������ʱ��
				delete from ORD_OrderOpCPTime where OrderNo = @OrderNo
				
				--ɾ����������ʱ��
				--delete from ORD_OrderBomCPTime where OrderNo = @OrderNo
			end
			else  --��ͣ������ڵ�ǰ����
			begin
				if not exists(select top 1 1 from ORD_OrderOp where OrderNo = @OrderNo and Op = @PauseSeq)
				begin
					set @ErrorMsg = N'�������ͣ���򲻴��ڡ�'
					RAISERROR(@ErrorMsg, 16, 1)
				end
				
				update ORD_OrderMstr_4 set PauseStatus = 1, PauseSeq = @PauseSeq, LastModifyDate = @DateTimeNow, LastModifyUser = @CreateUserId, LastModifyUserNm = @CreateUserNm, [Version] = [Version] + 1
				where OrderNo = @OrderNo and [Version] = @Version
				
				if @@ROWCOUNT <> 1
				begin
					set @ErrorMsg = N'����������' + @OrderNo + N'�Ѿ����£���������ͣ��'
					RAISERROR(@ErrorMsg, 16, 1)
				end
				
				set @NormalPause=1--������ͣ
				
				--���¼�����������ʱ��
				exec USP_Busi_UpdateOrderBomConsumeTime @ProdLine, @CreateUserId, @CreateUserNm
			end
		end
		
		---������ͣLOG��¼
		
		insert into LOG_ProdOrderPauseResume(ProdLine, ProdLineDesc, OrderNo, VanCode, CurrentOperation, PauseOp, OprateType, CreateUserName, Seq, SubSeq)
		values(@ProdLine, @ProdLineDesc, @OrderNo, @TraceCode, @CurrentOp, @PauseSeq, @NormalPause, @CreateUserNm, @Seq, @SubSeq)
		
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

