SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF EXISTS(SELECT * FROM sys.objects WHERE type='P' AND name='USP_Busi_RestartVanProdOrder') 
     DROP PROCEDURE USP_Busi_RestartVanProdOrder
GO

CREATE PROCEDURE  [dbo].[USP_Busi_RestartVanProdOrder] 
(
	@OrderNo varchar(50),
	@InsertOrderNoBefore varchar(50),
	@IsForce bit,
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
		
		declare @PauseStatus tinyint
		declare @PauseSeq int
		declare @Status int
		declare @Version int
		declare @ProdLine varchar(50)
		declare @ProdLineType tinyint
		declare @TraceCode varchar(50)
		declare @IsPLPause bit
		declare @StatusBefore tinyint
		declare @PauseStatusBefore tinyint
		declare @CurrentSeqBefore int
		declare @ProdLineBefore varchar(50)
		declare @SeqBefore bigint
		declare @SubSeqBefore int
		declare @TraceCodeBefore varchar(50)
		declare @StatusAfter tinyint
		declare @ProdLineDesc varchar(50)
		
		select @PauseStatus = PauseStatus, @PauseSeq = PauseSeq, @Version = [Version], @ProdLine = Flow, @ProdLineType = ProdLineType, @Status = [Status], @TraceCode = TraceCode,@ProdLineDesc=FlowDesc
		from ORD_OrderMstr_4 where OrderNo = @OrderNo
		
		if not exists(select 1 from ORD_OrderMstr_4 as mstr inner join ORD_OrderSeq as seq on mstr.OrderNo = seq.OrderNo where mstr.OrderNo = @InsertOrderNoBefore)
		begin
			set @ErrorMsg = N'ָ���ָ�������������' + @InsertOrderNoBefore + N'�����ڡ�'
			RAISERROR(@ErrorMsg, 16, 1)
		end
		
		select @StatusBefore = [Status], @PauseStatusBefore = mstr.PauseStatus, @ProdLineBefore = mstr.Flow, @SeqBefore = seq.Seq, @SubSeqBefore = seq.SubSeq, @CurrentSeqBefore = mstr.CurtOp, @TraceCodeBefore = mstr.TraceCode
		from ORD_OrderMstr_4 as mstr inner join ORD_OrderSeq as seq on mstr.OrderNo = seq.OrderNo
		where mstr.OrderNo = @InsertOrderNoBefore
		
		select @IsPLPause = IsPause from SCM_FlowMstr where Code = @ProdLine
		
		if @ProdLine <> @ProdLineBefore
		begin
			set @ErrorMsg = N'����������' + @OrderNo + N' Van��' + @TraceCode + N'��ָ���ָ�������������' + @InsertOrderNoBefore + N'�����߲�һ�¡�'
			RAISERROR(@ErrorMsg, 16, 1)
		end
		
		if @StatusBefore = 3 or @StatusBefore = 4
		begin
			set @ErrorMsg = N'ָ���ָ�������������' + @InsertOrderNoBefore + N'�Ѿ����ߣ����ָܻ�������������֮��'
			RAISERROR(@ErrorMsg, 16, 1)
		end
		
		if @PauseStatusBefore <> 0
		begin
			set @ErrorMsg = N'ָ���ָ�������������' + @InsertOrderNoBefore + N'�Ѿ���ͣ�����ָܻ�������������֮��'
			RAISERROR(@ErrorMsg, 16, 1)
		end
		
		if @PauseStatus = 0
		begin
			set @ErrorMsg = N'����������' + @OrderNo + N' Van��' + @TraceCode + N'û����ͣ���ָܻ���'
			RAISERROR(@ErrorMsg, 16, 1)
		end
		
		if @IsPLPause = 1
		begin
			set @ErrorMsg = N'����������' + @ProdLine + N'�Ѿ���ͣ�����ָܻ�������������'
			RAISERROR(@ErrorMsg, 16, 1)
		end
		
		--if @PauseSeq > 0 and @PauseSeq < @CurrentSeqBefore
		--begin
		--	set @ErrorMsg = N'����������' + @OrderNo + N' Van��' + @TraceCode + N'����ͣ����С��ָ���ָ�������������' + @InsertOrderNoBefore + N'�ĵ�ǰ���򣬲��ָܻ�������������֮��'
		--	RAISERROR(@ErrorMsg, 16, 1)
		--end
		
		if @Status = 1 and @StatusBefore <> 1
		begin
			select top 1 @StatusAfter = mstr.[Status] from ORD_OrderMstr_4 as mstr 
					inner join ORD_OrderSeq as seq on mstr.OrderNo = seq.OrderNo
					where mstr.Flow = @ProdLine and (seq.Seq > @SeqBefore or (seq.Seq = @SeqBefore and seq.SubSeq > @SubSeqBefore)) and mstr.PauseStatus <> 2
					order by seq.Seq, seq.SubSeq
			
			if @StatusAfter <> 1
			begin
				set @ErrorMsg = N'����������' + @OrderNo + N' Van��' + @TraceCode + N'δ���ߣ����ָܻ��������ߵ�����������֮ǰ��'
				RAISERROR(@ErrorMsg, 16, 1)
			end
		end
		
		--todo ������е��Ƿ��ܹ���ʱ����
		--ѭ�������飬�����Ƿ������м���������м�û�з�����IsCreateOrder�������������Ҫ�����е�
		--�ٴ����������ҵ���ǰ��ת�ĳ�ͷ�����ָ����˳���Ƿ��ڸó�ͷ֮��
		Create table #tempMsg
		(
			Msg1 varchar(500),
			Msg2 varchar(500),
		)
		
		insert into #tempMsg(Msg1, Msg2)
		select N'����������' + @OrderNo + N' Van��' + @TraceCode + N'��δ���������򵥲��ָܻ�������������' + @InsertOrderNoBefore + N' Van��' + @TraceCodeBefore + N'���ɻָ�������������' + seq.OrderNo + N' Van��' + seq.TraceCode + N'֮��',
		N'����������' + @OrderNo + N' Van��' + @TraceCode + N'��δ����������' + sg.Code + N'��'
		from SCM_SeqGroup as sg
		inner join ORD_OrderSeq as seq on sg.PrevSeq = seq.Seq and sg.PrevSubSeq = seq.SubSeq and sg.ProdLine = seq.ProdLine
		left join ORD_SeqOrderTrace as trace on trace.TraceCode = @TraceCode and sg.Code = trace.SeqGroup
		where sg.ProdLine = @ProdLine and trace.Id is null 
		order by seq.Seq desc, seq.SubSeq desc
		
		if (@IsForce = 0)
		begin
			select top 1 @ErrorMsg = Msg1 from #tempMsg
			RAISERROR(@ErrorMsg, 16, 1)
		end
		else
		begin
			select Msg2 from #tempMsg
		end
		
		drop table #tempMsg
		
		--���ָ����Ƿ��������м�¼�����һ̨���������Ҫ���������еĸ��³����һ̨����ǰһ̨���������򵥽�ת����
		if exists(select top 1 1 from SCM_SeqGroup where PrevOrderNo = @OrderNo)
		begin
			declare @Seq bigint
			declare @SubSeq int
			declare @PrevOrderNo varchar(50)
			declare @PrevTraceCode varchar(50)
			declare @PrevSeq bigint
			declare @PrevSubSeq int
			
			--���������������һ̨����ǰһ̨
			select @Seq = Seq, @SubSeq = SubSeq from ORD_OrderSeq where OrderNo = @OrderNo
			
			select top 1 @PrevOrderNo = OrderNo, @PrevTraceCode = TraceCode, @PrevSeq = Seq, @PrevSubSeq = SubSeq
			from ORD_OrderSeq where (Seq < @Seq or (Seq = @Seq and SubSeq < @SubSeq)) and ProdLine = @ProdLine 
			order by Seq desc, SubSeq desc
		
			if @PrevOrderNo <> @InsertOrderNoBefore
			begin
				Create table #tempSeqGroup
				(
					SeqGroup varchar(50),
					[Version] int	
				)
				
				insert into #tempSeqGroup(SeqGroup, [Version])
				select Code, [Version] from SCM_SeqGroup where PrevOrderNo = @OrderNo
				
				if exists(select top 1 1 from #tempSeqGroup)
				begin
					update seq set PrevOrderNo = @PrevOrderNo, PrevTraceCode = @PrevTraceCode, PrevSeq = @PrevSeq, PrevSubSeq = @PrevSubSeq, [Version] = seq.[Version] + 1
					from SCM_SeqGroup as seq inner join #tempSeqGroup as tSeq on seq.Code = tSeq.SeqGroup and seq.[Version] = tSeq.[Version]
					
					if (@@ROWCOUNT <> (select COUNT(1) from #tempSeqGroup))
					begin
						set @ErrorMsg = N'����������' + @OrderNo + N' Van��' + @TraceCode + N'�Ѿ����£������»ָ���'
						RAISERROR(@ErrorMsg, 16, 1)
					end
				end
				
				drop table #tempSeqGroup
			end
		end
		
		--�������Ż��б�ǰһ̨����ģ������ + ��
		update ORD_OrderSeq set SubSeq = SubSeq + 1, LastModifyDate = @DateTimeNow, LastModifyUser = @CreateUserId, LastModifyUserNm = @CreateUserNm, [Version] = [Version] + 1
		where ProdLine = @ProdLine and Seq = @SeqBefore and SubSeq > @SubSeqBefore
		
		--���±�̨�����
		update ORD_OrderSeq set Seq = @SeqBefore, SubSeq = @SubSeqBefore + 1, LastModifyDate = @DateTimeNow, LastModifyUser = @CreateUserId, LastModifyUserNm = @CreateUserNm, [Version] = [Version] + 1
		where OrderNo = @OrderNo
		
		--���±�̨����ͣ״̬
		update ORD_OrderMstr_4 set PauseStatus = 0, PauseSeq = 0, PauseTime = null, LastModifyDate = @DateTimeNow, LastModifyUser = @CreateUserId, LastModifyUserNm = @CreateUserNm, [Version] = [Version] + 1
		where OrderNo = @OrderNo and [Version] = @Version
		
		---������ͣLOG��¼
		insert into LOG_ProdOrderPauseResume(ProdLine, ProdLineDesc, OrderNo, BeforeOrderNo, BeforeVanCode, BeforeSeq, BeforeSubSeq, 
		VanCode, Seq, SubSeq, OprateType, CreateUserName)
		values(@ProdLine, @ProdLineDesc, @OrderNo, @InsertOrderNoBefore, @TraceCodeBefore, @SeqBefore, @SubSeqBefore, 
		@TraceCode, @SeqBefore, @SubSeqBefore + 1, 3, @CreateUserNm)
		
		if @@ROWCOUNT <> 1
		begin
			set @ErrorMsg = N'����������' + @OrderNo + N' Van��' + @TraceCode + N'�Ѿ����£������»ָ���'
			RAISERROR(@ErrorMsg, 16, 1)
		end
		
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
	--	exec USP_Busi_UpdateOrderBomConsumeTime @ProdLine, @CreateUserId, @CreateUserNm
	--end try
	--begin catch
	--	set @ErrorMsg = Error_Message() 
	--	RAISERROR(@ErrorMsg, 16, 1) 
	--end catch
END 