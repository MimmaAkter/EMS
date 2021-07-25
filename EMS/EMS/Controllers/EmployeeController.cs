using EMS.Models.BusinessBase;
using EMS.Models.DBLayer;
using System;
using System.Collections.Generic;
using System.Data;
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
            EmployeeB data = new EmployeeB();
            data.EMPLOYEEID = fc["EMPLOYEEID"];
            data.EMPLOYEENAME = fc["EMPLOYEENAME"];
            data.SEX = fc["SEX"];
            data.BASICSALARY = Convert.ToDecimal(fc["BASICSALARY"]);
            data.GROSSWAGES = Convert.ToDecimal(fc["GROSSWAGES"]);
            data.ACCOUNTNO = fc["ACCOUNTNO"];
            data.NID = fc["NID"];
            data.DEPARTMENTID = fc["DEPARTMENTID"];
            if (image != null)
            {
                data.PHOTO = new byte[image.ContentLength];
                image.InputStream.Read(data.PHOTO, 0, image.ContentLength);
            }          
            //data.DESIGNATIONID = fc["DESIGNATIONID"];
            //data.DEPARTMENTID = fc["DEPARTMENTID"];
            //data.EMPPRESADDRESS = fc["EMPPRESADDRESS"];
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
    }
}