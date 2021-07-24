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
    public class GenderDB
    {
        //ODTHelper _ojTc = new ODTHelper();
        OracleConnection constr = new OracleConnection(ConfigurationManager.ConnectionStrings["EMS"].ConnectionString);
        public List<GenderB> GenderLookUp()
        {
            List<GenderB> List = new List<GenderB>();
            string query = "select * from T_GENDER";
            using (OracleCommand com = new OracleCommand(query, constr))
            {
                //com.CommandType = CommandType.StoredProcedure;
                //com.Parameters.Add("data_cursor", OracleDbType.RefCursor, DBNull.Value, ParameterDirection.Output);
                com.CommandText = query;
                using (OracleDataAdapter da = new OracleDataAdapter())
                {
                    com.Connection = constr;
                    constr.Open();
                    da.SelectCommand = com;
                    OracleDataReader dr = com.ExecuteReader();
                    while (dr.Read())
                    {
                        GenderB obj = new GenderB();
                        obj.SEXID = dr["SEXID"].ToString();
                        obj.SEXNAME = dr["SEXNAME"].ToString();
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