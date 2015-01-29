
/****** Object:  StoredProcedure [dbo].[USP_Busi_PauseProductLine]    Script Date: 07/05/2012 14:55:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS(SELECT * FROM SYS.objects WHERE type='P' AND name='USP_Busi_PauseProductLine')
	DROP PROCEDURE USP_Busi_PauseProductLine
Create PROCEDURE [dbo].[USP_Busi_PauseProductLine]
(
	@ProductLineCode varchar(50),
	@UserId int,
	@UserNm varchar(100)
)
AS
BEGIN
	declare @DateTimeNow as datetime;
	set @DateTimeNow = GETDATE();
	
	--��ѯ��������������δ�ر���������Van��
	select TraceCode into #temp1 from ORD_OrderMstr_4 where Flow = @ProductLineCode and Status in (0, 1, 2);
	
	begin tran	
		--��������ͣ
		update SCM_FlowMstr set IsPause = 1, PauseTime = @DateTimeNow, LastModifyDate = @DateTimeNow, LastModifyUser = @UserId, LastModifyUserNm = @UserNm where Code = @ProductLineCode;
		
		--����Van����ͣ�ɹ�����Kit��/���򵥣�
		update ORD_OrderMstr_1 set IsPLPause = 1, PauseTime = @DateTimeNow, Version = Version + 1, LastModifyDate = GETDATE(), LastModifyUser = @UserId, LastModifyUserNm = @UserNm
		from ORD_OrderMstr_1 as m1 inner join #temp1 as t on m1.TraceCode = t.TraceCode
		
		--����Van����ͣ�ƿⵥ��Kit��/���򵥣�
		update ORD_OrderMstr_2 set IsPLPause = 1, PauseTime = @DateTimeNow, Version = Version + 1, LastModifyDate = GETDATE(), LastModifyUser = @UserId, LastModifyUserNm = @UserNm
		from ORD_OrderMstr_2 as m1 inner join #temp1 as t on m1.TraceCode = t.TraceCode
		
		--����Van����ͣ����������ʻ��/���̣�
		update ORD_OrderMstr_4 set IsPLPause = 1, PauseTime = @DateTimeNow, Version = Version + 1, LastModifyDate = GETDATE(), LastModifyUser = @UserId, LastModifyUserNm = @UserNm
		from ORD_OrderMstr_4 as m1 inner join #temp1 as t on m1.TraceCode = t.TraceCode
		
		--����Van����ͣ�ƻ�Э�鵥��Kit��/���򵥣�
		update ORD_OrderMstr_8 set IsPLPause = 1, PauseTime = @DateTimeNow, Version = Version + 1, LastModifyDate = GETDATE(), LastModifyUser = @UserId, LastModifyUserNm = @UserNm
		from ORD_OrderMstr_8 as m1 inner join #temp1 as t on m1.TraceCode = t.TraceCode
	commit

END
GO