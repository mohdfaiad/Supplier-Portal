SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF EXISTS(SELECT * FROM SYS.OBJECTS WHERE TYPE='P' AND name='USP_LE_GenOrder')
	DROP PROCEDURE USP_LE_GenOrder	
GO

CREATE PROCEDURE [dbo].[USP_LE_GenOrder]
(
	@BatchNo int,
	@LERunTime datetime,
	@CreateUserId int,
	@CreateUserNm varchar(100)
) --WITH ENCRYPTION
AS
BEGIN 
	set nocount on
	declare @Msg nvarchar(Max)
	
	--��¼��־
	set @Msg = N'����·����������Ҫ������ʼ'
	insert into LOG_RunLeanEngine(Lvl, Msg, BatchNo) values(0, @Msg, @BatchNo)

	declare @FlowId int 
	declare @MaxFlowId int
	select @FlowId = MIN(Id), @MaxFlowId = MAX(Id) from LE_FlowMstrSnapShot
	
	while (@FlowId <= @MaxFlowId)
	begin
		declare @Flow varchar(50) = null
	
		select @Flow = Flow from LE_FlowMstrSnapShot where Id = @FlowId
		
		if exists(select top 1 1 from LE_FlowDetSnapShot where Flow = @Flow and Strategy = 3)
		begin
			declare @LocTo varchar(50) = null
			select @LocTo = LocTo from LE_FlowDetSnapShot where Flow = @Flow
			
			if not exists(select top 1 1 from LE_OrderBomCPTimeSnapshot where Location = @LocTo)
			begin
				-------------------��JIT����-----------------------
				set @Msg = N'����JIT·��' + @Flow + N'Ҫ������ʼ'
				insert into LOG_RunLeanEngine(Flow, Lvl, Msg, BatchNo) values(@Flow, 0, @Msg, @BatchNo)
			
				exec USP_LE_GenJITOrder @Flow, @BatchNo, @LERunTime, @CreateUserId, @CreateUserNm
				
				set @Msg = N'����JIT·��' + @Flow + N'Ҫ��������'
				insert into LOG_RunLeanEngine(Flow, Lvl, Msg, BatchNo) values(@Flow, 0, @Msg, @BatchNo)
				-------------------��JIT����-----------------------
			end
		end
		else if exists(select top 1 1 from LE_FlowDetSnapShot where Flow = @Flow and Strategy = 2)
		begin
			-------------------��KB����-----------------------
			set @Msg = N'����KB·��' + @Flow + N'Ҫ������ʼ'
			insert into LOG_RunLeanEngine(Flow, Lvl, Msg, BatchNo) values(@Flow, 0, @Msg, @BatchNo)
			
			exec USP_LE_GenKBOrder @Flow, @BatchNo, @LERunTime, @CreateUserId, @CreateUserNm
			
			set @Msg = N'����KB·��' + @Flow + N'Ҫ��������'
			insert into LOG_RunLeanEngine(Flow, Lvl, Msg, BatchNo) values(@Flow, 0, @Msg, @BatchNo)
			-------------------��KB����-----------------------
		end
		else if not exists(select top 1 * from LE_FlowDetSnapShot)
		begin
			set @Msg = N'·��' + @Flow + N'û���Զ�������·����ϸ'
			insert into LOG_RunLeanEngine(Flow, Lvl, Msg, BatchNo) values(@Flow, 0, @Msg, @BatchNo)
		end
	
		set @FlowId = @FlowId + 1
	end
	
	--��¼��־
	set @Msg = N'����·����������Ҫ��������'
	insert into LOG_RunLeanEngine(Lvl, Msg, BatchNo) values(0, @Msg, @BatchNo)
END 