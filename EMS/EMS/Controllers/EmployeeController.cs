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
        #endregion

        #region CRUD
        public ActionResult Index()
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

            return View();
        }
        [HttpPost]
        public ActionResult Create(HttpPostedFileBase image, FormCollection fc)
        {           
            ViewBag.DEPARTMENTID = new SelectList(bsDepartment.DepartmentLookUp(), "DepartmentID", "Department");
            ViewBag.DESIGNATIONID = new SelectList(bsDesignation.DesignationLookUp(), "DESIGNATIONID", "DESIGNATION");

            EmployeeB data = new EmployeeB();
            data.EMPLOYEEID = fc["EMPLOYEEID"];
            data.EMPLOYEENAME = fc["EMPLOYEENAME"];
            data.SEX = fc["SEX"];
            data.BASICSALARY = Convert.ToDecimal(fc["BASICSALARY"]);
            data.GROSSWAGES = Convert.ToDecimal(fc["GROSSWAGES"]);
            data.ACCOUNTNO = fc["ACCOUNTNO"];
            data.NID = fc["NID"];
            data.DESIGNATIONID = fc["DESIGNATIONID"];
            data.DEPARTMENTID = fc["DEPARTMENTID"];
            data.EMPPRESADDRESS = fc["EMPPRESADDRESS"];
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
            var emp = _dbLayer.GetStudent().Find(smodel => smodel.EMPLOYEEID == id);
            emp.DepartmentList= new SelectList(bsDepartment.GetDepartment(), "DEPARTMENTID", "DEPARTMENT");
            return View("Update",emp);
        }
        [HttpPost]
        public ActionResult Update(string id, FormCollection fc)
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
        public ActionResult Delete(string id)
        {
            _dbLayer.Delete(id);
            return RedirectToAction("Index");
        }
        #endregion
    }
}