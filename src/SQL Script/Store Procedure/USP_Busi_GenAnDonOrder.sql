SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF EXISTS(SELECT * FROM sys.objects WHERE type='P' AND name='USP_Busi_GenAnDonOrder') 
     DROP PROCEDURE USP_Busi_GenAnDonOrder 
GO
CREATE PROCEDURE USP_Busi_GenAnDonOrder
(
	@CreateUserId int,
	@CreateUserNm varchar(100)
)
AS
BEGIN
	DECLARE @DateTimeNow datetime
	DECLARE @trancount int
	
	SET @DateTimeNow=GETDATE()
	SELECT ks.* INTO #TempNeedOrderScan FROM KB_KanbanScan ks INNER JOIN SCM_FlowStrategy fs ON ks.Flow=fs.Flow
	WHERE ks.ScanTime<@DateTimeNow AND ks.IsOrdered=0 AND fs.IsOrderNow=0
	
	CREATE TABLE #TempFlow(
		[Id] [int] IDENTITY(1,1) NOT NULL,
		[Flow] [varchar](50) NOT NULL,
		[Type] [tinyint] NULL,
		[Strategy] [tinyint] NULL,
		[PartyFrom] [varchar](50) NULL,
		[PartyTo] [varchar](50) NULL,
		[LocFrom] [varchar](50) NULL,
		[LocTo] [varchar](50) NULL,
		[Dock] [varchar](50) NULL,
		[ExtraDmdSource] [varchar](255) NULL,
		[OrderTime] [datetime] NULL,
		[ReqTimeFrom] [datetime] NULL,
		[ReqTimeTo] [datetime] NULL,
		[WindowTime] [datetime] NULL,
		[EMWindowTime] [datetime] NULL
	) 
	
	CREATE TABLE #TempOrderNos
	(
		OrderNo varchar(50)
	)
	
	
	INSERT INTO #TempFlow(Flow, [Type], Strategy, PartyFrom, PartyTo, LocFrom, LocTo, Dock, ExtraDmdSource)
	SELECT DISTINCT fm.Code AS Flow, fm.[Type], fs.Strategy, fm.PartyFrom, fm.PartyTo, fm.LocFrom, fm.LocTo, fm.Dock, fm.ExtraDmdSource
	FROM SCM_FlowMstr AS fm 
	INNER JOIN KB_KanbanScan ks ON fm.Code=ks.Flow
	INNER JOIN SCM_FlowStrategy fs ON fm.Code = fs.Flow
	WHERE ks.ScanTime<@DateTimeNow AND ks.IsOrdered=0 AND fs.IsOrderNow=0
	
	DECLARE @FlowRowId int
	DECLARE @MaxFlowRowId int
	
	
	
	
	SELECT @FlowRowId = MIN(Id), @MaxFlowRowId = MAX(Id) from #TempFlow
	WHILE (@FlowRowId <= @MaxFlowRowId)
	BEGIN
		DECLARE @Flow varchar(50) = null
		DECLARE @FlowType tinyint = null
		DECLARE @FlowStrategy tinyint = null
		DECLARE @PartyFrom varchar(50) = null
		DECLARE @PartyTo varchar(50) = null
		DECLARE @LocFrom varchar(50) = null
		DECLARE @LocTo varchar(50) = null
		DECLARE @ExtraDmdSource varchar(50) = null
		DECLARE @WinTimeType tinyint = null
		DECLARE @WinTimeDiff decimal(18, 8) = null  --�룬������ǰ��
		DECLARE @SafeTime decimal(18, 8) = null  --�룬��ȫ�ڣ����󸲸���ǰ�ڣ�@ReqTimeTo���������Ӱ�ȫ�ڵ�ʱ��
		DECLARE @LeadTime decimal(18, 8) = null  --�룬��ǰ�ڣ�������ǰ��
		DECLARE @EMLeadTime decimal(18, 8) = null  --�룬������ǰ��
		DECLARE @PrevWinTime datetime = null
		DECLARE @WindowTime datetime = null
		DECLARE @WindowTime2 datetime = null
		
		DECLARE @OrderNo varchar(50) = null
		DECLARE @Dock varchar(50) = null
		DECLARE @EMWindowTime datetime = null
		DECLARE @ReqTimeFrom datetime = null
		DECLARE @ReqTimeTo datetime = null
		DECLARE @OrderTime datetime = null
		DECLARE @OrderDetCount int
		DECLARE @EndOrderDetId int
		DECLARE @BeginOrderDetId int
		
		SELECT @Flow = Flow, @FlowType = [Type], @Dock=Dock,
		@PartyFrom = PartyFrom, @PartyTo = PartyTo,
		@LocFrom = LocFrom, @LocTo = LocTo, @ExtraDmdSource = ExtraDmdSource
		FROM #TempFlow WHERE Id = @FlowRowId
		
		SET @trancount = @@TRANCOUNT
		BEGIN TRY
			IF @trancount = 0
			BEGIN
				BEGIN TRAN
			END		
		
			SELECT @FlowStrategy = Strategy, @WinTimeType = WinTimeType, 
			@WinTimeDiff = WinTimeDiff * 60 * 60, --СʱתΪ��
			@SafeTime = ISNULL(SafeTime, 0) * 60 * 60, --СʱתΪ��
			@LeadTime = LeadTime * 60 * 60, --СʱתΪ��
			@EMLeadTime = EMLeadTime * 60 * 60,	   --СʱתΪ��
			@PrevWinTime = PreWinTime,       --�ϴδ���ʱ��
			@WindowTime = NextWinTime
			FROM SCM_FlowStrategy WHERE Flow = @Flow
			
			--���崰��ʱ��ֻ��Ҫ��ǰʱ�������ǰ�ڼ���
			EXEC USP_Busi_AddWorkingDate @DateTimeNow, @LeadTime, null, @PartyTo, @EMWindowTime output
		
			exec USP_GetDocNo_ORD @Flow, 7, @FlowType, 0, 0, 1, @PartyFrom, @PartyTo, @LocTo, @LocFrom, @Dock, 0, @OrderNo output

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
				7,					  --����
				@FlowType,			  --����
				0,					  --�����ͣ�0����
				0,					  --����״̬��0��Ʒ
				@DateTimeNow,         --��ʼʱ��
				@EMWindowTime,        --����ʱ��
				0,					  --��ͣ����0
				0,					  --�Ƿ���٣�0
				0,					  --���ȼ���1
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
				7,					  --����
				@FlowType,			  --����
				0,					  --�����ͣ�0����
				0,					  --����״̬��0��Ʒ
				@DateTimeNow,         --��ʼʱ��
				@EMWindowTime,        --����ʱ��
				0,					  --��ͣ����0
				0,					  --�Ƿ���٣�0
				0,					  --���ȼ���1
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
			
			SELECT @OrderDetCount = COUNT(*) FROM #TempNeedOrderScan WHERE Flow=@Flow
			
			EXEC USP_SYS_BatchGetNextId 'ORD_OrderDet', @OrderDetCount, @EndOrderDetId output
			--���ҿ�ʼ��ʶ
			SET @BeginOrderDetId = @EndOrderDetId - @OrderDetCount


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
				BillAddr,					--��Ʊ��ַ
				ContainerDesc,				--��¼FlowDetId�������0����ϵͳ�Զ�������·����ϸ
				BillTerm,					--���㷽ʽ
				BinTo						--Ŀ�Ĺ�λ
				)
				select 
				@BeginOrderDetId+ROW_NUMBER()OVER(ORDER BY tos.Id),				--��������ϸ��ʶ
				@OrderNo,				--��������
				@FlowType,					--���ͣ�1�ɹ�
				0,							--�����ͣ�0����
				ROW_NUMBER()OVER(ORDER BY tos.Id),			--�кţ�
				0,							--�ƻ�Э�����ͣ�0
				tos.Item,					--���Ϻ�
				i.RefCode,					--�ο����Ϻ�
				i.Desc1,					--��������
				i.Uom,					--��λ
				i.Uom,					--������λ
				i.UC,						--��װ��1
				1,							--��С��װ��1
				0,							--����״̬��0
				fd.ManufactureParty,		--������
				tos.ScanQty,					--����������1
				tos.ScanQty,				--����������1
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
				fm.LocFrom,					--�����λ
				lf.Name,					--�����λ����
				fm.LocTo,					--����λ
				lt.Name,					--����λ
				fm.BillAddr,				--��Ʊ��ַ
				CONVERT(varchar, fd.Id),--��¼FlowDetId�������0����ϵͳ�Զ�������·����ϸ
				fm.BillTerm,				--���㷽ʽ
				fd.BinTo						--Ŀ�Ĺ�λ
				from #TempNeedOrderScan tos
				INNER JOIN SCM_FlowMstr fm ON tos.Flow=fm.Code
				INNER JOIN SCM_FlowDet fd ON fd.Id=tos.FlowDetId
				INNER JOIN MD_Item as i on tos.Item = i.Code
				LEFT JOIN MD_Location as lf on fm.LocFrom = lf.Code
				LEFT JOIN MD_Location as lt on fm.LocTo = lt.Code
				WHERE tos.Flow=@Flow
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
				BillAddr,					--��Ʊ��ַ
				ContainerDesc,				--��¼FlowDetId�������0����ϵͳ�Զ�������·����ϸ
				BillTerm,					--���㷽ʽ
				BinTo						--Ŀ�Ĺ�λ
				)
				select 
				@BeginOrderDetId+ROW_NUMBER()OVER(ORDER BY tos.Id),				--��������ϸ��ʶ
				@OrderNo,				--��������
				@FlowType,					--���ͣ�1�ɹ�
				0,							--�����ͣ�0����
				ROW_NUMBER()OVER(ORDER BY tos.Id),			--�кţ�
				0,							--�ƻ�Э�����ͣ�0
				tos.Item,					--���Ϻ�
				i.RefCode,					--�ο����Ϻ�
				i.Desc1,					--��������
				i.Uom,					--��λ
				i.Uom,					--������λ
				i.UC,						--��װ��1
				1,							--��С��װ��1
				0,							--����״̬��0
				fd.ManufactureParty,		--������
				tos.ScanQty,					--����������1
				tos.ScanQty,				--����������1
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
				fm.LocFrom,					--�����λ
				lf.Name,					--�����λ����
				fm.LocTo,					--����λ
				lt.Name,					--����λ
				fm.BillAddr,				--��Ʊ��ַ
				CONVERT(varchar, fd.Id),--��¼FlowDetId�������0����ϵͳ�Զ�������·����ϸ
				fm.BillTerm,				--���㷽ʽ
				fd.BinTo					--Ŀ�Ĺ�λ
				from #TempNeedOrderScan tos
				INNER JOIN SCM_FlowMstr fm ON tos.Flow=fm.Code
				INNER JOIN SCM_FlowDet fd ON fd.Id=tos.FlowDetId
				INNER JOIN MD_Item as i on tos.Item = i.Code
				LEFT JOIN MD_Location as lf on fm.LocFrom = lf.Code
				LEFT JOIN MD_Location as lt on fm.LocTo = lt.Code
				WHERE tos.Flow=@Flow
			END
			
			--�����м����ݱ�
			IF @PartyFrom IN('SQC')
			BEGIN
				--˫�ż�����ʹ�þ�WMSϵͳ
				INSERT INTO FIS_CreateOrderDAT(
					OrderNo,
					MATNR,
					LIFNR,
					ENMNG,
					CHARG,
					COLOR,
					TIME_STAMP,
					CY_SEQNR,
					TIME_STAMP1,
					AUFNR,
					LGORT,
					UMLGO,
					LGPBE,
					REQ_TIME_STAMP,
					FLG_SORT,
					PLNBEZ,
					KTEXT,
					ZPLISTNO,
					ErrorCount,
					IsCreateDat,
					CreateUserNm)
				SELECT @OrderNo,
					tos.Item,
					tos.Supplier,
					CAST(tos.ScanQty AS decimal(18,3)),
					'',
					'',
					REPLACE(REPLACE(REPLACE(CONVERT(varchar(50),@DateTimeNow,120),':',''),'-',''),' ',''),
					'',
					null,
					'',
					fm.LocFrom,
					fm.LocTo,
					fd.BinTo,
					REPLACE(REPLACE(REPLACE(CONVERT(varchar(50),@EMWindowTime,120),':',''),'-',''),' ',''),
					'N',
					'',
					'',
					@BeginOrderDetId+ROW_NUMBER()OVER(ORDER BY tos.Id),
					0,
					0,
					@CreateUserNm
				FROM #TempNeedOrderScan tos
				INNER JOIN SCM_FlowMstr fm ON tos.Flow=fm.Code
				INNER JOIN SCM_FlowDet fd ON fd.Id=tos.FlowDetId
				INNER JOIN MD_Item as i on tos.Item = i.Code
				WHERE tos.Flow=@Flow
			END IF @PartyFrom IN('LOC')
			BEGIN
				--LOCʹ����WMSϵͳ
				INSERT INTO FIS_CreateProcurementOrderDAT(
					OrderNo, 
					Van, 
					OrderStrategy, 
					StartTime, 
					WindowTime, 
					Priority, 
					Sequence, 
					PartyFrom, 
					PartyTo, 
					Dock, 
					CreateDate, 
					Flow, 
					LineSeq, 
					Item, 
					ManufactureParty, 
					LocationTo, 
					Bin, 
					OrderedQty, 
					IsShipExceed, 
					FileName, 
					IsCreateDat)
				SELECT
					@OrderNo,
					'',
					7,
					@DateTimeNow,
					@EMWindowTime,
					0,
					'',
					fm.LocFrom,
					fm.LocTo,
					fm.Dock,
					@DateTimeNow,
					fm.Code,	
					@BeginOrderDetId+ROW_NUMBER()OVER(ORDER BY tos.Id),	
					tos.Item,
					fd.ManufactureParty,
					fd.LocTo,
					fd.BinTo,
					tos.ScanQty,
					fm.IsShipExceed,
					'',
					0
				FROM #TempNeedOrderScan tos
				INNER JOIN SCM_FlowMstr fm ON tos.Flow=fm.Code
				INNER JOIN SCM_FlowDet fd ON fd.Id=tos.FlowDetId
				INNER JOIN MD_Item as i on tos.Item = i.Code
				LEFT JOIN MD_Location as lf on fm.LocFrom = lf.Code
				LEFT JOIN MD_Location as lt on fm.LocTo = lt.Code
				WHERE tos.Flow=@Flow
			END	
								

			INSERT INTO #TempOrderNos(OrderNo)
			SELECT @OrderNo
			
			--IF @OrderTime <= @DateTimeNow
			--BEGIN
			--	--����·���ϴδ���ʱ��
			--	UPDATE SCM_FlowStrategy SET PreWinTime = @WindowTime, NextWinTime = @WindowTime2 WHERE Flow = @Flow
			--END
			
			--����ˢ����¼
			UPDATE ks SET ks.IsOrdered=1,ks.OrderNo=@OrderNo,ks.OrderQty=ks.ScanQty,ks.OrderTime=@DateTimeNow,
				ks.OrderUser=@CreateUserId,ks.OrderUserNm=@CreateUserNm
			FROM KB_KanbanScan ks INNER JOIN #TempNeedOrderScan tos ON ks.Id=tos.Id
			WHERE ks.Flow=@Flow
			
			UPDATE kb SET kb.Status=2 FROM KB_KanbanCard kb INNER JOIN #TempNeedOrderScan tos ON kb.CardNo=tos.CardNo
			WHERE kb.Flow=@Flow
			  
			SET @FlowRowId=@FlowRowId+1
			IF @trancount = 0 
			BEGIN  
				COMMIT
			END
		END TRY
		BEGIN CATCH
			IF @trancount = 0
			BEGIN
				ROLLBACK
			END 
			SET @FlowRowId=@FlowRowId+1
			DECLARE @errorMsg varchar(max)
			SET @errorMsg=ERROR_MESSAGE()
			RAISERROR(@errorMsg,16,1)
		END CATCH	
		SELECT * FROM #TempOrderNos		
	END	
END
