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

    }
}