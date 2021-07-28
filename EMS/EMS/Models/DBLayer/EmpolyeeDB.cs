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
            cmd.Parameters.Add("EMPLOYEEID", data.EMPLOYEEID);
            cmd.Parameters.Add("EMPLOYEENAME", data.EMPLOYEENAME);
            cmd.Parameters.Add("SPOUSENAME", data.SPOUSENAME);
            cmd.Parameters.Add("FATHERSNAME", data.FATHERSNAME);
            cmd.Parameters.Add("MOTHERSNAME", data.MOTHERSNAME);
            cmd.Parameters.Add("DESIGNATIONID", data.DESIGNATIONID);
            cmd.Parameters.Add("DEPARTMENTID", data.DEPARTMENTID);
            cmd.Parameters.Add("SECTIONID", data.SECTIONID);
            cmd.Parameters.Add("LINEID", data.LINEID);
            cmd.Parameters.Add("GRADE", data.GRADE);
            //cmd.Parameters.Add("pPHOTO", data.PHOTO);
            cmd.Parameters.Add("PHOTO", OracleDbType.Blob).Value = data.PHOTO;

            cmd.Parameters.Add("EMPPASSWORD", data.EMPPASSWORD);
            cmd.Parameters.Add("EMPCONTACTNO", data.EMPCONTACTNO);
            cmd.Parameters.Add("EMPPARADDRESS", data.EMPPARADDRESS);
            cmd.Parameters.Add("EMPPRESADDRESS", data.EMPPRESADDRESS);
            cmd.Parameters.Add("DISBURSEDATE", data.DISBURSEDATE);
            cmd.Parameters.Add("DOB", data.DOB);
            cmd.Parameters.Add("JOININGDATE", data.JOININGDATE);
            cmd.Parameters.Add("PFEFFECTEDDATE", data.PFEFFECTEDDATE);
            cmd.Parameters.Add("DATEOFCONFIRMATRION", data.DATEOFCONFIRMATRION);
            cmd.Parameters.Add("EXPERIENCE", data.EXPERIENCE);

            cmd.Parameters.Add("BASICSALARY", data.BASICSALARY);
            cmd.Parameters.Add("HOUSERENT", data.HOUSERENT);
            cmd.Parameters.Add("MEDICAL", data.MEDICAL);
            cmd.Parameters.Add("PROVIDENTFUND", data.PROVIDENTFUND);
            cmd.Parameters.Add("GROSSWAGES", data.GROSSWAGES);
            cmd.Parameters.Add("SEX", data.SEX);
            cmd.Parameters.Add("SALARYCATEGORY", data.SALARYCATEGORY);
            cmd.Parameters.Add("EMPSTATUS", data.EMPSTATUS);
            cmd.Parameters.Add("STATUS", data.STATUS);
            cmd.Parameters.Add("SHIFTFIXED", data.SHIFTFIXED);

            cmd.Parameters.Add("EMPGROUPID", data.EMPGROUPID);
            cmd.Parameters.Add("RESIGNDATE", data.RESIGNDATE);
            cmd.Parameters.Add("CONVEYANCE", data.CONVEYANCE);
            cmd.Parameters.Add("INCOMETAX", data.INCOMETAX);
            cmd.Parameters.Add("ADVANCE", data.ADVANCE);
            cmd.Parameters.Add("ADDITIONAL", data.ADDITIONAL);
            cmd.Parameters.Add("CARALLOWANCE", data.CARALLOWANCE);
            cmd.Parameters.Add("TOTALADDITION", data.TOTALADDITION);
            cmd.Parameters.Add("PAYMENTTYPEID", data.PAYMENTTYPEID);
            cmd.Parameters.Add("ACCOUNTNO", data.ACCOUNTNO);

            cmd.Parameters.Add("BANKID", data.BANKID);
            cmd.Parameters.Add("BRANCHNAME", data.BRANCHNAME);
            cmd.Parameters.Add("PFCHEQUENO", data.PFCHEQUENO);
            cmd.Parameters.Add("PFCHEQUEDATE", data.PFCHEQUEDATE);
            cmd.Parameters.Add("SITE", data.SITE);
            cmd.Parameters.Add("EMPNO", data.EMPNO);
            cmd.Parameters.Add("PUNCHNO", data.PUNCHNO);
            cmd.Parameters.Add("CARDREGDATE", data.CARDREGDATE);
            cmd.Parameters.Add("ALLOWBMSALARY", data.ALLOWBMSALARY);
            cmd.Parameters.Add("EDUCATIONALQUALIFICATION", data.EDUCATIONALQUALIFICATION);

            cmd.Parameters.Add("MARITALSTATUS", data.MARITALSTATUS);
            cmd.Parameters.Add("SHIFTID", data.SHIFTID);
            cmd.Parameters.Add("EMPTYPEID", data.EMPTYPEID);
            cmd.Parameters.Add("TINNO", data.TINNO);
            cmd.Parameters.Add("NID", data.NID);
            cmd.Parameters.Add("RELIGIONID", data.RELIGIONID);
            cmd.Parameters.Add("PFPARCENT", data.PFPARCENT);
            cmd.Parameters.Add("EMAIL", data.EMAIL);
            cmd.Parameters.Add("DEVISIONID", data.DEVISIONID);
            cmd.Parameters.Add("HELDUPDATE", data.HELDUPDATE);

            cmd.Parameters.Add("NOOFCHIELD", data.NOOFCHIELD);
            cmd.Parameters.Add("BLOODGROUPID", data.BLOODGROUPID);
            cmd.Parameters.Add("RESIGNDATE", data.RESIGNDATE);
            cmd.Parameters.Add("FNFDUESALARY", data.FNFDUESALARY);
            cmd.Parameters.Add("FNFCOMPLETE", data.FNFCOMPLETE);
            cmd.Parameters.Add("CELLPHONEALLOWANCE", data.CELLPHONEALLOWANCE);
            cmd.Parameters.Add("CPALLOWED", data.CPALLOWED);
            cmd.Parameters.Add("CELLPHONETYPEID", data.CELLPHONETYPEID);
            
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
        public List<EmployeeB> GetEmployee(string id)
        {
            //connection();
            List<EmployeeB> employeelist = new List<EmployeeB>();

            OracleCommand cmd = new OracleCommand("GetEmployeeInfo", constr);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Add("pEmployeeID", OracleDbType.Varchar2).Value = id;
            cmd.Parameters.Add("one_cursor", OracleDbType.RefCursor, DBNull.Value, ParameterDirection.Output);
            //cmd.Parameters.Add("many_cursor", OracleDbType.RefCursor, DBNull.Value, ParameterDirection.Output);
            OracleDataAdapter sd = new OracleDataAdapter(cmd);
            DataTable dt = new DataTable();

            constr.Open();
            sd.Fill(dt);
            constr.Close();

            foreach (DataRow dr in dt.Rows)
            {
                byte[] _photo = null;
                if (!Convert.IsDBNull(dr["PHOTO"]))
                {
                    _photo = (byte[])dr["PHOTO"];
                }
                employeelist.Add(
                    new EmployeeB
                    {
                        //EMPLOYEEID = dr["EMPLOYEEID"] == DBNull.Value ? string.Empty : Convert.ToString(dr["EMPLOYEEID"]),
                        ////(_dob.Text == string.Empty ? "NULL" : "'" + _dob.Date.ToString("dd-MMM-yyyy") + "'") +
                        //EMPLOYEENAME = dr["EMPLOYEENAME"] == DBNull.Value ? string.Empty : Convert.ToString(dr["EMPLOYEENAME"]),
                        //DEPARTMENTID = dr["DEPARTMENTID"] == DBNull.Value ? string.Empty : Convert.ToString(dr["DEPARTMENTID"]),
                        DESIGNATIONID = Convert.ToString(dr["DESIGNATIONID"]),
                        EMPCONTACTNO = Convert.ToString(dr["EMPCONTACTNO"]),
                        EMPLOYEEID = Convert.ToString(dr["EMPLOYEEID"]),
                        //(_dob.Text == string.Empty ? "NULL" : "'" + _dob.Date.ToString("dd-MMM-yyyy") + "'") +
                        EMPLOYEENAME = Convert.ToString(dr["EMPLOYEENAME"]),
                        DEPARTMENTID = Convert.ToString(dr["DEPARTMENTID"]),
                        EMPPARADDRESS = Convert.ToString(dr["EMPPARADDRESS"]),
                        EMPPRESADDRESS = Convert.ToString(dr["EMPPRESADDRESS"]),
                        EXPERIENCE = Convert.ToString(dr["EXPERIENCE"]),
                        ACCOUNTNO = Convert.ToString(dr["ACCOUNTNO"]),
                        BANKID = Convert.ToString(dr["BANKID"]),
                        BASICSALARY = Convert.ToDecimal(dr["BASICSALARY"]),
                        BLOODGROUPID = Convert.ToInt16(dr["BLOODGROUPID"]),
                        DOB = Convert.ToDateTime(dr["DOB"]),
                        FATHERSNAME = Convert.ToString(dr["FATHERSNAME"]),
                        MOTHERSNAME = Convert.ToString(dr["MOTHERSNAME"]),
                        SPOUSENAME = Convert.ToString(dr["SPOUSENAME"]),
                        HOUSERENT = Convert.ToDecimal(dr["HOUSERENT"]),
                        GROSSWAGES = Convert.ToDecimal(dr["GROSSWAGES"]),
                        NID = Convert.ToString(dr["NID"]),
                        SEX = dr["SEX"] == DBNull.Value ? string.Empty : Convert.ToString(dr["SEX"]),
                        RELIGIONID = Convert.ToInt16(dr["RELIGIONID"]),
                        MEDICAL = Convert.ToDecimal(dr["MEDICAL"]),
                        ServiceLength = Convert.ToString(dr["ServiceLength"]),
                        JOININGDATE = Convert.ToDateTime(dr["JOININGDATE"]),
                        //RGNSUBDATE = Convert.ToDateTime(dr["RGNSUBDATE"]) == string.Empty ? null : Convert.ToDateTime(dr["RGNSUBDATE"]),
                        EMPPASSWORD = Convert.ToString(dr["EMPPASSWORD"]),
                        EMPSTATUS = Convert.ToString(dr["EMPSTATUS"]),
                        //ImageUrl = "data:Image/png;base64" + Convert.ToBase64String(PHOTO)
                        //PHOTO = dr["PHOTO"] is DBNull ? null : Convert.tois(dr["PHOTO"])
                        PHOTO=_photo
                       //Convert.IsDBNull((byte[])dr["PHOTO"])=
                        //RESIGNDATE = Convert.ToDateTime(dr["RESIGNDATE"])

                    });
            }
            return employeelist;
        }


        //public List<EmployeeB> DepartmentLookUp()
        //{
        //    List<EmployeeB> List = new List<EmployeeB>();
        //    using (OracleCommand com = new OracleCommand("GetDepartmentLookUp", constr))
        //    {
        //        com.CommandType = CommandType.StoredProcedure;
        //        com.Parameters.Add("data_cursor", OracleDbType.RefCursor, DBNull.Value, ParameterDirection.Output);
        //        using (OracleDataAdapter da = new OracleDataAdapter())
        //        {
        //            com.Connection = constr;
        //            constr.Open();
        //            da.SelectCommand = com;
        //            OracleDataReader dr = com.ExecuteReader();
        //            while (dr.Read())
        //            {
        //                EmployeeB obj = new EmployeeB();
        //                obj.DEPARTMENT = dr["DEPARTMENT"].ToString();
        //                obj.DEPARTMENTID = dr["DEPARTMENTID"].ToString();
        //                List.Add(obj);
        //            }
        //        }
        //        return List;
        //    };
        //}

        public void Update(EmployeeB data)
        {
            OracleCommand cmd = new OracleCommand("UpdateEmployee", constr);
            cmd.CommandType = CommandType.StoredProcedure;
            //com.Parameters.Add("data_cursor", OracleDbType.RefCursor, DBNull.Value, ParameterDirection.Output);
            cmd.Parameters.Add("pEMPLOYEEID", OracleDbType.Varchar2).Value = data.EMPLOYEEID;
            //cmd.Parameters.Add("EMPLOYEEID", data.EMPLOYEEID);
            cmd.Parameters.Add("pEMPLOYEENAME", data.EMPLOYEENAME);           
            //=============================================================
            //cmd.Parameters.Add("pSEX", data.SEX);
            //cmd.Parameters.Add("pGROSSWAGES", data.GROSSWAGES);
            //cmd.Parameters.Add("pACCOUNTNO", data.ACCOUNTNO);
            //cmd.Parameters.Add("pNID", data.NID);
            //cmd.Parameters.Add("pBASICSALARY", data.BASICSALARY);
            //============================================================
            cmd.Parameters.Add("pSPOUSENAME", data.SPOUSENAME);
            cmd.Parameters.Add("pFATHERSNAME", data.FATHERSNAME);
            cmd.Parameters.Add("pMOTHERSNAME", data.MOTHERSNAME);
            cmd.Parameters.Add("pDESIGNATIONID", data.DESIGNATIONID);
            cmd.Parameters.Add("pDEPARTMENTID", data.DEPARTMENTID);
            //cmd.Parameters.Add("SECTIONID", data.SECTIONID);
            //cmd.Parameters.Add("LINEID", data.LINEID);
            //cmd.Parameters.Add("GRADE", data.GRADE);
            //cmd.Parameters.Add("pPHOTO", data.PHOTO);
            cmd.Parameters.Add("pPHOTO", OracleDbType.Blob).Value = data.PHOTO;

            cmd.Parameters.Add("pEMPPASSWORD", data.EMPPASSWORD);
            cmd.Parameters.Add("pEMPCONTACTNO", data.EMPCONTACTNO);
            cmd.Parameters.Add("pEMPPARADDRESS", data.EMPPARADDRESS);
            cmd.Parameters.Add("pEMPPRESADDRESS", data.EMPPRESADDRESS);
            //cmd.Parameters.Add("DISBURSEDATE", data.DISBURSEDATE);
            cmd.Parameters.Add("pDOB", data.DOB);
            cmd.Parameters.Add("pJOININGDATE", data.JOININGDATE);
            cmd.Parameters.Add("pPFEFFECTEDDATE", data.PFEFFECTEDDATE);
            //cmd.Parameters.Add("DATEOFCONFIRMATRION", data.DATEOFCONFIRMATRION);
            cmd.Parameters.Add("pEXPERIENCE", data.EXPERIENCE);

            cmd.Parameters.Add("pBASICSALARY", data.BASICSALARY);
            cmd.Parameters.Add("pHOUSERENT", data.HOUSERENT);
            cmd.Parameters.Add("pMEDICAL", data.MEDICAL);
            cmd.Parameters.Add("pPROVIDENTFUND", data.PROVIDENTFUND);
            cmd.Parameters.Add("pGROSSWAGES", data.GROSSWAGES);
            cmd.Parameters.Add("pSEX", data.SEX);
            //cmd.Parameters.Add("SALARYCATEGORY", data.SALARYCATEGORY);
            cmd.Parameters.Add("pEMPSTATUS", data.EMPSTATUS);
            //cmd.Parameters.Add("STATUS", data.STATUS);
            //cmd.Parameters.Add("SHIFTFIXED", data.SHIFTFIXED);

            //cmd.Parameters.Add("EMPGROUPID", data.EMPGROUPID);
            cmd.Parameters.Add("pRESIGNDATE", data.RESIGNDATE);
            cmd.Parameters.Add("pCONVEYANCE", data.CONVEYANCE);
            //cmd.Parameters.Add("INCOMETAX", data.INCOMETAX);
            //cmd.Parameters.Add("ADVANCE", data.ADVANCE);
            //cmd.Parameters.Add("ADDITIONAL", data.ADDITIONAL);
            //cmd.Parameters.Add("CARALLOWANCE", data.CARALLOWANCE);
            //cmd.Parameters.Add("TOTALADDITION", data.TOTALADDITION);
            cmd.Parameters.Add("pPAYMENTTYPEID", data.PAYMENTTYPEID);
            cmd.Parameters.Add("pACCOUNTNO", data.ACCOUNTNO);

            cmd.Parameters.Add("pBANKID", data.BANKID);
            cmd.Parameters.Add("pBRANCHNAME", data.BRANCHNAME);
            //cmd.Parameters.Add("PFCHEQUENO", data.PFCHEQUENO);
            //cmd.Parameters.Add("PFCHEQUEDATE", data.PFCHEQUEDATE);
            //cmd.Parameters.Add("SITE", data.SITE);
            //cmd.Parameters.Add("EMPNO", data.EMPNO);
            //cmd.Parameters.Add("PUNCHNO", data.PUNCHNO);
            //cmd.Parameters.Add("CARDREGDATE", data.CARDREGDATE);
            //cmd.Parameters.Add("ALLOWBMSALARY", data.ALLOWBMSALARY);
            cmd.Parameters.Add("pEDUCATIONALQUALIFICATION", data.EDUCATIONALQUALIFICATION);

            //cmd.Parameters.Add("MARITALSTATUS", data.MARITALSTATUS);
            //cmd.Parameters.Add("SHIFTID", data.SHIFTID);
            //cmd.Parameters.Add("EMPTYPEID", data.EMPTYPEID);
            //cmd.Parameters.Add("TINNO", data.TINNO);
            cmd.Parameters.Add("pNID", data.NID);
            cmd.Parameters.Add("pRELIGIONID", data.RELIGIONID);
            //cmd.Parameters.Add("PFPARCENT", data.PFPARCENT);
            cmd.Parameters.Add("pEMAIL", data.EMAIL);
            //cmd.Parameters.Add("DEVISIONID", data.DEVISIONID);
            //cmd.Parameters.Add("HELDUPDATE", data.HELDUPDATE);

            //cmd.Parameters.Add("NOOFCHIELD", data.NOOFCHIELD);
            cmd.Parameters.Add("pBLOODGROUPID", data.BLOODGROUPID);
            //cmd.Parameters.Add("RGNSUBDATE", data.RGNSUBDATE);
            //cmd.Parameters.Add("FNFDUESALARY", data.FNFDUESALARY);
            //cmd.Parameters.Add("FNFCOMPLETE", data.FNFCOMPLETE);
            //cmd.Parameters.Add("CELLPHONEALLOWANCE", data.CELLPHONEALLOWANCE);
            //cmd.Parameters.Add("CPALLOWED", data.CPALLOWED);
            //cmd.Parameters.Add("CELLPHONETYPEID", data.CELLPHONETYPEID);

            //cmd.Parameters.Add("EMPLOYEEID", OracleDbType.Varchar2).Value = data.EMPLOYEEID;

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

        #region ReadReport

        [Serializable()]
        private class Criteria
        {
            private short _querytype = -1;
            private short _empGroup = -1;
            public short QueryType
            {
                get { return _querytype; }
            }
            public short EmpGroup
            {
                get { return _empGroup; }
            }


            public Criteria(short querytype, short empGroup)
            { _querytype = querytype; _empGroup = empGroup; }
        }
        public DataTable ReadForPrint()
        {
            OracleCommand com = new OracleCommand("RptEmployeeList", constr);
            com.CommandType = CommandType.StoredProcedure;
            com.Parameters.Add("data_cursor", OracleDbType.RefCursor, DBNull.Value, ParameterDirection.Output);
            //com.Parameters.Add("pEmployeeID", OracleDbType.Varchar2).Value = id;
            //com.Parameters.Add("pStatus", 10);
            //com.Parameters.Add("pEmpGroup", OracleDbType.Int16, _Cri.EmpGroup, ParameterDirection.Input);
            //com.Parameters.Add("pReturnData", 1);
            OracleDataAdapter da = new OracleDataAdapter(com);
            //DataTable dt = new DataTable();
            DataTable ds = new DataTable();
            da.Fill(ds);
            return ds;
        }

        public DataTable ReadForPrintCV(string id)
        {
            OracleCommand com = new OracleCommand("GetEmployeeCV", constr);
            com.CommandType = CommandType.StoredProcedure;
            com.Parameters.Add("data_cursor", OracleDbType.RefCursor, DBNull.Value, ParameterDirection.Output);
            com.Parameters.Add("pStatus", OracleDbType.Int16, 0, ParameterDirection.Input);
            com.Parameters.Add("pEmployeeID", OracleDbType.Varchar2, id, ParameterDirection.Input);
            //com.Parameters.Add("pEmployeeID", OracleDbType.Varchar2).Value = id;
            //com.Parameters.Add("pStatus", 10);
            //com.Parameters.Add("pEmpGroup", OracleDbType.Int16, _Cri.EmpGroup, ParameterDirection.Input);
            //com.Parameters.Add("pReturnData", 1);
            OracleDataAdapter da = new OracleDataAdapter(com);
            //DataTable dt = new DataTable();
            DataTable ds = new DataTable();
            da.Fill(ds);
            return ds;
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