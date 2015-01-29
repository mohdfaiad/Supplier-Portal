IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_BAK_VanOrderBom]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[USP_BAK_VanOrderBom]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[USP_BAK_VanOrderBom] 
AS 
BEGIN
	BEGIN TRY
		DECLARE @BakDate datetime
		SET @BakDate=DATEADD(DAY,-3,GETDATE())

		--�鵵Bom
		DECLARE @COUNT INT = 1
		WHILE @COUNT < 1000 AND EXISTS(SELECT top 1 1 FROM ORD_OrderBomDet obd
		INNER JOIN ORD_OrderMstr_4 om on om.OrderNo=obd.OrderNo 
		WHERE om.ProdLineType in (1,2,3,4,9) AND om.CloseDate < @BakDate
		AND NOT EXISTS(SELECT * FROM ORD_OrderMstr_4 b WHERE om.TraceCode=b.TraceCode AND b.Status<>4))
		BEGIN
			DELETE TOP(10000) obd OUTPUT deleted.* 
			INTO Sconit5_Arch.dbo.ORD_OrderBomDet FROM ORD_OrderBomDet obd 
			INNER JOIN ORD_OrderMstr_4 om on om.OrderNo=obd.OrderNo 
			WHERE om.ProdLineType in (1,2,3,4,9) AND om.CloseDate < @BakDate
			AND NOT EXISTS(SELECT * FROM ORD_OrderMstr_4 b WHERE om.TraceCode=b.TraceCode AND b.Status<>4)
			
			SET @COUNT = @COUNT + 1
		END
		
		
		--�鵵�����¼
		--WHILE EXISTS(SELECT 1 FROM ORD_OrderBackflushDet WHERE OrderNo IS NULL AND CreateDate < @BakDate)
		--BEGIN
		--	DELETE TOP(100000) FROM ORD_OrderBackflushDet  OUTPUT deleted.* INTO [Sconit5_Arch].[DBO].ORD_OrderBackflushDet 
		--	WHERE OrderNo IS NULL AND CreateDate<@BakDate
		--END
		
		--WHILE EXISTS(SELECT 1 FROM ORD_OrderBomDet obd
		--INNER JOIN ORD_OrderMstr_4 om on om.OrderNo=obd.OrderNo 
		--WHERE om.ProdLineType not in (1,2,3,4,9) AND om.CreateDate<DATEADD(DAY,-7,@CurrentDate)
		--AND om.Status=4)
		--BEGIN
		--	DELETE TOP(20000) obd OUTPUT deleted.* 
		--	INTO Sconit5_Arch.dbo.ORD_OrderBomDet FROM ORD_OrderBomDet obd
		--	INNER JOIN ORD_OrderMstr_4 om on om.OrderNo=obd.OrderNo 
		--	WHERE om.ProdLineType not in (1,2,3,4,9) AND om.CreateDate<DATEADD(DAY,-7,@CurrentDate)
		--	AND om.Status=4
		--END	
		
		--ÿ��ĩ��һ�������ؽ�
		IF DATEPART(WEEKDAY,GETDATE())=1
		BEGIN
			DBCC DBREINDEX('ORD_OrderBomDet')
		END
	END TRY
	BEGIN CATCH
		Declare @ErrorMsg varchar(max) = Error_Message() 
		RAISERROR(@ErrorMsg , 16, 1) 
	END CATCH
END 
GO


