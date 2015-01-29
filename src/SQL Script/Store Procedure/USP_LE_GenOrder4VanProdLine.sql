SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF EXISTS(SELECT * FROM SYS.OBJECTS WHERE TYPE='P' AND name='USP_LE_GenOrder4VanProdLine')
	DROP PROCEDURE USP_LE_GenOrder4VanProdLine
GO

CREATE PROCEDURE [dbo].[USP_LE_GenOrder4VanProdLine]
(
	@BatchNo int,
	@LERunTime datetime,
	@CreateUserId int,
	@CreateUserNm varchar(100)
) --WITH ENCRYPTION
AS
BEGIN 
	set nocount on
	declare @DateTimeNow datetime = GetDate()
	declare @Msg nvarchar(Max)
	declare @trancount int
		
	create table #tempOrderBomDet
	(
		RowId int identity(1, 1) Primary Key,
		Flow varchar(50),
		FlowDetId int,
		Item varchar(50),
		Uom varchar(5),
		UC decimal(18, 8),
		MinUC decimal(18, 8),
		UCDesc varchar(50),
		Container varchar(50),
		ContainerDesc varchar(50),
		RoundUpOpt tinyint,
		ManufactureParty varchar(50),
		LocFrom varchar(50),
		LocTo varchar(50),
		OpRef varchar(50),
		RefOpRef varchar(256),
		NetOrderQty decimal(18, 8),
		OpRefQty decimal(18, 8),
		OrderQty decimal(18, 8),
		Balance decimal(18, 8),
		OrderNo varchar(50),
		OrderDetId int,
		OrderDetSeq int,
		IsUrgent bit,
		UUID varchar(50)
	)
	
	create table #tempOrderDet
	(
		RowId int identity(1, 1) Primary Key,
		Flow varchar(50),
		FlowDetId int,
		Item varchar(50),
		Uom varchar(5),
		UC decimal(18, 8),
		MinUC decimal(18, 8),
		UCDesc varchar(50),
		Container varchar(50),
		ContainerDesc varchar(50),
		ManufactureParty varchar(50),
		LocFrom varchar(50),
		LocTo varchar(50),
		ReqQty decimal(18, 8),
		OrderQty decimal(18, 8),
		OrderNo varchar(50),
		OrderDetId int,
		OrderDetSeq int,
		OpRef varchar(50),
		RefOpRef varchar(50)
	)
	
	Create table #tempOrderDetId
	(
		RowId int,
		OrderDetId int,
		OrderDetSeq int
	)
	
	CREATE TABLE #temp_LOG_GenOrder4VanProdLine(
		Flow varchar(50) NULL,
		OrderNo varchar(50) NULL,
		Lvl tinyint NULL,
		Msg varchar(500) NULL,
		CreateDate datetime NULL default(GETDATE()),
	)
	
	Create table #tempIgnoreWorkCenter(
		WorkCenter varchar(50) NULL
	)
	
	--��¼��־
	set @Msg = N'���������߱�����Ҫ������ʼ'
	insert into LOG_GenOrder4VanProdLine(Lvl, Msg, BatchNo) values(0, @Msg, @BatchNo)
	
	--���˵����������ǰ����ͱ�����������
	insert into #tempIgnoreWorkCenter(WorkCenter)
	select distinct WorkCenter from
		(select transPWC.WorkCenter from CUST_ProductLineMap as map
		inner join PRD_ProdLineWorkCenter as transPWC on map.TransFlow = transPWC.Flow
		union all
		select saddlePWC.WorkCenter from CUST_ProductLineMap as map
		inner join PRD_ProdLineWorkCenter as saddlePWC on map.SaddleFlow = saddlePWC.Flow
		) as A

	declare @FlowId int 
	declare @MaxFlowId int
	
	select @FlowId = MIN(Id), @MaxFlowId = MAX(Id) from LE_FlowMstrSnapShot
	
	while (@FlowId <= @MaxFlowId)
	begin
		truncate table #temp_LOG_GenOrder4VanProdLine
		
		declare @Flow varchar(50) = null
		declare @FlowType tinyint = null
		declare @FlowPartyFrom varchar(50) = null
		declare @FlowPartyTo varchar(50) = null
		declare @FlowLocFrom varchar(50) = null
		declare @FlowLocTo varchar(50) = null
		declare @FlowDock varchar(50) = null
		declare @OrderNo varchar(50) = null
		declare @StartTime datetime = null
		declare @WindowTime datetime = null
		declare @EMWindowTime datetime = null
		declare @ReqTimeFrom datetime = null
		declare @ReqTimeTo datetime = null
		declare @OrderDetCount int = null
		declare @BeginOrderDetId bigint = null
		declare @EndOrderDetId bigint = null

		select @Flow = Flow, @FlowType = [Type],
		@FlowPartyFrom = PartyFrom, @FlowPartyTo = PartyTo, @FlowLocFrom = LocFrom, @FlowLocTo = LocTo,
		@FlowDock = Dock, @StartTime = OrderTime, @WindowTime = WindowTime, @EMWindowTime = EMWindowTime,
		@ReqTimeFrom = ReqTimeFrom, @ReqTimeTo = ReqTimeTo
		from LE_FlowMstrSnapShot where Id = @FlowId
		
		if exists(select top 1 1 from LE_FlowDetSnapShot where Flow = @Flow and Strategy = 3)
		begin  --ֻ����JIT
			set @trancount = @@trancount
			begin try
				if @FlowType = 1
				begin
					insert into LOG_SnapshotFlowDet4LeanEngine(Lvl, ErrorId, Item, LocTo, Msg)
					select distinct 1, 26, bom.Item, bom.Location, N'û���ҵ����' + bom.Item + N'ָ����Ӧ��' + bom.ManufactureParty + N'��ֱ��·��'
					from LE_OrderBomCPTimeSnapshot as bom
					inner join LE_FlowDetSnapShot as fdet on bom.Item = fdet.Item and bom.Location = fdet.LocTo
					where fdet.Flow = @Flow and fdet.Strategy = 3 and bom.IsCreateOrder = 0 and bom.ManufactureParty <> @FlowPartyFrom
				end
				
				if @trancount = 0
				begin
					begin tran
				end
				
				-------------------�������������-----------------------
				--��¼��־
				set @Msg = N'����·�߽������������߱�����Ҫ������ʼ������ʱ��С��' + convert(varchar, @ReqTimeFrom, 120)
				insert into #temp_LOG_GenOrder4VanProdLine(Flow, Lvl, Msg) values(@Flow, 0, @Msg)
				
				--���㾻����
				truncate table #tempOrderBomDet
				insert into #tempOrderBomDet(Flow, FlowDetId, Item, Uom, UC, MinUC, UCDesc, Container, ContainerDesc, RoundUpOpt, ManufactureParty, LocFrom, LocTo, OpRef, RefOpRef, NetOrderQty, OpRefQty, OrderQty, UUID)
				select req.Flow, req.FlowDetId, req.Item, req.Uom, req.UC, req.MinUC, req.UCDesc, req.Container, req.ContainerDesc, req.RoundUpOpt, req.ManufactureParty, req.LocFrom, req.LocTo, req.OpRef, req.RefOpRef, req.OrderQty, ISNULL(orb.Qty, 0), req.OrderQty - (CASE WHEN ISNULL(req.ManufactureParty, '') = '' THEN ISNULL(orb.Qty, 0) ELSE 0 END), NEWID()
				from (select fdet.Flow, fdet.FlowDetId, fdet.Item, fdet.Uom, fdet.UC, fdet.MinUC, fdet.UCDesc, fdet.Container, fdet.ContainerDesc, fdet.RoundUpOpt, bom.ManufactureParty, fdet.LocFrom, fdet.LocTo, bom.OpRef, bom.RefOpRef, SUM(bom.OrderQty) as OrderQty
						from LE_OrderBomCPTimeSnapshot as bom
						inner join LE_FlowDetSnapShot as fdet on bom.Item = fdet.Item and bom.Location = fdet.LocTo
						left join #tempIgnoreWorkCenter as wc on bom.WorkCenter = wc.WorkCenter
						where fdet.Flow = @Flow and fdet.Strategy = 3 and bom.CPTime < @ReqTimeFrom and bom.IsCreateOrder = 0 and wc.WorkCenter is null
						group by fdet.Flow, fdet.FlowDetId, fdet.Item, fdet.Uom, fdet.UC, fdet.MinUC, fdet.UCDesc, fdet.Container, fdet.ContainerDesc, fdet.RoundUpOpt, bom.ManufactureParty, fdet.LocFrom, fdet.LocTo, bom.OpRef, bom.RefOpRef) as req
				left join SCM_OpRefBalance as orb on req.Item = orb.Item and req.OpRef = orb.OpRef
				order by req.Item, req.OpRef
				
				--ɾ��ֱ�͹�Ӧ�̺�ָ����Ӧ�̲���ͬ��
				if @FlowType = 1
				begin
					delete from #tempOrderBomDet where ManufactureParty is not null and ManufactureParty <> @FlowPartyFrom
				end
				
				if exists(select top 1 1 from #tempOrderBomDet)
				begin
					--���ͬһ����λ+����������������ϸ�Ļ�
					--ֻ�ܱ���һ���ĳ�ʼ��λ����������Ķ�Ҫupdate��0
					--���⹤λ��������
					update bom set OpRefQty = 0
					from #tempOrderBomDet as bom inner join
					--��������͹�λ�ٰ������̷�������null��empty����������ǰ�棩���ѷ���Ŵ���1�Ĺ�λ����ȫ����Ϊ0
					(select ROW_NUMBER() over(Partition by Item, OpRef order by ManufactureParty) as PtRowNum, RowId from #tempOrderBomDet) as t 
					on bom.RowId = t.RowId
					where t.PtRowNum > 1
					
					--����װԲ��
					update #tempOrderBomDet set OrderQty = ceiling(OrderQty / UC) * UC, Balance = ceiling(OrderQty / UC) * UC - OrderQty where OrderQty >= 0 and RoundUpOpt = 1 and UC > 0 and ISNULL(ManufactureParty, '') = ''
					update #tempOrderBomDet set OrderQty = 0, Balance = 0 - OrderQty where OrderQty < 0 and ISNULL(ManufactureParty, '') = ''
					update #tempOrderBomDet set OrderQty = ceiling(OrderQty / UC) * UC, Balance = OpRefQty + ceiling(OrderQty / UC) * UC - OrderQty where OrderQty >= 0 and RoundUpOpt = 1 and UC > 0 and ISNULL(ManufactureParty, '') <> ''
					update #tempOrderBomDet set Balance = (case when OrderQty >= 0 then 0 else (OpRefQty - NetOrderQty) end) where Balance is null and ISNULL(ManufactureParty, '') = ''
					update #tempOrderBomDet set Balance = OpRefQty where Balance is null and ISNULL(ManufactureParty, '') <> ''
					
					--���¹�λ����
					update orb set Qty = ISNULL(tod.Balance, 0), [Version] = [Version] + 1, LastModifyDate = @DateTimeNow, LastModifyUser = @CreateUserId, LastModifyUserNm = @CreateUserNm
					from SCM_OpRefBalance as orb 
						inner join (select Item, OpRef, SUM(Balance) as Balance from #tempOrderBomDet group by Item, OpRef) as tod on orb.Item = tod.Item and orb.OpRef = tod.OpRef
										
					--���¹�λ������־
					insert into LOG_OpRefBalanceChange(Item, OpRef, Qty, [Status], [Version], CreateDate, CreateUserId, CreateUserNm)
					select orb.Item, orb.OpRef, ISNULL(tod.Balance, 0), 1, orb.[Version], @DateTimeNow, @CreateUserId, @CreateUserNm
					from SCM_OpRefBalance as orb 
						inner join (select Item, OpRef, SUM(Balance) as Balance from #tempOrderBomDet group by Item, OpRef) as tod on orb.Item = tod.Item and orb.OpRef = tod.OpRef
					
					--���������ڵĹ�λ����
					insert into SCM_OpRefBalance (Item, OpRef, Qty, CreateUser, CreateUserNm, CreateDate, LastModifyUser, LastModifyUserNm, LastModifyDate, [Version])
					select tod.Item, tod.OpRef, ISNULL(tod.Balance, 0), @CreateUserId, @CreateUserNm, @DateTimeNow, @CreateUserId, @CreateUserNm, @DateTimeNow, 1
					from (select Item, OpRef, SUM(Balance) as Balance from #tempOrderBomDet group by Item, OpRef) as tod 
					left join SCM_OpRefBalance as orb on orb.Item = tod.Item and orb.OpRef = tod.OpRef
					where orb.Id is null
					
					--������λ������־
					insert into LOG_OpRefBalanceChange(Item, OpRef, Qty, [Status], [Version], CreateDate, CreateUserId, CreateUserNm)
					select tod.Item, tod.OpRef, ISNULL(tod.Balance, 0), 0, 1, @DateTimeNow, @CreateUserId, @CreateUserNm
					from (select Item, OpRef, SUM(Balance) as Balance from #tempOrderBomDet group by Item, OpRef) as tod 
					left join SCM_OpRefBalance as orb on orb.Item = tod.Item and orb.OpRef = tod.OpRef
					where orb.Id is null
					
					if exists(select top 1 1 from #tempOrderBomDet where OrderQty > 0)
					begin
						--���ܶ�����ϸ
						truncate table #tempOrderDet
						insert into #tempOrderDet(Flow, FlowDetId, Item, Uom, UC, MinUC, UCDesc, Container, ContainerDesc, ManufactureParty, LocFrom, LocTo, OpRef, RefOpRef, ReqQty, OrderQty)
						select det.Flow, det.FlowDetId, det.Item, det.Uom, det.UC, det.MinUC, det.UCDesc, det.Container, det.ContainerDesc, det.ManufactureParty, det.LocFrom, det.LocTo, det.OpRef, det.RefOpRef, SUM(det.NetOrderQty), SUM(det.OrderQty)
						from #tempOrderBomDet as det
						group by det.Flow, det.FlowDetId, det.Item, det.Uom, det.UC, det.MinUC, det.UCDesc, det.Container, det.ContainerDesc, det.ManufactureParty, det.LocFrom, det.LocTo, det.OpRef, det.RefOpRef having SUM(det.OrderQty) > 0
						
						--��ȡ������
						exec USP_GetDocNo_ORD @Flow, 3, @FlowType, 0, 0, 1, @FlowPartyFrom, @FlowPartyTo, @FlowLocTo, @FlowLocFrom, @FlowDock, 0, @OrderNo output
						--��¼������
						update #tempOrderDet set OrderNo = @OrderNo
						--��¼������
						update #tempOrderBomDet set OrderNo = @OrderNo where OrderQty > 0
						
						--��������ͷ
						if (@FlowType = 1)
						begin
							insert into ORD_OrderMstr_1 (
							OrderNo,              --������
							Flow,                 --·��
							OrderStrategy,        --���ԣ�
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
							3,					  --����
							@FlowType,			  --����
							0,					  --�����ͣ�0����
							0,					  --����״̬��0��Ʒ
							@DateTimeNow,         --��ʼʱ��
							@EMWindowTime,        --����ʱ��
							0,					  --��ͣ����0
							0,					  --�Ƿ���٣�0
							1,					  --���ȼ���1
							1,					  --״̬��1�ͷ�
							mstr.PartyFrom,			--�������
							pf.Name,            --��������
							mstr.PartyTo,              --�������
							pt.Name,            --��������
							--mstr.LocFrom,              --ԭ���Ͽ�λ
							--lf.Name,				--ԭ���Ͽ�λ
							mstr.LocTo,                --��Ʒ��λ
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
							left join MD_Location as lt on mstr.LocTo = lt.Code						
							where mstr.Code = @Flow
						end
						else if @FlowType = 2
						begin 
							insert into ORD_OrderMstr_2 (
							OrderNo,              --������
							Flow,                 --·��
							OrderStrategy,        --���ԣ�
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
							3,					  --����
							@FlowType,			  --����
							0,					  --�����ͣ�0����
							0,					  --����״̬��0��Ʒ
							@DateTimeNow,         --��ʼʱ��
							@EMWindowTime,        --����ʱ��
							0,					  --��ͣ����0
							0,					  --�Ƿ���٣�0
							1,					  --���ȼ���1
							1,					  --״̬��1�ͷ�
							mstr.PartyFrom,            --�������
							pf.Name,            --�������
							mstr.PartyTo,              --�������
							pt.Name,            --�������
							mstr.LocFrom,              --ԭ���Ͽ�λ
							lf.Name,              --ԭ���Ͽ�λ
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
							left join MD_Location as lt on mstr.LocTo = lt.Code						
							where mstr.Code = @Flow
						end
						else
						begin
							RAISERROR(N'·�����Ͳ���ȷ��', 16, 1)
						end
						
						--���Ҷ�������
						select @OrderDetCount = COUNT(*) from #tempOrderDet
						--����OrderDetId�ֶα�ʶ�ֶ�
						exec USP_SYS_BatchGetNextId 'ORD_OrderDet', @OrderDetCount, @EndOrderDetId output
						--���ҿ�ʼ��ʶ
						set @BeginOrderDetId = @EndOrderDetId - @OrderDetCount
						
						--���涩��ID
						truncate table #tempOrderDetId
						insert into #tempOrderDetId(RowId, OrderDetId, OrderDetSeq)
						select RowId, ROW_NUMBER() over (order by RowId) + @BeginOrderDetId as OrderDetId, ROW_NUMBER() over (order by RowId) as OrderDetSeq
						from #tempOrderDet
						
						--��¼������ϸID
						update det set OrderDetId = id.OrderDetId, OrderDetSeq = id.OrderDetSeq
						from #tempOrderDet as det inner join #tempOrderDetId as id
						on det.RowId = id.RowId
						
						--��¼������ϸ��BOM��ϸ�Ĺ�ϵ
						update bom set OrderDetId = det.OrderDetId, OrderDetSeq = det.RowId
						from #tempOrderDet as det inner join #tempOrderBomDet as bom
						on det.Item = bom.Item and det.LocTo = bom.LocTo
						
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
							WMSSeq,						--JIT���㹤λ
							BinTo,						--���͹�λ
							--LocFrom,					--�����λ
							--LocFromNm,				--�����λ����
							LocTo,						--����λ
							LocToNm,					--����λ����
							BillAddr,					--��Ʊ��ַ
							ExtraDmdSource,				--��¼FlowDetId�������0����ϵͳ�Զ�������·����ϸ
							BillTerm					--���㷽ʽ
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
							det.OpRef,					--JIT���㹤λ
							ISNULL(det.RefOpRef, det.OpRef),	--���͹�λ
							--det.LocFrom,				--�����λ
							--lf.Name,					--�����λ����
							ISNULL(det.LocTo, mstr.LocTo),	--����λ
							ISNULL(lt.Name, mstr.LocToNm),--����λ
							mstr.BillAddr,				--��Ʊ��ַ
							CONVERT(varchar, det.FlowDetId),--��¼FlowDetId�������0����ϵͳ�Զ�������·����ϸ
							mstr.BillTerm				--���㷽ʽ
							from #tempOrderDet as det
							inner join ORD_OrderMstr_1 as mstr on mstr.OrderNo = det.OrderNo
							inner join MD_Item as i on det.Item = i.Code
							--left join MD_Location as lf on det.LocFrom = lf.Code
							left join MD_Location as lt on det.LocTo = lt.Code
							
							--�����ۼƽ�����
							update q set AccumulateQty = ISNULL(q.AccumulateQty, 0) + det.OrderQty, [Version] = q.[Version] + 1
							from SCM_Quota as q 
							inner join (select det.Item, mstr.PartyFrom, SUM(det.OrderQty) as OrderQty
										from #tempOrderDet as det 
										inner join ORD_OrderMstr_1 as mstr on mstr.OrderNo = det.OrderNo
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
							MinUC,						--��С��װ��1
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
							WMSSeq,						--JIT���㹤λ
							BinTo,						--���͹�λ
							LocFrom,					--�����λ
							LocFromNm,					--�����λ����
							LocTo,						--����λ
							LocToNm,					--����λ����
							--BillAddr,					--��Ʊ��ַ
							ExtraDmdSource				--��¼FlowDetId�������0����ϵͳ�Զ�������·����ϸ
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
							det.OpRef,					--JIT���㹤λ
							ISNULL(det.RefOpRef, det.OpRef),--���͹�λ
							ISNULL(det.LocFrom, mstr.LocFrom),--�����λ
							ISNULL(lf.Name, mstr.LocFromNm),--�����λ
							ISNULL(det.LocTo, mstr.LocTo),	--����λ
							ISNULL(lt.Name, mstr.LocToNm),--����λ
							--mstr.BillAddr,				--��Ʊ��ַ
							CONVERT(varchar, det.FlowDetId)	--��¼FlowDetId�������0����ϵͳ�Զ�������·����ϸ
							from #tempOrderDet as det
							inner join ORD_OrderMstr_2 as mstr on mstr.OrderNo = det.OrderNo
							inner join MD_Item as i on det.Item = i.Code
							left join MD_Location as lf on det.LocFrom = lf.Code
							left join MD_Location as lt on det.LocTo = lt.Code
						end
												
						--��¼��־
						set @Msg = N'�����߱����Ͻ���Ҫ����' + @OrderNo
						insert into #temp_LOG_GenOrder4VanProdLine(Flow, OrderNo, Lvl, Msg) values(@Flow, @OrderNo, 0, @Msg)
						
						if @FlowType = 1
						begin  --��¼�����ƻ�Э��Ķ�����ϸ
							INSERT INTO SAP_CRSL(EINDT, FRBNR, LIFNR, MATNR, MENGE, SGTXT, WERKS, OrderDetId, [Status], ErrorCount, CreateDate, LastModifyDate)
							select CONVERT(varchar(8), @EMWindowTime, 112), det.OrderNo, mstr.PartyFrom, det.Item, det.OrderQty, det.OrderDetSeq, r.Plant, det.OrderDetId, 0, 0, @DateTimeNow, @DateTimeNow
							from #tempOrderDet as det
							inner join ORD_OrderMstr_1 as mstr on mstr.OrderNo = det.OrderNo
							inner join MD_Region as r on mstr.PartyTo = r.Code
						end
						else
						begin
							if exists(select top 1 1 from SCM_FlowMstr where Code = @Flow and PartyFrom in ('LOC','SQC'))
							begin
								--��¼FIS_CreateProcurementOrderDAT
								INSERT INTO FIS_CreateProcurementOrderDAT(OrderNo, Van, OrderStrategy, StartTime, WindowTime, Priority, 
								Sequence, PartyFrom, PartyTo, Dock, CreateDate, Flow, LineSeq, Item, ManufactureParty, 
								LocationTo, Bin, OrderedQty, IsShipExceed, FileName, IsCreateDat)
								select det.OrderNo, '', mstr.OrderStrategy, mstr.StartTime, mstr.WindowTime, mstr.Priority,
								'', ISNULL(det.LocFrom, mstr.LocFrom), ISNULL(det.LocTo, mstr.LocTo), mstr.Dock, mstr.CreateDate, mstr.Flow, det.OrderDetId, det.Item, det.ManufactureParty, 
								ISNULL(det.RefOpRef, det.OpRef), '', det.OrderQty, mstr.IsShipExceed, '', 0
								from #tempOrderDet as det
								inner join ORD_OrderMstr_2 as mstr on mstr.OrderNo = det.OrderNo
							end
							/**else if exists(select top 1 1 from SCM_FlowMstr where Code = @Flow and PartyFrom in ('SQC'))
							begin
								--��¼FIS_CreateOrderDAT
								INSERT INTO FIS_CreateOrderDAT(OrderNo, MATNR, LIFNR, ENMNG, CHARG, COLOR, TIME_STAMP, CY_SEQNR,
								TIME_STAMP1, AUFNR, LGORT, UMLGO, LGPBE, REQ_TIME_STAMP, FLG_SORT, PLNBEZ, KTEXT, ZPLISTNO, 
								ErrorCount, IsCreateDat, CreateUserNm)
								select det.OrderNo, det.Item, det.ManufactureParty, det.OrderQty, '', '', REPLACE(REPLACE(REPLACE(CONVERT(varchar(50),mstr.CreateDate,120),':',''),'-',''),' ',''), '',
								null, '', ISNULL(det.LocFrom, mstr.LocFrom), ISNULL(det.LocTo, mstr.LocTo), det.OpRef, REPLACE(REPLACE(REPLACE(CONVERT(varchar(50),mstr.WindowTime,120),':',''),'-',''),' ',''), 'N', '', '', det.OrderDetId,
								0, 0, @CreateUserNm
								from #tempOrderDet as det
								inner join ORD_OrderMstr_2 as mstr on mstr.OrderNo = det.OrderNo
							end**/
						end
					end
					
					--Log: JIT����������ϸ
					insert into LOG_VanOrderTrace(UUID, Flow, OrderNo, OrderDetSeq, OrderDetId, [Priority], StartTime, WindowTime, EMWindowTime, ReqTimeFrom, ReqTimeTo, 
						Item, RefItemCode, ItemDesc, Uom, UC, ManufactureParty, Location, OpRef, NetOrderQty, OrgOpRefQty, GrossOrderQty, OpRefQty, BatchNo) 
					select bom.UUID, bom.Flow, bom.OrderNo, bom.OrderDetSeq, bom.OrderDetId, 1, @StartTime, @WindowTime, @EMWindowTime, @ReqTimeFrom, @ReqTimeTo, 
						bom.Item, i.RefCode, i.Desc1, bom.Uom, bom.UC, bom.ManufactureParty, bom.LocTo, bom.OpRef, bom.NetOrderQty, bom.OpRefQty, bom.OrderQty, bom.Balance, @BatchNo
					from #tempOrderBomDet as bom inner join MD_Item as i on bom.Item = i.Code

					--Log: JIT����������ϸ��BOM�Ĺ�ϵ
					insert into LOG_VanOrderBomTrace(UUID, ProdLine, VanOrderNo, VanOrderBomDetId, Item, RefItemCode, ItemDesc, OpRef, LocFrom, LocTo, OrderQty, CPTime, BatchNo)
					select tod.UUID, bomCP.VanProdLine, bomCP.OrderNo, bomCP.BomId, bomCP.Item, i.RefCode, i.Desc1, bomCP.OpRef, fdet.LocFrom, fdet.LocTo, bomCP.OrderQty, bomCP.CPTime, @BatchNo 
					from LE_OrderBomCPTimeSnapshot as bomCP
					inner join LE_FlowDetSnapShot as fdet on bomCP.Item = fdet.Item and bomCP.Location = fdet.LocTo
					inner join #tempOrderBomDet as tod on tod.Item = bomCP.Item and tod.OpRef = bomCP.OpRef
					inner join MD_Item as i on tod.Item = i.Code
					where fdet.Flow = @Flow and fdet.Strategy = 3 and bomCP.CPTime < @ReqTimeFrom and bomCP.IsCreateOrder = 0
					
					--�������JIT������ϱ��
					update bom set IsCreateOrder = 1, [Version] = bom.[Version] + 1, LastModifyDate = @DateTimeNow, LastModifyUser = @CreateUserId, LastModifyUserNm = @CreateUserNm
					from ORD_OrderBomDet as bom
					inner join LE_OrderBomCPTimeSnapshot as bomCP on bom.Id = bomCP.BomId
					inner join LE_FlowDetSnapShot as fdet on bomCP.Item = fdet.Item and bomCP.Location = fdet.LocTo
					where fdet.Flow = @Flow and fdet.Strategy = 3 and bomCP.CPTime < @ReqTimeFrom and bomCP.IsCreateOrder = 0
					
					update bomCP set IsCreateOrder = 1
					from LE_OrderBomCPTimeSnapshot as bomCP
					inner join LE_FlowDetSnapShot as fdet on bomCP.Item = fdet.Item and bomCP.Location = fdet.LocTo
					where fdet.Flow = @Flow and fdet.Strategy = 3 and bomCP.CPTime < @ReqTimeFrom and bomCP.IsCreateOrder = 0
				end
				
				set @Msg = N'����·�߽������������߱�����Ҫ��������'
				insert into #temp_LOG_GenOrder4VanProdLine(Flow, Lvl, Msg) values(@Flow, 0, @Msg)
				-------------------�������������-----------------------
				
				
				-------------------��������������-----------------------
				if (@StartTime <= @LERunTime)
				begin
					--��¼��־
					set @Msg = N'����·���������������߱�����Ҫ������ʼ������ʱ��' + convert(varchar, @StartTime, 120) + N'����ʱ�䷶Χ' + convert(varchar, @ReqTimeFrom, 120) + ' ~ ' + convert(varchar, @ReqTimeTo, 120)
					insert into #temp_LOG_GenOrder4VanProdLine(Flow, Lvl, Msg) values(@Flow, 0, @Msg)
					
					--���㾻����
					truncate table #tempOrderBomDet
					insert into #tempOrderBomDet(Flow, FlowDetId, Item, Uom, UC, MinUC, UCDesc, Container, ContainerDesc, RoundUpOpt, ManufactureParty, LocFrom, LocTo, OpRef, RefOpRef, NetOrderQty, OpRefQty, OrderQty, UUID)
					select req.Flow, req.FlowDetId, req.Item, req.Uom, req.UC, req.MinUC, req.UCDesc, req.Container, req.ContainerDesc, req.RoundUpOpt, req.ManufactureParty, req.LocFrom, req.LocTo, req.OpRef, req.RefOpRef, req.OrderQty, ISNULL(orb.Qty, 0), req.OrderQty - (CASE WHEN ISNULL(req.ManufactureParty, '') = '' THEN ISNULL(orb.Qty, 0) ELSE 0 END), NEWID()
					from (select fdet.Flow, fdet.FlowDetId, fdet.Item, fdet.Uom, fdet.UC, fdet.MinUC, fdet.UCDesc, fdet.Container, fdet.ContainerDesc, fdet.RoundUpOpt, bom.ManufactureParty, fdet.LocFrom, fdet.LocTo, bom.OpRef, bom.RefOpRef, SUM(bom.OrderQty) as OrderQty
							from LE_OrderBomCPTimeSnapshot as bom
							inner join LE_FlowDetSnapShot as fdet on bom.Item = fdet.Item and bom.Location = fdet.LocTo
							left join #tempIgnoreWorkCenter as wc on bom.WorkCenter = wc.WorkCenter
							where fdet.Flow = @Flow and fdet.Strategy = 3 and bom.CPTime >= @ReqTimeFrom and bom.CPTime < @ReqTimeTo and bom.IsCreateOrder = 0 and wc.WorkCenter is null
							group by fdet.Flow, fdet.FlowDetId, fdet.Item, fdet.Uom, fdet.UC, fdet.MinUC, fdet.UCDesc, fdet.Container, fdet.ContainerDesc, fdet.RoundUpOpt, bom.ManufactureParty, fdet.LocFrom, fdet.LocTo, bom.OpRef, bom.RefOpRef) as req
					left join SCM_OpRefBalance as orb on req.Item = orb.Item and req.OpRef = orb.OpRef
					order by req.Item, req.OpRef
					
					--ɾ��ֱ�͹�Ӧ�̺�ָ����Ӧ�̲���ͬ��
					if @FlowType = 1
					begin
						delete from #tempOrderBomDet where ManufactureParty is not null and ManufactureParty <> @FlowPartyFrom
					end
					
					if exists(select top 1 1 from #tempOrderBomDet)
					begin
						--���ͬһ����λ+����������������ϸ�Ļ�
						--ֻ�ܱ���һ���ĳ�ʼ��λ����������Ķ�Ҫupdate��0
						--���⹤λ��������
						update bom set OpRefQty = 0
						from #tempOrderBomDet as bom inner join
						--��������͹�λ�ٰ������̷�������null��empty����������ǰ�棩���ѷ���Ŵ���1�Ĺ�λ����ȫ����Ϊ0
						(select ROW_NUMBER() over(Partition by Item, OpRef order by ManufactureParty) as PtRowNum, RowId from #tempOrderBomDet) as t 
						on bom.RowId = t.RowId
						where t.PtRowNum > 1
						
						--����װԲ��
						update #tempOrderBomDet set OrderQty = ceiling(OrderQty / UC) * UC, Balance = ceiling(OrderQty / UC) * UC - OrderQty where OrderQty >= 0 and RoundUpOpt = 1 and UC > 0 and ISNULL(ManufactureParty, '') = ''
						update #tempOrderBomDet set OrderQty = 0, Balance = 0 - OrderQty where OrderQty < 0 and ISNULL(ManufactureParty, '') = ''
						update #tempOrderBomDet set OrderQty = ceiling(OrderQty / UC) * UC, Balance = OpRefQty + ceiling(OrderQty / UC) * UC - OrderQty where OrderQty >= 0 and RoundUpOpt = 1 and UC > 0 and ISNULL(ManufactureParty, '') <> ''
						update #tempOrderBomDet set Balance = (case when OrderQty >= 0 then 0 else (OpRefQty - NetOrderQty) end) where Balance is null and ISNULL(ManufactureParty, '') = ''
						update #tempOrderBomDet set Balance = OpRefQty where Balance is null and ISNULL(ManufactureParty, '') <> ''
						
						--���¹�λ����
						update orb set Qty = ISNULL(tod.Balance, 0), [Version] = [Version] + 1, LastModifyDate = @DateTimeNow, LastModifyUser = @CreateUserId, LastModifyUserNm = @CreateUserNm
						from SCM_OpRefBalance as orb 
							inner join (select Item, OpRef, SUM(Balance) as Balance from #tempOrderBomDet group by Item, OpRef) as tod on orb.Item = tod.Item and orb.OpRef = tod.OpRef
						
						--���¹�λ������־
						insert into LOG_OpRefBalanceChange(Item, OpRef, Qty, [Status], [Version], CreateDate, CreateUserId, CreateUserNm)
						select tod.Item, tod.OpRef, ISNULL(tod.Balance, 0), 1, orb.[Version], @DateTimeNow, @CreateUserId, @CreateUserNm
						from SCM_OpRefBalance as orb 
							inner join (select Item, OpRef, SUM(Balance) as Balance from #tempOrderBomDet group by Item, OpRef) as tod on orb.Item = tod.Item and orb.OpRef = tod.OpRef
						
						--���������ڵĹ�λ����
						insert into SCM_OpRefBalance (Item, OpRef, Qty, CreateUser, CreateUserNm, CreateDate, LastModifyUser, LastModifyUserNm, LastModifyDate, [Version])
						select tod.Item, tod.OpRef, ISNULL(tod.Balance, 0), @CreateUserId, @CreateUserNm, @DateTimeNow, @CreateUserId, @CreateUserNm, @DateTimeNow, 1
						from (select Item, OpRef, SUM(Balance) as Balance from #tempOrderBomDet group by Item, OpRef) as tod 
						left join SCM_OpRefBalance as orb on orb.Item = tod.Item and orb.OpRef = tod.OpRef
						where orb.Id is null
						
						--������λ������־
						insert into LOG_OpRefBalanceChange(Item, OpRef, Qty, [Status], [Version], CreateDate, CreateUserId, CreateUserNm)
						select tod.Item, tod.OpRef, ISNULL(tod.Balance, 0), 0, 1, @DateTimeNow, @CreateUserId, @CreateUserNm
						from (select Item, OpRef, SUM(Balance) as Balance from #tempOrderBomDet group by Item, OpRef) as tod 
						left join SCM_OpRefBalance as orb on orb.Item = tod.Item and orb.OpRef = tod.OpRef
						where orb.Id is null
						
						if exists(select top 1 1 from #tempOrderBomDet where OrderQty > 0)
						begin
							--���ܶ�����ϸ
							truncate table #tempOrderDet
							insert into #tempOrderDet(Flow, FlowDetId, Item, Uom, UC, MinUC, UCDesc, Container, ContainerDesc, ManufactureParty, LocFrom, LocTo, OpRef, RefOpRef, ReqQty, OrderQty)
							select det.Flow, det.FlowDetId, det.Item, det.Uom, det.UC, det.MinUC, det.UCDesc, det.Container, det.ContainerDesc, det.ManufactureParty, det.LocFrom, det.LocTo, det.OpRef, det.RefOpRef, SUM(det.NetOrderQty), SUM(det.OrderQty)
							from #tempOrderBomDet as det
							group by det.Flow, det.FlowDetId, det.Item, det.Uom, det.UC, det.MinUC, det.UCDesc, det.Container, det.ContainerDesc, det.ManufactureParty, det.LocFrom, det.LocTo, det.OpRef, det.RefOpRef having SUM(det.OrderQty) > 0
							
							--��ȡ������
							exec USP_GetDocNo_ORD @Flow, 3, @FlowType, 0, 0, 0, @FlowPartyFrom, @FlowPartyTo, @FlowLocTo, @FlowLocFrom, @FlowDock, 0, @OrderNo output
							--��¼������
							update #tempOrderDet set OrderNo = @OrderNo
							--��¼������
							update #tempOrderBomDet set OrderNo = @OrderNo where OrderQty > 0
							
							--��������ͷ
							if (@FlowType = 1)
							begin
								insert into ORD_OrderMstr_1 (
								OrderNo,              --������
								Flow,                 --·��
								OrderStrategy,        --���ԣ�
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
								PartyFromNm,		  --��������
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
								mstr.Code,                 --·��
								3,					  --����
								@FlowType,			  --����
								0,					  --�����ͣ�0����
								0,					  --����״̬��0��Ʒ
								@StartTime,           --��ʼʱ��
								@WindowTime,          --����ʱ��
								0,					  --��ͣ����0
								0,					  --�Ƿ���٣�0
								0,					  --���ȼ���0
								1,					  --״̬��1�ͷ�
								mstr.PartyFrom,            --�������
								pf.Name,            --��������
								mstr.PartyTo,              --�������
								pt.Name,            --��������
								--mstr.LocFrom,              --ԭ���Ͽ�λ
								--lf.Name,				--ԭ���Ͽ�λ
								mstr.LocTo,                --��Ʒ��λ
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
								left join MD_Location as lt on mstr.LocTo = lt.Code						
								where mstr.Code = @Flow
							end
							else if @FlowType = 2
							begin 
								insert into ORD_OrderMstr_2 (
								OrderNo,              --������
								Flow,                 --·��
								OrderStrategy,        --���ԣ�
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
								PartyFromNm,		  --��������
								PartyTo,              --�������
								PartyToNm,            --��������
								LocFrom,              --ԭ���Ͽ�λ
								LocFromNm,            --ԭ���Ͽ�λ
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
								mstr.Code,                 --·��
								3,					  --����
								@FlowType,			  --����
								0,					  --�����ͣ�0����
								0,					  --����״̬��0��Ʒ
								@StartTime,           --��ʼʱ��
								@WindowTime,          --����ʱ��
								0,					  --��ͣ����0
								0,					  --�Ƿ���٣�0
								0,					  --���ȼ���0
								1,					  --״̬��1�ͷ�
								mstr.PartyFrom,            --�������
								pf.Name,            --��������
								mstr.PartyTo,              --�������
								pt.Name,            --��������
								mstr.LocFrom,              --ԭ���Ͽ�λ
								lf.Name,				--ԭ���Ͽ�λ
								mstr.LocTo,                --��Ʒ��λ
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
								left join MD_Location as lf on mstr.LocFrom = lf.Code						
								left join MD_Location as lt on mstr.LocTo = lt.Code						
								where mstr.Code = @Flow
							end
							else
							begin
								RAISERROR(N'·�����Ͳ���ȷ��', 16, 1)
							end
							
							--���Ҷ�������
							select @OrderDetCount = COUNT(*) from #tempOrderDet
							--����OrderDetId�ֶα�ʶ�ֶ�
							exec USP_SYS_BatchGetNextId 'ORD_OrderDet', @OrderDetCount, @EndOrderDetId output
							--���ҿ�ʼ��ʶ
							set @BeginOrderDetId = @EndOrderDetId - @OrderDetCount
							
							--���涩��ID
							truncate table #tempOrderDetId
							insert into #tempOrderDetId(RowId, OrderDetId, OrderDetSeq)
							select RowId, ROW_NUMBER() over (order by RowId) + @BeginOrderDetId as OrderDetId, ROW_NUMBER() over (order by RowId) as OrderDetSeq
							from #tempOrderDet
							
							--��¼������ϸID
							update det set OrderDetId = id.OrderDetId, OrderDetSeq = id.OrderDetSeq
							from #tempOrderDet as det inner join #tempOrderDetId as id
							on det.RowId = id.RowId
							
							--��¼������ϸ��BOM��ϸ�Ĺ�ϵ
							update bom set OrderDetId = det.OrderDetId, OrderDetSeq = det.RowId
							from #tempOrderDet as det inner join #tempOrderBomDet as bom
							on det.Item = bom.Item and det.LocTo = bom.LocTo
							
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
								MinUC,						--��С��װ��1
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
								WMSSeq,						--JIT���㹤λ
								BinTo,						--���͹�λ
								--LocFrom,					--�����λ
								--LocFromNm,					--�����λ����
								LocTo,						--����λ
								LocToNm,					--����λ����
								BillAddr,					--��Ʊ��ַ
								ExtraDmdSource,				--��¼FlowDetId�������0����ϵͳ�Զ�������·����ϸ
								BillTerm					--���㷽ʽ
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
								det.OpRef,					--JIT���㹤λ
								ISNULL(det.RefOpRef, det.OpRef),--���͹�λ
								--det.LocFrom,				--�����λ
								--lf.Name,					--�����λ����
								ISNULL(det.LocTo, mstr.LocTo),	--����λ
								ISNULL(lt.Name, mstr.LocToNm),--����λ
								mstr.BillAddr,				--��Ʊ��ַ
								CONVERT(varchar, det.FlowDetId),--��¼FlowDetId�������0����ϵͳ�Զ�������·����ϸ
								mstr.BillTerm
								from #tempOrderDet as det
								inner join ORD_OrderMstr_1 as mstr on mstr.OrderNo = det.OrderNo
								inner join MD_Item as i on det.Item = i.Code
								--left join MD_Location as lf on det.LocFrom = lf.Code
								left join MD_Location as lt on det.LocTo = lt.Code
								
								--�����ۼƽ�����
								update q set AccumulateQty = ISNULL(q.AccumulateQty, 0) + det.OrderQty, [Version] = q.[Version] + 1
								from SCM_Quota as q 
								inner join (select det.Item, mstr.PartyFrom, SUM(det.OrderQty) as OrderQty
											from #tempOrderDet as det 
											inner join ORD_OrderMstr_1 as mstr on mstr.OrderNo = det.OrderNo
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
								MinUC,						--��С��װ��1
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
								WMSSeq,						--JIT���㹤λ
								BinTo,						--���͹�λ
								LocFrom,					--�����λ
								LocFromNm,					--�����λ����
								LocTo,						--����λ
								LocToNm,					--����λ����
								--BillAddr,					--��Ʊ��ַ
								ExtraDmdSource				--��¼FlowDetId�������0����ϵͳ�Զ�������·����ϸ
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
								det.OpRef,					--JIT���㹤λ
								ISNULL(det.RefOpRef, det.OpRef),--���͹�λ
								ISNULL(det.LocFrom, mstr.LocFrom),--�����λ
								ISNULL(lf.Name, mstr.LocFromNm),--�����λ
								ISNULL(det.LocTo, mstr.LocTo),	--����λ
								ISNULL(lt.Name, mstr.LocToNm),--����λ
								--mstr.BillAddr,				--��Ʊ��ַ
								CONVERT(varchar, det.FlowDetId)	--��¼FlowDetId�������0����ϵͳ�Զ�������·����ϸ
								from #tempOrderDet as det
								inner join ORD_OrderMstr_2 as mstr on mstr.OrderNo = det.OrderNo
								inner join MD_Item as i on det.Item = i.Code
								left join MD_Location as lf on det.LocFrom = lf.Code
								left join MD_Location as lt on det.LocTo = lt.Code
							end
							
							--��¼��־
							set @Msg = N'�����߱�����Ҫ����' + @OrderNo
							insert into #temp_LOG_GenOrder4VanProdLine(Flow, OrderNo, Lvl, Msg) values(@Flow, @OrderNo, 0, @Msg)
							
							if @FlowType = 1
							begin  --��¼�����ƻ�Э��Ķ�����ϸ
								INSERT INTO SAP_CRSL(EINDT, FRBNR, LIFNR, MATNR, MENGE, SGTXT, WERKS, OrderDetId, [Status], ErrorCount, CreateDate, LastModifyDate)
								select CONVERT(varchar(8), @WindowTime, 112), det.OrderNo, mstr.PartyFrom, det.Item, det.OrderQty, det.OrderDetSeq, r.Plant, det.OrderDetId, 0, 0, @DateTimeNow, @DateTimeNow
								from #tempOrderDet as det
								inner join ORD_OrderMstr_1 as mstr on mstr.OrderNo = det.OrderNo
								inner join MD_Region as r on mstr.PartyTo = r.Code
							end
							else
							begin
								if exists(select top 1 1 from SCM_FlowMstr where Code = @Flow and PartyFrom in ('LOC','SQC'))
								begin
									--��¼FIS_CreateProcurementOrderDAT
									INSERT INTO FIS_CreateProcurementOrderDAT(OrderNo, Van, OrderStrategy, StartTime, WindowTime, Priority, 
									Sequence, PartyFrom, PartyTo, Dock, CreateDate, Flow, LineSeq, Item, ManufactureParty, 
									LocationTo, Bin, OrderedQty, IsShipExceed, FileName, IsCreateDat)
									select det.OrderNo, '', mstr.OrderStrategy, mstr.StartTime, mstr.WindowTime, mstr.Priority,
									'', ISNULL(det.LocFrom, mstr.LocFrom), ISNULL(det.LocTo, mstr.LocTo), mstr.Dock, mstr.CreateDate, mstr.Flow, det.OrderDetId, det.Item, det.ManufactureParty, 
									ISNULL(det.RefOpRef, det.OpRef), '', det.OrderQty, mstr.IsShipExceed, '', 0
									from #tempOrderDet as det
									inner join ORD_OrderMstr_2 as mstr on mstr.OrderNo = det.OrderNo
								end
								/**else if exists(select top 1 1 from SCM_FlowMstr where Code = @Flow and PartyFrom in ('SQC'))
								begin
									--��¼FIS_CreateOrderDAT
									INSERT INTO FIS_CreateOrderDAT(OrderNo, MATNR, LIFNR, ENMNG, CHARG, COLOR, TIME_STAMP, CY_SEQNR,
									TIME_STAMP1, AUFNR, LGORT, UMLGO, LGPBE, REQ_TIME_STAMP, FLG_SORT, PLNBEZ, KTEXT, ZPLISTNO, 
									ErrorCount, IsCreateDat, CreateUserNm)
									select det.OrderNo, det.Item, det.ManufactureParty, det.OrderQty, '', '', REPLACE(REPLACE(REPLACE(CONVERT(varchar(50),mstr.CreateDate,120),':',''),'-',''),' ',''), '',
									null, '', ISNULL(det.LocFrom, mstr.LocFrom), ISNULL(det.LocTo, mstr.LocTo), det.OpRef, REPLACE(REPLACE(REPLACE(CONVERT(varchar(50),mstr.WindowTime,120),':',''),'-',''),' ',''), 'N', '', '', det.OrderDetId,
									0, 0, @CreateUserNm
									from #tempOrderDet as det
									inner join ORD_OrderMstr_2 as mstr on mstr.OrderNo = det.OrderNo
								end**/
							end
						end
						
						--Log: JIT����������ϸ
						insert into LOG_VanOrderTrace(UUID, Flow, OrderNo, OrderDetSeq, OrderDetId, [Priority], StartTime, WindowTime, EMWindowTime, ReqTimeFrom, ReqTimeTo, 
							Item, RefItemCode, ItemDesc, Uom, UC, ManufactureParty, Location, OpRef, NetOrderQty, OrgOpRefQty, GrossOrderQty, OpRefQty, BatchNo) 
						select UUID, bom.Flow, bom.OrderNo, bom.OrderDetSeq, bom.OrderDetId, 0, @StartTime, @WindowTime, @EMWindowTime, @ReqTimeFrom, @ReqTimeTo, 
							bom.Item, i.RefCode, i.Desc1, bom.Uom, bom.UC, bom.ManufactureParty, bom.LocTo, bom.OpRef, bom.NetOrderQty, bom.OpRefQty, bom.OrderQty, bom.Balance, @BatchNo
						from #tempOrderBomDet as bom inner join MD_Item as i on bom.Item = i.Code
						
						--Log: JIT����������ϸ��BOM�Ĺ�ϵ
						insert into LOG_VanOrderBomTrace(UUID, ProdLine, VanOrderNo, VanOrderBomDetId, Item, RefItemCode, ItemDesc, OpRef, LocFrom, LocTo, OrderQty, CPTime, BatchNo)
						select tod.UUID, bomCP.VanProdLine, bomCP.OrderNo, bomCP.BomId, bomCP.Item, i.RefCode, i.Desc1, bomCP.OpRef, fdet.LocFrom, fdet.LocTo, bomCP.OrderQty, bomCP.CPTime, @BatchNo 
						from LE_OrderBomCPTimeSnapshot as bomCP
						inner join LE_FlowDetSnapShot as fdet on bomCP.Item = fdet.Item and bomCP.Location = fdet.LocTo
						inner join #tempOrderBomDet as tod on tod.Item = bomCP.Item and tod.OpRef = bomCP.OpRef
						inner join MD_Item as i on tod.Item = i.Code
						where fdet.Flow = @Flow and fdet.Strategy = 3 and bomCP.CPTime >= @ReqTimeFrom and bomCP.CPTime < @ReqTimeTo and bomCP.IsCreateOrder = 0
						
						--�������JIT������ϱ��
						update bom set IsCreateOrder = 1, [Version] = bom.[Version] + 1, LastModifyDate = @DateTimeNow, LastModifyUser = @CreateUserId, LastModifyUserNm = @CreateUserNm
						from ORD_OrderBomDet as bom
						inner join LE_OrderBomCPTimeSnapshot as bomCP on bom.Id = bomCP.BomId
						inner join LE_FlowDetSnapShot as fdet on bomCP.Item = fdet.Item and bomCP.Location = fdet.LocTo
						where fdet.Flow = @Flow and fdet.Strategy = 3 and bomCP.CPTime >= @ReqTimeFrom and bomCP.CPTime < @ReqTimeTo and bomCP.IsCreateOrder = 0
						
						update bomCP set IsCreateOrder = 1
						from LE_OrderBomCPTimeSnapshot as bomCP
						inner join LE_FlowDetSnapShot as fdet on bomCP.Item = fdet.Item and bomCP.Location = fdet.LocTo
						where fdet.Flow = @Flow and fdet.Strategy = 3 and bomCP.CPTime >= @ReqTimeFrom and bomCP.CPTime < @ReqTimeTo and bomCP.IsCreateOrder = 0
					end
					
					--��¼��־
					set @Msg = N'����·���������������߱�����Ҫ��������'
					insert into #temp_LOG_GenOrder4VanProdLine(Flow, Lvl, Msg) values(@Flow, 0, @Msg)
				end
				-------------------��������������-----------------------
				
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
				
				--��¼��־
				set @Msg = N'����·�����������߱�����Ҫ���������쳣���쳣��Ϣ��' +  + Error_Message()
				insert into #temp_LOG_GenOrder4VanProdLine(Flow, Lvl, Msg) values(@Flow, 1, @Msg)
			end catch	
		end
		
		insert into LOG_GenOrder4VanProdLine(OrderNo, Flow, Lvl, Msg, CreateDate, BatchNo) 
		select OrderNo, Flow, Lvl, Msg, CreateDate, @BatchNo from #temp_LOG_GenOrder4VanProdLine
	
		set @FlowId = @FlowId + 1
	end
	
	--��¼��־
	set @Msg = N'���������߱�����Ҫ��������'
	insert into LOG_GenOrder4VanProdLine(Lvl, Msg, BatchNo) values(0, @Msg, @BatchNo)
	
	drop table #tempIgnoreWorkCenter
	drop table #temp_LOG_GenOrder4VanProdLine
	drop table #tempOrderDetId
	drop table #tempOrderDet
	drop table #tempOrderBomDet
END 