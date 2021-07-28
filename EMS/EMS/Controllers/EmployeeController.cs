using CrystalDecisions.CrystalReports.Engine;
using EMS.Models.BusinessBase;
using EMS.Models.DBLayer;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace EMS.Controllers
{
    public class EmployeeController : Controller
    {
        // GET: Employee
        #region Initialization
        EmployeeB obj = new EmployeeB();
        EmployeeDB _dbLayer = new EmployeeDB();
        DepartmentDB bsDepartment = new DepartmentDB();
        DesignationDB bsDesignation = new DesignationDB();
        BankDB bsBank = new BankDB();
        GenderDB bsGender = new GenderDB();
        BloodDB bsBlood = new BloodDB();
        ReligionDB bsReligion = new ReligionDB();
        #endregion
        #region CRUD
        public ActionResult Index()
        {
            DataSet ds = _dbLayer.Read();
            ViewBag.data = ds.Tables[0];
            return View();
        }
        public ActionResult AllEmployees()
        {
            DataSet ds = _dbLayer.Read();
            ViewBag.data = ds.Tables[0];
            return View();
        }
        public ActionResult Create()
        {
            //DropDown DataSource                                  
            ViewBag.DEPARTMENTID = new SelectList(bsDepartment.DepartmentLookUp(), "DepartmentID", "Department");
            ViewBag.DESIGNATIONID = new SelectList(bsDesignation.DesignationLookUp(), "DESIGNATIONID", "DESIGNATION");
            ViewBag.SEXID = new SelectList(bsGender.GenderLookUp(), "SEXID", "SEXNAME");
            ViewBag.BANKID = new SelectList(bsBank.BankLookUp(), "BankId", "BankName");
            ViewBag.BLOODGROUPID = new SelectList(bsBlood.BloodLookUp(), "BLOODGROUPID", "BLOODGROUPNAME");
            ViewBag.RELIGIONID = new SelectList(bsReligion.ReligionLookUp(), "RELIGIONID", "RELIGIONNAME");

            return View();
        }
        [HttpPost]
        public ActionResult Create(HttpPostedFileBase image, FormCollection fc)
        {           
            ViewBag.DEPARTMENTID = new SelectList(bsDepartment.DepartmentLookUp(), "DepartmentID", "Department");
            ViewBag.DESIGNATIONID = new SelectList(bsDesignation.DesignationLookUp(), "DESIGNATIONID", "DESIGNATION");
            ViewBag.SEXID = new SelectList(bsGender.GenderLookUp(), "SEXID", "SEXNAME");
            ViewBag.BANKID = new SelectList(bsBank.BankLookUp(), "BankId", "BankName");
            ViewBag.BLOODGROUPID = new SelectList(bsBlood.BloodLookUp(), "BLOODGROUPID", "BLOODGROUPNAME");
            ViewBag.RELIGIONID = new SelectList(bsReligion.ReligionLookUp(), "RELIGIONID", "RELIGIONNAME");

            EmployeeB data = new EmployeeB();
            data.EMPLOYEEID = fc["EMPLOYEEID"].ToString().ToUpper();
            data.EMPLOYEENAME = fc["EMPLOYEENAME"].ToString();
            data.SEX = fc["SEXID"].ToString();
            data.BASICSALARY = Convert.ToDecimal(fc["BASICSALARY"]);
            data.GROSSWAGES = Convert.ToDecimal(fc["GROSSWAGES"]);
            data.ACCOUNTNO = fc["ACCOUNTNO"].ToString();
            data.NID = fc["NID"].ToString();
            data.DESIGNATIONID = fc["DESIGNATIONID"].ToString();
            data.DEPARTMENTID = fc["DEPARTMENTID"].ToString();
            data.EMPPRESADDRESS = fc["EMPPRESADDRESS"].ToString();
            data.BANKID = fc["BANKID"].ToString();
            data.RELIGIONID =Convert.ToInt32(fc["RELIGIONID"]);
            data.BLOODGROUPID =Convert.ToDecimal(fc["BLOODGROUPID"]);
            data.BRANCHNAME = fc["BRANCHNAME"].ToString();
            if (image != null)
            {
                data.PHOTO = new byte[image.ContentLength];
                image.InputStream.Read(data.PHOTO, 0, image.ContentLength);
            }
            _dbLayer.Create(data);
            return View();
        }

        public ActionResult GetDepartment()
        {
            return Json(bsDepartment.GetDepartment(), JsonRequestBehavior.AllowGet);
        }
        //public ActionResult Update(string id)
        //{
        //    DataSet ds = _dbLayer.Edit(id);
        //    //ViewBag.data = ds.Tables[0];
        //    ViewBag.DEPARTMENTID = new SelectList(bsDepartment.GetDepartment(), "DEPARTMENTID", "DEPARTMENT", 35);

        //    //obj.DesignationList = new SelectList(bsDesignation.DesignationLookUp(), "DESIGNATIONID", "DESIGNATION");
        //    //List<SelectListItem> selectListItems = new List<SelectListItem>();
        //    //foreach (EmployeeB department in ViewBag.data)
        //    //{
        //    //    SelectListItem selectListItem = new SelectListItem
        //    //    {
        //    //        Text = department.DEPARTMENT,
        //    //        Value = department.DEPARTMENTID.ToString(),
        //    //        Selected = department.DEPTGROUPID.HasValue ? department.DEPTGROUPID.Value : false
        //    //    };
        //    //    selectListItems.Add(selectListItem);
        //    //}
        //    //ViewBag.DepartmentID = selectListItems;


        //    //var list = _dbLayer.GetEmployeeBList().ToList();
        //    var view_model = ds.Tables[0].AsEnumerable().Select(dataRow => new EmployeeB
        //    {
        //        EMPLOYEEID = dataRow.Field<string>("EMPLOYEEID"),
        //        EMPLOYEENAME = dataRow.Field<string>("EMPLOYEENAME"),
        //        SEX = dataRow.Field<string>("SEX"),
        //        DEPARTMENTID = dataRow.Field<string>("DEPARTMENTID"),
        //        DESIGNATIONID = dataRow.Field<string>("DESIGNATIONID")
        //    }).ToList();
        //    //EmployeeB[] objects = view_model.ConvertAll<EmployeeB>(item => (EmployeeB)item).ToArray();
        //    //var model = ds.Tables[0].AsEnumerable().FirstOrDefault(id);
        //    //var emp = view_model.Find();
        //    //list.Find(id);

        //    return View();
        //}

        
        public ActionResult Update(string id)
        {          
            var emp = _dbLayer.GetEmployee(id).Find(smodel => smodel.EMPLOYEEID == id);
            emp.DepartmentList= new SelectList(bsDepartment.DepartmentLookUp(), "DEPARTMENTID", "DEPARTMENT");
            emp.DesignationList = new SelectList(bsDesignation.DesignationLookUp(), "DESIGNATIONID", "DESIGNATION");
            emp.GenderList = new SelectList(bsGender.GenderLookUp(), "SEXID", "SEXNAME");
            emp.BankList = new SelectList(bsBank.BankLookUp(), "BankId", "BankName");
            emp.BloodList = new SelectList(bsBlood.BloodLookUp(), "BLOODGROUPID", "BLOODGROUPNAME");
            emp.ReligionList = new SelectList(bsReligion.ReligionLookUp(), "RELIGIONID", "RELIGIONNAME");
            return View("Update",emp);
        }
        [HttpPost]
        public ActionResult Update(string id, FormCollection fc, HttpPostedFileBase image)
        {
            //var emp = _dbLayer.GetEmployee(id).Find(smodel => smodel.EMPLOYEEID == id);         
            EmployeeB data = new EmployeeB();

            //data.DepartmentList = new SelectList(bsDepartment.DepartmentLookUp(), "DEPARTMENTID", "DEPARTMENT");
            //data.DesignationList = new SelectList(bsDesignation.DesignationLookUp(), "DESIGNATIONID", "DESIGNATION");
            //data.GenderList = new SelectList(bsGender.GenderLookUp(), "SEXID", "SEXNAME");
            //data.BankList = new SelectList(bsBank.BankLookUp(), "BankId", "BankName");
            //data.BloodList = new SelectList(bsBlood.BloodLookUp(), "BLOODGROUPID", "BLOODGROUPNAME");
            //data.ReligionList = new SelectList(bsReligion.ReligionLookUp(), "RELIGIONID", "RELIGIONNAME");

            data.EMPLOYEEID = fc["EMPLOYEEID"];
            data.EMPLOYEENAME = fc["EMPLOYEENAME"];
            data.SPOUSENAME = fc["SPOUSENAME"];
            data.FATHERSNAME = fc["FATHERSNAME"];
            data.MOTHERSNAME = fc["MOTHERSNAME"];
            data.DESIGNATIONID = fc["DESIGNATIONID"];
            data.DEPARTMENTID = fc["DEPARTMENTID"];
            data.SECTIONID = fc["SECTIONID"];

            data.LINEID = fc["LINEID"];
            //data.GRADE = fc["GRADE"];
            data.EMPPASSWORD = fc["EMPPASSWORD"];
            data.EMPCONTACTNO = fc["EMPCONTACTNO"];
            data.EMPPARADDRESS = fc["EMPPARADDRESS"];
            data.EMPPRESADDRESS = fc["EMPPRESADDRESS"];
            data.DISBURSEDATE = Convert.ToDateTime(fc["DISBURSEDATE"]);
            data.DOB = Convert.ToDateTime(fc["DOB"]);

            data.JOININGDATE =Convert.ToDateTime(fc["JOININGDATE"]);
            //data.PFEFFECTEDDATE =Convert.ToDateTime(fc["PFEFFECTEDDATE"]);
            data.DATEOFCONFIRMATRION =Convert.ToDateTime(fc["DATEOFCONFIRMATRION"]);
            data.EXPERIENCE = fc["EXPERIENCE"];
            data.BASICSALARY = Convert.ToDecimal(fc["BASICSALARY"]);
            data.HOUSERENT =Convert.ToDecimal(fc["HOUSERENT"]);
            data.MEDICAL =Convert.ToDecimal(fc["MEDICAL"]);
            //data.PROVIDENTFUND =Convert.ToDecimal(fc["PROVIDENTFUND"]);

            data.GROSSWAGES =Convert.ToDecimal(fc["GROSSWAGES"]);           
            data.SEX = fc["SEX"];
            data.SALARYCATEGORY = fc["SALARYCATEGORY"];
            data.EMPSTATUS = fc["EMPSTATUS"];
            data.STATUS =Convert.ToBoolean(fc["STATUS"]);
            //data.SHIFTFIXED =Convert. fc["SHIFTFIXED"];
            //data.EMPGROUPID =Convert.ToInt16 (fc["EMPGROUPID"]);
            //data.RESIGNDATE = fc["RESIGNDATE"] == string.Empty ? null : Convert.ToDateTime(fc["RGNSUBDATE"]);

            //data.CONVEYANCE =Convert.ToDecimal(fc["CONVEYANCE"]);
            //data.INCOMETAX =Convert.ToDecimal(fc["INCOMETAX"]);
            //data.ADVANCE =Convert.ToDecimal(fc["ADVANCE"]);
            //data.ADDITIONAL = Convert.ToDecimal(fc["ADDITIONAL"]);
            //data.CARALLOWANCE = Convert.ToDecimal(fc["CARALLOWANCE"]);
            //data.TOTALADDITION =Convert.ToDecimal(fc["TOTALADDITION"]);
            //data.PAYMENTTYPEID =Convert.ToBoolean(fc["PAYMENTTYPEID"]);
            //data.ACCOUNTNO = fc["ACCOUNTNO"];

            data.BANKID = fc["BANKID"];
            data.BRANCHNAME = fc["BRANCHNAME"];
            //data.PFCHEQUENO = fc["PFCHEQUENO"];
            //data.PFCHEQUEDATE =Convert.ToDateTime(fc["PFCHEQUEDATE"]);
            //data.SITE = Convert.ToDecimal(fc["GROSSWAGES"]);
            data.EMPNO = fc["EMPNO"];
            data.PUNCHNO = fc["PUNCHNO"];
            //data.CARDREGDATE =Convert.ToDateTime(fc["CARDREGDATE"]);

            data.ALLOWBMSALARY =Convert.ToBoolean(fc["ALLOWBMSALARY"]);
            data.EDUCATIONALQUALIFICATION = fc["EDUCATIONALQUALIFICATION"];
            //data.MARITALSTATUS = Convert.ToDecimal(fc["MARITALSTATUS"]);
            //data.SHIFTID = Convert.ToDecimal(fc["ADDITIONAL"]);
            data.EMPTYPEID = Convert.ToInt16(fc["EMPTYPEID"]);
            data.TINNO = fc["TINNO"];
            data.NID = fc["NID"];
            data.RELIGIONID =Convert.ToInt16(fc["RELIGIONID"]);

            //data.PFPARCENT =Convert.ToDecimal(fc["PFPARCENT"]);
            data.EMAIL = fc["EMAIL"];
            //data.DEVISIONID =Convert.ToInt32(fc["DEVISIONID"]);
            //data.HELDUPDATE =Convert.ToDateTime(fc["HELDUPDATE"]);
            //data.NOOfCHIELD = fc["NOOfCHIELD"];
            data.BLOODGROUPID =Convert.ToInt16(fc["BLOODGROUPID"]);
            //data.RGNSUBDATE =Convert.ToDateTime(fc["RGNSUBDATE"]);
            //data.FNFDUESALARY =Convert.ToDecimal(fc["FNFDUESALARY"]);

            //data.FNFCOMPLETE =Convert.ToBoolean(fc["FNFCOMPLETE"]);
            //data.CELLPHONEALLOWANCE =Convert.ToDecimal(fc["CELLPHONEALLOWANCE"]);
            //data.CPALLOWED =Convert.ToBoolean(fc["CPALLOWED"]);
            //data.CELLPHONETYPEID =Convert.ToBoolean(fc["CELLPHONETYPEID"]);
            //data.MOTHERSNAME = fc["MOTHERSNAME"];

            if (image != null)
            {
                data.PHOTO = new byte[image.ContentLength];
                image.InputStream.Read(data.PHOTO, 0, image.ContentLength);
            }                      
            _dbLayer.Update(data);            
            return RedirectToAction("Index");
        }
        public ActionResult Delete(string id)
        {
            _dbLayer.Delete(id);
            return RedirectToAction("Index");
        }
        #endregion
        #region Profile       
        public new ActionResult Profile(string id)
        {
            var emp = _dbLayer.GetEmployee(id).Find(smodel => smodel.EMPLOYEEID == id);
            emp.DepartmentList = new SelectList(bsDepartment.GetDepartment(), "DEPARTMENTID", "DEPARTMENT");
            emp.DesignationList = new SelectList(bsDesignation.DesignationLookUp(), "DESIGNATIONID", "DESIGNATION");
            emp.GenderList = new SelectList(bsGender.GenderLookUp(), "SEXID", "SEXNAME");
            emp.BankList = new SelectList(bsBank.BankLookUp(), "BankId", "BankName");
            emp.BloodList = new SelectList(bsBlood.BloodLookUp(), "BLOODGROUPID", "BLOODGROUPNAME");
            emp.ReligionList = new SelectList(bsReligion.ReligionLookUp(), "RELIGIONID", "RELIGIONNAME");
            //emp.ImageUrl = "data:Image/png;base64"+ Convert.ToBase64String(emp.PHOTO);
            return View(emp);
        }
        [HttpPost]
        public new ActionResult Profile(string id, FormCollection fc)
        {
            EmployeeB data = new EmployeeB();
            data.EMPLOYEEID = fc["EMPLOYEEID"];
            data.EMPLOYEENAME = fc["EMPLOYEENAME"];
            data.SEX = fc["SEX"];
            data.BASICSALARY = Convert.ToDecimal(fc["BASICSALARY"]);
            data.GROSSWAGES = Convert.ToDecimal(fc["GROSSWAGES"]);
            data.ACCOUNTNO = fc["ACCOUNTNO"];
            data.NID = fc["NID"];
            data.DEPARTMENTID = fc["DEPARTMENTID"];
            //data.DESIGNATIONID = fc["DESIGNATIONID"];
            //data.DEPARTMENTID = fc["DEPARTMENTID"];
            //data.EMPPRESADDRESS = fc["EMPPRESADDRESS"];
            _dbLayer.Update(data);
            return RedirectToAction("Index");
        }
        #endregion
        #region Report
        public ActionResult Export()
        {
            ReportDocument rd = new ReportDocument();
            rd.Load(Path.Combine(Server.MapPath("~/Reports/Employee"), "EmployeeList.rpt"));
            //rd.SetDataSource(ListToDataTable(_dbLayer.GetBankListRpt().ToList()));
            rd.SetDataSource(_dbLayer.ReadForPrint());
            Response.Buffer = false;
            Response.ClearContent();
            Response.ClearHeaders();
            try
            {
                Stream stream = rd.ExportToStream(CrystalDecisions.Shared.ExportFormatType.PortableDocFormat);
                stream.Seek(0, SeekOrigin.Begin);
                return File(stream, "application/pdf", "EmployeeList.pdf");
            }
            catch
            {
                throw;
            }
        }
        public ActionResult Print(string id)
        {
            ReportDocument rd = new ReportDocument();
            rd.Load(Path.Combine(Server.MapPath("~/Reports/Employee"), "EmployeeCV.rpt"));
            //rd.SetDataSource(ListToDataTable(_dbLayer.GetBankListRpt().ToList()));
            rd.SetDataSource(_dbLayer.ReadForPrintCV(id));
            Response.Buffer = false;
            Response.ClearContent();
            Response.ClearHeaders();
            try
            {
                Stream stream = rd.ExportToStream(CrystalDecisions.Shared.ExportFormatType.PortableDocFormat);
                stream.Seek(0, SeekOrigin.Begin);
                return File(stream, "application/pdf", "EmployeeCV.pdf");
            }
            catch
            {
                throw;
            }
        }
        #endregion
    }
}