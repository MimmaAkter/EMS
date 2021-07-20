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
    public class DepartmentDB
    {
        //ODTHelper _ojTc = new ODTHelper();
        OracleConnection constr = new OracleConnection(ConfigurationManager.ConnectionStrings["EMS"].ConnectionString);
        public List<DepartmentB> DepartmentLookUp()
        {
            List<DepartmentB> List = new List<DepartmentB>();
            //List<SelectListItem> selectListItems = new List<SelectListItem>();
            using (OracleCommand com = new OracleCommand("GetDepartmentLookUp", constr))
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
                        DepartmentB obj = new DepartmentB();
                        obj.DEPARTMENT = dr["DEPARTMENT"].ToString();
                        obj.DEPARTMENTID = dr["DEPARTMENTID"].ToString();
                        //obj.DEPTGROUPID = Convert.ToInt32(dr.GetInt32("DEPTGROUPID")==0?true:false);
                        List.Add(obj);
                    }
                    //dr.GetValue(0).ToString();                  
                }
                
                return List;
            };
        }

        public List<DepartmentB> DepartmentRead(DataTable _dtable)
        {
            var _data = _dtable.AsEnumerable();
            var _dataList = _data.Select(s => new DepartmentB
            {
                DEPARTMENTID = s["DEPARTMENTID"].ToString(),
                DEPARTMENT = s["DEPARTMENT"].ToString()
            }).ToList();
            return _dataList;
        }

        public IEnumerable<DepartmentB> GetDepartment()
        {
            string query = "select DEPARTMENTID,DEPARTMENT from T_Department";
            constr.Open();
                OracleCommand cmd = new OracleCommand();
                cmd.Connection = constr;
                cmd.CommandText = query;
                DataSet ds = new DataSet();
                OracleDataAdapter da = new OracleDataAdapter(cmd);
                da.Fill(ds);
                DataTable dt = ds.Tables[0];
                var CList = DepartmentRead(dt);
                constr.Close();
                return CList;         
            
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