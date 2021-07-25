using EMS.Models.BusinessBase;
using EMS.Models.DBLayer;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace EMS.Controllers
{
    public class LoginController : Controller
    {
        // GET: Login
        #region Initialiation
        EmployeeDB _dbLayer = new EmployeeDB();
        EmployeeB user = new EmployeeB();
        #endregion
        public ActionResult Login()
        {
            return View();
        }
        [HttpPost]
        public ActionResult Login(FormCollection fc)
        {           
            user.EMPLOYEEID = fc["EMPLOYEEID"].ToUpper();
            user.EMPPASSWORD = fc["EMPPASSWORD"];
            List<EmployeeB> validUser = _dbLayer.Valid(user);
            if (validUser.Count == 0)
            {
                return RedirectToAction("Login", "Login");
            }
            else
            {
                Session["USERID"] = user.EMPLOYEEID;
                Session["USERNAME"] = user.EMPLOYEENAME;
                //Session["PHOTO"] = user.PHOTO;
                return RedirectToAction("Index", "Employee");                           
            }
        }
        public ActionResult Logout()
        {
            string userid = (string)Session["USERID"];
            Session.Abandon();
            return RedirectToAction("Index", "Home");
        }
    }
}