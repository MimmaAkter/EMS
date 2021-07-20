using EMS.Models.BusinessBase;
using Oracle.ManagedDataAccess.Client;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Web;

namespace EMS.Models.DBLayer
{
    public class EmployeeDB
    {
        OracleConnection constr = new OracleConnection(ConfigurationManager.ConnectionStrings["EMS"].ConnectionString);
        #region Data Access CRUD
        public void Create(EmployeeB data)
        {
            OracleCommand cmd = new OracleCommand("INSERTEMPLOYEE", constr);
            cmd.CommandType = CommandType.StoredProcedure;
            //com.Parameters.Add("data_cursor", OracleDbType.RefCursor, DBNull.Value, ParameterDirection.Output);
            cmd.Parameters.Add("pEMPLOYEEID", data.EMPLOYEEID);
            cmd.Parameters.Add("pEMPLOYEENAME", data.EMPLOYEENAME);
            cmd.Parameters.Add("pSEX", data.SEX);
            cmd.Parameters.Add("pBASICSALARY", data.BASICSALARY);
            cmd.Parameters.Add("pGROSSWAGES", data.GROSSWAGES);
            cmd.Parameters.Add("pACCOUNTNO", data.ACCOUNTNO);
            cmd.Parameters.Add("pNID", data.NID);
            cmd.Parameters.Add("pDESIGNATIONID", data.DESIGNATIONID);
            cmd.Parameters.Add("pDEPARTMENTID", data.DEPARTMENTID);
            cmd.Parameters.Add("pEMPPRESADDRESS", data.EMPPRESADDRESS);
            //cmd.Parameters.Add("pPHOTO", data.PHOTO);
            cmd.Parameters.Add("pPHOTO", OracleDbType.Blob).Value = data.PHOTO;            
            constr.Open();
            cmd.ExecuteNonQuery();
            constr.Close();
        }

        public DataSet Read()
        {
            OracleCommand com = new OracleCommand("GetEmployeeList", constr);
            com.CommandType = CommandType.StoredProcedure;
            com.Parameters.Add("data_cursor", OracleDbType.RefCursor, DBNull.Value, ParameterDirection.Output);
            //com.Parameters.Add("pReturnData", 1);
            OracleDataAdapter da = new OracleDataAdapter(com);
            //DataTable dt = new DataTable();
            DataSet ds = new DataSet();
            da.Fill(ds);
            return ds;
        }

        public DataSet Edit(string id)
        {
            OracleCommand cmd = new OracleCommand("GetEmployeeInfo", constr);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Add("pEmployeeID", OracleDbType.Varchar2).Value = id;
            cmd.Parameters.Add("one_cursor", OracleDbType.RefCursor, DBNull.Value, ParameterDirection.Output);
            cmd.Parameters.Add("many_cursor", OracleDbType.RefCursor, DBNull.Value, ParameterDirection.Output);
            OracleDataAdapter da = new OracleDataAdapter(cmd);            
            DataSet ds = new DataSet();
            da.Fill(ds);
            return ds;
        }
        public List<EmployeeB> GetStudent()
        {
            //connection();
            List<EmployeeB> studentlist = new List<EmployeeB>();

            OracleCommand cmd = new OracleCommand("GetEmployeeList", constr);
            cmd.CommandType = CommandType.StoredProcedure;
            //cmd.Parameters.Add("pEmployeeID", OracleDbType.Varchar2).Value = id;
            cmd.Parameters.Add("one_cursor", OracleDbType.RefCursor, DBNull.Value, ParameterDirection.Output);
            //cmd.Parameters.Add("many_cursor", OracleDbType.RefCursor, DBNull.Value, ParameterDirection.Output);
            OracleDataAdapter sd = new OracleDataAdapter(cmd);
            DataTable dt = new DataTable();

            constr.Open();
            sd.Fill(dt);
            constr.Close();

            foreach (DataRow dr in dt.Rows)
            {
                studentlist.Add(
                    new EmployeeB
                    {
                        EMPLOYEEID = Convert.ToString(dr["EMPLOYEEID"]),
                        EMPLOYEENAME = Convert.ToString(dr["EMPLOYEENAME"]),
                        DEPARTMENTID = Convert.ToString(dr["DEPARTMENTID"]),
                        ACCOUNTNO = Convert.ToString(dr["ACCOUNTNO"])
                    });
            }
            return studentlist;
        }


        public List<EmployeeB> DepartmentLookUp()
        {
            List<EmployeeB> List = new List<EmployeeB>();
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
                        EmployeeB obj = new EmployeeB();
                        obj.DEPARTMENT = dr["DEPARTMENT"].ToString();
                        obj.DEPARTMENTID = dr["DEPARTMENTID"].ToString();
                        List.Add(obj);
                    }
                }
                return List;
            };
        }

        public void Update(EmployeeB data)
        {
            OracleCommand cmd = new OracleCommand("UpdateEmployee", constr);
            cmd.CommandType = CommandType.StoredProcedure;
            //com.Parameters.Add("data_cursor", OracleDbType.RefCursor, DBNull.Value, ParameterDirection.Output);
            cmd.Parameters.Add("pEMPLOYEEID", OracleDbType.Varchar2).Value = data.EMPLOYEEID;
            //cmd.Parameters.Add("pEMPLOYEEID", data.EMPLOYEEID);
            cmd.Parameters.Add("pEMPLOYEENAME", data.EMPLOYEENAME);
            cmd.Parameters.Add("pSEX", data.SEX);
            cmd.Parameters.Add("pBASICSALARY", data.BASICSALARY);
            cmd.Parameters.Add("pGROSSWAGES", data.GROSSWAGES);
            cmd.Parameters.Add("pACCOUNTNO", data.ACCOUNTNO);
            cmd.Parameters.Add("pNID", data.NID);
            cmd.Parameters.Add("pDEPARTMENTID", data.DEPARTMENTID);
            //cmd.Parameters.Add("pDESIGNATIONID", data.DESIGNATIONID);
            //cmd.Parameters.Add("pDEPARTMENTID", data.DEPARTMENTID);
            //cmd.Parameters.Add("pEMPPRESADDRESS", data.EMPPRESADDRESS);
            constr.Open();
            cmd.ExecuteNonQuery();
            constr.Close();
        }
        public void Delete(string id)
        {
            OracleCommand cmd = new OracleCommand("DeleteEmployee", constr);
            cmd.CommandType = CommandType.StoredProcedure;
            //com.Parameters.Add("data_cursor", OracleDbType.RefCursor, DBNull.Value, ParameterDirection.Output);
            cmd.Parameters.Add("pEMPLOYEEID", OracleDbType.Varchar2).Value = id;
            constr.Open();
            cmd.ExecuteNonQuery();
            constr.Close();
        }
        #endregion

        #region Valid Login
        public List<EmployeeB> Valid(EmployeeB obj)
        {
            List<EmployeeB> List = new List<EmployeeB>();
            using (OracleCommand cmd = new OracleCommand("CheckEmployee", constr))
            {
                //EmployeeB obj = new EmployeeB();
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("data_cursor", OracleDbType.RefCursor, DBNull.Value, ParameterDirection.Output);
                cmd.Parameters.Add("pEmployeeid", OracleDbType.Varchar2).Value = obj.EMPLOYEEID;
                cmd.Parameters.Add("pEMPPASSWORD", OracleDbType.Varchar2).Value = obj.EMPPASSWORD;
                using (OracleDataAdapter da = new OracleDataAdapter())
                {
                    cmd.Connection = constr;
                    constr.Open();
                    da.SelectCommand = cmd;
                    OracleDataReader dr = cmd.ExecuteReader();
                    while (dr.Read())
                    {
                        obj.EMPLOYEEID = dr["EMPLOYEEID"].ToString();
                        obj.EMPPASSWORD = dr["EMPPASSWORD"].ToString();
                        obj.EMPLOYEENAME = dr["EMPLOYEENAME"].ToString();
                        List.Add(obj);
                    }
                }
                return List;
            };
        }
        #endregion

        #region List Converter
        public List<EmployeeB> GetEmployeeBList()
        {
            DataTable ResultDT = new DataTable();
            //ResultDT = _DataBAL; // Call BusinessLogic to fill DataTable, Here your ResultDT will get the result in which you will be having single or multiple rows with columns "EmployeeBId,RoleNumber and Name"  
            List<EmployeeB> EmployeeBlist = new List<EmployeeB>();
            EmployeeBlist = ConvertToList<EmployeeB>(ResultDT);
            
            return EmployeeBlist;
        }
        public static List<T> ConvertToList<T>(DataTable dt)
            {
                var columnNames = dt.Columns.Cast<DataColumn>().Select(c => c.ColumnName.ToLower()).ToList();
                var properties = typeof(T).GetProperties();
                return dt.AsEnumerable().Select(row => {
                    var objT = Activator.CreateInstance<T>();
                    foreach (var pro in properties)
                    {
                        if (columnNames.Contains(pro.Name.ToLower()))
                        {
                            try
                            {
                                pro.SetValue(objT, row[pro.Name]);
                            }
                            catch (Exception ex) { }
                        }
                    }
                    return objT;
                }).ToList();
            }
        #endregion

    }
}