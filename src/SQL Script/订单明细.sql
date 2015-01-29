USE [sconit5_New]
GO

/****** Object:  StoredProcedure [dbo].[USP_Search_PrintOrderDet]    Script Date: 01/22/2013 17:19:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[USP_Search_PrintOrderDet]
( 
	@OrderNo varchar(50), 
	@Flow varchar(50), 
	@Types varchar(50), 
	@SubType tinyint, 
	@PartyFrom varchar(50), 
	@PartyTo varchar(50), 
	@Status tinyint, 
	@Priority tinyint, 
	@ExtOrderNo varchar(50), 
	@RefOrderNo varchar(50), 
	@TraceCode varchar(50), 
	@CreateUserNm varchar(100), 
	@DateFrom datetime, 
	@DateTo datetime, 
    @StartTime datetime, 
	@EndTime datetime,
	@WindowTimeFrom datetime, 
	@WindowTimeTo datetime,   
	@Sequence bigint, 
	@IsSupplier bit, 
	@IsReturn bit, 
	@Item varchar(50), 
	@ManufactureParty varchar(50), 
	@WMSSeq varchar(50), 
	@UserId int, 
	@WhereStatement varchar(8000), 
	@SortCloumn varchar(50)=null, 
	@SortRule varchar(50)=null, 
	@PageSize int, 
	@Page int 
) 
AS 
BEGIN 
	SET NOCOUNT ON 
	DECLARE @SpliceTables nvarchar(4000)  
	DECLARE @Count int 
	DECLARE @Type varchar(5) 
	DECLARE @Statement nvarchar(4000)  
	DECLARE @Parameter nvarchar(4000) 
	DECLARE @PagePara nvarchar(4000) 
	DECLARE @SortDesc nvarchar(100) 
	DECLARE @DetailWhere nvarchar(4000) 
	DECLARE @MasterWhere nvarchar(4000) 
	DECLARE @PermissionClause nvarchar(1000) 
	SET @DetailWhere='WHERE 1=1 ' 
	SET @MasterWhere='WHERE 1=1 ' 
	set @Count=1

	IF(ISNULL(@Types,'')='') 
	BEGIN 
		RAISERROR ('Please choose order types to search!' , 16, 1) WITH NOWAIT 
	END 

	IF(ISNULL(@OrderNo,'')<>'') 
	BEGIN 
		SET @OrderNo='%'+@OrderNo+'%' 
		SET @MasterWhere=@MasterWhere+' AND o.OrderNo LIKE @OrderNo_1' 
	END 
	IF(ISNULL(@Flow,'')<>'') 
	BEGIN 
		SET @MasterWhere=@MasterWhere+' AND o.Flow=@Flow_1' 
	END 
	IF(ISNULL(@SubType,'')<>'') 
	BEGIN 
		SET @MasterWhere=@MasterWhere+' AND o.SubType=@SubType_1' 
	END	 
	IF(ISNULL(@PartyFrom,'')<>'') 
	BEGIN 
		SET @MasterWhere=@MasterWhere+' AND o.PartyFrom=@PartyFrom_1' 
	END 
	IF(ISNULL(@PartyTo,'')<>'') 
	BEGIN 
		SET @MasterWhere=@MasterWhere+' AND o.PartyTo=@PartyTo_1 ' 
	END		 
	IF(ISNULL(@Status,'')<>'') 
	BEGIN 
		SET @MasterWhere=@MasterWhere+' AND o.Status=@Status_1 ' 
	END		 
	IF(ISNULL(@Priority,'')<>'') 
	BEGIN 
		SET @MasterWhere=@MasterWhere+' AND o.Priority=@Priority_1 ' 
	END	 
	IF(ISNULL(@ExtOrderNo,'')<>'') 
	BEGIN 
		SET @MasterWhere=@MasterWhere+' AND o.ExtOrderNo LIKE @ExtOrderNo_1 ' 
	END	 
	IF(ISNULL(@RefOrderNo,'')<>'') 
	BEGIN 
		SET @MasterWhere=@MasterWhere+' AND o.RefOrderNo LIKE @RefOrderNo_1 ' 
	END		 
	IF(ISNULL(@TraceCode,'')<>'') 
	BEGIN 
		SET @MasterWhere=@MasterWhere+' AND o.TraceCode LIKE @TraceCode_1 ' 
	END	 
	IF(ISNULL(@CreateUserNm,'')<>'') 
	BEGIN 
		SET @MasterWhere=@MasterWhere+' AND o.CreateUserNm=@CreateUserNm_1 ' 
	END	 
	
	--����ʱ��
    IF(ISDATE(@DateTo)=1)
	BEGIN
    set @DateTo=dateadd(day,1,@DateTo)
    END
	IF(ISDATE(@DateFrom)=1 AND ISDATE(@DateTo)=1) 
	BEGIN 
		SET @MasterWhere=@MasterWhere+' AND o.CreateDate BETWEEN @DateFrom_1 And @DateTo_1 ' 
	END	 
	ELSE IF(ISDATE(@DateFrom)=1 AND ISDATE(@DateTo)=0) 
	BEGIN 
		SET @MasterWhere=@MasterWhere+' AND o.CreateDate > @DateFrom_1' 
	END 
	ELSE IF(ISDATE(@DateFrom)=0 AND ISDATE(@DateTo)=1) 
	BEGIN 
		SET @MasterWhere=@MasterWhere+' AND o.CreateDate < @DateTo_1' 
	END	 
	--��ʼʱ��
	IF(ISDATE(@EndTime)=1)
	BEGIN
    set @EndTime=dateadd(day,1,@EndTime)
    END
	IF(ISDATE(@StartTime)=1 AND ISDATE(@EndTime)=1) 
	BEGIN 
		SET @MasterWhere=@MasterWhere+' AND o.StartTime BETWEEN @StartTime_1 And @EndTime_1 ' 
	END	 
	ELSE IF(ISDATE(@StartTime)=1 AND ISDATE(@EndTime)=0) 
	BEGIN 
		SET @MasterWhere=@MasterWhere+' AND o.StartTime > @StartTime_1' 
	END 
	ELSE IF(ISDATE(@StartTime)=0 AND ISDATE(@EndTime)=1) 
	BEGIN 
		SET @MasterWhere=@MasterWhere+' AND o.StartTime < @EndTime_1' 
	END	 
	
	--����ʱ��
	IF(ISDATE(@WindowTimeTo)=1)
	BEGIN
    set @WindowTimeTo=dateadd(day,1,@WindowTimeTo)
    END
	IF(ISDATE(@WindowTimeFrom)=1 AND ISDATE(@WindowTimeTo)=1) 
	BEGIN 
		SET @MasterWhere=@MasterWhere+' AND o.WindowTime BETWEEN @WindowTimeFrom_1 And @WindowTimeTo_1 ' 
	END	 
	ELSE IF(ISDATE(@WindowTimeFrom)=1 AND ISDATE(@WindowTimeTo)=0) 
	BEGIN 
		SET @MasterWhere=@MasterWhere+' AND o.WindowTime > @WindowTimeFrom_1' 
	END 
	ELSE IF(ISDATE(@WindowTimeFrom)=0 AND ISDATE(@WindowTimeTo)=1) 
	BEGIN 
		SET @MasterWhere=@MasterWhere+' AND o.WindowTime < @WindowTimeTo_1' 
	END	 

	IF(ISNULL(@Item,'')<>'') 
	BEGIN 
		SET @DetailWhere=@DetailWhere+' AND d.Item=@Item_1' 
	END 
	IF(ISNULL(@ManufactureParty,'')<>'') 
	BEGIN 
		SET @DetailWhere=@DetailWhere+' AND d.ManufactureParty=@ManufactureParty_1' 
	END 
	IF(ISNULL(@WMSSeq,'')<>'') 
	BEGIN 
		SET @DetailWhere=@DetailWhere+' AND d.WMSSeq=@WMSSeq_1' 
	END		 

	--IF(ISDATE(@DateFrom)=1 AND ISDATE(@DateTo)=1) 
	--BEGIN 
	--	SET @DetailWhere=@DetailWhere+' AND d.CreateDate BETWEEN @DateFrom_1 And @DateTo_1 ' 
	--END	 
	--ELSE IF(ISDATE(@DateFrom)=1 AND ISDATE(@DateTo)=0) 
	--BEGIN 
	--	SET @DetailWhere=@DetailWhere+' AND d.CreateDate > @DateFrom_1' 
	--END 
	--ELSE IF(ISDATE(@DateFrom)=0 AND ISDATE(@DateTo)=1) 
	--BEGIN 
	--	SET @DetailWhere=@DetailWhere+' AND d.CreateDate < @DateTo_1' 
	--END	 

	DECLARE @UserCode varchar(50) 
	SELECT @UserCode=Code FROM ACC_User WHERE Id=@UserId 
	IF(UPPER(@UserCode)<>'SU') 
	BEGIN 
		SELECT PermissionCode INTO #Temp FROM VIEW_UserPermission WHERE UserId=@UserId 
		IF(@IsSupplier=0 AND @IsReturn=0) 
		BEGIN 
			SET @MasterWhere=@MasterWhere+' AND o.PartyTo IN (SELECT PermissionCode FROM #Temp) ' 
		END 
		ELSE IF(@IsSupplier=0 AND @IsReturn=1) 
		BEGIN 
			SET @MasterWhere=@MasterWhere+' AND o.PartyFrom IN (SELECT PermissionCode FROM #Temp) ' 
		END 
		ELSE  
		BEGIN 
			SET @MasterWhere=@MasterWhere+' AND (o.PartyFrom IN (SELECT PermissionCode FROM #Temp) OR o.PartyTo IN (SELECT PermissionCode FROM #Temp))  ' 
		END				 
	END 

	IF ISNULL(@SortCloumn,'')='' 
	BEGIN 
		SET @SortDesc=' ORDER BY MastCreateDate DESC' 
	END 
	ELSE 
	BEGIN 
		IF(ISNULL(@SortRule,'')='') 
		BEGIN 
			SET @SortRule=' ACS' 
		END 
		IF(CHARINDEX('Reference',@SortCloumn)>0) 
		BEGIN 
			SET @SortCloumn=REPLACE(@SortCloumn,'Reference','Ref') 
		END 
		IF(CHARINDEX('Name',@SortCloumn)>0) 
		BEGIN 
			SET @SortCloumn=REPLACE(@SortCloumn,'Name','NM') 
		END 
		IF(CHARINDEX('UnitCount',@SortCloumn)>0) 
		BEGIN 
			SET @SortCloumn=REPLACE(@SortCloumn,'UnitCount','UC') 
		END 
		IF(CHARINDEX('Sequence',@SortCloumn)>0) 
		BEGIN 
			SET @SortCloumn=REPLACE(@SortCloumn,'Sequence','Seq') 
		END					 
		SET @SortDesc=' ORDER BY '+@SortCloumn+' '+@SortRule 
	END 

	IF @Page>0 
	BEGIN 
		SET @PagePara='WHERE RowId BETWEEN '+cast(@PageSize*(@Page-1) as varchar(50))+' AND '++cast(@PageSize*(@Page) as varchar(50)) 
	END 

	SET @MasterWhere=REPLACE(@WhereStatement,'Where',@MasterWhere+' AND')	 
	WHILE(LEN(@Types)>0) 
	BEGIN 
		IF(LEN(@Types)=1) 
		BEGIN 
			SET @Type=@Types 
		END 
		ELSE 
		BEGIN 
			SET @Type=SUBSTRING(@Types,1,CHARINDEX(',',@Types)-1) 
		END 
		--IF(CHARINDEX('OrderDetail',@WhereStatement)>0) 
		--BEGIN 
		--	SET @WhereStatement=REPLACE(@WhereStatement,'OrderDetail','ORD_OrderDet'+@Type) 
		--END
		IF(ISNULL(@SpliceTables,'')='') 
		BEGIN 
			--SET @MasterWhere=REPLACE(@MasterWhere,'OrderMaster','ORD_OrderMstr_'+@Type+' ') 
			--RefOrderNo,ExtOrderNo,PartyFrom,PartyTo,Flow,Type,Status,CreateDate,
			SET @SpliceTables='SELECT d.Id,d.OrderNo,d.ExtNo,d.ExtSeq,d.Item,d.RefItemCode,d.ItemDesc,d.Uom,d.UC,d.LocFrom,d.LocTo,d.OrderQty,d.ShipQty,d.RecQty,d.ManufactureParty,m.RefOrderNo as MastRefOrderNo,m.ExtOrderNo as MastExtOrderNo,m.PartyFrom as MastPartyFrom ,m.PartyTo as MastPartyTo,m.Flow as MastFlow,m.Type as MastType,m.Status as MastStatus,m.CreateDate as MastCreateDate,l.SAPLocation as SAPLocation FROM ORD_OrderDet_'+@Type+' AS d  left join  ORD_OrderMstr_'+@Type +' as m on d.OrderNo=m.OrderNo left join MD_Location as l on d.LocTo=l.Code '
 +@DetailWhere+' '+REPLACE(@MasterWhere,'OrderMaster','ORD_OrderMstr_'+@Type+' ') +''

		END 
		ELSE 
		BEGIN 

			--SET @SpliceTables=@SpliceTables+' UNION ALL SELECT * FROM ORD_OrderDet_'+@Type+' AS d  '+@DetailWhere+' '+REPLACE(@MasterWhere,'OrderMaster','ORD_OrderMstr_'+@Type+' ') 
	 SET @SpliceTables=@SpliceTables+'  UNION ALL SELECT d.Id,d.OrderNo,d.ExtNo,d.ExtSeq,d.Item,d.RefItemCode,d.ItemDesc,d.Uom,d.UC,d.LocFrom,d.LocTo,d.OrderQty,d.ShipQty,d.RecQty,d.ManufactureParty,m.RefOrderNo as MastRefOrderNo,m.ExtOrderNo as MastExtOrderNo,m.PartyFrom as MastPartyFrom ,m.PartyTo as MastPartyTo,m.Flow as MastFlow,m.Type as MastType,m.Status as MastStatus,m.CreateDate as MastCreateDate,l.SAPLocation as SAPLocation FROM ORD_OrderDet_'+@Type+' AS d left join  ORD_OrderMstr_'+@Type +' as m on d.OrderNo=m.OrderNo left join MD_Location as l on d.LocTo=l.Code '
+@DetailWhere+' '+REPLACE(@MasterWhere,'OrderMaster','ORD_OrderMstr_'+@Type+' ') +''
set @Count=@Count+1

		END 
		SET @Types=SUBSTRING(@Types,3,LEN(@Types)) 
	END	 
	SET @Statement=N'SELECT TOP('+CAST(@PageSize AS VARCHAR(10))+') * FROM (SELECT *,RowId=ROW_NUMBER()OVER('+@SortDesc+') FROM ('+@SpliceTables+') AS T1 ) AS T2 '+@PagePara 

	SET @Parameter=N'@OrderNo_1 varchar(50),@Flow_1 varchar(50),@PartyFrom_1 varchar(50),@PartyTo_1 varchar(50),@Status_1 tinyint,@Priority_1 tinyint,@ExtOrderNo_1 varchar(50),@RefOrderNo_1 varchar(50),@TraceCode_1 varchar(50),@CreateUserNm_1 varchar(100),@DateFrom_1 datetime,@DateTo_1 datetime,
	@StartTime_1 datetime,@EndTime_1 datetime,@WindowTimeFrom_1 datetime,@WindowTimeTo_1 datetime,@SubType_1 tinyint,@Sequence_1 bigint,@Item_1 varchar(50),@ManufactureParty_1 varchar(50),@WMSSeq_1 varchar(50)'		 

 print @SpliceTables
	EXEC SP_EXECUTESQL @Statement,@Parameter, 
		@OrderNo_1=@OrderNo,@Flow_1=@Flow,@SubType_1=@SubType,@PartyFrom_1=@PartyFrom,@PartyTo_1=@PartyTo,@Status_1=@Status, 
		@Priority_1=@Priority,@ExtOrderNo_1=@ExtOrderNo,@RefOrderNo_1=@RefOrderNo,@TraceCode_1=@TraceCode, 
		@CreateUserNm_1=@CreateUserNm,@DateFrom_1=@DateFrom,@DateTo_1=@DateTo,@StartTime_1=@StartTime,@EndTime_1=@EndTime,
		@WindowTimeFrom_1=@WindowTimeFrom,@WindowTimeTo_1=@WindowTimeTo,@Sequence_1=@Sequence,@Item_1=@Item, 
		@ManufactureParty_1=@ManufactureParty,@WMSSeq_1=@WMSSeq	 
END 




SET ANSI_NULLS ON

GO


