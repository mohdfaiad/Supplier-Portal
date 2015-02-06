/// <summary>
/// Summary description for LocationController
/// </summary>
namespace com.Sconit.Web.Controllers.MD
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

    /// <summary>
    /// This controller response to control the Location.
    /// </summary>
    public class LocationController : WebAppBaseController
    {
        #region hql
        /// <summary>
        /// hql to get count of the location
        /// </summary>
        private static string selectCountStatement = "select count(*) from Location as u";

        /// <summary>
        /// hql to get all of the location
        /// </summary>
        private static string selectStatement = "select u from Location as u";

        /// <summary>
        /// hql to get count of the location by location's code
        /// </summary>
        private static string duiplicateVerifyStatement = @"select count(*) from Location as u where u.Code = ?";

        /// <summary>
        /// hql to get count of the LocationBin
        /// </summary>
        private static string locationBinselectCountStatement = "select count(*) from LocationBin as l";

        /// <summary>
        /// hql to get total of the LocationBin
        /// </summary>
        private static string locationBinselectStatement = "select l from LocationBin as l";

        /// <summary>
        /// hql to get count of the LocationBin by code
        /// </summary>
        private static string locationBinDuiplicateVerifyStatement = @"select count(*) from LocationBin as l where l.Code = ?";

        /// <summary>
        /// hql to get count of the locationArea 
        /// </summary>
        private static string locationAreaselectCountStatement = "select count(*) from LocationArea as l";

        /// <summary>
        /// hql to get all of the locationArea 
        /// </summary>
        private static string locationAreaselectStatement = "select l from LocationArea as l";

        /// <summary>
        /// hql to get count of the locationArea by locationArea's code
        /// </summary>
        private static string locationAreaDuiplicateVerifyStatement = @"select count(*) from LocationArea as l where l.Code = ?";

        #endregion

        #region location
        /// <summary>
        /// Index action for Location controller
        /// </summary>
        /// <returns>rediret view</returns>
        [SconitAuthorize(Permissions = "Url_Location_View")]
        public ActionResult Index()
        {
            return View();
        }

        /// <summary>
        /// List acion
        /// </summary>
        /// <param name="command">Telerik GridCommand</param>
        /// <param name="searchModel">Location Search Model</param>
        /// <returns>return to the result action</returns>
        [GridAction]
        [SconitAuthorize(Permissions = "Url_Location_View")]
        public ActionResult List(GridCommand command, LocationSearchModel searchModel)
        {

            SearchCacheModel searchCacheModel = this.ProcessSearchModel(command, searchModel);
              ViewBag.PageSize = base.ProcessPageSize(command.PageSize);
            return View();
        }

        /// <summary>
        /// AjaxList action
        /// </summary>
        /// <param name="command">Telerik GridCommand</param>
        /// <param name="searchModel">Location Search Model</param>
        /// <returns>return to the result action</returns>
        [GridAction(EnableCustomBinding = true)]
        [SconitAuthorize(Permissions = "Url_Location_View")]
        public ActionResult _AjaxList(GridCommand command, LocationSearchModel searchModel)
        {
            searchModel.IsActive = true;
            if (searchModel.IsIncludeInActive)
            {
                searchModel.IsActive = false;
            }
            SearchStatementModel searchStatementModel = this.PrepareSearchStatement(command, searchModel);
            return PartialView(GetAjaxPageData<Location>(searchStatementModel, command));
        }

        /// <summary>
        /// New action
        /// </summary>
        /// <returns>rediret view</returns>
        [SconitAuthorize(Permissions = "Url_Location_Edit")]
        public ActionResult New()
        {
            return View();
        }

        /// <summary>
        /// New action
        /// </summary>
        /// <param name="location">loction model</param>
        /// <returns>return to edit view</returns>
        [HttpPost]
        [SconitAuthorize(Permissions = "Url_Location_Edit")]
        public ActionResult New(Location location)
        {
            if (ModelState.IsValid)
            {
                if (base.genericMgr.FindAll<long>(duiplicateVerifyStatement, new object[] { location.Code })[0] > 0)
                {
                    SaveErrorMessage(Resources.ErrorMessage.Errors_Existing_Code, location.Code);
                }
                else
                {
                    base.genericMgr.Create(location);
                    SaveSuccessMessage(Resources.MD.Location.Location_Added);
                    return RedirectToAction("Edit/" + location.Code);
                }
            }

            return View(location);
        }

        /// <summary>
        /// Edit action
        /// </summary>
        /// <param name="id">location id for edit</param>
        /// <returns>return to edit view</returns>
        [HttpGet]
        [SconitAuthorize(Permissions = "Url_Location_Edit")]
        public ActionResult Edit(string id)
        {
            if (string.IsNullOrEmpty(id))
            {
                return HttpNotFound();
            }
            else
            {
                Location location = base.genericMgr.FindById<Location>(id);
                return View(location);
            }
        }


        /// <summary>
        /// Edit action
        /// </summary>
        /// <param name="location">location model</param>
        /// <returns>return to edit action</returns>
        [HttpPost]
        [SconitAuthorize(Permissions = "Url_Location_Edit")]
        public ActionResult Edit(Location location)
        {
            if (ModelState.IsValid)
            {
                base.genericMgr.Update(location);
                SaveSuccessMessage(Resources.MD.Location.Location_Updated);
            }

            return View(location);
        }

        /// <summary>
        /// Delete action
        /// </summary>
        /// <param name="id">loction id for delete</param>
        /// <returns>return to list action</returns>
        [SconitAuthorize(Permissions = "Url_Location_Delete")]
        public ActionResult Delete(string id)
        {
            if (string.IsNullOrEmpty(id))
            {
                return HttpNotFound();
            }
            else
            {
                base.genericMgr.DeleteById<Location>(id);
                SaveSuccessMessage(Resources.MD.Location.Location_Deleted);
                return RedirectToAction("List");
            }
        }
        #endregion

        /// <summary>
        /// Search Statement
        /// </summary>
        /// <param name="command">Telerik GridCommand</param>
        /// <param name="searchModel">LocationBin Search Model</param>
        /// <param name="locationCode">location Code</param>
        /// <returns>Search Statement</returns>
        private SearchStatementModel LocationBinPrepareSearchStatement(GridCommand command, LocationBinSearchModel searchModel, string locationCode)
        {
            string whereStatement = "where l.Location = '" + locationCode + "'";

            IList<object> param = new List<object>();

            HqlStatementHelper.AddLikeStatement("Code", searchModel.Code, HqlStatementHelper.LikeMatchMode.Start, "l", ref whereStatement, param);
            HqlStatementHelper.AddLikeStatement("Name", searchModel.Name, HqlStatementHelper.LikeMatchMode.Start, "l", ref whereStatement, param);
            HqlStatementHelper.AddEqStatement("Area", searchModel.Area, "l", ref whereStatement, param);
            string sortingStatement = HqlStatementHelper.GetSortingStatement(command.SortDescriptors);

            SearchStatementModel searchStatementModel = new SearchStatementModel();
            searchStatementModel.SelectCountStatement = locationBinselectCountStatement;
            searchStatementModel.SelectStatement = locationBinselectStatement;
            searchStatementModel.WhereStatement = whereStatement;
            searchStatementModel.SortingStatement = sortingStatement;
            searchStatementModel.Parameters = param.ToArray<object>();

            return searchStatementModel;
        }

        /// <summary>
        /// Search Statement
        /// </summary>
        /// <param name="command">Telerik GridCommand</param>
        /// <param name="searchModel">LocationArea Search Model</param>
        /// <param name="locationCode">location Code</param>
        /// <returns>Search Statement</returns>
        private SearchStatementModel LocationAreaPrepareSearchStatement(GridCommand command, LocationAreaSearchModel searchModel, string locationCode)
        {
            string whereLocationStatement = "where l.Location = '" + locationCode + "'";
            IList<object> param = new List<object>();
            HqlStatementHelper.AddLikeStatement("Code", searchModel.Code, HqlStatementHelper.LikeMatchMode.Start, "l", ref whereLocationStatement, param);
            HqlStatementHelper.AddLikeStatement("Name", searchModel.Name, HqlStatementHelper.LikeMatchMode.Start, "l", ref whereLocationStatement, param);
            string sortingStatement = HqlStatementHelper.GetSortingStatement(command.SortDescriptors);
            SearchStatementModel searchStatementModel = new SearchStatementModel();
            searchStatementModel.SelectCountStatement = locationAreaselectCountStatement;
            searchStatementModel.SelectStatement = locationAreaselectStatement;
            searchStatementModel.WhereStatement = whereLocationStatement;
            searchStatementModel.SortingStatement = sortingStatement;
            searchStatementModel.Parameters = param.ToArray<object>();
            return searchStatementModel;
        }

        /// <summary>
        /// Search Statement
        /// </summary>
        /// <param name="command">Telerik GridCommand</param>
        /// <param name="searchModel">Location Search Model</param>
        /// <returns>Search Statement</returns>
        private SearchStatementModel PrepareSearchStatement(GridCommand command, LocationSearchModel searchModel)
        {
            string whereStatement = string.Empty;

            IList<object> param = new List<object>();
            HqlStatementHelper.AddLikeStatement("SAPLocation", searchModel.SAPLocation, HqlStatementHelper.LikeMatchMode.Start, "u", ref whereStatement, param);
            HqlStatementHelper.AddLikeStatement("Code", searchModel.Code, HqlStatementHelper.LikeMatchMode.Start, "u", ref whereStatement, param);
            HqlStatementHelper.AddLikeStatement("Name", searchModel.Name, HqlStatementHelper.LikeMatchMode.Start, "u", ref whereStatement, param);
            HqlStatementHelper.AddEqStatement("Region", searchModel.Region, "u", ref whereStatement, param);
            HqlStatementHelper.AddEqStatement("IsActive", searchModel.IsActive, "u", ref whereStatement, param);
            if (searchModel.AllowNegaInv)
            {
                HqlStatementHelper.AddEqStatement("AllowNegative", searchModel.AllowNegaInv, "u", ref whereStatement, param);
            }

            if (searchModel.IsMRP)
            {
                HqlStatementHelper.AddEqStatement("IsMRP", searchModel.IsMRP, "u", ref whereStatement, param);
            }
            if (searchModel.AllowNegativeConsignment)
            {
                HqlStatementHelper.AddEqStatement("AllowNegativeConsignment", searchModel.AllowNegativeConsignment, "u", ref whereStatement, param);
            }
            if (searchModel.IsSource)
            {
                HqlStatementHelper.AddEqStatement("IsSource", searchModel.IsSource, "u", ref whereStatement, param);
            }

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
