
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF EXISTS(SELECT * FROM sys.objects WHERE type='P' AND name='USP_Busi_LotNoScan') 
     DROP PROCEDURE USP_Busi_LotNoScan 
GO
CREATE PROCEDURE [dbo].[USP_Busi_LotNoScan]
(
	@OpRef varchar(50),
	@TraceCode varchar(50),
	@Barcode varchar(50),
	@CreateUserId int,
	@CreateUserNm varchar(100)
) --WITH ENCRYPTION
AS
BEGIN
	set nocount on
	declare @SupplierShortCode varchar(50)
	declare @ItemShortCode varchar(50)
	declare @LotNo varchar(50)
	declare @SupplierCode varchar(50)
	declare @HuPreFix varchar(50)
	declare @ItemCode varchar(50)
	declare @ItemDesc varchar(100)
	declare @ProdLine varchar(50)
	declare @OrderNo varchar(50)
	declare @PrevTraceCode int
	declare @ErrorMsg nvarchar(Max)
	declare @trancount int = @@trancount
	declare @NowTime datetime =GETDATE()
	declare @PrevSeq bigint
	declare @PrevSubSeq  int
	declare @CurrentSeq bigint
	declare @CurrentSubSeq int
	
	begin try
		if @trancount = 0
		begin
            begin tran
        end
		
		if ISNULL(@OpRef, '') = ''
		begin
			RAISERROR(N'��λ����Ϊ�ա�', 16, 1)
		end
		else
		begin
			select @ProdLine=Code from SCM_FlowMstr where Routing=(select Routing from PRD_RoutingDet where OpRef=@OpRef)
			if ISNULL(@ProdLine,'')=''
			begin
			    set @ErrorMsg=N'��λ'+@OpRef+'�Ҳ�����Ӧ�������ߡ�'
				RAISERROR(@ErrorMsg,16,1)
			end
		end
		
		if ISNULL(@TraceCode, '') = ''
		begin
			RAISERROR(N'Van�Ų���Ϊ�ա�', 16, 1)
		end
		
		
		-- ͨ��Van���������ҵ���ǰɨ�賵����Ϣ
		select top 1 @OrderNo=OrderNo,@CurrentSeq=Seq,@CurrentSubSeq=SubSeq	from ORD_OrderSeq where ProdLine=@ProdLine and TraceCode=@TraceCode 
		
		if ISNULL(@OrderNo,'')=''
		begin
			set @ErrorMsg=N'Van��'+@TraceCode+'��λ'+@OpRef+'�Ҳ�����������'
			RAISERROR(@ErrorMsg, 16, 1)
		end
		if ISNULL(@Barcode, '') = ''
		begin
			RAISERROR(N'���벻��Ϊ�ա�', 16, 1)
		end
		
		if  exists(select top 1 1 from PRD_LotNoScan where LotNo = @Barcode)
		begin
			RAISERROR(N'�Ѿ�ɨ������������롣', 16, 1)
		end
		
		select @HuPreFix = PreFixed from SYS_SNRule where Code = 2001
		
		if SUBSTRING(@Barcode, 1, 2) = @HuPreFix
		begin
			select top 1 @ItemCode = Item, @ItemDesc = ItemDesc 
			from INV_Hu where HuId = @Barcode
			
			if @ItemCode is null
			begin
				RAISERROR(N'���벻���ڡ�', 16, 1)
			end
		end
		else
		begin
			if LEN(@Barcode) <> 17
			begin
				RAISERROR(N'���볤�Ȳ���17λ��', 16, 1)
			end
		
			if LEN(@Barcode) = 17
			begin
				set @SupplierShortCode = Substring(@Barcode, 1, 4)
				set @ItemShortCode = Substring(@Barcode, 5, 5)
				set @LotNo = Substring(@Barcode, 10, 4)
				
				select top 1 @SupplierCode = Code from MD_Supplier where ShortCode = @SupplierShortCode
				
				if  @SupplierCode is null
				begin
					RAISERROR(N'�����еĹ�Ӧ�̶̴��벻��ȷ��', 16, 1)
				end
				
				
				declare @ItemShotCodeCount int	
				
				select @ItemShotCodeCount = COUNT(1)  from MD_Item where ShortCode = @ItemShortCode	
				
				if @ItemShotCodeCount = 0
				begin
					RAISERROR(N'�����е�����̴��벻���ڡ�', 16, 1)
				end
				else if @ItemShotCodeCount = 1
				begin
					select @ItemCode = Code, @ItemDesc = Desc1 from MD_Item where ShortCode = @ItemShortCode	
				end
				else
				begin
					RAISERROR(N'�����е�����̴����ҵ��������ϴ��롣', 16, 1)
				end
			end
		end
		
		--�ҵ�����������ɨ��������һ̨��
		declare @PrevItem varchar(50)
		declare @PrevItemDesc varchar(50)
		declare @PrevBarcode varchar(50)
		select top 1 @PrevTraceCode=TraceCode,@PrevItem=Item,@PrevItemDesc=ItemDesc,@PrevBarcode=LotNo from PRD_LotNoScan where ProdLine=@ProdLine order by Id desc
		
		--��¼ɨ����Ϣ
		insert into  PRD_LotNoScan (ProdLine, OpRef, Item,ItemDesc, LotNo, OrderNo, TraceCode, CreateUser, CreateUserNm, CreateDate)
			values(@ProdLine,@OpRef,@ItemCode,@ItemDesc,@Barcode,@OrderNo,@TraceCode,@CreateUserId,@CreateUserNm,@NowTime)
		
		if ISNULL(@PrevTraceCode,'')<>''
		begin
			select top 1 @PrevSeq=Seq,@PrevSubSeq=SubSeq from ORD_OrderSeq where ProdLine=@ProdLine and TraceCode=@PrevTraceCode 
			insert into  PRD_LotNoTrace (ProdLine, OpRef, Item,ItemDesc, LotNo, OrderNo, TraceCode, CreateUser, CreateUserNm, CreateDate)
			select @ProdLine,@OpRef,@PrevItem,@PrevItemDesc,@PrevBarcode,OrderNo,TraceCode,@CreateUserId,@CreateUserNm,@NowTime from ORD_OrderSeq  where ProdLine=@ProdLine  and ((Seq =@PrevSeq and SubSeq>@PrevSubSeq )or(Seq >@PrevSeq and Seq <@CurrentSeq) or (Seq=@CurrentSeq and SubSeq<@CurrentSubSeq))
			 order by Seq,SubSeq asc  --��¼2������֮������еĳ�������Ϣ
		end
		--��¼��̨����Ϣ������Ϣ
		insert into  PRD_LotNoTrace (ProdLine, OpRef, Item,ItemDesc, LotNo, OrderNo, TraceCode, CreateUser, CreateUserNm, CreateDate)
			values(@ProdLine,@OpRef,@ItemCode,@ItemDesc,@Barcode,@OrderNo,@TraceCode,@CreateUserId,@CreateUserNm,@NowTime)
		
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

GO


