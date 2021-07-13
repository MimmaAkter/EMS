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
        public ActionResult Update(string id)
        {
            ViewBag.DEPARTMENTID = new SelectList(bsDepartment.DepartmentLookUp(), "DepartmentID", "Department");
            ViewBag.DESIGNATIONID = new SelectList(bsDesignation.DesignationLookUp(), "DESIGNATIONID", "DESIGNATION");

            DataSet ds = _dbLayer.Edit(id);
            ViewBag.data = ds.Tables[0];
            
            return View();
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