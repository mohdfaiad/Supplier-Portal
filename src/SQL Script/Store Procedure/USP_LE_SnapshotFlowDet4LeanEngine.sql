SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF EXISTS(SELECT * FROM SYS.objects WHERE type='P' AND name='USP_LE_SnapshotFlowDet4LeanEngine')
	DROP PROCEDURE USP_LE_SnapshotFlowDet4LeanEngine
GO

CREATE PROCEDURE [dbo].[USP_LE_SnapshotFlowDet4LeanEngine] 
(
	@BatchNo int,
	@LERunTime datetime
)
--WITH ENCRYPTION
AS
BEGIN
	SET NOCOUNT ON
	declare @Msg nvarchar(Max)
	declare @trancount int
	
	CREATE TABLE #tempFlowDet 
	(
		Id int identity(1, 1) Primary Key,
		Flow varchar(50) NULL,
		FlowDetId int NULL,
		Item varchar(50) NOT NULL,
		Uom varchar(5) NULL,
		UC decimal(18, 8) NULL,
		MinUC decimal(18, 8) NULL,
		Container varchar(50) NULL,
		ContainerDesc varchar(50) NULL,
		UCDesc varchar(50) NULL,
		ManufactureParty varchar(50) NULL,
		LocFrom varchar(50) NULL,
		LocTo varchar(50) NOT NULL,
		Routing varchar(50),
		ExtraDmdSource varchar(256) NULL,
		MrpTotal decimal(18, 8) NULL,
		MrpTotalAdj decimal(18, 8) NULL,
		MrpWeight decimal(18, 8) NULL,
		IsRefFlow bit NULL,
		SafeStock decimal(18, 8),
		MaxStock decimal(18, 8),
		MinLotSize decimal(18, 8),
		RoundUpOpt tinyint,
		Strategy tinyint,
	)
	
	CREATE NONCLUSTERED INDEX IX_TempFlowDet  ON #tempFlowDet 
	(
		Item asc,
		LocTo asc
	)
	
	create table #tempMultiSupplierGroup
	(
		RowId int identity(1, 1),
		Item varchar(50),
		LocTo varchar(50),
	)
	
	create table #tempMultiSupplierItem
	(
		RowId int identity(1, 1),
		FlowDetRowId int,
		Flow varchar(50),
		Item varchar(50), 
		LocTo varchar(50),
		MSGRowId int,
		MrpTotal decimal(18, 8),
		MrpTotalAdj decimal(18, 8),
		MrpWeight int,
		DeliveryCount int,  --�ѹ�������
		DeliveryBalance int   --����
	)
	
	CREATE NONCLUSTERED INDEX IX_TempMultiSupplierItem  ON #tempMultiSupplierItem 
	(
		Item asc,
		LocTo asc
	)
	
	create table #tempSortedMultiSupplierItem
	(
		GID int, 
		FlowDetRowId int,
		Flow varchar(50)
	)
	
	create table #tempOrderBom
	(
		Item varchar(50),
		Region varchar(50),
		Location varchar(50),
		IsMatch bit
	)
	
	create table #tempPurchase
	(
		Id int identity(1, 1) Primary Key,
		Item varchar(50),
		Region varchar(50),
		Location varchar(50)
	)
	
	create table #tempTransfer
	(
		Id int identity(1, 1) Primary Key,
		Item varchar(50),
		PartyFrom varchar(50),
		PartyTo varchar(50),
		LocFrom varchar(50),
		LocTo varchar(50)
	)
	
	Create table #tempExtraDmdSource
	(
		RowId int identity(1, 1),
		FlowDetSnapShotId int,
		FlowDetLocTo varchar(50),
		ExtraDmdSource varchar(256)
	)
	
	CREATE TABLE #temp_LOG_SnapshotFlowDet4LeanEngine(
		Flow varchar(50) NULL,
		Item varchar(50) NULL,
		LocFrom varchar(50) NULL,
		LocTo varchar(50) NULL,
		OrderNo varchar(50) NULL,
		TraceCode varchar(50) NULL,
		Lvl tinyint NULL,
		ErrorId tinyint NULL,
		Msg varchar(500) NULL,
		CreateDate datetime NULL default(GETDATE()),
	)
	
	create table #tempCompleteFlowDet  --����·��RowId
	(
		FlowDetRowId int,
		Item varchar(50),
		LocTo varchar(50)
	)
	
	--��¼��־
	set @Msg = N'��ȡ·����ϸ��ʼ'
	insert into #temp_LOG_SnapshotFlowDet4LeanEngine(Lvl, Msg) values(0, @Msg)
	
	--��ȡ·��
	truncate table LE_FlowMstrSnapShot
	insert into LE_FlowMstrSnapShot(Flow, [Type], Strategy, PartyFrom, PartyTo, LocFrom, LocTo, Dock, ExtraDmdSource)
	select mstr.Code as Flow, mstr.[Type], stra.Strategy, mstr.PartyFrom, mstr.PartyTo, mstr.LocFrom, mstr.LocTo, mstr.Dock, mstr.ExtraDmdSource
	from SCM_FlowMstr as mstr 
	inner join SCM_FlowStrategy as stra on mstr.Code = stra.Flow
	where mstr.IsActive = 1 and mstr.IsAutoCreate = 1 and mstr.[Type] in (1, 2, 5, 6, 7, 8) and stra.Strategy in (2, 3)
	
	-------------------������ÿ��·�ߵ�����ʱ��κͷ���ʱ��-----------------------
	declare @FlowRowId int
	declare @MaxFlowRowId int
	
	select @FlowRowId = MIN(Id), @MaxFlowRowId = MAX(Id) from LE_FlowMstrSnapShot
	while (@FlowRowId <= @MaxFlowRowId)
	begin
		declare @Flow varchar(50) = null
		declare @FlowType tinyint = null
		declare @FlowStrategy tinyint = null
		declare @PartyFrom varchar(50) = null
		declare @PartyTo varchar(50) = null
		declare @LocFrom varchar(50) = null
		declare @LocTo varchar(50) = null
		declare @ExtraDmdSource varchar(50) = null
		declare @LeadTimeOpt tinyint = null   --��ǰ��ѡ�0�Ӳ�����ȡ��1�Ӱ����ȡ
		declare @WinTimeType tinyint = null
		declare @WinTimeDiff decimal(18, 8) = null  --�룬������ǰ��
		declare @SafeTime decimal(18, 8) = null  --�룬��ȫ�ڣ����󸲸���ǰ�ڣ�@ReqTimeTo���������Ӱ�ȫ�ڵ�ʱ��
		declare @LeadTime decimal(18, 8) = null  --�룬��ǰ�ڣ�������ǰ��
		declare @EMLeadTime decimal(18, 8) = null  --�룬������ǰ��
		declare @PrevWinTime datetime = null
		declare @WindowTime datetime = null
		declare @WindowTime2 datetime = null
		declare @EMWindowTime datetime = null
		declare @ReqTimeFrom datetime = null
		declare @ReqTimeTo datetime = null
		declare @OrderTime datetime = null
		declare @EMOrderTime datetime = null
		
		select @Flow = Flow, @FlowType = [Type], 
		@PartyFrom = PartyFrom, @PartyTo = PartyTo,
		@LocFrom = LocFrom, @LocTo = LocTo, @ExtraDmdSource = ExtraDmdSource
		from LE_FlowMstrSnapShot where Id = @FlowRowId
		
		--��¼��־
		set @Msg = N'����·������ʱ��κͷ���ʱ�俪ʼ'
		insert into #temp_LOG_SnapshotFlowDet4LeanEngine(Flow, Lvl, Msg) values(@Flow, 0, @Msg)
		
		set @trancount = @@trancount
		begin try
			if @trancount = 0
			begin
				begin tran
			end		
		
			select @FlowStrategy = Strategy, @WinTimeType = WinTimeType, 
			@WinTimeDiff = WinTimeDiff * 60 * 60, --СʱתΪ��
			@SafeTime = ISNULL(SafeTime, 0) * 60 * 60, --СʱתΪ��
			@LeadTime = -LeadTime * 60 * 60, --СʱתΪ��
			@EMLeadTime = -EMLeadTime * 60 * 60,	   --СʱתΪ��
			@PrevWinTime = PreWinTime,       --�ϴδ���ʱ��
			@WindowTime = NextWinTime,
			@LeadTimeOpt = LeadTimeOpt
			from SCM_FlowStrategy with(UPDLOCK) where Flow = @Flow
			
			--�����´δ��ڿ�ʼʱ��
			exec USP_Busi_GetNextWindowTime @Flow, @PrevWinTime, @WindowTime output
			
			if (@LeadTimeOpt = 1)
			begin  --��ǰ��ȡ����ϵ�
				select top 1 @SafeTime = ISNULL(fsd.SafeTime, 0) * 60 * 60, --СʱתΪ��
				@LeadTime = -ISNULL(fsd.OrderLeadTime, 0) * 60 * 60,     --СʱתΪ��
				@EMLeadTime = -ISNULL(fsd.OrderEMLeadTime, 0) * 60 * 60,    --СʱתΪ��
				@WinTimeDiff = ISNULL(fsd.UnloadLeadTime, 0) * 60 * 60    --СʱתΪ��
				from PRD_WorkingCalendar as wc
				inner join SCM_FlowShiftDet as fsd on wc.[Shift] = fsd.[Shift]
				where wc.WorkingDate = CONVERT(datetime, CONVERT(varchar(10), @WindowTime))
				and wc.Region = @PartyTo
				and wc.[Type] = 0  --����
				and fsd.Flow = @Flow
			end

			--�����������ʱ��
			exec USP_Busi_SubtractWorkingDate @WindowTime, @EMLeadTime, null, @PartyTo, @EMOrderTime output
			
			--�����´δ���ʱ������´ν�������ʱ�䣬����´ν�������ʱ��С�ڵ�ǰʱ�����²����´δ��ڿ�ʼʱ��ͽ�������ʱ��
			declare @LoopCount int = 0
			while (@EMOrderTime < @LERunTime and @LoopCount < 99)
			begin  --��������ʱ��С�ڵ�ǰʱ�����²����´δ��ڿ�ʼʱ��ͽ�������ʱ��
				set @LoopCount = @LoopCount + 1 --����ѭ����Ҫ����100��
				
				set @Msg = N'���ݴ���ʱ��' + + CONVERT(varchar, @WindowTime, 120) + + N'����Ľ�������ʱ��' + CONVERT(varchar, @EMOrderTime, 120) + N'С�ڵ�ǰʱ�䣬���¼��㴰��ʱ��'
				insert into #temp_LOG_SnapshotFlowDet4LeanEngine(Flow, Lvl, ErrorId, Msg) values(@Flow, 1, 11, @Msg)
				
				exec USP_Busi_GetNextWindowTime @Flow, @WindowTime, @WindowTime output

				if (@LeadTimeOpt = 1)
				begin  --��ǰ��ȡ����ϵ�
					select top 1 @SafeTime = ISNULL(fsd.SafeTime, 0) * 60 * 60, --СʱתΪ��
					@LeadTime = -ISNULL(fsd.OrderLeadTime, 0) * 60 * 60,     --СʱתΪ��
					@EMLeadTime = -ISNULL(fsd.OrderEMLeadTime, 0) * 60 * 60,    --СʱתΪ��
					@WinTimeDiff = ISNULL(fsd.UnloadLeadTime, 0) * 60 * 60    --СʱתΪ��
					from PRD_WorkingCalendar as wc
					inner join SCM_FlowShiftDet as fsd on wc.[Shift] = fsd.[Shift]
					where wc.WorkingDate = CONVERT(datetime, CONVERT(varchar(10), @WindowTime))
					and wc.Region = @PartyTo
					and wc.[Type] = 0  --����
					and fsd.Flow = @Flow
				end

				exec USP_Busi_SubtractWorkingDate @WindowTime, @EMLeadTime, null, @PartyTo, @EMOrderTime output
			end
			
			--���㱾�δ��ڽ���ʱ��
			exec USP_Busi_GetNextWindowTime @Flow, @WindowTime, @WindowTime2 output
			
			--�����������ʱ��
			set @EMLeadTime = 0 - @EMLeadTime
			exec USP_Busi_AddWorkingDate @LERunTime, @EMLeadTime, null, @PartyTo, @EMWindowTime output
			if @EMWindowTime > @WindowTime
			begin
				set @EMWindowTime = @WindowTime
			end
		
			--���㷢��ʱ��
			exec USP_Busi_SubtractWorkingDate @WindowTime, @LeadTime, null, @PartyTo, @OrderTime output
			
			--�����´�����ʼʱ�䣬���ݽ�����ǰ�ڼ���ʵ������ʼʱ��
			exec USP_Busi_AddWorkingDate @WindowTime, @WinTimeDiff, null, @PartyTo, @ReqTimeFrom output
		
			--�����´��������ʱ�䣬���ݽ�����ǰ�ڼ���ʵ������ʼʱ��
			set @SafeTime = @SafeTime + @WinTimeDiff
			exec USP_Busi_AddWorkingDate @WindowTime2, @SafeTime, null, @PartyTo, @ReqTimeTo output
			
			--��¼��־
			set @Msg = N'·������ʱ��Ϊ' + CONVERT(varchar, @ReqTimeFrom, 120) + N'~' + CONVERT(varchar, @ReqTimeTo, 120)
				+ '������ʱ��Ϊ' + CONVERT(varchar, @OrderTime, 120)
				+ '������ʱ��Ϊ' + CONVERT(varchar, @WindowTime, 120)
				+ '����������ʱ��Ϊ' + CONVERT(varchar, @EMWindowTime, 120)
			insert into #temp_LOG_SnapshotFlowDet4LeanEngine(Flow, Lvl, Msg) values(@Flow, 0, @Msg)

			--����·��
			update LE_FlowMstrSnapShot set OrderTime = @OrderTime, ReqTimeFrom = @ReqTimeFrom, ReqTimeTo = @ReqTimeTo, 
			WindowTime = @WindowTime, EMWindowTime = @EMWindowTime
			where Id = @FlowRowId
			
			--��ȡ·����ϸ
			insert into #tempFlowDet(Flow, FlowDetId, Item, Uom, UC, MinUC, ManufactureParty,
			LocFrom, LocTo, Routing,
			ExtraDmdSource,
			MrpTotal, MrpTotalAdj, MrpWeight, IsRefFlow,
			SafeStock, MaxStock, MinLotSize, RoundUpOpt, Strategy,
			Container, ContainerDesc, UCDesc)
			select @Flow, det.Id as FlowDetId, det.Item, det.Uom, det.UC, det.MinUC, det.ManufactureParty, 
			@LocFrom, @LocTo, det.Routing,
			ISNULL(det.ExtraDmdSource, @ExtraDmdSource) as ExtraDmdSource,
			ISNULL(det.MrpTotal, 0), ISNULL(det.MrpTotalAdj, 0), ISNULL(det.MrpWeight, 0) as MrpWeight, 0,
			ISNULL(pref.SafeStock, 0), ISNULL(pref.MaxStock, 0), ISNULL(det.MinLotSize, 0), det.RoundUpOpt, @FlowStrategy,
			det.Container, det.ContainerDesc, det.UCDesc
			from SCM_FlowDet as det
			left join INV_LocationDetPref as pref on det.Item = pref.Item and pref.Location = @LocTo
			where det.Flow = @Flow 
			--and (det.StartDate is null or (det.StartDate <= @@LERunTime))
			--and (det.EndDate is null or (det.EndDate >= @@LERunTime))
			--and det.IsAutoCreate = 1 
			--and det.IsActive = 1

			if @OrderTime <= @LERunTime
			begin
				--��¼��־
				set @Msg = N'·�߷���ʱ��' + CONVERT(varchar, @OrderTime, 120) + 'С�ڵ�ǰʱ�����·���´δ���ʱ��Ϊ' + CONVERT(varchar, @WindowTime2, 120)
				insert into #temp_LOG_SnapshotFlowDet4LeanEngine(Flow, Lvl, Msg) values(@Flow, 0, @Msg)
				
				--����·���ϴδ���ʱ��
				update SCM_FlowStrategy set PreWinTime = @WindowTime, NextWinTime = @WindowTime2 where Flow = @Flow
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
			
			delete from LE_FlowMstrSnapShot where Flow = @Flow
			delete from LE_FlowDetSnapShot where Flow = @Flow
		
			--��¼��־
			set @Msg = N'����·������ʱ��κͷ���ʱ������쳣���쳣��Ϣ��' + Error_Message()
			insert into #temp_LOG_SnapshotFlowDet4LeanEngine(Flow, Lvl, ErrorId, Msg) values(@Flow, 2, 12, @Msg)
		end catch
		
		--��¼��־
		set @Msg = N'����·������ʱ��κͷ���ʱ�����'
		insert into #temp_LOG_SnapshotFlowDet4LeanEngine(Flow, Lvl, Msg) values(@Flow, 0, @Msg)
		
		set @FlowRowId = @FlowRowId + 1
	end
	-------------------������ÿ��·�ߵ�����ʱ��κͷ���ʱ��-----------------------
	
	

	-------------------����������·������ʱ��κͷ���ʱ��-----------------------
	--��¼��־
	set @Msg = N'��������·������ʱ��κͷ���ʱ�俪ʼ'
	insert into #temp_LOG_SnapshotFlowDet4LeanEngine(Lvl, Msg) values(0, @Msg)
	
	insert into #tempFlowDet(Flow, FlowDetId, Item, UOM, UC, MinUC, ManufactureParty,
	LocFrom, LocTo, Routing,
	ExtraDmdSource,
	IsRefFlow, MrpTotal, MrpTotalAdj, MrpWeight,
	SafeStock, MaxStock, MinLotSize, RoundUpOpt, Strategy,
	Container, ContainerDesc, UCDesc)
	select mstr.Code as Flow, fdet.FlowDetId, fdet.Item, fdet.UOM, fdet.UC, fdet.MinUC, fdet.ManufactureParty, 
	mstr.LocFrom, mstr.LocTo, fdet.Routing,
	mstr.ExtraDmdSource,
	1, 0, 0, 0,
	ISNULL(pref.SafeStock, 0), ISNULL(pref.MaxStock, 0), ISNULL(fdet.MinLotSize, 0), fdet.RoundUpOpt, stra.Strategy,
	fdet.Container, fdet.ContainerDesc, fdet.UCDesc
	from SCM_FlowMstr as mstr 
	inner join SCM_FlowStrategy as stra on mstr.Code = stra.Flow
	inner join LE_FlowMstrSnapShot as fmstr on mstr.Code = fmstr.Flow
	inner join #tempFlowDet as fdet on mstr.RefFlow = fdet.Flow
	left join INV_LocationDetPref as pref on fdet.Item = pref.Item and mstr.LocTo = pref.Location
	where mstr.IsActive = 1 and mstr.IsAutoCreate = 1
	and stra.Strategy in (2, 3)
	and not Exists(select top 1 1 from #tempFlowDet as tDet where tdet.Item = fdet.Item and tDet.LocTo = mstr.LocTo)
	
	--��¼��־
	set @Msg = N'��������·������ʱ��κͷ���ʱ�����'
	insert into #temp_LOG_SnapshotFlowDet4LeanEngine(Lvl, Msg) values(0, @Msg)
	-------------------����������·�ߵ�����ʱ��κͷ���ʱ��-----------------------
	
	
	
	-------------------������·���Ƿ�����-----------------------	
	--while 1 = 1
	--begin
	--	insert into #tempCompleteFlowDet(FlowDetRowId, Item, LocTo)
	--	select det.Id, det.Item, det.LocTo 
	--	from #tempFlowDet as det
	--	inner join LE_FlowMstrSnapShot as mstr on det.Flow = mstr.Flow
	--	inner join #tempCompleteFlowDet as cDet on (cDet.Item = det.Item and cDet.LocTo = det.LocFrom) --�ɹ�·��������·��
	--	where not exists(select top 1 1 from #tempCompleteFlowDet tDet where tDet.FlowDetRowId = det.Id)  --���˵��Ѿ���ӵ�����·�߱��е�·����ϸ
		
	--	if @@ROWCOUNT = 0
	--	begin
	--		break
	--	end
	--end
	
	--insert into #temp_LOG_SnapshotFlowDet4LeanEngine(Flow, Lvl, ErrorId, Item, LocFrom, LocTo, Msg)
	--select distinct det.Flow, 22, 16, det.Item, det.LocFrom, det.LocTo, N'��Ϊ·�߲�����ɾ�����' + det.Item + N'��Դ��λ' + det.LocFrom + N'Ŀ�Ŀ�λ' + det.LocTo + N'��·��' 
	--from #tempFlowDet as det 
	--left join #tempCompleteFlowDet as cDet on det.Id = cDet.FlowDetRowId
	--where cDet.FlowDetRowId is null
	
	--delete det 
	--from #tempFlowDet as det 
	--left join #tempCompleteFlowDet as cDet on det.Id = cDet.FlowDetRowId
	--where cDet.FlowDetRowId is null
	-------------------������·���Ƿ�����-----------------------
	
	
	
	-------------------���������ϵ����Ŀ�λ�Ͳɹ����ص�ƥ�䣬���ȱʧ��·��-----------------------
	--��¼��־
	set @Msg = N'�����������Ŀ�λ�Ͳɹ����ص�ƥ�䣬���ȱʧ���ƿ�·�߿�ʼ'
	insert into #temp_LOG_SnapshotFlowDet4LeanEngine(Lvl, Msg) values(0, @Msg)
	
	--���氰���ͱ������Ĺ�������
	select distinct wc.WorkCenter into #tempWorkCenter from SCM_FlowMstr as mstr
	inner join PRD_ProdLineWorkCenter as wc on mstr.Code = wc.Flow
	where mstr.Code in (
	select TransFlow from CUST_ProductLineMap where [Type] = 1 and IsActive = 1
	UNION ALL
	select SaddleFlow from CUST_ProductLineMap where [Type] = 1 and IsActive = 1)
	and mstr.IsActive = 1
	
	--��������������������+����+��λ��
	insert into #tempOrderBom(Item, Location, IsMatch)
	select Item, Location, 0 from LE_OrderBomCPTimeSnapshot as bom
	where WorkCenter not in (select WorkCenter from #tempWorkCenter)
	group by Item, Location
	
	--ɾ�������ͱ������Ĺ������ĵĻ����
	drop table #tempWorkCenter
	
	--���¿�λ����
	update bom set Region = loc.Region
	from #tempOrderBom as bom inner join MD_Location as loc on bom.Location = loc.Code
	
	
	--���ܲɹ����ص㣨����+����+��λ��
	insert into #tempPurchase(Item, Region, Location)
	--select det.Item, mstr.PartyTo as Region, ISNULL(det.LocTo, mstr.LocTo) as Location 
	select det.Item, mstr.PartyTo as Region, mstr.LocTo as Location 
	from SCM_FlowDet as det inner join SCM_FlowMstr as mstr 
	on det.Flow = mstr.Code
	where mstr.[Type] in (1, 5, 6, 8) and mstr.IsActive = 1 --and det.IsActive = 1
	
	--�����ƿ�·��
	insert into #tempTransfer(Item, PartyFrom, PartyTo, LocFrom, LocTo)
	--select det.Item, mstr.PartyFrom, mstr.PartyTo, ISNULL(det.LocFrom, mstr.LocFrom) as LocFrom, ISNULL(det.LocTo, mstr.LocTo) as LocTo
	select det.Item, mstr.PartyFrom, mstr.PartyTo, mstr.LocFrom, mstr.LocTo
	from SCM_FlowDet as det inner join SCM_FlowMstr as mstr 
	on det.Flow = mstr.Code
	where mstr.[Type] in (2, 7) and mstr.IsActive = 1 --and det.IsActive = 1
	
	--��һ��ƥ�䣬���Ŀ�λ�Ͳɹ����ص���ͬ
	update bom set IsMatch = 1
	from #tempOrderBom as bom
	inner join #tempPurchase as pur on bom.Item = pur.Item and bom.Location = pur.Location
	
	--�ڶ���ƥ�䣬���Ŀ�λ�Ͳɹ����ص�ͨ���ƿ�·�߹���
	if exists (select top 1 1 from #tempOrderBom where IsMatch = 0)
	begin
		update bom set IsMatch = 1
		from #tempOrderBom as bom
		inner join #tempTransfer as tra on bom.Item = tra.Item and bom.Location = tra.LocTo
		inner join #tempPurchase as pur on tra.Item = pur.Item and tra.LocFrom = pur.Location
		where bom.IsMatch = 0
	end
	
	--������ƥ�䣬���Ŀ�λ�Ͳɹ����ص�ͨ��2���ƿ�·�߹���
	if exists (select top 1 1 from #tempOrderBom where IsMatch = 0)
	begin
		update bom set IsMatch = 1
		from #tempOrderBom as bom
		inner join #tempTransfer as tra1 on bom.Item = tra1.Item and bom.Location = tra1.LocTo
		inner join #tempTransfer as tra2 on tra1.Item = tra2.Item and tra1.LocFrom = tra2.LocTo
		inner join #tempPurchase as pur on tra2.Item = pur.Item and tra2.LocFrom = pur.Location
		where bom.IsMatch = 0
	end
	
	-------------------����һ���������Ӳɹ����ص㵽�����������Ŀ�λ���ƿ�·��,������ͬ-----------------------
	if exists (select top 1 1 from #tempOrderBom where IsMatch = 0)
	begin
		--��¼��־
		insert into #temp_LOG_SnapshotFlowDet4LeanEngine(Lvl, ErrorId, Item, LocFrom, LocTo, Msg)
		select distinct 1, 13, bom.Item, pur.Location, bom.Location, N'������' + bom.Item + N'�Ӳɹ����ص�' + pur.Location + N'�������������Ŀ�λ' + bom.Location + N'���ƿ�·��'
		from #tempOrderBom as bom
		inner join #tempPurchase as pur on bom.Item = pur.Item and bom.Region = pur.Region
		inner join LE_FlowMstrSnapShot as mstr on mstr.PartyFrom = pur.Region and mstr.PartyTo = bom.Region and mstr.Strategy = 3
		where bom.IsMatch = 0
		
		insert into #tempFlowDet(Flow, FlowDetId, Item, UOM, UC, MinUC, ManufactureParty,
		LocFrom, LocTo, Routing,
		ExtraDmdSource,
		IsRefFlow, MrpTotal, MrpTotalAdj, MrpWeight,
		SafeStock, MaxStock, MinLotSize, RoundUpOpt, Strategy,
		Container, ContainerDesc, UCDesc)
		select distinct mstr.Flow, 0, bom.Item, item.UOM, item.MinUC, item.MinUC, null,  
		pur.Location, bom.Location, null,
		null,
		0, 0, 0, 0,
		ISNULL(pref.SafeStock, 0), ISNULL(pref.MaxStock, 0), 0, 0, 3,
		item.Container, item.ContainerDesc, null
		from #tempOrderBom as bom
		inner join #tempPurchase as pur on bom.Item = pur.Item and bom.Region = pur.Region
		inner join MD_Item as item on bom.Item = item.Code
		inner join LE_FlowMstrSnapShot as mstr on mstr.PartyFrom = pur.Region and mstr.PartyTo = bom.Region and mstr.Strategy = 3
		left join INV_LocationDetPref as pref on bom.Item = pref.Item and bom.Location = pref.Location
		where bom.IsMatch = 0
		
		update bom set IsMatch = 1
		from #tempOrderBom as bom
		inner join #tempPurchase as pur on bom.Item = pur.Item and bom.Region = pur.Region
		inner join LE_FlowMstrSnapShot as mstr on mstr.PartyFrom = pur.Region and mstr.PartyTo = bom.Region and mstr.Strategy = 3
		where bom.IsMatch = 0
	end
	-------------------����һ���������Ӳɹ����ص㵽�����������Ŀ�λ���ƿ�·��,������ͬ-----------------------
	
	-------------------���ڶ������������ƿ�·�߳����λ�������������Ŀ�λ���ƿ�·�ߣ�������ͬ�����ȱʧ��Buffer���߱ߵ��ƿ�·�ߣ�-----------------------
	if exists (select top 1 1 from #tempOrderBom where IsMatch = 0)
	begin
		--��¼��־
		insert into #temp_LOG_SnapshotFlowDet4LeanEngine(Lvl, ErrorId, Item, LocFrom, LocTo, Msg)
		select distinct 1, 14, bom.Item, tra.LocTo, bom.Location, N'������' + bom.Item + N'���ƿ�·������λ' + tra.LocTo + N'�������������Ŀ�λ' + bom.Location + N'���ƿ�·��'
		from #tempOrderBom as bom
		inner join #tempTransfer as tra on bom.Item = tra.Item and bom.Region = tra.PartyTo
		inner join #tempPurchase as pur on tra.Item = pur.Item and tra.LocFrom = pur.Location
		inner join LE_FlowMstrSnapShot as mstr on mstr.LocFrom = tra.LocTo and mstr.LocTo = bom.Location and mstr.Strategy = 3
		where bom.IsMatch = 0
		
		insert into #tempFlowDet(Flow, FlowDetId, Item, UOM, UC, MinUC, ManufactureParty,
		LocFrom, LocTo, Routing,
		ExtraDmdSource,
		IsRefFlow, MrpTotal, MrpTotalAdj, MrpWeight,
		SafeStock, MaxStock, MinLotSize, RoundUpOpt, Strategy,
		Container, ContainerDesc, UCDesc)
		select distinct mstr.Flow, 0, bom.Item, item.UOM, item.MinUC, item.MinUC, null,  
		tra.LocTo, bom.Location, null,
		null,
		0, 0, 0, 0,
		ISNULL(pref.SafeStock, 0), ISNULL(pref.MaxStock, 0), 0, 0, 3,
		item.Container, item.ContainerDesc, null
		from #tempOrderBom as bom
		inner join #tempTransfer as tra on bom.Item = tra.Item and bom.Region = tra.PartyTo
		inner join #tempPurchase as pur on tra.Item = pur.Item and tra.LocFrom = pur.Location
		inner join MD_Item as item on bom.Item = item.Code
		inner join LE_FlowMstrSnapShot as mstr on mstr.LocFrom = tra.LocTo and mstr.LocTo = bom.Location and mstr.Strategy = 3
		left join INV_LocationDetPref as pref on bom.Item = pref.Item and bom.Location = pref.Location
		where bom.IsMatch = 0
		
		update bom set IsMatch = 1
		from #tempOrderBom as bom
		inner join #tempTransfer as tra on bom.Item = tra.Item and bom.Region = tra.PartyTo
		inner join #tempPurchase as pur on tra.Item = pur.Item and tra.LocFrom = pur.Location
		inner join LE_FlowMstrSnapShot as mstr on mstr.LocFrom = tra.LocTo and mstr.LocTo = bom.Location and mstr.Strategy = 3
		where bom.IsMatch = 0
	end
	-------------------���ڶ������������ƿ�·�߳����λ�������������Ŀ�λ���ƿ�·�ߣ�������ͬ�����ȱʧ��Buffer���߱ߵ��ƿ�·�ߣ�-----------------------
	
	-------------------���������������Ӳɹ����ص㵽�����������Ŀ�λ���ƿ�·�ߣ�������ͬ��ԭ�������Ŀ�λ�Ͳɹ�·�߿�λ��ͬ-----------------------
	if exists (select top 1 1 from #tempOrderBom where IsMatch = 0)
	begin
		--��¼��־
		insert into #temp_LOG_SnapshotFlowDet4LeanEngine(Lvl, ErrorId, Item, LocFrom, LocTo, Msg)
		select distinct 1, 14, bom.Item, pur.Location, bom.Location, N'������' + bom.Item + N'�Ӳɹ����ص�' + pur.Location + N'�������������Ŀ�λ' + bom.Location + N'���ƿ�·��'
		from #tempOrderBom as bom
		inner join #tempPurchase as pur on bom.Item = pur.Item
		inner join LE_FlowMstrSnapShot as mstr on mstr.PartyFrom = pur.Region and mstr.PartyTo = bom.Region and mstr.Strategy = 3
		where bom.IsMatch = 0
		
		insert into #tempFlowDet(Flow, FlowDetId, Item, UOM, UC, MinUC, ManufactureParty,
		LocFrom, LocTo, Routing,
		ExtraDmdSource,
		IsRefFlow, MrpTotal, MrpTotalAdj, MrpWeight,
		SafeStock, MaxStock, MinLotSize, RoundUpOpt, Strategy,
		Container, ContainerDesc, UCDesc)
		select distinct mstr.Flow, 0, bom.Item, item.UOM, item.MinUC, item.MinUC, null,  
		pur.Location, bom.Location, null,
		null,
		0, 0, 0, 0,
		ISNULL(pref.SafeStock, 0), ISNULL(pref.MaxStock, 0), 0, 0, 3,
		item.Container, item.ContainerDesc, null
		from #tempOrderBom as bom
		inner join #tempPurchase as pur on bom.Item = pur.Item
		inner join MD_Item as item on bom.Item = item.Code
		inner join LE_FlowMstrSnapShot as mstr on mstr.LocFrom = pur.Location and mstr.LocTo = bom.Location and mstr.Strategy = 3
		left join INV_LocationDetPref as pref on bom.Item = pref.Item and bom.Location = pref.Location
		where bom.IsMatch = 0
		
		update bom set IsMatch = 1
		from #tempOrderBom as bom
		inner join #tempPurchase as pur on bom.Item = pur.Item
		inner join LE_FlowMstrSnapShot as mstr on mstr.LocFrom = pur.Location and mstr.LocTo = bom.Location and mstr.Strategy = 3
		where bom.IsMatch = 0
	end
	-------------------���������������Ӳɹ����ص㵽�����������Ŀ�λ���ƿ�·�ߣ�������ͬ��ԭ�������Ŀ�λ�Ͳɹ�·�߿�λ��ͬ-----------------------
	
	-------------------�����Ĵ��������Ӳɹ����ص㵽�����������Ŀ�λ���ƿ�·�ߣ�������ͬ��ԭ�������Ŀ�λ�Ͳɹ�·�߿�λ����ͬ-----------------------
	if exists (select top 1 1 from #tempOrderBom where IsMatch = 0)
	begin
		--��¼��־
		insert into #temp_LOG_SnapshotFlowDet4LeanEngine(Lvl, ErrorId, Item, LocFrom, LocTo, Msg)
		select distinct 1, 14, bom.Item, pur.Location, bom.Location, N'������' + bom.Item + N'�Ӳɹ����ص�' + pur.Location + N'�������������Ŀ�λ' + bom.Location + N'���ƿ�·��'
		from #tempOrderBom as bom
		inner join #tempPurchase as pur on bom.Item = pur.Item
		inner join LE_FlowMstrSnapShot as mstr on mstr.PartyFrom = pur.Region and mstr.PartyTo = bom.Region and mstr.Strategy = 3
		where bom.IsMatch = 0
		
		insert into #tempFlowDet(Flow, FlowDetId, Item, UOM, UC, MinUC, ManufactureParty,
		LocFrom, LocTo, Routing,
		ExtraDmdSource,
		IsRefFlow, MrpTotal, MrpTotalAdj, MrpWeight,
		SafeStock, MaxStock, MinLotSize, RoundUpOpt, Strategy,
		Container, ContainerDesc, UCDesc)
		select distinct mstr.Flow, 0, bom.Item, item.UOM, item.MinUC, item.MinUC, null,  
		pur.Location, bom.Location, null,
		null,
		0, 0, 0, 0,
		ISNULL(pref.SafeStock, 0), ISNULL(pref.MaxStock, 0), 0, 0, 3,
		item.Container, item.ContainerDesc, null
		from #tempOrderBom as bom
		inner join #tempPurchase as pur on bom.Item = pur.Item
		inner join MD_Item as item on bom.Item = item.Code
		inner join LE_FlowMstrSnapShot as mstr on mstr.PartyFrom = pur.Region and mstr.PartyTo = bom.Region and mstr.Strategy = 3
		left join INV_LocationDetPref as pref on bom.Item = pref.Item and bom.Location = pref.Location
		where bom.IsMatch = 0
		
		update bom set IsMatch = 1
		from #tempOrderBom as bom
		inner join #tempPurchase as pur on bom.Item = pur.Item
		inner join LE_FlowMstrSnapShot as mstr on mstr.PartyFrom = pur.Region and mstr.PartyTo = bom.Region and mstr.Strategy = 3
		where bom.IsMatch = 0
	end
	-------------------�����Ĵ��������Ӳɹ����ص㵽�����������Ŀ�λ���ƿ�·�ߣ�������ͬ��ԭ�������Ŀ�λ�Ͳɹ�·�߿�λ����ͬ-----------------------
	
	-------------------��û���ҵ��ɹ����ص�-----------------------
	if exists (select top 1 1 from #tempOrderBom where IsMatch = 0)
	begin
		--��¼��־
		insert into #temp_LOG_SnapshotFlowDet4LeanEngine(Lvl, ErrorId, Item, LocTo, Msg)
		select distinct 1, 15, bom.Item, bom.Location, N'���' + bom.Item + N'�����������Ŀ�λ' + bom.Location + N'û���ҵ��ɹ����ص��û�д����Ӳɹ�·�����������Ŀ�λ���ƿ�·��'
		from #tempOrderBom as bom inner join MD_Item as i on bom.Item = i.Code 
		where bom.IsMatch = 0 and i.BESKZ not in('E', 'X') --���˵����Ƽ�
	end
	-------------------��û���ҵ��ɹ����ص�-----------------------
	
	--��¼��־
	set @Msg = N'�����������Ŀ�λ�Ͳɹ����ص�ƥ�䣬���ȱʧ���ƿ�·�߽���'
	insert into #temp_LOG_SnapshotFlowDet4LeanEngine(Lvl, Msg) values(0, @Msg)
	-------------------���������ϵ����Ŀ�λ�Ͳɹ����ص�ƥ�䣬���ȱʧ��·��-----------------------
	
	
	
	-------------------���๩Ӧ�̹�����ѡȡ��Ӧ��-----------------------
	--��¼��־
	set @Msg = N'ѡȡ�����Ŀ�Ŀ�λ��ͬ��·����ϸ��ʼ'
	insert into #temp_LOG_SnapshotFlowDet4LeanEngine(Lvl, Msg) values(0, @Msg)
	
	-------------------��ɾ�������Ŀ�Ŀ�λ��JIT·����ͬ�Ŀ���·��-----------------------
	--JIT���������ȼ����ڿ��幩��
	--��¼��־
	insert into #temp_LOG_SnapshotFlowDet4LeanEngine(Flow, Lvl, ErrorId, Item, LocTo, Msg)
	select distinct det2.Flow, 1, 16, det2.Item, det2.LocTo, N'ɾ�����' + det2.Item + N'Ŀ�Ŀ�λ' + det2.LocTo + N'��JIT·����ͬ�Ŀ���·��' 
	from #tempFlowDet as det2
	inner join LE_FlowMstrSnapShot as mstr2 on det2.Flow = mstr2.Flow
	inner join (select det.Item, det.LocTo
				from #tempFlowDet as det 
				inner join LE_FlowMstrSnapShot as mstr on det.Flow = mstr.Flow
				where mstr.Strategy = 3 group by det.Item, det.LocTo) as det3
	on det2.Item = det3.Item and det2.LocTo = det3.LocTo
	where mstr2.Strategy = 2
	
	delete det2 
	from #tempFlowDet as det2
	inner join LE_FlowMstrSnapShot as mstr2 on det2.Flow = mstr2.Flow
	inner join (select det.Item, det.LocTo 
				from #tempFlowDet as det 
				inner join LE_FlowMstrSnapShot as mstr on det.Flow = mstr.Flow
				where mstr.Strategy = 3 group by det.Item, det.LocTo) as det3
	on det2.Item = det3.Item and det2.LocTo = det3.LocTo
	where mstr2.Strategy = 2
	-------------------��ɾ�������Ŀ�Ŀ�λ��JIT·����ͬ�Ŀ���·��-----------------------
	
	-------------------���������ѡ��๩Ӧ�̹�����·��-----------------------
	--��¼��־
	insert into #temp_LOG_SnapshotFlowDet4LeanEngine(Flow, Lvl, ErrorId, Item, LocTo, Msg)
	select distinct det.Flow, 1, 20, det.Item, det.LocTo, N'�������ѡ��Ӧ��' + cDet.Supplier + N'·��' + cDet.Flow + N'ɾ��·��' + det.Flow + N'���' + det.Item + N'Ŀ�Ŀ�λ' + det.LocTo + N'��·��' 
	from #tempFlowDet as det 
	inner join LE_FlowMstrSnapShot as mstr on det.Flow = mstr.Flow
	inner join (select det.Id, det.Flow, det.Item, det.LocTo, lq.Supplier
				from #tempFlowDet as det 
				inner join LE_FlowMstrSnapShot as mstr on det.Flow = mstr.Flow
				inner join LE_QuotaSnapShot as lq on det.Item = lq.Item and mstr.PartyFrom = lq.Supplier
				where mstr.[Type] = 1) as cDet --��ǰ�����Ĳɹ�·����ϸ
				on det.Item = cDet.Item and det.LocTo = cDet.LocTo and det.Id <> cDet.Id and mstr.PartyFrom <> cDet.Supplier
	where mstr.[Type] = 1   --ֻ���˵��ɹ���·��
	
	delete det
	from #tempFlowDet as det 
	inner join LE_FlowMstrSnapShot as mstr on det.Flow = mstr.Flow
	inner join (select det.Id, det.Item, det.LocTo 
				from #tempFlowDet as det 
				inner join LE_FlowMstrSnapShot as mstr on det.Flow = mstr.Flow
				inner join LE_QuotaSnapShot as lq on det.Item = lq.Item and mstr.PartyFrom = lq.Supplier
				where mstr.[Type] = 1) as cDet --��ǰ�����Ĳɹ�·����ϸ
				on det.Item = cDet.Item and det.LocTo = cDet.LocTo and det.Id <> cDet.Id
	where mstr.[Type] = 1   --ֻ���˵��ɹ���·��
	-------------------���������ѡ��๩Ӧ�̹�����·��-----------------------
	
	-------------------���������Ŀ�Ŀ�λ����-----------------------
	truncate table #tempMultiSupplierGroup
	insert into #tempMultiSupplierGroup(Item, LocTo)
	select Item, LocTo from #tempFlowDet
	where LocTo is not null
	group by Item, LocTo having COUNT(1) > 1 
	
	truncate table #tempMultiSupplierItem
	insert into #tempMultiSupplierItem(FlowDetRowId, Flow, Item, LocTo, MSGRowId, MrpTotal, MrpTotalAdj, MrpWeight)
	select det.Id, det.Flow, det.Item, det.LocTo, msg.RowId, det.MrpTotal, det.MrpTotalAdj, det.MrpWeight
	from #tempFlowDet as det
	inner join #tempMultiSupplierGroup as msg on det.Item = msg.Item and det.LocTo = msg.LocTo
	-------------------���������Ŀ�Ŀ�λ����-----------------------		
	
	-------------------�������Ŀ�Ŀ�λ��ͬ��·�߶�û�����ù���ѭ�������������װ����ѭ����-----------------------
	--��¼��־
	insert into #temp_LOG_SnapshotFlowDet4LeanEngine(Flow, Lvl, ErrorId, Item, LocTo, Msg)
	select distinct Flow, 1, 17, Item, LocTo, N'���Ϊ' + Item + N'Ŀ�Ŀ�λΪ' + LocTo + N'��·�߶�û�����ù���ѭ�������������װ����ѭ����' 
	from #tempMultiSupplierItem where MSGRowId in (select MSGRowId from #tempMultiSupplierItem group by MSGRowId having SUM(MrpWeight) = 0)
	
	update tmp set MrpWeight = (CASE WHEN det.UC = 0 THEN 1 ELSE det.UC END)
	from #tempMultiSupplierItem as tmp
	inner join #tempFlowDet as det on det.Id = tmp.FlowDetRowId
	where tmp.MSGRowId in (select MSGRowId from #tempMultiSupplierItem group by MSGRowId having SUM(MrpWeight) = 0)
	-------------------�������Ŀ�Ŀ�λ��ͬ��·�߶�û�����ù���ѭ�������������װ����ѭ����-----------------------
	
	-------------------�������Ŀ�Ŀ�λ��ͬ��·��û�����ù���ѭ������������Щ·����ϸ-----------------------
	insert into #temp_LOG_SnapshotFlowDet4LeanEngine(Flow, Lvl, ErrorId, Item, LocTo, Msg)
	select distinct Flow, 1, 18, Item, LocTo, N'���Ϊ' + Item + N'Ŀ�Ŀ�λΪ' + LocTo + N'��·��û�����ù���ѭ���������Ը���·����ϸ'
	from #tempMultiSupplierItem where MSGRowId in (select MSGRowId from #tempMultiSupplierItem where MrpWeight = 0)
	
	delete #tempFlowDet where Id in (select FlowDetRowId from #tempMultiSupplierItem where MrpWeight = 0)
	delete #tempMultiSupplierItem where FlowDetRowId in (select FlowDetRowId from #tempMultiSupplierItem where MrpWeight = 0)
	-------------------�������Ŀ�Ŀ�λ��ͬ��·��û�����ù���ѭ������������Щ·����ϸ-----------------------
	
	-------------------�����㹩������������-----------------------
	update #tempMultiSupplierItem set DeliveryCount = (ISNULL(MrpTotal, 0) + ISNULL(MrpTotalAdj, 0)) / MrpWeight, DeliveryBalance = (ISNULL(MrpTotal, 0) + ISNULL(MrpTotalAdj, 0)) % MrpWeight
	-------------------�����㹩������������-----------------------
	
	-------------------�����ݹ���������ѭ����ѡȡһ��·����ϸ����-----------------------
	truncate table #tempSortedMultiSupplierItem
	
	insert into #tempSortedMultiSupplierItem(GID, FlowDetRowId, Flow)
	select ROW_NUMBER() over(partition by MSGRowId order by DeliveryCount asc, MrpWeight desc, DeliveryBalance desc) as GID, FlowDetRowId, Flow 
	from #tempMultiSupplierItem
	
	--��¼��־
	insert into #temp_LOG_SnapshotFlowDet4LeanEngine(Flow, Lvl, ErrorId, Msg)
	select a.Flow, 1, 30, N'���Ϊ' + b.Item + N'Ŀ�Ŀ�λΪ' + b.LocTo + N'��·����ϸ�ظ���ϵͳ�Զ�ѡȡһ��·����ϸ' 
	from #tempSortedMultiSupplierItem as a inner join #tempMultiSupplierItem as b on a.FlowDetRowId = b.FlowDetRowId 
	where a.GID = 1
	
	delete #tempFlowDet where Id in (select FlowDetRowId from #tempSortedMultiSupplierItem where GID <> 1)
	delete #tempMultiSupplierItem where FlowDetRowId in (select FlowDetRowId from #tempSortedMultiSupplierItem where GID <> 1)
	-------------------�����ݹ���������ѭ����ѡȡһ��·����ϸ����-----------------------
	
	drop table #tempTransfer
	drop table #tempPurchase
	
	set @Msg = N'ѡȡ�����Ŀ�Ŀ�λ��ͬ��·����ϸ����'
	insert into #temp_LOG_SnapshotFlowDet4LeanEngine(Lvl, Msg) values(0, @Msg)
	-------------------���๩Ӧ�̹�����ѡȡ��Ӧ��-----------------------
	


	truncate table LE_FlowDetSnapShot
	insert into LE_FlowDetSnapShot(Flow, FlowDetId, Item, Uom, UC, MinUC, 
	ManufactureParty, LocFrom, LocTo, Routing, IsRefFlow, SafeStock, MaxStock, 
	MinLotSize, RoundUpOpt, Strategy, ExtraDmdSource, Container, ContainerDesc, UCDesc)
	select det.Flow, det.FlowDetId, det.Item, det.Uom, det.UC, det.MinUC,
	det.ManufactureParty, det.LocFrom, det.LocTo, det.Routing, det.IsRefFlow, det.SafeStock, det.MaxStock, 
	det.MinLotSize, det.RoundUpOpt, det.Strategy, det.ExtraDmdSource, det.Container, det.ContainerDesc, det.UCDesc
	from #tempFlowDet as det
	
	
	
	-------------------��������������Դ-----------------------
	truncate table LE_FlowDetExtraDmdSourceSnapshot
	insert into #tempExtraDmdSource(FlowDetSnapShotId, FlowDetLocTo, ExtraDmdSource)
	select Id, LocTo, ExtraDmdSource from LE_FlowDetSnapShot where ExtraDmdSource is not null and ExtraDmdSource <>  ''
	
	declare @SplitSymbol1 char(1) = ','
	declare @SplitSymbol2 char(1) = '|'
	
	declare @FlowDetSnapShotId int
	declare @FlowDetLocTo varchar(50)
	declare @FlowDetRowId int
	declare @MaxFlowDetRowId int
	
	create table #tempFlowDetExtraDmdSource
	(
		FlowDetSnapShotId int,
		Location varchar(50)
	)

	select @FlowDetRowId = MIN(RowId), @MaxFlowDetRowId = MAX(RowId) from #tempExtraDmdSource
	while (@FlowDetRowId <= @MaxFlowDetRowId)
	begin
		select @FlowDetSnapShotId = FlowDetSnapShotId, @FlowDetLocTo = FlowDetLocTo from #tempExtraDmdSource where RowId = @FlowDetRowId
		select @ExtraDmdSource = ExtraDmdSource from LE_FlowDetSnapShot where Id = @FlowDetSnapShotId
		
		if ISNULL(@ExtraDmdSource, '') <> ''
		begin
			if (charindex(@SplitSymbol1, @ExtraDmdSource) <> 0)
				begin
				--ѭ����������Դ���뻺�����
				while(charindex(@SplitSymbol1, @ExtraDmdSource) <> 0)
				begin
					insert #tempFlowDetExtraDmdSource(FlowDetSnapShotId, Location) values (@FlowDetSnapShotId, substring(@ExtraDmdSource, 1, charindex(@SplitSymbol1, @ExtraDmdSource) - 1))
					set @ExtraDmdSource = stuff(@ExtraDmdSource, 1, charindex(@SplitSymbol1, @ExtraDmdSource), ' ')
				end
			end
			else if (charindex(@SplitSymbol2, @ExtraDmdSource) <> 0)
			begin
				--ѭ����������Դ���뻺�����
				while(charindex(@SplitSymbol2, @ExtraDmdSource) <> 0)
				begin
					insert #tempFlowDetExtraDmdSource(FlowDetSnapShotId, Location) values (@FlowDetSnapShotId, substring(@ExtraDmdSource, 1, charindex(@SplitSymbol2, @ExtraDmdSource) - 1))
					set @ExtraDmdSource = stuff(@ExtraDmdSource, 1, charindex(@SplitSymbol2, @ExtraDmdSource), ' ')
				end
			end
			
			insert #tempFlowDetExtraDmdSource(FlowDetSnapShotId, Location) values (@FlowDetSnapShotId, Ltrim(@ExtraDmdSource))
		end
		
		--ɾ����Ŀ�Ŀ�λ��ͬ����������Դ��λ
		delete from #tempFlowDetExtraDmdSource where FlowDetSnapShotId = @FlowDetSnapShotId and Location = @FlowDetLocTo
		set @FlowDetRowId = @FlowDetRowId + 1
	end
	
	
	if exists(select top 1 1 from #tempFlowDetExtraDmdSource)
	begin
		insert into LE_FlowDetExtraDmdSourceSnapshot(FlowDetSnapShotId, Location) select distinct FlowDetSnapShotId, Location from #tempFlowDetExtraDmdSource
	end
	
	drop table #tempFlowDetExtraDmdSource
	-------------------��������������Դ-----------------------
	
	
	--��¼��־
	set @Msg = N'��ȡ·����ϸ����'
	insert into #temp_LOG_SnapshotFlowDet4LeanEngine(Lvl, Msg) values(0, @Msg)
	
	insert into LOG_SnapshotFlowDet4LeanEngine(Flow, Item, LocFrom, LocTo, OrderNo, Lvl, ErrorId, Msg, CreateDate, BatchNo) 
	select Flow, Item, LocFrom, LocTo, OrderNo, Lvl, ErrorId, Msg, CreateDate, @BatchNo from #temp_LOG_SnapshotFlowDet4LeanEngine
	
	drop table #temp_LOG_SnapshotFlowDet4LeanEngine
	drop table #tempExtraDmdSource
	drop table #tempOrderBom
	drop table #tempSortedMultiSupplierItem
	drop table #tempMultiSupplierItem
	drop table #tempMultiSupplierGroup
	drop table #tempFlowDet
	drop table #tempCompleteFlowDet
END
GO

