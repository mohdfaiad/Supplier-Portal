/// <summary>
/// Summary description for SCMSupplierPlantController
/// </summary>

using com.Sconit.Entity.Exception;

namespace com.Sconit.Web.Controllers.SCM
{
    using System.Collections;
    using System.Collections.Generic;
    using System.Linq;
    using System.Web.Mvc;
    using System.Web.Routing;
    using System.Web.Security;
    using com.Sconit.Entity.MD;
    using com.Sconit.Entity.SYS;
    using com.Sconit.Service;
    using com.Sconit.Web.Models;
    using com.Sconit.Web.Models.SearchModels.MD;
    using com.Sconit.Web.Util;
    using Telerik.Web.Mvc;
    using System;
    using com.Sconit.Entity.SCM;

    /// <summary>
    /// This controller response to control the SCMSupplierPlant.
    /// </summary>
    public class SCMSupplierPlantController : WebAppBaseController
    {
        /// <summary>
        /// Hql for SCMSupplierPlant
        /// </summary>
        private static string selectCountStatement = "select count(*) from SCMSupplierPlant as u";

        /// <summary>
        /// Hql for SCMSupplierPlant
        /// </summary>
        private static string selectStatement = "select u from SCMSupplierPlant as u";

        /// <summary>
        /// Hql for SCMSupplierPlant
        /// </summary>
        private static string duiplicateVerifyStatement = @"select count(*) from SCMSupplierPlant as u where u.Code = ?";

 
        #region SCMSupplierPlant
        /// <summary>
        /// Index action for SCMSupplierPlant controller
        /// </summary>
        /// <returns>rediret view</returns>
        [SconitAuthorize(Permissions = "Url_SCMSupplierPlant_View")]
        public ActionResult Index()
        {
            return View();
        }

        /// <summary>
        /// Search action
        /// </summary>
        /// <returns>rediret view</returns>
        //[SconitAuthorize(Permissions = "Url_SCMSupplierPlant_View")]
        //public ActionResult _Search()
        //{
        //    return PartialView();
        //}

        /// <summary>
        /// List action
        /// </summary>
        /// <param name="command">Telerik GridCommand</param>
        /// <param name="searchModel">SCMSupplierPlant Search Model</param>
        /// <returns>return to the result view</returns>
        [GridAction]
        [SconitAuthorize(Permissions = "Url_SCMSupplierPlant_View")]
        public ActionResult List(GridCommand command, SCMSupplierPlantSearchModel searchModel)
        {
            SearchCacheModel searchCacheModel = this.ProcessSearchModel(command, searchModel);
            ViewBag.PageSize = base.ProcessPageSize(command.PageSize);
            return View();
        }

        /// <summary>
        /// AjaxList action
        /// </summary>
        /// <param name="command">GridCommand Telerik</param>
        /// <param name="searchModel">SCMSupplierPlant Search Model</param>
        /// <returns>return to the result view</returns>
        [GridAction(EnableCustomBinding = true)]
        [SconitAuthorize(Permissions = "Url_SCMSupplierPlant_View")]
        public ActionResult _AjaxList(GridCommand command, SCMSupplierPlantSearchModel searchModel)
        {
            SearchStatementModel searchStatementModel = this.PrepareSearchStatement(command, searchModel);
            return PartialView(GetAjaxPageData<SCMSupplierPlant>(searchStatementModel, command));
        }

        /// <summary>
        /// New action
        /// </summary>
        /// <returns>rediret view</returns>
        [SconitAuthorize(Permissions = "Url_SCMSupplierPlant_Edit")]
        public ActionResult New()
        {
            return View();
        }

        /// <summary>
        /// New action
        /// </summary>
        /// <param name="SCMSupplierPlant">SCMSupplierPlant model</param>
        /// <returns>return to _edit view</returns>
        [HttpPost]
        [SconitAuthorize(Permissions = "Url_SCMSupplierPlant_Edit")]
        public ActionResult New(SCMSupplierPlant SCMSupplierPlant)
        {
            if (ModelState.IsValid)
            {
                if (base.genericMgr.FindAll<long>(duiplicateVerifyStatement, new object[] { SCMSupplierPlant.Code })[0] > 0)
                {
                    SaveErrorMessage(Resources.ErrorMessage.Errors_Existing_Code, SCMSupplierPlant.Code);
                }
                else
                {
                    base.genericMgr.Create(SCMSupplierPlant);
                    SaveSuccessMessage(Resources.SCM.SCMSupplierPlant.SCMSupplierPlant_Added);
                    return RedirectToAction("_Edit/" + SCMSupplierPlant.Code);
                }
            }

            return View(SCMSupplierPlant);
        }

        /// <summary>
        /// _edit action
        /// </summary>
        /// <param name="id">SCMSupplierPlant id for edit</param>
        /// <returns>return to the result view</returns>
        [HttpGet]
        [SconitAuthorize(Permissions = "Url_SCMSupplierPlant_Edit")]
        public ActionResult _Edit(string id)
        {
            if (string.IsNullOrEmpty(id))
            {
                return HttpNotFound();
            }
            else
            {
                SCMSupplierPlant SCMSupplierPlant = base.genericMgr.FindById<SCMSupplierPlant>(id);
                return PartialView(SCMSupplierPlant);
            }

        }

        /// <summary>
        /// _edit action
        /// </summary>
        /// <param name="SCMSupplierPlant">SCMSupplierPlant for edit</param>
        /// <returns>return to the result view</returns>
        [HttpPost]
        [SconitAuthorize(Permissions = "Url_SCMSupplierPlant_Edit")]
        public ActionResult _Edit(SCMSupplierPlant SCMSupplierPlant)
        {
            try
            {
                base.genericMgr.Update(SCMSupplierPlant);
                SaveSuccessMessage(Resources.SCM.SCMSupplierPlant.SCMSupplierPlant_Updated);
                return RedirectToAction("List");
            }
            catch (BusinessException ex)
            {
                SaveBusinessExceptionMessage(ex);
            }
            catch (Exception ex)
            {
                SaveErrorMessage(ex);
            }
            return RedirectToAction("_Edit/" + SCMSupplierPlant.Code);
        }

        /// <summary>
        /// delete action
        /// </summary>
        /// <param name="id">SCMSupplierPlant id for delete</param>
        /// <returns>return to list action</returns>
        [SconitAuthorize(Permissions = "Url_SCMSupplierPlant_Delete")]
        public ActionResult Delete(string Code)
        {
            try
            {
                base.genericMgr.DeleteById<SCMSupplierPlant>(Code);
                SaveSuccessMessage(Resources.SCM.SCMSupplierPlant.SCMSupplierPlant_Deleted);
                return RedirectToAction("List");
            }
            catch (Exception)
            {
                SaveErrorMessage(Resources.SCM.SCMSupplierPlant.SCMSupplierPlant_DeletedError);
                return RedirectToAction("_Edit/" + Code);
            }

        }
        #endregion

        #region SCMSupplierPlantConvert
        /// <summary>
        /// _SCMSupplierPlantConvert action
        /// </summary>
        /// <returns>rediret view</returns>
        [SconitAuthorize(Permissions = "Url_SCMSupplierPlant_View")]
        public ActionResult _SCMSupplierPlantConvert()
        {
            return PartialView();
        }

 


        /// <summary>
        /// _SCMSupplierPlantConvertNew action
        /// </summary>
        /// <returns>rediret action</returns>
        [SconitAuthorize(Permissions = "Url_SCMSupplierPlant_Edit")]
        public ActionResult _SCMSupplierPlantConvertNew()
        {
            return PartialView();
        }



        #endregion

        /// <summary>
        /// Search Statement
        /// </summary>
        /// <param name="command">GridCommand Telerik</param>
        /// <param name="searchModel">SCMSupplierPlant Search Model</param>
        /// <returns>Search Statement</returns>
        private SearchStatementModel PrepareSearchStatement(GridCommand command, SCMSupplierPlantSearchModel searchModel)
        {
            string whereStatement = string.Empty;
            IList<object> param = new List<object>();
            HqlStatementHelper.AddLikeStatement("Code", searchModel.Code, HqlStatementHelper.LikeMatchMode.Start, "u", ref whereStatement, param);
            HqlStatementHelper.AddLikeStatement("Description", searchModel.Description, HqlStatementHelper.LikeMatchMode.Start, "u", ref whereStatement, param);
            string sortingStatement = HqlStatementHelper.GetSortingStatement(command.SortDescriptors);

            SearchStatementModel searchStatementModel = new SearchStatementModel();
            searchStatementModel.SelectCountStatement = selectCountStatement;
            searchStatementModel.SelectStatement = selectStatement;
            searchStatementModel.WhereStatement = whereStatement;
            searchStatementModel.SortingStatement = sortingStatement;
            searchStatementModel.Parameters = param.ToArray<object>();

            return searchStatementModel;
        }
    }
}
