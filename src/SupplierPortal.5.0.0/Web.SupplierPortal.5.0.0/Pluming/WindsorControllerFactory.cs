using System;
using System.Linq;
using System.Reflection;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;
using Castle.Windsor;
using com.Sconit.Entity.Exception;
using com.Sconit.Web.Controllers;
using com.Sconit.Web.Util;

namespace com.Sconit.Web.Pluming
{
    public class WindsorControllerFactory : DefaultControllerFactory
    {
        private readonly IWindsorContainer container;

        public WindsorControllerFactory(IWindsorContainer container)
        {
            if ( container == null)
            {
                throw new ArgumentNullException("container");
            }

            this.container = container;
        }

        protected override IController GetControllerInstance(RequestContext context, Type controllerType)
        {
            if (controllerType == null)
            {
                throw new HttpException(404, string.Format("The controller for path '{0}' could not be found or it does not implement IController.", context.HttpContext.Request.Path));
            }

            UpdateRequestHost(context);

            IController controller = (IController)container.Resolve(controllerType);

            #region 如果Service没有赋值，这里重新赋值
            //if (controller as WebAppBaseController != null)
            //{
            //    foreach (PropertyInfo propertyInfo in controller.GetType().GetProperties().Where(p => (p.PropertyType.GetInterfaces().Contains(typeof(com.Sconit.Service.ICastleAwarable)))))
            //    {
            //        if (propertyInfo.GetGetMethod().Invoke(controller, null) == null)
            //        {
            //            Object service = ServiceLocator.ObtainContainer().Resolve(propertyInfo.GetGetMethod().ReturnType);

            //            if (service != null)
            //            {
            //                propertyInfo.GetSetMethod().Invoke(controller, new object[] { service });
            //            }
            //            else
            //            {
            //                throw new TechnicalException("控制器" + controller.GetType().ToString() + "的服务" + propertyInfo.Name + "没有赋值。");
            //            }
            //        }
            //    }
            //}
            #endregion

            return controller;
        }

        private void UpdateRequestHost(RequestContext context)
        {
            var host = container.Resolve<RequestContextHost>();
            host.SetContext(context);
        }

        public override void ReleaseController(IController controller)
        {
            var disposable = controller as IDisposable;
            if (disposable != null)
            {
                disposable.Dispose();
            }
            container.Release(controller);
        }
    }
}