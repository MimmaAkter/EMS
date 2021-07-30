using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace EMS.Models.BusinessBase
{
    public class EmployeeB
    {
        [Required]
        public string EMPLOYEEID { get; set; }
        [Required]
        public string EMPLOYEENAME { get; set; }
        [Required]
        public string DESIGNATIONID { get; set; }
        [Required]
        public string DEPARTMENTID { get; set; }
        public string SECTIONID { get; set; }
        public string LINEID { get; set; }
        public byte GRADE { get; set; }
        [Required]
        public string EMPPASSWORD { get; set; }
        public string EMPCONTACTNO { get; set; }
        public string EMPPARADDRESS { get; set; }
        [Required]
        public string EMPPRESADDRESS { get; set; }
        public string SEX { get; set; }
        public Nullable<System.DateTime> DOB { get; set; }
        public Nullable<System.DateTime> JOININGDATE { get; set; }
        public string EXPERIENCE { get; set; }
        public Nullable<decimal> BASICSALARY { get; set; }
        public Nullable<decimal> HOUSERENT { get; set; }
        public Nullable<decimal> MEDICAL { get; set; }
        public Nullable<decimal> GROSSWAGES { get; set; }
        public string EMPSTATUS { get; set; }
        public string SALARYCATEGORY { get; set; }
        public Nullable<bool> STATUS { get; set; }
        public Nullable<bool> EMPGROUPID { get; set; }
        public Nullable<System.DateTime> RESIGNDATE { get; set; }
        public Nullable<decimal> CONVEYANCE { get; set; }
        public Nullable<decimal> INCOMETAX { get; set; }
        public Nullable<decimal> ADVANCE { get; set; }
        public Nullable<decimal> ADDITIONAL { get; set; }
        public Nullable<decimal> CARALLOWANCE { get; set; }
        public Nullable<decimal> TOTALADDITION { get; set; }
        public Nullable<bool> PAYMENTTYPEID { get; set; }
        public Nullable<decimal> COMPANYCONPF { get; set; }
        public Nullable<decimal> BANKINTEREST { get; set; }
        public Nullable<decimal> TOTALPFAMT { get; set; }
        public Nullable<decimal> PAIDEMPCONPF { get; set; }
        public Nullable<decimal> PAIDCOMPANYCONPF { get; set; }
        public Nullable<decimal> PAIDBANKINTEREST { get; set; }
        public Nullable<decimal> TOTALPAIDAMT { get; set; }
        public Nullable<decimal> BALANCEAMT { get; set; }
        public string SITE { get; set; }
        public Nullable<System.DateTime> PFEFFECTEDDATE { get; set; }
        public string ACCOUNTNO { get; set; }
        public string BANKID { get; set; }
        public string BRANCHNAME { get; set; }
        public Nullable<decimal> EMPCONPF { get; set; }
        public string EMPNO { get; set; }
        public string PUNCHNO { get; set; }
        public Nullable<System.DateTime> CARDREGDATE { get; set; }
        public Nullable<bool> ALLOWBMSALARY { get; set; }
        public string SHIFTID { get; set; }
        public Nullable<decimal> PROVIDENTFUND { get; set; }
        public Nullable<System.DateTime> DISBURSEDATE { get; set; }
        public Nullable<bool> SHIFTFIXED { get; set; }
        public string SPOUSENAME { get; set; }
        public string FATHERSNAME { get; set; }
        public string MOTHERSNAME { get; set; }
        public string EDUCATIONALQUALIFICATION { get; set; }
        public Nullable<short> FOOD { get; set; }
        public bool MARITALSTATUS { get; set; }
        public byte[] PHOTO { get; set; }
        public Nullable<decimal> GRADEID { get; set; }
        public Nullable<decimal> OLDGROSSWAGES { get; set; }
        public Nullable<int> EMPTYPEID { get; set; }
        public Nullable<int> EDUDEGREEID { get; set; }
        public string TINNO { get; set; }
        public string NID { get; set; }
        public Nullable<int> RELIGIONID { get; set; }
        public Nullable<decimal> PFPARCENT { get; set; }
        public string EMAIL { get; set; }
        public Nullable<byte> DEVISIONID { get; set; }
        public Nullable<byte> NOOFCHIELD { get; set; }
        public Nullable<System.DateTime> HELDUPDATE { get; set; }
        public Nullable<decimal> TEMPGROSS { get; set; }
        public Nullable<decimal> BLOODGROUPID { get; set; }
        public Nullable<System.DateTime> RGNSUBDATE { get; set; }
        public Nullable<decimal> FNFDUESALARY { get; set; }
        public Nullable<bool> FNFCOMPLETE { get; set; }
        public Nullable<decimal> CELLPHONEALLOWANCE { get; set; }
        public Nullable<bool> CPALLOWED { get; set; }
        public Nullable<bool> CELLPHONETYPEID { get; set; }
        public Nullable<System.DateTime> DATEOFCONFIRMATRION { get; set; }
        public Nullable<decimal> TMPGROSSWAGES { get; set; }
        public string PFCHEQUENO { get; set; }
        public Nullable<System.DateTime> PFCHEQUEDATE { get; set; }
        public string EMPLOYEENAME4BANK { get; set; }
        public Nullable<long> TICKET { get; set; }
        public string INCOMETAXAREAID { get; set; }
        public HttpPostedFileBase ImageFile { get; set; }
        public SelectList DepartmentList { get; set; }
        public SelectList DesignationList { get; set; }
        public SelectList BloodList { get; set; }
        public SelectList ReligionList { get; set; }
        public SelectList BankList { get; set; }
        public SelectList GenderList { get; set; }
        public SelectList PaymenttypeList { get; set; }
        public string ImageUrl { get; set; }
        public string ServiceLength { get; set; }

    }
}