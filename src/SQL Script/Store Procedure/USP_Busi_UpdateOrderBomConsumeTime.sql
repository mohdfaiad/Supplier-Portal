SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF EXISTS(SELECT * FROM sys.objects WHERE type='P' AND name='USP_Busi_UpdateOrderBomConsumeTime') 
     DROP PROCEDURE USP_Busi_UpdateOrderBomConsumeTime
GO

CREATE PROCEDURE [dbo].[USP_Busi_UpdateOrderBomConsumeTime] 
(
	@ProdLine varchar(50),
	@CreateUserId int,
	@CreateUserNm varchar(50)
) --WITH ENCRYPTION
AS 
BEGIN
	set nocount on
	declare @DateTimeNow datetime = GetDate()
	declare @ErrorMsg nvarchar(MAX)
	declare @trancount int
	
	Create table #tempRoutingDet
	(
		AssProdLine varchar(50),    --�����ߣ�����Ƿ�װ����������洢��װ������
		AssOp int,               --ԭ�����
		Op int,
		Capacity int,
		JointProdLine varchar(50), --��װ�����ߣ�ֻ�з�װ�����߲���
		JointOp int,             --��װ����ֻ�з�װ�����߲���
		LoopCount int,
		LeadTime int          --��װ��ǰ�ڣ���
	)
	
	Create table #tempRoutingOpRef
	(
		AssProdLine varchar(50),    --�����ߣ�����Ƿ�װ����������洢��װ������
		AssOp int,               --ԭ�����
		Op int, 
		Capacity int,
		JointProdLine varchar(50), --��װ�����ߣ�ֻ�з�װ�����߲���
		JointOp int,             --��װ����ֻ�з�װ�����߲���
		OpRef varchar(50),
		LoopCount int,
		LeadTime int          --��װ��ǰ�ڣ���
	)
	
	create table #tempOrderOpSeq
	(
		Id int identity(1, 1) Primary Key,
		OrderNo  varchar(50), 
		AssProdLine varchar(50), 
		Seq bigint, 
		SubSeq int, 
		VanOp int, 
		AssOp int, 
		Op int, 
		OpTakt int, 
		LoopCount int,
	)
	
	create table #tempOrderOpTakt
	(
		Id int identity(1, 1) Primary Key,
		OrderNo  varchar(50), 
		AssProdLine varchar(50), 
		Seq bigint, 
		SubSeq int, 
		VanOp int, 
		AssOp int, 
		Op int, 
		OpTaktTime int, 
		LoopCount int
	)
	
	create table #tempCPTime
	(
		Id int identity(1, 1) Primary Key,
		OrderNo  varchar(50), 
		AssProdLine varchar(50), 
		Seq bigint, 
		SubSeq int, 
		VanOp int, 
		AssOp int, 
		Op int, 
		OpTaktTime int,
		CPTime datetime
	)
	
	create table #tempCPTime2
	(
		Id int identity(1, 1) Primary Key,
		OrderNo  varchar(50), 
		AssProdLine varchar(50), 
		Seq bigint, 
		SubSeq int, 
		VanOp int, 
		AssOp int, 
		Op int, 
		OpTaktTime int,
		CPTime datetime
	)
	
	--����������ʱ��
	create table #tempWorkingCalendarView
	(
		RowId int Identity(1, 1),
		WorkingDate datetime,
		DateFrom datetime,
		DateTo datetime
	)

	declare @TaktTime int               --����ʱ�䣨�룩
	declare @ProdLineRegion varchar(50) --����������
	declare @ProdLineType tinyint		--����������
	declare @Routing varchar(50)		--��������
	declare @LastOnlineVanSeq bigint    --���һ̨���߳����
	declare @LastOnlineVanSubSeq int    --���һ̨���߳����
	declare @LastOnlineVanStartTime datetime --���һ̨���߳�ʱ��
	declare @ProdLineStartTime datetime --�����߿���ʱ�䣬��׼ʱ������������һ̨���߳�ʱ����ȡ�����߿���ʱ��
	declare @FirstReleaseVanSeq bigint  --��һ̨�ͷų����
	declare @FirstReleaseVanSubSeq int    --��һ̨�ͷų����
	declare @LoopCount int              --������/��װ��������� ����Ϊ1����װ��Ϊ2����װ�ߵķ�װ��Ϊ3����������
	declare @MaxLoopCount int           --������
	declare @MinOp int					--��С����
	declare @MinAssOp int				--��С����
	declare @MinCPTime datetime         --��С����ʱ��  
	declare @MaxCPTime datetime         --������ʱ��
	declare @CPTimeLength int           --��С����ʱ���������ʱ��ĳ���
	declare @WCDateFrom datetime        --����������ʼʱ��
	declare @WCDateTo datetime          --������������ʱ��
	declare @WCCycleRowId int           --��������ѭ����ʶ
	declare @WCMaxRowId int             --������������ʶ
	declare @WCDeepCount int			--��װ��ѭ������
	
	--��ȡ������
	select  @TaktTime = TaktTime, @ProdLineRegion = PartyFrom, @Routing = Routing, @ProdLineType = ProdLineType from SCM_FlowMstr where Code = @ProdLine

	if (@ProdLineType = 4)
	begin  --��װ�ߣ�ȡ�����߿���ʱ�䣬�����̨��������ʱ��С�������߿���ʱ�䣬��̨��������ʱ�� = �����߿���ʱ��
		select @ProdLineStartTime = ProdLineStartTime from CUST_ProductLineMap where SpecialProdLine = @ProdLine
	end
	
	--��ȡ����������ϸ��λ	
	set @LoopCount = 1	
	insert into #tempRoutingOpRef(AssProdLine, AssOp, Op, Capacity, JointProdLine, JointOp, OpRef, LoopCount, LeadTime) 
	--select distinct @ProdLine, Op, Dense_rank() over (order by Op), ISNULL(Capacity, 1) as Capacity, null as JointProdLine, null as JointOp, OpRef, @LoopCount, 0 as LeadTime 
	select distinct @ProdLine, Op, Dense_rank() over (order by Op), 1 as Capacity, null as JointProdLine, null as JointOp, OpRef, @LoopCount, 0 as LeadTime 
	from PRD_RoutingDet 
	where Routing = @Routing
	
	--ѭ�����ҷ�װ�ߵĹ�λ����װ�ߵĹ���Ҫ�Ӻ�װ�㽵��ֵ�����װ����49���򣬷�װ�ߵ����һվ��48�������ڶ�վ��47������������
	--��װ����ͨ�����������еĺ�װ��λ
	while exists(select top 1 1 from #tempRoutingOpRef as tDet
				inner join SCM_FlowBinding as bind on tDet.AssProdLine = bind.MstrFlow
				inner join SCM_FlowMstr as subPL on bind.BindFlow = subPL.Code
				where tDet.LoopCount = @LoopCount)
	begin
		set @LoopCount = @LoopCount + 1
		
		--��ȡ�ϲ���С���������װ�����ߵĺ�װ��û�к��ϲ������߹����Ӧ�ģ�ȡ��С�Ĺ���
		select @MinOp = MIN(Op), @MinAssOp = MIN(AssOp) from #tempRoutingOpRef where LoopCount = @LoopCount - 1
		
		insert into #tempRoutingOpRef(AssProdLine, AssOp, Op, Capacity, JointProdLine, JointOp, OpRef, LoopCount, LeadTime)
		--select opRef.SubProdLine, opRef.AssOp, ISNULL(prevOpRef.Op, @MinOp) - opRef.Op, ISNULL(opRef.Capacity, 1) as Capacity, opRef.JointProdLine, ISNULL(opRef.JointOp, @MinAssOp), opRef.OpRef, @LoopCount, opRef.LeadTime
		select opRef.SubProdLine, opRef.AssOp, ISNULL(prevOpRef.Op, @MinOp) - opRef.Op, 1 as Capacity, opRef.JointProdLine, ISNULL(prevOpRef.Op, @MinOp), opRef.OpRef, @LoopCount, opRef.LeadTime
		from
		(select subPL.Code as SubProdLine, subPL.Routing, rDet.Op as AssOp, Dense_rank() over (Partition by subPL.Code order by rDet.Op desc) as Op, rDet.Capacity,  
		bind.MstrFlow as JointProdLine, bind.JointOp, rDet.OpRef, ISNULL(bind.LeadTime, 0) * 60 * 60 * -1 as LeadTime
		from #tempRoutingOpRef as opRef
		inner join SCM_FlowBinding as bind on opRef.AssProdLine = bind.MstrFlow
		inner join SCM_FlowMstr as subPL on bind.BindFlow = subPL.Code
		inner join PRD_RoutingDet as rDet on rDet.Routing = subPL.Routing
		where opRef.LoopCount = @LoopCount - 1
		group by subPL.Code, subPL.Routing, bind.MstrFlow, bind.JointOp, rDet.Op, rDet.Capacity, rDet.OpRef, bind.LeadTime) as opRef
		left join (select distinct AssOp, Op from #tempRoutingOpRef where LoopCount = @LoopCount - 1) as prevOpRef on opRef.JointOp = prevOpRef.AssOp
	end
	
	--��ȡ����������ϸ		
	insert into #tempRoutingDet(AssProdLine, AssOp, Op, Capacity, JointProdLine, JointOp, LoopCount, LeadTime) 
	select distinct AssProdLine, AssOp, Op, Capacity, JointProdLine, JointOp, LoopCount, LeadTime from #tempRoutingOpRef
	--��ȡ����װ��ѭ������
	select @MaxLoopCount = MAX(LoopCount) from #tempRoutingDet
	
	if exists(select top 1 1 from ORD_OrderMstr_4 with(NOLOCK) where Flow = @ProdLine and [Status] <> 1)
	begin  --�������߳�
		--���̨���߳���ź�����ʱ��
		select top 1 @LastOnlineVanSeq = seq.Seq, @LastOnlineVanSubSeq = seq.SubSeq, @LastOnlineVanStartTime = mstr.StartDate 
		from ORD_OrderMstr_4 as mstr with(NOLOCK)
		inner join ORD_OrderSeq as seq with(NOLOCK) on mstr.OrderNo = seq.OrderNo 
		where mstr.Flow = @ProdLine
		and mstr.[Status] in (2, 3, 4) --�����߳���
		and mstr.PauseStatus <> 2
		order by mstr.StartDate desc
	end
	else
	begin  --û�������߳�
		set @LastOnlineVanSeq = 0
		set @LastOnlineVanSubSeq = 0
		set @LastOnlineVanStartTime = @DateTimeNow
	end

	if @ProdLineStartTime is not null and @ProdLineStartTime > @LastOnlineVanStartTime
	begin  --��̨��������ʱ��С�������߿���ʱ�䣬��̨��������ʱ�� = �����߿���ʱ��
		set @LastOnlineVanStartTime = @ProdLineStartTime
	end

	if exists(select top 1 1 from ORD_OrderMstr_4 with(NOLOCK) where Flow = @ProdLine and [Status] in (0, 1))
	begin  --��δ���߳�
		--��һ̨�ͷų����
		select top 1 @FirstReleaseVanSeq = seq.Seq, @FirstReleaseVanSubSeq = seq.SubSeq 
		from ORD_OrderMstr_4 as mstr with(NOLOCK)
		inner join ORD_OrderSeq as seq with(NOLOCK) on mstr.OrderNo = seq.OrderNo 
		where mstr.Flow = @ProdLine 
		and mstr.[Status] in (0, 1) --���������ͷ�
		and mstr.PauseStatus <> 2
		order by seq.Seq desc, seq.subSeq desc
	end
	else
	begin  --û��δ���߳�
		set @FirstReleaseVanSeq = 0
		set @FirstReleaseVanSubSeq = 0
	end
	
	--if @LastOnlineVanSeq <> 0 or @FirstReleaseVanSeq <> 0
	if exists(select top 1 1 from ORD_OrderMstr_4 with(NOLOCK) where Flow = @ProdLine and [Status] in (0, 1, 2))
	begin
		Declare @PTick DateTime = GetDate()
		--print N'��ʼ��ѯ����ÿ�������˳��'
		--��ѯ����ÿ�������˳��
		set @LoopCount = 1
		insert into #tempOrderOpSeq(OrderNo, AssProdLine, Seq, SubSeq, VanOp, AssOp, Op, OpTakt, LoopCount)
		select baseOp.OrderNo, baseOp.AssProdLine, baseOp.Seq, baseOp.SubSeq, baseOp.AssOp as VanOp, baseOp.AssOp, baseOp.Op, SUM(case when baseOp.Op > op.Op then op.Capacity else 0 end) as OpTakt, @LoopCount
		from
		(select mstr.OrderNo, tRouting.AssProdLine, seq.Seq, seq.SubSeq, tRouting.AssOp, tRouting.Op
		from ORD_OrderSeq as seq with(NOLOCK)
		inner join ORD_OrderMstr_4 as mstr with(NOLOCK) on seq.OrderNo = mstr.OrderNo
		inner join #tempRoutingDet as tRouting on mstr.Flow = tRouting.AssProdLine  --���������ߵĹ�������
		where mstr.Flow = @ProdLine and mstr.[Status] in (0, 1, 2) 
		and (mstr.PauseStatus = 0 or (mstr.PauseStatus = 1 and tRouting.AssOp <= mstr.PauseSeq))  --ȡδ��ͣ��ƻ���ͣǰ�Ĺ���
		and tRouting.LoopCount = @LoopCount) as baseOp
		inner join #tempRoutingDet as op on baseOp.AssProdLine = op.AssProdLine
		where op.LoopCount = @LoopCount
		group by baseOp.OrderNo, baseOp.AssProdLine, baseOp.Seq, baseOp.SubSeq, baseOp.AssOp, baseOp.Op
	
		--ѭ�����ݺ�װ������+��װ���򲢰ѷ�װ�ߵĹ�����뵽��ʱ����
		--��װ�ߵĽ���ʱ��Ҫ�ú�װ��Ľ���ʱ���ȥ��װ������
		--�����һ����λ����Ϊ8,���ڶ�����λ������Ϊ5����װ�ߵĽ���Ϊ53��
		--�����һ����λ�Ľ���Ϊ45,���ڶ�����λ�Ľ���Ϊ40
		set @LoopCount = @LoopCount + 1
		while @LoopCount <= @MaxLoopCount
		begin
			insert into #tempOrderOpSeq(OrderNo, AssProdLine, Seq, SubSeq, VanOp, AssOp, Op, OpTakt, LoopCount)
			select opSeq.OrderNo, det.AssProdLine, opSeq.Seq, opSeq.SubSeq, opSeq.VanOp, det.AssOp, det.Op, opSeq.OpTakt - det.OpTakt, @LoopCount
			from #tempOrderOpSeq as opSeq
			inner join(select det1.AssProdLine, det1.AssOp, det1.Op, det1.JointProdLine, det1.JointOp, SUM(det2.Capacity) as OpTakt 
						from #tempRoutingDet as det1 
						inner join #tempRoutingDet as det2 on det1.AssProdLine = det2.AssProdLine
						where det1.LoopCount = @LoopCount and det2.LoopCount = @LoopCount and det1.Op <= det2.Op
						group by det1.AssProdLine, det1.AssOp, det1.Op, det1.JointProdLine, det1.JointOp) as det on opSeq.AssProdLine = det.JointProdLine and opSeq.Op = det.JointOp
			where opSeq.LoopCount = @LoopCount - 1
			
			set @LoopCount = @LoopCount + 1
		end
		--print N'������ѯ����ÿ�������˳����ʱ' + Convert(varchar(50), DateDiff(MS, @PTick, GetDate()))
		
		set @PTick = GetDate()
		--print N'��ʼ��ѯ����ÿ������Ľ��ģ���ʼʱ��' + convert(varchar(20), @PTick)
		--δ���߳��Ĺ���ʱ��
		insert into #tempOrderOpTakt(OrderNo, AssProdLine, Seq, SubSeq, VanOp, AssOp, Op, OpTaktTime, LoopCount)
		select toos.OrderNo, toos.AssProdLine, toos.Seq, toos.SubSeq, toos.VanOp, toos.AssOp, toos.Op, (toos.OpTakt + COUNT(*)) * @TaktTime, toos.LoopCount
		from #tempOrderOpSeq as toos
		inner join ORD_OrderSeq as seq with(NOLOCK) on toos.Seq > seq.Seq or (toos.Seq = seq.Seq and toos.SubSeq >= seq.SubSeq)
		left join ORD_OrderMstr_4 as mstr with(NOLOCK) on seq.OrderNo = mstr.OrderNo and mstr.Status in (0, 1, 2)
		where seq.ProdLine = @ProdLine and (seq.Seq > @LastOnlineVanSeq or (seq.Seq = @LastOnlineVanSeq and seq.SubSeq > @LastOnlineVanSubSeq))
		group by toos.OrderNo, toos.AssProdLine, toos.Seq, toos.SubSeq, toos.VanOp, toos.AssOp, toos.Op, toos.OpTakt, toos.LoopCount

		--�����߳��Ĺ���ʱ��
		if @LastOnlineVanSeq > 0
		begin
			insert into #tempOrderOpTakt(OrderNo, AssProdLine, Seq, SubSeq, VanOp, AssOp, Op, OpTaktTime, LoopCount)
			select toos.OrderNo, toos.AssProdLine, toos.Seq, toos.SubSeq, toos.VanOp, toos.AssOp, toos.Op, (toos.OpTakt - COUNT(*) + 1) * @TaktTime, toos.LoopCount
			from #tempOrderOpSeq as toos
			inner join ORD_OrderSeq as seq with(NOLOCK) on toos.Seq < seq.Seq or (toos.Seq = seq.Seq and toos.SubSeq <= seq.SubSeq)
			left join ORD_OrderMstr_4 as mstr with(NOLOCK) on seq.OrderNo = mstr.OrderNo and mstr.Status in (0, 1, 2)
			where seq.ProdLine = @ProdLine and (seq.Seq < @LastOnlineVanSeq or (seq.Seq = @LastOnlineVanSeq and seq.SubSeq <= @LastOnlineVanSubSeq))
			group by toos.OrderNo, toos.AssProdLine, toos.Seq, toos.SubSeq, toos.VanOp, toos.AssOp, toos.Op, toos.OpTakt, toos.LoopCount
		end
		--print N'������ѯ����ÿ������Ľ��ģ���ʱ' + Convert(varchar(50), DateDiff(MS, @PTick, GetDate()))

		set @PTick = GetDate()
		--print N'��ʼ����ƫ�������������������Ĺ���ʱ�䣨���������ڵ���0������ʼʱ��' + convert(varchar(20), @PTick)
		--����ƫ�������������������Ĺ���ʱ�䣨û�а�����ʱ�䣩
		truncate table #tempCPTime
		insert into #tempCPTime(OrderNo, AssProdLine, Seq, SubSeq, VanOp, AssOp, Op, OpTaktTime, CPTime)
		select toot.OrderNo, toot.AssProdLine, toot.Seq, toot.SubSeq, toot.VanOp, toot.AssOp, toot.Op, toot.OpTaktTime, DATEADD(SECOND, rd.LeadTime, DATEADD(SECOND, toot.OpTaktTime, @LastOnlineVanStartTime))
		from #tempOrderOpTakt as toot
		inner join #tempRoutingDet as rd on toot.AssProdLine = rd.AssProdLine and toot.AssOp = rd.AssOp
		where toot.OpTaktTime >= 0
		--print N'��������ƫ�������������������Ĺ���ʱ�䣨���������ڵ���0������ʱ' + Convert(varchar(50), DateDiff(MS, @PTick, GetDate()))
	
		set @PTick = GetDate()
		--print N'��ʼѭ�������Ϣʱ�䣨���������ڵ���0������ʼʱ��' + convert(varchar(20), @PTick)
		--ѭ�������Ϣʱ��
		select @MinCPTime = MIN(CPTime), @MaxCPTime = MAX(CPTime) from #tempCPTime
		set @WCDeepCount = 0
		while 1=1
		begin
			if @MinCPTime = @MAXCPTime
			begin  --����ѭ��
				break
			end
			
			truncate table #tempWorkingCalendarView
			insert into #tempWorkingCalendarView(WorkingDate, DateFrom, DateTo) exec USP_Busi_GetWorkingCalendarView @ProdLine, @ProdLineRegion, @MinCPTime, @MaxCPTime
			
			set @WCDateFrom = null
			set @WCDateTo = null
			if exists(select top 1 1 from #tempWorkingCalendarView)
			begin  --�ҵ�����ʱ��
				select @WCCycleRowId = MIN(RowId), @WCMaxRowId = MAX(RowId) from #tempWorkingCalendarView
				
				while @WCCycleRowId <= @WCMaxRowId
				begin
					if @WCDateFrom is null
					begin --��һ����¼����������¼����鿪ʼ�����Ƿ��@MinCPTime֮������Ϣʱ��
						select @WCDateFrom = DateFrom from #tempWorkingCalendarView where RowId = @WCCycleRowId
						
						if @WCDateFrom > @MinCPTime
						begin  --���м�¼���Ͽ�ʼ���ں�@MinCPTime֮�����Ϣʱ��
							update #tempCPTime set CPTime = DateAdd(SECOND, DateDiff(SECOND, @MinCPTime, @WCDateFrom), CPTime) where CPTime >= @MinCPTime
						end
					end
					
					select @WCDateTo = DateTo from #tempWorkingCalendarView where RowId = @WCCycleRowId
					
					if @WCCycleRowId + 1 <= @WCMaxRowId
					begin  --���к�����������
						select @WCDateFrom = DateFrom from #tempWorkingCalendarView where RowId = @WCCycleRowId + 1
						
						if @WCDateFrom > @WCDateTo
						begin  --�������ں���һ���Ŀ�ʼ����֮������Ϣʱ��
							update #tempCPTime set CPTime = DateAdd(SECOND, DateDiff(SECOND, @WCDateTo, @WCDateFrom), CPTime) where CPTime > @WCDateTo
						end
					end
					else
					begin  --���һ����������
						if @WCDateTo < @MaxCPTime
						begin  --���������Ƿ��@MaxCPTime֮������Ϣʱ��
							update #tempCPTime set CPTime = DateAdd(SECOND, DateDiff(SECOND, @WCDateTo, @MaxCPTime), CPTime) where CPTime > @WCDateTo
						end
						
						--����ȡ@MaxCPTime������ѭ��
						set @MinCPTime = @MaxCPTime
						select @MaxCPTime = MAX(CPTime) from #tempCPTime
					end
					
					set @WCCycleRowId = @WCCycleRowId + 1		
				end
			end
			else
			begin  --û���ҵ�����ʱ��
				--��¼��ʼ��������С���������
				set @CPTimeLength = DATEDIFF(SECOND, @MinCPTime, @MaxCPTime)
				declare @DatePlus1 datetime = @MaxCPTime
				
				if @CPTimeLength < 1000 * 60 * 60 * 24
				begin
					while 1 = 1
					begin  --Ϊ�˱���@CPTimeLength̫С��ѭ��999�ζ�û���ҵ�����ʱ��
						--ͨ��@MaxCPTime + 1������֮��Ĺ�������ʱ��
						set @DatePlus1 = DATEADD(DAY, 1, @DatePlus1)
						
						truncate table #tempWorkingCalendarView
						insert into #tempWorkingCalendarView(WorkingDate, DateFrom, DateTo) exec USP_Busi_GetWorkingCalendarView @ProdLine, @ProdLineRegion, @MaxCPTime, @DatePlus1
						
						if exists(select top 1 1 from #tempWorkingCalendarView)
						begin
							select top 1 @MaxCPTime = DateFrom from #tempWorkingCalendarView order by DateFrom asc
							break
						end
						
						set @WCDeepCount = @WCDeepCount + 1
						if @WCDeepCount > 999
						begin
							set @ErrorMsg = N'�������ʱ�䳬�����ѭ����������������' + @ProdLine + '�Ĺ�������û��ά��������'
							RAISERROR(@ErrorMsg, 16, 1)
							return
						end
					end
				end
				
				set @WCDeepCount = @WCDeepCount + 1
				if @WCDeepCount > 999
				begin
					set @ErrorMsg = N'�������ʱ�䳬�����ѭ����������������' + @ProdLine + '�Ĺ�������û��ά��������'
					RAISERROR(@ErrorMsg, 16, 1)
					return
				end
				
				--Ҫ�Ȱ����й���ʱ��С����Сʱ��ļ�¼������Сʱ������ʱ���ʱ����������Сʱ������ʱ��ķ�Χ
				update #tempCPTime set CPTime = DATEADD(SECOND, DATEDIFF(SECOND, @MinCPTime, @MaxCPTime), CPTime) where CPTime >= @MinCPTime
				set @MinCPTime = @MaxCPTime
				set @MaxCPTime = DATEADD(SECOND, @CPTimeLength, @MaxCPTime)
			end
		end
		--print N'����ѭ�������Ϣʱ�䣨���������ڵ���0������ʱ' + Convert(varchar(50), DateDiff(MS, @PTick, GetDate()))

		set @PTick = GetDate()
		--print N'��ʼ����ƫ�������������������Ĺ���ʱ�䣨������С��0������ʼʱ��' + convert(varchar(20), @PTick)
		--����ƫ�������������������Ĺ���ʱ�䣨û�а�����ʱ�䣩
		truncate table #tempCPTime2
		insert into #tempCPTime2(OrderNo, AssProdLine, Seq, SubSeq, VanOp, AssOp, Op, OpTaktTime, CPTime) 
		select toot.OrderNo, toot.AssProdLine, toot.Seq, toot.SubSeq, toot.VanOp, toot.AssOp, toot.Op, toot.OpTaktTime, DATEADD(SECOND, rd.LeadTime, DATEADD(SECOND, toot.OpTaktTime, @LastOnlineVanStartTime))
		from #tempOrderOpTakt as toot
		inner join #tempRoutingDet as rd on toot.AssProdLine = rd.AssProdLine and toot.AssOp = rd.AssOp
		where toot.OpTaktTime < 0
		--print N'��������ƫ�������������������Ĺ���ʱ�䣨������С��0������ʱ' + Convert(varchar(50), DateDiff(MS, @PTick, GetDate()))
	
		set @PTick = GetDate()
		--print N'��ʼѭ�������Ϣʱ�䣨������С��0������ʼʱ��' + convert(varchar(20), @PTick)
		if exists(select top 1 1 from #tempCPTime2)
		begin
			--ѭ�������Ϣʱ��
			select @MinCPTime = MIN(CPTime), @MaxCPTime = MAX(CPTime) from #tempCPTime2
			set @WCDeepCount = 0
			while 1=1
			begin
				if @MinCPTime = @MAXCPTime
				begin  --����ѭ��
					break
				end
				
				truncate table #tempWorkingCalendarView
				insert into #tempWorkingCalendarView(WorkingDate, DateFrom, DateTo) exec USP_Busi_GetWorkingCalendarView @ProdLine, @ProdLineRegion, @MinCPTime, @MaxCPTime
				
				set @WCDateFrom = null
				set @WCDateTo = null
				if exists(select top 1 1 from #tempWorkingCalendarView)
				begin  --�ҵ�����ʱ��
					select @WCCycleRowId = MIN(RowId), @WCMaxRowId = MAX(RowId) from #tempWorkingCalendarView
					
					while @WCCycleRowId <= @WCMaxRowId
					begin
						if @WCDateTo is null
						begin --���һ����¼����������¼�������������Ƿ��@MAXCPTime֮������Ϣʱ��
							select @WCDateTo = DateTo from #tempWorkingCalendarView where RowId = @WCMaxRowId
							
							if @WCDateTo < @MAXCPTime
							begin  --���м�¼��ȥ�������ں�@MAXCPTime֮�����Ϣʱ��
								update #tempCPTime2 set CPTime = DateAdd(SECOND, DateDiff(SECOND, @MAXCPTime, @WCDateTo), CPTime) where CPTime <= @MAXCPTime
							end
						end
						
						select @WCDateFrom = DateFrom from #tempWorkingCalendarView where RowId = @WCMaxRowId
						
						if @WCCycleRowId <= @WCMaxRowId - 1
						begin  --����ǰ��Ĺ�������
							select @WCDateTo = DateTo from #tempWorkingCalendarView where RowId = @WCMaxRowId - 1
							
							if @WCDateFrom > @WCDateTo
							begin  --�������ں���һ���Ŀ�ʼ����֮������Ϣʱ��
								update #tempCPTime2 set CPTime = DateAdd(SECOND, DateDiff(SECOND, @WCDateFrom, @WCDateTo), CPTime) where CPTime < @WCDateFrom
							end
						end
						else
						begin  --��һ����������
							if @WCDateFrom > @MinCPTime
							begin  --��ʼ�����Ƿ��@MinCPTime֮������Ϣʱ��
								update #tempCPTime2 set CPTime = DateAdd(SECOND, DateDiff(SECOND, @WCDateFrom, @MinCPTime), CPTime) where CPTime < @WCDateFrom
							end
							
							--����ȡ@MaxCPTime������ѭ��
							set @MaxCPTime = @MinCPTime
							select @MinCPTime = MIN(CPTime) from #tempCPTime2
						end
						
						set @WCMaxRowId = @WCMaxRowId - 1
					end
				end
				else
				begin  --û���ҵ�����ʱ��
					--��¼��ʼ��������С���������
					set @CPTimeLength = DATEDIFF(SECOND, @MaxCPTime, @MinCPTime)
					declare @DateMinus1 datetime = @MinCPTime
				
					if @CPTimeLength > -1000 * 60 * 60 * 24
					begin
						while 1 = 1
						begin  --Ϊ�˱���@CPTimeLength̫С��ѭ��999�ζ�û���ҵ�����ʱ��
							--ͨ��@MinCPTime - 1������֮ǰ�Ĺ�������ʱ��
							set @DateMinus1 = DATEADD(DAY, -1, @DateMinus1)
							
							truncate table #tempWorkingCalendarView
							insert into #tempWorkingCalendarView(WorkingDate, DateFrom, DateTo) exec USP_Busi_GetWorkingCalendarView @ProdLine, @ProdLineRegion, @DateMinus1, @MinCPTime
							
							if exists(select top 1 1 from #tempWorkingCalendarView)
							begin
								select top 1 @MinCPTime = DateTo from #tempWorkingCalendarView order by DateTo desc
								break
							end
							
							set @WCDeepCount = @WCDeepCount + 1
							if @WCDeepCount > 999
							begin
								set @ErrorMsg = N'�������ʱ�䳬�����ѭ����������������' + @ProdLine + '�Ĺ�������û��ά��������'
								RAISERROR(@ErrorMsg, 16, 1)
								return
							end
						end
					end
					
					set @WCDeepCount = @WCDeepCount + 1
					if @WCDeepCount > 999
					begin
						set @ErrorMsg = N'�������ʱ�䳬�����ѭ����������������' + @ProdLine + '�Ĺ�������û��ά��������'
						RAISERROR(@ErrorMsg, 16, 1)
						return
					end
					
					--Ҫ�Ȱ����й���ʱ��С�����ʱ��ļ�¼��ȥ����Сʱ������ʱ���ʱ����������Сʱ������ʱ��ķ�Χ
					update #tempCPTime2 set CPTime = DATEADD(SECOND, DATEDIFF(SECOND, @MaxCPTime, @MinCPTime), CPTime) where CPTime <= @MaxCPTime
					set @MaxCPTime = @MinCPTime
					set @MinCPTime = DATEADD(SECOND, @CPTimeLength, @MinCPTime)
				end
			end
		end
		--print N'����ѭ�������Ϣʱ�䣨������С��0������ʱ' + Convert(varchar(50), DateDiff(MS, @PTick, GetDate()))

		set @PTick = GetDate()
		--print N'��ʼ�����������ʱ�䣬��ʼʱ��' + convert(varchar(20), @PTick)
		set @trancount = @@trancount
		begin try
			if @trancount = 0
			begin
				begin tran
			end
			
			delete from ORD_OrderOpCPTime where VanProdLine = @ProdLine
			--delete from ORD_OrderBomCPTime where VanProdLine = @ProdLine
			
			insert into ORD_OrderOpCPTime(OrderNo, VanProdLine, AssProdLine, Seq, SubSeq, VanOp, AssOp, Op, OpTaktTime, CPTime) 
			select OrderNo, @ProdLine, AssProdLine, Seq, SubSeq, VanOp, AssOp, Op, OpTaktTime, CPTime from #tempCPTime
			
			insert into ORD_OrderOpCPTime(OrderNo, VanProdLine, AssProdLine, Seq, SubSeq, VanOp, AssOp, Op, OpTaktTime, CPTime) 
			select OrderNo, @ProdLine, AssProdLine, Seq, SubSeq, VanOp, AssOp, Op, OpTaktTime, CPTime from #tempCPTime2
			
			--insert into ORD_OrderBomCPTime(OrderNo, VanProdLine, AssProdLine, Seq, SubSeq, VanOp, AssOp, Op, OpTaktTime, CPTime,
			--Item, Uom, OpRef, OrderQty, Location, IsCreateOrder, BomId, DISPO, ManufactureParty, WorkCenter)
			--select tcpt.OrderNo, @ProdLine, tcpt.AssProdLine, tcpt.Seq, tcpt.SubSeq, tcpt.VanOp, tcpt.AssOp, tcpt.Op, tcpt.OpTaktTime, tcpt.CPTime,
			--bom.Item, bom.Uom, bom.OpRef, bom.OrderQty, bom.Location, bom.IsCreateOrder, bom.Id, bom.DISPO, bom.ManufactureParty, bom.WorkCenter
			--from ORD_OrderOpCPTime as tcpt
			--inner join ORD_OrderBomDet as bom on tcpt.OrderNo = bom.OrderNo and tcpt.AssProdLine = bom.AssProdLine and tcpt.AssOp = bom.Op
			--where tcpt.VanProdLine = @ProdLine
			
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
		--print N'���������������ʱ�䣬��ʱ' + Convert(varchar(50), DateDiff(MS, @PTick, GetDate()))	
	end
	else
	begin
		delete from ORD_OrderOpCPTime where VanProdLine = @ProdLine
	end
END