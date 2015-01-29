SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF EXISTS(SELECT * FROM sys.objects WHERE type='P' AND name='USP_Busi_UpdateVanProdOrderBomDet') 
     DROP PROCEDURE USP_Busi_UpdateVanProdOrderBomDet
GO

CREATE PROCEDURE [dbo].[USP_Busi_UpdateVanProdOrderBomDet] 
(
	@BatchNo int,
	@CreateUserId int,
	@CreateUserNm varchar(50)
) --WITH ENCRYPTION
AS 
BEGIN 
	set nocount on
	
	if exists(select top 1 1 from SAP_ProdBomDetUpdate where BatchNo = @BatchNo and Status = 1)
	begin
		return
	end
	
	declare @DateTimeNow datetime = GetDate()
	declare @ErrorMsg nvarchar(MAX)
	declare @trancount int = @@trancount
	
	begin try
		if @trancount = 0
		begin
            begin tran
        end
        
        declare @AUFNR varchar(50)
		select top 1  @AUFNR = AUFNR from SAP_ProdBomDetUpdate where BatchNo = @BatchNo
		
		
		-----------------------------↓新增驾驶室生产单Bom-----------------------------
		declare @CabOrderNo varchar(50)
		declare @CabProdLine varchar(50)
		declare @CabOrderDetId int
		
		select @CabOrderNo = mstr.OrderNo, @CabOrderDetId = det.Id, @CabProdLine = mstr.Flow
		from ORD_OrderMstr_4 as mstr
		inner join ORD_OrderDet_4 as det on mstr.OrderNo = det.OrderNo
		inner join CUST_ProductLineMap as cab on mstr.Flow = cab.CabProdLine
		where mstr.ExtOrderNo = @AUFNR and mstr.Status <> 4 and mstr.Status <> 5
		
		if @CabOrderNo is not null
		begin
			exec USP_Busi_UpdateSingleVanProdOrderBomDet @BatchNo, @CabProdLine, @CabOrderNo, @CabOrderDetId, @CreateUserId, @CreateUserNm
		end
		-----------------------------↑新增驾驶室生产单Bom-----------------------------
		
		
		
		
		-----------------------------↓新增底盘生产单Bom-----------------------------	
		declare @ChassisOrderNo varchar(50)
		declare @ChassisProdLine varchar(50)
		declare @ChassisOrderDetId int
		
		select @ChassisOrderNo = mstr.OrderNo, @ChassisOrderDetId = det.Id, @ChassisProdLine = mstr.Flow
		from ORD_OrderMstr_4 as mstr
		inner join ORD_OrderDet_4 as det on mstr.OrderNo = det.OrderNo
		inner join CUST_ProductLineMap as chassis on mstr.Flow = chassis.ChassisProdLine
		where mstr.ExtOrderNo = @AUFNR and mstr.Status <> 4 and mstr.Status <> 5
		
		if @ChassisOrderNo is not null
		begin
			exec USP_Busi_UpdateSingleVanProdOrderBomDet @BatchNo, @ChassisProdLine, @ChassisOrderNo, @ChassisOrderDetId, @CreateUserId, @CreateUserNm
		end
		-----------------------------↑新增底盘生产单Bom-----------------------------
		
		
		
		
		-----------------------------↓新增总装生产单Bom-----------------------------
		declare @AssemblyOrderNo varchar(50)
		declare @AssemblyProdLine varchar(50)
		declare @AssemblyOrderDetId int
		
		select @AssemblyOrderNo = mstr.OrderNo, @AssemblyOrderDetId = det.Id, @AssemblyProdLine = mstr.Flow
		from ORD_OrderMstr_4 as mstr
		inner join ORD_OrderDet_4 as det on mstr.OrderNo = det.OrderNo
		inner join CUST_ProductLineMap as a on mstr.Flow = a.AssemblyProdLine
		where mstr.ExtOrderNo = @AUFNR and mstr.Status <> 4 and mstr.Status <> 5
		
		if @AssemblyOrderNo is not null
		begin
			exec USP_Busi_UpdateSingleVanProdOrderBomDet @BatchNo, @AssemblyProdLine, @AssemblyOrderNo, @AssemblyOrderDetId, @CreateUserId, @CreateUserNm
		end
		-----------------------------↑新增总装生产单Bom-----------------------------
		
		
		
		
		-----------------------------↓新增特装生产单Bom-----------------------------
		declare @SpecialOrderNo varchar(50)
		declare @SpecialProdLine varchar(50)
		declare @SpecialOrderDetId int
		
		select @SpecialOrderNo = mstr.OrderNo, @SpecialOrderDetId = det.Id, @SpecialProdLine = mstr.Flow
		from ORD_OrderMstr_4 as mstr
		inner join ORD_OrderDet_4 as det on mstr.OrderNo = det.OrderNo
		inner join CUST_ProductLineMap as special on mstr.Flow = special.specialProdLine
		where mstr.ExtOrderNo = @AUFNR and mstr.Status <> 4 and mstr.Status <> 5
		
		if @SpecialOrderNo is not null
		begin
			exec USP_Busi_UpdateSingleVanProdOrderBomDet @BatchNo, @SpecialProdLine, @SpecialOrderNo, @SpecialOrderDetId, @CreateUserId, @CreateUserNm
		end
		-----------------------------↑新增特装生产单Bom-----------------------------
		
		
		
		
		-----------------------------↓新增检测生产单Bom-----------------------------
		declare @CheckOrderNo varchar(50)
		declare @CheckProdLine varchar(50)
		declare @CheckOrderDetId int
		
		select @CheckOrderNo = mstr.OrderNo, @CheckOrderDetId = det.Id, @CheckProdLine = mstr.Flow
		from ORD_OrderMstr_4 as mstr
		inner join ORD_OrderDet_4 as det on mstr.OrderNo = det.OrderNo
		inner join CUST_ProductLineMap as c on mstr.Flow = c.CheckProdLine
		where mstr.ExtOrderNo = @AUFNR and mstr.Status <> 4 and mstr.Status <> 5
		
		if @CheckOrderNo is not null
		begin
			exec USP_Busi_UpdateSingleVanProdOrderBomDet @BatchNo, @CheckProdLine, @CheckOrderNo, @CheckOrderDetId, @CreateUserId, @CreateUserNm
		end
		-----------------------------↑新增检测生产单Bom-----------------------------
		
		
		
		
		-----------------------------↓删除生产单Bom-----------------------------
		CREATE TABLE #tempBomId
		(
			BomId bigint,
			IsCreateOrder bit,
			GW varchar(50)
		)

		--查找并缓存需要删除的生产单Bom
		insert into #tempBomId(BomId, IsCreateOrder, GW)
		select b.Id, b.IsCreateOrder, CASE WHEN u.GW = 'Delete' THEN NULL ELSE 1 END
		from ORD_OrderBomDet as b
		inner join SAP_ProdBomDetUpdate as u on u.RSNUM = b.ReserveNo and u.RSPOS = b.ReserveLine
		inner join ORD_OrderMstr_4 as m on b.OrderNo = m.OrderNo
		where u.BatchNo = @BatchNo and u.GW in ('Delete', 'DeleteOn') --and m.Status <> 4 and m.Status <> 5
		and u.MDMNG > 0
		
		--策略是JIT的退回工位余量
		update ob set ob.Qty = ob.Qty + c.OrderQty
		from LE_OrderBomCPTimeSnapshot as c
		inner join #tempBomId as t on c.BomId = t.BomId
		inner join LE_FlowDetSnapShot as fd on c.Item = fd.Item and c.Location = fd.LocTo
		inner join LE_FlowMstrSnapShot as fm on fd.Flow = fm.Flow
		inner join SCM_OpRefBalance as ob on c.Item = ob.Item and c.OpRef = ob.OpRef
		where fm.Strategy = 3 and t.IsCreateOrder = 1
		
		--删除Bom过点时间表
		delete c from LE_OrderBomCPTimeSnapshot as c
		inner join #tempBomId as t on c.BomId = t.BomId		
		
		--更新Bom表，把原Bom数记录到BFQty字段中
		update b set BFQty = OrderQty
		from ORD_OrderBomDet as b
		inner join #tempBomId as t on b.Id = t.BomId 
		
		--更新Bom表，把原Bom数更新为0
		update b set OrderQty = 0, Bom = GW
		from ORD_OrderBomDet as b
		inner join #tempBomId as t on b.Id = t.BomId			
		
		--删除临时表
		drop table #tempBomId
		-----------------------------↑删除生产单Bom-----------------------------
		
		
		update SAP_ProdBomDetUpdate set Status = 1 where BatchNo = @BatchNo
		
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
        
		update SAP_ProdBomDetUpdate set Status = 2 where BatchNo = @BatchNo
		
		set @ErrorMsg = Error_Message() 
		RAISERROR(@ErrorMsg, 16, 1) 
	end catch 
END 
