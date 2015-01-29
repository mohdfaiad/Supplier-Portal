SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF EXISTS(SELECT * FROM SYS.OBJECTS WHERE TYPE='P' AND name='USP_LE_SpecifyOrderCSSupplier')
	DROP PROCEDURE USP_LE_SpecifyOrderCSSupplier	
GO

CREATE PROCEDURE [dbo].[USP_LE_SpecifyOrderCSSupplier]
(
	@OrderNo varchar(50)
) --WITH ENCRYPTION
AS
BEGIN
	set nocount on
	create table #tempSeqOrderDet3
	(
		RowId int identity(1, 1),
		OrderDetId int, 
		Item varchar(50), 
		LocFrom varchar(50),
		OrderQty decimal(18, 8), 
		ManufactureParty varchar(50)
	)
	
	create table #tempOccupyOrderDet
	(
		Item varchar(50),
		Location varchar(50),
		Qty decimal(18, 8),
		ManufactureParty varchar(50),
	)
	
	create table #tempLocFrom
	(
		RowId int identity(1, 1),
		LocFrom varchar(50)
	)
	
	create table #tempItem
	(
		RowId int identity(1, 1),
		Item varchar(50),
	)
	
	create table #tempLocationLotDet
	(
		Id int Primary KEY,
		Item varchar(50),
		Location varchar(50),
		Qty decimal(18, 8),
		OccupyQty decimal(18, 8) default 0,
		CSSupplier varchar(50),
	)

	begin try
		-------------------����������ϸ�з���-----------------------
		--ָ����Ӧ�̵ķ�ǰ�棬���ȷ���
		insert into #tempSeqOrderDet3(OrderDetId, Item, LocFrom, ManufactureParty, OrderQty)
		select det.Id, det.Item, det.LocFrom, det.ManufactureParty, SUM(det.OrderQty)
		from ORD_OrderDet_2 as det 
		where det.OrderNo = @OrderNo and det.OrderQty > 0 and det.ManufactureParty is not null
		group by det.Id, det.Item, det.LocFrom, det.ManufactureParty
		
		insert into #tempSeqOrderDet3(OrderDetId, Item, LocFrom, OrderQty)
		select det.Id, det.Item, det.LocFrom, SUM(det.OrderQty)
		from ORD_OrderDet_2 as det 
		where det.OrderNo = @OrderNo and det.OrderQty > 0 and det.ManufactureParty is null
		group by det.Id, det.Item, det.LocFrom
		-------------------����������ϸ�з���-----------------------
		
		if exists(select top 1 1 from #tempSeqOrderDet3)
		begin
			-------------------����ȡ�����ϸ-----------------------
			declare @Statement nvarchar(4000) 
			insert into #tempLocFrom(LocFrom) select distinct LocFrom from #tempSeqOrderDet3
			declare @LocFromRowId int
			declare @MaxLocFromRowId int
			select @LocFromRowId = MIN(RowId), @MaxLocFromRowId = MAX(RowId) from #tempLocFrom
			while @LocFromRowId <= @MaxLocFromRowId
			begin
				declare @LocFrom varchar(50) = null
				declare @PartSuffix varchar(50) = null
				select @LocFrom = lf.LocFrom, @PartSuffix = l.PartSuffix from #tempLocFrom as lf 
				inner join MD_Location as l on lf.LocFrom = l.Code
				where RowId = @LocFromRowId
				
				if @LocFromRowId = 1
				begin
					set @Statement = 'select MIN(Id) as Id, Item, Location, SUM(Qty) as Qty, CSSupplier from INV_LocationLotDet_' + CASE WHEN ISNULL(@PartSuffix, '') = '' THEN '0' ELSE @PartSuffix END + ' where Location = ''' + @LocFrom + ''' and Qty > 0 and OccupyType = 0 and IsATP = 1'
				end
				else
				begin
					set @Statement = @Statement + ' UNION ALL'
					set @Statement = @Statement + ' select MIN(Id) as Id, Item, Location, SUM(Qty) as Qty, CSSupplier from INV_LocationLotDet_' + CASE WHEN ISNULL(@PartSuffix, '') = '' THEN '0' ELSE @PartSuffix END + ' where Location = ''' + @LocFrom + ''' and Qty > 0 and OccupyType = 0 and IsATP = 1'
				end
				
				insert into #tempItem(Item) select distinct Item from #tempSeqOrderDet3 where LocFrom = @LocFrom
				declare @ItemRowId int
				declare @MaxItemRowId int
				select @ItemRowId = MIN(RowId), @MaxItemRowId = MAX(RowId) from #tempItem
				while @ItemRowId <= @MaxItemRowId
				begin
					declare @Item varchar(50) = null
					select @Item = Item from #tempItem where RowId = @ItemRowId
					
					if @ItemRowId = 1
					begin
						set @Statement = @Statement + ' and Item in (''' + @Item + ''''
					end
					else
					begin
						set @Statement = @Statement + ',''' + @Item+ ''''
					end
					
					set @ItemRowId = @ItemRowId + 1
				end
				set @Statement = @Statement + ') group by Item, Location, CSSupplier'
				
				set @LocFromRowId = @LocFromRowId + 1
			end
			
			insert into #tempLocationLotDet(Id, Item, Location, Qty, CSSupplier) exec sp_executesql @Statement
			-------------------����ȡ�����ϸ-----------------------
			
			if exists(select top 1 1 from #tempLocationLotDet)
			begin
				-------------------���ۼ����������ռ��-----------------------
				insert into #tempOccupyOrderDet(Item, Location, ManufactureParty, Qty)
				select det.Item, det.LocFrom, det.ICHARG, SUM(det.OrderQty - det.ShipQty) 
				from ORD_OrderDet_2 as det 
				inner join ORD_OrderMstr_2 as mstr on mstr.OrderNo = det.OrderNo
				inner join (select distinct Item, LocFrom from #tempSeqOrderDet3) as t on det.Item = t.Item and det.LocFrom = t.LocFrom
				where mstr.OrderNo <> @OrderNo --and mstr.OrderStrategy = 4 
					and mstr.[Status] in (1, 2) and mstr.SubType = 0 and det.OrderQty > det.ShipQty
				group by det.Item, det.LocFrom, det.ICHARG
				
				if exists(select top 1 1 from #tempOccupyOrderDet)
				begin
					-------------------����1�οۼ����п��-----------------------
					update loc set OccupyQty = ord.Qty
					from #tempLocationLotDet as loc 
					inner join #tempOccupyOrderDet as ord on loc.Item = ord.Item and loc.Location = ord.Location
					where loc.CSSupplier is null and ord.ManufactureParty is null
					-------------------����1�οۼ����п��-----------------------
					
					
					-------------------����2�οۼ����ۿ��-----------------------
					update loc set OccupyQty = ord.Qty
					from #tempLocationLotDet as loc 
					inner join #tempOccupyOrderDet as ord on loc.Item = ord.Item and loc.Location = ord.Location and loc.CSSupplier = ord.ManufactureParty
					where loc.CSSupplier is not null and ord.ManufactureParty is not null
					-------------------����2�οۼ����ۿ��-----------------------
				end
				-------------------���ۼ����������ռ��-----------------------
				
			
				-------------------��ѭ��ռ�ÿ��-----------------------
				if exists(select top 1 1 from #tempLocationLotDet where Qty > OccupyQty)
				begin
					declare @RowId int
					declare @MaxRowId int
					
					select @RowId = MIN(RowId), @MaxRowId = MAX(RowId) from #tempSeqOrderDet3
					
					while @RowId <= @MaxRowId
					begin
						declare @OrderDetId int = null
						declare @SeqDetItem varchar(50) = null
						declare @SeqDetLocFrom varchar(50) = null
						declare @ManufactureParty varchar(50) = null
						declare @CSSupplier varchar(50) = null
						declare @OrderQty decimal(18, 8) = null
						declare @LocationLotDetId int = null
					
						select @OrderDetId = OrderDetId, @SeqDetItem = Item, @SeqDetLocFrom = LocFrom, @ManufactureParty = ManufactureParty, @OrderQty = OrderQty 
						from #tempSeqOrderDet3 where RowId = @RowId
					
						if (ISNULL(@ManufactureParty, '') <> '')
						begin  --ָ����Ӧ��
							select @LocationLotDetId = Id, @CSSupplier = CSSupplier from #tempLocationLotDet
							where Item = @SeqDetItem and Location = @SeqDetLocFrom and CSSupplier = @ManufactureParty and Qty >= (OccupyQty + @OrderQty)
						
							if @LocationLotDetId is not null
							begin
								update ORD_OrderDet_2 set ICHARG = @CSSupplier where Id = @OrderDetId
								update #tempLocationLotDet set OccupyQty = OccupyQty + @OrderQty where Id = @LocationLotDetId
							end
							else
							begin
								update ORD_OrderDet_2 set BWART = N'ָ����Ӧ��' + @ManufactureParty + N'�Ŀ�治�㡣' where Id = @OrderDetId
							end
						end
						else
						begin
							select top 1 @LocationLotDetId = Id, @CSSupplier = CSSupplier from #tempLocationLotDet
							where Item = @SeqDetItem and Location = @SeqDetLocFrom and Qty >= (OccupyQty + @OrderQty)
							order by Id
							
							if @LocationLotDetId is not null
							begin
								update ORD_OrderDet_2 set BWART = null, ICHARG = @CSSupplier where Id = @OrderDetId
								update #tempLocationLotDet set OccupyQty = OccupyQty + @OrderQty where Id = @LocationLotDetId
							end
							else
							begin
								update ORD_OrderDet_2 set BWART = N'��治�㡣', ICHARG = null where Id = @OrderDetId
							end
						end
					
						set @RowId = @RowId + 1
					end
				end
				else
				begin
					update ORD_OrderDet_2 set BWART = N'��治�㡣'
					where OrderNo = @OrderNo and OrderQty > 0
				end
				-------------------��ѭ��ռ�ÿ��-----------------------
			end
			else
			begin
				update ORD_OrderDet_2 set BWART = N'��治�㡣'
				where OrderNo = @OrderNo and OrderQty > 0
			end
		end
	end try
	begin catch
		declare @Msg nvarchar(Max) = Error_Message() 
		RAISERROR(@Msg, 16, 1) 
	end catch
	
	drop table #tempSeqOrderDet3
	drop table #tempOccupyOrderDet
	drop table #tempLocFrom
	drop table #tempItem
	drop table #tempLocationLotDet
END