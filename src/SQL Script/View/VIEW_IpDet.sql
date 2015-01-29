

/****** Object:  View [dbo].[VIEW_IpDet]    Script Date: 2014/11/14 14:49:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO
IF EXISTS(SELECT * FROM SYS.objects WHERE type='V' AND name='VIEW_IpDet')
DROP VIEW VIEW_IpDet
go
CREATE VIEW [dbo].[VIEW_IpDet]
AS
SELECT a.Id,a.Type,a.IpNo,a.Seq,a.OrderNo,a.OrderType,a.OrderSubType,a.OrderDetId,a.OrderDetSeq,a.ExtNo,a.ExtSeq,a.Item,a.ItemDesc,a.RefItemCode,a.Uom,a.BaseUom,a.UC,a.UCDesc,a.Container,a.ContainerDesc,a.QualityType,a.ManufactureParty,a.Qty,a.RecQty,a.UnitQty,a.LocFrom,a.LocFromNm,a.LocTo,a.LocToNm,a.IsInspect,a.BillAddr,a.PriceList,a.UnitPrice,a.Currency,a.IsProvEst,a.Tax,a.IsIncludeTax,a.BillTerm,a.IsClose,a.GapRecNo,a.GapIpDetId,a.CreateUser,a.CreateUserNm,a.CreateDate,a.LastModifyUser,a.LastModifyUserNm,a.LastModifyDate,a.Version,a.StartTime,a.Windowtime,a.BinTo,a.IsScanHu,a.IsChangeUC,a.Flow,a.BWART,a.PSTYP FROM ORD_IpDet_0 AS a
UNION ALL
SELECT a.Id,a.Type,a.IpNo,a.Seq,a.OrderNo,a.OrderType,a.OrderSubType,a.OrderDetId,a.OrderDetSeq,a.ExtNo,a.ExtSeq,a.Item,a.ItemDesc,a.RefItemCode,a.Uom,a.BaseUom,a.UC,a.UCDesc,a.Container,a.ContainerDesc,a.QualityType,a.ManufactureParty,a.Qty,a.RecQty,a.UnitQty,a.LocFrom,a.LocFromNm,a.LocTo,a.LocToNm,a.IsInspect,a.BillAddr,a.PriceList,a.UnitPrice,a.Currency,a.IsProvEst,a.Tax,a.IsIncludeTax,a.BillTerm,a.IsClose,a.GapRecNo,a.GapIpDetId,a.CreateUser,a.CreateUserNm,a.CreateDate,a.LastModifyUser,a.LastModifyUserNm,a.LastModifyDate,a.Version,a.StartTime,a.Windowtime,a.BinTo,a.IsScanHu,a.IsChangeUC,a.Flow,a.BWART,a.PSTYP FROM ORD_IpDet_1 AS a
UNION ALL
SELECT a.Id,a.Type,a.IpNo,a.Seq,a.OrderNo,a.OrderType,a.OrderSubType,a.OrderDetId,a.OrderDetSeq,a.ExtNo,a.ExtSeq,a.Item,a.ItemDesc,a.RefItemCode,a.Uom,a.BaseUom,a.UC,a.UCDesc,a.Container,a.ContainerDesc,a.QualityType,a.ManufactureParty,a.Qty,a.RecQty,a.UnitQty,a.LocFrom,a.LocFromNm,a.LocTo,a.LocToNm,a.IsInspect,a.BillAddr,a.PriceList,a.UnitPrice,a.Currency,a.IsProvEst,a.Tax,a.IsIncludeTax,a.BillTerm,a.IsClose,a.GapRecNo,a.GapIpDetId,a.CreateUser,a.CreateUserNm,a.CreateDate,a.LastModifyUser,a.LastModifyUserNm,a.LastModifyDate,a.Version,a.StartTime,a.Windowtime,a.BinTo,a.IsScanHu,a.IsChangeUC,a.Flow,a.BWART,a.PSTYP FROM ORD_IpDet_2 AS a
UNION ALL
SELECT a.Id,a.Type,a.IpNo,a.Seq,a.OrderNo,a.OrderType,a.OrderSubType,a.OrderDetId,a.OrderDetSeq,a.ExtNo,a.ExtSeq,a.Item,a.ItemDesc,a.RefItemCode,a.Uom,a.BaseUom,a.UC,a.UCDesc,a.Container,a.ContainerDesc,a.QualityType,a.ManufactureParty,a.Qty,a.RecQty,a.UnitQty,a.LocFrom,a.LocFromNm,a.LocTo,a.LocToNm,a.IsInspect,a.BillAddr,a.PriceList,a.UnitPrice,a.Currency,a.IsProvEst,a.Tax,a.IsIncludeTax,a.BillTerm,a.IsClose,a.GapRecNo,a.GapIpDetId,a.CreateUser,a.CreateUserNm,a.CreateDate,a.LastModifyUser,a.LastModifyUserNm,a.LastModifyDate,a.Version,a.StartTime,a.Windowtime,a.BinTo,a.IsScanHu,a.IsChangeUC,a.Flow,a.BWART,a.PSTYP  FROM ORD_IpDet_3 AS a
UNION ALL
SELECT a.Id,a.Type,a.IpNo,a.Seq,a.OrderNo,a.OrderType,a.OrderSubType,a.OrderDetId,a.OrderDetSeq,a.ExtNo,a.ExtSeq,a.Item,a.ItemDesc,a.RefItemCode,a.Uom,a.BaseUom,a.UC,a.UCDesc,a.Container,a.ContainerDesc,a.QualityType,a.ManufactureParty,a.Qty,a.RecQty,a.UnitQty,a.LocFrom,a.LocFromNm,a.LocTo,a.LocToNm,a.IsInspect,a.BillAddr,a.PriceList,a.UnitPrice,a.Currency,a.IsProvEst,a.Tax,a.IsIncludeTax,a.BillTerm,a.IsClose,a.GapRecNo,a.GapIpDetId,a.CreateUser,a.CreateUserNm,a.CreateDate,a.LastModifyUser,a.LastModifyUserNm,a.LastModifyDate,a.Version,a.StartTime,a.Windowtime,a.BinTo,a.IsScanHu,a.IsChangeUC,a.Flow,a.BWART,a.PSTYP  FROM ORD_IpDet_4 AS a
UNION ALL
SELECT a.Id,a.Type,a.IpNo,a.Seq,a.OrderNo,a.OrderType,a.OrderSubType,a.OrderDetId,a.OrderDetSeq,a.ExtNo,a.ExtSeq,a.Item,a.ItemDesc,a.RefItemCode,a.Uom,a.BaseUom,a.UC,a.UCDesc,a.Container,a.ContainerDesc,a.QualityType,a.ManufactureParty,a.Qty,a.RecQty,a.UnitQty,a.LocFrom,a.LocFromNm,a.LocTo,a.LocToNm,a.IsInspect,a.BillAddr,a.PriceList,a.UnitPrice,a.Currency,a.IsProvEst,a.Tax,a.IsIncludeTax,a.BillTerm,a.IsClose,a.GapRecNo,a.GapIpDetId,a.CreateUser,a.CreateUserNm,a.CreateDate,a.LastModifyUser,a.LastModifyUserNm,a.LastModifyDate,a.Version,a.StartTime,a.Windowtime,a.BinTo,a.IsScanHu,a.IsChangeUC,a.Flow,a.BWART,a.PSTYP  FROM ORD_IpDet_5 AS a
UNION ALL
SELECT a.Id,a.Type,a.IpNo,a.Seq,a.OrderNo,a.OrderType,a.OrderSubType,a.OrderDetId,a.OrderDetSeq,a.ExtNo,a.ExtSeq,a.Item,a.ItemDesc,a.RefItemCode,a.Uom,a.BaseUom,a.UC,a.UCDesc,a.Container,a.ContainerDesc,a.QualityType,a.ManufactureParty,a.Qty,a.RecQty,a.UnitQty,a.LocFrom,a.LocFromNm,a.LocTo,a.LocToNm,a.IsInspect,a.BillAddr,a.PriceList,a.UnitPrice,a.Currency,a.IsProvEst,a.Tax,a.IsIncludeTax,a.BillTerm,a.IsClose,a.GapRecNo,a.GapIpDetId,a.CreateUser,a.CreateUserNm,a.CreateDate,a.LastModifyUser,a.LastModifyUserNm,a.LastModifyDate,a.Version,a.StartTime,a.Windowtime,a.BinTo,a.IsScanHu,a.IsChangeUC,a.Flow,a.BWART,a.PSTYP  FROM ORD_IpDet_6 AS a
UNION ALL
SELECT a.Id,a.Type,a.IpNo,a.Seq,a.OrderNo,a.OrderType,a.OrderSubType,a.OrderDetId,a.OrderDetSeq,a.ExtNo,a.ExtSeq,a.Item,a.ItemDesc,a.RefItemCode,a.Uom,a.BaseUom,a.UC,a.UCDesc,a.Container,a.ContainerDesc,a.QualityType,a.ManufactureParty,a.Qty,a.RecQty,a.UnitQty,a.LocFrom,a.LocFromNm,a.LocTo,a.LocToNm,a.IsInspect,a.BillAddr,a.PriceList,a.UnitPrice,a.Currency,a.IsProvEst,a.Tax,a.IsIncludeTax,a.BillTerm,a.IsClose,a.GapRecNo,a.GapIpDetId,a.CreateUser,a.CreateUserNm,a.CreateDate,a.LastModifyUser,a.LastModifyUserNm,a.LastModifyDate,a.Version,a.StartTime,a.Windowtime,a.BinTo,a.IsScanHu,a.IsChangeUC,a.Flow,a.BWART,a.PSTYP  FROM ORD_IpDet_7 AS a
UNION ALL
SELECT a.Id,a.Type,a.IpNo,a.Seq,a.OrderNo,a.OrderType,a.OrderSubType,a.OrderDetId,a.OrderDetSeq,a.ExtNo,a.ExtSeq,a.Item,a.ItemDesc,a.RefItemCode,a.Uom,a.BaseUom,a.UC,a.UCDesc,a.Container,a.ContainerDesc,a.QualityType,a.ManufactureParty,a.Qty,a.RecQty,a.UnitQty,a.LocFrom,a.LocFromNm,a.LocTo,a.LocToNm,a.IsInspect,a.BillAddr,a.PriceList,a.UnitPrice,a.Currency,a.IsProvEst,a.Tax,a.IsIncludeTax,a.BillTerm,a.IsClose,a.GapRecNo,a.GapIpDetId,a.CreateUser,a.CreateUserNm,a.CreateDate,a.LastModifyUser,a.LastModifyUserNm,a.LastModifyDate,a.Version,a.StartTime,a.Windowtime,a.BinTo,a.IsScanHu,a.IsChangeUC,a.Flow,a.BWART,a.PSTYP  FROM ORD_IpDet_8 AS a

GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'VIEW_IpDet'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'VIEW_IpDet'
GO

