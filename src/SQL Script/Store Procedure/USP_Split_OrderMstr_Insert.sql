SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF EXISTS(SELECT * FROM SYS.objects WHERE type='P' AND name='USP_Split_OrderMstr_Insert')
	DROP PROCEDURE USP_Split_OrderMstr_Insert
GO

CREATE PROCEDURE USP_Split_OrderMstr_Insert
(
	@Version int,
	@Flow varchar(50),
	@FlowDesc varchar(50),
	@TraceCode varchar(50),
	@RefOrderNo varchar(50),
	@ExtOrderNo varchar(50),
	@Type tinyint,
	@SubType tinyint,
	@QualityType tinyint,
	@StartTime datetime,
	@WindowTime datetime,
	@PauseStatus tinyint,
	@PauseSeq int,
	@PauseTime datetime,
	@EffDate datetime,
	@Priority tinyint,
	@Status tinyint,
	@PartyFrom varchar(50),
	@PartyFromNm varchar(100),
	@PartyTo varchar(50),
	@PartyToNm varchar(100),
	@ShipFrom varchar(50),
	@ShipFromAddr varchar(256),
	@ShipFromTel varchar(50),
	@ShipFromCell varchar(50),
	@ShipFromFax varchar(50),
	@ShipFromContact varchar(50),
	@ShipToAddr varchar(256),
	@ShipTo varchar(50),
	@ShipToTel varchar(50),
	@ShipToCell varchar(50),
	@ShipToFax varchar(50),
	@ShipToContact varchar(50),
	@Shift varchar(50),
	@LocFrom varchar(50),
	@LocFromNm varchar(100),
	@LocTo varchar(50),
	@LocToNm varchar(100),
	@IsInspect bit,
	@BillAddr varchar(50),
	@BillAddrDesc varchar(256),
	@PriceList varchar(50),
	@Currency varchar(50),
	@Dock varchar(100),
	@Routing varchar(50),
	@CurtOp int,
	@IsAutoRelease bit,
	@IsAutoStart bit,
	@IsAutoShip bit,
	@IsAutoReceive bit,
	@IsAutoBill bit,
	@IsManualCreateDet bit,
	@IsListPrice bit,
	@IsPrintOrder bit,
	@IsOrderPrinted bit,
	@IsPrintAsn bit,
	@IsPrintRec bit,
	@IsShipExceed bit,
	@IsRecExceed bit,
	@IsOrderFulfillUC bit,
	@IsShipFulfillUC bit,
	@IsRecFulfillUC bit,
	@IsShipScanHu bit,
	@IsRecScanHu bit,
	@IsCreatePL bit,
	@IsPLCreate bit,
	@IsShipFifo bit,
	@IsRecFifo bit,
	@IsShipByOrder bit,
	@IsOpenOrder bit,
	@IsAsnUniqueRec bit,
	@RecGapTo tinyint,
	@RecTemplate varchar(100),
	@OrderTemplate varchar(100),
	@AsnTemplate varchar(100),
	@HuTemplate varchar(100),
	@BillTerm tinyint,
	@CreateHuOpt tinyint,
	@ReCalculatePriceOpt tinyint,
	@WMSNo varchar(50),
	@CreateUser int,
	@CreateUserNm varchar(100),
	@CreateDate datetime,
	@LastModifyUser int,
	@LastModifyUserNm varchar(100),
	@LastModifyDate datetime,
	@ReleaseDate datetime,
	@ReleaseUser int,
	@ReleaseUserNm varchar(100),
	@StartDate datetime,
	@StartUser int,
	@StartUserNm varchar(100),
	@CompleteDate datetime,
	@CompleteUser int,
	@CompleteUserNm varchar(100),
	@CloseDate datetime,
	@CloseUser int,
	@CloseUserNm varchar(100),
	@CancelDate datetime,
	@CancelUser int,
	@CancelUserNm varchar(100),
	@CancelReason varchar(256),
	@OrderStrategy tinyint,
	@ProdLineFact varchar(50),
	@IsQuick bit,
	@PickStrategy varchar(50),
	@ExtraDmdSource varchar(256),
	@ProdLineType tinyint,
	@SeqGroup varchar(50),
	@OrderNo varchar(4000)
)
AS
BEGIN

	IF @Type = 8
	BEGIN
		IF EXISTS(SELECT 1 FROM ORD_OrderMstr_8 WHERE RefOrderNo=@RefOrderNo AND ExtOrderNo=@ExtOrderNo)
		BEGIN
			RAISERROR('�ƻ�Э����к��ظ�', 16, 1)
			RETURN
		END
	END
	DECLARE @Statement nvarchar(4000)
	DECLARE @Parameters nvarchar(4000)
	SET @Statement='INSERT INTO ORD_OrderMstr_' + CONVERT(nvarchar, @Type) + '(OrderNo,Version,Flow,FlowDesc,TraceCode,RefOrderNo,ExtOrderNo,Type,SubType,QualityType,StartTime,WindowTime,PauseStatus,PauseSeq,PauseTime,EffDate,Priority,Status,PartyFrom,PartyFromNm,PartyTo,PartyToNm,ShipFrom,ShipFromAddr,ShipFromTel,ShipFromCell,ShipFromFax,ShipFromContact,ShipToAddr,ShipTo,ShipToTel,ShipToCell,ShipToFax,ShipToContact,Shift,LocFrom,LocFromNm,LocTo,LocToNm,IsInspect,BillAddr,BillAddrDesc,PriceList,Currency,Dock,Routing,CurtOp,IsAutoRelease,IsAutoStart,IsAutoShip,IsAutoReceive,IsAutoBill,IsManualCreateDet,IsListPrice,IsPrintOrder,IsOrderPrinted,IsPrintAsn,IsPrintRec,IsShipExceed,IsRecExceed,IsOrderFulfillUC,IsShipFulfillUC,IsRecFulfillUC,IsShipScanHu,IsRecScanHu,IsCreatePL,IsPLCreate,IsShipFifo,IsRecFifo,IsShipByOrder,IsOpenOrder,IsAsnUniqueRec,RecGapTo,RecTemplate,OrderTemplate,AsnTemplate,HuTemplate,BillTerm,CreateHuOpt,ReCalculatePriceOpt,WMSNo,CreateUser,CreateUserNm,CreateDate,LastModifyUser,LastModifyUserNm,LastModifyDate,ReleaseDate,ReleaseUser,ReleaseUserNm,StartDate,StartUser,StartUserNm,CompleteDate,CompleteUser,CompleteUserNm,CloseDate,CloseUser,CloseUserNm,CancelDate,CancelUser,CancelUserNm,CancelReason,OrderStrategy,ProdLineFact,IsQuick,PickStrategy,ExtraDmdSource,ProdLineType,SeqGroup) VALUES(@OrderNo_1,@Version_1,@Flow_1,@FlowDesc_1,@TraceCode_1,@RefOrderNo_1,@ExtOrderNo_1,@Type_1,@SubType_1,@QualityType_1,@StartTime_1,@WindowTime_1,@PauseStatus_1,@PauseSeq_1,@PauseTime_1,@EffDate_1,@Priority_1,@Status_1,@PartyFrom_1,@PartyFromNm_1,@PartyTo_1,@PartyToNm_1,@ShipFrom_1,@ShipFromAddr_1,@ShipFromTel_1,@ShipFromCell_1,@ShipFromFax_1,@ShipFromContact_1,@ShipToAddr_1,@ShipTo_1,@ShipToTel_1,@ShipToCell_1,@ShipToFax_1,@ShipToContact_1,@Shift_1,@LocFrom_1,@LocFromNm_1,@LocTo_1,@LocToNm_1,@IsInspect_1,@BillAddr_1,@BillAddrDesc_1,@PriceList_1,@Currency_1,@Dock_1,@Routing_1,@CurtOp_1,@IsAutoRelease_1,@IsAutoStart_1,@IsAutoShip_1,@IsAutoReceive_1,@IsAutoBill_1,@IsManualCreateDet_1,@IsListPrice_1,@IsPrintOrder_1,@IsOrderPrinted_1,@IsPrintAsn_1,@IsPrintRec_1,@IsShipExceed_1,@IsRecExceed_1,@IsOrderFulfillUC_1,@IsShipFulfillUC_1,@IsRecFulfillUC_1,@IsShipScanHu_1,@IsRecScanHu_1,@IsCreatePL_1,@IsPLCreate_1,@IsShipFifo_1,@IsRecFifo_1,@IsShipByOrder_1,@IsOpenOrder_1,@IsAsnUniqueRec_1,@RecGapTo_1,@RecTemplate_1,@OrderTemplate_1,@AsnTemplate_1,@HuTemplate_1,@BillTerm_1,@CreateHuOpt_1,@ReCalculatePriceOpt_1,@WMSNo_1,@CreateUser_1,@CreateUserNm_1,@CreateDate_1,@LastModifyUser_1,@LastModifyUserNm_1,@LastModifyDate_1,@ReleaseDate_1,@ReleaseUser_1,@ReleaseUserNm_1,@StartDate_1,@StartUser_1,@StartUserNm_1,@CompleteDate_1,@CompleteUser_1,@CompleteUserNm_1,@CloseDate_1,@CloseUser_1,@CloseUserNm_1,@CancelDate_1,@CancelUser_1,@CancelUserNm_1,@CancelReason_1,@OrderStrategy_1,@ProdLineFact_1,@IsQuick_1,@PickStrategy_1,@ExtraDmdSource_1,@ProdLineType_1,@SeqGroup_1)'
	SET @Parameters='@OrderNo_1 varchar(4000), @Version_1 int, @Flow_1 varchar(50), @FlowDesc_1 varchar(50), @TraceCode_1 varchar(50), @RefOrderNo_1 varchar(50), @ExtOrderNo_1 varchar(50), @Type_1 tinyint, @SubType_1 tinyint, @QualityType_1 tinyint, @StartTime_1 datetime, @WindowTime_1 datetime, @PauseStatus_1 tinyint, @PauseSeq_1 int, @PauseTime_1 datetime, @EffDate_1 datetime, @Priority_1 tinyint, @Status_1 tinyint, @PartyFrom_1 varchar(50), @PartyFromNm_1 varchar(100), @PartyTo_1 varchar(50), @PartyToNm_1 varchar(100), @ShipFrom_1 varchar(50), @ShipFromAddr_1 varchar(256), @ShipFromTel_1 varchar(50), @ShipFromCell_1 varchar(50), @ShipFromFax_1 varchar(50), @ShipFromContact_1 varchar(50), @ShipToAddr_1 varchar(256), @ShipTo_1 varchar(50), @ShipToTel_1 varchar(50), @ShipToCell_1 varchar(50), @ShipToFax_1 varchar(50), @ShipToContact_1 varchar(50), @Shift_1 varchar(50), @LocFrom_1 varchar(50), @LocFromNm_1 varchar(100), @LocTo_1 varchar(50), @LocToNm_1 varchar(100), @IsInspect_1 bit, @BillAddr_1 varchar(50), @BillAddrDesc_1 varchar(256), @PriceList_1 varchar(50), @Currency_1 varchar(50), @Dock_1 varchar(100), @Routing_1 varchar(50), @CurtOp_1 int, @IsAutoRelease_1 bit, @IsAutoStart_1 bit, @IsAutoShip_1 bit, @IsAutoReceive_1 bit, @IsAutoBill_1 bit, @IsManualCreateDet_1 bit, @IsListPrice_1 bit, @IsPrintOrder_1 bit, @IsOrderPrinted_1 bit, @IsPrintAsn_1 bit, @IsPrintRec_1 bit, @IsShipExceed_1 bit, @IsRecExceed_1 bit, @IsOrderFulfillUC_1 bit, @IsShipFulfillUC_1 bit, @IsRecFulfillUC_1 bit, @IsShipScanHu_1 bit, @IsRecScanHu_1 bit, @IsCreatePL_1 bit, @IsPLCreate_1 bit, @IsShipFifo_1 bit, @IsRecFifo_1 bit, @IsShipByOrder_1 bit, @IsOpenOrder_1 bit, @IsAsnUniqueRec_1 bit, @RecGapTo_1 tinyint, @RecTemplate_1 varchar(100), @OrderTemplate_1 varchar(100), @AsnTemplate_1 varchar(100), @HuTemplate_1 varchar(100), @BillTerm_1 tinyint, @CreateHuOpt_1 tinyint, @ReCalculatePriceOpt_1 tinyint, @WMSNo_1 varchar(50), @CreateUser_1 int, @CreateUserNm_1 varchar(100), @CreateDate_1 datetime, @LastModifyUser_1 int, @LastModifyUserNm_1 varchar(100), @LastModifyDate_1 datetime, @ReleaseDate_1 datetime, @ReleaseUser_1 int, @ReleaseUserNm_1 varchar(100), @StartDate_1 datetime, @StartUser_1 int, @StartUserNm_1 varchar(100), @CompleteDate_1 datetime, @CompleteUser_1 int, @CompleteUserNm_1 varchar(100), @CloseDate_1 datetime, @CloseUser_1 int, @CloseUserNm_1 varchar(100), @CancelDate_1 datetime, @CancelUser_1 int, @CancelUserNm_1 varchar(100), @CancelReason_1 varchar(256), @OrderStrategy_1 tinyint, @ProdLineFact_1 varchar(50), @IsQuick_1 bit, @PickStrategy_1 varchar(50), @ExtraDmdSource_1 varchar(256), @ProdLineType_1 tinyint, @SeqGroup_1 varchar(50)'
	EXEC SP_EXECUTESQL @Statement,@Parameters,@OrderNo_1=@OrderNo,@Version_1=@Version,@Flow_1=@Flow,@FlowDesc_1=@FlowDesc,@TraceCode_1=@TraceCode,@RefOrderNo_1=@RefOrderNo,@ExtOrderNo_1=@ExtOrderNo,@Type_1=@Type,@SubType_1=@SubType,@QualityType_1=@QualityType,@StartTime_1=@StartTime,@WindowTime_1=@WindowTime,@PauseStatus_1=@PauseStatus,@PauseSeq_1=@PauseSeq,@PauseTime_1=@PauseTime,@EffDate_1=@EffDate,@Priority_1=@Priority,@Status_1=@Status,@PartyFrom_1=@PartyFrom,@PartyFromNm_1=@PartyFromNm,@PartyTo_1=@PartyTo,@PartyToNm_1=@PartyToNm,@ShipFrom_1=@ShipFrom,@ShipFromAddr_1=@ShipFromAddr,@ShipFromTel_1=@ShipFromTel,@ShipFromCell_1=@ShipFromCell,@ShipFromFax_1=@ShipFromFax,@ShipFromContact_1=@ShipFromContact,@ShipToAddr_1=@ShipToAddr,@ShipTo_1=@ShipTo,@ShipToTel_1=@ShipToTel,@ShipToCell_1=@ShipToCell,@ShipToFax_1=@ShipToFax,@ShipToContact_1=@ShipToContact,@Shift_1=@Shift,@LocFrom_1=@LocFrom,@LocFromNm_1=@LocFromNm,@LocTo_1=@LocTo,@LocToNm_1=@LocToNm,@IsInspect_1=@IsInspect,@BillAddr_1=@BillAddr,@BillAddrDesc_1=@BillAddrDesc,@PriceList_1=@PriceList,@Currency_1=@Currency,@Dock_1=@Dock,@Routing_1=@Routing,@CurtOp_1=@CurtOp,@IsAutoRelease_1=@IsAutoRelease,@IsAutoStart_1=@IsAutoStart,@IsAutoShip_1=@IsAutoShip,@IsAutoReceive_1=@IsAutoReceive,@IsAutoBill_1=@IsAutoBill,@IsManualCreateDet_1=@IsManualCreateDet,@IsListPrice_1=@IsListPrice,@IsPrintOrder_1=@IsPrintOrder,@IsOrderPrinted_1=@IsOrderPrinted,@IsPrintAsn_1=@IsPrintAsn,@IsPrintRec_1=@IsPrintRec,@IsShipExceed_1=@IsShipExceed,@IsRecExceed_1=@IsRecExceed,@IsOrderFulfillUC_1=@IsOrderFulfillUC,@IsShipFulfillUC_1=@IsShipFulfillUC,@IsRecFulfillUC_1=@IsRecFulfillUC,@IsShipScanHu_1=@IsShipScanHu,@IsRecScanHu_1=@IsRecScanHu,@IsCreatePL_1=@IsCreatePL,@IsPLCreate_1=@IsPLCreate,@IsShipFifo_1=@IsShipFifo,@IsRecFifo_1=@IsRecFifo,@IsShipByOrder_1=@IsShipByOrder,@IsOpenOrder_1=@IsOpenOrder,@IsAsnUniqueRec_1=@IsAsnUniqueRec,@RecGapTo_1=@RecGapTo,@RecTemplate_1=@RecTemplate,@OrderTemplate_1=@OrderTemplate,@AsnTemplate_1=@AsnTemplate,@HuTemplate_1=@HuTemplate,@BillTerm_1=@BillTerm,@CreateHuOpt_1=@CreateHuOpt,@ReCalculatePriceOpt_1=@ReCalculatePriceOpt,@WMSNo_1=@WMSNo,@CreateUser_1=@CreateUser,@CreateUserNm_1=@CreateUserNm,@CreateDate_1=@CreateDate,@LastModifyUser_1=@LastModifyUser,@LastModifyUserNm_1=@LastModifyUserNm,@LastModifyDate_1=@LastModifyDate,@ReleaseDate_1=@ReleaseDate,@ReleaseUser_1=@ReleaseUser,@ReleaseUserNm_1=@ReleaseUserNm,@StartDate_1=@StartDate,@StartUser_1=@StartUser,@StartUserNm_1=@StartUserNm,@CompleteDate_1=@CompleteDate,@CompleteUser_1=@CompleteUser,@CompleteUserNm_1=@CompleteUserNm,@CloseDate_1=@CloseDate,@CloseUser_1=@CloseUser,@CloseUserNm_1=@CloseUserNm,@CancelDate_1=@CancelDate,@CancelUser_1=@CancelUser,@CancelUserNm_1=@CancelUserNm,@CancelReason_1=@CancelReason,@OrderStrategy_1=@OrderStrategy,@ProdLineFact_1=@ProdLineFact,@IsQuick_1=@IsQuick,@PickStrategy_1=@PickStrategy,@ExtraDmdSource_1=@ExtraDmdSource,@ProdLineType_1=@ProdLineType,@SeqGroup_1=@SeqGroup
END
GO
