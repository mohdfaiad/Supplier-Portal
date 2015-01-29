SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF EXISTS(SELECT * FROM sys.objects WHERE type='P' AND name='USP_Busi_GenVanProdOrderVerify') 
     DROP PROCEDURE USP_Busi_GenVanProdOrderVerify
GO

CREATE PROCEDURE [dbo].[USP_Busi_GenVanProdOrderVerify] 
(
	@BatchNo int,
	@IsUpdate bit	
) --WITH ENCRYPTION
AS 
BEGIN 
	set nocount on
	declare @ErrorMsg nvarchar(MAX)
	
	Create table #tempWC
	(
		VanProdLine varchar(50),
		VanRouting varchar(50),
		WorkCenter varchar(50),
	)
	
	declare @SapProdLine varchar(50)  --SAP�����ߴ���A/B
	declare @SapOrderNo varchar(50)   --SAP��������������װ���������ţ����ǵ��̵��������ţ�
	declare @SapVAN varchar(50)       --VAN��
	
	declare @CabProdLine varchar(50)  --LES��ʻ�������ߴ���
	declare @CabProdLineRegion varchar(50)
	declare @CabLocFrom varchar(50)
	declare @CabLocTo varchar(50)
	declare @CabRouting varchar(50)
	declare @IsCabProdLineActive bit
	declare @CabProdLineType tinyint
	declare @CabTaktTime int
	declare @CabVirtualOpRef varchar(50)
	
	declare @ChassisProdLine varchar(50)  --LES���������ߴ���
	declare @ChassisProdLineRegion varchar(50)
	declare @ChassisLocFrom varchar(50)
	declare @ChassisLocTo varchar(50)
	declare @ChassisRouting varchar(50)
	declare @IsChassisProdLineActive bit
	declare @ChassisProdLineType tinyint
	declare @ChassisTaktTime int
	declare @ChassisVirtualOpRef varchar(50)
	
	declare @AssemblyProdLine varchar(50)  --LES��װ�����ߴ���
	declare @AssemblyProdLineRegion varchar(50)
	declare @AssemblyLocFrom varchar(50)
	declare @AssemblyLocTo varchar(50)
	declare @AssemblyRouting varchar(50)
	declare @IsAssemblyProdLineActive bit
	declare @AssemblyProdLineType tinyint
	declare @AssemblyTaktTime int
	declare @AssemblyVirtualOpRef varchar(50)
	
	declare @SpecialProdLine varchar(50)  --LES��װ�����ߴ���
	declare @SpecialProdLineRegion varchar(50)
	declare @SpecialLocFrom varchar(50)
	declare @SpecialLocTo varchar(50)
	declare @SpecialRouting varchar(50)
	declare @IsSpecialProdLineActive bit
	declare @SpecialProdLineType tinyint
	declare @SpecialTaktTime int
	declare @SpecialVirtualOpRef varchar(50)
	
	declare @CheckProdLine varchar(50)  --LES��������ߴ���
	declare @CheckProdLineRegion varchar(50)
	declare @CheckLocFrom varchar(50)
	declare @CheckLocTo varchar(50)
	declare @CheckRouting varchar(50)
	declare @IsCheckProdLineActive bit
	declare @CheckProdLineType tinyint
	declare @CheckTaktTime int
	declare @CheckVirtualOpRef varchar(50)
	
	declare @TransFlow varchar(50)  --LES������·�ߴ���
	declare @SaddleFlow varchar(50)  --LES����·�ߴ���
	

	
	--������������¼
	select @SapProdLine = ZLINE, @SapOrderNo = AUFNR, @SapVAN = CHARG from SAP_ProdOrder where BatchNo = @BatchNo
	
	--ɾ��SAP������־
	delete from LOG_GenVanProdOrder where AUFNR = @SapOrderNo
	
	if ISNULL(@SapProdLine, '') = ''
	begin
		set @ErrorMsg = N'SAP��������' + @SapOrderNo + N' Van��' + @SapVAN + N'û�����κ�' + CONVERT(varchar, @BatchNo) + N'��������������¼��'
		insert into LOG_GenVanProdOrder(AUFNR, ZLINE, BatchNo, Msg) values (@SapOrderNo, @SapProdLine, @BatchNo, @ErrorMsg)
		select Msg from LOG_GenVanProdOrder where AUFNR = @SapOrderNo
		return		
	end
	
	--����������ӳ����ҳ���ʻ�ҡ����̡���װ����װ�����ߣ��������Ͱ���·�ߴ���
	if not exists(select top 1 1 from CUST_ProductLineMap where SapProdLine = @SapProdLine)
	begin
		set @ErrorMsg = N'SAP��������' + @SapOrderNo + N' Van��' + @SapVAN + N'û��ά������������' + @SapProdLine + N'��ӳ���ϵ��'
		insert into LOG_GenVanProdOrder(AUFNR, ZLINE, BatchNo, Msg) values (@SapOrderNo, @SapProdLine, @BatchNo, @ErrorMsg) 
		select Msg from LOG_GenVanProdOrder where AUFNR = @SapOrderNo
		return		
	end
	else
	begin
		select @CabProdLine = CabProdLine, @ChassisProdLine = ChassisProdLine, 
		@AssemblyProdLine = AssemblyProdLine, @SpecialProdLine = SpecialProdLine,
		@TransFlow = TransFlow, @SaddleFlow = SaddleFlow, @CheckProdLine = CheckProdLine
		from CUST_ProductLineMap where SapProdLine = @SapProdLine and [Type] = 1
	end
	
	if (@IsUpdate = 0)
	begin
		--У��SAP�������Ƿ���
		if exists(select top 1 1 from ORD_OrderSeq where TraceCode = @SapVAN)
		begin
			set @ErrorMsg = N'����������' + @SapProdLine + N' SAP��������' + @SapOrderNo + N' Van��' + @SapVAN + N'�Ѿ����롣'
			insert into LOG_GenVanProdOrder(AUFNR, ZLINE, BatchNo, Msg) values (@SapOrderNo, @SapProdLine, @BatchNo, @ErrorMsg) 
			select Msg from LOG_GenVanProdOrder where AUFNR = @SapOrderNo
			return		
		end
	end
	else
	begin
		--У��SAP�������Ƿ���
		if not exists(select top 1 1 from ORD_OrderSeq where TraceCode = @SapVAN)
		begin
			set @ErrorMsg = N'����������' + @SapProdLine + N'û���ҵ�����������' + @SapVAN + N'��'
			insert into LOG_GenVanProdOrder(AUFNR, ZLINE, BatchNo, Msg) values (@SapOrderNo, @SapProdLine, @BatchNo, @ErrorMsg) 
			select Msg from LOG_GenVanProdOrder where AUFNR = @SapOrderNo
			return		
		end
		
		if exists(select top 1 1 from ORD_OrderMstr_4 as mstr
					inner join ORD_OrderOpReport as rp on mstr.OrderNo = rp.OrderNo
					 where mstr.TraceCode = @SapVAN)
		begin
			select top 1 @ErrorMsg = N'����������' + @SapProdLine + N' SAP��������' + @SapOrderNo + N' Van��' + @SapVAN + N'�Ѿ��������ܸ���Bom��' from ORD_OrderMstr_4 where TraceCode = @SapVAN and Status in (3, 4)
			insert into LOG_GenVanProdOrder(AUFNR, ZLINE, BatchNo, Msg) values (@SapOrderNo, @SapProdLine, @BatchNo, @ErrorMsg) 
			select Msg from LOG_GenVanProdOrder where AUFNR = @SapOrderNo
			return		
		end
	end
	
	
	
	
	-----------------------------����ʻ������У��-----------------------------
	if ISNULL(@CabProdLine, '') = ''
	begin
		set @ErrorMsg = N'SAP��������' + @SapOrderNo + N' Van��' + @SapVAN + N'û��ά������������' + @SapProdLine + N'ӳ���ϵ�еļ�ʻ�������ߡ�'
		insert into LOG_GenVanProdOrder(AUFNR, ZLINE, ProdLine, BatchNo, Msg) values (@SapOrderNo, @SapProdLine, @CabProdLine, @BatchNo, @ErrorMsg)
	end
	
	if not exists(select top 1 1 from SCM_FlowMstr where Code = @CabProdLine)
	begin
		set @ErrorMsg = N'SAP��������' + @SapOrderNo + N' Van��' + @SapVAN + N'û���ҵ���ʻ��������' + @CabProdLine + N'��'
		insert into LOG_GenVanProdOrder(AUFNR, ZLINE, ProdLine, BatchNo, Msg) values (@SapOrderNo, @SapProdLine, @CabProdLine, @BatchNo, @ErrorMsg)
	end
	
	--��ȡ��������Ϣ
	select @CabProdLineRegion = PartyFrom, @CabLocFrom = LocFrom, @CabLocTo = LocTo, @CabRouting = Routing, 
	@IsCabProdLineActive = IsActive, @CabProdLineType = ProdLineType, @CabTaktTime = TaktTime, @CabVirtualOpRef = VirtualOpRef
	from SCM_FlowMstr where Code = @CabProdLine
	
	if @IsCabProdLineActive = 0
	begin
		set @ErrorMsg = N'SAP��������' + @SapOrderNo + N' Van��' + @SapVAN + N'��ʻ��������' + @CabProdLine + N'û����Ч��'
		insert into LOG_GenVanProdOrder(AUFNR, ZLINE, ProdLine, BatchNo, Msg) values (@SapOrderNo, @SapProdLine, @CabProdLine, @BatchNo, @ErrorMsg)
	end
	
	if @CabTaktTime is null
	begin
		set @ErrorMsg = N'SAP��������' + @SapOrderNo + N' Van��' + @SapVAN + N'��ʻ��������' + @CabProdLine + N'û�����ý���ʱ�䡣'
		insert into LOG_GenVanProdOrder(AUFNR, ZLINE, ProdLine, BatchNo, Msg) values (@SapOrderNo, @SapProdLine, @CabProdLine, @BatchNo, @ErrorMsg)
	end
	else if @CabTaktTime <= 0
	begin
		set @ErrorMsg = N'SAP��������' + @SapOrderNo + N' Van��' + @SapVAN + N'��ʻ��������' + @CabProdLine + N'�Ľ���ʱ�䲻��С�ڵ���0��'
		insert into LOG_GenVanProdOrder(AUFNR, ZLINE, ProdLine, BatchNo, Msg) values (@SapOrderNo, @SapProdLine, @CabProdLine, @BatchNo, @ErrorMsg)
	end
	
	if ISNULL(@CabRouting, '') = ''
	begin
		set @ErrorMsg = N'SAP��������' + @SapOrderNo + N' Van��' + @SapVAN + N'û�����ü�ʻ��������' + @CabProdLine + N'�Ĺ������̡�'
		insert into LOG_GenVanProdOrder(AUFNR, ZLINE, ProdLine, BatchNo, Msg) values (@SapOrderNo, @SapProdLine, @CabProdLine, @BatchNo, @ErrorMsg)
	end
	
	if ISNULL(@CabVirtualOpRef, '') = ''
	begin
		set @ErrorMsg = N'SAP��������' + @SapOrderNo + N' Van��' + @SapVAN + N'û�����ü�ʻ��������' + @CabProdLine + N'�����⹤λ��'
		insert into LOG_GenVanProdOrder(AUFNR, ZLINE, ProdLine, BatchNo, Msg) values (@SapOrderNo, @SapProdLine, @CabProdLine, @BatchNo, @ErrorMsg)
	end

	if not exists(select top 1 1 from PRD_ProdLineWorkCenter where Flow = @CabProdLine)
	begin
		set @ErrorMsg = N'SAP��������' + @SapOrderNo + N' Van��' + @SapVAN + N'û���ҵ���ʻ��������' + @CabProdLine + N'�Ĺ������ġ�'
		insert into LOG_GenVanProdOrder(AUFNR, ZLINE, ProdLine, BatchNo, Msg) values (@SapOrderNo, @SapProdLine, @CabProdLine, @BatchNo, @ErrorMsg)
	end
	-----------------------------����ʻ������У��-----------------------------
	
	
	
	
	-----------------------------����������У��-----------------------------
	if ISNULL(@ChassisProdLine, '') = ''
	begin
		set @ErrorMsg = N'SAP��������' + @SapOrderNo + N' Van��' + @SapVAN + N'û��ά������������' + @SapProdLine + N'ӳ���ϵ�еĵ��������ߡ�'
		insert into LOG_GenVanProdOrder(AUFNR, ZLINE, ProdLine, BatchNo, Msg) values (@SapOrderNo, @SapProdLine, @ChassisProdLine, @BatchNo, @ErrorMsg)
	end
	
	if not exists(select top 1 1 from SCM_FlowMstr where Code = @ChassisProdLine)
	begin
		set @ErrorMsg = N'SAP��������' + @SapOrderNo + N' Van��' + @SapVAN + N'û���ҵ�����������' + @ChassisProdLine + N'��'
		insert into LOG_GenVanProdOrder(AUFNR, ZLINE, ProdLine, BatchNo, Msg) values (@SapOrderNo, @SapProdLine, @ChassisProdLine, @BatchNo, @ErrorMsg)
	end
	
	--��ȡ��������Ϣ
	select @ChassisProdLineRegion = PartyFrom, @ChassisLocFrom = LocFrom, @ChassisLocTo = LocTo, @ChassisRouting = Routing, 
	@IsChassisProdLineActive = IsActive, @ChassisProdLineType = ProdLineType, @ChassisTaktTime = TaktTime, @ChassisVirtualOpRef = VirtualOpRef
	from SCM_FlowMstr where Code = @ChassisProdLine
	
	if @IsChassisProdLineActive = 0
	begin
		set @ErrorMsg = N'SAP��������' + @SapOrderNo + N' Van��' + @SapVAN + N'����������' + @ChassisProdLine + N'û����Ч��'
		insert into LOG_GenVanProdOrder(AUFNR, ZLINE, ProdLine, BatchNo, Msg) values (@SapOrderNo, @SapProdLine, @ChassisProdLine, @BatchNo, @ErrorMsg)
	end
	
	if @ChassisTaktTime is null
	begin
		set @ErrorMsg = N'SAP��������' + @SapOrderNo + N' Van��' + @SapVAN + N'����������' + @ChassisProdLine + N'û�����ý���ʱ�䡣'
		insert into LOG_GenVanProdOrder(AUFNR, ZLINE, ProdLine, BatchNo, Msg) values (@SapOrderNo, @SapProdLine, @ChassisProdLine, @BatchNo, @ErrorMsg)
	end
	else if @ChassisTaktTime <= 0
	begin
		set @ErrorMsg = N'SAP��������' + @SapOrderNo + N' Van��' + @SapVAN + N'����������' + @ChassisProdLine + N'�Ľ���ʱ�䲻��С�ڵ���0��'
		insert into LOG_GenVanProdOrder(AUFNR, ZLINE, ProdLine, BatchNo, Msg) values (@SapOrderNo, @SapProdLine, @ChassisProdLine, @BatchNo, @ErrorMsg)
	end
	
	if ISNULL(@ChassisRouting, '') = ''
	begin
		set @ErrorMsg = N'SAP��������' + @SapOrderNo + N' Van��' + @SapVAN + N'û�����õ���������' + @ChassisProdLine + N'�Ĺ������̡�'
		insert into LOG_GenVanProdOrder(AUFNR, ZLINE, ProdLine, BatchNo, Msg) values (@SapOrderNo, @SapProdLine, @ChassisProdLine, @BatchNo, @ErrorMsg)
	end
	
	if ISNULL(@ChassisVirtualOpRef, '') = ''
	begin
		set @ErrorMsg = N'SAP��������' + @SapOrderNo + N' Van��' + @SapVAN + N'û�����õ���������' + @ChassisProdLine + N'�����⹤λ��'
		insert into LOG_GenVanProdOrder(AUFNR, ZLINE, ProdLine, BatchNo, Msg) values (@SapOrderNo, @SapProdLine, @ChassisProdLine, @BatchNo, @ErrorMsg)
	end

	if not exists(select top 1 1 from PRD_ProdLineWorkCenter where Flow = @ChassisProdLine)
	begin
		set @ErrorMsg = N'SAP��������' + @SapOrderNo + N' Van��' + @SapVAN + N'û���ҵ�����������' + @ChassisProdLine + N'�Ĺ������ġ�'
		insert into LOG_GenVanProdOrder(AUFNR, ZLINE, ProdLine, BatchNo, Msg) values (@SapOrderNo, @SapProdLine, @ChassisProdLine, @BatchNo, @ErrorMsg)
	end
	-----------------------------����������У��-----------------------------
	
	
	
	
	-----------------------------����װ����У��-----------------------------
	if ISNULL(@AssemblyProdLine, '') = ''
	begin
		set @ErrorMsg = N'SAP��������' + @SapOrderNo + N' Van��' + @SapVAN + N'û��ά������������' + @SapProdLine + N'ӳ���ϵ�е���װ�����ߡ�'
		insert into LOG_GenVanProdOrder(AUFNR, ZLINE, ProdLine, BatchNo, Msg) values (@SapOrderNo, @SapProdLine, @AssemblyProdLine, @BatchNo, @ErrorMsg)
	end
	
	if not exists(select top 1 1 from SCM_FlowMstr where Code = @AssemblyProdLine)
	begin
		set @ErrorMsg = N'SAP��������' + @SapOrderNo + N' Van��' + @SapVAN + N'û���ҵ���װ������' + @AssemblyProdLine + N'��'
		insert into LOG_GenVanProdOrder(AUFNR, ZLINE, ProdLine, BatchNo, Msg) values (@SapOrderNo, @SapProdLine, @AssemblyProdLine, @BatchNo, @ErrorMsg)
	end
	
	--��ȡ��������Ϣ
	select @AssemblyProdLineRegion = PartyFrom, @AssemblyLocFrom = LocFrom, @AssemblyLocTo = LocTo, @AssemblyRouting = Routing, 
	@IsAssemblyProdLineActive = IsActive, @AssemblyProdLineType = ProdLineType, @AssemblyTaktTime = TaktTime, @AssemblyVirtualOpRef = VirtualOpRef
	from SCM_FlowMstr where Code = @AssemblyProdLine
	
	if @IsAssemblyProdLineActive = 0
	begin
		set @ErrorMsg = N'SAP��������' + @SapOrderNo + N' Van��' + @SapVAN + N'��װ������' + @AssemblyProdLine + N'û����Ч��'
		insert into LOG_GenVanProdOrder(AUFNR, ZLINE, ProdLine, BatchNo, Msg) values (@SapOrderNo, @SapProdLine, @AssemblyProdLine, @BatchNo, @ErrorMsg)
	end
	
	if @AssemblyTaktTime is null
	begin
		set @ErrorMsg = N'SAP��������' + @SapOrderNo + N' Van��' + @SapVAN + N'��װ������' + @AssemblyProdLine + N'û�����ý���ʱ�䡣'
		insert into LOG_GenVanProdOrder(AUFNR, ZLINE, ProdLine, BatchNo, Msg) values (@SapOrderNo, @SapProdLine, @AssemblyProdLine, @BatchNo, @ErrorMsg)
	end
	else if @AssemblyTaktTime <= 0
	begin
		set @ErrorMsg = N'SAP��������' + @SapOrderNo + N' Van��' + @SapVAN + N'��װ������' + @AssemblyProdLine + N'�Ľ���ʱ�䲻��С�ڵ���0��'
		insert into LOG_GenVanProdOrder(AUFNR, ZLINE, ProdLine, BatchNo, Msg) values (@SapOrderNo, @SapProdLine, @AssemblyProdLine, @BatchNo, @ErrorMsg)
	end
	
	if ISNULL(@AssemblyRouting, '') = ''
	begin
		set @ErrorMsg = N'SAP��������' + @SapOrderNo + N' Van��' + @SapVAN + N'û��������װ������' + @AssemblyProdLine + N'�Ĺ������̡�'
		insert into LOG_GenVanProdOrder(AUFNR, ZLINE, ProdLine, BatchNo, Msg) values (@SapOrderNo, @SapProdLine, @AssemblyProdLine, @BatchNo, @ErrorMsg)
	end
	
	if ISNULL(@AssemblyVirtualOpRef, '') = ''
	begin
		set @ErrorMsg = N'SAP��������' + @SapOrderNo + N' Van��' + @SapVAN + N'û��������װ������' + @AssemblyProdLine + N'�����⹤λ��'
		insert into LOG_GenVanProdOrder(AUFNR, ZLINE, ProdLine, BatchNo, Msg) values (@SapOrderNo, @SapProdLine, @AssemblyProdLine, @BatchNo, @ErrorMsg)
	end

	if not exists(select top 1 1 from PRD_ProdLineWorkCenter where Flow = @AssemblyProdLine)
	begin
		set @ErrorMsg = N'SAP��������' + @SapOrderNo + N' Van��' + @SapVAN + N'û���ҵ���װ������' + @AssemblyProdLine + N'�Ĺ������ġ�'
		insert into LOG_GenVanProdOrder(AUFNR, ZLINE, ProdLine, BatchNo, Msg) values (@SapOrderNo, @SapProdLine, @AssemblyProdLine, @BatchNo, @ErrorMsg)
	end
	-----------------------------����װ����У��-----------------------------
	
	
	
	
	-----------------------------����װ����У��-----------------------------
	if ISNULL(@SpecialProdLine, '') = ''
	begin
		set @ErrorMsg = N'SAP��������' + @SapOrderNo + N' Van��' + @SapVAN + N'û��ά������������' + @SapProdLine + N'ӳ���ϵ�е���װ�����ߡ�'
		insert into LOG_GenVanProdOrder(AUFNR, ZLINE, ProdLine, BatchNo, Msg) values (@SapOrderNo, @SapProdLine, @SpecialProdLine, @BatchNo, @ErrorMsg)
	end
	
	if not exists(select top 1 1 from SCM_FlowMstr where Code = @SpecialProdLine)
	begin
		set @ErrorMsg = N'SAP��������' + @SapOrderNo + N' Van��' + @SapVAN + N'û���ҵ���װ������' + @SpecialProdLine + N'��'
		insert into LOG_GenVanProdOrder(AUFNR, ZLINE, ProdLine, BatchNo, Msg) values (@SapOrderNo, @SapProdLine, @SpecialProdLine, @BatchNo, @ErrorMsg)
	end
	
	--��ȡ��������Ϣ
	select @SpecialProdLineRegion = PartyFrom, @SpecialLocFrom = LocFrom, @SpecialLocTo = LocTo, @SpecialRouting = Routing, 
	@IsSpecialProdLineActive = IsActive, @SpecialProdLineType = ProdLineType, @SpecialTaktTime = TaktTime, @SpecialVirtualOpRef = VirtualOpRef
	from SCM_FlowMstr where Code = @SpecialProdLine
	
	if @IsSpecialProdLineActive = 0
	begin
		set @ErrorMsg = N'SAP��������' + @SapOrderNo + N' Van��' + @SapVAN + N'��װ������' + @SpecialProdLine + N'û����Ч��'
		insert into LOG_GenVanProdOrder(AUFNR, ZLINE, ProdLine, BatchNo, Msg) values (@SapOrderNo, @SapProdLine, @SpecialProdLine, @BatchNo, @ErrorMsg)
	end
	
	if @SpecialTaktTime is null
	begin
		set @ErrorMsg = N'SAP��������' + @SapOrderNo + N' Van��' + @SapVAN + N'��װ������' + @SpecialProdLine + N'û�����ý���ʱ�䡣'
		insert into LOG_GenVanProdOrder(AUFNR, ZLINE, ProdLine, BatchNo, Msg) values (@SapOrderNo, @SapProdLine, @SpecialProdLine, @BatchNo, @ErrorMsg)
	end
	else if @SpecialTaktTime <= 0
	begin
		set @ErrorMsg = N'SAP��������' + @SapOrderNo + N' Van��' + @SapVAN + N'��װ������' + @SpecialProdLine + N'�Ľ���ʱ�䲻��С�ڵ���0��'
		insert into LOG_GenVanProdOrder(AUFNR, ZLINE, ProdLine, BatchNo, Msg) values (@SapOrderNo, @SapProdLine, @SpecialProdLine, @BatchNo, @ErrorMsg)
	end
	
	if ISNULL(@SpecialRouting, '') = ''
	begin
		set @ErrorMsg = N'SAP��������' + @SapOrderNo + N' Van��' + @SapVAN + N'û��������װ������' + @SpecialProdLine + N'�Ĺ������̡�'
		insert into LOG_GenVanProdOrder(AUFNR, ZLINE, ProdLine, BatchNo, Msg) values (@SapOrderNo, @SapProdLine, @SpecialProdLine, @BatchNo, @ErrorMsg)
	end
	
	if ISNULL(@SpecialVirtualOpRef, '') = ''
	begin
		set @ErrorMsg = N'SAP��������' + @SapOrderNo + N' Van��' + @SapVAN + N'û��������װ������' + @SpecialProdLine + N'�����⹤λ��'
		insert into LOG_GenVanProdOrder(AUFNR, ZLINE, ProdLine, BatchNo, Msg) values (@SapOrderNo, @SapProdLine, @SpecialProdLine, @BatchNo, @ErrorMsg)
	end

	if not exists(select top 1 1 from PRD_ProdLineWorkCenter where Flow = @SpecialProdLine)
	begin
		set @ErrorMsg = N'SAP��������' + @SapOrderNo + N' Van��' + @SapVAN + N'û���ҵ���װ������' + @SpecialProdLine + N'�Ĺ������ġ�'
		insert into LOG_GenVanProdOrder(AUFNR, ZLINE, ProdLine, BatchNo, Msg) values (@SapOrderNo, @SapProdLine, @SpecialProdLine, @BatchNo, @ErrorMsg)
	end
	-----------------------------����װ����У��-----------------------------
	
	
	
	
	-----------------------------���������У��-----------------------------
	if ISNULL(@CheckProdLine, '') = ''
	begin
		set @ErrorMsg = N'SAP��������' + @SapOrderNo + N' Van��' + @SapVAN + N'û��ά������������' + @SapProdLine + N'ӳ���ϵ�еļ�������ߡ�'
		insert into LOG_GenVanProdOrder(AUFNR, ZLINE, ProdLine, BatchNo, Msg) values (@SapOrderNo, @SapProdLine, @CheckProdLine, @BatchNo, @ErrorMsg)
	end
	
	if not exists(select top 1 1 from SCM_FlowMstr where Code = @CheckProdLine)
	begin
		set @ErrorMsg = N'SAP��������' + @SapOrderNo + N' Van��' + @SapVAN + N'û���ҵ����������' + @CheckProdLine + N'��'
		insert into LOG_GenVanProdOrder(AUFNR, ZLINE, ProdLine, BatchNo, Msg) values (@SapOrderNo, @SapProdLine, @CheckProdLine, @BatchNo, @ErrorMsg)
	end
	
	--��ȡ��������Ϣ
	select @CheckProdLineRegion = PartyFrom, @CheckLocFrom = LocFrom, @CheckLocTo = LocTo, @CheckRouting = Routing, 
	@IsCheckProdLineActive = IsActive, @CheckProdLineType = ProdLineType, @CheckTaktTime = TaktTime, @CheckVirtualOpRef = VirtualOpRef
	from SCM_FlowMstr where Code = @CheckProdLine
	
	if @IsCheckProdLineActive = 0
	begin
		set @ErrorMsg = N'SAP��������' + @SapOrderNo + N' Van��' + @SapVAN + N'���������' + @CheckProdLine + N'û����Ч��'
		insert into LOG_GenVanProdOrder(AUFNR, ZLINE, ProdLine, BatchNo, Msg) values (@SapOrderNo, @SapProdLine, @CheckProdLine, @BatchNo, @ErrorMsg)
	end
	
	if @CheckTaktTime is null
	begin
		set @ErrorMsg = N'SAP��������' + @SapOrderNo + N' Van��' + @SapVAN + N'���������' + @CheckProdLine + N'û�����ý���ʱ�䡣'
		insert into LOG_GenVanProdOrder(AUFNR, ZLINE, ProdLine, BatchNo, Msg) values (@SapOrderNo, @SapProdLine, @CheckProdLine, @BatchNo, @ErrorMsg)
	end
	else if @CheckTaktTime <= 0
	begin
		set @ErrorMsg = N'SAP��������' + @SapOrderNo + N' Van��' + @SapVAN + N'���������' + @CheckProdLine + N'�Ľ���ʱ�䲻��С�ڵ���0��'
		insert into LOG_GenVanProdOrder(AUFNR, ZLINE, ProdLine, BatchNo, Msg) values (@SapOrderNo, @SapProdLine, @CheckProdLine, @BatchNo, @ErrorMsg)
	end
	
	if ISNULL(@CheckRouting, '') = ''
	begin
		set @ErrorMsg = N'SAP��������' + @SapOrderNo + N' Van��' + @SapVAN + N'û�����ü��������' + @CheckProdLine + N'�Ĺ������̡�'
		insert into LOG_GenVanProdOrder(AUFNR, ZLINE, ProdLine, BatchNo, Msg) values (@SapOrderNo, @SapProdLine, @CheckProdLine, @BatchNo, @ErrorMsg)
	end
	
	if ISNULL(@CheckVirtualOpRef, '') = ''
	begin
		set @ErrorMsg = N'SAP��������' + @SapOrderNo + N' Van��' + @SapVAN + N'û�����ü��������' + @CheckProdLine + N'�����⹤λ��'
		insert into LOG_GenVanProdOrder(AUFNR, ZLINE, ProdLine, BatchNo, Msg) values (@SapOrderNo, @SapProdLine, @CheckProdLine, @BatchNo, @ErrorMsg)
	end

	if not exists(select top 1 1 from PRD_ProdLineWorkCenter where Flow = @CheckProdLine)
	begin
		set @ErrorMsg = N'SAP��������' + @SapOrderNo + N' Van��' + @SapVAN + N'û���ҵ����������' + @CheckProdLine + N'�Ĺ������ġ�'
		insert into LOG_GenVanProdOrder(AUFNR, ZLINE, ProdLine, BatchNo, Msg) values (@SapOrderNo, @SapProdLine, @CheckProdLine, @BatchNo, @ErrorMsg)
	end
	-----------------------------���������У��-----------------------------
	
	
	
	
	-----------------------------��Bom��Workcenterƥ��У��-----------------------------
	insert into #tempWC (VanProdLine, VanRouting, WorkCenter)
	select VanProdLine, VanRouting, WorkCenter
	from (
		select plm.CabProdLine as VanProdLine, @CabRouting as VanRouting, cabWC.WorkCenter 
		from CUST_ProductLineMap as plm 
		inner join PRD_ProdLineWorkCenter as cabWC on plm.CabProdLine = cabWC.Flow
		where SapProdLine = @SapProdLine
		union all
		select plm.ChassisProdLine as VanProdLine, @ChassisRouting as VanRouting, chaWC.WorkCenter 
		from CUST_ProductLineMap as plm 
		inner join PRD_ProdLineWorkCenter as chaWC on plm.ChassisProdLine = chaWC.Flow
		where SapProdLine = @SapProdLine
		union all
		select plm.AssemblyProdLine as VanProdLine, @AssemblyRouting as VanRouting, assWC.WorkCenter 
		from CUST_ProductLineMap as plm 
		inner join PRD_ProdLineWorkCenter as assWC on plm.AssemblyProdLine = assWC.Flow
		where SapProdLine = @SapProdLine
		union all
		select plm.SpecialProdLine as VanProdLine, @SpecialRouting as VanRouting, apeWC.WorkCenter 
		from CUST_ProductLineMap as plm 
		inner join PRD_ProdLineWorkCenter as apeWC on plm.SpecialProdLine = apeWC.Flow
		where SapProdLine = @SapProdLine
		union all
		select plm.CheckProdLine as VanProdLine, @CheckRouting as VanRouting, apeWC.WorkCenter 
		from CUST_ProductLineMap as plm 
		inner join PRD_ProdLineWorkCenter as apeWC on plm.CheckProdLine = apeWC.Flow
		where SapProdLine = @SapProdLine
	) as a
	
	--���������ڶ��������������д���У��
	insert into LOG_GenVanProdOrder(AUFNR, ZLINE, BatchNo, Msg) 
	select distinct @SapOrderNo, @SapProdLine, @BatchNo, N'����������' + @SapProdLine + N' SAP��������' + @SapOrderNo + N' Van��' + @SapVAN + N'��������' + WorkCenter + N'�ڶ��������������д��ڡ�' 
	from #tempWC group by WorkCenter having COUNT(distinct VanProdLine) > 1
	
	--��������û����������������ά��
	insert into LOG_GenVanProdOrder(AUFNR, ZLINE, BatchNo, Msg) 
	select @SapOrderNo, @SapProdLine, @BatchNo, N'����������' + @SapProdLine + N' SAP��������' + @SapOrderNo + N' Van��' + @SapVAN + N'��������' + routing.ARBPL + N'û����������������ά����'
	from SAP_ProdBomDet as bom
	inner join SAP_ProdRoutingDet as routing on bom.BatchNo = routing.BatchNo 
	and bom.AUFPL = routing.AUFPL and bom.PLNFL = routing.PLNFL and bom.VORNR = routing.VORNR  --�ù���·�߱�š�˳��Ͳ��������
	left join #tempWC as wc on routing.ARBPL = wc.WorkCenter
	where bom.BatchNo = @BatchNo and wc.WorkCenter is null
	group by routing.ARBPL
	-----------------------------��Bom��Workcenterƥ��У��-----------------------------
	
	
	
	
	-----------------------------��RoutingDet�ͱ�������ƥ��У��-----------------------------
	insert into LOG_GenVanProdOrder(AUFNR, ZLINE, BatchNo, Msg) 
	select @SapOrderNo, @SapProdLine, @BatchNo, N'����������' + @SapProdLine + N' SAP��������' + @SapOrderNo + N' Van��' + @SapVAN +  + N'��������Ĺ�������' + sapRouting.ARBPL + N'û������������������ά����'
	from SAP_ProdRoutingDet as sapRouting 
	left join PRD_RoutingDet as routingDet on sapRouting.ARBPL = routingDet.WorkCenter 
	and routingDet.Routing in ((select wc.VanRouting from SAP_ProdBomDet as bom
	inner join SAP_ProdRoutingDet as routing on bom.BatchNo = routing.BatchNo 
	and bom.AUFPL = routing.AUFPL and bom.PLNFL = routing.PLNFL and bom.VORNR = routing.VORNR  --�ù���·�߱�š�˳��Ͳ��������
	inner join #tempWC as wc on routing.ARBPL = wc.WorkCenter
	where bom.BatchNo = @BatchNo
	group by wc.VanRouting))
	where sapRouting.BatchNo = @BatchNo and sapRouting.RUEK in ('1', '2') and routingDet.Id is null
	
	drop table #tempWC
	-----------------------------��RoutingDet�ͱ�������ƥ��У��-----------------------------
	
	
	
	
	-----------------------------������������Bom�͹�������ƥ��У��-----------------------------
	insert into LOG_GenVanProdOrder(AUFNR, ZLINE, BatchNo, Msg) 
	select @SapOrderNo, @SapProdLine, @BatchNo, N'����������Bom(AUFPL:' + CONVERT(varchar, bom.AUFPL) + N', PLNFL:' + bom.PLNFL + N', VORNR:' + bom.VORNR + N')û���ҵ���Ӧ��SAP����' 
	from SAP_ProdBomDet as bom
	left join SAP_ProdRoutingDet as routing on bom.BatchNo = routing.BatchNo 
	and bom.AUFPL = routing.AUFPL and bom.PLNFL = routing.PLNFL and bom.VORNR = routing.VORNR
	where bom.BatchNo = @BatchNo and routing.BatchNo is null
	-----------------------------������������Bom�͹�������ƥ��У��-----------------------------
	
	
	
	
	-----------------------------������������У��-----------------------------
	--û��ά������������ӳ���ϵ�ı������ƿ�·��
	if ISNULL(@TransFlow, '') = ''
	begin
		set @ErrorMsg = N'SAP��������' + @SapOrderNo + N' Van��' + @SapVAN + N'û��ά������������' + @TransFlow + N'ӳ���ϵ�еı������ƿ�·�ߡ�'
		insert into LOG_GenVanProdOrder(AUFNR, ZLINE, BatchNo, Msg) values (@SapOrderNo, @SapProdLine, @BatchNo, @ErrorMsg) 
	end
	
	--û���ҵ��������ƿ�·�ߵĹ�������
	if not exists(select top 1 1 from PRD_ProdLineWorkCenter where Flow = @TransFlow)
	begin
		set @ErrorMsg = N'SAP��������' + @SapOrderNo + N' Van��' + @SapVAN + N'û���ҵ��������ƿ�·��' + @TransFlow + N'�Ĺ������ġ�'
		insert into LOG_GenVanProdOrder(AUFNR, ZLINE, BatchNo, Msg) values (@SapOrderNo, @SapProdLine, @BatchNo, @ErrorMsg) 
	end
	-----------------------------������������У��-----------------------------
	
	
	
	
	-----------------------------����������У��-----------------------------
	--û��ά������������ӳ���ϵ�İ����ƿ�·��
	if ISNULL(@SaddleFlow, '') = ''
	begin
		set @ErrorMsg = N'SAP��������' + @SapOrderNo + N' Van��' + @SapVAN + N'û��ά������������' + @SaddleFlow + N'ӳ���ϵ�еİ����ƿ�·�ߡ�'
		insert into LOG_GenVanProdOrder(AUFNR, ZLINE, BatchNo, Msg) values (@SapOrderNo, @SapProdLine, @BatchNo, @ErrorMsg) 
	end
	
	--û���ҵ������ƿ�·�ߵĹ�������
	if not exists(select top 1 1 from PRD_ProdLineWorkCenter where Flow = @SaddleFlow)
	begin
		set @ErrorMsg = N'SAP��������' + @SapOrderNo + N' Van��' + @SapVAN + N'û���ҵ������ƿ�·��' + @SaddleFlow + N'�Ĺ������ġ�'
		insert into LOG_GenVanProdOrder(AUFNR, ZLINE, BatchNo, Msg) values (@SapOrderNo, @SapProdLine, @BatchNo, @ErrorMsg) 
	end
	-----------------------------����������У��-----------------------------
	
	
	select Msg from LOG_GenVanProdOrder where AUFNR = @SapOrderNo
END 
