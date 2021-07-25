using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace EMS.HtmlHelpers
{
    public static class CustomHtmlHelper
    {
        public static IHtmlString Image(this HtmlHelper helper,string src,string atl)
        {
            TagBuilder tb = new TagBuilder("img");
            tb.Attributes.Add("src", VirtualPathUtility.ToAbsolute(src));
            tb.Attributes.Add("atl", atl);
            return new MvcHtmlString(tb.ToString(TagRenderMode.SelfClosing));
        }
    }
}