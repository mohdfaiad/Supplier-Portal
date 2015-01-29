SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF EXISTS(SELECT * FROM sys.objects WHERE type='P' AND name='USP_Busi_StartEmptyVanProdOrder') 
     DROP PROCEDURE USP_Busi_StartEmptyVanProdOrder
GO

CREATE PROCEDURE [dbo].[USP_Busi_StartEmptyVanProdOrder] 
(
	@ProdLine varchar(50),
	@StartUserId int,
	@StartUserNm varchar(50)
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
      
		Declare @Seq bigint	
		Declare @SubSeq int	
		
		--��ȡ���ߵ����һ̨�������
		select top 1 @Seq = seq.Seq, @SubSeq = SubSeq from ORD_OrderMstr_4 as mstr 
		inner join ORD_OrderSeq as seq on mstr.OrderNo = seq.OrderNo
		where mstr.Flow = @ProdLine and Status = 2 order by seq.Seq desc, seq.SubSeq desc
		
		if @Seq is null
		begin
			set @ErrorMsg = N'����������' + @ProdLine + N'û�������ߵ����������ܲ���ճ���'
			RAISERROR(@ErrorMsg, 16, 1)
		end
		
		if exists(select top 1 * from SCM_FlowMstr where Code = @ProdLine and IsPause = 1)
		begin
			set @ErrorMsg = N'����������' + @ProdLine + N'�Ѿ���ͣ�����ܲ���ճ���'
			RAISERROR(@ErrorMsg, 16, 1)
		end
		
		--��˳��Ŵ�����һ̨������������˳�� +��
		update ORD_OrderSeq set SubSeq = SubSeq + 1, LastModifyUser = @StartUserId, LastModifyUserNm = @StartUserNm, 
		LastModifyDate = @DateTimeNow, [Version] = [Version] + 1
		where ProdLine = @ProdLine and Seq = @Seq and SubSeq > @SubSeq
		
		--����ճ�
		insert into ORD_OrderSeq (
		ProdLine,
		OrderNo,
		TraceCode,
		Seq,
		SubSeq,
		SapSeq,
		CreateUser,
		CreateUserNm,
		CreateDate,
		LastModifyUser,
		LastModifyUserNm,
		LastModifyDate,
		[Version]
		)
		values( 
		@ProdLine,
		null,
		null,
		@Seq,
		@SubSeq + 1,
		0,
		@StartUserId,
		@StartUserNm,
		@DateTimeNow,
		@StartUserId,
		@StartUserNm,
		@DateTimeNow,
		1
		)
		
		--�����ƶ�һ����λ
		exec USP_Busi_MoveVanProdOrder @ProdLine, @StartUserId, @StartUserNm
		
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
