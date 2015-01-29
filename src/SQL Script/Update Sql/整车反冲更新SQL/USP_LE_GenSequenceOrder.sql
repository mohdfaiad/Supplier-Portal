SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF EXISTS(SELECT * FROM SYS.OBJECTS WHERE TYPE='P' AND name='USP_LE_GenSequenceOrder')
	DROP PROCEDURE USP_LE_GenSequenceOrder	
GO

CREATE PROCEDURE [dbo].[USP_LE_GenSequenceOrder]
(
	@BatchNo int,
	@CreateUserId int,
	@CreateUserNm varchar(100)
) --WITH ENCRYPTION
AS
BEGIN
	set nocount on
	declare @DateTimeNow datetime = GetDate()
	declare @Msg nvarchar(Max)
	declare @trancount int
	
	create table #tempSeqGroup
	(
		RowId int identity(1, 1),
		SeqGroup varchar(50)
	)
	
	create table #tempSeqFlow
	(
		RowId int identity(1, 1),
		Flow varchar(50),
		[Type] tinyint,
		PartyFrom varchar(50),
		PartyTo varchar(50),
		LocFrom varchar(50),
		LocTo varchar(50),
		WinTimeDiff decimal(18, 8),
		EMLeadTime decimal(18, 8),
		LeadTime decimal(18, 8),
		MRPWeight int,
		MRPTotal decimal(18, 8),
		MRPTotalAdj decimal(18, 8),
		DeliveryCount int,
		DeliveryBalance int,
		IsCreatePickList bit
	)
	
	create table #tempAssOpRef
	(
		AssOpRef varchar(50)
	)
	
	create table #tempWMSKitWorkCenter
	(
		Flow varchar(50),
		WorkCenter varchar(50)
	)
	
	create table #tempTargetTraceCode
	(
		RowNo int,
		OrderNo varchar(50),
		TraceCode varchar(50),
		Seq bigint,
		SubSeq int
	)
	
	create table #tempBomCPTime
	(
		Id int identity(1, 1) Primary Key,
		OrderNo varchar(50),
		TraceCode varchar(50),
		Seq bigint,
		SubSeq int,
		CPTime datetime,
		Flow varchar(50),
		Item varchar(50), 
		ItemDesc varchar(100),
		RefItemCode varchar(50),
		Uom varchar(5),
		UC decimal(18, 8),
		MinUC decimal(18, 8),
		UCDesc varchar(50),
		Container varchar(50),
		ContainerDesc varchar(50),
		OpRef varchar(50), 
		OrderQty decimal(18, 8), 
		Location varchar(50), 
		BomId int, 
		ManufactureParty varchar(50),
		LocFrom varchar(50),
		LocTo varchar(50),
		ZOPWZ varchar(50),
		ZOPID varchar(50),
		ZOPDS varchar(50)
	)
	
	create table #tempFlowDet
	(
		FlowDetRowId int identity(1, 1) Primary Key,
		Flow varchar(50),		
		Item varchar(50), 
		ItemDesc varchar(100),
		RefItemCode varchar(50),
		Uom varchar(5),
		UC decimal(18, 8),
		MinUC decimal(18, 8),
		UCDesc varchar(50),
		Container varchar(50),
		ContainerDesc varchar(50),
		MrpTotal decimal(18, 8),
		MrpTotalAdj decimal(18, 8),
		MrpWeight int,
		LocFrom varchar(50),
		LocTo varchar(50)
	)
	
	create table #tempSeqOrderDet
	(
		RowId int identity(1, 1),
		Id int,
		Seq int, 
		TraceCode varchar(50), 
		VanSeq varchar(50),
		Item varchar(50), 
		ItemDesc varchar(100), 
		RefItemCode varchar(50), 
		ReqQty decimal(18, 8), 
		OrderQty decimal(18, 8), 
		Uom varchar(5), 
		UC decimal(18, 8), 
		MinUC decimal(18, 8), 
		UCDesc varchar(50),
		Container varchar(50),
		ContainerDesc varchar(50),
		ManufactureParty varchar(50),
		OpRef varchar(50),
		CPTime datetime,
		LocFrom varchar(50),
		LocTo varchar(50),
		IsCreateSeq bit,
		ZOPWZ varchar(50),
		ZOPID varchar(50),
		ZOPDS varchar(50),
		IsItemConsume bit
	)
	
	create table #tempMultiSupplierGroup
	(
		RowId int identity(1, 1),
		Item varchar(50)
	)
	
	create table #tempMultiSupplierItem
	(
		RowId int identity(1, 1),
		FlowDetRowId int,
		Flow varchar(50),
		Item varchar(50), 
		MSGRowId int,
		MrpTotal decimal(18, 8),
		MrpTotalAdj decimal(18, 8),
		MrpWeight int,
		DeliveryCount int,
		DeliveryBalance int,
	)
	
	create table #tempSortedMultiSupplierItem
	(
		GID int, 
		FlowDetRowId int,
		Flow varchar(50)
	)
	
	create table #tempItemConsume
	(
		RowId int identity(1, 1),
		Id int,
		Item varchar(50),
		RemainQty decimal(18, 8),
		[Version] int
	)
	
	create table #tempSeqOrderTrace
	(
		TraceCode varchar(50), 
		ProdLine varchar(50), 
		SeqGroup varchar(50), 
		DeliveryCount varchar(50)
	)
	
	create table #tempICSeqOrderDet
	(
		RowId int identity(1, 1),
		SeqRowId int
	)
	
	CREATE TABLE #temp_LOG_GenSequenceOrder (
		SeqGroup varchar(50) NULL,
		Flow varchar(50) NULL,
		Lvl tinyint NULL,
		Msg varchar(500) NULL,
		CreateDate datetime NULL default(GETDATE()),
		OrderNo varchar(50) NULL
	)
	
	--��¼��־
	set @Msg = N'�������򵥿�ʼ'
	insert into LOG_GenSequenceOrder(Lvl, Msg) values(0, @Msg)
	
	declare @SeqGroupRowId int
	declare @MaxSeqGroupRowId int

	insert into #tempSeqGroup(SeqGroup) 
	select seq.Code
	from SCM_SeqGroup as seq inner join SCM_FlowMstr as mstr on seq.ProdLine = mstr.Code
	where mstr.IsActive = 1 and seq.IsActive = 1
	
	select @SeqGroupRowId = MIN(RowId), @MaxSeqGroupRowId = MAX(RowId) from #tempSeqGroup
	
	while(@SeqGroupRowId <= @MaxSeqGroupRowId)
	begin
		truncate table #temp_LOG_GenSequenceOrder
		
		declare @LoopCount int = 0
		while @LoopCount <= 10
		begin
			begin try
				-----------------------------��ѭ����������-----------------------------
				declare @SeqGroup varchar(50) = null
				declare @AssOpRef varchar(50) = null
				declare @ProdLine varchar(50) = null
				declare @ProdLineRegion varchar(50) = null
				declare @SeqBatch int
				declare @PrevOrderNo varchar(50) = null
				declare @PrevTraceCode varchar(50) = null
				declare @PrevSeq bigint = null
				declare @PrevSubSeq int = null
				declare @PrevDeliveryDate datetime = null
				declare @PrevDeliveryCount int = null
				declare @Version int = null
				declare @SplitSymbol1 char(1) = ','
				declare @SplitSymbol2 char(1) = '|'
				declare @IsWMSKitOrder bit = null
				
				-----------------------------����ȡ�����������·��-----------------------------
				--��ȡ����������
				select @SeqGroup = Code, @AssOpRef = OpRef, @ProdLine = ProdLine, @SeqBatch = SeqBatch, @PrevOrderNo = PrevOrderNo, @PrevTraceCode = PrevTraceCode, 
				@PrevDeliveryDate = PrevDeliveryDate, @PrevDeliveryCount = PrevDeliveryCount, @Version = [Version] 
				from SCM_SeqGroup where Code = (select SeqGroup from #tempSeqGroup where RowId = @SeqGroupRowId)
				
				--����������
				select @ProdLineRegion = PartyFrom from SCM_FlowMstr where Code = @ProdLine
				
				--��¼��־
				set @Msg = N'���򵥼��㿪ʼ'
				insert into #temp_LOG_GenSequenceOrder(SeqGroup, Lvl, Msg) values(@SeqGroup, 0, @Msg)
				
				--��ȡ����·��
				truncate table #tempSeqFlow
				insert into #tempSeqFlow(Flow, [Type], PartyFrom, PartyTo, LocFrom, LocTo, WinTimeDiff, EMLeadTime, LeadTime, 
				MRPWeight, MRPTotal, MRPTotalAdj, 
				DeliveryCount, 
				DeliveryBalance,
				IsCreatePickList) 
				select stra.Flow, mstr.[Type], mstr.PartyFrom, mstr.PartyTo, mstr.LocFrom, mstr.LocTo, stra.WinTimeDiff, stra.EMLeadTime, stra.LeadTime + stra.WinTimeDiff, 
				stra.MRPWeight, ISNULL(stra.MRPTotal, 0), ISNULL(stra.MRPTotalAdj, 0), 
				(ISNULL(stra.MRPTotal, 0) + ISNULL(stra.MRPTotalAdj, 0)) / (case when stra.MRPWeight = 0 or stra.MRPWeight is null then 1 else stra.MRPWeight end) as DeliveryCount,
				(ISNULL(stra.MRPTotal, 0) + ISNULL(stra.MRPTotalAdj, 0)) % (case when stra.MRPWeight = 0 or stra.MRPWeight is null then 1 else stra.MRPWeight end) as DeliveryBalance,
				CASE WHEN mstr.Type = 2 and stra.IsCreatePL = 1 THEN 1 ELSE 0 END as IsCreatePickList
				from SCM_FlowStrategy as stra
				inner join SCM_FlowMstr as mstr on stra.Flow = mstr.Code
				where stra.SeqGroup = @SeqGroup and stra.Strategy = 4 and mstr.IsActive = 1
				
				if (select COUNT(1) from #tempSeqFlow where MRPWeight > 0) > 0
				begin  --���������ѭ����,����ѭ����ѡȡ·��
					-------------------������ѭ����ѡȡ·����ϸ-----------------------
					declare @SelectedFlow varchar(50) = null
					
					select top 1 @SelectedFlow = Flow from #tempSeqFlow where MRPWeight >= 0
						order by DeliveryCount asc, MRPWeight desc, DeliveryBalance desc
						
					--��¼��־
					insert into #temp_LOG_GenSequenceOrder(SeqGroup, Flow, Lvl, Msg)
					values(@SeqGroup, @SelectedFlow, 0, N'����ѭ����ѡȡ·��')
				
					delete from #tempSeqFlow where MRPWeight >= 0 and Flow <> @SelectedFlow
					-------------------������ѭ����ѡȡ·����ϸ-----------------------
				end
				
				if exists(select top 1 1 from CUST_ProductLineMap as map
						 inner join #tempSeqFlow as transFlow on map.TransFlow = transFlow.Flow)
				begin   --������
					set @IsWMSKitOrder = 1
				end
				else if exists(select top 1 1 from CUST_ProductLineMap as map
						 inner join #tempSeqFlow as saddleFlow on map.SaddleFlow = saddleFlow.Flow)
				begin	--����
					set @IsWMSKitOrder = 1
				end
				else
				begin
					set @IsWMSKitOrder = 0
				end
				-----------------------------����ȡ�����������·��-----------------------------
				
				if not exists(select top 1 1 from #tempSeqFlow)
				begin
					--��¼��־
					set @Msg = N'û����������·�߻�����·��û����Ч�����򵥼������'
					insert into #temp_LOG_GenSequenceOrder(SeqGroup, Lvl, Msg) values(@SeqGroup, 0, @Msg)
					
					break
				end
				else
				begin
					if (@PrevOrderNo is null)
					begin
						set @Msg = N'û�������ϴν�ת����������ϵͳ�Զ�����Ϊ0'
						insert into #temp_LOG_GenSequenceOrder(SeqGroup, Lvl, Msg) values(@SeqGroup, 1, @Msg)
						set @PrevSeq = 0
						set @PrevSubSeq = 0
					end
					else
					begin
						--�������µ�˳��Ϊ�˷�ֹ��ͣ/�ָ���ԭ�������仯
						select @PrevSeq = Seq, @PrevSubSeq = SubSeq from ORD_OrderSeq where OrderNo = @PrevOrderNo
						
						--��¼��־
						set @Msg = N'�ϴν�תį̃����������' + @PrevOrderNo + N'����' + CONVERT(varchar, @PrevSeq) + N'�ӳ���' + CONVERT(varchar, @PrevSubSeq)
						insert into #temp_LOG_GenSequenceOrder(SeqGroup, Lvl, Msg) values(@SeqGroup, 0, @Msg)
					end
					
					--��ȡ��Ҫ��ת�ĳ���
					--���ܰ������ضϳ������һ��������û���������Զ���ᷢ����ת�����Ῠס����ĳ�Ҳ���ܽ�ת������
					truncate table #tempTargetTraceCode
					insert into #tempTargetTraceCode(RowNo, OrderNo, TraceCode, Seq, SubSeq)
					select ROW_NUMBER() over(order by seq.Seq, seq.SubSeq) as RowNo, seq.OrderNo, seq.TraceCode, seq.Seq, seq.SubSeq 
					from ORD_OrderSeq as seq inner join ORD_OrderMstr_4 as mstr on seq.OrderNo = mstr.OrderNo
					where seq.ProdLine = @ProdLine 
					and (seq.Seq > @PrevSeq or (seq.Seq = @PrevSeq and seq.SubSeq > @PrevSubSeq)) 
					and mstr.PauseStatus in (0, 1)
					
					if @IsWMSKitOrder = 0
					begin  --���������
						-----------------------------��ѭ����װ��λ���뻺�����-----------------------------
						truncate table #tempAssOpRef
						if (charindex(@SplitSymbol1, @AssOpRef) <> 0)
							begin
							while(charindex(@SplitSymbol1, @AssOpRef) <> 0)
							begin
								insert #tempAssOpRef(AssOpRef) values (substring(@AssOpRef, 1, charindex(@SplitSymbol1, @AssOpRef) - 1))
								set @AssOpRef = stuff(@AssOpRef, 1, charindex(@SplitSymbol1, @AssOpRef), ' ')
							end
						end
						else if (charindex(@SplitSymbol2, @AssOpRef) <> 0)
						begin
							while(charindex(@SplitSymbol2, @AssOpRef) <> 0)
							begin
								insert #tempAssOpRef(AssOpRef) values (substring(@AssOpRef, 1, charindex(@SplitSymbol2, @AssOpRef) - 1))
								set @AssOpRef = stuff(@AssOpRef, 1, charindex(@SplitSymbol2, @AssOpRef), ' ')
							end
						end
						
						if (ISNULL(@AssOpRef, '') <> '')
						begin
							insert #tempAssOpRef(AssOpRef) values (@AssOpRef)
						end
						-----------------------------��ѭ����װ��λ���뻺�����-----------------------------
					
						-----------------------------����ȡ����·����ϸ�������˶೧�̹��������-----------------------------
						
						-------------------����ȡ��������·����ϸ-----------------------
						truncate table #tempFlowDet
						insert into #tempFlowDet(Flow, Item, ItemDesc, RefItemCode, Uom, UC, MinUC,
						UCDesc, Container, ContainerDesc, MrpTotal, MrpTotalAdj, MrpWeight, LocFrom, LocTo)
						select fdet.Flow as Flow, fdet.Item, i.Desc1 as ItemDesc, i.RefCode as RefItemCode, fdet.Uom, fdet.UC, fdet.MinUC,
						fdet.UCDesc, fdet.Container, fdet.ContainerDesc, fdet.MrpTotal, fdet.MrpTotalAdj, fdet.MrpWeight, mstr.LocFrom, mstr.LocTo
						from SCM_FlowDet as fdet
						inner join SCM_FlowMstr as mstr on fdet.Flow = mstr.Code
						inner join SCM_FlowStrategy as stra on stra.Flow = fdet.Flow
						inner join MD_Item as i on fdet.Item = i.Code
						where stra.Flow in (select Flow from #tempSeqFlow) and stra.Strategy = 4 --and fdet.IsActive = 1
						-------------------����ȡ��������·����ϸ-----------------------
						
						
						-------------------����ȡ����·����ϸ-----------------------
						insert into #tempFlowDet(Flow, Item, ItemDesc, RefItemCode, Uom, UC, MinUC,
						UCDesc, Container, ContainerDesc, MrpTotal, MrpTotalAdj, MrpWeight, LocFrom, LocTo)
						select mstr.Code as Flow, rDet.Item, i.Desc1 as ItemDesc, i.RefCode as RefItemCode, rDet.Uom, rDet.UC, rDet.MinUC, 
						rDet.UCDesc, rDet.Container, rDet.ContainerDesc, rDet.MrpTotal, rDet.MrpTotalAdj, rDet.MrpWeight, mstr.LocFrom, mstr.LocTo
						from SCM_FlowMstr as mstr
						inner join SCM_FlowStrategy as stra on stra.Flow = mstr.Code
						inner join SCM_FlowDet as rDet on mstr.RefFlow = rDet.Flow
						inner join MD_Item as i on rDet.Item = i.Code
						where stra.Flow in (select Flow from #tempSeqFlow) and stra.Strategy = 4 --and rDet.IsActive = 1
						and not Exists(select top 1 1 from #tempFlowDet as tDet where tdet.Item = rdet.Item)
						-------------------����ȡ����·����ϸ-----------------------
						
						
						-------------------���������ѡ��๩Ӧ�̹�����·��-----------------------
						if (select COUNT(1) from #tempSeqFlow) > 1
						begin
							delete det
							from #tempFlowDet as det 
							inner join SCM_FlowMstr as mstr on det.Flow = mstr.Code
							inner join (select det.FlowDetRowId, det.Item, lq.Supplier , det.LocTo
										from #tempFlowDet as det 
										inner join SCM_FlowMstr as mstr on det.Flow = mstr.Code
										inner join LE_QuotaSnapShot as lq on det.Item = lq.Item and mstr.PartyFrom = lq.Supplier
										where mstr.[Type] = 1) as cDet --��ǰ�����Ĳɹ�·����ϸ
										on det.Item = cDet.Item and det.FlowDetRowId <> cDet.FlowDetRowId and mstr.PartyFrom <> cDet.Supplier --and det.LocTo = cDet.LocTo 
							where mstr.[Type] = 1   --ֻ���˵��ɹ���·��
						end
						-------------------���������ѡ��๩Ӧ�̹�����·��-----------------------
						
						
						-------------------�����������-----------------------
						truncate table #tempMultiSupplierGroup
						insert into #tempMultiSupplierGroup(Item)
						select Item from #tempFlowDet
						group by Item having COUNT(*) > 1 
						
						insert into #tempMultiSupplierItem(FlowDetRowId, Flow, Item, MSGRowId, MrpTotal, MrpTotalAdj, MrpWeight)
						select det.FlowDetRowId, det.Flow, det.Item, msg.RowId, det.MrpTotal, det.MrpTotalAdj, det.MrpWeight 
						from #tempFlowDet as det inner join #tempMultiSupplierGroup as msg on det.Item = msg.Item
						-------------------�����������-----------------------
						
						
						-------------------�������Ŀ�Ŀ�λ��ͬ��·�߶�û�����ù����������������װ����ѭ����-----------------------
						update tmp set MrpWeight = (CASE WHEN det.UC = 0 THEN 1 ELSE det.UC END)
						from #tempMultiSupplierItem as tmp
						inner join #tempFlowDet as det on det.FlowDetRowId = tmp.FlowDetRowId
						where MSGRowId in (select MSGRowId from #tempMultiSupplierItem group by MSGRowId having SUM(MrpWeight) = 0)
						-------------------�������Ŀ�Ŀ�λ��ͬ��·�߶�û�����ù����������������װ����ѭ����-----------------------
						
						
						-------------------�������Ŀ�Ŀ�λ��ͬ��·��û�����ù���������������Щ·����ϸ-----------------------						
						delete #tempFlowDet where FlowDetRowId in (select FlowDetRowId from #tempMultiSupplierItem where MrpWeight = 0)
						delete #tempMultiSupplierItem where FlowDetRowId in (select FlowDetRowId from #tempMultiSupplierItem where MrpWeight = 0)
						------------------�������Ŀ�Ŀ�λ��ͬ��·��û�����ù���������������Щ·����ϸ-----------------------
						
						
						-------------------�����㹩������������-----------------------
						update #tempMultiSupplierItem set DeliveryCount = (ISNULL(MrpTotal, 0) + ISNULL(MrpTotalAdj, 0)) / MrpWeight, DeliveryBalance = (ISNULL(MrpTotal, 0) + ISNULL(MrpTotalAdj, 0)) % MrpWeight
						-------------------�����㹩������������-----------------------
						
						
						-------------------�����ݹ���������ѭ����ѡȡһ��·����ϸ����-----------------------
						truncate table #tempSortedMultiSupplierItem
						insert into #tempSortedMultiSupplierItem(GID, FlowDetRowId, Flow)
						select ROW_NUMBER() over(partition by MSGRowId order by DeliveryCount asc, MrpWeight desc, DeliveryBalance desc) as GID, FlowDetRowId, Flow 
						from #tempMultiSupplierItem
						
						insert into LOG_SnapshotFlowDet4LeanEngine(BatchNo, Flow, Lvl, ErrorId, Item, Msg)
						select distinct @BatchNo, Flow, 1, 23, Item, N'������' + @SeqGroup + N'�����ظ������' + Item + N'����������û��ά����ϵͳ�Զ�ɾ��·��' + Flow
						from #tempFlowDet where FlowDetRowId in (select FlowDetRowId from #tempSortedMultiSupplierItem where GID <> 1)
						
						delete #tempFlowDet where FlowDetRowId in (select FlowDetRowId from #tempSortedMultiSupplierItem where GID <> 1)
						delete #tempMultiSupplierItem where FlowDetRowId in (select FlowDetRowId from #tempSortedMultiSupplierItem where GID <> 1)
						-------------------�����ݹ���������ѭ����ѡȡһ��·����ϸ����-----------------------
						
						
						select @Msg = N'����·����ϸ����' + CONVERT(varchar, COUNT(1)) from #tempFlowDet
						insert into #temp_LOG_GenSequenceOrder(SeqGroup, Lvl, Msg) values(@SeqGroup, 0, @Msg)
					
					
						-----------------------------����ȡ����·����ϸ�������˶೧�̹��������-----------------------------
									
						--����������Bom
						truncate table #tempBomCPTime
						if exists(select top 1 1 from #tempAssOpRef)
						begin
							insert into #tempBomCPTime(OrderNo, TraceCode, Seq, SubSeq, CPTime, Flow, Item, ItemDesc, RefItemCode, Uom, UC, MinUC, UCDesc, Container, ContainerDesc, OpRef, OrderQty, Location, BomId, ManufactureParty, LocFrom, LocTo, ZOPWZ, ZOPID, ZOPDS)
							select bom.OrderNo, seq.TraceCode, seq.Seq, seq.SubSeq, cp.CPTime, CASE WHEN flow.Flow is not null THEN flow.Flow ELSE fdet.Flow END as Flow, bom.Item, fdet.ItemDesc, fdet.RefItemCode, fdet.Uom, fdet.UC, fdet.MinUC, fdet.UCDesc, fdet.Container, fdet.ContainerDesc, bom.OpRef, bom.OrderQty, bom.Location, bom.Id, bom.ManufactureParty, fdet.LocFrom, fdet.LocTo, bom.ZOPWZ, bom.ZOPID, bom.ZOPDS
							from ORD_OrderBomDet as bom
							inner join ORD_OrderMstr_4 as mstr on bom.OrderNo = mstr.OrderNo
							inner join #tempTargetTraceCode as seq on seq.TraceCode = mstr.TraceCode  --����Van��������������bom��������������
							inner join #tempAssOpRef as opRef on bom.OpRef = opRef.AssOpRef
							inner join #tempFlowDet as fdet on fdet.Item = bom.Item
							inner join SCM_FlowStrategy as stra on stra.Flow = fdet.Flow
							left join LE_OrderBomCPTimeSnapshot as cp on bom.Id = cp.BomId
							left join #tempSeqFlow as flow on flow.PartyFrom = bom.ManufactureParty  --ָ����Ӧ��ȡPartyFrom��ָ����Ӧ����ͬ��·�ߴ���
							where stra.SeqGroup = @SeqGroup and stra.Strategy = 4
						end
						else
						begin
							insert into #tempBomCPTime(OrderNo, TraceCode, Seq, SubSeq, CPTime, Flow, Item, ItemDesc, RefItemCode, Uom, UC, MinUC, UCDesc, Container, ContainerDesc, OpRef, OrderQty, Location, BomId, ManufactureParty, LocFrom, LocTo, ZOPWZ, ZOPID, ZOPDS)
							select bom.OrderNo, seq.TraceCode, seq.Seq, seq.SubSeq, cp.CPTime, CASE WHEN flow.Flow is not null THEN flow.Flow ELSE fdet.Flow END as Flow, bom.Item, fdet.ItemDesc, fdet.RefItemCode, fdet.Uom, fdet.UC, fdet.MinUC, fdet.UCDesc, fdet.Container, fdet.ContainerDesc, bom.OpRef, bom.OrderQty, bom.Location, bom.Id, bom.ManufactureParty, fdet.LocFrom, fdet.LocTo, bom.ZOPWZ, bom.ZOPID, bom.ZOPDS
							from ORD_OrderBomDet as bom
							inner join ORD_OrderMstr_4 as mstr on bom.OrderNo = mstr.OrderNo
							inner join #tempTargetTraceCode as seq on seq.TraceCode = mstr.TraceCode   --����Van��������������bom��������������
							inner join #tempFlowDet as fdet on fdet.Item = bom.Item
							inner join SCM_FlowStrategy as stra on stra.Flow = fdet.Flow
							left join LE_OrderBomCPTimeSnapshot as cp on bom.Id = cp.BomId
							left join #tempSeqFlow as flow on flow.PartyFrom = bom.ManufactureParty  --ָ����Ӧ��ȡPartyFrom��ָ����Ӧ����ͬ��·�ߴ���
							where stra.SeqGroup = @SeqGroup and stra.Strategy = 4
						end
					end
					else
					begin  --�����ͱ����������������������
						if exists(select top 1 1 from (select ROW_NUMBER() over(order by Flow) as RowNm from #tempSeqFlow) as rn where rn.RowNm > 1)
						begin
							--��¼��־
							set @Msg = N'�ҵ����������ͱ�����������·��'
							insert into #temp_LOG_GenSequenceOrder(SeqGroup, Lvl, Msg) values(@SeqGroup, 2, @Msg)
						end
						else
						begin
							declare @WMSKitOrderSeqFlow varchar(50) = null
							select top 1 @WMSKitOrderSeqFlow = Flow from #tempSeqFlow
						
							truncate table #tempWMSKitWorkCenter
							if exists(select top 1 1 from CUST_ProductLineMap as map
									 inner join #tempSeqFlow as transFlow on map.TransFlow = transFlow.Flow)
							begin   --������
								insert into #tempWMSKitWorkCenter(Flow, WorkCenter) 
								select map.TransFlow, pwc.WorkCenter from CUST_ProductLineMap as map
								inner join #tempSeqFlow as transFlow on map.TransFlow = transFlow.Flow
								inner join PRD_ProdLineWorkCenter as pwc on map.TransFlow = pwc.Flow
							end
							else if exists(select top 1 1 from CUST_ProductLineMap as map
									 inner join #tempSeqFlow as saddleFlow on map.SaddleFlow = saddleFlow.Flow)
							begin	--����
								insert into #tempWMSKitWorkCenter(Flow, WorkCenter)
								select map.SaddleFlow, pwc.WorkCenter from CUST_ProductLineMap as map
								inner join #tempSeqFlow as saddleFlow on map.SaddleFlow = saddleFlow.Flow
								inner join PRD_ProdLineWorkCenter as pwc on map.SaddleFlow = pwc.Flow
							end
						
							--����������Bom
							truncate table #tempBomCPTime
							insert into #tempBomCPTime(OrderNo, TraceCode, Seq, SubSeq, CPTime, Flow, Item, ItemDesc, RefItemCode, Uom, UC, MinUC, UCDesc, Container, ContainerDesc, OpRef, OrderQty, Location, BomId, ManufactureParty, LocFrom, LocTo, ZOPWZ, ZOPID, ZOPDS)
							select bom.OrderNo, seq.TraceCode, seq.Seq, seq.SubSeq, cp.CPTime, @WMSKitOrderSeqFlow as Flow, bom.Item, i.Desc1 as ItemDesc, i.RefCode as RefItemCode, i.Uom, i.UC, i.MinUC, null, i.Container, i.ContainerDesc, bom.OpRef, bom.OrderQty, bom.Location, bom.Id, bom.ManufactureParty, mstr.LocFrom, mstr.LocTo, bom.ZOPWZ, bom.ZOPID, bom.ZOPDS
							from ORD_OrderBomDet as bom
							inner join ORD_OrderMstr_4 as ord on bom.OrderNo = ord.OrderNo
							inner join #tempTargetTraceCode as seq on seq.TraceCode = ord.TraceCode    --����Van��������������bom��������������
							inner join #tempWMSKitWorkCenter as pwc on bom.WorkCenter = pwc.WorkCenter
							inner join MD_Item as i on bom.Item = i.Code
							inner join SCM_FlowMstr as mstr on mstr.Code = pwc.Flow
							left join LE_OrderBomCPTimeSnapshot as cp on bom.Id = cp.BomId
						end
					end

					if not exists(select top 1 1 from #tempBomCPTime)
					begin
						--��¼��־
						set @Msg = N'û���ҵ����ν�ת��̨�������򵥼������ @PrevSeq:'  + convert(nvarchar, ISNULL(@PrevSeq, 1)) + N' @PrevSubSeq:' + convert(nvarchar, ISNULL(@PrevSubSeq, 2))
						insert into #temp_LOG_GenSequenceOrder(SeqGroup, Lvl, Msg) values(@SeqGroup, 0, @Msg)
						
						break
					end
					else
					begin
						select @Msg = N'�ҵ����������ϸ����' + CONVERT(varchar, COUNT(1)) from #tempBomCPTime
						insert into #temp_LOG_GenSequenceOrder(SeqGroup, Lvl, Msg) values(@SeqGroup, 0, @Msg)
						
						-----------------------------�����򵥽�ת-----------------------------
						declare @FirstOrderNo varchar(50) = null
						declare @FirstTraceCode varchar(50) = null
						declare @FirstSeq bigint = null
						declare @FirstSubSeq int = null
						declare @WindowTime datetime = null
						declare @LastOrderNo varchar(50) = null  --������������
						declare @LastTraceCode varchar(50) = null  --������Van��
						declare @LastSeq bigint = null   --������˳���
						declare @LastSubSeq int = null	 --�����������
						
						--��ȡ��̨��������
						select top 1 @FirstOrderNo = OrderNo, @FirstSeq = Seq, @FirstSubSeq = SubSeq, @FirstTraceCode = TraceCode
						from #tempTargetTraceCode order by Seq, SubSeq											
						
						--��ȡ����ʱ��
						set @WindowTime = null
						select top 1 @WindowTime = CPTime
						from #tempBomCPTime where CPTime is not null order by CPTime
						
						--��¼��־
						set @Msg = N'Ԥ�ƴ���ʱ��Ϊ' + convert(varchar, @WindowTime, 120)
						insert into #temp_LOG_GenSequenceOrder(SeqGroup, Lvl, Msg) values(@SeqGroup, 0, @Msg)
					
						if @WindowTime is null
						begin
							--��¼��־
							set @Msg = N'û���ҵ����ν�ת�Ĵ���ʱ�䣬���򵥼������ @PrevSeq:'  + convert(nvarchar, ISNULL(@PrevSeq, 1)) + N' @PrevSubSeq:' + convert(nvarchar, ISNULL(@PrevSubSeq, 2))
							insert into #temp_LOG_GenSequenceOrder(SeqGroup, Lvl, Msg) values(@SeqGroup, 0, @Msg)
							break
						end
						else
						begin
							--��¼��־
							set @Msg = N'���ν�ת��̨��Van��' + @FirstTraceCode + N'��������' + @FirstOrderNo + N'����' + CONVERT(varchar, @FirstSeq) + N'�ӳ���' + CONVERT(varchar, @FirstSubSeq)
							insert into #temp_LOG_GenSequenceOrder(SeqGroup, Lvl, Msg) values(@SeqGroup, 0, @Msg)
						
							declare @WinTimeDiff int = null  --��������󵽻���ǰ�ڣ��룩
							declare @LeadTime int = null  --�����������ǰ�ڣ��룩
							declare @EMLeadTime int = null  --��������������ǰ�ڣ��룩
							declare @StartTime datetime = null   --Ԥ�Ʒ���ʱ��
							declare @EMStartTime datetime = null   --Ԥ�ƽ�������ʱ��
							declare @IsUrgent bit = 0
							
							--��ȡ��ǰ��
							select @WinTimeDiff = -MAX(WinTimeDiff) * 60 * 60, @LeadTime = -MAX(LeadTime) * 60 * 60, @EMLeadTime = -MAX(EMLeadTime) * 60 * 60 from #tempSeqFlow
							
							--���㴰��ʱ��
							exec USP_Busi_SubtractWorkingDate @WindowTime, @WinTimeDiff, @ProdLine, @ProdLineRegion, @WindowTime output
							
							--����Ԥ�Ʒ���ʱ��
							exec USP_Busi_SubtractWorkingDate @WindowTime, @LeadTime, @ProdLine, @ProdLineRegion, @StartTime output
						
							if @StartTime < @DateTimeNow
							begin
								if @EMLeadTime > 0
								begin
									--��ǰ�ڲ���������������ǰ��
									exec USP_Busi_SubtractWorkingDate @WindowTime, @EMLeadTime, @ProdLine, @ProdLineRegion, @EMStartTime output
									
									if @EMStartTime < @DateTimeNow
									begin
										--����Ϊ������
										set @IsUrgent = 1
								
										--������ǰ��Ҳ�������㣬���ÿ�ʼʱ��Ϊ��ǰʱ�䣬����ʱ��Ϊ��ǰʱ��+������ǰ��
										set @StartTime = @DateTimeNow
										set @EMLeadTime = 0 - @EMLeadTime
										exec USP_Busi_AddWorkingDate @StartTime, @EMLeadTime, @ProdLine, @ProdLineRegion, @WindowTime output
									end
								end
								else
								begin
									--��¼��־
									set @Msg = N'û�����ý�����ǰ��'
									insert into #temp_LOG_GenSequenceOrder(SeqGroup, Lvl, Msg) values(@SeqGroup, 2, @Msg)									
								end
							end
							
							--��¼��־
							set @Msg = N'Ԥ�ƴ���ʱ��Ϊ' + convert(varchar, @WindowTime, 120) + N'��Ԥ�Ʒ���ʱ��Ϊ' + convert(varchar, @StartTime, 120)
							insert into #temp_LOG_GenSequenceOrder(SeqGroup, Lvl, Msg) values(@SeqGroup, 0, @Msg)
							
							if (@StartTime <= @DateTimeNow)
							begin   --��̨�������������ʱ�� - ��ǰ���Ƿ���ڵ�ǰʱ��
								set @trancount = @@trancount
								
								begin try
									if @trancount = 0
									begin
										begin tran
									end
								
									--��¼��־
									set @Msg = N'��ǰʱ��' + convert(varchar, @DateTimeNow, 120) + N'���ڵ��ڷ���ʱ�䣬�������򵥿�ʼ'
									insert into #temp_LOG_GenSequenceOrder(SeqGroup, Lvl, Msg) values(@SeqGroup, 0, @Msg)
									
									if (@PrevDeliveryDate is null or @WindowTime > DateADD(DAY, 1, @PrevDeliveryDate))
									begin
										set @PrevDeliveryDate = CONVERT(datetime, CONVERT(varchar(10), @WindowTime, 120))
										set @PrevDeliveryCount = 0
									end
									set @PrevDeliveryCount = @PrevDeliveryCount + 1
									
									--���ҽ�������
									select top 1 @LastOrderNo = seq.OrderNo, @LastSeq = seq.Seq, @LastSubSeq = seq.SubSeq, @LastTraceCode = seq.TraceCode
                                    from #tempTargetTraceCode as seq where seq.RowNo <= @SeqBatch
                                    order by seq.Seq desc, seq.SubSeq desc
                                    
                                    --ɾ������Bom
                                    delete from #tempBomCPTime where Seq > @LastSeq or (Seq = @LastSeq and SubSeq > @LastSubSeq)
								
									--�Ѿ����ɵ���������ǣ�����JITҲ��������
									update LE_OrderBomCPTimeSnapshot set IsCreateOrder = 1
									where BomId in (select BomId from #tempBomCPTime)
									
									--�Ѿ����ɵ���������ǣ�����JITҲ��������
									update ORD_OrderBomDet set IsCreateOrder = 1, IsCreateSeq = 1, LastModifyDate = @DateTimeNow, LastModifyUser = @CreateUserId, LastModifyUserNm = @CreateUserNm, [Version] = [Version] + 1
									where Id in (select BomId from #tempBomCPTime)
									
									--����������ʱ��ȫ������Ϊ��С������ʱ��
									update bom set CPTime = mBom.MINCPTime
									from #tempBomCPTime as bom
									inner join (select OrderNo, MIN(CPTime) as MINCPTime from #tempBomCPTime where CPTime is not null group by OrderNo) as mBom on bom.OrderNo = mBom.OrderNo
									
									--��¼��־
									set @Msg = N'���ν�ת������Van��' + @LastTraceCode + N'��������' + @LastOrderNo + N'����' + CONVERT(varchar, @LastSeq) + N'�ӳ���' + CONVERT(varchar, @LastSubSeq)
									insert into #temp_LOG_GenSequenceOrder(SeqGroup, Lvl, Msg) values(@SeqGroup, 0, @Msg)
									
									
									-----------------------------������������-----------------------------
									update SCM_SeqGroup set PrevOrderNo = @LastOrderNo, PrevTraceCode = @LastTraceCode, PrevSeq = @LastSeq, PrevSubSeq = @LastSubSeq,
									PrevDeliveryDate = @PrevDeliveryDate, PrevDeliveryCount = @PrevDeliveryCount, [Version] = [Version] + 1
									where Code = @SeqGroup and [Version] = @Version
									
									if @@ROWCOUNT = 0
									begin
										RAISERROR(N'�������Ѿ������¡�', 16, 1)
									end
									-----------------------------������������-----------------------------
								
								
									-----------------------------��ѭ����������-----------------------------													
									declare @SeqFlowRowId int = null
									declare @MaxSeqFlowRowId int = null
									
									select @SeqFlowRowId = MIN(RowId), @MaxSeqFlowRowId = MAX(RowId) from #tempSeqFlow
									
									--����Ѿ����������򵥵�VAN�ŵ���ʱ��
									truncate table #tempSeqOrderTrace
									while (@SeqFlowRowId <= @MaxSeqFlowRowId)
									begin
										declare @SeqOrderNo varchar(50) = null  --���򵥺�
										declare @SeqFlow varchar(50) = null  --����·��
										declare @SeqFlowType tinyint = null  --����·������
										declare @SeqFlowPartyFrom varchar(50) = null  --����·����Դ����
										declare @SeqFlowPartyTo varchar(50) = null  --����·��Ŀ������
										declare @SeqFlowLocFrom varchar(50) = null  --����·����Դ��λ
										declare @SeqFlowLocTo varchar(50) = null  --����·��Ŀ�Ŀ�λ
										declare @SeqIsCreatePickList bit = null  --�Ƿ�Ҫ�����Ƚ��ȳ�ָ����Ӧ��
										
										select @SeqFlow = Flow, @SeqFlowType = [Type], @SeqFlowPartyFrom = PartyFrom,
										@SeqFlowPartyTo = PartyTo, @SeqFlowLocFrom = LocFrom, @SeqFlowLocTo = LocTo,
										@SeqIsCreatePickList = IsCreatePickList
										from #tempSeqFlow where RowId = @SeqFlowRowId
										
										--��¼��־
										set @Msg = N'����·��' + @SeqFlow + N'��ʼ��������'
										insert into #temp_LOG_GenSequenceOrder(SeqGroup, Flow, Lvl, Msg) values(@SeqGroup, @SeqFlow, 0, @Msg)
										
										-----------------------------����������ͷ-----------------------------
										exec USP_GetDocNo_ORD @SeqFlow, 4, @SeqFlowType, 0, 0, 0, @SeqFlowPartyFrom, @SeqFlowPartyTo, @SeqFlowLocFrom, @SeqFlowLocTo, null, 0, @SeqOrderNo output
										
										if @SeqFlowType = 1
										begin
											insert into ORD_OrderMstr_1 (
											OrderNo,              --���򵥺�
											Flow,                 --����·��
											TraceCode,			  --�˴�
											OrderStrategy,        --���ԣ�4
											RefOrderNo,			  --�������̨Van��
											ExtOrderNo,			  --�������̨Van��
											[Type],               --���ͣ�1 �ɹ�
											SubType,              --�����ͣ�0����
											QualityType,          --����״̬��0��Ʒ
											StartTime,            --��ʼʱ��
											WindowTime,           --����ʱ��
											PauseSeq,             --��ͣ����0
											IsQuick,              --�Ƿ���٣�0
											[Priority],           --���ȼ���0
											[Status],             --״̬��1�ͷ�
											PartyFrom,            --�������
											PartyFromNm,            --��������
											PartyTo,              --�������
											PartyToNm,              --��������
											--LocFrom,              --ԭ���Ͽ�λ
											--LocFromNm,			  --ԭ���Ͽ�λ
											LocTo,                --��Ʒ��λ
											LocToNm,              --��Ʒ��λ
											IsInspect,            --���߼��飬0
											BillAddr,			  --��Ʊ��ַ
											Dock,				  --����
											IsAutoRelease,        --�Զ��ͷţ�0
											IsAutoStart,          --�Զ����ߣ�0
											IsAutoShip,           --�Զ�������0
											IsAutoReceive,        --�Զ��ջ���0
											IsAutoBill,           --�Զ��˵���0
											IsManualCreateDet,    --�ֹ�������ϸ��0
											IsListPrice,          --��ʾ�۸񵥣�0
											IsPrintOrder,         --��ӡ���򵥣�0
											IsOrderPrinted,       --�����Ѵ�ӡ��0
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
											RecTemplate,		  --�ջ���ģ��
											OrderTemplate,		  --����ģ��
											AsnTemplate,		  --�ͻ���ģ��
											HuTemplate,			  --����ģ��
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
											FlowDesc,			  --·������
											ProdLineType,         --����������
											PauseStatus,          --��ͣ״̬��0
											SeqGroup,			  --������
											ShipFromContact		  --�˴�(������)
											)
											select 
											@SeqOrderNo,          --���򵥺�
											mstr.Code,                 --����·��
											convert(varchar(2), DATEPART(DAY, @PrevDeliveryDate)) + '-' + convert(varchar(3), @PrevDeliveryCount),			  --�˴�
											4,					  --���ԣ�4
											@PrevTraceCode,		  --�������̨Van��
											@LastTraceCode,		  --�������̨Van��
											@SeqFlowType,					  --���ͣ�1 �ɹ�
											0,					  --�����ͣ�0����
											0,					  --����״̬��0��Ʒ
											@StartTime,           --��ʼʱ��
											@WindowTime,          --����ʱ��
											0,					  --��ͣ����0
											0,					  --�Ƿ���٣�0
											@IsUrgent,			  --���ȼ���0
											1,					  --״̬��1�ͷ�
											mstr.PartyFrom,            --�������
											pf.Name,				--��������
											mstr.PartyTo,              --�������
											pt.Name,				--��������
											--mstr.LocFrom,              --ԭ���Ͽ�λ
											--lf.Name,              --ԭ���Ͽ�λ
											mstr.LocTo,                --��Ʒ��λ
											lt.Name,              --��Ʒ��λ
											mstr.IsInspect,            --���߼��飬0
											mstr.BillAddr,			  --��Ʊ��ַ
											mstr.Dock,				  --����
											mstr.IsAutoRelease,        --�Զ��ͷţ�0
											mstr.IsAutoStart,          --�Զ����ߣ�0
											mstr.IsAutoShip,           --�Զ�������0
											mstr.IsAutoReceive,        --�Զ��ջ���0
											mstr.IsAutoBill,           --�Զ��˵���0
											mstr.IsManualCreateDet,    --�ֹ�������ϸ��0
											mstr.IsListPrice,          --��ʾ�۸񵥣�0
											mstr.IsPrintOrder,         --��ӡ���򵥣�0
											0,					  --�����Ѵ�ӡ��0
											mstr.IsPrintAsn,           --��ӡASN��0
											mstr.IsPrintRcpt,          --��ӡ�ջ�����0
											mstr.IsShipExceed,         --��������0
											mstr.IsRecExceed,          --�����գ�0
											mstr.IsOrderFulfillUC,     --����װ�µ���0
											mstr.IsShipFulfillUC,      --����װ������0
											mstr.IsRecFulfillUC,       --����װ�ջ���0
											mstr.IsShipScanHu,         --����ɨ�����룬0
											mstr.IsRecScanHu,          --�ջ�ɨ�����룬0
											mstr.IsCreatePL,           --�����������0
											0,					  --������Ѵ�����0
											mstr.IsShipFifo,           --�����Ƚ��ȳ���0
											mstr.IsRecFifo,            --�ջ��Ƚ��ȳ���0
											mstr.IsShipByOrder,        --��������������0
											0,					  --���ڶ�����0
											mstr.IsAsnUniqueRec,       --ASNһ�����ջ���0
											mstr.RecGapTo,             --�ջ����촦��0
											mstr.RecTemplate,		  --�ջ���ģ��
											mstr.OrderTemplate,		  --����ģ��
											mstr.AsnTemplate,		  --�ͻ���ģ��
											mstr.HuTemplate,			  --����ģ��
											mstr.BillTerm,             --���㷽ʽ��0
											mstr.CreateHuOpt,          --��������ѡ�0
											0,					  --���¼���۸�ѡ�0
											@CreateUserId,        --�����û�
											@CreateUserNm,        --�����û�����
											@DateTimeNow,         --��������
											@CreateUserId,        --����޸��û�
											@CreateUserNm,        --����޸��û�����
											@DateTimeNow,         --����޸�����
											@CreateUserId,        --�ͷ��û�
											@CreateUserNm,        --�ͷ��û�����
											@DateTimeNow,         --�ͷ�����
											1,					  --�汾��1
											mstr.Desc1,				  --·������
											mstr.ProdLineType,         --����������
											0,					  --��ͣ״̬��0
											@SeqGroup,			  --������
											convert(varchar(10), @PrevDeliveryDate, 112) + '-' + convert(varchar(3), @PrevDeliveryCount)			  --�˴�(������)
											from SCM_FlowMstr as mstr 
											inner join MD_Party as pf on mstr.PartyFrom = pf.Code
											inner join MD_Party as pt on mstr.PartyTo = pt.Code
											--left join MD_Location as lf on mstr.LocFrom = lf.Code
											left join MD_Location as lt on mstr.LocTo = lt.Code
											where mstr.Code = @SeqFlow
										end
										else if @SeqFlowType = 2
										begin 
											insert into ORD_OrderMstr_2 (
											OrderNo,              --���򵥺�
											Flow,                 --����·��
											TraceCode,			  --�˴�
											OrderStrategy,        --���ԣ�4
											RefOrderNo,			  --�������̨Van��
											ExtOrderNo,			  --�������̨Van��
											[Type],               --���ͣ�2 �ƿ�
											SubType,              --�����ͣ�0����
											QualityType,          --����״̬��0��Ʒ
											StartTime,            --��ʼʱ��
											WindowTime,           --����ʱ��
											PauseSeq,             --��ͣ����0
											IsQuick,              --�Ƿ���٣�0
											[Priority],           --���ȼ���0
											[Status],             --״̬��1�ͷ�
											PartyFrom,            --�������
											PartyFromNm,            --��������
											PartyTo,              --�������
											PartyToNm,              --��������
											LocFrom,              --ԭ���Ͽ�λ
											LocFromNm,              --ԭ���Ͽ�λ
											LocTo,                --��Ʒ��λ
											LocToNm,                --��Ʒ��λ
											IsInspect,            --���߼��飬0
											Dock,				  --����
											IsAutoRelease,        --�Զ��ͷţ�0
											IsAutoStart,          --�Զ����ߣ�0
											IsAutoShip,           --�Զ�������0
											IsAutoReceive,        --�Զ��ջ���0
											IsAutoBill,           --�Զ��˵���0
											IsManualCreateDet,    --�ֹ�������ϸ��0
											IsListPrice,          --��ʾ�۸񵥣�0
											IsPrintOrder,         --��ӡ���򵥣�0
											IsOrderPrinted,       --�����Ѵ�ӡ��0
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
											RecTemplate,		  --�ջ���ģ��
											OrderTemplate,		  --����ģ��
											AsnTemplate,		  --�ͻ���ģ��
											HuTemplate,			  --����ģ��
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
											FlowDesc,			  --·������
											ProdLineType,         --����������
											PauseStatus,          --��ͣ״̬��0
											SeqGroup,			  --������
											ShipFromContact		  --�˴�(������)
											)
											select 
											@SeqOrderNo,          --���򵥺�
											mstr.Code,                 --����·��
											convert(varchar(2), DATEPART(DAY, @PrevDeliveryDate)) + '-' + convert(varchar(3), @PrevDeliveryCount),			  --�˴�
											4,					  --���ԣ�4
											@PrevTraceCode,		  --�������̨Van��
											@LastTraceCode,		  --�������̨Van��
											@SeqFlowType,		  --���ͣ�1 �ƿ�
											0,					  --�����ͣ�0����
											0,					  --����״̬��0��Ʒ
											@StartTime,           --��ʼʱ��
											@WindowTime,          --����ʱ��
											0,					  --��ͣ����0
											0,					  --�Ƿ���٣�0
											@IsUrgent,			  --���ȼ���0
											1,					  --״̬��1�ͷ�
											mstr.PartyFrom,            --�������
											pf.Name,				--��������
											mstr.PartyTo,              --�������
											pt.Name,				--��������
											mstr.LocFrom,              --ԭ���Ͽ�λ
											lf.Name,              --ԭ���Ͽ�λ
											mstr.LocTo,                --��Ʒ��λ
											lt.Name,                --��Ʒ��λ
											mstr.IsInspect,            --���߼��飬0
											mstr.Dock,				  --����
											mstr.IsAutoRelease,        --�Զ��ͷţ�0
											mstr.IsAutoStart,          --�Զ����ߣ�0
											mstr.IsAutoShip,           --�Զ�������0
											mstr.IsAutoReceive,        --�Զ��ջ���0
											mstr.IsAutoBill,           --�Զ��˵���0
											mstr.IsManualCreateDet,    --�ֹ�������ϸ��0
											mstr.IsListPrice,          --��ʾ�۸񵥣�0
											mstr.IsPrintOrder,         --��ӡ���򵥣�0
											0,					  --�����Ѵ�ӡ��0
											mstr.IsPrintAsn,           --��ӡASN��0
											mstr.IsPrintRcpt,          --��ӡ�ջ�����0
											mstr.IsShipExceed,         --��������0
											mstr.IsRecExceed,          --�����գ�0
											mstr.IsOrderFulfillUC,     --����װ�µ���0
											mstr.IsShipFulfillUC,      --����װ������0
											mstr.IsRecFulfillUC,       --����װ�ջ���0
											mstr.IsShipScanHu,         --����ɨ�����룬0
											mstr.IsRecScanHu,          --�ջ�ɨ�����룬0
											mstr.IsCreatePL,           --�����������0
											0,					  --������Ѵ�����0
											mstr.IsShipFifo,           --�����Ƚ��ȳ���0
											mstr.IsRecFifo,            --�ջ��Ƚ��ȳ���0
											mstr.IsShipByOrder,        --��������������0
											0,					  --���ڶ�����0
											mstr.IsAsnUniqueRec,       --ASNһ�����ջ���0
											mstr.RecGapTo,             --�ջ����촦��0
											mstr.RecTemplate,		  --�ջ���ģ��
											mstr.OrderTemplate,		  --����ģ��
											mstr.AsnTemplate,		  --�ͻ���ģ��
											mstr.HuTemplate,			  --����ģ��
											mstr.BillTerm,             --���㷽ʽ��0
											mstr.CreateHuOpt,          --��������ѡ�0
											0,					  --���¼���۸�ѡ�0
											@CreateUserId,        --�����û�
											@CreateUserNm,        --�����û�����
											@DateTimeNow,         --��������
											@CreateUserId,        --����޸��û�
											@CreateUserNm,        --����޸��û�����
											@DateTimeNow,         --����޸�����
											@CreateUserId,        --�ͷ��û�
											@CreateUserNm,        --�ͷ��û�����
											@DateTimeNow,         --�ͷ�����
											1,					  --�汾��1
											mstr.Desc1,				  --·������
											mstr.ProdLineType,         --����������
											0,					  --��ͣ״̬��0
											@SeqGroup,			  --������
											convert(varchar(10), @PrevDeliveryDate, 112) + '-' + convert(varchar(3), @PrevDeliveryCount)			  --�˴�(������)
											from SCM_FlowMstr as mstr
											inner join MD_Party as pf on mstr.PartyFrom = pf.Code
											inner join MD_Party as pt on mstr.PartyTo = pt.Code
											left join MD_Location as lf on mstr.LocFrom = lf.Code
											left join MD_Location as lt on mstr.LocTo = lt.Code
											where mstr.Code = @SeqFlow
										end
										else
										begin
											RAISERROR(N'����·�����Ͳ���ȷ��', 16, 1)
										end
										-----------------------------����������ͷ-----------------------------
										
										
										-----------------------------������������ϸ-----------------------------
										declare @OrderDetCount int = 0
										declare @BeginOrderDetId int = 0
										declare @NextOrderDetId int = 0
										
										truncate table #tempSeqOrderDet
										insert into #tempSeqOrderDet(Seq, TraceCode, VanSeq, 
										Item, ItemDesc, RefItemCode, ReqQty, OrderQty, 
										Uom, UC, MinUC, UCDesc, Container, ContainerDesc, ManufactureParty, OpRef, CPTime, IsCreateSeq, ZOPWZ, ZOPID, ZOPDS, IsItemConsume)
										select ROW_NUMBER() over (order by ord.Seq, ord.SubSeq) as Seq, ord.TraceCode,
										(convert(varchar, (ord.Seq * 100 + ord.SubSeq))) as VanSeq,
										bom.Item, bom.ItemDesc, bom.RefItemCode, bom.OrderQty as ReqQty, CASE WHEN ord.IsCreateSeq = 0 then bom.OrderQty else 0 end as OrderQty, 
										bom.Uom, bom.UC, bom.MinUC, bom.UCDesc, bom.Container, bom.ContainerDesc, bom.ManufactureParty, bom.OpRef, bom.CPTime, ord.IsCreateSeq, bom.ZOPWZ, bom.ZOPID, bom.ZOPDS, 0
										from
										(select seq.Seq, seq.SubSeq, seq.OrderNo, seq.TraceCode, CASE WHEN trace.Id is null THEN 0 ELSE 1 END as IsCreateSeq
										from #tempTargetTraceCode as seq
										left join ORD_SeqOrderTrace as trace on trace.TraceCode = seq.TraceCode and trace.SeqGroup = @SeqGroup
										where Seq < @LastSeq or (Seq = @LastSeq and SubSeq <= @LastSubSeq)) as ord
										left join #tempBomCPTime as bom on ord.TraceCode = bom.TraceCode and bom.Flow = @SeqFlow --and ord.IsCreateSeq = 0
										order by ord.Seq, ord.SubSeq
								
										--Ϊ�����и�ֵ��ȡ����·���ϵĵ�һ�����������Ϊ0
										update det set Item = '_0517LJ2', ItemDesc = '��������', RefItemCode = '��������', ReqQty = 0, OrderQty = 0,
										Uom = 'ST', UC = 1, MinUC = 1
										from #tempSeqOrderDet as det
										where det.Item is null							
										
										--����������Ϊ�յ�ֱ��ȡ��һ�����
										update det set Item = '_0517LJ2', ItemDesc = '��������', RefItemCode = '��������', ReqQty = 0, OrderQty = 0,
										Uom = 'ST', UC = 1, MinUC = 1 
										from #tempSeqOrderDet as det
										where det.Item is null
										
										select @Msg = N'��ת�����ϸ����' + CONVERT(varchar, COUNT(1)) from #tempSeqOrderDet
										insert into #temp_LOG_GenSequenceOrder(SeqGroup, Flow, Lvl, Msg) values(@SeqGroup, @SeqFlow, 0, @Msg)
										
										-----------------------------������������-----------------------------
										truncate table #tempItemConsume
										insert into #tempItemConsume(Id, Item, RemainQty, [Version])
										select distinct con.Id, con.Item, con.Qty - con.ConsumeQty as RemainQty, con.[Version] 
										from #tempSeqOrderDet as det inner join PRD_ItemConsume as con on det.Item = con.Item
										where det.OrderQty > 0 and con.Qty > con.ConsumeQty order by con.Id
										
										if exists(select top 1 1 from #tempItemConsume)
										begin
											declare @ICRowId int = null
											declare @MaxICRowId int = null
											select @ICRowId = MIN(RowId), @MaxICRowId = MAX(RowId) from #tempItemConsume
											
											while @ICRowId <= @MaxICRowId
											begin
												declare @ICId int = null
												declare @ICItem varchar(50) = null
												declare @ICRemainQty decimal(18, 8) = null
												declare @ICVersion int = null
											
												select @ICId = Id, @ICItem = Item, @ICRemainQty = RemainQty, @ICVersion = [Version] 
												from #tempItemConsume where RowId = @ICRowId
																							
												truncate table #tempICSeqOrderDet
												insert into #tempICSeqOrderDet(SeqRowId)
												select RowId from #tempSeqOrderDet where Item = @ICItem and OrderQty > 0
												
												declare @ICSeqRowId int = null
												declare @MaxICSeqRowId int = null
												select @ICSeqRowId = MIN(RowId), @MaxICSeqRowId = MAX(RowId) from #tempICSeqOrderDet
												
												while @ICSeqRowId <= @MaxICSeqRowId
												begin
													if (@ICRemainQty > 0)
													begin
														declare @SeqRowId int = null
														declare @SeqRowSeq int = null
														declare @ICOrderQty decimal(18, 8) = null
														select @SeqRowId = SeqRowId from #tempICSeqOrderDet where RowId = @ICSeqRowId 
														select @SeqRowSeq = Seq, @ICOrderQty = OrderQty from #tempSeqOrderDet where RowId = @SeqRowId
														
														if (@ICRemainQty >= @ICOrderQty)
														begin
															update #tempSeqOrderDet set OrderQty = 0, IsItemConsume = 1 where RowId = @SeqRowId
															set @ICRemainQty = @ICRemainQty - @ICOrderQty
														end
														else
														begin
															update #tempSeqOrderDet set ReqQty = ReqQty - @ICRemainQty, OrderQty = OrderQty - @ICRemainQty where RowId = @SeqRowId
															
															update #tempSeqOrderDet set Seq = Seq + 1 where Seq > @SeqRowSeq
															
															insert into #tempSeqOrderDet(Seq, TraceCode, VanSeq, 
																						Item, ItemDesc, RefItemCode, ReqQty, OrderQty, 
																						Uom, UC, MinUC, UCDesc, Container, ContainerDesc, ManufactureParty, OpRef, CPTime, IsCreateSeq, ZOPWZ, ZOPID, ZOPDS, IsItemConsume)
															select @SeqRowSeq + 1, TraceCode, VanSeq, 
																						Item, ItemDesc, RefItemCode, @ICRemainQty, 0, 
																						Uom, UC, MinUC, UCDesc, Container, ContainerDesc, ManufactureParty, OpRef, CPTime, IsCreateSeq, ZOPWZ, ZOPID, ZOPDS, 1
															from #tempSeqOrderDet where RowId = @SeqRowId
														end
													end
													else
													begin
														break
													end
													
													set @ICSeqRowId = @ICSeqRowId + 1
												end
												
												update PRD_ItemConsume set ConsumeQty = Qty - @ICRemainQty, LastModifyUser = @CreateUserId, LastModifyUserNm = @CreateUserNm, 
												LastModifyDate = @DateTimeNow, [Version] = [Version] + 1
												where Id = @ICId and [Version] = @ICVersion
												
												if @@RowCount <> 1
												begin
													RAISERROR(N'�����������Ѹ��¡�', 16, 1) 
												end
												
												set @ICRowId = @ICRowId + 1
											end
										end
										-----------------------------������������-----------------------------
										
										--���Ҷ�������
										select @OrderDetCount = COUNT(*) from #tempSeqOrderDet
										--����OrderDetId�ֶα�ʶ�ֶ�
										exec USP_SYS_BatchGetNextId 'ORD_OrderDet', @OrderDetCount, @NextOrderDetId output
										--���ҿ�ʼ��ʶ
										set @BeginOrderDetId = @NextOrderDetId - @OrderDetCount
									
										--������������ϸ��ʶ
										update #tempSeqOrderDet set Id = seq + @BeginOrderDetId
										
										if @SeqFlowType = 1
										begin
											insert into ORD_OrderDet_1 (
											Id,                         --��������ϸ��ʶ
											OrderNo,                    --��������
											OrderType,                  --���ͣ�1�ɹ�
											OrderSubType,               --�����ͣ�0����
											Seq,						--�кţ�1
											ReserveNo,					--�ⲿ�����ţ�Van��
											ReserveLine,				--������ˮ�� = ˳���+��˳���
											ScheduleType,               --�ƻ�Э�����ͣ�0
											Item,                       --���Ϻ�
											RefItemCode,				--�ο����Ϻ�
											ItemDesc,                   --��������
											Uom,                        --��λ
											BaseUom,                    --������λ
											UC,                         --��װ��1
											MinUC,                      --��С��װ��1
											UCDesc,						--��װ����
											Container,					--��������
											ContainerDesc,				--��������
											QualityType,                --����״̬��0
											ManufactureParty,           --������
											ReqQty,                     --����������1
											OrderQty,                   --����������1
											ShipQty,                    --����������0
											RecQty,                     --�ջ�������0
											RejQty,                     --��Ʒ������0
											ScrapQty,                   --��Ʒ������0
											PickQty,                    --���������0
											UnitQty,                    --��λ������1
											IsInspect,                  --�Ƿ���飬0
											IsProvEst,                  --���Ƿ��Ѿ����ɹ�����
											IsIncludeTax,               --�Ƿ�������
											IsScanHu,                   --�Ƿ�ɨ�����룬0
											CreateUser,                 --�����û�
											CreateUserNm,               --�����û�����
											CreateDate,                 --��������
											LastModifyUser,             --����޸��û�
											LastModifyUserNm,           --����޸��û�����
											LastModifyDate,             --����޸�����
											[Version],					--�汾��1
											IsChangeUC,					--�Ƿ��޸ĵ���װ��0
											BinTo,						--��¼��λ
											StartDate,					--��¼���������ʱ��
											--LocFrom,					--�����λ
											--LocFromNm,					--�����λ����
											LocTo,						--����λ
											LocToNm,					--����λ����
											BillAddr,					--��Ʊ��ַ
											BillTerm,					--���㷽ʽ
											ZOPWZ,						--
											ZOPID,						--
											ZOPDS						--
											)
											select 
											det.Id,                     --��������ϸ��ʶ
											@SeqOrderNo,				--��������
											@SeqFlowType,				--���ͣ�1�ɹ�
											0,							--�����ͣ�0����
											det.Seq,					--�кţ�
											det.TraceCode,				--�ⲿ�����ţ�Van��
											det.VanSeq,					--������ˮ�� = ˳���+��˳���
											0,							--�ƻ�Э�����ͣ�0
											det.Item,                   --���Ϻ�
											det.RefItemCode,			--�ο����Ϻ�
											det.ItemDesc,               --��������
											det.Uom,                    --��λ
											det.Uom,					--������λ
											det.UC,                     --��װ��1
											det.MinUC,                  --��С��װ��1
											det.UCDesc,					--��װ����
											det.Container,				--��������
											det.ContainerDesc,			--��������
											0,							--����״̬��0
											det.ManufactureParty,       --������
											ISNULL(det.ReqQty, 0),		--����������1
											det.OrderQty,				--����������1
											0,							--����������0
											0,							--�ջ�������0
											0,							--��Ʒ������0
											0,							--��Ʒ������0
											0,							--���������0
											1,							--��λ������1
											0,							--�Ƿ���飬0
											CASE WHEN ISNULL(det.ReqQty, 0) = 0 then 0 else det.IsCreateSeq end,			--���Ƿ��Ѿ����ɹ�����
											det.IsItemConsume,			--�Ƿ�������
											0,							--�Ƿ�ɨ�����룬0
											@CreateUserId,				--�����û�
											@CreateUserNm,				--�����û�����
											@DateTimeNow,				--��������
											@CreateUserId,				--����޸��û�
											@CreateUserNm,				--����޸��û�����
											@DateTimeNow,				--����޸�����
											1,							--�汾��1
											0,							--�Ƿ��޸ĵ���װ��0
											det.OpRef,					--��¼��λ
											det.CPTime,					--��¼���������ʱ��
											--ISNULL(det.LocFrom, mstr.LocFrom),--�����λ
											--ISNULL(lf.Name, mstr.LocFromNm),--�����λ
											ISNULL(det.LocTo, mstr.LocTo),	--����λ
											ISNULL(lt.Name, mstr.LocToNm),--����λ
											mstr.BillAddr,				--��Ʊ��ַ
											mstr.BillTerm,				--���㷽ʽ
											det.ZOPWZ,					--
											det.ZOPID,					--
											det.ZOPDS					--
											from #tempSeqOrderDet as det 
											inner join ORD_OrderMstr_1 as mstr on mstr.OrderNo = @SeqOrderNo
											--left join MD_Location as lf on det.LocFrom = lf.Code
											left join MD_Location as lt on det.LocTo = lt.Code
											
											--�����ۼƽ�����
											update q set AccumulateQty = ISNULL(q.AccumulateQty, 0) + det.OrderQty, [Version] = q.[Version] + 1
											from SCM_Quota as q 
											inner join (select det.Item, mstr.PartyFrom, SUM(det.OrderQty) as OrderQty 
														from #tempSeqOrderDet as det 
														inner join ORD_OrderMstr_1 as mstr on mstr.OrderNo = @SeqOrderNo
														where det.OrderQty > 0
														group by det.Item, mstr.PartyFrom) as det on q.Item = det.Item and q.Supplier = det.PartyFrom
										end
										else
										begin
											insert into ORD_OrderDet_2 (
											Id,                         --��������ϸ��ʶ
											OrderNo,                    --��������
											OrderType,                  --���ͣ�2�ƿ�
											OrderSubType,               --�����ͣ�0����
											Seq,						--�кţ�1
											ReserveNo,					--�ⲿ�����ţ�Van��
											ReserveLine,				--������ˮ�� = ˳���+��˳���
											ScheduleType,               --�ƻ�Э�����ͣ�0
											Item,                       --���Ϻ�
											RefItemCode,				--�ο����Ϻ�
											ItemDesc,                   --��������
											Uom,                        --��λ
											BaseUom,                    --������λ
											UC,                         --��װ��1
											MinUC,                      --��С��װ��1
											UCDesc,						--��װ����
											Container,					--��������
											ContainerDesc,				--��������
											QualityType,                --����״̬��0
											ManufactureParty,           --������
											ReqQty,                     --����������1
											OrderQty,                   --����������1
											ShipQty,                    --����������0
											RecQty,                     --�ջ�������0
											RejQty,                     --��Ʒ������0
											ScrapQty,                   --��Ʒ������0
											PickQty,                    --���������0
											UnitQty,                    --��λ������1
											IsInspect,                  --�Ƿ���飬0
											IsProvEst,                  --���Ƿ��Ѿ����ɹ�����
											IsIncludeTax,               --�Ƿ�������
											IsScanHu,                   --�Ƿ�ɨ�����룬0
											CreateUser,                 --�����û�
											CreateUserNm,               --�����û�����
											CreateDate,                 --��������
											LastModifyUser,             --����޸��û�
											LastModifyUserNm,           --����޸��û�����
											LastModifyDate,             --����޸�����
											[Version],					--�汾��1
											IsChangeUC,					--�Ƿ��޸ĵ���װ��0
											BinTo,						--��¼��λ
											StartDate,					--��¼���������ʱ��
											LocFrom,					--�����λ
											LocFromNm,					--�����λ����
											LocTo,						--����λ
											LocToNm,					--����λ����
											--BillAddr					--��Ʊ��ַ
											ZOPWZ,						--
											ZOPID,						--
											ZOPDS						--
											)
											select 
											det.Id,						--��������ϸ��ʶ
											@SeqOrderNo,				--��������
											@SeqFlowType,				--���ͣ�2�ƿ�
											0,							--�����ͣ�0����
											det.Seq,					--�кţ�
											det.TraceCode,					--�ⲿ�����ţ�Van��
											det.VanSeq,					--������ˮ�� = ˳���+��˳���
											0,							--�ƻ�Э�����ͣ�0
											det.Item,					--�������Ϻ�
											det.RefItemCode,			--�ο����Ϻ�
											det.ItemDesc,				--������������
											det.Uom,					--��λ
											det.Uom,					--������λ
											det.UC,						--��װ��1
											det.MinUC,					--��С��װ��1
											det.UCDesc,					--��װ����
											det.Container,				--��������
											det.ContainerDesc,			--��������
											0,							--����״̬��0
											det.ManufactureParty,		--������
											ISNULL(det.ReqQty, 0),		--����������1
											det.OrderQty,				--����������1
											0,							--����������0
											0,							--�ջ�������0
											0,							--��Ʒ������0
											0,							--��Ʒ������0
											0,							--���������0
											1,							--��λ������1
											0,							--�Ƿ���飬0
											CASE WHEN ISNULL(det.ReqQty, 0) = 0 then 0 else det.IsCreateSeq end,			--���Ƿ��Ѿ����ɹ�����
											det.IsItemConsume,			--�Ƿ�������
											0,							--�Ƿ�ɨ�����룬0
											@CreateUserId,				--�����û�
											@CreateUserNm,				--�����û�����
											@DateTimeNow,				--��������
											@CreateUserId,				--����޸��û�
											@CreateUserNm,				--����޸��û�����
											@DateTimeNow,				--����޸�����
											1,							--�汾��1
											0,							--�Ƿ��޸ĵ���װ��0
											det.OpRef,					--��¼��λ
											det.CPTime,					--��¼���������ʱ��
											ISNULL(det.LocFrom, mstr.LocFrom),--�����λ
											ISNULL(lf.Name, mstr.LocFromNm),--�����λ
											ISNULL(det.LocTo, mstr.LocTo),	--����λ
											ISNULL(lt.Name, mstr.LocToNm),--����λ
											--mstr.BillAddr				--��Ʊ��ַ
											det.ZOPWZ,					--
											det.ZOPID,					--
											det.ZOPDS					--
											from #tempSeqOrderDet as det 
											inner join ORD_OrderMstr_2 as mstr on mstr.OrderNo = @SeqOrderNo
											left join MD_Location as lf on det.LocFrom = lf.Code
											left join MD_Location as lt on det.LocTo = lt.Code
										end
									
										--��¼��־
										set @Msg = N'�ɹ���������' + @SeqOrderNo
										insert into #temp_LOG_GenSequenceOrder(SeqGroup, Flow, OrderNo, Lvl, Msg) values(@SeqGroup, @SeqFlow, @SeqOrderNo, 0, @Msg)
										-----------------------------������������ϸ-----------------------------
										
										--�ж������Ƿ�ֱ�ӹر�
										if not exists(select top 1 1 from #tempSeqOrderDet where OrderQty > 0)
										begin
											if @SeqFlowType = 1
											begin
												update ORD_OrderMstr_1 set [Status] = 4, CloseDate = @DateTimeNow, CloseUser = @CreateUserId, CloseUserNm = @CreateUserNm where OrderNo = @SeqOrderNo
											end
											else
											begin
												update ORD_OrderMstr_2 set [Status] = 4, CloseDate = @DateTimeNow, CloseUser = @CreateUserId, CloseUserNm = @CreateUserNm where OrderNo = @SeqOrderNo
											end
											
											set @Msg = N'�ر�����' + @SeqOrderNo + '����Ϊ��������ȫ��Ϊ0'
											insert into #temp_LOG_GenSequenceOrder(SeqGroup, Flow, OrderNo, Lvl, Msg) values(@SeqGroup, @SeqFlow, @SeqOrderNo, 0, @Msg)
										end
										
										if @SeqFlowType = 1
										begin  --��¼�����ƻ�Э��Ķ�����ϸ
											INSERT INTO SAP_CRSL(EINDT, FRBNR, LIFNR, MATNR, MENGE, SGTXT, WERKS, OrderDetId, [Status], ErrorCount, CreateDate, LastModifyDate)
											select CONVERT(varchar(8), @WindowTime, 112), @SeqOrderNo, mstr.PartyFrom, det.Item, det.OrderQty, det.Seq, r.Plant, det.Id, 0, 0, @DateTimeNow, @DateTimeNow
											from #tempSeqOrderDet as det
											inner join ORD_OrderMstr_1 as mstr on mstr.OrderNo = @SeqOrderNo
											inner join MD_Region as r on mstr.PartyTo = r.Code
											where det.OrderQty > 0
										end
										else
										begin
											if exists(select top 1 1 from SCM_FlowMstr where Code = @SeqFlow and PartyFrom in ('LOC', 'SQC'))
											begin
												INSERT INTO FIS_CreateSeqOrderDAT(SeqNo, Seq, Flow, StartTime, WindowTime, 
												PartyFrom, PartyTo, LocationTo, Container, CreateDate, Item, ManufactureParty, Qty, 
												SequenceNumber, Van, Line, Station, ErrorCount, UploadDate, FileName, IsCreateDat, OrderDetId)
												select @SeqOrderNo, det.Seq, mstr.SeqGroup, mstr.StartTime, mstr.WindowTime,
												ISNULL(det.LocFrom, mstr.LocFrom), ISNULL(det.LocTo, mstr.LocTo), ISNULL(det.OpRef, 'δ֪��λ'), '', @DateTimeNow, det.Item, det.ManufactureParty, det.OrderQty,
												det.VanSeq, det.TraceCode, '', null, 0, null, '', 0, det.Id
												from #tempSeqOrderDet as det
												inner join ORD_OrderMstr_2 as mstr on mstr.OrderNo = @SeqOrderNo
												left join MD_Location as lf on det.LocFrom = lf.Code
												left join MD_Location as lt on det.LocTo = lt.Code
											end
										end
										
										--������������ϵ��ۼ��������������ۼƣ�
										update SCM_FlowStrategy set MRPTotal = ISNULL(MRPTotal, 0) + (select COUNT(distinct TraceCode) from #tempSeqOrderDet where OrderQty > 0)
										where Flow = @SeqFlow
										
										if @SeqIsCreatePickList = 1
										begin
											exec USP_LE_SpecifySequenceOrderCSSupplier @SeqOrderNo
										end
										
										--��¼�Ѿ����������򵥵�VAN������ʱ��
										insert into #tempSeqOrderTrace(TraceCode, ProdLine, SeqGroup, DeliveryCount)
										select distinct det.TraceCode, @ProdLine, @SeqGroup, convert(varchar(2), DATEPART(DAY, @PrevDeliveryDate)) + '-' + convert(varchar(3), @PrevDeliveryCount)
										from #tempSeqOrderDet as det
										--left join #tempSeqOrderTrace as trace on trace.TraceCode = det.TraceCode and trace.SeqGroup = @SeqGroup
										where (det.OrderQty > 0 or det.IsItemConsume = 1) --and trace.TraceCode is null
									
										set @SeqFlowRowId = @SeqFlowRowId + 1
									end
									-----------------------------��ѭ����������-----------------------------
								
								
										
									--��¼�Ѿ����������򵥵�VAN��
									insert into ORD_SeqOrderTrace(TraceCode, ProdLine, SeqGroup, DeliveryCount)
									select distinct TraceCode, ProdLine, SeqGroup, DeliveryCount from #tempSeqOrderTrace
									
									--��¼��־
									set @Msg = N'�������򵥽���'
									insert into #temp_LOG_GenSequenceOrder(SeqGroup, Lvl, Msg) values(@SeqGroup, 0, @Msg)
									
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
									
									set @Msg = Error_Message() 
									RAISERROR(@Msg, 16, 1) 
								end catch
							end
							else
							begin
								--��¼��־
								set @Msg = N'��ǰʱ��' + convert(varchar, @DateTimeNow, 120) + N'С�ڷ���ʱ�䣬���򵥼������'
								insert into #temp_LOG_GenSequenceOrder(SeqGroup, Lvl, Msg) values(@SeqGroup, 0, @Msg)
								
								break
							end
						end
						-----------------------------�����򵥽�ת-----------------------------
					end
				end
				-----------------------------��ѭ����������-----------------------------
				
				set @LoopCount = @LoopCount + 1
			end try
			begin catch
				--��¼��־
				set @Msg = N'�������򵥳�������������' + CONVERT(varchar, ERROR_LINE()) + N'��������Ϣ��' + Error_Message()
				insert into #temp_LOG_GenSequenceOrder(SeqGroup, Lvl, Msg) values(@SeqGroup, 2, @Msg)
				
				break
			end catch
		end
		
		insert into LOG_GenSequenceOrder(SeqGroup, Flow, Lvl, Msg, CreateDate, OrderNo, BatchNo)
		select SeqGroup, Flow, Lvl, Msg, CreateDate, OrderNo, @BatchNo from #temp_LOG_GenSequenceOrder
		
		set @SeqGroupRowId = @SeqGroupRowId + 1
	end
	
	--��¼��־
	set @Msg = N'�������򵥽���'
	insert into LOG_GenSequenceOrder(Lvl, Msg) values(0, @Msg)
	
	drop table #temp_LOG_GenSequenceOrder
	drop table #tempItemConsume
	drop table #tempICSeqOrderDet
	drop table #tempSeqOrderDet
	drop table #tempBomCPTime
	drop table #tempAssOpRef
	drop table #tempSeqFlow
	drop table #tempSeqGroup
	drop table #tempSortedMultiSupplierItem
	drop table #tempMultiSupplierItem
	drop table #tempMultiSupplierGroup
	drop table #tempSeqOrderTrace
	drop table #tempTargetTraceCode
END