SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF EXISTS(SELECT * FROM sys.objects WHERE type='P' AND name='USP_Busi_CancelReceiveVanProdOrder') 
     DROP PROCEDURE USP_Busi_CancelReceiveVanProdOrder
GO

CREATE PROCEDURE USP_Busi_CancelReceiveVanProdOrder 
(
	@TraceCode varchar(50),
	@CancelUserId int,
	@CancelUserNm varchar(50)
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
       
		Declare @OrderNo varchar(50)
		Declare @Status tinyint
		Declare @Version int
		
		select top 1 @OrderNo = OrderNo from ORD_OrderMstr_4 where TraceCode = @TraceCode and ProdLineType in (3, 4)
		if @OrderNo = null
		begin
			set @ErrorMsg = N'Van��' + @TraceCode + N'������ȷ������������������������û�е��룬����ȡ��������ⱨ����'
			RAISERROR(@ErrorMsg, 16, 1)
		end
		
		select @Status = mstr.[Status], @Version = mstr.[Version]
		from ORD_OrderMstr_4 as mstr inner join ORD_OrderSeq as seq on mstr.OrderNo = seq.OrderNo 
		where mstr.OrderNo = @OrderNo

		if @Status <> 3
		begin
			if @Status = 4
			begin
				set @ErrorMsg = N'Van��' + @TraceCode + N'�����Ѿ����壬����ȡ��������ⱨ����'
				RAISERROR(@ErrorMsg, 16, 1)
			end
			else
			begin
				set @ErrorMsg = N'Van��' + @TraceCode + N'��δ������ⱨ����'
				RAISERROR(@ErrorMsg, 16, 1)
			end
		end
		
		if not exists(select top 1 1 from ORD_OrderOp as op
					where op.OrderNo = @OrderNo and op.IsAutoReport = 0 and op.WorkCenter is not null)
		begin
			set @ErrorMsg = N'Van��' + @TraceCode + N'û���ҵ�������ⱨ�������޷�ȡ��������ⱨ����'
			RAISERROR(@ErrorMsg, 16, 1)	
		end
		
		if exists(select top 1 1 from ORD_OrderOp as op
					where op.OrderNo = @OrderNo and op.IsAutoReport = 0 and op.WorkCenter is not null
					group by op.IsAutoReport having COUNT(1) > 1)
		begin
			set @ErrorMsg = N'Van��' + @TraceCode + N'�ҵ����������ⱨ�������޷�ȡ��������ⱨ����'
			RAISERROR(@ErrorMsg, 16, 1)	
		end
		
		--����������״̬Ϊִ����
		update ORD_OrderMstr_4 set [Status] = 2,
		CompleteDate = null, CompleteUser = null, CompleteUserNm = null, 
		LastModifyDate = @DateTimeNow, LastModifyUser = @CancelUserId, LastModifyUserNm = @CancelUserNm, 
		[Version] = [Version] + 1
		where OrderNo = @OrderNo and [Version] = @Version
		
		if @@rowcount = 0
		begin
			set @ErrorMsg = N'Van��' + @TraceCode + N'������������' + @OrderNo + N'�Ѿ����£�������ȡ��������ⱨ����'
			RAISERROR(@ErrorMsg, 16, 1)
		end
		
		Declare @OrderOpId int
		Declare @OrderOpVersion int
		Declare @OrderOpReportId int
		Declare @OrderOpReportVersion int
		Declare @OrderOpReportStatus tinyint
		
		select @OrderOpId = op.Id, @OrderOpVersion = op.[Version], @OrderOpReportId = rpt.Id,
		@OrderOpReportStatus = rpt.[Status], @OrderOpReportVersion = rpt.[Version] 
		from ORD_OrderOp as op
		inner join ORD_OrderOpReport as rpt on op.Id = rpt.OrderOpId
		where op.OrderNo = @OrderNo and op.IsAutoReport = 0 and op.WorkCenter is not null
		
		if @OrderOpReportVersion <> 0
		begin
			set @ErrorMsg = N'Van��' + @TraceCode + N'�Ѿ�ȡ��������ⱨ����'
			RAISERROR(@ErrorMsg, 16, 1)
		end
		
		--���¶�����������
		update ORD_OrderOp set ReportQty = 0, LastModifyUser = @CancelUserId, LastModifyUserNm = @CancelUserNm,
		LastModifyDate = @DateTimeNow, [Version] = [Version] + 1 
		where Id = @OrderOpId and [Version] = @OrderOpVersion
		
		if @@rowcount = 0
		begin
			set @ErrorMsg = N'Van��' + @TraceCode + N'������������' + @OrderNo + N'�Ѿ����£�������ȡ��������ⱨ����'
			RAISERROR(@ErrorMsg, 16, 1)
		end
		
		--���±���״̬Ϊȡ��
		update ORD_OrderOpReport set [Status] = 1, 
		CancelDate = @DateTimeNow, CancelUser = @CancelUserId, CancelUserNm = @CancelUserNm,
		LastModifyDate = @DateTimeNow, LastModifyUser = @CancelUserId, LastModifyUserNm = @CancelUserNm,
		[Version] = [Version] + 1
		where Id = @OrderOpReportId and [Version] = @OrderOpReportVersion
		
		if @@rowcount = 0
		begin
			set @ErrorMsg = N'Van��' + @TraceCode + N'������������' + @OrderNo + N'�Ѿ����£�������ȡ��������ⱨ����'
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
END 
