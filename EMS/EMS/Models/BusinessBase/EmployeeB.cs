using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace EMS.Models.BusinessBase
{
    public class EmployeeB
    {
        public string EMPLOYEEID { get; set; }
        public string EMPLOYEENAME { get; set; }
        public string DESIGNATIONID { get; set; }
        public string DEPARTMENTID { get; set; }
        public string DEPARTMENT { get; set; }
        public string SECTIONID { get; set; }
        public string LINEID { get; set; }
        public string EMPPASSWORD { get; set; }
        public string EMPCONTACTNO { get; set; }
        public string EMPPARADDRESS { get; set; }
        public string EMPPRESADDRESS { get; set; }
        public string SEX { get; set; }
        public string EXPERIENCE { get; set; }
        public decimal BASICSALARY { get; set; }
        public decimal HOUSERENT { get; set; }
        public decimal MEDICAL { get; set; }
        public decimal GROSSWAGES { get; set; }
        public string EMPSTATUS { get; set; }
        public string SALARYCATEGORY { get; set; }
        public string ACCOUNTNO { get; set; }
        public string BANKID { get; set; }
        public string BRANCHNAME { get; set; }
        public string EMPNO { get; set; }
        public string PUNCHNO { get; set; }

        public string SHIFTID { get; set; }

        public string SPOUSENAME { get; set; }
        public string FATHERSNAME { get; set; }
        public string MOTHERSNAME { get; set; }
        public string EDUCATIONALQUALIFICATION { get; set; }

        public string NID { get; set; }
        public string ImageUrl { get; set; }
        public byte[] PHOTO { get; set; }
        public HttpPostedFileBase ImageFile { get; set; }
    }
}