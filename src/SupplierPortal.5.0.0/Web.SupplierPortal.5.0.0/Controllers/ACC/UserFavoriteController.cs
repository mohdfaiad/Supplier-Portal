﻿/// <summary>
/// Summary description for AddressController
/// </summary>
namespace com.Sconit.Web.Controllers.ACC
{
    using System.Collections;
    using System.Collections.Generic;
    using System.Linq;
    using System.Web.Mvc;
    using System.Web.Routing;
    using System.Web.Security;
    using com.Sconit.Entity.ACC;
    using com.Sconit.Entity.SYS;
    using com.Sconit.Service;
    using com.Sconit.Web.Models;
    using com.Sconit.Web.Util;
    using Telerik.Web.Mvc;
    using System.Text.RegularExpressions;
    using com.Sconit.Entity.Exception;
    using NHibernate.Type;
    using NHibernate;
    using System;

    /// <summary>
    /// This controller response to control the UserFavorite.
    /// </summary>
    public class UserFavoriteController : WebAppBaseController
    {
        /// <summary>
        /// Index action for UserFavorite controller
        /// </summary>
        /// <returns>rediret view</returns>
        [SconitAuthorize(Permissions = "Url_UserFav_View")]
        public ActionResult Index()
        {
            int? id = CurrentUser.Id;
            if (!id.HasValue)
            {
                return HttpNotFound();
            }
            else
            {
                User user = base.genericMgr.FindById<User>(id);
                user.NewPassword = user.Password;
                user.ConfirmPassword = user.Password;
                return View(user);
            }
        }

        /// <summary>
        /// Edit action
        /// </summary>
        /// <param name="user">user model</param>
        /// <returns>return to the result view</returns>
        [HttpPost]
        [SconitAuthorize(Permissions = "Url_UserFav_Edit")]
        public ActionResult Edit(User user)
        {
            if (ModelState.IsValid)
            {
                user.IsActive = true;
                base.genericMgr.Update(user);
                SaveSuccessMessage(Resources.ACC.User.User_Updated);
            }

            return new RedirectToRouteResult(new RouteValueDictionary  
                                                   { 
                                                       { "action", "Index" }, 
                                                       { "controller", "UserFavorite" },
                                                       { "id", user.Id }
                                                   });
        }

        /// <summary>
        /// ChangePassword action 
        /// </summary>
        /// <returns>rediret view</returns>
        [SconitAuthorize(Permissions = "Url_UserFav_Edit")]
        public ActionResult ChangePassword()
        {
            return View();
        }

        /// <summary>
        /// ChangePassword action
        /// </summary>
        /// <param name="model">Change Password Model</param>
        /// <returns>return to the result view</returns>
        [HttpPost]
        [SconitAuthorize(Permissions = "Url_UserFav_Edit")]
        public ActionResult ChangePassword(ChangePasswordModel model)
        {
            if (ModelState.IsValid)
            {
                Regex r = new Regex("^(?:(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])|(?=.*[A-Z])(?=.*[a-z])(?=.*[^A-Za-z0-9])|(?=.*[A-Z])(?=.*[0-9])(?=.*[^A-Za-z0-9])|(?=.*[a-z])(?=.*[0-9])(?=.*[^A-Za-z0-9])).{6,}|(?:(?=.*[A-Z])(?=.*[a-z])|(?=.*[A-Z])(?=.*[0-9])|(?=.*[A-Z])(?=.*[^A-Za-z0-9])|(?=.*[a-z])(?=.*[0-9])|(?=.*[a-z])(?=.*[^A-Za-z0-9])|(?=.*[0-9])(?=.*[^A-Za-z0-9])|).{8,}");

                if (!r.IsMatch(model.ConfirmPassword))
                {
                    BusinessException ex = new BusinessException();
                    ex.AddMessage(Resources.ACC.User.User_Regex);
                    SaveBusinessExceptionMessage(ex);
                }
                else
                {
                    //CurrentUser.Password = FormsAuthentication.HashPasswordForStoringInConfigFile(model.ConfirmPassword, "MD5");
                    //CurrentUser.IsActive = true;
                    //base.genericMgr.Update(CurrentUser);
                    //SaveSuccessMessage(Resources.ACC.User.User_PasswordChanged);

                    try
                    {
                        CurrentUser.Password = FormsAuthentication.HashPasswordForStoringInConfigFile(model.ConfirmPassword, "MD5");
                        this.genericMgr.UpdateWithNativeQuery("exec USP_Busi_ChangePassword ?,?",
                        new object[] { CurrentUser.Id, CurrentUser.Password },
                        new IType[] { NHibernateUtil.String, NHibernateUtil.String });
                        SaveSuccessMessage(Resources.ACC.User.User_PasswordChanged);
                    }
                    catch (Exception ex)
                    {
                        if (ex.InnerException != null)
                        {
                            if (ex.InnerException.InnerException != null)
                            {
                                SaveErrorMessage(ex.InnerException.InnerException.Message);
                            }
                            else
                            {
                                SaveErrorMessage(ex.InnerException.Message);
                            }
                        }
                        else
                        {
                            SaveErrorMessage(ex.Message);
                        }
                    }
                }
            }

            return View(model);
        }
    }
}
