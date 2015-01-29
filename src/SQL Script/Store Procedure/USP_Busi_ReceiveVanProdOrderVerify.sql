SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF EXISTS(SELECT * FROM sys.objects WHERE type='P' AND name='USP_Busi_ReceiveVanProdOrderVerify') 
     DROP PROCEDURE USP_Busi_ReceiveVanProdOrderVerify
GO

CREATE PROCEDURE [dbo].[USP_Busi_ReceiveVanProdOrderVerify] 
(
	@OrderNo varchar(50),
	@IsCheckIssue bit,
	@IsCheckItemTrace bit,
	@IsForce bit
) --WITH ENCRYPTION
AS 
BEGIN 
	set nocount on
	Declare @ErrorMsg nvarchar(MAX)
	Declare @Status tinyint
	Declare @ProdLine varchar(50)
	Declare @Seq bigint
	Declare @SubSeq int
	Declare @PauseStatus tinyint
	Declare @PauseSeq int
	Declare @TraceCode varchar(50)
	Declare @ProdlineType int
	
	Create table #tempErrMsg
	(
		ErrMsg varchar(Max)
	)
	
	select @Status = mstr.[Status], @ProdLine = mstr.Flow, @Seq = seq.Seq, @SubSeq = SubSeq, 
	@PauseStatus = PauseStatus, @PauseSeq = PauseSeq, @TraceCode = mstr.TraceCode, @ProdlineType = mstr.ProdLineType
	from ORD_OrderMstr_4 as mstr inner join ORD_OrderSeq as seq on mstr.OrderNo = seq.OrderNo 
	where mstr.OrderNo = @OrderNo
	
	if @Status <> 2
	begin
		if @Status = 3 or @Status = 4
		begin
			set @ErrorMsg = N'����������' + @OrderNo + N'�Ѿ����ߡ�'
			RAISERROR(@ErrorMsg, 16, 1)
		end
		else
		begin
			set @ErrorMsg = N'����������' + @OrderNo + N'��δ���ߡ�'
			RAISERROR(@ErrorMsg, 16, 1)
		end
	end
	
	if @PauseStatus = 2
	begin
		set @ErrorMsg = N'����������' + @OrderNo + N'�Ѿ���ͣ���������ߡ�'
		RAISERROR(@ErrorMsg, 16, 1)
	end
	
	if @IsForce = 0 and not exists(select top 1 1 from CUST_ProductLineMap where CheckProdLine = @ProdLine or AssemblyProdLine = @ProdLine or SpecialProdLine = @ProdLine)
	begin
		if exists(select top 1 1 from ORD_OrderMstr_4 as mstr inner join ORD_OrderSeq as seq on mstr.OrderNo = seq.OrderNo 
					where mstr.Flow = @ProdLine and Status = 2 and PauseStatus <> 2 
					and (seq.Seq < @Seq or (seq.Seq = @Seq and seq.SubSeq < @SubSeq)))
		begin
			set @ErrorMsg = N'����������' + @OrderNo + N'����������' + @ProdLine + N'��һ�ŵȴ����ߵ���������'
			RAISERROR(@ErrorMsg, 16, 1)
		end
	end
		
	--if exists(select top 1 1 from SCM_FlowMstr where Code = @ProdLine and IsPause = 1) and (@ProdlineType = 1 or @ProdlineType = 2)
	--begin
		--set @ErrorMsg = N'����������' + @ProdLine + N'�Ѿ���ͣ��������' + @OrderNo + N'�������ߡ�'
		--RAISERROR(@ErrorMsg, 16, 1)
	--end
	
	if (@IsCheckIssue = 1 and exists(select top 1 * from ISS_IssueMstr where BackYards = @TraceCode and Status in (0, 1, 2)))
	begin
		insert into #tempErrMsg(ErrMsg) values(N'����������' + @OrderNo + N'��δ�رյ�ʧЧģʽ���������ߡ�')
		insert into #tempErrMsg(ErrMsg) select Content from ISS_IssueMstr where BackYards = @TraceCode and Status in (0, 1, 2) 
	end
	
	if (@IsCheckItemTrace = 1 and exists(select top 1 * from ORD_OrderItemTrace where OrderNo = @OrderNo and ScanQty < Qty))
	begin
		insert into #tempErrMsg(ErrMsg) values(N'����������' + @OrderNo + N'��δɨ��Ĺؼ������������ߡ�')
		insert into #tempErrMsg(ErrMsg) 
		select N'�ؼ������Ϻ�' + Item + N'����' + ISNULL(ItemDesc, '') + N'��ͼ��' + ISNULL(RefItemCode, '') + N'��λ' + ISNULL(OpRef, '') 
		from ORD_OrderItemTrace where OrderNo = @OrderNo and ScanQty < Qty
	end
	
	select ErrMsg from #tempErrMsg
	drop table #tempErrMsg
END 
