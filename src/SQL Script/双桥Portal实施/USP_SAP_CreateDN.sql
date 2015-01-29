SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS(SELECT * FROM sys.objects WHERE type='P' AND name='USP_SAP_CreateDN') 
     DROP PROCEDURE USP_SAP_CreateDN
GO

CREATE PROCEDURE [dbo].[USP_SAP_CreateDN]
(
	@CreateUser varchar(50)
)
AS
BEGIN
	set nocount on
	declare @DateTimeNow datetime = GetDate()
	declare @DateNow datetime = CONVERT(varchar(10), @DateTimeNow, 120)
	declare @ErrorMsg nvarchar(MAX)
	declare @Trancount int
	declare @IpDetConfirmStartId int
	declare @IpDetConfirmEndId int
	declare @IpDetConfirmSVersion int
	declare @CancelIpDetConfirmStartId int
	declare @CancelIpDetConfirmEndId int
	declare @CancelIpDetConfirmVersion int

	create table #tempCreateDN
	(
		IpDetConfirmId int Primary Key,
		OrderNo varchar(50),
		IpNo varchar(50),
		IpDetSeq int,
		Item varchar(50),
		ItemDesc varchar(100),
		Uom varchar(5),
		Qty decimal(18, 8),
		ShipPlant varchar(50),
		ShipLocation varchar(50),
		EBELN varchar(50),
		EBELP varchar(50),
		EffDate datetime,
	)

	create table #tempCancelCreateDN
	(
		CancelIpDetConfirmId int Primary Key,
		IpDetConfirmId int,
		OrderNo varchar(50),
		IpNo varchar(50),
		IpDetSeq int,
		Item varchar(50),
		ItemDesc varchar(100),
		Uom varchar(5),
		Qty decimal(18, 8),
		ShipPlant varchar(50),
		ShipLocation varchar(50),
		EBELN varchar(50),
		EBELP varchar(50),
		DNNo varchar(50),
		EffDate datetime,
	)

	begin try
		begin try
			if not exists(select top 1 1 from SAP_TableIndex where TableName = 'IpDetConfirm4Trans4DN')
			begin
				insert into SAP_TableIndex(TableName, Id, LastModifyDate, [Version]) values('IpDetConfirm4Trans4DN', 0, @DateTimeNow, 1)
			end

			if not exists(select top 1 1 from SAP_TableIndex where TableName = 'CancelIpDetConfirm4Trans4DN')
			begin
				insert into SAP_TableIndex(TableName, Id, LastModifyDate, [Version]) values('CancelIpDetConfirm4Trans4DN', 0, @DateTimeNow, 1)
			end

			select @IpDetConfirmStartId = Id, @IpDetConfirmSVersion = [Version] from SAP_TableIndex where TableName = 'IpDetConfirm4Trans4DN'
			select @CancelIpDetConfirmStartId = Id, @CancelIpDetConfirmVersion = [Version] from SAP_TableIndex where TableName = 'CancelIpDetConfirm4Trans4DN'

			insert into #tempCreateDN(IpDetConfirmId, OrderNo, IpNo, IpDetSeq, Item, ItemDesc, Uom, Qty, ShipPlant, ShipLocation, EBELN, EBELP, EffDate)
			select Id, OrderNo, IpNo, IpDetSeq, Item, ItemDesc, Uom, Qty, ShipPlant, ShipLocation, EBELN, EBELP, EffDate 
			from ORD_IpDetConfirm WITH(NOLOCK) where Id > @IpDetConfirmStartId and IsCreateDN = 1 order by Id

			insert into #tempCancelCreateDN(CancelIpDetConfirmId, IpDetConfirmId, OrderNo, IpNo, IpDetSeq, Item, ItemDesc, Uom, Qty, ShipPlant, ShipLocation, EBELN, EBELP, DNNo, EffDate)
			select l.Id, l.IpDetConfirmId, l.OrderNo, l.IpNo, l.IpDetSeq, l.Item, l.ItemDesc, l.Uom, l.Qty, l.ShipPlant, l.ShipLocation, l.EBELN, l.EBELP, s.VBELN_VL, l.EffDate 
			from ORD_CancelIpDetConfirm as l WITH(NOLOCK) left join SAP_CreateDN as s WITH(NOLOCK) on l.IpDetConfirmId = s.IpDetConfirmId
			where l.Id > @CancelIpDetConfirmStartId and l.IsCreateDN = 1 order by l.Id

			select @IpDetConfirmEndId = MAX(IpDetConfirmId) from #tempCreateDN
			select @CancelIpDetConfirmEndId = MAX(CancelIpDetConfirmId) from #tempCancelCreateDN
		end try
		begin catch
			set @ErrorMsg = N'数据准备出现异常：' +  Error_Message() 
			RAISERROR(@ErrorMsg, 16, 1)
		end catch

		begin try
			if @Trancount = 0
			begin
				begin tran
			end

			if exists(select top 1 1 from #tempCreateDN)
			begin
				insert into SAP_CreateDN(IpDetConfirmId, OrderNo, IpNo, IpDetSeq, MATNR, ItemDesc, Uom, G_LFIMG, WERKS, LGORT, EBELN, EBELP, EffDate, CreateUser, CreateDate, LastModifyUser, LastModifyDate, DNSTR, GISTR, VBELN_VL, ErrorCount, [Message], [Version])
				select t.IpDetConfirmId, t.OrderNo, t.IpNo, t.IpDetSeq, t.Item, t.ItemDesc, t.Uom, t.Qty, t.ShipPlant, t.ShipLocation, t.EBELN, t.EBELP, t.EffDate, @CreateUser, @DateTimeNow, @CreateUser, @DateTimeNow, 'P', 'P', null, 0, null, 1
				from #tempCreateDN as t left join SAP_CreateDN as s on t.IpDetConfirmId = s.IpDetConfirmId
				where s.IpDetConfirmId is null

				update SAP_TableIndex set Id = @IpDetConfirmEndId, LastModifyDate = @DateTimeNow, [Version] = [Version] + 1
				where TableName = 'IpDetConfirm4Trans4DN' and [Version] = @IpDetConfirmSVersion

				if (@@ROWCOUNT <> 1)
				begin
					RAISERROR(N'数据已经被更新，请重试。', 16, 1)
				end
			end

			if exists(select top 1 1 from #tempCancelCreateDN)
			begin
				insert into SAP_CancelCreateDN(CancelIpDetConfirmId, IpDetConfirmId, OrderNo, IpNo, IpDetSeq, MATNR, ItemDesc, Uom, G_LFIMG, WERKS, LGORT, EBELN, EBELP, EffDate, CreateUser, CreateDate, LastModifyUser, LastModifyDate, DNSTR, GISTR, VBELN_VL, ErrorCount, [Message], [Version])
				select t.CancelIpDetConfirmId, t.IpDetConfirmId, t.OrderNo, t.IpNo, t.IpDetSeq, t.Item, t.ItemDesc, t.Uom, t.Qty, t.ShipPlant, t.ShipLocation, t.EBELN, t.EBELP, t.EffDate, @CreateUser, @DateTimeNow, @CreateUser, @DateTimeNow, 'P', 'P', t.DNNo, 0, null, 1
				from #tempCancelCreateDN as t left join SAP_CancelCreateDN as s on t.CancelIpDetConfirmId = s.CancelIpDetConfirmId
				where s.CancelIpDetConfirmId is null

				update SAP_TableIndex set Id = @CancelIpDetConfirmEndId, LastModifyDate = @DateTimeNow, [Version] = [Version] + 1
				where TableName = 'CancelIpDetConfirm4Trans4DN' and [Version] = @CancelIpDetConfirmVersion

				if (@@ROWCOUNT <> 1)
				begin
					RAISERROR(N'数据已经被更新，请重试。', 16, 1)
				end
			end

			if @Trancount = 0 
			begin  
				commit
			end
		end try
		begin catch
			if @Trancount = 0
			begin
				rollback
			end 
		
			set @ErrorMsg = N'数据更新出现异常：' +  Error_Message() 
			RAISERROR(@ErrorMsg, 16, 1) 
		end catch
	end try
	begin catch
			set @ErrorMsg = N'生成SAP创建DN中间表出现异常：' +  Error_Message() 
			RAISERROR(@ErrorMsg, 16, 1) 
	end catch	

	drop table #tempCancelCreateDN
	drop table #tempCreateDN
END