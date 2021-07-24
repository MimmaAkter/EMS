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
    public class BloodDB
    {
        //ODTHelper _ojTc = new ODTHelper();
        OracleConnection constr = new OracleConnection(ConfigurationManager.ConnectionStrings["EMS"].ConnectionString);
        public List<BloodB> BloodLookUp()
        {
            List<BloodB> List = new List<BloodB>();
            //List<SelectListItem> selectListItems = new List<SelectListItem>();
            using (OracleCommand com = new OracleCommand("Select * from T_BLOODGROUP", constr))
            {
                //com.CommandType = CommandType.StoredProcedure;
                //com.Parameters.Add("data_cursor", OracleDbType.RefCursor, DBNull.Value, ParameterDirection.Output);
                using (OracleDataAdapter da = new OracleDataAdapter())
                {
                    com.Connection = constr;
                    constr.Open();
                    da.SelectCommand = com;
                    OracleDataReader dr = com.ExecuteReader();
                    while (dr.Read())
                    {
                        BloodB obj = new BloodB();
                        obj.BLOODGROUPNAME = dr["BLOODGROUPNAME"].ToString();
                        obj.BLOODGROUPID = Convert.ToDecimal(dr["BLOODGROUPID"]);
                        //obj.DEPTGROUPID = Convert.ToInt32(dr.GetInt32("DEPTGROUPID")==0?true:false);
                        List.Add(obj);
                    }
                    //dr.GetValue(0).ToString();                  
                }
                
                return List;
            };
        }       

        #region Conver DataTable into List
        private static List<T> ConvertDataTableToList<T>(DataTable dt)
        {
            List<T> data = new List<T>();
            foreach (DataRow row in dt.Rows)
            {
                T item = GetItem<T>(row);
                data.Add(item);
            }
            return data;
        }
        private static T GetItem<T>(DataRow dr)
        {
            Type temp = typeof(T);
            T obj = Activator.CreateInstance<T>();
            foreach (DataColumn column in dr.Table.Columns)
            {
                foreach (PropertyInfo pro in temp.GetProperties())
                {
                    if (pro.Name == column.ColumnName)
                        pro.SetValue(obj, dr[column.ColumnName], null);
                    else
                        continue;
                }
            }

            return obj;
        }
        #endregion
    }
}