SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF EXISTS(SELECT * FROM sys.objects WHERE type='P' AND name='USP_Busi_UpdateSingleVanProdOrderBomDet') 
     DROP PROCEDURE USP_Busi_UpdateSingleVanProdOrderBomDet
GO

CREATE PROCEDURE [dbo].[USP_Busi_UpdateSingleVanProdOrderBomDet]
(
	@BatchNo int,
	@VanProdLine varchar(50),
	@OrderNo varchar(50),
	@OrderDetId int,
	@CreateUserId int,
	@CreateUserNm varchar(50)
) --WITH ENCRYPTION
AS 
BEGIN 
	set nocount on
	declare @DateTimeNow datetime = GetDate()
	
	begin try
		-----------------------------����ȡSAP������Bom-----------------------------
		declare @VanProdLineRegion varchar(50)  --����������
		declare @LocTo varchar(50)     --������ԭ����
		declare @LocFrom varchar(50)   --�����߳�Ʒ
		declare @Routing varchar(50)  --�����߹�������
		declare @ProdLineType tinyint   --����������
		declare @TaktTime int           --����ʱ�䣨�룩
		declare @VirtualOpRef varchar(50)   --���⹤λ
		declare @FlowDesc varchar(100)	--·������
		declare @OrderTemplate varchar(100)	--����ģ��
		declare @FGItem varchar(50)   --�������Ϻ�
		
		--��ȡ��������Ϣ
		select @VanProdLineRegion = PartyFrom, @LocFrom = LocFrom, @LocTo = LocTo, @Routing = Routing, 
		@ProdLineType = ProdLineType, @TaktTime = TaktTime, @VirtualOpRef = VirtualOpRef, @FlowDesc = Desc1, @OrderTemplate=OrderTemplate
		from SCM_FlowMstr WITH(NOLOCK) where Code = @VanProdLine
		
		--��ȡ�������Ϻ�
		select @FGItem = Item from ORD_OrderDet_4 where OrderNo = @OrderNo
		-----------------------------����ȡSAP������Bom-----------------------------
		
		
		
		
		-----------------------------������������ʱ��-----------------------------
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
		-----------------------------������������ʱ��-----------------------------
		
		
		
		
		-----------------------------������������Bom��ʱ��-----------------------------
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
			AUFPL varchar(50),
			GW varchar(50)
		)
		
		--����Bom
		insert into #tempOrderBom(SapBomId, Item, ItemDesc, RefItemCode, UOM, ManufactureParty,
		AssProdLine, JointOp, Op, OpRef, OrderQty, Location,
		ReserveNo, ReserveLine, ZOPWZ, ZOPID, ZOPDS, AUFNR, ICHARG, BWART,
		IsScanHu, WorkCenter, DISPO, BESKZ, SOBSL, PLNFL, VORNR, AUFPL, GW)
		select distinct bom.Id as SapBomId, bom.MATERIAL as Item, bom.MAKTX as ItemDesc, bom.BISMT as RefItemCode, bom.MEINS as UOM, case when bom.LIFNR <> '' then bom.LIFNR else null end as ManufactureParty,
		null as ProdLine, null as JointOp, null as Op, case when ISNULL(GW, '') = '' then @VirtualOpRef when Len(GW) > 5 then SUBSTRING(GW, 1, 5) else GW end as OpRef, case when bom.BWART = '531' then -MDMNG else MDMNG end as OrderQty, null as Location,
		bom.RSNUM as ReserveNo, bom.RSPOS as ReserveLine, null as ZOPWZ, bom.ZOPID, bom.ZOPDS, bom.AUFNR, bom.ICHARG, bom.BWART,
		CASE WHEN trace.Item is not null THEN 1 ELSE 0 END as IsScanHu, pwc.WorkCenter, bom.DISPO, bom.BESKZ, bom.SOBSL, bom.PLNFL, bom.VORNR, bom.AUFPL, bom.GW
		from SAP_ProdBomDetUpdate as bom WITH(NOLOCK)
		inner join ORD_SAPOrderOp as op WITH(NOLOCK) on  bom.AUFPL = op.AUFPL and bom.PLNFL = op.PLNFL and bom.VORNR = op.VORNR  --�ù���·�߱�š�˳��Ͳ��������
		inner join PRD_ProdLineWorkCenter as pwc WITH(NOLOCK) on op.WorkCenter = pwc.WorkCenter
		left join CUST_ItemTrace as trace WITH(NOLOCK) on bom.MATERIAL = trace.Item
		left join ORD_OrderBomDet as obom WITH(NOLOCK) on bom.RSNUM = obom.ReserveNo and bom.RSPOS = obom.ReserveLine
		where bom.BatchNo = @BatchNo and bom.MDMNG > 0 and bom.RGEKZ = 'X' and pwc.Flow = @VanProdLine
		and op.OrderNo = @OrderNo and bom.GW in ('Insert', 'InsertOn') and obom.Id is null
		
		--ɾ������Bom
		delete from #tempOrderBom where OrderQty < 0
		
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
		-----------------------------������������BomBom��ʱ��-----------------------------
		
		
		-----------------------------������������Bom-----------------------------
		if exists(select top 1 1 from ORD_OrderBomDet where OrderNo = @OrderNo)
		begin  --ֻ��������û�й鵵�����
			INSERT INTO ORD_OrderBomDet (
			OrderNo,					--������Bom��
			OrderType,					--���ͣ�4������Bom
			OrderSubType,				--�����ͣ�0����
			OrderDetId,					--������Bom��ϸ��ʶ
			OrderDetSeq,				--������Bom��ϸ˳���
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
			AUFNR,						--������Bom��
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
			AUFPL,						--����·�߱��
			Bom							--��¼�Ƿ����ߺ����
			)
			select
			@OrderNo,					--������Bom��
			4,							--���ͣ�4������Bom
			0,							--�����ͣ�0����
			@OrderDetId,				--������Bom��ϸ��ʶ
			1,							--������Bom��ϸ˳���
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
			AUFNR,						--������Bom��
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
			AUFPL,						--����·�߱��
			CASE WHEN GW = 'InsertOn' THEN 1 ELSE NULL END    --��¼�Ƿ����ߺ����
			from #tempOrderBom
		end
		-----------------------------������������Bom-----------------------------
		
		
		
		-----------------------------����¼���ߺ���µ�BOM���ͻ�����-----------------------------
		----����Bom
		--insert into CUST_OrderBomDetOnline(
		--Region,
		--Location,
		--AUFNR,
		--Item,
		--ItemDesc,
		--Uom,
		--Qty,
		--FGItem,
		--ProdLine,
		--MoveType,
		--CreateDate,
		--CreateUser,
		--CreateUserNm,
		--LastModifyDate,
		--LastModifyUser,
		--LastModifyUserNm,
		--Version,
		--ErrorCount,
		--Status,
		--ReserveNo,
		--ReserveLine,
		--GW)
		--select 
		--l.Region,
		--bom.Location,
		--bom.AUFNR,
		--bom.Item,
		--bom.ItemDesc,
		--bom.UOM,
		--bom.OrderQty,
		--@FGItem,
		--@VanProdLine,
		--'261',
		--@DateTimeNow,
		--@CreateUserId,
		--@CreateUserNm,
		--@DateTimeNow,
		--@CreateUserId,
		--@CreateUserNm,
		--1,
		--0,
		--0,
		--bom.ReserveNo,
		--bom.ReserveLine,
		--bom.GW	
		--from #tempOrderBom as bom
		--inner join MD_Location as l on bom.Location = l.Code
		--where bom.GW = 'InsertOn'
		
		insert into CUST_OrderBomDetOnline(
		Region,
		Location,
		AUFNR,
		Item,
		ItemDesc,
		Uom,
		Qty,
		FGItem,
		ProdLine,
		MoveType,
		CreateDate,
		CreateUser,
		CreateUserNm,
		LastModifyDate,
		LastModifyUser,
		LastModifyUserNm,
		Version,
		ErrorCount,
		Status,
		ReserveNo,
		ReserveLine,
		GW,
		PLNFL,
		VORNR,
		AUFPL,
		SAPStatus)
		select 
		l.Region,
		wc.Location,
		bom.AUFNR,
		bom.MAKTX,
		bom.MATERIAL,
		i.Uom,
		bom.MDMNG,
		@FGItem,
		@VanProdLine,
		CASE WHEN bom.GW = 'InsertOn' THEN '261' ELSE '262' END,
		@DateTimeNow,
		@CreateUserId,
		@CreateUserNm,
		@DateTimeNow,
		@CreateUserId,
		@CreateUserNm,
		1,
		0,
		0,
		bom.RSNUM,
		bom.RSPOS,
		bom.GW,
		bom.PLNFL,
		bom.VORNR,
		bom.AUFPL,
		0
		from SAP_ProdBomDetUpdate as bom WITH(NOLOCK)
		inner join MD_Item as i WITH(NOLOCK) on bom.MAKTX = i.Code
		inner join ORD_SAPOrderOp as op WITH(NOLOCK) on  bom.AUFPL = op.AUFPL and bom.PLNFL = op.PLNFL and bom.VORNR = op.VORNR  --�ù���·�߱�š�˳��Ͳ��������
		inner join PRD_ProdLineWorkCenter as pwc WITH(NOLOCK) on op.WorkCenter = pwc.WorkCenter
		inner join MD_WorkCenter as wc WITH(NOLOCK) on pwc.WorkCenter = wc.Code 
		inner join MD_Location as l WITH(NOLOCK) on wc.Location = l.Code
		where bom.BatchNo = @BatchNo and bom.MDMNG > 0 and bom.RGEKZ = 'X' and pwc.Flow = @VanProdLine
		and op.OrderNo = @OrderNo and bom.GW in ('InsertOn', 'DeleteOn')
		-----------------------------����¼���ߺ���µ�BOM���ͻ�����-----------------------------
		
		
		
		-----------------------------�������ؼ���ɨ��-----------------------------
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
		-----------------------------�������ؼ���ɨ��-----------------------------
		
		
		drop table #tempRoutingDet
		drop table #tempOrderBom
	end try 
	begin catch
		declare @ErrorMsg nvarchar(MAX) = Error_Message() 
		RAISERROR(@ErrorMsg, 16, 1) 
	end catch 
END 
