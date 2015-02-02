using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ComponentModel;

namespace com.Sconit.Entity.SAP
{
    public enum StatusEnum
    {
        [Description("执行中")]
        Pending = 0,
        [Description("成功")]
        Success = 1,
        [Description("失败")]
        Fail = 2,
        [Description("异常")]
        Exception = 3,
    }

    public enum CreateDNDNSTREnum
    {
        [Description("未执行")]
        Pending = 'P',
        [Description("创建成功")]
        Success = 'S',
        [Description("创建失败")]
        Fail = 'F',
        [Description("删除")]
        Cancel = 'C',
        [Description("LES已取消")]
        LESCancel = 'A'
    }

    public enum CreateDNGISTREnum
    {
        [Description("未执行")]
        Pending = 'P',
        [Description("过账成功")]
        Success = 'S',
        [Description("过账失败")]
        Fail = 'F',
        [Description("过账冲销")]
        Cancel = 'C',
        [Description("LES已取消")]
        LESCancel = 'A'
    }

    public enum CancelCreateDNDNSTREnum
    {
        [Description("未执行")]
        Pending = 'P',
        [Description("删除失败")]
        Fail = 'S',
        [Description("删除成功")]
        Success = 'C',
        [Description("LES已取消")]
        LESCancel = 'A'
    }

    public enum CancelCreateDNGISTREnum
    {
        [Description("未执行")]
        Pending = 'P',
        [Description("冲销失败")]
        Fail = 'S',
        [Description("冲销成功")]
        Success = 'C',
        [Description("LES已取消")]
        LESCancel = 'A'
    }

    public interface ITraceable
    {
        StatusEnum Status { get; set; }
        DateTime CreateDate { get; set; }
        DateTime LastModifyDate { get; set; }
        Int32 ErrorCount { get; set; }
    }
}
