using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace EMS.Models.BusinessBase
{
    public class DesignationB
    {
        public string DESIGNATIONID { get; set; }
        public string DESIGNATION { get; set; }
        public Nullable<decimal> ATTENBONUS { get; set; }
        public Nullable<decimal> TATTENBONUS { get; set; }
        public Nullable<decimal> YDATTENBONUS { get; set; }
        public string DGROUPID { get; set; }
    }
}