SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF EXISTS(SELECT * FROM SYS.OBJECTS WHERE TYPE='P' AND name='USP_LE_GenJITOrder')
	DROP PROCEDURE USP_LE_GenJITOrder	
GO

CREATE PROCEDURE [dbo].[USP_LE_GenJITOrder]
(
	@Flow varchar(50),
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
	
	create table #tempExtraDemandSourceOrderPlan
	(
		Id int,
	)
	
	create table #tempOrderDet
	(
		RowId int identity(1, 1) Primary Key,
		UUID varchar(50),
		FlowDetSnapshotId int,
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
		Routing varchar(50),
		SafeStock decimal(18, 8),
		MaxStock decimal(18, 8),
		MinLotSize decimal(18, 8),
		RoundUpOpt tinyint,
		ReqQty decimal(18, 8),
		OrderQty decimal(18, 8),
		OrderNo varchar(50),
		OrderDetId int,
		OrderDetSeq int,
	)
	
	Create table #tempOrderDetId
	(
		RowId int,
		OrderDetId int,
		OrderDetSeq int
	)
	
	create table #tempCreatedEMOrderDet
	(
		Item varchar(50), 
		RefItemCode varchar(50), 
		ItemDesc1 varchar(100), 
		ManufactureParty varchar(50), 
		Location varchar(50), 
		OrderNo varchar(50), 
		ReqTime datetime, 
		OrderQty decimal(18, 8)
	)
	
	CREATE TABLE #temp_LOG_GenJITOrder(
		Flow varchar(50) NULL,
		OrderNo varchar(50) NULL,
		Lvl tinyint NULL,
		Msg varchar(500) NULL,
		CreateDate datetime NULL default(GETDATE()),
	)
	
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

	select @FlowType = [Type],
	@FlowPartyFrom = PartyFrom, @FlowPartyTo = PartyTo, @FlowLocFrom = LocFrom, @FlowLocTo = LocTo,
	@FlowDock = Dock, @StartTime = OrderTime, @WindowTime = WindowTime, @EMWindowTime = EMWindowTime,
	@ReqTimeFrom = ReqTimeFrom, @ReqTimeTo = ReqTimeTo
	from LE_FlowMstrSnapShot where Flow = @Flow
	
	set @trancount = @@trancount
	begin try
		if @trancount = 0
		begin
            begin tran
        end
        
        --������������Դ����Դ��λ��Ŀ�Ŀ�λ��ͬ������
        truncate table #tempExtraDemandSourceOrderPlan
        insert into #tempExtraDemandSourceOrderPlan(Id) select ip.Id 
		from LE_FlowDetSnapShot as det
		inner join LE_FlowDetExtraDmdSourceSnapshot as dmd on det.Id = dmd.FlowDetSnapShotId
		inner join LE_OrderPlanSnapshot as ip on det.Item = ip.Item 
				and ((dmd.Location = ip.Location and det.LocTo = ip.RefLocation) or (det.LocTo = ip.Location and dmd.Location = ip.RefLocation))
		where det.Flow = @Flow and det.Strategy = 3

		
		-------------------�������������-----------------------
		--��¼��־
		set @Msg = N'����·����������JIT����Ҫ������ʼ������ʱ��С��' + convert(varchar, @ReqTimeFrom, 120)
		insert into #temp_LOG_GenJITOrder(Flow, Lvl, Msg) values(@Flow, 0, @Msg)

		truncate table #tempOrderDet
		insert into #tempOrderDet(UUID, FlowDetSnapshotId, Flow, FlowDetId, Item, Uom, UC, MinUC, UCDesc, Container, ContainerDesc, 
								ManufactureParty, LocFrom, LocTo, Routing,
								ReqQty, SafeStock, MaxStock, MinLotSize, RoundUpOpt)
		select NEWID(), det.Id, det.Flow, det.FlowDetId, det.Item, det.Uom, det.UC, det.MinUC, det.UCDesc, det.Container, det.ContainerDesc,
		det.ManufactureParty, det.LocFrom, det.LocTo, det.Routing,
		--��ȫ����� + ���� - ��� - ����
		det.SafeStock + ISNULL(ip.IssQty, 0) - ISNULL(loc.Qty, 0) - ISNULL(op.RctQty, 0) as ReqQty,
		ISNULL(det.SafeStock, 0) as SafeStock, ISNULL(det.MaxStock, 0) as MaxStock, ISNULL(det.MinLotSize, 0) as MinLotSize, ISNULL(det.RoundUpOpt, 0) as RoundUpOpt
		from LE_FlowDetSnapShot as det
		left join LE_LocationDetSnapshot as loc on det.Item = loc.Item and det.LocTo = loc.Location
		left join (select ip.Item, ip.Location, SUM(ip.OrderQty - ip.FinishQty) as IssQty 
					from LE_FlowDetSnapShot as det
					inner join LE_OrderPlanSnapshot as ip on det.Item = ip.Item and det.LocTo = ip.Location
					where det.Flow = @Flow and det.Strategy = 3 and ip.IRType = 0 and ip.ReqTime < @ReqTimeFrom
					and not exists(select top 1 1 from #tempExtraDemandSourceOrderPlan as edop where edop.Id = ip.Id)  --���˵���������Դ����Դ��λ��Ŀ�Ŀ�λ��ͬ������
					group by ip.Item, ip.Location
					) as ip on det.Item = ip.Item and det.LocTo = ip.Location  --����
		left join (select op.Item, op.Location, SUM(op.OrderQty - op.FinishQty) as RctQty 
					from LE_FlowDetSnapShot as det
					inner join LE_OrderPlanSnapshot as op on det.Item = op.Item and det.LocTo = op.Location
					where det.Flow = @Flow and det.Strategy = 3 and op.IRType = 1 and op.ReqTime < @ReqTimeFrom
					and not exists(select top 1 1 from #tempExtraDemandSourceOrderPlan as edop where edop.Id = op.Id)  --���˵���������Դ����Դ��λ��Ŀ�Ŀ�λ��ͬ������
					group by op.Item, op.Location
					) as op on det.Item = op.Item and det.LocTo = op.Location  --����
		where det.Flow = @Flow and det.Strategy = 3

		truncate table #tempCreatedEMOrderDet
		if exists(select top 1 1 from #tempOrderDet)
		begin
			----����·����ϸ�ֶ�
			--update tdet set Flow = det.Flow, FlowDetId = det.FlowDetId, Uom = det.Uom, UC = det.UC, ManufactureParty = det.ManufactureParty, LocFrom = det.LocFrom, 
			--SafeStock = ISNULL(det.SafeStock, 0), MaxStock = ISNULL(det.MaxStock, 0), MinLotSize = ISNULL(det.MinLotSize, 0), RoundUpOpt = ISNULL(det.RoundUpOpt, 0)
			--from #tempOrderDet as tdet inner join LE_FlowDetSnapShot as det
			--on tdet.Item = det.Item and tdet.LocTo = det.LocTo
			
			--��������Դ
			update det set ReqQty = det.ReqQty + dmd.ReqQty
			from #tempOrderDet as det
			inner join (select det.Item, det.LocTo, SUM(dmdDet.SafeStock + ISNULL(ip.IssQty, 0) - ISNULL(loc.Qty, 0) - ISNULL(op.RctQty, 0)) as ReqQty
						from LE_FlowDetSnapShot as det
						inner join LE_FlowDetExtraDmdSourceSnapshot as dmd on det.Id = dmd.FlowDetSnapShotId
						inner join LE_FlowDetSnapShot as dmdDet on dmd.FlowDetSnapShotId = dmdDet.Id
						left join LE_LocationDetSnapshot as loc on det.Item = loc.Item and dmd.Location = loc.Location
						left join (select det.Item, det.LocTo as Location, SUM(ip.OrderQty - ip.FinishQty) as IssQty 
									from LE_FlowDetSnapShot as det
									inner join LE_FlowDetExtraDmdSourceSnapshot as dmd on det.Id = dmd.FlowDetSnapShotId
									inner join LE_OrderPlanSnapshot as ip on det.Item = ip.Item and dmd.Location = ip.Location
									where det.Flow = @Flow and det.Strategy = 3 and ip.IRType = 0 and ip.ReqTime < @ReqTimeFrom
									and not exists(select top 1 1 from #tempExtraDemandSourceOrderPlan as edop where edop.Id = ip.Id)  --���˵���������Դ����Դ��λ��Ŀ�Ŀ�λ��ͬ������
									group by det.Item, det.LocTo
									) as ip on det.Item = ip.Item and det.LocTo = ip.Location  --����
						left join (select det.Item, det.LocTo as Location, SUM(op.OrderQty - op.FinishQty) as RctQty 
									from LE_FlowDetSnapShot as det
									inner join LE_FlowDetExtraDmdSourceSnapshot as dmd on det.Id = dmd.FlowDetSnapShotId
									inner join LE_OrderPlanSnapshot as op on det.Item = op.Item and dmd.Location = op.Location
									where det.Flow = @Flow and det.Strategy = 3 and op.IRType = 1 and op.ReqTime < @ReqTimeFrom
									and not exists(select top 1 1 from #tempExtraDemandSourceOrderPlan as edop where edop.Id = op.Id)  --���˵���������Դ����Դ��λ��Ŀ�Ŀ�λ��ͬ������
									group by det.Item, det.LocTo
									) as op on det.Item = op.Item and det.LocTo = op.Location  --����	
						where det.Flow = @Flow and det.Strategy = 3
						group by det.Item, det.LocTo) as dmd on det.Item = dmd.Item and det.LocTo = dmd.LocTo
	
			--����װԲ��
			update #tempOrderDet set OrderQty = ReqQty where ReqQty > 0 and RoundUpOpt = 0  --��Բ��
			update #tempOrderDet set OrderQty = ReqQty where ReqQty > 0 and UC <= 0  --��Բ��
			update #tempOrderDet set OrderQty = ceiling(ReqQty / UC) * UC where ReqQty > 0 and RoundUpOpt = 1 and UC > 0  --����Բ��
			update #tempOrderDet set OrderQty = floor(ReqQty / UC) * UC where ReqQty > 0 and RoundUpOpt = 2 and UC > 0  --����Բ��
			
			if exists(select top 1 1 from #tempOrderDet where OrderQty >= MinLotSize and OrderQty > 0)
			begin
				--��ȡ������
				exec USP_GetDocNo_ORD @Flow, 3, @FlowType, 0, 0, 1, @FlowPartyFrom, @FlowPartyTo, @FlowLocTo, @FlowLocFrom, @FlowDock, 0, @OrderNo output
				
				--��¼������
				update #tempOrderDet set OrderNo = @OrderNo where OrderQty >= MinLotSize and OrderQty > 0
				
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
				select @OrderDetCount = COUNT(*) from #tempOrderDet where OrderQty >= MinLotSize and OrderQty > 0
				--����OrderDetId�ֶα�ʶ�ֶ�
				exec USP_SYS_BatchGetNextId 'ORD_OrderDet', @OrderDetCount, @EndOrderDetId output
				--���ҿ�ʼ��ʶ
				set @BeginOrderDetId = @EndOrderDetId - @OrderDetCount
				
				--���涩��ID
				truncate table #tempOrderDetId
				insert into #tempOrderDetId(RowId, OrderDetId, OrderDetSeq)
				select RowId, ROW_NUMBER() over (order by RowId) + @BeginOrderDetId as OrderDetId, ROW_NUMBER() over (order by RowId) as OrderDetSeq
				from #tempOrderDet where OrderQty >= MinLotSize and OrderQty > 0
				
				--��¼������ϸID
				update det set OrderDetId = id.OrderDetId, OrderDetSeq = id.OrderDetSeq
				from #tempOrderDet as det inner join #tempOrderDetId as id
				on det.RowId = id.RowId
						
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
					Routing						--������
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
					det.Routing					--������
					from #tempOrderDet as det
					inner join ORD_OrderMstr_1 as mstr on mstr.OrderNo = det.OrderNo
					inner join MD_Item as i on det.Item = i.Code
					--left join MD_Location as lf on det.LocFrom = lf.Code
					left join MD_Location as lt on det.LocTo = lt.Code
					where det.OrderQty >= det.MinLotSize and det.OrderQty > 0
					
					--�����ۼƽ�����
					update q set AccumulateQty = ISNULL(q.AccumulateQty, 0) + det.OrderQty, [Version] = q.[Version] + 1
					from SCM_Quota as q 
					inner join (select det.Item, mstr.PartyFrom, SUM(det.OrderQty) as OrderQty
								from #tempOrderDet as det 
								inner join ORD_OrderMstr_1 as mstr on mstr.OrderNo = det.OrderNo
								where OrderQty >= MinLotSize and OrderQty > 0
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
					Routing						--������
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
					det.Routing					--������
					from #tempOrderDet as det
					inner join ORD_OrderMstr_2 as mstr on mstr.OrderNo = det.OrderNo
					inner join MD_Item as i on det.Item = i.Code
					left join MD_Location as lf on det.LocFrom = lf.Code
					left join MD_Location as lt on det.LocTo = lt.Code
					where det.OrderQty >= det.MinLotSize and det.OrderQty > 0
				end
							
				--��¼��־
				set @Msg = N'����JIT����Ҫ����' + @OrderNo
				insert into #temp_LOG_GenJITOrder(Flow, OrderNo, Lvl, Msg) values(@Flow, @OrderNo, 0, @Msg)
				
				--�����Ѿ������Ľ���������ϸ
				insert into #tempCreatedEMOrderDet(Item, RefItemCode, ItemDesc1, ManufactureParty, Location, OrderNo, ReqTime, OrderQty)
				select det.Item, i.RefCode, i.Desc1, det.ManufactureParty, det.LocTo, det.OrderNo, @EMWindowTime, det.OrderQty
				from #tempOrderDet as det
				inner join MD_Item as i on det.Item = i.Code
				where det.OrderQty >= det.MinLotSize and det.OrderQty > 0
				
				if @FlowType = 1
				begin  --��¼�����ƻ�Э��Ķ�����ϸ
					INSERT INTO SAP_CRSL(EINDT, FRBNR, LIFNR, MATNR, MENGE, SGTXT, WERKS, OrderDetId, [Status], ErrorCount, CreateDate, LastModifyDate)
					select CONVERT(varchar(8), @EMWindowTime, 112), det.OrderNo, mstr.PartyFrom, det.Item, det.OrderQty, det.OrderDetSeq, r.Plant, det.OrderDetId, 0, 0, @DateTimeNow, @DateTimeNow
					from #tempOrderDet as det
					inner join ORD_OrderMstr_1 as mstr on mstr.OrderNo = det.OrderNo
					inner join MD_Region as r on mstr.PartyTo = r.Code
					where det.OrderQty >= det.MinLotSize and det.OrderQty > 0
				end
				else
				begin
					if exists(select top 1 1 from SCM_FlowMstr where Code = @Flow and PartyFrom in ('LOC','SQC'))
					begin
						--��¼FIS_CreateProcurementOrderDAT
						INSERT INTO FIS_CreateProcurementOrderDAT(OrderNo, Van, OrderStrategy, StartTime, WindowTime, Priority, 
						Sequence, PartyFrom, PartyTo, Dock, CreateDate, Flow, LineSeq, Item, ManufactureParty, 
						LocationTo, Bin, OrderedQty, IsShipExceed, FileName, IsCreateDat, Routing)
						select det.OrderNo, '', mstr.OrderStrategy, mstr.StartTime, mstr.WindowTime, mstr.Priority,
						'', ISNULL(det.LocFrom, mstr.LocFrom), ISNULL(det.LocTo, mstr.LocTo), mstr.Dock, mstr.CreateDate, mstr.Flow, det.OrderDetId, det.Item, det.ManufactureParty, 
						'', '', det.OrderQty, mstr.IsShipExceed, '', 0, det.Routing
						from #tempOrderDet as det
						inner join ORD_OrderMstr_2 as mstr on mstr.OrderNo = det.OrderNo
						where det.OrderQty >= det.MinLotSize and det.OrderQty > 0
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
						where det.OrderQty >= det.MinLotSize and det.OrderQty > 0
					end**/
				end	
			end
			
			--Log: JIT����������ϸ
			insert into LOG_OrderTrace(UUID, Flow, OrderNo, OrderDetSeq, OrderDetId, [Priority], StartTime, WindowTime, EMWindowTime, ReqTimeFrom, ReqTimeTo, 
				Item, RefItemCode, ItemDesc, Uom, UC, ManufactureParty, LocFrom, LocTo, SafeStock, MaxStock, MinLotSize, RoundUpOpt, ReqQty, OrderQty, BatchNo) 
			select UUID, det.Flow, det.OrderNo, det.OrderDetSeq, det.OrderDetId, 1, @StartTime, @WindowTime, @EMWindowTime, @ReqTimeFrom, @ReqTimeTo, 
				det.Item, i.RefCode, i.Desc1, det.Uom, det.UC, det.ManufactureParty, det.LocFrom, det.LocTo, det.SafeStock, det.MaxStock, det.MinLotSize, det.RoundUpOpt, det.ReqQty, det.OrderQty, @BatchNo
			from #tempOrderDet as det inner join MD_Item as i on det.Item = i.Code
			--where det.OrderQty >= det.MinLotSize and det.OrderQty > 0

			insert into LOG_OrderTraceDet(UUID, [Type], Item, RefItemCode, ItemDesc, ManufactureParty, Location, OrderNo, ReqTime, OrderQty, FinishQty, BatchNo)
			--Log: JIT����������ϸ�Ϳ���ϵ
			select det.UUID, 'LOC', loc.Item, i.RefCode, i.Desc1, null, loc.Location, null, null, loc.Qty, 0, @BatchNo
			from #tempOrderDet as det
			inner join LE_LocationDetSnapshot as loc on det.Item = loc.Item and det.LocTo = loc.Location
			inner join MD_Item as i on loc.Item = i.Code
			union all
			--Log: JIT����������ϸ�ʹ�����ϵ
			select det.UUID, 'ISS', ip.Item, i.RefCode, i.Desc1, ip.ManufactureParty, ip.Location, ip.OrderNo, ip.ReqTime, -ip.OrderQty, -ip.FinishQty, @BatchNo
			from #tempOrderDet as det
			inner join LE_OrderPlanSnapshot as ip on det.Item = ip.Item and det.LocTo = ip.Location and ip.IRType = 0 and ip.ReqTime < @ReqTimeFrom  --����
			inner join MD_Item as i on ip.Item = i.Code
			where not exists(select top 1 1 from #tempExtraDemandSourceOrderPlan as edop where edop.Id = ip.Id)  --���˵���������Դ����Դ��λ��Ŀ�Ŀ�λ��ͬ������
			union all
			--Log: JIT����������ϸ�ʹ��չ�ϵ
			select det.UUID, 'RCT', op.Item, i.RefCode, i.Desc1, op.ManufactureParty, op.Location, op.OrderNo, op.ReqTime, op.OrderQty, op.FinishQty, @BatchNo
			from #tempOrderDet as det
			inner join LE_OrderPlanSnapshot as op on det.Item = op.Item and det.LocTo = op.Location and op.IRType = 1 and op.ReqTime < @ReqTimeFrom  --����
			inner join MD_Item as i on op.Item = i.Code
			where not exists(select top 1 1 from #tempExtraDemandSourceOrderPlan as edop where edop.Id = op.Id)  --���˵���������Դ����Դ��λ��Ŀ�Ŀ�λ��ͬ������
			union all
			--Log: JIT����������ϸ�Ϳ���ϵ����������Դ��
			select det.UUID, 'LOC', loc.Item, i.RefCode, i.Desc1, null, loc.Location, null, null, loc.Qty, 0, @BatchNo
			from #tempOrderDet as det
			inner join LE_FlowDetExtraDmdSourceSnapshot as dmd on det.FlowDetSnapshotId = dmd.FlowDetSnapshotId
			inner join LE_LocationDetSnapshot as loc on det.Item = loc.Item and dmd.Location = loc.Location	
			inner join MD_Item as i on loc.Item = i.Code
			union all
			--Log: JIT����������ϸ�ʹ�����ϵ
			select det.UUID, 'ISS', ip.Item, i.RefCode, i.Desc1, ip.ManufactureParty, ip.Location, ip.OrderNo, ip.ReqTime, -ip.OrderQty, -ip.FinishQty, @BatchNo
			from #tempOrderDet as det
			inner join LE_FlowDetExtraDmdSourceSnapshot as dmd on det.FlowDetSnapshotId = dmd.FlowDetSnapshotId
			inner join LE_OrderPlanSnapshot as ip on det.Item = ip.Item and dmd.Location = ip.Location and ip.IRType = 0 and ip.ReqTime < @ReqTimeFrom  --����
			inner join MD_Item as i on ip.Item = i.Code
			where not exists(select top 1 1 from #tempExtraDemandSourceOrderPlan as edop where edop.Id = ip.Id)  --���˵���������Դ����Դ��λ��Ŀ�Ŀ�λ��ͬ������
			union all
			--Log: JIT����������ϸ�ʹ��չ�ϵ
			select det.UUID, 'RCT', op.Item, i.RefCode, i.Desc1, op.ManufactureParty, op.Location, op.OrderNo, op.ReqTime, op.OrderQty, op.FinishQty, @BatchNo
			from #tempOrderDet as det
			inner join LE_FlowDetExtraDmdSourceSnapshot as dmd on det.FlowDetSnapshotId = dmd.FlowDetSnapshotId
			inner join LE_OrderPlanSnapshot as op on det.Item = op.Item and dmd.Location = op.Location and op.IRType = 1 and op.ReqTime < @ReqTimeFrom  --����
			inner join MD_Item as i on op.Item = i.Code
			where not exists(select top 1 1 from #tempExtraDemandSourceOrderPlan as edop where edop.Id = op.Id)  --���˵���������Դ����Դ��λ��Ŀ�Ŀ�λ��ͬ������
		end
		
		--��¼��־
		set @Msg = N'����·����������JIT����Ҫ��������'
		insert into #temp_LOG_GenJITOrder(Flow, Lvl, Msg) values(@Flow, 0, @Msg)
		-------------------�������������-----------------------
		
		-------------------��������������-----------------------
		if (@StartTime <= @LERunTime)
		begin
			--��¼��־
			set @Msg = N'����·����������JITҪ������ʼ������ʱ��' + convert(varchar, @StartTime, 120) + N'������ʱ�䷶Χ' + convert(varchar, @ReqTimeFrom, 120) + ' ~ ' + convert(varchar, @ReqTimeTo, 120)
			insert into #temp_LOG_GenJITOrder(Flow, Lvl, Msg) values(@Flow, 0, @Msg)

			truncate table #tempOrderDet
			insert into #tempOrderDet(UUID, FlowDetSnapshotId, Flow, FlowDetId, Item, Uom, UC, MinUC, UCDesc, Container, ContainerDesc,
									ManufactureParty, LocFrom, LocTo, Routing,
									ReqQty, SafeStock, MaxStock, MinLotSize, RoundUpOpt)
			select NEWID(), det.Id, det.Flow, det.FlowDetId, det.Item, det.Uom, det.UC, det.MinUC, det.UCDesc, det.Container, det.ContainerDesc, 
			det.ManufactureParty, det.LocFrom, det.LocTo, det.Routing,
			--��ȫ����� + ���� - ��� - ����
			det.SafeStock + ISNULL(ip.IssQty, 0) - ISNULL(loc.Qty, 0) - ISNULL(op.RctQty, 0) as ReqQty,
			ISNULL(det.SafeStock, 0) as SafeStock, ISNULL(det.MaxStock, 0) as MaxStock, ISNULL(det.MinLotSize, 0) as MinLotSize, ISNULL(det.RoundUpOpt, 0) as RoundUpOpt
			from LE_FlowDetSnapShot as det
			left join LE_LocationDetSnapshot as loc on det.Item = loc.Item and det.LocTo = loc.Location
			left join (select ip.Item, ip.Location, SUM(ip.OrderQty - ip.FinishQty) as IssQty 
						from LE_FlowDetSnapShot as det
						inner join LE_OrderPlanSnapshot as ip on det.Item = ip.Item and det.LocTo = ip.Location
						where det.Flow = @Flow and det.Strategy = 3 and ip.IRType = 0 and ip.ReqTime < @ReqTimeTo
						and not exists(select top 1 1 from #tempExtraDemandSourceOrderPlan as edop where edop.Id = ip.Id)  --���˵���������Դ����Դ��λ��Ŀ�Ŀ�λ��ͬ������
						group by ip.Item, ip.Location
						) as ip on det.Item = ip.Item and det.LocTo = ip.Location  --����
			left join (select op.Item, op.Location, SUM(op.OrderQty - op.FinishQty) as RctQty 
						from LE_FlowDetSnapShot as det
						inner join LE_OrderPlanSnapshot as op on det.Item = op.Item and det.LocTo = op.Location
						where det.Flow = @Flow and det.Strategy = 3 and op.IRType = 1 and op.ReqTime < @ReqTimeTo
						and not exists(select top 1 1 from #tempExtraDemandSourceOrderPlan as edop where edop.Id = op.Id)  --���˵���������Դ����Դ��λ��Ŀ�Ŀ�λ��ͬ������
						group by op.Item, op.Location
						) as op on det.Item = op.Item and det.LocTo = op.Location  --����
			where det.Flow = @Flow and det.Strategy = 3
			
			if exists(select top 1 1 from #tempOrderDet)
			begin
				----����·����ϸ�ֶ�
				--update tdet set Flow = det.Flow, FlowDetId = det.FlowDetId, Uom = det.Uom, UC = det.UC, ManufactureParty = det.ManufactureParty, LocFrom = det.LocFrom, 
				--SafeStock = det.SafeStock, MaxStock = det.MaxStock, MinLotSize = det.MinLotSize, RoundUpOpt = det.RoundUpOpt
				--from #tempOrderDet as tdet inner join LE_FlowDetSnapShot as det
				--on tdet.Item = det.Item and tdet.LocTo = det.LocTo
				
				--��ȥ���������Ĵ���
				update tdet set ReqQty = tdet.ReqQty - det.OrderQty
				from #tempOrderDet as tdet inner join #tempCreatedEMOrderDet as det
				on tdet.Item = det.Item and tdet.LocTo = det.Location
				
				--��������Դ
				update det set ReqQty = det.ReqQty + dmd.ReqQty
				from #tempOrderDet as det
				inner join (select det.Item, det.LocTo, SUM(dmdDet.SafeStock + ISNULL(ip.IssQty, 0) - ISNULL(loc.Qty, 0) - ISNULL(op.RctQty, 0)) as ReqQty
							from LE_FlowDetSnapShot as det
							inner join LE_FlowDetExtraDmdSourceSnapshot as dmd on det.Id = dmd.FlowDetSnapshotId
							inner join LE_FlowDetSnapShot as dmdDet on dmd.FlowDetSnapshotId = dmdDet.Id
							left join LE_LocationDetSnapshot as loc on det.Item = loc.Item and dmd.Location = loc.Location
							left join (select det.Item, det.LocTo as Location, SUM(ip.OrderQty - ip.FinishQty) as IssQty 
										from LE_FlowDetSnapShot as det
										inner join LE_FlowDetExtraDmdSourceSnapshot as dmd on det.Id = dmd.FlowDetSnapshotId
										inner join LE_OrderPlanSnapshot as ip on det.Item = ip.Item and dmd.Location = ip.Location
										where det.Flow = @Flow and det.Strategy = 3 and ip.IRType = 0 and ip.ReqTime < @ReqTimeTo
										and not exists(select top 1 1 from #tempExtraDemandSourceOrderPlan as edop where edop.Id = ip.Id)  --���˵���������Դ����Դ��λ��Ŀ�Ŀ�λ��ͬ������
										group by det.Item, det.LocTo
										) as ip on det.Item = ip.Item and det.LocTo = ip.Location  --����
							left join (select det.Item, det.LocTo as Location, SUM(op.OrderQty - op.FinishQty) as RctQty 
										from LE_FlowDetSnapShot as det
										inner join LE_FlowDetExtraDmdSourceSnapshot as dmd on det.Id = dmd.FlowDetSnapshotId
										inner join LE_OrderPlanSnapshot as op on det.Item = op.Item and dmd.Location = op.Location
										where det.Flow = @Flow and det.Strategy = 3 and op.IRType = 1 and op.ReqTime < @ReqTimeTo
										and not exists(select top 1 1 from #tempExtraDemandSourceOrderPlan as edop where edop.Id = op.Id)  --���˵���������Դ����Դ��λ��Ŀ�Ŀ�λ��ͬ������
										group by det.Item, det.LocTo
										) as op on det.Item = op.Item and det.LocTo = op.Location  --����	
							where det.Flow = @Flow and det.Strategy = 3
							group by det.Item, det.LocTo) as dmd on det.Item = dmd.Item and det.LocTo = dmd.LocTo

				--����װԲ��
				update #tempOrderDet set OrderQty = ReqQty where ReqQty > 0 and RoundUpOpt = 0  --��Բ��
				update #tempOrderDet set OrderQty = ReqQty where ReqQty > 0 and UC <= 0  --��Բ��
				update #tempOrderDet set OrderQty = ceiling(ReqQty / UC) * UC where ReqQty > 0 and RoundUpOpt = 1 and UC > 0  --����Բ��
				update #tempOrderDet set OrderQty = floor(ReqQty / UC) * UC where ReqQty > 0 and RoundUpOpt = 2 and UC > 0  --����Բ��
				
				if exists(select top 1 1 from #tempOrderDet where OrderQty >= MinLotSize and OrderQty > 0)
				begin
					--��ȡ������
					exec USP_GetDocNo_ORD @Flow, 3, @FlowType, 0, 0, 0, @FlowPartyFrom, @FlowPartyTo, @FlowLocTo, @FlowLocFrom, @FlowDock, 0, @OrderNo output
					
					--��¼������
					update #tempOrderDet set OrderNo = @OrderNo where OrderQty >= MinLotSize and OrderQty > 0
					
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
						@StartTime,			  --��ʼʱ��
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
						@StartTime,			  --��ʼʱ��
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
					select @OrderDetCount = COUNT(*) from #tempOrderDet where OrderQty >= MinLotSize and OrderQty > 0
					--����OrderDetId�ֶα�ʶ�ֶ�
					exec USP_SYS_BatchGetNextId 'ORD_OrderDet', @OrderDetCount, @EndOrderDetId output
					--���ҿ�ʼ��ʶ
					set @BeginOrderDetId = @EndOrderDetId - @OrderDetCount
					
					--���涩��ID
					truncate table #tempOrderDetId
					insert into #tempOrderDetId(RowId, OrderDetId, OrderDetSeq)
					select RowId, ROW_NUMBER() over (order by RowId) + @BeginOrderDetId as OrderDetId, ROW_NUMBER() over (order by RowId) as OrderDetSeq
					from #tempOrderDet where OrderQty >= MinLotSize and OrderQty > 0
					
					--��¼������ϸID
					update det set OrderDetId = id.OrderDetId, OrderDetSeq = id.OrderDetSeq
					from #tempOrderDet as det inner join #tempOrderDetId as id
					on det.RowId = id.RowId						
					
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
						--LocFrom,					--�����λ
						--LocFromNm,					--�����λ����
						LocTo,						--����λ
						LocToNm,					--����λ����
						BillAddr,					--��Ʊ��ַ
						ExtraDmdSource,				--��¼FlowDetId�������0����ϵͳ�Զ�������·����ϸ
						BillTerm,					--���㷽ʽ
						Routing						--������
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
						mstr.BillTerm,					--���㷽ʽ
						det.Routing					--������
						from #tempOrderDet as det
						inner join ORD_OrderMstr_1 as mstr on mstr.OrderNo = det.OrderNo
						inner join MD_Item as i on det.Item = i.Code
						--left join MD_Location as lf on det.LocFrom = lf.Code
						left join MD_Location as lt on det.LocTo = lt.Code
						where det.OrderQty >= det.MinLotSize and det.OrderQty > 0
						
						--�����ۼƽ�����
						update q set AccumulateQty = ISNULL(q.AccumulateQty, 0) + det.OrderQty, [Version] = q.[Version] + 1
						from SCM_Quota as q 
						inner join (select det.Item, mstr.PartyFrom, SUM(det.OrderQty) as OrderQty
									from #tempOrderDet as det 
									inner join ORD_OrderMstr_1 as mstr on mstr.OrderNo = det.OrderNo
									where OrderQty >= MinLotSize and OrderQty > 0
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
						LocFrom,					--�����λ
						LocFromNm,					--�����λ����
						LocTo,						--����λ
						LocToNm,					--����λ����
						--BillAddr,					--��Ʊ��ַ
						ExtraDmdSource,				--��¼FlowDetId�������0����ϵͳ�Զ�������·����ϸ
						Routing						--������
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
						det.Routing					--������
						from #tempOrderDet as det
						inner join ORD_OrderMstr_2 as mstr on mstr.OrderNo = det.OrderNo
						inner join MD_Item as i on det.Item = i.Code
						left join MD_Location as lf on det.LocFrom = lf.Code
						left join MD_Location as lt on det.LocTo = lt.Code
						where det.OrderQty >= det.MinLotSize and det.OrderQty > 0
					end
						
					--��¼��־
					set @Msg = N'����JITҪ����' + @OrderNo
					insert into #temp_LOG_GenJITOrder(Flow, OrderNo, Lvl, Msg) values(@Flow, @OrderNo, 0, @Msg)
					
					if @FlowType = 1
					begin  --��¼�����ƻ�Э��Ķ�����ϸ
						INSERT INTO SAP_CRSL(EINDT, FRBNR, LIFNR, MATNR, MENGE, SGTXT, WERKS, OrderDetId, [Status], ErrorCount, CreateDate, LastModifyDate)
						select CONVERT(varchar(8), @WindowTime, 112), det.OrderNo, mstr.PartyFrom, det.Item, det.OrderQty, det.OrderDetSeq, r.Plant, det.OrderDetId, 0, 0, @DateTimeNow, @DateTimeNow
						from #tempOrderDet as det
						inner join ORD_OrderMstr_1 as mstr on mstr.OrderNo = det.OrderNo
						inner join MD_Region as r on mstr.PartyTo = r.Code
						where det.OrderQty >= det.MinLotSize and det.OrderQty > 0
					end
					else
					begin
						if exists(select top 1 1 from SCM_FlowMstr where Code = @Flow and PartyFrom in ('LOC','SQC'))
						begin
							--��¼FIS_CreateProcurementOrderDAT
							INSERT INTO FIS_CreateProcurementOrderDAT(OrderNo, Van, OrderStrategy, StartTime, WindowTime, Priority, 
							Sequence, PartyFrom, PartyTo, Dock, CreateDate, Flow, LineSeq, Item, ManufactureParty, 
							LocationTo, Bin, OrderedQty, IsShipExceed, FileName, IsCreateDat, Routing)
							select det.OrderNo, '', mstr.OrderStrategy, mstr.StartTime, mstr.WindowTime, mstr.Priority,
							'', det.LocFrom, det.LocTo, mstr.Dock, mstr.CreateDate, mstr.Flow, det.OrderDetId, det.Item, det.ManufactureParty, 
							'', '', det.OrderQty, mstr.IsShipExceed, '', 0, det.Routing
							from #tempOrderDet as det
							inner join ORD_OrderMstr_2 as mstr on mstr.OrderNo = det.OrderNo
							where det.OrderQty >= det.MinLotSize and det.OrderQty > 0
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
							where det.OrderQty >= det.MinLotSize and det.OrderQty > 0
						end**/
					end
				end	
				
				--Log: JIT����������ϸ
				insert into LOG_OrderTrace(UUID, Flow, OrderNo, OrderDetSeq, OrderDetId, [Priority], StartTime, WindowTime, EMWindowTime, ReqTimeFrom, ReqTimeTo, 
					Item, RefItemCode, ItemDesc, Uom, UC, ManufactureParty, LocFrom, LocTo, SafeStock, MaxStock, MinLotSize, RoundUpOpt, ReqQty, OrderQty, BatchNo) 
				select UUID, det.Flow, det.OrderNo, det.OrderDetSeq, det.OrderDetId, 0, @StartTime, @WindowTime, @EMWindowTime, @ReqTimeFrom, @ReqTimeTo, 
					det.Item, i.RefCode, i.Desc1, det.Uom, det.UC, det.ManufactureParty, det.LocFrom, det.LocTo, det.SafeStock, det.MaxStock, det.MinLotSize, det.RoundUpOpt, det.ReqQty, det.OrderQty, @BatchNo
				from #tempOrderDet as det inner join MD_Item as i on det.Item = i.Code
				--where det.OrderQty >= det.MinLotSize and OrderQty > 0

				insert into LOG_OrderTraceDet(UUID, [Type], Item, RefItemCode, ItemDesc, ManufactureParty, Location, OrderNo, ReqTime, OrderQty, FinishQty, BatchNo)
				--Log: JIT����������ϸ�Ϳ���ϵ
				select det.UUID, 'LOC', loc.Item, i.RefCode, i.Desc1, null, loc.Location, null, null, loc.Qty, 0, @BatchNo
				from #tempOrderDet as det
				inner join LE_LocationDetSnapshot as loc on det.Item = loc.Item and det.LocTo = loc.Location
				inner join MD_Item as i on loc.Item = i.Code
				union all
				--Log: JIT����������ϸ�ʹ�����ϵ
				select det.UUID, 'ISS', ip.Item, i.RefCode, i.Desc1, ip.ManufactureParty, ip.Location, ip.OrderNo, ip.ReqTime, -ip.OrderQty, -ip.FinishQty, @BatchNo
				from #tempOrderDet as det
				inner join LE_OrderPlanSnapshot as ip on det.Item = ip.Item and det.LocTo = ip.Location and ip.IRType = 0 and ip.ReqTime < @ReqTimeTo  --����
				inner join MD_Item as i on ip.Item = i.Code
				where not exists(select top 1 1 from #tempExtraDemandSourceOrderPlan as edop where edop.Id = ip.Id)  --���˵���������Դ����Դ��λ��Ŀ�Ŀ�λ��ͬ������
				union all
				--Log: JIT����������ϸ�ʹ��չ�ϵ
				select det.UUID, 'RCT', op.Item, i.RefCode, i.Desc1, op.ManufactureParty, op.Location, op.OrderNo, op.ReqTime, op.OrderQty, op.FinishQty, @BatchNo
				from #tempOrderDet as det
				inner join LE_OrderPlanSnapshot as op on det.Item = op.Item and det.LocTo = op.Location and op.IRType = 1 and op.ReqTime < @ReqTimeTo  --����
				inner join MD_Item as i on op.Item = i.Code
				where not exists(select top 1 1 from #tempExtraDemandSourceOrderPlan as edop where edop.Id = op.Id)  --���˵���������Դ����Դ��λ��Ŀ�Ŀ�λ��ͬ������
				union all
				--Log: JIT����������ϸ�Ϳ���ϵ����������Դ��
				select det.UUID, 'LOC', loc.Item, i.RefCode, i.Desc1, null, loc.Location, null, null, loc.Qty, 0, @BatchNo
				from #tempOrderDet as det
				inner join LE_FlowDetExtraDmdSourceSnapshot as dmd on det.FlowDetSnapshotId = dmd.FlowDetSnapshotId
				inner join LE_LocationDetSnapshot as loc on det.Item = loc.Item and dmd.Location = loc.Location	
				inner join MD_Item as i on loc.Item = i.Code
				union all
				--Log: JIT����������ϸ�ʹ�����ϵ
				select det.UUID, 'ISS', ip.Item, i.RefCode, i.Desc1, ip.ManufactureParty, ip.Location, ip.OrderNo, ip.ReqTime, -ip.OrderQty, -ip.FinishQty, @BatchNo
				from #tempOrderDet as det
				inner join LE_FlowDetExtraDmdSourceSnapshot as dmd on det.FlowDetSnapshotId = dmd.FlowDetSnapshotId
				inner join LE_OrderPlanSnapshot as ip on det.Item = ip.Item and dmd.Location = ip.Location and ip.IRType = 0 and ip.ReqTime < @ReqTimeTo  --����
				inner join MD_Item as i on ip.Item = i.Code
				where not exists(select top 1 1 from #tempExtraDemandSourceOrderPlan as edop where edop.Id = ip.Id)  --���˵���������Դ����Դ��λ��Ŀ�Ŀ�λ��ͬ������
				union all
				--Log: JIT����������ϸ�ʹ��չ�ϵ
				select det.UUID, 'RCT', op.Item, i.RefCode, i.Desc1, op.ManufactureParty, op.Location, op.OrderNo, op.ReqTime, op.OrderQty, op.FinishQty, @BatchNo
				from #tempOrderDet as det
				inner join LE_FlowDetExtraDmdSourceSnapshot as dmd on det.FlowDetSnapshotId = dmd.FlowDetSnapshotId
				inner join LE_OrderPlanSnapshot as op on det.Item = op.Item and dmd.Location = op.Location and op.IRType = 1 and op.ReqTime < @ReqTimeTo  --����
				inner join MD_Item as i on op.Item = i.Code	
				where not exists(select top 1 1 from #tempExtraDemandSourceOrderPlan as edop where edop.Id = op.Id)  --���˵���������Դ����Դ��λ��Ŀ�Ŀ�λ��ͬ������
				union all
				--Log: JIT����������ϸ��֮ǰ����JIT����������ϵ
				select det.UUID, 'RCT', eDet.Item, i.RefCode, i.Desc1, eDet.ManufactureParty, eDet.Location, eDet.OrderNo, eDet.ReqTime, eDet.OrderQty, 0 as FinishQty, @BatchNo
				from #tempOrderDet as det
				inner join #tempCreatedEMOrderDet as eDet on det.Item = eDet.Item and det.LocTo = edet.Location
				inner join MD_Item as i on eDet.Item = i.Code
			end
			
			--��¼��־
			set @Msg = N'����·����������JITҪ��������'
			insert into #temp_LOG_GenJITOrder(Flow, Lvl, Msg) values(@Flow, 0, @Msg)
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
		set @Msg = N'����·����������ҪJIT���������쳣���쳣��Ϣ��' +  + Error_Message()
		insert into #temp_LOG_GenJITOrder(Flow, Lvl, Msg) values(@Flow, 2, @Msg)
	end catch
	
	insert into LOG_GenJITOrder(Flow, OrderNo, Lvl, Msg, CreateDate, BatchNo) 
	select Flow, OrderNo, Lvl, Msg, CreateDate, @BatchNo from #temp_LOG_GenJITOrder
	
	drop table #temp_LOG_GenJITOrder
	drop table #tempCreatedEMOrderDet
	drop table #tempOrderDetId
	drop table #tempOrderDet
END 