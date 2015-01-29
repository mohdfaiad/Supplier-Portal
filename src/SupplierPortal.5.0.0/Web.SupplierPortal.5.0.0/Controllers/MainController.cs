using System.Web.Mvc;
using com.Sconit.Web.Util;
using System.Linq;
using com.Sconit.Service;
using com.Sconit.Entity.SYS;
using System.Collections.Generic;

/// <summary>
///MainController 的摘要说明
/// </summary>
namespace com.Sconit.Web.Controllers
{
    [SconitAuthorize]
    public class MainController : WebAppBaseController
    {
        public IPortalSettingMgr portalSettingMgr { get; set; }
        public MainController()
        {

        }

        public ActionResult Default()
        {
            var systemTitle = systemMgr.GetEntityPreferenceValue(Entity.SYS.EntityPreference.CodeEnum.SystemTitle);
            ViewBag.SystemTitle = systemTitle;
            //if (Request.Cookies[WebConstants.CookieMainPageUrlKey] != null && this.CurrentUser != null)
            //{
            //    string mainPage = Request.Cookies[WebConstants.CookieMainPageUrlKey].Values[this.CurrentUser.Code];
            //    if (string.IsNullOrWhiteSpace(mainPage))
            //    {
            //        ViewBag.MainPageUrl = "../UserFavorite/Index";
            //    }
            //    else
            //    {
            //        ViewBag.MainPageUrl = mainPage;
            //    }
            //}
            //else
            //{
            //    ViewBag.MainPageUrl = "../UserFavorite/Index";
            //}
            return View();
        }

        public ActionResult Top()
        {
            ViewBag.IsShowImage = true;
            var systemFlag = systemMgr.GetEntityPreferenceValue(Entity.SYS.EntityPreference.CodeEnum.SystemFlag);
            ViewBag.IsShow = systemFlag == "1";
            //IList<PortalSetting> portalSettingList = this.portalSettingMgr.GetNonePrimaryPortalSetting();
            //if (portalSettingList != null)
            //{
            //    ViewBag.SiteId = portalSettingList.First().Id;
            //    ViewBag.SiteName = portalSettingList.First().Name;
            //}
            return View();
        }

        public ActionResult Nav()
        {
            ViewBag.UserCode = this.CurrentUser.CodeDescription;
            return PartialView(base.GetAuthrizedMenuTree());
        }

        public ActionResult Switch()
        {
            return View();
        }

        public ActionResult Main()
        {
            if (Request.Cookies[WebConstants.CookieMainPageUrlKey] != null && this.CurrentUser != null)
            {
                string mainPage = Request.Cookies[WebConstants.CookieMainPageUrlKey].Values[this.CurrentUser.Code];
                if (string.IsNullOrWhiteSpace(mainPage))
                {
                    ViewBag.MainPageUrl = "~/UserFavorite/Index";
                }
                else
                {
                    if (!mainPage.StartsWith("~"))
                    {
                        mainPage = "~" + mainPage;
                    }
                    ViewBag.MainPageUrl = mainPage;
                }
            }
            else
            {
                ViewBag.MainPageUrl = "~/UserFavorite/Index";
            }
            var menu = systemMgr.GetAllMenu().Where(p => p.PageUrl != null && p.PageUrl.EndsWith(ViewBag.MainPageUrl)).First();
            ViewBag.MainPageName = menu.Description;
            //string name = Resources.Menu.ResourceManager.GetString(ViewBag.MainPageName);
            //if(name != null)
            //{
            //    ViewBag.MainPageName = name;
            //}
            if (string.IsNullOrWhiteSpace(ViewBag.MainPageName))
            {
                ViewBag.MainPageName = menu.Name;
            }
            ViewBag.MainPageCode = menu.Code;
            return View();
        }
    }
}