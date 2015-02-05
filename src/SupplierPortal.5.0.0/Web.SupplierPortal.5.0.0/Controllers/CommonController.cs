
namespace com.Sconit.Web.Controllers
{
    using System.Collections.Generic;
    using System.Linq;
    using System.Web.Mvc;
    using AutoMapper;
    using com.Sconit.Entity.MD;
    using com.Sconit.Entity.SYS;
    using com.Sconit.Web.Models;
    using Telerik.Web.Mvc.UI;
    using System;
    using com.Sconit.Service;
    using NHibernate.Criterion;
    using NHibernate.Type;
    using NHibernate;
    using com.Sconit.Entity.ACC;
    using com.Sconit.Entity;
    using System.Web.UI.WebControls;

    public class CommonController : WebAppBaseController
    {
        //下拉框默认只选出20条
        private static int firstRow = 0;
        private static int maxRow = 20;

        private static string selectEqItemStatement = "from Item as i where i.Code = ? and IsActive = ?";

        private static string selectLikeItemStatement = "from Item as i where i.Code like ? and IsActive = ?";

        private static string selectEqUserStatement = "from User as u where u.Code = ? and u.IsActive = ?";

        private static string selectLikeUserStatement = "from User as u where u.Code like ? and u.IsActive = ?";

        private static string selectEqItemPackageStatement = "from ItemPackage as i where  convert(VARCHAR,i.UnitCount) = ?";

        private static string selectLikeItemPackageStatement = "from ItemPackage as i where i.Item=? and convert(VARCHAR,i.UnitCount) like ? ";

        private static string selectEqSupplierStatement = "from Supplier as s where s.Code = ?";

        private static string selectEqCustomerStatement = "from Customer as c where c.Code = ?";

        private static string selectEqRegionStatement = "from Region as r where r.Code = ?";

        private static string selectLikeRoutingStatement = "from RoutingMaster as r where r.Code like ? and IsActive = ?";

        private static string selectEqBomStatement = "from BomMaster as b where b.Code = ? and IsActive = ?";

        private static string selectLikeBomStatement = "from BomMaster as b where b.Code like ? and IsActive = ?";

        private static string selectSAPLocationStatement = "  select distinct top 20  SAPLocation from md_location  where SAPLocation = '{0}'";

        private static string selectLikeSAPLocationStatement = " select distinct top 20  SAPLocation from md_location  where SAPLocation like '%{0}%' ";

        private static string selectEqIssueAddressStatement = "from IssueAddress as ia where  ia.Code = ? or ia.Description = ? order by Sequence";

        private static string selectLikeIssueAddressStatement = "from IssueAddress as ia where  ia.Code like ? or ia.Description like ?  order by Sequence";

        private static string selectEqFlowStatement = "from FlowMaster as f where f.Code = ? and f.IsActive = ? ";

        private static string selectEqLocationStatement = "from Location as l where l.Code = ?";

        private static string selectEqAddressStatement = "from Address as l where l.Code = ?";

        private static string selectEqPickStrategyStatement = " from PickStrategy as w where w.Code= ? ";

        private static string selectEqPickerStatement = "select distinct top 20 Code from MD_Picker as l where l.Code = '{0}'";

        private static string selectEqShipperStatement = "select distinct top 20 Code from MD_Shipper as l where l.Code = '{0}'";

        private static string selectShiftMastersStatement = "from ShiftMaster as mss";

        private static string selectLikeShiftMasterStatement = "from ShiftMaster as s where s.Code like ? ";

        private static string selectLikeSeqGroupStatement = "from SequenceGroup as s where s.Code like ? ";

        private static string selectSuppliersByGroupStatement = "from MultiSupplySupplier as mss where mss.GroupNo = ? ";

        private static string selectEqShiftMasterStatement = "from ShiftMaster as s where s.Code = ?";


        public ActionResult _SiteMapPath(string menuContent)
        {
            //IList<com.Sconit.Entity.SYS.Menu> allMenu = systemMgr.GetAllMenu();
            //IList<MenuModel> allMenuModel = Mapper.Map<IList<com.Sconit.Entity.SYS.Menu>, IList<MenuModel>>(allMenu);

            //List<MenuModel> menuList = allMenuModel.Where(m => m.Code == menuContent).ToList();
            //this.NestGetParentMenu(menuList, menuList, allMenuModel);

            //return PartialView(menuList);
            return PartialView();
        }


        #region CodeMaster
        public ActionResult _CodeMasterDropDownList(com.Sconit.CodeMaster.CodeMaster code, string controlName, string controlId, string selectedValue, string ajaxActionName, bool? isSupplier,
            //string[] parentCascadeControlNames, string[] cascadingControlNames,
                                                    bool? includeBlankOption, string blankOptionDescription, string blankOptionValue, bool? enable, bool? isConsignment, bool? isShowNA, int? orderType)
        {
            IList<CodeDetail> codeDetailList = systemMgr.GetCodeDetails(code, includeBlankOption, blankOptionDescription, blankOptionValue);

            //IList<object> para = new List<object>();
            //para.Add(com.Sconit.CodeMaster.CodeMaster.OrderStatus);
            //para.Add((int)com.Sconit.CodeMaster.OrderStatus.Create);
            //codeDetailList = systemMgr.GetCodeDetails(code, includeBlankOption, blankOptionDescription, blankOptionValue);
            //IList<CodeDetail> codeDetail = base.genericMgr.FindAll<CodeDetail>("from CodeDetail c where c.Code  = ? and c.Value=?", para.ToArray());
            //if (codeDetail.Count > 0)
            //{
            //    codeDetailList.Remove(codeDetail[0]);
            //}
            //    if (codeDetailList != null && codeDetailList.Count > 0)
            //    {
            //        codeDetailList = codeDetailList.Where(q => q.Value != ((int)com.Sconit.CodeMaster.OrderStatus.Create).ToString()).ToList();
            //    }
            //}
            //else
            //{

            if (isSupplier != null && isSupplier.Value)
            {
                codeDetailList = codeDetailList.Where(q => q.Value != ((int)com.Sconit.CodeMaster.OrderStatus.Create).ToString()).ToList();
            }
            //base.genericMgr.FindAll<CodeDetail>("from CodeDetail c where c.code = 'OrderStatus' and c.value in ('1','2')");
            //systemMgr.GetCodeDetails(code, includeBlankOption, blankOptionDescription, blankOptionValue);
            //采购路线中的结算方式 不显示寄售结算  
            if (isConsignment != null)
            {
                if (code == com.Sconit.CodeMaster.CodeMaster.BillTerm)
                {
                    if ((bool)isConsignment)
                    {
                        // codeDetailList = base.genericMgr.FindAll<CodeDetail>("from CodeDetail c where c.Description in ('" + "CodeDetail_BillTerm_BAC" + "','" + "CodeDetail_BillTerm_NA" + "','" + "CodeDetail_BillTerm_BAR" + "') order by c.Sequence");
                        codeDetailList = codeDetailList.Where(p => p.Value == ((int)com.Sconit.CodeMaster.OrderBillTerm.ConsignmentBilling).ToString() || p.Value == ((int)com.Sconit.CodeMaster.OrderBillTerm.NA).ToString() || p.Value == ((int)com.Sconit.CodeMaster.OrderBillTerm.ReceivingSettlement).ToString()).ToList();
                    }
                    else
                    {
                        codeDetailList = codeDetailList.Where(p => p.Value != ((int)com.Sconit.CodeMaster.OrderBillTerm.ConsignmentBilling).ToString()).ToList();
                    }
                    if (isShowNA != null)
                    {
                        if (!(bool)isShowNA)
                        {
                            codeDetailList = codeDetailList.Where(p => p.Value != ((int)com.Sconit.CodeMaster.OrderBillTerm.NA).ToString()).ToList();
                            //IList<CodeDetail> codeDetail = base.genericMgr.FindAll<CodeDetail>("from CodeDetail c where c.Description = ?", "CodeDetail_BillTerm_NA");
                            //if (codeDetail.Count > 0)
                            //{
                            //    codeDetailList.Remove(codeDetail[0]);
                            //}
                        }
                    }
                }
            }

            //收货和发货的OrderType 不显示销售和生产
            if (code == com.Sconit.CodeMaster.CodeMaster.OrderType)
            {
                //if (controlName == "GoodsReceiptOrderType" || controlName == "IpOrderType")
                //{
                //    IList<CodeDetail> codeDetail = base.genericMgr.FindAll<CodeDetail>("from CodeDetail c where c.Description = ? or c.Description=?",
                //        new object[] { "CodeDetail_OrderType_Distribution", "CodeDetail_OrderType_Production" });
                //    if (codeDetail.Count > 0)
                //    {
                //        for (int i = 0; i < codeDetail.Count; i++)
                //        {
                //            codeDetailList.Remove(codeDetail[i]);
                //        }
                //    }
                //}
                if (orderType != null)
                {
                    codeDetailList = systemMgr.GetCodeDetails(code);
                    if (orderType.Value == (int)com.Sconit.CodeMaster.OrderType.Production)
                    {
                        codeDetailList = codeDetailList.Where(p => p.Value == ((int)com.Sconit.CodeMaster.OrderType.Production).ToString()).ToList();
                        //   base.genericMgr.FindAll<CodeDetail>("from CodeDetail as c where c.Code = ? and c.Value = ?", new object[] { com.Sconit.CodeMaster.CodeMaster.OrderType.ToString(), (int)com.Sconit.CodeMaster.OrderType.Production });
                    }
                    if (orderType.Value == (int)com.Sconit.CodeMaster.OrderType.Procurement)
                    {
                        if (isSupplier != null && isSupplier.Value)
                        {
                            codeDetailList = codeDetailList.Where(p => p.Value == ((int)com.Sconit.CodeMaster.OrderType.Procurement).ToString() || p.Value == ((int)com.Sconit.CodeMaster.OrderType.CustomerGoods).ToString() || p.Value == ((int)com.Sconit.CodeMaster.OrderType.SubContract).ToString()).ToList();
                            //base.genericMgr.FindAll<CodeDetail>("from CodeDetail as c where c.Code = ? and c.Value in (?,?,?)", new object[] { com.Sconit.CodeMaster.CodeMaster.OrderType.ToString(), (int)com.Sconit.CodeMaster.OrderType.Procurement, (int)com.Sconit.CodeMaster.OrderType.CustomerGoods, (int)com.Sconit.CodeMaster.OrderType.SubContract });
                        }
                        else
                        {
                            codeDetailList = codeDetailList.Where(p => p.Value == ((int)com.Sconit.CodeMaster.OrderType.Procurement).ToString() || p.Value == ((int)com.Sconit.CodeMaster.OrderType.CustomerGoods).ToString() || p.Value == ((int)com.Sconit.CodeMaster.OrderType.Transfer).ToString() || p.Value == ((int)com.Sconit.CodeMaster.OrderType.SubContractTransfer).ToString() || p.Value == ((int)com.Sconit.CodeMaster.OrderType.ScheduleLine).ToString()).ToList();
                            // codeDetailList = base.genericMgr.FindAll<CodeDetail>("from CodeDetail as c where c.Code = ? and c.Value in (?,?,?,?,?,?)", new object[] { com.Sconit.CodeMaster.CodeMaster.OrderType.ToString(), (int)com.Sconit.CodeMaster.OrderType.Procurement, (int)com.Sconit.CodeMaster.OrderType.SubContract, (int)com.Sconit.CodeMaster.OrderType.CustomerGoods, (int)com.Sconit.CodeMaster.OrderType.Transfer, (int)com.Sconit.CodeMaster.OrderType.SubContractTransfer, (int)com.Sconit.CodeMaster.OrderType.ScheduleLine });
                        }
                    }
                    if (orderType.Value == (int)com.Sconit.CodeMaster.OrderType.Distribution)
                    {
                        codeDetailList = codeDetailList.Where(p => p.Value == ((int)com.Sconit.CodeMaster.OrderType.Distribution).ToString() || p.Value == ((int)com.Sconit.CodeMaster.OrderType.Transfer).ToString() || p.Value == ((int)com.Sconit.CodeMaster.OrderType.SubContractTransfer).ToString()).ToList();
                        //base.genericMgr.FindAll<CodeDetail>("from CodeDetail as c where c.Code = ? and c.Value in (?,?,?)", new object[] { com.Sconit.CodeMaster.CodeMaster.OrderType.ToString(), (int)com.Sconit.CodeMaster.OrderType.Distribution, (int)com.Sconit.CodeMaster.OrderType.Transfer, (int)com.Sconit.CodeMaster.OrderType.SubContractTransfer });
                    }

                    #region empty codedetail
                    CodeDetail emptyCodeDetail = new CodeDetail();
                    emptyCodeDetail.Value = blankOptionValue;
                    emptyCodeDetail.Description = blankOptionDescription;
                    codeDetailList.Insert(0, emptyCodeDetail);
                    #endregion
                }
            }
            ViewBag.ControlName = controlName;
            ViewBag.ControlId = controlId;
            //ViewBag.SelectedValue = selectedValue;
            ViewBag.AjaxActionName = ajaxActionName;

            ViewBag.Enable = enable;
            // codeDetailList.Add(new CodeDetail());
            //ViewBag.CascadingControlNames = cascadingControlNames;
            //ViewBag.ParentCascadeControlNames = parentCascadeControlNames;
            if (code == com.Sconit.CodeMaster.CodeMaster.FlowStrategy)
            {
                codeDetailList = codeDetailList.Where(c => c.Description != "CodeDetail_FlowStrategy_NA").ToList();
            }
            return PartialView(base.Transfer2DropDownList(code, codeDetailList, selectedValue));
        }


        public ActionResult _CodeMasterComboBox(com.Sconit.CodeMaster.CodeMaster code, string controlName, string controlId, string selectedValue, bool? enable, bool? isChange
            )
        {
            ViewBag.ControlName = controlName;
            ViewBag.ControlId = controlId;
            ViewBag.Enable = enable;
            ViewBag.Code = code;
            ViewBag.isChange = isChange;
            //IList<CodeDetail> codeDetailList = new List<CodeDetail>();
            //if (selectedValue != null && selectedValue.Trim() != string.Empty)
            //{
            //    codeDetailList = base.genericMgr.FindAll<CodeDetail>("from CodeDetail as c where c.Code = ? and c.Value = ?", new object[] { code, selectedValue });
            //}
            IList<CodeDetail> codeDetailList = null;
            if (selectedValue == null || selectedValue.Trim() == string.Empty)
                codeDetailList = systemMgr.GetCodeDetails(code);
            else
                codeDetailList = systemMgr.GetCodeDetails(code).Where(p => p.Value == selectedValue).ToList();

            return PartialView(base.Transfer2DropDownList(code, codeDetailList, selectedValue));
        }

        public ActionResult _CodeMasterAjaxLoading(string text, com.Sconit.CodeMaster.CodeMaster code)
        {
            //IList<CodeDetail> codeDetailList = new List<CodeDetail>();

            //string hql = "from CodeDetail as c where c.Code = ?";
            //IList<object> paraList = new List<object>();
            //paraList.Add(code);
            //if (!string.IsNullOrEmpty(text))
            //{
            //    hql += " and c.Value like ?";
            //    paraList.Add(text + "%");
            //}
            IList<CodeDetail> codeDetailList = null;
            if (text == "")
                codeDetailList = systemMgr.GetCodeDetails(code);
            else
                codeDetailList = systemMgr.GetCodeDetails(code).Where(p => p.Value == text).ToList();
            //genericMgr.FindAll<CodeDetail>(hql, paraList.ToArray(), firstRow, maxRow);


            IList<SelectListItem> itemList = Mapper.Map<IList<CodeDetail>, IList<SelectListItem>>(codeDetailList);
            foreach (var item in itemList)
            {
                item.Text = systemMgr.TranslateCodeDetailDescription(item.Text);
            }
            return new JsonResult { Data = new SelectList(itemList, "Value", "Text") };
        }

        public ActionResult _CodeMasterMultiSelectBox(com.Sconit.CodeMaster.CodeMaster code, string controlName, string controlId, string checkedValues, bool? isProcurement)
        {
            ViewBag.ControlName = controlName;
            ViewBag.ControlId = controlId;

            IList<CodeDetail> codeDetailList = null;
            codeDetailList = systemMgr.GetCodeDetails(code);
            if (isProcurement.HasValue && isProcurement.Value)  //订单类型，直送供应商不显示
            {
                codeDetailList = codeDetailList.Where(c => (c.Description == "CodeDetail_OrderType_ScheduleLine") || (c.Description == "CodeDetail_OrderType_Transfer") || (c.Description == "CodeDetail_OrderType_Procurement")).ToList();
            }
            foreach (var codeDetail in codeDetailList)
            {
                codeDetail.ChineDescription = systemMgr.TranslateCodeDetailDescription(codeDetail.Description);
            }
            ViewBag.CodeDetails = codeDetailList;
            if (!string.IsNullOrWhiteSpace(checkedValues))
            {
                ViewBag.CheckedValues = checkedValues.Split(',').ToList();
            }
            ViewBag.CodeDetails = codeDetailList;

            return PartialView();
        }
        #endregion

        #region User
        public ActionResult _UserComboBox(string controlName, string controlId, string selectedValue, bool? enable)
        {
            ViewBag.ControlName = controlName;
            ViewBag.ControlId = controlId;
            ViewBag.Enable = enable;

            IList<User> userList = new List<User>();
            if (selectedValue != null && selectedValue.Trim() != string.Empty)
            {
                userList = base.genericMgr.FindAll<User>(selectEqUserStatement, new object[] { selectedValue, true });
            }
            return PartialView(new SelectList(userList, "Code", "CodeDescription", selectedValue));
        }

        public ActionResult _UserAjaxLoading(string text)
        {
            IList<User> userList = new List<User>();
            userList = base.genericMgr.FindAll<User>(selectLikeUserStatement, new object[] { text + "%", true }, firstRow, maxRow);
            return new JsonResult { Data = new SelectList(userList, "Code", "CodeDescription") };
        }
        #endregion

        #region Item
        public ActionResult _ItemComboBox(string controlName, string controlId, string selectedValue, bool? enable, bool? coupled)
        {
            ViewBag.ControlName = controlName;
            ViewBag.ControlId = controlId;
            ViewBag.Enable = enable;
            ViewBag.Coupled = coupled;
            IList<Item> itemList = new List<Item>();
            if (selectedValue != null && selectedValue.Trim() != string.Empty)
            {
                itemList = base.genericMgr.FindAll<Item>(selectEqItemStatement, new object[] { selectedValue, true });
            }

            //ViewBag.ItemFilterMode = base.systemMgr.GetEntityPreferenceValue(EntityPreference.CodeEnum.ItemFilterMode);
            //ViewBag.ItemFilterMinimumChars = int.Parse(base.systemMgr.GetEntityPreferenceValue(EntityPreference.CodeEnum.ItemFilterMinimumChars));
            return PartialView(new SelectList(itemList, "Code", "CodeDescription", selectedValue));
        }

        public ActionResult _ItemAjaxLoading(string text)
        {
            //AutoCompleteFilterMode fileterMode = (AutoCompleteFilterMode)Enum.Parse(typeof(AutoCompleteFilterMode), base.systemMgr.GetEntityPreferenceValue(EntityPreference.CodeEnum.ItemFilterMode), true);
            IList<Item> itemList = new List<Item>();

            //if (fileterMode == AutoCompleteFilterMode.Contains)
            //{
            //    itemList = base.genericMgr.FindAll<Item>(selectLikeItemStatement, new object[] { "%" + text + "%", true }, firstRow, maxRow);
            //}
            //else
            //{
            //    itemList = base.genericMgr.FindAll<Item>(selectLikeItemStatement, new object[] { text + "%", true }, firstRow, maxRow);
            //}

            itemList = base.genericMgr.FindAll<Item>(selectLikeItemStatement, new object[] { text + "%", true }, firstRow, maxRow);
            return new JsonResult { Data = new SelectList(itemList, "Code", "CodeDescription") };
        }


        #endregion
        #region Uom
        public ActionResult _UomDropDownList(string controlName, string controlId, string selectedValue, bool? includeBlankOption, string blankOptionDescription, string blankOptionValue, bool? enable)
        {
            ViewBag.ControlName = controlName;
            ViewBag.ControlId = controlId;
            //ViewBag.SelectedValue = selectedValue;
            ViewBag.Enable = enable;
            IList<Uom> uomList = base.genericMgr.FindAll<Uom>("from Uom as u order by u.Code desc");
            if (uomList == null)
            {
                uomList = new List<Uom>();
            }

            if (includeBlankOption.HasValue && includeBlankOption.Value)
            {
                Uom blankUom = new Uom();
                blankUom.Code = blankOptionValue;
                blankUom.Description = blankOptionDescription;

                uomList.Insert(0, blankUom);
            }
            return PartialView(new SelectList(uomList, "Code", "Code", selectedValue));
        }

        public ActionResult _AjaxLoadingUom(string text, string item)
        {
            #region 基本单位
            IList<string> uomList = new List<string>();
            if (string.IsNullOrEmpty(item))
            {
                Item baseItem = base.genericMgr.FindById<Item>(item);
                uomList.Add(baseItem.Uom);
            }
            #endregion

            #region 单位转换
            IList<UomConversion> uomConversionList = base.genericMgr.FindAll<UomConversion>("from UomConversion as u where u.Item = ?", item);
            if (uomConversionList != null && uomConversionList.Count > 0)
            {
                foreach (UomConversion uc in uomConversionList)
                {
                    if (!uomList.Contains(uc.BaseUom))
                    {
                        uomList.Add(uc.BaseUom);
                    }
                    if (!uomList.Contains(uc.AlterUom))
                    {
                        uomList.Add(uc.AlterUom);
                    }
                }
            }
            #endregion

            return new JsonResult { Data = new SelectList(uomList) };
        }


        #endregion

        #region private methods

        #endregion
    }
}
