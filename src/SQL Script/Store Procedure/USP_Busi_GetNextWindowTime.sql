SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF EXISTS(SELECT * FROM SYS.objects WHERE type='P' AND name='USP_Busi_GetNextWindowTime')
	DROP PROCEDURE USP_Busi_GetNextWindowTime
GO

CREATE PROCEDURE [dbo].[USP_Busi_GetNextWindowTime]
(
	@Flow varchar(50),
	@WindowTime datetime,
	@NextWindowTime datetime output
) --WITH ENCRYPTION
AS
BEGIN
	set nocount on
	set @NextWindowTime = null
	
	declare @ErrorMsg nvarchar(Max)
	declare @DateTimeNow datetime = GETDATE()
	declare @FlowType tinyint
	declare @PartyFrom varchar(50)
	declare @PartyTo varchar(50)
	declare @WinTimeType tinyint
	declare @WeekInterval int
	declare @WinTimeInterval decimal(18, 8)
	declare @WeekDay int
	
	select @FlowType = mstr.[Type], @PartyFrom = mstr.PartyFrom, @PartyTo = mstr.PartyTo,
	@WinTimeType = stra.WinTimeType, @WinTimeInterval = stra.WinTimeInterval * 60 * 60,  --СʱתΪ��
	@WeekInterval = stra.WeekInterval
	from SCM_FlowStrategy as stra 
	inner join SCM_FlowMstr as mstr on stra.Flow = mstr.Code
	where stra.Flow = @Flow
	
	if (@WindowTime is null or @WindowTime <= @DateTimeNow)
	begin
		set @WindowTime = @DateTimeNow
		if (@WinTimeType = 1)
		begin  --�̶����ʱ�䣬ȡ����
			set @WindowTime = CONVERT(DATETIME, CONVERT(varchar(13), @WindowTime, 120) + ':00')
		end
	end
	
	if (@WinTimeType = 0)
	begin  --�̶�����ʱ��
		declare @WinTime varchar(256)
		declare @WinDate datetime = convert(datetime, convert(varchar(10), @WindowTime, 112), 120)
		--if @WeekInterval > 0
		--begin
		--	set @WinDate = DATEADD(WEEK, @WeekInterval, @WinDate)
		--end

		while 1 = 1
		begin
			set @WinTime = null
			if @FlowType <> 3
			begin  --�����ۿ�PartyTo�Ĺ�������
				select top 1 @WinTime = fsd.WinTime
				from PRD_WorkingCalendar as wc
				inner join SCM_FlowShiftDet as fsd on wc.Shift = fsd.Shift
				where wc.WorkingDate = @WinDate
				and wc.Region = @PartyTo
				and wc.[Type] = 0  --����
				and fsd.Flow = @Flow
			end
			else
			begin  --���ۿ�PartyFrom�Ĺ�������
				select top 1 @WinTime = fsd.WinTime
				from PRD_WorkingCalendar as wc
				inner join SCM_FlowShiftDet as fsd on wc.Shift = fsd.Shift
				where wc.WorkingDate = @WinDate
				and wc.Region = @PartyFrom
				and wc.[Type] = 0  --����
				and fsd.Flow = @Flow
			end
			
			if ISNULL(@WinTime, '') <> ''
			begin
				exec USP_Busi_MatchNextWindowTime @WindowTime, @WinDate, @WinTime, @NextWindowTime output
				
				if @NextWindowTime is not null
				begin
					return
				end
			end
			
			set @WinDate = DATEADD(DAY, 1, @WinDate)
			
			if DateDiff(DAY, @WindowTime, @WinDate) > 99
			begin
				set @ErrorMsg = N'·��' + @Flow + N'�Ĵ���ʱ��û��ά��������'
				RAISERROR(@ErrorMsg, 16, 1) 
				return
			end
		end
	end
	else
	begin  --�̶����ʱ��
		if @WinTimeInterval > 0
		begin
			if @FlowType <> 3
			begin  --�����ۿ�PartyTo�Ĺ�������
				exec USP_Busi_AddWorkingDate @WindowTime, @WinTimeInterval, null, @PartyTo, @NextWindowTime output
			end
			else
			begin  --���ۿ�PartyFrom�Ĺ�������
				exec USP_Busi_AddWorkingDate @WindowTime, @WinTimeInterval, null, @PartyFrom, @NextWindowTime output
			end
		end
		else
		begin
			set @ErrorMsg = N'·��' + @Flow + N'û�����ü��ʱ�䡣'
			RAISERROR(@ErrorMsg, 16, 1)
		end
	end
END
GO

