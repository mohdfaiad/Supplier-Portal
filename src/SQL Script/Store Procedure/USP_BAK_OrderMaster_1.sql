IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_BAK_OrderMaster_1]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[USP_BAK_OrderMaster_1]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USP_BAK_OrderMaster_1] 
AS 
BEGIN
	BEGIN TRY
		DECLARE @BakDate datetime
		DECLARE @COUNT INT
		SET @BakDate=DATEADD(DAY,-90,GETDATE())
		Create table #Temp_OrderNo
		(
			OrderNo varchar(50) Primary Key
		)	
		CREATE INDEX IX_Temp_OrderNo ON #Temp_OrderNo(OrderNo)
		
		update ORD_OrderMstr_1 set CloseDate = GETDATE() where Status = 4 and CloseDate is null
		update ORD_OrderMstr_1 set CancelDate = GETDATE() where Status = 5 and CancelDate is null
		
		insert into #Temp_OrderNo(OrderNo) SELECT OrderNo FROM ORD_OrderMstr_1 WHERE Status = 4 AND CloseDate<@BakDate
		insert into #Temp_OrderNo(OrderNo) SELECT OrderNo FROM ORD_OrderMstr_1 WHERE Status = 5 AND CancelDate<@BakDate
		
		--PRINT 'BEGIN BACKUP ORD_OrderBackflushDet'
		--WHILE EXISTS(SELECT top 1 1 FROM ORD_OrderBackflushDet obd INNER JOIN #Temp_OrderNo ord ON obd.OrderNo=ord.OrderNo)
		--BEGIN
		--	DELETE TOP(10000) obd OUTPUT deleted.* INTO [Sconit5_Arch].[DBO].ORD_OrderBackflushDet
		--	FROM ORD_OrderBackflushDet obd
		--	INNER JOIN #Temp_OrderNo ord 
		--		ON obd.OrderNo=ord.OrderNo
		--END
		
		--PRINT 'BEGIN BACKUP ORD_OrderBomDet'
		--WHILE EXISTS(SELECT top 1 1 FROM ORD_OrderBomDet obd INNER JOIN #Temp_OrderNo ord ON obd.OrderNo=ord.OrderNo)
		--BEGIN
		--	DELETE TOP(10000) obd  OUTPUT deleted.* INTO [Sconit5_Arch].[DBO].ORD_OrderBomDet
		--	FROM ORD_OrderBomDet obd
		--	INNER JOIN #Temp_OrderNo ord 
		--		ON obd.OrderNo=ord.OrderNo
		--END				
		
		Create table #Temp_RecNo
		(
			RecNo varchar(50) Primary Key
		)
		CREATE INDEX IX_Temp_RecNo ON #Temp_RecNo(RecNo)
		
		INSERT INTO #Temp_RecNo(RecNo) SELECT DISTINCT RecNo  FROM ORD_RecDet_1 rd 
		INNER JOIN #Temp_OrderNo ord ON rd.OrderNo=ord.OrderNo
		
		PRINT 'BEGIN BACKUP ORD_RecLocationDet_1'
		SET @COUNT = 1
		WHILE @COUNT < 1000 AND EXISTS(SELECT * FROM ORD_RecLocationDet_1 rld INNER JOIN #Temp_RecNo rn ON rld.RecNo=rn.RecNo)
		BEGIN
			DELETE TOP(10000) rld  OUTPUT deleted.* INTO [Sconit5_Arch].[DBO].ORD_RecLocationDet_1 
			FROM ORD_RecLocationDet_1 rld 
			INNER JOIN #Temp_RecNo rn 
				ON rld.RecNo=rn.RecNo	
			SET @COUNT = @COUNT + 1
		END
		
		PRINT 'BEGIN BACKUP ORD_RecDet_1'
		SET @COUNT = 1
		WHILE @COUNT < 1000 AND EXISTS(SELECT * FROM ORD_RecDet_1 rd INNER JOIN #Temp_RecNo rn ON rd.RecNo=rn.RecNo)
		BEGIN
			DELETE TOP(10000) rd  OUTPUT deleted.* INTO [Sconit5_Arch].[DBO].ORD_RecDet_1 
			FROM ORD_RecDet_1 rd
			INNER JOIN #Temp_RecNo rn 
				ON rd.RecNo=rn.RecNo	
		END	
		
		PRINT 'BEGIN BACKUP ORD_RecMstr_1'
		SET @COUNT = 1
		WHILE @COUNT < 1000 AND EXISTS(SELECT * FROM ORD_RecMstr_1 rm INNER JOIN #Temp_RecNo rn ON rm.RecNo=rn.RecNo)
		BEGIN
			DELETE TOP(10000) rm  OUTPUT deleted.* INTO [Sconit5_Arch].[DBO].ORD_RecMstr_1 
			FROM ORD_RecMstr_1 rm
			INNER JOIN #Temp_RecNo rn 
				ON rm.RecNo=rn.RecNo	
			SET @COUNT = @COUNT + 1
		END	
		
		Create table #Temp_IpNo
		(
			IpNo varchar(50) Primary Key
		)
		CREATE INDEX IX_Temp_IpNo ON #Temp_IpNo(IpNo)
		
		INSERT INTO #Temp_IpNo(IpNo) SELECT DISTINCT IpNo  FROM ORD_IpDet_1 id 
		INNER JOIN #Temp_OrderNo ord ON id.OrderNo=ord.OrderNo
		
		PRINT 'BEGIN BACKUP ORD_IpLocationDet_1'
		SET @COUNT = 1
		WHILE @COUNT < 1000 AND EXISTS(SELECT * FROM ORD_IpLocationDet_1 rld INNER JOIN #Temp_IpNo rn ON rld.IpNo=rn.IpNo)
		BEGIN
			DELETE TOP(10000) rld  OUTPUT deleted.* INTO [Sconit5_Arch].[DBO].ORD_IpLocationDet_1 
			FROM ORD_IpLocationDet_1 rld 
			INNER JOIN #Temp_IpNo rn 
				ON rld.IpNo=rn.IpNo	
			SET @COUNT = @COUNT + 1
		END
		
		PRINT 'BEGIN BACKUP ORD_IpDet_1'
		SET @COUNT = 1
		WHILE @COUNT < 1000 AND EXISTS(SELECT * FROM ORD_IpDet_1 rd INNER JOIN #Temp_IpNo rn ON rd.IpNo=rn.IpNo)
		BEGIN
			DELETE TOP(10000) rd  OUTPUT
			deleted.[Id]
           ,deleted.[Type]
           ,deleted.[IpNo]
           ,deleted.[Seq]
           ,deleted.[OrderNo]
           ,deleted.[OrderType]
           ,deleted.[OrderSubType]
           ,deleted.[OrderDetId]
           ,deleted.[OrderDetSeq]
           ,deleted.[ExtNo]
           ,deleted.[ExtSeq]
           ,deleted.[Item]
           ,deleted.[ItemDesc]
           ,deleted.[RefItemCode]
           ,deleted.[Uom]
           ,deleted.[BaseUom]
           ,deleted.[UC]
           ,deleted.[UCDesc]
           ,deleted.[Container]
           ,deleted.[ContainerDesc]
           ,deleted.[QualityType]
           ,deleted.[ManufactureParty]
           ,deleted.[Qty]
           ,deleted.[RecQty]
           ,deleted.[UnitQty]
           ,deleted.[LocFrom]
           ,deleted.[LocFromNm]
           ,deleted.[LocTo]
           ,deleted.[LocToNm]
           ,deleted.[IsInspect]
           ,deleted.[BillAddr]
           ,deleted.[PriceList]
           ,deleted.[UnitPrice]
           ,deleted.[Currency]
           ,deleted.[IsProvEst]
           ,deleted.[Tax]
           ,deleted.[IsIncludeTax]
           ,deleted.[BillTerm]
           ,deleted.[IsClose]
           ,deleted.[GapRecNo]
           ,deleted.[GapIpDetId]
           ,deleted.[CreateUser]
           ,deleted.[CreateUserNm]
           ,deleted.[CreateDate]
           ,deleted.[LastModifyUser]
           ,deleted.[LastModifyUserNm]
           ,deleted.[LastModifyDate]
           ,deleted.[Version]
           ,deleted.[StartTime]
           ,deleted.[Windowtime]
           ,deleted.[BinTo]
           ,deleted.[IsScanHu]
           ,deleted.[IsChangeUC]
           ,deleted.[Flow]
           ,deleted.[BWART]
           ,deleted.[PSTYP]
            INTO [Sconit5_Arch].[DBO].ORD_IpDet_1 
			FROM ORD_IpDet_1 rd
			INNER JOIN #Temp_IpNo rn 
			ON rd.IpNo=rn.IpNo	
			SET @COUNT = @COUNT + 1
		END	
		
		PRINT 'BEGIN BACKUP ORD_IpMstr_1'
		SET @COUNT = 1
		WHILE @COUNT < 1000 AND EXISTS(SELECT * FROM ORD_IpMstr_1 rm INNER JOIN #Temp_IpNo rn ON rm.IpNo=rn.IpNo)
		BEGIN
			DELETE TOP(10000) rm  OUTPUT deleted.* INTO [Sconit5_Arch].[DBO].ORD_IpMstr_1 
			FROM ORD_IpMstr_1 rm
			INNER JOIN #Temp_IpNo rn 
				ON rm.IpNo=rn.IpNo	
			SET @COUNT = @COUNT + 1
		END
		
		--PRINT 'BEGIN BACKUP BIL_ActBill'
		--WHILE EXISTS(SELECT ab.* FROM BIL_ActBill ab INNER JOIN #Temp_OrderNo ord ON ab.OrderNo=ord.OrderNo)
		--BEGIN
		--	DELETE TOP(10000) ab  OUTPUT deleted.* INTO [Sconit5_Arch].[DBO].BIL_ActBill 
		--	FROM BIL_ActBill ab
		--	INNER JOIN #Temp_OrderNo ord 
		--		ON ab.OrderNo=ord.OrderNo
		--END		
		
		--PRINT 'BEGIN BACKUP PlanBill'
		--WHILE EXISTS(SELECT pb.* FROM BIL_PlanBill pb INNER JOIN #Temp_OrderNo ord ON pb.OrderNo=ord.OrderNo)
		--BEGIN
		--	DELETE TOP(10000) pb  OUTPUT deleted.* INTO [Sconit5_Arch].[DBO].BIL_PlanBill 
		--	FROM BIL_PlanBill pb
		--	INNER JOIN #Temp_OrderNo ord 
		--		ON pb.OrderNo=ord.OrderNo
		--END	
		
		PRINT 'BEGIN BACKUP ORD_OrderDet_1'
		SET @COUNT = 1
		WHILE @COUNT < 1000 AND EXISTS(SELECT od.* FROM ORD_OrderDet_1 od INNER JOIN #Temp_OrderNo ord ON od.OrderNo=ord.OrderNo)
		BEGIN
			DELETE TOP(10000) od  OUTPUT
			deleted.Id
		  ,deleted.OrderNo
		  ,deleted.OrderType
		  ,deleted.OrderSubType
		  ,deleted.Seq
		  ,deleted.ExtNo
		  ,deleted.ExtSeq
		  ,deleted.StartDate
		  ,deleted.EndDate
		  ,deleted.ScheduleType
		  ,deleted.Item
		  ,deleted.ItemDesc
		  ,deleted.RefItemCode
		  ,deleted.Uom
		  ,deleted.BaseUom
		  ,deleted.UC
		  ,deleted.UCDesc
		  ,deleted.MinUC
		  ,deleted.Container
		  ,deleted.ContainerDesc
		  ,deleted.QualityType
		  ,deleted.ManufactureParty
		  ,deleted.ReqQty
		  ,deleted.OrderQty
		  ,deleted.ShipQty
		  ,deleted.RecQty
		  ,deleted.RejQty
		  ,deleted.ScrapQty
		  ,deleted.PickQty
		  ,deleted.UnitQty
		  ,deleted.RecLotSize
		  ,deleted.LocFrom
		  ,deleted.LocFromNm
		  ,deleted.LocTo
		  ,deleted.LocToNm
		  ,deleted.IsInspect
		  ,deleted.BillAddr
		  ,deleted.BillAddrDesc
		  ,deleted.PriceList
		  ,deleted.UnitPrice
		  ,deleted.IsProvEst
		  ,deleted.Tax
		  ,deleted.IsIncludeTax
		  ,deleted.Currency
		  ,deleted.Bom
		  ,deleted.Routing
		  ,deleted.BillTerm
		  ,deleted.PickStrategy
		  ,deleted.ExtraDmdSource
		  ,deleted.IsScanHu
		  ,deleted.ReserveNo
		  ,deleted.ReserveLine
		  ,deleted.ZOPWZ
		  ,deleted.ZOPID
		  ,deleted.ZOPDS
		  ,deleted.CreateUser
		  ,deleted.CreateUserNm
		  ,deleted.CreateDate
		  ,deleted.LastModifyUser
		  ,deleted.LastModifyUserNm
		  ,deleted.LastModifyDate
		  ,deleted.Version
		  ,deleted.BinTo
		  ,deleted.WMSSeq
		  ,deleted.IsChangeUC
		  ,deleted.AUFNR
		  ,deleted.ICHARG
		  ,deleted.BWART
		  ,deleted.IsCreatePickList 
		  INTO [Sconit5_Arch].[DBO].ORD_OrderDet_1 
			FROM ORD_OrderDet_1 od
			INNER JOIN #Temp_OrderNo ord 
				ON od.OrderNo=ord.OrderNo
			SET @COUNT = @COUNT + 1
		END
		
		PRINT 'BEGIN BACKUP ORD_OrderMstr_1'
		SET @COUNT = 1
		WHILE @COUNT < 1000 AND EXISTS(SELECT om.* FROM ORD_OrderMstr_1 om INNER JOIN #Temp_OrderNo ord ON om.OrderNo=ord.OrderNo)
		BEGIN
			DELETE TOP(10000) om  OUTPUT deleted.* INTO [Sconit5_Arch].[DBO].ORD_OrderMstr_1 
			FROM ORD_OrderMstr_1 om
			INNER JOIN #Temp_OrderNo ord 
				ON om.OrderNo=ord.OrderNo
			SET @COUNT = @COUNT + 1
		END
		
		DROP TABLE #Temp_OrderNo
		DROP TABLE #Temp_RecNo
		DROP TABLE #Temp_IpNo
	END TRY
	BEGIN CATCH
		Declare @ErrorMsg varchar(max) = Error_Message() 
		RAISERROR(@ErrorMsg , 16, 1) 
	END CATCH
END 

GO
