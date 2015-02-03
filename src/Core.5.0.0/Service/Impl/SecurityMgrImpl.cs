﻿using System;
using System.Collections.Generic;
using System.Linq;
using Castle.Services.Transaction;
using com.Sconit.Entity.ACC;
using com.Sconit.Entity.VIEW;
using com.Sconit.Utility;
using NHibernate.Criterion;
using System.DirectoryServices;
using com.Sconit.Entity.Exception;

namespace com.Sconit.Service.Impl
{
    [Transactional]
    public class SecurityMgrImpl : BaseMgr, ISecurityMgr
    {
        #region public proerty
        public string Domain { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public IGenericMgr genericMgr { get; set; }
        #endregion

        #region private property
        /// <summary>
        /// 
        /// </summary>
        private static string selectUserRoleByUserId = "select ur from UserRole as ur where ur.User.Id = ?";

        /// <summary>
        /// 
        /// </summary>
        private static string selectUserPermissionGroupByUserId = "select up from UserPermissionGroup as up where up.User.Id = ?";

        /// <summary>
        ///         
        /// </summary>
        private static string selectUserPermissionByUserId = @"select up from UserPermission as up 
                                                              join up.Permission as p
                                                              where up.User.Id = ? and p.PermissionCategory = ?";

        /// <summary>
        /// 
        /// </summary>
        private static string selectUserRoleByRoleId = "select ur from UserRole as ur where ur.Role.Id = ?";

        /// <summary>
        /// 
        /// </summary>
        private static string selectRolePermissionGroupByRoleId = "select rpg from RolePermissionGroup as rpg where rpg.Role.Id = ?";

        /// <summary>
        ///         
        /// </summary>
        private static string selectRolePermissionByRoleId = @"select rp from RolePermission as rp 
                                                              join rp.Permission as p
                                                              where rp.Role.Id = ? and p.PermissionCategory = ?";

        /// <summary>
        /// 
        /// </summary>
        private static string selectUserPermissionGroupByPermissionGroupId = "select ur from UserPermissionGroup as ur where ur.PermissionGroup.Id = ?";

        /// <summary>
        /// 
        /// </summary>
        private static string selectRolePermissionGroupByPermissionGroupId = "select rpg from RolePermissionGroup as rpg where rpg.PermissionGroup.Id = ?";

        /// <summary>
        ///         
        /// </summary>
        private static string selectPermissionGroupPermissionByPermissionGroupId = @"select pgp from PermissionGroupPermission as pgp 
                                                                                  join pgp.Permission as p
                                                                                  where pgp. PermissionGroup.Id = ? and p.PermissionCategory = ?";
        #endregion

        #region public method
        public User GetUser(string userCode)
        {
            string hql = "from User where Code = ?";
            IList<User> users = genericMgr.FindAll<User>(hql, userCode);

            if (users != null && users.Count > 0)
            {
                return users[0];
            }
            else
            {
                return null;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="userCode"></param>
        /// <returns></returns>
        public User GetUserWithPermissions(string userCode)
        {
            User user = GetUser(userCode);
            if (user != null)
            {
                user.Permissions = GetUserPermission(user);
                return user;
            }
            else
            {
                return null;
            }
        }

        public IList<UserPermissionView> GetUserPermissions(string userCode)
        {
            User user = GetUser(userCode);
            if (user != null)
            {
                return GetUserPermission(user);
            }
            else
            {
                return null;
            }
        }

        public IList<UserPermissionView> GetUserPermissions(string userCode, com.Sconit.CodeMaster.PermissionCategoryType categoryType)
        {
            User user = GetUser(userCode);
            if (user != null)
            {
                IList<UserPermissionView> permissionList = GetUserPermission(user);

                if (permissionList != null)
                {
                    return permissionList.Where(p => p.PermissionCategoryType == categoryType).ToList();
                }
                else
                {
                    return null;
                }
            }
            else
            {
                return null;
            }
        }

        public IList<UserPermissionView> GetUserPermissions(string userCode, com.Sconit.CodeMaster.PermissionCategoryType[] categoryTypes)
        {
            User user = GetUser(userCode);
            if (user != null)
            {
                IList<UserPermissionView> permissionList = GetUserPermission(user);

                if (permissionList != null)
                {
                    return permissionList.Where(p => categoryTypes.Contains(p.PermissionCategoryType)).ToList();
                }
                else
                {
                    return null;
                }
            }
            else
            {
                return null;
            }
        }

        #region 用户授权
        /// <summary>
        /// 
        /// </summary>
        /// <param name="userId"></param>
        /// <param name="assignedRoleIdList"></param>
        [Transaction(TransactionMode.Requires)]
        public void UpdateUserRoles(int userId, IList<int> assignedRoleIdList)
        {
            IList<Role> assignedRoleList = new List<Role>();

            if (assignedRoleIdList != null && assignedRoleIdList.Count > 0)
            {
                assignedRoleList = (from roleId in assignedRoleIdList
                                    select new Role
                                    {
                                        Id = roleId
                                    }).ToList();
            }

            IList<UserRole> oldAssingedUserRoleList = this.genericMgr.FindAll<UserRole>(selectUserRoleByUserId, userId);
            IList<Role> oldAssingedRoleList = new List<Role>();

            if (oldAssingedUserRoleList != null && oldAssingedUserRoleList.Count > 0)
            {
                oldAssingedRoleList = (from ur in oldAssingedUserRoleList
                                       select new Role
                                       {
                                           Id = ur.Role.Id
                                       }).ToList();
            }

            #region 删除没有授权的角色
            IList<Role> deleteRoleList = oldAssingedRoleList.Except<Role>(assignedRoleList).ToList();
            if (deleteRoleList.Count > 0)
            {
                foreach (Role role in deleteRoleList)
                {
                    UserRole deletingUserRole = oldAssingedUserRoleList.Where(ur => ur.Role.Id == role.Id).SingleOrDefault();
                    if (deletingUserRole != null)
                    {
                        this.genericMgr.Delete(deletingUserRole);
                    }
                }
            }
            #endregion

            #region 保存新增授权的角色
            IList<Role> insertingRoleList = assignedRoleList.Except<Role>(oldAssingedRoleList).ToList();
            if (insertingRoleList.Count > 0)
            {
                IList<UserRole> insertingUserRoleList = (from role in insertingRoleList
                                                         select new UserRole
                                                         {
                                                             User = new User(userId),
                                                             Role = role
                                                         }).ToList();

                foreach (UserRole userRole in insertingUserRoleList)
                {
                    this.genericMgr.Create(userRole);
                }
            }
            #endregion
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="userId"></param>
        /// <param name="assignedPermissionGroupIdList"></param>
        [Transaction(TransactionMode.Requires)]
        public void UpdateUserPermissionGroups(int userId, IList<int> assignedPermissionGroupIdList)
        {
            IList<PermissionGroup> assignedPermissionGroupList = new List<PermissionGroup>();

            if (assignedPermissionGroupIdList != null && assignedPermissionGroupIdList.Count > 0)
            {
                assignedPermissionGroupList = (from gpId in assignedPermissionGroupIdList
                                               select new PermissionGroup
                                               {
                                                   Id = gpId
                                               }).ToList();
            }

            IList<UserPermissionGroup> oldAssingedUserPermissionGroupList = this.genericMgr.FindAll<UserPermissionGroup>(selectUserPermissionGroupByUserId, userId);
            IList<PermissionGroup> oldAssingedPermissionGroupList = new List<PermissionGroup>();

            if (oldAssingedUserPermissionGroupList != null && oldAssingedUserPermissionGroupList.Count > 0)
            {
                oldAssingedPermissionGroupList = (from up in oldAssingedUserPermissionGroupList
                                                  select new PermissionGroup
                                                  {
                                                      Id = up.PermissionGroup.Id
                                                  }).ToList();
            }

            #region 删除没有授权的权限组
            IList<PermissionGroup> deletePermissionGroupList = oldAssingedPermissionGroupList.Except<PermissionGroup>(assignedPermissionGroupList).ToList();
            if (deletePermissionGroupList.Count > 0)
            {
                foreach (PermissionGroup permissionGroup in deletePermissionGroupList)
                {
                    UserPermissionGroup deletingUserPermissionGroup = oldAssingedUserPermissionGroupList.Where(up => up.PermissionGroup.Id == permissionGroup.Id).SingleOrDefault();
                    if (deletingUserPermissionGroup != null)
                    {
                        this.genericMgr.Delete(deletingUserPermissionGroup);
                    }
                }
            }
            #endregion

            #region 保存新增授权的权限组
            IList<PermissionGroup> insertingPermissionGroupList = assignedPermissionGroupList.Except<PermissionGroup>(oldAssingedPermissionGroupList).ToList();
            if (insertingPermissionGroupList.Count > 0)
            {
                IList<UserPermissionGroup> insertingUserPermissionGroupList = (from pg in insertingPermissionGroupList
                                                                               select new UserPermissionGroup
                                                                               {
                                                                                   User = new User(userId),
                                                                                   PermissionGroup = pg
                                                                               }).ToList();

                foreach (UserPermissionGroup userPG in insertingUserPermissionGroupList)
                {
                    this.genericMgr.Create(userPG);
                }
            }
            #endregion
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="userId"></param>
        /// <param name="permissionCategoryCode"></param>
        /// <param name="assignedPermissionIdList"></param>
        [Transaction(TransactionMode.Requires)]
        public void UpdateUserPermissions(int userId, string permissionCategoryCode, IList<int> assignedPermissionIdList)
        {
            IList<Permission> assignedPermissionList = new List<Permission>();

            if (assignedPermissionIdList != null && assignedPermissionIdList.Count > 0)
            {
                assignedPermissionList = (from permissionId in assignedPermissionIdList
                                          select new Permission
                                          {
                                              Id = permissionId
                                          }).ToList();
            }

            IList<UserPermission> oldAssingedUserPermissionList = this.genericMgr.FindAll<UserPermission>(selectUserPermissionByUserId, new object[] { userId, permissionCategoryCode });
            IList<Permission> oldAssingedPermissionList = new List<Permission>();

            if (oldAssingedUserPermissionList != null && oldAssingedUserPermissionList.Count > 0)
            {
                oldAssingedPermissionList = (from up in oldAssingedUserPermissionList
                                             select new Permission
                                             {
                                                 Id = up.Permission.Id
                                             }).ToList();
            }

            #region 删除没有授权的权限
            IList<Permission> deletePermissionList = oldAssingedPermissionList.Except<Permission>(assignedPermissionList).ToList();
            if (deletePermissionList.Count > 0)
            {
                foreach (Permission permission in deletePermissionList)
                {
                    UserPermission deletingUserPermission = oldAssingedUserPermissionList.Where(up => up.Permission.Id == permission.Id).SingleOrDefault();
                    if (deletingUserPermission != null)
                    {
                        this.genericMgr.Delete(deletingUserPermission);
                    }
                }
            }
            #endregion

            #region 保存新增授权的权限
            IList<Permission> insertingPermissionList = assignedPermissionList.Except<Permission>(oldAssingedPermissionList).ToList();
            if (insertingPermissionList.Count > 0)
            {
                IList<UserPermission> insertingUserPermissionList = (from permission in insertingPermissionList
                                                                     select new UserPermission
                                                                     {
                                                                         User = new User(userId),
                                                                         Permission = permission
                                                                     }).ToList();

                foreach (UserPermission userPermission in insertingUserPermissionList)
                {
                    this.genericMgr.Create(userPermission);
                }
            }
            #endregion
        }
        #endregion

        #region 角色授权
        /// <summary>
        /// 
        /// </summary>
        /// <param name="roleId"></param>
        /// <param name="assignedUserIdList"></param>
        [Transaction(TransactionMode.Requires)]
        public void UpdateRoleUsers(int roleId, IList<int> assignedUserIdList)
        {
            IList<User> assignedUserList = new List<User>();

            if (assignedUserIdList != null && assignedUserIdList.Count > 0)
            {
                assignedUserList = (from userId in assignedUserIdList
                                    select new User
                                    {
                                        Id = userId
                                    }).ToList();
            }

            IList<UserRole> oldAssingedUserRoleList = this.genericMgr.FindAll<UserRole>(selectUserRoleByRoleId, roleId);
            IList<User> oldAssingedUserList = new List<User>();

            if (oldAssingedUserRoleList != null && oldAssingedUserRoleList.Count > 0)
            {
                oldAssingedUserList = (from ur in oldAssingedUserRoleList
                                       select new User
                                       {
                                           Id = ur.User.Id
                                       }).ToList();
            }

            #region 删除没有授权的用户
            IList<User> deleteUserList = oldAssingedUserList.Except<User>(assignedUserList).ToList();
            if (deleteUserList.Count > 0)
            {
                foreach (User user in deleteUserList)
                {
                    UserRole deletingUserRole = oldAssingedUserRoleList.Where(ur => ur.User.Id == user.Id).SingleOrDefault();
                    if (deletingUserRole != null)
                    {
                        this.genericMgr.Delete(deletingUserRole);
                    }
                }
            }
            #endregion

            #region 保存新增授权的角色
            IList<User> insertingUserList = assignedUserList.Except<User>(oldAssingedUserList).ToList();
            if (insertingUserList.Count > 0)
            {
                IList<UserRole> insertingUserRoleList = (from user in insertingUserList
                                                         select new UserRole
                                                         {
                                                             User = user,
                                                             Role = new Role(roleId)
                                                         }).ToList();

                foreach (UserRole userRole in insertingUserRoleList)
                {
                    this.genericMgr.Create(userRole);
                }
            }
            #endregion
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="roleId"></param>
        /// <param name="assignedPermissionGroupIdList"></param>
        [Transaction(TransactionMode.Requires)]
        public void UpdateRolePermissionGroups(int roleId, IList<int> assignedPermissionGroupIdList)
        {
            IList<PermissionGroup> assignedPermissionGroupList = new List<PermissionGroup>();

            if (assignedPermissionGroupIdList != null && assignedPermissionGroupIdList.Count > 0)
            {
                assignedPermissionGroupList = (from gpId in assignedPermissionGroupIdList
                                               select new PermissionGroup
                                               {
                                                   Id = gpId
                                               }).ToList();
            }

            IList<RolePermissionGroup> oldAssingedRolePermissionGroupList = this.genericMgr.FindAll<RolePermissionGroup>(selectRolePermissionGroupByRoleId, roleId);
            IList<PermissionGroup> oldAssingedPermissionGroupList = new List<PermissionGroup>();

            if (oldAssingedRolePermissionGroupList != null && oldAssingedRolePermissionGroupList.Count > 0)
            {
                oldAssingedPermissionGroupList = (from rpg in oldAssingedRolePermissionGroupList
                                                  select new PermissionGroup
                                                  {
                                                      Id = rpg.PermissionGroup.Id
                                                  }).ToList();
            }

            #region 删除没有授权的权限组
            IList<PermissionGroup> deletePermissionGroupList = oldAssingedPermissionGroupList.Except<PermissionGroup>(assignedPermissionGroupList).ToList();
            if (deletePermissionGroupList.Count > 0)
            {
                foreach (PermissionGroup permissionGroup in deletePermissionGroupList)
                {
                    RolePermissionGroup deletingRolePermissionGroup = oldAssingedRolePermissionGroupList.Where(rpg => rpg.PermissionGroup.Id == permissionGroup.Id).SingleOrDefault();
                    if (deletingRolePermissionGroup != null)
                    {
                        this.genericMgr.Delete(deletingRolePermissionGroup);
                    }
                }
            }
            #endregion

            #region 保存新增授权的权限组
            IList<PermissionGroup> insertingPermissionGroupList = assignedPermissionGroupList.Except<PermissionGroup>(oldAssingedPermissionGroupList).ToList();
            if (insertingPermissionGroupList.Count > 0)
            {
                IList<RolePermissionGroup> insertingRolePermissionGroupList = (from rpg in insertingPermissionGroupList
                                                                               select new RolePermissionGroup
                                                                               {
                                                                                   Role = new Role(roleId),
                                                                                   PermissionGroup = rpg
                                                                               }).ToList();

                foreach (RolePermissionGroup rolePG in insertingRolePermissionGroupList)
                {
                    this.genericMgr.Create(rolePG);
                }
            }
            #endregion
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="roleId"></param>
        /// <param name="permissionCategoryCode"></param>
        /// <param name="assignedPermissionIdList"></param>
        [Transaction(TransactionMode.Requires)]
        public void UpdateRolePermissions(int roleId, string permissionCategoryCode, IList<int> assignedPermissionIdList)
        {
            IList<Permission> assignedPermissionList = new List<Permission>();

            if (assignedPermissionIdList != null && assignedPermissionIdList.Count > 0)
            {
                assignedPermissionList = (from permissionId in assignedPermissionIdList
                                          select new Permission
                                          {
                                              Id = permissionId
                                          }).ToList();
            }

            IList<RolePermission> oldAssingedRolePermissionList = this.genericMgr.FindAll<RolePermission>(selectRolePermissionByRoleId, new object[] { roleId, permissionCategoryCode });
            IList<Permission> oldAssingedPermissionList = new List<Permission>();

            if (oldAssingedRolePermissionList != null && oldAssingedRolePermissionList.Count > 0)
            {
                oldAssingedPermissionList = (from rp in oldAssingedRolePermissionList
                                             select new Permission
                                             {
                                                 Id = rp.Permission.Id
                                             }).ToList();
            }

            #region 删除没有授权的权限
            IList<Permission> deletePermissionList = oldAssingedPermissionList.Except<Permission>(assignedPermissionList).ToList();
            if (deletePermissionList.Count > 0)
            {
                foreach (Permission permission in deletePermissionList)
                {
                    RolePermission deletingRolePermission = oldAssingedRolePermissionList.Where(rp => rp.Permission.Id == permission.Id).SingleOrDefault();
                    if (deletingRolePermission != null)
                    {
                        this.genericMgr.Delete(deletingRolePermission);
                    }
                }
            }
            #endregion

            #region 保存新增授权的权限
            IList<Permission> insertingPermissionList = assignedPermissionList.Except<Permission>(oldAssingedPermissionList).ToList();
            if (insertingPermissionList.Count > 0)
            {
                IList<RolePermission> insertingRolePermissionList = (from permission in insertingPermissionList
                                                                     select new RolePermission
                                                                     {
                                                                         Role = new Role(roleId),
                                                                         Permission = permission
                                                                     }).ToList();

                foreach (RolePermission rolePermission in insertingRolePermissionList)
                {
                    this.genericMgr.Create(rolePermission);
                }
            }
            #endregion
        }
        #endregion

        #region 权限组授权
        /// <summary>
        ///         
        /// </summary>
        /// <param name="permissionGroupId"></param>
        /// <param name="assignedUserIdList"></param>
        [Transaction(TransactionMode.Requires)]
        public void UpdatePermissionGroupUsers(int permissionGroupId, IList<int> assignedUserIdList)
        {
            IList<User> assignedUserList = new List<User>();

            if (assignedUserIdList != null && assignedUserIdList.Count > 0)
            {
                assignedUserList = (from uId in assignedUserIdList
                                    select new User
                                    {
                                        Id = uId
                                    }).ToList();
            }

            IList<UserPermissionGroup> oldAssingedUserPermissionGroupList = this.genericMgr.FindAll<UserPermissionGroup>(selectUserPermissionGroupByPermissionGroupId, permissionGroupId);
            IList<User> oldAssingedUserList = new List<User>();

            if (oldAssingedUserPermissionGroupList != null && oldAssingedUserPermissionGroupList.Count > 0)
            {
                oldAssingedUserList = (from up in oldAssingedUserPermissionGroupList
                                       select new User
                                       {
                                           Id = up.User.Id
                                       }).ToList();
            }

            #region 删除没有授权的用户
            IList<User> deleteUserList = oldAssingedUserList.Except<User>(assignedUserList).ToList();
            if (deleteUserList.Count > 0)
            {
                foreach (User user in deleteUserList)
                {
                    UserPermissionGroup deletingUserPermissionGroup = oldAssingedUserPermissionGroupList.Where(up => up.User.Id == user.Id).SingleOrDefault();
                    if (deletingUserPermissionGroup != null)
                    {
                        this.genericMgr.Delete(deletingUserPermissionGroup);
                    }
                }
            }
            #endregion

            #region 保存新增授权的用户
            IList<User> insertingUserList = assignedUserList.Except<User>(oldAssingedUserList).ToList();
            if (insertingUserList.Count > 0)
            {
                IList<UserPermissionGroup> insertingUserPermissionGroupList = (from u in insertingUserList
                                                                               select new UserPermissionGroup
                                                                               {
                                                                                   User = u,
                                                                                   PermissionGroup = new PermissionGroup(permissionGroupId)
                                                                               }).ToList();

                foreach (UserPermissionGroup userPG in insertingUserPermissionGroupList)
                {
                    this.genericMgr.Create(userPG);
                }
            }
            #endregion
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="permissionGroupId"></param>
        /// <param name="assignedRoleIdList"></param>
        [Transaction(TransactionMode.Requires)]
        public void UpdatePermissionGroupRoles(int permissionGroupId, IList<int> assignedRoleIdList)
        {
            IList<Role> assignedRoleList = new List<Role>();

            if (assignedRoleIdList != null && assignedRoleIdList.Count > 0)
            {
                assignedRoleList = (from rId in assignedRoleIdList
                                    select new Role
                                    {
                                        Id = rId
                                    }).ToList();
            }

            IList<RolePermissionGroup> oldAssingedRolePermissionGroupList = this.genericMgr.FindAll<RolePermissionGroup>(selectRolePermissionGroupByPermissionGroupId, permissionGroupId);
            IList<Role> oldAssingedRoleList = new List<Role>();

            if (oldAssingedRolePermissionGroupList != null && oldAssingedRolePermissionGroupList.Count > 0)
            {
                oldAssingedRoleList = (from rpg in oldAssingedRolePermissionGroupList
                                       select new Role
                                       {
                                           Id = rpg.Role.Id
                                       }).ToList();
            }

            #region 删除没有授权的权限组
            IList<Role> deleteRoleList = oldAssingedRoleList.Except<Role>(assignedRoleList).ToList();
            if (deleteRoleList.Count > 0)
            {
                foreach (Role role in deleteRoleList)
                {
                    RolePermissionGroup deletingRolePermissionGroup = oldAssingedRolePermissionGroupList.Where(rpg => rpg.Role.Id == role.Id).SingleOrDefault();
                    if (deletingRolePermissionGroup != null)
                    {
                        this.genericMgr.Delete(deletingRolePermissionGroup);
                    }
                }
            }
            #endregion

            #region 保存新增授权的权限组
            IList<Role> insertingRoleList = assignedRoleList.Except<Role>(oldAssingedRoleList).ToList();
            if (insertingRoleList.Count > 0)
            {
                IList<RolePermissionGroup> insertingRolePermissionGroupList = (from r in insertingRoleList
                                                                               select new RolePermissionGroup
                                                                               {
                                                                                   Role = r,
                                                                                   PermissionGroup = new PermissionGroup(permissionGroupId)
                                                                               }).ToList();

                foreach (RolePermissionGroup rolePG in insertingRolePermissionGroupList)
                {
                    this.genericMgr.Create(rolePG);
                }
            }
            #endregion
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="permissionGroupId"></param>
        /// <param name="permissionCategoryCode"></param>
        /// <param name="assignedPermissionIdList"></param>
        [Transaction(TransactionMode.Requires)]
        public void UpdatePermissionGroupPermissions(int permissionGroupId, string permissionCategoryCode, IList<int> assignedPermissionIdList)
        {
            IList<Permission> assignedPermissionList = new List<Permission>();

            if (assignedPermissionIdList != null && assignedPermissionIdList.Count > 0)
            {
                assignedPermissionList = (from permissionId in assignedPermissionIdList
                                          select new Permission
                                          {
                                              Id = permissionId
                                          }).ToList();
            }

            IList<PermissionGroupPermission> oldAssingedPermissionGroupPermissionList = this.genericMgr.FindAll<PermissionGroupPermission>(selectPermissionGroupPermissionByPermissionGroupId, new object[] { permissionGroupId, permissionCategoryCode });
            IList<Permission> oldAssingedPermissionList = new List<Permission>();

            if (oldAssingedPermissionGroupPermissionList != null && oldAssingedPermissionGroupPermissionList.Count > 0)
            {
                oldAssingedPermissionList = (from rp in oldAssingedPermissionGroupPermissionList
                                             select new Permission
                                             {
                                                 Id = rp.Permission.Id
                                             }).ToList();
            }

            #region 删除没有授权的权限
            IList<Permission> deletePermissionList = oldAssingedPermissionList.Except<Permission>(assignedPermissionList).ToList();
            if (deletePermissionList.Count > 0)
            {
                foreach (Permission permission in deletePermissionList)
                {
                    PermissionGroupPermission deletingPermissionGroupPermission = oldAssingedPermissionGroupPermissionList.Where(rp => rp.Permission.Id == permission.Id).SingleOrDefault();
                    if (deletingPermissionGroupPermission != null)
                    {
                        this.genericMgr.Delete(deletingPermissionGroupPermission);
                    }
                }
            }
            #endregion

            #region 保存新增授权的权限
            IList<Permission> insertingPermissionList = assignedPermissionList.Except<Permission>(oldAssingedPermissionList).ToList();
            if (insertingPermissionList.Count > 0)
            {
                IList<PermissionGroupPermission> insertingPermissionGroupPermissionList = (from permission in insertingPermissionList
                                                                                           select new PermissionGroupPermission
                                                                     {
                                                                         PermissionGroup = new PermissionGroup(permissionGroupId),
                                                                         Permission = permission
                                                                     }).ToList();

                foreach (PermissionGroupPermission permissionGroupPermission in insertingPermissionGroupPermissionList)
                {
                    this.genericMgr.Create(permissionGroupPermission);
                }
            }
            #endregion
        }
        #endregion

        #region Permission Translate
        public void TranslatePermission(IList<Permission> permissionList)
        {
            if (permissionList != null && permissionList.Count > 0)
            {
                foreach (Permission permission in permissionList)
                {
                    string desc = Resources.Permission.ResourceManager.GetString(permission.Description);
                    if (desc != null)
                    {
                        permission.Description = desc;
                    }
                }
            }
        }

        public void TranslatePermissionCategory(IList<PermissionCategory> permissionCategoryList)
        {
            if (permissionCategoryList != null && permissionCategoryList.Count > 0)
            {
                foreach (PermissionCategory permissionCategory in permissionCategoryList)
                {
                    string desc = Resources.Permission.ResourceManager.GetString(permissionCategory.Description);
                    if (desc != null)
                    {
                        permissionCategory.Description = desc;
                    }
                }
            }
        }
        #endregion

        public bool VerifyUserPassword(string userCode, string password)
        {
            string hql = "from User where Code = ?";

            IList<User> users = genericMgr.FindAll<User>(hql, userCode);
            if (users != null && users.Count > 0)
            {
                User user = users[0];
                return EncryptHelper.Md5(password).Equals(user.Password, StringComparison.OrdinalIgnoreCase);
            }
            return false;
        }

        public bool IsDomainAuthenticated(string user, string password)
        {
            bool authenticated = false;

            try
            {
                DirectoryEntry entry = new DirectoryEntry(Domain, user, password);
                object nativeObject = entry.NativeObject;
                authenticated = true;
            }
            catch (DirectoryServicesCOMException cex)
            {
                //not authenticated; reason why is in cex 
            }
            catch (Exception ex)
            {
                //not authenticated due to some other exception [this is optional] 
            }
            return authenticated;
        }

       

        #endregion

        #region private methods      
        private IList<UserPermissionView> GetUserPermission(User user)
        {
            if (user.Code.Trim().ToLower() == "su")
            {
                //超级用户，给予所有权限
                DetachedCriteria criteria = DetachedCriteria.For<Permission>();
                IList<Permission> permissionList = genericMgr.FindAll<Permission>(criteria);

                criteria = DetachedCriteria.For<PermissionCategory>();
                IList<PermissionCategory> categoryList = genericMgr.FindAll<PermissionCategory>(criteria);

                return (from p in permissionList
                        join c in categoryList on p.PermissionCategory equals c.Code
                        select new UserPermissionView
                        {
                            UserId = user.Id,
                            PermissionCode = p.Code,
                            PermissionCategory = p.PermissionCategory,
                            PermissionCategoryType = c.Type
                        }).ToList();
            }
            else
            {
                DetachedCriteria criteria = DetachedCriteria.For<UserPermissionView>();
                criteria.Add(Expression.Eq("UserId", user.Id));

                return genericMgr.FindAll<UserPermissionView>(criteria);
            }
        }
        #endregion
    }
}
