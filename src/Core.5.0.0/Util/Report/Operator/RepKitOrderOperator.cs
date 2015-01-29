using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using com.Sconit.PrintModel.ORD;

namespace com.Sconit.Utility.Report.Operator
{
    public class RepKitOrderOperator: RepTemplate1
    {
        public RepKitOrderOperator()
        {
            //明细部分的行数
            this.pageDetailRowCount = 30;
            //列数   1起始
            this.columnCount = 13;
            //报表头的行数  1起始
            this.headRowCount = 7;
            //报表尾的行数  1起始
            this.bottomRowCount = 1;
        }

        /**
         * 填充报表
         * 
         * Param list [0]OrderHead
         * Param list [0]IList<OrderDetail>           
         */
        protected override bool FillValuesImpl(String templateFileName, IList<object> list)
        {
            try
            {
                if (list == null || list.Count < 2) return false;

                PrintOrderMaster orderMaster = (PrintOrderMaster)(list[0]);
                IList<PrintOrderDetail> orderDetails = (IList<PrintOrderDetail>)(list[1]);

                if (orderMaster == null
                    || orderDetails == null || orderDetails.Count == 0)
                {
                    return false;
                }


                //this.SetRowCellBarCode(0, 2, 7);
                this.barCodeFontName = this.GetBarcodeFontName(1,4);
                this.CopyPage(orderDetails.Count);

                this.FillHead(orderMaster);


                int pageIndex = 1;
                int rowIndex = 0;
                int rowTotal = 0;
                string reserveNo = string.Empty;
                foreach (PrintOrderDetail orderDetail in orderDetails)
                {
                    if (orderDetail.ReserveNo == reserveNo)
                    {
                        orderDetail.ReserveNo = string.Empty;
                    }
                    else
                    {
                        reserveNo = orderDetail.ReserveNo;
                    }

                    this.SetRowCell(pageIndex, rowIndex, 0, orderDetail.ReserveNo);

                    this.SetRowCell(pageIndex, rowIndex, 1, orderDetail.ZOPID);
                    
                    this.SetRowCell(pageIndex, rowIndex, 2, orderDetail.Item);

                    this.SetRowCell(pageIndex, rowIndex, 4, orderDetail.ReferenceItemCode);

                    this.SetRowCell(pageIndex, rowIndex, 5, orderDetail.ItemDescription);

                    this.SetRowCell(pageIndex, rowIndex, 8, orderDetail.ManufactureParty);

                    this.SetRowCell(pageIndex, rowIndex, 10,orderDetail.OrderedQty>0? orderDetail.OrderedQty.ToString("0.########"):string.Empty);

                    this.SetRowCell(pageIndex, rowIndex, 11, orderDetail.Routing);

                    this.SetRowCell(pageIndex, rowIndex, 12, orderDetail.IsScanHu ? "√" : string.Empty);


                    //if (orderDetail.IsScanHu == true)
                    //{
                    //    this.SetRowCell(pageIndex, rowIndex, 10, "√");
                    //}

                    //批号/备注
                   // this.SetRowCell(pageIndex, rowIndex, 11, "");

                    if (this.isPageBottom(rowIndex, rowTotal))//页的最后一行
                    {
                        pageIndex++;
                        rowIndex = 0;
                    }
                    else
                    {
                        rowIndex++;
                    }
                    rowTotal++;
                }

                this.sheet.DisplayGridlines = false;
                this.sheet.IsPrintGridlines = false;
            }
            catch (Exception)
            {
                return false;
            }
            return true;
        }

        /*
         * 填充报表头
         * 
         * Param repack 报验单头对象
         */
        private void FillHead(PrintOrderMaster orderMaster)
        {
            //顺序号:
            this.SetRowCell(0, 5, orderMaster.Sequence.ToString());
            //订单号:
            if (!string.IsNullOrEmpty(orderMaster.TraceCode))
            {
                string vanCode = Utility.BarcodeHelper.GetBarcodeStr(orderMaster.TraceCode, this.barCodeFontName);
                this.SetRowCell(1, 3, vanCode);
            }
            //Order No.:
            this.SetRowCell(2, 3, orderMaster.TraceCode);

            //订单号:
            string orderCode = Utility.BarcodeHelper.GetBarcodeStr(orderMaster.OrderNo, this.barCodeFontName);
            this.SetRowCell(1, 7, orderCode);
            //Order No.:
            this.SetRowCell(2, 7, orderMaster.OrderNo);

            this.SetRowCell(3, 3, orderMaster.Flow+"["+orderMaster.FlowDescription+"]");

            //线体
            this.SetRowCell(4, 3, orderMaster.SequenceGroup.Substring(orderMaster.SequenceGroup.Length - 1));
  
            //来源库位
           // this.SetRowCell(3, 5, orderMaster.OrderDetails[0].LocationFrom);

            //发出时间 Create Time:
            this.SetRowCell(3, 9, orderMaster.CreateDate.ToString("yyyy-MM-dd HH:mm:ss"));


            //目的库位
            //this.SetRowCell(4, 5, orderMaster.OrderDetails[0].LocationTo);

            //窗口时间 
            this.SetRowCell(4, 9, orderMaster.WindowTime.ToString("yyyy-MM-dd HH:mm:ss"));
        }

        /**
           * 需要拷贝的数据与合并单元格操作
           * 
           * Param pageIndex 页号
           */
        public override void CopyPageValues(int pageIndex)
        {
            this.SetMergedRegion(pageIndex, 7, 3, 7, 4);
            this.SetMergedRegion(pageIndex, 8, 3, 8, 4);
            this.SetMergedRegion(pageIndex, 9, 3, 9, 4);
            this.SetMergedRegion(pageIndex, 10, 3, 10, 4);
            this.SetMergedRegion(pageIndex, 11, 3, 11, 4);
            this.SetMergedRegion(pageIndex, 12, 3, 12, 4);
            this.SetMergedRegion(pageIndex, 13, 3, 13, 4);
            this.SetMergedRegion(pageIndex, 14, 3, 14, 4);
            this.SetMergedRegion(pageIndex, 15, 3, 15, 4);
            this.SetMergedRegion(pageIndex, 16, 3, 16, 4);
            this.SetMergedRegion(pageIndex, 17, 3, 17, 4);
            this.SetMergedRegion(pageIndex, 18, 3, 18, 4);
            this.SetMergedRegion(pageIndex, 19, 3, 19, 4);
            this.SetMergedRegion(pageIndex, 20, 3, 20, 4);
            this.SetMergedRegion(pageIndex, 21, 3, 21, 4);
            this.SetMergedRegion(pageIndex, 22, 3, 22, 4);
            this.SetMergedRegion(pageIndex, 23, 3, 23, 4);
            this.SetMergedRegion(pageIndex, 24, 3, 24, 4);
            this.SetMergedRegion(pageIndex, 25, 3, 25, 4);
            this.SetMergedRegion(pageIndex, 26, 3, 26, 4);
            this.SetMergedRegion(pageIndex, 27, 3, 27, 4);
            this.SetMergedRegion(pageIndex, 28, 3, 28, 4);
            this.SetMergedRegion(pageIndex, 29, 3, 29, 4);
            this.SetMergedRegion(pageIndex, 30, 3, 30, 4);
            this.SetMergedRegion(pageIndex, 31, 3, 31, 4);
            this.SetMergedRegion(pageIndex, 32, 3, 32, 4);
            this.SetMergedRegion(pageIndex, 33, 3, 33, 4);
            this.SetMergedRegion(pageIndex, 34, 3, 34, 4);
            this.SetMergedRegion(pageIndex, 35, 3, 35, 4);
            this.SetMergedRegion(pageIndex, 36, 3, 36, 4);


            this.SetMergedRegion(pageIndex, 7, 5, 7, 7);
            this.SetMergedRegion(pageIndex, 8, 5, 8, 7);
            this.SetMergedRegion(pageIndex, 9, 5, 9, 7);
            this.SetMergedRegion(pageIndex, 10, 5, 10, 7);
            this.SetMergedRegion(pageIndex, 11, 5, 11, 7);
            this.SetMergedRegion(pageIndex, 12, 5, 12, 7);
            this.SetMergedRegion(pageIndex, 13, 5, 13, 7);
            this.SetMergedRegion(pageIndex, 14, 5, 14, 7);
            this.SetMergedRegion(pageIndex, 15, 5, 15, 7);
            this.SetMergedRegion(pageIndex, 16, 5, 16, 7);
            this.SetMergedRegion(pageIndex, 17, 5, 17, 7);
            this.SetMergedRegion(pageIndex, 18, 5, 18, 7);
            this.SetMergedRegion(pageIndex, 19, 5, 19, 7);
            this.SetMergedRegion(pageIndex, 20, 5, 20, 7);
            this.SetMergedRegion(pageIndex, 21, 5, 21, 7);
            this.SetMergedRegion(pageIndex, 22, 5, 22, 7);
            this.SetMergedRegion(pageIndex, 23, 5, 23, 7);
            this.SetMergedRegion(pageIndex, 24, 5, 24, 7);
            this.SetMergedRegion(pageIndex, 25, 5, 25, 7);
            this.SetMergedRegion(pageIndex, 26, 5, 26, 7);
            this.SetMergedRegion(pageIndex, 27, 5, 27, 7);
            this.SetMergedRegion(pageIndex, 28, 5, 28, 7);
            this.SetMergedRegion(pageIndex, 29, 5, 29, 7);
            this.SetMergedRegion(pageIndex, 30, 5, 30, 7);
            this.SetMergedRegion(pageIndex, 31, 5, 31, 7);
            this.SetMergedRegion(pageIndex, 32, 5, 32, 7);
            this.SetMergedRegion(pageIndex, 33, 5, 33, 7);
            this.SetMergedRegion(pageIndex, 34, 5, 34, 7);
            this.SetMergedRegion(pageIndex, 35, 5, 35, 7);
            this.SetMergedRegion(pageIndex, 36, 5, 36, 7);


            this.SetMergedRegion(pageIndex, 7, 8, 7, 9);
            this.SetMergedRegion(pageIndex, 8, 8, 8, 9);
            this.SetMergedRegion(pageIndex, 9, 8, 9, 9);
            this.SetMergedRegion(pageIndex, 10, 8, 10, 9);
            this.SetMergedRegion(pageIndex, 11, 8, 11, 9);
            this.SetMergedRegion(pageIndex, 12, 8, 12, 9);
            this.SetMergedRegion(pageIndex, 13, 8, 13, 9);
            this.SetMergedRegion(pageIndex, 14, 8, 14, 9);
            this.SetMergedRegion(pageIndex, 15, 8, 15, 9);
            this.SetMergedRegion(pageIndex, 16, 8, 16, 9);
            this.SetMergedRegion(pageIndex, 17, 8, 17, 9);
            this.SetMergedRegion(pageIndex, 18, 8, 18, 9);
            this.SetMergedRegion(pageIndex, 19, 8, 19, 9);
            this.SetMergedRegion(pageIndex, 20, 8, 20, 9);
            this.SetMergedRegion(pageIndex, 21, 8, 21, 9);
            this.SetMergedRegion(pageIndex, 22, 8, 22, 9);
            this.SetMergedRegion(pageIndex, 23, 8, 23, 9);
            this.SetMergedRegion(pageIndex, 24, 8, 24, 9);
            this.SetMergedRegion(pageIndex, 25, 8, 25, 9);
            this.SetMergedRegion(pageIndex, 26, 8, 26, 9);
            this.SetMergedRegion(pageIndex, 27, 8, 27, 9);
            this.SetMergedRegion(pageIndex, 28, 8, 28, 9);
            this.SetMergedRegion(pageIndex, 29, 8, 29, 9);
            this.SetMergedRegion(pageIndex, 30, 8, 30, 9);
            this.SetMergedRegion(pageIndex, 31, 8, 31, 9);
            this.SetMergedRegion(pageIndex, 32, 8, 32, 9);
            this.SetMergedRegion(pageIndex, 33, 8, 33, 9);
            this.SetMergedRegion(pageIndex, 34, 8, 34, 9);
            this.SetMergedRegion(pageIndex, 35, 8, 35, 9);
            this.SetMergedRegion(pageIndex, 36, 8, 36, 9);

            this.CopyCell(pageIndex, 37, 0, "A38");
            this.CopyCell(pageIndex, 37, 5, "E38");
            this.CopyCell(pageIndex, 37, 9, "I38");
            
            //this.CopyCell(pageIndex, 50, 1, "B51");
            //this.CopyCell(pageIndex, 50, 5, "F51");
            //this.CopyCell(pageIndex, 50, 9, "J51");
            //this.CopyCell(pageIndex, 51, 0, "A52");
           // this.SetMergedRegion(pageIndex,7, 4, 35, 6);
        }


    }
}
