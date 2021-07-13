using EMS.Models.BusinessBase;
using Oracle.ManagedDataAccess.Client;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Reflection;
using System.Web;

namespace EMS.Models.DBLayer
{
    public class DesignationDB
    {
        OracleConnection constr = new OracleConnection(ConfigurationManager.ConnectionStrings["EMS"].ConnectionString);
        public List<DesignationB> DesignationLookUp()
        {
            List<DesignationB> List = new List<DesignationB>();
            using (OracleCommand com = new OracleCommand("GetDesignationLookUp", constr))
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
                        DesignationB obj = new DesignationB();
                        obj.DESIGNATIONID = dr["DESIGNATIONID"].ToString();
                        obj.DESIGNATION = dr["DESIGNATION"].ToString();
                        List.Add(obj);
                    }
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