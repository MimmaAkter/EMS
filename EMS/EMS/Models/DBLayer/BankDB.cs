using EMS.Models.BusinessBase;
using Oracle.ManagedDataAccess.Client;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Reflection;
using System.Web;
using System.Web.Mvc;
//using CDTypeHelper;

namespace EMS.Models.DBLayer
{
    public class BankDB
    {
        //ODTHelper _ojTc = new ODTHelper();
        OracleConnection constr = new OracleConnection(ConfigurationManager.ConnectionStrings["EMS"].ConnectionString);
        public List<BankB> BankLookUp()
        {
            List<BankB> List = new List<BankB>();
            //List<SelectListItem> selectListItems = new List<SelectListItem>();
            using (OracleCommand com = new OracleCommand("GetBankList", constr))
            {
                com.CommandType = CommandType.StoredProcedure;
                com.Parameters.Add("data_cursor", OracleDbType.RefCursor, DBNull.Value, ParameterDirection.Output);
                using (OracleDataAdapter da = new OracleDataAdapter())
                {
                    com.Connection = constr;
                    constr.Open();
                    da.SelectCommand = com;
                    OracleDataReader dr = com.ExecuteReader();
                    while (dr.Read())
                    {
                        BankB obj = new BankB();
                        obj.BANKNAME = dr["BankName"].ToString();
                        obj.BANKID = dr["BankId"].ToString();
                        //obj.DEPTGROUPID = Convert.ToInt32(dr.GetInt32("DEPTGROUPID")==0?true:false);
                        List.Add(obj);
                    }
                    //dr.GetValue(0).ToString();                  
                }
                
                return List;
            };
        }
       
    }
}