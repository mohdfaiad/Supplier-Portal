SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF EXISTS(SELECT * FROM sys.objects WHERE type='P' AND name='USP_Busi_CreateOrUpdateVanProdOrder') 
     DROP PROCEDURE USP_Busi_CreateOrUpdateVanProdOrder
GO

CREATE PROCEDURE [dbo].[USP_Busi_CreateOrUpdateVanProdOrder]
(
	@BatchNo int,
	@VanProdLine varchar(50),
	@VanProdLineNm varchar(100),
	@VanProdLine2 varchar(50),
	@VanProdLine3 varchar(50),
	@VanProdLine4 varchar(50),
	@CreateUserId int,
	@CreateUserNm varchar(50),
	@OrderNo varchar(50) output
) --WITH ENCRYPTION
AS 
BEGIN 
	set nocount on
	declare @DateTimeNow datetime = GetDate()
	declare @ErrorMsg nvarchar(MAX)
		
	begin try
		-----------------------------����ȡSAP������-----------------------------
		declare @SapProdLine varchar(50)  --SAP�����ߴ���A/B
		declare @SapOrderNo varchar(50)   --SAP��������������װ���������ţ����ǵ��̵��������ţ�
		declare @SapVAN varchar(50)       --VAN��
		declare @SapSeq bigint			  --SAP˳���
		declare @Seq bigint				--LES˳���
		declare @SubSeq int				--LES��˳���
		declare @SapStartTime datetime    --SAP�Ų�����
		declare @SapProdItem varchar(50)  --SAP�������Ϻ�  
		declare @SapProdItemDesc varchar(50)  --SAP������������
		declare @SapProdItemUom varchar(5)	--SAP�������ϵ�λ
		declare @IsOrderExists bit = 0
		declare @OrderVersion int
		declare @DAUAT varchar(50)
		
		select @SapProdLine = ZLINE, @SapOrderNo = AUFNR, @SapVAN = CHARG, @SapStartTime = GSTRS, 
		@SapProdItem = MATNR, @SapProdItemDesc = MAKTX, @SapProdItemUom = GMEIN, @SapSeq = Convert(bigint, CY_SEQNR),
		@Seq = Convert(bigint, CY_SEQNR), @SubSeq = 1, @DAUAT = DAUAT
		from SAP_ProdOrder WITH(NOLOCK) where BatchNo = @BatchNo
		
		select @OrderNo = OrderNo, @OrderVersion = [Version] from ORD_OrderMstr_4 with(NOLOCK) where Flow = @VanProdLine and TraceCode = @SapVAN
		
		if @OrderNo is not null
		begin
			set @IsOrderExists = 1
		end
		
		declare @IsProdLineActive bit  --�������Ƿ���Ч
		declare @Routing varchar(50)  --�����߹�������
		declare @VanProdLineRegion varchar(50)  --����������
		declare @LocTo varchar(50)     --������ԭ����
		declare @LocFrom varchar(50)   --�����߳�Ʒ
		declare @ProdLineType tinyint   --����������
		declare @VirtualOpRef varchar(50)   --���⹤λ
		declare @TaktTime int           --����ʱ�䣨�룩
		declare @FlowDesc varchar(100)	--·������
		declare @OrderTemplate varchar(100)	--����ģ��
		
		--��ȡ��������Ϣ
		select @VanProdLineRegion = PartyFrom, @LocFrom = LocFrom, @LocTo = LocTo, @Routing = Routing, 
		@IsProdLineActive = IsActive, @ProdLineType = ProdLineType, @TaktTime = TaktTime, @VirtualOpRef = VirtualOpRef,@FlowDesc = Desc1,@OrderTemplate=OrderTemplate
		from SCM_FlowMstr WITH(NOLOCK) where Code = @VanProdLine
		-----------------------------����ȡSAP������-----------------------------
		
		
		
		
		-----------------------------�����ɹ�����ʱ��-----------------------------
		Create table #tempRoutingDet
		(
			RowId int Identity(1, 1) Primary Key,
			LoopCount int,
			AssProdLine varchar(50),
			Routing varchar(50),
			JointOp int,               --��װ����
			Op int,
			OpRef varchar(50),
			Location varchar(50),
			WorkCenter varchar(50)
		)
		
		--�������߹���
		declare @LoopCount int = 1
		insert into #tempRoutingDet(LoopCount, AssProdLine, Routing, JointOp, Op, OpRef, Location, WorkCenter)
		select @LoopCount, @VanProdLine, Routing, Op, Op, OpRef, Location, WorkCenter 
		from PRD_RoutingDet WITH(NOLOCK) where Routing = @Routing
		
		--�����װ�߹���
		while exists(select top 1 1 from #tempRoutingDet as tDet WITH(NOLOCK)
					inner join SCM_FlowBinding as bind WITH(NOLOCK) on tDet.AssProdLine = bind.MstrFlow
					inner join SCM_FlowMstr as subPL WITH(NOLOCK) on bind.BindFlow = subPL.Code
					where tDet.LoopCount = @LoopCount)
		begin
			set @LoopCount = @LoopCount + 1
			
			insert into #tempRoutingDet(LoopCount, AssProdLine, Routing, JointOp, Op, OpRef, Location, WorkCenter)
			select @LoopCount, subPL.Code, subPL.Routing, bind.JointOp, rDet.Op, rDet.OpRef, rDet.Location, rDet.WorkCenter 
			from #tempRoutingDet as tDet WITH(NOLOCK)
			inner join SCM_FlowBinding as bind WITH(NOLOCK) on tDet.AssProdLine = bind.MstrFlow
			inner join SCM_FlowMstr as subPL WITH(NOLOCK) on bind.BindFlow = subPL.Code
			inner join PRD_RoutingDet as rDet WITH(NOLOCK) on rDet.Routing = subPL.Routing
			where tDet.LoopCount = @LoopCount - 1
			group by subPL.Code, subPL.Routing, bind.JointOp, rDet.Op, rDet.OpRef, rDet.Location, rDet.WorkCenter
		end
		-----------------------------�����ɹ�����ʱ��-----------------------------
		
		
		
		
		-----------------------------������������Bom��ʱ��-----------------------------
		Create table #tempVanProdLine
		(
			RowId int Identity(1, 1) Primary Key,
			VanProdLine varchar(50)
		)
		insert into #tempVanProdLine(VanProdLine) values(@VanProdLine)
		if (ISNULL(@VanProdLine2, '') <> '')
		begin
			insert into #tempVanProdLine(VanProdLine) values(@VanProdLine2)
		end
		if (ISNULL(@VanProdLine3, '') <> '')
		begin
			insert into #tempVanProdLine(VanProdLine) values(@VanProdLine3)
		end
		if (ISNULL(@VanProdLine4, '') <> '')
		begin
			insert into #tempVanProdLine(VanProdLine) values(@VanProdLine4)
		end
		
		Create table #tempOrderBom
		(
			RowId int identity(1, 1) Primary Key,
			SapBomId bigint,
			Item varchar(50),
			ItemDesc varchar(100),
			RefItemCode varchar(50),
			UOM varchar(5),
			ManufactureParty varchar(50),
			AssProdLine varchar(50),
			JointOp int,
			Op int,
			OpRef varchar(50),
			OrderQty decimal(18, 8),
			Location varchar(50),
			ReserveNo varchar(50),
			ReserveLine varchar(50),
			ZOPWZ varchar(50),
			ZOPID varchar(50),
			ZOPDS varchar(50),
			AUFNR varchar(50),
			ICHARG varchar(50),
			BWART varchar(50),
			IsScanHu bit,
			WorkCenter varchar(50),
			DISPO varchar(50),
			BESKZ varchar(100),
			SOBSL varchar(100),
			PLNFL varchar(50),
			VORNR varchar(50),
			AUFPL varchar(50)
		)
		
		--����Bom
		insert into #tempOrderBom(SapBomId, Item, ItemDesc, RefItemCode, UOM, ManufactureParty,
		AssProdLine, JointOp, Op, OpRef, OrderQty, Location,
		ReserveNo, ReserveLine, ZOPWZ, ZOPID, ZOPDS, AUFNR, ICHARG, BWART,
		IsScanHu, WorkCenter, DISPO, BESKZ, SOBSL, PLNFL, VORNR, AUFPL)
		select bom.Id as SapBomId, bom.MATERIAL as Item, bom.MAKTX as ItemDesc, bom.BISMT as RefItemCode, bom.MEINS as UOM, case when bom.LIFNR <> '' then bom.LIFNR else null end as ManufactureParty,
		null as ProdLine, null as JointOp, null as Op, case when ISNULL(GW, '') = '' then @VirtualOpRef when Len(GW) > 5 then SUBSTRING(GW, 1, 5) else GW end as OpRef, case when BWART = '531' then -MDMNG else MDMNG end as OrderQty, null as Location,
		bom.RSNUM as ReserveNo, bom.RSPOS as ReserveLine, null as ZOPWZ, bom.ZOPID, bom.ZOPDS, bom.AUFNR, bom.ICHARG, bom.BWART,
		CASE WHEN trace.Item is not null THEN 1 ELSE 0 END as IsScanHu, pwc.WorkCenter, bom.DISPO, bom.BESKZ, bom.SOBSL, bom.PLNFL, bom.VORNR, bom.AUFPL
		from SAP_ProdBomDet as bom WITH(NOLOCK)
		inner join SAP_ProdRoutingDet as routing WITH(NOLOCK) on bom.BatchNo = routing.BatchNo 
		and bom.AUFPL = routing.AUFPL and bom.PLNFL = routing.PLNFL and bom.VORNR = routing.VORNR  --�ù���·�߱�š�˳��Ͳ��������
		inner join PRD_ProdLineWorkCenter as pwc WITH(NOLOCK) on routing.ARBPL = pwc.WorkCenter
		left join CUST_ItemTrace as trace WITH(NOLOCK) on bom.MATERIAL = trace.Item
		where bom.BatchNo = @BatchNo and bom.MDMNG > 0 and bom.RGEKZ = 'X' and pwc.Flow in (select VanProdLine from #tempVanProdLine)
		
		--if exists(select 1 from CUST_ProductLineMap where SapProdLine = @SapProdLine and CabProdLine = @VanProdLine and [Type] = 1)
		--begin  --��ʻ��
		--	--�����ʻ��û�м����ʻ���������У��Ѽ�ʻ�Ҽ���
		--	insert into #tempOrderBom(SapBomId, Item, ItemDesc, RefItemCode, UOM, ManufactureParty,
		--	AssProdLine, JointOp, Op, OpRef, OrderQty, Location,
		--	ReserveNo, ReserveLine, ZOPWZ, ZOPID, ZOPDS, AUFNR, ICHARG, BWART,
		--	IsScanHu, WorkCenter, DISPO, BESKZ, SOBSL, PLNFL, VORNR, AUFPL)
		--	select bom.Id as SapBomId, bom.MATERIAL as Item, bom.MAKTX as ItemDesc, bom.BISMT as RefItemCode, bom.MEINS as UOM, case when bom.LIFNR <> '' then bom.LIFNR else null end as ManufactureParty,
		--	null as ProdLine, null as JointOp, null as Op, case when ISNULL(GW, '') = '' then @VirtualOpRef when Len(GW) > 5 then SUBSTRING(GW, 1, 5) else GW end as OpRef, case when tbom.BWART = '531' then -MDMNG else MDMNG end as OrderQty, null as Location,
		--	bom.RSNUM as ReserveNo, bom.RSPOS as ReserveLine, null as ZOPWZ, bom.ZOPID, bom.ZOPDS, bom.AUFNR, bom.ICHARG, bom.BWART,
		--	CASE WHEN trace.Item is not null THEN 1 ELSE 0 END as IsScanHu, routing.ARBPL as WorkCenter, bom.DISPO, bom.BESKZ, bom.SOBSL, bom.PLNFL, bom.VORNR, bom.AUFPL 
		--	from SAP_ProdBomDet as bom
		--	inner join SAP_ProdRoutingDet as routing on bom.BatchNo = routing.BatchNo and bom.AUFPL = routing.AUFPL and bom.PLNFL=routing.PLNFL and bom .VORNR=routing.VORNR
		--	and bom.AUFPL = routing.AUFPL and bom.PLNFL = routing.PLNFL and bom.VORNR = routing.VORNR  --�ù���·�߱�š�˳��Ͳ��������
		--	left join CUST_ItemTrace as trace on bom.MATERIAL = trace.Item
		--	left join #tempOrderBom as tbom on bom.Id = tbom.SapBomId
		--	where bom.BatchNo = @BatchNo and bom.MDMNG > 0
		--	and ((bom.DISPO = 'IAF' and bom.BESKZ = 'E' and ISNULL(bom.SOBSL, '') = '') or (bom.DISPO = 'L13'))
		--	and tbom.SapBomId is null
		--end
		--else
		--begin  --�Ǽ�ʻ��
		--	--ɾ����ʻ�ҵ�Bom
		--	delete tBom 
		--	from #tempOrderBom as tBom
		--	inner join SAP_ProdBomDet as bom on tBom.SapBomId = bom.Id
		--	where bom.BatchNo = @BatchNo and bom.MDMNG > 0
		--	and ((bom.DISPO = 'IAF' and bom.BESKZ = 'E' and ISNULL(bom.SOBSL, '') = '') or (bom.DISPO = 'L13'))
		--end
		
		--���Ҹ���Bom����¼������־
		insert into LOG_GenVanProdOrder(AUFNR, ZLINE, BatchNo, Msg)
		select @SapOrderNo, @SapProdLine, @BatchNo, N'�滻���ĸ���Bom(MATERIAL:' + Item + N', MDMNG:' + CONVERT(varchar, OrderQty) + N', AUFPL:' + AUFPL + N' PLNFL:' + PLNFL + N', VORNR:' + VORNR + N', RSNUM:' + ReserveNo + N', RSPOS:' + ReserveLine + N')û���ҵ���Ӧ����Bom��' 
		from #tempOrderBom where OrderQty < 0
		
		--ɾ������Bom
		delete from #tempOrderBom where OrderQty < 0
		
		if not exists(select top 1 1 from #tempOrderBom)
		begin
			if @IsOrderExists = 0
			begin
				if @ProdLineType = 2
				begin
					set @ErrorMsg = N'����������Bom����Ϊ�ա�'
					insert into Log_GenVanProdOrder(AUFNR, ZLINE, ProdLine, BatchNo, Msg) values (@SapOrderNo, @SapProdLine, @VanProdLine, @BatchNo, @ErrorMsg)
					RAISERROR(@ErrorMsg, 16, 1)
				end
				else
				begin
					return
				end
			end
			else
			begin
				delete from CUST_CabOut where OrderNo = @OrderNo
				delete from ORD_OrderItemTraceResult where OrderNo = @OrderNo
				delete from ORD_OrderItemTrace where OrderNo = @OrderNo
				delete from ORD_OrderOp where OrderNo = @OrderNo
				delete from ORD_OrderBomDet where OrderNo = @OrderNo
				delete from ORD_OrderDet_4 where OrderNo = @OrderNo
				delete from ORD_OrderSeq where OrderNo = @OrderNo
				delete from ORD_OrderMstr_4 where OrderNo = @OrderNo
			end
		end
		
		--���¹���
		declare @MinOp int  --��С���򣬴�������ȡ
		select @MinOp = MIN(Op) from PRD_RoutingDet WITH(NOLOCK) where Routing = @Routing
		
		--���°�װ�����ߡ����򡢹�λ���������Ŀ�λ������ȡ��װ����
		update bom set AssProdLine = IsNULL(det.AssProdLine, @VanProdLine),--��������û��ƥ��Ĺ�λȡ����������
		JointOp = IsNULL(det.JointOp, @MinOp),									--��������û��ƥ��Ĺ�λȡ���������ߵ���С����
		Op = IsNULL(det.Op, @MinOp),									--��������û��ƥ��Ĺ�λȡ���������ߵ���С����
		OpRef = ISNULL(det.OpRef, @VirtualOpRef),						--��������û��ƥ��Ĺ�λȡ���������ߵ����⹤λ
		Location = det.Location
		from #tempOrderBom as bom
		left join #tempRoutingDet as det on bom.OpRef = det.OpRef
		
		--�����������Ŀ�λ���ٴӹ�����������
		update bom set Location = wc.Location
		from #tempOrderBom as bom
		inner join MD_WorkCenter as wc on bom.WorkCenter = wc.Code 
		where bom.Location is null
		
		--�����������Ŀ�λ�����ȡ�������ϵ�ԭ���Ͽ�λ
		update #tempOrderBom set Location = @LocFrom where Location is null
		-----------------------------������������Bom��ʱ��-----------------------------
		
		
		
		-----------------------------������/����������ͷ-----------------------------
		if @IsOrderExists = 0
		begin
			exec USP_GetDocNo_ORD @VanProdLine, 0, 4, 0, 0, 0, @VanProdLineRegion, @VanProdLineRegion, @LocTo, @LocFrom, null, 0, @OrderNo output
		
			insert into ORD_OrderMstr_4 (
			OrderNo,              --��������
			Flow,                 --������
			TraceCode,            --׷���룬VAN��
			OrderStrategy,        --���ԣ�0
			ExtOrderNo,           --�ⲿ�����ţ�SAP��������
			[Type],               --���ͣ�4������
			SubType,              --�����ͣ�0����
			QualityType,          --����״̬��0��Ʒ
			StartTime,            --��ʼʱ��
			WindowTime,           --����ʱ��
			PauseSeq,             --��ͣ����0
			IsQuick,              --�Ƿ���٣�0
			[Priority],           --���ȼ���0
			[Status],             --״̬��1�ͷ�
			PartyFrom,            --�������
			PartyTo,              --�������
			LocFrom,              --ԭ���Ͽ�λ
			LocTo,                --��Ʒ��λ
			IsInspect,            --���߼��飬0
			IsAutoRelease,        --�Զ��ͷţ�0
			IsAutoStart,          --�Զ����ߣ�0
			IsAutoShip,           --�Զ�������0
			IsAutoReceive,        --�Զ��ջ���0
			IsAutoBill,           --�Զ��˵���0
			IsManualCreateDet,    --�ֹ�������ϸ��0
			IsListPrice,          --��ʾ�۸񵥣�0
			IsPrintOrder,         --��ӡ��������0
			IsOrderPrinted,       --�������Ѵ�ӡ��0
			IsPrintAsn,           --��ӡASN��0
			IsPrintRec,           --��ӡ�ջ�����0
			IsShipExceed,         --��������0
			IsRecExceed,          --�����գ�0
			IsOrderFulfillUC,     --����װ�µ���0
			IsShipFulfillUC,      --����װ������0
			IsRecFulfillUC,       --����װ�ջ���0
			IsShipScanHu,         --����ɨ�����룬0
			IsRecScanHu,          --�ջ�ɨ�����룬0
			IsCreatePL,           --�����������0
			IsPLCreate,           --������Ѵ�����0
			IsShipFifo,           --�����Ƚ��ȳ���0
			IsRecFifo,            --�ջ��Ƚ��ȳ���0
			IsShipByOrder,        --��������������0
			IsOpenOrder,          --���ڶ�����0
			IsAsnUniqueRec,       --ASNһ�����ջ���0
			RecGapTo,             --�ջ����촦��0
			OrderTemplate,        --����ģ��
			BillTerm,             --���㷽ʽ��0
			CreateHuOpt,          --��������ѡ�0
			ReCalculatePriceOpt,  --���¼���۸�ѡ�0
			CreateUser,           --�����û�
			CreateUserNm,         --�����û�����
			CreateDate,           --��������
			LastModifyUser,       --����޸��û�
			LastModifyUserNm,     --����޸��û�����
			LastModifyDate,       --����޸�����
			ReleaseUser,          --�ͷ��û�
			ReleaseUserNm,        --�ͷ��û�����
			ReleaseDate,          --�ͷ�����
			[Version],            --�汾��1
			FlowDesc,			  --����������	
			ProdLineType,         --����������
			PauseStatus,          --��ͣ״̬��0
			ShipFromContact,      --����������Ϻţ�
			ShipFromAddr,         --���������������
			ShipFromFax,          --����������ϵ�λ
			ShipFromTel			  --���SAP����������DAUAT
			)
			select 
			@OrderNo,                    --��������
			@VanProdLine,                --������
			@SapVAN,                     --׷���룬VAN��
			0,                           --���ԣ�0
			@SapOrderNo,                 --�ⲿ�����ţ�SAP��������
			4,                           --���ͣ�4������
			0,                           --�����ͣ�0����
			0,                           --����״̬��0��Ʒ
			@SapStartTime,               --��ʼʱ��
			@SapStartTime,               --����ʱ��
			0,                           --��ͣ����0
			0,                           --�Ƿ���٣�0
			0,                           --���ȼ���0
			1,                           --״̬��0������1�ͷ�
			@VanProdLineRegion,          --�������
			@VanProdLineRegion,          --�������
			@LocFrom,                    --ԭ���Ͽ�λ
			@LocTo,                      --��Ʒ��λ
			0,							 --���߼��飬0
			0,							 --�Զ��ͷţ�0
			0,							 --�Զ����ߣ�0
			0,							 --�Զ�������0
			0,							 --�Զ��ջ���0
			0,							 --�Զ��˵���0
			0,							 --�ֹ�������ϸ��0
			0,						     --��ʾ�۸񵥣�0
			0,							 --��ӡ��������0
			0,							 --�������Ѵ�ӡ��0
			0,							 --��ӡASN��0
			0,							 --��ӡ�ջ�����0
			0,							 --��������0
			0,							 --�����գ�0
			0,							 --����װ�µ���0
			0,							 --����װ������0
			0,							 --����װ�ջ���0
			0,							 --����ɨ�����룬0
			0,							 --�ջ�ɨ�����룬0
			0,							 --�����������0
			0,							 --������Ѵ�����0
			0,							 --�����Ƚ��ȳ���0
			0,							 --�ջ��Ƚ��ȳ���0
			0,							 --��������������0
			0,							 --���ڶ�����0
			0,							 --ASNһ�����ջ���0
			0,							 --�ջ����촦��0
			@OrderTemplate,              --����ģ��
			0,							 --���㷽ʽ��0
			0,							 --��������ѡ�0
			0,							 --���¼���۸�ѡ�0
			@CreateUserId,               --�����û�
			@CreateUserNm,               --�����û�����
			@DateTimeNow,                --��������
			@CreateUserId,               --����޸��û�
			@CreateUserNm,               --����޸��û�����
			@DateTimeNow,                --����޸�����
			@CreateUserId,               --�ͷ��û�
			@CreateUserNm,               --�ͷ��û�����
			@DateTimeNow,                --�ͷ�����
			1,                           --�汾��1
			@FlowDesc,					 --����������
			@ProdLineType,               --����������
			0,                           --��ͣ״̬��0
			@SapProdItem,				 --����������Ϻţ�
			@SapProdItemDesc,            --���������������
			@SapProdItemUom,             --����������ϵ�λ
			@DAUAT						 --SAP����������
		end
		-----------------------------������������ͷ-----------------------------
		
		
		
		-----------------------------������������˳��-----------------------------
		if @IsOrderExists = 0
		begin
			if exists(select top 1 1 from ORD_OrderSeq where Seq > @Seq or (Seq = @Seq and SubSeq > @SubSeq) and ProdLine = @VanProdLine)
			begin
				select @Seq = MAX(Seq) from ORD_OrderSeq where ProdLine = @VanProdLine
				select @SubSeq = MAX(SubSeq) + 1 from ORD_OrderSeq where Seq = @Seq and ProdLine = @VanProdLine
			end
			
			--���������
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
			@VanProdLine,
			@OrderNo,
			@SapVAN,
			@Seq,
			@SubSeq,
			@SapSeq,
			@CreateUserId,
			@CreateUserNm,
			@DateTimeNow,
			@CreateUserId,
			@CreateUserNm,
			@DateTimeNow,
			1
			)
		end
		-----------------------------������������˳��-----------------------------
		
		
		
		-----------------------------��������������ϸ-----------------------------
		declare @OrderDetId int
		if @IsOrderExists = 0
		begin
			exec USP_SYS_GetNextId 'ORD_OrderDet', @OrderDetId output
			
			insert into ORD_OrderDet_4 (
			Id,                         --��������ϸ��ʶ
			OrderNo,                    --��������
			OrderType,                  --���ͣ�4������
			OrderSubType,               --�����ͣ�0����
			Seq,						--�кţ�1
			ScheduleType,               --�ƻ�Э�����ͣ�0
			Item,                       --�������Ϻ�
			ItemDesc,                   --������������
			Uom,                        --��λ
			BaseUom,                    --������λ
			UC,                         --��װ��1
			MinUC,                      --��С��װ��1
			QualityType,                --����״̬��0
			ReqQty,                     --����������1
			OrderQty,                   --����������1
			ShipQty,                    --����������0
			RecQty,                     --�ջ�������0
			RejQty,                     --��Ʒ������0
			ScrapQty,                   --��Ʒ������0
			PickQty,                    --���������0
			UnitQty,                    --��λ������1
			IsInspect,                  --�Ƿ���飬0
			IsProvEst,                  --�Ƿ��ݹ��ۣ�0
			IsIncludeTax,               --�Ƿ�˰�ۣ�0
			IsScanHu,                   --�Ƿ�ɨ�����룬0
			CreateUser,                 --�����û�
			CreateUserNm,               --�����û�����
			CreateDate,                 --��������
			LastModifyUser,             --����޸��û�
			LastModifyUserNm,           --����޸��û�����
			LastModifyDate,             --����޸�����
			[Version],					--�汾��1
			IsChangeUC					--�Ƿ��޸ĵ���װ��0
			)
			select 
			@OrderDetId,                --��������ϸ��ʶ
			@OrderNo,                   --��������
			4,                          --���ͣ�4������
			0,                          --�����ͣ�0����
			1,							--�кţ�1
			0,                          --�ƻ�Э�����ͣ�0
			@SapProdItem,               --�������Ϻ�
			@SapProdItemDesc,           --������������
			@SapProdItemUom,            --��λ
			@SapProdItemUom,            --������λ
			1,                          --��װ��1
			1,                          --��С��װ��1
			0,                          --����״̬��0
			1,                          --����������1
			1,                          --����������1
			0,                          --����������0
			0,                          --�ջ�������0
			0,                          --��Ʒ������0
			0,                          --��Ʒ������0
			0,                          --���������0
			1,                          --��λ������1
			0,                          --�Ƿ���飬0
			0,                          --�Ƿ��ݹ��ۣ�0
			0,                          --�Ƿ�˰�ۣ�0
			0,                          --�Ƿ�ɨ�����룬0
			@CreateUserId,              --�����û�
			@CreateUserNm,              --�����û�����
			@DateTimeNow,               --��������
			@CreateUserId,              --����޸��û�
			@CreateUserNm,              --����޸��û�����
			@DateTimeNow,               --����޸�����
			1,							--�汾��1
			0							--�Ƿ��޸ĵ���װ��0
		end
		else
		begin
			select @OrderDetId = Id from ORD_OrderDet_4 WITH(NOLOCK) where OrderNo = @OrderNo
		end
		-----------------------------��������������ϸ-----------------------------
		
		
		
		-----------------------------������������Bom-----------------------------
		if @IsOrderExists = 0
		begin
			INSERT INTO ORD_OrderBomDet (
			OrderNo,					--��������
			OrderType,					--���ͣ�4������
			OrderSubType,				--�����ͣ�0����
			OrderDetId,					--��������ϸ��ʶ
			OrderDetSeq,				--��������ϸ˳���
			Seq,						--˳���
			Item,						--Bom�����
			ItemDesc,					--Bom�������
			RefItemCode,				--�����Ϻ�
			Uom,						--��λ
			BaseUom,					--������λ
			ManufactureParty,			--ָ����Ӧ��
			JointOp,					--��װ���򣬶��ڷ�װ��JointOp�����װ�Ĺ���
			Op,							--����
			OpRef,						--��λ
			OrderQty,					--Bom����
			BFQty,						--����ϸ�����
			BFRejQty,					--���岻�ϸ�����
			BFScrapQty,					--�����Ʒ����
			UnitQty,					--��λ����
			BomUnitQty,					--������Ʒ����
			Location,					--�����λ
			IsPrint,					--�Ƿ��ӡ
			BackFlushMethod,            --�س巽ʽ
			FeedMethod,                 --Ͷ�Ϸ�ʽ
			IsAutoFeed,                 --�Ƿ��Զ�Ͷ��
			IsScanHu,                   --�Ƿ�ؼ���
			EstConsumeTime,             --Ԥ������ʱ��
			ReserveNo,                  --Ԥ����
			ReserveLine,                --Ԥ���к�
			ZOPWZ,						--����˳���
			ZOPID,						--��λID
			ZOPDS,						--��������
			AUFNR,						--��������
			CreateUser,					--�����û�
			CreateUserNm,				--�����û�����
			CreateDate,					--��������
			LastModifyUser,				--����޸��û�
			LastModifyUserNm,			--����޸��û�����
			LastModifyDate,				--����޸�����
			[Version],					--�汾��1
			ICHARG,						--����
			BWART,						--�ƶ�����
			AssProdLine,				--�����װ��������/�����Ƿ�װ�ߣ�û�й�λ���߹�λ�����ڵ�ȡ���⹤λ
			IsCreateOrder,				--�Ƿ��Ѿ��������ϵ�
			DISPO,						--MRP������
			BESKZ,                      --�ɹ�����
			SOBSL,                      --����ɹ�����
			WorkCenter,					--��������
			PLNFL,						--����
			VORNR,						--����
			AUFPL						--����·�߱��
			)
			select
			@OrderNo,					--��������
			4,							--���ͣ�4������
			0,							--�����ͣ�0����
			@OrderDetId,				--��������ϸ��ʶ
			1,							--��������ϸ˳���
			ROW_NUMBER() over (order by Op, OpRef),--˳���
			Item,						--Bom�����
			ItemDesc,					--Bom�������
			RefItemCode,				--�����Ϻ�
			Uom,						--��λ
			Uom,						--������λ
			ManufactureParty,			--ָ����Ӧ��
			JointOp,					--��װ���򣬶��ڷ�װ��JointOp�����װ�Ĺ���
			Op,							--����
			OpRef,						--��λ
			OrderQty,					--Bom����
			0,							--����ϸ�����
			0,							--���岻�ϸ�����
			0,							--�����Ʒ����
			1,							--��λ����
			OrderQty,					--������Ʒ����
			Location,					--�����λ
			0,							--�Ƿ��ӡ
			0,							--�س巽ʽ
			0,							--Ͷ�Ϸ�ʽ
			0,							--�Ƿ��Զ�Ͷ��
			IsScanHu,                   --�Ƿ�ؼ���
			@DateTimeNow,				--Ԥ������ʱ��
			ReserveNo,                  --Ԥ����
			ReserveLine,                --Ԥ���к�
			ZOPWZ,						--����˳���
			ZOPID,						--��λID
			ZOPDS,						--��������
			AUFNR,						--��������
			@CreateUserId,              --�����û�
			@CreateUserNm,              --�����û�����
			@DateTimeNow,               --��������
			@CreateUserId,              --����޸��û�
			@CreateUserNm,              --����޸��û�����
			@DateTimeNow,               --����޸�����
			1,							--�汾��1
			ICHARG,						--����
			BWART,						--�ƶ�����
			AssProdLine,				--�����װ��������/�����Ƿ�װ��
			0,							--�Ƿ��Ѿ��������ϵ�
			DISPO,						--MRP������
			BESKZ,                      --�ɹ�����
			SOBSL,                      --����ɹ�����
			WorkCenter,					--��������
			PLNFL,						--����
			VORNR,						--����
			AUFPL						--����·�߱��
			from #tempOrderBom
		end
		else
		begin
			----�Ѿ��������JIT���Ҫ�˻�BOM��������λ�������
			--update orb set Qty = Qty + bom.orderQty, [Version] = orb.[Version] + 1, 
			--LastModifyDate = @DateTimeNow, LastModifyUser = @CreateUserId, LastModifyUserNm = @CreateUserNm
			--from ORD_OrderBomDet as bom 
			--inner join #tempOrderBom as tbom on bom.ReserveNo = tbom.ReserveNo and bom.ReserveLine = tbom.ReserveLine and bom.OpRef = tbom.OpRef and bom.OrderQty <> tbom.OrderQty
			--inner join SCM_OpRefBalance as orb on bom.Item = orb.Item and bom.OpRef = orb.OpRef
			--where bom.OrderNo = @OrderNo and bom.IsCreateOrder = 1
			
			----��Ԥ���ź�Ԥ���кŸ���Bom�����͹�λ
			--update bom set OrderQty = tbom.OrderQty, BomUnitQty = tbom.OrderQty, Op = tbom.Op, OpRef = tbom.OpRef, IsCreateOrder = 0, LastModifyDate = @DateTimeNow, 
			--LastModifyUser = @CreateUserId, LastModifyUserNm = @CreateUserNm, [Version] = bom.[Version] + 1
			--from ORD_OrderBomDet as bom 
			--inner join #tempOrderBom as tbom on bom.ReserveNo = tbom.ReserveNo and bom.ReserveLine = tbom.ReserveLine and bom.OpRef = tbom.OpRef and bom.OrderQty <> tbom.OrderQty
			--where bom.OrderNo = @OrderNo
			
			----�µ�BOMû�и�������Ѿ��������JIT���Ҫ�˻�BOM��������λ�������
			--update orb set Qty = Qty + bom.orderQty, [Version] = orb.[Version] + 1,
			--LastModifyDate = @DateTimeNow, LastModifyUser = @CreateUserId, LastModifyUserNm = @CreateUserNm
			--from ORD_OrderBomDet as bom 
			--inner join SCM_OpRefBalance as orb on bom.Item = orb.Item and bom.OpRef = orb.OpRef
			--left join #tempOrderBom as tbom on bom.ReserveNo = tbom.ReserveNo and bom.ReserveLine = tbom.ReserveLine and bom.OpRef = tbom.OpRef
			--where bom.OrderNo = @OrderNo and tbom.Item is null and bom.IsCreateOrder = 1
			
			----ɾ���µ�BOMû�и������
			--delete bom from ORD_OrderBomDet as bom 
			--left join #tempOrderBom as tbom on bom.ReserveNo = tbom.ReserveNo and bom.ReserveLine = tbom.ReserveLine and bom.OpRef = tbom.OpRef
			--where bom.OrderNo = @OrderNo and tbom.Item is null
			
			----��ȡBOm������
			--Declare @OrderBomSeq int
			--select @OrderBomSeq = Max(Seq) from ORD_OrderBomDet where OrderNo = @OrderNo
			--if @OrderBomSeq is null
			--begin
			--	set @OrderBomSeq = 1
			--end
			
			----�����ɵ�Bomû�и������
			--INSERT INTO ORD_OrderBomDet (
			--OrderNo,					--��������
			--OrderType,					--���ͣ�4������
			--OrderSubType,				--�����ͣ�0����
			--OrderDetId,					--��������ϸ��ʶ
			--OrderDetSeq,				--��������ϸ˳���
			--Seq,						--˳���
			--Item,						--Bom�����
			--ItemDesc,					--Bom�������
			--RefItemCode,				--�����Ϻ�
			--Uom,						--��λ
			--BaseUom,					--������λ
			--ManufactureParty,			--ָ����Ӧ��
			--JointOp,					--��װ���򣬶��ڷ�װ��JointOp�����װ�Ĺ���
			--Op,							--����
			--OpRef,						--��λ
			--OrderQty,					--Bom����
			--BFQty,						--����ϸ�����
			--BFRejQty,					--���岻�ϸ�����
			--BFScrapQty,					--�����Ʒ����
			--UnitQty,					--��λ����
			--BomUnitQty,					--������Ʒ����
			--Location,					--�����λ
			--IsPrint,					--�Ƿ��ӡ
			--BackFlushMethod,            --�س巽ʽ
			--FeedMethod,                 --Ͷ�Ϸ�ʽ
			--IsAutoFeed,                 --�Ƿ��Զ�Ͷ��
			--IsScanHu,                   --�Ƿ�ؼ���
			--EstConsumeTime,             --Ԥ������ʱ��
			--ReserveNo,                  --Ԥ����
			--ReserveLine,                --Ԥ���к�
			--ZOPWZ,						--����˳���
			--ZOPID,						--��λID
			--ZOPDS,						--��������
			--AUFNR,						--��������
			--CreateUser,					--�����û�
			--CreateUserNm,				--�����û�����
			--CreateDate,					--��������
			--LastModifyUser,				--����޸��û�
			--LastModifyUserNm,			--����޸��û�����
			--LastModifyDate,				--����޸�����
			--[Version],					--�汾��1
			--ICHARG,						--����
			--BWART,						--�ƶ�����
			--AssProdLine,				--�����װ��������/�����Ƿ�װ�ߣ�û�й�λ���߹�λ�����ڵ�ȥ���⹤λ
			--IsCreateOrder,				--�Ƿ��Ѿ��������ϵ�
			--DISPO,						--MRP������
			--BESKZ,                      --�ɹ�����
			--SOBSL,                      --����ɹ�����
			--WorkCenter,					--��������
			--PLNFL,						--����
			--VORNR,						--����
			--AUFPL						--����·�߱��
			--)
			--select
			--@OrderNo,					--��������
			--4,							--���ͣ�4������
			--0,							--�����ͣ�0����
			--@OrderDetId,				--��������ϸ��ʶ
			--1,							--��������ϸ˳���
			--@OrderBomSeq + ROW_NUMBER() over (order by tbom.Op, tbom.OpRef),		--˳���
			--tbom.Item,					--Bom�����
			--tbom.ItemDesc,				--Bom�������
			--tbom.RefItemCode,			--�����Ϻ�
			--tbom.Uom,					--��λ
			--tbom.Uom,					--������λ
			--tbom.ManufactureParty,		--ָ����Ӧ��
			--tbom.JointOp,				--��װ���򣬶��ڷ�װ��JointOp�����װ�Ĺ���
			--tbom.Op,					--����
			--tbom.OpRef,					--��λ
			--tbom.OrderQty,				--Bom����
			--0,							--����ϸ�����
			--0,							--���岻�ϸ�����
			--0,							--�����Ʒ����
			--1,							--��λ����
			--tbom.OrderQty,				--������Ʒ����
			--tbom.Location,				--�����λ
			--0,							--�Ƿ��ӡ
			--0,							--�س巽ʽ
			--0,							--Ͷ�Ϸ�ʽ
			--0,							--�Ƿ��Զ�Ͷ��
			--tbom.IsScanHu,				--�Ƿ�ؼ���
			--@DateTimeNow,				--Ԥ������ʱ��
			--tbom.ReserveNo,				--Ԥ����
			--tbom.ReserveLine,			--Ԥ���к�
			--tbom.ZOPWZ,					--����˳���
			--tbom.ZOPID,					--��λID
			--tbom.ZOPDS,					--��������
			--tbom.AUFNR,					--��������
			--@CreateUserId,              --�����û�
			--@CreateUserNm,              --�����û�����
			--@DateTimeNow,               --��������
			--@CreateUserId,              --����޸��û�
			--@CreateUserNm,              --����޸��û�����
			--@DateTimeNow,               --����޸�����
			--1,							--�汾��1
			--tbom.ICHARG,				--����
			--tbom.BWART,					--�ƶ�����
			--tbom.AssProdLine,			--�����װ��������/�����Ƿ�װ��
			--0,							--�Ƿ��Ѿ��������ϵ�
			--tbom.DISPO,					--MRP������
			--tbom.BESKZ,                 --�ɹ�����
			--tbom.SOBSL,                 --����ɹ�����
			--tbom.WorkCenter,			--��������
			--tbom.PLNFL,					--����
			--tbom.VORNR,					--����
			--tbom.AUFPL					--����·�߱��
			--from #tempOrderBom as tbom
			--left join ORD_OrderBomDet as bom on bom.ReserveNo = tbom.ReserveNo and bom.ReserveLine = tbom.ReserveLine and bom.OpRef = tbom.OpRef
			--where bom.Id is null
			
			--�Ѿ��������JIT���Ҫ�˻�BOM��������λ�������
			update orb set Qty = Qty + bom.OrderQty, [Version] = orb.[Version] + 1, 
			LastModifyDate = @DateTimeNow, LastModifyUser = @CreateUserId, LastModifyUserNm = @CreateUserNm
			from ORD_OrderBomDet as bom 
			inner join SCM_OpRefBalance as orb on bom.Item = orb.Item and bom.OpRef = orb.OpRef
			where bom.OrderNo = @OrderNo and bom.IsCreateOrder = 1 and bom.IsCreateSeq <> 1
			
			--���������ڵĹ�λ����
			insert into SCM_OpRefBalance(Item, OpRef, Qty, CreateUser, CreateUserNm, CreateDate, LastModifyUser, LastModifyUserNm, LastModifyDate, [Version])
			select bom.Item, bom.OpRef, SUM(bom.OrderQty) as Qty, @CreateUserId, @CreateUserNm, @DateTimeNow, @CreateUserId, @CreateUserNm, @DateTimeNow, 1
			from ORD_OrderBomDet as bom WITH(NOLOCK) 
			left join SCM_OpRefBalance as orb WITH(NOLOCK) on orb.Item = bom.Item and orb.OpRef = bom.OpRef
			where bom.OrderNo = @OrderNo and bom.IsCreateOrder = 1 and bom.IsCreateSeq <> 1 and orb.Id is null
			group by bom.Item, bom.OpRef
			
			--ɾ��ԭ������Bom
			delete from ORD_OrderBomDet where OrderNo = @OrderNo
			
			--����������Bom
			INSERT INTO ORD_OrderBomDet (
			OrderNo,					--��������
			OrderType,					--���ͣ�4������
			OrderSubType,				--�����ͣ�0����
			OrderDetId,					--��������ϸ��ʶ
			OrderDetSeq,				--��������ϸ˳���
			Seq,						--˳���
			Item,						--Bom�����
			ItemDesc,					--Bom�������
			RefItemCode,				--�����Ϻ�
			Uom,						--��λ
			BaseUom,					--������λ
			ManufactureParty,			--ָ����Ӧ��
			JointOp,					--��װ���򣬶��ڷ�װ��JointOp�����װ�Ĺ���
			Op,							--����
			OpRef,						--��λ
			OrderQty,					--Bom����
			BFQty,						--����ϸ�����
			BFRejQty,					--���岻�ϸ�����
			BFScrapQty,					--�����Ʒ����
			UnitQty,					--��λ����
			BomUnitQty,					--������Ʒ����
			Location,					--�����λ
			IsPrint,					--�Ƿ��ӡ
			BackFlushMethod,            --�س巽ʽ
			FeedMethod,                 --Ͷ�Ϸ�ʽ
			IsAutoFeed,                 --�Ƿ��Զ�Ͷ��
			IsScanHu,                   --�Ƿ�ؼ���
			EstConsumeTime,             --Ԥ������ʱ��
			ReserveNo,                  --Ԥ����
			ReserveLine,                --Ԥ���к�
			ZOPWZ,						--����˳���
			ZOPID,						--��λID
			ZOPDS,						--��������
			AUFNR,						--��������
			CreateUser,					--�����û�
			CreateUserNm,				--�����û�����
			CreateDate,					--��������
			LastModifyUser,				--����޸��û�
			LastModifyUserNm,			--����޸��û�����
			LastModifyDate,				--����޸�����
			[Version],					--�汾��1
			ICHARG,						--����
			BWART,						--�ƶ�����
			AssProdLine,				--�����װ��������/�����Ƿ�װ�ߣ�û�й�λ���߹�λ�����ڵ�ȡ���⹤λ
			IsCreateOrder,				--�Ƿ��Ѿ��������ϵ�
			DISPO,						--MRP������
			BESKZ,                      --�ɹ�����
			SOBSL,                      --����ɹ�����
			WorkCenter,					--��������
			PLNFL,						--����
			VORNR,						--����
			AUFPL						--����·�߱��
			)
			select
			@OrderNo,					--��������
			4,							--���ͣ�4������
			0,							--�����ͣ�0����
			@OrderDetId,				--��������ϸ��ʶ
			1,							--��������ϸ˳���
			ROW_NUMBER() over (order by Op, OpRef),--˳���
			Item,						--Bom�����
			ItemDesc,					--Bom�������
			RefItemCode,				--�����Ϻ�
			Uom,						--��λ
			Uom,						--������λ
			ManufactureParty,			--ָ����Ӧ��
			JointOp,					--��װ���򣬶��ڷ�װ��JointOp�����װ�Ĺ���
			Op,							--����
			OpRef,						--��λ
			OrderQty,					--Bom����
			0,							--����ϸ�����
			0,							--���岻�ϸ�����
			0,							--�����Ʒ����
			1,							--��λ����
			OrderQty,					--������Ʒ����
			Location,					--�����λ
			0,							--�Ƿ��ӡ
			0,							--�س巽ʽ
			0,							--Ͷ�Ϸ�ʽ
			0,							--�Ƿ��Զ�Ͷ��
			IsScanHu,                   --�Ƿ�ؼ���
			@DateTimeNow,				--Ԥ������ʱ��
			ReserveNo,                  --Ԥ����
			ReserveLine,                --Ԥ���к�
			ZOPWZ,						--����˳���
			ZOPID,						--��λID
			ZOPDS,						--��������
			AUFNR,						--��������
			@CreateUserId,              --�����û�
			@CreateUserNm,              --�����û�����
			@DateTimeNow,               --��������
			@CreateUserId,              --����޸��û�
			@CreateUserNm,              --����޸��û�����
			@DateTimeNow,               --����޸�����
			1,							--�汾��1
			ICHARG,						--����
			BWART,						--�ƶ�����
			AssProdLine,				--�����װ��������/�����Ƿ�װ��
			0,							--�Ƿ��Ѿ��������ϵ�
			DISPO,						--MRP������
			BESKZ,                      --�ɹ�����
			SOBSL,                      --����ɹ�����
			WorkCenter,					--��������
			PLNFL,						--����
			VORNR,						--����
			AUFPL						--����·�߱��
			from #tempOrderBom
			
			if not exists(select top 1 1 from ORD_OrderBomDet WITH(NOLOCK) where OrderNo = @OrderNo)
			begin
				update ORD_OrderMstr_4 set [Status] = 3, CompleteDate = @DateTimeNow, CompleteUser = @CreateUserId, CompleteUserNm = @CreateUserNm, [Version] = [Version] + 1
				where OrderNo = @OrderNo and [Version] = @OrderVersion
				
				if @@RowCount = 0
				begin
					set @ErrorMsg = N'����������' + @OrderNo + N'�Ѿ����¡�'
					insert into Log_GenVanProdOrder(AUFNR, ZLINE, ProdLine, BatchNo, Msg) values (@SapOrderNo, @SapProdLine, @VanProdLine, @BatchNo, @ErrorMsg)
					RAISERROR(@ErrorMsg, 16, 1)
				end
			end
		end
		-----------------------------������������Bom-----------------------------
		
		
		
		-----------------------------������������Op-----------------------------
		if @IsOrderExists = 0
		begin
			INSERT INTO ORD_OrderOp (
			OrderNo,					--��������
			OrderDetId,					--��������ϸ��ʶ
			Op,							--����
			OpRef,                      --��λ, ���ɶ�������ʱ�����ǹ�λ
			LeadTime,					--ǰ����
			TimeUnit,					--ǰ���ڵ�λ
			CreateUser,					--�����û�
			CreateUserNm,				--�����û�����
			CreateDate,					--��������
			LastModifyUser,				--����޸��û�
			LastModifyUserNm,			--����޸��û�����
			LastModifyDate,				--����޸�����
			[Version],					--�汾��1
			WorkCenter,					--��������
			IsAutoReport,				--�Ƿ��Զ�����
			ReportQty,					--��������
			BackflushQty,				--��Ʒ���Ϸ�������
			ScrapQty,					--��Ʒ����
			NeedReport,					--�Ƿ񱨹�����
			IsRecFG						--�Ƿ��ջ�����
			)
			select
			@OrderNo,					--��������
			@OrderDetId,				--��������ϸ��ʶ
			p.Op,							--����
			'',							--��λ, ���ɶ�������ʱ�����ǹ�λ
			0,							--ǰ����
			1,							--ǰ���ڵ�λ
			@CreateUserId,              --�����û�
			@CreateUserNm,              --�����û�����
			@DateTimeNow,               --��������
			@CreateUserId,              --����޸��û�
			@CreateUserNm,              --����޸��û�����
			@DateTimeNow,               --����޸�����
			1,							--�汾��1
			Max(p.WorkCenter),			--��������
			CASE WHEN SUM(CASE WHEN p.IsReport = 0 then 0 else 1 End) = 0 then 0 else 1 end,				--�Ƿ��Զ�����
			0,							--��������
			0,							--��Ʒ���Ϸ�������
			0,							--��Ʒ����
			1,							--�Ƿ񱨹�����
			0							--�Ƿ��ջ�����
			from PRD_RoutingDet as p WITH(NOLOCK)
			left join (select distinct ARBPL from SAP_ProdRoutingDet where BatchNo = @BatchNo and RUEK in ('1', '2')) as s on p.WorkCenter = s.ARBPL
			where p.Routing = @Routing and (p.WorkCenter is null or s.ARBPL is not null)
			group by p.Op
			
			--INSERT INTO CUST_SAPRoutingDet(AUFNR, WERKS, AUFPL, APLZL, PLNTY, PLNNR, PLNAL, PLNFL, VORNR, ARBPL, RUEK, AUTWE) 
			--select AUFNR, WERKS, AUFPL, APLZL, PLNTY, PLNNR, PLNAL, PLNFL, VORNR, ARBPL, RUEK, AUTWE
			--from SAP_ProdRoutingDet where BatchNo = @BatchNo
		end
		-----------------------------������������Op-----------------------------
		
		
		
		-----------------------------������SAP������Op-----------------------------
		if @IsOrderExists = 0
		begin
			insert into ORD_SAPOrderOp(OrderNo, WorkCenter, AUFNR, AUFPL, PLNFL, VORNR)
			select distinct @OrderNo, pwc.WorkCenter, routing.AUFNR, routing.AUFPL, routing.PLNFL, routing.VORNR
			from SAP_ProdRoutingDet as routing WITH(NOLOCK)
			inner join PRD_ProdLineWorkCenter as pwc WITH(NOLOCK) on routing.ARBPL = pwc.WorkCenter
			where routing.BatchNo = @BatchNo and pwc.Flow in (select VanProdLine from #tempVanProdLine)
		end
		-----------------------------������SAP������Op-----------------------------
		
		
		
		
		-----------------------------�������ؼ���ɨ��-----------------------------
		if @IsOrderExists = 1
		begin
			delete from ORD_OrderItemTrace where OrderNo = @OrderNo
		end
		
		INSERT INTO ORD_OrderItemTrace(
		OrderNo,
		Item,
		ItemDesc,
		RefItemCode,
		Op,
		OpRef,
		Qty,
		ScanQty,
		CreateUser,
		CreateUserNm,
		CreateDate,
		LastModifyUser,
		LastModifyUserNm,
		LastModifyDate,
		Version,
		TraceCode)
		select
		mstr.OrderNo,
		bom.Item,
		bom.ItemDesc,
		bom.RefItemCode,
		bom.Op,
		bom.OpRef,
		SUM(bom.OrderQty),
		0,
		@CreateUserId,
		@CreateUserNm,
		@DateTimeNow,
		@CreateUserId,
		@CreateUserNm,
		@DateTimeNow,
		1,
		mstr.TraceCode
		from ORD_OrderBomDet as bom  WITH(NOLOCK)
		inner join ORD_OrderMstr_4 as mstr WITH(NOLOCK) on bom.OrderNo = mstr.OrderNo
		where mstr.OrderNo = @OrderNo and bom.IsScanHu = 1
		group by mstr.OrderNo, bom.Item, bom.ItemDesc, bom.RefItemCode, bom.Op, bom.OpRef, mstr.TraceCode
		having SUM(bom.OrderQty) > 0
		
		if @IsOrderExists = 1 and exists(select top 1 1 from ORD_OrderItemTraceResult WITH(NOLOCK) where OrderNo = @OrderNo)
		begin
			if exists(select top 1 1 from ORD_OrderItemTraceResult as itr WITH(NOLOCK) left join ORD_OrderItemTrace as it WITH(NOLOCK) on itr.OrderNo = it.OrderNo and itr.Item = it.Item
				where itr.OrderNo = @OrderNo and it.Id is null)
			begin
				select top 1 @ErrorMsg = N'���º�����������' + @OrderNo + N'��Bom�����ں���ɨ��Ĺؼ���' + itr.Item + N'ƥ��ļ�¼����ɾ�����ٴθ��¡�'
				from ORD_OrderItemTraceResult as itr WITH(NOLOCK) left join ORD_OrderItemTrace as it WITH(NOLOCK) on itr.OrderNo = it.OrderNo and itr.Item = it.Item
				where itr.OrderNo = @OrderNo and it.Id is null
				
				insert into Log_GenVanProdOrder(AUFNR, ZLINE, ProdLine, BatchNo, Msg) values (@SapOrderNo, @SapProdLine, @VanProdLine, @BatchNo, @ErrorMsg)
				RAISERROR(@ErrorMsg, 16, 1)
			end
			
			if exists(select top 1 1 from ORD_OrderItemTraceResult as itr WITH(NOLOCK) inner join ORD_OrderItemTrace as it WITH(NOLOCK) on itr.OrderNo = it.OrderNo and itr.Item = it.Item
				where itr.OrderNo = @OrderNo group by itr.Id having count(*) > 1)
			begin
				select top 1 @ErrorMsg = N'���º�����������' + @OrderNo + N'��Bom���ڶ������Ѿ�ɨ��Ĺؼ���' + itr.Item + N'ƥ��ļ�¼����ɾ�����ٴθ��¡�'
				from ORD_OrderItemTraceResult as itr WITH(NOLOCK) inner join ORD_OrderItemTrace as it WITH(NOLOCK) on itr.OrderNo = it.OrderNo and itr.Item = it.Item
				where itr.OrderNo = @OrderNo group by itr.Id, itr.Item having count(*) > 1
				
				insert into Log_GenVanProdOrder(AUFNR, ZLINE, ProdLine, BatchNo, Msg) values (@SapOrderNo, @SapProdLine, @VanProdLine, @BatchNo, @ErrorMsg)
				RAISERROR(@ErrorMsg, 16, 1)
			end
			
			--���¸��¹ؼ���ɨ�����Ѿ�ɨ������
			update it set ScanQty = a.ScanQty
			from ORD_OrderItemTrace as it inner join 
			(select it.Id, COUNT(distinct itr.OrderItemTraceId) as ScanQty
			from ORD_OrderItemTraceResult as itr WITH(NOLOCK) inner join ORD_OrderItemTrace as it WITH(NOLOCK) on itr.OrderNo = it.OrderNo and itr.Item = it.Item
			where itr.OrderNo = @OrderNo
			group by it.Id) as a on it.Id = a.Id
		end
		-----------------------------�������ؼ���ɨ��-----------------------------
		
		
		
		-----------------------------��������ʻ�ҳ���-----------------------------
		declare @RowCount int
		declare @CabItem varchar(50)   --��ʻ�����Ϻ�
		declare @CabItemDesc varchar(100)   --��ʻ����������
		declare @CabType tinyint		--����/�⹺��ʻ�ұ��
		
		--���Ƶ�������ʻ�ң�MRP������IAF���䣬�ɹ�����ΪE������ɹ�����Ϊ�ա�
		--�⹺��������ʻ�ң�MRP������L13
		select @CabItem = Item, @CabItemDesc = ItemDesc from #tempOrderBom where DISPO = 'IAF' and BESKZ = 'E' and ISNULL(SOBSL, '') = ''
		set @RowCount = @@rowcount
		if @RowCount = 0
		begin
			select @CabItem = Item, @CabItemDesc = ItemDesc from #tempOrderBom where DISPO = 'L13'
			set @RowCount = @@rowcount
			
			if @RowCount = 1
			begin
				set @CabType = 1
			end
			else if @RowCount > 1
			begin
				set @ErrorMsg = N'�ҵ�����⹺��ʻ�ҡ�'
				insert into Log_GenVanProdOrder(AUFNR, ZLINE, ProdLine, BatchNo, Msg) values (@SapOrderNo, @SapProdLine, @VanProdLine, @BatchNo, @ErrorMsg)
				RAISERROR(@ErrorMsg, 16, 1)
			end
		end
		else if @RowCount = 1
		begin
			set @CabType = 0
		end
		else if @RowCount > 1
		begin
			set @ErrorMsg = N'�ҵ�������Ƽ�ʻ�ҡ�'
			insert into Log_GenVanProdOrder(AUFNR, ZLINE, ProdLine, BatchNo, Msg) values (@SapOrderNo, @SapProdLine, @VanProdLine, @BatchNo, @ErrorMsg)
			RAISERROR(@ErrorMsg, 16, 1)
		end
		
		if @RowCount = 1
		begin
			if @IsOrderExists = 0
			begin
				insert into CUST_CabOut(
				OrderNo, 
				ProdLine, 
				CabType, 
				CabItem,
				CabItemDesc,
				[Status], 
				CreateUser, 
				CreateUserNm, 
				CreateDate, 
				LastModifyUser, 
				LastModifyUserNm, 
				LastModifyDate)
				values(
				@OrderNo,
				@VanProdLine,
				@CabType,
				@CabItem,
				@CabItemDesc,
				0,
				@CreateUserId,
				@CreateUserNm,
				@DateTimeNow,
				@CreateUserId,
				@CreateUserNm,
				@DateTimeNow
				)
			end
			else if exists(select top 1 1 from CUST_CabOut WITH(NOLOCK) where OrderNo = @OrderNo and [Status] = 0)
			begin
				Update CUST_CabOut set CabType = @CabType, CabItem = @CabItem, CabItemDesc = @CabItemDesc where OrderNo = @OrderNo
			end
			--else
			--begin
			--	Update CUST_CabOut set CabType = @CabType, CabItem = @CabItem where OrderNo = @OrderNo
			--end
		end
		else
		begin
			delete from CUST_CabOut where OrderNo = @OrderNo
		end
		-----------------------------��������ʻ�ҳ���-----------------------------
		
		drop table #tempRoutingDet
		drop table #tempOrderBom
	end try 
	begin catch
		set @ErrorMsg = Error_Message() 
		RAISERROR(@ErrorMsg, 16, 1) 
	end catch 
END 
