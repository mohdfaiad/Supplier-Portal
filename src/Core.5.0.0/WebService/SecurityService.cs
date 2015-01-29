using System.Collections.Generic;
using System.Linq;
using System.Web.Services;
using com.Sconit.Entity.ACC;
using com.Sconit.Entity.VIEW;
using com.Sconit.Service;
using com.Sconit.Entity.Exception;
using System.Web.Services.Protocols;
using System;

namespace com.Sconit.WebService
{
    [WebService(Namespace = "http://com.Sconit.WebService.SecurityService/")]
    public class SecurityService : BaseWebService
    {
        //private ISecurityMgr securityMgr
        //{
        //    get
        //    {
        //        return GetService<ISecurityMgr>();
        //    }
        //}

        [WebMethod]
        public bool VerifyUserPassword(string userCode, string password)
        {
            return securityMgr.VerifyUserPassword(userCode, password);
        }

        [WebMethod]
        public List<string> GetUserPermissionCodes(string userCode)
        {
            IList<UserPermissionView> permissionList = securityMgr.GetUserPermissions(userCode);

            if (permissionList != null && permissionList.Count > 0)
            {
                return permissionList.Select(p => p.PermissionCode).Distinct().ToList();
            }

            return null;
        }

        //webservice不支持重载方法,就算是加了MessageName,到客户端那里的方法名就变成了MessageName的方法名
        [WebMethod]
        public List<string> GetUserPermissionCodesByType(string userCode, com.Sconit.CodeMaster.PermissionCategoryType permissionType)
        {
            IList<UserPermissionView> permissionList = securityMgr.GetUserPermissions(userCode, permissionType);

            if (permissionList != null && permissionList.Count > 0)
            {
                return permissionList.Select(p => p.PermissionCode).Distinct().ToList();
            }

            return null;
        }

        [WebMethod]
        public List<string> GetUserPermissionCodesByTypes(string userCode, com.Sconit.CodeMaster.PermissionCategoryType[] permissionType)
        {
            IList<UserPermissionView> permissionList = securityMgr.GetUserPermissions(userCode, permissionType);

            if (permissionList != null && permissionList.Count > 0)
            {
                return permissionList.Select(p => p.PermissionCode).Distinct().ToList();
            }

            return null;
        }

        [WebMethod]
        public string VerifyUserPasswordAndGetUserToken(string userCode, string password)
        {
            try
            {
                if (securityMgr.VerifyUserPassword(userCode, password))
                {
                    return this.securityMgr.GenerateUserToken(userCode);
                }
                else
                {
                    return null;
                }
            }
            catch (BusinessException ex)
            {
                throw new SoapException(string.Empty, SoapException.ServerFaultCode, ex.GetMessages()[0].GetMessageString(), ex);
            }
            catch (Exception ex)
            {
                string errorMessage = string.Format("获取用户Token出现异常，异常信息：{0}。", ex.Message);
                throw new SoapException(string.Empty, SoapException.ServerFaultCode, errorMessage, ex);
            }
        }

        [WebMethod]
        public string GenerateUserToken(string userCode)
        {
            try
            {
                return this.securityMgr.GenerateUserToken(userCode);               
            }
            catch (BusinessException ex)
            {
                throw new SoapException(string.Empty, SoapException.ServerFaultCode, ex.GetMessages()[0].GetMessageString(), ex);
            }
            catch (Exception ex)
            {
                string errorMessage = string.Format("获取用户Token出现异常，异常信息：{0}。", ex.Message);
                throw new SoapException(string.Empty, SoapException.ServerFaultCode, errorMessage, ex);
            }
        }
    }
}
