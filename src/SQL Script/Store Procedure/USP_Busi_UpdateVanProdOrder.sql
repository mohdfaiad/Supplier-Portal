SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF EXISTS(SELECT * FROM sys.objects WHERE type='P' AND name='USP_Busi_UpdateVanProdOrder') 
     DROP PROCEDURE USP_Busi_UpdateVanProdOrder
GO

CREATE PROCEDURE [dbo].[USP_Busi_UpdateVanProdOrder] 
(
	@BatchNo int,
	@CreateUserId int,
	@CreateUserNm varchar(50)
) --WITH ENCRYPTION
AS 
BEGIN 
	set nocount on
	declare @DateTimeNow datetime = GetDate()
	declare @ErrorMsg nvarchar(MAX)
	declare @trancount int = @@trancount
		
	begin try
		if @trancount = 0
		begin
            begin tran
        end
		
		-----------------------------������׼��-----------------------------
		declare @SapProdLine varchar(50)  --SAP�����ߴ���A/B
		declare @SapOrderNo varchar(50)   --SAP��������������װ���������ţ����ǵ��̵��������ţ�
		declare @SapVAN varchar(50)       --VAN��
		declare @SapVersion varchar(50)   --������װ������װ
		declare @CabProdLine varchar(50)  --LES��ʻ�������ߴ���
		declare @ChassisProdLine varchar(50)  --LES���������ߴ���
		declare @AssemblyProdLine varchar(50)  --LES��װ�����ߴ���
		declare @SpecialProdLine varchar(50)  --LES��װ�����ߴ���
		declare @CheckProdLine varchar(50)  --LES��������ߴ���
		declare @VHVIN varchar(50)
		declare @ZENGINE varchar(50)
		declare @MATNR varchar(50)
		
		--������������¼
		select @SapProdLine = ZLINE, @SapOrderNo = AUFNR, @SapVAN = CHARG, @SapVersion=[VERSION],
		@VHVIN = VHVIN, @ZENGINE = ZENGINE, @MATNR = MATNR
		from SAP_ProdOrder where BatchNo = @BatchNo
		
		select @CabProdLine = CabProdLine, @ChassisProdLine = ChassisProdLine, 
		@AssemblyProdLine = AssemblyProdLine, @SpecialProdLine = SpecialProdLine,
		@CheckProdLine = CheckProdLine
		from CUST_ProductLineMap where SapProdLine = @SapProdLine and [Type] = 1
		-----------------------------������׼��-----------------------------
		
		
		
		
		-----------------------------�����ɼ�ʻ��������-----------------------------
		if not (@SapVersion = '0002' and @MATNR = '-WT64')  --���峵�����ɼ�ʻ��������
		begin
			declare @CabOrderNo varchar(50)
			exec USP_Busi_CreateOrUpdateVanProdOrder @BatchNo, @CabProdLine, N'��ʻ��������', null, null, null, @CreateUserId, @CreateUserNm, @CabOrderNo output
		end
		-----------------------------�����ɼ�ʻ��������-----------------------------
		
		
		
		-----------------------------�����ɵ���������-----------------------------
		if not (@SapVersion = '0002' and @MATNR = '-WT64')  --���峵�����ɵ���������
		begin
			declare @ChassisOrderNo varchar(50)
			exec USP_Busi_CreateOrUpdateVanProdOrder @BatchNo, @ChassisProdLine, N'����������', null, null, null, @CreateUserId, @CreateUserNm, @ChassisOrderNo output
		end
		-----------------------------�����ɵ���������-----------------------------
		
		
		
		if @SapVersion <> '0002'
		begin
		-----------------------------��������װ������-----------------------------
			declare @AssemblyOrderNo varchar(50)
			exec USP_Busi_CreateOrUpdateVanProdOrder @BatchNo, @AssemblyProdLine, N'��װ������', @SpecialProdLine, null, null, @CreateUserId, @CreateUserNm, @AssemblyOrderNo output
		-----------------------------��������װ������-----------------------------
		end
		
		else
		
		begin
		-----------------------------��������װ������-----------------------------
			declare @SpecialOrderNo varchar(50)
			if @MATNR <> '-WT64'
			begin  --�ǿ��峵
				exec USP_Busi_CreateOrUpdateVanProdOrder @BatchNo, @SpecialProdLine, N'��װ������', @AssemblyProdLine, null, null, @CreateUserId, @CreateUserNm, @SpecialOrderNo output
			end
			else
			begin	--���峵
				exec USP_Busi_CreateOrUpdateVanProdOrder @BatchNo, @SpecialProdLine, N'��װ������', @CabProdLine, @ChassisProdLine, @AssemblyProdLine, @CreateUserId, @CreateUserNm, @SpecialOrderNo output
			end
		-----------------------------��������װ������-----------------------------
		end
		
		
		
		-----------------------------�����ɼ��������-----------------------------
		declare @CheckOrderNo varchar(50)
		exec USP_Busi_CreateOrUpdateVanProdOrder @BatchNo, @CheckProdLine, N'���������', null, null, null, @CreateUserId, @CreateUserNm, @CheckOrderNo output
		-----------------------------�����ɼ��������-----------------------------
		
		if not exists(select top 1 1 from CUST_EngineTrace where TraceCode = @SapVAN)
		begin
			INSERT INTO CUST_EngineTrace(TraceCode, VHVIN, ZENGINE, CreateDate, CreateUser, CreateUserNm, LastModifyDate, LastModifyUser, LastModifyUserNm)
			values(@SapVAN, @VHVIN, @ZENGINE, @DateTimeNow, @CreateUserId, @CreateUserNm,  @DateTimeNow, @CreateUserId, @CreateUserNm)
		end
		else
		begin
			update CUST_EngineTrace set VHVIN = @VHVIN, ZENGINE = @ZENGINE, LastModifyDate = @DateTimeNow, LastModifyUser = @CreateUserId, LastModifyUserNm = @CreateUserNm 
			where TraceCode = @SapVAN
		end
		
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
		
		set @ErrorMsg = Error_Message() 
		RAISERROR(@ErrorMsg, 16, 1) 
	end catch 
END 
