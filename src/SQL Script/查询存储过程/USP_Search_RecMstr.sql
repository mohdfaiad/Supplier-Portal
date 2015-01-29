IF EXISTS(SELECT * FROM sys.objects WHERE type='P' AND name='USP_Search_RecMstr') 
     DROP PROCEDURE USP_Search_RecMstr

/****** Object:  StoredProcedure [dbo].[USP_Search_RecMstr]    Script Date: 11/26/2012 10:57:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[USP_Search_RecMstr] 
( 
	@ReciptNo varchar(50), 
	@IpNo varchar(50), 
	@Status tinyint,	 
	@OrderTypes varchar(50), 
	@PartyFrom varchar(50), 
	@PartyTo varchar(50), 
	@StartDate datetime, 
	@EndDate datetime, 
	@Dock varchar(50), 
	@Item varchar(50), 
	@WMSNo varchar(50), 
	@ManufactureParty varchar(50), 
	@Flow varchar(50), 
	@IsSupplier bit, 
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
	DECLARE @Type varchar(5) 
	DECLARE @Statement nvarchar(4000) 
	DECLARE @Parameter nvarchar(4000) 
	DECLARE @PagePara nvarchar(4000) 
	DECLARE @SortDesc nvarchar(100) 
	DECLARE @Where nvarchar(4000) 
	DECLARE @PermissionClause nvarchar(1000) 
	SET @Where='WHERE 1=1 '+ISNULL(@WhereStatement,'') 

	IF(ISNULL(@OrderTypes,'')='') 
	BEGIN 
		RAISERROR ('Please choose order types to search!' , 16, 1) WITH NOWAIT 
	END 
	IF(ISNULL(@IPNo,'')<>'') 
	BEGIN 
		SET @IPNo=@IPNo+'%' 
		SET @Where=@Where+' AND r.IpNo LIKE @IpNo_1' 
	END	 
	IF(ISNULL(@ReciptNo,'')<>'') 
	BEGIN 
		SET @ReciptNo=@ReciptNo+'%' 
		SET @Where=@Where+' AND r.RecNo LIKE @ReciptNo_1' 
	END 
	IF(ISNULL(@WMSNo,'')<>'') 
	BEGIN 
		SET @WMSNo=@WMSNo+'%' 
		SET @Where=@Where+' AND r.WMSNo LIKE @WMSNo_1' 
	END	 
	IF(ISNULL(@Flow,'')<>'') 
	BEGIN 
		SET @Where=@Where+' AND r.Flow=@Flow_1' 
	END 
	IF(ISNULL(@PartyFrom,'')<>'') 
	BEGIN 
		SET @Where=@Where+' AND r.PartyFrom=@PartyFrom_1' 
	END 
	IF(ISNULL(@PartyTo,'')<>'') 
	BEGIN 
		SET @Where=@Where+' AND r.PartyTo=@PartyTo_1 ' 
	END		 
	IF(@Status is not null) 
	BEGIN 
		SET @Where=@Where+' AND r.Status=@Status_1 ' 
	END 
	IF(ISDATE(@EndDate)=1)
	BEGIN
    set @EndDate=dateadd(day,1,@EndDate)
    END
	IF(ISDATE(@StartDate)=1 AND ISDATE(@EndDate)=1) 
	BEGIN 
		SET @Where=@Where+' AND r.CreateDate BETWEEN @StartDate_1 And @EndDate_1 ' 
	END	 
	ELSE IF(ISDATE(@StartDate)=1 AND ISDATE(@EndDate)=0) 
	BEGIN 
		SET @Where=@Where+' AND r.CreateDate > @StartDate_1' 
	END 
	ELSE IF(ISDATE(@StartDate)=0 AND ISDATE(@EndDate)=1) 
	BEGIN 
		SET @Where=@Where+' AND r.CreateDate < @EndDate_1' 
	END	 

	DECLARE @UserCode varchar(50) 
	SELECT @UserCode=Code FROM ACC_User WHERE Id=@UserId 
	IF(UPPER(@UserCode)<>'SU') 
	BEGIN 
		SELECT PermissionCode INTO #Temp FROM VIEW_UserPermission WHERE UserId=@UserId 
		IF(@IsSupplier=0) 
		BEGIN 
			SET @Where=@Where+' AND r.PartyTo IN (SELECT PermissionCode FROM #Temp) ' 
		END 
		ELSE  
		BEGIN 
			SET @Where=@Where+' AND (r.PartyFrom IN (SELECT PermissionCode FROM #Temp) OR r.PartyTo IN (SELECT PermissionCode FROM #Temp))  ' 
		END				 
	END 

	IF ISNULL(@SortCloumn,'')='' 
	BEGIN 
		SET @SortDesc=' ORDER BY CreateDate DESC' 
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
		IF(CHARINDEX('Receive',@SortCloumn)>0) 
		BEGIN 
			SET @SortCloumn=REPLACE(@SortCloumn,'Receive','Rec') 
		END					 
		SET @SortDesc=' ORDER BY '+@SortCloumn+' '+@SortRule 
		IF(CHARINDEX('Address',@SortCloumn)>0) 
		BEGIN 
			SET @SortCloumn=REPLACE(@SortCloumn,'Address','Addr') 
		END					 
		SET @SortDesc=' ORDER BY '+@SortCloumn+' '+@SortRule		 
	END 

	IF @Page>0 
	BEGIN 
		SET @PagePara='WHERE RowId BETWEEN '+cast(@PageSize*(@Page-1) as varchar(50))+' AND '++cast(@PageSize*(@Page) as varchar(50)) 
	END 

	WHILE(LEN(@OrderTypes)>0) 
	BEGIN 
		IF(LEN(@OrderTypes)=1) 
		BEGIN 
			SET @Type=@OrderTypes 
		END 
		ELSE 
		BEGIN 
			SET @Type=SUBSTRING(@OrderTypes,1,CHARINDEX(',',@OrderTypes)-1) 
		END 

		IF(ISNULL(@SpliceTables,'')='') 
		BEGIN 
			SET @SpliceTables='SELECT * FROM ORD_RecMstr_'+@Type+' AS r '+REPLACE(@Where,'RecDetail','ORD_RecDet_'+@Type) 
		END 
		ELSE 
		BEGIN 
			SET @SpliceTables=@SpliceTables+' UNION ALL SELECT * FROM ORD_RecMstr_'+@Type+' AS r '+REPLACE(@Where,'RecDetail','ORD_RecDet_'+@Type) 
		END 
		SET @OrderTypes=SUBSTRING(@OrderTypes,3,LEN(@OrderTypes)) 
	END	 

	SET @Statement=N'SELECT TOP('+CAST(@PageSize AS VARCHAR(10))+') * FROM (SELECT *,RowId=ROW_NUMBER()OVER('+@SortDesc+') FROM ('+@SpliceTables+') AS T1 ) AS T2 '+@PagePara 
	PRINT @Statement 
	PRINT LEN(@Statement) 
	SET @Parameter=N'@IpNo_1 varchar(50),@Status_1 tinyint,	@OrderTypes_1 varchar(50),@PartyFrom_1 varchar(50),@PartyTo_1 varchar(50),@StartDate_1 datetime,@EndDate_1 datetime,@Dock_1 varchar(50),@Item_1 varchar(50),@ReciptNo_1 varchar(50),@WMSNo_1 varchar(50),@ManufactureParty_1 varchar(50),@Flow_1 varchar(50),@IsSupplier_1 bit'		 

	EXEC SP_EXECUTESQL @Statement,@Parameter, 
		@IPNo_1=@IPNo,@Status_1=@Status,@OrderTypes_1=@OrderTypes ,@PartyFrom_1=@PartyFrom,@PartyTo_1=@PartyTo ,@StartDate_1=@StartDate , 
		@EndDate_1=@EndDate ,@Dock_1=@Dock ,@Item_1=@Item ,@ReciptNo_1=@ReciptNo,@WMSNo_1=@WMSNo,@ManufactureParty_1=@ManufactureParty , 
		@Flow_1=@Flow,@IsSupplier_1=@IsSupplier 

END 

GO


