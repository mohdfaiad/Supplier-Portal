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
		-----------------------------↓获取SAP生产单Bom-----------------------------
		declare @VanProdLineRegion varchar(50)  --生产线区域
		declare @LocTo varchar(50)     --生产线原材料
		declare @LocFrom varchar(50)   --生产线成品
		declare @Routing varchar(50)  --生产线工艺流程
		declare @ProdLineType tinyint   --生产线类型
		declare @TaktTime int           --节拍时间（秒）
		declare @VirtualOpRef varchar(50)   --虚拟工位
		declare @FlowDesc varchar(100)	--路线描述
		declare @OrderTemplate varchar(100)	--订单模板
		declare @FGItem varchar(50)   --整车物料号
		
		--获取生产线信息
		select @VanProdLineRegion = PartyFrom, @LocFrom = LocFrom, @LocTo = LocTo, @Routing = Routing, 
		@ProdLineType = ProdLineType, @TaktTime = TaktTime, @VirtualOpRef = VirtualOpRef, @FlowDesc = Desc1, @OrderTemplate=OrderTemplate
		from SCM_FlowMstr WITH(NOLOCK) where Code = @VanProdLine
		
		--获取整车物料号
		select @FGItem = Item from ORD_OrderDet_4 where OrderNo = @OrderNo
		-----------------------------↑获取SAP生产单Bom-----------------------------
		
		
		
		
		-----------------------------↓新增工序临时表-----------------------------
		Create table #tempRoutingDet
		(
			RowId int Identity(1, 1) Primary Key,
			LoopCount int,
			AssProdLine varchar(50),
			Routing varchar(50),
			JointOp int,               --合装工序
			Op int,
			OpRef varchar(50),
			Location varchar(50),
			WorkCenter varchar(50)
		)
		
		--插入主线工序
		declare @LoopCount int = 1
		insert into #tempRoutingDet(LoopCount, AssProdLine, Routing, JointOp, Op, OpRef, Location, WorkCenter)
		select @LoopCount, @VanProdLine, Routing, Op, Op, OpRef, Location, WorkCenter 
		from PRD_RoutingDet WITH(NOLOCK) where Routing = @Routing
		
		--插入分装线工序
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
		-----------------------------↑新增工序临时表-----------------------------
		
		
		
		
		-----------------------------↓新增生产单Bom临时表-----------------------------
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
		
		--查找Bom
		insert into #tempOrderBom(SapBomId, Item, ItemDesc, RefItemCode, UOM, ManufactureParty,
		AssProdLine, JointOp, Op, OpRef, OrderQty, Location,
		ReserveNo, ReserveLine, ZOPWZ, ZOPID, ZOPDS, AUFNR, ICHARG, BWART,
		IsScanHu, WorkCenter, DISPO, BESKZ, SOBSL, PLNFL, VORNR, AUFPL, GW)
		select distinct bom.Id as SapBomId, bom.MATERIAL as Item, bom.MAKTX as ItemDesc, bom.BISMT as RefItemCode, bom.MEINS as UOM, case when bom.LIFNR <> '' then bom.LIFNR else null end as ManufactureParty,
		null as ProdLine, null as JointOp, null as Op, case when ISNULL(GW, '') = '' then @VirtualOpRef when Len(GW) > 5 then SUBSTRING(GW, 1, 5) else GW end as OpRef, case when bom.BWART = '531' then -MDMNG else MDMNG end as OrderQty, null as Location,
		bom.RSNUM as ReserveNo, bom.RSPOS as ReserveLine, null as ZOPWZ, bom.ZOPID, bom.ZOPDS, bom.AUFNR, bom.ICHARG, bom.BWART,
		CASE WHEN trace.Item is not null THEN 1 ELSE 0 END as IsScanHu, pwc.WorkCenter, bom.DISPO, bom.BESKZ, bom.SOBSL, bom.PLNFL, bom.VORNR, bom.AUFPL, bom.GW
		from SAP_ProdBomDetUpdate as bom WITH(NOLOCK)
		inner join ORD_SAPOrderOp as op WITH(NOLOCK) on  bom.AUFPL = op.AUFPL and bom.PLNFL = op.PLNFL and bom.VORNR = op.VORNR  --用工艺路线编号、顺序和操作活动关联
		inner join PRD_ProdLineWorkCenter as pwc WITH(NOLOCK) on op.WorkCenter = pwc.WorkCenter
		left join CUST_ItemTrace as trace WITH(NOLOCK) on bom.MATERIAL = trace.Item
		left join ORD_OrderBomDet as obom WITH(NOLOCK) on bom.RSNUM = obom.ReserveNo and bom.RSPOS = obom.ReserveLine
		where bom.BatchNo = @BatchNo and bom.MDMNG > 0 and bom.RGEKZ = 'X' and pwc.Flow = @VanProdLine
		and op.OrderNo = @OrderNo and bom.GW in ('Insert', 'InsertOn') and obom.Id is null
		
		--删除负数Bom
		delete from #tempOrderBom where OrderQty < 0
		
		--更新工序
		declare @MinOp int  --最小工序，从主线上取
		select @MinOp = MIN(Op) from PRD_RoutingDet WITH(NOLOCK) where Routing = @Routing
		
		--更新安装生产线、工序、工位和物料消耗库位，工序取合装工序
		update bom set AssProdLine = IsNULL(det.AssProdLine, @VanProdLine),--工艺流程没有匹配的工位取整车生产线
		JointOp = IsNULL(det.JointOp, @MinOp),									--工艺流程没有匹配的工位取整车生产线的最小工序
		Op = IsNULL(det.Op, @MinOp),									--工艺流程没有匹配的工位取整车生产线的最小工序
		OpRef = ISNULL(det.OpRef, @VirtualOpRef),						--工艺流程没有匹配的工位取整车生产线的虚拟工位
		Location = det.Location
		from #tempOrderBom as bom
		left join #tempRoutingDet as det on bom.OpRef = det.OpRef
		
		--更新物料消耗库位，再从工作中心上找
		update bom set Location = wc.Location
		from #tempOrderBom as bom
		inner join MD_WorkCenter as wc on bom.WorkCenter = wc.Code 
		where bom.Location is null
		
		--更新物料消耗库位，最后取生产线上的原材料库位
		update #tempOrderBom set Location = @LocFrom where Location is null
		-----------------------------↑新增生产单BomBom临时表-----------------------------
		
		
		-----------------------------↓新增生产单Bom-----------------------------
		if exists(select top 1 1 from ORD_OrderBomDet where OrderNo = @OrderNo)
		begin  --只有生产单没有归档才添加
			INSERT INTO ORD_OrderBomDet (
			OrderNo,					--生产单Bom号
			OrderType,					--类型，4生产单Bom
			OrderSubType,				--子类型，0正常
			OrderDetId,					--生产单Bom明细标识
			OrderDetSeq,				--生产单Bom明细顺序号
			Seq,						--顺序号
			Item,						--Bom零件号
			ItemDesc,					--Bom零件描述
			RefItemCode,				--旧物料号
			Uom,						--单位
			BaseUom,					--基本单位
			ManufactureParty,			--指定供应商
			JointOp,					--合装工序，对于分装线JointOp代表合装的工序
			Op,							--工序
			OpRef,						--工位
			OrderQty,					--Bom用量
			BFQty,						--反冲合格数量
			BFRejQty,					--反冲不合格数量
			BFScrapQty,					--反冲废品数量
			UnitQty,					--单位用量
			BomUnitQty,					--单个成品用量
			Location,					--反冲库位
			IsPrint,					--是否打印
			BackFlushMethod,            --回冲方式
			FeedMethod,                 --投料方式
			IsAutoFeed,                 --是否自动投料
			IsScanHu,                   --是否关键件
			EstConsumeTime,             --预计消耗时间
			ReserveNo,                  --预留号
			ReserveLine,                --预留行号
			ZOPWZ,						--工艺顺序号
			ZOPID,						--工位ID
			ZOPDS,						--工序描述
			AUFNR,						--生产单Bom号
			CreateUser,					--创建用户
			CreateUserNm,				--创建用户名称
			CreateDate,					--创建日期
			LastModifyUser,				--最后修改用户
			LastModifyUserNm,			--最后修改用户名称
			LastModifyDate,				--最后修改日期
			[Version],					--版本，1
			ICHARG,						--批号
			BWART,						--移动类型
			AssProdLine,				--零件安装的生产线/可能是分装线，没有工位或者工位不存在的取虚拟工位
			IsCreateOrder,				--是否已经创建拉料单
			DISPO,						--MRP控制者
			BESKZ,                      --采购类型
			SOBSL,                      --特殊采购类型
			WorkCenter,					--工作中心
			PLNFL,						--序列
			VORNR,						--操作
			AUFPL,						--工艺路线编号
			Bom							--记录是否上线后更新
			)
			select
			@OrderNo,					--生产单Bom号
			4,							--类型，4生产单Bom
			0,							--子类型，0正常
			@OrderDetId,				--生产单Bom明细标识
			1,							--生产单Bom明细顺序号
			ROW_NUMBER() over (order by Op, OpRef),--顺序号
			Item,						--Bom零件号
			ItemDesc,					--Bom零件描述
			RefItemCode,				--旧物料号
			Uom,						--单位
			Uom,						--基本单位
			ManufactureParty,			--指定供应商
			JointOp,					--合装工序，对于分装线JointOp代表合装的工序
			Op,							--工序
			OpRef,						--工位
			OrderQty,					--Bom用量
			0,							--反冲合格数量
			0,							--反冲不合格数量
			0,							--反冲废品数量
			1,							--单位用量
			OrderQty,					--单个成品用量
			Location,					--反冲库位
			0,							--是否打印
			0,							--回冲方式
			0,							--投料方式
			0,							--是否自动投料
			IsScanHu,                   --是否关键件
			@DateTimeNow,				--预计消耗时间
			ReserveNo,                  --预留号
			ReserveLine,                --预留行号
			ZOPWZ,						--工艺顺序号
			ZOPID,						--工位ID
			ZOPDS,						--工序描述
			AUFNR,						--生产单Bom号
			@CreateUserId,              --创建用户
			@CreateUserNm,              --创建用户名称
			@DateTimeNow,               --创建日期
			@CreateUserId,              --最后修改用户
			@CreateUserNm,              --最后修改用户名称
			@DateTimeNow,               --最后修改日期
			1,							--版本，1
			ICHARG,						--批号
			BWART,						--移动类型
			AssProdLine,				--零件安装的生产线/可能是分装线
			0,							--是否已经创建拉料单
			DISPO,						--MRP控制者
			BESKZ,                      --采购类型
			SOBSL,                      --特殊采购类型
			WorkCenter,					--工作中心
			PLNFL,						--序列
			VORNR,						--操作
			AUFPL,						--工艺路线编号
			CASE WHEN GW = 'InsertOn' THEN 1 ELSE NULL END    --记录是否上线后更新
			from #tempOrderBom
		end
		-----------------------------↑新增生产单Bom-----------------------------
		
		
		
		-----------------------------↓记录上线后更新的BOM至客户化表-----------------------------
		----新增Bom
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
		inner join ORD_SAPOrderOp as op WITH(NOLOCK) on  bom.AUFPL = op.AUFPL and bom.PLNFL = op.PLNFL and bom.VORNR = op.VORNR  --用工艺路线编号、顺序和操作活动关联
		inner join PRD_ProdLineWorkCenter as pwc WITH(NOLOCK) on op.WorkCenter = pwc.WorkCenter
		inner join MD_WorkCenter as wc WITH(NOLOCK) on pwc.WorkCenter = wc.Code 
		inner join MD_Location as l WITH(NOLOCK) on wc.Location = l.Code
		where bom.BatchNo = @BatchNo and bom.MDMNG > 0 and bom.RGEKZ = 'X' and pwc.Flow = @VanProdLine
		and op.OrderNo = @OrderNo and bom.GW in ('InsertOn', 'DeleteOn')
		-----------------------------↑记录上线后更新的BOM至客户化表-----------------------------
		
		
		
		-----------------------------↓新增关键件扫描-----------------------------
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
		-----------------------------↑新增关键件扫描-----------------------------
		
		
		drop table #tempRoutingDet
		drop table #tempOrderBom
	end try 
	begin catch
		declare @ErrorMsg nvarchar(MAX) = Error_Message() 
		RAISERROR(@ErrorMsg, 16, 1) 
	end catch 
END 
