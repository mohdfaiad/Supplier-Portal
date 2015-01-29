SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF EXISTS(SELECT * FROM SYS.objects WHERE type='P' AND name='USP_LE_ManualGenOrder')
	DROP PROCEDURE USP_LE_ManualGenOrder
GO

CREATE PROCEDURE [dbo].[USP_LE_ManualGenOrder]
(
	@ProdOrderNo varchar(50),
	@WindowTime datetime,
	@Priority tinyint,
	@SAPProdLine varchar(50),
	@CreateUserId int,
	@CreateUserNm varchar(50)
)
--WITH ENCRYPTION
AS
BEGIN
	SET NOCOUNT ON
	declare @DateTimeNow datetime = GetDate()
	declare @Msg nvarchar(Max)
	declare @trancount int
	
	Create table #tempMsg
	(
		Lvl tinyint,
		Msg varchar(max)
	)
	
	Create table #tempDuplicateOpRef
	(
		Item varchar(50),
		Location varchar(50)
	)
	
	Create table #tempOrderBomDetTotal
	(
		Item varchar(50),
		Location varchar(50),
		OpRef varchar(50),
		RefOpRef varchar(50),
		OrderQty decimal(18, 8),
		ManufactureParty varchar(50)
	)
	
	Create table #tempCreatedOrderDet
	(
		Item varchar(50),
		LocTo varchar(50),
		OpRef varchar(50),
		OrderQty decimal(18, 8),
		ManufactureParty varchar(50)
	)
	
	Create table #tempOrderBomDetTBD
	(
		Item varchar(50),
		Location varchar(50),
		OpRef varchar(50),
		RefOpRef varchar(50),
		OrderQty decimal(18, 8),
		IsMatch bit,
		ManufactureParty varchar(50)
	)
	
	Create table #tempItemLocationTBD
	(
		Item varchar(50),
		Location varchar(50)
	)
	
	Create table #tempConsumedOpRefBalance
	(
		Item varchar(50),
		OpRef varchar(50),
		ConsumeQty decimal(18, 8),
	)
	
	Create table #tempThisConsumeOpRefBalance
	(
		Item varchar(50),
		OpRef varchar(50),
		ConsumeQty decimal(18, 8),
	)
	
	create table #tempPurchase
	(
		Flow varchar(50),
		Item varchar(50),
		Location varchar(50),
		Uom varchar(5),
		UC decimal(18, 8),
		MrpTotal decimal(18, 8),
		MrpTotalAdj decimal(18, 8),
		MrpWeight int,
	)
		
	create table #tempFlowDet
	(
		Id int identity(1, 1),
		Flow varchar(50),
		FlowType tinyint,
		FlowDetId int,
		--MSGId int,
		Item varchar(50),
		Uom varchar(5),
		UC decimal(18, 8),
		MinUC decimal(18, 8),
		UCDesc varchar(50),
		Container varchar(50),
		ContainerDesc varchar(50),
		LocFrom varchar(50),
		LocTo varchar(50),
		--OpRef varchar(50),
		MrpTotal decimal(18, 8),
		MrpTotalAdj decimal(18, 8),
		MrpWeight int,
		DeliveryCount int,
		DeliveryBalance int,
		--ReqQty decimal(18, 8),
		--OrderQty decimal(18, 8),
		RoundUpOpt tinyint,
		--OrderNo varchar(50),
		--OrderDetId int,
		--OrderDetSeq int,
		--ManufactureParty varchar(50)
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
	
	create table #tempOrderDet
	(
		RowId int identity(1, 1),
		Flow varchar(50),
		FlowDetId int,
		Item varchar(50),
		Uom varchar(5),
		UC decimal(18, 8),
		MinUC decimal(18, 8),
		UCDesc varchar(50),
		Container varchar(50),
		ContainerDesc varchar(50),
		LocFrom varchar(50),
		LocTo varchar(50),
		OpRef varchar(50),
		RefOpRef varchar(256),
		MrpTotal decimal(18, 8),
		MrpTotalAdj decimal(18, 8),
		MrpWeight int,
		DeliveryCount int,
		DeliveryBalance int,
		NetReqQty decimal(18, 8),
		OpRefQty decimal(18, 8),
		ReqQty decimal(18, 8),
		OrderQty decimal(18, 8),
		Balance decimal(18, 8),
		RoundUpOpt tinyint,
		OrderNo varchar(50),
		OrderDetId int,
		OrderDetSeq int,
		ManufactureParty varchar(50)
	)
	
	Create table #tempFlowMstr
	(
		RowId int identity(1, 1),
		Flow varchar(50),
		LocTo varchar(50)
	)
	
	Create table #tempOrderDetId
	(
		RowId int,
		OrderDetId int,
		OrderDetSeq int
	)
	
	declare @ProdOrderStartTime datetime
	declare @DAUAT varchar(50)
	declare @OrderStrategy tinyint
	select @ProdOrderStartTime = StartTime, @DAUAT = ShipFromTel from ORD_OrderMstr_4 where OrderNo = @ProdOrderNo
	
	--Z901	10	������������
	--Z902	10	MTS��������
	--Z903	10	��Ʒ������������
	--Z904	10	CKD��������
	--Z90R	10	������������
	--ZP01	10	�з����������� 
	--ZP02	10	���Ƴ��������� 
	if (@DAUAT = 'Z902')
	begin
		--���Ƽ�
		set @OrderStrategy = 12
	end
	else if (@DAUAT = 'Z903')
	begin
		--��Ʒ����
		set @OrderStrategy = 9
	end
	else if (@DAUAT = 'Z904')
	begin
		--CKD
		set @OrderStrategy = 11
	end
	else if (@DAUAT = 'Z90R')
	begin
		--����
		set @OrderStrategy = 10
	end
	else if (@DAUAT = 'ZP01' or @DAUAT = 'ZP02')
	begin
		--����
		set @OrderStrategy = 8
	end
	else
	begin
		--�ֹ�
		set @OrderStrategy = 1
	end
	
	-------------------�����¹�λ-----------------------
	if @SAPProdline is not null
	begin
		set @trancount = @@trancount
		begin try
			if @trancount = 0
			begin
				begin tran
			end

			-------------------��������ѡ��λ-----------------------
			--��¼�ظ���λ
			insert into #tempDuplicateOpRef(Item, Location)
			select bom.Item, bom.Location
			from ORD_OrderBomDet as bom
			inner join CUST_OpRefMap as map on bom.Item = map.Item and bom.Location = map.Location
			where bom.OrderNo = @ProdOrderNo and (bom.OpRef is null or bom.OpRef = '')
			and map.SAPProdLine = @SAPProdline and map.IsPrimary = 1
			group by bom.Item, bom.Location
			having COUNT(distinct map.OpRef) > 1
				
			--����Bom��λ
			update bom set OpRef = map.OpRef, RefOpRef = map.RefOpRef
			from ORD_OrderBomDet as bom
			inner join (select bom.Item, bom.Location from ORD_OrderBomDet as bom
						inner join CUST_OpRefMap as map on bom.Item = map.Item and bom.Location = map.Location
						where bom.OrderNo = @ProdOrderNo and (bom.OpRef is null or bom.OpRef = '')
						and map.SAPProdLine = @SAPProdline and map.IsPrimary = 1
						group by bom.Item, bom.Location
						having COUNT(distinct map.OpRef) = 1) as t on bom.Item = t.Item and bom.Location = t.Location
			inner join CUST_OpRefMap as map on bom.Item = map.Item and bom.Location = map.Location
			where bom.OrderNo = @ProdOrderNo and (bom.OpRef is null or bom.OpRef = '') and map.SAPProdLine = @SAPProdline and map.IsPrimary = 1
			-------------------��������ѡ��λ-----------------------
			
			-------------------����������ѡ��λ-----------------------
			--��¼�ظ���λ
			insert into #tempDuplicateOpRef(Item, Location)
			select bom.Item, bom.Location
			from ORD_OrderBomDet as bom
			inner join CUST_OpRefMap as map on bom.Item = map.Item and bom.Location = map.Location
			where bom.OrderNo = @ProdOrderNo and (bom.OpRef is null or bom.OpRef = '')
			and map.SAPProdLine = @SAPProdline
			group by bom.Item, bom.Location 
			having COUNT(distinct map.OpRef) > 1
			
			--����Bom��λ
			update bom set OpRef = map.OpRef, RefOpRef = map.RefOpRef
			from ORD_OrderBomDet as bom
			inner join (select bom.Item, bom.Location from ORD_OrderBomDet as bom
						inner join CUST_OpRefMap as map on bom.Item = map.Item and bom.Location = map.Location
						where bom.OrderNo = @ProdOrderNo and (bom.OpRef is null or bom.OpRef = '')
						and map.SAPProdLine = @SAPProdline
						group by bom.Item, bom.Location
						having COUNT(distinct map.OpRef) = 1) as t on bom.Item = t.Item and bom.Location = t.Location
			inner join CUST_OpRefMap as map on bom.Item = map.Item and bom.Location = map.Location
			where bom.OrderNo = @ProdOrderNo and (bom.OpRef is null or bom.OpRef = '') and map.SAPProdLine = @SAPProdline
			-------------------����������ѡ��λ-----------------------

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
			
			set @Msg = N'���¹�λʧ�ܣ�ʧ����Ϣ��' + Error_Message()
			insert into #tempMsg(Lvl, Msg) values(1, @Msg)
			
			select Lvl, Msg from #tempMsg
	
			drop table #tempConsumedOpRefBalance
			drop table #tempThisConsumeOpRefBalance
			drop table #tempFlowMstr
			drop table #tempOrderDetId
			drop table #tempOrderDet
			drop table #tempPurchase
			drop table #tempItemLocationTBD
			drop table #tempOrderBomDetTBD
			drop table #tempCreatedOrderDet
			drop table #tempOrderBomDetTotal
			drop table #tempMsg
			drop table #tempMultiSupplierGroup
			drop table #tempMultiSupplierItem
			drop table #tempSortedMultiSupplierItem
			drop table #tempDuplicateOpRef 
			
			return
		end catch
	end
	
	--��¼�����λ�����ϵ���־
	insert into #tempMsg(Lvl, Msg)
	select distinct 1, N'���' + ref.Item + N'��λ' + ref.Location + N'�ҵ������λ���޷��������ϵ���'
	from #tempDuplicateOpRef as ref inner join MD_Item as i on ref.Item = i.Code
	where i.BESKZ <> 'E'
	-------------------�����¹�λ-----------------------	
	
	-------------------����ȡ����Bom����-----------------------
	insert into #tempOrderBomDetTotal(Item, Location, OpRef, RefOpRef, OrderQty, ManufactureParty)
	select bom.Item, bom.Location, ISNULL(bom.OpRef, ''), bom.RefOpRef, SUM(bom.OrderQty) as OrderQty, bom.ManufactureParty 
	from ORD_OrderBomDet as bom
	left join CUST_ManualGenOrderIgnoreWorkCenter as wc on bom.WorkCenter = wc.WorkCenter
	left join #tempDuplicateOpRef as te on bom.Item = te.Item and bom.Location = te.Location  --���˵���λ�ظ�������
	where bom.OrderNo = @ProdOrderNo and wc.WorkCenter is null and te.Item is null
	group by bom.Item, bom.Location, ISNULL(bom.OpRef, ''), bom.RefOpRef, bom.ManufactureParty
	having SUM(bom.OrderQty) > 0
	-------------------����ȡ����Bom����-----------------------
	
	-------------------����ȡ�Ѵ��������ϵ�-----------------------
	insert into #tempCreatedOrderDet(Item, LocTo, OrderQty, OpRef, ManufactureParty)
	select det.Item, det.LocTo, SUM(det.OrderQty) as OrderQty, det.OpRef, det.ManufactureParty
	from (select det.Item, ISNULL(det.LocTo, mstr.LocTo) as LocTo, ISNULL(det.WMSSeq, '') as OpRef, det.OrderQty, det.ManufactureParty
			from CUST_ManualGenOrderTrace as trace
			inner join ORD_OrderDet_1 as det on trace.OrderNo = det.OrderNo
			inner join ORD_OrderMstr_1 as mstr on det.OrderNo = mstr.OrderNo
			where ProdOrderNo = @ProdOrderNo and mstr.[Status] <> 5  --δȡ��
			union all
			select det.Item, ISNULL(det.LocTo, mstr.LocTo) as LocTo, ISNULL(det.WMSSeq, '') as OpRef, det.OrderQty, det.ManufactureParty 
			from CUST_ManualGenOrderTrace as trace
			inner join ORD_OrderDet_2 as det on trace.OrderNo = det.OrderNo
			inner join ORD_OrderMstr_2 as mstr on det.OrderNo = mstr.OrderNo
			where ProdOrderNo = @ProdOrderNo and mstr.[Status] <> 5  --δȡ��
			) as det
	group by det.Item, det.LocTo, det.OpRef, det.ManufactureParty
	-------------------����ȡ�Ѵ��������ϵ�-----------------------
	
	-------------------����ȡ��ռ�õĹ�λ����-----------------------
	insert into #tempConsumedOpRefBalance(Item, OpRef, ConsumeQty)
	select Item, OpRef, SUM(Qty) from CUST_ManualGenOrderOpRefBalanceTrace 
	where ProdOrderNo = @ProdOrderNo
	group by Item, OpRef
	-------------------����ȡ��ռ�õĹ�λ����-----------------------
	
	-------------------����ȡδ��������������-----------------------
	insert into #tempOrderBomDetTBD(Item, Location, OpRef, RefOpRef, OrderQty, IsMatch, ManufactureParty)
	select bom.Item, bom.Location, bom.OpRef, bom.RefOpRef, bom.OrderQty - ISNULL(det.OrderQty, 0) - ISNULL(opRef.ConsumeQty, 0) as ReqQty, 0 as IsMatch, bom.ManufactureParty 
	from #tempOrderBomDetTotal as bom
	left join #tempCreatedOrderDet as det on bom.Item = det.Item and bom.Location = det.LocTo and bom.OpRef = det.OpRef
	--and ((bom.ManufactureParty = det.ManufactureParty) or (ISNULL(bom.ManufactureParty, '') = '' and ISNULL(det.ManufactureParty, '') = ''))
	and ((bom.ManufactureParty = det.ManufactureParty) or ISNULL(bom.ManufactureParty, '') = '')
	left join #tempConsumedOpRefBalance as opRef on bom.Item = OpRef.Item and bom.OpRef = opRef.OpRef and ISNULL(bom.ManufactureParty, '') = ''
	where (bom.OrderQty - ISNULL(det.OrderQty, 0) - ISNULL(opRef.ConsumeQty, 0)) > 0
	-------------------����ȡδ��������������-----------------------
	
	-------------------���ȿ���ʹ�ù�λ����-----------------------
	insert into #tempThisConsumeOpRefBalance(Item, OpRef, ConsumeQty)
	select opRef.Item, opRef.OpRef, CASE WHEN tbd.OrderQty >= opRef.Qty THEN opRef.Qty ELSE OrderQty END
	from SCM_OpRefBalance as opRef
	inner join #tempOrderBomDetTBD as tbd on opRef.Item = tbd.Item and opRef.OpRef = tbd.OpRef
	where opRef.Qty > 0 and ISNULL(tbd.OpRef, '') <> '' and ISNULL(tbd.ManufactureParty, '') = ''
										
	if exists(select top 1 1 from #tempThisConsumeOpRefBalance)
	begin										
		update tbd set OrderQty = OrderQty - cOpRef.ConsumeQty
		from #tempOrderBomDetTBD as tbd 
		inner join #tempThisConsumeOpRefBalance as cOpRef on tbd.Item = cOpRef.Item and tbd.OpRef = cOpRef.OpRef 
		where ISNULL(tbd.OpRef, '') <> '' and ISNULL(tbd.ManufactureParty, '') = ''
		
		delete from #tempOrderBomDetTBD where OrderQty = 0										
												
		set @trancount = @@trancount
		begin try
			if @trancount = 0
			begin
				begin tran
			end
					
			--���¹�λ����
			update opRef set Qty = opRef.Qty - cOpRef.ConsumeQty, LastModifyDate = @DateTimeNow, LastModifyUser = @CreateUserId, LastModifyUserNm = @CreateUserNm, [Version] = [Version] + 1
			from SCM_OpRefBalance as opRef
			inner join #tempThisConsumeOpRefBalance as cOpRef on opRef.Item = cOpRef.Item and opRef.OpRef = cOpRef.OpRef
			
			--���¹�λ������־
			insert into LOG_OpRefBalanceChange(Item, OpRef, Qty, [Status], [Version], CreateDate, CreateUserId, CreateUserNm)
			select opRef.Item, opRef.OpRef, opRef.Qty, 1, opRef.[Version], @DateTimeNow, @CreateUserId, @CreateUserNm
			from SCM_OpRefBalance as opRef
			inner join #tempThisConsumeOpRefBalance as cOpRef on opRef.Item = cOpRef.Item and opRef.OpRef = cOpRef.OpRef 
			
			--��¼��λ����������
			insert into CUST_ManualGenOrderOpRefBalanceTrace(ProdOrderNo, Item, OpRef, Qty, CreateUser, CreateUserNm, CreateDate)
			select @ProdOrderNo, Item, OpRef, ConsumeQty, @CreateUserId, @CreateUserNm, @DateTimeNow from #tempThisConsumeOpRefBalance
			
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
			
			set @Msg = N'���¹�λ����ʧ�ܣ�ʧ����Ϣ��' + Error_Message()
			insert into #tempMsg(Lvl, Msg) values(1, @Msg)
		end catch
	end
	-------------------���ȿ���ʹ�ù�λ����-----------------------
	
	if exists(select top 1 1 from #tempOrderBomDetTBD)
	begin				
		-------------------�����˵��Զ�����������-----------------------
		--delete bom
		--from #tempOrderBomDetTBD as bom 
		--inner join SCM_FlowDet as det on bom.Item = det.Item
		--inner join SCM_FlowMstr as mstr	on det.Flow = mstr.Code
		--inner join SCM_FlowStrategy as stra on mstr.Code = stra.Flow
		--where ((det.LocTo is not null and bom.Location = det.LocTo) or (det.LocTo is null and bom.Location = mstr.LocTo))
		--and mstr.IsActive = 1 and det.IsActive = 1 and det.IsAutoCreate = 1 and mstr.IsAutoCreate = 1 and stra.Strategy <> 4 --���ܹ��˵������
		-------------------�����˵��Զ�����������-----------------------
		
		-------------------�����˵��ֹ�KB�͵��ӿ��������-----------------------
		delete req
		from #tempOrderBomDetTBD as req 
		inner join SCM_FlowDet as det on req.Item = det.Item
		inner join SCM_FlowMstr as mstr	on det.Flow = mstr.Code and req.Location = mstr.LocTo
		inner join SCM_FlowStrategy as stra	on stra.Flow = mstr.Code
		--where ((det.LocTo is not null and req.Location = det.LocTo) or (det.LocTo is null and req.Location = mstr.LocTo))
		where mstr.IsActive = 1 and stra.Strategy in (2, 7) --and det.IsActive = 1
		
		--��������·��
		delete req
		from #tempOrderBomDetTBD as req 
		inner join SCM_FlowDet as det on req.Item = det.Item
		inner join SCM_FlowMstr as mstr	on det.Flow = mstr.RefFlow and req.Location = mstr.LocTo
		inner join SCM_FlowStrategy as stra	on stra.Flow = mstr.Code
		--where ((det.LocTo is not null and req.Location = det.LocTo) or (det.LocTo is null and req.Location = mstr.LocTo))
		where mstr.IsActive = 1 and stra.Strategy in (2, 7) --and det.IsActive = 1
		-------------------�����˵��ֹ�KB�͵��ӿ��������-----------------------
	
		-------------------����������ϵ����ϺͿ�λ-----------------------
		insert into #tempItemLocationTBD(Item, Location)
		select Item, Location from #tempOrderBomDetTBD group by Item, Location
		-------------------����������ϵ����ϺͿ�λ-----------------------
		
		-------------------����ȡ����·����ϸ-----------------------
		insert into #tempFlowDet(Flow, FlowType, FlowDetId,
		Item, Uom, UC, MinUC, UCDesc, Container, ContainerDesc, LocFrom, LocTo,
		MrpTotal, MrpTotalAdj, MrpWeight, RoundUpOpt)
		select distinct det.Flow, mstr.[Type], det.Id, 
		det.Item, det.Uom, det.UC, det.MinUC, det.UCDesc, det.Container, det.ContainerDesc, mstr.LocFrom, mstr.LocTo, 
		ISNULL(det.MrpTotal, 0), ISNULL(det.MrpTotalAdj, 0), ISNULL(det.MrpWeight, 0), det.RoundUpOpt
		from #tempItemLocationTBD as tbd 
		inner join SCM_FlowDet as det on tbd.Item = det.Item
		inner join SCM_FlowMstr as mstr	on det.Flow = mstr.Code --and tbd.Location = mstr.LocTo
		inner join SCM_FlowStrategy as stra	on stra.Flow = mstr.Code
		where mstr.IsActive = 1 --and det.IsActive = 1
		and mstr.[Type] in (1, 2)
		--and mstr.IsActive = 1 and (det.IsAutoCreate = 0 or mstr.IsAutoCreate = 0 or stra.Strategy = 4) and det.IsActive = 1
		
		--��ȡ����·����ϸ
		insert into #tempFlowDet(Flow, FlowType, FlowDetId,
		Item, Uom, UC, MinUC, UCDesc, Container, ContainerDesc, LocFrom, LocTo,
		MrpTotal, MrpTotalAdj, MrpWeight, RoundUpOpt)
		select distinct mstr.Code, mstr.[Type], rdet.Id,
		rdet.Item, rdet.Uom, rdet.UC, rdet.MinUC, rdet.UCDesc, rdet.Container, rdet.ContainerDesc, mstr.LocFrom, mstr.LocTo, 
		0 as MrpTotal, 0 as MrpTotalAdj, 0 as MrpWeight, rdet.RoundUpOpt
		from #tempItemLocationTBD as tbd 
		inner join SCM_FlowDet as rdet on tbd.Item = rdet.Item
		inner join SCM_FlowMstr as rmstr on rdet.Flow = rmstr.Code
		inner join SCM_FlowMstr as mstr	on rmstr.Code = mstr.RefFlow --and tbd.Location = mstr.LocTo
		inner join SCM_FlowStrategy as stra	on stra.Flow = mstr.Code
		where rdet.Item = tbd.Item
		--and mstr.IsActive = 1 and (mstr.IsAutoCreate = 0 or stra.Strategy = 4) and rdet.IsActive = 1
		and mstr.IsActive = 1 --and rdet.IsActive = 1
		and mstr.[Type] in (1, 2)
		and not exists(select top 1 1 from #tempFlowDet as det where det.Item = rdet.Item and det.LocTo = mstr.LocTo)
		-------------------����ȡ����·����ϸ-----------------------
		
		-------------------���������ѡ��๩Ӧ�̹�����·��-----------------------
		delete det
		from #tempFlowDet as det 
		inner join SCM_FlowMstr as mstr on det.Flow = mstr.Code
		inner join (select det.Id, det.Item, det.LocTo 
					from #tempFlowDet as det
					inner join SCM_FlowMstr as mstr on det.Flow = mstr.Code
					inner join LE_QuotaSnapShot as lq on det.Item = lq.Item and mstr.PartyFrom = lq.Supplier
					where mstr.[Type] = 1) as cDet --��ǰ�����Ĳɹ�·����ϸ
					on det.Item = cDet.Item and det.LocTo = cDet.LocTo and det.Id <> cDet.Id
		where mstr.[Type] = 1   --ֻ���˵��ɹ���·��
		-------------------���������ѡ��๩Ӧ�̹�����·��-----------------------
		
		-------------------����һ��ƥ�䣬ƥ���������λ������·����ͬ������-----------------------
		--���������ƥ���ʾ
		update bom set IsMatch = 1
		from #tempOrderBomDetTBD as bom inner join #tempFlowDet as det on bom.Item = det.Item and bom.Location = det.LocTo
		-------------------����һ��ƥ�䣬ƥ���������λ������·����ͬ������-----------------------
	
		-------------------���ڶ���ƥ�䣬ƥ��ɹ����ص���Դ��λ-----------------------
		insert into #tempFlowDet(Flow, FlowType, FlowDetId,
		Item, Uom, UC, MinUC, UCDesc, Container, ContainerDesc, LocFrom, LocTo,
		MrpTotal, MrpTotalAdj, MrpWeight, RoundUpOpt)
		select distinct null, 2, null as FlowDetId,
		det.Item, i.Uom, i.MinUC, i.MinUC, null, i.Container, i.ContainerDesc, det.LocTo as LocFrom, bom.Location as LocTo,
		0, 0, 0, 0
		from #tempOrderBomDetTBD as bom
		inner join #tempFlowDet as det on bom.Item = det.Item
		inner join MD_Location as l on det.LocTo = l.Code
		inner join MD_Item as i on det.Item = i.Code
		where bom.IsMatch = 0 and l.IsSource = 1 and det.FlowType = 1
		
		--��·��ͷ
		update #tempFlowDet set Flow = mstr.Code
		from #tempFlowDet as det
		inner join SCM_FlowMstr as mstr on mstr.LocFrom = det.LocFrom and mstr.LocTo = det.LocTo
		inner join SCM_FlowStrategy as stra on mstr.Code = stra.Flow
		where mstr.IsActive = 1 and det.Flow is null and stra.Strategy = 3
		
		update #tempFlowDet set Flow = mstr.Code
		from #tempFlowDet as det
		inner join SCM_FlowMstr as mstr on mstr.LocFrom = det.LocFrom and mstr.LocTo = det.LocTo
		inner join SCM_FlowStrategy as stra on mstr.Code = stra.Flow
		where mstr.IsActive = 1 and det.Flow is null and stra.Strategy <> 3
		
		if exists (select top 1 1 from #tempFlowDet where Flow is null)
		begin
			--��¼��־
			insert into #tempMsg(Lvl, Msg)
			select 1, N'���' + d.Item + N'û��ά���ӿ�λ' + d.LocFrom + '����λ' + d.LocTo + '���ƿ�·�ߣ��޷��������ϵ���'
			from #tempFlowDet as d inner join MD_Item as i on d.Item = i.Code
			where d.Flow is null and i.BESKZ <> 'E'
			
			update bom set IsMatch = 1
			from #tempOrderBomDetTBD as bom inner join #tempFlowDet as det on bom.Item = det.Item and bom.Location = det.LocTo
			where bom.IsMatch = 0 and det.Flow is null
		
			delete from #tempFlowDet where Flow is null
		end

		update bom set IsMatch = 1
		from #tempOrderBomDetTBD as bom inner join #tempFlowDet as det on bom.Item = det.Item and bom.Location = det.LocTo
		where bom.IsMatch = 0
		-------------------���ڶ���ƥ�䣬ƥ��ɹ����ص���Դ��λ-----------------------
	
		-------------------��������ƥ�䣬ƥ��ֱ��-----------------------
		insert into #tempFlowDet(Flow, FlowType, FlowDetId,
		Item, Uom, UC, MinUC, UCDesc, Container, ContainerDesc, LocFrom, LocTo,
		MrpTotal, MrpTotalAdj, MrpWeight, RoundUpOpt)
		select distinct det.Flow, 1, null as FlowDetId,
		det.Item, det.Uom, det.UC, det.MinUC, det.UCDesc, det.Container, det.ContainerDesc, null as LocFrom, bom.Location as LocTo,
		0, 0, 0, 0
		from #tempOrderBomDetTBD as bom
		inner join #tempFlowDet as det on bom.Item = det.Item
		where bom.IsMatch = 0 and det.FlowType = 1
		
		update bom set IsMatch = 1
		from #tempOrderBomDetTBD as bom inner join #tempFlowDet as det on bom.Item = det.Item and bom.Location = det.LocTo
		where bom.IsMatch = 0
		-------------------��������ƥ�䣬ƥ��ֱ��-----------------------
	
		-------------------��û���ҵ��ɹ����ص�-----------------------
		if exists (select top 1 1 from #tempOrderBomDetTBD where IsMatch = 0)
		begin
			--��¼��־
			insert into #tempMsg(Lvl, Msg)
			select 1, N'���' + t.Item + N'���Ŀ�λ' + t.Location + N'û������·��Ҳû�вɹ����ص㣬�޷��������ϵ���'
			from #tempOrderBomDetTBD as t inner join MD_Item as i on t.Item = i.Code
			where t.IsMatch = 0 and i.BESKZ <> 'E'
		end
		-------------------��û���ҵ��ɹ����ص�-----------------------
		
		-------------------��������������������Ϳ�λ��ͬ��·��-----------------------
		-------------------���������Ŀ�Ŀ�λ����-----------------------
		insert into #tempMultiSupplierGroup(Item, LocTo)
		select Item, LocTo from #tempFlowDet
		where LocTo is not null
		group by Item, LocTo having COUNT(1) > 1 
		
		insert into #tempMultiSupplierItem(FlowDetRowId, Flow, Item, LocTo, MSGRowId, MrpTotal, MrpTotalAdj, MrpWeight)
		select det.Id, det.Flow, det.Item, det.LocTo, msg.RowId, det.MrpTotal, det.MrpTotalAdj, det.MrpWeight
		from #tempFlowDet as det
		inner join #tempMultiSupplierGroup as msg on det.Item = msg.Item and det.LocTo = msg.LocTo
		-------------------���������Ŀ�Ŀ�λ����-----------------------		
		
		-------------------�������Ŀ�Ŀ�λ��ͬ��·�߶�û�����ù���ѭ�������������װ����ѭ����-----------------------
		update tmp set MrpWeight = (CASE WHEN det.UC = 0 THEN 1 ELSE det.UC END)
		from #tempMultiSupplierItem as tmp
		inner join #tempFlowDet as det on det.Id = tmp.FlowDetRowId
		where tmp.MSGRowId in (select MSGRowId from #tempMultiSupplierItem group by MSGRowId having SUM(MrpWeight) = 0)
		-------------------�������Ŀ�Ŀ�λ��ͬ��·�߶�û�����ù���ѭ�������������װ����ѭ����-----------------------
		
		-------------------�������Ŀ�Ŀ�λ��ͬ��·��û�����ù���ѭ������������Щ·����ϸ-----------------------
		delete #tempFlowDet where Id in (select FlowDetRowId from #tempMultiSupplierItem where MrpWeight = 0)
		delete #tempMultiSupplierItem where FlowDetRowId in (select FlowDetRowId from #tempMultiSupplierItem where MrpWeight = 0)
		-------------------�������Ŀ�Ŀ�λ��ͬ��·��û�����ù���ѭ������������Щ·����ϸ-----------------------
		
		-------------------�����㹩������������-----------------------
		update #tempMultiSupplierItem set DeliveryCount = (ISNULL(MrpTotal, 0) + ISNULL(MrpTotalAdj, 0)) / MrpWeight, DeliveryBalance = (ISNULL(MrpTotal, 0) + ISNULL(MrpTotalAdj, 0)) % MrpWeight
		-------------------�����㹩������������-----------------------
		
		-------------------�����ݹ���������ѭ����ѡȡһ��·����ϸ����-----------------------
		insert into #tempSortedMultiSupplierItem(GID, FlowDetRowId, Flow)
		select ROW_NUMBER() over(partition by MSGRowId order by DeliveryCount asc, MrpWeight desc, DeliveryBalance desc) as GID, FlowDetRowId, Flow 
		from #tempMultiSupplierItem
		
		delete #tempFlowDet where Id in (select FlowDetRowId from #tempSortedMultiSupplierItem where GID <> 1)
		delete #tempMultiSupplierItem where FlowDetRowId in (select FlowDetRowId from #tempSortedMultiSupplierItem where GID <> 1)
		-------------------�����ݹ���������ѭ����ѡȡһ��·����ϸ����-----------------------
		
		
		-------------------���������λ��Դ��λ��Ҫ������Դ��λ������-----------------------
		--insert into #tempOrderBomDetTBD(Item, Location, OpRef, RefOpRef, OrderQty, IsMatch, ManufactureParty)
		--select tbd.Item, det.LocFrom, null, null, tbd.OrderQty, tbd.IsMatch, tbd.ManufactureParty 
		--from #tempOrderBomDetTBD as tbd 
		--inner join #tempFlowDet as det on det.Item = tbd.Item and det.LocTo = tbd.Location
		--inner join MD_Location as l on tbd.Location = l.Code 
		--where l.IsSource = 1
		-------------------���������λ��Դ��λ��Ҫ������Դ��λ������-----------------------
		
		
		-------------------������Ҫ����-----------------------
		insert into #tempOrderDet(Flow, FlowDetId,
		Item, Uom, UC, MinUC, UCDesc, Container, ContainerDesc, LocFrom, LocTo,
		ReqQty, OrderQty, OpRef, RefOpRef, MrpTotal, MrpTotalAdj, MrpWeight, ManufactureParty, RoundUpOpt)
		select det.Flow, det.FlowDetId, 
		det.Item, det.Uom, det.UC, det.MinUC, det.UCDesc, det.Container, det.ContainerDesc, det.LocFrom, det.LocTo,
		tbd.OrderQty, 0, tbd.OpRef, tbd.RefOpRef, det.MrpTotal, det.MrpTotalAdj, det.MrpWeight, tbd.ManufactureParty, det.RoundUpOpt
		from #tempFlowDet as det 
		inner join #tempOrderBomDetTBD as tbd on det.Item = tbd.Item and det.LocTo = tbd.Location
		
		insert into #tempFlowMstr(Flow, LocTo) select distinct Flow, LocTo from #tempOrderDet
		
		declare @FlowRowId int
		declare @MaxFlowRowId int
		
		select @FlowRowId = MIN(RowId), @MaxFlowRowId = MAX(RowId) from #tempFlowMstr
		while (@FlowRowId <= @MaxFlowRowId)
		begin
			set @trancount = @@trancount
			begin try
				declare @Flow varchar(50) = null
				declare @FlowType tinyint = null
				declare @FlowPartyFrom varchar(50) = null
				declare @FlowPartyTo varchar(50) = null
				declare @FlowPartyToName varchar(100) = null
				declare @FlowLocFrom varchar(50) = null
				declare @FlowLocTo varchar(50) = null
				declare @FlowDock varchar(50) = null
				declare @OrderNo varchar(50) = null
				declare @OrderDetCount int = null
				declare @BeginOrderDetId bigint = null
				declare @EndOrderDetId bigint = null
						
				if @trancount = 0
				begin
					begin tran
				end
				
				--��ȡ·����Ϣ
				select @Flow = Code, @FlowType = [Type], @FlowPartyFrom = PartyFrom, @FlowPartyTo = PartyTo, @FlowLocFrom = LocFrom, @FlowLocTo = LocTo, @FlowDock = Dock
				from SCM_FlowMstr where Code = (select Flow from #tempFlowMstr where RowId = @FlowRowId)
				
				--����ϸ�����»�ȡ�������ĵص㣬����ǵ�����ƥ�䣬ֱ�Ӵӹ�Ӧ���������������ĵص㣬����ȡ·��ͷ�ϵ�Ŀ�Ŀ�λ
				select @FlowLocTo = mstr.LocTo, @FlowPartyTo = l.Region, @FlowPartyToName = l.Name
				from #tempFlowMstr as mstr inner join MD_Location as l on mstr.LocTo = l.Code where RowId = @FlowRowId
				
				--��ȡ������
				exec USP_GetDocNo_ORD @Flow, 3, @FlowType, 0, 0, 1, @FlowPartyFrom, @FlowPartyTo, @FlowLocTo, @FlowLocFrom, @FlowDock, 0, @OrderNo output
				update #tempOrderDet set OrderNo = @OrderNo where Flow = @Flow and LocTo = @FlowLocTo
				
				--��������ͷ
				if (@FlowType = 1)
				begin
					insert into ORD_OrderMstr_1 (
					OrderNo,              --������
					Flow,                 --·��
					OrderStrategy,        --���ԣ�
					RefOrderNo,           --�ο�������,��¼��������
					[Type],               --���ͣ�1 �ɹ�
					SubType,              --�����ͣ�0����
					QualityType,          --����״̬��0��Ʒ
					StartTime,            --��ʼʱ��
					WindowTime,           --����ʱ��
					PauseSeq,             --��ͣ����0
					IsQuick,              --�Ƿ���٣�0
					[Priority],           --���ȼ���1
					[Status],             --״̬��1�ͷ�
					PartyFrom,            --�������
					PartyFromNm,            --��������
					PartyTo,              --�������
					PartyToNm,            --��������
					--LocFrom,              --ԭ���Ͽ�λ
					--LocFromNm,            --ԭ���Ͽ�λ
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
					IsPrintOrder,         --��ӡҪ������0
					IsOrderPrinted,       --Ҫ�����Ѵ�ӡ��0
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
					PauseStatus			  --��ͣ״̬��0
					)
					select 
					@OrderNo,			  --������
					mstr.Code,            --·��
					@OrderStrategy,		  --����
					@ProdOrderNo,          --�ο������ţ���������
					@FlowType,			  --����
					0,					  --�����ͣ�0����
					0,					  --����״̬��0��Ʒ
					@DateTimeNow,         --��ʼʱ��
					@WindowTime,          --����ʱ��
					0,					  --��ͣ����0
					0,					  --�Ƿ���٣�0
					@Priority,			  --���ȼ���1
					1,					  --״̬��1�ͷ�
					mstr.PartyFrom,            --�������
					pf.Name,            --��������
					@FlowPartyTo,              --�������
					@FlowPartyToName,            --��������
					--mstr.LocFrom,              --ԭ���Ͽ�λ
					--lf.Name,				--ԭ���Ͽ�λ
					@FlowLocTo,                --��Ʒ��λ
					lt.Name,                --��Ʒ��λ
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
					mstr.IsPrintOrder,         --��ӡҪ������0
					0,					  --Ҫ�����Ѵ�ӡ��0
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
					0					  --��ͣ״̬��0
					from SCM_FlowMstr as mstr
					inner join MD_Party as pf on mstr.PartyFrom = pf.Code
					inner join MD_Party as pt on mstr.PartyTo = pt.Code
					--left join MD_Location as lf on mstr.LocFrom = lf.Code						
					left join MD_Location as lt on lt.Code = @FlowLocTo					
					where mstr.Code = @Flow
				end
				else if @FlowType = 2
				begin 
					insert into ORD_OrderMstr_2 (
					OrderNo,              --������
					Flow,                 --·��
					OrderStrategy,        --���ԣ�
					RefOrderNo,			  --�ο�������,��������
					[Type],               --���ͣ�1 �ɹ�
					SubType,              --�����ͣ�0����
					QualityType,          --����״̬��0��Ʒ
					StartTime,            --��ʼʱ��
					WindowTime,           --����ʱ��
					PauseSeq,             --��ͣ����0
					IsQuick,              --�Ƿ���٣�0
					[Priority],           --���ȼ���1
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
					BillAddr,			  --��Ʊ��ַ
					Dock,				  --����
					IsAutoRelease,        --�Զ��ͷţ�0
					IsAutoStart,          --�Զ����ߣ�0
					IsAutoShip,           --�Զ�������0
					IsAutoReceive,        --�Զ��ջ���0
					IsAutoBill,           --�Զ��˵���0
					IsManualCreateDet,    --�ֹ�������ϸ��0
					IsListPrice,          --��ʾ�۸񵥣�0
					IsPrintOrder,         --��ӡҪ������0
					IsOrderPrinted,       --Ҫ�����Ѵ�ӡ��0
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
					PauseStatus			  --��ͣ״̬��0
					)
					select
					@OrderNo,			  --������
					mstr.Code,                 --·��
					@OrderStrategy,		 --����
					@ProdOrderNo,          --�ο������ţ���������
					@FlowType,			  --����
					0,					  --�����ͣ�0����
					0,					  --����״̬��0��Ʒ
					@DateTimeNow,         --��ʼʱ��
					@WindowTime,        --����ʱ��
					0,					  --��ͣ����0
					0,					  --�Ƿ���٣�0
					@Priority,					  --���ȼ���1
					1,					  --״̬��1�ͷ�
					mstr.PartyFrom,            --�������
					pf.Name,            --�������
					mstr.PartyTo,              --�������
					pt.Name,            --�������
					mstr.LocFrom,              --ԭ���Ͽ�λ
					lf.Name,              --ԭ���Ͽ�λ
					@FlowLocTo,                --��Ʒ��λ
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
					mstr.IsPrintOrder,         --��ӡҪ������0
					0,					  --Ҫ�����Ѵ�ӡ��0
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
					0					  --��ͣ״̬��0
					from SCM_FlowMstr  as mstr
					inner join MD_Party as pf on mstr.PartyFrom = pf.Code
					inner join MD_Party as pt on mstr.PartyTo = pt.Code
					left join MD_Location as lf on mstr.LocFrom = lf.Code					
					left join MD_Location as lt on lt.Code = @FlowLocTo			
					where mstr.Code = @Flow
				end
				else
				begin
					RAISERROR(N'·�����Ͳ���ȷ��', 16, 1)
				end
				
				--���Ҷ�������
				select @OrderDetCount = COUNT(*) from #tempOrderDet where OrderNo = @OrderNo
				--����OrderDetId�ֶα�ʶ�ֶ�
				exec USP_SYS_BatchGetNextId 'ORD_OrderDet', @OrderDetCount, @EndOrderDetId output
				--���ҿ�ʼ��ʶ
				set @BeginOrderDetId = @EndOrderDetId - @OrderDetCount
				
				--���涩��ID
				truncate table #tempOrderDetId
				insert into #tempOrderDetId(RowId, OrderDetId, OrderDetSeq)
				select RowId, ROW_NUMBER() over (order by RowId) + @BeginOrderDetId as OrderDetId, ROW_NUMBER() over (order by RowId) as OrderDetSeq
				from #tempOrderDet where OrderNo = @OrderNo
				
				--��¼������ϸID
				update det set OrderDetId = id.OrderDetId, OrderDetSeq = id.OrderDetSeq
				from #tempOrderDet as det inner join #tempOrderDetId as id on det.RowId = id.RowId
				where OrderNo = @OrderNo
				
				--����װԲ��
				update #tempOrderDet set OrderQty = ReqQty where OrderNo = @OrderNo and RoundUpOpt in (0, 2)  --��Բ��
				update #tempOrderDet set OrderQty = ReqQty where OrderNo = @OrderNo and UC <= 0  --��Բ��
				update #tempOrderDet set OrderQty = ReqQty where OrderNo = @OrderNo and RoundUpOpt = 1 and UC > 0 --����Բ��
				--update #tempOrderDet set OrderQty = ceiling(ReqQty / UC) * UC where OrderNo = @OrderNo and RoundUpOpt = 1 and UC > 0 --����Բ��
				--update #tempOrderDet set OrderQty = floor(ReqQty / UC) * UC where OrderNo = @OrderNo and ReqQty > 0 and RoundUpOpt = 2 and UC > 0  --����Բ��
				
				--���¹�λ����
				update orb set Qty = ISNULL(tod.Balance, 0), [Version] = [Version] + 1, LastModifyDate = @DateTimeNow, LastModifyUser = @CreateUserId, LastModifyUserNm = @CreateUserNm
				from SCM_OpRefBalance as orb 
				inner join (select Item, OpRef, SUM(OrderQty - ReqQty) as Balance from #tempOrderDet 
							where OrderQty > ReqQty and ISNULL(OpRef, '') <> '' group by Item, OpRef) as tod on orb.Item = tod.Item and orb.OpRef = tod.OpRef
									
				--���¹�λ������־
				insert into LOG_OpRefBalanceChange(Item, OpRef, Qty, [Status], [Version], CreateDate, CreateUserId, CreateUserNm)
				select orb.Item, orb.OpRef, ISNULL(tod.Balance, 0), 1, orb.[Version], @DateTimeNow, @CreateUserId, @CreateUserNm
				from SCM_OpRefBalance as orb 
				inner join (select Item, OpRef, SUM(OrderQty - ReqQty) as Balance from #tempOrderDet 
							where OrderQty > ReqQty and ISNULL(OpRef, '') <> '' group by Item, OpRef) as tod on orb.Item = tod.Item and orb.OpRef = tod.OpRef
				
				--���������ڵĹ�λ����
				insert into SCM_OpRefBalance (Item, OpRef, Qty, CreateUser, CreateUserNm, CreateDate, LastModifyUser, LastModifyUserNm, LastModifyDate, [Version])
				select tod.Item, tod.OpRef, ISNULL(tod.Balance, 0), @CreateUserId, @CreateUserNm, @DateTimeNow, @CreateUserId, @CreateUserNm, @DateTimeNow, 1
				from (select Item, OpRef, SUM(OrderQty - ReqQty) as Balance from #tempOrderDet 
						where OrderQty > ReqQty and ISNULL(OpRef, '') <> '' group by Item, OpRef) as tod 
				left join SCM_OpRefBalance as orb on orb.Item = tod.Item and orb.OpRef = tod.OpRef
				where orb.Id is null
				
				--������λ������־
				insert into LOG_OpRefBalanceChange(Item, OpRef, Qty, [Status], [Version], CreateDate, CreateUserId, CreateUserNm)
				select tod.Item, tod.OpRef, ISNULL(tod.Balance, 0), 0, 1, @DateTimeNow, @CreateUserId, @CreateUserNm
				from (select Item, OpRef, SUM(OrderQty - ReqQty) as Balance from #tempOrderDet 
						where OrderQty > ReqQty and ISNULL(OpRef, '') <> '' group by Item, OpRef) as tod 
				left join SCM_OpRefBalance as orb on orb.Item = tod.Item and orb.OpRef = tod.OpRef
				where orb.Id is null
				
				--����������ϸ
				if @FlowType = 1
				begin
					insert into ORD_OrderDet_1 (
					Id,                         --��������ϸ��ʶ
					OrderNo,                    --��������
					OrderType,                  --���ͣ�1�ɹ�
					OrderSubType,               --�����ͣ�0����
					Seq,						--�кţ�1
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
					IsChangeUC,					--�Ƿ��޸ĵ���װ��0
					--LocFrom,					--�����λ
					--LocFromNm,				--�����λ����
					LocTo,						--����λ
					LocToNm,					--����λ����
					BillAddr,					--��Ʊ��ַ
					ExtraDmdSource,				--��¼FlowDetId�������0����ϵͳ�Զ�������·����ϸ
					BillTerm,					--���㷽ʽ
					WMSSeq,						--JIT���㹤λ
					BinTo						--���͹�λ
					)
					select 
					det.OrderDetId,				--��������ϸ��ʶ
					det.OrderNo,				--��������
					@FlowType,					--���ͣ�1�ɹ�
					0,							--�����ͣ�0����
					det.OrderDetSeq,			--�кţ�
					0,							--�ƻ�Э�����ͣ�0
					det.Item,					--���Ϻ�
					i.RefCode,					--�ο����Ϻ�
					i.Desc1,					--��������
					det.Uom,					--��λ
					det.Uom,					--������λ
					det.UC,						--��װ��1
					det.MinUC,                  --��С��װ��1
					det.UCDesc,					--��װ����
					det.Container,				--��������
					det.ContainerDesc,			--��������
					0,							--����״̬��0
					det.ManufactureParty,		--������
					det.ReqQty,					--����������1
					det.OrderQty,				--����������1
					0,							--����������0
					0,							--�ջ�������0
					0,							--��Ʒ������0
					0,							--��Ʒ������0
					0,							--���������0
					1,							--��λ������1
					0,							--�Ƿ���飬0
					0,							--�Ƿ��ݹ��ۣ�0
					0,							--�Ƿ�˰�ۣ�0
					0,							--�Ƿ�ɨ�����룬0
					@CreateUserId,				--�����û�
					@CreateUserNm,				--�����û�����
					@DateTimeNow,				--��������
					@CreateUserId,				--����޸��û�
					@CreateUserNm,				--����޸��û�����
					@DateTimeNow,				--����޸�����
					1,							--�汾��1
					0,							--�Ƿ��޸ĵ���װ��0
					--det.LocFrom,				--�����λ
					--lf.Name,					--�����λ����
					ISNULL(det.LocTo, mstr.LocTo),	--����λ
					ISNULL(lt.Name, mstr.LocToNm),--����λ
					mstr.BillAddr,				--��Ʊ��ַ
					CONVERT(varchar, det.FlowDetId),--��¼FlowDetId�������0����ϵͳ�Զ�������·����ϸ
					mstr.BillTerm,				--���㷽ʽ
					det.OpRef,						--JIT���㹤λ
					ISNULL(det.RefOpRef, det.OpRef)	--���͹�λ
					from #tempOrderDet as det
					inner join ORD_OrderMstr_1 as mstr on mstr.OrderNo = det.OrderNo
					inner join MD_Item as i on det.Item = i.Code
					left join MD_Location as lt on det.LocTo = lt.Code
					where det.OrderNo = @OrderNo
					
					--�����ۼƽ�����
					update q set AccumulateQty = ISNULL(q.AccumulateQty, 0) + det.OrderQty, [Version] = q.[Version] + 1
					from SCM_Quota as q 
					inner join (select det.Item, mstr.PartyFrom, SUM(det.OrderQty) as OrderQty
								from #tempOrderDet as det 
								inner join ORD_OrderMstr_1 as mstr on mstr.OrderNo = det.OrderNo
								where det.OrderNo = @OrderNo
								group by det.Item, mstr.PartyFrom) as det on q.Item = det.Item and q.Supplier = det.PartyFrom								
				end
				else
				begin
					insert into ORD_OrderDet_2 (
					Id,                         --��������ϸ��ʶ
					OrderNo,                    --��������
					OrderType,                  --���ͣ�1�ɹ�
					OrderSubType,               --�����ͣ�0����
					Seq,						--�кţ�1
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
					IsChangeUC,					--�Ƿ��޸ĵ���װ��0
					LocFrom,					--�����λ
					LocFromNm,					--�����λ����
					LocTo,						--����λ
					LocToNm,					--����λ����
					--BillAddr,					--��Ʊ��ַ
					ExtraDmdSource,				--��¼FlowDetId�������0����ϵͳ�Զ�������·����ϸ
					WMSSeq,						--JIT���㹤λ
					BinTo						--��λ
					)
					select 
					det.OrderDetId,				--��������ϸ��ʶ
					det.OrderNo,				--��������
					@FlowType,					--���ͣ�1�ɹ�
					0,							--�����ͣ�0����
					det.OrderDetSeq,			--�кţ�
					0,							--�ƻ�Э�����ͣ�0
					det.Item,					--���Ϻ�
					i.RefCode,					--�ο����Ϻ�
					i.Desc1,					--��������
					det.Uom,					--��λ
					det.Uom,					--������λ
					det.UC,						--��װ��1
					det.MinUC,                  --��С��װ��1
					det.UCDesc,					--��װ����
					det.Container,				--��������
					det.ContainerDesc,			--��������
					0,							--����״̬��0
					det.ManufactureParty,		--������
					det.ReqQty,					--����������1
					det.OrderQty,				--����������1
					0,							--����������0
					0,							--�ջ�������0
					0,							--��Ʒ������0
					0,							--��Ʒ������0
					0,							--���������0
					1,							--��λ������1
					0,							--�Ƿ���飬0
					0,							--�Ƿ��ݹ��ۣ�0
					0,							--�Ƿ�˰�ۣ�0
					0,							--�Ƿ�ɨ�����룬0
					@CreateUserId,				--�����û�
					@CreateUserNm,				--�����û�����
					@DateTimeNow,				--��������
					@CreateUserId,				--����޸��û�
					@CreateUserNm,				--����޸��û�����
					@DateTimeNow,				--����޸�����
					1,							--�汾��1
					0,							--�Ƿ��޸ĵ���װ��0
					ISNULL(det.LocFrom, mstr.LocFrom),--�����λ
					ISNULL(lf.Name, mstr.LocFromNm),--�����λ
					ISNULL(det.LocTo, mstr.LocTo),	--����λ
					ISNULL(lt.Name, mstr.LocToNm),--����λ
					--mstr.BillAddr,				--��Ʊ��ַ
					CONVERT(varchar, det.FlowDetId),--��¼FlowDetId�������0����ϵͳ�Զ�������·����ϸ
					det.OpRef,						--JIT���㹤λ
					ISNULL(det.RefOpRef, det.OpRef)	--���͹�λ
					from #tempOrderDet as det
					inner join ORD_OrderMstr_2 as mstr on mstr.OrderNo = det.OrderNo
					inner join MD_Item as i on det.Item = i.Code
					left join MD_Location as lf on det.LocFrom = lf.Code
					left join MD_Location as lt on det.LocTo = lt.Code
					where det.OrderNo = @OrderNo
				end
								
				if @FlowType = 1
					begin  --��¼�����ƻ�Э��Ķ�����ϸ
						INSERT INTO SAP_CRSL(EINDT, FRBNR, LIFNR, MATNR, MENGE, SGTXT, WERKS, OrderDetId, [Status], ErrorCount, CreateDate, LastModifyDate)
						select CONVERT(varchar(8), @WindowTime, 112), det.OrderNo, mstr.PartyFrom, det.Item, det.OrderQty, det.OrderDetSeq, r.Plant, det.OrderDetId, 0, 0, @DateTimeNow, @DateTimeNow
						from #tempOrderDet as det
						inner join ORD_OrderMstr_1 as mstr on mstr.OrderNo = det.OrderNo
						inner join MD_Region as r on mstr.PartyTo = r.Code
						where det.OrderNo = @OrderNo
					end
					else
					begin
						if exists(select top 1 1 from SCM_FlowMstr where Code = @Flow and PartyFrom in ('LOC','SQC'))
						begin
							--��¼FIS_CreateProcurementOrderDAT
							INSERT INTO FIS_CreateProcurementOrderDAT(OrderNo, Van, OrderStrategy, StartTime, WindowTime, [Priority], 
							Sequence, PartyFrom, PartyTo, Dock, CreateDate, Flow, LineSeq, Item, ManufactureParty, 
							LocationTo, Bin, OrderedQty, IsShipExceed, [FileName], IsCreateDat)
							select det.OrderNo, '', mstr.OrderStrategy, mstr.StartTime, mstr.WindowTime, mstr.[Priority],
							'', ISNULL(det.LocFrom, mstr.LocFrom), ISNULL(det.LocTo, mstr.LocTo), mstr.Dock, mstr.CreateDate, mstr.Flow, det.OrderDetId, det.Item, det.ManufactureParty, 
							ISNULL(det.RefOpRef, det.OpRef), '', det.OrderQty, mstr.IsShipExceed, '', 0
							from #tempOrderDet as det
							inner join ORD_OrderMstr_2 as mstr on mstr.OrderNo = det.OrderNo
							where det.OrderNo = @OrderNo
						end
						/**else if exists(select top 1 1 from SCM_FlowMstr where Code = @Flow and PartyFrom in ('SQC'))
						begin
							--��¼FIS_CreateOrderDAT
							INSERT INTO FIS_CreateOrderDAT(OrderNo, MATNR, LIFNR, ENMNG, CHARG, COLOR, TIME_STAMP, CY_SEQNR,
							TIME_STAMP1, AUFNR, LGORT, UMLGO, LGPBE, REQ_TIME_STAMP, FLG_SORT, PLNBEZ, KTEXT, ZPLISTNO, 
							ErrorCount, IsCreateDat, CreateUserNm)
							select det.OrderNo, det.Item, det.ManufactureParty, det.OrderQty, '', '', REPLACE(REPLACE(REPLACE(CONVERT(varchar(50),mstr.CreateDate,120),':',''),'-',''),' ',''), '',
							null, '', ISNULL(det.LocFrom, mstr.LocFrom), ISNULL(det.LocTo, mstr.LocTo), '', REPLACE(REPLACE(REPLACE(CONVERT(varchar(50),mstr.WindowTime,120),':',''),'-',''),' ',''), 'N', '', '', det.OrderDetId,
							0, 0, @CreateUserNm
							from #tempOrderDet as det
							inner join ORD_OrderMstr_2 as mstr on mstr.OrderNo = det.OrderNo
							where det.OrderNo = @OrderNo
						end**/
					end
				
				--��¼�Ѿ����ɵ����ϵ�
				insert into CUST_ManualGenOrderTrace(ProdOrderNo, OrderNo) values(@ProdOrderNo, @OrderNo)
					
				set @Msg = N'�ɹ���������·��' + @Flow + N'�����ϵ�' + @OrderNo + N'��'
				insert into #tempMsg(Lvl, Msg) values(0, @Msg)
							
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
				
				set @Msg = N'��������·��' + @Flow + N'�����ϵ�ʧ�ܣ�ʧ����Ϣ��' + Error_Message()
				insert into #tempMsg(Lvl, Msg) values(1, @Msg)
			end catch
			
			set @FlowRowId = @FlowRowId + 1
		end
		-------------------������Ҫ����-----------------------
		

	end
	
	select Lvl, Msg from #tempMsg
	
	drop table #tempConsumedOpRefBalance
	drop table #tempThisConsumeOpRefBalance
	drop table #tempFlowMstr
	drop table #tempOrderDetId
	drop table #tempOrderDet
	drop table #tempPurchase
	drop table #tempItemLocationTBD
	drop table #tempOrderBomDetTBD
	drop table #tempCreatedOrderDet
	drop table #tempOrderBomDetTotal
	drop table #tempMsg
	drop table #tempMultiSupplierGroup
	drop table #tempMultiSupplierItem
	drop table #tempSortedMultiSupplierItem
	drop table #tempDuplicateOpRef
END

