PROMPT CREATE OR REPLACE PACKAGE  001 :: PACKAGE
CREATE OR REPLACE PACKAGE pReturnData AS
	TYPE c_Records IS REF CURSOR;
END pReturnData;
/

PROMPT CREATE OR REPLACE Procedure  002 :: ExecuteSQL
CREATE OR REPLACE Procedure ExecuteSQL
(
  pStrSql IN VARCHAR2,
  pRecsAffected out NUMBER
)
AS
  insertSql VARCHAR2(1000);
BEGIN
  insertSql :=pStrSql ;
  execute immediate insertSql;
  pRecsAffected := SQL%ROWCOUNT;
END ExecuteSQL;
/

PROMPT CREATE OR REPLACE Procedure  003 :: GetAutoGenerate   
CREATE OR REPLACE Procedure GetAutoGenerate
(
  pIdentityName IN VARCHAR2,
  pIdentityFld IN VARCHAR2,
  pWhere       IN VARCHAR2,
  pIdentityValue out number
  )
AS
  tmpID VARCHAR2(20);

BEGIN
	execute immediate 'select '||  pIdentityFld || ' into ' ||tmpID||'  from '|| pIdentityName || ' WHERE  '|| pIdentityFld ||' =' ||pWhere
	into tmpID;

	if tmpID ='' then
	   pIdentityValue:=0;
	elsif tmpID <>'' then
	   pIdentityValue:=1;
	end if;
END GetAutoGenerate;
/
PROMPT CREATE OR REPLACE Procedure  004 :: GetAuxForIDs
CREATE OR REPLACE Procedure GetAuxForIDs
(
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN

    OPEN data_cursor for
    Select AuxFor, AuxForID from T_AuxFor;

END;
/
PROMPT CREATE OR REPLACE Procedure  005 :: GetAuxiliariesLookUp
CREATE OR REPLACE Procedure GetAuxiliariesLookUp
(
  pStatus number,
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)

AS

BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=0 then
  OPEN data_cursor for
   select AUXID,AUXNAME
	from t_auxiliaries order by AUXNAME;

/*If the Value is 1 then retun as the */

elsif pStatus=1 then
  OPEN data_cursor for
  select AUXID,AUXNAME
	from t_auxiliaries where AUXID=pWhereValue order by AUXNAME;
end if;
END GetAuxiliariesLookUp;
/

PROMPT CREATE OR REPLACE Procedure  006 :: GETAuxImpLCInfo
CREATE OR REPLACE Procedure GETAuxImpLCInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  many_cursor IN OUT pReturnData.c_Records,
  pLCNumber IN NUMBER
)
AS
BEGIN
  open one_cursor for
  select LCNo, BankLCNo, OpeningDate, SupplierID, CurrencyId, ConRate,ExpLCNo, ShipmentDate,
  DocRecDate, DocRelDate, GoodsRecDate, ImpLCStatusId, BankCharge, Insurance,
  TruckFair, CNFValue, OtherCharge, Remarks, ShipDate, Cancelled,Lcmaturityperiod,ImpLctypeid
  from T_AuxImpLC
  where LCNo=pLCNumber;

  open many_cursor for
  select PID,a.AuxTypeId, a.AuxId, b.DyeBaseID ,
  a.Qty, UnitPrice, ValueFC, ValueTk, ValueBank,
  ValueInsurance, ValueTruck, ValueCNF, ValueOther, TotCost, UnitCost
  FROM T_AuxImpLCItems a, T_Auxiliaries b
  where a.AuxId=b.AuxId and
  LCNo=pLCNumber order by PID;
END GETAuxImpLCInfo;
/

PROMPT CREATE OR REPLACE Procedure  007 :: GETAUXINFO 
CREATE OR REPLACE Procedure GETAUXINFO
(
  one_cursor IN OUT pReturnData.c_Records,
  many_cursor IN OUT pReturnData.c_Records,
  pAuxID number,
  pAuxTypeId number
)
AS
BEGIN
    open one_cursor for
    select AuxTypeID, AuxId, AuxName, AuxForId, DyeBaseID, UnitOfMeasID,AuxUnitPrice,RecipeSheetSeq, Qty, Amount, WAvgPrice
    from T_Auxiliaries
    where AuxID=pAuxID and AuxTypeId=pAuxTypeId;
    open many_cursor for
    select a.PID,a.AuxId,p.AuxName,a.AuxTypeID,b.SUPPLIERNAME,a.supplierid,a.currencyid, a.PurchaseDate,a.UnitPrice,a.Qty,c.Currencyname,a.conrate,decode(a.unitprice,0,0,round((a.unitprice/a.CONRATE),2)) as funitprice,a.unitprice
    from T_AuxPrice a,T_supplier b,T_Currency c,T_Auxiliaries p
    where a.AuxID=p.AuxID and
	a.AuxID=pAuxID and
	  a.currencyid=c.currencyid(+) and
	  a.supplierid=b.supplierid(+) and
	 a.AuxTypeId=pAuxTypeId
	 Order by a.PurchaseDate Desc;
END GETAUXINFO;
/ 

PROMPT CREATE OR REPLACE Procedure  008 :: GetAuxLookup
CREATE OR REPLACE Procedure GetAuxLookup
(
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN

  OPEN data_cursor for
  select AUXTYPEID, DYEBASEID, AUXID, AUXNAME from T_Auxiliaries ORDER BY AUXNAME;

END GetAuxLookup;
/


PROMPT CREATE OR REPLACE Procedure  009 :: GETAuxStockInfo
CREATE OR REPLACE Procedure GETAuxStockInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  many_cursor IN OUT pReturnData.c_Records,
  pAuxStockID number
)
AS
BEGIN
    open one_cursor for
    select AuxStockTypeID, AuxStockId, STOCKINVOICENO, STOCKDATE, PURCHASEORDERNO,
    PURCHASEORDERDATE,SUPPLIERID,DELIVERYNOTE,DELIVERYNOTEDATE,SUBCONID,sCOMPLETE,
    CURRENCYID,CONRATE
    from t_auxStock
    where AuxStockId=pAuxStockID;
    open many_cursor for
    select a.AUXSTOCKID,a.AUXSTOCKSL,a.PID,a.AUXTYPEID,b.DYEBASEID,c.AuxStockTypeID,
    a.AUXID,a.STOCKREQQTY,a.STOCKQTY,a.STOREFOLIO,a.REMARKS,a.UNITPRICE,a.SUPPLIERID,a.CURRENTSTOCK
    from T_AuxStockItem a, T_Auxiliaries b,t_auxStock c
    where a.AuxId=b.AuxId and
	c.AuxStockId=a.AuxStockId and 
    a.AUXSTOCKID=pAuxStockID order by AUXSTOCKSL;
END GETAuxStockInfo;
/




PROMPT CREATE OR REPLACE Procedure  010 :: GetAuxStockItem
CREATE OR REPLACE Procedure GetAuxStockItem
(
  data_cursor IN OUT pReturnData.c_Records,
  pAuxStockID varchar2
)
AS
BEGIN
  OPEN data_cursor for
   Select AUXSTOCKID,AUXTYPEID,AUXID,STOCKREQQTY,STOCKQTY,STOREFOLIO,REMARKS,UNITPRICE
   From T_AuxStockItem
   where AUXSTOCKID=pAuxStockID;

END GetAuxStockItem;
/


PROMPT CREATE OR REPLACE Procedure  011 :: GetAuxStockTypeList
CREATE OR REPLACE Procedure GetAuxStockTypeList
(
  data_cursor IN OUT pReturnData.c_Records
)

AS
BEGIN

    OPEN data_cursor for
    Select AuxStockTypeID, AuxStockType from T_AuxStockType order by AuxStockTypeID;
END;
/


PROMPT CREATE OR REPLACE Procedure  012 :: GetAuxStockTypeLookUp
CREATE OR REPLACE Procedure GetAuxStockTypeLookUp
(
  pStatus number,
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)

AS

BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=0 then
  OPEN data_cursor for
   select AuxStockTypeID,AuxStockType
	from t_auxStocktype order by auxStocktype;

/*If the Value is 1 then retun as the */

elsif pStatus=1 then
  OPEN data_cursor for
  select AuxStockTypeID,AuxStockType
	from t_auxStocktype where AuxStockTypeID=pWhereValue order by auxStocktype;
end if;
END GetAuxStockTypeLookUp;
/

PROMPT CREATE OR REPLACE Procedure  013 :: GetAuxTypeIDs
CREATE OR REPLACE Procedure GetAuxTypeIDs
(
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN

    OPEN data_cursor for
    Select AuxType, AuxTypeID from T_AuxType;

END;
/
PROMPT CREATE OR REPLACE Procedure  014:: GetNPartsLookup
CREATE OR REPLACE Procedure GetNPartsLookup
(
  data_cursor IN OUT pReturnData.c_Records,
  pMachineTypeID number
)
AS

BEGIN
  OPEN data_cursor for
     select PARTID,PARTNAME 
	 from T_KMCPARTSINFO 
	 Where MCPARTSTYPEID=pMachineTypeID
	 order by PARTNAME;
END GetNPartsLookup;
/


PROMPT CREATE OR REPLACE Procedure  015 :: GetBasicType
CREATE OR REPLACE Procedure GetBasicType
(
  pStatus number,
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=0 then
  OPEN data_cursor for
   select basictypeID,basictypename,unitofmeasid,basictypeSL
   from t_basictype order by basictypeSL;

/*If the Value is 1 then retun as the */

elsif pStatus=1 then
  OPEN data_cursor for
  select basictypeID,basictypename,unitofmeasid,basictypeSL
  from t_basictype where basictypeID=pWhereValue order by basictypeSL;
end if;
END GetBasicType;
/

PROMPT CREATE OR REPLACE Procedure  016 :: GetBasicWorkOrder
CREATE OR REPLACE Procedure GetBasicWorkOrder
(
  pStatus number,
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
/*if the Value is 0 then retun all the Data */
if pStatus=0 then
  OPEN data_cursor for
    select '' AS PID,BASICTYPEID,WORKORDERNO FROM T_BASICWORKORDER;
/*If the Value is 1 then retun as the */

elsif pStatus=1 then
  OPEN data_cursor for
    select '' AS PID,BASICTYPEID,WORKORDERNO FROM T_BASICWORKORDER /*WHERE PID=pWhereValue*/;

/*If the Value is 2 then retun as the  Work order*/

elsif pStatus=2 then
  OPEN data_cursor for
    select '' AS PID,BASICTYPEID,WORKORDERNO FROM T_BASICWORKORDER WHERE WORKORDERNO=pWhereValue;

end if;


END GetBasicWorkOrder;
/

PROMPT CREATE OR REPLACE Procedure  017 :: GetClientGroup
CREATE OR REPLACE Procedure GetClientGroup
(
  pStatus number,
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)

AS

BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=0 then
  OPEN data_cursor for
   select clientgroupID,clientGroupName
	from t_clientGroup order by clientGroupName;

/*If the Value is 1 then retun as the */

elsif pStatus=1 then
  OPEN data_cursor for
   select clientgroupID,clientGroupName
	from t_clientGroup where clientgroupID=pWhereValue order by clientGroupName;
end if;
END GetClientGroup;
/

PROMPT CREATE OR REPLACE Procedure  018 :: GetClientInfo
CREATE OR REPLACE Procedure GetClientInfo
(
  pStatus number,
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)

AS

BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=0 then
  OPEN data_cursor for
    select CLIENTID, CLIENTNAME,CLIENTSTATUSID,
     CADDRESS,CFACTORYADDRESS,CTELEPHONE,
     CFAX,CEMAIL,CURL,CCONTACTPERSON, CACCCODE,
     CREMARKS,CLIENTGROUPID  from T_Client order by CLIENTNAME;
/*If the Value is 1 then retun as the */

elsif pStatus=1 then
  OPEN data_cursor for
   select CLIENTID, CLIENTNAME,CLIENTSTATUSID,
     CADDRESS,CFACTORYADDRESS,CTELEPHONE,
     CFAX,CEMAIL,CURL,CCONTACTPERSON, CACCCODE,
     CREMARKS,CLIENTGROUPID  from T_Client where
     clientid=pWhereValue order by CLIENTNAME;
end if;
END GetClientInfo;
/

PROMPT CREATE OR REPLACE Procedure  018 :: GetCombinationIDs
CREATE OR REPLACE Procedure GetCombinationIDs
(
  pStatus number,
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)

AS

BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=0 then
  OPEN data_cursor for
  Select CombinationID,Combination
  	from T_Combination order by Combination;

/*If the Value is 1 then retun as the */

elsif pStatus=1 then
  OPEN data_cursor for
   Select CombinationID,Combination
	from T_Combination
	 where CombinationID=pWhereValue order by Combination;
end if;
END GetCombinationIDs;
/



PROMPT CREATE OR REPLACE Procedure  019 :: GetcurrencyIDs
CREATE OR REPLACE Procedure GetcurrencyIDs
(
  pStatus number,
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)

AS

BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=0 then
  OPEN data_cursor for
   Select CurrencyID,CurrencyName,ConRate,eConrate
	from T_Currency order by CurrencyID;
/*If the Value is 1 then retun as the */

elsif pStatus=1 then
  OPEN data_cursor for
    Select CurrencyID,CurrencyName,ConRate,eConrate
	from T_Currency
	 where CurrencyID=pWhereValue order by CurrencyID;
end if;
END GetcurrencyIDs;
/

PROMPT CREATE OR REPLACE Procedure  020 :: GetCurrencyLookUp
CREATE OR REPLACE Procedure GetCurrencyLookUp
(
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
  OPEN data_cursor for
    Select CurrencyID,CurrencyName,ConRate,eConRate
	from T_Currency order by CurrencyName;
END GetCurrencyLookUp;
/



PROMPT CREATE OR REPLACE Procedure  021 :: GetDesignationInfo
CREATE OR REPLACE Procedure GetDesignationInfo
(
  pStatus number,
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records

)
AS
BEGIN
/*if the Value is 0 then retun all the Data */
if pStatus=0 then
  OPEN data_cursor for
 select DesignationID,Designation,Grade
 from T_Designation order by Designation;
/*If the Value is 1 then retun as the */
elsif pStatus=1 then
  OPEN data_cursor for

   select DesignationID,Designation,Grade
 from T_Designation
  where DesignationID=pWhereValue order by Designation;
end if;
END GetDesignationInfo;
/

PROMPT CREATE OR REPLACE Procedure  023 :: GetDesignationList
CREATE OR REPLACE Procedure GetDesignationList
(
  pStatus number,
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)

AS

BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=0 then
  OPEN data_cursor for
 select DesignationID,Designation,GRADE
 from T_Designation order by Designation;
/*If the Value is 1 then retun as the */

elsif pStatus=1 then
  OPEN data_cursor for
   select DesignationID,Designation,grade
 from T_Designation
  where DesignationID=pWhereValue order by Designation;
end if;
END GetDesignationList;
/


PROMPT CREATE OR REPLACE Procedure  023 :: GetdyeBaseID
CREATE OR REPLACE Procedure GetdyeBaseID
(
  pStatus number,
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)

AS
BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=0 then
  OPEN data_cursor for
   Select dyeBaseid,dyeBase,auxforID
   from T_dyebase order by dyeBaseId;
/*If the Value is 1 then retun as the */

elsif pStatus=1 then
  OPEN data_cursor for
    Select dyeBaseid,dyeBase,auxforID
    from T_dyebase
    where dyeBaseid=pWhereValue order by dyeBase;
end if;
END GetdyeBaseID;
/

PROMPT CREATE OR REPLACE Procedure  024 :: GetDyeBaseList
CREATE OR REPLACE Procedure GetDyeBaseList
(
  data_cursor IN OUT pReturnData.c_Records
)

AS
BEGIN

    OPEN data_cursor for
    Select DyeBaseID,DyeBase,AuxForID,BUsedInRecipe  
    from T_DyeBase order by DyeBase;

END GetDyeBaseList;
/


PROMPT CREATE OR REPLACE Procedure  025 :: GetEmpGroupList
CREATE OR REPLACE Procedure GetEmpGroupList
(
  pStatus number,
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)

AS
BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=0 then
  OPEN data_cursor for
   select EmpGroupID,EmpGroup
 from T_EmpGroup order by EmpGroup;
/*If the Value is 1 then retun as the */

elsif pStatus=1 then
  OPEN data_cursor for
   select EmpGroupID,EmpGroup
 from T_EmpGroup
  where EmpGroupID=pWhereValue order by EmpGroup;
end if;
END GetEmpGroupList;
/


PROMPT CREATE OR REPLACE Procedure  026 :: GetEmployee
CREATE OR REPLACE Procedure GetEmployee
(
  pStatus number,
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)

AS
BEGIN
/*if the Value is 0 then retun all the Data */
if pStatus=0 then
  OPEN data_cursor for
  select EmployeeID,EmployeeName,empgroupID, Designationid,EmpStatusid,EmpPassword,EmpManager,
empcontactno,empparaddress,emppresaddress,empEmail 
from T_Employee 
order by EmployeeName;

/*If the Value is 1 then retun as the */
elsif pStatus=1 then
  OPEN data_cursor for
   select EmployeeID,EmployeeName,empgroupID,Designationid,EmpStatusid,EmpPassword,EmpManager,
   empcontactno,empparaddress,emppresaddress,empEmail
	from T_Employee
	 where EmployeeID=pWhereValue order by EmployeeName;
	 
/*If the Value is 2 then retun as the authorized person for Knitting*/
elsif pStatus=2 then
  OPEN data_cursor for
	select EmployeeID,EmployeeName,empgroupID,Designationid,EmpStatusid,EmpPassword,EmpManager,
	empcontactno,empparaddress,emppresaddress,empEmail
	from T_Employee
	where AUTHORIZEDFOR=pWhereValue
	order by EmployeeName;
end if;
END GetEmployee;
/

PROMPT CREATE OR REPLACE Procedure  027 :: GETEMPLOYEEASSAIGN
CREATE OR REPLACE Procedure GETEMPLOYEEASSAIGN
(
  pStatus number,
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)

AS

BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=0 then
  OPEN data_cursor for
  select EMPId,RoleId, PId from T_EmployeeAssign order by EMPId;
/*If the Value is 1 then retun as the */

elsif pStatus=1 then
  OPEN data_cursor for
   select EMPID,RoleId, PId from T_EmployeeAssign
  where EMPID=pWhereValue order by EMPID;
end if;
END GeTEMPLOYEEASSAIGN;
/

PROMPT CREATE OR REPLACE Procedure  028 :: GetFabricType
CREATE OR REPLACE Procedure GetFabricType
(
  pStatus number,
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
/*if the Value is 0 then retun all the Data */
if pStatus=0 then
  OPEN data_cursor for
  select fabrictypeID,fabrictype from t_fabrictype order by fabrictype;
/*If the Value is 1 then retun as the */
elsif pStatus=1 then
  OPEN data_cursor for
   select fabrictypeID,fabrictype from t_fabrictype
  where fabrictypeID=pWhereValue order by fabrictype;
end if;
END GetFabricType;
/

PROMPT CREATE OR REPLACE Procedure  029 :: GetImpLCStatusLookUp
CREATE OR REPLACE Procedure GetImpLCStatusLookUp
(
  pStatus number,
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)

AS

BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=0 then
  OPEN data_cursor for
   select ImpLCStatusID,ImpLCStatus
 from  T_ImpLCStatus order by ImpLCStatusID;

/*If the Value is 1 then retun as the */

elsif pStatus=1 then
  OPEN data_cursor for
  select ImpLCStatusID,ImpLCStatus
 from T_ImpLCStatus
  where ImpLCStatusID=pWhereValue order by ImpLCStatusID;
end if;
END GetImpLCStatusLookUp;
/

PROMPT CREATE OR REPLACE Procedure  030 :: GetImpLCTStatusLookUp
CREATE OR REPLACE Procedure GetImpLCTStatusLookUp
(
  pStatus number,
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
/*if the Value is 0 then retun all the Data */
if pStatus=0 then
  OPEN data_cursor for
   select ImpLCStatusID,ImpLCStatus
 from  T_ImpLCStatus order by ImpLCStatus;
/*If the Value is 1 then retun as the */
elsif pStatus=1 then
  OPEN data_cursor for
  select ImpLCStatusID,ImpLCStatus
 from T_ImpLCStatus
  where ImpLCStatusID=pWhereValue order by ImpLCStatus;
end if;
END GetImpLCTStatusLookUp;
/

PROMPT CREATE OR REPLACE Procedure  031 :: GetImpLCTypeLookUp
CREATE OR REPLACE Procedure GetImpLCTypeLookUp
(
  pStatus number,
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)

AS

BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=0 then
  OPEN data_cursor for
   select ImpLCTypeID,ImpLCType
 from  T_ImpLCType order by ImpLCType;

/*If the Value is 1 then retun as the */

elsif pStatus=1 then
  OPEN data_cursor for
  select ImpLCTypeID,ImpLCType
 from T_ImpLCType
  where ImpLCTypeID=pWhereValue order by ImpLCType;
end if;
END GetImpLCTypeLookUp;
/

PROMPT CREATE OR REPLACE Procedure  032 :: GetKMcDeptartmentLookUp
CREATE OR REPLACE Procedure GetKMcDeptartmentLookUp
(
  pStatus number,
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)

AS

BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=0 then
  OPEN data_cursor for
   select KMCDEPARTMENTID,KMCDEPARTMENT
 from t_kmcdepartment order by KMCDEPARTMENT;

/*If the Value is 1 then retun as the */

elsif pStatus=1 then
  OPEN data_cursor for
  select KMCDEPARTMENTID,KMCDEPARTMENT
 from t_kmcdepartment where KMCDEPARTMENTID=pWhereValue order by KMCDEPARTMENT;
end if;
END GetKMcDeptartmentLookUp;
/

PROMPT CREATE OR REPLACE Procedure  033 :: GETKMcPartsInfo
CREATE OR REPLACE Procedure GETKMcPartsInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  many_cursor IN OUT pReturnData.c_Records,
  pPARTID number
)
AS
BEGIN
    open one_cursor for
    select PARTID, PARTNAME,DESCRIPTION,FOREIGNPART,MCTYPEID,UNITOFMEASID,REORDERQTY,ORDERLEADTIME,
    SPARETYPEID,LOCATIONID,REMARKS,WAVGPRICE,KMCDEPARTMENTID,MCPARTSTYPEID 
    from t_kmcpartsinfo
    where PARTID=pPARTID;
     
    open many_cursor for
    select PID,PARTID, PURCHASEDATE, UNITPRICE, SUPPLIERNAME, QTY
    from t_kmcpartshistory
    where PARTID=pPARTID;
END GETKMcPartsInfo;
/


PROMPT CREATE OR REPLACE Procedure  034 :: GetKmcPartsInfoLookUp
CREATE OR REPLACE Procedure GetKmcPartsInfoLookUp
(
  pStatus number,
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)

AS

BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=0 then
  OPEN data_cursor for
   select PartID,PARTNAME,Description
 from T_KMCPARTSINFO order by PARTNAME;

/*If the Value is 1 then retun as the */

elsif pStatus=1 then
  OPEN data_cursor for
  select PartID,PARTNAME,Description
 from T_KMCPARTSINFO where PARTID=pWhereValue order by PARTNAME;
end if;
END GetKmcPartsInfoLookUp;
/


PROMPT CREATE OR REPLACE Procedure  035 :: GetKmcPartsMRRMPDetail
CREATE OR REPLACE Procedure GetKmcPartsMRRMPDetail
(
  data_cursor IN OUT pReturnData.c_Records,
  PStockId IN NUMBER
)
As
Begin
  OPEN data_cursor FOR
  select   a.StockDate,a.StockId,b.PartId,c.PARTNAME,b.Qty,
  a.Challanno,b.Stockitemsl,a.PURCHASEORDERNO,
  a.PURCHASEORDERDATE,D.SUPPLIERNAME,D.SADDRESS,b.REMARKS
  from T_KmcPartsTran a,T_KmcPartsTransDetails b,T_KmcPartsInfo c,T_SUPPLIER d
  where a.StockId=b.StockId and
  a.supplierID=d.supplierID and 
  b.PartId=c.PartId  and
  B.KmcSTOCKTYPEID=1 And
  a.StockId=PStockId;
End GetKmcPartsMRRMPDetail;
/


PROMPT CREATE OR REPLACE Procedure  036 :: GetKmcPartsPickUp
CREATE OR REPLACE Procedure GetKmcPartsPickUp
(
  pStatus number,
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)

AS

BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=0 then
  OPEN data_cursor for
   select a.PartID,a.PARTNAME,a.Description,a.FOREIGNPART,a.MCPARTSTYPEID,
   c.MCPARTSTYPE,a.LOCATIONID,b.LOCATION,
   d.MCTYPENAME,a.MCTYPEID,a.SPARETYPEID,a.UNITOFMEASID,
   e.SPARETYPENAME,f.UNITOFMEAS
 from T_KMCPARTSINFO a,t_storeLocation b,t_mcpartstype c,t_kmctype d,t_sparetype e,t_unitofmeas f where 
 a.LOCATIONID=b.LOCATIONID and a.MCPARTSTYPEID=c.MCPARTSTYPEID and a.MCTYPEID=d.MCTYPEID and 
 a.SPARETYPEID=e.SPARETYPEID and a.UNITOFMEASID=f.UNITOFMEASID   
 order by a.PARTID,a.PARTNAME;

/*If the Value is 1 then retun as the */

elsif pStatus=1 then
  OPEN data_cursor for
   select a.PartID,a.PARTNAME,a.Description,a.FOREIGNPART,a.MCPARTSTYPEID,
   c.MCPARTSTYPE,a.LOCATIONID,b.LOCATION,
   d.MCTYPENAME,a.MCTYPEID,a.SPARETYPEID,a.UNITOFMEASID,
   e.SPARETYPENAME,f.UNITOFMEAS
 from T_KMCPARTSINFO a,t_storeLocation b,t_mcpartstype c,t_kmctype d,t_sparetype e,t_unitofmeas f where 
 a.LOCATIONID=b.LOCATIONID and a.MCPARTSTYPEID=c.MCPARTSTYPEID and a.MCTYPEID=d.MCTYPEID and 
 a.SPARETYPEID=e.SPARETYPEID and a.UNITOFMEASID=f.UNITOFMEASID   
and a.MCTYPEID=pWhereValue order by a.PARTID,a.PARTNAME;
end if;
END GetKmcPartsPickUp;
/


PROMPT CREATE OR REPLACE Procedure  037 :: GetKmcPartsStatusLookUp
CREATE OR REPLACE Procedure GetKmcPartsStatusLookUp
(
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN

    OPEN data_cursor for
    Select PartsStatus, PartsStatusID from T_KmcPartsStatus;

END GetKmcPartsStatusLookUp;
/


PROMPT CREATE OR REPLACE Procedure  038 :: GETKMCPartStockInfo
CREATE OR REPLACE Procedure GETKMCPartStockInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  many_cursor IN OUT pReturnData.c_Records,
  pKmcStockID number
)
AS
BEGIN
    	open one_cursor for
    	select a.StockId, a.StockDate, a.ChallanNo, a.ChallanDate, a.PURCHASEORDERNO, a.PURCHASEORDERDATE,
	a.KmcStockTypeId,a.SUBCONID,a.SUPPLIERID,CURRENCYID,CONRATE,SCOMPLETE,SupplierInvoiceNo, SupplierInvoiceDate
    	from T_KmcPartsTran a
    	where a.StockId=pKmcStockID;

    	open many_cursor for
    	select a.STOCKID,c.partsstatus, a.STOCKITEMSL,a.PARTID,a.UNITPRICE,a.REMARKS,
 	a.PARTSSTATUSFROMID,a.PARTSSTATUSTOID,a.QTY,a.MACHINEID,a.PID,a.CURRENTSTOCK,
 	a.KMCTYPEID,b.PARTNAME,b.DESCRIPTION,b.FOREIGNPART
    	from T_KMCPARTSTRANSDETAILS a,t_kmcpartsinfo b,t_kmcpartsstatus c
    	where  a.STOCKID=pKMCStockID and
 	a.PARTID=b.PARTID and
      	c.partsstatusid=a.PARTSSTATUSFROMID
    	order by a.STOCKITEMSL asc;
END GETKMCPartStockInfo;
/




PROMPT CREATE OR REPLACE Procedure  040 :: GetKmcStockPickUp
CREATE OR REPLACE Procedure GetKmcStockPickUp(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  subConID in number
)
AS

mFloorToMachine number default 9;

BEGIN
/* Pick All the Latest Stock from the Database For Report Purpose Only*/
  if pQueryType=0 then

        open data_cursor for

        select b.PARTID,c.PARTNAME,
           sum(b.QTY * d.MSN) as MainStoreNew,
           sum(b.QTY * d.MSO) as MainStoreOld,
           sum(b.QTY * d.MSB) as MainStoreBroken,
           sum(b.QTY * d.MSR) as MainStoreRejected,
           sum(b.QTY * d.FSN) as FloorNewReturn,
	   sum(b.QTY * d.FSO) as FloorOldReturn,
           sum(b.QTY * d.SSN) as SubContractorNew
           from t_kmcpartstransdetails b,t_kmcpartsinfo c,t_kmcstockStatus d
           where b.PARTID=c.PARTID and B.KMCSTOCKTYPEID=d.KMCSTOCKTYPEID and
           b.PARTSSTATUSFROMID=d.PARTSSTATUSFROMID and b.PARTSSTATUSTOID=d.PARTSSTATUSTOID
           group by b.PARTID,c.PARTNAME;

        /* For Main Store Old And New */
  elsif pQueryType=1 then
 open data_cursor for
     select b.PARTID,f.MCTYPENAME,c.DESCRIPTION,c.FOREIGNPART,c.MCTYPEID,b.UNITPRICE,c.PARTNAME,
        b.PARTSSTATUSTOID AS PARTSSTATUSFROMID,a.PARTSSTATUS,c.MCPARTSTYPEID,
		'' as UNITOFMEASID,'' as UNITOFMEAS,sum(b.QTY * d.MSN) as Qty
        from   t_kmcPartsstatus a,t_kmcpartstransdetails b,t_kmcpartsinfo c,t_kmcstockStatus d,t_UnitOfMeas e,t_kmctype f
        where  b.PARTID=c.PARTID and
        c.MCTYPEID=f.MCTYPEID and
        b.PARTSSTATUSTOID=a.PARTSSTATUSID and
        B.KMCSTOCKTYPEID=d.KMCSTOCKTYPEID and b.PARTSSTATUSFROMID=d.PARTSSTATUSFROMID and
        b.PARTSSTATUSTOID=d.PARTSSTATUSTOID and c.UNITOFMEASID=e.UNITOFMEASID
        group by b.PARTID,c.PARTNAME,b.PARTSSTATUSTOID,a.PARTSSTATUS,b.UNITPRICE,c.MCPARTSTYPEID,
        c.DESCRIPTION,c.FOREIGNPART,c.MCTYPEID,f.MCTYPENAME
        having sum(b.Qty*d.MSN)>0
union all
    select b.PARTID,f.MCTYPENAME,c.DESCRIPTION,c.FOREIGNPART,c.MCTYPEID,b.UNITPRICE,c.PARTNAME,
	b.PARTSSTATUSTOID  AS PARTSSTATUSFROMID,a.PARTSSTATUS,c.MCPARTSTYPEID,
        '' as UNITOFMEASID,'' as UNITOFMEAS,sum(b.QTY * d.MSO) as Qty
        from t_kmcPartsstatus a,t_kmcpartstransdetails b,t_kmcpartsinfo c,t_kmcstockStatus d,t_UnitOfMeas e,t_kmctype f
        where b.PARTID=c.PARTID and f.MCTYPEID=c.MCTYPEID and
        b.PARTSSTATUSTOID=a.PARTSSTATUSID and
        B.KMCSTOCKTYPEID=d.KMCSTOCKTYPEID and b.PARTSSTATUSFROMID=d.PARTSSTATUSFROMID and
        b.PARTSSTATUSTOID=d.PARTSSTATUSTOID and c.UNITOFMEASID=e.UNITOFMEASID
        group by b.PARTID,c.PARTNAME,b.PARTSSTATUSTOID,a.PARTSSTATUS,b.UNITPRICE,c.MCPARTSTYPEID,
        c.DESCRIPTION,c.FOREIGNPART,c.MCTYPEID,f.MCTYPENAME
        having sum(b.Qty*d.MSO)>0
        order by MCPARTSTYPEID,PARTSSTATUS,PARTNAME;

 /* For Floor  Store New and Old */
  elsif pQueryType=2 then
open data_cursor for
                 select b.PARTID,b.MACHINEID,f.MCTYPENAME,c.DESCRIPTION,c.FOREIGNPART,c.MCTYPEID,b.UNITPRICE,c.PARTNAME,b.PARTSSTATUSFROMID,a.PARTSSTATUS,
                   c.UNITOFMEASID,e.UNITOFMEAS,
           sum(b.QTY * d.FSN) as Qty
            from
            t_kmcPartsstatus a,t_kmcpartstransdetails b,t_kmcpartsinfo c,t_kmcstockStatus d,t_UnitOfMeas e,t_kmctype f
           where   b.PARTID=c.PARTID and
                   f.MCTYPEID =c.MCTYPEID and
                   b.PARTSSTATUSFROMID=a.PARTSSTATUSID and
           B.KMCSTOCKTYPEID=d.KMCSTOCKTYPEID and b.PARTSSTATUSFROMID=d.PARTSSTATUSFROMID and
           b.PARTSSTATUSTOID=d.PARTSSTATUSTOID  and c.UNITOFMEASID=e.UNITOFMEASID
           group by b.PARTID,b.MACHINEID,c.PARTNAME,b.PARTSSTATUSFROMID,c.UNITOFMEASID,e.UNITOFMEAS,a.PARTSSTATUS,b.UNITPRICE,
                   c.DESCRIPTION,c.FOREIGNPART,c.MCTYPEID,f.MCTYPENAME
                  having sum(b.Qty*d.FSN)>0
union all
select b.PARTID,b.MACHINEID,f.MCTYPENAME,c.DESCRIPTION,c.FOREIGNPART,c.MCTYPEID,b.UNITPRICE,c.PARTNAME,b.PARTSSTATUSFROMID,a.PARTSSTATUS,
                   c.UNITOFMEASID,e.UNITOFMEAS,
	sum(b.QTY * d.FSO) as Qty
            from
           t_kmcPartsstatus a,t_kmcpartstransdetails b,t_kmcpartsinfo c,t_kmcstockStatus d,t_UnitOfMeas e,t_kmctype f
           where
           b.PARTID=c.PARTID and
                   f.MCTYPEID =c.MCTYPEID and
                   b.PARTSSTATUSFROMID=a.PARTSSTATUSID and
           B.KMCSTOCKTYPEID=d.KMCSTOCKTYPEID and b.PARTSSTATUSFROMID=d.PARTSSTATUSFROMID and
           b.PARTSSTATUSTOID=d.PARTSSTATUSTOID  and c.UNITOFMEASID=e.UNITOFMEASID
           group by b.PARTID,b.MACHINEID,c.PARTNAME,b.PARTSSTATUSFROMID,c.UNITOFMEASID,e.UNITOFMEAS,a.PARTSSTATUS,b.UNITPRICE,
                   c.DESCRIPTION,c.FOREIGNPART,c.MCTYPEID,f.MCTYPENAME
		  having sum(b.Qty*d.FSO)>0
                  order by MACHINEID,partID;


/* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/
 /* For Sub Cintractor new */
  elsif pQueryType=3 then
open data_cursor for
                 select b.PARTID,f.MCTYPENAME,c.DESCRIPTION,c.FOREIGNPART,c.MCTYPEID,b.UNITPRICE,c.PARTNAME,b.PARTSSTATUSFROMID,a.PARTSSTATUS,
                   c.UNITOFMEASID,e.UNITOFMEAS,
           sum(b.QTY * d.SSN) as Qty from
            t_kmcPartsstatus a,t_kmcpartstransdetails b,t_kmcpartsinfo c,t_kmcstockStatus d,t_UnitOfMeas e,t_kmctype f
           where
           b.PARTID=c.PARTID and
                   f.MCTYPEID =c.MCTYPEID and
                   b.PARTSSTATUSFROMID=a.PARTSSTATUSID and
           B.KMCSTOCKTYPEID=d.KMCSTOCKTYPEID and b.PARTSSTATUSFROMID=d.PARTSSTATUSFROMID and
           b.PARTSSTATUSTOID=d.PARTSSTATUSTOID  and c.UNITOFMEASID=e.UNITOFMEASID
           group by b.PARTID,c.PARTNAME,b.PARTSSTATUSFROMID,c.UNITOFMEASID,e.UNITOFMEAS,a.PARTSSTATUS,b.UNITPRICE,
                   c.DESCRIPTION,c.FOREIGNPART,c.MCTYPEID,f.MCTYPENAME
                  having sum(b.Qty*d.SSN)>0
		order by partID;

/* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/
/* Loan  To Party */
 elsif pQueryType=4 then
                open data_cursor for
                   select b.PARTID,g.MCTYPENAME,c.DESCRIPTION,c.FOREIGNPART,c.MCTYPEID,b.UNITPRICE,c.PARTNAME,b.PARTSSTATUSFROMID,a.PARTSSTATUS,
                   c.UNITOFMEASID,e.UNITOFMEAS,
           sum(b.QTY * d.MSN) as Qty
            from
           t_kmcPartsstatus a,t_kmcpartstransdetails b,t_kmcpartsinfo c,t_kmcstockStatus d,t_UnitOfMeas e,
	 t_kmcpartstran f,t_kmctype g
           where
           b.PARTID=c.PARTID and
                   g.MCTYPEID =c.MCTYPEID and
                   b.STOCKID=f.STOCKID and
                   b.PARTSSTATUSFROMID=a.PARTSSTATUSID and
           B.KMCSTOCKTYPEID=d.KMCSTOCKTYPEID and b.PARTSSTATUSFROMID=d.PARTSSTATUSFROMID and
           b.PARTSSTATUSTOID=d.PARTSSTATUSTOID and c.UNITOFMEASID=e.UNITOFMEASID
           group by b.PARTID,c.PARTNAME,b.PARTSSTATUSFROMID,c.UNITOFMEASID,e.UNITOFMEAS,a.PARTSSTATUS,b.UNITPRICE,
                   c.DESCRIPTION,c.FOREIGNPART,c.MCTYPEID,g.MCTYPENAME
                  having sum(b.Qty*d.MSN)>0;

/* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/
/* Loan  Return From  Party */
 elsif pQueryType=5 then
                open data_cursor for
                   select b.PARTID,g.MCTYPENAME,c.DESCRIPTION,c.FOREIGNPART,c.MCTYPEID,b.UNITPRICE,c.PARTNAME,b.PARTSSTATUSFROMID,a.PARTSSTATUS,
                   c.UNITOFMEASID,e.UNITOFMEAS,
           sum(b.QTY * d.SSN) as Qty
            from
           t_kmcPartsstatus a,t_kmcpartstransdetails b,t_kmcpartsinfo c,t_kmcstockStatus d,t_UnitOfMeas e,
                   t_kmcpartstran f,t_kmctype g
		where  b.PARTID=c.PARTID and
                   g.MCTYPEID =c.MCTYPEID and
                   f.SUBCONID=subConID and
                   b.STOCKID=f.STOCKID and
                   b.PARTSSTATUSFROMID=a.PARTSSTATUSID and
           B.KMCSTOCKTYPEID=d.KMCSTOCKTYPEID and b.PARTSSTATUSFROMID=d.PARTSSTATUSFROMID and
           b.PARTSSTATUSTOID=d.PARTSSTATUSTOID and c.UNITOFMEASID=e.UNITOFMEASID
           group by b.PARTID,c.PARTNAME,b.PARTSSTATUSFROMID,c.UNITOFMEASID,e.UNITOFMEAS,a.PARTSSTATUS,b.UNITPRICE,
                   c.DESCRIPTION,c.FOREIGNPART,c.MCTYPEID,g.MCTYPENAME
                  having sum(b.Qty*d.SSN)>0;

/* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/
/* There is no Pick Up for Query type 6 Means Loan From Party*/
/* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/
/* Loan  To Party */
 elsif pQueryType=7 then
                open data_cursor for
                   select b.PARTID,g.MCTYPENAME,c.DESCRIPTION,c.FOREIGNPART,c.MCTYPEID,b.UNITPRICE,c.PARTNAME,b.PARTSSTATUSFROMID,a.PARTSSTATUS,
                   c.UNITOFMEASID,e.UNITOFMEAS,
           sum(b.QTY * d.MSN) as Qty
            from
           t_kmcPartsstatus a,t_kmcpartstransdetails b,t_kmcpartsinfo c,t_kmcstockStatus d,t_UnitOfMeas e,
	   t_kmcpartstran f,t_kmctype g
           where
           b.PARTID=c.PARTID and
                   g.MCTYPEID =c.MCTYPEID and
                   b.STOCKID=f.STOCKID and
                   b.PARTSSTATUSFROMID=a.PARTSSTATUSID and
           B.KMCSTOCKTYPEID=d.KMCSTOCKTYPEID and b.PARTSSTATUSFROMID=d.PARTSSTATUSFROMID and
           b.PARTSSTATUSTOID=d.PARTSSTATUSTOID and c.UNITOFMEASID=e.UNITOFMEASID
           group by b.PARTID,c.PARTNAME,b.PARTSSTATUSFROMID,c.UNITOFMEASID,e.UNITOFMEAS,a.PARTSSTATUS,b.UNITPRICE,
                   c.DESCRIPTION,c.FOREIGNPART,c.MCTYPEID,g.MCTYPENAME
                  having sum(b.Qty*d.MSN)>0;
/* For Floor To MAchine */
  elsif pQueryType=9 then
  open data_cursor for
  select partid,MCTYPENAME,DESCRIPTION,FOREIGNPART,MCTYPEID,partName,sum(Qty) as Qty,PARTSSTATUS,PartsstatusFromID,
                unitprice,UNITOFMEASID,unitofmeas from
		(select t_kmcpartstransdetails.partid,t_kmctype.MCTYPENAME,DESCRIPTION,
                FOREIGNPART,t_kmcpartsinfo.MCTYPEID,partName,sum(QTY*-1) as Qty,PARTSSTATUS,PartsstatusFromID,
                unitprice,t_kmcpartsinfo.UNITOFMEASID,unitofmeas from t_kmcpartstransdetails,t_kmcPartsstatus,
                t_kmcpartsinfo,t_unitofmeas,t_kmctype
                where MACHINEID<>0 and KMCSTOCKTYPEID=mFloorToMachine and
                t_kmctype.MCTYPEID =t_kmcpartsinfo.MCTYPEID and
                partsstatusFromID=1 and t_kmcpartstransdetails.PARTSSTATUSFROMID=t_kmcPartsstatus.PARTSSTATUSID and
                t_kmcpartstransdetails.PARTID=t_kmcpartsinfo.partid and t_kmcpartsinfo.UNITOFMEASID=t_unitofmeas.UNITOFMEASID
                group by PARTSSTATUS,t_kmctype.MCTYPENAME,PartsstatusFromID,unitprice,t_kmcpartstransdetails.partid,PartName,
                t_kmcpartsinfo.UNITOFMEASID,unitofmeas,DESCRIPTION,FOREIGNPART,t_kmcpartsinfo.MCTYPEID
                union all
		select t_kmcpartstransdetails.partid,t_kmctype.MCTYPENAME,DESCRIPTION,FOREIGNPART,t_kmcpartsinfo.MCTYPEID,partName,sum(QTY) as Qty,PARTSSTATUS,PartsstatusFromID,unitprice,
                t_kmcpartsinfo.UNITOFMEASID,unitofmeas from t_kmcpartstransdetails,t_kmcPartsstatus,
                t_kmcPartsinfo,t_unitofmeas,t_kmctype
                where MACHINEID=0 and KMCSTOCKTYPEID=2 and partsstatusFromID=1 and
                t_kmcpartstransdetails.PARTID=t_kmcpartsinfo.partid and
                t_kmctype.MCTYPEID = t_kmcpartsinfo.MCTYPEID and
                t_kmcpartstransdetails.PARTSSTATUSFROMID=t_kmcPartsstatus.PARTSSTATUSID
                and t_kmcpartsinfo.UNITOFMEASID=t_unitofmeas.UNITOFMEASID
                group by PARTSSTATUS,PartsstatusFromID,unitprice,DESCRIPTION,FOREIGNPART,t_kmcpartsinfo.MCTYPEID,
                t_kmcpartstransdetails.partid,partName,t_kmcpartsinfo.UNITOFMEASID,unitofmeas,t_kmctype.MCTYPENAME) a
                group by PARTSSTATUS,MCTYPENAME,PartsstatusFromID,unitprice,partid,PartName,UNITOFMEASID,unitofmeas,DESCRIPTION,FOREIGNPART,MCTYPEID
		having sum(Qty)>0
                union all
                select partid,MCTYPENAME,DESCRIPTION,FOREIGNPART,MCTYPEID,partName,sum(Qty) as Qty,PARTSSTATUS,PartsstatusFromID,
                unitprice,UNITOFMEASID,unitofmeas from
                (select t_kmcpartstransdetails.partid,t_kmctype.MCTYPENAME,DESCRIPTION,
                FOREIGNPART,t_kmcpartsinfo.MCTYPEID,partName,sum(QTY*-1) as Qty,PARTSSTATUS,PartsstatusFromID,
                unitprice,t_kmcpartsinfo.UNITOFMEASID,unitofmeas from t_kmcpartstransdetails,t_kmcPartsstatus,
                t_kmcpartsinfo,t_unitofmeas,t_kmctype
                where MACHINEID<>0 and KMCSTOCKTYPEID=mFloorToMachine and
                t_kmctype.MCTYPEID =t_kmcpartsinfo.MCTYPEID and
                partsstatusFromID=2 and t_kmcpartstransdetails.PARTSSTATUSFROMID=t_kmcPartsstatus.PARTSSTATUSID and
		t_kmcpartstransdetails.PARTID=t_kmcpartsinfo.partid and t_kmcpartsinfo.UNITOFMEASID=t_unitofmeas.UNITOFMEASID
                group by PARTSSTATUS,t_kmctype.MCTYPENAME,PartsstatusFromID,unitprice,t_kmcpartstransdetails.partid,PartName,
                t_kmcpartsinfo.UNITOFMEASID,unitofmeas,DESCRIPTION,FOREIGNPART,t_kmcpartsinfo.MCTYPEID
                union all
                select t_kmcpartstransdetails.partid,t_kmctype.MCTYPENAME,DESCRIPTION,FOREIGNPART,t_kmcpartsinfo.MCTYPEID,partName,sum(QTY) as Qty,PARTSSTATUS,PartsstatusFromID,unitprice,
                t_kmcpartsinfo.UNITOFMEASID,unitofmeas from t_kmcpartstransdetails,t_kmcPartsstatus,
                t_kmcPartsinfo,t_unitofmeas,t_kmctype
                where MACHINEID=0 and KMCSTOCKTYPEID=2 and partsstatusFromID=2 and
                t_kmcpartstransdetails.PARTID=t_kmcpartsinfo.partid and
                t_kmctype.MCTYPEID = t_kmcpartsinfo.MCTYPEID and
                t_kmcpartstransdetails.PARTSSTATUSFROMID=t_kmcPartsstatus.PARTSSTATUSID
		and t_kmcpartsinfo.UNITOFMEASID=t_unitofmeas.UNITOFMEASID
                group by PARTSSTATUS,PartsstatusFromID,unitprice,DESCRIPTION,FOREIGNPART,t_kmcpartsinfo.MCTYPEID,
                t_kmcpartstransdetails.partid,partName,t_kmcpartsinfo.UNITOFMEASID,unitofmeas,t_kmctype.MCTYPENAME) a
                group by PARTSSTATUS,MCTYPENAME,PartsstatusFromID,unitprice,partid,PartName,UNITOFMEASID,unitofmeas,DESCRIPTION,FOREIGNPART,MCTYPEID
                having sum(Qty)>0;
				
/* For Requisition Old And New */
  elsif pQueryType=10 then
 open data_cursor for
     select CHALLANNO,b.PARTID,f.MCTYPENAME,c.DESCRIPTION,c.FOREIGNPART,c.MCTYPEID,b.UNITPRICE,c.PARTNAME,
        b.PartsstatusFromID,a.PARTSSTATUS,e.UNITOFMEAS,b.MACHINEID,h.MACHINENAME,sum(-b.QTY * d.MSN) as Qty
        from   t_kmcPartsstatus a,t_kmcpartstransdetailsReq b,t_kmcpartsinfo c,t_kmcstockStatus d,
	t_UnitOfMeas e,t_kmctype f,T_KMCPARTSTRANREQUISITION g,T_KNITMACHINEINFO h
        where  b.PARTID=c.PARTID and b.STOCKID=g.STOCKID and
        c.MCTYPEID=f.MCTYPEID and b.MACHINEID=h.MACHINEID and
        b.PARTSSTATUSTOID=a.PARTSSTATUSID and
        B.KMCSTOCKTYPEID=d.KMCSTOCKTYPEID and b.PARTSSTATUSFROMID=d.PARTSSTATUSFROMID and
        b.PARTSSTATUSTOID=d.PARTSSTATUSTOID and c.UNITOFMEASID=e.UNITOFMEASID and Executed=0
	group by CHALLANNO,b.PARTID,c.PARTNAME,e.UNITOFMEAS,b.PartsstatusFromID,a.PARTSSTATUS,b.UNITPRICE,
        c.DESCRIPTION,c.FOREIGNPART,c.MCTYPEID,f.MCTYPENAME,b.MACHINEID,h.MACHINENAME
        having sum(-b.Qty*d.MSN)>0
union all
    select CHALLANNO,b.PARTID,f.MCTYPENAME,c.DESCRIPTION,c.FOREIGNPART,c.MCTYPEID,b.UNITPRICE,c.PARTNAME,
	b.PartsstatusFromID,a.PARTSSTATUS,e.UNITOFMEAS,b.MACHINEID,h.MACHINENAME,sum(-b.QTY * d.MSO) as Qty
        from t_kmcPartsstatus a,t_kmcpartstransdetailsReq b,t_kmcpartsinfo c,t_kmcstockStatus d,
	t_UnitOfMeas e,t_kmctype f,T_KMCPARTSTRANREQUISITION g,T_KNITMACHINEINFO h
        where b.PARTID=c.PARTID and b.STOCKID=g.STOCKID and
	f.MCTYPEID=c.MCTYPEID and b.MACHINEID=h.MACHINEID and
        b.PARTSSTATUSTOID=a.PARTSSTATUSID and
        B.KMCSTOCKTYPEID=d.KMCSTOCKTYPEID and b.PARTSSTATUSFROMID=d.PARTSSTATUSFROMID and
        b.PARTSSTATUSTOID=d.PARTSSTATUSTOID and c.UNITOFMEASID=e.UNITOFMEASID and Executed=0
	group by CHALLANNO,b.PARTID,c.PARTNAME,e.UNITOFMEAS,b.PartsstatusFromID,a.PARTSSTATUS,b.UNITPRICE,
        c.DESCRIPTION,c.FOREIGNPART,c.MCTYPEID,f.MCTYPENAME,b.MACHINEID,h.MACHINENAME
        having sum(-b.Qty*d.MSO)>0
        order by partID;
		
/*For Broken and Rejected Needle Return to Head Office*/			
elsif pQueryType=11 then
 open data_cursor for
     select b.PARTID,f.MCTYPENAME,c.DESCRIPTION,c.FOREIGNPART,c.MCTYPEID,0 as UNITPRICE,c.PARTNAME,
        b.PARTSSTATUSTOID AS PARTSSTATUSFROMID,a.PARTSSTATUS,'' as UNITOFMEASID,'' as UNITOFMEAS,sum(b.QTY * d.MSB) as Qty
        from   t_kmcPartsstatus a,t_kmcpartstransdetails b,t_kmcpartsinfo c,t_kmcstockStatus d,t_kmctype f
        where  b.PARTID=c.PARTID and
        c.MCTYPEID=f.MCTYPEID and
        b.PARTSSTATUSTOID=a.PARTSSTATUSID and
        B.KMCSTOCKTYPEID=d.KMCSTOCKTYPEID and b.PARTSSTATUSFROMID=d.PARTSSTATUSFROMID and
        b.PARTSSTATUSTOID=d.PARTSSTATUSTOID 
        group by b.PARTID,c.PARTNAME,b.PARTSSTATUSTOID,a.PARTSSTATUS,
        c.DESCRIPTION,c.FOREIGNPART,c.MCTYPEID,f.MCTYPENAME
        having sum(b.Qty*d.MSB)>0
union all

    select b.PARTID,f.MCTYPENAME,c.DESCRIPTION,c.FOREIGNPART,c.MCTYPEID,0 as UNITPRICE,c.PARTNAME,
	b.PARTSSTATUSTOID  AS PARTSSTATUSFROMID,a.PARTSSTATUS,
        '' as UNITOFMEASID,'' as UNITOFMEAS,sum(b.QTY * d.MSR) as Qty
        from t_kmcPartsstatus a,t_kmcpartstransdetails b,t_kmcpartsinfo c,t_kmcstockStatus d,t_kmctype f
        where b.PARTID=c.PARTID and f.MCTYPEID=c.MCTYPEID and
        b.PARTSSTATUSTOID=a.PARTSSTATUSID and
        B.KMCSTOCKTYPEID=d.KMCSTOCKTYPEID and b.PARTSSTATUSFROMID=d.PARTSSTATUSFROMID and
        b.PARTSSTATUSTOID=d.PARTSSTATUSTOID 
        group by b.PARTID,c.PARTNAME,b.PARTSSTATUSTOID,a.PARTSSTATUS,
        c.DESCRIPTION,c.FOREIGNPART,c.MCTYPEID,f.MCTYPENAME
        having sum(b.Qty*d.MSR)>0
        order by PARTNAME;
/* For Main Store Brokecn */
  elsif pQueryType=55 then
open data_cursor for
                   select b.PARTID,e.MCTYPENAME,c.DESCRIPTION,c.FOREIGNPART,c.MCTYPEID,c.PARTNAME,
           sum(b.QTY * d.MSB) as MainStoreNew
            from
           t_kmcpartstransdetails b,t_kmcpartsinfo c,t_kmcstockStatus d,t_kmctype e
           where
           b.PARTID=c.PARTID and e.MCTYPEID=c.MCTYPEID and
	   B.KMCSTOCKTYPEID=d.KMCSTOCKTYPEID and b.PARTSSTATUSFROMID=d.PARTSSTATUSFROMID and
           b.PARTSSTATUSTOID=d.PARTSSTATUSTOID
           group by b.PARTID,c.PARTNAME,c.DESCRIPTION,c.FOREIGNPART,c.MCTYPEID,e.MCTYPENAME
                  having sum(b.Qty*d.MSB)>0;
/* For Main store Rejected */
  elsif pQueryType=56 then
                open data_cursor for
                   select b.PARTID,e.MCTYPENAME,c.DESCRIPTION,c.FOREIGNPART,c.MCTYPEID,c.PARTNAME,
           sum(b.QTY * d.MSR) as MainStoreNew
	from
           t_kmcpartstransdetails b,t_kmcpartsinfo c,t_kmcstockStatus d,t_kmctype e
           where
           b.PARTID=c.PARTID and
                   e.MCTYPEID =c.MCTYPEID and
           B.KMCSTOCKTYPEID=d.KMCSTOCKTYPEID and b.PARTSSTATUSFROMID=d.PARTSSTATUSFROMID and
           b.PARTSSTATUSTOID=d.PARTSSTATUSTOID
           group by b.PARTID,c.PARTNAME,c.DESCRIPTION,c.FOREIGNPART,c.MCTYPEID,e.MCTYPENAME
                  having sum(b.Qty*d.MSR)>0;
  end if;

END GetKmcStockPickUp;
/


PROMPT CREATE OR REPLACE Procedure  041 :: GetKmcStockTypeList
CREATE OR REPLACE Procedure GetKmcStockTypeList
(
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN

    OPEN data_cursor for
    Select KMCSTOCKTYPEID,KMCSTOCKTYPE from T_KmcStockType;
END GetKmcStockTypeList;
/


PROMPT CREATE OR REPLACE Procedure  042 :: GetKmcTypeIDs
CREATE OR REPLACE Procedure GetKmcTypeIDs
(
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN

    OPEN data_cursor for
    Select McTypeName, McTypeID from T_KmcType;

END;
/


PROMPT CREATE OR REPLACE Procedure  043 :: GetKmcTypeLookUp
CREATE OR REPLACE Procedure GetKmcTypeLookUp
(
  pStatus number,
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)

AS

BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=0 then
  OPEN data_cursor for
   select MCTYPEID,MCTYPENAME
	from t_kmctype order by MCTYPENAME;

/*If the Value is 1 then retun as the */

elsif pStatus=1 then
  OPEN data_cursor for
  select MCTYPEID,MCTYPENAME
	from t_kmctype where MCTYPEID=pWhereValue order by MCTYPENAME;
end if;
END GetKmcTypeLookUp;
/


PROMPT CREATE OR REPLACE Procedure  044 :: GetKnitMachineInfoLookUp
CREATE OR REPLACE Procedure GetKnitMachineInfoLookUp
(
  pStatus number,
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
/*if the Value is 0 then retun all the Data */
if pStatus=0 then
  OPEN data_cursor for
   select a.MachineID,MACHINENAME as KnitMCDia,'' as KnitMcGauge,'' as RatedCapacity
	from t_knitMachineInfo a
	order by a.MachineID;

/*If the Value is 1 then retun as the */

elsif pStatus=1 then
  OPEN data_cursor for
   select a.MachineID,MACHINENAME as KnitMCDia,'' as KnitMcGauge,'' as RatedCapacity
	from t_knitMachineInfo a
	where  a.MACHINEID=pWhereValue
	order by MachineID;
end if;
END GetKnitMachineInfoLookUp;
/


PROMPT CREATE OR REPLACE Procedure  045 :: GetKnitPlanList
CREATE OR REPLACE Procedure GetKnitPlanList
(
  pStatus number,
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)

AS

BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=0 then
  OPEN data_cursor for
   Select a.ORDERNO,a.PlanID,a.BATCHID,a.MERGEID,a.MACHINEID,a.PLANQTY,a.PLANREMARKS,a.SCHEDULEDATE,a.SCHEDULEPLANDATE,
   a.PLANSTATUSID
   from T_knitPlan a
    order by a.PLANID;


/*If the Value is 1 then retun as the  Work Order */

elsif pStatus=1 then
  OPEN data_cursor for
Select a.ORDERNO,a.PlanID,a.BATCHID,a.MERGEID,a.MACHINEID,a.PLANQTY,a.PLANREMARKS,a.SCHEDULEDATE,a.SCHEDULEPLANDATE,
   a.PLANSTATUSID
	from t_knitPlan a
	where  a.ORDERNO=pWhereValue	order by a.PLANID;
end if;
END GetKnitPlanList;
/

PROMPT CREATE OR REPLACE Procedure  046 :: GetknitStockInfo
CREATE OR REPLACE Procedure GetknitStockInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  many_cursor IN OUT pReturnData.c_Records,
  pKnitStockID number
)
AS
BEGIN
    open one_cursor for
    select StockId, KNTITRANSACTIONTYPEID, ReferenceNo, ReferenceDate, StockTransNO, StockTransDATE,
    supplierID,SupplierInvoiceNo,SupplierInvoiceDate,Remarks, SubConId
    from T_KnitStock
    where StockId=pKnitStockID;

    open many_cursor for
    select PID,a.ORDERNO,GetfncWOBType(a.OrderNo) as btype,fncTransOrder(a.STOCKID+1,KNTISTOCKITEMSL) as TOrderNo,a.STOCKID, KNTISTOCKITEMSL,a.YarnCountId, a.YarnTypeId,
    a.FabricTypeId,a.OrderlineItem,a.Quantity, a.Squantity,a.PunitOfmeasId,a.SUNITOFMEASID,a.REQQUANTITY,a.YarnBatchNo,
    a.Shade,a.REMARKS,a.CurrentStock,a.supplierID,a.RequisitionNo,a.SubConId,b.SHADEGROUPID,b.SHADEGROUPNAME,
    c.KNTITRANSACTIONTYPEID,a.REMAINQTY,a.yarnfor
    from T_KnitStockItems a,T_ShadeGroup b,T_KnitStock c
    where a.STOCKID=c.STOCKID and
    a.STOCKID=pKnitStockID and
    a.SHADEGROUPID=b.SHADEGROUPID
    order by KNTISTOCKITEMSL asc;
END GetknitStockInfo;
/





PROMPT CREATE OR REPLACE Procedure  047 :: GetKnittingMergeList
CREATE OR REPLACE Procedure GetKnittingMergeList
(
  pStatus number,
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)

AS

BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=0 then
  OPEN data_cursor for
   select a.WOSLNO,a.ORDERNO,a.MERGEID,a.SHADEDETAILS,a.QTY,a.FABRICTYPEID,b.FABRICTYPE
	from t_KnittingMerge a,t_fabrictype b
	where a.FABRICTYPEID= b.FABRICTYPEID
	order by a.WOSLNO ASC;

/*If the Value is 1 then retun as the */

elsif pStatus=1 then
  OPEN data_cursor for
   select a.WOSLNO,a.ORDERNO,a.MERGEID,a.SHADEDETAILS,a.QTY,a.FABRICTYPEID,b.FABRICTYPE
	from t_KnittingMerge a,t_fabrictype b
	where a.FABRICTYPEID= b.FABRICTYPEID and  a.ORDERNO=pWhereValue order by a.WOSLNO ASC;
end if;
END GetKnittingMergeList;
/


PROMPT CREATE OR REPLACE Procedure  048 :: GetKnittingMergeLookUP
CREATE OR REPLACE Procedure GetKnittingMergeLookUP
(
  pStatus number,
  pWhereValue number,
  pMergeID number,
  data_cursor IN OUT pReturnData.c_Records
)

AS

BEGIN
/*if the Value is 0 then retun all the Data */
if pStatus=0 then
  OPEN data_cursor for
   select a.MERGEID,a.WOSLNO,a.FABRICTYPEID,a.ORDERNO,a.QTY,a.SHADEDETAILS
 from  T_knittingMerge a
 where a.ORDERNO= pWhereValue
 order by a.WOSLNO;

 elsif pStatus=1 then
  OPEN data_cursor for
   select a.MERGEID,a.WOSLNO,a.FABRICTYPEID,a.ORDERNO,a.QTY,a.SHADEDETAILS
 from  T_knittingMerge a
 where a.ORDERNO= pWhereValue and a.MERGEID=pMergeID
 order by a.WOSLNO;
end if;
END GetKnittingMergeLookUP;
/



PROMPT CREATE OR REPLACE Procedure  049 :: GetKnitTransTypeLookUP
CREATE OR REPLACE Procedure GetKnitTransTypeLookUP
(
  data_cursor IN OUT pReturnData.c_Records
)

AS

BEGIN

  OPEN data_cursor for
  select KNTITRANSACTIONTYPEID,KnitTransactionType,ATLGYS,ATLGFS,ATLGYF,AYDLGYS,ODSCONGYS,KSCONGYS
  from t_KnitTransactionType
  order by KNTITRANSACTIONTYPEID;
END GetKnitTransTypeLookUP;
/



PROMPT CREATE OR REPLACE Procedure  050 :: GetKnitYarnReturnStockPosition
CREATE OR REPLACE Procedure GetKnitYarnReturnStockPosition(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pKnitTranTypeID NUMBER,
  pStockDate DATE
)
AS
BEGIN
/*  All Summary Report*/
  if pQueryType=0 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID, b.YARNBATCHNO,b.FABRICTYPEID,c.YarnCount, 
    d.YarnType, e.UnitOfMeas, sum(b.Quantity*ATLGYS) MainStore, 
    sum(b.Quantity*ATLGYF) SubStore, sum(b.Quantity*AYDLGYS) SubStock 
    from T_Knitstock a, T_KnitStockItems b, T_YarnCount c, T_YarnType d, 
    T_UnitOfMeas e, T_knitTransactionType f
    where a.StockID=b.StockID and
    b.yarnCountId=c.yarncountid and
    b.yarntypeid=d.yarntype and
    b.PunitOfMeasId=e.UnitOfmeasId and
    STOCKTRANSDATE <= pStockDate and
    a.KNTITRANSACTIONTYPEID = pKnitTranTypeID  ORDER BY btype;

        /* ATLGYS*/
  elsif pQueryType=1 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,b.Shade,
    b.OrderlineItem, b.YARNTYPEID,b.YARNCOUNTID,
    YarnCount,YarnType,b.PUnitOfMeasId,UnitOfMeas,b.DyedLotno,sum(Quantity*ATLGYS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,
    t_supplier h
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.YARNBATCHNO,b.Shade,b.SUPPLIERID,h.SUPPLIERNAME,b.DyedLotno
    having sum(Quantity*ATLGYS)>0  ORDER BY btype;

/*  ATLGFS*/
elsif pQueryType=2 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
    b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, b.Shade,    
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.DyedLotno,
    sum(Quantity*ATLGFS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,
    t_supplier h
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,             
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.YARNBATCHNO,b.SUPPLIERID,h.SUPPLIERNAME,b.DyedLotno
    having sum(Quantity*ATLGFS)>0  ORDER BY btype;


          /*GRAY YARN RETURN FROM ATLGYF TO MAIN STORE  */
elsif pQueryType=3 then
    open data_cursor for

    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,x.SUPPLIERNAME,b.YARNBATCHNO,b.yarnfor,
    b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
    j.SHADEGROUPNAME,'' AS Shade,YarnType,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,
    f.UnitOfMeas,'' AS DyedLotno,b.subconid,'' AS subconname,sum(Quantity*ATLGYF) CurrentStock,sum(SQuantity*ATLGYF) Cursqty
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,T_fabricType i,T_ShadeGroup j,T_UnitOfMeas k,T_supplier x
    where a.StockID=b.StockID and
    b.SHADEGROUPID=j.SHADEGROUPID and
	b.supplierid=x.supplierid(+) and
    b.FABRICTYPEID=i.FABRICTYPEID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId(+) and
    b.YarnTypeId= e.YarnTypeId(+) and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUnitOfMeasID=k.UnitOfMeasID(+) and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.OrderlineItem,b.yarnfor,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.SUPPLIERID,x.SUPPLIERNAME,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
	j.SHADEGROUPNAME,YarnType,b.PUnitOfMeasId,f.UnitOfMeas,b.YARNBATCHNO,b.subconid,k.unitofmeas,b.sunitofmeasid
    having sum(Quantity*ATLGYF)>0  ORDER BY btype;

     /*GRAY YARN RETURN FROM AYDLGYS TO MAIN STORE  */
elsif pQueryType=4 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,b.yarnfor,x.SUPPLIERNAME,b.YARNBATCHNO,'' as OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,'' AS subconname,'' AS subconid,b.shadegroupid,j.shadeGroupName,b.fabrictypeid,
    i.FABRICTYPE,b.shade,'' as subconname,'' as DyedLotno,sum(Quantity*AYDLGYS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,T_FabricType i,t_shadegroup j,T_supplier x
    where a.StockID=b.StockID and
	b.FABRICTYPEID=i.FABRICTYPEID(+) and
    b.shadegroupid=j.shadegroupid and 
	b.supplierid=x.supplierid(+) and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.YARNBATCHNO,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.SUPPLIERID,x.SUPPLIERNAME,b.yarnfor,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.shadegroupid,j.shadeGroupName,b.fabrictypeid,i.FABRICTYPE,b.shade
    having sum(Quantity*AYDLGYS)>0;

                /*GRAY YARN RETURN FROM ODSCONGYS TO MAIN STORE  */
elsif pQueryType=5 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,x.SUPPLIERNAME,b.yarnfor,b.YARNBATCHNO,b.OrderlineItem,b.YARNTYPEID,
    b.YARNCOUNTID,YarnCount,YarnType,b.PUnitOfMeasId,UnitOfMeas,'' as DyedLotno,j.SHADEGROUPID,j.SHADEGROUPNAME,b.FABRICTYPEID,k.FABRICTYPE,
    b.Shade,b.subconid,i.subconname,sum(Quantity*ODSCONGYS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_subcontractors i,T_ShadeGroup j,T_fabricType k,T_supplier x
    where a.StockID=b.StockID and
    b.SHADEGROUPID=j.SHADEGROUPID and
	b.supplierid=x.supplierid(+) and
    b.FABRICTYPEID=k.FABRICTYPEID(+) and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID  and
    b.subconid=i.subconid and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.YARNBATCHNO,b.OrderlineItem,b.yarnfor,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,YarnType,b.SUPPLIERID,x.SUPPLIERNAME,
	b.PUnitOfMeasId,UnitOfMeas,j.SHADEGROUPID,j.SHADEGROUPNAME,b.FABRICTYPEID,k.FABRICTYPE,b.Shade,b.subconid,i.subconname
    having sum(Quantity*ODSCONGYS)>0  ORDER BY btype;

                /*GRAY YARN RETURN FROM KSCONGYS TO MAIN STORE  */
elsif pQueryType= 6 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,x.SUPPLIERNAME,b.YARNBATCHNO,b.yarnfor,
    '' as OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.ShadeGroupID,j.SHADEGROUPNAME,'' as Shade,b.FABRICTYPEID,i.FABRICTYPE,    
    YarnType,b.PUnitOfMeasId,f.UnitOfMeas,'' as DyedLotno,g.subconname,b.subconid,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,sum(Quantity*KSCONGYS) CurrentStock,sum(SQuantity*KSCONGYS) Cursqty
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_subcontractors g,T_fabricType i,T_ShadeGroup j,T_UnitOfMeas k,T_supplier x
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.SHADEGROUPID=j.SHADEGROUPID and
    b.FABRICTYPEID=i.FABRICTYPEID and
    b.YarnCountId=d.YarnCountId and
	b.supplierid=x.supplierid(+) and
    b.YarnTypeId= e.YarnTypeId and
     b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUnitOfMeasID=k.UnitOfMeasID(+) and
    b.subconid=g.subconid and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.YARNBATCHNO,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.yarnfor,
    b.ShadeGroupID,j.SHADEGROUPNAME,b.FABRICTYPEID,i.FABRICTYPE,b.SUPPLIERID,x.SUPPLIERNAME,    
    YarnType,b.PUnitOfMeasId,f.UnitOfMeas,g.subconname,b.subconid,k.unitofmeas,b.sunitofmeasid
    having sum(Quantity*KSCONGYS)>0 ORDER BY btype;
  end if;
END GetKnitYarnReturnStockPosition;
/





PROMPT CREATE OR REPLACE Procedure  051 :: GetKnitYarnStockPosition
CREATE OR REPLACE Procedure GetKnitYarnStockPosition(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pKnitTranTypeID NUMBER,
  pBatch in varchar2,
  pStockDate DATE
)
AS
BEGIN
/*  All Summary Report*/
  if pQueryType=0 then
    open data_cursor for
    select c.YarnCount,b.SUPPLIERID,g.SUPPLIERNAME, d.YarnType, e.UnitOfMeas, sum(b.Quantity*ATLGYS) MainStore, sum(b.Quantity*ATLGYF) SubStore, sum(b.Quantity*AYDLGYS) SubStock
    from T_Knitstock a, T_KnitStockItems b, T_YarnCount c, T_YarnType d, T_UnitOfMeas e, T_knitTransactionType f,
	t_supplier g
    where a.StockID=b.StockID and
	b.SUPPLIERID=g.SUPPLIERID and 
    b.yarnCountId=c.yarncountid and
    b.yarntypeid=d.yarntype and
    b.PunitOfMeasId=e.UnitOfmeasId and
    STOCKTRANSDATE <= pStockDate and
    a.KNTITRANSACTIONTYPEID = pKnitTranTypeID;

        /* ATLGYS*/
  elsif pQueryType=1 then
    open data_cursor for
    select b.YARNBATCHNO,b.SUPPLIERID,g.SUPPLIERNAME,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, 
    YarnType,b.PUnitOfMeasId,UnitOfMeas, sum(Quantity*ATLGYS) CurrentStock,b.yarnfor
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, T_YarnCount d, 
    T_YarnType e, T_UnitOfMeas f,T_supplier g
    where a.StockID=b.StockID and
    b.SUPPLIERID=g.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.YARNBATCHNO,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, 
    YarnType,b.PUnitOfMeasId,UnitOfMeas, b.SUPPLIERID,g.SUPPLIERNAME,b.yarnfor
    having sum(Quantity*ATLGYS)>0 ORDER BY YarnCount ASC;

/*  ATLGFS*/
elsif pQueryType=2 then
    open data_cursor for
    select b.YARNBATCHNO,b.SUPPLIERID,g.SUPPLIERNAME,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, YarnType,b.PUnitOfMeasId,UnitOfMeas,
    sum(Quantity*ATLGFS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier g
    where a.StockID=b.StockID and
	b.SUPPLIERID=g.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
            group by b.YARNBATCHNO,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, YarnType,b.PUnitOfMeasId,UnitOfMeas,
			b.SUPPLIERID,g.SUPPLIERNAME
    having sum(Quantity*ATLGFS)>0;

        /* ATLGYF */
elsif pQueryType=3 then
    open data_cursor for
    select b.YARNBATCHNO,b.SUPPLIERID,g.SUPPLIERNAME,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, YarnType,b.PUnitOfMeasId,UnitOfMeas,
    sum(Quantity*ATLGYF) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier g
    where a.StockID=b.StockID and
	b.SUPPLIERID=g.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
            group by b.YARNBATCHNO,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, YarnType,b.PUnitOfMeasId,UnitOfMeas,
			b.SUPPLIERID,g.SUPPLIERNAME
    having sum(Quantity*ATLGYF)>0;

                /* AYDLGYS */
elsif pQueryType=4 then
    open data_cursor for
    select b.YARNBATCHNO,b.SUPPLIERID,g.SUPPLIERNAME,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, YarnType,b.PUnitOfMeasId,UnitOfMeas,
    sum(Quantity*AYDLGYS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier g
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
	b.SUPPLIERID=g.SUPPLIERID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
            group by b.YARNBATCHNO,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, YarnType,b.PUnitOfMeasId,UnitOfMeas,
		   b.SUPPLIERID,g.SUPPLIERNAME
    having sum(Quantity*AYDLGYS)>0;

                /*ODSCONGYS*/
elsif pQueryType=5 then
    open data_cursor for
    select b.YARNBATCHNO,b.SUPPLIERID,g.SUPPLIERNAME,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, YarnType,b.PUnitOfMeasId,UnitOfMeas,
    sum(Quantity*ODSCONGYS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier g
    where a.StockID=b.StockID and
	b.SUPPLIERID=g.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
            group by b.YARNBATCHNO,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, YarnType,b.PUnitOfMeasId,UnitOfMeas,
			b.SUPPLIERID,g.SUPPLIERNAME
    having sum(Quantity*ODSCONGYS)>0;

                /*KSCONGYS*/
elsif pQueryType= 6 then
    open data_cursor for
    select b.YARNBATCHNO,b.SUPPLIERID,g.SUPPLIERNAME,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, YarnType,b.PUnitOfMeasId,UnitOfMeas,
    sum(Quantity*KSCONGYS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier g
    where a.StockID=b.StockID and
	b.SUPPLIERID=g.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.YARNBATCHNO,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, YarnType,b.PUnitOfMeasId,UnitOfMeas,
	b.SUPPLIERID,g.SUPPLIERNAME			
    having sum(Quantity*KSCONGYS)>0;
 
elsif pQueryType=7 then
    open data_cursor for
    select b.YARNBATCHNO,b.SUPPLIERID,g.SUPPLIERNAME,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, 
    YarnType,b.PUnitOfMeasId,UnitOfMeas,
    sum(Quantity*ATLGYS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, T_YarnCount d, 
    T_YarnType e, T_UnitOfMeas f,t_supplier g
    where a.StockID=b.StockID and
    b.SUPPLIERID=g.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate and
    b.YARNBATCHNO LIKE pBatch
    group by b.YARNBATCHNO,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, 
    YarnType,b.PUnitOfMeasId,UnitOfMeas,
    b.SUPPLIERID,g.SUPPLIERNAME
    having sum(Quantity*ATLGYS)>0;
	        /* ATLGYS FOR YARN PRICE ENTRY*/
  elsif pQueryType=8 then
    open data_cursor for
    select b.YARNBATCHNO,b.SUPPLIERID,g.SUPPLIERNAME,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, 
    YarnType,b.PUnitOfMeasId,UnitOfMeas, sum(Quantity*ATLGYS) CurrentStock,b.yarnfor
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, T_YarnCount d, 
    T_YarnType e, T_UnitOfMeas f,T_supplier g
    where a.StockID=b.StockID and
    b.SUPPLIERID=g.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.YARNBATCHNO,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, 
    YarnType,b.PUnitOfMeasId,UnitOfMeas, b.SUPPLIERID,g.SUPPLIERNAME,b.yarnfor
    /*having sum(Quantity*ATLGYS)>0*/ ORDER BY YarnCount ASC;

  end if;
END GetKnitYarnStockPosition;
/




PROMPT CREATE OR REPLACE Procedure  052 :: GetMcPartsTypeLookUp
CREATE OR REPLACE Procedure GetMcPartsTypeLookUp
(
  pStatus number,
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)

AS

BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=0 then
  OPEN data_cursor for
   select MCPARTSTYPEID,MCPARTSTYPE
 from t_McPartsType order by MCPARTSTYPE;

/*If the Value is 1 then retun as the */

elsif pStatus=1 then
  OPEN data_cursor for
  select MCPARTSTYPEID,MCPARTSTYPE
 from t_McPartsType where MCPARTSTYPEID=pWhereValue order by MCPARTSTYPE;
end if;
END GetMcPartsTypeLookUp;
/


PROMPT CREATE OR REPLACE Procedure  053 :: GETOBJECT
CREATE OR REPLACE Procedure GETOBJECT
(
  pStatus number,
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)

AS

BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=0 then
  OPEN data_cursor for
  select ObjectId,ObjectName, OBJECTType from T_Object order by ObjectId;
/*If the Value is 1 then retun as the */

elsif pStatus=1 then
  OPEN data_cursor for
   select ObjectId,ObjectName,OBJECTType from T_Object
  where ObjectId=pWhereValue order by ObjectName;
end if;
END GETOBJECT;
/


PROMPT CREATE OR REPLACE Procedure  054 :: GetOrderItemKnittingMerge
CREATE OR REPLACE Procedure GetOrderItemKnittingMerge
(
  pStatus number,
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)

AS

BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=0 then
  OPEN data_cursor for
   Select a.ORDERLINEITEM,a.MERGEID,a.ORDERNO,a.PID
   from T_orderItemKnittingMerge a
    order by a.ORDERLINEITEM;


/*If the Value is 1 then retun as the  Work Order */

elsif pStatus=1 then
  OPEN data_cursor for
   Select a.ORDERLINEITEM,a.MERGEID,a.ORDERNO,a.PID
   from T_orderItemKnittingMerge a
	where   a.ORDERNO=pWhereValue	order by a.ORDERLINEITEM;

/*If the Value is 1 then retun as the  Work Order */

elsif pStatus=2 then
  OPEN data_cursor for
   Select a.ORDERLINEITEM,a.MERGEID,a.ORDERNO,a.PID
   from T_orderItemKnittingMerge a
	where   a.MERGEID=pWhereValue	order by a.ORDERLINEITEM;

elsif pStatus=3 then
  OPEN data_cursor for
   Select a.ORDERLINEITEM,a.MERGEID,a.ORDERNO,a.PID
   from T_orderItemKnittingMerge a
	where   a.ORDERLINEITEM=pWhereValue	order by a.ORDERLINEITEM;
end if;
END GetOrderItemKnittingMerge;
/

PROMPT CREATE OR REPLACE Procedure  055 :: GetOrderLineItemList
Create or Replace Procedure GetOrderLineItemList
(
  data_cursor IN OUT pReturnData.c_Records,
  pStatus number,
  pWhereValue number

)
AS
BEGIN
/*if the Value is 0 then retun all the Data */
if pStatus=0 then
  OPEN data_cursor for
   Select a.FABRICTYPEID,a.ORDERNO,getfncWOBType(a.ORDERNO) as btype,a.ORDERLINEITEM,a.KNITMCDIAGAUGE,a.FINISHEDGSM,
   a.WIDTH,a.SHRINKAGE,a.SHADE,a.FEEDERCOUNT,getFncYarnDes(a.ORDERLINEITEM) as YarnDesc,b.FABRICTYPE,
   getFncYarnDes(a.ORDERLINEITEM) as YarnDesc,a.WOITEMSL,a.ShadeGroupID,c.SHADEGROUPNAME,a.QUANTITY,
	NVL((SELECT sum(y.QUANTITY) FROM T_KNITSTOCK x,T_KNITSTOCKITEMS y
	where x.stockID=y.stockID and y.ORDERNO=a.Orderno and y.FABRICTYPEID=a.FABRICTYPEID and
	y.shadegroupid=a.SHADEGROUPID and y.ORDERLINEITEM=a.ORDERLINEITEM and KNTITRANSACTIONTYPEID in (24,25)),0) as ReceivedQty,
   	(a.QUANTITY-NVL((SELECT sum(y.QUANTITY) FROM T_KNITSTOCK x,T_KNITSTOCKITEMS y
	where x.stockID=y.stockID and y.ORDERNO=a.Orderno and y.FABRICTYPEID=a.FABRICTYPEID and
	y.shadegroupid=a.SHADEGROUPID and y.ORDERLINEITEM=a.ORDERLINEITEM and KNTITRANSACTIONTYPEID in (24,25)),0)) as RemainQty
	from T_Orderitems a,t_fabricType b,T_ShadeGroup c
   where a.FABRICTYPEID=b.FABRICTYPEID
   and a.SHADEGROUPID=c.SHADEGROUPID
   and a.ORDERNO=pWhereValue
   order by a.ORDERLINEITEM;

/*Work Order lineitems for Dyed yarn Fabric Received*/
elsif pStatus=1 then
  OPEN data_cursor for
   Select a.FABRICTYPEID,a.ORDERNO,getfncWOBType(a.ORDERNO) as btype,a.ORDERLINEITEM,a.KNITMCDIAGAUGE,a.FINISHEDGSM,
   a.WIDTH,a.SHRINKAGE,a.SHADE,a.FEEDERCOUNT,getFncYarnDes(a.ORDERLINEITEM) as YarnDesc,b.FABRICTYPE,
   getFncYarnDes(a.ORDERLINEITEM) as YarnDesc,a.WOITEMSL,a.ShadeGroupID,c.SHADEGROUPNAME,a.QUANTITY,
	NVL((SELECT sum(y.QUANTITY) FROM T_KNITSTOCK x,T_KNITSTOCKITEMS y
	where x.stockID=y.stockID and y.ORDERNO=a.Orderno and y.FABRICTYPEID=a.FABRICTYPEID and
	y.shadegroupid=a.SHADEGROUPID and y.ORDERLINEITEM=a.ORDERLINEITEM and KNTITRANSACTIONTYPEID in (24,25)),0) as ReceivedQty,
   	(a.QUANTITY-NVL((SELECT sum(y.QUANTITY) FROM T_KNITSTOCK x,T_KNITSTOCKITEMS y
	where x.stockID=y.stockID and y.ORDERNO=a.Orderno and y.FABRICTYPEID=a.FABRICTYPEID and
	y.shadegroupid=a.SHADEGROUPID and y.ORDERLINEITEM=a.ORDERLINEITEM and KNTITRANSACTIONTYPEID in (24,25)),0)) as RemainQty,a.sqty as Sqty
	from T_Orderitems a,t_fabricType b,T_ShadeGroup c
   where a.FABRICTYPEID=b.FABRICTYPEID
   and	a.SHADEGROUPID=c.SHADEGROUPID
   and a.ORDERNO=pWhereValue
   order by a.ORDERLINEITEM;

/*Work Order lineitems for Gray yarn Fabric Batch*/
elsif pStatus=2 then
  OPEN data_cursor for
   Select a.FABRICTYPEID,a.ORDERNO,getfncWOBType(a.ORDERNO) as btype,a.ORDERLINEITEM,a.KNITMCDIAGAUGE,a.FINISHEDGSM,
   a.WIDTH,a.SHRINKAGE,a.SHADE,a.FEEDERCOUNT,getFncYarnDes(a.ORDERLINEITEM) as YarnDesc,COLLARCUFFSIZE,b.FABRICTYPE,a.QUANTITY,
   getFncYarnDes(a.ORDERLINEITEM) as YarnDesc,a.WOITEMSL,a.ShadeGroupID,c.SHADEGROUPNAME,a.sqty as sqty,
        NVL((SELECT sum(QUANTITY) FROM T_DBATCHITEMS
	where ORDERNO=a.Orderno and FABRICTYPEID=a.FABRICTYPEID and
	shadegroupid=a.SHADEGROUPID and ORDERLINEITEM=a.ORDERLINEITEM),0) as BatchedQty,
	(a.QUANTITY-NVL((SELECT sum(QUANTITY) FROM T_DBATCHITEMS
	where ORDERNO=a.Orderno and FABRICTYPEID=a.FABRICTYPEID and
	shadegroupid=a.SHADEGROUPID and ORDERLINEITEM=a.ORDERLINEITEM),0)) as RemainQty
   from T_Orderitems a,t_fabricType b,T_ShadeGroup c,T_COLLARCUFF d
   where a.FABRICTYPEID=b.FABRICTYPEID
   and a.SHADEGROUPID=c.SHADEGROUPID
   and a.COLLARCUFFID=d.COLLARCUFFID
   and a.ORDERNO=pWhereValue
   order by a.ORDERLINEITEM;

/*Work Order lineitems for Gray yarn Fabric Received */
elsif pStatus=3 then
  OPEN data_cursor for
   Select a.ORDERNO,d.unitofmeas as sunit,a.sunit as sunitid,a.UNITOFMEASID,getfncWOBType(a.ORDERNO) as btype,
   a.FABRICTYPEID,b.FABRICTYPE,a.ORDERLINEITEM,a.ShadeGroupID,c.SHADEGROUPNAME,SUM(a.QUANTITY) AS QUANTITY,
        NVL((SELECT sum(y.QUANTITY) FROM T_KNITSTOCK x,T_KNITSTOCKITEMS y
	where x.stockID=y.stockID and y.ORDERNO=a.Orderno and y.FABRICTYPEID=a.FABRICTYPEID and
	y.shadegroupid=a.SHADEGROUPID and KNTITRANSACTIONTYPEID in (6,7)),0) as ReceivedQty,
	(SUM(a.QUANTITY)-NVL((SELECT sum(y.QUANTITY) FROM T_KNITSTOCK x,T_KNITSTOCKITEMS y
	where x.stockID=y.stockID and y.ORDERNO=a.Orderno and y.FABRICTYPEID=a.FABRICTYPEID and
	y.shadegroupid=a.SHADEGROUPID and KNTITRANSACTIONTYPEID in (6,7)),0)) as RemainQty,sum(a.sqty) as Sqty
   from T_Orderitems a,t_fabricType b,T_ShadeGroup c,t_unitofmeas d, t_unitofmeas e
   where a.FABRICTYPEID=b.FABRICTYPEID
   and a.SHADEGROUPID=c.SHADEGROUPID and a.sunit=d.unitofmeasid(+) and a.UNITOFMEASID=e.unitofmeasid(+)
   and a.ORDERNO=pWhereValue
   GROUP BY a.ORDERNO,a.FABRICTYPEID,a.ORDERLINEITEM,b.FABRICTYPE,a.ShadeGroupID,c.SHADEGROUPNAME,d.unitofmeas,a.UNITOFMEASID,a.sunit;

/*Work Order lineitems for Dyed yarn Fabric Received*/
elsif pStatus=4 then
  OPEN data_cursor for

   Select a.ORDERNO,d.unitofmeas as sunit,a.UNITOFMEASID,getfncWOBType(a.ORDERNO) as btype,
   '' as FABRICTYPEID,'' as FABRICTYPE,a.ShadeGroupID,c.SHADEGROUPNAME,SUM(a.QUANTITY) AS QUANTITY,
        NVL((SELECT sum(y.QUANTITY) FROM T_KNITSTOCK x,T_KNITSTOCKITEMS y
	where x.stockID=y.stockID and y.ORDERNO=a.Orderno and
	y.shadegroupid=a.SHADEGROUPID and KNTITRANSACTIONTYPEID in (6,7)),0) as ReceivedQty,
	(SUM(a.QUANTITY)-NVL((SELECT sum(y.QUANTITY) FROM T_KNITSTOCK x,T_KNITSTOCKITEMS y
	where x.stockID=y.stockID and y.ORDERNO=a.Orderno and
	y.shadegroupid=a.SHADEGROUPID and KNTITRANSACTIONTYPEID in (6,7)),0)) as RemainQty,sum(a.sqty) as Sqty
   from T_Orderitems a,t_fabricType b,T_ShadeGroup c ,t_unitofmeas d, t_unitofmeas e
   where a.FABRICTYPEID=b.FABRICTYPEID
   and a.SHADEGROUPID=c.SHADEGROUPID and a.sunit=d.unitofmeasid(+) and a.UNITOFMEASID=e.unitofmeasid(+)
   and a.ORDERNO=pWhereValue
   GROUP BY a.ORDERNO,a.ShadeGroupID,c.SHADEGROUPNAME,d.unitofmeas,a.UNITOFMEASID;


elsif pStatus=5 then
  OPEN data_cursor for
   Select a.ORDERNO,getfncWOBType(a.ORDERNO) as btype,a.UNITOFMEASID,a.sunit,d.unitofmeas,e.unitofmeas as sunitofmeas,
   a.FABRICTYPEID,b.FABRICTYPE,a.ShadeGroupID,c.SHADEGROUPNAME,sum(a.QUANTITY) AS QUANTITY,sum(a.sqty) AS Sqty
   from T_Orderitems a,t_fabricType b,T_ShadeGroup c,t_unitofmeas d,t_unitofmeas e
   where a.FABRICTYPEID=b.FABRICTYPEID and a.SHADEGROUPID=c.SHADEGROUPID and
   a.unitofmeasid=d.unitofmeasid(+) and
   a.sunit=e.unitofmeasid(+) 
   and a.ORDERNO=pWhereValue
   GROUP BY a.ORDERNO,a.FABRICTYPEID,b.FABRICTYPE,a.ShadeGroupID,c.SHADEGROUPNAME,a.UNITOFMEASID,a.sunit,d.unitofmeas,e.unitofmeas;

elsif pStatus=6 then
  OPEN data_cursor for
   Select a.ORDERNO,getfncWOBType(a.ORDERNO) as btype,a.ORDERLINEITEM,a.UNITOFMEASID,a.sunit,d.unitofmeas,e.unitofmeas as sunitofmeas,
   a.FABRICTYPEID,b.FABRICTYPE,a.ShadeGroupID,c.SHADEGROUPNAME,a.QUANTITY,a.sqty as sqty
   from T_Orderitems a,t_fabricType b,T_ShadeGroup c,t_unitofmeas d,t_unitofmeas e
   where a.FABRICTYPEID=b.FABRICTYPEID and a.SHADEGROUPID=c.SHADEGROUPID and
   a.unitofmeasid=d.unitofmeasid(+) and
   a.sunit=e.unitofmeasid(+) 
   and a.ORDERNO=pWhereValue;

/*pICKUP FOR SHADE TRANSFER BATHCHING FLOOR*/
elsif pStatus=7 then
  OPEN data_cursor for

   select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.FABRICTYPEID,FABRICTYPE,'' as OrderlineItem,b.Shade,
	b.PUnitOfMeasId as UNITOFMEASID,f.UnitOfMeas,b.sUnitOfMeasId as sunit,i.unitofmeas as sunitofmeas,
	b.shadegroupid,h.shadegroupname,
	b.YARNBATCHNO,b.DYEDLOTNO,b.YARNTYPEID,b.YARNCOUNTID,'' YarnCount,'' YarnType,
	(sum(Quantity*ATLGFDF)-NVL(decode(b.DYEDLOTNO,null,(SELECT sum(QUANTITY) FROM T_DBATCHITEMS 
	where ORDERNO=b.Orderno and FABRICTYPEID=b.FABRICTYPEID and 
	shadegroupid=b.Shadegroupid and YARNBATCHNO=b.YARNBATCHNO and Shade=b.Shade),(SELECT sum(QUANTITY) FROM T_DBATCHITEMS 
	where ORDERNO=b.Orderno and FABRICTYPEID=b.FABRICTYPEID and 
	shadegroupid=b.Shadegroupid and YARNBATCHNO=b.YARNBATCHNO and DYEDLOTNO=b.DYEDLOTNO and Shade=b.Shade)),0)) as  QUANTITY,
	(sum(SQuantity*ATLGFDF)-NVL(decode(b.DYEDLOTNO,null,(SELECT sum(SQuantity) FROM T_DBATCHITEMS 
	where ORDERNO=b.Orderno and FABRICTYPEID=b.FABRICTYPEID and 
	shadegroupid=b.Shadegroupid and YARNBATCHNO=b.YARNBATCHNO and Shade=b.Shade),(SELECT sum(SQuantity) FROM T_DBATCHITEMS 
	where ORDERNO=b.Orderno and FABRICTYPEID=b.FABRICTYPEID and 
	shadegroupid=b.Shadegroupid and YARNBATCHNO=b.YARNBATCHNO and DYEDLOTNO=b.DYEDLOTNO and Shade=b.Shade)),0)) as sqty
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_UnitOfMeas f,T_FabricType g,T_shadeGroup h,T_UnitOfMeas i
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.FABRICTYPEID=g.FABRICTYPEID and 
    b.shadegroupid=h.shadegroupid and 
    b.PUnitOfMeasID=f.UnitOfMeasID(+)  and
    b.SUnitOfMeasID=i.UnitOfMeasID(+)  and b.ORDERNO=pWhereValue
    group by b.ORDERNO,b.Shade,b.PUnitOfMeasId,f.UnitOfMeas,b.FABRICTYPEID,FABRICTYPE,b.YARNBATCHNO,b.DYEDLOTNO,b.YARNTYPEID,b.YARNCOUNTID,
    b.shadegroupid,h.shadegroupname,b.sUnitOfMeasId,i.unitofmeas
    	having (sum(Quantity*ATLGFDF)-NVL(decode(b.DYEDLOTNO,null,(SELECT sum(QUANTITY) FROM T_DBATCHITEMS 
	where ORDERNO=b.Orderno and FABRICTYPEID=b.FABRICTYPEID and 
	shadegroupid=b.Shadegroupid and YARNBATCHNO=b.YARNBATCHNO and Shade=b.Shade),(SELECT sum(QUANTITY) FROM T_DBATCHITEMS 
	where ORDERNO=b.Orderno and FABRICTYPEID=b.FABRICTYPEID and 
	shadegroupid=b.Shadegroupid and YARNBATCHNO=b.YARNBATCHNO and DYEDLOTNO=b.DYEDLOTNO and Shade=b.Shade)),0)) >0 	
    ORDER BY btype;
end if;
END GetOrderLineItemList;
/




PROMPT CREATE OR REPLACE Procedure  056 :: GetOrderStatusIDs
CREATE OR REPLACE Procedure GetOrderStatusIDs
(
  pStatus number,
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)

AS

BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=0 then
  OPEN data_cursor for
  Select OrderStatusID, OrderStatus
	from T_OrderStatus order by OrderStatusID;
/*If the Value is 1 then retun as the */

elsif pStatus=1 then
  OPEN data_cursor for
   Select OrderStatusID, OrderStatus
	from T_OrderStatus
	 where OrderStatusID=pWhereValue order by OrderStatusID;
end if;
END GetOrderStatusIDs;
/


PROMPT CREATE OR REPLACE Procedure  057 :: GetPlanStatusLookUp
CREATE OR REPLACE Procedure GetPlanStatusLookUp
(
  data_cursor IN OUT pReturnData.c_Records
)

AS

BEGIN
/*if the Value is 0 then retun all the Data */

  OPEN data_cursor for
   select a.PLANSTATUSID,a.PLANSTATUS
 from  T_planStatus a order by a.PLANSTATUSID;

END GetPlanStatusLookUp;
/

PROMPT CREATE OR REPLACE Procedure  058 :: GetSalesTerm
CREATE OR REPLACE Procedure GetSalesTerm
(
  pStatus number,
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)

AS

BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=0 then
  OPEN data_cursor for
  Select salestermid,salesTerm
  	from T_salesterm order by salestermid;

/*If the Value is 1 then retun as the */

elsif pStatus=1 then
  OPEN data_cursor for
   Select salestermid,salesTerm
	from T_salesterm
	 where salestermid=pWhereValue order by salestermid;
end if;
END GetSalesTerm;
/

PROMPT CREATE OR REPLACE Procedure  059 :: GetSpareType
CREATE OR REPLACE Procedure GetSpareType
(
  pStatus number,
  pWhereValue number,
  data_cursor IN OUT pReturnData.c_Records
)

AS

BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=0 then
  OPEN data_cursor for
   select SpareTypeID,SpareTypeName
 from t_sparetype order by SpareTypeName;

/*If the Value is 1 then retun as the */

elsif pStatus=1 then
  OPEN data_cursor for
select SpareTypeID,SpareTypeName
 from t_sparetype where SpareTypeID=pWhereValue order by SpareTypeName;
end if;
END GetSpareType;
/


PROMPT CREATE OR REPLACE Procedure  060 :: GetSpareTypeLookUp
CREATE OR REPLACE Procedure GetSpareTypeLookUp
(
  pStatus number,
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)

AS

BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=0 then
  OPEN data_cursor for
   select SPARETYPEID,SPARETYPENAME
	from t_sparetype order by SPARETYPENAME;

/*If the Value is 1 then retun as the */

elsif pStatus=1 then
  OPEN data_cursor for
  select SPARETYPEID,SPARETYPENAME
	from t_sparetype where SPARETYPEID=pWhereValue order by SPARETYPENAME;
end if;
END GetSpareTypeLookUp;
/


PROMPT CREATE OR REPLACE Procedure  061 :: GetStoreLocation
CREATE OR REPLACE Procedure GetStoreLocation
(
  pStatus number,
  pWhereValue number,
  data_cursor IN OUT pReturnData.c_Records
)

AS

BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=0 then
  OPEN data_cursor for
   select LocationID,Location
 from t_storeLocation order by Location;

/*If the Value is 1 then retun as the */

elsif pStatus=1 then
  OPEN data_cursor for
select LocationID,Location
 from t_storeLocation where LocationID=pWhereValue order by Location;
end if;
END GetStoreLocation;
/


PROMPT CREATE OR REPLACE Procedure  062 :: GetStoreLocationLookUp
CREATE OR REPLACE Procedure GetStoreLocationLookUp
(
  pStatus number,
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)

AS

BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=0 then
  OPEN data_cursor for
   select LOCATIONID,LOCATION
	from t_storelocation order by LOCATION;

/*If the Value is 1 then retun as the */

elsif pStatus=1 then
  OPEN data_cursor for
  select LOCATIONID,LOCATION
	from t_storelocation where LOCATIONID=pWhereValue order by LOCATION;
end if;
END GetStoreLocationLookUp;
/


PROMPT CREATE OR REPLACE Procedure  063 :: GetSubContracttorLookUp
CREATE OR REPLACE Procedure GetSubContracttorLookUp
(
  pStatus number,
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)

AS

BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=0 then
  OPEN data_cursor for
   select a.SubConid,a.SubConName,a.SubAddress,a.SUBFACTORYADDRESS,a.SUBCONTACTPERSON
	from t_subContractors a order by SubConName;

/*If the Value is 1 then retun as the */

elsif pStatus=1 then
  OPEN data_cursor for
   select a.SubConid,a.SubConName,a.SubAddress,a.SUBFACTORYADDRESS,a.SUBCONTACTPERSON
	from t_subContractors a where SubConid=pWhereValue  order by SubConName ;
end if;
END GetSubContracttorLookUp;
/

PROMPT CREATE OR REPLACE Procedure  064 :: GetSupplierInfo
CREATE OR REPLACE Procedure GetSupplierInfo
(
  pStatus number,
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=0 then 
  OPEN data_cursor for
   Select SupplierName, SupplierID, SAddress,
    STelephone,SFax,SEmail,SURL,SContactperson,
    SRemarks from T_Supplier
    order by SupplierName;
/*If the Value is 1 then retun as the */

elsif pStatus=1 then 
     OPEN data_cursor for
   Select SupplierName, SupplierID, SAddress,
    STelephone,SFax,SEmail,SURL,SContactperson,
    SRemarks from T_Supplier where 
     SupplierID=pWhereValue order by SupplierName;
end if;
END GetSupplierInfo;
/

PROMPT CREATE OR REPLACE Procedure  065 :: getSupplierList
CREATE OR REPLACE Procedure getSupplierList (
  io_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pSupplierId IN NUMBER,
  pGroupId IN NUMBER
)
AS
BEGIN

  if pQueryType=0 then
    OPEN io_cursor FOR
    select SupplierId,SupplierName,SAddress,Stelephone,SGroupId,SContactPerson from T_Supplier		
    order by SupplierName asc;

  elsif pQueryType=1 then
    OPEN io_cursor FOR
    select SupplierId,SupplierName,SAddress,Stelephone,SGroupId,SContactPerson from T_Supplier
    where supplierId=pSupplierId
    order by SupplierId asc, SupplierName asc;

  elsif pQueryType=2 then
    OPEN io_cursor FOR
    select SupplierId,SupplierName,SAddress,Stelephone,SGroupId,SContactPerson from T_Supplier
    where SGroupId=pGroupId
    order by SGroupId asc, SupplierName asc;
  end if;
END getSupplierList;
/


PROMPT CREATE OR REPLACE Procedure  066 :: getTreeAuxImpLCList
CREATE OR REPLACE Procedure getTreeAuxImpLCList (
  io_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pLCNo IN NUMBER,
  sDate IN date,
  eDate IN date
)
AS
  vSDate date;
  vEDate date;
BEGIN
  vSDate := TO_DATE('01/01/1900', 'DD/MM/YYYY');
  vEDate := TO_DATE('01/01/2999', 'DD/MM/YYYY');
  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  end if;
  
/* For all The Data*/
  if pQueryType=0 then
    OPEN io_cursor FOR
    select LCNo, BankLCNo from T_AuxImpLC
 order by lcno desc ;

 /* For Supplier Name*/

  elsif pQueryType=1 then
    OPEN io_cursor FOR
    select b.SUPPLIERNAME, LCNo, BankLCNo
    from T_AuxImpLC a, T_SUPPLIER b 
    where a.SupplierID=b.SupplierID and
          OPeningDate>=SDate and OPeningDate<=EDate
    order by a.SupplierID, BankLCNo desc;


 /* for Lc Status */
  elsif pQueryType=2 then
    OPEN io_cursor FOR
    select b.ImpLCStatus, LCNo, BankLCNo
    from T_AuxImpLC a, T_ImpLCStatus b
    where a.ImpLCStatusId=b.ImpLCStatusId and
    OPeningDate>=SDate and OPeningDate<=EDate
    order by a.ImpLCStatusId, BankLCNo desc;

 /*  For LC Type */
  elsif pQueryType=3 then
    OPEN io_cursor FOR
    select  b.impLctype, LCNo, BankLCNo
    from T_AuxImpLC a, T_ImpLCtype b
    where a.IMPLctypeid=b.impLctypeid and
    OPeningDate>=SDate and OPeningDate<=EDate
    order by a.ImpLctypeid, BankLCNo desc;
 /* */
  elsif pQueryType=9999 then
    OPEN io_cursor FOR
    select LCNo from T_AuxImpLC
    where  OPeningDate>=SDate and OPeningDate<=EDate and
    Upper(BankLCNo) Like pLCNo;
  end if;
END getTreeAuxImpLCList;
/



PROMPT CREATE OR REPLACE Procedure  067 :: getTreeAuxList
CREATE OR REPLACE Procedure getTreeAuxList (
  io_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pAuxType IN NUMBER
)
AS
BEGIN


 /* Grouping For Chemicals*/
  if pQueryType=1 then
      OPEN io_cursor FOR
      select DyeBaseId, AuxId,AuxTypeId, AuxName from T_Auxiliaries
      where AuxTypeId=pAuxType
      order by AuxName;

/* Grouping For Dyes*/
  elsif pQueryType=2 then
      OPEN io_cursor FOR
      select b.Dyebase,a.DyeBaseId, AuxId,AuxTypeId, AuxName from T_Auxiliaries a,T_dyebase b
      where AuxTypeId=pAuxType and
      a.DyeBaseId=b.DyebaseId
      order by DyeBase,AuxName;

/*Grouping for Misc*/
  elsif pQueryType=3 then
      OPEN io_cursor FOR
      select DyeBaseId, AuxId,AuxTypeId, AuxName from T_Auxiliaries
      where AuxTypeId=pAuxType
      order by AuxName;
  end if;

END getTreeAuxList;
/



PROMPT CREATE OR REPLACE Procedure  068 :: getTreeAuxStockList
CREATE OR REPLACE Procedure getTreeAuxStockList (
  io_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pStockType IN NUMBER,
  pInvoiceNo IN VARCHAR2 DEFAULT NULL,
  sDate IN date,
  eDate IN date
)
AS
BEGIN

  if pQueryType=0 then
    OPEN io_cursor FOR
    select AuxStockId, StockInvoiceNo from T_AuxStock
    where AuxStockTypeId=pStockType and
    StockDate>=SDate and StockDate<=EDate
    order by StockInvoiceNo desc;

  elsif pQueryType=1 then
    OPEN io_cursor FOR
    select AuxStockId, StockInvoiceNo, StockDate from T_AuxStock
    where AuxStockTypeId=pStockType and
    StockDate>=SDate and StockDate<=EDate
    order by StockDate desc, StockInvoiceNo desc;
	
  elsif pQueryType=20 then
     OPEN io_cursor FOR
    select A.AuxStockId, A.StockInvoiceNo, b.SupplierName from T_AuxStock A,T_Supplier b
    where AuxStockTypeId=pStockType and
	a.supplierid=b.supplierid and
    StockDate>=SDate and StockDate<=EDate
    order by StockDate desc, StockInvoiceNo desc;
	
	elsif pQueryType=2 then
	OPEN io_cursor FOR
    select d.AuxTypeId, c.DyeBaseId, d.AuxId, b.AuxType, a.DyeBase, c.AuxName
    from T_DyeBase a, T_AuxType b, T_Auxiliaries c, T_AuxStockItem d, T_AuxStock e
    where c.AuxId = d.AuxId and
    c.AuxTypeId = d.AuxTypeId and
    b.AuxTypeId = c.AuxTypeId and
    e.AuxStockId = d.AuxStockId and
    a.DyeBaseId(+) = c.DyeBaseId and
    StockDate>=SDate and StockDate<=EDate
    group by d.AuxTypeId, c.DyeBaseId, d.AuxId, b.AuxType, a.DyeBase, c.AuxName
    order by b.AuxType, a.DyeBase, c.AuxName;  
	
  elsif pQueryType=3 then
    OPEN io_cursor FOR
	select b.AUXID, c.AUXNAME,b.AuxTypeId,d.AuxType from t_auxStock a, T_AuxStockItem b, T_Auxiliaries c,T_AuxType d
    where AuxStockTypeId=pStockType and
	a.AuxStockId=b.AuxStockId and 
	b.AuxId=c.AuxId and
	d.AuxTypeId = c.AuxTypeId and
    a.StockDate>=SDate and StockDate<=EDate
	group by b.AUXID, c.AUXNAME,b.AuxTypeId,d.AuxType
    order by c.AUXNAME,d.AuxType;
	
  elsif pQueryType=9999 then
    OPEN io_cursor FOR
    select AuxStockId from T_AuxStock
    where AuxStockTypeId=pStockType and
    StockDate>=SDate and StockDate<=EDate and
    Upper(StockInvoiceNo) Like pInvoiceNo;
  end if;

END getTreeAuxStockList;
/


PROMPT CREATE OR REPLACE Procedure  069 :: getTreeKMcPartsInfoList
CREATE OR REPLACE Procedure getTreeKMcPartsInfoList(
  io_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pmcPartsType in number
)
AS
BEGIN
 /* For Parts Name*/
  if pQueryType=0 then
    OPEN io_cursor FOR
    	select a.PARTID,a.PARTNAME from t_kmcpartsinfo a
    	where a.MCPARTSTYPEID=pmcPartsType
    order by PARTNAME desc;
 /* For Machine Type  */
  elsif pQueryType=1 then
    OPEN io_cursor FOR
        select a.PARTID,a.PARTNAME,b.mcTypeNAme,c.Location from
        t_kmcpartsinfo a,t_kmcType b,t_storeLocation c,t_mcPartsType D
        where a.MCTYPEID=b.MCTYPEID and a.LOCATIONID=c.LOCATIONID
        and a.MCPARTSTYPEID=d.MCPARTSTYPEID and
        a.MCPARTSTYPEID=pmcPartsType
    order by b.MCTYPENAME desc;
 /* For Locaiton */
  elsif pQueryType=2 then
    OPEN io_cursor FOR
        select a.PARTID,a.PARTNAME,b.mcTypeNAme,c.Location from
        t_kmcpartsinfo a,t_kmcType b,t_storeLocation c,t_mcPartsType D
        where a.MCTYPEID=b.MCTYPEID and a.LOCATIONID=c.LOCATIONID and
    a.MCPARTSTYPEID=d.MCPARTSTYPEID and
        a.MCPARTSTYPEID=pmcPartsType
    order by c.LOCATION desc;
elsif pQueryType=3 then
 /* For Parts Type  */
    OPEN io_cursor FOR
        select a.PARTID,a.PARTNAME,b.mcTypeNAme,c.Location,d.MCPartsType from
        t_kmcpartsinfo a,t_kmcType b,t_storeLocation c,t_mcPartsType D
        where a.MCTYPEID=b.MCTYPEID and a.LOCATIONID=c.LOCATIONID
        and a.MCPARTSTYPEID=d.MCPARTSTYPEID and
        a.MCPARTSTYPEID=pmcPartsType
    order by d.MCPARTSTYPE desc;
  end if;
END getTreeKMcPartsInfoList;
/


PROMPT CREATE OR REPLACE Procedure  070 :: getTreeKmcStockList
CREATE OR REPLACE Procedure getTreeKmcStockList (
  io_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pStockType IN NUMBER,
  sDate IN date,
  eDate IN date
)
AS
BEGIN
/* for Any Stock Particular StockType with challan No*/
  if pQueryType=0 then
    OPEN io_cursor FOR
    select A.StockId, A.ChallanNo, B.Suppliername ,A.StockDate from T_KmcPartsTran A, T_Supplier B
    where KmcStockTypeId=pStockType and
	a.supplierid=b.supplierid(+) and 
    StockDate>=SDate and StockDate<=EDate order by 
    ChallanNo desc;	
/* for Any Stock Particular StockDate with challan No*/
  elsif pQueryType=1 then
    OPEN io_cursor FOR
    select A.StockId, A.ChallanNo, A.StockDate,B.Suppliername from T_KmcPartsTran A, T_Supplier B
    where KmcStockTypeId=pStockType and
	a.supplierid=b.supplierid(+) and 
    StockDate>=SDate and StockDate<=EDate order by 
    StockDate desc;	  
/* for Any Stock Particular SupplierName with challan No*/
  elsif pQueryType=2 then
    OPEN io_cursor FOR
    select A.StockId, A.ChallanNo, A.StockDate,B.Suppliername from T_KmcPartsTran A, T_Supplier B
    where KmcStockTypeId=pStockType and
	a.supplierid=b.supplierid(+) and 
    StockDate>=SDate and StockDate<=EDate order by 
    StockDate desc;

/* for Any Stock Particular MachinePartsName with challan No*/	
  elsif pQueryType=3 then
    OPEN io_cursor FOR
    select b.PARTID, c.PARTNAME from T_KmcPartsTran a, T_KMCPARTSTRANSDETAILS b, t_kmcpartsinfo c
    where a.KmcStockTypeId=pStockType and
	C.PARTID(+)=b.PARTID and
	a.STOCKID=b.STOCKID and	
    a.StockDate>=SDate and a.StockDate<=EDate 
	group by b.PARTID, c.PARTNAME
	order by c.PARTNAME;	
  end if;
END getTreeKmcStockList;
/

PROMPT CREATE OR REPLACE Procedure  071 :: getTreeKnitStockList
CREATE OR REPLACE Procedure getTreeKnitStockList (
  io_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pStockType IN NUMBER,
  pTransNo IN VARCHAR2 DEFAULT NULL,
  sDate IN date,
  eDate IN date
)
AS
BEGIN

  if pQueryType=0 then
    OPEN io_cursor FOR
    select StockId, StockTransNo from T_KnitStock
    where KNTITRANSACTIONTYPEID=pStockType and
    StockTransDate>=SDate and StockTransDate<=EDate
    order by StockTransNo desc;

  elsif pQueryType=1 then
    OPEN io_cursor FOR
    select StockId, StockTransNo, StockTransDate from T_KnitStock
    where KNTITRANSACTIONTYPEID=pStockType and
    StockTransDate>=SDate and StockTransDate<=EDate
    order by StockTransDate desc, StockTransNo desc;
elsif pQueryType=2 then
    OPEN io_cursor FOR
    select b.orderno, Getfncwobtype(b.orderno) as dorderno
    from T_KnitStock a,T_KnitStockItems b
    where a.stockid=b.stockid and KNTITRANSACTIONTYPEID=pStockType and
    StockTransDate>=SDate and StockTransDate<=EDate
    Group by b.orderno
    order by dorderno desc;
elsif pQueryType=3 then
    OPEN io_cursor FOR
    select a.StockId, a.StockTransNo,b.PARTYNAME as YarnFor from T_KnitStock a,t_yarnparty b
    where a.KNTITRANSACTIONTYPEID=pStockType and
        a.Yarnfor=b.pid and
    a.StockTransDate>=SDate and a.StockTransDate<=EDate
    order by b.PARTYNAME desc ,a.StockTransDate desc, a.StockTransNo desc;
elsif pQueryType=4 then
    OPEN io_cursor FOR
    select a.StockId, b.SUPPLIERNAME, b.SUPPLIERID
	from T_KnitStock a,T_SUPPLIER b
    where a.SUPPLIERID=b.SUPPLIERID and 
	a.KNTITRANSACTIONTYPEID=pStockType and
    a.StockTransDate>=SDate and a.StockTransDate<=EDate
    order by b.SUPPLIERNAME desc;
elsif pQueryType=9999 then
    OPEN io_cursor FOR
    select StockId from T_KnitStock
    where KNTITRANSACTIONTYPEID=pStockType and
    StockTransDate>=SDate and StockTransDate<=EDate and
    Upper(StockTransNo) Like pTransNo;
  end if;
END getTreeKnitStockList;
/


PROMPT CREATE OR REPLACE Procedure  072 :: GetUnitOfMeasList
CREATE OR REPLACE Procedure GetUnitOfMeasList
(
  pStatus number,
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)
AS

BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=0 then
	OPEN data_cursor for
    Select UnitOfMeas, UnitOfMeasID 
	from T_UnitOfMeas 
	order by UnitOfMeas;

/*If the Value is 1 then retun as the */

elsif pStatus=1 then
	OPEN data_cursor for
    Select 	UnitOfMeas, UnitOfMeasID 
	from 	T_UnitOfMeas
	where 	UnitOfMeasID=pWhereValue 
	order by UnitOfMeas;
  
elsif pStatus=2 then
	OPEN data_cursor for
    Select UnitOfMeas, UnitOfMeasID 
	from 	T_UnitOfMeas	
	order by UnitOfMeas;
end if;
END GetUnitOfMeasList;
/



PROMPT CREATE OR REPLACE Procedure  073 :: GetWorkOrderDetails
CREATE OR REPLACE Procedure GetWorkOrderDetails
(
  one_cursor IN OUT pReturnData.c_Records,
  many_cursor IN OUT pReturnData.c_Records,
  pOrderLineItem varchar2
)

AS

BEGIN

    open one_cursor for
     	select OrderNo,OrderLineItem, WoItemSl, KnitMcDiaGauge, CombinationID, 
	FabricTypeID, FinishedGSM,
     	Width, Shrinkage, Shade, Rate, FeederCount, GrayGSM, Ply, UnitOfMeasID, Quantity,
	Remarks,getFncYarnDes(ORDERLINEITEM) as YarnDesc
 	from T_OrderItems where OrderLineItem=pOrderLineItem order by WoItemSl;

    open many_cursor for
   	select pid,orderlineitem,yarncountid,yarntypeid,stitchlength,
	yarnpercent from t_yarndesc 
	where orderlineitem=pOrderLineItem;
END GetWorkOrderDetails;
/

PROMPT CREATE OR REPLACE Procedure  074 :: GetGWorkorderInfo
CREATE OR REPLACE Procedure GetGWorkorderInfo
(
	one_cursor IN OUT pReturnData.c_Records,
	many_cursor IN OUT pReturnData.c_Records,
	basictype_cursor  IN OUT pReturnData.c_Records,
	pOrderNo NUMBER
)
AS
BEGIN
	open one_cursor for
	select GORDERNO,GDORDERNO,ORDERTYPEID,GORDERDATE,CLIENTID,SALESTERMID,CURRENCYID,CONRATE,SALESPERSONID,WCANCELLED,WREVISED,
	ORDERSTATUSID,CONTACTPERSON,CLIENTSREF,DELIVERYPLACE,DELIVERYSTARTDATE,DELIVERYENDDATE,DAILYPRODUCTIONTARGET,
	TERMOFDELIVERY,TERMOFPAYMENT,SEASON,COSTINGREFNO,QUOTEDPRICE,ORDERREMARKS from T_GWorkOrder
	where GOrderNo=pOrderNo;

	open many_cursor for
	select a.ORDERLINEITEM,a.WOITEMSL, a.GORDERNO, a.STYLE, a.COUNTRYID, a.SHADE,a.PRICE,a.UNITOFMEASID,a.QUANTITY,a.DELIVERYDATE,a.REMARKS,b.ORDERTYPEID,getgsizeDesc(ORDERLINEITEM) as SizeDesc
	from T_GOrderItems a,T_GWorkOrder b
	where a.GOrderNo=b.GOrderNo and a.GOrderNo=pOrderNo order by WoItemSl;

END GetGWorkorderInfo;
/


PROMPT CREATE OR REPLACE Procedure  075 :: GetGDWorkOrderList
CREATE OR REPLACE Procedure GetGDWorkOrderList
(
  data_cursor IN OUT pReturnData.c_Records,
  pBasictypeid varchar2
)
AS
BEGIN
	OPEN data_cursor for
    	Select ORDERTYPEID,ORDERTYPEID || ' ' || GDORDERNO as GDORDERNO,GORDERNO 
	from T_Gworkorder where ordertypeid=pBasictypeid ORDER BY GDORDERNO DESC;

END GetGDWorkOrderList;
/


PROMPT CREATE OR REPLACE Procedure  076 :: GetGOrdertypeInfo
CREATE OR REPLACE Procedure GetGOrdertypeInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  pBasictypeid varchar2
)
AS
BEGIN

    open one_cursor for
    select max(gdorderno) from T_GWorkOrder where ordertypeid=pBasictypeid ;

    
END GetGOrdertypeInfo;
/

PROMPT CREATE OR REPLACE Procedure  077 :: UpdateOrderBasicTypes
CREATE OR REPLACE Procedure UpdateOrderBasicTypes(
pOrderNo NUMBER, pBasicStr VARCHAR2)
is
idx NUMBER;
begin
     
	delete from T_BasicWorkorder where WorkorderNo=pOrderNo;
	
	if (pBasicStr is not null) then
	        for idx in 1..length(pBasicStr)
		loop
			insert into T_BasicWorkorder values (pOrderNo, substr(pBasicStr,idx,1));
	        end loop;
	end if;

end UpdateOrderBasicTypes;
/


PROMPT CREATE OR REPLACE Procedure  078 :: getGWorkorderTree
CREATE OR REPLACE Procedure getGWorkorderTree (
  tree_cursor IN OUT pReturnData.c_Records,
  pOrdertype varchar2,
  pGroupID number,
  pStartDate date,
  pEndDate date
)
AS
BEGIN
  /* Order No Assecndig*/
  if pGroupID=0 then
    open tree_cursor for
    select GOrderNo,gdorderNO
    from T_GWorkOrder
    where GOrderDate between pStartDate and pEndDate and ordertypeid=pOrdertype
    order by GDORDERNO desc;
 /* Order Date */
  elsif pGroupID = 1 then
    open tree_cursor for
    select GOrderNo, gdorderNO,GOrderDate
    from T_GWorkOrder
    where GOrderDate between pStartDate and pEndDate and ordertypeid=pOrdertype
    order by GOrderDate desc, GDORDERNO desc;

 /* Client Name */
  elsif pGroupID = 2 then
    open tree_cursor for
    select GOrderNo,gdorderNO, ClientName
    from T_GWorkOrder, T_Client
    where T_GWorkOrder.ClientID=T_Client.ClientID and
    GOrderDate between pStartDate and pEndDate and ordertypeid=pOrdertype
    order by ClientName, GDORDERNO desc;

  /* Sales Person*/
  elsif pGroupID = 3 then
    open tree_cursor for
    select GOrderNo,gdorderNO, EmployeeName
    from T_GWorkOrder, T_Employee
    where T_GWorkOrder.SalesPersonID=T_Employee.EmployeeID and
    GOrderDate between pStartDate and pEndDate and ordertypeid=pOrdertype
    order by EmployeeName, GDORDERNO desc;
  end if;
END;
/



PROMPT CREATE OR REPLACE Procedure  079 :: GetYarnCount
CREATE OR REPLACE Procedure GetYarnCount
(
  pStatus number,
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=0 then
  OPEN data_cursor for
   select YarnCountID, YarnCount
    from T_YarnCount order by YarnCount;
/*If the Value is 1 then retun as the */

elsif pStatus=1 then
  OPEN data_cursor for
 select YarnCountID, YarnCount
 from T_YarnCount
  where YarnCountID=pWhereValue order by YarnCount;
end if;
END GetYarnCount;
/

PROMPT CREATE OR REPLACE Procedure  080 :: getYarnDesc
CREATE OR REPLACE Procedure getYarnDesc
(
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)

AS

BEGIN

  OPEN data_cursor for
 select orderLineItem, yarnCountID,yarnTypeID,StitchLength,YarnPercent,PID from T_YarnDesc
  where orderLineItem=pWhereValue;

END getYarnDesc;
/

PROMPT CREATE OR REPLACE Procedure  081 :: getYarnType
CREATE OR REPLACE Procedure getYarnType
(
  pStatus number,
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=0 then
  OPEN data_cursor for
   select YarnTypeID, YarnType from T_YarnType order by YarnType;

/*If the Value is 1 then retun as the */

elsif pStatus=1 then

  OPEN data_cursor for
 select YarnTypeID, YarnType from T_YarnType
  where YarnTypeID=pWhereValue order by YarnType;
end if;
END getYarnType;
/


PROMPT CREATE OR REPLACE Procedure  082 :: InsertRecWithIdentity
CREATE OR REPLACE Procedure InsertRecWithIdentity  (
  pStrSql IN VARCHAR2,
  pIdentityName IN VARCHAR2,
  pIdentityFld IN VARCHAR2,
  pCurIdentityVal OUT NUMBER,
  pRecsAffected out NUMBER
)
AS
  tmpSql VARCHAR2(10000);
  restSql VARCHAR2(10000);
  insertSql VARCHAR2(10000);
  tmpPos NUMBER;
BEGIN

  execute immediate 'select ' || pIdentityName || '.NEXTVAL from sys.dual'
  into pCurIdentityVal;

  tmpPos := instr(pStrSql, '(', 1, 1);
  tmpSql := substr(pStrSql, 1, tmpPos);
  restSql := substr(pStrSql, tmpPos+1);
  insertSql := tmpSql || pIdentityFld || ',';

  tmpPos := instr(restSql, ' values (', 1, 1);
  tmpSql := substr(restSql, 1, tmpPos);
  restSql := substr(restSql, tmpPos+9);
  insertSql := insertSql || tmpSql || ' values (' ||
          TO_CHAR(pCurIdentityVal) || ',' || restSql;

  execute immediate insertSql;
  pRecsAffected := SQL%ROWCOUNT;

END InsertRecWithIdentity;
/

PROMPT CREATE OR REPLACE Procedure  083 :: GetKnitMachineInfo
Create or Replace Procedure  GetKnitMachineInfo                                                         
(                                                                               
  pStatus number,                                                               
  pWhereValue number,                                                         
  data_cursor IN OUT pReturnData.c_Records                                      
)                                                                                                                                                            
AS                                                                              
BEGIN                                                                           
/*if the Value is 0 then retun all the Data */                                  
if pStatus=0 then                                                               

  OPEN data_cursor for                                                          
    select MACHINEID, MCTYPEID,FABRICTYPEID,KNITMCDIA,KNITMCGAUGE,
    MCFEEDER,RATEDCAPACITY,UNITOFMEASID,PATTERNS,MACHINENAME                                       
    from T_KNITMACHINEINFO order by MACHINENAME;                 
/*If the Value is 1 then retun as the */                                        

elsif pStatus=1 then                                                            
  OPEN data_cursor for 
    select MACHINEID, MCTYPEID,FABRICTYPEID,KNITMCDIA,KNITMCGAUGE,
    MCFEEDER,RATEDCAPACITY,UNITOFMEASID,PATTERNS,MACHINENAME                                       
    from T_KNITMACHINEINFO where  MACHINEID=pWhereValue 
    order by MACHINENAME;                                   
end if;                                                                         
END GetKnitMachineInfo;  
/

PROMPT CREATE OR REPLACE Procedure  084 :: GetKmcType
CREATE OR REPLACE Procedure GetKmcType
(
  pStatus number,
  pWhereValue number,
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
/*if the Value is 0 then retun all the Data */
if pStatus=0 then
  OPEN data_cursor for
   select mcTypeID,mcTypeName
 from t_KmcType order by mcTypeName;
/*If the Value is 1 then retun as the */
elsif pStatus=1 then
  OPEN data_cursor for
select mcTypeID,mcTypeName
 from t_KmcType where mcTypeID=pWhereValue order by mcTypeName;
end if;
END GetKmcType;
/





PROMPT CREATE OR REPLACE Procedure  085 :: GetFormsPosition
CREATE OR REPLACE Procedure GetFormsPosition
(
  data_cursor IN OUT pReturnData.c_Records,
  pEmpId varchar2
)
AS
BEGIN
 
 open data_cursor for
 Select a.FormId, a.FormDesc
 from T_Forms a
 where FormId not in
 (select FormId from T_EmpForms where EmployeeId=pEmpId)
 order by a.FormDesc;

END GetFormsPosition;
/
PROMPT CREATE OR REPLACE Procedure  086 :: GETEmployeeInfo
Create or Replace Procedure  GETEmployeeInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  many_forms_cursor IN OUT pReturnData.c_Records,
  many_reports_cursor IN OUT pReturnData.c_Records,
  pEmployeeID varchar2
)
AS
BEGIN
 open one_cursor for
	select EmployeeID,EmployeeName,empgroupID, Designationid,EmpStatusid,
	EmpPassword,EmpManager,empcontactno,empparaddress,emppresaddress,empEmail
	from T_Employee where EmployeeID=pEmployeeID
	order by EmployeeName;
 open many_forms_cursor for
	Select a.EmployeeID,b.EMPLOYEENAME,a.FORMID,c.FORMDESC,a.FORMPERMISSION
	from T_EmpForms a,T_EMPLOYEE b, T_FORMS c
	where b.EmployeeID=a.EmployeeID AND
	c.FORMID=a.FORMID AND
	a.EmployeeID=pEmployeeID
	order by c.FORMDESC; 
  open many_reports_cursor for
	Select a.EmployeeID,b.EMPLOYEENAME,a.ReportId,c.ReportTitle,c.RptOldName,a.bAccess
	from T_ReportAccess a,T_EMPLOYEE b, T_ReportList c
	where b.EmployeeID=a.EmployeeID AND
	c.ReportId=a.ReportId AND
	a.EmployeeID=pEmployeeID
	order by c.ReportTitle;
END GETEmployeeInfo;
/
PROMPT CREATE OR REPLACE Procedure  087 :: GetSCWorkorderInfo
CREATE OR REPLACE Procedure GetSCWorkorderInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  many_cursor IN OUT pReturnData.c_Records,
  basictype_cursor  IN OUT pReturnData.c_Records,
  pOrderNo NUMBER
)
AS
BEGIN
    open one_cursor for
    select OrderNo,TOrderNo,dorderno,basictypeid, OrderDate, ClientID,SUBCONID, SalesTermID, CurrencyID,ConRate,SalesPersonID,
    WCancelled, WRevised,OrderStatusID, ContactPerson, ClientsRef, DeliveryPlace,DeliveryStartDate,
    DeliveryEndDate,DailyProductionTarget,OrderRemarks, GarmentsOrderRef, FncSCOrderBasicTypes(pOrderNo) as BasicTypes
    from T_SCWorkOrder
    where OrderNo=pOrderNo;

    open many_cursor for
    select OrderLineItem,WoItemSl,KnitMcDiaGauge,FabricTypeID,FinishedGSM,Width,COLLARCUFFID,
	Shrinkage,STITCHLENGTH,SHADEGROUPID,Shade, Rate, FeederCount,GrayGSM,CurrentQty,Quantity,UnitOfMeasID,
	SUNIT,SqTY,T_SCWorkOrder.budgetid,TORDERLINEITEMREF,Remarks,
    getFncSCYarnDes(ORDERLINEITEM) as YarnDesc,getFncColourCombination(ORDERLINEITEM) as ColourCombination,T_SCWorkOrder.basictypeid
    from T_SCOrderItems,T_SCWorkOrder
    where T_SCOrderItems.OrderNo=T_SCWorkOrder.OrderNo AND T_SCOrderItems.OrderNo=pOrderNo order by WoItemSl;

    open basictype_cursor for
    select BasicTypeID
    from T_SCBasicWorkOrder
    where WorkOrderNo=pOrderNo;

END GetSCWorkorderInfo;
/

PROMPT CREATE OR REPLACE Procedure  088 :: CopySCYarndesc
Create or Replace Procedure CopySCYarndesc
(
 pTOrderLineID in Varchar2,
 pSCOrderLineID in varchar2,
 pRecsAffected out NUMBER
)
AS
id number;
BEGIN
   for rec1 in(select PID,YARNTYPEID,YARNCOUNTID,Orderlineitem,YARNPERCENT 
   from T_YarnDesc where Orderlineitem=pTOrderLineID)
   loop
	select NVL(max(pid),0)+1 into id from (select to_number(pid) as pid from T_SCYarndesc);
    insert into T_SCYarnDesc(PID,YARNTYPEID,YARNCOUNTID,Orderlineitem,YARNPERCENT)
    values(id,rec1.YARNTYPEID,rec1.YARNCOUNTID,pSCOrderLineID,rec1.YARNPERCENT);
   end loop;

END CopySCYarndesc;
/
PROMPT CREATE OR REPLACE Procedure  089 :: getSCYarnDesc
CREATE OR REPLACE Procedure getSCYarnDesc
(
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)

AS

BEGIN

  OPEN data_cursor for
 select orderLineItem, yarnCountID,yarnTypeID,StitchLength,YarnPercent,PID from T_SCYarnDesc
  where orderLineItem=pWhereValue;

END getSCYarnDesc;
/
PROMPT CREATE OR REPLACE Procedure  090 :: getColourCombination
CREATE OR REPLACE Procedure getColourCombination
(
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)

AS

BEGIN

  OPEN data_cursor for
 select PID,ORDERLINEITEM,COLOURID,COLOURLENGTH,CUNITOFMEASID,FEEDERLENGTH,FUNITOFMEASID  
 from T_ColourCombination
  where orderLineItem=pWhereValue;
END getColourCombination;
/

PROMPT CREATE OR REPLACE Procedure  91 :: getSCWorkorderTree
CREATE OR  REPLACE Procedure getSCWorkorderTree (
  tree_cursor IN OUT pReturnData.c_Records,
  pOrdercode varchar2,
  pGroupID number,
  pStartDate date,
  pEndDate date
)
AS
BEGIN
  /* Order No Descending by Date*/
  if pGroupID=0 then
    open tree_cursor for
    select OrderNo,dorderNO AS dorder
    from T_SCWorkOrder
    where OrderDate between pStartDate and pEndDate and basictypeid=pOrdercode
    order by dorderNO desc;
 /* Order Date */
  elsif pGroupID = 1 then
    open tree_cursor for
    select OrderNo,dorderNO AS dorder, OrderDate
    from T_SCWorkOrder
    where OrderDate between pStartDate and pEndDate and basictypeid=pOrdercode
	order by dorderNO desc;
 /* Sub Contractors */
  elsif pGroupID = 2 then
    open tree_cursor for
    select OrderNo,dorderNO AS dorder, SUBCONNAME
    from T_SCWorkOrder, t_subcontractors
    where T_SCWorkOrder.SUBCONID=t_subcontractors.SUBCONID and
    OrderDate between pStartDate and pEndDate and basictypeid=pOrdercode
    order by SUBCONNAME,dorderNO desc;
  
  /* Sales Person*/
  elsif pGroupID = 3 then
    open tree_cursor for
    select OrderNo,dorderNO AS dorder, EmployeeName
    from T_SCWorkOrder, T_Employee
    where T_SCWorkOrder.SalesPersonID=T_Employee.EmployeeID and
    OrderDate between pStartDate and pEndDate and basictypeid=pOrdercode
    order by EmployeeName,dorderNO desc;
	
/* TWOrder */
  elsif pGroupID = 4 then
    open tree_cursor for
    select OrderNo,dorderNO AS dorder, getfncWOBType(TOrderNo) AS WOBTName
    from T_SCWorkOrder 											
    where OrderDate between pStartDate and pEndDate and basictypeid=pOrdercode
    order by WOBTName,dorderNO desc;

  /* Combo Fillup Assecndig*/
  elsif pGroupID=99 then
    open tree_cursor for
    select OrderNo,GetfncWOBType(OrderNo) as dorder
    from T_SCWorkOrder
    where OrderDate between pStartDate and pEndDate
    order by basictypeid,dorderno desc;
  end if;
End getSCWorkorderTree;
/


PROMPT CREATE OR REPLACE Procedure  92 :: UpdateSCOrderBasicTypes
CREATE OR REPLACE Procedure UpdateSCOrderBasicTypes(
pOrderNo NUMBER, pBasicStr VARCHAR2)
is
idx NUMBER;
begin
     
	delete from T_SCBasicWorkorder where WorkorderNo=pOrderNo;
	
	if (pBasicStr is not null) then
	        for idx in 1..length(pBasicStr)
		loop
			insert into T_SCBasicWorkorder values (pOrderNo, substr(pBasicStr,idx,1));
	        end loop;
	end if;

end UpdateSCOrderBasicTypes;
/
PROMPT CREATE OR REPLACE Procedure  93 :: GetSCOrdertypeInfo
CREATE OR REPLACE Procedure GetSCOrdertypeInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  pBasictypeid varchar2
)
AS
BEGIN
    open one_cursor for
    select max(dorderno) from T_SCWorkOrder where basictypeid=pBasictypeid ;    
END GetSCOrdertypeInfo;
/

PROMPT CREATE OR REPLACE Procedure  94 :: GetReportsPosition
CREATE OR REPLACE Procedure GetReportsPosition
(
  data_cursor IN OUT pReturnData.c_Records,
  pEmpId varchar2
)
AS
BEGIN 
 open data_cursor for
 Select a.ReportId, a.ReportTitle,a.RptOldName
 from T_ReportList a
 where ReportId not in
 (select ReportId from T_ReportAccess where EmployeeId=pEmpId)
 order by a.ReportTitle;

END GetReportsPosition;
/


PROMPT CREATE OR REPLACE Procedure  95 :: GetFabricStockPosition
CREATE OR REPLACE Procedure GetFabricStockPosition
(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pKnitTranTypeID NUMBER,
  pStockDate DATE
)
AS
BEGIN


/*  All Summary Report*/
  if pQueryType=0 then
    open data_cursor for
    select c.YarnCount,b.SUPPLIERID,g.SUPPLIERNAME, d.YarnType, 
    e.UnitOfMeas, sum(b.Quantity*ATLGYS) MainStore, sum(b.Quantity*ATLGYF) SubStore, 
    sum(b.Quantity*AYDLGYS) SubStock
    from T_Knitstock a, T_KnitStockItems b, T_YarnCount c, T_YarnType d, 
    T_UnitOfMeas e, T_knitTransactionType f,t_supplier g
    where a.StockID=b.StockID and
    b.SUPPLIERID=g.SUPPLIERID and 
    b.yarnCountId=c.yarncountid and
    b.yarntypeid=d.yarntype and
    b.PunitOfMeasId=e.UnitOfmeasId and
    STOCKTRANSDATE <= pStockDate and
    a.KNTITRANSACTIONTYPEID = pKnitTranTypeID;

        /* ATLGYS*/
  elsif pQueryType=1 then
    open data_cursor for
    select b.YARNBATCHNO,b.SUPPLIERID,g.SUPPLIERNAME,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,          
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.DyedLotno,
    sum(Quantity*ATLGYS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, T_YarnCount d, 
    T_YarnType e, T_UnitOfMeas f,t_supplier g
    where a.StockID=b.StockID and
    b.SUPPLIERID=g.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.YARNBATCHNO,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, 
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.SUPPLIERID,g.SUPPLIERNAME,b.DyedLotno
    having sum(Quantity*ATLGYS)>0;

/*  ATLGFS*/
elsif pQueryType=2 then
    open data_cursor for
    select b.YARNBATCHNO,b.SUPPLIERID,g.SUPPLIERNAME,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,          
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.DyedLotno,
    sum(Quantity*ATLGFS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, T_YarnCount d, 
    T_YarnType e, T_UnitOfMeas f,t_supplier g
    where a.StockID=b.StockID and
    b.SUPPLIERID=g.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.YARNBATCHNO,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, YarnType,
    b.PUnitOfMeasId,UnitOfMeas,b.SUPPLIERID,g.SUPPLIERNAME,b.DyedLotno
    having sum(Quantity*ATLGFS)>0;


        /* ATLGYF */
elsif pQueryType=3 then
    open data_cursor for
    select b.YARNBATCHNO,b.SUPPLIERID,g.SUPPLIERNAME,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,         
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.DyedLotno,
    sum(Quantity*ATLGYF) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, T_YarnCount d, 
    T_YarnType e, T_UnitOfMeas f,t_supplier g
    where a.StockID=b.StockID and
    b.SUPPLIERID=g.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.YARNBATCHNO,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, 
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.SUPPLIERID,g.SUPPLIERNAME,b.DyedLotno
    having sum(Quantity*ATLGYF)>0;


                /* AYDLGYS */
elsif pQueryType=4 then
    open data_cursor for
    select b.YARNBATCHNO,b.SUPPLIERID,g.SUPPLIERNAME,b.YARNTYPEID,
    b.YARNCOUNTID,YarnCount, YarnType,b.PUnitOfMeasId,UnitOfMeas,b.DyedLotno,
    sum(Quantity*AYDLGYS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier g
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.SUPPLIERID=g.SUPPLIERID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.YARNBATCHNO,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, 
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.SUPPLIERID,g.SUPPLIERNAME,b.DyedLotno
    having sum(Quantity*AYDLGYS)>0;

                /*ODSCONGYS*/
elsif pQueryType=5 then
    open data_cursor for
    select b.YARNBATCHNO,b.SUPPLIERID,g.SUPPLIERNAME,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,         
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.DyedLotno,
    sum(Quantity*ODSCONGYS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier g
    where a.StockID=b.StockID and
    b.SUPPLIERID=g.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.YARNBATCHNO,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, 
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.SUPPLIERID,g.SUPPLIERNAME,b.DyedLotno
    having sum(Quantity*ODSCONGYS)>0;


                /*KSCONGYS*/
elsif pQueryType= 6 then
    open data_cursor for
    select b.YARNBATCHNO,b.SUPPLIERID,g.SUPPLIERNAME,b.YARNTYPEID,
    b.YARNCOUNTID,YarnCount, YarnType,b.PUnitOfMeasId,UnitOfMeas,b.DyedLotno,
    sum(Quantity*KSCONGYS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier g
    where a.StockID=b.StockID and
    b.SUPPLIERID=g.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.YARNBATCHNO,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, 
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.SUPPLIERID,g.SUPPLIERNAME,b.DyedLotno			
    having sum(Quantity*KSCONGYS)>0;


/*ATLGFS For Fabric Delivery*/
elsif pQueryType=7 then
    open data_cursor for
    select b.YARNBATCHNO,b.SUPPLIERID,g.SUPPLIERNAME,b.YARNTYPEID,
    b.YARNCOUNTID,YarnCount,YarnType,b.PUnitOfMeasId,UnitOfMeas,b.DyedLotno,
    sum(Quantity*ATLGFS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, T_YarnCount d, 
    T_YarnType e, T_UnitOfMeas f,t_supplier g
    where a.StockID=b.StockID and
    b.SUPPLIERID=g.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.YARNBATCHNO,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, YarnType,b.DyedLotno,
    b.PUnitOfMeasId,UnitOfMeas,b.SUPPLIERID,g.SUPPLIERNAME
    having sum(Quantity*ATLGFS)>0;

end if;

END GetFabricStockPosition;
/




PROMPT CREATE OR REPLACE Procedure  96 :: GetKnitFabricDelStockPosition
Create or Replace Procedure GetKnitFabricDelStockPosition(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pKnitTranTypeID NUMBER,
  pStockDate DATE
)
AS
BEGIN


/*  All Summary Report*/
  if pQueryType=0 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID, b.YARNBATCHNO,b.FABRICTYPEID,c.YarnCount,
    d.YarnType, e.UnitOfMeas, sum(b.Quantity*ATLGYS) MainStore,
    sum(b.Quantity*ATLGYF) SubStore, sum(b.Quantity*AYDLGYS) SubStock
    from T_Knitstock a, T_KnitStockItems b, T_YarnCount c, T_YarnType d,
    T_UnitOfMeas e, T_knitTransactionType f
    where a.StockID=b.StockID and
    b.yarnCountId=c.yarncountid and
    b.yarntypeid=d.yarntype and
    b.PunitOfMeasId=e.UnitOfmeasId and
    STOCKTRANSDATE <= pStockDate and
    a.KNTITRANSACTIONTYPEID = pKnitTranTypeID;

        /* ATLGYS*/
  elsif pQueryType=1 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,b.Shade,
    b.FABRICTYPEID,FABRICTYPE,b.OrderlineItem, b.YARNTYPEID,b.YARNCOUNTID,
    YarnCount,YarnType,b.PUnitOfMeasId,UnitOfMeas,b.DyedLotno,sum(Quantity*ATLGYS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,
    T_FabricType g,t_supplier h
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate and
    b.ORDERNO=pKnitTranTypeID /* ORDERNO passing to pKnitTranTypeID*/
    group by
    b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.DyedLotno,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.FABRICTYPEID,FABRICTYPE,b.YARNBATCHNO,b.Shade,
    b.SUPPLIERID,h.SUPPLIERNAME
    having sum(Quantity*ATLGYS)>0;

/*  ATLGFS*/
elsif pQueryType=2 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,b.FABRICTYPEID,
    FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.DyedLotno,
    sum(Quantity*ATLGFS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,
    T_FabricType g,t_supplier h
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.FABRICTYPEID,FABRICTYPE,b.YARNBATCHNO,b.DyedLotno,
    b.SUPPLIERID,h.SUPPLIERNAME
    having sum(Quantity*ATLGFS)>0;

        /* ATLGYF */
elsif pQueryType=3 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,b.FABRICTYPEID,
    FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.DyedLotno,sum(Quantity*ATLGYF) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,
    T_FabricType g,t_supplier h
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.FABRICTYPEID,FABRICTYPE,b.YARNBATCHNO,b.DyedLotno,
    b.SUPPLIERID,h.SUPPLIERNAME
    having sum(Quantity*ATLGYF)>0;

                /* AYDLGYS */
elsif pQueryType=4 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,b.FABRICTYPEID,
    FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.DyedLotno,sum(Quantity*AYDLGYS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,
    T_FabricType g,t_supplier h
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.FABRICTYPEID,FABRICTYPE,b.DyedLotno,
    b.YARNBATCHNO,b.SUPPLIERID,h.SUPPLIERNAME
    having sum(Quantity*AYDLGYS)>0;

                /*ODSCONGYS*/
elsif pQueryType=5 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,b.FABRICTYPEID,
    FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.DyedLotno,
    sum(Quantity*ODSCONGYS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,
    T_FabricType g,t_supplier h
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,
    b.Shade, YarnType,b.PUnitOfMeasId,UnitOfMeas,b.DyedLotno,
    b.FABRICTYPEID,FABRICTYPE,b.YARNBATCHNO,b.SUPPLIERID,h.SUPPLIERNAME
    having sum(Quantity*ODSCONGYS)>0;

                /*KSCONGYS*/
elsif pQueryType= 6 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,b.FABRICTYPEID,
    FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.DyedLotno,sum(Quantity*KSCONGYS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,T_FabricType g,t_supplier h
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.SUPPLIERID=h.SUPPLIERID and
    b.YarnTypeId= e.YarnTypeId and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.FABRICTYPEID,b.DyedLotno,
    FABRICTYPE,b.YARNBATCHNO,b.SUPPLIERID,h.SUPPLIERNAME
    having sum(Quantity*KSCONGYS)>0;

/*ATLGFS For FabricDelivery*/
elsif pQueryType=7 then
	open data_cursor for
	select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.FABRICTYPEID,b.sunitofmeasid as sunitid,i.unitofmeas as sunit,
	FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,'' AS YarnCount,
	'' AS YarnType,b.PUnitOfMeasId,f.UnitOfMeas,b.YARNBATCHNO,b.DyedLotno,b.shadegroupid,h.shadegroupname,b.SHADE,
	0 IssuedQty,
	sum(Quantity*ATLGFS) CurrentStock,sum(sQuantity*ATLGFS) as squantity
	from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
	T_YarnCount d, T_YarnType e,T_UnitOfMeas f,
	T_FabricType g,T_SHADEGROUP h,T_UnitOfMeas i
	where a.StockID=b.StockID and
	a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
	b.YarnCountId=d.YarnCountId and
	b.shadegroupid=h.shadegroupid and
	b.YarnTypeId= e.YarnTypeId and
	b.FABRICTYPEID=g.FABRICTYPEID and
	b.PUnitOfMeasID=f.UnitOfMeasID(+) and
	b.SUnitOfMeasID=i.UnitOfMeasID(+) and
	STOCKTRANSDATE <= pStockDate  and
        b.ORDERNO=pKnitTranTypeID /*  ORDERNO passing to pKnitTranTypeID*/
	group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,YarnType,b.PUnitOfMeasId,
	f.UnitOfMeas,b.FABRICTYPEID,FABRICTYPE,b.YARNBATCHNO,b.DyedLotno,b.shadegroupid,h.shadegroupname,b.SHADE,b.sunitofmeasid,i.unitofmeas
	having sum(Quantity*ATLGFS)>0 	ORDER BY btype;

	/*ATLGFDF* For Dyed Fabric*/
elsif pQueryType=8 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,b.FABRICTYPEID,
    FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.DyedLotno,
    sum(Quantity*ATLGFDF) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,
    T_FabricType g,t_supplier h
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.FABRICTYPEID,FABRICTYPE,b.YARNBATCHNO,b.DyedLotno,
    b.SUPPLIERID,h.SUPPLIERNAME
    having sum(Quantity*ATLGFDF)>0;

	/*ATLDFDS For Finished Fabric*/
elsif pQueryType=9 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.YARNBATCHNO,b.FABRICTYPEID,
    FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.DyedLotno,
    sum(Quantity*ATLDFDS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,
    T_FabricType g
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.FABRICTYPEID,FABRICTYPE,b.YARNBATCHNO,b.DyedLotno
    having sum(Quantity*ATLDFDS)>0;

	/*ATLFFS For Fnished Fabric Delivery */
elsif pQueryType=10 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.YARNBATCHNO,b.FABRICTYPEID,b.sunitofmeasid as sunitid,
    i.unitofmeas as sunit,b.shadegroupid,h.shadegroupname,
    FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, b.Shade,
    YarnType,b.PUnitOfMeasId,f.UnitOfMeas,b.DyedLotno,
    sum(Quantity*ATLFFS) CurrentStock,sum(sQuantity*ATLFFS) as squantity
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,T_UnitOfMeas i,
    T_FabricType g,T_SHADEGROUP h
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.shadegroupid=h.shadegroupid and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUnitOfMeasID=i.UnitOfMeasID(+) and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
    YarnType,b.PUnitOfMeasId,f.UnitOfMeas,b.FABRICTYPEID,FABRICTYPE,b.shadegroupid,h.shadegroupname,b.YARNBATCHNO,b.DyedLotno,b.sunitofmeasid,i.unitofmeas
    having sum(Quantity*ATLFFS)>0;

/*DFSCON For Knitting and Fnished Fabric received from subcon*/
elsif pQueryType=11 then
	open data_cursor for
	select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.FABRICTYPEID,b.sunitofmeasid as sunitid,i.unitofmeas as sunit,
	FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,
	YarnType,b.PUnitOfMeasId,f.UnitOfMeas,b.YARNBATCHNO,b.DyedLotno,b.shadegroupid,h.shadegroupname,b.SHADE,
	0 IssuedQty,
	sum(Quantity*DFSCON) CurrentStock,sum(sQuantity*DFSCON) as squantity
	from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
	T_YarnCount d, T_YarnType e,T_UnitOfMeas f,
	T_FabricType g,T_SHADEGROUP h,T_UnitOfMeas i
	where a.StockID=b.StockID and
	a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
	b.YarnCountId=d.YarnCountId and
	b.shadegroupid=h.shadegroupid and
	b.YarnTypeId= e.YarnTypeId and
	b.FABRICTYPEID=g.FABRICTYPEID and
	b.PUnitOfMeasID=f.UnitOfMeasID(+) and
	b.SUnitOfMeasID=i.UnitOfMeasID(+) and
	STOCKTRANSDATE <= pStockDate  and
        b.ORDERNO=pKnitTranTypeID  /* ORDERNO passing to pKnitTranTypeID*/
	group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,YarnType,b.PUnitOfMeasId,
	f.UnitOfMeas,b.FABRICTYPEID,FABRICTYPE,b.YARNBATCHNO,b.DyedLotno,b.shadegroupid,h.shadegroupname,b.SHADE,b.sunitofmeasid,i.unitofmeas
	having sum(Quantity*DFSCON)>0 	ORDER BY btype;

/*ATLGFS For FabricDelivery*/
elsif pQueryType=17 then
	open data_cursor for
	select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.FABRICTYPEID,'' as sunitid,'' as sunit,
	FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,
	YarnType,b.PUnitOfMeasId,f.UnitOfMeas,b.YARNBATCHNO,b.DyedLotno,'' as shadegroupid,'' as shadegroupname,'' as SHADE,
	0 as IssuedQty,
	sum(Quantity*ATLGFS) CurrentStock,sum(sQuantity*ATLGFS) as squantity
	from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
	T_YarnCount d, T_YarnType e,T_UnitOfMeas f,
	T_FabricType g,T_SHADEGROUP h,T_UnitOfMeas i
	where a.StockID=b.StockID and
	a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
	b.YarnCountId=d.YarnCountId and
	b.shadegroupid=h.shadegroupid and
	b.YarnTypeId= e.YarnTypeId and
	b.FABRICTYPEID=g.FABRICTYPEID and
	b.PUnitOfMeasID=f.UnitOfMeasID(+) and
	b.SUnitOfMeasID=i.UnitOfMeasID(+) and
	STOCKTRANSDATE <= pStockDate
	group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,YarnType,b.PUnitOfMeasId,
	f.UnitOfMeas,b.FABRICTYPEID,FABRICTYPE,b.YARNBATCHNO,b.DyedLotno
	having sum(Quantity*ATLGFS)>0 	ORDER BY btype;

/*ATLDFDS For DyedFabricDelivery*/
elsif pQueryType=41 then
	open data_cursor for
	select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.FABRICTYPEID,'' as sunitid,'' as sunit,
	FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,
	YarnType,b.PUnitOfMeasId,f.UnitOfMeas,b.YARNBATCHNO,b.DyedLotno,'' as shadegroupid,'' as shadegroupname,'' as SHADE,
	0 as IssuedQty,
	sum(Quantity*ATLDFDS) CurrentStock,sum(sQuantity*ATLDFDS) as squantity
	from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
	T_YarnCount d, T_YarnType e,T_UnitOfMeas f,
	T_FabricType g,T_SHADEGROUP h,T_UnitOfMeas i
	where a.StockID=b.StockID and
	a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
	b.YarnCountId=d.YarnCountId and
	b.shadegroupid=h.shadegroupid and
	b.YarnTypeId= e.YarnTypeId and
	b.FABRICTYPEID=g.FABRICTYPEID and
	b.PUnitOfMeasID=f.UnitOfMeasID(+) and
	b.SUnitOfMeasID=i.UnitOfMeasID(+) and
	STOCKTRANSDATE <= pStockDate
	group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,YarnType,b.PUnitOfMeasId,
	f.UnitOfMeas,b.FABRICTYPEID,FABRICTYPE,b.YARNBATCHNO,b.DyedLotno
	having sum(Quantity*ATLDFDS)>0 	ORDER BY btype;

        /* ATLGFS for Fabric Transfer Main stock*/
  elsif pQueryType=121 then
    open data_cursor for
	select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.FABRICTYPEID,b.sunitofmeasid as sunitid,i.unitofmeas as sunit,
	FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,
	YarnType,b.PUnitOfMeasId,f.UnitOfMeas,b.YARNBATCHNO,b.DyedLotno,b.shadegroupid,h.shadegroupname,b.SHADE,
		0 IssuedQty,
	sum(Quantity*ATLGFS) CurrentStock,sum(sQuantity*ATLGFS) as squantity
	from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
	T_YarnCount d, T_YarnType e,T_UnitOfMeas f,
	T_FabricType g,T_SHADEGROUP h,T_UnitOfMeas i
	where a.StockID=b.StockID and
	a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
	b.YarnCountId=d.YarnCountId and
	b.shadegroupid=h.shadegroupid and
	b.YarnTypeId= e.YarnTypeId and
	b.FABRICTYPEID=g.FABRICTYPEID and
	b.PUnitOfMeasID=f.UnitOfMeasID(+) and
	b.SUnitOfMeasID=i.UnitOfMeasID(+) and
	STOCKTRANSDATE <= pStockDate /* and
        b.ORDERNO=pKnitTranTypeID   ORDERNO passing to pKnitTranTypeID*/
	group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,YarnType,b.PUnitOfMeasId,
	f.UnitOfMeas,b.FABRICTYPEID,FABRICTYPE,b.YARNBATCHNO,b.DyedLotno,b.shadegroupid,h.shadegroupname,b.SHADE,b.sunitofmeasid,i.unitofmeas
	having sum(Quantity*ATLGFS)>0 	ORDER BY btype;

        /* ATLGFDF for Fabric Transfer Batching floor*/
  elsif pQueryType=161 then
    open data_cursor for
   select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.FABRICTYPEID,
    FABRICTYPE,b.OrderlineItem as OrderlineItem,b.Shade,b.YARNBATCHNO,b.DYEDLOTNO,b.YARNTYPEID,b.YARNCOUNTID,'' YarnCount,'' YarnType,
    b.PUnitOfMeasId,f.UnitOfMeas,b.shadegroupid,h.shadegroupname,b.sUnitOfMeasId as sunitid,i.unitofmeas as sunit,   
	/*(sum(Quantity*ATLGFDF)-NVL(decode(b.DYEDLOTNO,null,(SELECT sum(QUANTITY) FROM T_DBATCHITEMS 
	where ORDERNO=b.Orderno and FABRICTYPEID=b.FABRICTYPEID and 
	shadegroupid=b.Shadegroupid and YARNBATCHNO=b.YARNBATCHNO and Shade=b.Shade),(SELECT sum(QUANTITY) FROM T_DBATCHITEMS 
	where ORDERNO=b.Orderno and FABRICTYPEID=b.FABRICTYPEID and 
	shadegroupid=b.Shadegroupid and YARNBATCHNO=b.YARNBATCHNO and DYEDLOTNO=b.DYEDLOTNO and Shade=b.Shade)),0)) */ sum(Quantity*ATLGFDF) as  CurrentStock,
	/*(sum(SQuantity*ATLGFDF)-NVL(decode(b.DYEDLOTNO,null,(SELECT sum(SQuantity) FROM T_DBATCHITEMS 
	where ORDERNO=b.Orderno and FABRICTYPEID=b.FABRICTYPEID and 
	shadegroupid=b.Shadegroupid and YARNBATCHNO=b.YARNBATCHNO and Shade=b.Shade),(SELECT sum(SQuantity) FROM T_DBATCHITEMS 
	where ORDERNO=b.Orderno and FABRICTYPEID=b.FABRICTYPEID and 
	shadegroupid=b.Shadegroupid and YARNBATCHNO=b.YARNBATCHNO and DYEDLOTNO=b.DYEDLOTNO and Shade=b.Shade)),0))*/ sum(SQuantity*ATLGFDF)  as squantity
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_UnitOfMeas f,T_FabricType g,T_shadeGroup h,T_UnitOfMeas i
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.FABRICTYPEID=g.FABRICTYPEID and 
    b.shadegroupid=h.shadegroupid and 
    b.PUnitOfMeasID=f.UnitOfMeasID(+)  and
    b.SUnitOfMeasID=i.UnitOfMeasID(+)  
    group by b.ORDERNO,b.Shade,b.PUnitOfMeasId,f.UnitOfMeas,b.OrderlineItem,b.FABRICTYPEID,FABRICTYPE,b.YARNBATCHNO,b.DYEDLOTNO,b.YARNTYPEID,b.YARNCOUNTID,
    b.shadegroupid,h.shadegroupname,b.sUnitOfMeasId,i.unitofmeas
    	having sum(Quantity*ATLGFDF)>0 /*-NVL(decode(b.DYEDLOTNO,null,(SELECT sum(QUANTITY) FROM T_DBATCHITEMS 
	where ORDERNO=b.Orderno and FABRICTYPEID=b.FABRICTYPEID and 
	shadegroupid=b.Shadegroupid and YARNBATCHNO=b.YARNBATCHNO and Shade=b.Shade),(SELECT sum(QUANTITY) FROM T_DBATCHITEMS 
	where ORDERNO=b.Orderno and FABRICTYPEID=b.FABRICTYPEID and 
	shadegroupid=b.Shadegroupid and YARNBATCHNO=b.YARNBATCHNO and DYEDLOTNO=b.DYEDLOTNO and Shade=b.Shade)),0)) >0 	*/
    ORDER BY btype;
  end if;
END GetKnitFabricDelStockPosition;
/

PROMPT CREATE OR REPLACE Procedure  097 :: GetGrayYarnStockPick
Create Or Replace Procedure GetGrayYarnStockPick(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pKnitTranTypeID NUMBER,
  pStockDate DATE
)
AS
BEGIN


/*  All Summary Report*/

  if pQueryType=0 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID, b.YARNBATCHNO,b.FABRICTYPEID,c.YarnCount,
    d.YarnType, e.UnitOfMeas, sum(b.Quantity*ATLGYS) MainStore,
    sum(b.Quantity*ATLGYF) SubStore, sum(b.Quantity*AYDLGYS) SubStock
    from T_Knitstock a, T_KnitStockItems b, T_YarnCount c, T_YarnType d,
    T_UnitOfMeas e, T_knitTransactionType f
    where a.StockID=b.StockID and
    b.yarnCountId=c.yarncountid and
    b.yarntypeid=d.yarntype and
    b.PunitOfMeasId=e.UnitOfmeasId and
    STOCKTRANSDATE <= pStockDate and
    a.KNTITRANSACTIONTYPEID = pKnitTranTypeID;

        /* ATLGYS*/
  elsif pQueryType=1 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,b.Shade,
    b.FABRICTYPEID,FABRICTYPE,b.OrderlineItem, b.YARNTYPEID,b.YARNCOUNTID,
    YarnCount,YarnType,b.PUnitOfMeasId,UnitOfMeas,sum(Quantity*ATLGYS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,
    T_FabricType g,t_supplier h
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by
    b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.FABRICTYPEID,FABRICTYPE,b.YARNBATCHNO,b.Shade,
    b.SUPPLIERID,h.SUPPLIERNAME
    having sum(Quantity*ATLGYS)>0;

/*  ATLGFS*/
elsif pQueryType=2 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,b.FABRICTYPEID,
    FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,
    sum(Quantity*ATLGFS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,
    T_FabricType g,t_supplier h
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.FABRICTYPEID,FABRICTYPE,b.YARNBATCHNO,
    b.SUPPLIERID,h.SUPPLIERNAME
    having sum(Quantity*ATLGFS)>0;


        /* ATLGYF */
elsif pQueryType=3 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,b.FABRICTYPEID,
    FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,sum(Quantity*ATLGYF) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,
    T_FabricType g,t_supplier h
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.FABRICTYPEID,FABRICTYPE,b.YARNBATCHNO,
    b.SUPPLIERID,h.SUPPLIERNAME
    having sum(Quantity*ATLGYF)>0;


                /*DYED YARN RECEIVED FROM AYDLGYS AFTER DYE*/
elsif pQueryType=4 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,'' as OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,'' AS subconname,'' AS subconid,b.shadegroupid,j.shadeGroupName,b.fabrictypeid,
    i.fabrictype,b.shade,b.yarnfor,sum(Quantity*AYDLGYS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier h,T_FabricType i,t_shadegroup j
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID(+) and
	b.FABRICTYPEID=i.FABRICTYPEID(+) and
    b.shadegroupid=j.shadegroupid and 
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.shadegroupid,j.shadeGroupName,b.fabrictypeid,i.fabrictype,b.shade,b.yarnfor
    having sum(Quantity*AYDLGYS)>0;


                   /*DYED YARN RECEIVED FROM ODSCONGYS AFTER DYE*/
elsif pQueryType=5 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,'' as OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,i.subconname,b.subconid,b.shadegroupid,j.shadeGroupName,b.fabrictypeid,
    l.fabrictype,b.shade,b.yarnfor,sum(Quantity*ODSCONGYS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier h,t_subcontractors i,t_shadegroup j,T_FabricType l
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID(+) and
	b.FABRICTYPEID=l.FABRICTYPEID(+) and
    b.shadegroupid=j.shadegroupid and 
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    b.subconid=i.subconid and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,i.subconname,b.subconid,b.shadegroupid,j.shadeGroupName,b.fabrictypeid,l.fabrictype,b.shade,b.yarnfor
    having sum(Quantity*ODSCONGYS)>0;
                /*KSCONGYS*/
elsif pQueryType= 6 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,b.FABRICTYPEID,
    FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,sum(Quantity*KSCONGYS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,T_FabricType g,t_supplier h
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.SUPPLIERID=h.SUPPLIERID and
    b.YarnTypeId= e.YarnTypeId and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.FABRICTYPEID,
    FABRICTYPE,b.YARNBATCHNO,b.SUPPLIERID,h.SUPPLIERNAME
    having sum(Quantity*KSCONGYS)>0;

/*ATLGFS For FabricDelivery*/
elsif pQueryType=7 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,b.FABRICTYPEID,
    FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,
    sum(Quantity*ATLGFS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,
    T_FabricType g,t_supplier h
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.FABRICTYPEID,FABRICTYPE,b.YARNBATCHNO,
    b.SUPPLIERID,h.SUPPLIERNAME
    having sum(Quantity*ATLGFS)>0;

        /*ATLGFDF* For Dyed Fabric*/
elsif pQueryType=8 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,b.FABRICTYPEID,
    FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,
    sum(Quantity*ATLGFDF) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,
    T_FabricType g,t_supplier h
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.FABRICTYPEID,FABRICTYPE,b.YARNBATCHNO,
    b.SUPPLIERID,h.SUPPLIERNAME
    having sum(Quantity*ATLGFDF)>0;

        /*ATLDFDS For Finished Fabric*/
elsif pQueryType=9 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,b.FABRICTYPEID,
    FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,
    sum(Quantity*ATLDFDS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,
    T_FabricType g,t_supplier h
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.FABRICTYPEID,FABRICTYPE,b.YARNBATCHNO,
    b.SUPPLIERID,h.SUPPLIERNAME
    having sum(Quantity*ATLDFDS)>0;

        /*ATLFFS For Fnished Fabric Delivery */
elsif pQueryType=10 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,b.FABRICTYPEID,
    FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,
    sum(Quantity*ATLFFS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,
    T_FabricType g,t_supplier h
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.FABRICTYPEID,FABRICTYPE,b.YARNBATCHNO,
    b.SUPPLIERID,h.SUPPLIERNAME
    having sum(Quantity*ATLFFS)>0;
  end if;
END GetGrayYarnStockPick;
/


PROMPT CREATE OR REPLACE Procedure  098 :: GetCountryIDs
CREATE OR REPLACE Procedure GetCountryIDs
(
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN

    OPEN data_cursor for
    Select CountryID, CountryName from T_Country;
END;
/
PROMPT CREATE OR REPLACE Procedure  099:: UserLogin
CREATE OR REPLACE Procedure UserLogin
(
  data_cursor1 IN OUT pReturnData.c_Records,
  data_cursor2 IN OUT pReturnData.c_Records,
  user in varchar2,
  pwd in varchar2
)
AS
BEGIN

  open data_cursor1 for
  select EmployeeName,User_Role(user) as isrole  from T_Employee
  where EmployeeID=user and EmpPassword=pwd;

  open data_cursor2 for
  select FormID, FormPermission from T_EmpForms
  where EmployeeID=user;

END UserLogin;
/


PROMPT CREATE OR REPLACE Procedure  100 :: GetCountryList
CREATE OR REPLACE Procedure GetCountryList
(
  pStatus number,
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
/*if the Value is 0 then retun all the Data */
if pStatus=0 then
  OPEN data_cursor for
    Select CountryName, CountryID from T_Country order by CountryName;
/*If the Value is 1 then retun as the */
elsif pStatus=1 then
  OPEN data_cursor for
    Select CountryName, CountryID from T_Country
  where CountryID=pWhereValue order by CountryName;
end if;
END GetCountryList;
/

PROMPT CREATE OR REPLACE Procedure  101 :: GetGWorkOrderList
CREATE OR REPLACE Procedure GetGWorkOrderList
(
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
    OPEN data_cursor for
    Select GORDERNO from T_Gworkorder;
END GetGWorkOrderList;
/

PROMPT CREATE OR REPLACE Procedure  102 :: UpdateOrderBasicTypes
CREATE OR REPLACE Procedure UpdateOrderBasicTypes(
pOrderNo NUMBER, pBasicStr VARCHAR2)
is
idx NUMBER;
begin
 delete from T_BasicWorkorder where WorkorderNo=pOrderNo;
 if (pBasicStr is not null) then
         for idx in 1..length(pBasicStr)
  loop
   insert into T_BasicWorkorder values (pOrderNo, substr(pBasicStr,idx,1));
         end loop;
 end if;
end UpdateOrderBasicTypes;
/


PROMPT CREATE OR REPLACE Procedure  103 :: GetGordertypeLookup
CREATE OR REPLACE Procedure GetGordertypeLookup
(
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
  OPEN data_cursor for
  select ORDERTYPE,DESCRIPTION ||' (' || ORDERTYPE|| ')'  AS DESCRIPTION from t_gordertype;

END GetGordertypeLookup;
/


PROMPT CREATE OR REPLACE Procedure  104 :: getfncBasicType
CREATE OR REPLACE FUNCTION getfncBasicType(basTyID in VARCHAR2)
RETURN varchar2
IS
basictypeNameD  t_basictype.BASICTYPENAME%type;
BEGIN
select basictypeName into basictypeNameD from t_basictype where BASICTYPEID=basTyID;
return basictypeNameD;

END getfncBasicType;
/



PROMPT CREATE OR REPLACE Procedure  105 :: GetWorkorderInfo
CREATE OR REPLACE Procedure GetWorkorderInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  many_cursor IN OUT pReturnData.c_Records,
  basictype_cursor  IN OUT pReturnData.c_Records,
  pOrderNo NUMBER
)
AS
BEGIN
    open one_cursor for
    select OrderNo,dorderno,basictypeid, OrderDate, ClientID, SalesTermID, CurrencyID,ConRate,SalesPersonID,WCancelled,
    WRevised,OrderStatusID, ContactPerson, ClientsRef, DeliveryPlace,DeliveryStartDate,DeliveryEndDate,DailyProductionTarget,
    OrderRemarks, GarmentsOrderRef, GetOrderBasicTypes(pOrderNo) as BasicTypes,budgetid,WOEXECUTE,WOEXECUTEDATE,PPQTY,PSQTY,PRATE,TOTALPRICE
    from T_WorkOrder
    where OrderNo=pOrderNo;

    open many_cursor for
    select OrderLineItem, WoItemSl, KnitMcDiaGauge, CombinationID, FabricTypeID,FinishedGSM,Width,COLLARCUFFID,
    Shrinkage,SHADEGROUPID,Shade, Rate, FeederCount, GrayGSM, Ply, UnitOfMeasID,Quantity AS Quantity ,Remarks,ploss,/*(Quantity + ((Quantity *ploss) / 100))*/
    pQuantity as totalqty,SUNIT,SqTY,T_WorkOrder.budgetid,Brefpid,
    getFncYarnDes(ORDERLINEITEM) as YarnDesc,T_WorkOrder.basictypeid
    from T_OrderItems,T_WorkOrder
    where T_OrderItems.OrderNo=T_WorkOrder.OrderNo AND T_OrderItems.OrderNo=pOrderNo order by WoItemSl;

    open basictype_cursor for
    select BasicTypeID
    from T_BasicWorkOrder
    where WorkOrderNo=pOrderNo;

END GetWorkorderInfo;
/



PROMPT CREATE OR REPLACE Procedure  106 :: CopyYarndesc
Create or Replace Procedure CopyYarndesc
(
 pBUDGETID IN NUMBER,
 pParentid in Varchar2,
 POrderlineitem in varchar2,
 pRecsAffected out NUMBER
)
AS
id number;
BEGIN
   for rec1 in(select YARNTYPEID,YARNCOUNTID,QUANTITY,USES,QTY,PROCESSLOSS from t_yarncost where budgetid=pBUDGETID and ppid=pParentid order by pid)
   loop
	select max(pid)+1 into id from (select to_number(pid) as pid from t_Yarndesc);
    insert into t_yarndesc(PID,YARNTYPEID,YARNCOUNTID,Orderlineitem,YARNPERCENT)
    values(id,rec1.YARNTYPEID,rec1.YARNCOUNTID,POrderlineitem,rec1.USES);
   end loop;

END CopyYarndesc;
/



PROMPT CREATE OR REPLACE Procedure  107 :: GetCollarCuffList
CREATE OR REPLACE Procedure GetCollarCuffList
(
  data_cursor IN OUT pReturnData.c_Records
)

AS
BEGIN

    OPEN data_cursor for
    Select CollarCuffID,CollarCuffSize  from T_CollarCuff order by CollarCuffSize;

END;
/


PROMPT CREATE OR REPLACE Procedure  108 :: GetAttachmentIDs
CREATE OR REPLACE Procedure GetAttachmentIDs
(
  pStatus number,
  pWhereValue number,
  data_cursor IN OUT pReturnData.c_Records
)

AS

BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=0 then
  OPEN data_cursor for
   Select ATTACHMENTID,GORDERNO,ATTACHLOCATION,ATTACHDESC
	from t_gattachmentref order by ATTACHMENTID;
/*If the Value is 1 then retun as the */

elsif pStatus=1 then
  OPEN data_cursor for
   Select ATTACHMENTID,GORDERNO,ATTACHLOCATION,ATTACHDESC
	from t_gattachmentref
	 where GORDERNO=pWhereValue order by ATTACHMENTID;
end if;
END GetAttachmentIDs;
/








PROMPT CREATE OR REPLACE Procedure  109 :: GetDBatchInfo
CREATE OR REPLACE Procedure GetDBatchInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  many_cursor IN OUT pReturnData.c_Records,
  pDBatchID number
)
AS
BEGIN

    open one_cursor for
    select DBatchId, BatchNo, BatchDate,Execute
    from T_DBatch
    where DBatchId=pDBatchID;

    open many_cursor for
    select PID,T_DBatchItems.ORDERNO,GetfncWOBType(T_DBatchItems.ORDERNO) as btype,T_DBatchItems.DBatchId, BatchITEMSL,
    FabricTypeId,OrderlineItem,currentStock,
    Quantity, Squantity,PunitOfmeasId,SUNITOFMEASID,YARNBATCHNO,DYEDLOTNO,Shade,REMARKS
    from T_DBatchItems
    where DBatchId=pDBatchID
    order by BatchITEMSL asc;
END GetDBatchInfo;
/






PROMPT CREATE OR REPLACE Procedure  110 :: getTreeBatchList
CREATE OR REPLACE Procedure getTreeBatchList (
  io_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pBatchNo IN VARCHAR2 DEFAULT NULL,
  sDate IN date,
  eDate IN date
)
AS
BEGIN

  if pQueryType=0 then
    OPEN io_cursor FOR
    select DBatchId, BatchNo from T_DBatch
    where BatchDate>=SDate and BatchDate<=EDate
    order by BatchNo desc;

  elsif pQueryType=1 then
    OPEN io_cursor FOR
    select DBatchId, BatchNo, BatchDate from T_DBatch
    where BatchDate>=SDate and BatchDate<=EDate
    order by BatchDate desc, BatchNo desc;

elsif pQueryType=2 then
    OPEN io_cursor FOR
    select b.orderno, Getfncwobtype(b.orderno) as dorderno 
    from T_DBatch a,T_DBatchItems b
    where a.DBATCHID=b.DBATCHID and BatchDate>=SDate and BatchDate<=EDate
    Group by b.orderno
    order by dorderno desc;

  elsif pQueryType=9999 then
    OPEN io_cursor FOR
    select DBatchId from T_DBatch
    where BatchDate>=SDate and BatchDate<=EDate and
    Upper(BatchNo) Like pBatchNo;
  end if;

END getTreeBatchList;
/






PROMPT CREATE OR REPLACE Procedure  111:: GetDeliveryBatch
CREATE OR REPLACE Procedure GetDeliveryBatch(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pOrderno in Number,
  pShadegroupid in Number,
  pFABRICTYPEID IN VARCHAR2,
  pStockDate DATE
)
AS
BEGIN
/*  All Summary Report*/
  if pQueryType=0 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID, b.YARNBATCHNO,b.FABRICTYPEID,c.YarnCount,
    d.YarnType, e.UnitOfMeas, sum(b.Quantity*ATLGYS) MainStore,
    sum(b.Quantity*ATLGYF) SubStore, sum(b.Quantity*AYDLGYS) SubStock
    from T_Knitstock a, T_KnitStockItems b, T_YarnCount c, T_YarnType d,
    T_UnitOfMeas e,T_KnitTransactionTYpe f
    where a.StockID=b.StockID and
    b.yarnCountId=c.yarncountid and
    b.yarntypeid=d.yarntype and
    b.PunitOfMeasId=e.UnitOfmeasId and
    STOCKTRANSDATE <= pStockDate;
	/*ATLGFDF* For GRAY Fabric*/
elsif pQueryType=1 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.FABRICTYPEID,
    FABRICTYPE,'' as OrderlineItem,b.Shade,b.YARNBATCHNO,b.DYEDLOTNO,
    b.PUnitOfMeasId,f.UnitOfMeas,b.shadegroupid,h.shadegroupname,b.sUnitOfMeasId as sunitid,i.unitofmeas as sunit,
    sum(Quantity*ATLGFDF) CurrentStock,sum(SQuantity*ATLGFDF) sqty,
	NVL(decode(b.DYEDLOTNO,null,(SELECT sum(QUANTITY) FROM T_DBATCHITEMS
	where ORDERNO=pOrderno and FABRICTYPEID=b.FABRICTYPEID and
	shadegroupid=pShadegroupid and YARNBATCHNO=b.YARNBATCHNO),(SELECT sum(QUANTITY) FROM T_DBATCHITEMS
	where ORDERNO=pOrderno and FABRICTYPEID=b.FABRICTYPEID and
	shadegroupid=pShadegroupid and YARNBATCHNO=b.YARNBATCHNO and DYEDLOTNO=b.DYEDLOTNO and Shade=b.Shade)),0) as BatchQty,
	(sum(Quantity*ATLGFDF)-NVL(decode(b.DYEDLOTNO,null,(SELECT sum(QUANTITY) FROM T_DBATCHITEMS
	where ORDERNO=pOrderno and FABRICTYPEID=b.FABRICTYPEID and
	shadegroupid=pShadegroupid and YARNBATCHNO=b.YARNBATCHNO),(SELECT sum(QUANTITY) FROM T_DBATCHITEMS
	where ORDERNO=pOrderno and FABRICTYPEID=b.FABRICTYPEID and
	shadegroupid=pShadegroupid and YARNBATCHNO=b.YARNBATCHNO and DYEDLOTNO=b.DYEDLOTNO and Shade=b.Shade)),0)) as RemainBatchQty,
   (sum(SQuantity*ATLGFDF)-NVL(decode(b.DYEDLOTNO,null,(SELECT sum(SQUANTITY) FROM T_DBATCHITEMS
	where ORDERNO=pOrderno and FABRICTYPEID=b.FABRICTYPEID and
	shadegroupid=pShadegroupid and YARNBATCHNO=b.YARNBATCHNO),(SELECT sum(SQUANTITY) FROM T_DBATCHITEMS
	where ORDERNO=pOrderno and FABRICTYPEID=b.FABRICTYPEID and
	shadegroupid=pShadegroupid and YARNBATCHNO=b.YARNBATCHNO and DYEDLOTNO=b.DYEDLOTNO and Shade=b.Shade)),0)) as RemainBatchSQty
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_UnitOfMeas f,T_FabricType g,T_shadeGroup h,T_UnitOfMeas i
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and c.KNTITRANSACTIONTYPEID<>73 and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.shadegroupid=h.shadegroupid and
    b.PUnitOfMeasID=f.UnitOfMeasID(+)  and
    b.SUnitOfMeasID=i.UnitOfMeasID(+)  and
    STOCKTRANSDATE <= pStockDate and b.FABRICTYPEID=pFABRICTYPEID and
    b.orderno=pOrderno and b.shadegroupid=pShadegroupid
    group by b.ORDERNO,b.Shade,b.PUnitOfMeasId,f.UnitOfMeas,b.FABRICTYPEID,FABRICTYPE,b.YARNBATCHNO,
	b.DYEDLOTNO,b.shadegroupid,h.shadegroupname,b.sUnitOfMeasId,i.unitofmeas
   having (sum(Quantity*ATLGFDF)-NVL(decode(b.DYEDLOTNO,null,(SELECT sum(QUANTITY) FROM T_DBATCHITEMS
	where ORDERNO=pOrderno and FABRICTYPEID=b.FABRICTYPEID and
	shadegroupid=pShadegroupid and YARNBATCHNO=b.YARNBATCHNO),(SELECT sum(QUANTITY) FROM T_DBATCHITEMS
	where ORDERNO=pOrderno and FABRICTYPEID=b.FABRICTYPEID and
	shadegroupid=pShadegroupid and YARNBATCHNO=b.YARNBATCHNO and DYEDLOTNO=b.DYEDLOTNO and Shade=b.Shade)),0))>0
UNION ALL
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.FABRICTYPEID,
    FABRICTYPE,'' as OrderlineItem,b.Shade,b.YARNBATCHNO,b.DYEDLOTNO,
    b.PUnitOfMeasId,f.UnitOfMeas,b.shadegroupid,h.shadegroupname,b.sUnitOfMeasId as sunitid,i.unitofmeas as sunit,
    sum(Quantity*ATLGFDF) CurrentStock,sum(SQuantity*ATLGFDF) sqty,
	NVL(decode(b.DYEDLOTNO,null,(SELECT sum(QUANTITY) FROM T_DBATCHITEMS
	where ORDERNO=pOrderno and FABRICTYPEID=b.FABRICTYPEID and
	shadegroupid=pShadegroupid and YARNBATCHNO=b.YARNBATCHNO),(SELECT sum(QUANTITY) FROM T_DBATCHITEMS
	where ORDERNO=pOrderno and FABRICTYPEID=b.FABRICTYPEID and
	shadegroupid=pShadegroupid and YARNBATCHNO=b.YARNBATCHNO and DYEDLOTNO=b.DYEDLOTNO and Shade=b.Shade)),0) as BatchQty,
	(sum(Quantity*ATLGFDF)-NVL(decode(b.DYEDLOTNO,null,(SELECT sum(QUANTITY) FROM T_DBATCHITEMS
	where ORDERNO=pOrderno and FABRICTYPEID=b.FABRICTYPEID and
	shadegroupid=pShadegroupid and YARNBATCHNO=b.YARNBATCHNO),(SELECT sum(QUANTITY) FROM T_DBATCHITEMS
	where ORDERNO=pOrderno and FABRICTYPEID=b.FABRICTYPEID and
	shadegroupid=pShadegroupid and YARNBATCHNO=b.YARNBATCHNO and DYEDLOTNO=b.DYEDLOTNO and Shade=b.Shade)),0)) as RemainBatchQty,
   (sum(SQuantity*ATLGFDF)-NVL(decode(b.DYEDLOTNO,null,(SELECT sum(SQUANTITY) FROM T_DBATCHITEMS
	where ORDERNO=pOrderno and FABRICTYPEID=b.FABRICTYPEID and
	shadegroupid=pShadegroupid and YARNBATCHNO=b.YARNBATCHNO),(SELECT sum(SQUANTITY) FROM T_DBATCHITEMS
	where ORDERNO=pOrderno and FABRICTYPEID=b.FABRICTYPEID and
	shadegroupid=pShadegroupid and YARNBATCHNO=b.YARNBATCHNO and DYEDLOTNO=b.DYEDLOTNO and Shade=b.Shade)),0)) as RemainBatchSQty
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_UnitOfMeas f,T_FabricType g,T_shadeGroup h,T_UnitOfMeas i
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and c.KNTITRANSACTIONTYPEID=73 and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.shadegroupid=h.shadegroupid and
    b.PUnitOfMeasID=f.UnitOfMeasID(+)  and
    b.SUnitOfMeasID=i.UnitOfMeasID(+)  and
    STOCKTRANSDATE <= pStockDate and b.FABRICTYPEID=pFABRICTYPEID and
    b.orderno=pOrderno and b.shadegroupid=pShadegroupid
    group by b.ORDERNO,b.Shade,b.PUnitOfMeasId,f.UnitOfMeas,b.FABRICTYPEID,FABRICTYPE,b.YARNBATCHNO,
	b.DYEDLOTNO,b.shadegroupid,h.shadegroupname,b.sUnitOfMeasId,i.unitofmeas
   having (sum(Quantity*ATLGFDF)-NVL(decode(b.DYEDLOTNO,null,(SELECT sum(QUANTITY) FROM T_DBATCHITEMS
	where ORDERNO=pOrderno and FABRICTYPEID=b.FABRICTYPEID and
	shadegroupid=pShadegroupid and YARNBATCHNO=b.YARNBATCHNO),(SELECT sum(QUANTITY) FROM T_DBATCHITEMS
	where ORDERNO=pOrderno and FABRICTYPEID=b.FABRICTYPEID and
	shadegroupid=pShadegroupid and YARNBATCHNO=b.YARNBATCHNO and DYEDLOTNO=b.DYEDLOTNO and Shade=b.Shade)),0))>0 	;
  end if;
END GetDeliveryBatch;
/




PROMPT CREATE OR REPLACE Procedure  112 :: GetDeliveryInvoice
CREATE OR REPLACE Procedure GetDeliveryInvoice
(
  one_cursor IN OUT pReturnData.c_Records,
  many_cursor IN OUT pReturnData.c_Records,
  pDInvoiceID number
)
AS
BEGIN
    open one_cursor for
    select DInvoiceId, InvoiceNo, InvoiceDate, ClientId, ContactPerson, DeliveryPlace,
    GatePassNo,DINVOICECOMMENTS,DType,orderno,MREMARKS
    from T_DInvoice
    where DInvoiceId=pDInvoiceID;

    open many_cursor for
    select PID,t_DinvoiceItems.DINVOICEID,DINVOICEITEMSL,
    FABRICTYPEID, ORDERLINEITEM,ITEMDESC,CURRENTQTY,QUANTITY,SQUANTITY,RETURNABLE,RETURNEDQTY,NONRETURNABLE,
    PUNITOFMEASID, SUNITOFMEASID,Shade,REMARKS,ORDERNO,YARNBATCHNO,
    getfncWOBType(orderno) as BTYPE,FINISHEDDIA,FINISHEDGSM,GWT,FWT,DBatch,shadegroupid
    from t_DinvoiceItems
    where DInvoiceId=pDInvoiceID
    order by DINVOICEITEMSL asc;
END GetDeliveryInvoice;
/





PROMPT CREATE OR REPLACE Procedure  113 :: getTreeInvoiceList

CREATE OR REPLACE Procedure getTreeInvoiceList (
  io_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pdtype  IN VARCHAR2,
  sDate IN date,
  eDate IN date
)
AS
BEGIN

  if pQueryType=0 then
    OPEN io_cursor FOR
    select DInvoiceId, InvoiceNo from T_DInvoice
    where InvoiceDate>=SDate and InvoiceDate<=EDate AND DTYPE=pdtype
    order by InvoiceNo desc;

  elsif pQueryType=1 then
    OPEN io_cursor FOR
    select DInvoiceId, InvoiceNo, InvoiceDate from T_DInvoice
    where InvoiceDate>=SDate and InvoiceDate<=EDate AND DTYPE=pdtype
    order by InvoiceDate desc, InvoiceNo desc;

  elsif pQueryType=2 then
    OPEN io_cursor FOR
    select a.ORDERNO, Getfncwobtype(a.ORDERNO) as dorderno 
    from T_DInvoice a
    where InvoiceDate>=SDate and InvoiceDate<=EDate AND DTYPE=pdtype
    Group by a.ORDERNO
    order by dorderno desc;
	
  elsif pQueryType=3 then    
    OPEN io_cursor FOR
    select DInvoiceId, InvoiceNo,ClientName from T_DInvoice,T_Client
    where InvoiceDate>=SDate and InvoiceDate<=EDate AND DTYPE=pdtype and T_DInvoice.ClientID=T_Client.ClientID
    order by ClientName,InvoiceNo desc;

  elsif pQueryType=9999 then
    OPEN io_cursor FOR
    select DInvoiceId from T_DInvoice
    where InvoiceDate>=SDate and InvoiceDate<=EDate and DTYPE=pdtype;
  end if;

END getTreeInvoiceList;
/




PROMPT CREATE OR REPLACE Procedure  114 :: GetBatchPickUp
CREATE OR REPLACE Procedure GetBatchPickUp(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pStockDate DATE
)
AS
BEGIN


/*  All Summary Report*/
  if pQueryType=0 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,a.ClientID, b.dBatch,b.FABRICTYPEID,e.UnitOfMeas, b.Quantity 
    from T_DInvoice a, T_DInvoiceItems b,T_UnitOfMeas e
    where a.dInvoiceID=b.dInvoiceID and
    b.PunitOfMeasId=e.UnitOfmeasId and
    InvoiceDATE <= pStockDate;

	/*ATLGFDF* For Dyed Fabric*/
elsif pQueryType=1 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.FABRICTYPEID,
    FABRICTYPE,b.OrderlineItem,a.BATCHNO,b.Shade,
    b.PUnitOfMeasId,UnitOfMeas,Quantity,SQuantity,b.SUnitOfMeasId
    from T_DBatch a, T_DBatchItems b,
    T_UnitOfMeas f,
    T_FabricType g
    where a.dbatchID=b.dbatchID and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    BatchDATE <= pStockDate
    group by b.ORDERNO,b.FABRICTYPEID,
    FABRICTYPE,b.OrderlineItem,a.BATCHNO,b.Shade,
    b.PUnitOfMeasId,UnitOfMeas,Quantity,SQuantity,b.SUnitOfMeasId
    having Quantity>0;

  end if;
END GetBatchPickUp;
/



------------------------------------------------------------------

PROMPT CREATE OR REPLACE Procedure  115 :: GetGroupIDs
CREATE OR REPLACE Procedure GetGroupIDs
(
  pStatus number,
  pWhereValue number,
  data_cursor IN OUT pReturnData.c_Records
)

AS

BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=0 then
  OPEN data_cursor for
   Select GroupID,GroupName
	from T_AccGroup order by GroupID;
/*If the Value is 1 then retun as the */

elsif pStatus=1 then
  OPEN data_cursor for
    Select GroupID,GroupName
	from T_AccGroup
	 where GroupID=pWhereValue order by GroupID;
end if;
END GetGroupIDs;
/

PROMPT CREATE OR REPLACE Procedure  116 :: GetGroupID
CREATE OR REPLACE Procedure GetGroupID
(
  data_cursor IN OUT pReturnData.c_Records
)

AS

BEGIN
  OPEN data_cursor for
   Select GroupID,GroupName
	from T_AccGroup order by GroupID;
END GetGroupID;
/


PROMPT CREATE OR REPLACE Procedure  117 :: GetTWOItemList

create or replace Procedure GetTWOItemList
(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType number,
  pOrderno number
)
AS
BEGIN
if (pQueryType=1) then
	OPEN data_cursor for
	select a.OrderLineItem,getFncYarnDes(a.ORDERLINEITEM) as YarnDesc,a.WoItemSl,a.FabricTypeID,a.FinishedGSM,a.ORDERNO,a.COLLARCUFFID,
	a.SHADEGROUPID,a.Shade,a.KNITMCDIAGAUGE,a.WIDTH,(a.Quantity+(a.Quantity/100)*(Select max(PROCESSLOSS) From T_YARNCOST Where PPID=a.BREFPID group by PPID)) as CurrentQty,
	/*((a.Quantity)-DECODE((SELECT SUM(NVL(Quantity,0)) FROM T_SCORDERITEMS WHERE TORDERLINEITEMREF=a.OrderLineItem),NULL,0,(SELECT SUM(NVL(Quantity,0)) FROM T_SCORDERITEMS WHERE TORDERLINEITEMREF=a.OrderLineItem))) AS Quantity,*/
	(a.Quantity) AS Quantity,
	(Select max(PROCESSLOSS) From T_YARNCOST Where PPID=a.BREFPID group by PPID) as Wastage,
	((a.Quantity+(a.Quantity/100)*(Select max(PROCESSLOSS) From T_YARNCOST Where PPID=a.BREFPID group by PPID))-DECODE((SELECT SUM(NVL(Quantity,0)) FROM T_SCORDERITEMS WHERE TORDERLINEITEMREF=a.OrderLineItem),NULL,0,(SELECT SUM(NVL(Quantity,0)) FROM T_SCORDERITEMS WHERE TORDERLINEITEMREF=a.OrderLineItem))) as RemQty,
	a.UnitOfMeasID,0 AS SqTY,a.SUNIT,a.basictypeid,a.BREFPID
	from T_ORDERITEMS a
	WHERE a.ORDERNO=pOrderno;
End If;
END GetTWOItemList;
/



PROMPT CREATE OR REPLACE Procedure  118:: getGAWorkorderTree
CREATE OR REPLACE Procedure getGAWorkorderTree (
  tree_cursor IN OUT pReturnData.c_Records,
 /* pOrdercode varchar2, */
  pGroupID number,
  pStartDate date,
  pEndDate date
)
AS
BEGIN
  /* Order No Descending by Date*/
  if pGroupID=0 then
    open tree_cursor for
    select OrderNo,dorderNO AS dorder
    from T_GAWorkOrder
    where OrderDate between pStartDate and pEndDate
    order by dorderNO desc;
 /* Order Date */
  elsif pGroupID = 1 then
    open tree_cursor for
    select OrderNo,dorderNO AS dorder, OrderDate
    from T_GAWorkOrder
    where OrderDate between pStartDate and pEndDate
    order by OrderDate desc;

 /* Supplier Name */
  elsif pGroupID = 2 then
    open tree_cursor for
    select OrderNo,dorderNO AS dorder, SUPPLIERNAME
    from T_GAWorkOrder, T_Supplier
    where T_GAWorkOrder.SupplierId=T_Supplier.SupplierId and
    OrderDate between pStartDate and pEndDate
    order by SUPPLIERNAME,dorderNO desc;

  /* Combo Fillup Assecndig*/
  elsif pGroupID=99 then
    open tree_cursor for
    select OrderNo,dorderNO AS dorder
    from T_GAWorkOrder
    where OrderDate between pStartDate and pEndDate
    order by OrderNo,dorderno desc;
  end if;
End getGAWorkorderTree;
/


PROMPT CREATE OR REPLACE Procedure  119 :: GetAccItemFromBudgetPickUp
CREATE OR REPLACE Procedure GetAccItemFromBudgetPickUp
(
  data_cursor IN OUT pReturnData.c_Records,
  pBudgetId Number
)
AS

BEGIN
  OPEN data_cursor for
    Select a.BUDGETID, a.PID, a.QUNATITY, a.UNITPRICE, c.ITEM, b.GROUPNAME, d.unitofmeas as Unit, a.TOTALCOST,
        a.AccessoriesID,c.GroupId,a.UNITOFMEASID	
from T_GarmentsCost a, T_AccGroup b, T_Accessories c, T_unitOfmeas d
where 
	c.GroupId=b.GROUPID(+) and
	a.AccessoriesID=c.ACCESSORIESID(+) and
	a.UNITOFMEASID=d.UNITOFMEASID(+) and
	a.BUDGETID=pBUDGETID
	order by a.PID;
END GetAccItemFromBudgetPickUp;
/


PROMPT CREATE OR REPLACE Procedure  120:: GetAllGWorkOrderList

create or replace Procedure GetAllGWorkOrderList
(
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
 OPEN data_cursor for
     Select GOrderNo,ORDERTYPEID || ' ' || GDORDERNO as GDORDERNO
 from T_Gworkorder;
END GetAllGWorkOrderList;
/


PROMPT CREATE OR REPLACE Procedure  121 :: getTreeAccList
CREATE OR REPLACE Procedure getTreeAccList (
  io_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER
)
AS
BEGIN


 /* Grouping For All Except Misc*/
  if pQueryType=0 then
      OPEN io_cursor FOR
 	select Level,accessoriesid, Item, Parent
   	from t_accessories
   	start with Parent is null
   	connect by prior t_accessories.accessoriesid = Parent;

  elsif pQueryType=1 then
      OPEN io_cursor FOR
 	select Level, lpad(' ',2*(level-1)) || to_char(t_accessories.accessoriesid) accessoriesid,Item, Parent
   	from t_accessories
   	start with Parent is null
   	connect by prior t_accessories.accessoriesid = Parent
       	order by accessoriesid;

/*Grouping for Misc*/
  elsif pQueryType=2 then
      OPEN io_cursor FOR
 	select Level, lpad(' ',2*(level-1)) || to_char(t_accessories.accessoriesid) accessoriesid,Item, Parent
   	from t_accessories
   	start with Parent is null
   	connect by prior t_accessories.accessoriesid = Parent
       	order by accessoriesid;
  end if;

END getTreeAccList;
/


PROMPT CREATE OR REPLACE Procedure  122 :: GetDyedFabricStockPosition
Create or Replace Procedure GetDyedFabricStockPosition
(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pKnitTranTypeID NUMBER,
  pStockDate DATE
)
AS
BEGIN
/*  All Summary Report*/
  if pQueryType=0 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID, b.YARNBATCHNO,b.FABRICTYPEID,c.YarnCount,
    d.YarnType, e.UnitOfMeas, sum(b.Quantity*ATLGYS) MainStore,
    sum(b.Quantity*ATLGYF) SubStore, sum(b.Quantity*AYDLGYS) SubStock
    from T_Knitstock a, T_KnitStockItems b,T_YarnCount c, T_YarnType d,
    T_UnitOfMeas e, T_knitTransactionType f
    where a.StockID=b.StockID and
    b.yarnCountId=c.yarncountid and
    b.yarntypeid=d.yarntype and
    b.PunitOfMeasId=e.UnitOfmeasId and
    STOCKTRANSDATE <= pStockDate and
    a.KNTITRANSACTIONTYPEID = pKnitTranTypeID;

        /* ATLGYS*/
  elsif pQueryType=1 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,b.Shade,
    b.FABRICTYPEID,FABRICTYPE,b.OrderlineItem, b.YARNTYPEID,b.YARNCOUNTID,b.DyedLotno,
    YarnCount,YarnType,b.PUnitOfMeasId,UnitOfMeas,sum(Quantity*ATLGYS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,
    T_FabricType g,t_supplier h
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by
    b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.DyedLotno,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.FABRICTYPEID,FABRICTYPE,b.YARNBATCHNO,b.Shade,
    b.SUPPLIERID,h.SUPPLIERNAME
    having sum(Quantity*ATLGYS)>0 ORDER BY btype;

/*  ATLGFS*/
elsif pQueryType=2 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,b.FABRICTYPEID,
    FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.DyedLotno,
    sum(Quantity*ATLGFS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,
    T_FabricType g,t_supplier h
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.FABRICTYPEID,FABRICTYPE,b.YARNBATCHNO,
    b.SUPPLIERID,h.SUPPLIERNAME
    having sum(Quantity*ATLGFS)>0 ORDER BY btype;


        /* ATLGYF */
elsif pQueryType=3 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,b.FABRICTYPEID,
    FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,b.DyedLotno,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,sum(Quantity*ATLGYF) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,
    T_FabricType g,t_supplier h
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.FABRICTYPEID,FABRICTYPE,b.YARNBATCHNO,b.DyedLotno,
    b.SUPPLIERID,h.SUPPLIERNAME
    having sum(Quantity*ATLGYF)>0 ORDER BY btype;

      /* AYDLGYS */
elsif pQueryType=4 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,b.FABRICTYPEID,
    FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.DyedLotno,sum(Quantity*AYDLGYS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,
    T_FabricType g,t_supplier h
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.FABRICTYPEID,FABRICTYPE,b.DyedLotno,
    b.YARNBATCHNO,b.SUPPLIERID,h.SUPPLIERNAME
    having sum(Quantity*AYDLGYS)>0 ORDER BY btype;

                /*ODSCONGYS*/
elsif pQueryType=5 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,b.FABRICTYPEID,
    FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.DyedLotno,
    sum(Quantity*ODSCONGYS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,
    T_FabricType g,t_supplier h
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,
    b.Shade, YarnType,b.PUnitOfMeasId,UnitOfMeas,b.DyedLotno,
    b.FABRICTYPEID,FABRICTYPE,b.YARNBATCHNO,b.SUPPLIERID,h.SUPPLIERNAME
    having sum(Quantity*ODSCONGYS)>0 ORDER BY btype;


                /*KSCONGYS*/
elsif pQueryType= 6 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,b.FABRICTYPEID,
    FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.DyedLotno,sum(Quantity*KSCONGYS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,T_FabricType g,t_supplier h
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.SUPPLIERID=h.SUPPLIERID and
    b.YarnTypeId= e.YarnTypeId and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.FABRICTYPEID,b.DyedLotno,
    FABRICTYPE,b.YARNBATCHNO,b.SUPPLIERID,h.SUPPLIERNAME
    having sum(Quantity*KSCONGYS)>0 ORDER BY btype;

/*ATLGFS For FabricDelivery*/
elsif pQueryType=7 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,b.FABRICTYPEID,
    FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.DyedLotno,
    sum(Quantity*ATLGFS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,
    T_FabricType g,t_supplier h
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.FABRICTYPEID,FABRICTYPE,b.YARNBATCHNO,
    b.SUPPLIERID,h.SUPPLIERNAME,b.DyedLotno
    having sum(Quantity*ATLGFS)>0 ORDER BY btype;

        /*ATLGFDF* For Dyed Fabric*/
elsif pQueryType=8 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,b.FABRICTYPEID,
    FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.DyedLotno,
    sum(Quantity*ATLGFDF) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,
    T_FabricType g,t_supplier h
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.FABRICTYPEID,FABRICTYPE,b.YARNBATCHNO,
    b.SUPPLIERID,h.SUPPLIERNAME,b.DyedLotno
    having sum(Quantity*ATLGFDF)>0 ORDER BY btype;

        /*ATLDFDS For Finished Fabric*/
elsif pQueryType=9 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,b.FABRICTYPEID,
    FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.DyedLotno,
    sum(Quantity*ATLDFDS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,
    T_FabricType g,t_supplier h
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.FABRICTYPEID,FABRICTYPE,b.YARNBATCHNO,
    b.SUPPLIERID,h.SUPPLIERNAME,b.DyedLotno
    having sum(Quantity*ATLDFDS)>0 ORDER BY btype;

        /*ATLFFS For Fnished Fabric Delivery */
elsif pQueryType=10 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,b.FABRICTYPEID,
    FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.DyedLotno,
    sum(Quantity*ATLFFS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,
    T_FabricType g,t_supplier h
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.FABRICTYPEID,FABRICTYPE,b.YARNBATCHNO,
    b.SUPPLIERID,h.SUPPLIERNAME,b.DyedLotno
    having sum(Quantity*ATLFFS)>0 ORDER BY btype;

        /*ATLDYS For Dyed Yarn Issue To Floor For Knitting*/
elsif pQueryType=11 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
    b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.DyedLotno,b.shadegroupid,i.shadegroupname,'' AS fabrictypeid,'' AS fabrictype,
    sum(Quantity*ATLDYS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier h,t_shadegroup i
    where a.StockID=b.StockID and
    b.shadegroupid=i.shadegroupid and
    b.SUPPLIERID=h.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.YARNBATCHNO,
    b.SUPPLIERID,h.SUPPLIERNAME,b.DyedLotno,b.shadegroupid,i.shadegroupname
    having sum(Quantity*ATLDYS)>0  ORDER BY btype,i.shadegroupName,b.Shade,b.YARNBATCHNO;

        /*ATLDYF Fabric Receive From Floor*/
elsif pQueryType=12 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
    b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.DyedLotno,
    sum(Quantity*ATLDYF) CurrentStock,i.subconname,b.subconid
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,
    t_supplier h,t_subcontractors i
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    b.subconid=i.subconid and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.YARNBATCHNO,
    b.SUPPLIERID,h.SUPPLIERNAME,b.DyedLotno,i.subconname,b.subconid
    having sum(Quantity*ATLDYF)>0 ORDER BY btype;

        /*KSCONDYS Fabric Receive From Knitting SubCon*/
elsif pQueryType=13 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
    b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.DyedLotno,
    sum(Quantity*KSCONDYS) CurrentStock,i.subconname,b.subconid
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,
    t_supplier h,t_subcontractors i
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    b.subconid=i.subconid and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.YARNBATCHNO,
    b.SUPPLIERID,h.SUPPLIERNAME,b.DyedLotno,i.subconname,b.subconid
    having sum(Quantity*KSCONDYS)>0 ORDER BY btype;
	
	/*ATLDYF Dyed Yarn Return From Floor*/
elsif pQueryType=14 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
    b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.shadegroupid,j.shadegroupName,b.Shade,
    YarnType,b.PUnitOfMeasId,f.UnitOfMeas,b.DyedLotno,b.fabrictypeid,k.fabrictype,b.shadegroupid,g.shadegroupName,b.sunitofmeasid as sunitid,l.unitofmeas as sunit,
    sum(Quantity*ATLDYF) CurrentStock,b.yarnfor, sum(SQuantity*ATLDYF) Cursqty,i.subconname,b.subconid
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,T_ShadeGroup g,
    t_supplier h,t_subcontractors i,t_shadegroup j,t_fabrictype k,T_UnitOfMeas l
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID and
    b.shadegroupid=j.shadegroupid and 
    b.fabrictypeid=k.fabrictypeid and 
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.SHADEGROUPID=g.SHADEGROUPID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUnitOfMeasID=l.UnitOfMeasID(+) and 
    b.subconid=i.subconid and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.shadegroupid,g.shadegroupName,b.Shade,
    YarnType,b.PUnitOfMeasId,f.UnitOfMeas,b.YARNBATCHNO,b.SUPPLIERID,h.SUPPLIERNAME,b.DyedLotno,i.subconname,
    b.subconid,b.fabrictypeid,k.fabrictype,b.shadegroupid,j.shadegroupName,b.sunitofmeasid,l.unitofmeas,b.yarnfor
    having sum(Quantity*ATLDYF)>0 ORDER BY btype;
	/*KSCONDYS Dyed Yarn Return From K-SubCon*/
elsif pQueryType=15 then
    open data_cursor for
 select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
    b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, b.Shade,
    YarnType,b.PUnitOfMeasId,f.UnitOfMeas,b.DyedLotno,b.fabrictypeid,k.fabrictype,b.shadegroupid,j.shadegroupName,b.sunitofmeasid as sunitid,l.unitofmeas as sunit,
    sum(Quantity*KSCONDYS) CurrentStock,b.yarnfor,sum(SQuantity*KSCONDYS) Cursqty,i.subconname,b.subconid
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,
    t_supplier h,t_subcontractors i,t_shadegroup j,t_fabrictype k,T_UnitOfMeas l
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID and
    b.shadegroupid=j.shadegroupid and 
    b.fabrictypeid=k.fabrictypeid and 
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
     b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUnitOfMeasID=l.UnitOfMeasID(+) and 
    b.subconid=i.subconid and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
    YarnType,b.PUnitOfMeasId,f.UnitOfMeas,b.YARNBATCHNO,b.SUPPLIERID,h.SUPPLIERNAME,b.DyedLotno,i.subconname,
    b.subconid,b.fabrictypeid,k.fabrictype,b.shadegroupid,j.shadegroupName,b.sunitofmeasid,l.unitofmeas,b.yarnfor
    having sum(Quantity*KSCONDYS)>0 ORDER BY btype;

   
	/*ATLDFS Dyed Yarn Transfer Main Stock*/
elsif pQueryType=16 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
    b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.SHADEGROUPID,j.SHADEGROUPNAME, b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.DyedLotno,b.yarnfor,k.fabrictype,b.FabricTypeID,
    sum(Quantity*ATLDYS) CurrentStock,i.subconname,b.subconid
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,
    t_supplier h,t_subcontractors i,T_ShadeGroup j,T_fabrictype k
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.SHADEGROUPID=j.SHADEGROUPID and
	b.fabrictypeid=k.fabrictypeid and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    b.subconid=i.subconid and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.SHADEGROUPID,j.SHADEGROUPNAME,b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.YARNBATCHNO,k.fabrictype,b.FabricTypeID,
    b.SUPPLIERID,h.SUPPLIERNAME,b.DyedLotno,i.subconname,b.subconid,b.yarnfor
    having sum(Quantity*ATLDYS)>0 ORDER BY btype;

	/*ATLDYS Dyed Yarn Return To AYDL/subContractor FOR REDYEING*/
elsif pQueryType=17 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
    b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.shadegroupid,j.shadegroupName,b.Shade,
    YarnType,b.PUnitOfMeasId,f.UnitOfMeas,b.DyedLotno,b.fabrictypeid,m.fabrictype,b.shadegroupid,
    g.shadegroupName,b.sunitofmeasid as sunitid,l.unitofmeas as sunit,b.yarnfor,
    sum(Quantity*ATLDYS) CurrentStock, sum(SQuantity*ATLDYS) Cursqty,i.subconname,b.subconid
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,T_ShadeGroup g,
    t_supplier h,t_subcontractors i,t_shadegroup j,T_UnitOfMeas l,T_fabricType m
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID and
    b.shadegroupid=j.shadegroupid and 
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
	b.FABRICTYPEID=m.FABRICTYPEID(+) and
    b.SHADEGROUPID=g.SHADEGROUPID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUnitOfMeasID=l.UnitOfMeasID(+) and 
    b.subconid=i.subconid and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.shadegroupid,g.shadegroupName,b.Shade,
    YarnType,b.PUnitOfMeasId,f.UnitOfMeas,b.YARNBATCHNO,b.SUPPLIERID,h.SUPPLIERNAME,b.DyedLotno,i.subconname,
    b.subconid,b.fabrictypeid,m.fabrictype,b.shadegroupid,j.shadegroupName,b.sunitofmeasid,l.unitofmeas,b.yarnfor
    having sum(Quantity*ATLDYS)>0 ORDER BY btype,j.shadegroupName,b.Shade,b.YARNBATCHNO;

  end if;
END GetDyedFabricStockPosition;
/



PROMPT CREATE OR REPLACE Procedure  123 :: getWorkorderTree
CREATE OR REPLACE Procedure getWorkorderTree (
  tree_cursor IN OUT pReturnData.c_Records,
  pOrdercode varchar2,
  pGroupID number,
  pStartDate date,
  pEndDate date
)
AS
BEGIN
  /* Order No Descending by Date*/
  if pGroupID=0 then
    open tree_cursor for
    select OrderNo,dorderNO AS dorder
    from T_WorkOrder
    where OrderDate between pStartDate and pEndDate and basictypeid=pOrdercode
    order by dorderNO desc;
 /* Order Date */
  elsif pGroupID = 1 then
    open tree_cursor for
    select OrderNo,dorderNO AS dorder, OrderDate
    from T_WorkOrder
    where OrderDate between pStartDate and pEndDate and basictypeid=pOrdercode
    order by OrderDate desc;

 /* Client Name */
  elsif pGroupID = 2 then
    open tree_cursor for
    select OrderNo,dorderNO AS dorder, ClientName
    from T_WorkOrder, T_Client
    where T_WorkOrder.ClientID=T_Client.ClientID and
    OrderDate between pStartDate and pEndDate and basictypeid=pOrdercode
    order by ClientName,dorderNO desc;

  /* Sales Person*/

  elsif pGroupID = 3 then
    open tree_cursor for
    select OrderNo,dorderNO AS dorder, EmployeeName
    from T_WorkOrder, T_Employee
    where T_WorkOrder.SalesPersonID=T_Employee.EmployeeID and
    OrderDate between pStartDate and pEndDate and basictypeid=pOrdercode
    order by EmployeeName,dorderNO desc;

  /* Combo Fillup Assecndig*/
  elsif pGroupID=99 then
    open tree_cursor for
    select OrderNo,GetfncWOBType(OrderNo) as dorder
    from T_WorkOrder
    where OrderDate between pStartDate and pEndDate
    order by basictypeid,dorderno desc;
  end if;
End getWorkorderTree;
/



PROMPT CREATE OR REPLACE Procedure  124 :: GetordertypeLookup
CREATE OR REPLACE Procedure GetordertypeLookup
(
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
  OPEN data_cursor for
  select ORDERCODE,DESCRIPTION ||' (' || ORDERCODE || ')'  AS DESCRIPTION from t_ordertype
	order by DESCRIPTION;

END GetordertypeLookup;
/


PROMPT CREATE OR REPLACE Procedure  125 :: GetordertypeLookup
CREATE OR REPLACE Procedure GetordertypeLookup
(
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
  OPEN data_cursor for
  select ORDERCODE,DESCRIPTION ||' (' || ORDERCODE || ')'  AS DESCRIPTION from t_ordertype
	order by DESCRIPTION;

END GetordertypeLookup;
/




PROMPT CREATE OR REPLACE Procedure  126 :: GetOrdertypeInfo
CREATE OR REPLACE Procedure GetOrdertypeInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  pBasictypeid varchar2
)
AS
BEGIN

    open one_cursor for
    select max(dorderno) from T_WorkOrder where basictypeid=pBasictypeid ;

    
END GetOrdertypeInfo;
/





PROMPT CREATE OR REPLACE Procedure  127 :: GetBatchFabricStockPosition
CREATE OR REPLACE Procedure GetBatchFabricStockPosition(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pKnitTranTypeID NUMBER,
  pStockDate DATE
)
AS
BEGIN
/*  All Summary Report*/
  if pQueryType=0 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID, b.YARNBATCHNO,b.FABRICTYPEID,c.YarnCount,
    d.YarnType, e.UnitOfMeas, sum(b.Quantity*ATLGYS) MainStore,
    sum(b.Quantity*ATLGYF) SubStore, sum(b.Quantity*AYDLGYS) SubStock
    from T_Knitstock a, T_KnitStockItems b, T_YarnCount c, T_YarnType d,
    T_UnitOfMeas e, T_knitTransactionType f
    where a.StockID=b.StockID and
    b.yarnCountId=c.yarncountid and
    b.yarntypeid=d.yarntype and
    b.PunitOfMeasId=e.UnitOfmeasId and
    STOCKTRANSDATE <= pStockDate and
    a.KNTITRANSACTIONTYPEID = pKnitTranTypeID;

        /* ATLGYS*/
  elsif pQueryType=1 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,b.Shade,
    b.FABRICTYPEID,FABRICTYPE,b.OrderlineItem, b.YARNTYPEID,b.YARNCOUNTID,
    YarnCount,YarnType,b.PUnitOfMeasId,UnitOfMeas,b.DyedLotno,sum(Quantity*ATLGYS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,
    T_FabricType g,t_supplier h
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by
    b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.DyedLotno,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.FABRICTYPEID,FABRICTYPE,b.YARNBATCHNO,b.Shade,
    b.SUPPLIERID,h.SUPPLIERNAME
    having sum(Quantity*ATLGYS)>0;

/*  ATLGFS*/
elsif pQueryType=2 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,b.FABRICTYPEID,
    FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.DyedLotno,
    sum(Quantity*ATLGFS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,
    T_FabricType g,t_supplier h
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.FABRICTYPEID,FABRICTYPE,b.YARNBATCHNO,b.DyedLotno,
    b.SUPPLIERID,h.SUPPLIERNAME
    having sum(Quantity*ATLGFS)>0;

        /* ATLGYF */
elsif pQueryType=3 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,b.FABRICTYPEID,
    FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.DyedLotno,sum(Quantity*ATLGYF) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,
    T_FabricType g,t_supplier h
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.FABRICTYPEID,FABRICTYPE,b.YARNBATCHNO,b.DyedLotno,
    b.SUPPLIERID,h.SUPPLIERNAME
    having sum(Quantity*ATLGYF)>0;

                /* AYDLGYS */
elsif pQueryType=4 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,b.FABRICTYPEID,
    FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.DyedLotno,sum(Quantity*AYDLGYS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,
    T_FabricType g,t_supplier h
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.FABRICTYPEID,FABRICTYPE,b.DyedLotno,
    b.YARNBATCHNO,b.SUPPLIERID,h.SUPPLIERNAME
    having sum(Quantity*AYDLGYS)>0;

                /*ODSCONGYS*/
elsif pQueryType=5 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,b.FABRICTYPEID,
    FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.DyedLotno,
    sum(Quantity*ODSCONGYS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,
    T_FabricType g,t_supplier h
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,
    b.Shade, YarnType,b.PUnitOfMeasId,UnitOfMeas,b.DyedLotno,
    b.FABRICTYPEID,FABRICTYPE,b.YARNBATCHNO,b.SUPPLIERID,h.SUPPLIERNAME
    having sum(Quantity*ODSCONGYS)>0;

                /*KSCONGYS*/
elsif pQueryType= 6 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,b.FABRICTYPEID,
    FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.DyedLotno,sum(Quantity*KSCONGYS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,T_FabricType g,t_supplier h
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.SUPPLIERID=h.SUPPLIERID and
    b.YarnTypeId= e.YarnTypeId and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.FABRICTYPEID,b.DyedLotno,
    FABRICTYPE,b.YARNBATCHNO,b.SUPPLIERID,h.SUPPLIERNAME
    having sum(Quantity*KSCONGYS)>0;

/*ATLGFS For FabricDelivery*/
elsif pQueryType=7 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,b.FABRICTYPEID,
    FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.DyedLotno,
    sum(Quantity*ATLGFS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,
    T_FabricType g,t_supplier h
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.FABRICTYPEID,FABRICTYPE,b.YARNBATCHNO,b.DyedLotno,
    b.SUPPLIERID,h.SUPPLIERNAME
    having sum(Quantity*ATLGFS)>0;

	/*ATLGFDF* For Dyed Fabric*/
elsif pQueryType=8 then
    open data_cursor for

	select a.BATCHNO,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.FABRICTYPEID,'' as yarntype,'' as yarncount,'1' as yarntypeid,'1' as yarncountid,
    FABRICTYPE,b.OrderlineItem,b.Shade,b.PUnitOfMeasId,UnitOfMeas,b.YARNBATCHNO,b.DYEDLOTNO,b.SHADEGROUPID,h.SHADEGROUPNAME,sum(b.SQuantity) as Cursqty,sum(b.Quantity) Currentstock
    from T_DBatch a, T_DBatchItems b,t_workorder c,T_UnitOfMeas f,T_FabricType g,T_SHADEGROUP h
    where a.dbatchid=b.dbatchid and
    b.SHADEGROUPID=h.SHADEGROUPID and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.PUnitOfMeasID=f.UnitOfMeasID and b.orderno=pKnitTranTypeID  and
    b.orderno=c.orderno AND a.BATCHNO NOT IN (select a.BATCHNO from T_DBatch a, T_DBatchItems b,T_KnitStock x,
	T_knitStockItems y, T_KnitTransactionTYpe z
    	where a.dbatchid=b.dbatchid and
    	a.BATCHNO=y.DYEDLOTNO and
    	x.StockID=y.StockID and x.KNTITRANSACTIONTYPEID=z.KNTITRANSACTIONTYPEID AND
    	y.ORDERNO=b.ORDERNO and y.ORDERLINEITEM=b.ORDERLINEITEM and y.FABRICTYPEID=b.FABRICTYPEID)
    group by a.BATCHNO,b.ORDERNO,b.FABRICTYPEID,
    FABRICTYPE,b.OrderlineItem,b.Shade,b.PUnitOfMeasId,UnitOfMeas,b.YARNBATCHNO,b.DYEDLOTNO,b.SHADEGROUPID,h.SHADEGROUPNAME
    having sum(b.Quantity)>0
	UNION
	select yy.BATCHNO,yy.ORDERNO,yy.btype,yy.FABRICTYPEID,yy.yarntype,yy.yarncount,yy.yarntypeid,yy.yarncountid,
    yy.FABRICTYPE,yy.OrderlineItem,yy.Shade,yy.PUnitOfMeasId,yy.UnitOfMeas,yy.YARNBATCHNO,yy.DYEDLOTNO,yy.SHADEGROUPID,yy.SHADEGROUPNAME,(yy.Cursqty-xx.Cursqty) as Cursqty,(yy.Currentstock-xx.Currentstock) as Currentstock
    from (select a.BATCHNO,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.FABRICTYPEID,'' as yarntype,'' as yarncount,'1' as yarntypeid,'1' as yarncountid,
    FABRICTYPE,b.OrderlineItem,b.Shade,b.PUnitOfMeasId,UnitOfMeas,b.YARNBATCHNO,b.DYEDLOTNO,b.SHADEGROUPID,h.SHADEGROUPNAME,sum(b.Quantity) Currentstock,sum(b.SQuantity) Cursqty
    from T_DBatch a, T_DBatchItems b,t_workorder c,T_UnitOfMeas f,T_FabricType g,T_SHADEGROUP h
    where a.dbatchid=b.dbatchid and
    b.SHADEGROUPID=h.SHADEGROUPID and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    b.orderno=c.orderno
	GROUP BY a.BATCHNO,b.ORDERNO,b.FABRICTYPEID,
    FABRICTYPE,b.OrderlineItem,b.Shade,b.PUnitOfMeasId,UnitOfMeas,b.YARNBATCHNO,b.DYEDLOTNO,b.SHADEGROUPID,h.SHADEGROUPNAME) yy,
    (select y.DYEDLOTNO,sum(y.QUANTITY) Currentstock,sum(y.sQUANTITY) Cursqty
    from T_KnitStock x,T_knitStockItems y
    where x.StockID=y.StockID
	GROUP BY y.DYEDLOTNO) xx
	where yy.BATCHNO=xx.DYEDLOTNO  and yy.ORDERNO=pKnitTranTypeID /*pKnitTranTypeID USED 4 ORDERNO*/  and 
	(yy.Currentstock-xx.Currentstock)>0;
	/*ATLDFDS For Finished Fabric*/
elsif pQueryType=9 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,b.FABRICTYPEID,
    FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.DyedLotno,
    sum(Quantity*ATLDFDS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,
    T_FabricType g,t_supplier h
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.FABRICTYPEID,FABRICTYPE,b.YARNBATCHNO,b.DyedLotno,
    b.SUPPLIERID,h.SUPPLIERNAME
    having sum(Quantity*ATLDFDS)>0;

	/*ATLFFS For Fnished Fabric Delivery */
elsif pQueryType=10 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,b.FABRICTYPEID,
    FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.DyedLotno,
    sum(Quantity*ATLFFS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,
    T_FabricType g,t_supplier h
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.FABRICTYPEID,FABRICTYPE,b.YARNBATCHNO,b.DyedLotno,
    b.SUPPLIERID,h.SUPPLIERNAME
    having sum(Quantity*ATLFFS)>0;


	/*ATLGFDF* For Dyed Fabric return for ReDyeing*/
elsif pQueryType=11 then
    open data_cursor for

	select a.BATCHNO,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.FABRICTYPEID,'' as yarntype,'' as yarncount,'1' as yarntypeid,'1' as yarncountid,
    FABRICTYPE,b.OrderlineItem,b.Shade,b.PUnitOfMeasId,UnitOfMeas,b.YARNBATCHNO,b.DYEDLOTNO,b.SHADEGROUPID,h.SHADEGROUPNAME,sum(b.Quantity) Currentstock,SUM(b.squantity) as Cursqty
    from T_DBatch a, T_DBatchItems b,t_workorder c,T_UnitOfMeas f,T_FabricType g,T_SHADEGROUP h
    where a.dbatchid=b.dbatchid and
    b.SHADEGROUPID=h.SHADEGROUPID and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.PUnitOfMeasID=f.UnitOfMeasID and b.orderno=pKnitTranTypeID  and
    b.orderno=c.orderno AND a.BATCHNO NOT IN (select a.BATCHNO from T_DBatch a, T_DBatchItems b,T_KnitStock x,
	T_knitStockItems y, T_KnitTransactionTYpe z
    	where a.dbatchid=b.dbatchid and
    	a.BATCHNO=y.DYEDLOTNO and
    	x.StockID=y.StockID and x.KNTITRANSACTIONTYPEID=z.KNTITRANSACTIONTYPEID AND
    	y.ORDERNO=b.ORDERNO and y.ORDERLINEITEM=b.ORDERLINEITEM and y.FABRICTYPEID=b.FABRICTYPEID)
    group by a.BATCHNO,b.ORDERNO,b.FABRICTYPEID,
    FABRICTYPE,b.OrderlineItem,b.Shade,b.PUnitOfMeasId,UnitOfMeas,b.YARNBATCHNO,b.DYEDLOTNO,b.SHADEGROUPID,h.SHADEGROUPNAME
    having sum(b.Quantity)>0
	UNION
	select yy.BATCHNO,yy.ORDERNO,yy.btype,yy.FABRICTYPEID,yy.yarntype,yy.yarncount,yy.yarntypeid,yy.yarncountid,
    yy.FABRICTYPE,yy.OrderlineItem,yy.Shade,yy.PUnitOfMeasId,yy.UnitOfMeas,yy.YARNBATCHNO,yy.DYEDLOTNO,yy.SHADEGROUPID,yy.SHADEGROUPNAME,(yy.Currentstock-xx.Currentstock) as Currentstock,(YY.Cursqty-XX.Cursqty) AS Cursqty
    from (select a.BATCHNO,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.FABRICTYPEID,'' as yarntype,'' as yarncount,'1' as yarntypeid,'1' as yarncountid,
    FABRICTYPE,b.OrderlineItem,b.Shade,b.PUnitOfMeasId,UnitOfMeas,b.YARNBATCHNO,b.DYEDLOTNO,b.SHADEGROUPID,h.SHADEGROUPNAME,sum(b.Quantity) Currentstock,sum(b.SQuantity) Cursqty
    from T_DBatch a, T_DBatchItems b,t_workorder c,T_UnitOfMeas f,T_FabricType g,T_SHADEGROUP h
    where a.dbatchid=b.dbatchid and
    b.SHADEGROUPID=h.SHADEGROUPID and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    b.orderno=c.orderno
	GROUP BY a.BATCHNO,b.ORDERNO,b.FABRICTYPEID,
    FABRICTYPE,b.OrderlineItem,b.Shade,b.PUnitOfMeasId,UnitOfMeas,b.YARNBATCHNO,b.DYEDLOTNO,b.SHADEGROUPID,h.SHADEGROUPNAME) yy,
    (select y.DYEDLOTNO,sum(y.QUANTITY) Currentstock,sum(y.sQUANTITY) Cursqty
    from T_KnitStock x,T_knitStockItems y
    where x.StockID=y.StockID
	GROUP BY y.DYEDLOTNO) xx
	where yy.BATCHNO=xx.DYEDLOTNO  and yy.ORDERNO=pKnitTranTypeID /*pKnitTranTypeID USED 4 ORDERNO*/
      and (yy.Currentstock-xx.Currentstock)>0;
	  
	/*ATLFFS* For Finished Fabric Return to Dyeing Floor for ReDyeing*/
	elsif pQueryType=12 then
    open data_cursor for
    select b.ORDERNO,b.SUNITOFMEASID,i.unitofmeas as sunit,b.YARNBATCHNO,b.FABRICTYPEID,getfncWOBType(b.ORDERNO) as btype,
    g.FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,d.YarnCount,b.SHADEGROUPID,j.SHADEGROUPNAME, b.Shade,
    e.YarnType,b.PUnitOfMeasId,f.UnitOfMeas,'' as DyedLotno,h.FINISHEDGSM,h.WIDTH,h.KNITMCDIAGAUGE,'' as BATCHNO,
    sum(b.Quantity*ATLFFS) CurrentStock,sum(b.squantity*ATLFFS) as squantity,0 as Cursqty
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,
    T_FabricType g,T_ORDERITEMS h, T_UnitOfMeas i,T_SHADEGROUP j
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.OrderlineItem=h.OrderlineItem(+) and
    b.YarnCountId=d.YarnCountId(+) and
    b.YarnTypeId= e.YarnTypeId(+) and
    b.FABRICTYPEID=g.FABRICTYPEID(+) and
	b.SHADEGROUPID=j.SHADEGROUPID and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUNITOFMEASID=i.UnitOfMeasID(+) and b.ORDERNO=pKnitTranTypeID /*and pKnitTranTypeID IS USED HERE FOR ORDERNO */
  /*  b.DYEDLOTNO in (select c.BatchNo from T_Qc a, T_QcItems b,T_DBATCH c where a.QcId=b.QcId and b.DBatchId=c.DBatchId and a.QCTYPE=1) and 
    STOCKTRANSDATE <= pStockDate */
    group by b.ORDERNO,b.YARNBATCHNO,b.FABRICTYPEID,b.SUNITOFMEASID,i.unitofmeas,
    g.FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,d.YarnCount,b.SHADEGROUPID,j.SHADEGROUPNAME,b.Shade,
    e.YarnType,b.PUnitOfMeasId,f.UnitOfMeas,h.FINISHEDGSM,h.WIDTH,h.KNITMCDIAGAUGE
    having sum(b.Quantity*ATLFFS)>0  order by g.FABRICTYPE;  
  end if;
END GetBatchFabricStockPosition;

PROMPT CREATE OR REPLACE Procedure  128 :: GetFinishedFabricStockPosition
CREATE OR REPLACE Procedure GetFinishedFabricStockPosition(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pKnitTranTypeID NUMBER,
  pStockDate DATE
)
AS
BEGIN


/*  All Summary Report*/
  if pQueryType=0 then
    open data_cursor for
    select b.ORDERNO,b.SUPPLIERID, b.YARNBATCHNO,b.FABRICTYPEID,c.YarnCount,
    d.YarnType, e.UnitOfMeas, sum(b.Quantity*ATLGYS) MainStore,
    sum(b.Quantity*ATLGYF) SubStore, sum(b.Quantity*AYDLGYS) SubStock
    from T_Knitstock a, T_KnitStockItems b, T_YarnCount c, T_YarnType d,
    T_UnitOfMeas e, T_knitTransactionType f
    where a.StockID=b.StockID and
    b.yarnCountId=c.yarncountid and
    b.yarntypeid=d.yarntype and
    b.PunitOfMeasId=e.UnitOfmeasId and
    STOCKTRANSDATE <= pStockDate and
    a.KNTITRANSACTIONTYPEID = pKnitTranTypeID;

        /* ATLGYS*/
  elsif pQueryType=1 then
    open data_cursor for
    select b.ORDERNO,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,b.Shade,
    b.FABRICTYPEID,FABRICTYPE,b.OrderlineItem, b.YARNTYPEID,b.YARNCOUNTID,
    YarnCount,YarnType,b.PUnitOfMeasId,UnitOfMeas,b.DyedLotno,sum(Quantity*ATLGYS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,
    T_FabricType g,t_supplier h
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by
    b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.DyedLotno,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.FABRICTYPEID,FABRICTYPE,b.YARNBATCHNO,b.Shade,
    b.SUPPLIERID,h.SUPPLIERNAME
    having sum(Quantity*ATLGYS)>0;

/*  ATLGFS*/
elsif pQueryType=2 then
    open data_cursor for
    select b.ORDERNO,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,b.FABRICTYPEID,
    FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.DyedLotno,
    sum(Quantity*ATLGFS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,
    T_FabricType g,t_supplier h
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.FABRICTYPEID,FABRICTYPE,b.YARNBATCHNO,b.DyedLotno,
    b.SUPPLIERID,h.SUPPLIERNAME
    having sum(Quantity*ATLGFS)>0;


        /* ATLGYF */
elsif pQueryType=3 then
    open data_cursor for
    select b.ORDERNO,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,b.FABRICTYPEID,
    FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.DyedLotno,sum(Quantity*ATLGYF) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,
    T_FabricType g,t_supplier h
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.FABRICTYPEID,FABRICTYPE,b.YARNBATCHNO,b.DyedLotno,
    b.SUPPLIERID,h.SUPPLIERNAME
    having sum(Quantity*ATLGYF)>0;


                /* AYDLGYS */
elsif pQueryType=4 then
    open data_cursor for
    select b.ORDERNO,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,b.FABRICTYPEID,
    FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.DyedLotno,sum(Quantity*AYDLGYS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,
    T_FabricType g,t_supplier h
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.FABRICTYPEID,FABRICTYPE,b.DyedLotno,
    b.YARNBATCHNO,b.SUPPLIERID,h.SUPPLIERNAME
    having sum(Quantity*AYDLGYS)>0;

                /*ODSCONGYS*/
elsif pQueryType=5 then
    open data_cursor for
    select b.ORDERNO,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,b.FABRICTYPEID,
    FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.DyedLotno,
    sum(Quantity*ODSCONGYS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,
    T_FabricType g,t_supplier h
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,
    b.Shade, YarnType,b.PUnitOfMeasId,UnitOfMeas,b.DyedLotno,
    b.FABRICTYPEID,FABRICTYPE,b.YARNBATCHNO,b.SUPPLIERID,h.SUPPLIERNAME
    having sum(Quantity*ODSCONGYS)>0;


                /*KSCONGYS*/
elsif pQueryType= 6 then
    open data_cursor for
    select b.ORDERNO,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,b.FABRICTYPEID,
    FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.DyedLotno,sum(Quantity*KSCONGYS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,T_FabricType g,t_supplier h
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.SUPPLIERID=h.SUPPLIERID and
    b.YarnTypeId= e.YarnTypeId and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.FABRICTYPEID,b.DyedLotno,
    FABRICTYPE,b.YARNBATCHNO,b.SUPPLIERID,h.SUPPLIERNAME
    having sum(Quantity*KSCONGYS)>0;

/*ATLGFS For FabricDelivery*/
elsif pQueryType=7 then
    open data_cursor for
    select b.ORDERNO,b.YARNBATCHNO,b.FABRICTYPEID,
    FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.DyedLotno,
    sum(Quantity*ATLGFS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e,T_UnitOfMeas f,
    T_FabricType g
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.FABRICTYPEID,FABRICTYPE,b.YARNBATCHNO,b.DyedLotno
    having sum(Quantity*ATLGFS)>0;

	/*ATLGFDF* For Dyed Fabric*/
elsif pQueryType=8 then
    open data_cursor for
    select b.ORDERNO,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,b.FABRICTYPEID,
    FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.DyedLotno,
    sum(Quantity*ATLGFDF) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,
    T_FabricType g,t_supplier h
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.FABRICTYPEID,FABRICTYPE,b.YARNBATCHNO,b.DyedLotno,
    b.SUPPLIERID,h.SUPPLIERNAME
    having sum(Quantity*ATLGFDF)>0;

	/*ATLDFDS For Finished Fabric*/
elsif pQueryType=9 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.YARNBATCHNO,b.FABRICTYPEID,
    FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, b.Shade,
    YarnType,b.PUnitOfMeasId,f.UnitOfMeas,b.DyedLotno,b.SHADEGROUPID,h.SHADEGROUPNAME,i.unitofmeas as sunit,b.sunitofmeasid as sunitid,
    sum(Quantity*ATLDFDS) CurrentStock,NVL(sum(SQuantity*ATLDFDS),0) as Squantity
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,
    T_FabricType g,T_SHADEGROUP h,T_UnitOfMeas i
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.SHADEGROUPID=h.SHADEGROUPID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUnitOfMeasID=i.UnitOfMeasID(+)
    and b.ORDERNO=pKnitTranTypeID and  
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.YARNBATCHNO,b.FABRICTYPEID,
    FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, b.Shade,
    YarnType,b.PUnitOfMeasId,f.UnitOfMeas,b.DyedLotno,b.SHADEGROUPID,h.SHADEGROUPNAME,i.unitofmeas,b.sunitofmeasid
    having sum(Quantity*ATLDFDS)>0 ORDER BY btype,b.DyedLotno;

	/*ATLFFS For Fnished Fabric Delivery */
elsif pQueryType=10 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.YARNBATCHNO,b.FABRICTYPEID,
    FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.DyedLotno,
    sum(Quantity*ATLFFS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,
    T_FabricType g
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.FABRICTYPEID,FABRICTYPE,b.YARNBATCHNO,b.DyedLotno
    having sum(Quantity*ATLFFS)>0;
	/*ATLFFS For Fnished Fabric Delivery */
elsif pQueryType=11 then
    open data_cursor for
    select b.ORDERNO,b.SUNITOFMEASID,i.unitofmeas as sunit,b.YARNBATCHNO,b.FABRICTYPEID,getfncWOBType(b.ORDERNO) as btype,
    g.FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,d.YarnCount,b.SHADEGROUPID, b.Shade,    
    e.YarnType,b.PUnitOfMeasId,f.UnitOfMeas,b.DyedLotno,h.FINISHEDGSM,h.WIDTH,h.KNITMCDIAGAUGE,
    sum(b.Quantity*ATLFFS) CurrentStock,sum(b.squantity*ATLFFS) as squantity
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,
    T_FabricType g,T_ORDERITEMS h, T_UnitOfMeas i
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.OrderlineItem=h.OrderlineItem(+) and
    b.YarnCountId=d.YarnCountId(+) and
    b.YarnTypeId= e.YarnTypeId(+) and
    b.FABRICTYPEID=g.FABRICTYPEID(+) and 
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUNITOFMEASID=i.UnitOfMeasID(+) and b.ORDERNO=pKnitTranTypeID and   /*pKnitTranTypeID IS USED HERE FOR ORDERNO */
  /*  b.DYEDLOTNO in (select c.BatchNo from T_Qc a, T_QcItems b,T_DBATCH c where a.QcId=b.QcId and b.DBatchId=c.DBatchId and a.QCTYPE=1) and */
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.YARNBATCHNO,b.FABRICTYPEID,b.SUNITOFMEASID,i.unitofmeas,
    g.FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,d.YarnCount,b.SHADEGROUPID, b.Shade,    
    e.YarnType,b.PUnitOfMeasId,f.UnitOfMeas,b.DyedLotno,h.FINISHEDGSM,h.WIDTH,h.KNITMCDIAGAUGE
    having sum(b.Quantity*ATLFFS)>0  order by b.DyedLotno;
    
	/*FSCON For Finished Fabric*/
elsif pQueryType=12 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.YARNBATCHNO,b.FABRICTYPEID,
    FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, b.Shade,
    YarnType,b.PUnitOfMeasId,f.UnitOfMeas,b.DyedLotno,b.SHADEGROUPID,h.SHADEGROUPNAME,NVL(sum(SQuantity*FSCON),0)  as Squantity,i.UnitOfMeas AS Sunit,DECODE(b.sunitofmeasid,'','3',b.sunitofmeasid) AS Sunitid, 
    sum(Quantity*FSCON) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,
    T_FabricType g,T_SHADEGROUP h, T_UnitOfMeas i
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.SHADEGROUPID=h.SHADEGROUPID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUNITOFMEASID=i.UnitOfMeasID(+) and b.ORDERNO=pKnitTranTypeID and  /*pKnitTranTypeID IS USED HERE FOR ORDERNO */
  /*  b.DYEDLOTNO in (select c.BatchNo from T_Qc a, T_QcItems b,T_DBATCH c where a.QcId=b.QcId and b.DBatchId=c.DBatchId and a.QCTYPE=2)  and */
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.YARNBATCHNO,b.FABRICTYPEID,
    FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, b.Shade,
    YarnType,b.PUnitOfMeasId,f.UnitOfMeas,b.DyedLotno,b.SHADEGROUPID,h.SHADEGROUPNAME,b.sunitofmeasid,i.unitofmeas
    having sum(Quantity*FSCON)>0 ORDER BY btype,b.DyedLotno;

	/*Delivery Finished Fabric Return From Clients*/
elsif pQueryType=13 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.YARNBATCHNO,b.FABRICTYPEID,
    FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,  b.Shade,
    YarnType,b.PUnitOfMeasId,f.UnitOfMeas,b.DyedLotno,b.SHADEGROUPID,h.SHADEGROUPNAME,
   0 AS FINISHEDGSM,0 AS WIDTH,NVL(SUM(Squantity*(-ATLFFS)),0) AS Squantity,i.unitofmeasid AS Sunitofmeasid,i.unitofmeas AS Sunit,
    sum(Quantity*(-ATLFFS)) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,
    T_FabricType g,T_SHADEGROUP h, T_UnitOfMeas i
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and c.KNTITRANSACTIONTYPEID IN (21,33,49) and
    b.SHADEGROUPID=h.SHADEGROUPID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.PUnitOfMeasID=f.UnitOfMeasID(+)  and
    b.SUNITOFMEASID=i.UnitOfMeasID(+) and b.ORDERNO=pKnitTranTypeID and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.YARNBATCHNO,b.FABRICTYPEID,
    FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,  b.Shade,
    YarnType,b.PUnitOfMeasId,F.UnitOfMeas,i.unitofmeasid,i.unitofmeas,b.DyedLotno,b.SHADEGROUPID,h.SHADEGROUPNAME
     having sum(Quantity*(-ATLFFS))>0  ORDER BY btype,b.DyedLotno;

   /*ATLGFS For Gray Fabric Delivery */
elsif pQueryType=14 then
    open data_cursor for
    select b.ORDERNO,b.SUNITOFMEASID,i.unitofmeas as sunit,b.YARNBATCHNO,b.FABRICTYPEID,getfncWOBType(b.ORDERNO) as btype,
    g.FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,d.YarnCount,b.SHADEGROUPID, b.Shade,    
    e.YarnType,b.PUnitOfMeasId,f.UnitOfMeas,b.DyedLotno,h.FINISHEDGSM,h.WIDTH,h.KNITMCDIAGAUGE,
    sum(b.Quantity*ATLGFS) CurrentStock,sum(b.squantity*ATLGFS) as squantity
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,
    T_FabricType g,T_ORDERITEMS h, T_UnitOfMeas i
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.OrderlineItem=h.OrderlineItem and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.FABRICTYPEID=g.FABRICTYPEID and 
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUNITOFMEASID=i.UnitOfMeasID(+) and b.ORDERNO=pKnitTranTypeID and   /*pKnitTranTypeID IS USED HERE FOR ORDERNO */
  /*  b.DYEDLOTNO in (select c.BatchNo from T_Qc a, T_QcItems b,T_DBATCH c where a.QcId=b.QcId and b.DBatchId=c.DBatchId and a.QCTYPE=1) and */
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.YARNBATCHNO,b.FABRICTYPEID,b.SUNITOFMEASID,i.unitofmeas,
    g.FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,d.YarnCount,b.SHADEGROUPID, b.Shade,    
    e.YarnType,b.PUnitOfMeasId,f.UnitOfMeas,b.DyedLotno,h.FINISHEDGSM,h.WIDTH,h.KNITMCDIAGAUGE
    having sum(b.Quantity*ATLGFS)>0  order by b.DyedLotno; 
   
/*ATLDFDS For Dyed Fabric Delivery */
elsif pQueryType=15 then
    open data_cursor for
    select b.ORDERNO,b.SUNITOFMEASID,i.unitofmeas as sunit,b.YARNBATCHNO,b.FABRICTYPEID,getfncWOBType(b.ORDERNO) as btype,
    g.FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,d.YarnCount,b.SHADEGROUPID, b.Shade,    
    e.YarnType,b.PUnitOfMeasId,f.UnitOfMeas,b.DyedLotno,h.FINISHEDGSM,h.WIDTH,h.KNITMCDIAGAUGE,
    sum(b.Quantity*ATLDFDS) CurrentStock,sum(b.squantity*ATLDFDS) as squantity
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,
    T_FabricType g,T_ORDERITEMS h, T_UnitOfMeas i
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.OrderlineItem=h.OrderlineItem and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.FABRICTYPEID=g.FABRICTYPEID and 
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUNITOFMEASID=i.UnitOfMeasID(+) and b.ORDERNO=pKnitTranTypeID and   /*pKnitTranTypeID IS USED HERE FOR ORDERNO */
  /*  b.DYEDLOTNO in (select c.BatchNo from T_Qc a, T_QcItems b,T_DBATCH c where a.QcId=b.QcId and b.DBatchId=c.DBatchId and a.QCTYPE=1) and */
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.YARNBATCHNO,b.FABRICTYPEID,b.SUNITOFMEASID,i.unitofmeas,
    g.FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,d.YarnCount,b.SHADEGROUPID, b.Shade,    
    e.YarnType,b.PUnitOfMeasId,f.UnitOfMeas,b.DyedLotno,h.FINISHEDGSM,h.WIDTH,h.KNITMCDIAGAUGE
    having sum(b.Quantity*ATLDFDS)>0  order by b.DyedLotno;
    end if;
END GetFinishedFabricStockPosition;
/






PROMPT CREATE OR REPLACE Procedure  129 :: GetDyedYarnLRequisitionInfo
CREATE OR REPLACE Procedure GetDyedYarnLRequisitionInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  many_cursor IN OUT pReturnData.c_Records,
  pKnitStockID number
)
AS
BEGIN

    open one_cursor for
    select StockId, YarnRequisitionTypeId, ReferenceNo, ReferenceDate, StockTransNO, StockTransDATE,
    supplierID,SupplierInvoiceNo,SupplierInvoiceDate,Remarks, SubConId,execute
    from T_YarnRequisition
    where StockId=pKnitStockID;

    open many_cursor for
    select PID,a.ORDERNO,GetfncWOBType(OrderNo) as btype,a.STOCKID, KNTISTOCKITEMSL,YarnCountId, 
	YarnTypeId,FabricTypeId,OrderlineItem,Quantity, Squantity,PunitOfmeasId,SUNITOFMEASID,YarnBatchNo,
	shadegroupid,Shade,REMARKS,CurrentStock,BUDGETQTY,REMAINQTY,supplierID,DYEDLOTNO
    from T_YarnRequisitionItems a
    where STOCKID=pKnitStockID
union all
    select PID,a.ORDERNO,GetfncWOBType(OrderNo) as btype,a.STOCKID, KNTISTOCKITEMSL,YarnCountId, 
	YarnTypeId,FabricTypeId,OrderlineItem,Quantity, Squantity,PunitOfmeasId,SUNITOFMEASID,YarnBatchNo,
	shadegroupid,Shade,REMARKS,CurrentStock,BUDGETQTY,REMAINQTY,supplierID,DYEDLOTNO
    from T_YarnRequisitionItems a
    where STOCKID=(SELECT STOCKID FROM T_YARNREQUISITION WHERE PARENTSTOCKID=pKnitStockID)
    order by KNTISTOCKITEMSL asc;
END GetDyedYarnLRequisitionInfo;
/


PROMPT CREATE OR REPLACE Procedure  130 :: GetYarnReqTransTypeLookUP
CREATE OR REPLACE Procedure GetYarnReqTransTypeLookUP
(
  data_cursor IN OUT pReturnData.c_Records
)

AS

BEGIN

  OPEN data_cursor for
  select YarnRequisitionTypeId,YarnRequisitionType
  from T_YarnRequisitionType
  order by YarnRequisitionTypeId;
END GetYarnReqTransTypeLookUP;
/


PROMPT CREATE OR REPLACE Procedure  131 :: getTreeYarnReqStockList
CREATE OR REPLACE Procedure getTreeYarnReqStockList (
  io_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pStockType IN NUMBER,
  pTransNo IN VARCHAR2 DEFAULT NULL,
  sDate IN date,
  eDate IN date
)
AS
BEGIN

  if pQueryType=0 then
    OPEN io_cursor FOR
    select StockId, StockTransNo from T_YarnRequisition
    where YarnRequisitionTypeId=pStockType and
    StockTransDate>=SDate and StockTransDate<=EDate
    order by StockTransNo desc;

  elsif pQueryType=1 then
    OPEN io_cursor FOR
    select StockId, StockTransNo, StockTransDate from T_YarnRequisition
    where YarnRequisitionTypeId=pStockType and
    StockTransDate>=SDate and StockTransDate<=EDate
    order by StockTransDate desc, StockTransNo desc;

 elsif pQueryType=2 then
    OPEN io_cursor FOR
    select b.orderno, Getfncwobtype(b.orderno) as dorderno 
    from T_YarnRequisition a,T_YarnRequisitionItems b
    where a.stockid=b.stockid and YarnRequisitionTypeId=pStockType and
    StockTransDate>=SDate and StockTransDate<=EDate
    Group by b.orderno
    order by dorderno desc;

  elsif pQueryType=9999 then
    OPEN io_cursor FOR
    select StockId from T_YarnRequisition
    where YarnRequisitionTypeId=pStockType and
    StockTransDate>=SDate and StockTransDate<=EDate and
    Upper(StockTransNo) Like pTransNo;
  end if;

END getTreeYarnReqStockList;
/

PROMPT CREATE OR REPLACE Procedure  132 :: GetYarnRequisition
create or Replace Procedure GetYarnRequisition(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pKnitTranTypeID NUMBER,
  pStockDate DATE
)
AS
BEGIN
/*  All Summary Report*/
if pQueryType=0 then
    open data_cursor for
    select c.YarnCount,b.SUPPLIERID,g.SUPPLIERNAME, d.YarnType, e.UnitOfMeas,
    sum(b.Quantity*ATLGYS) MainStore, sum(b.Quantity*ATLGYF) SubStore, sum(b.Quantity*AYDLGYS) SubStock
    from T_Knitstock a, T_KnitStockItems b, T_YarnCount c, T_YarnType d, T_UnitOfMeas e, T_knitTransactionType f,
    t_supplier g
    where a.StockID=b.StockID and
    b.SUPPLIERID=g.SUPPLIERID(+) and
    b.yarnCountId=c.yarncountid and
    b.yarntypeid=d.yarntype and
    b.PunitOfMeasId=e.UnitOfmeasId and
    STOCKTRANSDATE <= pStockDate and
    a.KNTITRANSACTIONTYPEID = pKnitTranTypeID;

	/*Gray Yarn Issue For Knitting (Floor) from Gray Yarn Requisition */
elsif pQueryType=1 then
    open data_cursor for
    select a.STOCKTRANSNO,b.YARNBATCHNO,b.squantity as sqty,b.SUNITOFMEASID as sunitid,b.SUPPLIERID,g.SUPPLIERNAME,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,
    YarnType,b.PUnitOfMeasId,j.UnitOfMeas as sunit,f.UnitOfMeas,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,'' AS ORDERLINEITEM,h.SHADEGROUPID,
    h.SHADEGROUPNAME,'' AS SHADE,b.FABRICTYPEID,i.FABRICTYPE,SUM(Quantity) CurrentStock,b.yarnfor,

    	NVL(( select sum(Quantity*ATLGYS)
    	from T_KnitStock x, T_knitStockItems y, T_KnitTransactionTYpe z
    	where x.StockID=y.StockID and x.KNTITRANSACTIONTYPEID=z.KNTITRANSACTIONTYPEID and
    	y.YARNTYPEID=b.YARNTYPEID and Y.YARNCOUNTID=b.YARNCOUNTID AND y.YARNBATCHNO=b.YARNBATCHNO and
		y.SUPPLIERID=b.SUPPLIERID and y.PUnitOfMeasId=b.PUnitOfMeasId
    	group by y.YARNBATCHNO,y.YARNTYPEID,y.YARNCOUNTID,y.SUPPLIERID,y.PUnitOfMeasId,y.yarnfor
    	having sum(Quantity*ATLGYS)>0),0) as mainstock,

		(SUM(Quantity)-
		NVL(( select sum(decode(x.KNTITRANSACTIONTYPEID,3,Quantity,x.KNTITRANSACTIONTYPEID,9,-Quantity,0)) from  T_KnitStock x,T_knitStockItems y
    	where x.StockID=y.StockID and y.REQUISITIONNO=a.STOCKTRANSNO and
    	y.YARNTYPEID=b.YARNTYPEID and Y.YARNCOUNTID=b.YARNCOUNTID AND
		y.YARNBATCHNO=b.YARNBATCHNO and x.KNTITRANSACTIONTYPEID in (3,9)
    	group by y.YARNBATCHNO,y.YARNTYPEID,y.YARNCOUNTID),0)) as REMAINQTY

    from T_YarnRequisition a, T_YarnRequisitionItems b, T_YARNREQUISITIONTYPE c, T_YarnCount d,
    T_YarnType e, T_UnitOfMeas f,t_supplier g,T_ShadeGroup h,T_fabricType i,T_UnitOfMeas j
    where a.StockID=b.StockID and
    b.SUPPLIERID=g.SUPPLIERID(+) and
    b.SHADEGROUPID=h.SHADEGROUPID and
    b.FABRICTYPEID=i.FABRICTYPEID(+) and
    a.YARNREQUISITIONTYPEID=c.YARNREQUISITIONTYPEID and
    b.YarnCountId=d.YarnCountId(+) and
    b.YarnTypeId= e.YarnTypeId(+) and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUNITOFMEASID=j.UnitOfMeasID(+) and
    a.YARNREQUISITIONTYPEID=1 and
    a.execute=0 and
    STOCKTRANSDATE <= pStockDate
    group by a.STOCKTRANSNO,b.YARNBATCHNO,b.SUPPLIERID,g.SUPPLIERNAME,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.yarnfor,
    YarnType,b.PUnitOfMeasId,f.UnitOfMeas,j.UnitOfMeas,b.ORDERNO,h.SHADEGROUPID,h.SHADEGROUPNAME,b.FABRICTYPEID,i.FABRICTYPE,b.squantity,b.SUNITOFMEASID
	having nvl((SUM(Quantity)-
		NVL(( select sum(decode(x.KNTITRANSACTIONTYPEID,3,Quantity,x.KNTITRANSACTIONTYPEID,9,-Quantity,0)) from  T_KnitStock x,T_knitStockItems y
    	where x.StockID=y.StockID and y.REQUISITIONNO=a.STOCKTRANSNO and
    	y.YARNTYPEID=b.YARNTYPEID and Y.YARNCOUNTID=b.YARNCOUNTID AND
		y.YARNBATCHNO=b.YARNBATCHNO and x.KNTITRANSACTIONTYPEID in (3,9)
    	group by y.YARNBATCHNO,y.YARNTYPEID,y.YARNCOUNTID),0)),0)>0
    ORDER BY btype,a.STOCKTRANSNO DESC;
/*Gray and  Dyed Yarn Issue For Knitting (Floor) from Gray and  Dyed Yarn Requisition */
elsif pQueryType=2 then
	open data_cursor for
	select a.STOCKTRANSNO,b.squantity as sqty,b.SUNITOFMEASID as sunitid,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
    b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,YarnType,b.PUnitOfMeasId,k.UnitOfMeas as sunit,f.UnitOfMeas,
    b.DyedLotno,b.SHADE,b.fabrictypeid,j.fabrictype,b.shadegroupid,i.shadegroupname,'N' AS Lycra,b.yarnfor,
		sum(Quantity) CurrentStock,
    	NVL(( select sum(Quantity*ATLDYS)
    	from T_KnitStock x, T_knitStockItems y, T_KnitTransactionTYpe z
    	where x.StockID=y.StockID and x.KNTITRANSACTIONTYPEID=z.KNTITRANSACTIONTYPEID and /*y.FABRICTYPEID=b.fabrictypeid and*/
    	y.ORDERNO=b.ORDERNO and y.YARNTYPEID=b.YARNTYPEID AND Y.YARNCOUNTID=b.YARNCOUNTID and y.YARNBATCHNO=b.YARNBATCHNO and
		y.SHADE=B.SHADE and y.SUPPLIERID=b.SUPPLIERID and y.DyedLotno=b.DyedLotno
    	group by y.DyedLotno,y.YARNBATCHNO,y.YARNTYPEID,y.YARNCOUNTID,Y.SUPPLIERID,y.SHADE
    	having sum(Quantity*ATLDYS)>0),0) as mainstock
    from T_YarnRequisition a, T_YarnRequisitionItems b, T_YARNREQUISITIONTYPE c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,
    t_supplier h,t_shadegroup i,t_fabrictype j,T_UnitOfMeas k
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID(+) and
    b.shadegroupid=i.shadegroupid and
    b.fabrictypeid=j.fabrictypeid and
    a.YARNREQUISITIONTYPEID=c.YARNREQUISITIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUNITOFMEASID=k.UnitOfMeasID(+) and
    a.YARNREQUISITIONTYPEID=2 and
    a.execute=0 and
    STOCKTRANSDATE <= pStockDate
    group by a.STOCKTRANSNO,b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,b.yarnfor,
    YarnType,b.PUnitOfMeasId,b.YARNBATCHNO,b.SHADE,b.SUPPLIERID,h.SUPPLIERNAME,b.DyedLotno,b.fabrictypeid,j.fabrictype,
	b.shadegroupid,i.shadegroupname,f.UnitOfMeas,k.UnitOfMeas,b.squantity,b.SUNITOFMEASID
    having NVL(( select sum(Quantity*ATLDYS)
    	from T_KnitStock x, T_knitStockItems y, T_KnitTransactionTYpe z
    	where x.StockID=y.StockID and x.KNTITRANSACTIONTYPEID=z.KNTITRANSACTIONTYPEID and /*y.FABRICTYPEID=b.fabrictypeid and*/
    	y.ORDERNO=b.ORDERNO and y.YARNTYPEID=b.YARNTYPEID AND Y.YARNCOUNTID=b.YARNCOUNTID and y.YARNBATCHNO=b.YARNBATCHNO and
		y.SHADE=B.SHADE and y.SUPPLIERID=b.SUPPLIERID
    	group by y.YARNBATCHNO,y.YARNTYPEID,y.YARNCOUNTID,Y.SUPPLIERID,y.SHADE
    	having sum(Quantity*ATLDYS)>0),0)>0
UNION ALL
    select a.STOCKTRANSNO,b.squantity as sqty,b.SUNITOFMEASID as sunitid,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,g.SUPPLIERNAME,b.YARNBATCHNO,
    '' AS ORDERLINEITEM,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,YarnType,b.PUnitOfMeasId,k.UnitOfMeas as sunit,f.UnitOfMeas,
    '' AS DyedLotno,b.SHADE,b.FABRICTYPEID,i.FABRICTYPE,h.SHADEGROUPID,h.SHADEGROUPNAME,'Y' AS Lycra,b.yarnfor,
    SUM(Quantity) CurrentStock,
    	NVL(( select sum(Quantity*ATLGYS)
    	from T_KnitStock x, T_knitStockItems y, T_KnitTransactionTYpe z
    	where x.StockID=y.StockID and x.KNTITRANSACTIONTYPEID=z.KNTITRANSACTIONTYPEID and
    	y.YARNTYPEID=b.YARNTYPEID AND Y.YARNCOUNTID=b.YARNCOUNTID and y.YARNBATCHNO=b.YARNBATCHNO
    	group by y.YARNBATCHNO,y.YARNTYPEID,y.YARNCOUNTID
    	having sum(Quantity*ATLGYS)>0),0) as mainstock
    from T_YarnRequisition a, T_YarnRequisitionItems b, T_YARNREQUISITIONTYPE c, T_YarnCount d,
    T_YarnType e, T_UnitOfMeas f,t_supplier g,T_ShadeGroup h,T_fabricType i,T_UnitOfMeas k
    where a.StockID=b.StockID and
    b.SUPPLIERID=g.SUPPLIERID(+) and
    b.SHADEGROUPID=h.SHADEGROUPID and
    b.FABRICTYPEID=i.FABRICTYPEID(+) and
    a.YARNREQUISITIONTYPEID=c.YARNREQUISITIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUNITOFMEASID=k.UnitOfMeasID(+) and
    a.execute=0 and
    a.YARNREQUISITIONTYPEID=1 and a.PARENTSTOCKID<>a.STOCKID and
    STOCKTRANSDATE <= pStockDate
    group by a.STOCKTRANSNO,b.ORDERNO,b.SUPPLIERID,g.SUPPLIERNAME,b.YARNBATCHNO,b.YARNTYPEID,b.YARNCOUNTID,b.yarnfor,
    YarnCount,YarnType,b.PUnitOfMeasId,b.SHADE,b.FABRICTYPEID,i.FABRICTYPE,h.SHADEGROUPID,h.SHADEGROUPNAME,f.UnitOfMeas,k.UnitOfMeas,b.squantity,b.SUNITOFMEASID
    having SUM(Quantity)>0 ORDER BY btype DESC;
        /* Fabric Requisition */
elsif pQueryType=3 then
    open data_cursor for
    select a.STOCKTRANSNO,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.YARNBATCHNO,b.FABRICTYPEID,
    FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.SUNITOFMEASID as sunitid,i.unitofmeas as sunit,
    YarnType,b.PUnitOfMeasId,f.UnitOfMeas,b.DyedLotno,b.SHADE,b.shadegroupid,h.shadegroupname,b.yarnfor,
		DECODE(b.DyedLotno,NULL,nvl((select sum(Quantity*ATLGFS)
 		from T_KnitStock x, T_knitStockItems y, T_KnitTransactionTYpe z
 		where x.StockID=y.StockID and x.KNTITRANSACTIONTYPEID=z.KNTITRANSACTIONTYPEID and
 		y.orderno=b.ORDERNO and y.shadegroupid=b.shadegroupid and y.yarnbatchno=b.YARNBATCHNO and
		y.FABRICTYPEID=b.FABRICTYPEID
 		group by y.ORDERNO,y.YARNTYPEID,y.YARNCOUNTID,y.FABRICTYPEID,y.YARNBATCHNO,y.shadegroupid
 		having sum(Quantity*ATLGFS)>0),0),nvl((select sum(Quantity*ATLGFS)
 		from T_KnitStock x, T_knitStockItems y, T_KnitTransactionTYpe z
 		where x.StockID=y.StockID and x.KNTITRANSACTIONTYPEID=z.KNTITRANSACTIONTYPEID and
 		y.orderno=b.ORDERNO and y.shadegroupid=b.shadegroupid and y.yarnbatchno=b.YARNBATCHNO and
		y.FABRICTYPEID=b.FABRICTYPEID and y.DyedLotno=b.DyedLotno and y.SHADE=b.SHADE
 		group by y.ORDERNO,y.YARNTYPEID,y.YARNCOUNTID,y.FABRICTYPEID,y.YARNBATCHNO,y.shadegroupid
 		having sum(Quantity*ATLGFS)>0),0)) as mainstock,

	(SUM(Quantity)-NVL(( select sum(Quantity) from  T_KnitStock x,T_knitStockItems y
    	where x.StockID=y.StockID and y.REQUISITIONNO=a.STOCKTRANSNO and
    	y.YARNTYPEID=b.YARNTYPEID and Y.YARNCOUNTID=b.YARNCOUNTID AND
		y.YARNBATCHNO=b.YARNBATCHNO and x.KNTITRANSACTIONTYPEID=18
    	group by y.YARNBATCHNO,y.YARNTYPEID,y.YARNCOUNTID),0)) as REMAINQTY,

		DECODE(b.DyedLotno,NULL,nvl((select sum(SQuantity*ATLGFS)
 		from T_KnitStock x, T_knitStockItems y, T_KnitTransactionTYpe z
 		where x.StockID=y.StockID and x.KNTITRANSACTIONTYPEID=z.KNTITRANSACTIONTYPEID and
 		y.orderno=b.ORDERNO and y.shadegroupid=b.shadegroupid and y.yarnbatchno=b.YARNBATCHNO and
		y.FABRICTYPEID=b.FABRICTYPEID
 		group by y.ORDERNO,y.YARNTYPEID,y.YARNCOUNTID,y.FABRICTYPEID,y.YARNBATCHNO,y.shadegroupid
 		having sum(SQuantity*ATLGFS)>0),0),nvl((select sum(SQuantity*ATLGFS)
 		from T_KnitStock x, T_knitStockItems y, T_KnitTransactionTYpe z
 		where x.StockID=y.StockID and x.KNTITRANSACTIONTYPEID=z.KNTITRANSACTIONTYPEID and
 		y.orderno=b.ORDERNO and y.shadegroupid=b.shadegroupid and y.yarnbatchno=b.YARNBATCHNO and
		y.FABRICTYPEID=b.FABRICTYPEID and y.DyedLotno=b.DyedLotno and y.SHADE=b.SHADE
 		group by y.ORDERNO,y.YARNTYPEID,y.YARNCOUNTID,y.FABRICTYPEID,y.YARNBATCHNO,y.shadegroupid
 		having sum(SQuantity*ATLGFS)>0),0)) as mainsqty,
    sum(Quantity) CurrentStock,sum(SQuantity) sqty
    from T_YarnRequisition a, T_YarnRequisitionItems b, T_YARNREQUISITIONTYPE c,
    T_YarnCount d, T_YarnType e,T_UnitOfMeas f,
    T_FabricType g,T_shadegroup h,T_UnitOfMeas i
    where a.StockID=b.StockID and
    a.YARNREQUISITIONTYPEID=c.YARNREQUISITIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.shadegroupid=h.shadegroupid and
    b.YarnTypeId= e.YarnTypeId and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    b.SUnitOfMeasID=i.UnitOfMeasID and
    a.YARNREQUISITIONTYPEID=3 and
    a.execute=0 and
    STOCKTRANSDATE <= pStockDate and b.ORDERNO=pKnitTranTypeID  /* pKnitTranTypeID=orderno just var name */
    group by a.STOCKTRANSNO,b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.yarnfor,
    YarnType,b.PUnitOfMeasId,f.UnitOfMeas,b.FABRICTYPEID,FABRICTYPE,b.YARNBATCHNO,b.DyedLotno,b.SHADE,b.shadegroupid,h.shadegroupname,b.SUNITOFMEASID,i.unitofmeas
    having (SUM(Quantity)-NVL(( select sum(Quantity) from  T_KnitStock x,T_knitStockItems y
    	where x.StockID=y.StockID and y.REQUISITIONNO=a.STOCKTRANSNO and
    	y.YARNTYPEID=b.YARNTYPEID and Y.YARNCOUNTID=b.YARNCOUNTID AND
		y.YARNBATCHNO=b.YARNBATCHNO and x.KNTITRANSACTIONTYPEID=18
    	group by y.YARNBATCHNO,y.YARNTYPEID,y.YARNCOUNTID),0))>0
		ORDER BY btype DESC;
        /* AYDLGYS */
elsif pQueryType=4 then
    open data_cursor for
    select b.YARNBATCHNO,b.yarnfor,b.SUPPLIERID,g.SUPPLIERNAME,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, YarnType,b.PUnitOfMeasId,UnitOfMeas,
    sum(Quantity*AYDLGYS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier g
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
        b.SUPPLIERID=g.SUPPLIERID(+) and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.YARNBATCHNO,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, YarnType,b.PUnitOfMeasId,UnitOfMeas,b.yarnfor,
    b.SUPPLIERID,g.SUPPLIERNAME
    having sum(Quantity*AYDLGYS)>0;
    /*ODSCONGYS*/
elsif pQueryType=5 then
    open data_cursor for
    select b.YARNBATCHNO,b.yarnfor,b.SUPPLIERID,g.SUPPLIERNAME,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, YarnType,b.PUnitOfMeasId,UnitOfMeas,
    sum(Quantity*ODSCONGYS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier g
    where a.StockID=b.StockID and
        b.SUPPLIERID=g.SUPPLIERID(+) and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.YARNBATCHNO,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, YarnType,b.PUnitOfMeasId,UnitOfMeas,b.yarnfor,b.SUPPLIERID,g.SUPPLIERNAME
    having sum(Quantity*ODSCONGYS)>0;
    /*KSCONGYS*/
elsif pQueryType= 6 then
	open data_cursor for
    select b.YARNBATCHNO,b.yarnfor,b.SUPPLIERID,g.SUPPLIERNAME,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, YarnType,b.PUnitOfMeasId,UnitOfMeas,
    sum(Quantity*KSCONGYS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier g
    where a.StockID=b.StockID and
    b.SUPPLIERID=g.SUPPLIERID(+) and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.YARNBATCHNO,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, YarnType,b.PUnitOfMeasId,UnitOfMeas,b.yarnfor,b.SUPPLIERID,g.SUPPLIERNAME
    having sum(Quantity*KSCONGYS)>0;
	/*Gray Yarn Issue For Knitting (SCON) from Gray Yarn Requisition */
elsif pQueryType= 7 then
	open data_cursor for
    select a.STOCKTRANSNO,b.squantity as sqty,b.SUNITOFMEASID as sunitid,b.YARNBATCHNO,b.SUPPLIERID,g.SUPPLIERNAME,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,
    YarnType,b.PUnitOfMeasId,j.UnitOfMeas as sunit,f.UnitOfMeas,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,'' AS ORDERLINEITEM,h.SHADEGROUPID,
    h.SHADEGROUPNAME,'' AS SHADE,b.FABRICTYPEID,i.FABRICTYPE,SUM(Quantity) CurrentStock,b.yarnfor,
    	NVL(( select sum(Quantity*ATLGYS)
    	from T_KnitStock x, T_knitStockItems y, T_KnitTransactionTYpe z,  T_YarnType xx
    	where x.StockID=y.StockID and x.KNTITRANSACTIONTYPEID=z.KNTITRANSACTIONTYPEID and
    	y.YarnTypeId= xx.YarnTypeId  and y.YARNTYPEID=b.YARNTYPEID and
		y.YARNBATCHNO=b.YARNBATCHNO AND Y.YARNCOUNTID=b.YARNCOUNTID
    	group by y.YARNBATCHNO,y.YARNTYPEID,y.YARNCOUNTID,YarnType
    	having sum(Quantity*ATLGYS)>0),0) as mainstock,
		(SUM(Quantity)-NVL(( select sum(decode(x.KNTITRANSACTIONTYPEID,4,Quantity,x.KNTITRANSACTIONTYPEID,10,-Quantity,0)) from  T_KnitStock x,T_knitStockItems y
    	where x.StockID=y.StockID and y.REQUISITIONNO=a.STOCKTRANSNO and
    	y.YARNTYPEID=b.YARNTYPEID and Y.YARNCOUNTID=b.YARNCOUNTID AND
		y.YARNBATCHNO=b.YARNBATCHNO and x.KNTITRANSACTIONTYPEID in (4,10)
    	group by y.YARNBATCHNO,y.YARNTYPEID,y.YARNCOUNTID),0)) as REMAINQTY
    from T_YarnRequisition a, T_YarnRequisitionItems b, T_YARNREQUISITIONTYPE c, T_YarnCount d,
    T_YarnType e, T_UnitOfMeas f,t_supplier g,T_ShadeGroup h,T_fabricType i,T_UnitOfMeas j
    where a.StockID=b.StockID and
    b.SUPPLIERID=g.SUPPLIERID(+) and
    b.SHADEGROUPID=h.SHADEGROUPID and
    b.FABRICTYPEID=i.FABRICTYPEID and
    a.YARNREQUISITIONTYPEID=c.YARNREQUISITIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUNITOFMEASID=j.UnitOfMeasID(+) and
    a.execute=0 and
    a.YARNREQUISITIONTYPEID=4 and
    STOCKTRANSDATE <= pStockDate
    group by a.STOCKTRANSNO,b.YARNBATCHNO,b.SUPPLIERID,g.SUPPLIERNAME,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.yarnfor,
    YarnType,b.PUnitOfMeasId,b.ORDERNO,h.SHADEGROUPID,h.SHADEGROUPNAME,b.FABRICTYPEID,i.FABRICTYPE,f.UnitOfMeas,j.UnitOfMeas,b.squantity,b.SUNITOFMEASID
    having NVL((SUM(Quantity)-NVL(( select sum(decode(x.KNTITRANSACTIONTYPEID,4,Quantity,x.KNTITRANSACTIONTYPEID,10,-Quantity,0)) from  T_KnitStock x,T_knitStockItems y
    	where x.StockID=y.StockID and y.REQUISITIONNO=a.STOCKTRANSNO and
    	y.YARNTYPEID=b.YARNTYPEID and Y.YARNCOUNTID=b.YARNCOUNTID AND
		y.YARNBATCHNO=b.YARNBATCHNO and x.KNTITRANSACTIONTYPEID in (4,10)
    	group by y.YARNBATCHNO,y.YARNTYPEID,y.YARNCOUNTID),0)),0)>0;
    /*Yarn Issue For Dyeing (AYDL) from Yarn Requisition */
elsif pQueryType= 8 then
	open data_cursor for
	select a.STOCKTRANSNO,b.squantity as sqty,b.SUNITOFMEASID as sunitid,b.YARNBATCHNO,b.SUPPLIERID,g.SUPPLIERNAME,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,
    YarnType,b.PUnitOfMeasId,j.UnitOfMeas as sunit,f.UnitOfMeas,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,'' AS ORDERLINEITEM,
    h.SHADEGROUPID,h.SHADEGROUPNAME,b.SHADE,b.FABRICTYPEID,i.FABRICTYPE,SUM(Quantity) CurrentStock,b.yarnfor,

		NVL(( select sum(Quantity*ATLGYS)
    	from T_KnitStock x, T_knitStockItems y, T_KnitTransactionTYpe z
    	where x.StockID=y.StockID and x.KNTITRANSACTIONTYPEID=z.KNTITRANSACTIONTYPEID and
    	y.YARNTYPEID=b.YARNTYPEID and Y.YARNCOUNTID=b.YARNCOUNTID AND y.YARNBATCHNO=b.YARNBATCHNO and
		y.SUPPLIERID=b.SUPPLIERID and y.PUnitOfMeasId=b.PUnitOfMeasId
    	group by y.YARNBATCHNO,y.YARNTYPEID,y.YARNCOUNTID,y.SUPPLIERID,y.PUnitOfMeasId,y.yarnfor
    	having sum(Quantity*ATLGYS)>0),0) as mainstock,

	(SUM(Quantity)-NVL(( select sum(decode(x.KNTITRANSACTIONTYPEID,5,Quantity,x.KNTITRANSACTIONTYPEID,11,-Quantity,0)) from  T_KnitStock x,T_knitStockItems y
    	where x.StockID=y.StockID and y.REQUISITIONNO=a.STOCKTRANSNO and
    	y.YARNTYPEID=b.YARNTYPEID and Y.YARNCOUNTID=b.YARNCOUNTID AND
		y.YARNBATCHNO=b.YARNBATCHNO and x.KNTITRANSACTIONTYPEID in (5,11)
    	group by y.YARNBATCHNO,y.YARNTYPEID,y.YARNCOUNTID),0)) as REMAINQTY
    from T_YarnRequisition a, T_YarnRequisitionItems b, T_YARNREQUISITIONTYPE c, T_YarnCount d,
    T_YarnType e, T_UnitOfMeas f,t_supplier g,T_ShadeGroup h,T_fabricType i,T_UnitOfMeas j
    where a.StockID=b.StockID and
    b.SUPPLIERID=g.SUPPLIERID(+) and
	b.FABRICTYPEID=i.FABRICTYPEID(+) and
    b.SHADEGROUPID=h.SHADEGROUPID and
    a.YARNREQUISITIONTYPEID=c.YARNREQUISITIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUNITOFMEASID=j.UnitOfMeasID(+) and
    a.execute=0 and
    a.YARNREQUISITIONTYPEID=5 and
    STOCKTRANSDATE <= pStockDate
    group by a.STOCKTRANSNO,b.YARNBATCHNO,b.yarnfor,b.SUPPLIERID,g.SUPPLIERNAME,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,YarnType,b.PUnitOfMeasId,
	b.ORDERNO,b.SHADE,h.SHADEGROUPID,h.SHADEGROUPNAME,f.UnitOfMeas,j.UnitOfMeas,b.squantity,b.SUNITOFMEASID,b.FABRICTYPEID,i.FABRICTYPE
    having NVL((SUM(Quantity)-NVL(( select sum(decode(x.KNTITRANSACTIONTYPEID,5,Quantity,x.KNTITRANSACTIONTYPEID,11,-Quantity,0)) from  T_KnitStock x,T_knitStockItems y
    	where x.StockID=y.StockID and y.REQUISITIONNO=a.STOCKTRANSNO and
    	y.YARNTYPEID=b.YARNTYPEID and Y.YARNCOUNTID=b.YARNCOUNTID AND
		y.YARNBATCHNO=b.YARNBATCHNO and x.KNTITRANSACTIONTYPEID in (5,11)
    	group by y.YARNBATCHNO,y.YARNTYPEID,y.YARNCOUNTID),0)),0)>0 ;
	/*Yarn Issue For Dyeing (SCON) from Yarn Requisition */
elsif pQueryType= 9 then
	open data_cursor for
    select a.STOCKTRANSNO,b.squantity as sqty,b.SUNITOFMEASID as sunitid,b.YARNBATCHNO,b.SUPPLIERID,g.SUPPLIERNAME,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,
    YarnType,b.PUnitOfMeasId,j.UnitOfMeas as sunit,f.UnitOfMeas,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,'' as ORDERLINEITEM,
    h.SHADEGROUPID,h.SHADEGROUPNAME,b.SHADE,b.FABRICTYPEID,i.FABRICTYPE,SUM(Quantity) CurrentStock,b.yarnfor,
    	NVL(( select sum(Quantity*ATLGYS)
    	from T_KnitStock x, T_knitStockItems y, T_KnitTransactionTYpe z, T_YarnType xx
    	where x.StockID=y.StockID and x.KNTITRANSACTIONTYPEID=z.KNTITRANSACTIONTYPEID and
    	y.YarnTypeId= xx.YarnTypeId  and y.YARNTYPEID=b.YARNTYPEID and
		y.YARNBATCHNO=b.YARNBATCHNO AND Y.YARNCOUNTID=b.YARNCOUNTID
    	group by y.YARNBATCHNO,y.YARNTYPEID,y.YARNCOUNTID,YarnType
    	having sum(Quantity*ATLGYS)>0),0) as mainstock,
	(SUM(Quantity)-NVL(( select sum(decode(x.KNTITRANSACTIONTYPEID,12,Quantity,x.KNTITRANSACTIONTYPEID,14,-Quantity,0)) from  T_KnitStock x,T_knitStockItems y
    	where x.StockID=y.StockID and y.REQUISITIONNO=a.STOCKTRANSNO and
    	y.YARNTYPEID=b.YARNTYPEID and Y.YARNCOUNTID=b.YARNCOUNTID AND
		y.YARNBATCHNO=b.YARNBATCHNO and x.KNTITRANSACTIONTYPEID in (12,14)
    	group by y.YARNBATCHNO,y.YARNTYPEID,y.YARNCOUNTID),0)) as REMAINQTY
    from T_YarnRequisition a, T_YarnRequisitionItems b, T_YARNREQUISITIONTYPE c, T_YarnCount d,
    T_YarnType e, T_UnitOfMeas f,t_supplier g,T_ShadeGroup h,T_fabricType i,T_UnitOfMeas j
    where a.StockID=b.StockID and
    b.SUPPLIERID=g.SUPPLIERID(+) and
	b.FABRICTYPEID=i.FABRICTYPEID(+) and
    b.SHADEGROUPID=h.SHADEGROUPID and
    a.YARNREQUISITIONTYPEID=c.YARNREQUISITIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUNITOFMEASID=j.UnitOfMeasID(+) and
    a.execute=0 and
    a.YARNREQUISITIONTYPEID=6 and
    STOCKTRANSDATE <= pStockDate
    group by a.STOCKTRANSNO,b.YARNBATCHNO,b.yarnfor,b.SUPPLIERID,g.SUPPLIERNAME,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,YarnType,b.PUnitOfMeasId,
	b.ORDERNO,b.ORDERLINEITEM,b.SHADE,h.SHADEGROUPID,h.SHADEGROUPNAME,f.UnitOfMeas,j.UnitOfMeas,b.squantity,b.SUNITOFMEASID,b.FABRICTYPEID,i.FABRICTYPE
    having NVL((SUM(Quantity)-NVL(( select sum(decode(x.KNTITRANSACTIONTYPEID,12,Quantity,x.KNTITRANSACTIONTYPEID,14,-Quantity,0)) from  T_KnitStock x,T_knitStockItems y
    	where x.StockID=y.StockID and y.REQUISITIONNO=a.STOCKTRANSNO and
    	y.YARNTYPEID=b.YARNTYPEID and Y.YARNCOUNTID=b.YARNCOUNTID AND
		y.YARNBATCHNO=b.YARNBATCHNO and x.KNTITRANSACTIONTYPEID in (12,14)
    	group by y.YARNBATCHNO,y.YARNTYPEID,y.YARNCOUNTID),0)),0)>0;

	/*Gray and Dyed Yarn Issue For Knitting (SCON) from Gray and  Dyed Yarn Requisition */
elsif pQueryType=10 then
    open data_cursor for
    select a.STOCKTRANSNO,b.squantity as sqty,b.SUNITOFMEASID as sunitid,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
    b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,YarnType,b.PUnitOfMeasId,k.UnitOfMeas as sunit,f.UnitOfMeas,
    b.DyedLotno,b.Shade,b.fabrictypeid,j.fabrictype,b.shadegroupid,i.shadegroupname,'N' AS Lycra,b.yarnfor,
    sum(Quantity) CurrentStock,
	NVL(( select sum(Quantity*ATLDYS)
    	from T_KnitStock x, T_knitStockItems y, T_KnitTransactionTYpe z,T_YarnType xx
    	where x.StockID=y.StockID and
    	x.KNTITRANSACTIONTYPEID=z.KNTITRANSACTIONTYPEID and b.ORDERNO=y.ORDERNO and
    	y.YarnTypeId= xx.YarnTypeId  and y.YARNTYPEID=b.YARNTYPEID and
		y.YARNBATCHNO=b.YARNBATCHNO AND  Y.YARNCOUNTID=b.YARNCOUNTID
    	group by y.ORDERNO,y.YARNBATCHNO,y.YARNTYPEID,y.YARNCOUNTID,YarnType
    	having sum(Quantity*ATLDYS)>0),0) as mainstock
    from T_YarnRequisition a, T_YarnRequisitionItems b, T_YARNREQUISITIONTYPE c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier h,t_shadegroup i,t_fabrictype j,T_UnitOfMeas k
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID(+) and
    a.YARNREQUISITIONTYPEID=c.YARNREQUISITIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUNITOFMEASID=k.UnitOfMeasID(+) and
    a.YARNREQUISITIONTYPEID=7 and
    b.shadegroupid=i.shadegroupid and
    b.fabrictypeid=j.fabrictypeid and
    a.execute=0 and
    STOCKTRANSDATE <= pStockDate
    group by a.STOCKTRANSNO,b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
    YarnType,b.PUnitOfMeasId,b.YARNBATCHNO,b.yarnfor,
    b.SUPPLIERID,h.SUPPLIERNAME,b.DyedLotno,b.fabrictypeid,j.fabrictype,b.shadegroupid,i.shadegroupname,f.UnitOfMeas,k.UnitOfMeas,b.squantity,b.SUNITOFMEASID
    having sum(Quantity)>0
  UNION ALL
    select a.STOCKTRANSNO,b.squantity as sqty,b.SUNITOFMEASID as sunitid,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,g.SUPPLIERNAME,b.YARNBATCHNO,
    '' AS ORDERLINEITEM,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,YarnType,b.PUnitOfMeasId,k.UnitOfMeas as sunit,f.UnitOfMeas,
    '' AS DyedLotno,b.SHADE,b.FABRICTYPEID,i.FABRICTYPE,h.SHADEGROUPID,h.SHADEGROUPNAME,'Y' AS Lycra,b.yarnfor,
    SUM(Quantity) CurrentStock,
	NVL(( select sum(Quantity*ATLGYS)
    	from T_KnitStock x, T_knitStockItems y, T_KnitTransactionTYpe z,T_YarnType xx
    	where x.StockID=y.StockID and
    	x.KNTITRANSACTIONTYPEID=z.KNTITRANSACTIONTYPEID and
    	y.YarnTypeId= xx.YarnTypeId  and y.YARNTYPEID=b.YARNTYPEID and
        y.YARNBATCHNO=b.YARNBATCHNO AND  Y.YARNCOUNTID=b.YARNCOUNTID
    	group by y.YARNBATCHNO,y.YARNTYPEID,y.YARNCOUNTID,YarnType
    	having sum(Quantity*ATLGYS)>0),0) as mainstock
    from T_YarnRequisition a, T_YarnRequisitionItems b, T_YARNREQUISITIONTYPE c, T_YarnCount d,
    T_YarnType e, T_UnitOfMeas f,t_supplier g,T_ShadeGroup h,T_fabricType i,T_UnitOfMeas k
    where a.StockID=b.StockID and
    b.SUPPLIERID=g.SUPPLIERID(+) and
    b.SHADEGROUPID=h.SHADEGROUPID and
    b.FABRICTYPEID=i.FABRICTYPEID and
    a.YARNREQUISITIONTYPEID=c.YARNREQUISITIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUNITOFMEASID=k.UnitOfMeasID(+) and
    a.execute=0 and
    a.YARNREQUISITIONTYPEID=4 and a.PARENTSTOCKID<>a.STOCKID and
    STOCKTRANSDATE <= pStockDate
    group by a.STOCKTRANSNO,b.ORDERNO,b.SUPPLIERID,g.SUPPLIERNAME,b.YARNBATCHNO,b.YARNTYPEID,b.YARNCOUNTID,b.yarnfor,
    YarnCount,YarnType,b.PUnitOfMeasId,b.SHADE,b.FABRICTYPEID,i.FABRICTYPE,h.SHADEGROUPID,h.SHADEGROUPNAME,f.UnitOfMeas,k.UnitOfMeas,b.squantity,b.SUNITOFMEASID
    having SUM(Quantity)>0 ORDER BY btype DESC;
  end if;
END GetYarnRequisition;
/

PROMPT CREATE OR REPLACE Procedure  133 :: GetknitFabricStockInfo
CREATE OR REPLACE Procedure GetknitFabricStockInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  many_cursor IN OUT pReturnData.c_Records,
  pKnitStockID number
)
AS
BEGIN
    open one_cursor for
    select StockId, KNTITRANSACTIONTYPEID, ReferenceNo, ReferenceDate,CurrencyId,ConRate,StockTransNO, StockTransDATE,
    supplierID,SupplierInvoiceNo,SupplierInvoiceDate,Remarks, SubConId, ClientID,orderno
    from T_KnitStock
    where StockId=pKnitStockID;
	
    open many_cursor for
    select PID,c.clientname,a.ORDERNO,getfncWOBType(a.ORDERNO) as btype,a.STOCKID, KNTISTOCKITEMSL,
    YarnCountId, YarnTypeId,FabricTypeId,OrderlineItem,UnitPrice,Quantity,Squantity,PunitOfmeasId,
	SUNITOFMEASID,YarnBatchNo,a.shadegroupid,a.REQQUANTITY,Shade,REMARKS,CurrentStock,supplierID,DYEDLOTNO,
	SubConId,KMACHINEPIDREF,a.REMAINQTY,a.yarnfor,TO_CHAR(a.KSTARTDATETIME,'dd/MM/yyyy hh:MI AM') AS KSTARTDATETIME,
	TO_CHAR(a.KENDDATETIME,'dd/MM/yyyy hh:MI AM') AS KENDDATETIME,
	getfncDateTimeDistance(a.KSTARTDATETIME,a.KENDDATETIME) AS KDURATION,SHIFTID
    from T_KnitStockItems a,t_workorder b,t_client c
    where b.clientid=c.clientid and
    b.orderno=a.orderno and
    STOCKID=pKnitStockID
    order by KNTISTOCKITEMSL asc;
END GetknitFabricStockInfo;
/

PROMPT CREATE OR REPLACE Procedure  134 :: GETGYTransInsert
CREATE OR REPLACE Procedure GETGYTransInsert (
  pStrSql1 IN VARCHAR2,
  pStrSql2 IN VARCHAR2,
  pIdentityName IN VARCHAR2,
  pIdentityFld1 IN VARCHAR2,
  pIdentityFld2 IN VARCHAR2,
  pCurIdentityVal OUT NUMBER,
  pRecsAffected out NUMBER
)
AS
  tmpSql VARCHAR2(1000);
  restSql VARCHAR2(1000);
  insertSql VARCHAR2(1000);
  parentIdentityVal  NUMBER;
  tmpPos NUMBER;
  faults EXCEPTION;
BEGIN

  execute immediate 'select ' || pIdentityName || '.NEXTVAL from sys.dual'
  into pCurIdentityVal;

  parentIdentityVal:=pCurIdentityVal;

  tmpPos := instr(pStrSql1, '(', 1, 1);
  tmpSql := substr(pStrSql1, 1, tmpPos);
  restSql := substr(pStrSql1, tmpPos+1);
  insertSql := tmpSql || pIdentityFld1 || ','|| pIdentityFld2 || ',';

  tmpPos := instr(restSql, ' values (', 1, 1);
  tmpSql := substr(restSql, 1, tmpPos);
  restSql := substr(restSql, tmpPos+9);

  insertSql := insertSql || tmpSql || ' values (' ||
          TO_CHAR(pCurIdentityVal) || ',' ||TO_CHAR(pCurIdentityVal) || ',' || restSql;

  execute immediate insertSql;

 pRecsAffected := SQL%ROWCOUNT;

/*========================Copy Section(102)======================*/
  execute immediate 'select ' || pIdentityName || '.NEXTVAL from sys.dual'
  into pCurIdentityVal;
  
  tmpPos := instr(pStrSql2, '(', 1, 1);
  tmpSql := substr(pStrSql2, 1, tmpPos);
  restSql := substr(pStrSql2, tmpPos+1);
  insertSql := tmpSql || pIdentityFld1 || ','|| pIdentityFld2 || ',';

  tmpPos := instr(restSql, ' values (', 1, 1);
  tmpSql := substr(restSql, 1, tmpPos);
  restSql := substr(restSql, tmpPos+9);

  insertSql := insertSql || tmpSql || ' values (' ||
          TO_CHAR(pCurIdentityVal) || ',' ||TO_CHAR(parentIdentityVal) || ',' || restSql;

  execute immediate insertSql;

  pRecsAffected := SQL%ROWCOUNT+pRecsAffected;
/*===============================================================*/
	IF (pRecsAffected=2)
	THEN
        COMMIT;
	ELSE
		RAISE faults;
	END IF;

EXCEPTION
	WHEN faults THEN ROLLBACK;

END GETGYTransInsert;
/

 
PROMPT CREATE OR REPLACE Procedure  135 :: GETGYTransItemsInsert
CREATE OR REPLACE Procedure GETGYTransItemsInsert (
  pStockId IN NUMBER,
  pStrSql1 IN VARCHAR2,
  pStrSql2 IN VARCHAR2,
  pIdentityName IN VARCHAR2,
  pIdentityFld1 IN VARCHAR2,
  pIdentityFld2 IN VARCHAR2,
  pCurIdentityVal OUT NUMBER,
  pRecsAffected out NUMBER
)
AS
  tmpSql VARCHAR2(1000);
  restSql VARCHAR2(1000);
  insertSql VARCHAR2(1000);
  parentIdentityVal  NUMBER;
  tmpPos NUMBER;
  faults EXCEPTION;
BEGIN

/*========================Main Section(101)======================*/
  execute immediate 'select ' || pIdentityName || '.NEXTVAL from sys.dual'
  into pCurIdentityVal;


  parentIdentityVal:=pCurIdentityVal;

  tmpPos := instr(pStrSql1, '(', 1, 1);
  tmpSql := substr(pStrSql1, 1, tmpPos);
  restSql := substr(pStrSql1, tmpPos+1);
  insertSql := tmpSql || pIdentityFld1 || ','|| pIdentityFld2 || ',';

  tmpPos := instr(restSql, ' values (', 1, 1);
  tmpSql := substr(restSql, 1, tmpPos);
  restSql := substr(restSql, tmpPos+9);

  insertSql := insertSql || tmpSql || ' values (' ||
          TO_CHAR(pCurIdentityVal) || ',' ||TO_CHAR(pStockId) || ',' || restSql;

  execute immediate insertSql;
 pRecsAffected := SQL%ROWCOUNT;
/*========================Copy Section(102)======================*/
  execute immediate 'select ' || pIdentityName || '.NEXTVAL from sys.dual'
  into pCurIdentityVal;


  tmpPos := instr(pStrSql2, '(', 1, 1);
  tmpSql := substr(pStrSql2, 1, tmpPos);
  restSql := substr(pStrSql2, tmpPos+1);
  insertSql := tmpSql || pIdentityFld1 || ','|| pIdentityFld2 || ',';

  tmpPos := instr(restSql, ' values (', 1, 1);
  tmpSql := substr(restSql, 1, tmpPos);
  restSql := substr(restSql, tmpPos+9);

  insertSql := insertSql || tmpSql || ' values (' ||
          TO_CHAR(pCurIdentityVal) || ',' ||TO_CHAR(pStockId) || ',' || restSql;

  execute immediate insertSql;
  pRecsAffected := SQL%ROWCOUNT+pRecsAffected;
 /*===============================================================*/
	IF (pRecsAffected=2)
	THEN
        COMMIT;
	ELSE
		RAISE faults;
	END IF;


EXCEPTION
	WHEN faults THEN ROLLBACK;

END GETGYTransItemsInsert;
/


PROMPT CREATE OR REPLACE Procedure  136 :: GETCopyWOLineItems
CREATE OR REPLACE Procedure GETCopyWOLineItems(
  pOrderNo IN NUMBER,
  pOrderLineItemID IN VARCHAR2,
  pRecsAffected out NUMBER
)
AS
  insertTmpSql VARCHAR2(1000);
  tmpOrderItem NUMBER;
  tmpSlNoSql NUMBER;
  tmpPID NUMBER;
  tmpMaxPID NUMBER;
BEGIN
   SELECT MAX(to_number(ORDERLINEITEM))+1 into tmpOrderItem from T_OrderItems;
   SELECT MAX(WOITEMSL)+1 into tmpSlNoSql from T_OrderItems where OrderNo=pOrderNo;

   insert into T_OrderItems (ORDERLINEITEM,WOITEMSL,BASICTYPEID,ORDERNO,KNITMCDIAGAUGE,COMBINATIONID,FABRICTYPEID,FINISHEDGSM,WIDTH,SHRINKAGE,
        SHADE,RATE,FEEDERCOUNT,GRAYGSM,PLY,UNITOFMEASID,QUANTITY,FINISHEDQUALITY,OTHERQUALITY,REMARKS,COLLARCUFFID,shadegroupid,BREFPID,SUNIT)
     select tmpOrderItem,tmpSlNoSql,BASICTYPEID,ORDERNO,KNITMCDIAGAUGE,COMBINATIONID,FABRICTYPEID,FINISHEDGSM,WIDTH,SHRINKAGE,
        SHADE,RATE,FEEDERCOUNT,GRAYGSM,PLY,UNITOFMEASID,0,0,0,REMARKS,COLLARCUFFID,shadegroupid,BREFPID,SUNIT  from T_OrderItems where ORDERLINEITEM=pOrderLineItemID; 
      
	SELECT MAX(to_number(PID))+1 into tmpMaxPID from T_YARNDESC;
       for  rec in (SELECT PID from T_YARNDESC WHERE ORDERLINEITEM=pOrderLineItemID)
        LOOP
                insert into T_YARNDESC(PID,ORDERLINEITEM,YARNCOUNTID,YARNTYPEID,STITCHLENGTH,YARNPERCENT)
		SELECT tmpMaxPID,tmpOrderItem,YARNCOUNTID,YARNTYPEID,STITCHLENGTH,YARNPERCENT FROM T_YARNDESC
		WHERE ORDERLINEITEM=pOrderLineItemID and PID=rec.PID;
                SELECT MAX(to_number(PID))+1 into tmpMaxPID from T_YARNDESC;
        END loop;

   pRecsAffected := SQL%ROWCOUNT;
END GETCopyWOLineItems;
/



PROMPT CREATE OR REPLACE Procedure  137 :: GETCopyGWOLineItems
CREATE OR REPLACE Procedure GETCopyGWOLineItems(
  pGOrderNo IN NUMBER,
  pGOrderLineItemID IN VARCHAR2,
  pRecsAffected out NUMBER
)
AS
  insertTmpSql VARCHAR2(1000);
  tmpOrderItem NUMBER;
  tmpSlNoSql NUMBER;
BEGIN

   SELECT MAX(to_number(ORDERLINEITEM))+1 into tmpOrderItem from T_GORDERITEMS;
   SELECT MAX(WOITEMSL)+1 into tmpSlNoSql from T_GORDERITEMS where GORDERNO=pGOrderNo;

   insert into T_GORDERITEMS (ORDERLINEITEM,WOITEMSL,GORDERNO,STYLE,COUNTRYID,SHADE,PRICE,QUANTITY,UNITOFMEASID,DELIVERYDATE,REMARKS)
     select tmpOrderItem,tmpSlNoSql,GORDERNO,STYLE,COUNTRYID,SHADE,0,0,UNITOFMEASID,DELIVERYDATE,REMARKS
	  from T_GORDERITEMS where ORDERLINEITEM=pGOrderLineItemID; 
 
   pRecsAffected := SQL%ROWCOUNT;


END GETCopyGWOLineItems;
/






PROMPT CREATE OR REPLACE Procedure  138 :: GetAuxStockTypeRequisitionList
CREATE OR REPLACE Procedure GetAuxStockTypeRequisitionList
(
  data_cursor IN OUT pReturnData.c_Records
)

AS
BEGIN

    OPEN data_cursor for
    Select AuxStockTypeID, AuxStockType from T_AuxStockTypeRequisition order by AuxStockTypeID;
END;
/



PROMPT CREATE OR REPLACE Procedure  139 :: GETAuxStockRequisitionInfo
CREATE OR REPLACE Procedure GETAuxStockRequisitionInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  many_cursor IN OUT pReturnData.c_Records,
  pAuxStockID number
)
AS
BEGIN
    open one_cursor for
    select AuxStockTypeID, AuxStockId, STOCKINVOICENO, STOCKDATE, PURCHASEORDERNO,
    PURCHASEORDERDATE,SUPPLIERID,DELIVERYNOTE,DELIVERYNOTEDATE,SUBCONID,executed
    from t_auxStockRequisition
    where AuxStockId=pAuxStockID;
    open many_cursor for
    select AUXSTOCKID,AUXSTOCKSL,PID,t_AuxStockItemRequisition.AUXTYPEID,DYEBASEID,
t_AuxStockItemRequisition.AUXID,STOCKREQQTY,STOCKQTY,STOREFOLIO,REMARKS,UNITPRICE,SUPPLIERID,CURRENTSTOCK
    from T_AuxStockItemRequisition, T_Auxiliaries
    where T_AuxStockItemRequisition.AuxId=T_Auxiliaries.AuxId and
    AUXSTOCKID=pAuxStockID order by AUXSTOCKSL;
END GETAuxStockRequisitionInfo;
/


PROMPT CREATE OR REPLACE Procedure  140 :: getTreeAuxStockRequisitionList
CREATE OR REPLACE Procedure getTreeAuxStockRequisitionList (
  io_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pStockType IN NUMBER,
  pInvoiceNo IN VARCHAR2 DEFAULT NULL,
  sDate IN date,
  eDate IN date
)
AS
BEGIN

  if pQueryType=0 then
    OPEN io_cursor FOR
    select AuxStockId, StockInvoiceNo from T_AuxStockRequisition
    where AuxStockTypeId=pStockType and
    StockDate>=SDate and StockDate<=EDate
    order by StockInvoiceNo desc;

  elsif pQueryType=1 then
    OPEN io_cursor FOR
    select AuxStockId, StockInvoiceNo, StockDate from T_AuxStockRequisition
    where AuxStockTypeId=pStockType and
    StockDate>=SDate and StockDate<=EDate
    order by StockDate desc, StockInvoiceNo desc;
  elsif pQueryType=2 then
    OPEN io_cursor FOR
    select d.AuxTypeId, c.DyeBaseId, d.AuxId, b.AuxType, a.DyeBase, c.AuxName
    from T_DyeBase a, T_AuxType b, T_Auxiliaries c, T_AuxStockItemRequisition d, T_AuxStockRequisition e
    where c.AuxId = d.AuxId and
    c.AuxTypeId = d.AuxTypeId and
    b.AuxTypeId = c.AuxTypeId and
    e.AuxStockId = d.AuxStockId and
    a.DyeBaseId(+) = c.DyeBaseId and
    StockDate>=SDate and StockDate<=EDate
    group by d.AuxTypeId, c.DyeBaseId, d.AuxId, b.AuxType, a.DyeBase, c.AuxName
    order by b.AuxType, a.DyeBase, c.AuxName;
  elsif pQueryType=9999 then
    OPEN io_cursor FOR
    select AuxStockId from T_AuxStockRequisition
    where AuxStockTypeId=pStockType and
    StockDate>=SDate and StockDate<=EDate and
    Upper(StockInvoiceNo) Like pInvoiceNo;
  end if;

END getTreeAuxStockRequisitionList;
/

PROMPT CREATE OR REPLACE Procedure  141 :: GetAuxStockPosition
CREATE OR REPLACE Procedure GetAuxStockPosition(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pAuxTypeID NUMBER,
  pStockDate DATE
)
AS
BEGIN
/*  For Report */
  if pQueryType=0 then
    open data_cursor for
    select b.AuxID,g.AuxTypeID,g.AuxType,e.DyeBase, AuxName,nvl(WAVGPRICE,0) as wPrice,
    UnitOfMeas, sum(StockQty*c.AuxStockBank) BankStock,sum(StockQty*c.AuxStockMain) MainStock,
    sum(StockQty*c.AuxStockSecondary) SubStock,sum(StockQty*c.ASLOANTOPARTY) LoanTo,
    sum(StockQty*c.ASLOANFromPARTY) LoanFrom
    from T_AuxStock a, T_AuxStockItem b, T_AuxStockTypeDetails c, T_Auxiliaries d, T_DyeBase e, T_UnitOfMeas f, T_AuxType g
    where a.AuxStockID=b.AuxStockID and
    a.AuxStockTypeID=c.AuxStockTypeID and
    d.AuxTypeID = g.AuxTypeID and
    B.AUXTYPEID=C.AUXTYPEID AND
    b.AuxID=d.AuxID and
    d.DyeBaseID= e.DyeBaseID (+) and
    d.UnitOfMeasID=f.UnitOfMeasID and
    d.AuxTypeID=g.AuxTypeID and
    StockDate <= pStockDate and
    b.AuxTypeID = pAuxTypeID
    group by b.AuxID,g.AuxTypeID,g.AuxType,e.DyeBase, AuxName,nvl(WAVGPRICE,0),UnitOfMeas
    order by DyeBase, AuxName;
 /* For Bank Store */
  elsif pQueryType=1 then
    open data_cursor for
    select b.AuxID, DyeBase, AuxName, UnitOfMeas, sum(StockQty*c.AuxStockBank) CurrentStock
    from T_AuxStock a, T_AuxStockItem b, T_AuxStockTypeDetails c, T_Auxiliaries d, T_DyeBase e, T_UnitOfMeas f, T_AuxType g
    where a.AuxStockID=b.AuxStockID and
    a.AuxStockTypeID=c.AuxStockTypeID and
    d.AuxTypeID = g.AuxTypeID and
    B.AUXTYPEID=C.AUXTYPEID AND
    b.AuxID=d.AuxID and
    d.DyeBaseID= e.DyeBaseID (+) and
    d.UnitOfMeasID=f.UnitOfMeasID and
    d.AuxTypeID=g.AuxTypeID and
    StockDate <= pStockDate and
    b.AuxTypeID = pAuxTypeID
    group by b.AuxID, DyeBase, AuxName, UnitOfMeas
    having sum(StockQty*c.AuxStockBank)>0
  order by DyeBase, AuxName;
 /* View the main Stock */
  elsif pQueryType=2 then
    open data_cursor for
    select b.AuxID,
    DyeBase, AuxName, UnitOfMeas,sum(StockQty*c.AuxStockMain) CurrentStock
    from T_AuxStock a, T_AuxStockItem b, T_AuxStockTypeDetails c, T_Auxiliaries d,
 T_DyeBase e, T_UnitOfMeas f, T_AuxType g
    where a.AuxStockID=b.AuxStockID and
    a.AuxStockTypeID=c.AuxStockTypeID and
 B.AUXTYPEID=C.AUXTYPEID AND
    d.AuxTypeID = g.AuxTypeID and
    b.AuxID=d.AuxID and
    d.DyeBaseID= e.DyeBaseID (+) and
    d.UnitOfMeasID=f.UnitOfMeasID and
    d.AuxTypeID=g.AuxTypeID and
    b.AuxTypeID = pAuxTypeID
    group by b.AuxID, DyeBase, AuxName, UnitOfMeas
    having sum(StockQty*c.AuxStockMain)>0
  order by DyeBase, AuxName;
 /* For Sub Store */
  elsif pQueryType=3 then
    open data_cursor for
    select b.AuxID, DyeBase, AuxName, UnitOfMeas, sum(StockQty*c.AuxStockSecondary) CurrentStock
    from T_AuxStock a, T_AuxStockItem b, T_AuxStockTypeDetails c, T_Auxiliaries d, T_DyeBase e, T_UnitOfMeas f, T_AuxType g
    where a.AuxStockID=b.AuxStockID and
    a.AuxStockTypeID=c.AuxStockTypeID and
 B.AUXTYPEID=C.AUXTYPEID AND
    d.AuxTypeID = g.AuxTypeID and
    b.AuxID=d.AuxID and
    d.DyeBaseID= e.DyeBaseID (+) and
    d.UnitOfMeasID=f.UnitOfMeasID and
    d.AuxTypeID=g.AuxTypeID and
    StockDate <= pStockDate and
    b.AuxTypeID = pAuxTypeID
    group by b.AuxID, DyeBase, AuxName, UnitOfMeas
    having sum(StockQty*c.AuxStockSecondary)>0
  order by DyeBase, AuxName;
 /* For Loan To Party Store */
elsif pQueryType=4 then
    open data_cursor for
    select b.AuxID, DyeBase, AuxName, UnitOfMeas, sum(StockQty*c.ASLOANTOPARTY) CurrentStock
    from T_AuxStock a, T_AuxStockItem b, T_AuxStockTypeDetails c, T_Auxiliaries d, T_DyeBase e, T_UnitOfMeas f, T_AuxType g
    where a.AuxStockID=b.AuxStockID and
    a.AuxStockTypeID=c.AuxStockTypeID and
 B.AUXTYPEID=C.AUXTYPEID AND
    d.AuxTypeID = g.AuxTypeID and
    b.AuxID=d.AuxID and
    d.DyeBaseID= e.DyeBaseID (+) and
    d.UnitOfMeasID=f.UnitOfMeasID and
    d.AuxTypeID=g.AuxTypeID and
    StockDate <= pStockDate and
    b.AuxTypeID = pAuxTypeID
    group by b.AuxID, DyeBase, AuxName, UnitOfMeas
    having sum(StockQty*c.ASLOANTOPARTY)>0
  order by DyeBase, AuxName;
 /* For Loan From Party  Store */
  elsif pQueryType=5 then
    open data_cursor for
    select b.AuxID, DyeBase, AuxName, UnitOfMeas, sum(-StockQty*c.ASLOANFromPARTY) CurrentStock
    from T_AuxStock a, T_AuxStockItem b, T_AuxStockTypeDetails c, T_Auxiliaries d, T_DyeBase e, T_UnitOfMeas f, T_AuxType g
    where a.AuxStockID=b.AuxStockID and
    a.AuxStockTypeID=c.AuxStockTypeID and
    B.AUXTYPEID=C.AUXTYPEID AND
    d.AuxTypeID = g.AuxTypeID and
    b.AuxID=d.AuxID and
    d.DyeBaseID= e.DyeBaseID (+) and
    d.UnitOfMeasID=f.UnitOfMeasID and
    d.AuxTypeID=g.AuxTypeID and
    StockDate <= pStockDate and
    b.AuxTypeID = pAuxTypeID
    group by b.AuxID, DyeBase, AuxName, UnitOfMeas
    having sum(-StockQty*c.ASLOANfromPARTY)>0
    order by DyeBase, AuxName;
 /* View the Requisition Stock */
  elsif pQueryType=6 then
    open data_cursor for
    select STOCKINVOICENO,b.AuxID,DyeBase, AuxName, UnitOfMeas,sum(StockQty*c.AuxStockMain) CurrentStock
    from T_AuxStockRequisition a, T_AuxStockItemRequisition b, T_AuxStockTypeDetails c, T_Auxiliaries d,
    T_DyeBase e, T_UnitOfMeas f, T_AuxType g
    where a.AuxStockID=b.AuxStockID and
    a.AuxStockTypeID=c.AuxStockTypeID and
    B.AUXTYPEID=C.AUXTYPEID AND
    d.AuxTypeID = g.AuxTypeID and
    b.AuxID=d.AuxID and
    d.DyeBaseID= e.DyeBaseID (+) and
    d.UnitOfMeasID=f.UnitOfMeasID and
    d.AuxTypeID=g.AuxTypeID and
    b.AuxTypeID = pAuxTypeID AND EXECUTED=0
    group by STOCKINVOICENO,b.AuxID, DyeBase, AuxName, UnitOfMeas
    having sum(StockQty*c.AuxStockMain)>0
  order by STOCKINVOICENO,DyeBase, AuxName;

  end if;
END GetAuxStockPosition;
/


PROMPT CREATE OR REPLACE Procedure  142 :: GETkMCPartStockReqInfo
CREATE OR REPLACE Procedure GETkMCPartStockReqInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  many_cursor IN OUT pReturnData.c_Records,
  pKmcStockID number
)
AS
BEGIN

    open one_cursor for
    select a.StockId, a.StockDate, a.ChallanNo, a.ChallanDate, a.PURCHASEORDERNO, a.PURCHASEORDERDATE,
    a.KmcStockTypeId,a.SUBCONID,a.SUPPLIERID,a.EXECUTED
    from T_KmcPartsTranRequisition  a
    where a.StockId=pKmcStockID;

    open many_cursor for
    select a.STOCKID,c.partsstatus, a.STOCKITEMSL,a.PARTID,a.UNITPRICE,a.REMARKS,
    a.PARTSSTATUSFROMID,a.PARTSSTATUSTOID,a.QTY,a.MACHINEID,a.PID,a.CURRENTSTOCK,
    a.KMCTYPEID,b.PARTNAME,b.DESCRIPTION,b.FOREIGNPART
    from T_KMCPARTSTRANSDETAILSReq a,t_kmcpartsinfo b,t_kmcpartsstatus c
    where a.STOCKID=pKMCStockID and a.PARTID=b.PARTID and
    c.partsstatusid=a.PARTSSTATUSFROMID
    order by a.STOCKITEMSL asc;
END GETkMCPartStockReqInfo;
/


PROMPT CREATE OR REPLACE Procedure  143 :: getTreeKmcStockReqList
CREATE OR REPLACE Procedure getTreeKmcStockReqList (
  io_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pStockType IN NUMBER,
  sDate IN date,
  eDate IN date
)
AS
BEGIN

/* for Any Stock Particular StockType with challan No*/
  if pQueryType=0 then
    OPEN io_cursor FOR
    select StockId, ChallanNo, StockDate from T_KmcPartsTranRequisition
    where KmcStockTypeId=pStockType and
    StockDate>=SDate and StockDate<=EDate order by 
    ChallanNo desc;
	
/* for Any Stock Particular StockDate with challan No*/
  elsif pQueryType=1 then
    OPEN io_cursor FOR
    select StockId, ChallanNo, StockDate from T_KmcPartsTranRequisition
    where KmcStockTypeId=pStockType and
    StockDate>=SDate and StockDate<=EDate order by 
    StockDate desc;	
	
/* for Any Stock Particular MachinePartsName with challan No*/	
  elsif pQueryType=2 then
    OPEN io_cursor FOR
    select b.PARTID, c.PARTNAME from T_KmcPartsTranRequisition a, T_KMCPARTSTRANSDETAILSReq b, t_kmcpartsinfo c
    where b.PARTID=c.PARTID and
	a.STOCKID=b.STOCKID and
	a.KmcStockTypeId=pStockType and
    a.StockDate>=SDate and a.StockDate<=EDate 
	group by b.PARTID, c.PARTNAME
	order by c.PARTNAME;
  end if;

END getTreeKmcStockReqList;
/


PROMPT CREATE OR REPLACE Procedure  144 :: getTreeMachinePartsInfoList
CREATE OR REPLACE Procedure getTreeMachinePartsInfoList(
  io_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pMPGroup IN NUMBER
)
AS
BEGIN
 /* For Parts Name*/
  if pQueryType=0 then
    OPEN io_cursor FOR
    select a.PARTID,a.PARTNAME from  T_TEXMCPARTSINFO a
	WHERE MPGroupID=pMPGroup
    order by PARTNAME asc;

 /* For Machine Type  */
  elsif pQueryType=1 then
    OPEN io_cursor FOR
        select a.PARTID,a.PARTNAME,a.MACHINETYPE,a.BINNO 
		from T_TEXMCPARTSINFO a  
		WHERE MPGroupID=pMPGroup
		order by MACHINETYPE,PARTNAME asc;
 /* For Locaiton */
  elsif pQueryType=2 then
    OPEN io_cursor FOR
        select a.PARTID,a.PARTNAME,a.MACHINETYPE,a.BINNO 
		from T_TEXMCPARTSINFO a
		WHERE MPGroupID=pMPGroup
		order by BINNO,PARTNAME asc;
  end if;
END getTreeMachinePartsInfoList;
/


PROMPT CREATE OR REPLACE Procedure  145 :: GETMachinePartsInfo
CREATE OR REPLACE Procedure GETMachinePartsInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  many_cursor IN OUT pReturnData.c_Records,
  pPARTID number
)
AS
BEGIN
    open one_cursor for
    select PARTID,PARTNAME,DESCRIPTION,FOREIGNPART,MACHINETYPE,UNITOFMEASID,MACHINENO,BINNO,
    REORDERQTY,SUPPLIERADDRESS,ORDERLEADTIME,REMARKS,WAVGPRICE,PROJCODE,CCATACODE,MPGroupID
    from T_TEXMCPARTSINFO  where PARTID=pPARTID;

    open many_cursor for
    select PID,PARTID, PURCHASEDATE, UNITPRICE, SUPPLIERNAME, QTY
    from T_TexMcPartsPrice
    where PARTID=pPARTID
	Order By PURCHASEDATE DESC;
END GETMachinePartsInfo;
/


PROMPT CREATE OR REPLACE Procedure  146 :: GetMachineSpareTypeLookup

CREATE OR REPLACE Procedure GetMachineSpareTypeLookup
(
  pStatus number,
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)
AS

BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=0 then
  OPEN data_cursor for
     select CCATACODE,CCATANAME  from t_acclass order by CCATANAME;

/*If the Value is 1 then retun as the */

elsif pStatus=1 then
  OPEN data_cursor for
     select CCATACODE,CCATANAME  from t_acclass
  where CCATACODE=pWhereValue order by CCATANAME;
end if;
END GetMachineSpareTypeLookup;
/


PROMPT CREATE OR REPLACE Procedure  147 :: GetMachineDepartmentLookup

CREATE OR REPLACE Procedure GetMachineDepartmentLookup
(
  pStatus number,
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)
AS

BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=0 then
  OPEN data_cursor for
    select PROJCODE,PROJNAME from t_project order by PROJNAME;

/*If the Value is 1 then retun as the */

elsif pStatus=1 then
  OPEN data_cursor for
     select PROJCODE,PROJNAME from t_project 
  where PROJCODE=pWhereValue order by PROJNAME;
end if;
END GetMachineDepartmentLookup;
/


PROMPT CREATE OR REPLACE Procedure  148 ::  GetMachineListLookup

CREATE OR REPLACE Procedure GetMachineListLookup
(
  pStatus number,
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)
AS

BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=0 then
  OPEN data_cursor for
     select MCLISTID,MCLISTNAME  from T_TexMcList order by MCLISTNAME;

/*If the Value is 1 then retun as the */

elsif pStatus=1 then
  OPEN data_cursor for
     select MCLISTID,MCLISTNAME  from T_TexMcList
  where MCLISTID=pWhereValue order by MCLISTNAME;
end if;
END GetMachineListLookup;
/



PROMPT CREATE OR REPLACE Procedure  149 :: getTreeMachinePartsStockList
CREATE OR REPLACE Procedure getTreeMachinePartsStockList (
  io_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pStockType IN NUMBER,
  sDate IN date,
  eDate IN date
)
AS
BEGIN
/* for Any Stock Particular StockType with challan No*/
  if pQueryType=0 then
    OPEN io_cursor FOR
    select StockId, ChallanNo, StockDate from T_TexMcStock
    where TexMCSTOCKTYPEID=pStockType and
    StockDate>=SDate and StockDate<=EDate order by 
    ChallanNo desc;
	
/* for Any Stock Particular StockDate with challan No*/
  elsif pQueryType=1 then
    OPEN io_cursor FOR
    select StockId, ChallanNo, StockDate from T_TexMcStock
    where TexMCSTOCKTYPEID=pStockType and
    StockDate>=SDate and StockDate<=EDate order by 
    StockDate desc;	

	/* for Any Stock Particular SUPPLIERNAME with challan No*/	
  elsif pQueryType=2 then
    OPEN io_cursor FOR
    select StockId, ChallanNo,T_Supplier.SupplierName AS SupplierName from T_TexMcStock,T_Supplier
    where T_TexMcStock.SUPPLIERID=T_Supplier.SUPPLIERID AND 
	TexMCSTOCKTYPEID=pStockType and
    StockDate>=SDate and StockDate<=EDate order by 
    StockDate desc;	
	
	/* for Any Stock Particular MachinePartsName with challan No*/	
  elsif pQueryType=3 then
    OPEN io_cursor FOR
    select b.PARTID, c.PARTNAME from T_TexMcStock a, T_TexMcStockItems b, T_TexMcPartsInfo c
    where b.PARTID=c.PARTID and
	a.STOCKID=b.STOCKID and
	a.TexMCSTOCKTYPEID=pStockType and
    a.StockDate>=SDate and a.StockDate<=EDate 
	group by b.PARTID, c.PARTNAME
	order by c.PARTNAME;

	/* for Any Stock Particular MachinePartsName with challan No*/
 elsif pQueryType=4 then
    OPEN io_cursor FOR
    select b.PARTID, c.PARTNAME from T_TexMcStock a, T_TexMcStockItems b, T_TexMcPartsInfo c
    where b.PARTID=c.PARTID and
	a.STOCKID=b.STOCKID and
	a.TexMCSTOCKTYPEID=3 and
    a.StockDate>=SDate and a.StockDate<=EDate 
	group by b.PARTID, c.PARTNAME
	order by c.PARTNAME;
  end if;
END getTreeMachinePartsStockList;
/




PROMPT CREATE OR REPLACE Procedure  150 :: GETMachinePartsPartStockInfo
CREATE OR REPLACE Procedure GETMachinePartsPartStockInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  many_cursor IN OUT pReturnData.c_Records,
  pMcStockID number
)
AS
BEGIN
    open one_cursor for
    	select a.StockId, a.StockDate, a.ChallanNo, a.ChallanDate, a.PURCHASEORDERNO, 	
		a.PURCHASEORDERDATE, CURRENCYID,CONRATE,SCOMPLETE,      
		a.TexMCSTOCKTYPEID,a.SUPPLIERID,a.DELIVERYNOTE
    	from T_TexMcStock a  where a.StockId=pMcStockID;

    open many_cursor for
    	select a.STOCKID,c.partsstatus, a.STOCKITEMSL,a.PARTID,a.UNITPRICE,a.REMARKS,
		a.PARTSSTATUSFROMID,a.PARTSSTATUSTOID,a.QTY,a.IssueFor,a.PID,a.CURRENTSTOCK,
		a.TexMCSTOCKTYPEID,b.PARTNAME,b.DESCRIPTION,b.FOREIGNPART,a.MPGroupID,d.MPGroupName
    	from T_TexMcStockItems a,T_TexMcPartsInfo b,T_TexMCPARTSSTATUS c,T_MPGroup d
    	where a.STOCKID=pMcStockID and
 	    a.PARTID=b.PARTID and a.MPGroupID=d.MPGroupID and
      	c.partsstatusid=a.PARTSSTATUSFROMID
    	order by a.STOCKITEMSL asc;
END GETMachinePartsPartStockInfo;
/


PROMPT CREATE OR REPLACE Procedure  151 :: GetMachinePartsPickUp

CREATE OR REPLACE Procedure GetMachinePartsPickUp
(
  pStatus number,
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
/*if the Value is 0 then retun all the Data */
if pStatus=0 then
  OPEN data_cursor for
   select a.PartID,a.PARTNAME,a.Description,a.FOREIGNPART,a.MachineType,a.UNITOFMEASID,f.UNITOFMEAS,a.MPGROUPID,b.MPGROUPNAME
   from T_TexMcPartsInfo a,t_unitofmeas f,T_MPGROUP b
   where a.UNITOFMEASID=f.UNITOFMEASID  and   a.MPGROUPID=b.MPGROUPID
   order by a.MachineType,a.PARTNAME;
/*If the Value is 1 then retun as the */
elsif pStatus=1 then
  OPEN data_cursor for
   select a.PartID,a.PARTNAME,a.Description,a.FOREIGNPART,a.MachineType,a.UNITOFMEASID,f.UNITOFMEAS,a.MPGROUPID,b.MPGROUPNAME
   from T_TexMcPartsInfo a,t_unitofmeas f ,T_MPGROUP b
   where a.UNITOFMEASID=f.UNITOFMEASID   and   a.MPGROUPID=b.MPGROUPID
   order by a.MachineType,a.PARTNAME;
end if;
END GetMachinePartsPickUp;
/

PROMPT CREATE OR REPLACE Procedure  152 :: getTreeMcPartsStockReqList

CREATE OR REPLACE Procedure getTreeMcPartsStockReqList (
  io_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pStockType IN NUMBER,
  sDate IN date,
  eDate IN date
)
AS
BEGIN

/* for Any Stock Particular StockType with challan No*/
  if pQueryType=0 then
    OPEN io_cursor FOR
    select StockId, ChallanNo, StockDate from T_TexMcStockReq
    where TexMCSTOCKTYPEID=pStockType and
    StockDate>=SDate and StockDate<=EDate order by 
    ChallanNo desc;
	
/* for Any Stock Particular StockDate with challan No*/
  elsif pQueryType=1 then
    OPEN io_cursor FOR
    select StockId, ChallanNo, StockDate from T_TexMcStockReq
    where TexMCSTOCKTYPEID=pStockType and
    StockDate>=SDate and StockDate<=EDate order by 
    StockDate desc;	
	
  elsif pQueryType=2 then
    OPEN io_cursor FOR
    select b.PARTID, c.PARTNAME from T_TexMcStockReq a, T_TexMcStockItemsReq b, T_TexMcPartsInfo c
    where b.PARTID=c.PARTID and
	a.STOCKID=b.STOCKID and
	a.TexMCSTOCKTYPEID=pStockType and
    a.StockDate>=SDate and a.StockDate<=EDate 
	group by b.PARTID, c.PARTNAME
	order by c.PARTNAME;
  end if;

END getTreeMcPartsStockReqList;
/

PROMPT CREATE OR REPLACE Procedure  153 :: GetMCPartsStockReqInfo
CREATE OR REPLACE Procedure GetMCPartsStockReqInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  many_cursor IN OUT pReturnData.c_Records,
  pMcStockID number
)
AS
BEGIN
    open one_cursor for
    	select a.StockId, a.StockDate, a.ChallanNo, a.ChallanDate, a.PURCHASEORDERNO, a.PURCHASEORDERDATE,
	a.TexMCSTOCKTYPEID,a.SUPPLIERNAME,a.SUPPLIERADDRESS,a.DELIVERYNOTE,a.EXECUTED
    	from T_TexMcStockReq a  where a.StockId=pMcStockID;
    open many_cursor for
    	select a.STOCKID,c.partsstatus, a.STOCKITEMSL,a.PARTID,a.UNITPRICE,a.REMARKS,
		a.PARTSSTATUSFROMID,a.PARTSSTATUSTOID,a.QTY,a.IssueFor,a.PID,a.CURRENTSTOCK,
		a.TexMCSTOCKTYPEID,b.PARTNAME,b.DESCRIPTION,b.FOREIGNPART,a.MPGroupID,d.MPGroupName
    	from T_TexMcStockItemsReq a,T_TexMcPartsInfo b,T_TexMCPARTSSTATUS c,T_MPGroup d
    	where a.STOCKID=pMcStockID and
		a.PARTID=b.PARTID and a.MPGroupID=d.MPGroupID and
      	c.partsstatusid=a.PARTSSTATUSFROMID
    	order by a.STOCKITEMSL asc;
END GetMCPartsStockReqInfo;
/

PROMPT CREATE OR REPLACE Procedure  154 :: GetMachineStockPickUp
CREATE OR REPLACE Procedure GetMachineStockPickUp(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER
)
AS

BEGIN
/* Pick All the Latest Stock from the Database For Report Purpose Only*/
  if pQueryType=0 then

        open data_cursor for

        select b.PARTID,c.PARTNAME,
           sum(b.QTY * d.MSN) as MainStoreNew,
           sum(b.QTY * d.MSO) as MainStoreOld,
           sum(b.QTY * d.MSB) as MainStoreBroken,
           sum(b.QTY * d.MSR) as MainStoreRejected,
           sum(b.QTY * d.FSN) as FloorNewReturn,
	   sum(b.QTY * d.FSO) as FloorOldReturn,
           sum(b.QTY * d.SSN) as SubContractorNew
           from t_kmcpartstransdetails b,t_kmcpartsinfo c,t_kmcstockStatus d
           where b.PARTID=c.PARTID and B.KMCSTOCKTYPEID=d.KMCSTOCKTYPEID and
           b.PARTSSTATUSFROMID=d.PARTSSTATUSFROMID and b.PARTSSTATUSTOID=d.PARTSSTATUSTOID
           group by b.PARTID,c.PARTNAME;

        /* For requisition from Main Store New */
  elsif pQueryType=1 then
 open data_cursor for
    select b.PARTID,c.PARTNAME,a.PARTSSTATUS,c.FOREIGNPART,c.MACHINETYPE,c.DESCRIPTION,0 as UNITPRICE,
        b.PARTSSTATUSTOID AS PARTSSTATUSFROMID,e.UNITOFMEAS,SUM(b.QTY * d.MSN) as Qty,0 as stockQty,b.MPGroupID,h.MPGroupName
        from T_TEXMCPARTSSTATUS a,T_TexMcStockItems b,T_TEXMCPARTSINFO c,
		T_TEXMCSTOCKSTATUS d,t_UnitOfMeas e,T_MPGroup h
	where  b.PARTID=c.PARTID and
        b.PARTSSTATUSTOID=a.PARTSSTATUSID and b.MPGroupID=h.MPGroupID and
        B.TEXMCSTOCKTYPEID=d.TEXMCSTOCKTYPEID and b.PARTSSTATUSFROMID=d.PARTSSTATUSFROMID and
        b.PARTSSTATUSTOID=d.PARTSSTATUSTOID and c.UNITOFMEASID=e.UNITOFMEASID
        group by  b.PARTID,c.PARTNAME,a.PARTSSTATUS,c.FOREIGNPART,c.MACHINETYPE,c.DESCRIPTION,
        b.PARTSSTATUSTOID,e.UNITOFMEAS,b.MPGroupID,h.MPGroupName
        having sum(b.Qty*d.MSN)>0
        order by partID;

 /* For issue from main store corresponding by Requisition Store New*/
  elsif pQueryType=10 then
 open data_cursor for
   select CHALLANNO,b.PARTID,c.PARTNAME,a.PARTSSTATUS,c.FOREIGNPART,c.MACHINETYPE,c.DESCRIPTION,0 as UNITPRICE,
       b.PARTSSTATUSTOID AS PARTSSTATUSFROMID,e.UNITOFMEAS,f.MCLISTID,f.MCLISTNAME,
	   SUM(-b.QTY * d.MSN) as Qty,/*Qty for requisition quantity*/
	   
	100 as stockQty,
		b.MPGroupID,h.MPGroupName
       from T_TEXMCPARTSSTATUS a,T_TexMcStockItemsReq b,T_TEXMCPARTSINFO c,
	   T_TEXMCSTOCKSTATUS d,T_UnitOfMeas e,T_TexMcStockReq G,T_TEXMCLIST f,T_MPGroup h	    
       where  b.StockId=g.StockID and b.PARTID=c.PARTID and b.MPGroupID=h.MPGroupID and
       b.PARTSSTATUSTOID=a.PARTSSTATUSID and ISSUEFOR=f.MCLISTID and
       B.TEXMCSTOCKTYPEID=d.TEXMCSTOCKTYPEID and b.PARTSSTATUSFROMID=d.PARTSSTATUSFROMID and
       b.PARTSSTATUSTOID=d.PARTSSTATUSTOID and c.UNITOFMEASID=e.UNITOFMEASID and Executed=0
       group by  CHALLANNO,b.PARTID,c.PARTNAME,a.PARTSSTATUS,c.FOREIGNPART,c.MACHINETYPE,c.DESCRIPTION,
       b.PARTSSTATUSTOID,e.UNITOFMEAS,f.MCLISTID,f.MCLISTNAME,b.MPGroupID,h.MPGroupName
       having sum(-b.Qty*d.MSN)>0
       order by partID;

 /* For Floor Store for Return Pickup */
  elsif pQueryType=2 then
open data_cursor for
   select b.PARTID,c.PARTNAME,a.PARTSSTATUS,c.FOREIGNPART,c.MACHINETYPE,c.DESCRIPTION,b.UNITPRICE,
        b.PARTSSTATUSTOID AS PARTSSTATUSFROMID,e.UNITOFMEAS,f.MCLISTID,f.MCLISTNAME,
		SUM(b.QTY * d.FSN) as Qty,0 as stockQty,b.MPGroupID,h.MPGroupName
        from T_TEXMCPARTSSTATUS a,T_TexMcStockItems b,T_TEXMCPARTSINFO c,T_TEXMCSTOCKSTATUS d,
		t_UnitOfMeas e,T_TEXMCLIST f,T_MPGroup h
        where  b.PARTID=c.PARTID and b.MPGroupID=h.MPGroupID and
        b.PARTSSTATUSTOID=a.PARTSSTATUSID and ISSUEFOR=f.MCLISTID and
        B.TEXMCSTOCKTYPEID=d.TEXMCSTOCKTYPEID and b.PARTSSTATUSFROMID=d.PARTSSTATUSFROMID and
        b.PARTSSTATUSTOID=d.PARTSSTATUSTOID and c.UNITOFMEASID=e.UNITOFMEASID
        group by  b.PARTID,c.PARTNAME,a.PARTSSTATUS,c.FOREIGNPART,c.MACHINETYPE,c.DESCRIPTION,b.UNITPRICE,
        b.PARTSSTATUSTOID,e.UNITOFMEAS,f.MCLISTID,f.MCLISTNAME,b.MPGroupID,h.MPGroupName
        having sum(b.Qty*d.FSN)>0
	order by partID;

  end if;

END GetMachineStockPickUp;
/


PROMPT CREATE OR REPLACE Procedure  155 :: GetMachineInfoLookUp
CREATE OR REPLACE Procedure GetMachineInfoLookUp
(
  pStatus number,
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)

AS

BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=0 then
  OPEN data_cursor for
   select MCLISTID,MCLISTNAME
	from T_TEXMCLIST
	order by MCLISTNAME;

/*If the Value is 1 then retun as the */

elsif pStatus=1 then
  OPEN data_cursor for
   select MCLISTID,MCLISTNAME
	from T_TEXMCLIST
	where  MCLISTID=pWhereValue
	order by MCLISTNAME;

end if;
END GetMachineInfoLookUp;
/


PROMPT CREATE OR REPLACE Procedure  156 :: GetMachinePartsSpareType

CREATE OR REPLACE Procedure GetMachinePartsSpareType
(
  pStatus number,
  pWhereValue number,
  data_cursor IN OUT pReturnData.c_Records
)

AS

BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=0 then
  	OPEN data_cursor for
   	select CCATACODE,CCATANAME,CCATATYPE
 	from T_ACCLASS order by CCATANAME;

/*If the Value is 1 then retun as the */

elsif pStatus=1 then
  	OPEN data_cursor for
	select CCATACODE,CCATANAME,CCATATYPE
 	from T_ACCLASS where CCATACODE=pWhereValue order by CCATANAME;
end if;
END GetMachinePartsSpareType;
/

               
PROMPT CREATE OR REPLACE Procedure  157 :: GetAllMachineList

CREATE OR REPLACE Procedure GetAllMachineList
(
  pStatus number,
  pWhereValue number,
  data_cursor IN OUT pReturnData.c_Records
)

AS

BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=0 then
  	OPEN data_cursor for
   	select  MCLISTID,MCLISTNAME     
 	from T_TEXMCLIST order by MCLISTNAME;

/*If the Value is 1 then retun as the */

elsif pStatus=1 then
  	OPEN data_cursor for
	select MCLISTID,MCLISTNAME     
 	from T_TEXMCLIST where MCLISTID=pWhereValue order by MCLISTNAME;
end if;
END GetAllMachineList;
/

      
PROMPT CREATE OR REPLACE Procedure  158 ::  GetMachineDeptList
         
CREATE OR REPLACE Procedure GetMachineDeptList
(
  pStatus number,
  pWhereValue number,
  data_cursor IN OUT pReturnData.c_Records
)

AS

BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=0 then
  	OPEN data_cursor for
   	select  PROJCODE,PROJNAME     
 	from T_PROJECT order by PROJNAME;

/*If the Value is 1 then retun as the */

elsif pStatus=1 then
  	OPEN data_cursor for
	select PROJCODE,PROJNAME     
 	from T_PROJECT where PROJCODE=pWhereValue order by PROJNAME;
end if;
END GetMachineDeptList;
/ 


------------------------------------------------------------- 
-- START of Textile Dyeline SP
------------------------------------------------------------- 
PROMPT CREATE OR REPLACE Procedure  159 :: getTreeDyeMachinesInfoList

CREATE OR REPLACE Procedure getTreeDyeMachinesInfoList(
  io_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER
)
AS
BEGIN
 /* For MACHINENAME Name*/
  if pQueryType=0 then
    OPEN io_cursor FOR
    select a.MACHINEID,a.MACHINENAME from  T_DYEMACHINES a
    order by MACHINENAME desc;

  end if;
END getTreeDyeMachinesInfoList;
/

PROMPT CREATE OR REPLACE Procedure  160 :: GETDyeMachinePartsInfo

CREATE OR REPLACE Procedure GETDyeMachinePartsInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  dMACHINEID number
)
AS
BEGIN
    open one_cursor for
    select  MACHINEID,MACHINENAME,LIQUOR,CAPACITY,MINCAPACITY,MAXCAPACITY,BATCHCOUNT,STATUS,
    ENABLED,PRIORITY      
    from T_DyeMachines where MACHINEID=dMACHINEID;
END GETDyeMachinePartsInfo;
/

PROMPT CREATE OR REPLACE Procedure  161 :: GetDUnitOfMeasList
CREATE OR REPLACE Procedure GetDUnitOfMeasList
(
  pStatus number,
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)
AS

BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=0 then
  OPEN data_cursor for
    Select UnitOfMeas, UnitOfMeasID from T_DUnitOfMeas order by UnitOfMeas;

/*If the Value is 1 then retun as the */

elsif pStatus=1 then
  OPEN data_cursor for
    Select UnitOfMeas, UnitOfMeasID from T_DUnitOfMeas
  where UnitOfMeasID=pWhereValue order by UnitOfMeas;
end if;
END GetDUnitOfMeasList;
/


PROMPT CREATE OR REPLACE Procedure  162 :: GetDyeBatchList
CREATE OR REPLACE Procedure GetDyeBatchList
(
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN

    OPEN data_cursor for
    Select DBATCHID,BATCHNO from T_DBatch;

END;
/


PROMPT CREATE OR REPLACE Procedure  163 :: GetDyeMachineList
CREATE OR REPLACE Procedure GetDyeMachineList
(
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN

    OPEN data_cursor for
    Select MACHINEID,MACHINENAME from T_DyeMachines;

END;
/



PROMPT CREATE OR REPLACE Procedure  164 :: GetDyeLineInfo
CREATE OR REPLACE Procedure GetDyeLineInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  many_cursor_Head IN OUT pReturnData.c_Records,
  pDYELINEID number
)
AS
BEGIN
    open one_cursor for
  select DYELINEID,DBATCHID,UDYELINEID,DYELINENO,DYELINEDATE,
  MACHINEID,DLIQUOR,DWEIGHT,DLIQUORRATIO,PACKAGECOUNT,DYEINGPROGRAM,
  PRODDATE,DSTARTDATETIME,DENDDATETIME,FINISHEDWEIGHT,
  DYEINGSHIFT,DCOMMENTS,DPARENT,DRECOUNT,DCOMPLETE,DREDYEINGCOUNT,
  BPOSTEDTOSTOCK,EMPLOYEEID from T_DYELINE where DYELINEID=pDYELINEID;

    open many_cursor_Head for
      select a.HEADID,b.HEADORDER,a.HEADNAME,a.AUXTYPEID,DECODE(a.HEADID,b.HEADID,b.HEADCOMMENTS,'') as HEADCOMMENTS,'1' as HOType
  from T_DYELINEHEAD a,T_DSUBHEADS b WHERE a.HEADID=b.HEADID and b.DYELINEID=pDYELINEID
  union
  select a.HEADID,a.HEADORDER,a.HEADNAME,a.AUXTYPEID,'' as HEADCOMMENTS,'2' as HOType
  from T_DYELINEHEAD a where a.HEADID not in (select HEADID from T_DSUBHEADS WHERE  DYELINEID=pDYELINEID)
 order by HOType,HEADORDER;

END GetDyeLineInfo;
/

PROMPT CREATE OR REPLACE Procedure  165 :: GetDyeLineHeadItemsInfo
CREATE OR REPLACE Procedure GetDyeLineHeadItemsInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  pDYELINEID number,
  pAUXTYPEID number,
  pHEADID number
)
AS
BEGIN
    open one_cursor for
	select DSUBITEMSID,a.DYELINEID,HEADID,a.AUXTYPEID,b.DYEBASEID,a.AUXID,AUXQTY,a.UNITOFMEASID,
	AUXINCDECBY,AUXADDITION,AUXADDCOUNT,AUXTOTQTYPERC,AUXTOTQTYGM,c.DLIQUOR,c.DWEIGHT 
	from T_DSUBITEMS a,T_Auxiliaries b,T_DYELINE c 
	where  a.AuxId=b.AuxId and a.DYELINEID=c.DYELINEID and a.DYELINEID=pDYELINEID and a.AUXTYPEID=pAUXTYPEID and HEADID=pHEADID 
	order by DSUBITEMSID;

END GetDyeLineHeadItemsInfo;
/


PROMPT CREATE OR REPLACE Procedure  166 :: GetDyeLineSubHeadInsertUpdate
CREATE OR REPLACE Procedure GetDyeLineSubHeadInsertUpdate
(
	pDYELINEID IN NUMBER,
  	pHEADID IN NUMBER,
     	pHEADORDER IN NUMBER,
     	pHEADCOMMENTS IN varchar2
)
AS
 pINUP NUMBER;

BEGIN
 select COUNT(*) INTO pINUP from T_DYELINEHEAD a 
	where a.HEADID in (select COUNT(*) from T_DSUBHEADS WHERE  DYELINEID=pDYELINEID AND HEADID=pHEADID);

 if pINUP=0 then
    	INSERT INTO T_DSUBHEADS (DYELINEID,HEADID,HEADORDER,HEADCOMMENTS)
	VALUES(pDYELINEID,pHEADID,pHEADORDER,pHEADCOMMENTS);
 elsif pINUP=1 then
    	UPDATE T_DSUBHEADS SET HEADCOMMENTS=pHEADCOMMENTS WHERE  DYELINEID=pDYELINEID AND HEADID=pHEADID;
 end if;

END GetDyeLineSubHeadInsertUpdate;
/

PROMPT CREATE OR REPLACE Procedure  167 :: GetDyeLineSubItemUpdate
CREATE OR REPLACE Procedure GetDyeLineSubItemUpdate
(
 pDyeLineID IN NUMBER,
 pHeadID IN NUMBER,
 pLiquorLt IN NUMBER,
 pWeightKg IN NUMBER
)
AS
BEGIN

 update T_DSubItems set AUXTOTQTYPERC=AUXQTY,AUXTOTQTYGM=AUXQTY*pLiquorLt
  where DYELINEID=pDyeLineID  and AuxTypeID=1;

 update T_DSubItems set AUXTOTQTYPERC=0,AUXTOTQTYGM=AUXQTY*pWeightKg*10
  where DYELINEID=pDyeLineID  and AuxTypeID=1 AND UNITOFMEASID=2;

 update T_DSubItems set AUXTOTQTYPERC=AUXQTY,AUXTOTQTYGM=AUXQTY*pWeightKg
  where DYELINEID=pDyeLineID  and AuxTypeID=1 and AUXINCDECBY=0;

 update T_DSubItems set AUXTOTQTYPERC=((AUXQTY*AUXINCDECBY)/100)+AUXQTY,AUXTOTQTYGM=AUXQTY*pWeightKg
  where DYELINEID=pDyeLineID  and AuxTypeID=1 and AUXINCDECBY<>0;



 update T_DSubItems set AUXTOTQTYPERC=AUXQTY,AUXTOTQTYGM=AUXTOTQTYPERC*pWeightKg*10
  where DYELINEID=pDyeLineID  and AuxTypeID=2 and AUXINCDECBY=0;



 update T_DSubItems set AUXTOTQTYPERC=((AUXQTY*AUXINCDECBY)/100)+AUXQTY,AUXTOTQTYGM=AUXTOTQTYPERC*pWeightKg*10
  where DYELINEID=pDyeLineID  and AuxTypeID=2 and AUXINCDECBY<>0;

END GetDyeLineSubItemUpdate;
/




PROMPT CREATE OR REPLACE Procedure  168 :: GetDMachineLookup
CREATE OR REPLACE Procedure GetDMachineLookup
(
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)

AS
BEGIN
  OPEN data_cursor for
    Select MACHINEID,MACHINENAME,CAPACITY AS LIQUOR,MAXCAPACITY    
    from T_DYEMACHINES order by MACHINEID;

END GetDMachineLookup;
/


PROMPT CREATE OR REPLACE Procedure  169 :: GetDBatchWOItemsInfo
CREATE OR REPLACE Procedure GetDBatchWOItemsInfo (
 data_cursor IN OUT pReturnData.c_Records,
  pBATCHNO IN VARCHAR2
)
AS
BEGIN
 OPEN data_cursor FOR
 select a.DBATCHID,a.BATCHNO,a.BATCHDATE,b.ORDERNO,GetfncWOBType(b.OrderNo) as btype,b.ORDERLINEITEM,
 b.QUANTITY,b.SQUANTITY,f.UNITOFMEAS,b.SUNITOFMEASID,b.SHADE,b.REMARKS,d.CLIENTNAME,e.FABRICTYPE,
 g.KNITMCDIAGAUGE,g.Width,g.FINISHEDGSM,b.YARNBATCHNO,DYEDLOTNO,getFncYarnDes(b.ORDERLINEITEM) as YarnDesc
 from T_DBATCH a,T_DBATCHITEMS b,T_WorkOrder c,T_CLIENT d,T_FABRICTYPE e,T_UNITOFMEAS f,T_ORDERITEMS g
 where a.DBATCHID=b.DBATCHID and  b.ORDERNO=c.ORDERNO and  c.CLIENTID=d.CLIENTID and b.ORDERLINEITEM=g.ORDERLINEITEM and
        b.FABRICTYPEID=e.FABRICTYPEID and b.PUNITOFMEASID=f.UNITOFMEASID and a.BATCHNO=pBATCHNO;   

END GetDBatchWOItemsInfo;
/




PROMPT CREATE OR REPLACE Procedure  170 :: getDSUBHEADINFO
CREATE OR REPLACE Procedure getDSUBHEADINFO
(
  pDYELINEID varchar2,
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
  OPEN data_cursor for
	select b.DYELINEID,b.HEADID,b.HEADORDER,a.HEADNAME,b.HEADCOMMENTS
 	from T_DYELINEHEAD a,T_DSUBHEADS b 
	WHERE a.HEADID=b.HEADID and b.DYELINEID=pDYELINEID
 	order by b.HEADORDER;	

END  getDSUBHEADINFO;
/
 

PROMPT CREATE OR REPLACE Procedure  171 :: GETDHeadOrderChange
CREATE OR REPLACE Procedure GETDHeadOrderChange(
	pChangeType IN NUMBER,
  	pDYELINEID IN NUMBER,
	pCurPreviousHeadOrder IN NUMBER,
	pCurHeadOrder IN NUMBER,
	pCurNextHeadOrder IN NUMBER,
  	pRecsAffected out NUMBER
)
AS
BEGIN
if pChangeType=2 then
	UPDATE T_DSUBHEADS SET HEADORDER=999  WHERE HEADORDER=pCurNextHeadOrder AND DYELINEID=pDYELINEID;
	UPDATE T_DSUBHEADS SET HEADORDER=pCurNextHeadOrder WHERE HEADORDER=pCurHeadOrder AND DYELINEID=pDYELINEID;
	UPDATE T_DSUBHEADS SET HEADORDER=pCurHeadOrder WHERE HEADORDER=999 AND DYELINEID=pDYELINEID;
elsif pChangeType=1 then
	UPDATE T_DSUBHEADS SET HEADORDER=999  WHERE HEADORDER=pCurPreviousHeadOrder AND DYELINEID=pDYELINEID;
	UPDATE T_DSUBHEADS SET HEADORDER=pCurPreviousHeadOrder WHERE HEADORDER=pCurHeadOrder AND DYELINEID=pDYELINEID;
	UPDATE T_DSUBHEADS SET HEADORDER=pCurHeadOrder WHERE HEADORDER=999 AND DYELINEID=pDYELINEID;
end if;
   pRecsAffected := SQL%ROWCOUNT;
END GETDHeadOrderChange;
/



PROMPT CREATE OR REPLACE Procedure  172 :: InsertRecWithIdentityDyeLine
CREATE OR REPLACE Procedure InsertRecWithIdentityDyeLine  (
  pStrSql IN VARCHAR2,
  pIdentityName IN VARCHAR2,
  pIdentityFld IN VARCHAR2,
  pCurIdentityVal OUT NUMBER,
  pRecsAffected out NUMBER
)
AS
  tmpSql VARCHAR2(1000);
  restSql VARCHAR2(1000);
  insertSql VARCHAR2(1000);
  tmpPos NUMBER;
BEGIN

  execute immediate 'select ' || pIdentityName || '.NEXTVAL from sys.dual'
  into pCurIdentityVal;

  tmpPos := instr(pStrSql, '(', 1, 1);
  tmpSql := substr(pStrSql, 1, tmpPos);
  restSql := substr(pStrSql, tmpPos+1);
  insertSql := tmpSql || pIdentityFld || ',DPARENT,';

  tmpPos := instr(restSql, ' values (', 1, 1);
  tmpSql := substr(restSql, 1, tmpPos);
  restSql := substr(restSql, tmpPos+9);
  insertSql := insertSql || tmpSql || ' values (' ||
          TO_CHAR(pCurIdentityVal) ||','|| TO_CHAR(pCurIdentityVal) ||',' || restSql;

  execute immediate insertSql;
  pRecsAffected := SQL%ROWCOUNT;

END InsertRecWithIdentityDyeLine;
/



PROMPT CREATE OR REPLACE Procedure  173 :: getDSUBHEADINFO
CREATE OR REPLACE Procedure getDSUBHEADINFO
(
  pDYELINEID varchar2,
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
  OPEN data_cursor for
	select b.DYELINEID,b.HEADID,b.HEADORDER,a.HEADNAME,b.HEADCOMMENTS
 	from T_DYELINEHEAD a,T_DSUBHEADS b 
	WHERE a.HEADID=b.HEADID and b.DYELINEID=pDYELINEID
 	order by b.HEADORDER;	

END  getDSUBHEADINFO;
/
 

PROMPT CREATE OR REPLACE Procedure  174 :: GETDHeadOrderChange
CREATE OR REPLACE Procedure GETDHeadOrderChange(
	pChangeType IN NUMBER,
  	pDYELINEID IN NUMBER,
	pCurPreviousHeadOrder IN NUMBER,
	pCurHeadOrder IN NUMBER,
	pCurNextHeadOrder IN NUMBER,
  	pRecsAffected out NUMBER
)
AS
BEGIN
if pChangeType=2 then
	UPDATE T_DSUBHEADS SET HEADORDER=999  WHERE HEADORDER=pCurNextHeadOrder AND DYELINEID=pDYELINEID;
	UPDATE T_DSUBHEADS SET HEADORDER=pCurNextHeadOrder WHERE HEADORDER=pCurHeadOrder AND DYELINEID=pDYELINEID;
	UPDATE T_DSUBHEADS SET HEADORDER=pCurHeadOrder WHERE HEADORDER=999 AND DYELINEID=pDYELINEID;
elsif pChangeType=1 then
	UPDATE T_DSUBHEADS SET HEADORDER=999  WHERE HEADORDER=pCurPreviousHeadOrder AND DYELINEID=pDYELINEID;
	UPDATE T_DSUBHEADS SET HEADORDER=pCurPreviousHeadOrder WHERE HEADORDER=pCurHeadOrder AND DYELINEID=pDYELINEID;
	UPDATE T_DSUBHEADS SET HEADORDER=pCurHeadOrder WHERE HEADORDER=999 AND DYELINEID=pDYELINEID;
end if;
   pRecsAffected := SQL%ROWCOUNT;
END GETDHeadOrderChange;
/




PROMPT CREATE OR REPLACE Procedure  175 :: GetCopyDyeline
Create or Replace Procedure GetCopyDyeline (
  pFromUDyelineId IN VARCHAR2,
  pToUDyelineId IN VARCHAR2,
  pEmployeeID IN VARCHAR2,
  pRecsAffected out NUMBER
)
AS
  pNewDyelineID T_DYELINE.DYELINEID%TYPE;
  pTEMPDyelineID T_DYELINE.DYELINEID%TYPE;
  pNewItemId T_DSubItems.DSubItemsId%TYPE;
  tmpCheck NUMBER;
  faults EXCEPTION;
BEGIN
      SELECT COUNT(*) into tmpCheck FROM T_DYELINE WHERE UDYELINEID IN (SELECT UDYELINEID  FROM T_DYELINE WHERE UDYELINEID=pToUDyelineId);

  if tmpCheck=1 then
 	pRecsAffected :=99;
  else
      	select seq_DYESUBITEMSID.NEXTVAL into pNewDyelineID from sys.dual;
      	SELECT DYELINEID into pTEMPDyelineID FROM T_DYELINE WHERE UDYELINEID=pFromUDyelineId;

      	INSERT INTO T_DYELINE(DYELINEID,DBATCHID,UDYELINEID,DYELINENO,DYELINEDATE,MACHINEID,
  	DLIQUOR,DWEIGHT,PACKAGECOUNT,DYEINGPROGRAM,PRODDATE,FINISHEDWEIGHT,DYEINGSHIFT,DCOMMENTS,
  	DPARENT,DRECOUNT,DCOMPLETE,DREDYEINGCOUNT,BPOSTEDTOSTOCK,DSTARTDATETIME,DENDDATETIME,DLIQUORRATIO,EmployeeID)
  		select pNewDyelineID,(SELECT DBATCHID FROM T_DBATCH WHERE BATCHNO=pToUDyelineId),pToUDyelineId,
  		(SELECT max(DYELINENO)+1 FROM T_DYELINE WHERE MACHINEID=MACHINEID AND DYELINEDATE=DYELINEDATE),
		DYELINEDATE,MACHINEID,(SELECT SUM(QUANTITY) FROM T_DBATCHITEMS
			WHERE DBATCHID=(SELECT DBATCHID FROM T_DBATCH WHERE BATCHNO=pToUDyelineId)
			GROUP BY DBATCHID),
			(SELECT SUM(QUANTITY) FROM T_DBATCHITEMS
			WHERE DBATCHID=(SELECT DBATCHID FROM T_DBATCH WHERE BATCHNO=pToUDyelineId)
			GROUP BY DBATCHID),
		PACKAGECOUNT,DYEINGPROGRAM,PRODDATE,0,DYEINGSHIFT,'',
  		pNewDyelineID,DRECOUNT,0,DREDYEINGCOUNT,BPOSTEDTOSTOCK,'','',1,pEmployeeID
   		FROM T_DYELINE WHERE DYELINEID=pTEMPDyelineID;

      	pRecsAffected := SQL%ROWCOUNT;

       	for  rec in (SELECT HEADID FROM T_DSUBHEADS WHERE DYELINEID=pTEMPDyelineID)
       	LOOP
                insert into T_DSUBHEADS(DYELINEID,HEADID,HEADORDER,HEADCOMMENTS)
  		SELECT pNewDyelineID,HEADID,HEADORDER,HEADCOMMENTS FROM T_DSUBHEADS
  		WHERE DYELINEID=pTEMPDyelineID and HEADID=rec.HEADID;

  		select seq_DYESUBITEMSID.NEXTVAL into pNewItemId from sys.dual;
        	for  rec1 in (SELECT DSubItemsId FROM T_DSubItems WHERE DYELINEID=pTEMPDyelineID and HEADID=rec.HEADID)
         	LOOP
                 	insert into T_DSubItems(DSUBITEMSID,DYELINEID,HEADID,AUXTYPEID,AUXID,AUXQTY,UNITOFMEASID,
   			AUXINCDECBY,AUXADDITION,AUXADDCOUNT,AUXTOTQTYPERC,AUXTOTQTYGM)
   			select pNewItemId,pNewDyelineID,HEADID,AUXTYPEID,AUXID,AUXQTY,UNITOFMEASID,
   			AUXINCDECBY,AUXADDITION,AUXADDCOUNT,AUXTOTQTYPERC,(AuxTotQtyGm-NVL(AuxAddition,0))
   			from T_DSubItems where DSUBITEMSID=rec1.DSubItemsId;
   			select seq_DYESUBITEMSID.NEXTVAL into pNewItemId from sys.dual;
         	END loop;
	END loop;
  pRecsAffected := SQL%ROWCOUNT+pRecsAffected;
 /*===============================================================*/
 IF (pRecsAffected=2)
  THEN
         COMMIT;
 ELSE
  RAISE faults;
 END IF;

END IF;

 EXCEPTION
  WHEN faults THEN ROLLBACK;
END GetCopyDyeline;
/

PROMPT CREATE OR REPLACE Procedure  176 :: GetReDyeline
CREATE OR REPLACE Procedure GetReDyeline (
  pFromUDyelineId IN VARCHAR2,
  pEmployeeID IN VARCHAR2,
  pRecsAffected out NUMBER
) 
AS 
  pNewDBATCHID T_DBATCH.DBATCHID%TYPE;
  pTEMDBATCHID T_DBATCH.DBATCHID%TYPE;
  pNewPID T_DBATCHITEMS.PID%TYPE;

  pNewDyelineID T_DYELINE.DYELINEID%TYPE;
  pTEMPDyelineID T_DYELINE.DYELINEID%TYPE;
  pNewItemId T_DSubItems.DSubItemsId%TYPE;
  tmpCheck NUMBER;
  faults EXCEPTION;
BEGIN 
      SELECT COUNT(*) into tmpCheck FROM T_DYELINE WHERE UDYELINEID IN (SELECT UDYELINEID  FROM T_DYELINE WHERE UDYELINEID=pFromUDyelineId ||'R');

  if tmpCheck=1 then
	pRecsAffected :=99;
  else
      select SEQ_DBATCHID.NEXTVAL into pNewDBATCHID from sys.dual;

	SELECT DBATCHID into pTEMDBATCHID FROM T_DYELINE WHERE UDYELINEID=pFromUDyelineId;
	INSERT INTO T_DBATCH(DBATCHID,BATCHNO,BATCHDATE,EXECUTE)
	SELECT pNewDBATCHID,BATCHNO || 'R',BATCHDATE,EXECUTE FROM T_DBATCH WHERE DBATCHID=pTEMDBATCHID; 

		select seq_BatchItemPID.NEXTVAL into pNewPID from sys.dual;
      		for  rec2 in (SELECT PID FROM T_DBATCHITEMS WHERE DBATCHID=pTEMDBATCHID)
        	LOOP
			INSERT INTO T_DBATCHITEMS (PID,DBATCHID,BATCHITEMSL,FABRICTYPEID,ORDERLINEITEM,QUANTITY,SQUANTITY,              
			PUNITOFMEASID,SUNITOFMEASID,SHADE,REMARKS,ORDERNO,CURRENTSTOCK) 
			SELECT pNewPID,pNewDBATCHID,BATCHITEMSL,FABRICTYPEID,ORDERLINEITEM,QUANTITY,SQUANTITY,              
			PUNITOFMEASID,SUNITOFMEASID,SHADE,REMARKS,ORDERNO,CURRENTSTOCK FROM T_DBATCHITEMS
			WHERE PID=rec2.PID;
			select seq_BatchItemPID.NEXTVAL into pNewPID from sys.dual;
        	END loop;


      select seq_DYESUBITEMSID.NEXTVAL into pNewDyelineID from sys.dual;
      SELECT DYELINEID into pTEMPDyelineID FROM T_DYELINE WHERE UDYELINEID=pFromUDyelineId;

      INSERT INTO T_DYELINE(DYELINEID,DBATCHID,UDYELINEID,DYELINENO,DYELINEDATE,MACHINEID,
		DLIQUOR,DWEIGHT,PACKAGECOUNT,DYEINGPROGRAM,PRODDATE,FINISHEDWEIGHT,DYEINGSHIFT,DCOMMENTS,
		DPARENT,DRECOUNT,DCOMPLETE,DREDYEINGCOUNT,BPOSTEDTOSTOCK,DSTARTDATETIME,DENDDATETIME,DLIQUORRATIO,EmployeeID)
		select pNewDyelineID,pNewDBATCHID,UDYELINEID|| 'R',(SELECT max(DYELINENO)+1 FROM T_DYELINE 
		WHERE MACHINEID=MACHINEID AND DYELINEDATE=DYELINEDATE),DYELINEDATE,MACHINEID,              
 		DLIQUOR,DWEIGHT,PACKAGECOUNT,DYEINGPROGRAM,PRODDATE,0,DYEINGSHIFT,'',
		DPARENT,DRECOUNT,0,DREDYEINGCOUNT+1,BPOSTEDTOSTOCK,'','',DLIQUORRATIO,pEmployeeID   
 		FROM T_DYELINE WHERE DYELINEID=pTEMPDyelineID;

	pRecsAffected := SQL%ROWCOUNT;

       for  rec in (SELECT HEADID FROM T_DSUBHEADS WHERE DYELINEID=pTEMPDyelineID)
        LOOP
                insert into T_DSUBHEADS(DYELINEID,HEADID,HEADORDER,HEADCOMMENTS)
		SELECT pNewDyelineID,HEADID,HEADORDER,HEADCOMMENTS FROM T_DSUBHEADS
		WHERE DYELINEID=pTEMPDyelineID and HEADID=rec.HEADID;

		select seq_DYESUBITEMSID.NEXTVAL into pNewItemId from sys.dual;
      		for  rec1 in (SELECT DSubItemsId FROM T_DSubItems WHERE DYELINEID=pTEMPDyelineID and HEADID=rec.HEADID)
        	LOOP
                	insert into T_DSubItems(DSUBITEMSID,DYELINEID,HEADID,AUXTYPEID,AUXID,AUXQTY,UNITOFMEASID,
			AUXINCDECBY,AUXADDITION,AUXADDCOUNT,AUXTOTQTYPERC,AUXTOTQTYGM)
			select pNewItemId,pNewDyelineID,HEADID,AUXTYPEID,AUXID,AUXQTY,UNITOFMEASID,
			AUXINCDECBY,AUXADDITION,AUXADDCOUNT,AUXTOTQTYPERC,(AuxTotQtyGm-NVL(AuxAddition,0)) 
			from T_DSubItems where DSUBITEMSID=rec1.DSubItemsId;
			select seq_DYESUBITEMSID.NEXTVAL into pNewItemId from sys.dual;
        	END loop;
        END loop;

  pRecsAffected := SQL%ROWCOUNT+pRecsAffected;

	IF (pRecsAffected=2)
		THEN
        	COMMIT;
	ELSE
		RAISE faults;
	END IF;
END IF;
	EXCEPTION
		WHEN faults THEN ROLLBACK;

END GetReDyeline; 
/


 
PROMPT CREATE OR REPLACE Procedure  177 :: getTreeDyeLineList
CREATE OR REPLACE Procedure getTreeDyeLineList (
  io_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pUDyeLine IN VARCHAR2 DEFAULT NULL,
  sDate IN date,
  eDate IN date
)
AS
BEGIN

  if pQueryType=0 then
    OPEN io_cursor FOR
    select DyeLineId,UDyeLineId,DCOMPLETE from T_DyeLine
    where DyeLineDate>=SDate and DyeLineDate<=EDate
    order by UDyeLineId desc,MACHINEID;

  elsif pQueryType=1 then
    OPEN io_cursor FOR
    select DyeLineId,UDyeLineId,DyeLineDate,DCOMPLETE from T_DyeLine
    where DyeLineDate>=SDate and DyeLineDate<=EDate
    order by DyeLineDate desc, UDyeLineId desc,MACHINEID;

  elsif pQueryType=2 then
    OPEN io_cursor FOR
    select DyeLineId,UDyeLineId,DyeLineDate,DCOMPLETE from T_DyeLine
    where DyeLineId<>DPARENT and DyeLineDate>=SDate and DyeLineDate<=EDate
    order by DyeLineDate desc, UDyeLineId desc,MACHINEID;

  elsif pQueryType=3 then
    OPEN io_cursor FOR
    select DyeLineId,UDyeLineId,DyeLineDate,DCOMPLETE from T_DyeLine
    where DyeLineDate>=SDate and DyeLineDate<=EDate
    order by DyeLineDate desc, UDyeLineId desc,MACHINEID;

  elsif pQueryType=9999 then
    OPEN io_cursor FOR
    select UDyeLineId,DCOMPLETE from T_DyeLine
    where DyeLineDate>=SDate and DyeLineDate<=EDate and
    Upper(UDyeLineId) Like UDyeLineId;
  end if;

END getTreeDyeLineList;
/



PROMPT CREATE OR REPLACE Procedure  178 :: GetDyeBatchLookup
CREATE OR REPLACE Procedure GetDyeBatchLookup
(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType in number
)
AS
BEGIN
if pQueryType=0 then
    OPEN data_cursor for
        Select x.DBATCHID AS DBATCHID,x.BATCHNO AS BATCHNO, y.PQTY AS PQTY, y.SQTY AS SQTY  
        from T_DBatch x,(select a.DBATCHID,a.BATCHNO,SUM(b.QUANTITY) as PQTY,SUM(b.SQUANTITY) as SQTY
	from T_DBATCH a,T_DBATCHITEMS b
	where a.DBATCHID=b.DBATCHID GROUP BY a.DBATCHID,a.BATCHNO) y WHERE x.DBATCHID=y.DBATCHID AND
	X.DBATCHID NOT IN (SELECT DBATCHID FROM T_DYELINE)
	ORDER BY x.BATCHNO; 
elsif pQueryType=1 then	
    OPEN data_cursor for
        Select x.DBATCHID AS DBATCHID,x.BATCHNO AS BATCHNO, 0 AS PQTY, 0 AS SQTY  
        from T_DBatch x		
	ORDER BY x.BATCHNO; 
elsif pQueryType=2 then	
    OPEN data_cursor for
        Select x.DBATCHID AS DBATCHID,x.BATCHNO AS BATCHNO, 0 AS PQTY, 0 AS SQTY  
        from T_DBatch x
	ORDER BY x.BATCHNO; 	
End If;	
END GetDyeBatchLookup;
/

PROMPT CREATE OR REPLACE Procedure  179 :: getTreeDyeProfileInfoList
CREATE OR REPLACE Procedure getTreeDyeProfileInfoList(
  io_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER
)
AS
BEGIN
 /* For Profile Description*/
  if pQueryType=0 then
    OPEN io_cursor FOR
    select a.PROFILEID,a.PROFILEDESC,b.headid,b.headname,b.auxtypeid from  t_dyelineprofile a,t_dyelinehead b where a.headid=b.headid
    order by b.headID;

  end if;
END getTreeDyeProfileInfoList;
/


PROMPT CREATE OR REPLACE Procedure  180 :: GetDyeHeadProfilePickUp
CREATE OR REPLACE Procedure GetDyeHeadProfilePickUp(
  data_cursor IN OUT pReturnData.c_Records,
  pHeadID IN NUMBER
)
AS
BEGIN
    open data_cursor for
    select HEADID,PROFILEID,PROFILEDESC    
    from T_DyelineProfile where HEADID=pHeadID;

END GetDyeHeadProfilePickUp;
/



PROMPT CREATE OR REPLACE Procedure  181 :: InsertPtoDyeline
CREATE OR REPLACE Procedure InsertPtoDyeline (
  pDyelineId IN NUMBER, 
  pHeadId IN NUMBER, 
  pProfileId IN VARCHAR2
) 
AS 
  pCurIdentityVal T_DSubItems.DSubItemsId%TYPE;
  cursor c1 is 
  select HeadId, AuxTypeId, AuxId, AuxQty, UnitOfMeasId
  from T_DProfileItems
  where HeadId=pHeadId and ProfileId=pProfileId ORDER BY PROFILEITEMSL;
  myrec c1%rowtype;
  pLiquor NUMBER;
  pWeight NUMBER; 
  sqlText varchar2(1000);
  pPerc varchar2(20);
  pQty varchar2(20);
  tmpCheck NUMBER;
BEGIN 

  open c1;
  loop 	
    fetch c1 into myrec;    
    exit when c1%notfound;

	SELECT COUNT(*) into tmpCheck FROM T_DSUBHEADS WHERE DYELINEID=pDyelineId AND  HEADID=pHeadId;

  if tmpCheck=0 then
	insert into T_DSUBHEADS(DYELINEID,HEADID,HEADORDER,HEADCOMMENTS)
		VALUES(pDyelineID,pHeadId,(SELECT HEADORDER FROM T_DYELINEHEAD WHERE HeadId=pHeadId),'') ;
  END IF;


    select seq_DYESUBITEMSID.NEXTVAL into pCurIdentityVal from sys.dual;

    select dLiquor, dWeight into pLiquor, pWeight from T_Dyeline where DyelineId=pDyelineId;

    insert into T_DSubItems 
    (DSubItemsId, DyelineId, HeadId, AuxTypeId, AuxId, AuxQty, UnitOfMeasId, AuxAddCount,  
    AuxTotQtyPerc, AuxTotQtyGm) values
    (pCurIdentityVal, pDyelineId, myrec.HeadId, myrec.AuxTypeId, myrec.AuxId, 
    myrec.AuxQty, myrec.UnitOfMeasId,0, 
    DECODE(myrec.AuxTypeId,2, myrec.AuxQty,NULL), 
    DECODE(myrec.UnitOfMeasId, 1, myrec.AuxQty  * pLiquor, 2, myrec.AuxQty * pWeight*10, 0));

    if myrec.AuxTypeId = 2 then
       pPerc := TO_CHAR(myrec.AuxQty);
    else
       pPerc := 'NULL';
    end if;
    if myrec.UnitOfMeasId = 1 then
       pQty := TO_CHAR(myrec.AuxQty  * pLiquor);
    elsif myrec.UnitOfMeasId = 2 then
       pQty := TO_CHAR(myrec.AuxQty * pWeight*10);
    else
       pQty := '0';
    end if;

    sqlText := 'insert into T_DSubItems (DSubItemsId, DyelineId, HeadId, AuxTypeId, ' ||
               'AuxId, AuxQty, UnitOfMeasId, AuxAddCount, AuxTotQtyPerc, AuxTotQtyGm) values (' ||
               TO_CHAR(pCurIdentityVal) || ',' || TO_CHAR(pDyelineId) || ',' || 
               TO_CHAR(myrec.HeadId) || ',' || TO_CHAR(myrec.AuxTypeId) || ','|| 
               TO_CHAR(myrec.AuxId) || ',' || TO_CHAR(myrec.AuxQty) || ',' || 
               TO_CHAR(myrec.UnitOfMeasId) || ',0,' || pPerc || ',' || pQty || ')'; 

  end loop;
  close c1;

END InsertPtoDyeline; 
/  


PROMPT CREATE OR REPLACE Procedure  182 :: GetDyeHeadProfilePickUp
CREATE OR REPLACE Procedure GetDyeHeadProfilePickUp(
  data_cursor IN OUT pReturnData.c_Records,
  pHeadID IN NUMBER
)
AS
BEGIN
    open data_cursor for
    select HEADID,PROFILEID,PROFILEDESC    
    from T_DyelineProfile where HEADID=pHeadID;

END GetDyeHeadProfilePickUp;
/


------------------------------------------------------------- 
-- End of Textile Dyeline SP
------------------------------------------------------------- 


PROMPT CREATE OR REPLACE Procedure  183 :: GETDyeProfileInfo
CREATE OR REPLACE Procedure GETDyeProfileInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  many_cursor IN OUT pReturnData.c_Records,
  pPROFILEID VARCHAR,
  pHeadid number
)
AS
BEGIN
    open one_cursor for
    select a.PROFILEID,a.PROFILEDESC,b.headid,b.headname,b.auxtypeid from t_dyelineprofile a,t_dyelinehead b where a.headid=b.headid and PROFILEID= pPROFILEID and a.headid=pHeadid;

    open many_cursor for
    select  PID,HEADID,PROFILEID,PROFILEITEMSL,AUXTYPEID,AUXID,AUXQTY,UNITOFMEASID
    from T_DPROFILEITEMS
    where PROFILEID=pPROFILEID and headid=pHeadid order by PROFILEITEMSL ;
END GETDyeProfileInfo;
/


PROMPT CREATE OR REPLACE Procedure  184 :: GETDyeHeadList
CREATE OR REPLACE Procedure GETDyeHeadList
(
  Data_cursor IN OUT pReturnData.c_Records

)
AS
BEGIN
    open Data_cursor for
    select HEADID,HEADNAME FROM T_DYELINEHEAD ;

END GETDyeHeadList;
/



PROMPT CREATE OR REPLACE Procedure  185 :: GETDyeProfileList
CREATE OR REPLACE Procedure GETDyeProfileList
(
  Data_cursor IN OUT pReturnData.c_Records

)
AS
BEGIN
    open Data_cursor for
    select ATOZID  FROM t_atoz ;

END GETDyeProfileList;
/

PROMPT CREATE OR REPLACE Procedure  186 :: GetDyeAuxNameLookup
CREATE OR REPLACE Procedure GetDyeAuxNameLookup
(
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
/*if the Value is 0 then retun all the Data */

  OPEN data_cursor for
  select A.AUXID,A.AUXNAME from T_AUXILIARIES A
  WHERE	AUXTYPEID=1
  ORDER BY AUXNAME;

END GetDyeAuxNameLookup;
/

PROMPT CREATE OR REPLACE Procedure  187 :: GetFabricRcvdAfterKnitPickUp
Create or Replace Procedure GetFabricRcvdAfterKnitPickUp
(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pORDERNO IN NUMBER,
  pOrderlineItem varchar2,
  pshadeGroupID IN NUMBER,
  pStockDate DATE
)
AS
BEGIN
/* FABRIC RECEIVED FROM KNITTING FLOOR(ATLGYF) AFTER KNITTING */
if pQueryType=5 then
    open data_cursor for
     select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,x.SUPPLIERNAME,b.YARNBATCHNO,
    b.OrderlineItem,b.YARNTYPEID,b.FABRICTYPEID,b.YARNCOUNTID,YarnCount,YarnType,'' AS Shade,b.PUnitOfMeasId,K.UNITOFMEAS as sunit,B.SUNITOFMEASID,
    f.UnitOfMeas,b.DyedLotno,'' AS subconid,'' AS SubConName,i.SHADEGROUPID,i.SHADEGROUPNAME,j.FABRICTYPE,
    0 as YIssuedTotal,sum(quantity*ATLGyF) as CurrentStock,sum(squantity*ATLGyF) as cursqty,b.yarnfor
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,T_ShadeGroup i,T_fabricType j,T_UnitOfMeas k,T_supplier x
    where a.StockID=b.StockID and
    b.SHADEGROUPID=i.SHADEGROUPID and
	b.supplierid=x.supplierid(+) and
    b.FABRICTYPEID=j.FABRICTYPEID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.sUnitOfMeasID=K.UnitOfMeasID(+) and
    STOCKTRANSDATE <= pStockDate  and
    b.ORDERNO=pORDERNO and b.SHADEGROUPID=pshadeGroupID
    group by b.ORDERNO,b.OrderlineItem,b.SUPPLIERID,x.SUPPLIERNAME,b.YARNTYPEID,b.FABRICTYPEID,b.YARNCOUNTID,YarnCount,YarnType,b.PUnitOfMeasId,f.UnitOfMeas,b.YARNBATCHNO,
    i.SHADEGROUPID,i.SHADEGROUPNAME,j.FABRICTYPE,b.DyedLotno,K.UNITOFMEAS,B.SUNITOFMEASID,b.yarnfor 
    having(sum(quantity*ATLGYF) >0) ORDER BY btype;

/* FABRIC RECEIVED FROM KNITTING SUBCON(KSCONGYS) AFTER KNITTING */
elsif pQueryType= 6 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,x.SUPPLIERNAME,b.YARNBATCHNO,
    b.OrderlineItem,b.YARNTYPEID,b.FABRICTYPEID,b.YARNCOUNTID,YarnCount,YarnType,'' AS Shade,b.PUnitOfMeasId,l.UNITOFMEAS as sunit,b.SUNITOFMEASID,
    f.UnitOfMeas,'' AS DyedLotno,i.SHADEGROUPID,i.SHADEGROUPNAME,j.FABRICTYPE,b.subconid,k.subconname,
    0 as YIssuedTotal,sum(Quantity*KSCONGYS) CurrentStock,sum(squantity*KSCONGYS) as cursqty,b.yarnfor
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,T_ShadeGroup i,T_fabricType j,t_subcontractors k,T_UnitOfMeas l,T_supplier x
    where a.StockID=b.StockID and
    b.SHADEGROUPID=i.SHADEGROUPID and
    b.FABRICTYPEID=j.FABRICTYPEID and
	b.supplierid=x.supplierid(+) and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.sUnitOfMeasID=l.UnitOfMeasID(+) and
    b.subconid=k.subconid and
    STOCKTRANSDATE <= pStockDate   and
    b.ORDERNO=pORDERNO and b.SHADEGROUPID=pshadeGroupID
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.FABRICTYPEID,b.YARNCOUNTID,YarnCount,YarnType,b.SUPPLIERID,x.SUPPLIERNAME,
    b.PUnitOfMeasId,f.UnitOfMeas,b.YARNBATCHNO,i.SHADEGROUPID,i.SHADEGROUPNAME,j.FABRICTYPE,b.subconid,
	k.subconname,l.UNITOFMEAS,b.SUNITOFMEASID,b.yarnfor
    having sum(Quantity*KSCONGYS)>0  ORDER BY btype;

/* FABRIC RECEIVED FROM KNITTING FLOOR(ATLDYF) AFTER KNITTING */
elsif pQueryType=12 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,x.SUPPLIERNAME,b.YARNBATCHNO,
    b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,YarnType,b.PUnitOfMeasId,f.UnitOfMeas,
	b.DyedLotno,j.SHADEGROUPID,j.SHADEGROUPNAME,b.FABRICTYPEID,k.FABRICTYPE,l.UNITOFMEAS as sunit,b.SUNITOFMEASID,
    0 as YIssuedTotal,
    sum(Quantity*ATLDYF) CurrentStock,sum(squantity*ATLDYF) as cursqty,i.subconname,b.subconid,b.yarnfor
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_subcontractors i,T_ShadeGroup j,T_fabricType k,T_UnitOfMeas l,T_supplier x
    where a.StockID=b.StockID and
    b.SHADEGROUPID=j.SHADEGROUPID and
    b.FABRICTYPEID=k.FABRICTYPEID and
	b.supplierid=x.supplierid(+) and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.sUnitOfMeasID=l.UnitOfMeasID(+) and
    b.subconid=i.subconid and
    STOCKTRANSDATE <= pStockDate and
    b.ORDERNO=pORDERNO  and b.SHADEGROUPID=pshadeGroupID
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,b.SUPPLIERID,x.SUPPLIERNAME,
    YarnType,b.PUnitOfMeasId,f.UnitOfMeas,b.YARNBATCHNO,b.DyedLotno,i.subconname,b.subconid,j.SHADEGROUPID,
    j.SHADEGROUPNAME,b.FABRICTYPEID,k.FABRICTYPE,l.UNITOFMEAS,b.SUNITOFMEASID,b.yarnfor
    having sum(Quantity*ATLDYF)>0 ORDER BY btype;

/* FABRIC RECEIVED FROM KNITTING SUBCON(KSCONDYS) AFTER KNITTING */
elsif pQueryType=13 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,x.SUPPLIERNAME,b.YARNBATCHNO,
    b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,YarnType,b.PUnitOfMeasId,f.UnitOfMeas,
	b.DyedLotno,j.SHADEGROUPID,j.SHADEGROUPNAME,b.FABRICTYPEID,k.FABRICTYPE,l.UNITOFMEAS as sunit,b.SUNITOFMEASID,
    0 as YIssuedTotal,sum(Quantity*KSCONDYS) CurrentStock,sum(squantity*KSCONDYS) as cursqty,i.subconname,b.subconid,b.yarnfor
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_subcontractors i,T_ShadeGroup j,T_fabricType k,T_UnitOfMeas l,T_supplier x
    where a.StockID=b.StockID and
    b.SHADEGROUPID=j.SHADEGROUPID and
    b.FABRICTYPEID=k.FABRICTYPEID and
	b.supplierid=x.supplierid(+) and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
     b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.sUnitOfMeasID=l.UnitOfMeasID(+) and
    b.subconid=i.subconid and
    STOCKTRANSDATE <= pStockDate and
    b.ORDERNO=pORDERNO  and b.SHADEGROUPID=pshadeGroupID
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,b.SUPPLIERID,x.SUPPLIERNAME,
	YarnType,b.PUnitOfMeasId,f.UnitOfMeas,b.YARNBATCHNO,b.DyedLotno,i.subconname,b.subconid,j.SHADEGROUPID,
    j.SHADEGROUPNAME,b.FABRICTYPEID,k.FABRICTYPE,l.UNITOFMEAS,b.SUNITOFMEASID,b.yarnfor
    having sum(Quantity*KSCONDYS)>0 ORDER BY btype;
end if;
END GetFabricRcvdAfterKnitPickUp;
/




PROMPT CREATE OR REPLACE Procedure  188 :: getTreeDyeHeadnfoList
CREATE OR REPLACE Procedure getTreeDyeHeadnfoList(
  io_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER
)
AS
BEGIN
 /* For Parts Name*/
  if pQueryType=0 then
    OPEN io_cursor FOR
    select a.HEADID,a.HEADNAME from  T_Dyelinehead a
    order by a.HEADid desc;

  end if;
END getTreeDyeHeadnfoList;
/



PROMPT CREATE OR REPLACE Procedure  189 :: GETFebReceviedFromFloorMany
CREATE OR REPLACE Procedure GETFebReceviedFromFloorMany (
  pStockId IN NUMBER,
  pStrSql2 IN VARCHAR2,
  pIdentityName IN VARCHAR2,
  pIdentityFld1 IN VARCHAR2,
  pIdentityFld2 IN VARCHAR2,
  pCurIdentityVal OUT NUMBER,
  pRecsAffected out NUMBER
)
AS
  tmpSql VARCHAR2(1000);
  restSql VARCHAR2(1000);
  insertSql VARCHAR2(1000);
  parentIdentityVal  NUMBER;
  tmpPos NUMBER;
  faults EXCEPTION;
BEGIN


/*========================Copy Section(102)======================*/
  execute immediate 'select ' || pIdentityName || '.NEXTVAL from sys.dual'
  into pCurIdentityVal;


  tmpPos := instr(pStrSql2, '(', 1, 1);
  tmpSql := substr(pStrSql2, 1, tmpPos);
  restSql := substr(pStrSql2, tmpPos+1);
  insertSql := tmpSql || pIdentityFld1 || ','|| pIdentityFld2 || ',';

  tmpPos := instr(restSql, ' values (', 1, 1);
  tmpSql := substr(restSql, 1, tmpPos);
  restSql := substr(restSql, tmpPos+9);

  insertSql := insertSql || tmpSql || ' values (' ||
          TO_CHAR(pCurIdentityVal) || ',' ||TO_CHAR(pStockId) || ',' || restSql;

  execute immediate insertSql;
 pRecsAffected := SQL%ROWCOUNT;
 /*===============================================================*/
	IF (pRecsAffected=1)
	THEN
        COMMIT;
	ELSE
		RAISE faults;
	END IF;


EXCEPTION
	WHEN faults THEN ROLLBACK;

END GETFebReceviedFromFloorMany;
/


PROMPT CREATE OR REPLACE Procedure  190 :: GETFebReceviedFromFloorM2One
CREATE OR REPLACE Procedure GETFebReceviedFromFloorM2One (
  pStockId IN NUMBER,
  pStrSql1 IN VARCHAR2,
  pIdentityName IN VARCHAR2,
  pIdentityFld1 IN VARCHAR2,
  pIdentityFld2 IN VARCHAR2,
  pCurIdentityVal OUT NUMBER,
  pRecsAffected out NUMBER
)
AS
  tmpSql VARCHAR2(1000);
  restSql VARCHAR2(1000);
  insertSql VARCHAR2(1000);
  parentIdentityVal  NUMBER;
  tmpPos NUMBER;
  faults EXCEPTION;
BEGIN

/*========================Main Section(101)======================*/
  execute immediate 'select ' || pIdentityName || '.NEXTVAL from sys.dual'
  into pCurIdentityVal;


  parentIdentityVal:=pCurIdentityVal;

  tmpPos := instr(pStrSql1, '(', 1, 1);
  tmpSql := substr(pStrSql1, 1, tmpPos);
  restSql := substr(pStrSql1, tmpPos+1);
  insertSql := tmpSql || pIdentityFld1 || ','|| pIdentityFld2 || ',';

  tmpPos := instr(restSql, ' values (', 1, 1);
  tmpSql := substr(restSql, 1, tmpPos);
  restSql := substr(restSql, tmpPos+9);

  insertSql := insertSql || tmpSql || ' values (' ||
          TO_CHAR(pCurIdentityVal) || ',' ||TO_CHAR(pStockId) || ',' || restSql;

  execute immediate insertSql;
 pRecsAffected := SQL%ROWCOUNT;

 /*===============================================================*/
	IF (pRecsAffected=1)
	THEN
        COMMIT;
	ELSE
		RAISE faults;
	END IF;


EXCEPTION
	WHEN faults THEN ROLLBACK;

END GETFebReceviedFromFloorM2One;
/

PROMPT CREATE OR REPLACE Procedure  191 :: GetAuxChemicalLookUp
Create or Replace Procedure GetAuxChemicalLookUp
(
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN

  OPEN data_cursor for
  select AUXTYPEID, DYEBASEID, AUXID, AUXNAME
 from T_Auxiliaries
 where AUXTYPEID=1  ORDER BY AUXNAME;

END GetAuxChemicalLookUp;

/

PROMPT CREATE OR REPLACE Procedure  192 :: GETDyeHeadInfo
CREATE OR REPLACE Procedure GETDyeHeadInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  pHEADID number
)
AS
BEGIN
    open one_cursor for
    select HEADID,HEADNAME,HEADORDER,HEADMCWASH,AUXTYPEID FROM T_DYELINEHEAD WHERE HEADID= pHEADID ;

END GETDyeHeadInfo;
/


PROMPT CREATE OR REPLACE Procedure  193 :: GetDeleteDyelineHeadAndItems
Create or Replace Procedure GetDeleteDyelineHeadAndItems (
	pDYELINEID IN NUMBER,
  	pHEADID IN NUMBER,
	pDSUBITEMSID IN NUMBER,
	pRecsAffected out NUMBER
)
AS
  tmpCheck NUMBER;
  faults EXCEPTION;
BEGIN
	DELETE from T_DSubItems WHERE DSUBITEMSID=pDSUBITEMSID;
	pRecsAffected := SQL%ROWCOUNT;
	
      	SELECT COUNT(*) into tmpCheck FROM T_DSubItems WHERE DYELINEID=pDYELINEID AND HEADID=pHEADID;

  IF tmpCheck=0 then

 	DELETE FROM T_DSUBHEADS WHERE DYELINEID=pDYELINEID AND HEADID=pHEADID;
	pRecsAffected := SQL%ROWCOUNT;

  	 /*pRecsAffected := SQL%ROWCOUNT+pRecsAffected;*/

   END IF;
 /*===============================================================*/
 IF (pRecsAffected=1)
  THEN
         COMMIT;
 ELSE
  RAISE faults;
 END IF;


 EXCEPTION
  WHEN faults THEN ROLLBACK;
END GetDeleteDyelineHeadAndItems;
/

PROMPT CREATE OR REPLACE Procedure  194 :: GetSHADEGROUPNAMEList
CREATE OR REPLACE Procedure GetSHADEGROUPNAMEList
(
  data_cursor IN OUT pReturnData.c_Records
)

AS
BEGIN

    OPEN data_cursor for
    Select SHADEGROUPID,SHADEGROUPNAME  from T_SHADEGROUP order by SHADEGROUPNAME;

END;
/




PROMPT CREATE OR REPLACE Procedure  195 :: GETAuxWAvgPrice
CREATE OR REPLACE Procedure GETAuxWAvgPrice(
  pAuxStockID IN NUMBER,
  pPID IN NUMBER,
  pStockDate DATE,
  pRecsAffected out NUMBER
)
AS
  tmpNextPID NUMBER;
  tmpConRate NUMBER;
  tmpUPrice NUMBER;
  tmpPQTY NUMBER;
  tmpUCheck NUMBER;
  tmpcOUNT NUMBER;
  tmpqtycheck NUMBER;
  faults EXCEPTION;
BEGIN
  SELECT CONRATE INTO tmpConRate FROM T_AuxStock WHERE AuxStockID=pAuxStockID;
 	for rec in (select b.PID,b.AUXID,b.STOCKQTY,b.UNITPRICE,a.CURRENCYID,a.CONRATE from T_AuxStock a,T_AuxStockItem b 
		where a.AuxStockID=b.AuxStockID and b.PID=pPID)
        LOOP
		select count(*) into tmpqtycheck
     		from T_AuxStock a, T_AuxStockItem b, T_AuxStockTypeDetails c
     		where a.AuxStockID=b.AuxStockID and a.AuxStockTypeID=c.AuxStockTypeID and 
     		B.AUXTYPEID=C.AUXTYPEID and AUXID=rec.AUXID 
     		group by b.AuxID ;
	if((tmpqtycheck-1)<>0) then
		/*select sum(StockQty*c.AuxStockMain) into tmpPQTY
     		from T_AuxStock a, T_AuxStockItem b, T_AuxStockTypeDetails c
     		where a.AuxStockID=b.AuxStockID and a.AuxStockTypeID=c.AuxStockTypeID and 
     		B.AUXTYPEID=C.AUXTYPEID and AUXID=rec.AUXID AND B.PID<rec.PID
     		group by b.AuxID ;*/			
			SELECT DECODE((select sum(StockQty*c.AuxStockMain)
     		from T_AuxStock a, T_AuxStockItem b, T_AuxStockTypeDetails c
     		where a.AuxStockID=b.AuxStockID and a.AuxStockTypeID=c.AuxStockTypeID and 
     		B.AUXTYPEID=C.AUXTYPEID and AUXID=rec.AUXID AND B.PID<rec.PID
     		group by b.AuxID),NULL,0,(select sum(StockQty*c.AuxStockMain)
     		from T_AuxStock a, T_AuxStockItem b, T_AuxStockTypeDetails c
     		where a.AuxStockID=b.AuxStockID and a.AuxStockTypeID=c.AuxStockTypeID and 
     		B.AUXTYPEID=C.AUXTYPEID and AUXID=rec.AUXID AND B.PID<rec.PID
     		group by b.AuxID))  into tmpPQTY FROM DUAL;			
	else 
		tmpPQTY:=0;
	end if;
		SELECT count(*) into tmpUCheck FROM T_AUXPRICE WHERE AUXID=rec.AUXID AND 
		PURCHASEDATE=(SELECT decode(MAX(PURCHASEDATE),null,'01-jan-1900',MAX(PURCHASEDATE)) FROM T_AUXPRICE 
			WHERE AUXID=rec.AUXID AND PURCHASEDATE<pStockDate);

 		IF (tmpUCheck=1) then
			SELECT UNITPRICE into tmpUPrice FROM T_AUXPRICE WHERE AUXID=rec.AUXID AND 
			PURCHASEDATE=(SELECT decode(MAX(PURCHASEDATE),null,'01-jan-1900',MAX(PURCHASEDATE)) FROM T_AUXPRICE 
			WHERE AUXID=rec.AUXID AND PURCHASEDATE<pStockDate);	
		ELSE
  			tmpUPrice:=0;
 		END IF;
		pRecsAffected := SQL%ROWCOUNT;

		SELECT COUNT(*) into tmpcOUNT FROM T_AUXPRICE WHERE AUXID=rec.AUXID AND PURCHASEDATE=pStockDate AND REFPID=rec.PID;

		IF (tmpcOUNT=0) THEN  /* CHECK INSERT OR UPDATE */
			SELECT MAX(PID)+1 INTO tmpNextPID from T_AUXPRICE;
					
            INSERT INTO T_AUXPRICE(PID,AUXTYPEID,AUXID,PURCHASEDATE,UNITPRICE,SUPPLIERID,QTY,PPRICE,PQTY,NPRICE,NQTY,REFPID,CURRENCYID,CONRATE)
 			SELECT tmpNextPID,AUXTYPEID,AUXID,pStockDate,
 			NVL(((rec.STOCKQTY*(rec.UNITPRICE*tmpConRate))+tmpPQTY*tmpUPrice)/(rec.STOCKQTY+tmpPQTY),0),
 			(SELECT SUPPLIERID FROM T_AuxStock WHERE AuxStockID=pAuxStockID),
 			(rec.STOCKQTY+tmpPQTY),tmpUPrice,tmpPQTY,rec.UNITPRICE*tmpConRate,rec.STOCKQTY,rec.PID,rec.CURRENCYID,rec.CONRATE
			from T_AuxStockItem WHERE PID=rec.PID;
		ELSE
  			UPDATE T_AUXPRICE SET UNITPRICE=NVL(((rec.STOCKQTY*(rec.UNITPRICE*tmpConRate))+tmpPQTY*tmpUPrice)/(rec.STOCKQTY+tmpPQTY),0),
 			QTY=(rec.STOCKQTY+tmpPQTY),PPRICE=tmpUPrice,PQTY=tmpPQTY,NPRICE=rec.UNITPRICE*tmpConRate,NQTY=rec.STOCKQTY,CURRENCYID=rec.CURRENCYID,CONRATE=rec.CONRATE
			WHERE AUXID=rec.AUXID AND PURCHASEDATE=pStockDate AND REFPID=rec.PID;
 		END IF;

		UPDATE T_AUXILIARIES 
			SET WAVGPRICE=NVL(((rec.STOCKQTY*(rec.UNITPRICE*tmpConRate))+tmpPQTY*tmpUPrice)/(rec.STOCKQTY+tmpPQTY),0)
			WHERE AUXID=rec.AUXID;
  	    pRecsAffected := SQL%ROWCOUNT+pRecsAffected;
  	IF (pRecsAffected=2)
  		THEN
         	COMMIT;
	ELSE
  		RAISE faults;
 	END IF;	 
        END loop;
 EXCEPTION
  WHEN faults THEN ROLLBACK;
END GETAuxWAvgPrice;
/


PROMPT CREATE OR REPLACE Procedure  196 :: InsertRecWithParentIdentity
CREATE OR REPLACE Procedure InsertRecWithParentIdentity  (
  pStrSql IN VARCHAR2,
  pIdentityName IN VARCHAR2,
  pIdentityFld IN VARCHAR2,
  pIdentityParentFld IN VARCHAR2,
  pCurIdentityVal OUT NUMBER,
  pRecsAffected out NUMBER
)
AS
  tmpSql VARCHAR2(1000);
  restSql VARCHAR2(1000);
  insertSql VARCHAR2(1000);
  tmpPos NUMBER;
BEGIN

  execute immediate 'select ' || pIdentityName || '.NEXTVAL from sys.dual'
  into pCurIdentityVal;

  tmpPos := instr(pStrSql, '(', 1, 1);
  tmpSql := substr(pStrSql, 1, tmpPos);
  restSql := substr(pStrSql, tmpPos+1);
  insertSql := tmpSql || pIdentityFld || ',' || pIdentityParentFld || ',';

  tmpPos := instr(restSql, ' values (', 1, 1);
  tmpSql := substr(restSql, 1, tmpPos);
  restSql := substr(restSql, tmpPos+9);
  insertSql := insertSql || tmpSql || ' values (' ||
          TO_CHAR(pCurIdentityVal) ||','|| TO_CHAR(pCurIdentityVal) ||',' || restSql;


  execute immediate insertSql;
  pRecsAffected := SQL%ROWCOUNT;

END InsertRecWithParentIdentity;
/




PROMPT CREATE OR REPLACE Procedure  197 :: InsertLycraKnitStockReq
CREATE OR REPLACE Procedure InsertLycraKnitStockReq(
  pStockId IN NUMBER,
  pYARNREQUISITIONTYPEID  IN NUMBER,
  pCurIdentityVal OUT NUMBER,
  pRecsAffected out NUMBER
)
AS
  tmpCheck NUMBER;
BEGIN
  
  SELECT COUNT(*) INTO tmpCheck FROM T_YARNREQUISITION WHERE PARENTSTOCKID=pStockId;
    if tmpCheck>0 then
      SELECT STOCKID INTO pCurIdentityVal FROM T_YARNREQUISITION WHERE PARENTSTOCKID=pStockId;
    else
  	execute immediate 'select SEQ_YARNREQSTOCKID.NEXTVAL from sys.dual'
  	into pCurIdentityVal;

  	INSERT INTO T_YARNREQUISITION (STOCKID,YARNREQUISITIONTYPEID,REFERENCENO,REFERENCEDATE,STOCKTRANSNO,STOCKTRANSDATE,                 
  	SUPPLIERID,SUPPLIERINVOICENO,SUPPLIERINVOICEDATE,REMARKS,SUBCONID,EXECUTE,PARENTSTOCKID)
  	SELECT pCurIdentityVal,pYARNREQUISITIONTYPEID,REFERENCENO,REFERENCEDATE,STOCKTRANSNO || ' LR',STOCKTRANSDATE,                 
  	SUPPLIERID,SUPPLIERINVOICENO,SUPPLIERINVOICEDATE,REMARKS,SUBCONID,EXECUTE,STOCKID FROM T_YARNREQUISITION
	WHERE STOCKID=pStockId;   
    END IF;
	
  pRecsAffected := SQL%ROWCOUNT;

END InsertLycraKnitStockReq;
/





PROMPT CREATE OR REPLACE Procedure  198 :: InsertLycraKnitStock
CREATE OR REPLACE Procedure InsertLycraKnitStock(
  pStockId IN NUMBER,
  pCurIdentityVal OUT NUMBER,
  pRecsAffected out NUMBER
)
AS
  tmpCheck NUMBER;
BEGIN
  
  SELECT COUNT(*) INTO tmpCheck FROM T_KNITSTOCK WHERE PARENTSTOCKID=pStockId;
    if tmpCheck>0 then
      SELECT STOCKID INTO pCurIdentityVal FROM T_KNITSTOCK WHERE PARENTSTOCKID=pStockId;
    else
  	execute immediate 'select SEQ_KNITSTOCKID.NEXTVAL from sys.dual'
  	into pCurIdentityVal;

  	INSERT INTO T_KNITSTOCK(STOCKID,KNTITRANSACTIONTYPEID,REFERENCENO,REFERENCEDATE,STOCKTRANSNO,STOCKTRANSDATE,
	SUPPLIERINVOICENO,SUPPLIERINVOICEDATE,REMARKS,SUBCONID,SUPPLIERID,PARENTSTOCKID)
  	SELECT pCurIdentityVal,3,REFERENCENO,REFERENCEDATE,STOCKTRANSNO  || ' LI',STOCKTRANSDATE,
	SUPPLIERINVOICENO,SUPPLIERINVOICEDATE,REMARKS,SUBCONID,SUPPLIERID,STOCKID FROM T_KNITSTOCK
	WHERE STOCKID=pStockId;   
    END IF;
	
  pRecsAffected := SQL%ROWCOUNT;

END InsertLycraKnitStock;
/

PROMPT CREATE OR REPLACE Procedure  199 :: GetKnitMachineLookUp
CREATE OR REPLACE Procedure GetKnitMachineLookUp
(
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN

    OPEN data_cursor for
    Select MACHINEID,MACHINENAME from T_KNITMACHINEINFO;

END GetKnitMachineLookUp;
/





PROMPT CREATE OR REPLACE Procedure  200 :: GETAccWAvgPrice

CREATE OR REPLACE Procedure GETAccWAvgPrice(
  pAccStockID IN NUMBER,
  pPID IN NUMBER,
  pStockDate DATE,
  pRecsAffected out NUMBER
)
AS
  tmpNextPID NUMBER;
  tmprec NUMBER;
  tmpConRate NUMBER;
  tmpUPrice NUMBER;
  tmpCheck NUMBER;
  tmpPQTY NUMBER;
  tmpUCheck NUMBER;  
  tmpcOUNT NUMBER;  
  faults EXCEPTION;

BEGIN
  tmpPQty:=0;
  SELECT CONRATE INTO tmpConRate FROM T_AccStock WHERE StockID=pAccStockID;
        
 	for rec in (select b.PID, b.AccessoriesID, b.OrderNo, b.Quantity,b.UNITPRICE,a.CURRENCYID,a.CONRATE 
				from T_AccStock a,T_AccStockItems b 
	            where a.STOCKID=b.STOCKID and b.PID=pPID)
    LOOP
  		select nvl(sum(Quantity*c.AccStockMain),0) into tmpPQty
     		from T_AccStock a, T_AccStockItems b, T_AccTransactionType c
     		where a.StockID=b.StockID and a.AccTransTypeID=c.AccTransTypeID and	a.AccTransTypeID=1 and		
     		AccessoriesID=rec.AccessoriesID and OrderNo=rec.OrderNo and
			StockTransDate<=pStockDate
     		group by b.OrderNo, b.AccessoriesID  
			having sum(Quantity*c.AccStockMain)>0;
		/*=============== Previous Item Check Start =====================================*/	
		SELECT count(*) into tmpUCheck FROM T_AccPRICE WHERE AccessoriesID=rec.AccessoriesID AND OrderNo=rec.OrderNo AND 
			PURCHASEDATE=(SELECT decode(MAX(PURCHASEDATE),null,'01-jan-1900',MAX(PURCHASEDATE)) FROM T_AccPRICE 
						WHERE AccessoriesID=rec.AccessoriesID and OrderNo=rec.OrderNo AND PURCHASEDATE<pStockDate);

 		IF (tmpUCheck=1) then
			SELECT UNITPRICE into tmpUPrice FROM T_AccPRICE WHERE AccessoriesID=rec.AccessoriesID and OrderNo=rec.OrderNo AND PURCHASEDATE=(SELECT decode(MAX(PURCHASEDATE),null,'01-jan-1900',MAX(PURCHASEDATE)) FROM T_AccPRICE 
			WHERE AccessoriesID=rec.AccessoriesID and OrderNo=rec.OrderNo AND PURCHASEDATE<pStockDate);
		ELSE
  			tmpUPrice:=0;
 		END IF;
	    	pRecsAffected := SQL%ROWCOUNT;
		/*=============== Previous Item Check End  =====================================*/	
		
		SELECT COUNT(*) into tmpcOUNT FROM T_ACCPRICE WHERE AccessoriesID=rec.AccessoriesID AND 
						PURCHASEDATE=pStockDate AND REFPID=rec.PID;
		IF (tmpcOUNT=0) THEN  /* CHECK INSERT OR UPDATE */
            select count(*) into tmprec from T_AccPrice; /* CHECK its firts record or not*/
			if(tmprec=0) then
			   tmpNextPID:=1;
			else   
			   SELECT MAX(PID)+1 INTO tmpNextPID from T_ACCPRICE;
			end if;
            INSERT INTO T_AccPRICE(PID,StockID, AccessoriesID, OrderNo, PURCHASEDATE, UNITPRICE, SUPPLIERID, QTY, PPRICE,PQTY,NPRICE,NQTY,REFPID,CURRENCYID,CONRATE)
 			SELECT tmpNextPID,StockID,AccessoriesID, OrderNo, pStockDate,
			NVL(((rec.QUANTITY*(rec.UNITPRICE*tmpConRate))+tmpPQTY*tmpUPrice)/(rec.QUANTITY+tmpPQTY),0),
 			(SELECT SUPPLIERID FROM T_AccStock  
 			WHERE T_AccStock.StockID=pAccStockID),
 			(rec.QUANTITY+tmpPQTY),tmpUPrice,tmpPQTY,rec.UNITPRICE*tmpConRate,rec.Quantity,rec.PID,rec.CURRENCYID,rec.CONRATE from T_AccStockItems WHERE PID=rec.PID;
		ELSE
  			UPDATE T_AccPRICE SET UNITPRICE=NVL(((rec.Quantity*(rec.UNITPRICE*tmpConRate))+tmpPQTY*tmpUPrice)/(rec.Quantity+tmpPQTY),0),
 			QTY=(rec.Quantity+tmpPQTY),PPRICE=tmpUPrice,PQTY=tmpPQTY,NPRICE=rec.UNITPRICE*tmpConRate,NQTY=rec.Quantity,CURRENCYID=rec.CURRENCYID,CONRATE=rec.CONRATE
			WHERE PID=rec.PID;
 		END IF;

		UPDATE T_Accessories 
			SET WAVGPRICE=((rec.Quantity*(rec.UNITPRICE*tmpConRate))+(tmpPQty-rec.Quantity)*tmpUPrice)/(rec.Quantity+tmpPQTY)
		WHERE AccessoriesID=rec.AccessoriesID;
  	    pRecsAffected := SQL%ROWCOUNT+pRecsAffected;	   
 	   
		IF (pRecsAffected=2)
			THEN
				COMMIT;
		ELSE
			RAISE faults;
		END IF;	 
    END loop;	

 EXCEPTION
  WHEN faults THEN ROLLBACK;
END GETAccWAvgPrice;
/


PROMPT CREATE OR REPLACE Procedure  201 :: GetAccGDWorkOrderLookUp
CREATE OR REPLACE Procedure GetAccGDWorkOrderLookUp
(
  data_cursor IN OUT pReturnData.c_Records,
  pBasictypeid varchar2
)
AS
BEGIN
	OPEN data_cursor for
    	Select ORDERTYPEID, ORDERTYPEID || ' ' || GDORDERNO as GDORDERNO, GORDERNO, CLIENTSREF
		from T_Gworkorder where (pBasictypeid is Null or ordertypeid=pBasictypeid) 
		ORDER BY GDORDERNO DESC;
END GetAccGDWorkOrderLookUp;
/



PROMPT CREATE OR REPLACE Procedure  202 :: GetAccRequisition
Create or Replace Procedure GetAccRequisition(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pAccGroup NUMBER,
  pStockDate DATE
)
AS
BEGIN

  if pQueryType=1 then
    if pAccGroup=-1 then
    	open data_cursor for
    	select a.RequisitionNo, b.GroupID,b.AccessoriesID, b.gorderno,b.OrderNo, b.StyleNo, b.Colour, r.ColourName, b.code, c.Item, b.Count_Size,b.PUnitOfMeasId,u.UnitOfMeas, b.Quantity CurrentStock,
NVL( ( select sum(y.Quantity*z.AccStockMain)
    from T_AccStock x, T_AccStockItems y, T_AccTransactionType z
    where x.StockID=y.StockID and
    x.AccTransTypeID=z.AccTransTypeID and
    y.AccessoriesID=b.AccessoriesID and
    y.ColourID=b.Colour and
    y.StyleNo=b.StyleNo and
    y.code=b.code and
    y.OrderNo=b.OrderNo and
    Y.GroupID=b.GroupID	and
    y.Count_Size=b.Count_Size
    group by y.GroupID,y.AccessoriesID,y.Count_Size ,y.code,y.colourID,y.PUnitOfMeasId,y.StyleNo,y.OrderNo
    having sum(y.Quantity*z.AccStockMain)>0),0) as mainstock
from T_AccRequisition a, T_AccRequisitionItems b,T_accessories c, T_UnitOfMeas u, T_AccRequisitionType t, T_Colour r
    	where a.RequisitionID=b.RequisitionID and
	t.AccRequisitionTypeId=a.AccRequisitionTypeId and
    	b.AccessoriesID=c.AccessoriesID and
	b.PUnitOfMeasID=u.UnitOfMeasID and
	b.Colour=r.ColourID and
	a.Execute=0 and
	a.RequisitionTransDate<= pStockDate and a.AccRequisitionTypeId=1  and
	b.Quantity>0
	order by c.Item;
     elsif  pAccGroup<>-1 then
	open data_cursor for
select a.RequisitionNo, b.GroupID,b.AccessoriesID,b.gorderno,b.OrderNo, b.StyleNo, b.Colour, r.ColourName, b.code, c.Item, b.Count_Size,b.PUnitOfMeasId,u.UnitOfMeas, b.Quantity CurrentStock,
NVL( ( select sum(y.Quantity*z.AccStockMain)
    from T_AccStock x, T_AccStockItems y, T_AccTransactionType z
    where x.StockID=y.StockID and
    x.AccTransTypeID=z.AccTransTypeID and
    y.AccessoriesID=b.AccessoriesID and
    y.ColourID=b.Colour and
    y.StyleNo=b.StyleNo and
    y.code=b.code and
    y.OrderNo=b.OrderNo and
    Y.GroupID=b.GroupID	and
    y.Count_Size=b.Count_Size
    group by y.GroupID,y.AccessoriesID,y.Count_Size ,y.code,y.colourID,y.PUnitOfMeasId,y.StyleNo,y.OrderNo
    having sum(y.Quantity*z.AccStockMain)>0),0) as mainstock
from T_AccRequisition a, T_AccRequisitionItems b,T_accessories c, T_UnitOfMeas u, T_AccRequisitionType t, T_Colour r
    	where a.RequisitionID=b.RequisitionID and
	t.AccRequisitionTypeId=a.AccRequisitionTypeId and
    	b.AccessoriesID=c.AccessoriesID and
	b.PUnitOfMeasID=u.UnitOfMeasID and
	b.Colour=r.ColourID and
	a.Execute=0 and
	b.GroupID=pAccGroup and
	a.RequisitionTransDate<= pStockDate and a.AccRequisitionTypeId=1 and
	b.Quantity>0
	order by c.Item;
     end if;
  end if;
END GetAccRequisition;
/

PROMPT CREATE OR REPLACE Procedure  203 :: GetAccStockPosition
Create or Replace Procedure GetAccStockPosition(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pAccGroup NUMBER,
  pStockDate DATE
)
AS
BEGIN

 /* View the main Stock */
  if pQueryType=2 then
     /* View all group*/
    if(pAccGroup=-1) then
    	open data_cursor for
    	select b.GroupID,b.AccessoriesID,b.GORDERNO, b.OrderNo, b.StyleNo, b.ColourID, r.ColourName, b.code, c.Item, b.Count_Size,b.PUnitOfMeasId,u.UnitOfMeas, sum(b.Quantity*t.AccStockMain) CurrentStock
    	from T_AccStock a, T_AccStockItems b,T_accessories c, T_UnitOfMeas u, T_AccTransactionType t, T_Colour r
    	where  a.StockID=b.StockID and
	t.AccTransTypeID=a.AccTransTypeID and
    	b.AccessoriesID=c.AccessoriesID and
	b.PUnitOfMeasID=u.UnitOfMeasID and
	b.ColourID=r.ColourID and
	StockTransDate<=pStockDate
	group by b.GroupID,b.AccessoriesID,b.Count_Size,c.Item,b.code,b.colourID,r.colourName, b.PUnitOfMeasId, u.UnitOfMeas,b.StyleNo,b.GORDERNO, b.OrderNo
	having  sum(b.Quantity*t.AccStockMain)>0
	order by c.Item  desc,b.code  desc,b.Count_Size desc,b.OrderNo desc,b.StyleNo,b.ORDERNO desc;
    /* View specific group*/
    elsif(pAccGroup<>-1) then
     	open data_cursor for
    	select b.GroupID,b.AccessoriesID,b.GORDERNO, b.OrderNo, b.StyleNo, b.ColourID,r.ColourName, b.code, c.Item, b.Count_Size,b.PUnitOfMeasId,u.UnitOfMeas, sum(b.Quantity*t.AccStockMain) CurrentStock
    	from T_AccStock a, T_AccStockItems b,T_accessories c, T_UnitOfMeas u, T_AccTransactionType t, T_Colour r
    	where  a.StockID=b.StockID and
	t.AccTransTypeID=a.AccTransTypeID and
    	b.AccessoriesID=c.AccessoriesID and
	b.PUnitOfMeasID=u.UnitOfMeasID and
	b.ColourID=r.ColourID and
	b.GroupID=pAccGroup and
	StockTransDate<=pStockDate
	group by b.GroupID,b.AccessoriesID,b.Count_Size,c.Item,b.code,b.colourID,r.colourName, b.PUnitOfMeasId, u.UnitOfMeas, b.StyleNo,b.OrderNo,b.GORDERNO
	having  sum(b.Quantity*t.AccStockMain)>0
	order by  c.Item  desc,b.code  desc,b.Count_Size desc,b.OrderNo desc,b.StyleNo desc;
    end if;
  /* View the sub store Stock */
  elsif pQueryType=3 then
    /* View all group*/
    if(pAccGroup=-1) then
    	open data_cursor for
	select b.LineNo, b.GroupID,b.AccessoriesID,b.GORDERNO, b.OrderNo, b.StyleNo, b.ColourID, r.ColourName, b.code, c.Item, b.Count_Size,b.PUnitOfMeasId,u.UnitOfMeas, sum(b.Quantity*t.AccStockSub) CurrentStock
    	from T_AccStock a, T_AccStockItems b,T_accessories c, T_UnitOfMeas u, T_AccTransactionType t, T_Colour r
    	where  a.StockID=b.StockID and
	t.AccTransTypeID=a.AccTransTypeID and
    	b.AccessoriesID=c.AccessoriesID and
	b.PUnitOfMeasID=u.UnitOfMeasID and
	b.ColourID=r.ColourID and
	StockTransDate<=pStockDate
	group by b.LineNo, b.GroupID,b.AccessoriesID,b.Count_Size,c.Item,b.code,b.colourID,r.colourName, b.PUnitOfMeasId, u.UnitOfMeas,b.StyleNo,b.OrderNo,b.GORDERNO
	having  sum(b.Quantity*t.AccStockSub)>0
	order by c.Item  desc,b.code  desc,b.Count_Size desc,b.OrderNo desc,b.StyleNo desc;
    /* View specific group*/
    elsif(pAccGroup<>-1) then
     	open data_cursor for
    	select b.LineNo, b.GroupID,b.AccessoriesID,b.GORDERNO, b.OrderNo, b.StyleNo, b.ColourID, r.ColourName, b.code, c.Item, b.Count_Size,b.PUnitOfMeasId,u.UnitOfMeas, sum(b.Quantity*t.AccStockSub) CurrentStock
    	from T_AccStock a, T_AccStockItems b,T_accessories c, T_UnitOfMeas u, T_AccTransactionType t, T_Colour r
    	where  a.StockID=b.StockID and
	t.AccTransTypeID=a.AccTransTypeID and
    	b.AccessoriesID=c.AccessoriesID and
	b.PUnitOfMeasID=u.UnitOfMeasID and
	b.ColourID=r.ColourID and
	b.GroupID=pAccGroup and
	StockTransDate<=pStockDate
	group by b.LineNo, b.GroupID,b.AccessoriesID,b.Count_Size,c.Item,b.code,b.colourID,r.colourName, b.PUnitOfMeasId, u.UnitOfMeas,b.StyleNo,b.OrderNo,b.GORDERNO
	having  sum(b.Quantity*t.AccStockSub)>0
	order by c.Item  desc,b.code  desc,b.Count_Size desc,b.OrderNo desc,b.StyleNo desc;
    end if;
  end if;
END GetAccStockPosition;
/



PROMPT CREATE OR REPLACE Procedure  204 :: getTreeAccRequistionList
Create or Replace Procedure getTreeAccRequistionList (
  io_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pRequisitionType IN NUMBER,
  pRequisitonNo IN VARCHAR2 DEFAULT NULL,
  sDate IN date,
  eDate IN date
)
AS
BEGIN

  if pQueryType=0 then
    OPEN io_cursor FOR
    select REQUISITIONID,REQUISITIONNO
    from T_AccRequisition
    where AccRequisitionTypeId=pRequisitionType and
    RequisitionTransDate>=SDate and RequisitionTransDate<=EDate
    order by REQUISITIONNO desc;

  elsif pQueryType=1 then
    OPEN io_cursor FOR
    select REQUISITIONID, REQUISITIONNO, RequisitionTransDate
    from T_AccRequisition
    where AccRequisitionTypeId=pRequisitionType and
    RequisitionTransDate>=SDate and RequisitionTransDate<=EDate
    order by RequisitionTransDate desc, REQUISITIONNO desc;

elsif pQueryType=2 then
    OPEN io_cursor FOR
    select REQUISITIONID, REQUISITIONNO, RequisitionTransDate
    from T_AccRequisition
    where AccRequisitionTypeId=pRequisitionType and
    RequisitionTransDate>=SDate and RequisitionTransDate<=EDate and AccRequisitionTypeId=2
    order by RequisitionTransDate desc, REQUISITIONNO desc;

  elsif pQueryType=9999 then
    OPEN io_cursor FOR
    select REQUISITIONID from T_AccRequisition
    where AccRequisitionTypeId=pRequisitionType and
    RequisitionTransDate>=SDate and RequisitionTransDate<=EDate and
    Upper(REQUISITIONNO) Like pRequisitonNo;
  end if;
END getTreeAccRequistionList;
/


PROMPT CREATE OR REPLACE Procedure  205 :: getAccRequisitionInfo
Create or Replace Procedure getAccRequisitionInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  many_cursor IN OUT pReturnData.c_Records,
  pReqID number
)
AS
BEGIN
    open one_cursor for
    select RequisitionID, AccRequisitionTypeId,  RequisitionNo, RequisitionTransDate,ReferenceNo, ReferenceDate, SupplierId, SupplierInvoiceNo, SupplierInvoiceDate, Remarks,Execute
    from T_AccRequisition
    where RequisitionID=pReqID;
    open many_cursor for
    select PID,RequisitionID,gorderno,CLIENTREF,OrderNo, GroupID ,AccessoriesID ,StyleNo, Colour, Code, Count_Size, Quantity ,PunitOfMeasId ,SQuantity ,SunitOfMeasId ,Remarks,CurrentStock
    from T_AccRequisitionItems
    where RequisitionID=pReqID
    order by pReqID;
END getAccRequisitionInfo;
/

PROMPT CREATE OR REPLACE Procedure  206 :: GetAccRequisitionTypeLookUP
CREATE OR REPLACE Procedure GetAccRequisitionTypeLookUP
(
  data_cursor IN OUT pReturnData.c_Records
)

AS
BEGIN

  OPEN data_cursor for
  select AccRequisitionTypeId, AccRequisitionType
  from T_AccRequisitionType
  order by AccRequisitionTypeId;
END GetAccRequisitionTypeLookUP;
/

PROMPT CREATE OR REPLACE Procedure  207 :: GetAccImpLCList
CREATE OR REPLACE Procedure GetAccImpLCList
(
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
    OPEN data_cursor for
    Select LCNo,BankLCNo
    from T_AccImpLC
    ORDER BY BankLCNo;
END GetAccImpLCList;
/



PROMPT CREATE OR REPLACE Procedure  208 :: getTreeAccStockList
CREATE OR REPLACE Procedure getTreeAccStockList (
  io_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pStockType IN NUMBER,
  pTransNo IN VARCHAR2 DEFAULT NULL,
  sDate IN date,
  eDate IN date
)
AS
BEGIN

  if pQueryType=0 then
    OPEN io_cursor FOR
    select StockId, StockTransNo from T_AccStock
    where AccTransTypeID=pStockType and
    StockTransDate>=SDate and StockTransDate<=EDate
    order by to_number(StockTransNo) desc;

  elsif pQueryType=1 then
    OPEN io_cursor FOR
    select StockId, StockTransNo, StockTransDate from T_AccStock
    where AccTransTypeID=pStockType and
    StockTransDate>=SDate and StockTransDate<=EDate
    order by StockTransDate desc, to_number(StockTransNo) desc;
	
  elsif pQueryType=2 then
    OPEN io_cursor FOR
    select a.StockId, a.StockTransNo,b.SupplierName  from T_AccStock a,T_Supplier b
    where a.AccTransTypeID=pStockType and
	     a.supplierid=b.supplierid and 
    a.StockTransDate>=SDate and a.StockTransDate<=EDate
    order by b.Suppliername desc, to_number(a.StockTransNo) desc;
	
/* GORDERNO */
 elsif pQueryType=3 then
    OPEN io_cursor FOR    
    select b.GORDERNO,b.ORDERNO
	from T_AccStock a, T_AccStockItems b
    where a.stockid=b.stockid and
	a.AccTransTypeID=pStockType AND	
    a.StockTransDate>=SDate and a.StockTransDate<=EDate
	group by b.GORDERNO,b.ORDERNO
    order by b.ORDERNO desc;
	
/* Items Name */
 elsif pQueryType=4 then
    OPEN io_cursor FOR    
    select b.ACCESSORIESID,c.ITEM
	from T_AccStock a, T_AccStockItems b,T_Accessories c
    where a.stockid=b.stockid and
	b.ACCESSORIESID=c.ACCESSORIESID and
	a.AccTransTypeID=pStockType AND	
    a.StockTransDate>=SDate and a.StockTransDate<=EDate
	group by b.ACCESSORIESID,c.ITEM
    order by c.ITEM desc;
	
  elsif pQueryType=9999 then
    OPEN io_cursor FOR
    select StockId from T_AccStock
    where AccTransTypeID=pStockType and
    StockTransDate>=SDate and StockTransDate<=EDate and
    Upper(StockTransNo) Like pTransNo;
  end if;

END getTreeAccStockList;
/


PROMPT CREATE OR REPLACE Procedure  209 :: GetAccTransTypeLookUP
CREATE OR REPLACE Procedure GetAccTransTypeLookUP
(
  data_cursor IN OUT pReturnData.c_Records
)

AS
BEGIN

  OPEN data_cursor for
  select AccTransTypeID, AccTransTypeName, AccStockMain, AccStockSub
  from T_AccTransactionType
  order by AccTransTypeID;
END GetAccTransTypeLookUP;
/


PROMPT CREATE OR REPLACE Procedure  210 :: getAccStockInfo
CREATE OR REPLACE Procedure getAccStockInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  many_cursor IN OUT pReturnData.c_Records,
  pStockID number,
  pAccStockTypeId number
)
AS
BEGIN
    open one_cursor for
    select StockId,GOrderNo, AccTransTypeID, StockTransNo, StockTransDate,CurrencyId,ConRate, ReferenceNo, ReferenceDate, SupplierId, SupplierInvoiceNo, SupplierInvoiceDate, Scomplete,  Remarks
    from T_AccStock
    where StockId=pStockID and
    AccTransTypeID=pAccStockTypeId;
    open many_cursor for
    select PID,StockID, ImpLCNO,LineNo, GOrderNo,getfncGAOrderNoFromPIDRef(PIDREF) as GAORDERNOREF, ClientRef, ORDERNO, GroupID  ,AccessoriesID , StyleNo, ColourID, Code, Count_Size, Quantity ,PunitOfMeasId ,SQuantity ,SunitOfMeasId ,Remarks,CurrentStock, RequisitionNo, ReqQuantity, UnitPrice
    from T_AccStockItems
    where StockID=pStockID
    order by PID;
END getAccStockInfo;
/


PROMPT CREATE OR REPLACE Procedure  211 :: GetGroupID
CREATE OR REPLACE Procedure GetGroupID
(
  data_cursor IN OUT pReturnData.c_Records
)

AS

BEGIN
  OPEN data_cursor for
   Select GroupID,GroupName
	from T_AccGroup order by GroupName;
END GetGroupID;
/

PROMPT CREATE OR REPLACE Procedure  212 :: GetAccItemsLookUp
CREATE OR REPLACE Procedure GetAccItemsLookUp
(
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
  open data_cursor for
  select ACCESSORIESID,ITEM,GROUPID,SUBGROUPID
  from  T_Accessories;
END GetAccItemsLookUp;
/

PROMPT CREATE OR REPLACE Procedure  213 :: getTreeAccList
CREATE OR REPLACE Procedure getTreeAccList (
  io_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
      OPEN io_cursor FOR
 	select a.accessoriesid,a.Item , (select GROUPNAME FROM T_AccGroup WHERE GroupID=a.GroupID) as GroupName
   	from t_Accessories a        
   	Order By GroupName,Item;
END getTreeAccList;
/



PROMPT CREATE OR REPLACE Procedure  214 :: GetAccessoriesInfo
CREATE OR REPLACE Procedure GetAccessoriesInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  many_cursor IN OUT pReturnData.c_Records,
  pAccID number
)
AS
BEGIN
    open one_cursor for
    select AccessoriesId, Item, UnitOfMeasID, GroupID, WAVGPRICE
    from T_Accessories
    where AccessoriesId=pAccID;
    open many_cursor for
    select
    a.PID,a.AccessoriesID,d.Item,b.SUPPLIERNAME,a.supplierid,a.currencyid,
    a.PurchaseDate,a.UnitPrice,a.Qty,c.Currencyname,a.conrate,
   decode(a.unitprice,0,0,round((a.unitprice/a.CONRATE),2)) as funitprice,a.unitprice
    from T_AccPrice a,T_Supplier b, T_currency c,T_Accessories d
    where a.SUPPLIERID=b.SUPPLIERID and
          a.currencyid=c.currencyid(+) and
          a.AccessoriesId=d.AccessoriesId and
          a.AccessoriesId=pAccID
		  Order By a.PurchaseDate Desc;
END GetAccessoriesInfo;
/


PROMPT CREATE OR REPLACE Procedure  215 :: GetColourList
CREATE OR REPLACE Procedure GetColourList
(
  pStatus number,
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)

AS

BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=0 then
  OPEN data_cursor for
  Select ColourID,ColourName
  	from T_Colour order by ColourName;

/*If the Value is 1 then retun as the */

elsif pStatus=1 then
  OPEN data_cursor for
   Select ColourID,ColourName
	from T_Colour
	 where ColourID=pWhereValue order by ColourID;
end if;
END GetColourList;
/




PROMPT CREATE OR REPLACE Procedure  216 :: getTreeAccbookingList
Create or Replace Procedure getTreeAccbookingList (
  io_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pRequisitionType IN NUMBER,
  pRequisitonNo IN VARCHAR2 DEFAULT NULL,
  sDate IN date,
  eDate IN date
)
AS
BEGIN

  if pQueryType=0 then
    OPEN io_cursor FOR
    select REQUISITIONID,REQUISITIONNO
    from T_AccRequisition
    where AccRequisitionTypeId=pRequisitionType and
    RequisitionTransDate>=SDate and RequisitionTransDate<=EDate and AccRequisitionTypeId=2
    order by REQUISITIONNO desc;

  elsif pQueryType=1 then
    OPEN io_cursor FOR
    select REQUISITIONID, REQUISITIONNO, RequisitionTransDate
    from T_AccRequisition
    where AccRequisitionTypeId=pRequisitionType and
    RequisitionTransDate>=SDate and RequisitionTransDate<=EDate and AccRequisitionTypeId=2
    order by RequisitionTransDate desc, REQUISITIONNO desc;

elsif pQueryType=2 then
    OPEN io_cursor FOR
    select REQUISITIONID, REQUISITIONNO, RequisitionTransDate
    from T_AccRequisition
    where AccRequisitionTypeId=pRequisitionType and
    RequisitionTransDate>=SDate and RequisitionTransDate<=EDate and AccRequisitionTypeId=2
    order by RequisitionTransDate desc, REQUISITIONNO desc;

  elsif pQueryType=9999 then
    OPEN io_cursor FOR
    select REQUISITIONID from T_AccRequisition
    where AccRequisitionTypeId=pRequisitionType and
    RequisitionTransDate>=SDate and RequisitionTransDate<=EDate and AccRequisitionTypeId=2 and
    Upper(REQUISITIONNO) Like pRequisitonNo;
  end if;
END getTreeAccbookingList;
/

PROMPT CREATE OR REPLACE Procedure  217 :: GetAccBooking
Create or Replace Procedure GetAccBooking (
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pAccGroup NUMBER,
  pStockDate DATE
)
AS
BEGIN

  if pQueryType=1 then
    if pAccGroup=-1 then
     open data_cursor for
     select a.RequisitionNo, b.GroupID,b.AccessoriesID,b.gorderno,b.CLIENTREF,b.OrderNo, b.StyleNo, b.Colour, r.ColourName, b.code, c.Item, b.Count_Size,b.PUnitOfMeasId,u.UnitOfMeas, b.Quantity CurrentStock
from T_AccRequisition a, T_AccRequisitionItems b,T_accessories c, T_UnitOfMeas u, T_AccRequisitionType t, T_Colour r
     where a.RequisitionID=b.RequisitionID and
 t.AccRequisitionTypeId=a.AccRequisitionTypeId and
     b.AccessoriesID=c.AccessoriesID and
 b.PUnitOfMeasID=u.UnitOfMeasID and
 b.Colour=r.ColourID and
 a.Execute=0 and a.AccRequisitionTypeId=2 and
 a.RequisitionTransDate<= pStockDate and
 b.Quantity>0
 order by c.Item;
     elsif  pAccGroup<>-1 then
 open data_cursor for
select a.RequisitionNo, b.GroupID,b.AccessoriesID,b.gorderno,b.CLIENTREF, b.OrderNo, b.StyleNo, b.Colour, r.ColourName, b.code, c.Item, b.Count_Size,b.PUnitOfMeasId,u.UnitOfMeas, b.Quantity CurrentStock
from T_AccRequisition a, T_AccRequisitionItems b,T_accessories c, T_UnitOfMeas u, T_AccRequisitionType t, T_Colour r
     where a.RequisitionID=b.RequisitionID and
 t.AccRequisitionTypeId=a.AccRequisitionTypeId and
     b.AccessoriesID=c.AccessoriesID and
 b.PUnitOfMeasID=u.UnitOfMeasID and
 b.Colour=r.ColourID and
 a.Execute=0 and a.AccRequisitionTypeId=2 and
 b.GroupID=pAccGroup and
 a.RequisitionTransDate<= pStockDate and
 b.Quantity>0
 order by c.Item;
     end if;
  end if;
END GetAccBooking;
/



PROMPT CREATE OR REPLACE Procedure  218 :: GetBTBLCPaymentList
CREATE OR REPLACE Procedure GetBTBLCPaymentList
(  
  pLCNo number,
  pLCCategory number,
  data_cursor IN OUT pReturnData.c_Records
)
AS

BEGIN
  OPEN data_cursor for
    Select PID, LCNo,IFDBCNo,IFDBCDate,IFDBCAmount,duedate,paymentdate,paidamount,balance
    from T_BTBLCPayment
    where lcno=pLCNo AND LCCategory=pLCCategory
    order by PID;
END GetBTBLCPaymentList;
/

PROMPT CREATE OR REPLACE Procedure  219 :: LC_PaymentTree
CREATE OR REPLACE Procedure LC_PaymentTree (
  io_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER, 
  sDate IN date,
  eDate IN date,
  plctype in number
)
AS
BEGIN

  if pQueryType=0 then
    OPEN io_cursor FOR
    select pid,paymentinvoiceno from T_LcpaymentInfo 
    where pinvoicetdate>=SDate and pinvoicetdate<=EDate  and lctype=plctype
    order by (paymentinvoiceno) desc;

  elsif pQueryType=1 then
    OPEN io_cursor FOR    
    select pid,paymentinvoiceno,pinvoicetdate from T_LcpaymentInfo 
    where pinvoicetdate>=SDate and pinvoicetdate<=EDate and lctype=plctype
    order by pinvoicetdate desc, paymentinvoiceno desc;	
  end if;

END LC_PaymentTree;
/

PROMPT CREATE OR REPLACE Procedure  220 :: GetBTBLCInfo
CREATE OR REPLACE Procedure GetBTBLCInfo
(  
  data_cursor IN OUT pReturnData.c_Records,
  pExpLCNo IN NUMBER,
  pLinked IN NUMBER
)
AS	
BEGIN

  OPEN data_cursor for
    with Yarn AS(
    Select a.LCNo,  sum(b.ValueFC) as AmountFC, sum(b.ValueTk) as AmountTk
    from T_YarnImpLC a,T_YarnImpLCItems b
    Where  a.LCNo=b.LCNo and  EXPLCNO=pExpLCNo and  IMPLCTYPEID=3 and Linked=pLinked 
    GROUP BY a.LCNo
  ), Aux AS(
    Select a.LCNo,  sum(b.ValueFC) as AmountFC, sum(b.ValueTk) as AmountTk
    from T_AuxImpLC a,T_AuxImpLCItems b
    Where  a.LCNo=b.LCNo and  EXPLCNO=pExpLCNo and  IMPLCTYPEID=3 and Linked=pLinked  
    GROUP BY a.LCNo
  ), Acc AS(
    Select a.LCNo,  sum(b.ValueFC) as AmountFC, sum(b.ValueTk) as AmountTk
    from T_AccImpLC a,T_AccImpLCItems b
    Where  a.LCNo=b.LCNo and  EXPLCNO=pExpLCNo and  IMPLCTYPEID=3 and Linked=pLinked 
    GROUP BY a.LCNo
  )
  SELECT Yarn.LCNO,a.BankLCNo, a.OpeningDate, Yarn.AmountFC,Yarn.AmountTk,getfncSupplier(a.supplierID) "Client", getYarn_Count_Type_Name(Yarn.LCNO) "Particulars", 1."LCCategory"   
  FROM Yarn,T_YarnImpLC a
  WHERE Yarn.LCNO=a.LCNo
  UNION
  SELECT Aux.LCNO,a.BankLCNo, a.OpeningDate, Aux.AmountFC,Aux.AmountTk,getfncSupplier(a.supplierID) "Client", getAux_Name(Aux.LCNO) "Particulars", 2."LCCategory" 
  FROM Aux,T_AuxImpLC a
  WHERE Aux.LCNO=a.LCNo
  UNION
  SELECT Acc.LCNO,a.BankLCNo, a.OpeningDate, Acc.AmountFC,Acc.AmountTk,getfncSupplier(a.supplierID) "Client", getAccessories_Name(Acc.LCNO) "Particulars", 3."LCCategory" 
  FROM Acc,T_AccImpLC a
  WHERE Acc.LCNO=a.LCNo
  ORDER BY OpeningDate;

END GetBTBLCInfo;
/



PROMPT CREATE OR REPLACE Procedure  221 :: GetExpLCItemsWorkOrder
CREATE OR REPLACE Procedure GetExpLCItemsWorkOrder
(
  data_cursor IN OUT pReturnData.c_Records,	
  pLCNo IN NUMBER,
  pLCType IN NUMBER
)
AS
BEGIN

/*  For Garments work order for L/C or Contract*/

if pLCType=1 or pLCType=2 then
    OPEN data_cursor for
    Select OrderNo,nvl(CLIENTSREF,'None') as btype
 from T_LCItems
where LCNo=pLCNo ORDER BY LCITEMID;


/*  For Fabic Sales work order */

elsif pLCType=3 then
OPEN data_cursor for
    Select OrderNo,getfncWOBType(ORDERNO) as btype
 from T_LCItems
where LCNo=pLCNo ORDER BY LCITEMID;

/* Check, is there any payment entry of deleting work order */
/* Its will work with L/C form*/
else
OPEN data_cursor for
    Select OrderNo,getfncWOBType(ORDERNO) as btype
 from T_LCPayment
where LCNo=pLCNo and OrderNo=pLCType;
end if;

END GetExpLCItemsWorkOrder;
/



PROMPT CREATE OR REPLACE Procedure  222 :: GetExpLCPaymentList
CREATE OR REPLACE Procedure GetExpLCPaymentList
(
  pStatus number,
  pWhereValue number,
  data_cursor IN OUT pReturnData.c_Records
)
AS

BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=0 then
  OPEN data_cursor for
    Select PID, LCNo, OrderNo, LCStatusID, LCReceiveDate, ShipmentDate, PartyAcceptDate, SubmittedToBankDate,
	BankAcceptanceDate, DocPurchaseDate, PayRealisedDate, FDBC, IFDBP, ExpBillAmt, PayReceiveAmt,
	PurchaseDate, LCAmount, BTBLCAmount, DFCAmount, BuyerCommision, ERQAccount, PartyAccount, PurExchRate, 
	AmountTk, SSIAccount, STex, CommisionTk, PostageCharge, FDRBTBAccount, OurAccount, FCC, PayLessTk, 
	PayLessFC, Rate, Stamp, Discount, UsancePeriod, DueDate, TotalInvValue, Margin, ReferedSundryAC,refid,
	packingcost,InvoiceNo,InvoiceDate,SPID,Payexrate

 from T_LCPayment order by PID;

/*If the Value is 1 then retun as the */

elsif pStatus=1 then
  OPEN data_cursor for
    Select PID, LCNo, OrderNo, LCStatusID, LCReceiveDate, ShipmentDate, PartyAcceptDate, SubmittedToBankDate, 
	BankAcceptanceDate, DocPurchaseDate, PayRealisedDate, FDBC, IFDBP, ExpBillAmt, PayReceiveAmt, PurchaseDate, 
	LCAmount, BTBLCAmount, DFCAmount, BuyerCommision, ERQAccount, PartyAccount, PurExchRate, AmountTk, SSIAccount,
	STex, CommisionTk, PostageCharge, FDRBTBAccount, OurAccount, FCC, PayLessTk, PayLessFC, Rate, Stamp, Discount, 
	UsancePeriod, DueDate, TotalInvValue,refid, 
	Margin, ReferedSundryAC,Packingcost,InvoiceNo,InvoiceDate,SPID,Payexrate
 from T_LCPayment
  where LCNo=pWhereValue order by PID;
  
  
elsif pStatus=2 then
  OPEN data_cursor for
    Select PID, LCNo, OrderNo, LCStatusID, LCReceiveDate, ShipmentDate, PartyAcceptDate, SubmittedToBankDate, 
	BankAcceptanceDate, DocPurchaseDate, PayRealisedDate, FDBC, IFDBP, ExpBillAmt, PayReceiveAmt, PurchaseDate, 
	LCAmount, BTBLCAmount, DFCAmount, BuyerCommision, ERQAccount, PartyAccount, PurExchRate, AmountTk, SSIAccount,
	STex, CommisionTk, PostageCharge, FDRBTBAccount, OurAccount, FCC, PayLessTk, PayLessFC, Rate, Stamp, Discount, 
	UsancePeriod, DueDate, TotalInvValue,refid, 
	Margin, ReferedSundryAC,Packingcost,InvoiceNo,InvoiceDate,SPID,Payexrate
 from T_LCPayment
  where SPID=pWhereValue;
end if;
END GetExpLCPaymentList;
/

PROMPT CREATE OR REPLACE Procedure  223 :: LcInvoicePickup
Create or Replace Procedure LcInvoicePickup
(
 one_cursor IN OUT pReturnData.c_Records,
 pQuerytype in Number,
 plctype in number
)
AS
BEGIN
if(pQuerytype=1) then
 open one_cursor for
 select PID,invoiceno,invoicedate,a.lcno,invoicevalue,b.BANKLCNO
 from  T_shipmentinfo a,T_lcinfo b
 where
 a.lcno=b.lcno and a.PID NOT IN(SELECT x.REFID FROM T_LCPAYMENT x,T_LCPAYMENTINFO y 
 WHERE y.PID=x.SPID and a.PID=x.REFID) AND 
 (plctype is null or b.EXPLCTYPEID=plctype) and a.INVOICENO is not null
 ORDER BY a.invoiceno;
 end if;
END LcInvoicePickup;
/



PROMPT CREATE OR REPLACE Procedure  224 :: GetOrderQtyAmount
Create or Replace Procedure GetOrderQtyAmount
(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER, 
  pClient  VARCHAR2,
  pSearchValue varchar2
)
AS
BEGIN
/*  Get Garments Work order for L/C or Contract */
   if pQueryType=1 or pQueryType=2 then
    open data_cursor for
WITH X AS(
     select a.GORDERNO,getfncDispalyorder(a.GORDERNO) as btype, a.CLIENTSREF, sum(b.QUANTITY) as QUANTITY, sum(b.QUANTITY) as RemQty,sum(b.QUANTITY*b.PRICE) as AMOUNT ,sum(b.QUANTITY*b.PRICE) as RemAmt
    from T_GOrderItems b,T_GWorkorder a 
    where  a.GORDERNO= b.GORDERNO and CLIENTID=pClient and 
           ordertypeid='G' 
    GROUP BY a.GORDERNO, a.CLIENTSREF 
    ORDER BY a.CLIENTSREF),Y AS (select ORDERNO,sum(LCWOQTY) "QTY", sum(LCWOAMT) "AMT"  FROM T_LCItems  GROUP BY ORDERNO)
SELECT X.GORDERNO,X.btype,X.CLIENTSREF,X.QUANTITY, Y.QTY "LINKEDQTY", (X.QUANTITY-nvl(Y.QTY,0)) "RemQty",X.AMOUNT, Y.AMT "LINKEDAMT", (X.AMOUNT-nvl(Y.AMT,0)) "RemAmt" FROM X,Y WHERE X.GORDERNO=Y.ORDERNO(+) and ((X.QUANTITY-nvl(Y.QTY,0))>0 OR X.AMOUNT-nvl(Y.AMT,0)>0); 

/* for Search */
elsif pQueryType=3 then
open data_cursor for
WITH X AS(
     select a.GORDERNO,getfncDispalyorder(a.GORDERNO) as btype, a.CLIENTSREF, sum(b.QUANTITY) as QUANTITY, sum(b.QUANTITY) as RemQty,sum(b.QUANTITY*b.PRICE) as AMOUNT ,sum(b.QUANTITY*b.PRICE) as RemAmt
    from T_GOrderItems b,T_GWorkorder a 
    where a.GORDERNO= b.GORDERNO and CLIENTID=pClient and upper(CLIENTSREF) LIKE '%' || upper(pSearchValue) || '%' and
           ordertypeid='G' 
    GROUP BY a.GORDERNO, a.CLIENTSREF 
    ORDER BY a.CLIENTSREF),Y AS (select ORDERNO,sum(LCWOQTY) "QTY", sum(LCWOAMT) "AMT"  FROM T_LCItems  GROUP BY ORDERNO)
SELECT X.GORDERNO,X.btype,X.CLIENTSREF,X.QUANTITY, Y.QTY "LINKEDQTY", (X.QUANTITY-nvl(Y.QTY,0)) "RemQty",X.AMOUNT, Y.AMT "LINKEDAMT", (X.AMOUNT-nvl(Y.AMT,0)) "RemAmt" FROM X,Y WHERE X.GORDERNO=Y.ORDERNO(+) and ((X.QUANTITY-nvl(Y.QTY,0))>0 OR X.AMOUNT-nvl(Y.AMT,0)>0); 


/*  Get Fabric Work order
elsif pQueryType=3 then
    open data_cursor for
     select a.ORDERNO as GORDERNO ,getfncWOBType(a.ORDERNO) as btype, a.CLIENTSREF, sum(b.QUANTITY) as QUANTITY, sum(b.QUANTITY) as RemQty, sum(b.QUANTITY*b.Rate) as AMOUNT ,sum(b.QUANTITY*b.Rate) as RemAmt
    from T_OrderItems b, T_Workorder a 
    where  a.ORDERNO=b.ORDERNO and CLIENTID=pClient and 
           a.BASICTYPEID='FS'
    GROUP BY a.ORDERNO, a.CLIENTSREF 
    ORDER BY a.CLIENTSREF ;
 */
 end if;
END GetOrderQtyAmount;
/



PROMPT CREATE OR REPLACE Procedure  225 :: getTreeExpLCList
CREATE OR REPLACE Procedure getTreeExpLCList (
  io_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pLcType IN NUMBER,
  sDate IN date,
  eDate IN date
)
AS
  vSDate date;
  vEDate date;
BEGIN
  
  vSDate := TO_DATE('01/01/1900', 'DD/MM/YYYY');
  vEDate := TO_DATE('01/01/2999', 'DD/MM/YYYY');
  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  end if;
  /* For all The Data*/

if pQueryType=0 then
    OPEN io_cursor FOR
    select LCNo, BankLCNo 
    from T_LCInfo
    where EXPLCTYPEID=pLcType and RECEIVEDATE>=SDate and RECEIVEDATE<=EDate
    order by LCNo desc;

 /* For Client Name*/

elsif pQueryType=1 then
    OPEN io_cursor FOR
    	select LCNo, BankLCNo, b.CLIENTNAME as CLIENTNAME 
	from T_LCInfo a, T_client b 
	where a.CLIENTID=b.CLIENTID and
	EXPLCTYPEID=pLcType and RECEIVEDATE>=SDate and RECEIVEDATE<=EDate  
	order by b.CLIENTNAME ;

/* For Date*/

elsif pQueryType=2 then
    OPEN io_cursor FOR
    	select RECEIVEDATE, LCNo, BankLCNo 
	from T_LCInfo 
	where EXPLCTYPEID=pLcType and RECEIVEDATE>=SDate and RECEIVEDATE<=EDate  
	order by RECEIVEDATE,BankLCNo desc;

/*  For Export LC Type */

elsif pQueryType=3 then
    OPEN io_cursor FOR 
	select b.EXPLCTYPENAME as EXPLCTYPENAME, LCNo, BankLCNo 
	from T_LCInfo a, T_ExpLCType b
	where a.EXPLCTYPEID=b.EXPLCTYPEID and 
	a.EXPLCTYPEID=pLcType  
	order by a.EXPLCTYPEID, a.BankLCNo desc; 
end if;
END getTreeExpLCList;
/

PROMPT CREATE OR REPLACE Procedure  226:: getExpLCInfo
CREATE OR REPLACE Procedure getExpLCInfo
(
  one_cursor IN OUT pReturnData.c_Records, 
  many_cursor IN OUT pReturnData.c_Records, 
  pLCNo IN NUMBER,
  pLCType IN NUMBER
)
AS

BEGIN
  open one_cursor for 
	select LCNo, BankLCNo, ClientID,ReceiveDate, ExpLCTypeID, CurrencyId,  ConRate, LCOrderQty, LCOrderAmt, LCExpiryDate, LCMaturityPeriod, PayDueDate, DocPurchasedAmt, BankId,BankBillNo, PurchaseRate, PayExchangeRate, UsanceRate, OverDueIntRate,UsanceAdvice, OverDueAdvice, PayAdvice, PayAdvDate, Remarks,BTBLCLimit 
	from T_LCInfo 
  	where LCNo=pLCNo; 

/*  For Garments work order */

if pLCType=1 then
open many_cursor for
    select LCItemID,OrderNo,getClientRef(ORDERNO) as WOCLIENTSREF,CLIENTSREF,LCWoQty,LCWoAmt
  FROM T_LCItems
  where LCNo=pLCNo order by LCItemID;

/*  For Contract */

elsif pLCType=2 then
open many_cursor for
    select LCItemID,OrderNo,getClientRef(ORDERNO) as WOCLIENTSREF,CLIENTSREF,LCWoQty,LCWoAmt
  FROM T_LCItems
  where LCNo=pLCNo order by LCItemID;

/*  For Fabic Sales work order */

elsif pLCType=3 then
open many_cursor for
    select LCItemID,OrderNo,getClientRef(ORDERNO) as WOCLIENTSREF,CLIENTSREF,LCWoQty,LCWoAmt
  FROM T_LCItems
  where LCNo=pLCNo order by LCItemID;
end if;

END getExpLCInfo;
/





PROMPT CREATE OR REPLACE Procedure  227 :: GetBankIDs
CREATE OR REPLACE Procedure GetBankIDs
(
  pStatus number,
  pWhereValue number,
  data_cursor IN OUT pReturnData.c_Records
)

AS

BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=0 then
  OPEN data_cursor for
   Select BankID,BankName,BranchName
	from T_LCBank order by BankName;
/*If the Value is 1 then retun as the */

elsif pStatus=1 then
  OPEN data_cursor for
    Select BankID,BankName,BranchName
	from T_LCBank
	 where BankID=pWhereValue order by BankName;
end if;
END GetBankIDs;
/

PROMPT CREATE OR REPLACE Procedure  228 :: GetExpLCTypeList
CREATE OR REPLACE Procedure GetExpLCTypeList
(
  pStatus number,
  pWhereValue number,
  data_cursor IN OUT pReturnData.c_Records
)
AS

BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=0 then
  OPEN data_cursor for
    Select ExpLCTypeName, ExpLCTypeID from T_ExpLCType order by ExpLCTypeID;

/*If the Value is 1 then retun as the */

elsif pStatus=1 then
  OPEN data_cursor for
    Select ExpLCTypeName, ExpLCTypeID from T_ExpLCType
  where ExpLCTypeID=pWhereValue order by ExpLCTypeName;
end if;
END GetExpLCTypeList;
/


PROMPT CREATE OR REPLACE Procedure  229:: GetLCStatusList
CREATE OR REPLACE Procedure GetLCStatusList
(
  pStatus number,
  pWhereValue number,
  data_cursor IN OUT pReturnData.c_Records
)
AS

BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=0 then
  OPEN data_cursor for
    Select LCStatus, LCStatusID from T_LCStatus order by LCStatusID;

/*If the Value is 1 then retun as the */

elsif pStatus=1 then
  OPEN data_cursor for
    Select LCStatus, LCStatusID from T_LCStatus
  where LCStatusID=pWhereValue order by LCStatus;
end if;
END GetLCStatusList;
/



/* For all Reports */

PROMPT CREATE OR REPLACE Procedure  230 :: GetReportExpLCPayment
CREATE OR REPLACE Procedure GetReportExpLCPayment
(
  data_cursor IN OUT pReturnData.c_Records,
  pLCNo number 
)
AS
BEGIN

  OPEN data_cursor for
Select PID, LCNo, OrderNo, LCStatusID, ShipmentDate, PartyAcceptDate, SubmittedToBankDate, BankAcceptanceDate, DocPurchaseDate, PayRealisedDate, FDBC, IFDBP, ExpBillAmt, PayReceiveAmt, PurchaseDate, LCAmount, BTBLCAmount, DFCAmount, BuyerCommision, ERQAccount, PartyAccount, PurExchRate, AmountTk, SSIAccount, STex, CommisionTk, PostageCharge, FDRBTBAccount, OurAccount, FCC, PayLessTk, PayLessFC, Rate, Stamp, Discount, UsancePeriod, DueDate, TotalInvValue, Margin, ReferedSundryAC

 from T_LCPayment  
 where LCNO=pLCNO
 order by PID;
  

END GetReportExpLCPayment;
/





PROMPT CREATE OR REPLACE Procedure  231:: GETAccImpLCInfo
CREATE OR REPLACE Procedure GETAccImpLCInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  many_cursor IN OUT pReturnData.c_Records,
  pLCNumber IN NUMBER
)
AS
BEGIN
  open one_cursor for
  select LCNo, BankLCNo, OpeningDate, SupplierID, CurrencyId, ConRate, ExpLCNo,ShipmentDate,
  DocRecDate, DocRelDate, GoodsRecDate, ImpLCStatusId, BankCharge, Insurance,
  TruckFair, CNFValue, OtherCharge, Remarks, ShipDate, Cancelled,Lcmaturityperiod,ImpLctypeid
  from T_AccImpLC
  where LCNo=pLCNumber;

  open many_cursor for
  select PID, GROUPID,AccessoriesId, Qty, UnitPrice, ValueFC, ValueTk, ValueBank,
  ValueInsurance, ValueTruck, ValueCNF, ValueOther, TotCost, UnitCost
  FROM T_AccImpLCItems
  where LCNo=pLCNumber order by PID;
END GETAccImpLCInfo;
/




PROMPT CREATE OR REPLACE Procedure  232 :: getTreeAccImpLCList
CREATE OR REPLACE Procedure getTreeAccImpLCList (
  io_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pLCNo IN NUMBER,
  sDate IN date,
  eDate IN date
)
AS
  vSDate date;
  vEDate date;
BEGIN
  vSDate := TO_DATE('01/01/1900', 'DD/MM/YYYY');
  vEDate := TO_DATE('01/01/2999', 'DD/MM/YYYY');
  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  end if;
  /* For all The Data*/
  if pQueryType=0 then
    OPEN io_cursor FOR
    select LCNo, BankLCNo from T_AccImpLC
    where OPeningDate>=SDate and OPeningDate<=EDate 
 order by lcno desc ;

 /* For Supplier Name*/


  elsif pQueryType=1 then
    OPEN io_cursor FOR
    select b.SUPPLIERNAME, LCNo, BankLCNo 
    from T_AccImpLC a, T_SUPPLIER b 
    where a.SupplierID=b.SupplierID and
          OPeningDate>=SDate and OPeningDate<=EDate
    order by a.SupplierID, BankLCNo desc;

 /* for Lc Status */
  elsif pQueryType=2 then
    OPEN io_cursor FOR
    select b.ImpLCStatus, LCNo, BankLCNo
    from T_AccImpLC a, T_ImpLCStatus b
    where a.ImpLCStatusId=b.ImpLCStatusId and
    OPeningDate>=SDate and OPeningDate<=EDate
    order by a.ImpLCStatusId, BankLCNo desc;

 /*  For LC Type */
  elsif pQueryType=3 then
    OPEN io_cursor FOR
    select  b.impLctype, LCNo, BankLCNo
    from T_AccImpLC a, T_ImpLCtype b
    where a.IMPLctypeid=b.impLctypeid and
    OPeningDate>=SDate and OPeningDate<=EDate
    order by a.ImpLctypeid, BankLCNo desc;
 /* */
  elsif pQueryType=9999 then
    OPEN io_cursor FOR
    select LCNo from T_AccImpLC
    where  OPeningDate>=SDate and OPeningDate<=EDate and
    Upper(BankLCNo) Like pLCNo;
  end if;
END getTreeAccImpLCList;
/

PROMPT CREATE OR REPLACE Procedure  233 :: GetExpLCNoList
CREATE OR REPLACE Procedure GetExpLCNoList
(
  data_cursor IN OUT pReturnData.c_Records,
  plctype in varchar2
)
AS
BEGIN
	OPEN data_cursor for    	
	with X AS(Select e.LCNo,  nvl((Select sum(b.ValueFC)
    		       from T_YarnImpLC a,T_YarnImpLCItems b
    		       Where  a.LCNo=b.LCNo and  EXPLCNO=e.LCNo and  IMPLCTYPEID=3 
    		      GROUP BY a.EXPLCNO),0)+
		      nvl((Select sum(b.ValueFC)
                      from T_AuxImpLC a,T_AuxImpLCItems b
                      Where  a.LCNo=b.LCNo and  EXPLCNO=e.LCNo and  IMPLCTYPEID=3 
                      GROUP BY e.LCNo),0) +
                      nvl((Select sum(b.ValueFC) 
                      from T_AccImpLC a,T_AccImpLCItems b
                      Where  a.LCNo=b.LCNo and  EXPLCNO=e.LCNo and  IMPLCTYPEID=3 
                      GROUP BY e.LCNo),0) as BTBLCAmount     
        FROM T_LCInfo e 		
        GROUP BY e.LCNo)
         SELECT X.LCNo,Y.BankLCNo, Y.LCORDERAMT "ExpLCAmount", X.BTBLCAmount
         FROM X,T_LCInfo Y
	 WHERE Y.LCNO=X.LCNo and (plctype is null or y.explctypeid=plctype)
         ORDER BY Y.BankLCNo DESC;
END GetExpLCNoList;
/



PROMPT CREATE OR REPLACE Procedure  234 :: GETYarnImpLCInfo
CREATE OR REPLACE Procedure GETYarnImpLCInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  many_cursor IN OUT pReturnData.c_Records,
  pLCNumber IN NUMBER
)
AS
BEGIN
  open one_cursor for
  select LCNo, BankLCNo, OpeningDate, SupplierID, CurrencyId, ConRate, ExpLCNo,ShipmentDate,
  DocRecDate, DocRelDate, GoodsRecDate, ImpLCStatusId, BankCharge, Insurance,
  TruckFair, CNFValue, OtherCharge, Remarks, ShipDate, Cancelled,Lcmaturityperiod,ImpLctypeid
  from T_YarnImpLC
  where LCNo=pLCNumber;

  open many_cursor for
  select PID,YARNIMPLCITEMSSL,YarnTypeId, CountId, Qty, UnitPrice, ValueFC, ValueTk, ValueBank,
  ValueInsurance, ValueTruck, ValueCNF, ValueOther, TotCost, UnitCost
  FROM T_YarnImpLCItems
  where LCNo=pLCNumber order by PID;
END GETYarnImpLCInfo;
/


PROMPT CREATE OR REPLACE Procedure  235 :: getTreeYarnImpLCList
CREATE OR REPLACE Procedure getTreeYarnImpLCList (
  io_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pLCNo IN NUMBER,
  sDate IN date,
  eDate IN date
)
AS
  vSDate date;
  vEDate date;
BEGIN
  vSDate := TO_DATE('01/01/1900', 'DD/MM/YYYY');
  vEDate := TO_DATE('01/01/2999', 'DD/MM/YYYY');
  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  end if;
  /* For all The Data*/
  if pQueryType=0 then
    OPEN io_cursor FOR
    select LCNo, BankLCNo from T_YarnImpLC
    where OPeningDate>=SDate and OPeningDate<=EDate 
 order by lcno desc ;

 /* For Supplier Name*/


  elsif pQueryType=1 then
    OPEN io_cursor FOR
    select b.SUPPLIERNAME, LCNo, BankLCNo 
    from T_YarnImpLC a, T_SUPPLIER b 
    where a.SupplierID=b.SupplierID and
          OPeningDate>=SDate and OPeningDate<=EDate
    order by a.SupplierID, BankLCNo desc;

 /* for Lc Status */
  elsif pQueryType=2 then
    OPEN io_cursor FOR
    select b.ImpLCStatus, LCNo, BankLCNo
    from T_YarnImpLC a, T_ImpLCStatus b
    where a.ImpLCStatusId=b.ImpLCStatusId and
    OPeningDate>=SDate and OPeningDate<=EDate
    order by a.ImpLCStatusId, BankLCNo desc;

 /*  For LC Type */
  elsif pQueryType=3 then
    OPEN io_cursor FOR
    select  b.impLctype, LCNo, BankLCNo
    from T_YarnImpLC a, T_ImpLCtype b
    where a.IMPLctypeid=b.impLctypeid and
    OPeningDate>=SDate and OPeningDate<=EDate
    order by a.ImpLctypeid, BankLCNo desc;
 /* */
  elsif pQueryType=9999 then
    OPEN io_cursor FOR
    select LCNo from T_YarnImpLC
    where  OPeningDate>=SDate and OPeningDate<=EDate and
    Upper(BankLCNo) Like pLCNo;
  end if;
END getTreeYarnImpLCList;
/


PROMPT CREATE OR REPLACE Procedure  236 :: GetImpLCTypeLookUp
CREATE OR REPLACE Procedure GetImpLCTypeLookUp
(
  pStatus number,
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)

AS

BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=0 then
  OPEN data_cursor for
   select ImpLCTypeID,ImpLCType
 from  T_ImpLCType order by ImpLCTypeID;

/*If the Value is 1 then retun as the */

elsif pStatus=1 then
  OPEN data_cursor for
  select ImpLCTypeID,ImpLCType
 from T_ImpLCType
  where ImpLCTypeID=pWhereValue order by ImpLCType;
end if;
END GetImpLCTypeLookUp;
/

PROMPT CREATE OR REPLACE Procedure  237 :: getKnitStockLookup
CREATE OR REPLACE Procedure getKnitStockLookup
(
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
  OPEN data_cursor for
    select STOCKID,STOCKTRANSNO,STOCKTRANSDATE from T_KnitStock
	WHERE KNTITRANSACTIONTYPEID=1
    order by STOCKTRANSNO asc;  
END getKnitStockLookup;
/



PROMPT CREATE OR REPLACE Procedure  238:: GetYarnPrices
CREATE OR REPLACE Procedure GetYarnPrices
(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  sDate IN date,
  eDate IN date
)
AS
BEGIN
    open data_cursor for
    select p.PID, p.YarnStockID,t.YarnType, c.YarnCount,p.YarnBatchNo,s.SupplierName,p.PurchaseDate, 
	p.Qty,p.currencyid,x.CURRENCYNAME, p.CONRATE,decode(p.UnitPrice,0,0,round((p.UnitPrice/p.CONRATE),2)) as fUnitPrice,p.UnitPrice
    from T_YarnPrice p, T_YarnType t, T_yarnCount c, T_supplier s,t_currency x
    where p.YarnTypeID=t.YarnTypeID and
          p.CountID=c.YarncountID and
          p.supplierID=s.supplierID  and
		  p.currencyid=x.currencyid(+) and
		  p.PurchaseDate>=SDate and p.PurchaseDate<=EDate
    Order by  p.YarnBatchNo, p.YarnTypeID, p.countID;
END GetYarnPrices;
/  

PROMPT CREATE OR REPLACE Procedure  239:: GetknitStockMRRInfo
CREATE OR REPLACE Procedure GetknitStockMRRInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  many_cursor IN OUT pReturnData.c_Records,
  pKnitStockID number
)
AS
BEGIN
    open one_cursor for
    select StockId, KNTITRANSACTIONTYPEID, ReferenceNo, ReferenceDate,StockTransNO, StockTransDATE,
    supplierID,SupplierInvoiceNo,SupplierInvoiceDate,Remarks,SubConId,CurrencyId,ConRate,SCOMPLETE,YARNFOR
    from T_KnitStock  where StockId=pKnitStockID;

    open many_cursor for
    select PID,a.ORDERNO,a.STOCKID, KNTISTOCKITEMSL,
    YarnCountId, YarnTypeId,FabricTypeId,OrderlineItem,CurrentStock,(CurrentStock+Quantity) AS PhysicalQty,
    Quantity, Squantity,PunitOfmeasId,SUNITOFMEASID,YarnBatchNo,Shade,REMARKS,a.supplierID,b.SUPPLIERNAME,ImpLcNo,UnitPrice,
	a.YARNFOR
    from T_KnitStockItems a,T_Supplier b
	where STOCKID=pKnitStockID and
	a.supplierid=b.supplierid(+)
    order by KNTISTOCKITEMSL asc;
END GetknitStockMRRInfo;
/

PROMPT CREATE OR REPLACE Procedure  240:: GetYarnWavgPrice
CREATE OR REPLACE Procedure GetYarnWavgPrice(
   pKnitStockID IN NUMBER,
   pItemsID IN NUMBER,
   pRecsAffected out NUMBER
 )
 as
 tmpcOUNT NUMBER;
 pQuantity number(12,2);
 pQty number(12,2);
 pyarnprice number(12,2);
 squantity number(12,2);
 syarnprice number(12,4);
 pwavgprice number(12,4);
 pTotalQty number(12,4);
 pYarntype number(3);
 vmaxDate date;
 pyarnstockid number(20);
 pdate date;
 slcount number(6);
 pid number(20);
 sSupplierId number(4);
 tmpCheck NUMBER;
 tmpDouble NUMBER;
 faults EXCEPTION;

 cursor c1 is SELECT a.pid as spid, yarntypeid, YarnCountId countid, YarnBatchNo, (a.Quantity) squantity, 
 (a.unitprice) syarnprice, (b.StockId) pyarnstockid, (b.StockTransDate) pdate,
 (b.SupplierId) sSupplierId, b.ConRate ConRate,b.CURRENCYID
 from T_KnitStockItems a,T_KnitStock b
 where a.StockId=b.StockId and
 a.PID=pItemsID and
 a.StockId=pKnitStockID;
 myrec c1%rowtype;
 BEGIN
    for  myrec in c1
    LOOP
		select distinct (b.StockId) into pid from T_KnitStock a, T_KnitStockItems b
		where a.StockId=b.StockId and b.PID=pItemsID and
		b.StockId=pKnitStockID;

		select distinct (b.yarntypeid) into pYarntype from T_KnitStock a, T_KnitStockItems b
		where YarnCountId=myrec.countid and
		yarntypeid=myrec.yarntypeid and
		YarnBatchNo=myrec.YarnBatchNo and
		a.KntiTransactionTypeId=1 and
		b.PID=pItemsID and
		a.StockId=b.StockId;

		select nvl(sum(Quantity*c.ATLGYS),0) into pQuantity
        from T_KnitStock a, T_KnitStockItems b,T_KnitTransactionType c
        where a.StockID = b.StockID and
        a.KntiTransactionTypeId = c.KntiTransactionTypeId and
        b.pid < myrec.spid and
        b.YarnCountId = myrec.countid and
        b.yarntypeid = myrec.yarntypeid and
		b.PID=pItemsID and
		b.YarnBatchNo = myrec.YarnBatchNo;

		select max(PURCHASEDATE) into vmaxDate from T_YarnPrice
			where countid = myrec.countid and yarntypeid = myrec.yarntypeid and
				YarnBatchNo = myrec.YarnBatchNo and PURCHASEDATE<myrec.pdate;
			if vmaxDate is null THEN
                pyarnprice:= 0;
			else
				select (nvl(unitprice,0)) into pyarnprice
                from T_YarnPrice
                where PURCHASEDATE=vmaxDate and
				countid = myrec.countid and yarntypeid = myrec.yarntypeid and YarnBatchNo = myrec.YarnBatchNo;
			end if;
			pTotalQty:=(pQuantity+myrec.squantity);
			if pTotalQty=0 THEN
                pwavgprice:= ((myrec.squantity*myrec.syarnprice*myrec.ConRate)/myrec.squantity);
			else
				pwavgprice:=((pQuantity*pyarnprice)+(myrec.squantity*myrec.syarnprice*myrec.ConRate))/(pTotalQty);
			end if;
			SELECT COUNT(*) into tmpcOUNT FROM T_YarnPrice WHERE PURCHASEDATE=myrec.pdate AND countid = myrec.countid and yarntypeid = myrec.yarntypeid and YarnBatchNo = myrec.YarnBatchNo;
			/*YARNSTOCKID=myrec.pyarnstockid AND PURCHASEDATE=myrec.pdate AND REFPID=myrec.SPID;*/
			IF (tmpcOUNT=0) THEN  /* CHECK INSERT OR UPDATE */
				insert into T_YarnPrice(PID,yarntypeid,countid,YarnBatchNo,UNITPRICE,PURCHASEDATE,qty,yarnstockid,Supplierid,PQTY,PPRICE,NQTY,NPRICE,REFPID,CURRENCYID,ConRate)
				values(seq_YarnPricePID.NextVal,pYarntype,myrec.countid, myrec.YarnBatchNo, pwavgprice,myrec.pdate,(pQuantity+myrec.squantity),pid,myrec.sSupplierId,pQuantity,pyarnprice,myrec.squantity,myrec.syarnprice,myrec.spid,myrec.CURRENCYID,myrec.ConRate);
			Else
				update T_YarnPrice set UNITPRICE=pwavgprice,PURCHASEDATE=myrec.pdate,qty=(pQuantity+myrec.squantity),PQTY=pQuantity,PPRICE=pyarnprice,NQTY=myrec.squantity,NPRICE=myrec.syarnprice
				WHERE PURCHASEDATE=myrec.pdate AND countid = myrec.countid and yarntypeid = myrec.yarntypeid and YarnBatchNo = myrec.YarnBatchNo;
				/*YARNSTOCKID=myrec.pyarnstockid AND PURCHASEDATE=myrec.pdate AND REFPID=myrec.SPID;*/
			End if;
			pQuantity:=0;
			pyarnstockid:=pid;
			pRecsAffected:=SQL%ROWCOUNT+pRecsAffected;
	END loop;
    pRecsAffected := SQL%ROWCOUNT;

    EXCEPTION
        WHEN faults THEN ROLLBACK;
END GetYarnWavgPrice;
/

PROMPT CREATE OR REPLACE Procedure  241 :: GetKStockGYRInfo
CREATE OR REPLACE Procedure GetKStockGYRInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  many_cursor IN OUT pReturnData.c_Records,
  pKnitStockID number
)
AS
BEGIN
    open one_cursor for
    select StockId, KNTITRANSACTIONTYPEID, ReferenceNo, ReferenceDate, StockTransNO, StockTransDATE,
    supplierID,SupplierInvoiceNo,SupplierInvoiceDate,Remarks, SubConId,ClientID
    from T_KnitStock
    where StockId=pKnitStockID;

    open many_cursor for
    select PID,a.ORDERNO,GetfncWOBType(a.OrderNo) as btype,a.STOCKID, KNTISTOCKITEMSL,
    a.YarnCountId, a.YarnTypeId,a.FabricTypeId,a.OrderlineItem,a.Quantity, a.Squantity,a.PunitOfmeasId,a.SUNITOFMEASID,a.REQQUANTITY,
    a.YarnBatchNo,a.Shade,a.REMARKS,a.CurrentStock,a.supplierID,d.SUPPLIERNAME,a.RequisitionNo,
    a.SubConId,a.SHADEGROUPID,'' AS SHADEGROUPNAME,c.KNTITRANSACTIONTYPEID,a.REMAINQTY,a.yarnfor
    from T_KnitStockItems a,T_KnitStock c,T_supplier d
    where a.STOCKID=c.STOCKID and a.supplierID=d.supplierID and
    a.STOCKID=pKnitStockID
    order by KNTISTOCKITEMSL asc;
END GetKStockGYRInfo;
/






PROMPT CREATE OR REPLACE Procedure  242:: getTreeQC
CREATE OR REPLACE Procedure getTreeQC(
  io_cursor IN OUT pReturnData.c_Records,  
  pQueryType IN NUMBER,
  pQcNo IN VARCHAR2 DEFAULT NULL,
  sDate IN date,
  eDate IN date,
  pQcType NUMBER
)
AS
BEGIN
  if pQueryType=0 then
    OPEN io_cursor FOR
    select QcId, QcNo from T_QC
    where QcDate>=SDate and QcDate<=EDate and
	QcType = pQcType
    order by QcNo desc;

  elsif pQueryType=1 then
    OPEN io_cursor FOR
    select QcId, QcNo, QcDate from T_Qc
    where QcDate>=SDate and QcDate<=EDate and
	QcType = pQcType
    order by QcDate desc, QcNo desc;

  elsif pQueryType=9999 then
    OPEN io_cursor FOR
    select QcId from T_Qc
    where QcDate>=SDate and QcDate<=EDate and
	QcType = pQcType and
    Upper(QcNo) Like pQcNo;
  end if;
END getTreeQC;
/


PROMPT CREATE OR REPLACE Procedure  243 :: GetQcStatusList
CREATE OR REPLACE Procedure GetQcStatusList
(
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
    OPEN data_cursor for
    Select QcStatusId, QcStatus from T_QcStatus
    Order By QcStatusId;
END GetQcStatusList;
/

PROMPT CREATE OR REPLACE Procedure  244 :: GetShadeQcBatchPickUp
CREATE or REPLACE Procedure GetShadeQcBatchPickUp(
  data_cursor IN OUT pReturnData.c_Records,
  pStockDate date
)
AS
BEGIN
    open data_cursor for
    select k.ClientName as BuyerName,b.OrderNo,GetfncWOBType(b.OrderNo) as DOrderNo, i.DBatchId, i.BatchNo, b.Shade,
    g.FABRICTYPE, sum(b.Quantity*ATLDFDS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, t_yarntype d, t_yarncount e,
    T_UnitOfMeas f, T_FabricType g, t_workorder h, T_DBatch i, T_Client k
   where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    h.orderno=b.orderno and
    b.yarntypeid=d.yarntypeid and
    b.yarncountid=e.yarncountid and
    b.DyedLotNo(+) = i.BatchNo and
    h.ClientId = k.ClientId and
    i.DBatchId not in (select b.DBatchId from T_Qc a, T_QcItems b where a.QcId=b.QcId and a.QcType=2)  and
    STOCKTRANSDATE <= pStockDate
    group by k.ClientName, b.OrderNo, i.DBatchId, i.BatchNo, b.Shade,
    g.FABRICTYPE
    having sum(b.Quantity*ATLDFDS)>0;

END GetShadeQcBatchPickUp;
/




PROMPT CREATE OR REPLACE Procedure  245 :: GetFinishedQcBatchPickUp
CREATE or REPLACE Procedure GetFinishedQcBatchPickUp(
  data_cursor IN OUT pReturnData.c_Records,
  pStockDate date
)
AS
BEGIN
    open data_cursor for
    select k.ClientName BuyerName, b.OrderNo,GetfncWOBType(b.OrderNo) as DOrderNo, i.DBatchId, i.BatchNo, b.Shade,
    g.FABRICTYPE, sum(b.Quantity*ATLFFS) CurrentStock
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, t_yarntype d, t_yarncount e,
    T_UnitOfMeas f, T_FabricType g, t_workorder h, T_DBatch i, T_Client k
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    h.orderno=b.orderno and
    b.yarntypeid=d.yarntypeid and
    b.yarncountid=e.yarncountid and
    b.DyedLotNo(+) = i.BatchNo and
    h.ClientId = k.ClientId and
    b.DYEDLOTNO in (select c.BatchNo from T_Qc a, T_QcItems b,T_DBATCH c where a.QcId=b.QcId and b.DBatchId=c.DBatchId) and
     STOCKTRANSDATE <= pStockDate
    group by k.ClientName, b.OrderNo, i.DBatchId, i.BatchNo, b.Shade,g.FABRICTYPE
    having sum(b.Quantity*ATLFFS)>0;
END GetFinishedQcBatchPickUp;
/


PROMPT CREATE OR REPLACE Procedure  246 :: GetQcInfo
CREATE OR REPLACE Procedure GetQcInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  many_cursor IN OUT pReturnData.c_Records,
  pQcId number,
  pQcType number
)
AS
BEGIN
    open one_cursor for
    select QcId, QcNo, QcDate
    from T_QC
    where QcId = pQcId and
	QcType = pQcType
    order by  QcId asc;

    open many_cursor for
    select l.ClientName BuyerName, b.OrderNo, i.BatchNo, b.Shade,g.FABRICTYPE, sum(b.Quantity*ATLFFS) CurrentStock, 
    m.PID, m.QcItemSL, m.PackingDate, m.Remarks,m.DBatchId, m.QcId, m.QcStatusId
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, t_yarntype d, t_yarncount e,
    T_UnitOfMeas f, T_FabricType g, t_workorder h, T_DBatch i, T_DBatchItems j,T_Client l,T_QcItems m
    where m.DBatchId = j.DBatchId and
           j.OrderLineItem = b.OrderLineItem and
           b.StockID=a.StockID and
           a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
           b.FABRICTYPEID=g.FABRICTYPEID and
           b.PUnitOfMeasID=f.UnitOfMeasID and
           b.orderno=h.orderno and
           b.yarntypeid=d.yarntypeid and
           b.yarncountid=e.yarncountid and    
           j.DBatchId = i.DBatchId and
           h.ClientId = l.ClientId and
           m.QcId= pQcId
	   group by l.ClientName, b.OrderNo, i.BatchNo, b.Shade,
           g.FABRICTYPE,m.PID, m.QcItemSL, m.PackingDate, m.Remarks, m.DBatchId, m.QcId, m.QcStatusId
    having sum(b.Quantity*ATLFFS)>0

    order by m.PID asc;
END GetQcInfo;
/



PROMPT CREATE OR REPLACE Procedure  247 :: GetQcAllInfo
CREATE OR REPLACE Procedure GetQcAllInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  many_cursor IN OUT pReturnData.c_Records,
  pQcId number,
  pQcType number
)
AS
BEGIN
open one_cursor for
    select QcId, QcNo, QcDate
    from T_QC
    where QcId = pQcId and QcType = pQcType
    order by  QcId asc;

if pQcType=1 then
    open many_cursor for
    	select l.ClientName BuyerName,b.OrderNo, GetfncWOBType(b.OrderNo) as DOrderNo, i.BatchNo, b.Shade,
    	g.FABRICTYPE, sum(b.Quantity*ATLFFS) CurrentStock, m.PID, m.QcItemSL, m.PackingDate, m.Remarks, 		
	m.DBatchId,m.QcId, m.QcStatusId
	from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, t_yarntype d, t_yarncount e,
	T_UnitOfMeas f, T_FabricType g, t_workorder h, T_DBatch i, T_DBatchItems j,T_Client l,
	T_QcItems m
           where m.DBatchId = j.DBatchId and
           j.OrderLineItem = b.OrderLineItem and
           b.StockID=a.StockID and
           a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
           b.FABRICTYPEID=g.FABRICTYPEID and
           b.PUnitOfMeasID=f.UnitOfMeasID and
           b.orderno=h.orderno and
           b.yarntypeid=d.yarntypeid and
           b.yarncountid=e.yarncountid and
           j.DBatchId = i.DBatchId and
           h.ClientId = l.ClientId and
           m.QcId= pQcId
	group by l.ClientName,b.OrderNo,i.BatchNo, b.Shade,
	g.FABRICTYPE, m.PID, m.QcItemSL, m.PackingDate, m.Remarks, m.DBatchId, m.QcId, m.QcStatusId
	having sum(b.Quantity*ATLFFS)>0
	order by m.PID asc;

elsif pQcType=2 then
    open many_cursor for
	select l.ClientName BuyerName,h.OrderNo, GetfncWOBType(h.OrderNo) as DOrderNo, i.BatchNo, j.Shade,
	g.FABRICTYPE, m.PID, m.QcItemSL, m.PackingDate, m.Remarks,m.DBatchId, m.QcId, m.QcStatusId,
        j.Quantity as CurrentStock
	from T_FabricType g,t_workorder h, T_DBatch i, T_DBatchItems j,T_Client l, T_QcItems m
	where m.DBatchId = j.DBatchId and
           j.orderno=h.orderno and
           j.FABRICTYPEID=g.FABRICTYPEID and
           j.DBatchId = i.DBatchId and
           h.ClientId = l.ClientId and
	   i.DBatchId in (select b.DBatchId from T_Qc a, T_QcItems b where a.QcId=b.QcId and a.QcType=2)  and
           m.QcId= pQcId
          order by m.PID asc;
end if;
END GetQcAllInfo;
/


PROMPT CREATE OR REPLACE Procedure  248 :: getGAWorkOrderInfo
CREATE OR REPLACE Procedure getGAWorkOrderInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  many_cursor IN OUT pReturnData.c_Records,
  pOrderNo NUMBER
)
AS
BEGIN
    	
	open one_cursor for
    select OrderNo,dorderno, OrderDate, ClientID, SupplierId, SalesTermID, CurrencyID,ConRate,SalesPersonID,
    WCancelled, WRevised,OrderStatusID, ContactPerson, ClientsRef, DeliveryPlace,DeliveryStartDate,
    DeliveryEndDate,DailyProductionTarget,OrderRemarks, GOrderno, BudgetID
    from T_GAWorkOrder
    where OrderNo=pOrderNo;
	
    open many_cursor for
    select PID, OrderNo,GAWOITEMSL, ImpLCNO, LineNo, GOrderNo, ClientRef, GroupID, AccessoriesID, StyleNo, ColourID, Code, Count_Size, Quantity, PunitOfMeasId, SQuantity, SunitOfMeasId, Remarks, CurrentStock, UnitPrice, PARENTSTOCKID
    from T_GAWorkOrderItems 
    where OrderNo=pOrderNo
    order by PID;
	
END getGAWorkOrderInfo;
/




PROMPT CREATE OR REPLACE Procedure  249 :: GetTexMcPWAvgPrice
CREATE OR REPLACE Procedure GetTexMcPWAvgPrice(
  pStockID IN NUMBER,
  pPID IN NUMBER,
  pStockDate DATE, 
  pRecsAffected out NUMBER
)
AS
  tmpConRate NUMBER;
  tmpUPrice NUMBER;
  tmpCheck NUMBER;
  tmpTotQty NUMBER;
  tmpUCheck NUMBER;
  tmpDouble NUMBER;
  tmpcOUNT NUMBER;
  tmpqtycheck NUMBER;
  faults EXCEPTION;

BEGIN
 SELECT CONRATE INTO tmpConRate FROM T_TexMcStock WHERE StockID=pStockID;
  SELECT sCOMPLETE INTO tmpCheck FROM T_TexMcStock WHERE StockID=pStockID;
  
 	for rec in (select PID,PARTID,QTY,UNITPRICE from T_TexMcStockItems where pid=pPID)
        LOOP	
		select count(*) into tmpqtycheck
     		from T_TexMcStock a, T_TexMcStockItems b, T_TexMcStockStatus c
     		where a.StockID=b.StockID and a.TEXMCSTOCKTYPEID=c.TEXMCSTOCKTYPEID and 
     		B.PARTSSTATUSTOID=C.PARTSSTATUSTOID and PARTID=rec.PARTID
     		group by b.PARTID;
		if((tmpqtycheck-1)<>0) then		
			select sum(QTY) into tmpTotQty
				from T_TexMcStock a, T_TexMcStockItems b
				where a.StockID=b.StockID and PARTID=rec.PARTID and b.pid<rec.pid
				group by b.PARTID;
		else 
			tmpTotQty:=0;
		end if;

		SELECT count(*) into tmpUCheck FROM T_TexMcPartsPrice WHERE PARTID=rec.PARTID AND PURCHASEDATE=(SELECT decode(MAX(PURCHASEDATE),null,'01-jan-1900',MAX(PURCHASEDATE)) FROM T_TexMcPartsPrice
			WHERE PARTID=rec.PARTID AND PURCHASEDATE<pStockDate);	
			
 		IF (tmpUCheck=1) then
			SELECT UNITPRICE into tmpUPrice FROM T_TexMcPartsPrice WHERE PARTID=rec.PARTID AND 
			PURCHASEDATE=(SELECT decode(MAX(PURCHASEDATE),null,'01-jan-1900',MAX(PURCHASEDATE)) FROM T_TexMcPartsPrice 
			WHERE PARTID=rec.PARTID AND PURCHASEDATE<pStockDate);
		ELSE
  			tmpUPrice:=0;
 		END IF;
		pRecsAffected := SQL%ROWCOUNT;

		SELECT COUNT(*) into tmpcOUNT FROM T_TexMcPartsPrice WHERE PARTID=rec.partid AND PURCHASEDATE=pStockDate AND REFPID=rec.PID;

		IF (tmpcOUNT=0) THEN  /* CHECK INSERT OR UPDATE */
            INSERT INTO T_TexMcPartsPrice(PID,PARTID,PURCHASEDATE,UNITPRICE,SUPPLIERNAME,QTY,PPRICE,PQTY,NPRICE,NQTY,REFPID)
			SELECT SEQ_TexMcpID.Nextval,PARTID,pStockDate,NVL(((rec.QTY*(rec.UNITPRICE*tmpConRate))+tmpTotQty*tmpUPrice)/(rec.QTY+tmpTotQty),0),((select SUPPLIERNAME from T_TexMcStock where T_TexMcStock.stockid=pStockID)),(rec.QTY+tmpTotQty),tmpUPrice,tmpTotQty,rec.UNITPRICE*tmpConRate,rec.qty,rec.pid
				from T_TexMcStockItems WHERE PID=rec.PID;		
		ELSE 
			UPDATE T_TexMcPartsPrice SET UNITPRICE=NVL(((rec.QTY*(rec.UNITPRICE*tmpConRate))+tmpTotQty*tmpUPrice)/(rec.QTY+tmpTotQty),0),QTY=(rec.QTY+tmpTotQty),PPRICE=tmpUPrice,PQTY=tmpTotQty,NPRICE=rec.UNITPRICE,NQTY=rec.QTY
				WHERE PARTID=rec.partid AND PURCHASEDATE=pStockDate AND REFPID=rec.PID;
		END IF;
		
		UPDATE T_TEXMCPARTSINFO 
			SET WAVGPRICE=NVL(((rec.QTY*(rec.UNITPRICE*tmpConRate))+tmpTotQty*tmpUPrice)/(rec.QTY+tmpTotQty),0)
			WHERE PARTID=rec.PARTID;
			
  	    pRecsAffected := SQL%ROWCOUNT+pRecsAffected; 	  
	IF (pRecsAffected=2) THEN
         	COMMIT;
	ELSE
  		RAISE faults;
 	END IF;
        END loop;	
 EXCEPTION
  WHEN faults THEN ROLLBACK;
END GetTexMcPWAvgPrice;
/


PROMPT CREATE OR REPLACE Procedure  250:: GetNiddleWAvgPrice
CREATE OR REPLACE Procedure GetNiddleWAvgPrice(
  pStockID IN NUMBER,
  pPID IN NUMBER,
  pStockDate DATE,
  pRecsAffected out NUMBER
)
AS
  tmpConRate NUMBER;
  tmpUPrice NUMBER;
  tmpCheck NUMBER;
  tmpTotQty NUMBER;
  tmpUCheck NUMBER;
  tmpDouble NUMBER;
  tmpcOUNT NUMBER;
  tmpqtycheck NUMBER;
  faults EXCEPTION;
BEGIN
	SELECT CONRATE INTO tmpConRate FROM T_KmcpartsTran WHERE StockID=pStockID;
      	for rec in (select PID,PARTID,QTY,UNITPRICE from T_KmcpartsTransdetails where PID=pPID)
	LOOP
		select count(*) into tmpqtycheck
     		from T_KmcpartsTran a, T_KmcpartsTransdetails b, T_KMCSTOCKSTATUS c
     		where a.StockID=b.StockID and a.KMCSTOCKTYPEID=c.KMCSTOCKTYPEID and
     		B.PARTSSTATUSTOID=C.PARTSSTATUSTOID and PARTID=rec.PARTID
     		group by b.PARTID ;
	if((tmpqtycheck-1)<>0) then
		select sum(QTY*MSN) into tmpTotQty
     		from T_KmcpartsTran a, T_KmcpartsTransdetails b, T_KMCSTOCKSTATUS c
     		where a.StockID=b.StockID and a.KMCSTOCKTYPEID=c.KMCSTOCKTYPEID and
     		B.PARTSSTATUSTOID=C.PARTSSTATUSTOID and PARTID=rec.PARTID AND B.PID<REC.PID
     		group by b.PARTID ;
	else
		tmpTotQty:=0;
	end if;
		SELECT count(*) into tmpUCheck FROM t_kmcpartsHistory WHERE PARTID=rec.PARTID AND PURCHASEDATE=(SELECT decode(MAX(PURCHASEDATE),null,'01-jan-1900',MAX(PURCHASEDATE)) FROM t_kmcpartsHistory
			WHERE PARTID=rec.PARTID AND PURCHASEDATE<pStockDate);
 		IF (tmpUCheck=1) then
			SELECT UNITPRICE into tmpUPrice FROM t_kmcpartsHistory WHERE PARTID=rec.PARTID AND
			PURCHASEDATE=(SELECT decode(MAX(PURCHASEDATE),null,'01-jan-1900',MAX(PURCHASEDATE)) FROM t_kmcpartsHistory
			WHERE PARTID=rec.PARTID AND PURCHASEDATE<pStockDate);
		ELSE
  			tmpUPrice:=0;
 		END IF;
		pRecsAffected := SQL%ROWCOUNT;
		SELECT COUNT(*) into tmpcOUNT FROM t_kmcpartsHistory WHERE PARTID=rec.partid AND PURCHASEDATE=pStockDate AND REFPID=rec.PID;

		IF (tmpcOUNT=0) THEN  /* CHECK INSERT OR UPDATE */
			INSERT INTO t_kmcpartsHistory(PID,PARTID,PURCHASEDATE,UNITPRICE,SUPPLIERNAME,QTY,PPRICE,PQTY,NPRICE,NQTY,REFPID )
			SELECT SEQ_NiddleHID.Nextval,PARTID,pStockDate,NVL(((rec.QTY*(rec.UNITPRICE*tmpConRate))+tmpTotQty*tmpUPrice)/(rec.QTY+tmpTotQty),0),
			((SELECT SUPPLIERNAME FROM T_SUPPLIER,T_KmcpartsTran
			WHERE T_SUPPLIER.SUPPLIERID=T_KmcpartsTran.SUPPLIERID AND T_KmcpartsTran.StockID=pStockID)),
			(rec.QTY+tmpTotQty),tmpUPrice,tmpTotQty,rec.UNITPRICE*tmpConRate,rec.qty,rec.pid from T_KmcpartsTransdetails WHERE PID=rec.PID;
		ELSE
			UPDATE t_kmcpartsHistory SET UNITPRICE=NVL(((rec.QTY*(rec.UNITPRICE*tmpConRate))+tmpTotQty*tmpUPrice)/(rec.QTY+tmpTotQty),0),QTY=(rec.QTY+tmpTotQty),PPRICE=tmpUPrice,PQTY=tmpTotQty,NPRICE=rec.UNITPRICE,NQTY=rec.QTY
			WHERE PARTID=rec.partid AND PURCHASEDATE=pStockDate AND REFPID=rec.PID;
 	    END IF;
		
		UPDATE T_KMCPARTSINFO 
			SET WAVGPRICE=NVL(((rec.QTY*(rec.UNITPRICE*tmpConRate))+tmpTotQty*tmpUPrice)/(rec.QTY+tmpTotQty),0)
			WHERE PARTID=rec.PARTID;
		
	pRecsAffected := SQL%ROWCOUNT+pRecsAffected;
	IF (pRecsAffected=2) THEN
         	COMMIT;
	ELSE
  		RAISE faults;
 	END IF;
END loop;
 EXCEPTION
  WHEN faults THEN ROLLBACK;
END GetNiddleWAvgPrice;
/





PROMPT CREATE OR REPLACE Procedure  251 :: GetYarnEstimateQtyChk
Create or Replace Procedure GetYarnEstimateQtyChk(
  porderNo IN NUMBER,
  pFabricTypeId IN VARCHAR2,
  pShadeGroupId IN NUMBER,
  pyarnCountId IN VARCHAR2,
  pyarnTypeID IN VARCHAR2,
  pIQty IN NUMBER,
  pRecsAffected out NUMBER
)
AS
  tmpOrderQty T_KNITSTOCKITEMS.QUANTITY%TYPE;
  tmpIssuedQty T_KNITSTOCKITEMS.QUANTITY%TYPE;
  tmpAvailableQty T_KNITSTOCKITEMS.QUANTITY%TYPE;

  tmpCheck NUMBER;
  faults EXCEPTION;
BEGIN
tmpCheck:=0;

	SELECT DECODE((	select count(*)  FROM T_OrderYarnReq 
	WHERE ORDERNO=pORDERNO AND FABRICTYPEID=pFABRICTYPEID AND SHADEGROUPID=pSHADEGROUPID
	group by ORDERNO,FABRICTYPEID,SHADEGROUPID),NULL,0,
	(select count(*)  FROM T_OrderYarnReq 
	WHERE ORDERNO=pORDERNO AND FABRICTYPEID=pFABRICTYPEID AND SHADEGROUPID=pSHADEGROUPID
	group by ORDERNO,FABRICTYPEID,SHADEGROUPID)) into tmpCheck 
	FROM T_WORKORDER WHERE orderno=porderNo;

  if tmpCheck>0 then	
	select sum(REQTY) into tmpIssuedQty  FROM T_OrderYarnReq 
	WHERE ORDERNO=pORDERNO AND FABRICTYPEID=pFABRICTYPEID AND SHADEGROUPID=pSHADEGROUPID
	group by ORDERNO,FABRICTYPEID,SHADEGROUPID;
  else
	tmpIssuedQty :=0;
  END IF;

	select SUM(b.QUANTITY) into tmpOrderQty from t_orderitems b
	where b.FABRICTYPEID=pFabricTypeId and b.SHADEGROUPID=pShadeGroupId 
	and orderno=porderNo GROUP BY b.orderno,b.FABRICTYPEID,b.SHADEGROUPID;

	tmpAvailableQty:=tmpOrderQty-tmpIssuedQty;

  	if tmpAvailableQty>=pIQty then
 		pRecsAffected :=999999;
  	else
		pRecsAffected :=tmpAvailableQty;
	END IF;

END GetYarnEstimateQtyChk;
/



PROMPT CREATE OR REPLACE Procedure  252 :: GetIssuedQtyChk
Create or Replace Procedure GetIssuedQtyChk (
  porderNo IN NUMBER,
  pFabricTypeId IN VARCHAR2,
  pShadeGroupId IN NUMBER,
  pyarnCountId IN VARCHAR2,
  pyarnTypeID IN VARCHAR2,
  pIQty IN NUMBER,
  pRecsAffected out NUMBER
)
AS
  tmpOrderQty T_KNITSTOCKITEMS.QUANTITY%TYPE;
  tmpIssuedQty T_KNITSTOCKITEMS.QUANTITY%TYPE;
  tmpAvailableQty T_KNITSTOCKITEMS.QUANTITY%TYPE;

  tmpCheck NUMBER;
  faults EXCEPTION;
BEGIN

tmpCheck:=0;

	SELECT DECODE((select count(*)  FROM T_OrderYarnReq 
	WHERE ORDERNO=pORDERNO AND
	yarncountid=pyarnCountId and yarntypeid=pyarnTypeID
	group by ORDERNO,yarnCountID,yarnTypeID),NULL,0,
	(select count(*)  FROM T_OrderYarnReq 
	WHERE ORDERNO=pORDERNO AND
	yarncountid=pyarnCountId and yarntypeid=pyarnTypeID
	group by ORDERNO,yarnCountID,yarnTypeID)) into tmpCheck 
	FROM T_WORKORDER WHERE orderno=porderNo;
	
  if tmpCheck>0 then	
	select sum(TOTALQTY) into tmpOrderQty  FROM T_OrderYarnReq 
	WHERE ORDERNO=pORDERNO AND 
	yarncountid=pyarnCountId and yarntypeid=pyarnTypeID
	group by ORDERNO,yarnCountID,yarnTypeID;
  else
	tmpIssuedQty :=0;
  END IF;

	SELECT nvl(SUM(QUANTITY),0) into tmpIssuedQty FROM T_KNITSTOCK a,T_KNITSTOCKITEMS b
	WHERE a.STOCKID=b.STOCKID and
	a.KNTITRANSACTIONTYPEID in (3,4,5,12) and
	b.ORDERNO=pORDERNO and
	b.YARNCOUNTID=pYARNCOUNTID and    
	b.YARNTYPEID=pYARNTYPEID 
	group by b.ORDERNO,b.YARNCOUNTID,b.YARNTYPEID;  

	tmpAvailableQty:=tmpOrderQty-tmpIssuedQty;

  	if tmpAvailableQty>=pIQty then
 		pRecsAffected :=999999;
  	else
		pRecsAffected :=tmpIssuedQty;
	END IF;

END GetIssuedQtyChk;
/



PROMPT CREATE OR REPLACE Procedure  253:: getOrderFebricDesc
CREATE OR REPLACE Procedure getOrderFebricDesc
(
  data_cursor IN OUT pReturnData.c_Records,
  pOrderno number

)

AS
BEGIN
 OPEN data_cursor for
	select b.orderno,GetfncWOBType(OrderNo) as DOrderNo,b.FABRICTYPEID,C.FABRICTYPE,b.SHADEGROUPID,d.SHADEGROUPNAME,SUM(b.QUANTITY) as Qty
 	from t_orderitems b,T_FABRICTYPE c,T_SHADEGROUP d 
	where b.FABRICTYPEID=c.FABRICTYPEID
  	and b.SHADEGROUPID=d.SHADEGROUPID 
	and orderno=pOrderno
 	GROUP BY b.orderno,b.FABRICTYPEID,C.FABRICTYPE,b.SHADEGROUPID,d.SHADEGROUPNAME
	ORDER BY C.FABRICTYPE;

END getOrderFebricDesc;
/



PROMPT CREATE OR REPLACE Procedure  254 :: getWOYarnApproved
CREATE OR REPLACE Procedure getWOYarnApproved
(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN number,
  pOrderNo IN number,
  pFABRICTYPEID IN VARCHAR2,
  pSHADEGROUPID IN number
)

AS
BEGIN
if pQueryType =1 then
 OPEN data_cursor for
	select  PID,ORDERNO,FABRICTYPEID,SHADEGROUPID,YARNCOUNTID,YARNTYPEID,
	REQTY,PLOSS,TOTALQTY 
 	FROM T_OrderYarnReq 
	WHERE ORDERNO=pORDERNO AND
	FABRICTYPEID=pFABRICTYPEID AND
	SHADEGROUPID=pSHADEGROUPID;
elsif pQueryType =2 then
 OPEN data_cursor for
	select  '1' as PID,ORDERNO,FABRICTYPEID,SHADEGROUPID,YARNCOUNTID,YARNTYPEID,
	sum(REQTY) as REQTY,(sum(TOTALQTY)-sum(REQTY)) as PLOSS,sum(TOTALQTY) as TOTALQTY  
 	FROM T_OrderYarnReq 
	WHERE ORDERNO=pORDERNO
	GROUP BY ORDERNO,FABRICTYPEID,SHADEGROUPID,YARNCOUNTID,YARNTYPEID;
end if;
END getWOYarnApproved;
/



PROMPT CREATE OR REPLACE Procedure  255 :: GetBStageList
CREATE OR REPLACE Procedure GetBStageList
(
  pStatus number,  
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
/*if the Value is 0 then retun all the Data */
if pStatus=0 then
  OPEN data_cursor for
    Select StageName,StageID,StageOrder from T_BUDGETSTAGES order by StageOrder;
end if;
END GetBStageList;
/

PROMPT CREATE OR REPLACE Procedure  256 :: GetBSParameterLookup
CREATE OR REPLACE Procedure GetBSParameterLookup
(
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
  OPEN data_cursor for
  select PARAMID,PARAMETERNAME from T_BUDGETPARAMETER order by PARAMETERNAME,PARAMETERORDER;
END GetBSParameterLookup;
/

PROMPT CREATE OR REPLACE Procedure  257 :: GETBSParameterInfo
CREATE OR REPLACE Procedure GETBSParameterInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  many_cursor IN OUT pReturnData.c_Records,
  pSTAGEID number
)
AS
BEGIN
    open one_cursor for
    select STAGEID,STAGENAME,STAGEORDER from T_BUDGETSTAGES  where STAGEID=pSTAGEID;

    open many_cursor for
    select PID,STAGEID, PARAMID, PARAMETERORDER
    from T_BUDGETSTAGEPARAMETER
    where STAGEID=pSTAGEID order by PARAMETERORDER;
END GETBSParameterInfo;
/

PROMPT CREATE OR REPLACE Procedure  258 :: getTreeBStageInfoList
CREATE OR REPLACE Procedure getTreeBStageInfoList(
  io_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER
)
AS
BEGIN
 /* For Stage Name*/
  if pQueryType=0 then
    OPEN io_cursor FOR
    select StageID,StageName from  T_BUDGETSTAGES 
    order by StageOrder ;
   end if;
END getTreeBStageInfoList;
/

PROMPT CREATE OR REPLACE Procedure  259 :: GETBudgetInfo 
CREATE OR REPLACE Procedure GetBudgetInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  pBudgetid number
)
AS
BEGIN
    open one_cursor for
    select BUDGETID,BUDGETNO,CLIENTID,ORDERNO,ORDERREF,ORDERDESC,LCNO,LCRECEIVEDATE,LCEXPIRYDATE,
	SHIPMENTDATE,LCVALUE,QUANTITY,UNITQTY,UNITPRICE,BUDGETPREDATE,COMPLETE,postDate,revision,ordertypeid,PI,
	cadrefno,employeeid,BugetworderRef(budgetid) as WorderRef,getfncBudgetGARef(budgetid) as GAORef,
	decode(revision,65,BREVCHECK(budgetno,ordertypeid),revision-66) as Budgetrevno
	FROM T_Budget WHERE BUDGETID= pBudgetid ;
END GetBudgetInfo;
/


PROMPT CREATE OR REPLACE Procedure  260 :: GetBstageLookup
CREATE OR REPLACE Procedure GetBstageLookup
(
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
  OPEN data_cursor for
  select STAGEID,STAGENAME from T_Budgetstages order by STAGENAME;
END GetBstageLookup;
/

PROMPT CREATE OR REPLACE Procedure  261 :: GetFabricConsumptionInfo
Create or Replace Procedure GetFabricConsumptionInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  pBudgetID number
)
AS
BEGIN
open one_cursor for
 SELECT a.BUDGETID,a.PID,a.FABRICTYPEID,a.yarntypeid,a.GSM,a.CONSUMPTIONPERDOZ,SHADEGROUPID,
        a.NETCONSUMPTIONPERDOZ,a.TOTALCONSUMPTION,a.STAGEID,a.WASTAGE,a.rpercent,a.pcs,a.styleno
        FROM t_fabricconsumption a,t_budget b
        WHERE a.budgetid=b.budgetid and a.budgetid=pBudgetID order by a.PID;
END GetFabricConsumptionInfo;
/

PROMPT CREATE OR REPLACE Procedure  262 :: GetSupplierInfo
CREATE OR REPLACE Procedure GetSupplierInfo
(
  pStatus number,
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=0 then 
  OPEN data_cursor for
   Select SupplierName, SupplierID, SAddress,
    STelephone,SFax,SEmail,SURL,SContactperson,
    SRemarks from T_Supplier
    order by SupplierName;
/*If the Value is 1 then retun as the */

elsif pStatus=1 then 
     OPEN data_cursor for
   Select SupplierName, SupplierID, SAddress,
    STelephone,SFax,SEmail,SURL,SContactperson,
    SRemarks from T_Supplier where 
     SupplierID=pWhereValue order by SupplierName;
end if;
END GetSupplierInfo;
/

PROMPT CREATE OR REPLACE Procedure  263 ::  getTreeBugetList
create or replace Procedure getTreeBugetList(
 io_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pOrdertype varchar2,
  pBudgetno IN varchar2 default null,
  sDate IN date,
  eDate IN date
)
AS
BEGIN
if pQueryType=0 then
    OPEN io_cursor FOR
    select BUDGETID,BUDGETNO,revision from t_budget
   where BUDGETPREDATE>=sDate and BUDGETPREDATE <=EDate and ordertypeid=pOrdertype order by TO_NUMBER(BUDGETNO) desc, revision desc ;
elsif pQueryType=1 then
    OPEN io_cursor FOR
    select BUDGETID,BUDGETNO||' '|| chr(revision) as BUDGETNO ,BUDGETPREDATE from  t_budget a
    where a.BUDGETPREDATE>=sDate and a.BUDGETPREDATE <=EDate and ordertypeid=pOrdertype order by a.BUDGETPREDATE desc;
elsif pQueryType=2 then
    OPEN io_cursor FOR
    select a.BUDGETID,a.BUDGETNO,getfncwobtype(b.orderno) as Dorderno from  t_budget a,t_workorder b
where a.BUDGETID=b.BUDGETID and a.revision=65 and a.ordertypeid=pOrdertype and  a.BUDGETPREDATE>=sDate and a.BUDGETPREDATE <=EDate order by Dorderno desc,a.budgetno desc;
elsif pQueryType=3 then
    OPEN io_cursor FOR
    select a.BUDGETID,a.BUDGETNO,a.orderno,b.gdorderno from  t_budget a,t_gworkorder b
    where a.orderno=b.gorderno and a.ordertypeid=pOrdertype and complete=1 and a.BUDGETPREDATE>=sDate and a.BUDGETPREDATE <=EDate order by orderno,budgetno desc;
   end if;
END getTreeBugetList;
/

PROMPT CREATE OR REPLACE Procedure  264 ::  GetGarmentsItemsInfo
create or replace Procedure GetGarmentsItemsInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  pBUDGETID number,
  pSTAGEID number
)
AS
BEGIN
    open one_cursor for
	SELECT PID,BUDGETID,STAGEID,PARAMID,SUPPLIERID,CONSUMPTIONPERDOZ,QUNATITY,QTY,UNITPRICE,TOTALCOST,SUBCONID
		FROM t_garmentscost WHERE  BUDGETID=pBUDGETID AND STAGEID=pSTAGEID
	union
	SELECT PARAMID+1 as PID,pBUDGETID AS BUDGETID,STAGEID,PARAMID,0 AS SUPPLIERID,0 AS CONSUMPTIONPERDOZ,0 AS QUNATITY,'' AS QTY,0 AS UNITPRICE,0 AS TOTALCOST,0 AS SUBCONID
		FROM T_BUDGETSTAGEPARAMETER
		WHERE PARAMID NOT IN(SELECT PARAMID FROM t_garmentscost WHERE  BUDGETID=pBUDGETID AND STAGEID=pSTAGEID) and stageid=pSTAGEID order by PARAMID;
END GetGarmentsItemsInfo;
/



PROMPT CREATE OR REPLACE Procedure  265 :: GetGMarkupInsertUpdate

CREATE OR REPLACE Procedure GetGMarkupInsertUpdate
(
	pPID in number,
	pBUDGETID IN NUMBER,
  	pSTAGEID IN NUMBER,
    pPARAMID IN NUMBER,
	pSUPPLIERID in number,
    pCONSUMPTIONPERDOZ IN Number,
	pQUNATITY IN Number,
	pUNITPRICE IN Number,
	pTOTALCOST IN Number
)
AS
	ID NUMBER;
	tQty number;
	total number;
BEGIN
	SELECT Seq_accesoriesPID.NEXTVAL INTO ID FROM DUAL;
	select round(sum(TOTALCOST)) into tQty from t_garmentscost where budgetid=pBUDGETID and stageid in(7,8,9);
	total:=(tQty*(pQUNATITY/100));	
	if pPID=pPARAMID+1 then
    	INSERT INTO T_Garmentscost(PID,BUDGETID,STAGEID,PARAMID,SUPPLIERID,CONSUMPTIONPERDOZ,QUNATITY,UNITPRICE,TOTALCOST) values (ID,pBUDGETID,pSTAGEID,pPARAMID,pSUPPLIERID,pCONSUMPTIONPERDOZ,pQUNATITY,pUNITPRICE,total) ;           
	else
    	UPDATE T_Garmentscost SET SUPPLIERID=pSUPPLIERID,CONSUMPTIONPERDOZ=pCONSUMPTIONPERDOZ,QUNATITY=pQUNATITY,UNITPRICE=pUNITPRICE,TOTALCOST=total WHERE  STAGEID=pSTAGEID AND BUDGETID=pBUDGETID AND PID=pPID;
 end if;
END GetGMarkupInsertUpdate;
/

PROMPT CREATE OR REPLACE Procedure  266 :: GetBillOrderList
CREATE OR REPLACE Procedure GetBillOrderList
(
  data_cursor IN OUT pReturnData.c_Records,
  pStatus number,
  pClient  VARCHAR2,
  pBasictype varchar2

)
AS
BEGIN
/*if the Value is 0 then retun all the Data */
/*if the Value is 0 then retun all the Data */
if pStatus=1 then
  OPEN data_cursor for
   Select a.ORDERNO,getfncWOBType(a.ORDERNO) as btype,a.ORDERLINEITEM,a.RATE,
   a.FABRICTYPEID,b.FABRICTYPE,a.ShadeGroupID,c.SHADEGROUPNAME,a.Shade, 
   a.QUANTITY AS ORDQTY,a.SQTY AS ORDSQTY,a.UNITOFMEASID as PUNIT,a.SUNIT,
	a.QUANTITY AS PRDQTY,a.SQTY AS PRDSQTY,           
	NVL((SELECT SUM(QUANTITY) FROM T_DINVOICEITEMS
	WHERE ORDERNO=a.ORDERNO AND FABRICTYPEID=a.FABRICTYPEID),0) AS DELQTY,
	NVL((SELECT SUM(SQUANTITY) FROM T_DINVOICEITEMS
	WHERE ORDERNO=a.ORDERNO AND FABRICTYPEID=a.FABRICTYPEID),0) AS DELSQTY,
        NVL((SELECT SUM(BILLITEMSQTY) FROM T_BILLITEMS
	WHERE ORDERNO=a.ORDERNO AND WOITEMSL=a.WOITEMSL),0) AS  BILLQTY,
	NVL((SELECT SUM(SQTY) FROM T_BILLITEMS
	WHERE ORDERNO=a.ORDERNO AND WOITEMSL=a.WOITEMSL),0) AS  BILLSQTY,
        (a.QUANTITY-(NVL((SELECT SUM(BILLITEMSQTY) FROM T_BILLITEMS
	WHERE ORDERNO=a.ORDERNO AND WOITEMSL=a.WOITEMSL),0))) AS REMQTY,
	(a.SQTY-(NVL((SELECT SUM(SQTY) FROM T_BILLITEMS
	WHERE ORDERNO=a.ORDERNO AND WOITEMSL=a.WOITEMSL),0))) AS REMSQTY,
	a.woitemsl,d.Basictypeid
   from T_Orderitems a,t_fabricType b,T_ShadeGroup c,t_workorder d
   where a.FABRICTYPEID=b.FABRICTYPEID and a.SHADEGROUPID=c.SHADEGROUPID and a.orderno=d.orderno
		and d.clientid=pClient and d.Basictypeid=pBasictype
		and ((a.QUANTITY-(NVL((SELECT SUM(BILLITEMSQTY) FROM T_BILLITEMS
		WHERE ORDERNO=a.ORDERNO AND WOITEMSL=a.WOITEMSL),0)))>0 or (a.SQTY-(NVL((SELECT SUM(SQTY) FROM T_BILLITEMS
	WHERE ORDERNO=a.ORDERNO AND WOITEMSL=a.WOITEMSL),0)))>0);
end if;
END GetBillOrderList;
/




PROMPT CREATE OR REPLACE Procedure  267 :: GetBillInfo
CREATE OR REPLACE Procedure GetBillInfo
(
	one_cursor IN OUT pReturnData.c_Records,
	many_cursor IN OUT pReturnData.c_Records,	
	pOrdercode in varchar2,	
	pBillNo in NUMBER
)
AS
BEGIN
	open one_cursor for
	select ORDERCODE,BILLNO,BILLDATE,CLIENTID,BILLDISCOUNT,BILLDISCOMMENTS,BILLDISPERC,KNITTING,DYEING,FABRIC,
	CURRENCYID,CONRATE,CANCELLED,BILLCOMMENTS,EMPLOYEEID from T_BILL
	where BillNo=pBillNo and ORDERCODE=pOrdercode;

	open many_cursor for
        SELECT  A.ORDERCODE,A.BILLNO,A.BILLITEMSL,A.DORDERCODE,A.DINVOICENO,A.DITEMSL,A.WORDERCODE,A.ORDERNO,               
 		A.WOITEMSL,A.BILLITEMSQTY,A.BILLITEMSUNITPRICE,c.FabricTypeId,c.Shadegroupid,c.Shade,A.COLORDEPTHID,
        a.punit,a.sqty,a.sunit		
        FROM T_BILLITEMS A,T_BILL B,T_orderitems C
        WHERE  A.ORDERNO=C.ORDERNO and 
			a.ordercode=b.ordercode AND 
			A.WOITEMSL=C.WOITEMSL AND 
			A.BILLNO=B.BILLNO AND 
		    A.BILLNO=pBillNo and 
			a.ORDERCODE=pOrdercode
  		ORDER BY BILLITEMSL;    
END GetBillInfo;
/




PROMPT CREATE OR REPLACE Procedure  268 :: getBillTree
CREATE OR REPLACE Procedure getBillTree (
  tree_cursor IN OUT pReturnData.c_Records,
  pOrderCode varchar2,  
  pGroupID number,
  pStartDate date,
  pEndDate date
)
AS
BEGIN
  /* Order No Assecndig*/
  if pGroupID=0 then
    open tree_cursor for
    select BillNo,Billno as BBillNO
    from T_Bill
    where BillDate between pStartDate and pEndDate and Ordercode=pOrderCode
    order by BILLNO desc;
 /* Order Date */
  elsif pGroupID = 1 then
    open tree_cursor for
    select BillNo,BillDate
    from T_Bill
    where BillDate between pStartDate and pEndDate and Ordercode=pOrderCode
    order by BillDate, BILLNO desc;  

 /* Client Name */
  elsif pGroupID = 2 then
    open tree_cursor for
    select BillNo,ClientName
    from T_Bill,T_Client    
    where T_BILL.ClientID=T_Client.ClientID and
    BillDate between pStartDate and pEndDate and Ordercode=pOrderCode
    order by ClientName, BILLNO desc;
  end if;
END getBillTree;
/

PROMPT CREATE OR REPLACE Procedure  269 :: GetYarnRequisitionInfo
CREATE OR REPLACE Procedure GetYarnRequisitionInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  many_cursor IN OUT pReturnData.c_Records,
  pKnitStockID number
)
AS
BEGIN

    open one_cursor for
    select StockId, YarnRequisitionTypeId, ReferenceNo, ReferenceDate, StockTransNO, StockTransDATE,
    supplierID,SupplierInvoiceNo,SupplierInvoiceDate,Remarks, SubConId,execute
    from T_YarnRequisition
    where StockId=pKnitStockID;

    open many_cursor for
    select PID,a.ORDERNO,GetfncWOBType(OrderNo) as btype,a.STOCKID, KNTISTOCKITEMSL,
    YarnCountId, YarnTypeId,FabricTypeId,OrderlineItem,Quantity,Squantity,PunitOfmeasId,SUNITOFMEASID,
    YarnBatchNo,shadegroupid,Shade,REMARKS,CurrentStock,BUDGETQTY,REMAINQTY,supplierID,DYEDLOTNO,a.yarnfor
    from T_YarnRequisitionItems a
    where STOCKID=pKnitStockID
    order by KNTISTOCKITEMSL asc;
END GetYarnRequisitionInfo;
/



PROMPT CREATE OR REPLACE Procedure  270 :: NextStockTransNo
CREATE OR REPLACE Procedure NextStockTransNo
(
  one_cursor IN OUT pReturnData.c_Records  
)
AS
BEGIN

    open one_cursor for
    select max(STOCKTRANSNO) from (Select to_number(STOCKTRANSNO) as STOCKTRANSNO from t_knitstock
    where KNTITRANSACTIONTYPEID=1);

END NextStockTransNo;
/


PROMPT CREATE OR REPLACE Procedure  271 :: GetKnitYarnStockWOFabricType 
CREATE OR REPLACE Procedure GetKnitYarnStockWOFabricType(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pWorkOrderNo NUMBER,
  pFabricTypeID in varchar2,
  pSHADEGROUPID NUMBER
)
AS
tmpBType varchar2(200);
tmpbudgetid number;
tmpCountShade number;
tmpCountFabric number;
BEGIN

SELECT BASICTYPEID into tmpBType FROM T_WORKORDER WHERE ORDERNO=pWorkOrderNo;
SELECT budgetID into tmpbudgetid FROM T_WORKORDER WHERE ORDERNO=pWorkOrderNo;
SELECT COUNT(*) INTO tmpCountShade FROM T_FABRICCONSUMPTION
	WHERE BudgetID=tmpbudgetid and FabricTypeID=pFabricTypeID and SHADEGROUPID=pSHADEGROUPID;
/*GRAY YARN REQUISITION FROM KNITTING FLOOR For KNITTING*/
if pQueryType=1 then

  if ((tmpBType='FG') or (tmpBType='FS') or (tmpBType='SF')) then
	if (tmpCountShade>0) then
	open data_cursor for  /*FOR NEW BUDGET WITH SHADE GROUP*/
	select 	yy.YARNBATCHNO,yy.SUPPLIERID,s.suppliername AS SUPPLIERNAME,yy.PUnitOfMeasId,xx.YARNCOUNTID,xx.YARNTYPEID,
			d.YarnCount,e.YarnType,f.UnitOfMeas,'' as DYEDLOTNO,'' as Shade,(nvl(yy.Qty,0)) AS  CurrentStock,
			xx.Quantity as Quantity,yy.YarnFor,	
			(NVL((SELECT SUM(aa.QUANTITY) FROM T_YARNREQUISITION bb,T_YARNREQUISITIONITEMS aa
				WHERE aa.STOCKID=bb.STOCKID and bb.YARNREQUISITIONTYPEID in (1,4,5,6) and
				aa.OrderNo=pWorkOrderNo AND aa.YARNCOUNTID=xx.YARNCOUNTID AND aa.YARNTYPEID=xx.YARNTYPEID AND
				aa.FABRICTYPEID=pFabricTypeID and aa.SHADEGROUPID=pSHADEGROUPID
			GROUP BY aa.OrderNo,aa.YARNCOUNTID,aa.YARNTYPEID,aa.FABRICTYPEID,aa.SHADEGROUPID),0)-
			NVL((SELECT SUM(aa.QUANTITY) FROM T_KNITSTOCK bb,T_KNITSTOCKITEMS aa
				WHERE aa.STOCKID=bb.STOCKID and bb.KNTITRANSACTIONTYPEID in (9,10,11,14) and
				aa.OrderNo=pWorkOrderNo AND aa.YARNCOUNTID=xx.YARNCOUNTID AND aa.YARNTYPEID=xx.YARNTYPEID AND
				aa.FABRICTYPEID=pFabricTypeID  and aa.SHADEGROUPID=pSHADEGROUPID
				GROUP BY aa.OrderNo,aa.YARNCOUNTID,aa.YARNTYPEID,aa.FABRICTYPEID,aa.SHADEGROUPID),0)) as ReqQuantity,
			(xx.Quantity-NVL((SELECT SUM(aa.QUANTITY) FROM T_YARNREQUISITION bb,T_YARNREQUISITIONITEMS aa
				WHERE aa.STOCKID=bb.STOCKID and bb.YARNREQUISITIONTYPEID in (1,4,5,6) and
				aa.OrderNo=pWorkOrderNo AND aa.YARNCOUNTID=xx.YARNCOUNTID AND aa.YARNTYPEID=xx.YARNTYPEID AND
				aa.FABRICTYPEID=pFabricTypeID  and aa.SHADEGROUPID=pSHADEGROUPID
				GROUP BY aa.OrderNo,aa.YARNCOUNTID,aa.YARNTYPEID,aa.FABRICTYPEID,aa.SHADEGROUPID),0)+
				NVL((SELECT SUM(aa.QUANTITY) FROM T_KNITSTOCK bb,T_KNITSTOCKITEMS aa
				WHERE aa.STOCKID=bb.STOCKID and bb.KNTITRANSACTIONTYPEID in (9,10,11,14) and
				aa.OrderNo=pWorkOrderNo AND aa.YARNCOUNTID=xx.YARNCOUNTID AND aa.YARNTYPEID=xx.YARNTYPEID AND
				aa.FABRICTYPEID=pFabricTypeID  and aa.SHADEGROUPID=pSHADEGROUPID
				GROUP BY aa.OrderNo,aa.YARNCOUNTID,aa.YARNTYPEID,aa.FABRICTYPEID,aa.SHADEGROUPID),0)) as RQuantity
	from (SELECT p.YARNCOUNTID,p.YARNTYPEID,sum(p.Quantity) as Quantity
			FROM T_YARNCOST p,T_FABRICcONSUMPTION q,T_Budget r
			WHERE p.PPID=q.PID and q.BudgetID=r.BudgetID and p.BudgetID=q.BudgetID AND
			r.budgetid=tmpbudgetid and q.FabricTypeID=pFabricTypeID and q.SHADEGROUPID=pSHADEGROUPID
			group by p.YARNCOUNTID,p.YARNTYPEID) xx,
		(SELECT b.YARNBATCHNO,b.yarnfor,b.SUPPLIERID,b.PUnitOfMeasId,b.YARNCOUNTID,b.YARNTYPEID,sum(b.Quantity*ATLGYS) as Qty
			FROM T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c
			WHERE 	a.StockID=b.StockID and a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID
			group by b.YARNBATCHNO,b.SUPPLIERID,b.PUnitOfMeasId,b.YARNCOUNTID,b.YARNTYPEID,b.yarnfor
			having sum(b.Quantity*ATLGYS)>0) yy, 
		T_YarnCount d, T_YarnType e, T_UnitOfMeas f,T_Supplier s
	where xx.YARNCOUNTID=yy.YARNCOUNTID and xx.YARNCOUNTID=d.YARNCOUNTID and yy.supplierid=s.supplierid and
        xx.YARNTYPEID=yy.YARNTYPEID and  xx.YARNTYPEID=e.YARNTYPEID and yy.PUnitOfMeasId=f.UnitOfMeasId
    order by d.YarnCount,e.YarnType;
	else  
	open data_cursor for /*FOR OLD BUDGET WITH NOT SHADE GROUP*/
	select yy.YARNBATCHNO,yy.SUPPLIERID,s.suppliername AS SUPPLIERNAME,yy.PUnitOfMeasId,xx.YARNCOUNTID,xx.YARNTYPEID,
       d.YarnCount,e.YarnType,f.UnitOfMeas,'' as DYEDLOTNO,'' as Shade,
	(nvl(yy.Qty,0)) AS  CurrentStock,
	xx.Quantity as Quantity,yy.YarnFor,
		NVL((SELECT SUM(aa.QUANTITY) FROM T_YARNREQUISITION bb,T_YARNREQUISITIONITEMS aa
  		WHERE aa.STOCKID=bb.STOCKID and bb.YARNREQUISITIONTYPEID in (1,4,5,6) and
		aa.OrderNo=pWorkOrderNo AND aa.YARNCOUNTID=xx.YARNCOUNTID AND aa.YARNTYPEID=xx.YARNTYPEID AND
		aa.FABRICTYPEID=pFabricTypeID
  		GROUP BY aa.OrderNo,aa.YARNCOUNTID,aa.YARNTYPEID,aa.FABRICTYPEID),0) as ReqQuantity,
	(xx.Quantity-NVL((SELECT SUM(aa.QUANTITY) FROM T_YARNREQUISITION bb,T_YARNREQUISITIONITEMS aa
  		WHERE aa.STOCKID=bb.STOCKID and bb.YARNREQUISITIONTYPEID in (1,4,5,6) and
		aa.OrderNo=pWorkOrderNo AND aa.YARNCOUNTID=xx.YARNCOUNTID AND aa.YARNTYPEID=xx.YARNTYPEID AND
		aa.FABRICTYPEID=pFabricTypeID
  		GROUP BY aa.OrderNo,aa.YARNCOUNTID,aa.YARNTYPEID,aa.FABRICTYPEID),0)) as RQuantity
	from (SELECT p.YARNCOUNTID,p.YARNTYPEID,sum(p.Quantity) as Quantity
		FROM T_YARNCOST p,T_FABRICcONSUMPTION q,T_Budget r
		WHERE p.PPID=q.PID and q.BudgetID=r.BudgetID and p.BudgetID=q.BudgetID AND
		r.budgetid=tmpbudgetid and q.FabricTypeID=pFabricTypeID and q.SHADEGROUPID=pSHADEGROUPID
		group by p.YARNCOUNTID,p.YARNTYPEID) xx,
     	(SELECT b.YARNBATCHNO,b.yarnfor,b.SUPPLIERID,b.PUnitOfMeasId,b.YARNCOUNTID,b.YARNTYPEID,sum(b.Quantity*ATLGYS) as Qty
 	FROM T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c
 	WHERE 	a.StockID=b.StockID and a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID
	group by b.YARNBATCHNO,b.SUPPLIERID,b.PUnitOfMeasId,b.YARNCOUNTID,b.YARNTYPEID,b.yarnfor
	having sum(b.Quantity*ATLGYS)>0) yy, T_YarnCount d, T_YarnType e, T_UnitOfMeas f,T_Supplier s
        where xx.YARNCOUNTID=yy.YARNCOUNTID and xx.YARNCOUNTID=d.YARNCOUNTID and yy.supplierid=s.supplierid and
        xx.YARNTYPEID=yy.YARNTYPEID and  xx.YARNTYPEID=e.YARNTYPEID and yy.PUnitOfMeasId=f.UnitOfMeasId
        order by d.YarnCount,e.YarnType;
		end if;
   elsif ((tmpBType='FC')) then
  	open data_cursor for
	
	select yy.YARNBATCHNO,yy.SUPPLIERID,s.suppliername AS SUPPLIERNAME,yy.PUnitOfMeasId,xx.YARNCOUNTID,xx.YARNTYPEID,
        d.YarnCount,e.YarnType,f.UnitOfMeas,'' as DYEDLOTNO,'' as Shade,
	(nvl(yy.Qty,0)) AS  CurrentStock,
	xx.Quantity as Quantity,yy.YarnFor,
		(NVL((SELECT SUM(aa.QUANTITY) FROM T_YARNREQUISITIONITEMS aa,T_YARNREQUISITION bb
  		WHERE aa.OrderNo=pWorkOrderNo AND aa.YARNCOUNTID=xx.YARNCOUNTID AND aa.YARNTYPEID=xx.YARNTYPEID  AND
		aa.FABRICTYPEID=pFabricTypeID and aa.stockid=bb.stockid and bb.YARNREQUISITIONTYPEID in (1,4,5,6)
  		GROUP BY aa.OrderNo,aa.YARNCOUNTID,aa.YARNTYPEID),0)-NVL((SELECT SUM(aa.QUANTITY) FROM T_KNITSTOCK bb,T_KNITSTOCKITEMS aa
  		WHERE aa.OrderNo=pWorkOrderNo AND aa.YARNCOUNTID=xx.YARNCOUNTID AND aa.YARNTYPEID=xx.YARNTYPEID  AND
		aa.FABRICTYPEID=pFabricTypeID and aa.stockid=bb.stockid and bb.KNTITRANSACTIONTYPEID in (9,10,11,14)
  		GROUP BY aa.OrderNo,aa.YARNCOUNTID,aa.YARNTYPEID),0)) as ReqQuantity,
	(xx.Quantity-NVL((SELECT SUM(aa.QUANTITY) FROM T_YARNREQUISITIONITEMS aa,T_YARNREQUISITION bb
  		WHERE aa.OrderNo=pWorkOrderNo AND aa.YARNCOUNTID=xx.YARNCOUNTID AND aa.YARNTYPEID=xx.YARNTYPEID  AND
		aa.FABRICTYPEID=pFabricTypeID and aa.stockid=bb.stockid and bb.YARNREQUISITIONTYPEID in (1,4,5,6)
  		GROUP BY aa.OrderNo,aa.YARNCOUNTID,aa.YARNTYPEID),0)+NVL((SELECT SUM(aa.QUANTITY) FROM T_KNITSTOCK bb,T_KNITSTOCKITEMS aa
  		WHERE aa.OrderNo=pWorkOrderNo AND aa.YARNCOUNTID=xx.YARNCOUNTID AND aa.YARNTYPEID=xx.YARNTYPEID  AND
		aa.FABRICTYPEID=pFabricTypeID and aa.stockid=bb.stockid and bb.KNTITRANSACTIONTYPEID in (9,10,11,14)
  		GROUP BY aa.OrderNo,aa.YARNCOUNTID,aa.YARNTYPEID),0)) as RQuantity
	from (SELECT r.YARNCOUNTID,r.YARNTYPEID,sum(p.Quantity*YARNPERCENT/100) AS Quantity
 	FROM T_ORDERITEMS p,T_YARNDESC r
 	WHERE p.ORDERLINEITEM=r.ORDERLINEITEM and p.ORDERNO=pWorkOrderNo and p.FabricTypeID=pFabricTypeID
	group by r.YARNCOUNTID,r.YARNTYPEID) xx,
    	(SELECT b.YARNBATCHNO,b.yarnfor,b.SUPPLIERID,b.PUnitOfMeasId,b.YARNCOUNTID,b.YARNTYPEID,sum(b.Quantity*ATLGYS) as Qty
 	FROM T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c
 	WHERE 	a.StockID=b.StockID and a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID
	group by b.YARNBATCHNO,b.SUPPLIERID,b.PUnitOfMeasId,b.YARNCOUNTID,b.YARNTYPEID,b.yarnfor
	having sum(b.Quantity*ATLGYS)>0) yy, T_YarnCount d, T_YarnType e, T_UnitOfMeas f,T_Supplier s
        where xx.YARNCOUNTID=yy.YARNCOUNTID and xx.YARNCOUNTID=d.YARNCOUNTID and yy.supplierid=s.supplierid and
        xx.YARNTYPEID=yy.YARNTYPEID and  xx.YARNTYPEID=e.YARNTYPEID and yy.PUnitOfMeasId=f.UnitOfMeasId
        order by d.YarnCount,e.YarnType;
		
   end if;

/*GRAY YARN REQUISITION DYEING FLOOR For DYEING*/
elsif pQueryType=2 then

  if ((tmpBType='FG') or (tmpBType='FS') or (tmpBType='SF')) then
  	if (tmpCountShade>0) then
	open data_cursor for  /*FOR NEW BUDGET WITH SHADE GROUP*/
	select YY.YARNBATCHNO,yy.SUPPLIERID,s.suppliername AS SUPPLIERNAME,yy.PUnitOfMeasId,xx.YARNCOUNTID,xx.YARNTYPEID,
       d.YarnCount,e.YarnType,f.UnitOfMeas,'' as DYEDLOTNO,'' as Shade,
	   (nvl(yy.Qty,0)) AS  CurrentStock,xx.Quantity as Quantity,yy.YarnFor,
		NVL((SELECT SUM(aa.QUANTITY) FROM T_YARNREQUISITION bb,T_YARNREQUISITIONITEMS aa
  		WHERE aa.STOCKID=bb.STOCKID and bb.YARNREQUISITIONTYPEID in (1,4,5,6) and
		aa.OrderNo=pWorkOrderNo AND aa.YARNCOUNTID=xx.YARNCOUNTID AND aa.YARNTYPEID=xx.YARNTYPEID and aa.SHADEGROUPID=pSHADEGROUPID
  		GROUP BY aa.OrderNo,aa.YARNCOUNTID,aa.YARNTYPEID,aa.SHADEGROUPID),0) as ReqQuantity,
	(xx.Quantity-NVL((SELECT SUM(aa.QUANTITY) FROM T_YARNREQUISITION bb,T_YARNREQUISITIONITEMS aa
  		WHERE aa.STOCKID=bb.STOCKID and bb.YARNREQUISITIONTYPEID in (1,4,5,6) and
		aa.OrderNo=pWorkOrderNo AND aa.YARNCOUNTID=xx.YARNCOUNTID AND 
		aa.YARNTYPEID=xx.YARNTYPEID and aa.SHADEGROUPID=pSHADEGROUPID
  		GROUP BY aa.OrderNo,aa.YARNCOUNTID,aa.YARNTYPEID,aa.SHADEGROUPID),0)) as RQuantity
	from (SELECT p.YARNCOUNTID,p.YARNTYPEID,sum(p.Quantity) as Quantity
		FROM T_YARNCOST p,T_FABRICcONSUMPTION q,T_Budget r
		WHERE p.PPID=q.PID and q.BudgetID=r.BudgetID and
		p.BudgetID=q.BudgetID AND r.budgetid=tmpbudgetid
		group by p.YARNCOUNTID,p.YARNTYPEID) xx,
     	(SELECT b.YARNBATCHNO,b.yarnfor,b.SUPPLIERID,b.PUnitOfMeasId,b.YARNCOUNTID,b.YARNTYPEID,sum(b.Quantity*ATLGYS) as Qty
		FROM T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c
		WHERE 	a.StockID=b.StockID and a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID
		group by b.YARNBATCHNO,b.SUPPLIERID,b.PUnitOfMeasId,b.YARNCOUNTID,b.YARNTYPEID,b.yarnfor
		having sum(b.Quantity*ATLGYS)>0) yy, T_YarnCount d, T_YarnType e, T_UnitOfMeas f,T_Supplier s
    where xx.YARNCOUNTID=yy.YARNCOUNTID(+) and xx.YARNCOUNTID=d.YARNCOUNTID and yy.supplierid=s.supplierid(+) and
    xx.YARNTYPEID=yy.YARNTYPEID(+) and  xx.YARNTYPEID=e.YARNTYPEID and yy.PUnitOfMeasId=f.UnitOfMeasId
    order by d.YarnCount,e.YarnType;
	
	ELSE
			open data_cursor for  /*FOR OLD BUDGET WITH NOT SHADE GROUP*/
	select YY.YARNBATCHNO,yy.SUPPLIERID,s.suppliername AS SUPPLIERNAME,yy.PUnitOfMeasId,xx.YARNCOUNTID,xx.YARNTYPEID,
       d.YarnCount,e.YarnType,f.UnitOfMeas,'' as DYEDLOTNO,'' as Shade,
	(nvl(yy.Qty,0)) AS  CurrentStock,
	xx.Quantity as Quantity,yy.YarnFor,
		NVL((SELECT SUM(aa.QUANTITY) FROM T_YARNREQUISITION bb,T_YARNREQUISITIONITEMS aa
  		WHERE aa.STOCKID=bb.STOCKID and bb.YARNREQUISITIONTYPEID in (1,4,5,6) and
		aa.OrderNo=pWorkOrderNo AND aa.YARNCOUNTID=xx.YARNCOUNTID AND aa.YARNTYPEID=xx.YARNTYPEID
  		GROUP BY aa.OrderNo,aa.YARNCOUNTID,aa.YARNTYPEID),0) as ReqQuantity,
	(xx.Quantity-NVL((SELECT SUM(aa.QUANTITY) FROM T_YARNREQUISITION bb,T_YARNREQUISITIONITEMS aa
  		WHERE aa.STOCKID=bb.STOCKID and bb.YARNREQUISITIONTYPEID in (1,4,5,6) and
		aa.OrderNo=pWorkOrderNo AND aa.YARNCOUNTID=xx.YARNCOUNTID AND aa.YARNTYPEID=xx.YARNTYPEID
  		GROUP BY aa.OrderNo,aa.YARNCOUNTID,aa.YARNTYPEID),0)) as RQuantity
	from (SELECT p.YARNCOUNTID,p.YARNTYPEID,sum(p.Quantity) as Quantity
 	FROM T_YARNCOST p,T_FABRICcONSUMPTION q,T_Budget r
 	WHERE p.PPID=q.PID and q.BudgetID=r.BudgetID and
	p.BudgetID=q.BudgetID AND r.budgetid=tmpbudgetid
	group by p.YARNCOUNTID,p.YARNTYPEID) xx,
     	(SELECT b.YARNBATCHNO,b.yarnfor,b.SUPPLIERID,b.PUnitOfMeasId,b.YARNCOUNTID,b.YARNTYPEID,sum(b.Quantity*ATLGYS) as Qty
 	FROM T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c
 	WHERE 	a.StockID=b.StockID and a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID
	group by b.YARNBATCHNO,b.SUPPLIERID,b.PUnitOfMeasId,b.YARNCOUNTID,b.YARNTYPEID,b.yarnfor
	having sum(b.Quantity*ATLGYS)>0) yy, T_YarnCount d, T_YarnType e, T_UnitOfMeas f,T_Supplier s
        where xx.YARNCOUNTID=yy.YARNCOUNTID(+) and xx.YARNCOUNTID=d.YARNCOUNTID and yy.supplierid=s.supplierid(+) and
        xx.YARNTYPEID=yy.YARNTYPEID(+) and  xx.YARNTYPEID=e.YARNTYPEID and yy.PUnitOfMeasId=f.UnitOfMeasId
        order by d.YarnCount,e.YarnType;
	END IF;
   elsif ((tmpBType='FC')) then
  	open data_cursor for
	select yy.YARNBATCHNO,yy.SUPPLIERID,s.suppliername AS SUPPLIERNAME,yy.PUnitOfMeasId,xx.YARNCOUNTID,xx.YARNTYPEID,
        d.YarnCount,e.YarnType,f.UnitOfMeas,'' as DYEDLOTNO,'' as Shade,
	(nvl(yy.Qty,0)) AS  CurrentStock,
	xx.Quantity as Quantity,yy.YarnFor,
		NVL((SELECT SUM(aa.QUANTITY) FROM T_YARNREQUISITIONITEMS aa
  		WHERE aa.OrderNo=pWorkOrderNo AND aa.YARNCOUNTID=xx.YARNCOUNTID AND aa.YARNTYPEID=xx.YARNTYPEID
  		GROUP BY aa.OrderNo,aa.YARNCOUNTID,aa.YARNTYPEID),0) as ReqQuantity,
	(xx.Quantity-NVL((SELECT SUM(aa.QUANTITY) FROM T_YARNREQUISITIONITEMS aa
  		WHERE aa.OrderNo=pWorkOrderNo AND aa.YARNCOUNTID=xx.YARNCOUNTID AND aa.YARNTYPEID=xx.YARNTYPEID
  		GROUP BY aa.OrderNo,aa.YARNCOUNTID,aa.YARNTYPEID,aa.FABRICTYPEID),0)) as RQuantity
	from (SELECT r.YARNCOUNTID,r.YARNTYPEID,sum(p.Quantity*YARNPERCENT/100) AS Quantity
 	FROM T_ORDERITEMS p,T_YARNDESC r
 	WHERE p.ORDERLINEITEM=r.ORDERLINEITEM and p.ORDERNO=pWorkOrderNo
	group by r.YARNCOUNTID,r.YARNTYPEID) xx,
    	(SELECT b.YARNBATCHNO,b.yarnfor,b.SUPPLIERID,b.PUnitOfMeasId,b.YARNCOUNTID,b.YARNTYPEID,sum(b.Quantity*ATLGYS) as Qty
 	FROM T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c
 	WHERE 	a.StockID=b.StockID and a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID
	group by b.YARNBATCHNO,b.SUPPLIERID,b.PUnitOfMeasId,b.YARNCOUNTID,b.YARNTYPEID,b.yarnfor
	having sum(b.Quantity*ATLGYS)>0) yy, T_YarnCount d, T_YarnType e, T_UnitOfMeas f,T_Supplier s
        where xx.YARNCOUNTID=yy.YARNCOUNTID(+) and xx.YARNCOUNTID=d.YARNCOUNTID and yy.supplierid=s.supplierid(+) and
        xx.YARNTYPEID=yy.YARNTYPEID(+) and  xx.YARNTYPEID=e.YARNTYPEID and yy.PUnitOfMeasId=f.UnitOfMeasId
        order by d.YarnCount,e.YarnType;

   end if;
          /*ATLDYS For Dyed Yarn Req For Floor For Knitting Floor/Subcon */
elsif pQueryType=11 then

	if ((tmpBType='FG') or (tmpBType='FS') or (tmpBType='SF')) then
		open data_cursor for
		select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
		b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, b.Shade,
		YarnType,b.PUnitOfMeasId,UnitOfMeas,b.DyedLotno,b.shadegroupid,i.shadegroupname,b.fabrictypeid,j.fabrictype,
		sum(Quantity*ATLDYS) CurrentStock,0 as Quantity,b.YarnFor,

			NVL((SELECT SUM(aa.QUANTITY) FROM T_YARNREQUISITION bb,T_YARNREQUISITIONITEMS aa
			WHERE aa.STOCKID=bb.STOCKID and bb.YARNREQUISITIONTYPEID in (2,7) and aa.OrderNo=pWorkOrderNo AND 
			aa.YARNCOUNTID=b.YARNCOUNTID AND aa.YARNTYPEID=b.YARNTYPEID AND	aa.FABRICTYPEID=pFabricTypeID and aa.SHADEGROUPID=pSHADEGROUPID
			GROUP BY aa.OrderNo,aa.YARNCOUNTID,aa.YARNTYPEID,aa.FABRICTYPEID,aa.SHADEGROUPID),0) as ReqQuantity,
	/*(sum(Quantity*ATLDYS)-NVL((SELECT SUM(aa.QUANTITY) FROM T_YARNREQUISITION bb,T_YARNREQUISITIONITEMS aa
  		WHERE aa.STOCKID=bb.STOCKID and bb.YARNREQUISITIONTYPEID in (2,7) and
		aa.OrderNo=pWorkOrderNo AND aa.YARNCOUNTID=b.YARNCOUNTID AND aa.YARNTYPEID=b.YARNTYPEID AND
		aa.FABRICTYPEID=pFabricTypeID  and aa.SHADEGROUPID=pSHADEGROUPID
  		GROUP BY aa.OrderNo,aa.YARNCOUNTID,aa.YARNTYPEID,aa.FABRICTYPEID,aa.SHADEGROUPID),0)) as RQuantity,*/
			(sum(Quantity*ATLDYS)) as RQuantity,
		0 AS  OrdQty
		from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
		T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier h,t_shadegroup i,T_FabricType j
		where a.StockID=b.StockID and
		b.fabrictypeid=j.fabrictypeid(+) and
		b.shadegroupid=i.shadegroupid and
		b.SUPPLIERID=h.SUPPLIERID(+) and
		a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
		b.YarnCountId=d.YarnCountId and
		b.YarnTypeId= e.YarnTypeId and
		b.PUnitOfMeasID=f.UnitOfMeasID and b.ORDERNO=pWorkOrderNo and 
		b.FABRICTYPEID=pFabricTypeID and b.SHADEGROUPID=pSHADEGROUPID
		group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
		YarnType,b.PUnitOfMeasId,UnitOfMeas,b.YARNBATCHNO,b.yarnfor,
		b.SUPPLIERID,h.SUPPLIERNAME,b.DyedLotno,b.shadegroupid,i.shadegroupname,b.fabrictypeid,j.fabrictype
		having (sum(Quantity*ATLDYS))>0  
	UNION ALL
			select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
		b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, b.Shade,
		YarnType,b.PUnitOfMeasId,UnitOfMeas,b.DyedLotno,b.shadegroupid,i.shadegroupname,b.fabrictypeid,j.fabrictype,
		sum(Quantity*ATLDYS) CurrentStock,0 as Quantity,b.YarnFor,
			NVL((SELECT SUM(aa.QUANTITY) FROM T_YARNREQUISITION bb,T_YARNREQUISITIONITEMS aa
			WHERE aa.STOCKID=bb.STOCKID and bb.YARNREQUISITIONTYPEID in (2,7) and aa.OrderNo=pWorkOrderNo AND 
			aa.YARNCOUNTID=b.YARNCOUNTID AND aa.YARNTYPEID=b.YARNTYPEID AND	aa.SHADEGROUPID=pSHADEGROUPID
			GROUP BY aa.OrderNo,aa.YARNCOUNTID,aa.YARNTYPEID,aa.SHADEGROUPID),0) as ReqQuantity,
	/*(sum(Quantity*ATLDYS)-NVL((SELECT SUM(aa.QUANTITY) FROM T_YARNREQUISITION bb,T_YARNREQUISITIONITEMS aa
  		WHERE aa.STOCKID=bb.STOCKID and bb.YARNREQUISITIONTYPEID in (2,7) and
		aa.OrderNo=pWorkOrderNo AND aa.YARNCOUNTID=b.YARNCOUNTID AND aa.YARNTYPEID=b.YARNTYPEID AND
		aa.FABRICTYPEID=pFabricTypeID  and aa.SHADEGROUPID=pSHADEGROUPID
  		GROUP BY aa.OrderNo,aa.YARNCOUNTID,aa.YARNTYPEID,aa.FABRICTYPEID,aa.SHADEGROUPID),0)) as RQuantity,*/
			(sum(Quantity*ATLDYS)) as RQuantity,
		0 AS  OrdQty
		from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
		T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier h,t_shadegroup i,T_FabricType j
		where a.StockID=b.StockID and
		b.fabrictypeid=j.fabrictypeid(+) and
		b.shadegroupid=i.shadegroupid and
		b.SUPPLIERID=h.SUPPLIERID(+) and
		a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
		b.YarnCountId=d.YarnCountId and
		b.YarnTypeId= e.YarnTypeId and
		b.PUnitOfMeasID=f.UnitOfMeasID and b.ORDERNO=pWorkOrderNo and 
		(b.FABRICTYPEID IS NULL) and b.SHADEGROUPID=pSHADEGROUPID
		group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
		YarnType,b.PUnitOfMeasId,UnitOfMeas,b.YARNBATCHNO,
		b.SUPPLIERID,h.SUPPLIERNAME,b.DyedLotno,b.shadegroupid,i.shadegroupname,b.fabrictypeid,j.fabrictype,b.yarnfor
		having (sum(Quantity*ATLDYS))>0  ;
	elsif ((tmpBType='FC')) then
		open data_cursor for
		select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
		b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, b.Shade,
		YarnType,b.PUnitOfMeasId,UnitOfMeas,b.DyedLotno,b.shadegroupid,i.shadegroupname,b.fabrictypeid,j.fabrictype,
		sum(Quantity*ATLDYS) CurrentStock,0 as Quantity,b.YarnFor,
		0 as ReqQuantity,0 RQuantity,0 AS  OrdQty
		from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
		T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier h,t_shadegroup i,T_FabricType j
		where a.StockID=b.StockID and
		b.fabrictypeid=j.fabrictypeid(+) and
		b.shadegroupid=i.shadegroupid and
		b.SUPPLIERID=h.SUPPLIERID(+) and
		a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
		b.YarnCountId=d.YarnCountId and
		b.YarnTypeId= e.YarnTypeId and
		b.PUnitOfMeasID=f.UnitOfMeasID and b.ORDERNO=pWorkOrderNo and 
		b.FABRICTYPEID=pFabricTypeID and b.SHADEGROUPID=pSHADEGROUPID
		group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
		YarnType,b.PUnitOfMeasId,UnitOfMeas,b.YARNBATCHNO,
		b.SUPPLIERID,h.SUPPLIERNAME,b.DyedLotno,b.shadegroupid,i.shadegroupname,b.fabrictypeid,j.fabrictype,b.yarnfor
		having sum(Quantity*ATLDYS)>0  
	UNION ALL
			select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
		b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount, b.Shade,
		YarnType,b.PUnitOfMeasId,UnitOfMeas,b.DyedLotno,b.shadegroupid,i.shadegroupname,b.fabrictypeid,j.fabrictype,
		sum(Quantity*ATLDYS) CurrentStock,0 as Quantity,b.YarnFor,
		0 as ReqQuantity,0 RQuantity,0 AS  OrdQty
		from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
		T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier h,t_shadegroup i,T_FabricType j
		where a.StockID=b.StockID and
		b.fabrictypeid=j.fabrictypeid(+) and
		b.shadegroupid=i.shadegroupid and
		b.SUPPLIERID=h.SUPPLIERID(+) and
		a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
		b.YarnCountId=d.YarnCountId and
		b.YarnTypeId= e.YarnTypeId and
		b.PUnitOfMeasID=f.UnitOfMeasID and b.ORDERNO=pWorkOrderNo and 
		(b.FABRICTYPEID IS NULL) and b.SHADEGROUPID=pSHADEGROUPID
		group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.Shade,
		YarnType,b.PUnitOfMeasId,UnitOfMeas,b.YARNBATCHNO,
		b.SUPPLIERID,h.SUPPLIERNAME,b.DyedLotno,b.shadegroupid,i.shadegroupname,b.fabrictypeid,j.fabrictype,b.yarnfor
		having sum(Quantity*ATLDYS)>0  ;
	end if;
end if;
END GetKnitYarnStockWOFabricType;
/



PROMPT CREATE OR REPLACE Procedure  272 :: GetOrderBudgetcheck
create or replace Procedure GetOrderBudgetcheck
(
 pOrderno IN NUMBER,
 pBudgetid in number,
 pRecsAffected out Number
)
AS
	tmpCount number(12);
 	Budgetqty number(12,2);
 	ptemp Varchar2(50) default null;
	pfabtype varchar2(100);
 	quantity_mismatch exception;
BEGIN
	select count(*) into tmpCount from t_orderitems where orderno=pOrderno;
	if (tmpCount>0) then
		for rec in(select fabrictypeid,SHADEGROUPID,sum(quantity) as Quantity from t_orderitems where orderno=pOrderno 
				group by fabrictypeid,SHADEGROUPID)
		Loop 
		select Nvl(sum(TOTALCONSUMPTION),0) into Budgetqty from t_fabricconsumption 
			where budgetid=pBudgetid and FABRICTYPEID=rec.fabrictypeid and SHADEGROUPID=rec.SHADEGROUPID;
		if (rec.Quantity>Budgetqty) then 
			ptemp:=rec.fabrictypeid;
		else 
			ptemp:=101;
		End if;
		END LOOP;
		pRecsAffected:=ptemp;
	else
		pRecsAffected:=101;
	End if;
END GetOrderBudgetcheck;
/


/* UPDATED DATE 09.05.2010 BY HABIB*/
PROMPT CREATE OR REPLACE Procedure  273 :: GetBQuantityCheck
Create or Replace Procedure GetBQuantityCheck
(
 pIDD IN Varchar2,
 pBrefpid IN NUMBER,
 pIQty in number,
 pRecsAffected out NUMBER
)
AS
mainBudgetqty number(12,2);
insertedOrderqty number(12,2);
currentRowQty number(12,2);
legaldueQty  number(12,2);
tmpQty number(12,2);
tmpAvailableQty number(12);
tmpCount number(12);

BEGIN
 /*select (NVL(sum(TOTALCONSUMPTION),0)+nvl(sum(TOTALCONSUMPTION)*(Select max(PROCESSLOSS) From T_YARNCOST Where PPID=pBrefpid group by PPID)/100,0)) into mainBudgetqty */
 
 select NVL(sum(TOTALCONSUMPTION),0) into mainBudgetqty 
 from t_fabricconsumption
  where pid=pBrefpid group by PID;

select NVL(max(count(*)),0) into tmpCount from t_orderitems
  where brefpid=pBrefpid AND orderlineitem<>pIDD group by brefpid;
  
 if (tmpCount>0) then 
	select nvl(sum(quantity),0) into insertedOrderqty from t_orderitems
	where brefpid= pBrefpid AND orderlineitem<>pIDD group by brefpid;
 else
	insertedOrderqty:=0;
 end if;

 tmpAvailableQty:=mainBudgetqty-insertedOrderqty;
 
 if(tmpAvailableQty>=pIQty) then
    pRecsAffected:=0;
 elsif (tmpAvailableQty<pIQty)  then
         pRecsAffected:=tmpAvailableQty;
 end if;
EXCEPTION
 WHEN NO_DATA_FOUND THEN pRecsAffected:=1111111;
END GetBQuantityCheck;
/



PROMPT CREATE OR REPLACE Procedure  274 :: YarnPartyLookup
CREATE OR REPLACE Procedure YarnPartyLookup
(

  data_cursor IN OUT pReturnData.c_Records
)

AS

BEGIN

  OPEN data_cursor for
  select pid,partyname
  from t_yarnparty
  order by pid;
END YarnPartyLookup;
/

PROMPT CREATE OR REPLACE Procedure  275 :: GetBudgetItemList

Create or Replace Procedure GetBudgetItemList
(
  data_cursor IN OUT pReturnData.c_Records,
  pQuerytype number,
  pBudgetID number

)
AS
tmpYarnPrec number;
BEGIN

if(pQuerytype=1) then
open data_cursor for
 	SELECT a.BUDGETID,a.PID,a.stageid,a.shadegroupid,d.shadegroupname,a.fabrictypeid,a.gsm,b.fabrictype,a.TOTALCONSUMPTION AS BudgetQty,
	nvl((Select max(PROCESSLOSS) From T_YARNCOST Where PPID=a.PID),0) as WastagePrc,
	a.TOTALCONSUMPTION+(a.TOTALCONSUMPTION*nvl((Select max(PROCESSLOSS) From T_YARNCOST Where PPID=a.PID),0))/100 as BudgetQtyWithWastage,
	/*(a.TOTALCONSUMPTION+(a.TOTALCONSUMPTION*nvl((Select max(PROCESSLOSS) From T_YARNCOST Where PPID=a.PID),0))/100-nvl(c.issuedQty,0)) as curqty*/
	(a.TOTALCONSUMPTION-nvl(c.issuedQty,0)) as curqty
    FROM T_FabricConsumption a,T_Fabrictype b,
  	(select brefpid as p,Nvl(sum(y.quantity),0) as issuedQty from t_orderitems y,t_workorder z
  	where y.orderno=z.orderno and z.budgetid=pBudgetID group by brefpid)  c,T_shadegroup d
        WHERE a.fabrictypeid=b.fabrictypeid and 
		a.shadegroupid=d.shadegroupid and 
		a.pid=c.p(+) and a.budgetid=pBudgetID
        order by a.PID;
end if;
END GetBudgetItemList;
/



PROMPT CREATE OR REPLACE Procedure  276 :: GetAuxStockforPrice
CREATE OR REPLACE Procedure GetAuxStockforPrice(
  data_cursor IN OUT pReturnData.c_Records,   
  pAuxStockID NUMBER,
  pAuxTypeID NUMBER,
  pStockDate DATE
)
AS
BEGIN
    open data_cursor for
    select a.AuxID,a.Auxtypeid,b.DyeBase,a.AUXNAME,c.UnitOfMeas,sum(d.StockQty*f.AuxStockMain) CurrentStock,E.SUPPLIERID,g.suppliername
    from T_Auxiliaries a,T_DyeBase b,T_UnitOfMeas c,T_AuxStockItem d,T_AuxStock e,T_AuxStockTypeDetails f,T_supplier g 
    where 
	a.DyeBaseID= b.DyeBaseID (+) and
	a.UnitOfMeasID=c.UnitOfMeasID(+) and
	a.AuxID=d.AuxID and
	d.AuxStockID=e.AuxStockID and
	e.AuxStockTypeID=f.AuxStockTypeID and
	E.SUPPLIERID=g.SUPPLIERID and
    a.AuxID=pAuxStockID and
    a.auxtypeid=pAuxTypeID	
    group by a.AuxID,a.Auxtypeid,b.DyeBase,a.AUXNAME,c.UnitOfMeas,E.SUPPLIERID,g.suppliername
    having sum(d.StockQty*f.AuxStockMain)>0
  order by b.DyeBase, a.AuxName;
END GetAuxStockforPrice;
/



PROMPT CREATE OR REPLACE Procedure  277 :: GetKnitYarnStockPosition2
CREATE OR REPLACE Procedure GetKnitYarnStockPosition2(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pKnitTranTypeID NUMBER,
  pSuppid in Number,
  pStockDate DATE
)
AS
BEGIN
if pQueryType=1 then
    open data_cursor for
    select b.YARNBATCHNO,b.SUPPLIERID,g.SUPPLIERNAME,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,
    YarnType,b.PUnitOfMeasId,UnitOfMeas, sum(Quantity*ATLGYS) CurrentStock,b.yarnfor
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, T_YarnCount d,
    T_YarnType e, T_UnitOfMeas f,T_supplier g
    where a.StockID=b.StockID and
    b.SUPPLIERID=g.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
 (pSuppid=0 or b.SUPPLIERID=pSuppid) and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.YARNBATCHNO,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,
    YarnType,b.PUnitOfMeasId,UnitOfMeas, b.SUPPLIERID,g.SUPPLIERNAME,b.yarnfor
    having sum(Quantity*ATLGYS)>0 ORDER BY YarnCount ASC;

elsif pQueryType=2 then
    open data_cursor for
    select b.YARNBATCHNO,b.SUPPLIERID,g.SUPPLIERNAME,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,
    YarnType,b.PUnitOfMeasId,UnitOfMeas, sum(Quantity*GYLTP) CurrentStock,b.yarnfor
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, T_YarnCount d,
    T_YarnType e, T_UnitOfMeas f,T_supplier g
    where a.StockID=b.StockID and
    b.SUPPLIERID=g.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
 (pSuppid=0 or b.SUPPLIERID=pSuppid) and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.YARNBATCHNO,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,
    YarnType,b.PUnitOfMeasId,UnitOfMeas, b.SUPPLIERID,g.SUPPLIERNAME,b.yarnfor
    having sum(Quantity*GYLTP)>0 ORDER BY YarnCount ASC;

elsif pQueryType=3 then
    open data_cursor for
    select b.YARNBATCHNO,b.SUPPLIERID,g.SUPPLIERNAME,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,
    YarnType,b.PUnitOfMeasId,UnitOfMeas, sum(Quantity*GYLFP) CurrentStock,b.yarnfor
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, T_YarnCount d,
    T_YarnType e, T_UnitOfMeas f,T_supplier g
    where a.StockID=b.StockID and
    b.SUPPLIERID=g.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
 (pSuppid=0 or b.SUPPLIERID=pSuppid) and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.YARNBATCHNO,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,
    YarnType,b.PUnitOfMeasId,UnitOfMeas, b.SUPPLIERID,g.SUPPLIERNAME,b.yarnfor
    having sum(Quantity*GYLFP)>0 ORDER BY YarnCount ASC;

elsif pQueryType=4 then
    open data_cursor for
    select b.YARNBATCHNO,b.SUPPLIERID,g.SUPPLIERNAME,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,
    YarnType,b.PUnitOfMeasId,UnitOfMeas, sum(Quantity*ATLGYS) CurrentStock,b.yarnfor
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, T_YarnCount d,
    T_YarnType e, T_UnitOfMeas f,T_supplier g
    where a.StockID=b.StockID and
    b.SUPPLIERID=g.SUPPLIERID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
 (pSuppid=0 or b.SUPPLIERID=pSuppid) and
    b.PUnitOfMeasID=f.UnitOfMeasID and
    STOCKTRANSDATE <= pStockDate
    group by b.YARNBATCHNO,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,
    YarnType,b.PUnitOfMeasId,UnitOfMeas, b.SUPPLIERID,g.SUPPLIERNAME,b.yarnfor
    having sum(Quantity*ATLGYS)>0 ORDER BY YarnCount ASC;
end if;
END GetKnitYarnStockPosition2;
/




PROMPT CREATE OR REPLACE Procedure  278 :: GSampleLookup
CREATE OR REPLACE Procedure GSampleLookup
(
  data_cursor IN OUT pReturnData.c_Records
)
AS

BEGIN

  OPEN data_cursor for
  select SampleID,Sampletype from T_GSampleType order by Sampletype;

END GSampleLookup;
/
PROMPT CREATE OR REPLACE Procedure  279 :: getTreeSGpassList
CREATE OR REPLACE Procedure getTreeSGpassList (
  io_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,  
  sDate IN date,
  eDate IN date
)
AS
BEGIN

  if pQueryType=0 then
    OPEN io_cursor FOR
    select GPID, GPassNo from T_GSampleGatePass
    where GPassDate>=SDate and GPassDate<=EDate
    order by GPassNo desc;

  elsif pQueryType=1 then
    OPEN io_cursor FOR
    select GPID, GPassNo, GPassDate 
	from 	T_GSampleGatePass
    where 	GPassDate>=SDate and 
			GPassDate<=EDate
    order by GPassDate desc, GPassNo desc; 
	
end if;

END getTreeSGpassList;
/
PROMPT CREATE OR REPLACE Procedure  280:: GetSmapleGatepass
CREATE OR REPLACE Procedure GetSmapleGatepass
(
  one_cursor IN OUT pReturnData.c_Records,
  many_cursor IN OUT pReturnData.c_Records,
  pGPID number
)
AS
BEGIN
    open one_cursor for
    select GPID,GPASSNO,GPASSDATE,CLIENTNAME,ORDERNO,CONTACTPERSON,DELIVERYPLACE,PREPAREDBY,CTELEPHONE,EMPLOYEEID
    from T_GSampleGatePass
    where GPID=pGPID;
            
    open many_cursor for  
    select ITEMID,SERIALNO,ITEMSDESC,QUANTITY,UNITOFMEASID,RETURNABLE,NONRETURNABLE,GPID,SAMPLEID,style,ReturnedQty,CLIENTID,GORDERNO
    from T_GSampleGatePassItems
    where GPID=pGPID
    order by SERIALNO asc;
END GetSmapleGatepass;
/


PROMPT CREATE OR REPLACE Procedure  281:: GetSampletypeList
CREATE OR REPLACE Procedure GetSampletypeList
(
  pStatus number,  
  data_cursor IN OUT pReturnData.c_Records
)
AS

BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=0 then
  OPEN data_cursor for
    Select SAMPLEID,SAMPLETYPE from t_gsampletype order by SAMPLEID;
end if;
END GetSampletypeList;
/

PROMPT CREATE OR REPLACE Procedure  282 :: GetBudgetPosted
CREATE OR REPLACE Procedure GetBudgetPosted(
  pBudgetid IN NUMBER,  
  pRecsAffected out NUMBER
)
AS
  posted NUMBER;
BEGIN   
   SELECT COMPLETE into posted from T_Budget where  BUDGETID=pBudgetid;
   pRecsAffected := posted;
END GetBudgetPosted;
/


PROMPT CREATE OR REPLACE Procedure  283 :: OrderWiseTransaction
CREATE OR REPLACE Procedure OrderWiseTransaction(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pOrderno NUMBER
)
AS
BEGIN
/*  All Summary Report*/
  if pQueryType=0 then
    open data_cursor for
     select a.STOCKTRANSNO,A.STOCKTRANSDATE AS TDATE,b.YARNBATCHNO,b.squantity as sqty,b.SUNITOFMEASID as sunitid,b.SUPPLIERID,g.SUPPLIERNAME,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,
    YarnType,b.PUnitOfMeasId,j.UnitOfMeas as sunit,f.UnitOfMeas,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,'' AS ORDERLINEITEM,h.SHADEGROUPID,
    h.SHADEGROUPNAME,'' AS SHADE,b.FABRICTYPEID,i.FABRICTYPE,(Quantity) CurrentStock,0 as mainstock,0 as REMAINQTY,b.DYEDLOTNO,'' as reqno,0 as reqqty
    from
	 	T_YarnRequisition a, 
		T_YarnRequisitionItems b, 
		T_YARNREQUISITIONTYPE c, 
		T_YarnCount d,
    		T_YarnType e, 
		T_UnitOfMeas f,
		t_supplier g,
		T_ShadeGroup h,
		T_fabricType i,
		T_UnitOfMeas j
    where 
		a.StockID=b.StockID and
    		b.SUPPLIERID=g.SUPPLIERID(+) and
    		b.SHADEGROUPID=h.SHADEGROUPID and
   		b.FABRICTYPEID=i.FABRICTYPEID and
    		a.YARNREQUISITIONTYPEID=c.YARNREQUISITIONTYPEID and
    		b.YarnCountId=d.YarnCountId and
    		b.YarnTypeId= e.YarnTypeId and
    		b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    		b.SUNITOFMEASID=j.UnitOfMeasID(+) and    
    		a.YARNREQUISITIONTYPEID=1 and
    		B.ORDERNO = pOrderno 
    ORDER BY 
		btype,a.STOCKTRANSNO DESC;
elsif pQueryType=1 then
    open data_cursor for
     select a.STOCKTRANSNO,A.STOCKTRANSDATE AS TDATE,b.YARNBATCHNO,b.squantity as sqty,b.SUNITOFMEASID as sunitid,b.SUPPLIERID,g.SUPPLIERNAME,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,
    YarnType,b.PUnitOfMeasId,j.UnitOfMeas as sunit,f.UnitOfMeas,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,'' AS ORDERLINEITEM,h.SHADEGROUPID,
    h.SHADEGROUPNAME,'' AS SHADE,b.FABRICTYPEID,i.FABRICTYPE,(Quantity) CurrentStock,0 as mainstock,0 as REMAINQTY,b.DYEDLOTNO,'' as reqno,0 as reqqty
    from T_YarnRequisition a, T_YarnRequisitionItems b, T_YARNREQUISITIONTYPE c, T_YarnCount d,
    T_YarnType e, T_UnitOfMeas f,t_supplier g,T_ShadeGroup h,T_fabricType i,T_UnitOfMeas j
    where a.StockID=b.StockID and
    b.SUPPLIERID=g.SUPPLIERID(+) and
    b.SHADEGROUPID=h.SHADEGROUPID and
    b.FABRICTYPEID=i.FABRICTYPEID and
    a.YARNREQUISITIONTYPEID=c.YARNREQUISITIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUNITOFMEASID=j.UnitOfMeasID(+) and    
    a.YARNREQUISITIONTYPEID=4 and
    B.ORDERNO = pOrderno 
    ORDER BY btype,a.STOCKTRANSNO DESC;
elsif pQueryType=2 then
    open data_cursor for
    select a.STOCKTRANSNO,STOCKTRANSDATE AS TDATE,b.squantity as sqty,b.SUNITOFMEASID as sunitid,b.YARNBATCHNO,b.SUPPLIERID,g.SUPPLIERNAME,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,
    YarnType,b.PUnitOfMeasId,j.UnitOfMeas as sunit,f.UnitOfMeas,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,'' AS ORDERLINEITEM,
    h.SHADEGROUPID,h.SHADEGROUPNAME,b.SHADE,b.FABRICTYPEID,i.FABRICTYPE,(Quantity) CurrentStock,0 as mainstock,0 as REMAINQTY ,b.DYEDLOTNO,'' as reqno,0 as reqqty
    from T_YarnRequisition a, T_YarnRequisitionItems b, T_YARNREQUISITIONTYPE c, T_YarnCount d,
    T_YarnType e, T_UnitOfMeas f,t_supplier g,T_ShadeGroup h,T_fabricType i,T_UnitOfMeas j
    where a.StockID=b.StockID and
    b.SUPPLIERID=g.SUPPLIERID(+) and
   b.FABRICTYPEID=i.FABRICTYPEID(+) and
    b.SHADEGROUPID=h.SHADEGROUPID and
    a.YARNREQUISITIONTYPEID=c.YARNREQUISITIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUNITOFMEASID=j.UnitOfMeasID(+) and
    b.orderno= pOrderno  and
    a.YARNREQUISITIONTYPEID=5
    ORDER BY btype,a.STOCKTRANSNO DESC;
elsif pQueryType=3 then
    open data_cursor for
    select a.STOCKTRANSNO,STOCKTRANSDATE AS TDATE,b.squantity as sqty,b.SUNITOFMEASID as sunitid,b.YARNBATCHNO,b.SUPPLIERID,g.SUPPLIERNAME,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,
    YarnType,b.PUnitOfMeasId,j.UnitOfMeas as sunit,f.UnitOfMeas,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,'' AS ORDERLINEITEM,
    h.SHADEGROUPID,h.SHADEGROUPNAME,b.SHADE,b.FABRICTYPEID,i.FABRICTYPE,(Quantity) CurrentStock,0  as mainstock,0 as REMAINQTY,b.DYEDLOTNO,'' as reqno,0 as reqqty 
    from T_YarnRequisition a, T_YarnRequisitionItems b, T_YARNREQUISITIONTYPE c, T_YarnCount d,
    T_YarnType e, T_UnitOfMeas f,t_supplier g,T_ShadeGroup h,T_fabricType i,T_UnitOfMeas j
    where a.StockID=b.StockID and
    b.SUPPLIERID=g.SUPPLIERID(+) and
   b.FABRICTYPEID=i.FABRICTYPEID(+) and
    b.SHADEGROUPID=h.SHADEGROUPID and
    a.YARNREQUISITIONTYPEID=c.YARNREQUISITIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUNITOFMEASID=j.UnitOfMeasID(+) and
    b.orderno= pOrderno  and
    a.YARNREQUISITIONTYPEID=6
    ORDER BY btype,a.STOCKTRANSNO DESC;
elsif pQueryType=4 then
  open data_cursor for
  select a.STOCKTRANSNO,STOCKTRANSDATE AS TDATE,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
    '' AS OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
    j.SHADEGROUPNAME,'' AS Shade,YarnType,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,
    f.UnitOfMeas,'' AS DyedLotno,b.subconid,'' AS subconname,Quantity as CurrentStock,SQuantity as Sqty,0  as mainstock,0 as REMAINQTY,REQUISITIONNO as reqno,REQQUANTITY as reqqty
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier h,T_fabricType i,T_ShadeGroup j,T_UnitOfMeas k
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID(+) and 
    b.SHADEGROUPID=j.SHADEGROUPID and
    b.FABRICTYPEID=i.FABRICTYPEID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUnitOfMeasID=k.UnitOfMeasID(+) and
    a.KNTITRANSACTIONTYPEID=3 and
    B.ORDERNO = pOrderno 
ORDER BY btype,a.STOCKTRANSNO DESC;
elsif pQueryType=5 then
  open data_cursor for
  select a.STOCKTRANSNO,STOCKTRANSDATE AS TDATE,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
    '' AS OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
    j.SHADEGROUPNAME,B. Shade,YarnType,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,
    f.UnitOfMeas,'' AS DyedLotno,b.subconid,'' AS subconname,Quantity as CurrentStock,SQuantity as Sqty,0  as mainstock,0 as REMAINQTY,REQUISITIONNO as reqno,REQQUANTITY as reqqty
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier h,T_fabricType i,T_ShadeGroup j,T_UnitOfMeas k
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID(+) and 
    b.SHADEGROUPID=j.SHADEGROUPID and
    b.FABRICTYPEID=i.FABRICTYPEID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUnitOfMeasID=k.UnitOfMeasID(+) and
    a.KNTITRANSACTIONTYPEID=4 and
    B.ORDERNO = pOrderno 
ORDER BY btype,a.STOCKTRANSNO DESC;
elsif pQueryType=6 then
  open data_cursor for
 select a.STOCKTRANSNO,STOCKTRANSDATE AS TDATE,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
    '' AS OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
    j.SHADEGROUPNAME,B.Shade,YarnType,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,
    f.UnitOfMeas,'' AS DyedLotno,b.subconid,'' AS subconname,Quantity as CurrentStock,SQuantity as Sqty,0  as mainstock,0 as REMAINQTY,REQUISITIONNO as reqno,REQQUANTITY as reqqty
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier h,T_fabricType i,T_ShadeGroup j,T_UnitOfMeas k
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID(+) and 
    b.SHADEGROUPID=j.SHADEGROUPID and
    b.FABRICTYPEID=i.FABRICTYPEID(+) and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUnitOfMeasID=k.UnitOfMeasID(+) and
    a.KNTITRANSACTIONTYPEID=5 and
    B.ORDERNO = pOrderno 
ORDER BY btype,a.STOCKTRANSNO DESC;
elsif pQueryType=7 then
  open data_cursor for
 select a.STOCKTRANSNO,STOCKTRANSDATE AS TDATE,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
    '' AS OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
    j.SHADEGROUPNAME,B.Shade,YarnType,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,
    f.UnitOfMeas,'' AS DyedLotno,b.subconid,'' AS subconname,Quantity as CurrentStock,SQuantity as Sqty,0  as mainstock,0 as REMAINQTY,REQUISITIONNO as reqno,REQQUANTITY as reqqty
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier h,T_fabricType i,T_ShadeGroup j,T_UnitOfMeas k
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID(+) and 
    b.SHADEGROUPID=j.SHADEGROUPID and
    b.FABRICTYPEID=i.FABRICTYPEID(+) and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUnitOfMeasID=k.UnitOfMeasID(+) and
    a.KNTITRANSACTIONTYPEID=12 and
    B.ORDERNO = pOrderno 
ORDER BY btype,a.STOCKTRANSNO DESC;
elsif pQueryType=8 then
  open data_cursor for
 select a.BATCHNO AS STOCKTRANSNO ,A.BATCHDATE AS TDATE, b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,0 AS SUPPLIERID,'' AS SUPPLIERNAME,b.YARNBATCHNO,
    '' AS OrderlineItem,'' AS YARNTYPEID,'' AS YARNCOUNTID,'' AS YarnCount,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
    j.SHADEGROUPNAME,B.Shade,'' AS YarnType,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,
    f.UnitOfMeas,B.DyedLotno,0 AS subconid,'' AS subconname,Quantity as CurrentStock,SQuantity as Sqty,0  as mainstock,0 as REMAINQTY,'' as reqno,0 as reqqty
    from T_DBATCH a, T_DBATCHITEMS b,T_UnitOfMeas f,T_fabricType i,T_ShadeGroup j,T_UnitOfMeas k
    where a.DBATCHID=b.DBATCHID and    
    b.SHADEGROUPID=j.SHADEGROUPID and
    b.FABRICTYPEID=i.FABRICTYPEID(+) and 
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUnitOfMeasID=k.UnitOfMeasID(+) and   
    B.ORDERNO = pOrderno 
ORDER BY btype,STOCKTRANSNO DESC;
elsif pQueryType=9 then
  open data_cursor for
 select a.DINVOICEID,a.INVOICENO,a.INVOICEDATE,a.ORDERNO,getfncWOBType(a.ORDERNO) as btype,FINISHEDDIA,FINISHEDGSM,b.YARNBATCHNO,
    GWT,FWT,DBATCH,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
    j.SHADEGROUPNAME,B.Shade,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,
    f.UnitOfMeas,Quantity,SQuantity as Sqty
    from 
		t_dinvoice a,
 		t_dinvoiceItems b,
		T_UnitOfMeas f,
		T_fabricType i,
		T_ShadeGroup j,
		T_UnitOfMeas k
    where 
		a.DINVOICEID=b.DINVOICEID and    
    		b.SHADEGROUPID=j.SHADEGROUPID and
    		b.FABRICTYPEID=i.FABRICTYPEID(+) and 
    		b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    		b.SUnitOfMeasID=k.UnitOfMeasID(+) and 
			DTYPE=21 and  
    		a.ORDERNO = pOrderno 
	ORDER BY 
		a.DINVOICEID,btype,a.INVOICENO DESC;
elsif pQueryType=10 then
  open data_cursor for
 select A.STOCKID,a.STOCKTRANSNO,STOCKTRANSDATE AS TDATE,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
    '' AS OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
    j.SHADEGROUPNAME,B.Shade,YarnType,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,
    f.UnitOfMeas,B.DyedLotno,b.subconid,'' AS subconname,Quantity as CurrentStock,SQuantity as Sqty,0  as mainstock,0 as REMAINQTY,REQUISITIONNO as reqno,REQQUANTITY as reqqty
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier h,T_fabricType i,T_ShadeGroup j,T_UnitOfMeas k
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID(+) and 
    b.SHADEGROUPID=j.SHADEGROUPID and
    b.FABRICTYPEID=i.FABRICTYPEID(+) and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUnitOfMeasID=k.UnitOfMeasID(+) and
    a.KNTITRANSACTIONTYPEID=8 and
    B.ORDERNO = pOrderno 
ORDER BY btype,a.STOCKTRANSNO DESC;
elsif pQueryType=11 then
  open data_cursor for
 select A.STOCKID,a.STOCKTRANSNO,STOCKTRANSDATE AS TDATE,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
    '' AS OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
    j.SHADEGROUPNAME,B.Shade,YarnType,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,
    f.UnitOfMeas,B.DyedLotno,b.subconid,'' AS subconname,Quantity as CurrentStock,SQuantity as Sqty,0  as mainstock,0 as REMAINQTY,REQUISITIONNO as reqno,REQQUANTITY as reqqty
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier h,T_fabricType i,T_ShadeGroup j,T_UnitOfMeas k
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID(+) and 
    b.SHADEGROUPID=j.SHADEGROUPID and
    b.FABRICTYPEID=i.FABRICTYPEID(+) and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUnitOfMeasID=k.UnitOfMeasID(+) and
    a.KNTITRANSACTIONTYPEID=13 and
    B.ORDERNO = pOrderno 
ORDER BY btype,a.STOCKTRANSNO DESC;
elsif pQueryType=12 then
  open data_cursor for
 select A.STOCKID,a.STOCKTRANSNO,STOCKTRANSDATE AS TDATE,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
    '' AS OrderlineItem,b.YARNTYPEID,b.KMACHINEPIDREF,b.YARNCOUNTID,YarnCount,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
    j.SHADEGROUPNAME,B.Shade,YarnType,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,
    f.UnitOfMeas,B.DyedLotno,b.subconid,'' AS subconname,Quantity as CurrentStock,SQuantity as Sqty,0  as mainstock,0 as REMAINQTY,REQUISITIONNO as reqno,REQQUANTITY as reqqty
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier h,T_fabricType i,T_ShadeGroup j,T_UnitOfMeas k
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID(+) and 
    b.SHADEGROUPID=j.SHADEGROUPID and
    b.FABRICTYPEID=i.FABRICTYPEID(+) and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUnitOfMeasID=k.UnitOfMeasID(+) and
    a.KNTITRANSACTIONTYPEID=6 and
    B.ORDERNO = pOrderno 
ORDER BY btype,a.STOCKTRANSNO DESC;
elsif pQueryType=13 then
  open data_cursor for
 select A.STOCKID,a.STOCKTRANSNO,STOCKTRANSDATE AS TDATE,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
    '' AS OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
    j.SHADEGROUPNAME,B.Shade,YarnType,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,
    f.UnitOfMeas,B.DyedLotno,b.subconid,'' AS subconname,Quantity as CurrentStock,SQuantity as Sqty,0  as mainstock,0 as REMAINQTY,REQUISITIONNO as reqno,REQQUANTITY as reqqty
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier h,T_fabricType i,T_ShadeGroup j,T_UnitOfMeas k
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID(+) and 
    b.SHADEGROUPID=j.SHADEGROUPID and
    b.FABRICTYPEID=i.FABRICTYPEID(+) and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUnitOfMeasID=k.UnitOfMeasID(+) and
    a.KNTITRANSACTIONTYPEID=7 and
    B.ORDERNO = pOrderno 
ORDER BY btype,a.STOCKTRANSNO DESC;
elsif pQueryType=14 then
  open data_cursor for
 select A.STOCKID,a.STOCKTRANSNO,STOCKTRANSDATE AS TDATE,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
    '' AS OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.KMACHINEPIDREF,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
    j.SHADEGROUPNAME,B.Shade,YarnType,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,
    f.UnitOfMeas,B.DyedLotno,b.subconid,'' AS subconname,Quantity as CurrentStock,SQuantity as Sqty,0  as mainstock,0 as REMAINQTY,REQUISITIONNO as reqno,REQQUANTITY as reqqty
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier h,T_fabricType i,T_ShadeGroup j,T_UnitOfMeas k
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID(+) and 
    b.SHADEGROUPID=j.SHADEGROUPID and
    b.FABRICTYPEID=i.FABRICTYPEID(+) and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUnitOfMeasID=k.UnitOfMeasID(+) and
    a.KNTITRANSACTIONTYPEID=24 and
    B.ORDERNO = pOrderno 
ORDER BY btype,a.STOCKTRANSNO DESC;
elsif pQueryType=15 then
  open data_cursor for
 select A.STOCKID,a.STOCKTRANSNO,STOCKTRANSDATE AS TDATE,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
    '' AS OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
    j.SHADEGROUPNAME,B.Shade,YarnType,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,
    f.UnitOfMeas,B.DyedLotno,b.subconid,'' AS subconname,Quantity as CurrentStock,SQuantity as Sqty,0  as mainstock,0 as REMAINQTY,REQUISITIONNO as reqno,REQQUANTITY as reqqty
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier h,T_fabricType i,T_ShadeGroup j,T_UnitOfMeas k
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID(+) and 
    b.SHADEGROUPID=j.SHADEGROUPID and
    b.FABRICTYPEID=i.FABRICTYPEID(+) and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUnitOfMeasID=k.UnitOfMeasID(+) and
    a.KNTITRANSACTIONTYPEID=25 and
    B.ORDERNO = pOrderno 
ORDER BY btype,a.STOCKTRANSNO DESC;
elsif pQueryType=16 then
  open data_cursor for
 select A.STOCKID,a.STOCKTRANSNO,STOCKTRANSDATE AS TDATE,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
    '' AS OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
    j.SHADEGROUPNAME,B.Shade,YarnType,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,
    f.UnitOfMeas,B.DyedLotno,b.subconid,'' AS subconname,Quantity as CurrentStock,SQuantity as Sqty,0  as mainstock,0 as REMAINQTY,REQUISITIONNO as reqno,REQQUANTITY as reqqty
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier h,T_fabricType i,T_ShadeGroup j,T_UnitOfMeas k
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID(+) and 
    b.SHADEGROUPID=j.SHADEGROUPID and
    b.FABRICTYPEID=i.FABRICTYPEID(+) and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUnitOfMeasID=k.UnitOfMeasID(+) and
    a.KNTITRANSACTIONTYPEID=22 and
    B.ORDERNO = pOrderno 
ORDER BY btype,a.STOCKTRANSNO DESC;
elsif pQueryType=17 then
  open data_cursor for
 select A.STOCKID,a.STOCKTRANSNO,STOCKTRANSDATE AS TDATE,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
    '' AS OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
    j.SHADEGROUPNAME,B.Shade,YarnType,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,
    f.UnitOfMeas,B.DyedLotno,b.subconid,'' AS subconname,Quantity as CurrentStock,SQuantity as Sqty,0  as mainstock,0 as REMAINQTY,REQUISITIONNO as reqno,REQQUANTITY as reqqty
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier h,T_fabricType i,T_ShadeGroup j,T_UnitOfMeas k
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID(+) and 
    b.SHADEGROUPID=j.SHADEGROUPID and
    b.FABRICTYPEID=i.FABRICTYPEID(+) and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUnitOfMeasID=k.UnitOfMeasID(+) and
    a.KNTITRANSACTIONTYPEID=23 and
    B.ORDERNO = pOrderno 
ORDER BY btype,a.STOCKTRANSNO DESC;
elsif pQueryType=18 then
    open data_cursor for
    select a.STOCKTRANSNO,STOCKTRANSDATE AS TDATE,b.squantity as sqty,b.SUNITOFMEASID as sunitid,b.YARNBATCHNO,b.SUPPLIERID,g.SUPPLIERNAME,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,
    YarnType,b.PUnitOfMeasId,j.UnitOfMeas as sunit,f.UnitOfMeas,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,'' AS ORDERLINEITEM,
    h.SHADEGROUPID,h.SHADEGROUPNAME,b.SHADE,b.FABRICTYPEID,i.FABRICTYPE,(Quantity) CurrentStock,0 as mainstock,0 as REMAINQTY ,b.DYEDLOTNO,'' as reqno,0 as reqqty
    from T_YarnRequisition a, T_YarnRequisitionItems b, T_YARNREQUISITIONTYPE c, T_YarnCount d,
    T_YarnType e, T_UnitOfMeas f,t_supplier g,T_ShadeGroup h,T_fabricType i,T_UnitOfMeas j
    where a.StockID=b.StockID and
    b.SUPPLIERID=g.SUPPLIERID(+) and
   b.FABRICTYPEID=i.FABRICTYPEID(+) and
    b.SHADEGROUPID=h.SHADEGROUPID and
    a.YARNREQUISITIONTYPEID=c.YARNREQUISITIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUNITOFMEASID=j.UnitOfMeasID(+) and
    b.orderno= pOrderno  and
    a.YARNREQUISITIONTYPEID=2
    ORDER BY btype,a.STOCKTRANSNO DESC;
elsif pQueryType=19 then
    open data_cursor for
    select a.STOCKTRANSNO,STOCKTRANSDATE AS TDATE,b.squantity as sqty,b.SUNITOFMEASID as sunitid,b.YARNBATCHNO,b.SUPPLIERID,g.SUPPLIERNAME,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,
    YarnType,b.PUnitOfMeasId,j.UnitOfMeas as sunit,f.UnitOfMeas,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,'' AS ORDERLINEITEM,
    h.SHADEGROUPID,h.SHADEGROUPNAME,b.SHADE,b.FABRICTYPEID,i.FABRICTYPE,(Quantity) CurrentStock,0  as mainstock,0 as REMAINQTY,b.DYEDLOTNO,'' as reqno,0 as reqqty 
    from T_YarnRequisition a, T_YarnRequisitionItems b, T_YARNREQUISITIONTYPE c, T_YarnCount d,
    T_YarnType e, T_UnitOfMeas f,t_supplier g,T_ShadeGroup h,T_fabricType i,T_UnitOfMeas j
    where a.StockID=b.StockID and
    b.SUPPLIERID=g.SUPPLIERID(+) and
   b.FABRICTYPEID=i.FABRICTYPEID(+) and
    b.SHADEGROUPID=h.SHADEGROUPID and
    a.YARNREQUISITIONTYPEID=c.YARNREQUISITIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUNITOFMEASID=j.UnitOfMeasID(+) and
    b.orderno= pOrderno  and
    a.YARNREQUISITIONTYPEID=7
    ORDER BY btype,a.STOCKTRANSNO DESC;
elsif pQueryType=20 then
  open data_cursor for
 select A.STOCKID,a.STOCKTRANSNO,STOCKTRANSDATE AS TDATE,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
    '' AS OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
    j.SHADEGROUPNAME,B.Shade,YarnType,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,
    f.UnitOfMeas,B.DyedLotno,b.subconid,'' AS subconname,Quantity as CurrentStock,SQuantity as Sqty,0  as mainstock,0 as REMAINQTY,REQUISITIONNO as reqno,REQQUANTITY as reqqty
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier h,T_fabricType i,T_ShadeGroup j,T_UnitOfMeas k
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID(+) and 
    b.SHADEGROUPID=j.SHADEGROUPID and
    b.FABRICTYPEID=i.FABRICTYPEID(+) and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUnitOfMeasID=k.UnitOfMeasID(+) and
    a.KNTITRANSACTIONTYPEID=26 and
    B.ORDERNO = pOrderno 
ORDER BY btype,a.STOCKTRANSNO DESC;
elsif pQueryType=21 then
  open data_cursor for
 select A.STOCKID,a.STOCKTRANSNO,STOCKTRANSDATE AS TDATE,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
    '' AS OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
    j.SHADEGROUPNAME,B.Shade,YarnType,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,
    f.UnitOfMeas,B.DyedLotno,b.subconid,'' AS subconname,Quantity as CurrentStock,SQuantity as Sqty,0  as mainstock,0 as REMAINQTY,REQUISITIONNO as reqno,REQQUANTITY as reqqty
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier h,T_fabricType i,T_ShadeGroup j,T_UnitOfMeas k
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID(+) and 
    b.SHADEGROUPID=j.SHADEGROUPID and
    b.FABRICTYPEID=i.FABRICTYPEID(+) and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUnitOfMeasID=k.UnitOfMeasID(+) and
    a.KNTITRANSACTIONTYPEID=27 and
    B.ORDERNO = pOrderno 
ORDER BY btype,a.STOCKTRANSNO DESC;
elsif pQueryType=22 then
  open data_cursor for
 select A.STOCKID,a.STOCKTRANSNO,STOCKTRANSDATE AS TDATE,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
    '' AS OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
    j.SHADEGROUPNAME,B.Shade,YarnType,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,
    f.UnitOfMeas,B.DyedLotno,b.subconid,'' AS subconname,Quantity as CurrentStock,SQuantity as Sqty,0  as mainstock,0 as REMAINQTY,REQUISITIONNO as reqno,REQQUANTITY as reqqty
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier h,T_fabricType i,T_ShadeGroup j,T_UnitOfMeas k
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID(+) and 
    b.SHADEGROUPID=j.SHADEGROUPID and
    b.FABRICTYPEID=i.FABRICTYPEID(+) and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUnitOfMeasID=k.UnitOfMeasID(+) and
    a.KNTITRANSACTIONTYPEID=44 and
    B.ORDERNO= pOrderno 
ORDER BY btype,a.STOCKTRANSNO DESC;
elsif pQueryType=23 then
  open data_cursor for
 select a.DINVOICEID,a.INVOICENO,a.INVOICEDATE,a.ORDERNO,getfncWOBType(a.ORDERNO) as btype,FINISHEDDIA,FINISHEDGSM,b.YARNBATCHNO,
    GWT,FWT,DBATCH,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,j.SHADEGROUPNAME,B.Shade,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,
	k.unitofmeas as sunit,f.UnitOfMeas,Quantity,SQuantity as Sqty
    from 
		t_dinvoice a,
 		t_dinvoiceItems b,
		T_UnitOfMeas f,
		T_fabricType i,
		T_ShadeGroup j,
		T_UnitOfMeas k
    where 
		a.DINVOICEID=b.DINVOICEID and    
    		b.SHADEGROUPID=j.SHADEGROUPID and
    		b.FABRICTYPEID=i.FABRICTYPEID(+) and 
    		b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    		b.SUnitOfMeasID=k.UnitOfMeasID(+) and
		    DTYPE=17 and    
    		a.ORDERNO = pOrderno 
	ORDER BY 
		a.DINVOICEID,btype,a.INVOICENO DESC;
elsif pQueryType=24 then
    open data_cursor for
    select a.STOCKTRANSNO,STOCKTRANSDATE AS TDATE,b.squantity as sqty,b.SUNITOFMEASID as sunitid,b.YARNBATCHNO,b.SUPPLIERID,g.SUPPLIERNAME,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,
    YarnType,b.PUnitOfMeasId,j.UnitOfMeas as sunit,f.UnitOfMeas,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,'' AS ORDERLINEITEM,
    h.SHADEGROUPID,h.SHADEGROUPNAME,b.SHADE,b.FABRICTYPEID,i.FABRICTYPE,(Quantity) CurrentStock,0  as mainstock,0 as REMAINQTY,b.DYEDLOTNO,'' as reqno,0 as reqqty 
    from T_YarnRequisition a, T_YarnRequisitionItems b, T_YARNREQUISITIONTYPE c, T_YarnCount d,
    T_YarnType e, T_UnitOfMeas f,t_supplier g,T_ShadeGroup h,T_fabricType i,T_UnitOfMeas j
    where a.StockID=b.StockID and
    b.SUPPLIERID=g.SUPPLIERID(+) and
   b.FABRICTYPEID=i.FABRICTYPEID(+) and
    b.SHADEGROUPID=h.SHADEGROUPID and
    a.YARNREQUISITIONTYPEID=c.YARNREQUISITIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUNITOFMEASID=j.UnitOfMeasID(+) and
    b.orderno= pOrderno  and
    a.YARNREQUISITIONTYPEID=3
    ORDER BY btype,a.STOCKTRANSNO DESC;
elsif pQueryType=25 then
  open data_cursor for
 select A.STOCKID,a.STOCKTRANSNO,STOCKTRANSDATE AS TDATE,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
    '' AS OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
    j.SHADEGROUPNAME,B.Shade,YarnType,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,
    f.UnitOfMeas,B.DyedLotno,b.subconid,'' AS subconname,Quantity as CurrentStock,SQuantity as Sqty,0  as mainstock,0 as REMAINQTY,REQUISITIONNO as reqno,REQQUANTITY as reqqty
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier h,T_fabricType i,T_ShadeGroup j,T_UnitOfMeas k
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID(+) and 
    b.SHADEGROUPID=j.SHADEGROUPID and
    b.FABRICTYPEID=i.FABRICTYPEID(+) and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUnitOfMeasID=k.UnitOfMeasID(+) and
    a.KNTITRANSACTIONTYPEID=18 and
    B.ORDERNO = pOrderno 
ORDER BY btype,a.STOCKTRANSNO DESC;
elsif pQueryType=26 then
  open data_cursor for
 select A.STOCKID,a.STOCKTRANSNO,STOCKTRANSDATE AS TDATE,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
    '' AS OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
    j.SHADEGROUPNAME,B.Shade,YarnType,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,
    f.UnitOfMeas,B.DyedLotno,b.subconid,'' AS subconname,Quantity as CurrentStock,SQuantity as Sqty,0  as mainstock,0 as REMAINQTY,REQUISITIONNO as reqno,REQQUANTITY as reqqty
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier h,T_fabricType i,T_ShadeGroup j,T_UnitOfMeas k
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID(+) and 
    b.SHADEGROUPID=j.SHADEGROUPID and
    b.FABRICTYPEID=i.FABRICTYPEID(+) and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUnitOfMeasID=k.UnitOfMeasID(+) and
    a.KNTITRANSACTIONTYPEID=19 and
    B.ORDERNO = pOrderno 
ORDER BY btype,a.STOCKTRANSNO DESC;
elsif pQueryType=27 then
  open data_cursor for
 select A.STOCKID,a.STOCKTRANSNO,STOCKTRANSDATE AS TDATE,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
    '' AS OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
    j.SHADEGROUPNAME,B.Shade,YarnType,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,
    f.UnitOfMeas,B.DyedLotno,b.subconid,'' AS subconname,Quantity as CurrentStock,SQuantity as Sqty,0  as mainstock,0 as REMAINQTY,REQUISITIONNO as reqno,REQQUANTITY as reqqty
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier h,T_fabricType i,T_ShadeGroup j,T_UnitOfMeas k
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID(+) and 
    b.SHADEGROUPID=j.SHADEGROUPID and
    b.FABRICTYPEID=i.FABRICTYPEID(+) and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUnitOfMeasID=k.UnitOfMeasID(+) and
    a.KNTITRANSACTIONTYPEID=20 and
    B.ORDERNO = pOrderno 
ORDER BY btype,a.STOCKTRANSNO DESC;
elsif pQueryType=28 then 
  open data_cursor for
 select a.DINVOICEID,a.INVOICENO,a.INVOICEDATE,a.ORDERNO,getfncWOBType(a.ORDERNO) as btype,FINISHEDDIA,FINISHEDGSM,b.YARNBATCHNO,
    GWT,FWT,DBATCH,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
    j.SHADEGROUPNAME,B.Shade,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,
    f.UnitOfMeas,Quantity,SQuantity as Sqty
    from 
		t_dinvoice a,
 		t_dinvoiceItems b,
		T_UnitOfMeas f,
		T_fabricType i,
		T_ShadeGroup j,
		T_UnitOfMeas k
    where 
		a.DINVOICEID=b.DINVOICEID and    
    		b.SHADEGROUPID=j.SHADEGROUPID and
    		b.FABRICTYPEID=i.FABRICTYPEID(+) and 
    		b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    		b.SUnitOfMeasID=k.UnitOfMeasID(+) and
		    DTYPE=41 and    
    		a.ORDERNO = pOrderno 
	ORDER BY 
		a.DINVOICEID,btype,a.INVOICENO DESC;
elsif pQueryType=29 then
  open data_cursor for
 select A.STOCKID,a.STOCKTRANSNO,STOCKTRANSDATE AS TDATE,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
    '' AS OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
    j.SHADEGROUPNAME,B.Shade,YarnType,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,
    f.UnitOfMeas,B.DyedLotno,b.subconid,'' AS subconname,Quantity as CurrentStock,SQuantity as Sqty,0  as mainstock,0 as REMAINQTY,REQUISITIONNO as reqno,REQQUANTITY as reqqty
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier h,T_fabricType i,T_ShadeGroup j,T_UnitOfMeas k
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID(+) and 
    b.SHADEGROUPID=j.SHADEGROUPID and
    b.FABRICTYPEID=i.FABRICTYPEID(+) and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUnitOfMeasID=k.UnitOfMeasID(+) and
    a.KNTITRANSACTIONTYPEID=11 and
    B.ORDERNO = pOrderno 
ORDER BY btype,a.STOCKTRANSNO DESC;
elsif pQueryType=30 then
  open data_cursor for
 select A.STOCKID,a.STOCKTRANSNO,STOCKTRANSDATE AS TDATE,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
    '' AS OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
    j.SHADEGROUPNAME,B.Shade,YarnType,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,
    f.UnitOfMeas,B.DyedLotno,b.subconid,'' AS subconname,Quantity as CurrentStock,SQuantity as Sqty,0  as mainstock,0 as REMAINQTY,REQUISITIONNO as reqno,REQQUANTITY as reqqty
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier h,T_fabricType i,T_ShadeGroup j,T_UnitOfMeas k
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID(+) and 
    b.SHADEGROUPID=j.SHADEGROUPID and
    b.FABRICTYPEID=i.FABRICTYPEID(+) and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUnitOfMeasID=k.UnitOfMeasID(+) and
    a.KNTITRANSACTIONTYPEID=14 and
    B.ORDERNO = pOrderno 
ORDER BY btype,a.STOCKTRANSNO DESC;
elsif pQueryType=31 then
  open data_cursor for
 select A.STOCKID,a.STOCKTRANSNO,STOCKTRANSDATE AS TDATE,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
    '' AS OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
    j.SHADEGROUPNAME,B.Shade,YarnType,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,
    f.UnitOfMeas,B.DyedLotno,b.subconid,'' AS subconname,Quantity as CurrentStock,SQuantity as Sqty,0  as mainstock,0 as REMAINQTY,REQUISITIONNO as reqno,REQQUANTITY as reqqty
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier h,T_fabricType i,T_ShadeGroup j,T_UnitOfMeas k
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID(+) and 
    b.SHADEGROUPID=j.SHADEGROUPID and
    b.FABRICTYPEID=i.FABRICTYPEID(+) and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUnitOfMeasID=k.UnitOfMeasID(+) and
    a.KNTITRANSACTIONTYPEID=9 and
    B.ORDERNO = pOrderno 
ORDER BY btype,a.STOCKTRANSNO DESC;
elsif pQueryType=32 then
  open data_cursor for
 select A.STOCKID,a.STOCKTRANSNO,STOCKTRANSDATE AS TDATE,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
    '' AS OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
    j.SHADEGROUPNAME,B.Shade,YarnType,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,
    f.UnitOfMeas,B.DyedLotno,b.subconid,'' AS subconname,Quantity as CurrentStock,SQuantity as Sqty,0  as mainstock,0 as REMAINQTY,REQUISITIONNO as reqno,REQQUANTITY as reqqty
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier h,T_fabricType i,T_ShadeGroup j,T_UnitOfMeas k
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID(+) and 
    b.SHADEGROUPID=j.SHADEGROUPID and
    b.FABRICTYPEID=i.FABRICTYPEID(+) and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUnitOfMeasID=k.UnitOfMeasID(+) and
    a.KNTITRANSACTIONTYPEID=10 and
    B.ORDERNO = pOrderno 
ORDER BY btype,a.STOCKTRANSNO DESC;
elsif pQueryType=33 then
  open data_cursor for
 select A.STOCKID,a.STOCKTRANSNO,STOCKTRANSDATE AS TDATE,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
    '' AS OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
    j.SHADEGROUPNAME,B.Shade,YarnType,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,
    f.UnitOfMeas,B.DyedLotno,b.subconid,'' AS subconname,Quantity as CurrentStock,SQuantity as Sqty,0  as mainstock,0 as REMAINQTY,REQUISITIONNO as reqno,REQQUANTITY as reqqty
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier h,T_fabricType i,T_ShadeGroup j,T_UnitOfMeas k
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID(+) and 
    b.SHADEGROUPID=j.SHADEGROUPID and
    b.FABRICTYPEID=i.FABRICTYPEID(+) and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUnitOfMeasID=k.UnitOfMeasID(+) and
    a.KNTITRANSACTIONTYPEID=35 and
    B.ORDERNO = pOrderno 
ORDER BY btype,a.STOCKTRANSNO DESC;
end if;
End OrderWiseTransaction;
/

PROMPT CREATE OR REPLACE Procedure  284 :: GetBIllOrder
Create or Replace Procedure GetBIllOrder
(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER, 
  pClient  VARCHAR2,
  pBasictype varchar2
)
AS
BEGIN

   if pQueryType=1  Then
    open data_cursor for
     select a.ORDERNO,getfncWOBType(a.ORDERNO) as btype,a.BASICTYPEID,b.woitemsl
    from T_OrderItems b, T_Workorder a 
    where  a.ORDERNO=b.ORDERNO and CLIENTID=pClient and a.BASICTYPEID=pBasictype
      ORDER BY a.ORDERNO ;
 end if;
END GetBIllOrder;
/
PROMPT CREATE OR REPLACE Procedure  285 :: GetBillPaymentIDs
CREATE OR REPLACE PROCEDURE GetBillPaymentIDs(
  data_cursor IN OUT pReturnData.c_Records,  
  pbill IN NUMBER,
  pocode in varchar2
)
AS  
BEGIN
  OPEN data_cursor  FOR
  SELECT billno,billpayitemsl,orderno,billpmtdate,billwopmt,ordercode from T_BillPayment 
     where billno=pbill and ordercode=pocode order by BILLPAYITEMSL;         
END GetBillPaymentIDs;
/

PROMPT CREATE OR REPLACE Procedure  286 :: GetbillWOList
CREATE OR REPLACE PROCEDURE GetbillWOList(
  data_cursor IN OUT pReturnData.c_Records,  
  pBillno IN NUMBER,
  pOrdercode in varchar2
)
AS  
BEGIN
  OPEN data_cursor  FOR
  SELECT orderno,GetfncWOBType(orderno)as btype
  from T_BillItems where billno=pBillno and ordercode=pOrdercode group by orderno order by GetfncWOBType(orderno);         
END GetbillWOList;
/



PROMPT CREATE OR REPLACE Procedure  287 :: GetYarnRejectStock
CREATE OR REPLACE Procedure GetYarnRejectStock(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pKnitTranTypeID NUMBER,
  pStockDate DATE
)
AS
BEGIN
if pQueryType=1 then
    open data_cursor for
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,x.SUPPLIERNAME,b.YARNBATCHNO,
    b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
    j.SHADEGROUPNAME,'' AS Shade,YarnType,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,
    f.UnitOfMeas,'' AS DyedLotno,b.subconid,'' AS subconname,sum(Quantity*REJECT) CurrentStock,sum(SQuantity*REJECT) Cursqty,
	'Gray Yarn from Knitting Floor' as RejectFloor,b.yarnfor
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,T_WorkOrder w, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,T_fabricType i,T_ShadeGroup j,T_UnitOfMeas k,T_supplier x
    where a.StockID=b.StockID and
    b.SHADEGROUPID=j.SHADEGROUPID and
	b.supplierid=x.supplierid(+) and
	b.orderno=w.orderno and w.BASICTYPEID='FC' and
    b.FABRICTYPEID=i.FABRICTYPEID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and a.KNTITRANSACTIONTYPEID in (42,66) and
    b.YarnCountId=d.YarnCountId(+) and
    b.YarnTypeId= e.YarnTypeId(+) and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUnitOfMeasID=k.UnitOfMeasID(+) and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.SUPPLIERID,x.SUPPLIERNAME,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
	j.SHADEGROUPNAME,YarnType,b.PUnitOfMeasId,f.UnitOfMeas,b.YARNBATCHNO,b.subconid,k.unitofmeas,b.sunitofmeasid,b.yarnfor
    having sum(Quantity*REJECT)>0
    UNION
    select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,x.SUPPLIERNAME,b.YARNBATCHNO,
    b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
    j.SHADEGROUPNAME,'' AS Shade,YarnType,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,
    f.UnitOfMeas,'' AS DyedLotno,b.subconid,'' AS subconname,sum(Quantity*REJECT) CurrentStock,sum(SQuantity*REJECT) Cursqty,
	'Dyed yarn from Dyeing Floor' as RejectFloor,b.yarnfor
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,T_WorkOrder w, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,T_fabricType i,T_ShadeGroup j,T_UnitOfMeas k,T_supplier x
    where a.StockID=b.StockID and
    b.SHADEGROUPID=j.SHADEGROUPID and
	b.supplierid=x.supplierid(+) and
	b.orderno=w.orderno and w.BASICTYPEID='FC' and
    b.FABRICTYPEID=i.FABRICTYPEID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and a.KNTITRANSACTIONTYPEID in (43,66) and
    b.YarnCountId=d.YarnCountId(+) and
    b.YarnTypeId= e.YarnTypeId(+) and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUnitOfMeasID=k.UnitOfMeasID(+) and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.SUPPLIERID,x.SUPPLIERNAME,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
	j.SHADEGROUPNAME,YarnType,b.PUnitOfMeasId,f.UnitOfMeas,b.YARNBATCHNO,b.subconid,k.unitofmeas,b.sunitofmeasid,b.yarnfor
    having sum(Quantity*REJECT)>0 
	UNION
	select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,x.SUPPLIERNAME,b.YARNBATCHNO,
    b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
    j.SHADEGROUPNAME,'' AS Shade,YarnType,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,
    f.UnitOfMeas,'' AS DyedLotno,b.subconid,'' AS subconname,sum(Quantity*REJECT) CurrentStock,sum(SQuantity*REJECT) Cursqty,
	'Dyed Yarn from Knitting Floor' as RejectFloor,b.yarnfor
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,T_WorkOrder w, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,T_fabricType i,T_ShadeGroup j,T_UnitOfMeas k,T_supplier x
    where a.StockID=b.StockID and
    b.SHADEGROUPID=j.SHADEGROUPID and
	b.supplierid=x.supplierid(+) and
	b.orderno=w.orderno and w.BASICTYPEID='FC' and
    b.FABRICTYPEID=i.FABRICTYPEID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and a.KNTITRANSACTIONTYPEID in (44,66) and
    b.YarnCountId=d.YarnCountId(+) and
    b.YarnTypeId= e.YarnTypeId(+) and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUnitOfMeasID=k.UnitOfMeasID(+) and
    STOCKTRANSDATE <= pStockDate
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.SUPPLIERID,x.SUPPLIERNAME,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
	j.SHADEGROUPNAME,YarnType,b.PUnitOfMeasId,f.UnitOfMeas,b.YARNBATCHNO,b.subconid,k.unitofmeas,b.sunitofmeasid,b.yarnfor
    having sum(Quantity*REJECT)>0;
  end if;
END GetYarnRejectStock;
/



PROMPT CREATE OR REPLACE Procedure  288 :: GetWotoBQtycheck
Create or Replace Procedure GetWotoBQtycheck
(
 pPid in number,
 pBudgetid IN number,
 pFabricid IN varchar2,
 pShade in number,
 pRecsAffected out NUMBER
)
AS

orderqtysum number(12,2);
budgetqtysum number(12,2);
BEGIN
	/*Find total work order quantity fabrictype, shadegroup, budget wise*/
    select NVL(SUM(QUANTITY),0) INTO orderqtysum from T_ORDERITEMS 
	     WHERE BREFPID=pPid AND FABRICTYPEID=pFabricid AND SHADEGROUPID=pShade;		
	pRecsAffected:=orderqtysum;
EXCEPTION 
	WHEN NO_DATA_FOUND THEN pRecsAffected:=1111111;
END GetWotoBQtycheck;
/



PROMPT CREATE OR REPLACE Procedure  289 :: GetFormAccess
CREATE OR REPLACE Procedure GetFormAccess(
  pFormid IN varchar2, 
  pUserid in varchar2,  
  pRecsAffected out NUMBER
)
AS
  ok NUMBER;
BEGIN   
   SELECT count(*) into ok from T_Athurization where  Employeeid=pUserid and formid=pFormid;
   pRecsAffected := ok;
END GetFormAccess;
/


PROMPT CREATE OR REPLACE Procedure  290 :: GetStaBrandList
CREATE OR REPLACE Procedure GetStaBrandList
(
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN

    OPEN data_cursor for
    Select BRANDID,BRANDNAME  from T_Brand order by BRANDNAME;
END GetStaBrandList;
/

PROMPT CREATE OR REPLACE Procedure  291 :: GetStaDeptList
CREATE OR REPLACE Procedure GetStaDeptList
(
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN

    OPEN data_cursor for
    Select DEPTID,DEPTNAME  from T_DEPARTMENT order by DEPTNAME;
END GetStaDeptList;
/


PROMPT CREATE OR REPLACE Procedure  292 :: GetPartyInfo
CREATE OR REPLACE Procedure GetPartyInfo
(
  pStatus number,
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)

AS

BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=0 then
  OPEN data_cursor for
    select PARTYID,PARTYNAME,PADDRESS,PTELEPHONE,PFAX,PEMAIL,PURL,PCONTACTPERSON   from T_Party order by PARTYNAME;
/*If the Value is 1 then retun as the */

elsif pStatus=1 then
  OPEN data_cursor for
   select PARTYID,PARTYNAME,PADDRESS,PTELEPHONE,PFAX,PEMAIL,PURL,PCONTACTPERSON  from T_Party where
     PARTYID=pWhereValue order by PARTYNAME;
end if;
END GetPartyInfo;
/


PROMPT CREATE OR REPLACE Procedure  293:: GetAccLCItems
Create or Replace Procedure GetAccLCItems (
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,  
  pStockDate DATE
)
AS
BEGIN
open data_cursor for
select  PID,LCNO,GROUPID,ACCESSORIESID,QTY,UNITPRICE,VALUEFC,VALUETK,VALUEBANK,VALUEINSURANCE,
        VALUETRUCK,VALUECNF,VALUEOTHER,TOTCOST,UNITCOST      
from  T_AccImpLCItems
  where GROUPID=32
 order by GROUPID,ACCESSORIESID;
END GetAccLCItems;
/


PROMPT CREATE OR REPLACE Procedure  294 :: GETKNeedleImpLCInfo
CREATE OR REPLACE Procedure GETKNeedleImpLCInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  many_cursor IN OUT pReturnData.c_Records,
  pLCNumber IN NUMBER
)
AS
BEGIN
  open one_cursor for
  select LCNo, BankLCNo, OpeningDate, SupplierID, CurrencyId, ConRate, ExpLCNo,ShipmentDate,
  DocRecDate, DocRelDate, GoodsRecDate, ImpLCStatusId, BankCharge, Insurance,
  TruckFair, CNFValue, OtherCharge, Remarks, ShipDate, Cancelled,Lcmaturityperiod,ImpLctypeid
  from T_KNeedleImpLC
  where LCNo=pLCNumber;

  open many_cursor for
  select PID, GROUPID,PartId, Qty, UnitPrice, ValueFC, ValueTk, ValueBank,
  ValueInsurance, ValueTruck, ValueCNF, ValueOther, TotCost, UnitCost
  FROM T_KNeedleImpLCItems
  where LCNo=pLCNumber order by PID;
END GETKNeedleImpLCInfo;
/


PROMPT CREATE OR REPLACE Procedure  295 :: getTreeKNeedleImpLCList
CREATE OR REPLACE Procedure getTreeKNeedleImpLCList (
  io_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pLCNo IN NUMBER,
  sDate IN date,
  eDate IN date
)
AS
  vSDate date;
  vEDate date;
BEGIN
  vSDate := TO_DATE('01/01/1900', 'DD/MM/YYYY');
  vEDate := TO_DATE('01/01/2999', 'DD/MM/YYYY');
  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  end if;
  /* For all The Data*/
  if pQueryType=0 then
    OPEN io_cursor FOR
    select LCNo, BankLCNo from T_KNeedleImpLC
    where OPeningDate>=SDate and OPeningDate<=EDate 
 order by lcno desc ;

 /* For Supplier Name*/
  elsif pQueryType=1 then
    OPEN io_cursor FOR
    select b.SUPPLIERNAME, LCNo, BankLCNo 
    from T_KNeedleImpLC a, T_SUPPLIER b 
    where a.SupplierID=b.SupplierID and
          OPeningDate>=SDate and OPeningDate<=EDate
    order by a.SupplierID, BankLCNo desc;

 /* for Lc Status */
  elsif pQueryType=2 then
    OPEN io_cursor FOR
    select b.ImpLCStatus, LCNo, BankLCNo
    from T_KNeedleImpLC a, T_ImpLCStatus b
    where a.ImpLCStatusId=b.ImpLCStatusId and
    OPeningDate>=SDate and OPeningDate<=EDate
    order by a.ImpLCStatusId, BankLCNo desc;

 /*  For LC Type */
  elsif pQueryType=3 then
    OPEN io_cursor FOR
    select  b.impLctype, LCNo, BankLCNo
    from T_KNeedleImpLC a, T_ImpLCtype b
    where a.IMPLctypeid=b.impLctypeid and
    OPeningDate>=SDate and OPeningDate<=EDate
    order by a.ImpLctypeid, BankLCNo desc;
 /* */
  elsif pQueryType=9999 then
    OPEN io_cursor FOR
    select LCNo from T_KNeedleImpLC
    where  OPeningDate>=SDate and OPeningDate<=EDate and
    Upper(BankLCNo) Like pLCNo;
  end if;
END getTreeKNeedleImpLCList;
/

PROMPT CREATE OR REPLACE Procedure  296 :: GetKmcNeedleInfoLookUp
CREATE OR REPLACE Procedure GetKmcNeedleInfoLookUp
(
  pStatus number,
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)

AS

BEGIN
/*if the Value is 0 then retun all the Data */
if pStatus=0 then
  OPEN data_cursor for
   select PartID,PARTNAME
 from T_KMCPARTSINFO where MCPARTSTYPEID=1 order by PARTNAME;
end if; 
END GetKmcNeedleInfoLookUp;
/

PROMPT CREATE OR REPLACE Procedure  297 :: GetKmcPartsPickUp
CREATE OR REPLACE Procedure GetKmcPartsPickUp
(
  pStatus number,
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)

AS

BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=0 then
  OPEN data_cursor for
   select a.PartID,a.PARTNAME,a.Description,a.FOREIGNPART,a.MCPARTSTYPEID,
   c.MCPARTSTYPE,a.LOCATIONID,b.LOCATION,
   d.MCTYPENAME,a.MCTYPEID,a.SPARETYPEID,a.UNITOFMEASID,
   e.SPARETYPENAME,f.UNITOFMEAS,0 as unitprice
 from T_KMCPARTSINFO a,t_storeLocation b,t_mcpartstype c,t_kmctype d,t_sparetype e,t_unitofmeas f where 
 a.LOCATIONID=b.LOCATIONID and a.MCPARTSTYPEID=c.MCPARTSTYPEID and a.MCTYPEID=d.MCTYPEID and 
 a.SPARETYPEID=e.SPARETYPEID and a.UNITOFMEASID=f.UNITOFMEASID   
 order by a.PARTID,a.PARTNAME;

/*If the Value is 1 then retun as the */

elsif pStatus=1 then
  OPEN data_cursor for
   select a.PartID,a.PARTNAME,a.Description,a.FOREIGNPART,a.MCPARTSTYPEID,
   c.MCPARTSTYPE,a.LOCATIONID,b.LOCATION,
   d.MCTYPENAME,a.MCTYPEID,a.SPARETYPEID,a.UNITOFMEASID,
   e.SPARETYPENAME,f.UNITOFMEAS,0 as unitprice
 from T_KMCPARTSINFO a,t_storeLocation b,t_mcpartstype c,t_kmctype d,t_sparetype e,t_unitofmeas f where 
 a.LOCATIONID=b.LOCATIONID and a.MCPARTSTYPEID=c.MCPARTSTYPEID and a.MCTYPEID=d.MCTYPEID and 
 a.SPARETYPEID=e.SPARETYPEID and a.UNITOFMEASID=f.UNITOFMEASID   
and a.MCTYPEID=pWhereValue order by a.PARTID,a.PARTNAME;

/*for needle lc parts pickup*/
elsif pStatus=2 then
  OPEN data_cursor for
   select a.PartID,a.PARTNAME,a.Description,a.FOREIGNPART,a.MCPARTSTYPEID,
   c.MCPARTSTYPE,a.LOCATIONID,b.LOCATION,
   d.MCTYPENAME,a.MCTYPEID,a.SPARETYPEID,a.UNITOFMEASID,
   e.SPARETYPENAME,f.UNITOFMEAS,h.UNITPRICE as unitprice
 from T_KNeedleImpLCItems H,T_KMCPARTSINFO a,t_storeLocation b,t_mcpartstype c,t_kmctype d,t_sparetype e,t_unitofmeas f 
 where
  H.PARTID=A.PARTID AND
  a.LOCATIONID=b.LOCATIONID and a.MCPARTSTYPEID=c.MCPARTSTYPEID and a.MCTYPEID=d.MCTYPEID and 
 a.SPARETYPEID=e.SPARETYPEID and a.UNITOFMEASID=f.UNITOFMEASID 
 group by a.PartID,a.PARTNAME,a.Description,a.FOREIGNPART,a.MCPARTSTYPEID,
   c.MCPARTSTYPE,a.LOCATIONID,b.LOCATION,
   d.MCTYPENAME,a.MCTYPEID,a.SPARETYPEID,a.UNITOFMEASID,
   e.SPARETYPENAME,f.UNITOFMEAS,h.UNITPRICE
 order by a.PARTID,a.PARTNAME;

end if;
END GetKmcPartsPickUp;
/



PROMPT CREATE OR REPLACE Procedure  298 :: GETGMachinePartsPartStockInfo
CREATE OR REPLACE Procedure GETGMachinePartsPartStockInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  many_cursor IN OUT pReturnData.c_Records,
  pMcStockID number
)
AS
BEGIN
    open one_cursor for
    select a.StockId, a.StockDate, a.ChallanNo, a.ChallanDate, a.PURCHASEORDERNO, 	a.PURCHASEORDERDATE, CURRENCYID,CONRATE,SCOMPLETE,      
	a.TexMCSTOCKTYPEID,a.SUPPLIERID,a.DELIVERYNOTE
    from T_GMcStock a  where a.StockId=pMcStockID;

    open many_cursor for
    select a.STOCKID,c.partsstatus, a.STOCKITEMSL,a.PARTID,a.UNITPRICE,a.REMARKS,
 	a.PARTSSTATUSFROMID,a.PARTSSTATUSTOID,a.QTY,a.REQQTY,a.UNITOFMEASID,a.IssueFor,a.PID,a.CURRENTSTOCK,
 	a.TexMCSTOCKTYPEID,b.PARTNAME,b.DESCRIPTION,b.FOREIGNPART,a.DeptID
    from T_GMcStockItems a,T_GMcPartsInfo b,T_GMCPARTSSTATUS c
    where a.STOCKID=pMcStockID and
 	a.PARTID=b.PARTID and
    c.partsstatusid=a.PARTSSTATUSFROMID
    order by a.STOCKITEMSL asc;
END GETGMachinePartsPartStockInfo;
/


PROMPT CREATE OR REPLACE Procedure  299 :: getTreeGMachinePartsStockList
CREATE OR REPLACE Procedure getTreeGMachinePartsStockList (
  io_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pStockType IN NUMBER,
  sDate IN date,
  eDate IN date
)
AS
BEGIN

/* for Any Stock Particular StockType with challan No*/
  if pQueryType=0 then
    OPEN io_cursor FOR
    select StockId, ChallanNo, StockDate from T_GMcStock
    where TexMCSTOCKTYPEID=pStockType and
    StockDate>=SDate and StockDate<=EDate order by 
    ChallanNo desc;
	
/* for Any Stock Particular StockDate with challan No*/
  elsif pQueryType=1 then
    OPEN io_cursor FOR
    select StockId, ChallanNo, StockDate from T_GMcStock
    where TexMCSTOCKTYPEID=pStockType and
    StockDate>=SDate and StockDate<=EDate order by 
    StockDate desc;	

/* for Any Stock Particular SupplierName with challan No*/
	elsif pQueryType=2 then
    OPEN io_cursor FOR
    select StockId, ChallanNo,T_Supplier.SupplierName AS SupplierName from T_GMcStock,T_Supplier
    where T_GMcStock.SUPPLIERID=T_Supplier.SUPPLIERID AND 
	TexMCSTOCKTYPEID=pStockType and
    StockDate>=SDate and StockDate<=EDate order by 
    StockDate desc;	
	
/* for Any Stock Particular MachinePartsName with challan No*/	
  elsif pQueryType=3 then
    OPEN io_cursor FOR
    select b.PARTID, c.PARTNAME from T_GMcStock a,T_GMcStockItems b,T_GMcPartsInfo c
    where b.PARTID=c.PARTID and
	a.STOCKID=b.STOCKID and
	a.TexMCSTOCKTYPEID=pStockType and
    a.StockDate>=SDate and a.StockDate<=EDate 
	group by b.PARTID, c.PARTNAME
	order by c.PARTNAME;
	
  end if;
END getTreeGMachinePartsStockList;
/


PROMPT CREATE OR REPLACE Procedure  300 :: GetGMachinePartsPickUp
CREATE OR REPLACE Procedure GetGMachinePartsPickUp
(
  pStatus number,
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=0 then
  OPEN data_cursor for
   select a.PartID,a.PARTNAME,a.Description,a.FOREIGNPART,a.MachineType,a.UNITOFMEASID,f.UNITOFMEAS
   from T_GMcPartsInfo a,t_unitofmeas f 
   where a.UNITOFMEASID=f.UNITOFMEASID   
   order by a.MachineType,a.PARTNAME;

/*If the Value is 1 then retun as the */

elsif pStatus=1 then
  OPEN data_cursor for
   select a.PartID,a.PARTNAME,a.Description,a.FOREIGNPART,a.MachineType,a.UNITOFMEASID,f.UNITOFMEAS
   from T_GMcPartsInfo a,t_unitofmeas f 
   where a.UNITOFMEASID=f.UNITOFMEASID   
   order by a.MachineType,a.PARTNAME;
end if;
END GetGMachinePartsPickUp;
/


PROMPT CREATE OR REPLACE Procedure  301 :: GetGMCPartsStockReqInfo
CREATE OR REPLACE Procedure GetGMCPartsStockReqInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  many_cursor IN OUT pReturnData.c_Records,
  pMcStockID number
)
AS
BEGIN

    open one_cursor for
    	select a.StockId, a.StockDate, a.ChallanNo, a.ChallanDate, a.PURCHASEORDERNO, a.PURCHASEORDERDATE,
	a.TexMCSTOCKTYPEID,a.SUPPLIERNAME,a.SUPPLIERADDRESS,a.DELIVERYNOTE,a.EXECUTED
    	from T_GMcStockReq a  where a.StockId=pMcStockID;

    open many_cursor for
    	select a.STOCKID,c.partsstatus, a.STOCKITEMSL,a.PARTID,a.UNITPRICE,a.REMARKS,
 	a.PARTSSTATUSFROMID,a.PARTSSTATUSTOID,a.QTY,a.UNITOFMEASID,a.IssueFor,a.PID,a.CURRENTSTOCK,
 	a.TexMCSTOCKTYPEID,b.PARTNAME,b.DESCRIPTION,b.FOREIGNPART,a.DeptID
    	from T_GMcStockItemsReq a,T_GMcPartsInfo b,T_GMCPARTSSTATUS c
    	where a.STOCKID=pMcStockID and
 	a.PARTID=b.PARTID and
      	c.partsstatusid=a.PARTSSTATUSFROMID
    	order by a.STOCKITEMSL asc;
END GetGMCPartsStockReqInfo;
/


PROMPT CREATE OR REPLACE Procedure  302 :: getTreeGMcPartsStockReqList
CREATE OR REPLACE Procedure getTreeGMcPartsStockReqList (
  io_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pStockType IN NUMBER,
  sDate IN date,
  eDate IN date
)
AS
BEGIN

/* for Any Stock Particular StockType with challan No*/
  if pQueryType=0 then
    OPEN io_cursor FOR
    select StockId, ChallanNo, StockDate from T_GMcStockReq
    where TexMCSTOCKTYPEID=pStockType and
    StockDate>=SDate and StockDate<=EDate order by 
    ChallanNo desc;
	
/* for Any Stock Particular StockDate with challan No*/
  elsif pQueryType=1 then
    OPEN io_cursor FOR
    select StockId, ChallanNo, StockDate from T_GMcStockReq
    where TexMCSTOCKTYPEID=pStockType and
    StockDate>=SDate and StockDate<=EDate order by 
    StockDate desc;	
  end if;

END getTreeGMcPartsStockReqList;
/


PROMPT CREATE OR REPLACE Procedure  303 :: GetGMachineStockPickUp
CREATE OR REPLACE Procedure GetGMachineStockPickUp(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER
)
AS
BEGIN
if pQueryType=1 then
 open data_cursor for
    select b.PARTID,c.PARTNAME,a.PARTSSTATUS,c.FOREIGNPART,c.MACHINETYPE,c.DESCRIPTION,0 as UNITPRICE,
        b.PARTSSTATUSTOID AS PARTSSTATUSFROMID,c.UNITOFMEASID,e.UNITOFMEAS,b.DeptID,g.PROJNAME as DeptName,SUM(b.QTY * d.MSN) as Qty
        from T_GMCPARTSSTATUS a,T_GMcStockItems b,T_GMCPARTSINFO c,T_GMCSTOCKSTATUS d,t_UnitOfMeas e,T_PROJECT g
		where  b.PARTID=c.PARTID and
        b.PARTSSTATUSTOID=a.PARTSSTATUSID and b.DeptID=g.PROJCODE and
        B.TEXMCSTOCKTYPEID=d.TEXMCSTOCKTYPEID and b.PARTSSTATUSFROMID=d.PARTSSTATUSFROMID and
        b.PARTSSTATUSTOID=d.PARTSSTATUSTOID and c.UNITOFMEASID=e.UNITOFMEASID(+)
        group by  b.PARTID,c.PARTNAME,a.PARTSSTATUS,c.FOREIGNPART,c.MACHINETYPE,c.DESCRIPTION,
        b.PARTSSTATUSTOID,c.UNITOFMEASID,e.UNITOFMEAS,b.DeptID,g.PROJNAME
        having sum(b.Qty*d.MSN)>0
        order by partID;

  /* For Issue to floor from main store Pickup */
  elsif pQueryType=2 then
 open data_cursor for
   select CHALLANNO,b.PARTID,c.PARTNAME,a.PARTSSTATUS,c.FOREIGNPART,c.MACHINETYPE,c.DESCRIPTION,b.UNITPRICE,
       b.PARTSSTATUSTOID AS PARTSSTATUSFROMID,c.UNITOFMEASID,e.UNITOFMEAS,f.MCLISTID,f.MCLISTNAME,b.DeptID,h.PROJNAME as DeptName,
	   nvl((select SUM(x.QTY * y.MSN)
        from T_GMcStockItems x,T_GMCSTOCKSTATUS y
		where  x.PARTID=b.PARTID and
        x.TEXMCSTOCKTYPEID=y.TEXMCSTOCKTYPEID and 
		x.PARTSSTATUSFROMID=y.PARTSSTATUSFROMID
        group by  x.PARTID
        having sum(x.Qty*y.MSN)>0),0) as Qty,
	   nvl(SUM(-b.QTY * d.MSN),0) as ReqQty,
	   nvl((SUM(-b.QTY * d.MSN)- nvl((select sum(x.QTY) 
	   from t_gmcstockitems x 
	   where x.TEXMCSTOCKTYPEID=2 and 
	   x.reqno=g.CHALLANNO and x.PARTID=b.PARTID
	   group by  x.reqno,x.PARTID),0)),0) as RemQty
       from T_GMCPARTSSTATUS a,T_GMcStockItemsReq b,T_GMCPARTSINFO c,T_GMCSTOCKSTATUS d,
       t_UnitOfMeas e,T_GMcStockReq G,T_GMCLIST f,T_PROJECT h
       where  b.StockId=g.StockID and b.PARTID=c.PARTID and b.DeptID=h.PROJCODE and
       b.PARTSSTATUSTOID=a.PARTSSTATUSID and ISSUEFOR=f.MCLISTID and
       B.TEXMCSTOCKTYPEID=d.TEXMCSTOCKTYPEID and b.PARTSSTATUSFROMID=d.PARTSSTATUSFROMID and
       b.PARTSSTATUSTOID=d.PARTSSTATUSTOID and c.UNITOFMEASID=e.UNITOFMEASID(+) and Executed=0
       group by  CHALLANNO,b.PARTID,c.PARTNAME,a.PARTSSTATUS,c.FOREIGNPART,c.MACHINETYPE,c.DESCRIPTION,b.UNITPRICE,
       b.PARTSSTATUSTOID,c.UNITOFMEASID,e.UNITOFMEAS,f.MCLISTID,f.MCLISTNAME,b.DeptID,h.PROJNAME
       having nvl((SUM(-b.QTY * d.MSN)-
	   nvl((select sum(x.QTY) from t_gmcstockitems x where x.TEXMCSTOCKTYPEID=2 and 
	   x.reqno=g.CHALLANNO and x.PARTID=b.PARTID
	   group by  x.reqno,x.PARTID),0)),0)>0
       order by partID;

 /* For Floor Store for Return Pickup */
  elsif pQueryType=3 then
open data_cursor for
   select b.PARTID,c.PARTNAME,a.PARTSSTATUS,c.FOREIGNPART,c.MACHINETYPE,c.DESCRIPTION,b.UNITPRICE,
        b.PARTSSTATUSTOID AS PARTSSTATUSFROMID,c.UNITOFMEASID,e.UNITOFMEAS,f.MCLISTID,f.MCLISTNAME,b.DeptID,
		h.PROJNAME as DeptName,SUM(b.QTY * d.FSN) as Qty
        from T_GMCPARTSSTATUS a,T_GMcStockItems b,T_GMCPARTSINFO c,
		T_GMCSTOCKSTATUS d,t_UnitOfMeas e,T_GMCLIST f,T_PROJECT h
        where  b.PARTID=c.PARTID and b.DeptID=h.PROJCODE and
        b.PARTSSTATUSTOID=a.PARTSSTATUSID and ISSUEFOR=f.MCLISTID and
        B.TEXMCSTOCKTYPEID=d.TEXMCSTOCKTYPEID and b.PARTSSTATUSFROMID=d.PARTSSTATUSFROMID and
        b.PARTSSTATUSTOID=d.PARTSSTATUSTOID and c.UNITOFMEASID=e.UNITOFMEASID(+)
        group by  b.PARTID,c.PARTNAME,a.PARTSSTATUS,c.FOREIGNPART,c.MACHINETYPE,c.DESCRIPTION,b.UNITPRICE,
        b.PARTSSTATUSTOID,c.UNITOFMEASID,e.UNITOFMEAS,f.MCLISTID,f.MCLISTNAME,b.DeptID,h.PROJNAME
        having sum(b.Qty*d.FSN)>0
	order by partID;

  end if;
END GetGMachineStockPickUp;
/


PROMPT CREATE OR REPLACE Procedure  304 :: getTreeGMachinePartsInfoList
CREATE OR REPLACE Procedure getTreeGMachinePartsInfoList(
  io_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER
)
AS
BEGIN
 /* For Parts Name*/
  if pQueryType=0 then
    OPEN io_cursor FOR
    select a.PARTID,a.PARTNAME from  T_GMCPARTSINFO a
    order by PARTNAME desc;

 /* For Machine Type  */
  elsif pQueryType=1 then
    OPEN io_cursor FOR
        select a.PARTID,a.PARTNAME,a.MACHINETYPE,a.BINNO from
        T_GMCPARTSINFO a  order by MACHINETYPE desc;
 /* For Locaiton */
  elsif pQueryType=2 then
    OPEN io_cursor FOR
        select a.PARTID,a.PARTNAME,a.MACHINETYPE,a.BINNO from
        T_GMCPARTSINFO a order by BINNO desc;
  end if;
END getTreeGMachinePartsInfoList;
/

PROMPT CREATE OR REPLACE Procedure  305 :: GETGMachinePartsInfo
CREATE OR REPLACE Procedure GETGMachinePartsInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  many_cursor IN OUT pReturnData.c_Records,
  pPARTID number
)
AS
BEGIN
    open one_cursor for
    select PARTID,PARTNAME,DESCRIPTION,FOREIGNPART,MACHINETYPE,UNITOFMEASID,MACHINENO,BINNO,
    REORDERQTY,SUPPLIERADDRESS,ORDERLEADTIME,REMARKS,WAVGPRICE,PROJCODE,CCATACODE
    from T_GMCPARTSINFO  where PARTID=pPARTID;

    open many_cursor for
    select PID,PARTID, PURCHASEDATE, UNITPRICE, SUPPLIERNAME, QTY
    from T_GMcPartsPrice
    where PARTID=pPARTID;
END GETGMachinePartsInfo;
/


PROMPT CREATE OR REPLACE Procedure  306 :: GetAllGMachineList
CREATE OR REPLACE Procedure GetAllGMachineList
(
  pStatus number,
  pWhereValue number,
  data_cursor IN OUT pReturnData.c_Records
)

AS

BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=0 then
  	OPEN data_cursor for
   	select  MCLISTID,MCLISTNAME     
 	from T_GMCLIST order by MCLISTNAME;

/*If the Value is 1 then retun as the */

elsif pStatus=1 then
  	OPEN data_cursor for
	select MCLISTID,MCLISTNAME     
 	from T_GMCLIST where MCLISTID=pWhereValue order by MCLISTNAME;
end if;
END GetAllGMachineList;
/



PROMPT CREATE OR REPLACE Procedure  307 :: StationeryGroupInfo
CREATE OR REPLACE Procedure StationeryGroupInfo
(
  data_cursor IN OUT pReturnData.c_Records
)

AS

BEGIN
  OPEN data_cursor for
   Select GroupID,GroupName
	from T_StationeryGroup order by GroupID;
END StationeryGroupInfo;
/


PROMPT CREATE OR REPLACE Procedure  308 :: getTreeStationery
CREATE OR REPLACE Procedure getTreeStationery(
  io_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER
)
AS
BEGIN
 /* For Stage Name*/
  if pQueryType=0 then
    OPEN io_cursor FOR
    	select Stationeryid,Item,b.groupName from  T_Stationery a, T_StationeryGroup b
	where a.groupid=b.groupid
    order by b.groupName;
   end if;
END getTreeStationery;
/


PROMPT CREATE OR REPLACE Procedure  309 :: GetStationeryInfo
CREATE OR REPLACE Procedure GetStationeryInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  many_cursor IN OUT pReturnData.c_Records,
  pSTID number
)
AS
BEGIN
    open one_cursor for
    select STATIONERYID,ITEM,UNITOFMEASID,WAVGPRICE,GROUPID
    from T_STATIONERY
    where STATIONERYID=pSTID;
	
	open many_cursor for
    select a.PID,a.StationeryID,p.ITEM,b.SUPPLIERNAME,a.supplierid,a.currencyid, a.PurchaseDate,a.UnitPrice,a.Qty,c.Currencyname,a.conrate,
	decode(a.unitprice,0,0,round((a.unitprice/a.CONRATE),2)) as funitprice,a.unitprice
    from T_StationeryPrice a,T_supplier b,T_Currency c,T_Stationery p
    where a.StationeryID=p.StationeryID and
	a.StationeryID=pSTID and
	  a.currencyid=c.currencyid(+) and
	  a.supplierid=b.supplierid(+) 
	  ORDER BY a.PurchaseDate DESC;
END GetStationeryInfo;
/

PROMPT CREATE OR REPLACE Procedure  310:: StationeryLookup
CREATE OR REPLACE Procedure StationeryLookup
(
  one_cursor IN OUT pReturnData.c_Records 
)
AS
BEGIN

    open one_cursor for
    select STATIONERYID,ITEM,UNITOFMEASID,GROUPID        
    from T_STATIONERY;            
 
END StationeryLookup;
/


PROMPT CREATE OR REPLACE Procedure  311:: GetSgroupLookup
CREATE OR REPLACE Procedure GetSgroupLookup
(
  data_cursor IN OUT pReturnData.c_Records
)
AS

BEGIN

  OPEN data_cursor for
  select GROUPID,GROUPNAME from T_STATIONERYGROUP order by GROUPNAME;

END GetSgroupLookup;
/


PROMPT CREATE OR REPLACE Procedure  312:: ReqByLookup
CREATE OR REPLACE Procedure ReqByLookup
(
  data_cursor IN OUT pReturnData.c_Records
)
AS

BEGIN

  OPEN data_cursor for
  select pid,name from T_PurchaseReqBy order by Name;

END ReqByLookup;
/


PROMPT CREATE OR REPLACE Procedure  313:: GetDepartmentLookup
CREATE OR REPLACE Procedure GetDepartmentLookup
(
  data_cursor IN OUT pReturnData.c_Records
)
AS

BEGIN

  OPEN data_cursor for
  select DEPTID,DEPTNAME from T_DEPARTMENT order by DEPTNAME;

END GetDepartmentLookup;
/

PROMPT CREATE OR REPLACE Procedure  314:: BrandLookup
CREATE OR REPLACE Procedure BrandLookup
(
  data_cursor IN OUT pReturnData.c_Records
)
AS

BEGIN

  OPEN data_cursor for
  select Brandid,BrandNAME from T_Brand order by BrandNAME;

END BrandLookup;
/

PROMPT CREATE OR REPLACE Procedure  315:: getTreePurcharReq
CREATE OR REPLACE Procedure getTreePurcharReq (
  io_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,  
  sDate IN date,
  eDate IN date
)
AS
BEGIN

  if pQueryType=0 then
    OPEN io_cursor FOR
    select REQID, Reqno from T_PurchaseReq
    where REQDATE>=SDate and REQDATE<=EDate
    order by Reqno desc;

  elsif pQueryType=1 then
    OPEN io_cursor FOR
    select REQID, Reqno, REQDATE
	from 	T_PurchaseReq
    where 	REQDATE>=SDate and 
			REQDATE<=EDate
    order by REQDATE desc, Reqno desc; 
	
end if;

END getTreePurcharReq;
/
PROMPT CREATE OR REPLACE Procedure  316:: GetpurchageReqinfo
CREATE OR REPLACE Procedure GetpurchageReqinfo
(
 one_cursor IN OUT pReturnData.c_Records,
 many_cursor IN OUT pReturnData.c_Records,
 preqid Number
)
AS
BEGIN
	open one_cursor for
	SELECT REQID,REQNO,REQDATE ,DEPTID,REQUIRMENTDATE,REMARKS,Reqby
	from T_PurchaseReq
	where Reqid=preqid ;

	open many_cursor for
	select PID,REQTYPEID,REQID,ITEMID,QUANTITY,PUNITOFMEASID,SQUANTITY,SUNITOFMEASID,REMARKS,
	CURRENTSTOCK,UNITPRICE,GROUPID,SLNO,BRANDID,COUNTRYID
	from  T_PurchaseReqItems
	where  Reqid=preqid 
	order by PID asc;
END GetpurchageReqinfo;
/

PROMPT CREATE OR REPLACE Procedure  317:: GetStationeryStockInfo
Create or Replace Procedure GetStationeryStockInfo
(
 one_cursor IN OUT pReturnData.c_Records,
 many_cursor IN OUT pReturnData.c_Records,
 pStokid Number
)
AS
BEGIN
 open one_cursor for
   SELECT STOCKID,STOCKTRANSNO,STOCKTRANSDATE,SUPPLIERID,SUPPLIERINVOICENO,SUPPLIERINVOICEDATE,REMARKS,stocktype,CURRENCYID,CONRATE
   from t_stationerystock
   where Stockid=pStokid;

 open many_cursor for
   select PID,TRANSTYPEID,STOCKID,STATIONERYID,QUANTITY,PUNITOFMEASID,SQUANTITY,SUNITOFMEASID,
   REMARKS,CURRENTSTOCK,UNITPRICE,GROUPID ,BRANDID,COUNTRYID,DEPTID,REQNO
   from  t_stationerystockItems
   where Stockid=pStokid;

END GetStationeryStockInfo;
/

PROMPT CREATE OR REPLACE Procedure  318:: getTreeStationerystock
Create or Replace Procedure getTreeStationerystock (
  io_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pStocktype in Number,
  sDate IN date,
  eDate IN date
)
AS
BEGIN
  if pQueryType=0 then
    OPEN io_cursor FOR
    select Stockid,STOCKTRANSNO from t_stationerystock
    where STOCKTRANSDATE >=SDate and STOCKTRANSDATE <=EDate and stocktype=pStocktype
    order by STOCKTRANSNO desc;

  elsif pQueryType=1 then
    OPEN io_cursor FOR
    select Stockid,STOCKTRANSNO,STOCKTRANSDATE
    from t_stationerystock
    where  STOCKTRANSDATE >=SDate and
    STOCKTRANSDATE <=EDate and stocktype=pStocktype
    order by STOCKTRANSDATE desc, STOCKTRANSNO desc;
	
 elsif pQueryType=2 then
    OPEN io_cursor FOR
    select a.Stockid,a.STOCKTRANSNO,b.SupplierName
    from  t_stationerystock a, T_Supplier b
    where  STOCKTRANSDATE >=SDate and
	a.supplierid=b.supplierid and 
    STOCKTRANSDATE <=EDate and stocktype=pStocktype
    order by STOCKTRANSDATE desc, STOCKTRANSNO desc;
	
  elsif pQueryType=3 then
    OPEN io_cursor FOR
    select b.STATIONERYID,c.ITEM
    from t_stationerystock a,t_stationerystockItems b,T_STATIONERY c
    where a.STOCKID=b.STOCKID and 
	b.STATIONERYID=c.STATIONERYID and
	a.STOCKTRANSDATE >=SDate and a.STOCKTRANSDATE <=EDate and
	/* a.STOCKTRANSDATE between SDate and EDate AND */
	a.stocktype=pStocktype
	group by b.STATIONERYID,c.ITEM
    order by c.ITEM;
end if;
END getTreeStationerystock ;
/


PROMPT CREATE OR REPLACE Procedure  319:: PurchageReqinfoPickup
Create or Replace Procedure PurchageReqinfoPickup
(
 one_cursor IN OUT pReturnData.c_Records,
 pQuerytype in Number
)
AS
BEGIN
if(pQuerytype=1) then
 open one_cursor for  
 select PID,REQTYPEID,a.REQID,a.ITEMID,a.QUANTITY,a.PUNITOFMEASID,a.SQUANTITY,a.SUNITOFMEASID,a.REMARKS,        
a.CURRENTSTOCK,a.UNITPRICE,a.GROUPID,a.SLNO,a.BRANDID,a.COUNTRYID,b.REQNO,b.DEPTID,b.reqby,d.DEPTNAME ,e.countryname,
f.brandname,g.groupname ,h.ITEM,C.unitofmeas        
 from  T_PurchaseReqItems a,
	T_PurchaseReq b,
	t_unitofmeas c,
	t_department d,
	t_country e,
	t_brand f,
	t_Stationerygroup g,
	t_stationery h
 where  a.Reqid=b.reqid and 
	a.PUNITOFMEASID=c.unitofmeasid(+) and
	b.deptid=d.deptid(+) and
	a.brandid=f.brandid(+) and
	a.groupid=g.groupid(+) and
	a.countryid=e.countryid(+) and
	a.itemid=h.stationeryid 
	ORDER BY b.REQNO;
	
elsif (pQuerytype=2) then
	open one_cursor for  
 select a.STATIONERYID,a.PUNITOFMEASID,    
a.GROUPID,a.BRANDID,a.COUNTRYID,a.reqby,e.countryname,
f.brandname,g.groupname,h.ITEM,C.unitofmeas, sum(a.QUANTITY*MainStore) as CurrentStock        
 from  T_StationeryStockItems a,
	T_Stationerystock b,
	t_unitofmeas c,	
	t_country e,
	t_brand f,
	t_Stationerygroup g,
	t_stationery h,
	T_StationeryTransactionType	i
 where  a.stockid=b.stockid and 
	a.PUNITOFMEASID=c.unitofmeasid(+) and	
	a.brandid=f.brandid(+) and
	a.groupid=g.groupid(+) and
	a.countryid=e.countryid(+) and
	a.STATIONERYID=h.stationeryid and
	a.TRANSTYPEID=i.TransTypeID
	group  by a.STATIONERYID,a.PUNITOFMEASID,    
a.GROUPID,a.BRANDID,a.COUNTRYID,a.reqby,e.countryname,
f.brandname,g.groupname ,h.ITEM,C.unitofmeas
having sum(a.QUANTITY*MainStore)>0;

elsif (pQuerytype=3) then
	open one_cursor for  
 select a.STATIONERYID,a.PUNITOFMEASID,    
a.GROUPID,a.BRANDID,a.COUNTRYID,a.DEPTID,d.DEPTNAME ,e.countryname,
f.brandname,g.groupname ,h.ITEM,C.unitofmeas, sum(a.QUANTITY*SubStore) as CurrentStock        
 from  T_StationeryStockItems a,
	T_Stationerystock b,
	t_unitofmeas c,
	t_department d,
	t_country e,
	t_brand f,
	t_Stationerygroup g,
	t_stationery h,
	T_StationeryTransactionType	i
 where  a.stockid=b.stockid and 
	a.PUNITOFMEASID=c.unitofmeasid and
	a.deptid=d.deptid and
	a.brandid=f.brandid and
	a.groupid=g.groupid and
	a.countryid=e.countryid and
	a.STATIONERYID=h.stationeryid and
	a.TRANSTYPEID=i.TransTypeID
	group  by a.STATIONERYID,a.PUNITOFMEASID,    
a.GROUPID,a.BRANDID,a.COUNTRYID,a.DEPTID,d.DEPTNAME ,e.countryname,
f.brandname,g.groupname ,h.ITEM,C.unitofmeas
having sum(a.QUANTITY*SubStore)>0;
end if;	
END PurchageReqinfoPickup;
/



PROMPT CREATE OR REPLACE Procedure  320 :: GetFmarkupInsertUpdate
Create or Replace Procedure GetFmarkupInsertUpdate
(
 pPID in number,
 pBUDGETID IN NUMBER,
 pSTAGEID IN NUMBER,
 pParameterid IN NUMBER,
 pQUANTITY in number,
 pUNITPRICE in number


)
AS
	ID NUMBER;
	tfabric number;
	tyarn number;
	tkd number;
	tfcharge number;
	total number;
	net number;
	unitp number;
	netunitp number;
BEGIN
	SELECT Seq_KDFPID.NEXTVAL INTO ID FROM DUAL;
	select sum(TOTALCONSUMPTION) into tfabric from t_fabricconsumption where budgetid=pBUDGETID and stageid=1;
	select round(sum(totalcost)) into tyarn from t_Yarncost where budgetid=pBUDGETID and stageid=2;
	select sum(TOTALCOST) into tkd from t_kdfcost where budgetid=pBUDGETID and stageid in(3,4);
	select sum(totalcost) into tfcharge from t_kdfcost where budgetid=pBUDGETID and stageid=5;
	total:= tfabric+tyarn+tkd+tfcharge;
	unitp:=total/tfabric;
	net:=total*(pQUANTITY/100);
	netunitp:=unitp*(pQUANTITY/100);
	if pPID=pParameterid+1 then
		INSERT INTO T_KDFCOST(PID,BUDGETID,STAGEID,PARAMID,QUANTITY,UNITPRICE,TOTALCOST)
			VALUES(ID,pBUDGETID,pSTAGEID,pParameterid ,pQUANTITY,netunitp,net);
	else
		UPDATE T_KDFCOST SET QUANTITY=pQUANTITY,UNITPRICE=netunitp,TOTALCOST=net
			WHERE STAGEID=pSTAGEID AND BUDGETID=pBUDGETID AND PID=pPID;
 end if;
END GetFmarkupInsertUpdate;
/

PROMPT CREATE OR REPLACE Procedure  321 :: GetKDFItemsInfo
create or replace Procedure GetKDFItemsInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  pBUDGETID number,
  pSTAGEID number,
  pPPid number
)
AS
	id  number;
BEGIN
	select count(PPID) into id from t_kdfcost where STAGEID=4 AND BUDGETID=pBUDGETID;
	if(id=0) then
		if(pSTAGEID=3) then
			open one_cursor for
			SELECT PID,STAGEID,BUDGETID,PARAMID,QUANTITY,UNITPRICE,TOTALCOST,PPID,UNIT FROM T_KDFCOST
				WHERE STAGEID=pSTAGEID AND BUDGETID=pBUDGETID and ppid=pPPid
			union
			select PARAMID+1 as pid,STAGEID,pBUDGETID as BUDGETID,PARAMID,
				0 as QUANTITY , 0 AS UNITPRICE,0 AS TOTALCOST,pPPid as PPID,'' AS UNIT
				FROM t_BUDGETSTAGEPARAMETER
				WHERE PARAMID NOT IN(SELECT PARAMID FROM T_KDFCOST WHERE STAGEID=pSTAGEID AND BUDGETID=pBUDGETID)
				and stageid=pSTAGEID ORDER BY PARAMID ;
		else
			open one_cursor for
			SELECT PID,STAGEID,BUDGETID,PARAMID,QUANTITY,UNITPRICE,TOTALCOST,PPID,UNIT FROM T_KDFCOST
				WHERE STAGEID=pSTAGEID AND BUDGETID=pBUDGETID
			union
			select PARAMID+1 as pid,STAGEID,pBUDGETID as BUDGETID,PARAMID,
				0 as QUANTITY , 0 AS UNITPRICE,0 AS TOTALCOST,pPPid as PPID,'' AS UNIT
				FROM t_BUDGETSTAGEPARAMETER
				WHERE PARAMID NOT IN(SELECT PARAMID FROM T_KDFCOST WHERE STAGEID=pSTAGEID AND BUDGETID=pBUDGETID)
				and stageid=pSTAGEID ORDER BY PARAMID ;
		end if;
	else
		open one_cursor for
		SELECT PID,STAGEID,BUDGETID,PARAMID,QUANTITY,UNITPRICE,TOTALCOST,PPID,UNIT FROM T_KDFCOST
			WHERE STAGEID=pSTAGEID AND BUDGETID=pBUDGETID and ppid=pPPid
		union
		select PARAMID+1 as pid,STAGEID,pBUDGETID as BUDGETID,PARAMID,
			0 as QUANTITY , 0 AS UNITPRICE,0 AS TOTALCOST,pPPid as PPID,'' AS UNIT
			FROM t_BUDGETSTAGEPARAMETER
			WHERE PARAMID NOT IN(SELECT PARAMID FROM T_KDFCOST WHERE STAGEID=pSTAGEID AND BUDGETID=pBUDGETID and ppid=pPPid)
			and stageid=pSTAGEID ORDER BY PARAMID ;
	end if;
END GetKDFItemsInfo;
/


PROMPT CREATE OR REPLACE Procedure  322 :: GetKDGItemsInfo
create or replace Procedure GetKDGItemsInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  pBUDGETID number,
  pSTAGEID number
)
AS
BEGIN
    open one_cursor for
	SELECT PID,STAGEID,BUDGETID,PARAMID,QUANTITY,UNITPRICE,TOTALCOST FROM T_KDFCOST
		WHERE STAGEID=pSTAGEID AND BUDGETID=pBUDGETID 
	union
	select PARAMID+1 as pid,STAGEID,pBUDGETID as BUDGETID,PARAMID,
		0 as QUANTITY , 0 AS UNITPRICE,0 AS TOTALCOST
		FROM t_BUDGETSTAGEPARAMETER
        WHERE PARAMID NOT IN(SELECT PARAMID FROM T_KDFCOST WHERE STAGEID=pSTAGEID AND BUDGETID=pBUDGETID)
        and stageid=pSTAGEID ORDER BY PARAMID ;
END GetKDGItemsInfo;
/

PROMPT CREATE OR REPLACE Procedure  323 :: GetFMItemsInfo
Create or Replace Procedure GetFMItemsInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  pBUDGETID number,
  pSTAGEID number

)
AS
BEGIN
    open one_cursor for
 SELECT PID,STAGEID,BUDGETID,PARAMID,QUANTITY,UNITPRICE,TOTALCOST FROM T_KDFCOST
 WHERE STAGEID=pSTAGEID AND BUDGETID=pBUDGETID
 union
 select PARAMID+1 as pid,STAGEID,pBUDGETID as BUDGETID,PARAMID,
 0 AS QUANTITY,
 0 AS UNITPRICE,0 AS TOTALCOST
       FROM t_BUDGETSTAGEPARAMETER
        WHERE PARAMID NOT IN(SELECT PARAMID FROM T_KDFCOST WHERE STAGEID=pSTAGEID AND BUDGETID=pBUDGETID)
        and stageid=pSTAGEID;
END GetFMItemsInfo;
/


PROMPT CREATE OR REPLACE Procedure  324 :: GetGarmentsItemsInfo11
Create or Replace Procedure GetGarmentsItemsInfo11
(
  one_cursor IN OUT pReturnData.c_Records,
  pBUDGETID number,
  pSTAGEID number

)
AS
BEGIN
    open one_cursor for
	SELECT PID,BUDGETID,STAGEID,PARAMID,SUPPLIERID,CONSUMPTIONPERDOZ,QUNATITY,UNITPRICE,TOTALCOST,SUBCONID
		FROM t_garmentscost WHERE  BUDGETID=pBUDGETID AND STAGEID=9
	union
	SELECT PARAMID+1 as PID,pBUDGETID AS BUDGETID,STAGEID,PARAMID,0 AS SUPPLIERID,(select round(quantity/12) from t_budget WHERE BUDGETID=pBUDGETID) AS CONSUMPTIONPERDOZ,0 AS QUNATITY,0 AS UNITPRICE,0 AS TOTALCOST,0 as SUBCONID
		FROM T_BUDGETSTAGEPARAMETER
		WHERE PARAMID NOT IN(SELECT PARAMID FROM t_garmentscost WHERE  BUDGETID=pBUDGETID AND STAGEID=9) and stageid=9 order by PARAMID;
END GetGarmentsItemsInfo11;
/

PROMPT CREATE OR REPLACE Procedure  325 :: BUDGETUPDATE
create or replace Procedure BUDGETUPDATE
(
 pBUDGETID IN NUMBER

)
AS
	ftotal number;
	mqty  number;
	tyc number;
	tfcost number;
	netfcost number;
	funitp number;
	kdfcost number;
	tgcost number;
	id number;
	tgsqty number;
	nettgsqty number;
	fscost number;
	netfscost number;
	pc number;
	tc Number;
	yqty number;
	ynqty number;
	id1 number;
	lcvalue Number(15,4);
BEGIN
	select count(*) into id from t_budget where budgetid=pBUDGETID;
	if(id!=0) then
		select QUANTITY into mqty from t_budget where budgetid=pBUDGETID;
		select Nvl(lcvalue,0) into lcvalue from t_budget where budgetid=pBUDGETID;
	for rec in(select budgetid,pid,CONSUMPTIONPERDOZ,WASTAGE,NETCONSUMPTIONPERDOZ,TOTALCONSUMPTION,
		STAGEID,RPERCENT,PCS from t_fabricconsumption where budgetid=pBUDGETID)
	loop
		pc:=((rec.rpercent*mqty)/100)/12;
		tc:=round((rec.NETCONSUMPTIONPERDOZ*pc),2);
		UPDATE t_fabricconsumption SET pcs=pc,
			TOTALCONSUMPTION=(rec.NETCONSUMPTIONPERDOZ*pc) where pid=rec.pid;
		for rec1 in(select pid,YARNTYPEID,YARNCOUNTID,SUPPLIERID,QUANTITY,UNITPRICE,TOTALCOST,
			STAGEID,USES,QTY,PROCESSLOSS,FABRICTYPEID from t_yarncost where budgetid=pBUDGETID and ppid=rec.pid)
		loop
			yqty:=(rec1.uses*tc)/100;
			ynqty:=(yqty+(yqty*rec1.processloss)/100);
			update t_yarncost set qty=yqty,quantity=ynqty,totalcost=ynqty*rec1.unitprice where pid=rec1.pid;
		end loop;
	end loop;
	select (sum(TOTALCONSUMPTION)) into ftotal from t_fabricconsumption where budgetid=pBUDGETID;
	if ftotal=0 then
		ftotal:=Null;
	else 
		ftotal:=ftotal;
	end if;
	select nvl((sum(TOTALCOST)),0) into tyc from t_Yarncost where budgetid=pBUDGETID;
	select nvl((sum(totalcost)),0) into kdfcost from t_kdfcost where budgetid=pBUDGETID and stageid in(3,4,5);
	netfcost:=tyc+kdfcost;
	funitp:=netfcost/ftotal;
	update t_kdfcost set UNITPRICE=(funitp*(QUANTITY/100)),TOTALCOST=(netfcost*(QUANTITY/100)) where budgetid=pBUDGETID and stageid=6;
	select nvl((sum(totalcost)),0) into tgcost from t_garmentscost where budgetid=pBUDGETID and stageid in(7,8,9,11);
	update t_garmentscost set CONSUMPTIONPERDOZ=mqty/12,TOTALCOST=mqty/12*UNITPRICE where budgetid=pBUDGETID and stageid=9;
	update t_garmentscost set TOTALCOST=(tgcost*QUNATITY)/100 where budgetid=pBUDGETID and stageid=10;
	select nvl((sum(totalcost)),0) into fscost from t_kdfcost where budgetid=pBUDGETID and stageid in(3,4,5);
	netfscost:=tyc+fscost;
	select nvl((sum(totalcost)),0) into tgsqty from t_garmentscost where budgetid=pBUDGETID and stageid in(7,8,9);
	nettgsqty:=netfscost+tgsqty;
	for rec2 in(select pid,qty from t_garmentscost where budgetid=pBUDGETID and stageid=11 and PARAMID not in(26,27,28,31))
	loop
		update t_garmentscost set TOTALCOST=(lcvalue*rec2.QTY)/100 where pid=rec2.pid;
	end loop;
	end if;
END BUDGETUPDATE;
/

PROMPT CREATE OR REPLACE Procedure  326 :: GetBYarncostInfo
CREATE OR REPLACE Procedure GetBYarncostInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  pBudgetID number,
  pPPid number
)
AS
BEGIN
open one_cursor for
 SELECT a.BUDGETID,a.PID,a.stageid,a.YARNTYPEID,a.USES,a.QTY,a.PROCESSLOSS,a.fabrictypeid,
a.yarncountid,a.SUPPLIERID,a.QUANTITY,a.UNITPRICE,a.TOTALCOST,a.ppid
        FROM t_yarncost a
        WHERE a.budgetid=pBudgetID and a.PPid=pPPid
        order by a.PID ;
END GetBYarncostInfo;
/

PROMPT CREATE OR REPLACE Procedure  327 :: getByarntotal
create or replace Procedure getByarntotal
(
	data_cursor IN OUT pReturnData.c_Records,
	pWhereValue number
)
AS
BEGIN
	OPEN data_cursor for
	select a.budgetid,a.yarncountid,a.yarntypeid,b.yarncount,c.yarntype,sum(quantity) as netqty,sum(totalcost) as reqty
		from t_yarncost a,t_yarncount b,t_yarntype c
		where a.yarncountid=b.yarncountid and
			a.yarntypeid=c.yarntypeid and
			budgetid=pWhereValue
		group by  a.yarncountid,a.yarntypeid,b.yarncount,c.yarntype,a.budgetid;
END getByarntotal;
/
PROMPT CREATE OR REPLACE Procedure  328 :: BudgetRevision
Create or replace Procedure BudgetRevision
(
	pBUDGETID IN NUMBER,
	pOrdertypeid in Varchar2,
	pRecsAffected out NUMBER
)
AS
	ID NUMBER;
	ID1 Number;
	ID2 Number;
	bno Varchar2(50);
	npid number;
	wno number;
	rno number;
	rvnocheck number;
BEGIN
	select max(budgetid)+1 into id from t_budget;
	select budgetno into bno from t_budget where budgetid=pBUDGETID;
	select Nvl(max(revision),0)+1 into rno from t_budget where budgetno=bno and ordertypeid=pOrdertypeid;
	select revision into rvnocheck from t_budget where budgetid=pBUDGETID;
	if(rvnocheck!=65) then
		pRecsAffected:=99;
	else
		pRecsAffected:=100;
	insert into t_budget(BUDGETID,BUDGETNO,CLIENTID,ORDERNO,ORDERREF,
		ORDERDESC,LCNO,LCRECEIVEDATE,LCEXPIRYDATE,
		SHIPMENTDATE,LCVALUE,QUANTITY,UNITPRICE,BUDGETPREDATE,Revision,ordertypeid,pi,cadrefno,EMPLOYEEID,COMPLETE,POSTDATE)
		select id,BUDGETNO,CLIENTID,ORDERNO,ORDERREF,
		ORDERDESC,LCNO,LCRECEIVEDATE,LCEXPIRYDATE,
		SHIPMENTDATE,LCVALUE,QUANTITY,UNITPRICE,BUDGETPREDATE,rno,ordertypeid,pi,cadrefno,EMPLOYEEID,1,POSTDATE from t_budget where budgetid=pBUDGETID;
	for rec in(select budgetid,pid,YARNTYPEID,FABRICTYPEID,GSM,CONSUMPTIONPERDOZ,
		WASTAGE,NETCONSUMPTIONPERDOZ,TOTALCONSUMPTION,STAGEID,rpercent,pcs,styleno,SHADEGROUPID from t_fabricconsumption where budgetid=pBUDGETID order by pid)
	loop
		select max(pid)+1 into npid from t_fabricconsumption;
		insert into t_fabricconsumption(BUDGETID,PID,YARNTYPEID,FABRICTYPEID,GSM,CONSUMPTIONPERDOZ,
		WASTAGE,NETCONSUMPTIONPERDOZ,TOTALCONSUMPTION,STAGEID,rpercent,pcs,styleno,SHADEGROUPID)
		values(id,npid,rec.YARNTYPEID,rec.FABRICTYPEID,rec.GSM,rec.CONSUMPTIONPERDOZ,
		rec.WASTAGE,rec.NETCONSUMPTIONPERDOZ,rec.TOTALCONSUMPTION,rec.STAGEID,rec.rpercent,rec.pcs,rec.styleno,rec.SHADEGROUPID);
		for rec1 in(select YARNTYPEID,YARNCOUNTID,SUPPLIERID,QUANTITY,UNITPRICE,TOTALCOST,
			STAGEID,USES,QTY,PROCESSLOSS,FABRICTYPEID from t_yarncost where budgetid=pBUDGETID and ppid=rec.pid order by pid)
		loop
			insert into t_yarncost(BUDGETID,PID,YARNTYPEID,YARNCOUNTID,SUPPLIERID,QUANTITY,
				UNITPRICE,TOTALCOST,STAGEID,USES,QTY,PROCESSLOSS,FABRICTYPEID,PPid)
				values(id,(select max(pid)+1 from t_Yarncost),rec1.YARNTYPEID,rec1.YARNCOUNTID,rec1.SUPPLIERID,rec1.QUANTITY,rec1.UNITPRICE,
				rec1.TOTALCOST,rec1.STAGEID,rec1.USES,rec1.QTY,rec1.PROCESSLOSS,rec1.FABRICTYPEID,npid);
		end loop;	
	for rec2 in(select STAGEID,PARAMID,QUANTITY,UNITPRICE,TOTALCOST,UNIT from t_kdfcost where budgetid=pBUDGETID and ppid=rec.pid and stageid IN(3,4) order by pid)
	loop
		SELECT Seq_kdfPID.NEXTVAL INTO ID1 FROM DUAL;
		insert into t_kdfcost( BUDGETID,PID,STAGEID,PARAMID,QUANTITY,UNITPRICE,TOTALCOST,PPID,UNIT)
			values(id,id1,rec2.STAGEID,rec2.PARAMID,rec2.QUANTITY,rec2.UNITPRICE,rec2.TOTALCOST,npid,rec2.unit);
		end loop;
	end loop;
	for rec in(select STAGEID,PARAMID,QUANTITY,UNITPRICE,TOTALCOST from t_kdfcost where budgetid=pBUDGETID and stageid =5 order by pid)
	loop
		SELECT Seq_kdfPID.NEXTVAL INTO ID1 FROM DUAL;
		insert into t_kdfcost( BUDGETID,PID,STAGEID,PARAMID,QUANTITY,UNITPRICE,TOTALCOST)
		values(id,id1,rec.STAGEID,rec.PARAMID,rec.QUANTITY,rec.UNITPRICE,rec.TOTALCOST);
	end loop;
	for rec in(select STAGEID,PARAMID,SUPPLIERID,CONSUMPTIONPERDOZ,QUNATITY,UNITPRICE,
		TOTALCOST,ACCESSORIESID,GROUPID,UNITOFMEASID,QTY,WASTAGE,
		CONSUMPTION,SUBCONID from t_garmentscost where budgetid=pBUDGETID)
	loop
		SELECT Seq_accesoriesPID.NEXTVAL INTO ID2 FROM DUAL;
		insert into t_garmentscost(BUDGETID,PID,STAGEID,PARAMID,SUPPLIERID,CONSUMPTIONPERDOZ,
			QUNATITY,UNITPRICE,TOTALCOST,ACCESSORIESID,GROUPID,UNITOFMEASID,QTY,WASTAGE,
			CONSUMPTION,SUBCONID)
			values(id,id2,rec.STAGEID,rec.PARAMID,rec.SUPPLIERID,rec.CONSUMPTIONPERDOZ,
			rec.QUNATITY,rec.UNITPRICE,rec.TOTALCOST,rec.ACCESSORIESID,rec.GROUPID,
			rec.UNITOFMEASID,rec.QTY,rec.WASTAGE,
			rec.CONSUMPTION,rec.SUBCONID);
	end loop;
	End IF;
END BudgetRevision;
/


PROMPT CREATE OR REPLACE Procedure  330:: Budgetcomplete
Create or Replace Procedure Budgetcomplete
(
 pBUDGETID IN NUMBER,
 pRecsAffected out NUMBER
)
AS
dt varchar2(50);
BEGIN
select to_char(localtimestamp(0),'dd/mm/yyyy hh.mi.ss am') into  dt from dual;
pRecsAffected:=100;
update t_budget set complete=1,postdate=dt where budgetid=pBUDGETID;
END Budgetcomplete;
/

PROMPT CREATE OR REPLACE Procedure  331:: GetGAccessoriesInfo
create or replace Procedure GetGAccessoriesInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  pBUDGETID number,
  pSTAGEID number
)
AS
BEGIN
    open one_cursor for
	SELECT PID,BUDGETID,STAGEID,PARAMID,SUPPLIERID,Unitofmeasid,CONSUMPTIONPERDOZ,QUNATITY,
		QTY,UNITPRICE,Accessoriesid,Groupid,TOTALCOST,CONSUMPTION,wastage
		FROM t_garmentscost WHERE  BUDGETID=pBUDGETID AND STAGEID=pSTAGEID order by Accessoriesid;
END GetGAccessoriesInfo;
/

PROMPT CREATE OR REPLACE Procedure  332:: GetKDFItmeInsertCheck
create or replace Procedure GetKDFItmeInsertCheck
(
	pIDD IN Number,
	pBUDGETID IN NUMBER,
	pSTAGEID IN NUMBER,
	pParameterid IN NUMBER,
	pIQty in number, 
	pRecsAffected out NUMBER
)
AS
	mqty number(12,2);
	cqty number(12,2);
	uqty number(12,2);
	nqty number(12,2);
	nnqty number(12,2);
	tqty number(12,2);
BEGIN
	select nvl(sum(quantity),0) into mqty from t_yarncost where BUDGETID=pBUDGETID;
	if pIDD=pParameterid+1 then
		if((pIQty)>mqty) then
			pRecsAffected:=mqty;
		else
			pRecsAffected:=0;
		end if;
	else
		select nvl(sum(quantity),0) into cqty from t_kdfcost where BUDGETID=pBUDGETID and
			stageid=pSTAGEID group by stageid;
		select nvl(sum(quantity),0) into uqty from t_kdfcost where BUDGETID=pBUDGETID and
			stageid=pSTAGEID and pid=pIDD group by pid;
		nqty:=(cqty - uqty);
		tqty:=nqty + pIQty;
		if(tqty>mqty) then
			pRecsAffected:=mqty;
		else
			pRecsAffected:=0;
		end if;
	end if;
END GetKDFItmeInsertCheck;
/



PROMPT CREATE OR REPLACE Procedure  333:: getTreeTexBugetList
create or replace Procedure getTreeTexBugetList(
 io_cursor IN OUT pReturnData.c_Records,
  pOrdertype varchar2,
  pQueryType IN NUMBER,  
  sDate IN date,
  eDate IN date  
)
AS
BEGIN 
if pQueryType=0 then
    OPEN io_cursor FOR
    select BUDGETID,BUDGETNO,revision from t_budget 
		where BUDGETPREDATE>=sDate and BUDGETPREDATE <=EDate and ordertypeid=pOrdertype order by budgetid desc;
elsif pQueryType=1 then
    OPEN io_cursor FOR
    select BUDGETID,BUDGETNO,BUDGETPREDATE from  t_budget a
		where a.BUDGETPREDATE>=sDate and a.BUDGETPREDATE <=EDate and ordertypeid=pOrdertype order by a.BUDGETPREDATE desc;
elsif pQueryType=2 then
    OPEN io_cursor FOR
    select a.BUDGETID,a.BUDGETNO,getfncwobtype(b.orderno) as Dorderno from  t_budget a,t_workorder b
		where a.BUDGETID=b.BUDGETID and a.revision=65 and a.ordertypeid=pOrdertype and  a.BUDGETPREDATE>=sDate and a.BUDGETPREDATE <=EDate order by Dorderno desc,a.budgetno desc;
end if;
END getTreeTexBugetList;
/

PROMPT CREATE OR REPLACE Procedure  334:: GetGDWorkOrderListNew
create or replace Procedure GetGDWorkOrderListNew
(
  data_cursor IN OUT pReturnData.c_Records,
  pOrdertype varchar2
)
AS
BEGIN
 OPEN data_cursor for
     Select ORDERTYPEID,ORDERTYPEID || ' ' || GDORDERNO as GDORDERNO,GORDERNO
		from T_Gworkorder where ordertypeid=pOrdertype ORDER BY GDORDERNO DESC;
END GetGDWorkOrderListNew;
/

PROMPT CREATE OR REPLACE Procedure  335:: GetTWorkOrderList
create or replace Procedure GetTWorkOrderList
(
  data_cursor IN OUT pReturnData.c_Records,
  pOrdertype varchar2
)
AS
BEGIN
 OPEN data_cursor for
     Select BASICTYPEID,BASICTYPEID || ' ' || DORDERNO as DORDERNO,ORDERNO
		from T_workorder where BASICTYPEID=pOrdertype ORDER BY DORDERNO DESC;
END GetTWorkOrderList;
/



PROMPT CREATE OR REPLACE Procedure  336:: GetNextBudgetno
CREATE OR REPLACE Procedure GetNextBudgetno
(
  one_cursor IN OUT pReturnData.c_Records,
  pBasictypeid varchar2
)
AS
BEGIN
    open one_cursor for
    select To_char(max(budgetno)) from (select to_number(budgetno) as budgetno 
		from t_budget where ordertypeid=pBasictypeid);    
END GetNextBudgetno;
/


PROMPT CREATE OR REPLACE Procedure  337:: AccessoriesPickInfo
create or replace Procedure AccessoriesPickInfo
(
  one_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
    open one_cursor for
	SELECT  a.ACCESSORIESID,a.ITEM,a.UNITOFMEASID,b.unitofmeas
		from t_accessories a, t_unitofmeas b
		where a.unitofmeasid=b.unitofmeasid
		order by GROUPID, ACCESSORIESID;
END AccessoriesPickInfo;
/

PROMPT CREATE OR REPLACE Procedure  338:: getKchargetotal
create or replace Procedure getKchargetotal
(
 data_cursor IN OUT pReturnData.c_Records,
 pWhereValue number
)

AS
BEGIN
 OPEN data_cursor for
select a.budgetid,a.PARAMID,b.PARAMETERNAME,d.fabrictype as fabrictype,sum(quantity) as netqty,sum(totalcost) as reqty
   from t_kdfcost a, t_budgetparameter b,t_fabricconsumption c,t_fabrictype d
   where  a.ppid=c.pid and c.fabrictypeid=d.fabrictypeid and
   a.paramid=b.paramid and
   a.budgetid=pWhereValue and a.stageid=3 group by a.budgetid,a.PARAMID,b.PARAMETERNAME,d.fabrictype,a.ppid order by a.ppid;
END getKchargetotal;
/

PROMPT CREATE OR REPLACE Procedure  339:: GetKItmeInsertCheck

create or replace Procedure GetKItmeInsertCheck
(
	pIDD IN Number,
	pBUDGETID IN NUMBER,
	pSTAGEID IN NUMBER,
	pParameterid IN NUMBER,
	pIQty in number,
	PPpid in number,
	pRecsAffected out NUMBER
)
AS
	mqty number(12,2);
	cqty number(12,2);
	uqty number(12,2);
	nqty number(12,2);
	nnqty number(12,2);
	tqty number(12,2);
BEGIN
	select nvl(sum(quantity),0) into mqty from t_yarncost where BUDGETID=pBUDGETID and ppid=PPpid;
	if pIDD=pParameterid+1 then
		if((pIQty)>mqty) then
			pRecsAffected:=mqty;
		else
			pRecsAffected:=0;
		end if;
	else
		select nvl(sum(quantity),0) into cqty from t_kdfcost where BUDGETID=pBUDGETID and
			stageid=pSTAGEID and ppid=PPpid group by ppid;
		select nvl(sum(quantity),0) into uqty from t_kdfcost where BUDGETID=pBUDGETID and
			stageid=pSTAGEID and pid=pIDD group by pid;
		nqty:=(cqty - uqty);
		tqty:=nqty + pIQty;
		if(tqty>mqty) then
			pRecsAffected:=mqty;
		else
			pRecsAffected:=0;
		end if;
	end if;
END GetKItmeInsertCheck;
/


PROMPT CREATE OR REPLACE Procedure  340 :: TexBUDGETUPDATE
create or replace Procedure TexBUDGETUPDATE
(
	pBUDGETID IN NUMBER
)
AS
	ftotal number;
	mqty  number;
	tyc number;
	tfcost number;
	netfcost number;
	funitp number;
	kdfcost number;
	tgcost number;
	id number;
	tgsqty number;
	nettgsqty number;
	fscost number;
	netfscost number;
	pc number;
	tc Number;
	yqty number;
	ynqty number;
	id1 number;
BEGIN
	select count(*) into id from t_budget where budgetid=pBUDGETID;
	if(id!=0) then
		select QUANTITY into mqty from t_budget where budgetid=pBUDGETID;
	for rec in(select budgetid,pid,CONSUMPTIONPERDOZ,WASTAGE,NETCONSUMPTIONPERDOZ,TOTALCONSUMPTION,
		STAGEID,RPERCENT,PCS from t_fabricconsumption where budgetid=pBUDGETID)
	loop
		tc:=(rec.TOTALCONSUMPTION);
		UPDATE t_fabricconsumption SET 
			TOTALCONSUMPTION=(rec.TOTALCONSUMPTION) where pid=rec.pid;
		for rec1 in(select pid,YARNTYPEID,YARNCOUNTID,SUPPLIERID,QUANTITY,UNITPRICE,TOTALCOST,
			STAGEID,USES,QTY,PROCESSLOSS,FABRICTYPEID from t_yarncost where budgetid=pBUDGETID and ppid=rec.pid)
			loop
				yqty:=(rec1.uses*tc)/100;
				ynqty:=(yqty+(yqty*rec1.processloss)/100);
				update t_yarncost set qty=(rec1.uses*tc)/100,quantity=ynqty,totalcost=ynqty*rec1.unitprice where pid=rec1.pid;
			end loop;
		end loop;
	select round(sum(TOTALCONSUMPTION)) into ftotal from t_fabricconsumption where budgetid=pBUDGETID;
	if ftotal=0 then
		ftotal:=Null;
	else ftotal:=ftotal;
	end if;
	select nvl(round(sum(TOTALCOST)),0) into tyc from t_Yarncost where budgetid=pBUDGETID;
	select nvl(round(sum(totalcost)),0) into kdfcost from t_kdfcost where budgetid=pBUDGETID and stageid in(3,4,5);
	netfcost:=tyc+kdfcost;
	funitp:=netfcost/ftotal;
	update t_kdfcost set UNITPRICE=(funitp*(QUANTITY/100)),TOTALCOST=(netfcost*(QUANTITY/100)) where budgetid=pBUDGETID and stageid=6;
	select nvl(round(sum(totalcost)),0) into tgcost from t_garmentscost where budgetid=pBUDGETID and stageid in(7,8,9,11);
	update t_garmentscost set CONSUMPTIONPERDOZ=mqty/12,TOTALCOST=mqty/12*UNITPRICE where budgetid=pBUDGETID and stageid=9;
	update t_garmentscost set TOTALCOST=(tgcost*QUNATITY)/100 where budgetid=pBUDGETID and stageid=10;
	select nvl(round(sum(totalcost)),0) into fscost from t_kdfcost where budgetid=pBUDGETID and stageid in(3,4,5);
	netfscost:=tyc+fscost;
	select nvl(round(sum(totalcost)),0) into tgsqty from t_garmentscost where budgetid=pBUDGETID and stageid in(7,8,9);
	nettgsqty:=netfscost+tgsqty;
	for rec2 in(select pid,qty from t_garmentscost where budgetid=pBUDGETID and stageid=11 and PARAMID not in(26,27,28))
		loop
			update t_garmentscost set TOTALCOST=(nettgsqty*rec2.QTY)/100 where pid=rec2.pid;
		end loop;
	end if;
END TexBUDGETUPDATE;
/

PROMPT CREATE OR REPLACE Procedure  341 :: getGASupplierInfo
CREATE OR REPLACE Procedure getGASupplierInfo(
	io_cursor IN OUT pReturnData.c_Records 
  )
AS
BEGIN  
    OPEN io_cursor FOR
	select SupplierId,SupplierName from T_Supplier where substr(supplierfor,3,1)=1	
		order by SupplierName asc;  
END getGASupplierInfo;
/
PROMPT CREATE OR REPLACE Procedure  342 :: GetBSubconLookup
CREATE OR REPLACE Procedure GetBSubconLookup
(
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
  OPEN data_cursor for
  select  SUBCONID,SUBCONNAME from  t_subcontractors order by SUBCONNAME asc;
END GetBSubconLookup;
/

PROMPT CREATE OR REPLACE Procedure  343 :: GetSizeList
CREATE OR REPLACE Procedure GetSizeList
(
  pStatus number,
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
/*if the Value is 0 then retun all the Data */
if pStatus=0 then
  OPEN data_cursor for
    Select SIZENAME, SIZEID from T_SIZE order by SIZENAME;
/*If the Value is 1 then retun as the */
elsif pStatus=1 then
  OPEN data_cursor for
    Select SIZENAME, SIZEID from T_SIZE
  where SIZEID=pWhereValue order by SIZENAME;
end if;
END GetSizeList;
/


PROMPT CREATE OR REPLACE Procedure  344 :: GetSizeIDs
CREATE OR REPLACE Procedure GetSizeIDs
(
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN

    OPEN data_cursor for
    Select SIZEID, SIZENAME from T_SIZE;

END GetSizeIDs;
/



PROMPT CREATE OR REPLACE Procedure  345 :: getGorderSize
CREATE OR REPLACE Procedure getGorderSize
(
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)

AS

BEGIN

  OPEN data_cursor for
 select GSIZEID,SIZEID,QUANTITY,ORDERLINEITEM from T_GORDERSIZE
  where orderLineItem=pWhereValue;

END getGorderSize;
/




PROMPT CREATE OR REPLACE Procedure  346 :: GetGMachineInfoLookUp
CREATE OR REPLACE Procedure GetGMachineInfoLookUp
(
  pStatus number,
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
/*if the Value is 0 then retun all the Data */
if pStatus=0 then
  OPEN data_cursor for
   select MCLISTID,MCLISTNAME
	from T_GMCLIST
	order by MCLISTNAME;
/*If the Value is 1 then retun as the */
elsif pStatus=1 then
  OPEN data_cursor for
   select MCLISTID,MCLISTNAME
	from T_GMCLIST
	where  MCLISTID=pWhereValue
	order by MCLISTNAME;
end if;
END GetGMachineInfoLookUp;
/


PROMPT CREATE OR REPLACE Procedure  347 :: getTreeGMCPurcharReq
CREATE OR REPLACE Procedure getTreeGMCPurcharReq (
  io_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,  
  sDate IN date,
  eDate IN date
)
AS
BEGIN

  if pQueryType=0 then
    OPEN io_cursor FOR
    select REQID, Reqno from T_GMCPurchaseReq
    where REQDATE>=SDate and REQDATE<=EDate
    order by Reqno desc;

  elsif pQueryType=1 then
    OPEN io_cursor FOR
    select REQID, Reqno, REQDATE
	from 	T_GMCPurchaseReq
    where 	REQDATE>=SDate and 
			REQDATE<=EDate
    order by REQDATE desc, Reqno desc; 
	
end if;

END getTreeGMCPurcharReq;
/
PROMPT CREATE OR REPLACE Procedure  348 :: GetGMCpurchageReqinfo
Create or Replace Procedure GetGMCpurchageReqinfo
(
 one_cursor IN OUT pReturnData.c_Records,
 many_cursor IN OUT pReturnData.c_Records,
 preqid Number
)
AS
BEGIN
 open one_cursor for
  SELECT REQID,REQNO,REQDATE ,DEPTID,REQUIRMENTDATE,REMARKS,Reqby           
  from T_GMCPurchaseReq
 where Reqid=preqid ;

 open many_cursor for
 select a.PID,a.REQTYPEID,a.REQID,a.SLNO,a.PARTID,b.PARTNAME,b.DESCRIPTION,b.FOREIGNPART,
 a.UNITPRICE,a.QTY,a.UNITOFMEASID,a.ISSUEFOR,a.DeptID,a.REMARKS                      
 from  T_GMCPurchaseReqItems a,T_GMcPartsInfo b
 where a.PARTID=b.PARTID  and Reqid=preqid ;

END GetGMCpurchageReqinfo;
/
PROMPT CREATE OR REPLACE Procedure  349 :: GetGMCPartsPickUpFromPReq
CREATE OR REPLACE Procedure GetGMCPartsPickUpFromPReq(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER
)
AS

BEGIN
 /* For Purchase Requisition Pickup */
if pQueryType=1 then
 open data_cursor for
	Select a.REQID,a.REQNO,a.REQDATE,a.REQBY,i.name as REQBYNAME,a.REQUIRMENTDATE,
	b.PID,b.REQTYPEID,b.REQID,b.PARTID,b.UNITPRICE,b.QTY,b.UNITOFMEASID,e.UNITOFMEAS,b.ISSUEFOR AS MACHINEID,MCLISTNAME,b.REMARKS,
	c.PARTNAME,c.FOREIGNPART,c.MACHINETYPE,c.DESCRIPTION,b.DeptID,g.PROJNAME as DeptName     
	From T_GMCPurchaseReq a,T_GMCPurchaseReqItems b,T_GMCPARTSINFO c,t_UnitOfMeas e,T_GMCLIST f,T_PROJECT g,T_PurchaseReqBy i
	Where a.REQID=b.REQID and b.PARTID=c.PARTID and
		ISSUEFOR=f.MCLISTID(+) and 
		b.DeptID=g.PROJCODE(+) and
		i.pid=a.REQBY(+) and
		b.UNITOFMEASID=e.UNITOFMEASID(+)
        order by a.REQNO;
  end if;
END GetGMCPartsPickUpFromPReq;
/


PROMPT CREATE OR REPLACE Procedure  350 :: ExecuteSQL_WithLog
CREATE OR REPLACE Procedure ExecuteSQL_WithLog
(
  pStrSql IN VARCHAR2,
  pRecsAffected out NUMBER,  
  pStrSqllog IN VARCHAR2,
  pRecsAffectedlog out NUMBER
)
AS
  insertSql VARCHAR2(3000);
  insertSqllog VARCHAR2(3000);
BEGIN
  insertSql :=pStrSql;
  insertSqllog :=pStrSqllog;

  execute immediate insertSql;
  pRecsAffected := SQL%ROWCOUNT;
    
  if pRecsAffected > 0 then
  	execute immediate insertSqllog;
	  pRecsAffectedlog := SQL%ROWCOUNT;
  End if;
	
  if pRecsAffectedlog >0 then
	commit;
  Else
	Rollback;
  End If;
END ExecuteSQL_WithLog;
/



PROMPT CREATE OR REPLACE Procedure  351 :: ExecuteSQL_NoEff
CREATE OR REPLACE Procedure ExecuteSQL_NoEff
(
  pStrSql IN VARCHAR2,
  pRecsAffected out NUMBER
)
AS
  insertSql VARCHAR2(1000);
BEGIN
  insertSql :=pStrSql;
  execute immediate insertSql;
  pRecsAffected := SQL%ROWCOUNT;
END ExecuteSQL_NoEff;
/


PROMPT CREATE OR REPLACE Procedure  352 :: GetUserLoggingList
CREATE OR REPLACE PROCEDURE GetUserLoggingList    
(
  io_cursor IN OUT pReturnData.c_Records,
  pDate varchar2
)
AS
BEGIN
  open io_cursor for
  select UserLoggingId, UserId || '  ' ||EmployeeName as UserId, LogIn, Terminal, LogOut
 from T_UserLogging,T_Employee
 where T_UserLogging.UserId=T_Employee.EmployeeID and 
 To_Char(LogIn, 'DD-MM-YYYY') = pDate
 order by LogIn Desc;
END GetUserLoggingList;
/

PROMPT CREATE OR REPLACE Procedure  353 :: InsertRecWithIdentity_NoEff
CREATE OR REPLACE Procedure InsertRecWithIdentity_NoEff(
  pStrSql IN VARCHAR2,
  pIdentityName IN VARCHAR2,
  pIdentityFld IN VARCHAR2,
  pCurIdentityVal OUT NUMBER,
  pRecsAffected out NUMBER,
  pUserName IN VARCHAR2,
  pComputerName IN VARCHAR2
)
AS
  tmpSql VARCHAR2(1000);
  restSql VARCHAR2(1000);
  insertSql VARCHAR2(1000);
  tmpPos NUMBER;
BEGIN

  execute immediate 'select ' || pIdentityName || '.NEXTVAL from sys.dual'
  into pCurIdentityVal;

  tmpPos := instr(pStrSql, '(', 1, 1);
  tmpSql := substr(pStrSql, 1, tmpPos);
  restSql := substr(pStrSql, tmpPos+1);
  insertSql := tmpSql || pIdentityFld || ',';

  tmpPos := instr(restSql, ' values (', 1, 1);
  tmpSql := substr(restSql, 1, tmpPos);
  restSql := substr(restSql, tmpPos+9);
  insertSql := insertSql || tmpSql || ' values (' ||
          TO_CHAR(pCurIdentityVal) || ',' || restSql;


  execute immediate insertSql;
  pRecsAffected := pCurIdentityVal; /*SQL%ROWCOUNT; Just Test Only by Habib */

END InsertRecWithIdentity_NoEff;
/


PROMPT CREATE OR REPLACE Procedure  354 :: GetSqlLogMinMax
create or replace procedure GetSqlLogMinMax
(
   one_cursor IN OUT pReturnData.c_Records
)
as
begin
open one_cursor for
   select nvl(min(Logsequenceid),0)minid ,nvl(max(Logsequenceid),0)maxid 
   from t_sqllog;
end GetSqlLogMinMax;
/

PROMPT CREATE OR REPLACE Procedure  355:: GetUpdateLogTree
create or replace procedure GetUpdateLogTree
(
   io_cursor IN OUT pReturnData.c_Records,
   pMin number,
   pMax number

)
as
begin
  open io_cursor for
  select Logsequenceid from T_SQLLOGUPDATE

  where  Logsequenceid between pMin and pMax
  order by Logsequenceid desc;

end GetUpdateLogTree;
/
PROMPT CREATE OR REPLACE Procedure  356:: GetLogTree
create or replace procedure GetLogTree
(
   io_cursor IN OUT pReturnData.c_Records,
   pMin number,
   pMax number
)
as
begin
  open io_cursor for
  select Logsequenceid from T_SQLLOG
  where  Logsequenceid between pMin and pMax
  order by Logsequenceid desc;
end GetLogTree;
/

PROMPT CREATE OR REPLACE Procedure  357:: GetUserLoggingList
CREATE OR REPLACE PROCEDURE GetUserLoggingList    
(
  io_cursor IN OUT pReturnData.c_Records,
  pDate varchar2
)
AS
BEGIN
  open io_cursor for
  select UserLoggingId, EmployeeName || ' (' || UserId || ')' as UserId, LogIn, Terminal, LogOut
 from T_UserLogging,T_Employee
 where T_UserLogging.UserId=T_Employee.EmployeeID and 
 To_Char(LogIn, 'DD-MM-YYYY') = pDate
 order by LogIn Desc;
END GetUserLoggingList;
/

PROMPT CREATE OR REPLACE Procedure  358 :: GetSqlUpdateTextFile
create or replace Procedure GetSqlUpdateTextFile(
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
     open data_cursor for
 SELECT LOGSEQUENCEID, SQL
 FROM T_SQLLog
 WHERE COPIED = 0
 ORDER BY LOGSEQUENCEID;

END GetSqlUpdateTextFile;
/


PROMPT CREATE OR REPLACE Procedure  359 :: GetSqlUpdateLogMinMax
create or replace procedure GetSqlUpdateLogMinMax
(
   one_cursor IN OUT pReturnData.c_Records
)
as
begin
open one_cursor for
   select nvl(min(Logsequenceid),0)minid ,nvl(max(Logsequenceid),0)maxid
   from T_SQLLOGUPDATE;
end GetSqlUpdateLogMinMax;
/

PROMPT CREATE OR REPLACE Procedure  360 :: GetSqlLogInfo
create or replace Procedure  GetSqlLogInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  pLogsequenceid number
)
AS
BEGIN
 open one_cursor for
  select a.Logsequenceid,(a.employeeid)userid,a.terminal,a.logdate,a.sql,
(b.employeename)username, a.Copied

  from t_sqllog a, t_employee b
  where a.employeeid=b.employeeid(+) and
  a.Logsequenceid = pLogsequenceid
  order by Logsequenceid;
END GetSqlLogInfo;
/
PROMPT CREATE OR REPLACE Procedure  361 :: GetOCWbillList
CREATE OR REPLACE PROCEDURE GetOCWbillList(
  data_cursor IN OUT pReturnData.c_Records,   
  pOrdercode in varchar2
)
AS  
BEGIN
  OPEN data_cursor  FOR
  SELECT billno,Ordercode||' '||billno as btype
  from T_BillItems where pOrdercode is null or ordercode=pOrdercode 
  group by billno,ordercode 
  order by Ordercode||' '||billno;         
END GetOCWbillList;
/

PROMPT CREATE OR REPLACE Procedure  362 :: GETMoneyReceiptInfo
CREATE OR REPLACE Procedure GETMoneyReceiptInfo
(
  one_cursor IN OUT pReturnData.c_Records, 
  pReceipID number
)
AS
BEGIN
    open one_cursor for
    select PID ,RECEIPTNO,RECEIPTDATE,RECEIPTFOR,PARTYID,AMOUNT ,paymentno,cash,cheque,payorder,draft,
	branch,PAYDATE,BANKID,BILLNO,PURPOSE,EMPLOYEEID ,status ,Posted,Postdate,customerid,electric,maintenence,cancel,reason  
    from T_MoneyReceipt
    where PID=pReceipID;   
END GETMoneyReceiptInfo;
/

PROMPT CREATE OR REPLACE Procedure  363 :: TreeMoneyReceipt
CREATE OR REPLACE Procedure TreeMoneyReceipt (
  io_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER, 
  sDate IN date,
  eDate IN date,
  pCurgroup IN Number
)
AS
BEGIN

  if pQueryType=0 then
    OPEN io_cursor FOR
    select pid,receiptno from T_MoneyReceipt 
    where receiptdate>=SDate and receiptdate<=EDate  and receiptfor=pCurgroup
    order by (receiptno) desc;

elsif pQueryType=1 then
    OPEN io_cursor FOR    
    select pid,receiptno,receiptdate from T_MoneyReceipt 
    where receiptdate>=SDate and receiptdate<=EDate and receiptfor=pCurgroup
    order by receiptdate desc, receiptno desc;
	
elsif pQueryType=2 then
    OPEN io_cursor FOR    
    select pid,receiptno,employeename from T_MoneyReceipt a,T_employee b
    where a.employeeid=b.employeeid and receiptdate>=SDate and receiptdate<=EDate and receiptfor=pCurgroup
    order by employeename desc, receiptno desc;
	
elsif pQueryType=3 then
	OPEN io_cursor FOR    
    select pid,receiptno,PARTYNAME from T_MoneyReceipt a,T_Party b
    where a.PARTYID=b.PARTYID and a.receiptdate>=SDate and a.receiptdate<=EDate and a.receiptfor=pCurgroup
    order by PARTYNAME desc, receiptno desc;
  end if;

END TreeMoneyReceipt;
/
PROMPT CREATE OR REPLACE Procedure  364 :: moneyreceippartyLookup
CREATE OR REPLACE Procedure moneyreceippartyLookup
(
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN

  OPEN data_cursor for
  select Partyid,Partyname from T_Party ORDER BY Partyname asc;

END moneyreceippartyLookup;
/
PROMPT CREATE OR REPLACE Procedure  365 :: ReceipentLookup
CREATE OR REPLACE Procedure ReceipentLookup
(
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN

  OPEN data_cursor for
  select rid,INITCAP(DESCRIPTION) as receipentname from T_receipent ORDER BY receipentname asc;
END ReceipentLookup;
/


PROMPT CREATE OR REPLACE Procedure  366:: ReceiptPost
Create or Replace Procedure ReceiptPost
(
 pReciptid IN NUMBER,
 pRecsAffected out NUMBER

)
AS
dt varchar2(50);
id number;
BEGIN
select to_char(localtimestamp(0),'dd/mm/yyyy hh.mi.ss am') into  dt from dual;
pRecsAffected:=100;

select customerid into id from t_moneyreceipt where pid=pReciptid;
update t_electricitybill set paid=1 where pid=id;

update T_MoneyReceipt set Posted=1,postdate=sysdate where PID=pReciptid;

END ReceiptPost;
/



PROMPT CREATE OR REPLACE Procedure  367:: ReceiptUnpost

Create or Replace Procedure ReceiptUnpost
(
 pReceiptid IN NUMBER,
 pUserID Varchar2,
 pPassword varchar2,
 pFormid In Varchar2,
 pRecsAffected out NUMBER

)
AS
uid varchar2(50);

id number;
execep_login_failed Exception;
execep_auth_failed Exception;
BEGIN
select count(*) into id from t_employee where Employeeid=pUserID and Emppassword=pPassword;
if(id=0) then
Raise execep_login_failed;

Else 
select Employeeid into uid from t_Athurization where employeeid=pUserID and formid=pformid;
pRecsAffected:=100;

if (uid=pUserID) then
update T_MoneyReceipt set Posted=0,unpostby=uid where PID=pReceiptid;
else
Raise No_data_found ;
End if;

END IF;
EXCEPTION
WHEN execep_login_failed then
pRecsAffected:=98;

WHEN No_data_found then
pRecsAffected:=99;

END ReceiptUnpost;
/



PROMPT CREATE OR REPLACE Procedure  368 :: DeliveryChalanInfo
CREATE OR REPLACE Procedure DeliveryChalanInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  many_cursor IN OUT pReturnData.c_Records,
  pInvoiceid number
)
AS
BEGIN
    open one_cursor for
    	select Invoiceid,ChallanNo, ChallanDate, Invoiceno, InvoiceDATE,
   	 	ClientID,Remarks, SubConId,Pono,GatepassNo,catid,contactperson,deliveryplace,orderno,
		VEHICLENO,DRIVERNAME,DRIVERLICENSENO,DRIVERMOBILENO,TRANSCOMPNAME,CANDFID,DELORDERTYPEID
		from T_GDELIVERYCHALLAN
		where Invoiceid=pInvoiceid;
	
    open many_cursor for
    	select a.PID,a.ORDERNO,a.Invoiceid,a.GSTOCKITEMSL,a.Quantity,a.Squantity,a.PunitOfmeasId,
		a.SUNITOFMEASID,a.SIZEID,a.BatchNo,a.Shade,a.REMARKS,a.CurrentStock,a.Styleno,a.countryid,
		a.Cartonno,a.CTNTYPE,a.CBM
		from T_GDELIVERYCHALLANItems a
		where a.Invoiceid=pInvoiceid 
		order by GSTOCKITEMSL asc;
END DeliveryChalanInfo;
/

PROMPT CREATE OR REPLACE Procedure  369 :: SendtoFF
Create or Replace Procedure SendtoFF
( 
	pStockID IN NUMBER,
	pRecsAffected out NUMBER
)
AS
ID NUMBER;
BEGIN
pRecsAffected:=100;
select SEQ_gStockID.nextval into ID from dual;
insert into T_Gstock(STOCKID,STOCKTRANSNO,STOCKTRANSDATE,CATID)
select ID,STOCKTRANSNO,STOCKTRANSDATE,7
 from T_Gstock where STOCKID=pStockID; 
  INSERT INTO T_GstockItems(PID,GTransTypeId,Orderno,StockId,GSTOCKITEMSL,PUnitOfMeasId,Currentstock,Quantity,Shade,Styleno,Countryid,SizeID,Cuttingid,Lineno)
 select SEQ_GStockItemID.Nextval,13,Orderno,ID,GSTOCKITEMSL,PUnitOfMeasId,Quantity,Quantity,Shade,Styleno,Countryid,SizeID,Cuttingid,
 case 
 when lineno between 1 and 7 then 1
  when lineno between 8 and 14 then 2
  else 3
  end as line
 from T_GstockItems where Stockid=pStockID and GTransTypeId=7; 
END SendtoFF;
/

PROMPT CREATE OR REPLACE Procedure  370 :: GETCopyCuttingItems
CREATE OR REPLACE Procedure GETCopyCuttingItems(
  pSTOCKID IN NUMBER,
  pSID IN NUMBER,
  pRecsAffected out NUMBER
)
AS   
  tmpSlNoSql NUMBER;
BEGIN
   
   		SELECT MAX(GSTOCKITEMSL)+1 into tmpSlNoSql from T_GStockitems where Stockid=pSTOCKID;

  		insert into T_GStockitems (Pid,STOCKID,GSTOCKITEMSL,ORDERNO,BUNDLENO,SIZEID,COUNTRYID,SHADE,
		STYLENO,PUNITOFMEASID,Sunitofmeasid,GTRANSTYPEID,QUANTITY,FABRICTYPEID,PIECESTATUS,cuttingid,displayno)
    		select SEQ_GStockItemID.Nextval,STOCKID,tmpSlNoSql,ORDERNO,
		BUNDLENO,SIZEID,COUNTRYID,SHADE,STYLENO,PUNITOFMEASID,Sunitofmeasid,
		GTRANSTYPEID,QUANTITY,FABRICTYPEID,PIECESTATUS,cuttingid,displayno
	from 
		T_GStockitems where pid=pSID;

   pRecsAffected := SQL%ROWCOUNT;

END GETCopyCuttingItems;
/



PROMPT CREATE OR REPLACE Procedure  371 :: Cuttingsummary
CREATE OR REPLACE PROCEDURE Cuttingsummary(
  data_cursor IN OUT pReturnData.c_Records,
  pCuttingid IN Number
)
AS
  vSDate date;
  vEDate date;
  curdate Date;
BEGIN
 	select STOCKTRANSDATE into curdate from t_Gstock where STOCKID=pCuttingid;
OPEN data_cursor  FOR
		Select B.SHADE,getfncDispalyorder(C.GORDERNO) as btype,b.PUNITOFMEASID as Unitofmeasid,b.SIZEID,'' AS ORDERLINEITEM,a.STOCKTRANSDATE as CUTTINGDATE,B.styleno,
		'' AS PONO,d.clientname,e.sizename,f.unitofmeas,g.countryname,C.GORDERNO,Sum(b.QUANTITY*CGS) as qty
	from 
		T_GSTOCK a,
		T_GStockItems b,
		t_Gworkorder c,
		t_client d,
		t_size e,
		t_unitofmeas f,
		t_country g,
		t_gtransactiontype i
	where 
		a.STOCKID=b.STOCKID and
		b.GTRANSTYPEID=i.GTRANSACTIONTYPEID and
		B.orderno=c.gorderno and
		a.clientid=d.clientid and
		b.sizeid=e.sizeid and
		B.countryid=g.countryid and
		b.Punitofmeasid=f.unitofmeasid and
		a.STOCKTRANSDATE between curdate and  curdate
	Group by 
		B.SHADE,b.PUNITOFMEASID,b.SIZEID,a.STOCKTRANSDATE ,B.styleNO,
		d.clientname,e.sizename,f.unitofmeas,g.countryname,C.GORDERNO
	order by styleno;
END Cuttingsummary;
/


PROMPT CREATE OR REPLACE Procedure  372 :: GarmentsIssuetoSFPickup
CREATE OR REPLACE PROCEDURE GarmentsIssuetoSFPickup(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pBundleno IN Varchar2
)
AS
BEGIN
	if pQueryType=1 then
	OPEN data_cursor  FOR
	select '' AS bundleno,B.lineno,B.SHADE,getfncDispalyorder(b.ORDERNO) as btype,b.PUNITOFMEASID as punitid,b.cuttingid,cuttingno(b.cuttingid) as cuttingno,
		b.SIZEID,B.styleno,B.PIECESTATUS  as statusid,DECODE(B.PIECESTATUS,0,'Non-Printed','Printed') as Pstatus,
		e.sizename,f.unitofmeas as punit,g.countryname,B.ORDERNO,B.countryid,Sum(b.QUANTITY) as currentstock,
		(select sum(quantity)  from t_gstockitems where lineno=b.lineno and shade=b.shade and orderno=b.orderno and
		punitofmeasid=b.PUNITOFMEASID and cuttingid=b.cuttingid and sizeid=b.SIZEID and styleno=b.styleno
		and b.piecestatus=B.PIECESTATUS and countryid=b.countryid  and GTRANSTYPEID =6
		group by lineno,shade,orderno,punitofmeasid,cuttingid,sizeid,styleno,piecestatus) as issueqty,
		Sum(b.QUANTITY)-(select sum(quantity)  from t_gstockitems where lineno=b.lineno and shade=b.shade and orderno=b.orderno and
		punitofmeasid=b.PUNITOFMEASID and cuttingid=b.cuttingid and sizeid=b.SIZEID and styleno=b.styleno
		and b.piecestatus=B.PIECESTATUS and countryid=b.countryid  and GTRANSTYPEID =6
		group by lineno,shade,orderno,punitofmeasid,cuttingid,sizeid,styleno,piecestatus) as RemainQty
 from
	T_GFabricReqItems b,
	T_GFabricReq a,
	T_GFabricReqType c,
	t_size e,
	t_unitofmeas f,
	t_country g
    where
		a.STOCKID=b.STOCKID and
		b.GFabricReqTypeId=c.GFabricReqTypeId and
		b.sizeid=e.sizeid and
		B.countryid=g.countryid and
		b.Punitofmeasid=f.unitofmeasid and
		b.GFabricReqTypeId=2 and
		(pBundleno is null or b.bundleno=pBundleno)
	Group by
		B.SHADE,b.PUNITOFMEASID,b.SIZEID,B.styleNO,B.lineno,
		e.sizename,f.unitofmeas,g.countryname,B.ORDERNO,B.countryid,B.PIECESTATUS,b.cuttingid
		having Sum(b.QUANTITY)-(select sum(quantity)  from t_gstockitems where lineno=b.lineno and shade=b.shade and orderno=b.orderno and
		punitofmeasid=b.PUNITOFMEASID and cuttingid=b.cuttingid and sizeid=b.SIZEID and styleno=b.styleno
		and b.piecestatus=B.PIECESTATUS and countryid=b.countryid  and GTRANSTYPEID =6
		group by lineno,shade,orderno,punitofmeasid,cuttingid,sizeid,styleno,piecestatus)>0
	order by cuttingno,btype,B.styleno,B.SHADE,B.PIECESTATUS;
	elsif pQueryType=2 then
	OPEN data_cursor  FOR
	Select
		b.bundleno,B.lineno,B.SHADE,getfncDispalyorder(b.ORDERNO) as btype,b.PUNITOFMEASID as punitid,b.cuttingid,b.displayno as cuttingno,
		b.SIZEID,B.styleno,B.PIECESTATUS  as statusid,DECODE(B.PIECESTATUS,0,'Non-Printed','Printed') as Pstatus,
		e.sizename,f.unitofmeas as punit,g.countryname,B.ORDERNO,B.countryid,Sum(b.QUANTITY*CGSL) as currentstock
	from
		T_GSTOCK a,
		T_GStockItems b,
		t_size e,
		t_unitofmeas f,
		t_country g,
		t_gtransactiontype i
	where
		a.STOCKID=b.STOCKID and
		b.GTRANSTYPEID=i.GTRANSACTIONTYPEID and
		b.sizeid=e.sizeid and
		B.countryid=g.countryid and
		 b.GTRANSTYPEID Not in(15,26) AND
		b.Punitofmeasid=f.unitofmeasid AND
		(pBundleno is null or b.bundleno=pBundleno)
	Group by
		B.SHADE,b.PUNITOFMEASID,b.SIZEID,B.styleNO,B.lineno,
		e.sizename,f.unitofmeas,g.countryname,B.ORDERNO,b.bundleno,B.countryid,B.PIECESTATUS,b.cuttingid,b.displayno
		having Sum(b.QUANTITY*CGSL)>0
	order by btype,B.styleno,B.SHADE;
    /*Complete garments receive from sewing for iron pickup*/
	elsif pQueryType=3 then
		OPEN data_cursor  FOR
		Select '' AS bundleno,'' AS lineno,B.SHADE,getfncDispalyorder(b.ORDERNO) as btype,b.PUNITOFMEASID as punitid,b.SIZEID,B.styleno,b.cuttingid,b.displayno as cuttingno,
		e.sizename,f.unitofmeas as punit,g.countryname,B.ORDERNO,B.countryid,Sum(b.QUANTITY*SGS) as currentstock
	from T_GSTOCK a,
		T_GStockItems b,
		t_size e,
		t_unitofmeas f,
		t_country g,
		t_gtransactiontype i
	where
		a.STOCKID=b.STOCKID and
		b.GTRANSTYPEID=i.GTRANSACTIONTYPEID and
		b.sizeid=e.sizeid and
		B.countryid=g.countryid and
		b.Punitofmeasid=f.unitofmeasid AND
		(pBundleno is null or b.bundleno=pBundleno)
	Group by
		B.SHADE,b.PUNITOFMEASID,b.SIZEID,B.styleNO,
		e.sizename,f.unitofmeas,g.countryname,B.ORDERNO,B.countryid,b.cuttingid,b.displayno
		having Sum(b.QUANTITY*SGS)>0
	order by
		btype,B.styleno,B.SHADE;
	elsif pQueryType=4 then
		OPEN data_cursor  FOR
		Select '' AS bundleno,b.lineno AS lineno,B.SHADE,getfncDispalyorder(b.ORDERNO) as btype,b.PUNITOFMEASID as punitid,b.SIZEID,B.styleno,b.cuttingid,b.displayno as cuttingno,
		e.sizename,f.unitofmeas as punit,g.countryname,B.ORDERNO,B.countryid,Sum(b.QUANTITY*GIF) as currentstock
	from
		T_GSTOCK a,
		T_GStockItems b,
		t_size e,
		t_unitofmeas f,
		t_country g,
		t_gtransactiontype i
	where
		a.STOCKID=b.STOCKID and
		b.GTRANSTYPEID=i.GTRANSACTIONTYPEID and
		b.sizeid=e.sizeid and
		B.countryid=g.countryid and
		b.Punitofmeasid=f.unitofmeasid AND
		(pBundleno is null or b.bundleno=pBundleno) and
		b.cuttingid is not null or b.cuttingid!=''
	Group by
		B.SHADE,b.PUNITOFMEASID,b.SIZEID,B.styleNO,
		e.sizename,f.unitofmeas,g.countryname,B.ORDERNO,B.countryid,b.lineno,b.cuttingid,b.displayno
		having Sum(b.QUANTITY*GIF)>0
	order by
		btype,B.styleno,B.SHADE;
	elsif pQueryType=5 then
	OPEN data_cursor  FOR
	Select '' AS bundleno,'' AS lineno,B.SHADE,getfncDispalyorder(b.ORDERNO) as btype,b.PUNITOFMEASID as punitid,b.SIZEID,B.styleno,b.cuttingid,b.displayno as cuttingno,
		e.sizename,f.unitofmeas as punit,g.countryname,B.ORDERNO,B.countryid,b.spotRef,'' as QCLOCATION,Sum(b.QUANTITY*GWSC) as currentstock
	from 	T_GSTOCK a,
		T_GStockItems b,
		t_size e,
		t_unitofmeas f,
		t_country g,
		t_gtransactiontype i
	where
		a.STOCKID=b.STOCKID and
		b.GTRANSTYPEID=i.GTRANSACTIONTYPEID and
		b.sizeid=e.sizeid and
		B.countryid=g.countryid and
		b.Punitofmeasid=f.unitofmeasid AND
		(pBundleno is null or b.bundleno=pBundleno)
	Group by
		B.SHADE,b.PUNITOFMEASID,b.SIZEID,B.styleNO,
		e.sizename,f.unitofmeas,g.countryname,B.ORDERNO,B.countryid,b.spotRef,b.cuttingid,b.displayno
		having Sum(b.QUANTITY*GWSC)>0
	order by btype,B.styleno,B.SHADE;
	elsif pQueryType=6 then
	OPEN data_cursor  FOR
	Select '' AS bundleno,'' AS lineno,B.SHADE,getfncDispalyorder(b.ORDERNO) as btype,b.PUNITOFMEASID as punitid,b.SIZEID,B.styleno,
		e.sizename,f.unitofmeas as punit,g.countryname,B.ORDERNO,B.countryid,Sum(b.QUANTITY*FGS) as currentstock
	from
		T_GSTOCK a,
		T_GStockItems b,
		t_size e,
		t_unitofmeas f,
		t_country g,
		t_gtransactiontype i
	where
		a.STOCKID=b.STOCKID and
		b.GTRANSTYPEID=i.GTRANSACTIONTYPEID and
		b.sizeid=e.sizeid and
		B.countryid=g.countryid and
		b.Punitofmeasid=f.unitofmeasid AND
		(pBundleno is null or b.bundleno=pBundleno)
	Group by
		B.SHADE,b.PUNITOFMEASID,b.SIZEID,B.styleNO,
		e.sizename,f.unitofmeas,g.countryname,B.ORDERNO,B.countryid
		having Sum(b.QUANTITY*FGS)>0
	order by btype,B.styleno,B.SHADE;
	elsif pQueryType=7 then
	OPEN data_cursor  FOR
	Select '' AS bundleno,'' AS lineno,B.SHADE,getfncDispalyorder(b.ORDERNO) as btype,
		b.PUNITOFMEASID as punitid,b.SIZEID,B.styleno,b.cuttingid,b.displayno as cuttingno,
		e.sizename,f.unitofmeas as punit,g.countryname,B.ORDERNO,B.countryid,b.spotRef,DECODE(b.spotRef,10,'Sewing Q.C',17,'Finishing Q.C','') as QCLOCATION,
		Sum(b.QUANTITY*GWF) as currentstock
	from
		T_GSTOCK a,
		T_GStockItems b,
		t_size e,
		t_unitofmeas f,
		t_country g,
		t_gtransactiontype i
	where
		a.STOCKID=b.STOCKID and
		b.GTRANSTYPEID=i.GTRANSACTIONTYPEID and
		b.sizeid=e.sizeid and
		B.countryid=g.countryid and
		b.Punitofmeasid=f.unitofmeasid AND
		(pBundleno is null or b.bundleno=pBundleno)
	Group by
		B.SHADE,b.PUNITOFMEASID,b.SIZEID,B.styleNO,
		e.sizename,f.unitofmeas,g.countryname,B.ORDERNO,B.countryid,b.spotRef,b.cuttingid,b.displayno
		having Sum(b.QUANTITY*GWF)>0
	order by btype,B.styleno,B.SHADE;
elsif pQueryType=8 then
	OPEN data_cursor  FOR
	Select
			'' AS bundleno,B.SHADE,getfncDispalyorder(b.ORDERNO) as btype,
			b.PUNITOFMEASID as punitid,b.SIZEID,B.styleno,b.cuttingid,b.displayno as cuttingno,
			e.sizename,f.unitofmeas as punit,g.countryname,B.ORDERNO,B.countryid,
			Sum(b.QUANTITY*FGS) as currentstock
	from
			T_GSTOCK a,
			T_GStockItems b,
			t_size e,
			t_unitofmeas f,
			t_country g,
			t_gtransactiontype i
	where
			a.STOCKID=b.STOCKID and
			b.GTRANSTYPEID=i.GTRANSACTIONTYPEID and
			b.sizeid=e.sizeid and
			B.countryid=g.countryid and
			b.Punitofmeasid=f.unitofmeasid AND
			(pBundleno is null or b.bundleno=pBundleno) and
			b.cuttingid is not null or b.cuttingid!=''
	Group by
			B.SHADE,b.PUNITOFMEASID,b.SIZEID,B.styleNO,
			e.sizename,f.unitofmeas,g.countryname,B.ORDERNO,B.countryid,b.cuttingid,b.displayno 
	having Sum(b.QUANTITY*FGS)>0
	order by btype,B.styleno,B.SHADE;
	elsif pQueryType=9 then
	OPEN data_cursor  FOR
	Select 		'' AS bundleno,'' AS lineno,B.SHADE,getfncDispalyorder(b.ORDERNO) as btype,b.PUNITOFMEASID as punitid,b.SIZEID,B.styleno,
			e.sizename,f.unitofmeas as punit,g.countryname,B.ORDERNO,B.countryid,Sum(b.QUANTITY*CTN) as currentstock
	from
			T_GSTOCK a,
			T_GStockItems b,
			t_size e,
			t_unitofmeas f,
			t_country g,
			t_gtransactiontype i
	where
			a.STOCKID=b.STOCKID and
			b.GTRANSTYPEID=i.GTRANSACTIONTYPEID and
			b.sizeid=e.sizeid and
			B.countryid=g.countryid and
			b.Punitofmeasid=f.unitofmeasid AND
			(pBundleno is null or b.bundleno=pBundleno)
	Group by
			B.SHADE,b.PUNITOFMEASID,b.SIZEID,B.styleNO,
			e.sizename,f.unitofmeas,g.countryname,B.ORDERNO,B.countryid
			having Sum(b.QUANTITY*CTN)>0 
			order by btype,B.styleno,B.SHADE;
	elsif pQueryType=10 then
	OPEN data_cursor  FOR
		Select 	5 AS GTRANSTYPE,'' AS bundleno,B.SHADE,getfncDispalyorder(b.ORDERNO) as btype,b.PUNITOFMEASID as punitid,b.SIZEID,B.styleno,b.cuttingid,b.displayno as cuttingno,
			e.sizename,f.unitofmeas as punit,g.countryname,B.ORDERNO,B.countryid,Sum(b.QUANTITY*CGSC) as currentstock,1 as GCPARTSID,'' AS GCUTTINGPARTS
	from
			T_GSTOCK a,
			T_GStockItems b,
			t_size e,
			t_unitofmeas f,
			t_country g,
			t_gtransactiontype i
	where
			a.STOCKID=b.STOCKID and
			b.GTRANSTYPEID=i.GTRANSACTIONTYPEID and
			b.sizeid=e.sizeid and
			B.countryid=g.countryid and
			b.Punitofmeasid=f.unitofmeasid AND
			(pBundleno is null or b.bundleno=pBundleno)
	Group by
			B.SHADE,b.PUNITOFMEASID,b.SIZEID,B.styleNO,
			e.sizename,f.unitofmeas,g.countryname,B.ORDERNO,B.countryid,b.cuttingid,b.displayno
			having Sum(b.QUANTITY*CGSC)>0
	UNION ALL		
	Select 	31 AS GTRANSTYPE,'' AS bundleno,B.SHADE,getfncDispalyorder(b.ORDERNO) as btype,b.PUNITOFMEASID as punitid,b.SIZEID,B.styleno,b.cuttingid,b.displayno as cuttingno,
			e.sizename,f.unitofmeas as punit,g.countryname,B.ORDERNO,B.countryid,Sum(b.QUANTITY*CGPSC) as currentstock,b.GCPARTSID,GCUTTINGPARTS
	from
			T_GSTOCK a,
			T_GStockItems b,
			t_size e,
			t_unitofmeas f,
			t_country g,
			t_gtransactiontype i,
			T_GCUTTINGPARTSLIST j
	where
			a.STOCKID=b.STOCKID and
			b.GTRANSTYPEID=i.GTRANSACTIONTYPEID and
			b.sizeid=e.sizeid and
			B.countryid=g.countryid and
			b.Punitofmeasid=f.unitofmeasid AND
			b.GCPARTSID=j.GCPARTSID and
			(pBundleno is null or b.bundleno=pBundleno)
	Group by
			B.SHADE,b.PUNITOFMEASID,b.SIZEID,B.styleNO,
			e.sizename,f.unitofmeas,g.countryname,B.ORDERNO,B.countryid,b.cuttingid,b.displayno,b.GCPARTSID,GCUTTINGPARTS
			having Sum(b.QUANTITY*CGPSC)>0
			order by cuttingno,btype,styleno,SHADE;
elsif pQueryType=11 then
	OPEN data_cursor  FOR
	Select
		'' as bundleno,B.SHADE,getfncDispalyorder(b.ORDERNO) as btype,b.PUNITOFMEASID as punitid,b.SIZEID,B.styleno,b.cuttingid,b.displayno as cuttingno,
		e.sizename,f.unitofmeas as punit,g.countryname,B.ORDERNO,B.countryid,B.PIECESTATUS  as statusid,DECODE(B.PIECESTATUS,0,'Non-Printed','Printed') as Pstatus, Sum(b.QUANTITY*CGS) as currentstock
	from
		T_GSTOCK a,
		T_GStockItems b,
		t_size e,
		t_unitofmeas f,
		t_country g,
		t_gtransactiontype i
	where
		a.STOCKID=b.STOCKID and
		b.GTRANSTYPEID=i.GTRANSACTIONTYPEID and
		b.sizeid=e.sizeid and
		B.countryid=g.countryid and
		b.Punitofmeasid=f.unitofmeasid and
		(pBundleno is null or b.bundleno=pBundleno)
	Group by
		B.SHADE,b.PUNITOFMEASID,b.SIZEID,B.styleNO,
		e.sizename,f.unitofmeas,g.countryname,B.ORDERNO,B.countryid,B.PIECESTATUS,b.cuttingid,b.displayno
		having Sum(b.QUANTITY*CGS)>0
	order by cuttingno,btype,B.styleno,B.SHADE,B.PIECESTATUS;
elsif pQueryType=12 then
	OPEN data_cursor  FOR
	Select
		'' AS  bundleno,B.LINENO,B.SHADE,getfncDispalyorder(b.ORDERNO) as btype,b.PUNITOFMEASID as punitid,
		b.SIZEID,B.styleno,e.sizename,f.unitofmeas as punit,g.countryname,B.ORDERNO,B.countryid,b.cuttingid,b.displayno as cuttingno,
		Sum(b.QUANTITY*CGSL) as currentstock
	from
		T_GSTOCK a,
		T_GStockItems b,
		t_size e,
		t_unitofmeas f,
		t_country g,
		t_gtransactiontype i
	where
		a.STOCKID=b.STOCKID and
		b.GTRANSTYPEID=i.GTRANSACTIONTYPEID and
		b.sizeid=e.sizeid and
		B.countryid=g.countryid and
		b.Punitofmeasid=f.unitofmeasid AND
                b.GTRANSTYPEID in(15,26) AND
		(pBundleno is null or b.bundleno=pBundleno)
	Group by
		B.SHADE,b.PUNITOFMEASID,b.SIZEID,B.styleNO,B.LINENO,
		e.sizename,f.unitofmeas,g.countryname,B.ORDERNO,B.countryid,b.cuttingid,b.displayno
		having Sum(b.QUANTITY*CGSL)>0
	order by cuttingno,btype,B.styleno,B.SHADE;
/*Update by Imran for insert display no*/
elsif pQueryType=13 then
	OPEN data_cursor  FOR
	Select
		'' as bundleno,B.SHADE,getfncDispalyorder(b.ORDERNO) as btype,b.PUNITOFMEASID as punitid,b.SIZEID,B.styleno,b.cuttingid,b.displayno as cuttingno,
		e.sizename,f.unitofmeas as punit,g.countryname,B.ORDERNO,B.countryid,B.PIECESTATUS  as statusid,DECODE(B.PIECESTATUS,0,'Non-Printed','Printed') as Pstatus, Sum(b.QUANTITY*CGS) as currentstock
	from
		T_GSTOCK a,
		T_GStockItems b,
		t_size e,
		t_unitofmeas f,
		t_country g,
		t_gtransactiontype i
	where
		a.STOCKID=b.STOCKID and
		b.GTRANSTYPEID=i.GTRANSACTIONTYPEID and
		b.sizeid=e.sizeid and
		B.countryid=g.countryid and
		b.Punitofmeasid=f.unitofmeasid and B.PIECESTATUS=0 and
		(pBundleno is null or b.bundleno=pBundleno)
	Group by
		B.SHADE,b.PUNITOFMEASID,b.SIZEID,B.styleNO,
		e.sizename,f.unitofmeas,g.countryname,B.ORDERNO,B.countryid,B.PIECESTATUS,b.cuttingid,b.displayno
		having Sum(b.QUANTITY*CGS)>0
	order by b.displayno,btype,B.styleno,B.SHADE,B.PIECESTATUS;
/*Poly garments pick up for CTN*/
elsif pQueryType=14 then
	OPEN data_cursor  FOR
	Select
			'' AS bundleno,B.SHADE,getfncDispalyorder(b.ORDERNO) as btype,
			b.PUNITOFMEASID as punitid,b.SIZEID,B.styleno,b.cuttingid,b.displayno as cuttingno,
			e.sizename,f.unitofmeas as punit,g.countryname,B.ORDERNO,B.countryid,
			Sum(b.QUANTITY*FGFD) as currentstock
	from
			T_GSTOCK a,
			T_GStockItems b,
			t_size e,
			t_unitofmeas f,
			t_country g,
			t_gtransactiontype i
	where
			a.STOCKID=b.STOCKID and
			b.GTRANSTYPEID=i.GTRANSACTIONTYPEID and
			b.sizeid=e.sizeid and
			B.countryid=g.countryid and
			b.Punitofmeasid=f.unitofmeasid AND
			(pBundleno is null or b.orderno=to_number(pBundleno)) and
			b.cuttingid is not null or b.cuttingid!=''
	Group by
			B.SHADE,b.PUNITOFMEASID,b.SIZEID,B.styleNO,
			e.sizename,f.unitofmeas,g.countryname,B.ORDERNO,B.countryid,b.cuttingid,b.displayno 
	having Sum(b.QUANTITY*FGFD)>0
	order by btype,B.styleno,B.SHADE;
	/*Poly garments pick up for Delivery Sample Garments Workorder*/
elsif pQueryType=15 then
	OPEN data_cursor  FOR
	Select
			'' AS bundleno,B.SHADE,getfncDispalyorder(b.ORDERNO) as btype,
			b.PUNITOFMEASID as punitid,b.SIZEID,B.styleno,'' AS cuttingid,'' as cuttingno,
			e.sizename,f.unitofmeas as punit,'' AS countryname,B.ORDERNO,'' AS countryid,
			Sum(b.QUANTITY*FGFD) as currentstock
	from
			T_GSTOCK a,
			T_GStockItems b,
			t_size e,
			t_unitofmeas f,
			t_gtransactiontype i
	where
			a.STOCKID=b.STOCKID and
			b.GTRANSTYPEID=i.GTRANSACTIONTYPEID and
			b.sizeid=e.sizeid and
			b.Punitofmeasid=f.unitofmeasid
	Group by
			B.SHADE,b.PUNITOFMEASID,b.SIZEID,B.styleNO,
			e.sizename,f.unitofmeas,B.ORDERNO
	having Sum(b.QUANTITY*FGFD)>0
	order by btype,B.styleno,B.SHADE;
END IF;
END GarmentsIssuetoSFPickup;
/


PROMPT CREATE OR REPLACE Procedure  373 :: GetGarmentRecvFromSFInfo
CREATE OR REPLACE Procedure GetGarmentRecvFromSFInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  many_cursor IN OUT pReturnData.c_Records,
  pGStockID number
)
AS
BEGIN

    open one_cursor for
    select StockId,ChallanNo, ChallanDate, StockTransNO, StockTransDATE,
    ClientID,Remarks, SubConId,Pono,GatepassNo,catid,PRODHOUR
    from T_GStock
    where StockId=pGStockID;

    open many_cursor for
  
 select T_GStockItems.ORDERNO,T_GStockItems.STOCKID,cuttingid,displayno as cuttingno,
    GSTOCKITEMSL,FabricTypeId,MAX(DECODE(GTRANSTYPEID,7,Quantity,0)) AS OKQTY,
    MAX(DECODE(GTRANSTYPEID,8,Quantity,0)) AS ALTERQTY,
   MAX(DECODE(GTRANSTYPEID,9,Quantity,0)) AS REJQTY,
   MAX(DECODE(GTRANSTYPEID,10,Quantity,0)) AS SPOTQTY,
   Squantity,PunitOfmeasId,SUNITOFMEASID,SIZEID,
   Shade,REMARKS,CurrentStock,subconid
    FabricDia,FabricGSM,Styleno,countryid,lineno,bundleno
    from T_GStockItems
    where STOCKID=pGStockID AND GTRANSTYPEID IN(7,8,9,10)
    GROUP BY T_GStockItems.ORDERNO,T_GStockItems.STOCKID,
    GSTOCKITEMSL,FabricTypeId,Squantity,PunitOfmeasId,SUNITOFMEASID,SIZEID,
    Shade,REMARKS,CurrentStock,subconid,
    FabricDia,FabricGSM,Styleno,lineno,cuttingid,bundleno,countryid,cuttingid,displayno
    order by GSTOCKITEMSL asc;
END GetGarmentRecvFromSFInfo;
/



PROMPT CREATE OR REPLACE Procedure  374 :: GetGarmentRecvFromIFInfo
CREATE OR REPLACE Procedure GetGarmentRecvFromIFInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  many_cursor IN OUT pReturnData.c_Records,
  pGStockID number
)
AS
BEGIN

    open one_cursor for
    select StockId,ChallanNo, ChallanDate, StockTransNO, StockTransDATE,
    ClientID,Remarks, SubConId,Pono,GatepassNo,catid,PRODHOUR
    from T_GStock
    where StockId=pGStockID;

    open many_cursor for
  
 select T_GStockItems.ORDERNO,T_GStockItems.STOCKID,
    GSTOCKITEMSL,FabricTypeId,MAX(DECODE(GTRANSTYPEID,14,Quantity,0)) AS OKQTY,
    MAX(DECODE(GTRANSTYPEID,15,Quantity,0)) AS ALTERQTY,
    MAX(DECODE(GTRANSTYPEID,16,Quantity,0)) AS REJQTY,
   MAX(DECODE(GTRANSTYPEID,17,Quantity,0)) AS SPOTQTY,
   Squantity,PunitOfmeasId,SUNITOFMEASID,SIZEID,
   Shade,REMARKS,CurrentStock,subconid
    FabricDia,FabricGSM,Styleno,countryid,lineno,bundleno
    from T_GStockItems
    where STOCKID=pGStockID AND GTRANSTYPEID IN(14,15,16,17)
    GROUP BY T_GStockItems.ORDERNO,T_GStockItems.STOCKID,
    GSTOCKITEMSL,FabricTypeId,Squantity,PunitOfmeasId,SUNITOFMEASID,SIZEID,
    Shade,REMARKS,CurrentStock,subconid,
FabricDia,FabricGSM,Styleno,lineno,cuttingid,bundleno,countryid
    order by GSTOCKITEMSL asc;

END GetGarmentRecvFromIFInfo;
/



PROMPT CREATE OR REPLACE Procedure  375 :: GetgSTOCKITEMUpdate
create or replace Procedure GetgSTOCKITEMUpdate
(
 pStockid in number,
 pItemsl IN NUMBER ,
PQty IN Number
)
AS
ID NUMBER;


BEGIN
select pid into id from t_gstockitems where stockid=pStockid and GSTOCKITEMSL=pItemsl and GTRANSTYPEID=7;

 Update T_gstockitems set Quantity=PQty where pid=id;
END GetgSTOCKITEMUpdate;
/



PROMPT CREATE OR REPLACE Procedure  376 :: GetgSTOCKITEMUpdateSPOT
create or replace Procedure GetgSTOCKITEMUpdateSPOT
(
 pStockid in number,
 pItemsl IN NUMBER ,
PQty IN Number
)
AS
ID NUMBER;


BEGIN
select pid into id from t_gstockitems where stockid=pStockid and GSTOCKITEMSL=pItemsl and GTRANSTYPEID=10;

 Update T_gstockitems set Quantity=PQty where pid=id;
END GetgSTOCKITEMUpdateSPOT;
/




PROMPT CREATE OR REPLACE Procedure  377 :: GetgSTOCKITEMUpdateALTER
create or replace Procedure GetgSTOCKITEMUpdateALTER
(
 pStockid in number,
 pItemsl IN NUMBER ,
PQty IN Number
)
AS
ID NUMBER;


BEGIN
select pid into id from t_gstockitems where stockid=pStockid and GSTOCKITEMSL=pItemsl and GTRANSTYPEID=8;

 Update T_gstockitems set Quantity=PQty where pid=id;
END GetgSTOCKITEMUpdateALTER;
/


PROMPT CREATE OR REPLACE Procedure  378 :: GetgSTOCKITEMUpdateREJECT
create or replace Procedure GetgSTOCKITEMUpdateREJECT
(
 pStockid in number,
 pItemsl IN NUMBER ,
PQty IN Number
)
AS
ID NUMBER;


BEGIN
select pid into id from t_gstockitems where stockid=pStockid and GSTOCKITEMSL=pItemsl and GTRANSTYPEID=9;

 Update T_gstockitems set Quantity=PQty where pid=id;
END GetgSTOCKITEMUpdateREJECT;
/

PROMPT CREATE OR REPLACE Procedure  379 :: GetgSTOCKITEMDELETE
create or replace Procedure GetgSTOCKITEMDELETE
(
 pStockid in number,
 pItemsl IN NUMBER 
)
AS
ID NUMBER;


BEGIN
 
 FOR REC IN(select pid from t_gstockitems where stockid=pStockid and GTRANSTYPEID IN(7,8,9,10) and GSTOCKITEMSL=pItemsl)
LOOP 
DELETE FROM T_gstockitems where pid=REC.PID;
END LOOP;

END GetgSTOCKITEMDELETE;
/



PROMPT CREATE OR REPLACE Procedure  380 :: GetgSTOCKITEMIRECVUpdate
create or replace Procedure GetgSTOCKITEMIRECVUpdate
(
pStockid in number,
 pItemsl IN NUMBER ,
PQty IN Number
)
AS
ID NUMBER;
BEGIN
select pid into id from t_gstockitems where stockid=pStockid and GSTOCKITEMSL=pItemsl and GTRANSTYPEID=14;

 Update T_gstockitems set Quantity=PQty where pid=id;

END GetgSTOCKITEMIRECVUpdate;
/


PROMPT CREATE OR REPLACE Procedure  381 :: GetgSTOCKITEMUpdateISPOT
create or replace Procedure GetgSTOCKITEMUpdateISPOT
(
 pStockid in number,
 pItemsl IN NUMBER ,
PQty IN Number
)
AS
ID NUMBER;


BEGIN
select pid into id from t_gstockitems where stockid=pStockid and GSTOCKITEMSL=pItemsl and GTRANSTYPEID=17;

 Update T_gstockitems set Quantity=PQty where pid=id;
END GetgSTOCKITEMUpdateISPOT;
/



PROMPT CREATE OR REPLACE Procedure  382 :: GetgSTOCKITEMUpdateIALTER
create or replace Procedure GetgSTOCKITEMUpdateIALTER
(
 pStockid in number,
 pItemsl IN NUMBER ,
PQty IN Number
)
AS
ID NUMBER;


BEGIN
select pid into id from t_gstockitems where stockid=pStockid and GSTOCKITEMSL=pItemsl and GTRANSTYPEID=15;

 Update T_gstockitems set Quantity=PQty where pid=id;
END GetgSTOCKITEMUpdateIALTER;
/

PROMPT CREATE OR REPLACE Procedure  383 :: GetgSTOCKITEMUpdateIREJECT
create or replace Procedure GetgSTOCKITEMUpdateIREJECT
(
 pStockid in number,
 pItemsl IN NUMBER ,
PQty IN Number
)
AS
ID NUMBER;


BEGIN
select pid into id from t_gstockitems where stockid=pStockid and GSTOCKITEMSL=pItemsl and GTRANSTYPEID=16;

 Update T_gstockitems set Quantity=PQty where pid=id;

END GetgSTOCKITEMUpdateIREJECT;
/

PROMPT CREATE OR REPLACE Procedure  384 :: GetIronSTOCKITEMDELETE
create or replace Procedure GetIronSTOCKITEMDELETE
(
 pStockid in number,
 pItemsl IN NUMBER 
)
AS
ID NUMBER;


BEGIN
 
 FOR REC IN(select pid from t_gstockitems where stockid=pStockid and GTRANSTYPEID IN(14,15,16,17) and GSTOCKITEMSL=pItemsl)
LOOP 
DELETE FROM T_gstockitems where pid=REC.PID;
END LOOP;

END GetIronSTOCKITEMDELETE;
/


PROMPT CREATE OR REPLACE Procedure  385 :: GarmentsDeliveryickup
CREATE OR REPLACE PROCEDURE GarmentsDeliveryickup(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pClient IN varchar2
)
AS
BEGIN
if pQueryType=1 then
	OPEN data_cursor  FOR
	Select getfncDispalyorder(a.ORDERNO) as Dorder,A.ORDERNO,
	    a.CTNTYPE,sum(a.CTNQTY-nvl((select sum(b.QUANTITY) from T_GDELIVERYCHALLANItems b where 
		  a.orderno=b.orderno and 
		  a.CTNTYPE=b.CTNTYPE group by b.ORDERNO,b.CTNTYPE),0)) as Quantity 		
	from T_GSTOCK a
	where /*a.orderno=pOrderno and	*/      
	      a.CATID=21
	group by A.ORDERNO,a.CTNTYPE
	having sum(a.CTNQTY-nvl((select sum(b.QUANTITY) from T_GDELIVERYCHALLANItems b where 
		  a.orderno=b.orderno and 
		  a.CTNTYPE=b.CTNTYPE group by b.ORDERNO,b.CTNTYPE),0))>0
	order by A.ORDERNO,a.CTNTYPE;
END IF;
END GarmentsDeliveryickup;
/	
PROMPT CREATE OR REPLACE Procedure  386 :: ExecuteCTNforDelivery
CREATE OR REPLACE Procedure ExecuteCTNforDelivery (
  pStockId in number,
  pOrderNo in number,
  pCtnType in varchar2,
  pQuantity in number,
  pRecsAffected out NUMBER
)
AS 
tmpctnid number; 
tmpcheck number;
tmpCount number;
tmpc number;
tmpc2 number;
BEGIN 
tmpCount:=0;
tmpc:=0;
pRecsAffected:=0;
   delete from T_gStockItems where StockId=pStockId and GTransTypeId=20;
   select CTNID into tmpctnid from T_CTN where ORDERNO=pOrderNo and CTNTYPE=pCtnType;
   for rec in(select SHADE,STYLE,SIZEID,QUANTITY  from T_CtnItems where CTNID=tmpctnid)
   Loop
		select decode(MAX(sum(QUANTITY)),null,0,1) into tmpCount from T_GStockItems where GTRANSTYPEID=24 and
		       SIZEID=rec.SIZEID and STYLENO=rec.STYLE and SHADE=rec.SHADE and ORDERNO=pOrderNo
			   group by SIZEID,STYLENO,SHADE,ORDERNO,GTRANSTYPEID
			   having sum(QUANTITY)>=(rec.QUANTITY*pQuantity);
			tmpc:=tmpCount+tmpc;  		    		
   End Loop;
   select NVL(max(count(*)),0) into tmpc2  from T_CtnItems where CTNID=tmpctnid
         group by CTNID;
   if(tmpc=tmpc2) then
		for rec1 in(select SHADE,STYLE,SIZEID,QUANTITY,PUNIT  from T_CtnItems where CTNID=tmpctnid)
		Loop
		 Insert into T_GStockItems(PID,GTransTypeId,StockId,GSTOCKITEMSL, Quantity,
		         OrderNo,PunitOfMeasId,Shade,styleno,sizeid) values
				 (SEQ_GStockItemID.NEXTVAL,20,pStockId,(select nvl(max(GSTOCKITEMSL),0)+1 from T_gStockItems where StockId=pStockId),
				 rec1.QUANTITY*pQuantity,pOrderNo,rec1.PUNIT,rec1.SHADE,rec1.STYLE,rec1.SIZEID);		
		End Loop;       
   else
       pRecsAffected:=99;
   End If;   
END ExecuteCTNforDelivery;
/  


PROMPT CREATE OR REPLACE Procedure  387 :: GetCodeWiseWOList

CREATE OR REPLACE PROCEDURE GetCodeWiseWOList(
  data_cursor IN OUT pReturnData.c_Records,   
  pOrdercode in varchar2
)
AS  
BEGIN

  if(pOrdercode='G' or pOrdercode='S') then
    OPEN data_cursor  FOR
		SELECT GORDERNO as ORDERNO,ORDERTYPEID||' '||GDORDERNO as BTYPE
		from T_Gworkorder where ORDERTYPEID=pOrdercode   
		order by GDORDERNO DESC; 
  elsif(pOrdercode='FG' or pOrdercode='FS' or pOrdercode='FC' or pOrdercode='SF') then
    OPEN data_cursor  FOR
		SELECT ORDERNO,BASICTYPEID||' '||DORDERNO as BTYPE
		from T_Workorder where BASICTYPEID=pOrdercode   
		order by DORDERNO  DESC; 
  End If;  
END GetCodeWiseWOList;
/

PROMPT CREATE OR REPLACE Procedure  388 :: CtnTypeList
CREATE or replace Procedure CtnTypeList
(
  data_cursor IN OUT pReturnData.c_Records,
  pOrderNo in number 
)
AS
BEGIN

  OPEN data_cursor for
   select CTNID,CTNType from T_CTN
     where orderno=pOrderNo;
END CtnTypeList;
/


PROMPT CREATE OR REPLACE Procedure  389 :: GarmentsMRRPickup
CREATE OR REPLACE PROCEDURE GarmentsMRRPickup(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  PClientid IN Varchar2
)
AS
BEGIN
if pQueryType=1 then
OPEN data_cursor  FOR
Select DISTINCT A.FABRICTYPEID,getfncWoBtype(b.ORDERNO) as Dorder,A.PUNITOFMEASID as punitid,A.SUNITOFMEASID as sunitid,A.SHADE,A.REMARKS,c.style as styleno,d.fabrictype,
C.GORDERNO as orderno,A.DBATCH as batchno,A.FINISHEDDIA as fabdia,A.FINISHEDGSM as gsm,F.UNITOFMEAS as punit,G.UNITOFMEAS as sunit,
(A.QUANTITY) AS qty,(A.SQUANTITY) as sqty           
from T_Dinvoice i,T_DINVOICEITEMs A,t_unitofmeas f,t_unitofmeas G,T_WORKORDER B,T_Gorderitems C,T_fabrictype d
where i.dinvoiceid=a.dinvoiceid and
A.Punitofmeasid=f.unitofmeasid(+) AND
A.Sunitofmeasid=G.unitofmeasid(+) AND
A.orderno=B.ORDERNO AND 
a.fabrictypeid=d.fabrictypeid and
B.GARMENTSORDERREF=C.GORDERNO and
I.INVOICENO=PClientid
order by c.style;

END IF;
END GarmentsMRRPickup;
/
PROMPT CREATE OR REPLACE Procedure  390 :: GetGarmentStockMRRInfo
CREATE OR REPLACE Procedure  GetGarmentStockMRRInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  many_cursor IN OUT pReturnData.c_Records,
  pGStockID number
)
AS
BEGIN

    open one_cursor for
    select StockId,ChallanNo, ChallanDate, StockTransNO, StockTransDATE,CUTPIECEREJECT,Jhute,
    ClientID,Remarks, SubConId,Pono,GatepassNo,catid,Fweight,CutWeight,EFFICIENCY,COMPLETE,PRODHOUR,
    GDORDERNO,orderno,CTNType,CtnQty,DELIVERYPLACE
    from T_GStock
    where StockId=pGStockID;

    open many_cursor for
    select PID,T_GStockItems.ORDERNO,T_GStockItems.STOCKID, FABWEIGHT,Reject, REQQUANTITY,getClientRef(T_GStockItems.ORDERNO) as ClientRef,
     GSTOCKITEMSL,FabricTypeId,Quantity,Squantity,PunitOfmeasId,SUNITOFMEASID,SIZEID,cuttingid,displayno as cuttingno,
     BatchNo,Shade,REMARKS,CurrentStock,subconid,FabricDia,FabricGSM,Styleno,GTRANSTYPEID,countryid,lineno,cuttingid,
     bundleno,orderlineitem,cartonno,GCPartsID
    from T_GStockItems
    where STOCKID=pGStockID
    order by GSTOCKITEMSL,lineno asc;
END GetGarmentStockMRRInfo;
/




PROMPT CREATE OR REPLACE Procedure  391 :: getTreeGStockList
CREATE OR REPLACE Procedure getTreeGStockList (
  io_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pStockType IN NUMBER,
  pTransNo IN VARCHAR2 DEFAULT NULL,
  sDate IN date,
  eDate IN date
)
AS
BEGIN
/* Invoice No */
  if pQueryType=0 then
    OPEN io_cursor FOR
    select A.StockId, A.StockTransNo,to_number(A.StockTransNo) as stockno from T_GStock A 
    where a.catid=pStockType AND
    StockTransDate>=SDate and StockTransDate<=EDate
    order by (stockno) desc;

	/* Invoice Date */
  elsif pQueryType=1 then
    OPEN io_cursor FOR    
    select A.StockId, A.StockTransNo,A.StockTransDate,to_number(A.StockTransNo) as stockno from T_GStock A 
    where a.catid=pStockType AND
    StockTransDate>=SDate and StockTransDate<=EDate
    order by StockTransDate desc, stockno desc;
	
	/* Cutting No */
  elsif pQueryType=2 then
    OPEN io_cursor FOR    
    select to_Number(b.CuttingID) as CuttingNo,getDisplayCuttingNo(b.cuttingID) as DCuttingNo
	from T_GStock a, T_GstockItems b
    where a.stockid=b.stockid and
	a.catid=pStockType AND	
    a.StockTransDate>=SDate and a.StockTransDate<=EDate
	group by b.CuttingID
    order by to_Number(getDisplayCuttingNo(b.cuttingId)) desc;
	
	/* GORDERNO */
 elsif pQueryType=3 then
    OPEN io_cursor FOR    
    select to_Number(b.ORDERNO) as ORDERNO,getfncDispalyorder(b.ORDERNO) as GORDERNO
	from T_GStock a, T_GstockItems b
    where a.stockid=b.stockid and
	a.catid=pStockType AND	
    a.StockTransDate>=SDate and a.StockTransDate<=EDate
	group by b.ORDERNO
    order by getfncDispalyorder(b.ORDERNO) desc;
	
	/* Combo Fillup Assecndig*/
  elsif pQueryType=9999 then
    OPEN io_cursor FOR
    select StockId from T_GStock
    where  StockTransDate>=SDate and StockTransDate<=EDate and
    Upper(StockTransNo) Like pTransNo;
  end if;

END getTreeGStockList;
/


PROMPT CREATE OR REPLACE Procedure  392 :: CuttingWiseTransaction
create or Replace Procedure CuttingWiseTransaction(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pCuttingno NUMBER,
  sDate IN date,
  eDate IN date
)
AS
BEGIN
/*Cutting Parts Send to Print or Embroidary*/
if (pQueryType=1) then
    open data_cursor for
    select a.StockID,a.STOCKTRANSNO,a.STOCKTRANSDATE,a.CHALLANNO,a.CHALLANDATE,
	    getfncDispalyorder(b.ORDERNO) as ORDERNO,c.SIZENAME,b.STYLENO as STYLE,
        b.SHADE,b.QUANTITY,d.UNITOFMEAS as UNIT		
	from T_GStock a, T_GstockItems b,T_Size c,T_Unitofmeas d	 	
    where	a.StockID=b.StockID and
	        b.CUTTINGID=pCuttingno	and
			a.STOCKTRANSDATE between sDate and eDate AND
			a.catid=15 and
			b.SIZEID=c.SIZEID and
			b.PUNITOFMEASID=d.UNITOFMEASID
    ORDER BY a.STOCKTRANSNO,a.STOCKTRANSDATE,getfncDispalyorder(b.ORDERNO),c.SIZENAME,b.STYLENO,
        b.SHADE;
/*Cutting Parts Received from Print or Embroidary*/
elsif (pQueryType=2) then
    open data_cursor for
    select a.StockID,a.STOCKTRANSNO,a.STOCKTRANSDATE,a.CHALLANNO,a.CHALLANDATE,
	    getfncDispalyorder(b.ORDERNO) as ORDERNO,c.SIZENAME,b.STYLENO as STYLE,
        b.SHADE,b.QUANTITY,d.UNITOFMEAS as UNIT		
	from T_GStock a, T_GstockItems b,T_Size c,T_Unitofmeas d	 	
    where	a.StockID=b.StockID and
	        b.CUTTINGID=pCuttingno	and
			a.STOCKTRANSDATE between sDate and eDate AND
			a.catid=16 and
			b.SIZEID=c.SIZEID and
			b.PUNITOFMEASID=d.UNITOFMEASID
    ORDER BY a.STOCKTRANSNO,a.STOCKTRANSDATE,getfncDispalyorder(b.ORDERNO),c.SIZENAME,b.STYLENO,
        b.SHADE;
elsif (pQueryType=3) then
    open data_cursor for
    select a.StockID,a.STOCKTRANSNO,a.STOCKTRANSDATE,a.CHALLANNO,a.CHALLANDATE,
	    getfncDispalyorder(b.ORDERNO) as ORDERNO,c.SIZENAME,b.STYLENO as STYLE,
        b.SHADE,b.QUANTITY,d.UNITOFMEAS as UNIT		
	from T_GStock a, T_GstockItems b,T_Size c,T_Unitofmeas d	 	
    where	a.StockID=b.StockID and
	        b.CUTTINGID=pCuttingno	and
			a.STOCKTRANSDATE between sDate and eDate AND
			a.catid=5 and
			b.SIZEID=c.SIZEID and
			b.PUNITOFMEASID=d.UNITOFMEASID
    ORDER BY a.STOCKTRANSNO,a.STOCKTRANSDATE,getfncDispalyorder(b.ORDERNO),c.SIZENAME,b.STYLENO,
        b.SHADE;
elsif (pQueryType=4) then
    open data_cursor for
    select a.StockID,a.STOCKTRANSNO,a.STOCKTRANSDATE,a.CHALLANNO,a.CHALLANDATE,
	    getfncDispalyorder(b.ORDERNO) as ORDERNO,c.SIZENAME,b.STYLENO as STYLE,
        b.SHADE,b.QUANTITY,d.UNITOFMEAS as UNIT		
	from T_GStock a, T_GstockItems b,T_Size c,T_Unitofmeas d	 	
    where	a.StockID=b.StockID and
	        b.CUTTINGID=pCuttingno	and
			a.STOCKTRANSDATE between sDate and eDate AND
			a.catid=6 and
			b.SIZEID=c.SIZEID and
			b.PUNITOFMEASID=d.UNITOFMEASID
    ORDER BY a.STOCKTRANSNO,a.STOCKTRANSDATE,getfncDispalyorder(b.ORDERNO),c.SIZENAME,b.STYLENO,
        b.SHADE;
elsif (pQueryType=5) then
    open data_cursor for
    select a.StockID,a.STOCKTRANSNO,a.STOCKTRANSDATE,a.CHALLANNO,a.CHALLANDATE,
	    getDisplayCuttingNo(b.cuttingID) as ORDERNO,c.SIZENAME,b.STYLENO as STYLE,
        b.SHADE,b.QUANTITY,d.UNITOFMEAS as UNIT		
	from T_GStock a, T_GstockItems b,T_Size c,T_Unitofmeas d	 	
    where	a.StockID=b.StockID and
	        b.ORDERNO=pCuttingno	and  /* pCuttingno Like as Order No */
			a.STOCKTRANSDATE between sDate and eDate AND
			a.catid=15 and
			b.SIZEID=c.SIZEID and
			b.PUNITOFMEASID=d.UNITOFMEASID
    ORDER BY a.STOCKTRANSNO,a.STOCKTRANSDATE,getfncDispalyorder(b.ORDERNO),c.SIZENAME,b.STYLENO,
        b.SHADE;
elsif (pQueryType=6) then
    open data_cursor for
    select a.StockID,a.STOCKTRANSNO,a.STOCKTRANSDATE,a.CHALLANNO,a.CHALLANDATE,
	    getDisplayCuttingNo(b.cuttingID) as ORDERNO,c.SIZENAME,b.STYLENO as STYLE,
        b.SHADE,b.QUANTITY,d.UNITOFMEAS as UNIT		
	from T_GStock a, T_GstockItems b,T_Size c,T_Unitofmeas d	 	
    where	a.StockID=b.StockID and
	        b.ORDERNO=pCuttingno	and  /* pCuttingno Like as Order No */
			a.STOCKTRANSDATE between sDate and eDate AND
			a.catid=5 and
			b.SIZEID=c.SIZEID and
			b.PUNITOFMEASID=d.UNITOFMEASID
    ORDER BY a.STOCKTRANSNO,a.STOCKTRANSDATE,getfncDispalyorder(b.ORDERNO),c.SIZENAME,b.STYLENO,
        b.SHADE;
elsif (pQueryType=7) then
    open data_cursor for
    select a.StockID,a.STOCKTRANSNO,a.STOCKTRANSDATE,a.CHALLANNO,a.CHALLANDATE,
	    getDisplayCuttingNo(b.cuttingID) as ORDERNO,c.SIZENAME,b.STYLENO as STYLE,
        b.SHADE,b.QUANTITY,d.UNITOFMEAS as UNIT		
	from T_GStock a, T_GstockItems b,T_Size c,T_Unitofmeas d	 	
    where	a.StockID=b.StockID and
	        b.ORDERNO=pCuttingno	and  /* pCuttingno Like as Order No */
			a.STOCKTRANSDATE between sDate and eDate AND
			a.catid=6 and
			b.SIZEID=c.SIZEID and
			b.PUNITOFMEASID=d.UNITOFMEASID
    ORDER BY a.STOCKTRANSNO,a.STOCKTRANSDATE,getfncDispalyorder(b.ORDERNO),c.SIZENAME,b.STYLENO,
        b.SHADE;
elsif (pQueryType=8) then
    open data_cursor for
    select a.StockID,a.STOCKTRANSNO,a.STOCKTRANSDATE,a.CHALLANNO,a.CHALLANDATE,
	    getDisplayCuttingNo(b.cuttingID) as ORDERNO,c.SIZENAME,b.STYLENO as STYLE,
        b.SHADE,b.QUANTITY,d.UNITOFMEAS as UNIT		
	from T_GStock a, T_GstockItems b,T_Size c,T_Unitofmeas d	 	
    where	a.StockID=b.StockID and
	        b.ORDERNO=pCuttingno	and  /* pCuttingno Like as Order No */
			a.STOCKTRANSDATE between sDate and eDate AND
			a.catid=7 and
			b.SIZEID=c.SIZEID and
			b.PUNITOFMEASID=d.UNITOFMEASID
    ORDER BY a.STOCKTRANSNO,a.STOCKTRANSDATE,getfncDispalyorder(b.ORDERNO),c.SIZENAME,b.STYLENO,
        b.SHADE;
elsif (pQueryType=9) then
    open data_cursor for
    select a.StockID,a.STOCKTRANSNO,a.STOCKTRANSDATE,a.CHALLANNO,a.CHALLANDATE,
	    getDisplayCuttingNo(b.cuttingID) as ORDERNO,c.SIZENAME,b.STYLENO as STYLE,
        b.SHADE,b.QUANTITY,d.UNITOFMEAS as UNIT		
	from T_GStock a, T_GstockItems b,T_Size c,T_Unitofmeas d	 	
    where	a.StockID=b.StockID and
	        b.ORDERNO=pCuttingno	and  /* pCuttingno Like as Order No */
			a.STOCKTRANSDATE between sDate and eDate AND
			a.catid=8 and
			b.SIZEID=c.SIZEID and
			b.PUNITOFMEASID=d.UNITOFMEASID and b.QUANTITY>0
    ORDER BY a.STOCKTRANSNO,a.STOCKTRANSDATE,getfncDispalyorder(b.ORDERNO),c.SIZENAME,b.STYLENO,
		b.SHADE;
elsif (pQueryType=10) then
    open data_cursor for
    select a.StockID,a.STOCKTRANSNO,a.STOCKTRANSDATE,a.CHALLANNO,a.CHALLANDATE,
	    getDisplayCuttingNo(b.cuttingID) as ORDERNO,c.SIZENAME,b.STYLENO as STYLE,
        b.SHADE,b.QUANTITY,d.UNITOFMEAS as UNIT		
	from T_GStock a, T_GstockItems b,T_Size c,T_Unitofmeas d	 	
    where	a.StockID=b.StockID and
	        b.ORDERNO=pCuttingno	and  /* pCuttingno Like as Order No */
			a.STOCKTRANSDATE between sDate and eDate AND
			a.catid=12 and
			b.SIZEID=c.SIZEID and
			b.PUNITOFMEASID=d.UNITOFMEASID
    ORDER BY a.STOCKTRANSNO,a.STOCKTRANSDATE,getfncDispalyorder(b.ORDERNO),c.SIZENAME,b.STYLENO,
        b.SHADE;
elsif (pQueryType=11) then
    open data_cursor for
select a.StockID,a.STOCKTRANSNO,a.STOCKTRANSDATE,a.CHALLANNO,a.CHALLANDATE,
	    getDisplayCuttingNo(b.cuttingID) as ORDERNO,'' as SIZENAME,b.STYLENO as STYLE,
        b.SHADE,b.QUANTITY,d.UNITOFMEAS as UNIT		
	from T_GStock a, T_GstockItems b,T_Unitofmeas d	 	
    where	a.StockID=b.StockID and
	        b.ORDERNO=pCuttingno	and  /* pCuttingno Like as Order No */
			a.STOCKTRANSDATE between sDate and eDate AND
			a.catid=1 and
			b.PUNITOFMEASID=d.UNITOFMEASID
    ORDER BY a.STOCKTRANSNO,a.STOCKTRANSDATE,getfncDispalyorder(b.ORDERNO),b.STYLENO,
        b.SHADE;
elsif (pQueryType=12) then
    open data_cursor for
    select a.StockID,a.STOCKTRANSNO,a.STOCKTRANSDATE,a.CHALLANNO,a.CHALLANDATE,
	    getDisplayCuttingNo(b.cuttingID) as ORDERNO,'' as SIZENAME,b.STYLENO as STYLE,
        b.SHADE,b.QUANTITY,d.UNITOFMEAS as UNIT		
	from T_GStock a, T_GstockItems b,T_Unitofmeas d	 	
    where	a.StockID=b.StockID and
	        b.ORDERNO=pCuttingno	and  /* pCuttingno Like as Order No */
			a.STOCKTRANSDATE between sDate and eDate AND
			a.catid=17 and			
			b.PUNITOFMEASID=d.UNITOFMEASID
    ORDER BY a.STOCKTRANSNO,a.STOCKTRANSDATE,getfncDispalyorder(b.ORDERNO),b.STYLENO,
        b.SHADE;
elsif (pQueryType=13) then
    open data_cursor for
    select a.StockID,a.STOCKTRANSNO,a.STOCKTRANSDATE,a.CHALLANNO,a.CHALLANDATE,
	    getDisplayCuttingNo(b.cuttingID) as ORDERNO,'' as SIZENAME,b.STYLENO as STYLE,
        b.SHADE,b.QUANTITY,d.UNITOFMEAS as UNIT		
	from T_GStock a, T_GstockItems b,T_Unitofmeas d	 	
    where	a.StockID=b.StockID and
	        b.ORDERNO=pCuttingno	and  /* pCuttingno Like as Order No */
			a.STOCKTRANSDATE between sDate and eDate AND
			a.catid=2 and			
			b.PUNITOFMEASID=d.UNITOFMEASID
    ORDER BY a.STOCKTRANSNO,a.STOCKTRANSDATE,getfncDispalyorder(b.ORDERNO),b.STYLENO,
        b.SHADE;
elsif (pQueryType=14) then
    open data_cursor for
    select a.StockID,a.STOCKTRANSNO,a.STOCKTRANSDATE,a.CHALLANNO,a.CHALLANDATE,
	    getDisplayCuttingNo(b.cuttingID) as ORDERNO,'' as SIZENAME,b.STYLENO as STYLE,
        b.SHADE,b.QUANTITY,d.UNITOFMEAS as UNIT		
	from T_GStock a, T_GstockItems b,T_Unitofmeas d	 	
    where	a.StockID=b.StockID and
	        b.ORDERNO=pCuttingno	and  /* pCuttingno Like as Order No */
			a.STOCKTRANSDATE between sDate and eDate AND
			a.catid=3 and			
			b.PUNITOFMEASID=d.UNITOFMEASID
    ORDER BY a.STOCKTRANSNO,a.STOCKTRANSDATE,getfncDispalyorder(b.ORDERNO),b.STYLENO,
        b.SHADE;
elsif (pQueryType=15) then
    open data_cursor for
    select a.StockID,a.STOCKTRANSNO,a.STOCKTRANSDATE,a.CHALLANNO,a.CHALLANDATE,
	    getDisplayCuttingNo(b.cuttingID) as ORDERNO,c.SIZENAME,b.STYLENO as STYLE,
        b.SHADE,b.QUANTITY,d.UNITOFMEAS as UNIT		
	from T_GStock a, T_GstockItems b,T_Size c,T_Unitofmeas d	 	
    where	a.StockID=b.StockID and
	        b.ORDERNO=pCuttingno	and  /* pCuttingno Like as Order No */
			a.STOCKTRANSDATE between sDate and eDate AND
			a.catid=4 and
			b.SIZEID=c.SIZEID and
			b.PUNITOFMEASID=d.UNITOFMEASID
    ORDER BY a.STOCKTRANSNO,a.STOCKTRANSDATE,getfncDispalyorder(b.ORDERNO),c.SIZENAME,b.STYLENO,
        b.SHADE;
elsif (pQueryType=16) then
    open data_cursor for
    select a.StockID,a.STOCKTRANSNO,a.STOCKTRANSDATE,a.CHALLANNO,a.CHALLANDATE,
	    getDisplayCuttingNo(b.cuttingID) as ORDERNO,c.SIZENAME,b.STYLENO as STYLE,
        b.SHADE,b.QUANTITY,d.UNITOFMEAS as UNIT		
	from T_GStock a, T_GstockItems b,T_Size c,T_Unitofmeas d	 	
    where	a.StockID=b.StockID and
	        b.ORDERNO=pCuttingno	and  /* pCuttingno Like as Order No */
			a.STOCKTRANSDATE between sDate and eDate AND
			a.catid=16 and
			b.SIZEID=c.SIZEID and
			b.PUNITOFMEASID=d.UNITOFMEASID
    ORDER BY a.STOCKTRANSNO,a.STOCKTRANSDATE,getfncDispalyorder(b.ORDERNO),c.SIZENAME,b.STYLENO,
        b.SHADE;
elsif (pQueryType=17) then
    open data_cursor for
    select a.StockID,a.STOCKTRANSNO,a.STOCKTRANSDATE,a.CHALLANNO,a.CHALLANDATE,
	    getDisplayCuttingNo(b.cuttingID) as ORDERNO,c.SIZENAME,b.STYLENO as STYLE,
        b.SHADE,b.QUANTITY,d.UNITOFMEAS as UNIT		
	from T_GStock a, T_GstockItems b,T_Size c,T_Unitofmeas d	 	
    where	a.StockID=b.StockID and
	        b.ORDERNO=pCuttingno	and  /* pCuttingno Like as Order No */
			a.STOCKTRANSDATE between sDate and eDate AND
			a.catid=21 and
			b.SIZEID=c.SIZEID and
			b.PUNITOFMEASID=d.UNITOFMEASID
    ORDER BY a.STOCKTRANSNO,a.STOCKTRANSDATE,getfncDispalyorder(b.ORDERNO),c.SIZENAME,b.STYLENO,
        b.SHADE;
End If;
END CuttingWiseTransaction;
/


PROMPT CREATE OR REPLACE Procedure  393 :: GetAuxNameLookUp
CREATE or replace Procedure GetAuxNameLookUp
(
  data_cursor IN OUT pReturnData.c_Records,
  pQtype in number,
  pAuxType in number  
)
AS
BEGIN
/*if the Value is 0 then retun all Dyes data */
if pQtype=0 then
  OPEN data_cursor for
   select AUXID,AUXNAME
	from t_auxiliaries where AUXTYPEID=2 and  (pAuxType=0 or DYEBASEID=pAuxType) order by AUXNAME;
/*If the Value is 1 then retun chemical and misc data */
elsif pQtype=1 then
  OPEN data_cursor for
  select AUXID,AUXNAME
	from t_auxiliaries where AUXTYPEID=pAuxType order by AUXNAME;
end if;
END GetAuxNameLookUp;
/


PROMPT CREATE OR REPLACE Procedure  394 :: getTreeChallanList
CREATE OR REPLACE Procedure getTreeChallanList (
  io_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pDelOrderTypeID IN VARCHAR2,
  pStockType IN NUMBER,  
  sDate IN date,
  eDate IN date
)
AS
BEGIN
  if pQueryType=0 then
    OPEN io_cursor FOR
    select Invoiceid, Invoiceno,to_number(Invoiceno) as invono from T_GDELIVERYCHALLAN
    where catid=pStockType AND 
	DELORDERTYPEID=pDelOrderTypeID AND
    InvoiceDate>=SDate and InvoiceDate<=EDate
    order by (invono) desc;

  elsif pQueryType=1 then
    OPEN io_cursor FOR    
    select Invoiceid, Invoiceno,InvoiceDate,to_number(Invoiceno) as invono from T_GDELIVERYCHALLAN
    where catid=pStockType AND
    InvoiceDate>=SDate and InvoiceDate<=EDate
    order by InvoiceDate desc, invono desc;

elsif pQueryType=2 then
    OPEN io_cursor FOR
	select to_Number(b.ORDERNO) as ORDERNO,getfncDispalyorder(b.ORDERNO) as GORDERNO
	from T_GDELIVERYCHALLAN a, T_GDELIVERYCHALLANItems b
    where a.Invoiceid=b.Invoiceid and
	a.catid=pStockType AND	
	DELORDERTYPEID=pDelOrderTypeID AND
    InvoiceDate>=SDate and InvoiceDate<=EDate
	group by b.ORDERNO
    order by getfncDispalyorder(b.ORDERNO) desc;
	
/* Combo Fillup Assecndig*/
  elsif pQueryType=9999 then
    OPEN io_cursor FOR
    select Invoiceid from T_GDELIVERYCHALLAN
    where  InvoiceDate>=SDate and InvoiceDate<=EDate;
  end if;
END getTreeChallanList;
/


PROMPT CREATE OR REPLACE Procedure  395 :: getTreeGFabReqStockList
CREATE OR REPLACE Procedure getTreeGFabReqStockList (
  io_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pStockType IN NUMBER,
  pTransNo IN VARCHAR2 DEFAULT NULL,
  sDate IN date,
  eDate IN date
)
AS
BEGIN

  if pQueryType=0 then
    OPEN io_cursor FOR
    select StockId, StockTransNo from T_GFabricReq
    where StockTransDate>=SDate and StockTransDate<=EDate and reqtype=pStockType
    order by to_number(StockTransNo) desc;

  elsif pQueryType=1 then
    OPEN io_cursor FOR
    select StockId, StockTransNo, StockTransDate from T_GFabricReq
    where StockTransDate>=SDate and StockTransDate<=EDate and reqtype=pStockType
    order by StockTransDate desc, to_number(StockTransNo) desc;  
  end if;

END getTreeGFabReqStockList ;
/

PROMPT CREATE OR REPLACE Procedure  396 :: GetFabricIssuetoCF
CREATE OR REPLACE Procedure GetFabricIssuetoCF(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pKnitTranTypeID NUMBER,
  pStockDate DATE
)
AS
BEGIN
        /* GMS*/
    if pQueryType=1 then
    open data_cursor for
    select a.ORDERNO,getfncDispalyorder(a.ORDERNO) as Dorder,a.STOCKID,a.FabricTypeId,a.PunitOfmeasId,a.SUNITOFMEASID as sunitid,f.unitofmeas as punit,g.unitofmeas as sunit,d.fabrictype,
    a.BatchNo,a.Shade,a.REMARKS,a.FabricDia,a.FabricGSM,a.Styleno,B.subconid,h.SUBCONNAME,sum(Quantity) CurrentStock,sum(SQuantity) Cursqty
    from T_GFabricReqItems a,T_GFabricReq b,T_GFabricReqType c,T_fabrictype d,T_UnitOfMeas f,T_UnitOfMeas g,T_subcontractors h
    where  a.StockID=b.StockID and
    a.GFabricReqTypeId=c.GFabricReqTypeId and
    a.fabrictypeid=d.fabrictypeid and
    a.PUnitOfMeasID=f.UnitOfMeasID(+)  and
    a.SUnitOfMeasID=g.UnitOfMeasID(+)  and
    B.subconid=h.subconid and
    B.EXECUTE<>1 AND
    STOCKTRANSDATE <= pStockDate
    group by a.ORDERNO,a.STOCKID,a.FabricTypeId,a.PunitOfmeasId,a.SUNITOFMEASID,f.unitofmeas,g.unitofmeas,d.fabrictype,
    a.BatchNo,a.Shade,a.REMARKS,a.FabricDia,a.FabricGSM,a.Styleno,B.subconid,h.SUBCONNAME
    having sum(Quantity)>0 order by a.orderno asc;

elsif pQueryType=2 then
    open data_cursor for
    select a.ORDERNO,getfncDispalyorder(a.ORDERNO) as Dorder,a.FabricTypeId,a.PunitOfmeasId,a.SUNITOFMEASID as sunitid,f.unitofmeas as punit,g.unitofmeas as sunit,d.fabrictype,
    a.BatchNo,a.Shade,a.REMARKS,a.FabricDia,a.FabricGSM,a.Styleno,a.subconid,h.SUBCONNAME,sum(Quantity*GFCF) CurrentStock,sum(SQuantity*GFCF) Cursqty
    from T_GStockItems a,T_Gstock b,T_GTransactionType c,T_fabrictype d,T_UnitOfMeas f,T_UnitOfMeas g,T_subcontractors h
    where  a.StockID=b.StockID and   
    a.GTRANSTYPEID=c.GTRANSACTIONTYPEID and
    a.fabrictypeid=d.fabrictypeid and
    a.PUnitOfMeasID=f.UnitOfMeasID(+)  and
    a.SUnitOfMeasID=g.UnitOfMeasID(+) AND
    a.subconid=h.subconid AND
    STOCKTRANSDATE <= pStockDate
    group by a.ORDERNO,a.FabricTypeId,a.PunitOfmeasId,a.SUNITOFMEASID,f.unitofmeas,g.unitofmeas,d.fabrictype,
    a.BatchNo,a.Shade,a.REMARKS,a.FabricDia,a.FabricGSM,a.Styleno,a.subconid,h.SUBCONNAME
    having sum(Quantity*GFCF)>0 order by a.orderno asc;

end if;
End GetFabricIssuetoCF;
/



PROMPT CREATE OR REPLACE Procedure  397 :: GetGFabstock
CREATE OR REPLACE Procedure GetGFabstock(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pKnitTranTypeID NUMBER,  
  pStockDate DATE
)
AS
BEGIN
        /* GMS*/
    if pQueryType=1 then
    open data_cursor for
    select a.ORDERNO,a.FabricTypeId,getfncDispalyorder(a.ORDERNO) as Dorder,a.PunitOfmeasId,a.SUNITOFMEASID as sunitid,f.unitofmeas as punit,g.unitofmeas as sunit,d.fabrictype,
    a.BatchNo,a.Shade,a.REMARKS,a.FabricDia,a.FabricGSM,a.Styleno,sum(Quantity*GMS) CurrentStock,sum(SQuantity*GMS) Cursqty
    from T_GStockItems a,T_Gstock b,T_GTransactionType c,T_fabrictype d,T_UnitOfMeas f,T_UnitOfMeas g
    where  a.StockID=b.StockID and
    a.GTRANSTYPEID=c.GTRANSACTIONTYPEID and
    a.fabrictypeid=d.fabrictypeid and
    a.PUnitOfMeasID=f.UnitOfMeasID(+)  and
    a.SUnitOfMeasID=g.UnitOfMeasID(+) AND
    STOCKTRANSDATE <= pStockDate
    group by a.ORDERNO,a.FabricTypeId,a.PunitOfmeasId,a.SUNITOFMEASID,f.unitofmeas,g.unitofmeas,d.fabrictype,
    a.BatchNo,a.Shade,a.REMARKS,a.FabricDia,a.FabricGSM,a.Styleno
    having sum(Quantity*GMS)>0 order by a.orderno asc;    
    
end if;
End GetGFabstock;
/

PROMPT CREATE OR REPLACE Procedure  398 :: GetGFabReqInfo
Create or Replace Procedure GetGFabReqInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  many_cursor IN OUT pReturnData.c_Records,
  pGStockID number
)
AS
BEGIN

    open one_cursor for
    select StockId, StockTransNO, StockTransDATE,
    Remarks, SubConId,Reqtype,EXECUTE
    from T_GFabricReq where StockId=pGStockID;

    open many_cursor for
    select PID,a.ORDERNO,a.STOCKID,
    GSTOCKITEMSL,FabricTypeId,Quantity,Squantity,PunitOfmeasId,SUNITOFMEASID,LINENO,COUNTRYID,BUNDLENO,SIZEID,
    BatchNo,Shade,REMARKS,CurrentStock,subconid,FabricDia,FabricGSM,Styleno, GFABRICREQTYPEID,cuttingid,cuttingno(cuttingid) as cuttingno
    from T_GFabricReqItems a
    where STOCKID=pGStockID
    order by GSTOCKITEMSL asc;
END GetGFabReqInfo;
/
PROMPT CREATE OR REPLACE Procedure  399 :: ProductionHourLookup
CREATE OR REPLACE Procedure ProductionHourLookup
(
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN

  OPEN data_cursor for
  select HID,Description from T_ProductionHOur ORDER BY Hid;

END ProductionHourLookup;
/

PROMPT CREATE OR REPLACE Procedure  400 :: GetGOrderLineItemList
CREATE OR REPLACE Procedure GetGOrderLineItemList
(
  data_cursor IN OUT pReturnData.c_Records,
  pStatus number,
  pClientid Varchar2,
  pStockDate DATE
)
AS
BEGIN
/*if the Value is 0 then retun all the Data */
if pStatus=1 then
open data_cursor for
	select	a.ORDERNO as GOrderNO,a.FabricTypeId,d.fabrictype,getfncDispalyorder(a.ORDERNO) as btype,
    	a.Shade,a.Styleno as style,'' as Countryid, '' as Countryname,'' as ORDERLINEITEM,
		sum(Quantity*GFCF) CurrentStock,0 as cursqty
    from
		T_GStockItems a,
		T_Gstock b,
		T_GTransactionType c,
		T_fabrictype d
    where
		a.StockID=b.StockID and
   		a.GTRANSTYPEID=c.GTRANSACTIONTYPEID and
    	a.fabrictypeid=d.fabrictypeid AND
		b.complete<>1 AND
		a.ORDERNO>0
    group by
		a.ORDERNO,a.FabricTypeId,a.PunitOfmeasId,d.fabrictype,
    	a.Shade,a.Styleno
    	Having sum(Quantity*GFCF)>0 
		order by a.orderno DESC;
end if;
END GetGOrderLineItemList;
/


PROMPT CREATE OR REPLACE Procedure  401 :: GetOrderClientInfo
CREATE OR REPLACE Procedure GetOrderClientInfo
(
  pStatus number,
  pOrderno Number,
  data_cursor IN OUT pReturnData.c_Records
)

AS

BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=0 then
  OPEN data_cursor for
    select 
			a.CLIENTID, a.CLIENTNAME,a.CLIENTSTATUSID,getfncDispalyorder(b.GORDERNO) AS DORDERNO,b.Gorderno,
			a.CADDRESS,a.CFACTORYADDRESS,a.CTELEPHONE,
			a.CFAX,a.CEMAIL,a.CURL,a.CCONTACTPERSON, a.CACCCODE,
			a.CREMARKS,a.CLIENTGROUPID  
	from 	
			T_Client a,
			T_Gworkorder b
	Where 
			b.clientid=a.clientid(+) 
	order by 
			DORDERNO;
/*If the Value is 1 then retun as the */
end if;
END GetOrderClientInfo;
/




PROMPT CREATE OR REPLACE Procedure  402 :: AlliedCustomerInfo
CREATE OR REPLACE Procedure AlliedCustomerInfo
(
  one_cursor IN OUT pReturnData.c_Records, 
  pWhereValue number
)
AS
BEGIN
    open one_cursor for
    Select customerid,name,Officeno,meterno,contactno,fax,coatactPerson,status,shop,office,officesize,maintenenceaccounts,mrate	
	from T_AlliedCustomer where customerid=pWhereValue order by name asc;
END AlliedCustomerInfo;
/


PROMPT CREATE OR REPLACE Procedure  403 :: AlliedCustomerList
CREATE OR REPLACE Procedure AlliedCustomerList
(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER
  
)
AS
BEGIN
if(pQueryType=0) then
    open data_cursor for
    Select customerid,trim(name) as name,trim(Officeno) as Officeno,meterno,officesize,maintenenceaccounts,mrate
	from T_AlliedCustomer 
	order by officeno asc;
elsif(pQueryType =1) then
	open data_cursor for
    Select  customerid,name,meterno,contactno,fax,coatactPerson,status,shop,office,(Officeno||' ' ||' '||'('|| name||')') as Officeno,
	officesize,maintenenceaccounts,mrate
	from T_AlliedCustomer 
	order by  name asc;
End if;
END AlliedCustomerList;
/


PROMPT CREATE OR REPLACE Procedure  404 :: Getpreviousdate
CREATE OR REPLACE Procedure Getpreviousdate (
  io_cursor IN OUT pReturnData.c_Records,
  pcustomerid IN NUMBER, 
  billdate IN date,
  pbilltype in number
)
AS
BEGIN
 
    OPEN io_cursor FOR
    select  PID,CURRENTREADING,CURRENTREADINGDATE, 
	(select sum(totalamount) from t_electricitybill where paid=0 and customerid=pcustomerid and billtype=pbilltype and (billmonth is null or billmonth<billdate) group by customerid)  as previousdue,
	b.customerid,b.name,b.Officeno,b.meterno
	from T_ElectricityBill a,T_AlliedCustomer b where a.customerid=b.customerid and a.customerid=pcustomerid and billtype=pbilltype and (billmonth is null or billmonth<billdate);
	
END Getpreviousdate;
/

PROMPT CREATE OR REPLACE Procedure  405 :: AlliedBillLookup
CREATE OR REPLACE Procedure AlliedBillLookup
(
  data_cursor IN OUT pReturnData.c_Records
)
AS

BEGIN

  OPEN data_cursor for
  select pid,serialno from T_Electricitybill ;

END AlliedBillLookup;
/

PROMPT CREATE OR REPLACE Procedure  406 :: AlliedCustomerLookup
CREATE OR REPLACE Procedure AlliedCustomerLookup
(
  data_cursor IN OUT pReturnData.c_Records
)
AS

BEGIN

  OPEN data_cursor for
  select customerid,name from T_AlliedCustomer where status=0 order by name asc;

END AlliedCustomerLookup;
/


PROMPT CREATE OR REPLACE Procedure  407 :: ElectricityTree
CREATE OR REPLACE Procedure ElectricityTree (
  io_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER, 
  sDate IN date,
  eDate IN date,
  pBilltype in number
)
AS

BEGIN

  if pQueryType=0 then
    OPEN io_cursor FOR
    select pid,serialno from T_ElectricityBill
    where billmonth>=SDate and billmonth<=EDate and billtype=pBilltype
    order by (serialno) desc;

  elsif pQueryType=1 then
    OPEN io_cursor FOR    
    select pid,serialno,BMONTH ||', '||BYEAR AS billmonth from T_ElectricityBill 
    where  billtype=pBilltype
    order by billmonth desc, serialno desc;

  end if;

END ElectricityTree;
/



PROMPT CREATE OR REPLACE Procedure  408 :: ElectricityBillInfo
CREATE OR REPLACE Procedure ElectricityBillInfo
(
  one_cursor IN OUT pReturnData.c_Records, 
  pWhere number
)
AS
BEGIN
    open one_cursor for
    select  PID,CUSTOMERID,CURRENTREADING,CURRENTREADINGDATE,USENCEUNIT,UNITRATE,ISSUEDATE,PAYMENTDATE,USENCECOST,             
 GOVTDUTY,SERVICECHARGE ,DEMANDCHARGE, VAT,DUEAMOUNT,PAYABLEAMOUNT,TOTALAMOUNT,PAID,SERIALNO, EMPLOYEEID,BILLMONTH,
 PREVREADING,PREVDATE,PAIDAMOUNT,BILLTYPE,bmonth,byear,totalpayableinwords,payableinwords     
    from T_ElectricityBill
    where PID=pWhere;   
END ElectricityBillInfo;
/


PROMPT CREATE OR REPLACE Procedure  409:: UpdatePaiddate
Create or Replace Procedure UpdatePaiddate
(
 pserialid IN NUMBER,
 pRecsAffected out NUMBER
)
AS
BEGIN
pRecsAffected:=0;
for rec in(select PAYMENTDATE,PAYABLEAMOUNT,TOTALAMOUNT from T_ElectricityBill where PID=pserialid)
loop
if(rec.PAYMENTDATE>=sysdate) then
update T_ElectricityBill set paiddate=to_char(sysdate,'DD-Mon-YYYY'),paidamount=rec.PAYABLEAMOUNT where PID=pserialid;
else
update T_ElectricityBill set paiddate=to_char(sysdate,'DD-Mon-YYYY'),paidamount=rec.TOTALAMOUNT where PID=pserialid;
end if;
end loop;
pRecsAffected:=100;
END UpdatePaiddate;
/


PROMPT CREATE OR REPLACE Procedure  410:: AL001ElectricityBill
CREATE OR REPLACE Procedure AL001ElectricityBill
(
  one_cursor IN OUT pReturnData.c_Records, 
  pWhere number
)
AS
BEGIN
    open one_cursor for
    select  PID,a.CUSTOMERID,CURRENTREADING,CURRENTREADINGDATE,USENCEUNIT,UNITRATE,ISSUEDATE,PAYMENTDATE,USENCECOST,             
 GOVTDUTY,SERVICECHARGE ,DEMANDCHARGE, VAT,DUEAMOUNT,PAYABLEAMOUNT,TOTALAMOUNT,PAID,SERIALNO, EMPLOYEEID,BILLMONTH,
 PREVREADING,PREVDATE,PAIDAMOUNT,b.meterno,b.officeno ,b.name            
    from T_ElectricityBill a, T_AlliedCustomer b
    where a.CUSTOMERID=b.customerid and PID=pWhere;   
END AL001ElectricityBill;
/



PROMPT CREATE OR REPLACE Procedure  411 :: Unlock
Create or Replace Procedure Unlock
(
 PWhere IN NUMBER,
 pUserID Varchar2,
 pPassword varchar2,
 pFormid In Varchar2,
 pUnlocktype in number,
 pRecsAffected out NUMBER

)
AS
uid varchar2(50);

id number;
execep_login_failed Exception;
execep_auth_failed Exception;
BEGIN
select count(*) into id from t_employee where Employeeid=pUserID and Emppassword=pPassword;
if(id=0) then
Raise execep_login_failed;

Else 
select Employeeid into uid from t_Athurization where employeeid=pUserID and formid=pformid;
pRecsAffected:=100;
/*For All Money Receipt*/
if (uid=pUserID) and pUnlocktype=1 then
update T_MoneyReceipt set Posted=0,unpostby=uid where PID=PWhere;
/*For Allied Electric Bill*/
elsif (uid=pUserID) and pUnlocktype=2 then 
update T_ElectricityBill set Paid=0,unlockby=uid where PID=PWhere;
/*For Budget*/
elsif (uid=pUserID) and pUnlocktype=3 then  
update t_budget set complete=0,AUTHORIZEDID=uid where budgetid=PWhere;
else
Raise No_data_found ;
End if;

END IF;
EXCEPTION
WHEN execep_login_failed then
pRecsAffected:=98;

WHEN No_data_found then
pRecsAffected:=99;

END Unlock;
/

PROMPT CREATE OR REPLACE Procedure  412 :: AlliedBillInfo
CREATE OR REPLACE Procedure AlliedBillInfo
(
  data_cursor IN OUT pReturnData.c_Records,
  pbilltype IN NUMBER  
)
AS
BEGIN
    open data_cursor for
    Select PAYABLEAMOUNT,TOTALAMOUNT,PAID,(serialno||' ' ||' '||'('|| decode(billtype,1,'Electric',2,'Maintenence')||')') AS serial, serialno,PAYMENTDATE,a.CUSTOMERID,PID,b.officeno,b.name             
	from t_electricitybill a,t_alliedcustomer b where a.customerid=b.customerid and (pbilltype is null or BILLTYPE=pbilltype)
	order by serialno asc;
END AlliedBillInfo;
/

PROMPT CREATE OR REPLACE Procedure  413 :: CopyAlliedBill
Create or Replace Procedure CopyAlliedBill
(
 pBillid IN NUMBER,
 pBilltype in number,
 pRecsAffected out NUMBER

)
AS
slno number;

BEGIN

select max(serialno)+1 into slno from  T_Electricitybill where Billtype=pBilltype;
pRecsAffected:=100;

insert into T_Electricitybill(PID,SERIALNO,BILLMONTH,CUSTOMERID,CURRENTREADING,Currentreadingdate,PREVREADING,PREVDATE,USENCEUNIT,             
UNITRATE,ISSUEDATE,PAYMENTDATE,USENCECOST,GOVTDUTY,SERVICECHARGE,DEMANDCHARGE,VAT,DUEAMOUNT,PAYABLEAMOUNT,TOTALAMOUNT,PAID ,                  
EMPLOYEEID,PAIDAMOUNT,PAIDDATE,UNLOCKBY,BILLTYPE,BMONTH,BYEAR) 
select Seq_electricitybill.nextval,slno,BILLMONTH,decode(Billtype,1,-1,2,CUSTOMERID),null,Currentreadingdate,0,null,USENCEUNIT,             
UNITRATE,ISSUEDATE,PAYMENTDATE,USENCECOST,GOVTDUTY,SERVICECHARGE,DEMANDCHARGE,VAT,DUEAMOUNT,PAYABLEAMOUNT,TOTALAMOUNT,PAID ,                  
EMPLOYEEID,PAIDAMOUNT,PAIDDATE,UNLOCKBY,BILLTYPE,BMONTH,BYEAR from T_Electricitybill where PID=pBillid;
 
END CopyAlliedBill;
/

PROMPT CREATE OR REPLACE Procedure  414 :: CopyAlliedMaintenanceBill
Create or Replace Procedure CopyAlliedMaintenanceBill
(
 pBillid IN NUMBER,
 pBilltype in number,
 pRecsAffected out NUMBER

)
AS
slno number;

BEGIN

select max(serialno)+1 into slno from  T_Electricitybill where Billtype=pBilltype;
pRecsAffected:=100;

insert into T_Electricitybill(PID,SERIALNO,BILLMONTH,CUSTOMERID,CURRENTREADING,Currentreadingdate,PREVREADING,PREVDATE,USENCEUNIT,             
UNITRATE,ISSUEDATE,PAYMENTDATE,USENCECOST,GOVTDUTY,SERVICECHARGE,DEMANDCHARGE,VAT,DUEAMOUNT,PAYABLEAMOUNT,TOTALAMOUNT,PAID ,                  
EMPLOYEEID,PAIDAMOUNT,PAIDDATE,UNLOCKBY,BILLTYPE,BMONTH,BYEAR) 
select Seq_electricitybill.nextval,slno,BILLMONTH,CUSTOMERID,null,Currentreadingdate,0,null,USENCEUNIT,             
UNITRATE,ISSUEDATE,PAYMENTDATE,USENCECOST,GOVTDUTY,SERVICECHARGE,DEMANDCHARGE,VAT,DUEAMOUNT,PAYABLEAMOUNT,TOTALAMOUNT,PAID ,                  
EMPLOYEEID,PAIDAMOUNT,PAIDDATE,UNLOCKBY,BILLTYPE,
Case
when BMONTH='January' then 'February'
when BMONTH='February' then 'March'
when BMONTH='March' then 'April'
when BMONTH='April' then 'May'
when BMONTH='May' then 'June'
when BMONTH='June' then 'July'
when BMONTH='July' then 'August'
when BMONTH='August' then 'September'
when BMONTH='September' then 'October'
when BMONTH='October' then 'November'
when BMONTH='November' then 'December'
when BMONTH='December' then 'January'
else
''
End,
Byear from T_Electricitybill where PID=pBillid;
 
END CopyAlliedMaintenanceBill;
/


PROMPT CREATE OR REPLACE Procedure  415 :: GetLCSupplierLookup
CREATE OR REPLACE Procedure GetLCSupplierLookup
(
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
  OPEN data_cursor for
    Select a.SupplierID,b.SupplierName from T_AccImpLC a,T_Supplier b
    where a.SupplierID=b.SupplierID
	UNION
	Select a.SupplierID,b.SupplierName from T_AuxImpLC a,T_Supplier b
    where a.SupplierID=b.SupplierID
	UNION
	Select a.SupplierID,b.SupplierName from T_YarnImpLC a,T_Supplier b
    where a.SupplierID=b.SupplierID;
END GetLCSupplierLookup;
/
PROMPT CREATE OR REPLACE Procedure  416 :: GetBtoBLCLookup
CREATE OR REPLACE Procedure GetBtoBLCLookup
(
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
  OPEN data_cursor for
    Select LCNO,BANKLCNO from T_AccImpLC    
	UNION
	Select LCNO,BANKLCNO from T_AuxImpLC a   
	UNION
	Select LCNO,BANKLCNO from T_YarnImpLC a;
END GetBtoBLCLookup;
/

PROMPT CREATE OR REPLACE Procedure  417:: GetLcvoucherInfo
CREATE OR REPLACE Procedure GetLcvoucherInfo
(
  one_cursor IN OUT pReturnData.c_Records, 
  pExpid number
)
AS
BEGIN
    open one_cursor for
    select PID,REFNO,REFDATE,IBPNO,IBPAMOUNT,INTTACNO,INTTAMOUNT,CDAC,CDACAMOUNT,TOTALAMOUNT,GENERALACNO,            
CURRENTACNO,PONO,PODATE ,COMPANYID,BANKID,COMMAC,COMMACAMOUNT,BILLAMOUNT,PURCHASEAMOUNTFC,PURCHASEAMOUNTTK,
PURCHASEDATE,EXCHANGERATE,PTACNO,VOUCHERTYPE,PTAMMOUNT                       
    from t_lcvoucher
    where PID=pExpid;   
END GetLcvoucherInfo;
/

PROMPT CREATE OR REPLACE Procedure  418 :: GetExpno
CREATE OR REPLACE Procedure GetExpno
(
  pStatus number,
  pWhereValue number,
  data_cursor IN OUT pReturnData.c_Records
)

AS

BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=0 then
  OPEN data_cursor for
   Select expno
	from T_ShipmentInfo order by expno;
end if;
END GetExpno;
/

PROMPT CREATE OR REPLACE Procedure  419 :: CopyShipmentInfo
Create or Replace Procedure CopyShipmentInfo
( 
	pSID IN NUMBER,
	pRecsAffected out NUMBER
)
AS
ID NUMBER;
BEGIN
pRecsAffected:=100;

insert into T_ShipmentInfo(PID, EXPNO,EXPDATE,GOODSDESC,QUANTITYPCS,BLNO,INVOICENO,INVOICEDATE,SHIPPINBILLNO ,         
 SHIPPINGBILLDATE, SHIPPINGBILLQTY ,GSPNO,GSPDATE ,GSPQTY ,LCNO,BLDATE,INVOICEVALUE ,orderno)
select Seq_shipmentinfo.nextval,EXPNO,EXPDATE,GOODSDESC,QUANTITYPCS,BLNO,INVOICENO || 'A',INVOICEDATE,SHIPPINBILLNO ,         
 SHIPPINGBILLDATE, SHIPPINGBILLQTY ,GSPNO,GSPDATE ,GSPQTY ,LCNO,BLDATE,INVOICEVALUE ,orderno
 from T_ShipmentInfo where PID=pSID; 
  INSERT INTO T_Lcpayment(PID,lcno,Invoiceno,InvoiceDate,ExpBillAmt,LCSTATUSID,Spid)
 select seq_ExpLCPaymentID.Nextval,LCNO,INVOICENO,INVOICEDATE,INVOICEVALUE,3,PID from T_ShipmentInfo where PID=pSID; 
END CopyShipmentInfo;
/

PROMPT CREATE OR REPLACE Procedure  420 :: GetShipmentInfo
CREATE OR REPLACE Procedure GetShipmentInfo
(
  one_cursor IN OUT pReturnData.c_Records, 
  pExpid number
)
AS
BEGIN
    open one_cursor for
    select  PID, EXPNO,EXPDATE,GOODSDESC,QUANTITYPCS,BLNO,INVOICENO,INVOICEDATE,SHIPPINBILLNO ,         
 SHIPPINGBILLDATE, SHIPPINGBILLQTY ,GSPNO,GSPDATE ,GSPQTY ,LCNO,BLDATE,INVOICEVALUE ,orderno,docsubdate,CURRENCYID          
    from T_Shipmentinfo
    where PID=pExpid;   
END GetShipmentInfo;
/
PROMPT CREATE OR REPLACE Procedure  421 :: GetMPGroupLookUp
CREATE OR REPLACE Procedure GetMPGroupLookUp
(
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
  OPEN data_cursor for
    Select MPGroupID,MPGroupName from T_MPGroup;
END GetMPGroupLookUp;
/
PROMPT CREATE OR REPLACE Procedure  422 :: Lc_paymentInfo1
Create or Replace Procedure Lc_paymentInfo1
(
  one_cursor IN OUT pReturnData.c_Records,
  pExpid number
)
AS
BEGIN
    open one_cursor for
    select  PID, paymentinvoiceno,pinvoicetdate,pInvoicevalue,lctype,REMARKS
    from T_LcpaymentInfo
    where PID=pExpid;
END Lc_paymentInfo1;
/
PROMPT CREATE OR REPLACE Procedure  423 :: GetTransferOrderList
Create or Replace Procedure GetTransferOrderList
(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType number,
  pShadegroup number,
  pFabric varchar2,
  pOrderLineItem varchar2,
  pShade varchar2
)
AS
BEGIN

if pQueryType=1 then  /*pStatus=5 in procedure GetOrderLineItemList*/
  OPEN data_cursor for
   Select a.ORDERNO,getfncWOBType(a.ORDERNO) as btype,a.UNITOFMEASID,a.sunit,d.unitofmeas,e.unitofmeas as sunitofmeas,
   a.FABRICTYPEID,b.FABRICTYPE,a.ShadeGroupID,c.SHADEGROUPNAME,sum(a.QUANTITY) AS QUANTITY,sum(a.sqty) AS Sqty
   from T_Orderitems a,t_fabricType b,T_ShadeGroup c,t_unitofmeas d,t_unitofmeas e
   where a.FABRICTYPEID=b.FABRICTYPEID and a.SHADEGROUPID=c.SHADEGROUPID and
   a.unitofmeasid=d.unitofmeasid(+) and
   a.sunit=e.unitofmeasid(+) and
   a.FABRICTYPEID=pFabric and a.SHADEGROUPID=pShadegroup
   GROUP BY a.ORDERNO,a.FABRICTYPEID,b.FABRICTYPE,a.ShadeGroupID,c.SHADEGROUPNAME,a.UNITOFMEASID,a.sunit,d.unitofmeas,e.unitofmeas;

elsif pQueryType=2 then /*pStatus=6 in procedure GetOrderLineItemList*/
   OPEN data_cursor for
   Select a.ORDERNO,getfncWOBType(a.ORDERNO) as btype,a.ORDERLINEITEM,a.UNITOFMEASID,a.sunit,d.unitofmeas,e.unitofmeas as sunitofmeas,
   a.FABRICTYPEID,b.FABRICTYPE,a.ShadeGroupID,c.SHADEGROUPNAME,a.QUANTITY,a.sqty as sqty
   from T_Orderitems a,t_fabricType b,T_ShadeGroup c,t_unitofmeas d,t_unitofmeas e
   where a.FABRICTYPEID=b.FABRICTYPEID and a.SHADEGROUPID=c.SHADEGROUPID and
   a.FABRICTYPEID=pFabric and a.SHADEGROUPID=pShadegroup and
   /*a.ORDERLINEITEM=pOrderLineItem and*/
   a.unitofmeasid=d.unitofmeasid(+) and
   a.sunit=e.unitofmeasid(+);
elsif pQueryType=3 then  /*pStatus=7 in procedure GetOrderLineItemList*/
OPEN data_cursor for
   select b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.FABRICTYPEID,FABRICTYPE,b.ORDERLINEITEM as OrderlineItem,b.Shade,
	b.PUnitOfMeasId as UNITOFMEASID,f.UnitOfMeas,b.sUnitOfMeasId as sunit,i.unitofmeas as sunitofmeas,
	b.shadegroupid,h.shadegroupname,
	b.YARNBATCHNO,b.DYEDLOTNO,b.YARNTYPEID,b.YARNCOUNTID,'' YarnCount,'' YarnType,
	(sum(Quantity*ATLGFDF)-NVL(decode(b.DYEDLOTNO,null,(SELECT sum(QUANTITY) FROM T_DBATCHITEMS
	where ORDERNO=b.Orderno and FABRICTYPEID=b.FABRICTYPEID and
	shadegroupid=b.Shadegroupid and YARNBATCHNO=b.YARNBATCHNO and Shade=b.Shade),(SELECT sum(QUANTITY) FROM T_DBATCHITEMS
	where ORDERNO=b.Orderno and FABRICTYPEID=b.FABRICTYPEID and
	shadegroupid=b.Shadegroupid and YARNBATCHNO=b.YARNBATCHNO and DYEDLOTNO=b.DYEDLOTNO and Shade=b.Shade)),0)) as  QUANTITY,
	(sum(SQuantity*ATLGFDF)-NVL(decode(b.DYEDLOTNO,null,(SELECT sum(SQuantity) FROM T_DBATCHITEMS
	where ORDERNO=b.Orderno and FABRICTYPEID=b.FABRICTYPEID and
	shadegroupid=b.Shadegroupid and YARNBATCHNO=b.YARNBATCHNO and Shade=b.Shade),(SELECT sum(SQuantity) FROM T_DBATCHITEMS
	where ORDERNO=b.Orderno and FABRICTYPEID=b.FABRICTYPEID and
	shadegroupid=b.Shadegroupid and YARNBATCHNO=b.YARNBATCHNO and DYEDLOTNO=b.DYEDLOTNO and Shade=b.Shade)),0)) as sqty
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
    T_UnitOfMeas f,T_FabricType g,T_shadeGroup h,T_UnitOfMeas i
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.FABRICTYPEID=g.FABRICTYPEID and
    b.shadegroupid=h.shadegroupid and
    b.PUnitOfMeasID=f.UnitOfMeasID(+)  and
    b.SUnitOfMeasID=i.UnitOfMeasID(+) and
	b.FABRICTYPEID=pFabric /*and b.SHADEGROUPID=pShadegroup and
    b.ORDERLINEITEM=pOrderLineItem and b.shade=pShade*/
    group by b.ORDERNO,b.Shade,b.PUnitOfMeasId,f.UnitOfMeas,b.FABRICTYPEID,FABRICTYPE,b.YARNBATCHNO,b.DYEDLOTNO,b.YARNTYPEID,b.YARNCOUNTID,
    b.shadegroupid,h.shadegroupname,b.sUnitOfMeasId,i.unitofmeas,b.ORDERLINEITEM
    	having (sum(Quantity*ATLGFDF)-NVL(decode(b.DYEDLOTNO,null,(SELECT sum(QUANTITY) FROM T_DBATCHITEMS
	where ORDERNO=b.Orderno and FABRICTYPEID=b.FABRICTYPEID and
	shadegroupid=b.Shadegroupid and YARNBATCHNO=b.YARNBATCHNO and Shade=b.Shade),(SELECT sum(QUANTITY) FROM T_DBATCHITEMS
	where ORDERNO=b.Orderno and FABRICTYPEID=b.FABRICTYPEID and
	shadegroupid=b.Shadegroupid and YARNBATCHNO=b.YARNBATCHNO and DYEDLOTNO=b.DYEDLOTNO and Shade=b.Shade)),0)) >0
    ORDER BY btype;
end if;
END GetTransferOrderList;
/



PROMPT CREATE OR REPLACE Procedure  424 :: GetDevExGarments
CREATE OR REPLACE Procedure GetDevExGarments
(
  pCatID IN NUMBER,
  sDate in date,
  eDate in date,
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
  OPEN data_cursor for
  select A.STOCKID,A.STOCKTRANSNO,A.STOCKTRANSDATE,
	C.SUBCONNAME,B.CLIENTNAME,A.PONO,A.GATEPASSNO,A.FWEIGHT,        
	A.CUTWEIGHT,A.EFFICIENCY,A.CUTPIECEREJECT,A.JHUTE,D.DESCRIPTION AS PRODHOUR,
	AA.GSTOCKITEMSL,BB.FABRICTYPE,AA.DISPLAYNO,AA.BATCHNO,AA.SHADE,AA.STYLENO,
	getfncDispalyorder(AA.ORDERNO) AS ORDERNO,CC.SIZENAME,AA.LINENO,
	AA.CARTONNO,FF.COUNTRYNAME,AA.BUNDLENO,AA.FABWEIGHT,AA.QUANTITY,       
	GG.UNITOFMEAS AS PUNIT,AA.SQUANTITY,HH.UNITOFMEAS AS SUNIT
  from T_GSTOCK A,T_CLIENT B,T_SUBCONTRACTORS C,T_PRODUCTIONHOUR D,
		T_GStockItems AA,T_FABRICTYPE BB,T_SIZE CC,T_COUNTRY FF,
		T_UNITOFMEAS GG,T_UNITOFMEAS HH
  WHERE A.CATID=pCatID AND
		A.CLIENTID=B.CLIENTID(+) AND
		A.SUBCONID=C.SUBCONID(+) AND
		(A.STOCKTRANSDATE between sDate and eDate) and
		A.PRODHOUR=D.HID(+) and
		A.STOCKID=AA.STOCKID and
		AA.FABRICTYPEID=BB.FABRICTYPEID(+) AND
		AA.SIZEID=CC.SIZEID(+) AND	
		AA.COUNTRYID=FF.COUNTRYID(+) AND
		AA.PUNITOFMEASID=GG.UNITOFMEASID(+) AND
		AA.SUNITOFMEASID=HH.UNITOFMEASID(+) and
		AA.QUANTITY>0;
END GetDevExGarments;
/
PROMPT CREATE OR REPLACE Procedure  425 :: getTreeFRCardList
create or replace Procedure getTreeFRCardList(
  io_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pRoutecardno IN varchar2 default null,
  sDate IN date,
  eDate IN date
)
AS
BEGIN
 /* For Route card id*/
  if pQueryType=0 then
  OPEN io_cursor FOR
    select a.RouteCardID,a.routecardno from  T_ProcessRouteCard a
    where a.ROUTECARDDATE>=sDate and a.ROUTECARDDATE <=EDate  
	order by to_number(a.routecardno) desc;

elsif pQueryType=1 then
    OPEN io_cursor FOR
    select a.RouteCardID,a.routecardno,ROUTECARDDATE from  T_ProcessRouteCard a
    where a.ROUTECARDDATE>=sDate and a.ROUTECARDDATE <=EDate
	order by a.ROUTECARDDATE,to_number(a.routecardno) desc;
	
elsif pQueryType=2 then
    OPEN io_cursor FOR
    select a.RouteCardID,a.routecardno,b.BATCHNO from  T_ProcessRouteCard a, T_Dbatch b
    where a.ROUTECARDDATE>=sDate and a.ROUTECARDDATE <=EDate and a.FABRICBATCHID=b.DBATCHID(+)
	order by b.BATCHNO,to_number(a.routecardno) desc;
	
elsif pQueryType=999 then
    OPEN io_cursor FOR
    select a.routecardno from  T_ProcessRouteCard a
    where a.ROUTECARDDATE>=sDate and a.ROUTECARDDATE <=EDate ;
   end if;
END getTreeFRCardList;
/
PROMPT CREATE OR REPLACE Procedure  426 :: DevExYarnLossSummary
CREATE OR REPLACE Procedure DevExYarnLossSummary(
   one_cursor IN OUT pReturnData.c_Records,
   pOrderNo in varchar2,
   pClientName in varchar2,
   pSdate in varchar2,
   pEdate in varchar2   
)
AS
vSDate date;
vEDate date;
BEGIN
  if not pSdate is null then
    vSDate := TO_DATE(pSdate, 'DD/MM/YYYY');
  end if;
  if not pEdate is null then
    vEDate := TO_DATE(pEdate, 'DD/MM/YYYY');
  end if;
open one_cursor for
select b.orderno,getfncWOBType(b.orderno) as workorder,e.ORDERDATE,f.ClientName,
/* Gray yarn Issue to Floor=3 other=4...Dyed Yarn Issue to floor=22 other=23*/
 SUM(decode (a.KNTITRANSACTIONTYPEID,3,b.Quantity,22,b.Quantity,0)) as YI_FLOOR,
 SUM(decode (a.KNTITRANSACTIONTYPEID,4,b.Quantity,23,b.Quantity,0)) as YI_OTHERS,
 SUM(decode (a.KNTITRANSACTIONTYPEID,3,b.Quantity,4,b.Quantity,22,b.Quantity,23,b.Quantity,0)) as YI_TOTAL,
/* Gray yarn and dyed yarn adjustment*/
 SUM(decode (a.KNTITRANSACTIONTYPEID,60,b.Quantity,64,b.Quantity,0)) as YADJ_FLOOR,
 SUM(decode (a.KNTITRANSACTIONTYPEID,61,b.Quantity,65,b.Quantity,0)) as YADJ_OTHERS,
 SUM(decode (a.KNTITRANSACTIONTYPEID,60,b.Quantity,61,b.Quantity,64,b.Quantity,65,b.Quantity,0)) as YADJ_TOTAL,
/*Gray yarn return from Floor=9 other=26...Dyed Yarn return from floor=10 other=26*/
 SUM(decode (a.KNTITRANSACTIONTYPEID,9,b.Quantity,26,b.Quantity,0)) as YRF_FLOOR,
 SUM(decode (a.KNTITRANSACTIONTYPEID,10,b.Quantity,27,b.Quantity,0)) as YRF_OTHERS,
 SUM(decode (a.KNTITRANSACTIONTYPEID,9,b.Quantity,10,b.Quantity,26,b.Quantity,27,b.Quantity,0)) as YR_TOTAL,
/* Knit Yarn Transfer One to Another */
 SUM(decode(a.KNTITRANSACTIONTYPEID,101,b.Quantity,111,b.Quantity,0)) as YT_FROM,
 SUM(decode(a.KNTITRANSACTIONTYPEID,102,b.Quantity,112,b.Quantity,0)) as YT_TO,
 SUM(decode(a.KNTITRANSACTIONTYPEID,101,b.Quantity,102,-b.Quantity,111,b.Quantity,112,-b.Quantity,0)) as YT_TOTAL,
 /* Gray fabric receive*/
 SUM(decode (a.KNTITRANSACTIONTYPEID,6,b.Quantity,24,b.Quantity,0)) as YREC_FLOOR,
 SUM(decode (a.KNTITRANSACTIONTYPEID,7,b.Quantity,25,b.Quantity,0)) as YREC_OTHERS,
 SUM(decode (a.KNTITRANSACTIONTYPEID,6,b.Quantity,7,b.Quantity,24,b.Quantity,25,b.Quantity,0)) AS REC_TOTAL,
 /*Yarn reject from floor and others*/
 SUM(decode (a.KNTITRANSACTIONTYPEID,42,b.Quantity,44,b.Quantity,0)) as YRJ_FLOOR,
 0 as YRJ_OTHERS,
 SUM(decode (a.KNTITRANSACTIONTYPEID,42,b.Quantity,44,b.Quantity,0)) as YRJ_TOTAL, 
 /* KNITTING PROCESS [TOTAL NET YARN ISSUD FOR KNITTING ]*/
  SUM(decode (a.KNTITRANSACTIONTYPEID,3,b.Quantity,22,b.Quantity,9,-b.Quantity,26,-b.Quantity,101,b.Quantity,111,b.Quantity,
     102,-b.Quantity,112,-b.Quantity,6,-b.Quantity,24,-b.Quantity,42,-b.Quantity,44,-b.Quantity,60,b.Quantity,64,b.Quantity,0)) AS NET_YARN_FLOOR,
 /* KNITTING PROCESS [TOTAL NET YARN ISSUD FOR OTHERS ]*/
  SUM(decode (a.KNTITRANSACTIONTYPEID,4,b.Quantity,23,b.Quantity,10,-b.Quantity,27,-b.Quantity,
      7,-b.Quantity,25,-b.Quantity,61,b.Quantity,65,b.Quantity,0))AS NET_YARN_OTHERS,
 /* KNITTING PROCESS [TOTAL NET YARN FLOOR AND OTHERS ]*/
  SUM(decode (a.KNTITRANSACTIONTYPEID,3,b.Quantity,9,-b.Quantity,101,b.Quantity,102,-b.Quantity,
        6,-b.Quantity,4,b.Quantity,10,-b.Quantity,60,b.Quantity,61,b.Quantity,64,b.Quantity,65,b.Quantity,
       7,-b.Quantity,42,-b.Quantity,44,-b.Quantity,22,b.Quantity,26,-b.Quantity,111,b.Quantity,
	   112,-b.Quantity,24,-b.Quantity,23,b.Quantity,27,-b.Quantity,25,-b.Quantity,0))AS NET_YARN_GRAND_TOTAL
 from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c,t_workorder e,T_Client f
 where a.StockID=b.StockID and
 a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and 
 a.KNTITRANSACTIONTYPEID in (3,4,6,7,9,10,22,23,24,25,26,27,42,44,60,61,64,65,101,102,111,112) and
 b.orderno=e.orderno and (pOrderNo is null or b.orderno=pOrderNo) and 
 e.ClientID=f.ClientID and (pClientName is null or e.ClientID=pClientName) and
 e.ORDERDATE between vSDate and vEDate
GROUP BY b.OrderNo,e.ORDERDATE,f.ClientName
ORDER BY getfncWOBType(b.orderno);
END DevExYarnLossSummary;
/
PROMPT CREATE OR REPLACE Procedure  427 :: DevExYarnLossDetails
CREATE OR REPLACE Procedure DevExYarnLossDetails(
   many_cursor IN OUT pReturnData.c_Records,
   pOrderno in number
)
AS 
BEGIN
open many_cursor for
select a.STOCKTRANSNO,a.STOCKTRANSDATE,b.KNTISTOCKITEMSL,
/* Gray yarn Issue to Floor=3 other=4...Dyed Yarn Issue to floor=22 other=23*/
 (decode (a.KNTITRANSACTIONTYPEID,3,b.Quantity,22,b.Quantity,0)) as YI_FLOOR,
 (decode (a.KNTITRANSACTIONTYPEID,4,b.Quantity,23,b.Quantity,0)) as YI_OTHERS,
 (decode (a.KNTITRANSACTIONTYPEID,3,b.Quantity,4,b.Quantity,22,b.Quantity,23,b.Quantity,0)) as YI_TOTAL,
/* Gray yarn and dyed yarn adjustment*/
 (decode (a.KNTITRANSACTIONTYPEID,60,b.Quantity,64,b.Quantity,0)) as YADJ_FLOOR,
 (decode (a.KNTITRANSACTIONTYPEID,61,b.Quantity,65,b.Quantity,0)) as YADJ_OTHERS,
 (decode (a.KNTITRANSACTIONTYPEID,60,b.Quantity,61,b.Quantity,64,b.Quantity,65,b.Quantity,0)) as YADJ_TOTAL,
/*Gray yarn return from Floor=9 other=26...Dyed Yarn return from floor=10 other=26*/
 (decode (a.KNTITRANSACTIONTYPEID,9,b.Quantity,26,b.Quantity,0)) as YRF_FLOOR,
 (decode (a.KNTITRANSACTIONTYPEID,10,b.Quantity,27,b.Quantity,0)) as YRF_OTHERS,
 (decode (a.KNTITRANSACTIONTYPEID,9,b.Quantity,10,b.Quantity,26,b.Quantity,27,b.Quantity,0)) as YR_TOTAL,
/* Knit Yarn Transfer One to Another */
 (decode(a.KNTITRANSACTIONTYPEID,101,b.Quantity,111,b.Quantity,0)) as YT_FROM,
 (decode(a.KNTITRANSACTIONTYPEID,102,b.Quantity,112,b.Quantity,0)) as YT_TO,
 (decode(a.KNTITRANSACTIONTYPEID,101,b.Quantity,102,-b.Quantity,111,b.Quantity,112,-b.Quantity,0)) as YT_TOTAL,
 /* Gray fabric receive*/
 (decode (a.KNTITRANSACTIONTYPEID,6,b.Quantity,24,b.Quantity,0)) as YREC_FLOOR,
 (decode (a.KNTITRANSACTIONTYPEID,7,b.Quantity,25,b.Quantity,0)) as YREC_OTHERS,
 (decode (a.KNTITRANSACTIONTYPEID,6,b.Quantity,7,b.Quantity,24,b.Quantity,25,b.Quantity,0)) AS REC_TOTAL,
 /*Yarn reject from floor and others*/
 (decode (a.KNTITRANSACTIONTYPEID,42,b.Quantity,44,b.Quantity,0)) as YRJ_FLOOR,
  0 as YRJ_OTHERS,
 (decode (a.KNTITRANSACTIONTYPEID,42,b.Quantity,44,b.Quantity,0)) as YRJ_TOTAL, 
 /* KNITTING PROCESS [TOTAL NET YARN ISSUD FOR KNITTING ]*/
  (decode (a.KNTITRANSACTIONTYPEID,3,b.Quantity,22,b.Quantity,9,-b.Quantity,26,-b.Quantity,101,b.Quantity,111,b.Quantity,
     102,-b.Quantity,112,-b.Quantity,6,-b.Quantity,24,-b.Quantity,42,-b.Quantity,44,-b.Quantity,60,b.Quantity,64,b.Quantity,0)) AS NET_YARN_FLOOR,
 /* KNITTING PROCESS [TOTAL NET YARN ISSUD FOR OTHERS ]*/
  (decode (a.KNTITRANSACTIONTYPEID,4,b.Quantity,23,b.Quantity,10,-b.Quantity,27,-b.Quantity,
      7,-b.Quantity,25,-b.Quantity,61,b.Quantity,65,b.Quantity,0))AS NET_YARN_OTHERS,
 /* KNITTING PROCESS [TOTAL NET YARN FLOOR AND OTHERS ]*/
  (decode (a.KNTITRANSACTIONTYPEID,3,b.Quantity,9,-b.Quantity,101,b.Quantity,102,-b.Quantity,
        6,-b.Quantity,4,b.Quantity,10,-b.Quantity,60,b.Quantity,61,b.Quantity,64,b.Quantity,65,b.Quantity,
       7,-b.Quantity,42,-b.Quantity,44,-b.Quantity,22,b.Quantity,26,-b.Quantity,111,b.Quantity,
	   112,-b.Quantity,24,-b.Quantity,23,b.Quantity,27,-b.Quantity,25,-b.Quantity,0))AS NET_YARN_GRAND_TOTAL
 from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c
 where a.StockID=b.StockID and
 a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and 
 a.KNTITRANSACTIONTYPEID in (3,4,6,7,9,10,22,23,24,25,26,27,42,44,60,61,64,65,101,102,111,112) and
 b.orderno=pOrderno 
ORDER BY a.STOCKTRANSDATE,KNTISTOCKITEMSL;
END DevExYarnLossDetails;
/
PROMPT CREATE OR REPLACE Procedure  428 :: GETFRouteCardInfo
CREATE OR REPLACE Procedure GETFRouteCardInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  many_cursor_stage IN OUT pReturnData.c_Records,
  pRoutecardid number
)
AS
BEGIN
    open one_cursor for
    select Routecardid,routecardno,fabricbatchid,BATCHNO,ROUTECARDDATE,remarks,masterroutecardid,
    BatchWeight	
	FROM T_processRoutecard, T_DBATCH
	WHERE Routecardid= pRoutecardid AND
	FABRICBATCHID=DBATCHID;

	open many_cursor_stage for
	select A.STAGEID,A.STAGENAME,A.STAGEORDER,'1' as HOType
	from T_FINISHINGSTAGESMASTER A,T_ROUTECARDSTAGES B where A.STAGEID=B.STAGEID AND
	Routecardid=pRoutecardid
	UNION
    select A.STAGEID,A.STAGENAME,A.STAGEORDER,'2' as HOType FROM T_FINISHINGSTAGESMASTER A 
	WHERE A.STAGEID NOT IN(SELECT STAGEID FROM T_ROUTECARDSTAGES WHERE Routecardid= pRoutecardid) 
	order by HOType,STAGEORDER;
END GETFRouteCardInfo;
/

PROMPT CREATE OR REPLACE Procedure  429 :: InsertRecWithIdentity_WithLog
CREATE OR REPLACE Procedure InsertRecWithIdentity_WithLog(
  pStrSql IN VARCHAR2,
  pStrSqllog IN VARCHAR2,
  pIdentityName IN VARCHAR2,
  pIdentityFld IN VARCHAR2,
  pCurIdentityVal OUT NUMBER,
  pRecsAffected out NUMBER,
  pRecsAffectedlog out NUMBER
)
AS
  tmpSql VARCHAR2(10000);
  restSql VARCHAR2(10000);
  insertSql VARCHAR2(10000);
  insertSqlLog VARCHAR2(10000);
  tmpPos NUMBER;  
BEGIN
  execute immediate 'select ' || pIdentityName || '.NEXTVAL from sys.dual'
  into pCurIdentityVal;

  tmpPos := instr(pStrSql, '(', 1, 1);
  tmpSql := substr(pStrSql, 1, tmpPos);
  restSql := substr(pStrSql, tmpPos+1);
  insertSql := tmpSql || pIdentityFld || ',';

  tmpPos := instr(restSql, ' values (', 1, 1);
  tmpSql := substr(restSql, 1, tmpPos);
  restSql := substr(restSql, tmpPos+9);
  insertSql := insertSql || tmpSql || ' values (' ||
          TO_CHAR(pCurIdentityVal) || ',' || restSql;

  execute immediate insertSql;
  pRecsAffected := SQL%ROWCOUNT;  
  
  insertSqllog :=pStrSqllog;
  if pRecsAffected > 0 then
  	  execute immediate insertSqllog;
	  pRecsAffectedlog := SQL%ROWCOUNT;
  End if;
	
  if pRecsAffectedlog >0 then
	commit;
  Else
	Rollback;
  End If;  
END InsertRecWithIdentity_WithLog;
/


PROMPT CREATE OR REPLACE Procedure  430:: InsertRecWithPIdentity_WithLog
CREATE OR REPLACE Procedure InsertRecWithPIdentity_WithLog(
  pStrSql IN VARCHAR2,
  pStrSqllog IN VARCHAR2,
  pIdentityName IN VARCHAR2,
  pIdentityFld IN VARCHAR2,
  pIdentityParentFld IN VARCHAR2,
  pCurIdentityVal OUT NUMBER,
  pRecsAffected out NUMBER,
  pRecsAffectedlog out NUMBER
)
AS
  tmpSql VARCHAR2(1000);
  restSql VARCHAR2(1000);
  insertSql VARCHAR2(1000);
  insertSqlLog VARCHAR2(10000);
  tmpPos NUMBER;
BEGIN

  execute immediate 'select ' || pIdentityName || '.NEXTVAL from sys.dual'
  into pCurIdentityVal;

  tmpPos := instr(pStrSql, '(', 1, 1);
  tmpSql := substr(pStrSql, 1, tmpPos);
  restSql := substr(pStrSql, tmpPos+1);
  insertSql := tmpSql || pIdentityFld || ',' || pIdentityParentFld || ',';

  tmpPos := instr(restSql, ' values (', 1, 1);
  tmpSql := substr(restSql, 1, tmpPos);
  restSql := substr(restSql, tmpPos+9);
  insertSql := insertSql || tmpSql || ' values (' ||
          TO_CHAR(pCurIdentityVal) ||','|| TO_CHAR(pCurIdentityVal) ||',' || restSql;

  execute immediate insertSql;
  pRecsAffected := SQL%ROWCOUNT;
  
  insertSqllog :=pStrSqllog;
  if pRecsAffected > 0 then
  	  execute immediate insertSqllog;
	  pRecsAffectedlog := SQL%ROWCOUNT;
  End if;
	
  if pRecsAffectedlog >0 then
	commit;
  Else
	Rollback;
  End If;  

END InsertRecWithPIdentity_WithLog;
/



PROMPT CREATE OR REPLACE Procedure  431:: GetDevExWorkorder
CREATE OR REPLACE Procedure GetDevExWorkorder
(
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN

    OPEN data_cursor for
    select getfncWOBType(a.ORDERNO) as OrderTypeId, b.ClientName, DeliveryStartDate AS OrderDate, d.EmployeeName,
		f.SalesTerm, g.CURRENCYNAME, e.ORDERSTATUS,DeliveryStartDate,DeliveryStartDate as DeliveryDate,
		'0' as TeamNo, a.OrderNo
    from T_WorkOrder a, T_Client b, T_Employee d, T_OrderStatus e, T_SalesTerm f, T_Currency g
    where  a.ClientId = b.ClientId and
			a.SalesPersonId = d.EmployeeId and
			a.OrderStatusId = e.OrderStatusId and
			a.SALESTERMID = f.SALESTERMID and
			a.CURRENCYID = g.CURRENCYID;
END GetDevExWorkorder;
/

PROMPT CREATE OR REPLACE Procedure  432:: GetDevExWorkorderItems
CREATE OR REPLACE Procedure GetDevExWorkorderItems
(
	pOrderNo number,
	data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN

    OPEN data_cursor for
    select b.FabricType, c.SHADEGROUPNAME,'0' as ColorCode, a.Shade, '' as DiaType, a.Width, a.KnitMcDiaGauge,
		FINISHEDGSM,100 as FINISHEDQTY, PLOSS,100 as  GRAYQTY, RATE,100 as  TOTFINISHEDQTY
    from T_OrderItems a, T_FabricType b, T_ShadeGroup c
    where  a.FabricTypeId = b.FabricTypeId and
			a.ShadeGroupId = c.ShadeGroupId and
			a.ORDERNO = pOrderNo;
END GetDevExWorkorderItems;
/
PROMPT CREATE OR REPLACE Procedure  433:: DevExDYarnLossSummary
CREATE OR REPLACE Procedure DevExDYarnLossSummary(
   one_cursor IN OUT pReturnData.c_Records,
   pOrderNo in varchar2,
   pClientName in varchar2,
   pSdate in varchar2,
   pEdate in varchar2   
)
AS
vSDate date;
vEDate date;
BEGIN
  if not pSdate is null then
    vSDate := TO_DATE(pSdate, 'DD/MM/YYYY');
  end if;
  if not pEdate is null then
    vEDate := TO_DATE(pEdate, 'DD/MM/YYYY');
  end if;
open one_cursor for
select b.OrderNo,getfncWOBType(b.orderno) as workorder,e.ORDERDATE,f.ClientName,
/* YARN DYEING PROCESS [YARN ISSUE FOR YARN DYEING]*/
 SUM(decode (a.KNTITRANSACTIONTYPEID,5,b.Quantity,0)) as YI_FLOOR,
 SUM(decode (a.KNTITRANSACTIONTYPEID,12,b.Quantity,0)) as YI_OTHERS,
 SUM(decode (a.KNTITRANSACTIONTYPEID,5,b.Quantity,12,b.Quantity,0)) as YI_TOTAL,
/* YARN DYEING PROCESS [YARN RETURN FROM YARN DYEING]*/
 SUM(decode (a.KNTITRANSACTIONTYPEID,11,b.Quantity,0)) as YRF_FLOOR,
 SUM(decode (a.KNTITRANSACTIONTYPEID,14,b.Quantity,0)) as YRF_OTHERS,
 SUM(decode (a.KNTITRANSACTIONTYPEID,11,b.Quantity,14,b.Quantity,0)) as YR_TOTAL,
/* Knit Yarn Transfer One to Another */
 SUM(decode(a.KNTITRANSACTIONTYPEID,151,b.Quantity)) as YT_FROM,
 SUM(decode(a.KNTITRANSACTIONTYPEID,152,b.Quantity)) as YT_TO,
 SUM(decode(a.KNTITRANSACTIONTYPEID,151,b.Quantity,152,-b.Quantity,0)) as YT_TOTAL,
 /* YARN DYEING PROCESS [YARN RECEIVED FROM YARN DYEING]*/
 SUM(decode (a.KNTITRANSACTIONTYPEID,8,b.Quantity,0)) as YREC_FLOOR,
 SUM(decode (a.KNTITRANSACTIONTYPEID,13,b.Quantity,0)) as YREC_OTHERS,
 SUM(decode (a.KNTITRANSACTIONTYPEID,8,b.Quantity,13,b.Quantity,0)) AS REC_TOTAL,
 /* YARN Rejected*/
 SUM(decode (a.KNTITRANSACTIONTYPEID,43,b.Quantity,0)) as YRJ_FLOOR,
 SUM(decode (a.KNTITRANSACTIONTYPEID,55,b.Quantity,0)) as YRJ_OTHERS,
 SUM(decode (a.KNTITRANSACTIONTYPEID,43,b.Quantity,55,b.Quantity,0)) as YRJ_TOTAL,
 /* YARN Adjustment*/
 SUM(decode (a.KNTITRANSACTIONTYPEID,62,b.Quantity,0)) as YADJ_FLOOR,
 SUM(decode (a.KNTITRANSACTIONTYPEID,63,b.Quantity,0)) as YADJ_OTHERS,
 SUM(decode (a.KNTITRANSACTIONTYPEID,62,b.Quantity,63,b.Quantity,0)) as YADJ_TOTAL,
 /* KNITTING PROCESS [TOTAL NET YARN ISSUD FOR KNITTING ]*/
  SUM(decode (a.KNTITRANSACTIONTYPEID,5,b.Quantity,11,-b.Quantity,151,b.Quantity,152,-b.Quantity,
     8,-b.Quantity,62,b.Quantity,43,-b.Quantity,0)) AS NET_YARN_FLOOR,
 /* KNITTING PROCESS [TOTAL NET YARN ISSUD FOR OTHERS ]*/
  SUM(decode (a.KNTITRANSACTIONTYPEID,12,b.Quantity,63,b.Quantity,13,-b.Quantity,14,-b.Quantity,55,-b.Quantity,0)) AS NET_YARN_OTHERS,
 /* KNITTING PROCESS [TOTAL NET YARN FLOOR AND OTHERS ]*/
  SUM(decode (a.KNTITRANSACTIONTYPEID,5,b.Quantity,11,-b.Quantity,151,b.Quantity,152,-b.Quantity,
      8,-b.Quantity,12,b.Quantity,13,-b.Quantity,14,-b.Quantity,62,b.Quantity,63,b.Quantity,
      43,-b.Quantity,55,-b.Quantity,0))AS NET_YARN_GRAND_TOTAL
 from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c,  t_workorder e,T_Client f
 where a.StockID=b.StockID and
	a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and 
	a.KNTITRANSACTIONTYPEID in (5,8,11,12,13,14,43,55,62,63,151,152) and
	b.orderno=e.orderno and e.ClientID=f.ClientID and
	(pOrderNo is null or b.orderno=pOrderNo) and
	(pClientName is NULL or e.ClientID=pClientName) and
	e.ORDERDATE between vSDate and vEDate
	GROUP BY b.OrderNo,e.ORDERDATE,f.ClientName
	ORDER BY getfncWOBType(b.orderno);
END DevExDYarnLossSummary;
/
PROMPT CREATE OR REPLACE Procedure  434:: DevExDYarnLossDetails
CREATE OR REPLACE Procedure DevExDYarnLossDetails(
   many_cursor IN OUT pReturnData.c_Records,
   pOrderno in number
)
AS 
BEGIN
open many_cursor for
select a.STOCKTRANSNO,a.STOCKTRANSDATE,b.KNTISTOCKITEMSL,
/* YARN DYEING PROCESS [YARN ISSUE FOR YARN DYEING]*/
 (decode (a.KNTITRANSACTIONTYPEID,5,b.Quantity,0)) as YI_FLOOR,
 (decode (a.KNTITRANSACTIONTYPEID,12,b.Quantity,0)) as YI_OTHERS,
 (decode (a.KNTITRANSACTIONTYPEID,5,b.Quantity,12,b.Quantity,0)) as YI_TOTAL,
/* YARN DYEING PROCESS [YARN RETURN FROM YARN DYEING]*/
 (decode (a.KNTITRANSACTIONTYPEID,11,b.Quantity,0)) as YRF_FLOOR,
 (decode (a.KNTITRANSACTIONTYPEID,14,b.Quantity,0)) as YRF_OTHERS,
 (decode (a.KNTITRANSACTIONTYPEID,11,b.Quantity,14,b.Quantity,0)) as YR_TOTAL,
/* Knit Yarn Transfer One to Another */
 (decode(a.KNTITRANSACTIONTYPEID,151,b.Quantity)) as YT_FROM,
 (decode(a.KNTITRANSACTIONTYPEID,152,b.Quantity)) as YT_TO,
 (decode(a.KNTITRANSACTIONTYPEID,151,b.Quantity,152,-b.Quantity,0)) as YT_TOTAL,
 /* YARN DYEING PROCESS [YARN RECEIVED FROM YARN DYEING]*/
 (decode (a.KNTITRANSACTIONTYPEID,8,b.Quantity,0)) as YREC_FLOOR,
 (decode (a.KNTITRANSACTIONTYPEID,13,b.Quantity,0)) as YREC_OTHERS,
 (decode (a.KNTITRANSACTIONTYPEID,8,b.Quantity,13,b.Quantity,0)) AS REC_TOTAL,
 /* YARN Rejected*/
 (decode (a.KNTITRANSACTIONTYPEID,43,b.Quantity,0)) as YRJ_FLOOR,
 (decode (a.KNTITRANSACTIONTYPEID,55,b.Quantity,0)) as YRJ_OTHERS,
 (decode (a.KNTITRANSACTIONTYPEID,43,b.Quantity,55,b.Quantity,0)) as YRJ_TOTAL,
 /* YARN Adjustment*/
 (decode (a.KNTITRANSACTIONTYPEID,62,b.Quantity,0)) as YADJ_FLOOR,
 (decode (a.KNTITRANSACTIONTYPEID,63,b.Quantity,0)) as YADJ_OTHERS,
 (decode (a.KNTITRANSACTIONTYPEID,62,b.Quantity,63,b.Quantity,0)) as YADJ_TOTAL,
 /* KNITTING PROCESS [TOTAL NET YARN ISSUD FOR KNITTING ]*/
  (decode (a.KNTITRANSACTIONTYPEID,5,b.Quantity,11,-b.Quantity,151,b.Quantity,152,-b.Quantity,
     8,-b.Quantity,62,b.Quantity,43,-b.Quantity,0)) AS NET_YARN_FLOOR,
 /* KNITTING PROCESS [TOTAL NET YARN ISSUD FOR OTHERS ]*/
  (decode (a.KNTITRANSACTIONTYPEID,12,b.Quantity,63,b.Quantity,13,-b.Quantity,14,-b.Quantity,55,-b.Quantity,0)) AS NET_YARN_OTHERS,
 /* KNITTING PROCESS [TOTAL NET YARN FLOOR AND OTHERS ]*/
  (decode (a.KNTITRANSACTIONTYPEID,5,b.Quantity,11,-b.Quantity,151,b.Quantity,152,-b.Quantity,
      8,-b.Quantity,12,b.Quantity,13,-b.Quantity,14,-b.Quantity,62,b.Quantity,63,b.Quantity,
      43,-b.Quantity,55,-b.Quantity,0))AS NET_YARN_GRAND_TOTAL
 from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c
 where a.StockID=b.StockID and
 a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and 
 a.KNTITRANSACTIONTYPEID in (5,8,11,12,13,14,43,55,62,63,151,152) and
 b.orderno=pOrderno 
ORDER BY a.STOCKTRANSDATE,KNTISTOCKITEMSL;
END DevExDYarnLossDetails;
/
PROMPT CREATE OR REPLACE Procedure  435:: DevExFabricLossSummary
CREATE OR REPLACE Procedure DevExFabricLossSummary(
   one_cursor IN OUT pReturnData.c_Records,
   pOrderNo in varchar2,
   pClientName in varchar2,
   pSdate in varchar2,
   pEdate in varchar2   
)
AS
vSDate date;
vEDate date;
BEGIN
  if not pSdate is null then
    vSDate := TO_DATE(pSdate, 'DD/MM/YYYY');
  end if;
  if not pEdate is null then
    vEDate := TO_DATE(pEdate, 'DD/MM/YYYY');
  end if;
open one_cursor for
select b.OrderNo,getfncWOBType(b.orderno) as workorder,e.ORDERDATE,f.ClientName,    
	/* Fabric Issue in Dyeing and Finishing Floor*/ 
	sum(decode(a.KNTITRANSACTIONTYPEID,19,b.quantity,0)) as IBFtoDF,
	sum(decode(a.KNTITRANSACTIONTYPEID,20,b.quantity,0)) as IDFtoFF,
	/* Fabric Adjustment in Dyeing and Finishing Floor*/ 
	sum(decode(a.KNTITRANSACTIONTYPEID,48,b.quantity,0)) as DFAdj,
	sum(decode(a.KNTITRANSACTIONTYPEID,49,b.quantity,0)) as FFAdj,
	/* Fabric rejected in Dyeing and Finishing Floor*/   
	sum(decode(a.KNTITRANSACTIONTYPEID,58,b.quantity,0)) as RJDFloor,
	sum(decode(a.KNTITRANSACTIONTYPEID,59,b.quantity,0)) as RJFFloor,
	/* Finishing Fabric Transfer and Receive*/    
    sum(decode(a.KNTITRANSACTIONTYPEID,141,b.quantity,0)) as FFRecFrm,
    sum(decode(a.KNTITRANSACTIONTYPEID,142,b.quantity,0)) as FFTrnTo,
	/* Net fabric received in dyeing and finishing from subcontractor*/    
    sum(decode(a.KNTITRANSACTIONTYPEID,39,b.quantity,0)) as DFOthers,
    sum(decode(a.KNTITRANSACTIONTYPEID,32,b.quantity,40,b.quantity,0)) as FFOthers,
    /* Fabric delivery in Batching, Dyeing and Finishing Floor*/    
    sum(decode(a.KNTITRANSACTIONTYPEID,41,b.quantity,0)) as DIDFloor,
    sum(decode(a.KNTITRANSACTIONTYPEID,21,b.quantity,0)) as DIFFloor,
	/*Process Loss Dyeing and finishing floor*/
	sum(decode(a.KNTITRANSACTIONTYPEID,19,b.quantity,48,b.quantity,39,b.quantity,58,-b.quantity,41,-b.quantity,20,-b.quantity,0)) as DFPLoss,
	sum(decode(a.KNTITRANSACTIONTYPEID,20,b.quantity,49,b.quantity,32,b.quantity,40,b.quantity,59,-b.quantity,21,-b.quantity,141,b.quantity,142,-b.quantity,0)) as FFPLoss
from T_Knitstock a,T_KnitStockItems b,T_knitTransactionType c,T_workorder e,T_Client f
where a.StockID=b.StockID and
   a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and 
   a.KNTITRANSACTIONTYPEID in (19,20,58,59,141,142,39,32,40,41,21,48,49) and
   b.orderno=e.orderno and e.ClientID=f.ClientID and
   (pOrderNo is null or b.orderno=pOrderNo) and
   (pClientName is NULL or e.ClientID=pClientName) and
   e.ORDERDATE between vSDate and vEDate
GROUP BY b.OrderNo,e.ORDERDATE,f.ClientName
ORDER BY getfncWOBType(b.orderno);
END DevExFabricLossSummary;
/
PROMPT CREATE OR REPLACE Procedure  436:: DevExFabricLossDetails
CREATE OR REPLACE Procedure DevExFabricLossDetails(
   many_cursor IN OUT pReturnData.c_Records,
   pOrderno in number
)
AS 
BEGIN
open many_cursor for
select a.STOCKTRANSNO,a.STOCKTRANSDATE,b.KNTISTOCKITEMSL,
/* Fabric Issue in Dyeing and Finishing Floor*/ 
	(decode(a.KNTITRANSACTIONTYPEID,19,b.quantity,0)) as IBFtoDF,
	(decode(a.KNTITRANSACTIONTYPEID,20,b.quantity,0)) as IDFtoFF,
	/* Fabric Adjustment in Dyeing and Finishing Floor*/ 
	(decode(a.KNTITRANSACTIONTYPEID,48,b.quantity,0)) as DFAdj,
	(decode(a.KNTITRANSACTIONTYPEID,49,b.quantity,0)) as FFAdj,
	/* Fabric rejected in Batching, Dyeing and Finishing Floor*/   
	(decode(a.KNTITRANSACTIONTYPEID,58,b.quantity,0)) as RJDFloor,
	(decode(a.KNTITRANSACTIONTYPEID,59,b.quantity,0)) as RJFFloor,
	/* Finishing Fabric Transfer and Receive*/    
    (decode(a.KNTITRANSACTIONTYPEID,141,b.quantity,0)) as FFRecFrm,
    (decode(a.KNTITRANSACTIONTYPEID,142,b.quantity,0)) as FFTrnTo,
	/* Net fabric received in dyeing and finishing from subcontractor*/    
    (decode(a.KNTITRANSACTIONTYPEID,39,b.quantity,0)) as DFOthers,
    (decode(a.KNTITRANSACTIONTYPEID,32,b.quantity,40,b.quantity,0)) as FFOthers,
    /* Fabric delivery in Batching, Dyeing and Finishing Floor*/    
    (decode(a.KNTITRANSACTIONTYPEID,41,b.quantity,0)) as DIDFloor,
    (decode(a.KNTITRANSACTIONTYPEID,21,b.quantity,0)) as DIFFloor,
	/*Process Loss Dyeing and finishing floor*/
	(decode(a.KNTITRANSACTIONTYPEID,19,b.quantity,48,b.quantity,39,b.quantity,58,-b.quantity,41,-b.quantity,20,-b.quantity,0)) as DFPLoss,
	(decode(a.KNTITRANSACTIONTYPEID,20,b.quantity,49,b.quantity,32,b.quantity,40,b.quantity,59,-b.quantity,21,-b.quantity,141,b.quantity,142,-b.quantity,0)) as FFPLoss
from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c
 where a.StockID=b.StockID and
 a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and  
 a.KNTITRANSACTIONTYPEID in (19,20,58,59,141,142,39,32,40,41,21,48,49) and
 b.orderno=pOrderno 
ORDER BY a.STOCKTRANSDATE,KNTISTOCKITEMSL;
END DevExFabricLossDetails;
/
PROMPT CREATE OR REPLACE Procedure  437:: DevExCuttingLossSummary
CREATE OR REPLACE Procedure DevExCuttingLossSummary(
   one_cursor IN OUT pReturnData.c_Records,   
   pSdate in varchar2,
   pEdate in varchar2   
)
AS
vSDate date;
vEDate date;
BEGIN
  if not pSdate is null then
    vSDate := TO_DATE(pSdate, 'DD/MM/YYYY');
  end if;
  if not pEdate is null then
    vEDate := TO_DATE(pEdate, 'DD/MM/YYYY');
  end if;
open one_cursor for
select a.STOCKID,a.STOCKTRANSNO,a.STOCKTRANSDATE,b.CLIENTNAME,FWEIGHT,CUTWEIGHT,      
		EFFICIENCY,CUTPIECEREJECT,JHUTE      
from T_Gstock a,T_Client b
where CATID=4 AND
   a.CLIENTID=b.CLIENTID and 
   a.STOCKTRANSDATE between vSDate and vEDate
   order by a.STOCKTRANSNO,a.STOCKTRANSDATE,b.CLIENTNAME;
END DevExCuttingLossSummary;
/
PROMPT CREATE OR REPLACE Procedure  438:: DevExCuttingLossDetails
CREATE OR REPLACE Procedure DevExCuttingLossDetails(
   many_cursor IN OUT pReturnData.c_Records,
   pStockId in number
)
AS 
BEGIN
open many_cursor for
select a.GSTOCKITEMSL,getfncDispalyorder(a.ORDERNO) as GORDERNO,b.FabricType,a.STYLENO,a.SHADE,
       c.SIZENAME,a.QUANTITY,d.UNITOFMEAS
from T_GStockItems a,T_FabricType b,T_Size c,T_UnitofMeas d
where a.STOCKID=pStockId and
      a.FABRICTYPEID=b.FABRICTYPEID and  
      a.SIZEID=c.SIZEID and
      a.PUNITOFMEASID=d.UNITOFMEASID 	  
Order by a.GSTOCKITEMSL; 
END DevExCuttingLossDetails;
/
PROMPT CREATE OR REPLACE Procedure  439:: ATLLossSummary
CREATE OR REPLACE Procedure ATLLossSummary(
   data_cursor IN OUT pReturnData.c_Records,
   pSdate in varchar2,
   pEdate in varchar2
)
AS
vSDate date;
vEDate date;
BEGIN
  if not pSdate is null then
    vSDate := TO_DATE(pSdate, 'DD/MM/YYYY');
  end if;
  if not pEdate is null then
    vEDate := TO_DATE(pEdate, 'DD/MM/YYYY');
  end if;
open data_cursor for
select to_char(e.ORDERDATE,'MM') as mont,to_char(e.ORDERDATE,'MON')||'-'||to_char(e.ORDERDATE,'YYYY') as MonthYear,
    /*Gray Yarn Loss*/
 SUM(decode (a.KNTITRANSACTIONTYPEID,6,b.Quantity,7,b.Quantity,42,b.Quantity,44,b.Quantity,0)) as GYarnOutput,
    SUM(decode (a.KNTITRANSACTIONTYPEID,3,b.Quantity,9,-b.Quantity,101,b.Quantity,102,-b.Quantity,
       6,-b.Quantity,4,b.Quantity,10,-b.Quantity,60,b.Quantity,61,b.Quantity,64,b.Quantity,65,b.Quantity,
       7,-b.Quantity,22,b.Quantity,26,-b.Quantity,111,b.Quantity,42,-b.Quantity,44,-b.Quantity,
    112,-b.Quantity,24,-b.Quantity,23,b.Quantity,27,-b.Quantity,25,-b.Quantity,0)) as GYarnLoss,
 SUM(decode (a.KNTITRANSACTIONTYPEID,3,b.Quantity,9,-b.Quantity,101,b.Quantity,102,-b.Quantity,
       4,b.Quantity,10,-b.Quantity,60,b.Quantity,61,b.Quantity,64,b.Quantity,65,b.Quantity,
       22,b.Quantity,26,-b.Quantity,111,b.Quantity,112,-b.Quantity,24,-b.Quantity,
    23,b.Quantity,27,-b.Quantity,25,-b.Quantity,0)) as GYarnConsump,
 /*Dyed Yarn Loss(AYDL)*/
 SUM(decode (a.KNTITRANSACTIONTYPEID,8,b.Quantity,13,b.Quantity,43,b.Quantity,55,b.Quantity,0)) as DYarnOutput,
 SUM(decode (a.KNTITRANSACTIONTYPEID,5,b.Quantity,11,-b.Quantity,151,b.Quantity,152,-b.Quantity,
      8,-b.Quantity,12,b.Quantity,13,-b.Quantity,14,-b.Quantity,62,b.Quantity,63,b.Quantity,
      43,-b.Quantity,55,-b.Quantity,0)) AS DYarnLoss,
 SUM(decode (a.KNTITRANSACTIONTYPEID,5,b.Quantity,11,-b.Quantity,151,b.Quantity,152,-b.Quantity,
      12,b.Quantity,14,-b.Quantity,62,b.Quantity,63,b.Quantity,0)) AS DYarnConsump,
    /*Loss in Dyeing*/
 sum(decode(a.KNTITRANSACTIONTYPEID,41,b.quantity,20,b.quantity,0)) as DyeingOutput,
 sum(decode(a.KNTITRANSACTIONTYPEID,19,b.quantity,48,b.quantity,39,b.quantity,58,-b.quantity,41,-b.quantity,20,-b.quantity,0)) as DyeingLoss,
 sum(decode(a.KNTITRANSACTIONTYPEID,19,b.quantity,48,b.quantity,39,b.quantity,58,-b.quantity,0)) as DyeingConsump,
    /*Loss in Finishing*/
 sum(decode(a.KNTITRANSACTIONTYPEID,21,b.quantity,0)) as FinishOutput,
 sum(decode(a.KNTITRANSACTIONTYPEID,20,b.quantity,49,b.quantity,32,b.quantity,40,b.quantity,59,-b.quantity,21,-b.quantity,141,b.quantity,142,-b.quantity,0)) as FinishLoss,
 sum(decode(a.KNTITRANSACTIONTYPEID,20,b.quantity,49,b.quantity,32,b.quantity,40,b.quantity,59,-b.quantity,141,b.quantity,142,-b.quantity,0)) as FinishConsump
 from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c,t_workorder e
 where a.StockID=b.StockID and
 a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
 b.orderno=e.orderno and
 e.ORDERDATE between vSDate and vEDate
 GROUP BY to_char(e.ORDERDATE,'YYYY'),to_char(e.ORDERDATE,'MM'),to_char(e.ORDERDATE,'MON')
 order by to_char(e.ORDERDATE,'YYYY'),to_char(e.ORDERDATE,'MM');
END ATLLossSummary;
/

PROMPT CREATE OR REPLACE Procedure  440:: InsertRecOnetoMany
CREATE OR REPLACE Procedure InsertRecOnetoMany (
  pStockId in number,
  ppId in number,
  pOrderNo in number,
  pCtnType in varchar2,
  pRecsAffected out number
)
AS  
BEGIN 
  pRecsAffected:=0; 
  for rec in(select a.ORDERNO,b.SHADE,b.STYLE,b.SIZEID,b.QUANTITY,b.PUNIT  from T_CTN a,T_CTNItems b
      where a.CTNID=b.CTNID and a.ORDERNO=pOrderNo and a.CTNTYPE=pCtnType) 
  Loop
		insert into T_gStockItems (PID,GTransTypeId,StockId,GSTOCKITEMSL, CURRENTSTOCK,OrderNo,
                          PunitOfMeasId,Shade,styleno,sizeid,ITEMCHALLAN,Quantity) values
                (SEQ_GStockItemID.NEXTVAL,25,pStockId ,(select nvl(max(GSTOCKITEMSL),0)+1 from T_gStockItems where StockId=pStockId),
				rec.QUANTITY,rec.ORDERNO,rec.PUNIT,rec.SHADE,rec.STYLE,rec.SIZEID,ppId,0);
		commit;
		pRecsAffected:=SQL%ROWCOUNT+pRecsAffected; 
  End Loop;
END InsertRecOnetoMany;
/	

PROMPT CREATE OR REPLACE Procedure  441:: getCandFInfo
CREATE OR REPLACE Procedure getCandFInfo
(
  data_cursor IN OUT pReturnData.c_Records,  
  pCandFID in varchar2  
)
AS
BEGIN
  OPEN data_cursor for
   Select CANDFNAME, CANDFID, CANDFADDRESS,
    Telephone,Remarks from T_CANDF
	where pCandFID is null or CANDFID=pCandFID
	order by CANDFNAME;
END getCandFInfo;
/
PROMPT CREATE OR REPLACE Procedure  442:: GetCTNInfo
CREATE OR REPLACE Procedure GetCTNInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  many_cursor IN OUT pReturnData.c_Records,
  pCtnID number
)
AS
BEGIN

    open one_cursor for
		select CTNID,orderno,CTNType,CTNSize from T_CTN
		where CTNID=pCtnID;

    open many_cursor for
		select PID,SL,CTNID,Shade,Style,SizeID,Quantity,Punit
		from T_CTNItems
		where CTNID=pCtnID
    order by SL asc;
END GetCTNInfo;
/
PROMPT CREATE OR REPLACE Procedure  443:: getTreeCTNList
CREATE OR REPLACE Procedure getTreeCTNList (
  io_cursor IN OUT pReturnData.c_Records,
  pQType IN NUMBER,
  pOrderNo IN NUMBER,
  pCtnType IN VARCHAR2
)
AS
BEGIN
  if pQType=0 then
    OPEN io_cursor FOR
		select CTNID,getfncDispalyorder(orderno) as DOrderno,CTNType from T_CTN A 
		order by orderno,CTNType desc;
  End if;	
END getTreeCTNList;
/
PROMPT CREATE OR REPLACE Procedure  444:: BudgetUnlock
Create or Replace Procedure BudgetUnlock
(
	pBUDGETID IN NUMBER,
	pUserID Varchar2,
	pPassword varchar2,
	pRecsAffected out NUMBER
)
AS
	uid varchar2(50);
	formid varchar2(50);
	id number;
	execep_login_failed Exception;
	execep_auth_failed Exception;
BEGIN
	select count(*) into id from t_employee where Employeeid=pUserID and Emppassword=pPassword;
	if(id=0) then
		Raise execep_login_failed;
	Else 
		select Employeeid into uid from t_Athurization where employeeid=pUserID;
		pRecsAffected:=100;
		if (uid=pUserID) then
			update t_budget set complete=0,AUTHORIZEDID=uid where budgetid=pBUDGETID;
		else
			Raise No_data_found ;
		End if;
	END IF;
	EXCEPTION
		WHEN execep_login_failed then
			pRecsAffected:=98;
		WHEN No_data_found then
			pRecsAffected:=99;
END BudgetUnlock;
/
PROMPT CREATE OR REPLACE Procedure  445:: getDchargetotal
create or replace Procedure getDchargetotal
(
 data_cursor IN OUT pReturnData.c_Records,
 pWhereValue number
)
AS
BEGIN
 OPEN data_cursor for
select a.budgetid,a.PARAMID,b.PARAMETERNAME,d.fabrictype as fabrictype,sum(quantity) as netqty,sum(totalcost) as reqty
   from t_kdfcost a, t_budgetparameter b,t_fabricconsumption c,t_fabrictype d
   where  a.ppid=c.pid(+) and c.fabrictypeid=d.fabrictypeid(+) and
   a.paramid=b.paramid and
   a.budgetid=pWhereValue and a.stageid=4 group by a.budgetid,a.PARAMID,b.PARAMETERNAME,d.fabrictype,a.ppid order by a.ppid;
END getDchargetotal;
/

PROMPT CREATE OR REPLACE Procedure  446:: GetBParameterList
CREATE OR REPLACE Procedure GetBParameterList
(
  pStatus number,  
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
/*if the Value is 0 then retun all the Data */
if pStatus=0 then
  OPEN data_cursor for
    Select  PARAMID,PARAMETERNAME,PARAMETERORDER,UNITOFMEASID
    from t_budgetParameter order by PARAMETERORDER;
end if;
END GetBParameterList;
/
PROMPT CREATE OR REPLACE Procedure  447:: ShipmentTree
Create or Replace Procedure ShipmentTree (
  io_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  sDate IN date,
  eDate IN date,
  plctype in number
)
AS
BEGIN

  if pQueryType=0 then
    OPEN io_cursor FOR
    select pid,INVOICENO from T_Shipmentinfo a, t_lcinfo b
    where a.lcno=b.lcno and INVOICEDATE>=SDate and INVOICEDATE<=EDate  and b.explctypeid=plctype
    order by (INVOICENO) desc;
  elsif pQueryType=1 then
    OPEN io_cursor FOR
    select pid,INVOICENO,INVOICEDATE from T_Shipmentinfo a, t_lcinfo b
    where a.lcno=b.lcno and INVOICEDATE>=SDate and INVOICEDATE<=EDate  and b.explctypeid=plctype
    order by INVOICEDATE desc, INVOICENO desc;
	 elsif pQueryType=2 then
    OPEN io_cursor FOR
    select pid,INVOICENO,EXPNO from T_Shipmentinfo a, t_lcinfo b
    where a.lcno=b.lcno and INVOICEDATE>=SDate and INVOICEDATE<=EDate  and b.explctypeid=plctype
    order by INVOICEDATE desc, INVOICENO desc;
  end if;
END ShipmentTree;
/
PROMPT CREATE OR REPLACE Procedure  448:: GetRptPermissionCheck
CREATE OR REPLACE Procedure GetRptPermissionCheck(
  pUser IN VARCHAR2,
  pRptId IN VARCHAR2,
  pRecsAffected out NUMBER
)
AS
BEGIN
    if(pUser='MIS' or pUser='evp') then
		pRecsAffected:=1;	
	else
		SELECT NVL(MAX(COUNT(*)),0) INTO pRecsAffected FROM T_ReportAccess 
		WHERE ReportId=pRptId AND
			EmployeeId=pUser and 
			bAccess=2
		GROUP BY EmployeeId,ReportId;
	End If;
END GetRptPermissionCheck;
/
PROMPT CREATE OR REPLACE Procedure  449:: GetBudgetList
Create or replace Procedure GetBudgetList
(
  data_cursor IN OUT pReturnData.c_Records,
  pQuerytype number,
  pBtype varchar2
)
AS
BEGIN
if(pQuerytype=1) then
    OPEN data_cursor for
    Select Budgetid,getfncBOType(a.BUDGETID) as BNo,a.ORDERTYPEID  from T_Budget a
where a.ORDERTYPEID=pBtype and a.revision=65 order by to_number(budgetno) desc;

elsif(pQuerytype=2) then
    OPEN data_cursor for
    Select Budgetid,getfncBOType(a.BUDGETID) as BNo,a.ORDERTYPEID  from T_Budget a
where a.ORDERTYPEID in('S','SF') and a.revision=65 order by to_number(budgetno) desc;
end if;
END GetBudgetList;
/


PROMPT CREATE OR REPLACE Procedure  450:: GetFORMS
CREATE OR REPLACE Procedure GetFORMS
(
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
  OPEN data_cursor for
   select FORMID,FORMDESC,FORMGROUPID,FORMSERIAL
    from T_FORMS order by FORMID;
END GetFORMS;
/

PROMPT CREATE OR REPLACE Procedure  451:: GetPROJECTFORMSLOOKUP
CREATE OR REPLACE Procedure GetPROJECTFORMSLOOKUP
(
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
  OPEN data_cursor for
   select FORMGROUPID,FORMGROUP
    from T_FORMGROUP order by FORMGROUPID;
END GetPROJECTFORMSLOOKUP;
/
PROMPT CREATE OR REPLACE Procedure  452:: GetReportFormListLOOKUP
CREATE OR REPLACE Procedure GetReportFormListLOOKUP
(
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
  OPEN data_cursor for
   select REPORTGROUPID,REPORTGROUP
    from T_REPORTGROUP order by REPORTGROUPID;
END GetReportFormListLOOKUP;
/
PROMPT CREATE OR REPLACE Procedure  453:: GetReportForm
CREATE OR REPLACE Procedure GetReportForm
(
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
  OPEN data_cursor for
   select REPORTID,REPORTGROUPID,REPORTBY,REPORTTITLE,RPTOLDNAME
    from T_REPORTLIST order by REPORTID;
END GetReportForm;
/


PROMPT CREATE OR REPLACE Procedure  454:: GetSubconList
CREATE OR REPLACE Procedure GetSubconList
(
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
  OPEN data_cursor for
    select SUBCONID,SUBCONNAME,SUBADDRESS,SUBFACTORYADDRESS,SUBTELEPHONE,SUBFAX,SUBEMAIL,                       
	SUBURL,SUBCONTACTPERSON,SUBACCOUNTCODE,SUBREMARKS,SUBCONGROUPID,SUBCONSTATUS   
	from T_SUBCONTRACTORS 
	order by SUBCONNAME;
END GetSubconList;
/

PROMPT CREATE OR REPLACE Procedure  455:: ShipmentWiseTransaction

create or Replace Procedure ShipmentWiseTransaction(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pOrderNo NUMBER,
  sDate IN date,
  eDate IN date
)
AS
BEGIN
/*Cutting Parts Send to Print or Embroidary  */
if (pQueryType=1) then
    open data_cursor for
    select a.Invoiceid,a.Invoiceno,a.InvoiceDATE,a.CHALLANNO,a.CHALLANDATE,a.GatepassNo,f.CLIENTNAME,e.CANDFNAME,
	    '' as ORDERNO,b.CTNTYPE,'' as SAMPLETYPE,'' as STYLENO,'' as SIZENAME,
        '' as SHADE,b.RETURNABLE,b.NONRETURNABLE,b.RETURNEDQTY,b.QUANTITY,b.SQUANTITY,b.CurrentStock,d.UNITOFMEAS as UNIT,b.CBM		
	from T_GDELIVERYCHALLAN a, T_GDELIVERYCHALLANItems b,T_Unitofmeas d,T_CANDF e,T_Client f	 	
    where	a.Invoiceid=b.Invoiceid and
	        b.OrderNo=pOrderNo	and
			a.CANDFID=e.CANDFID and
			a.CLIENTID=f.CLIENTID and
			a.INVOICEDATE between sDate and eDate AND
			a.catid=14 and
			b.PUNITOFMEASID=d.UNITOFMEASID
    ORDER BY a.Invoiceno,a.InvoiceDATE,a.GatepassNo,f.CLIENTNAME,e.CANDFNAME,b.CTNTYPE,b.QUANTITY,b.SQUANTITY,
	b.CBM;

elsif (pQueryType=2) then
    open data_cursor for
	    select a.Invoiceid,a.Invoiceno,a.InvoiceDATE,a.CHALLANNO,a.CHALLANDATE,a.GatepassNo,f.CLIENTNAME,'' as CANDFNAME,
	    '' as ORDERNO,b.CTNTYPE,g.SAMPLETYPE,b.STYLENO,h.SIZENAME,
        b.SHADE,b.RETURNABLE,b.NONRETURNABLE,b.RETURNEDQTY,b.QUANTITY,b.SQUANTITY,b.CurrentStock,d.UNITOFMEAS as UNIT,b.CBM		
	from T_GDELIVERYCHALLAN a, T_GDELIVERYCHALLANItems b,T_Unitofmeas d,T_Client f,T_GSampleType g,T_SIZE h	 	
    where	a.Invoiceid=b.Invoiceid and
	        b.OrderNo=pOrderNo	and
			b.SIZEID=h.SIZEID and
			b.SampleID=g.SampleID and
			a.CLIENTID=f.CLIENTID and
			a.INVOICEDATE between sDate and eDate AND
			a.catid=15 and
			b.PUNITOFMEASID=d.UNITOFMEASID
    ORDER BY a.Invoiceno,a.InvoiceDATE,a.GatepassNo,f.CLIENTNAME,b.CurrentStock,b.QUANTITY,b.RETURNEDQTY,
	b.NONRETURNABLE,b.RETURNABLE;

	End If;
END ShipmentWiseTransaction;
/

PROMPT CREATE OR REPLACE Procedure  456:: GetGSDeliveryChalanInfo
CREATE OR REPLACE Procedure GetGSDeliveryChalanInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  many_cursor IN OUT pReturnData.c_Records,
  pInvoiceid number
)
AS
BEGIN
    open one_cursor for
     select Invoiceid,ChallanNo, ChallanDate, Invoiceno, InvoiceDATE,EMPLOYEEID,
      ClientID,Remarks, SubConId,Pono,GatepassNo,catid,contactperson,deliveryplace,orderno,
  VEHICLENO,DRIVERNAME,DRIVERLICENSENO,DRIVERMOBILENO,TRANSCOMPNAME,CANDFID,DELORDERTYPEID,REMARKS
  from T_GDELIVERYCHALLAN
  where Invoiceid=pInvoiceid;

    open many_cursor for
     select a.PID,a.ORDERNO,a.Invoiceid,a.GSTOCKITEMSL,SAMPLEID,RETURNABLE,NONRETURNABLE,RETURNEDQTY,a.Quantity,a.Squantity,a.PunitOfmeasId,
  a.SUNITOFMEASID,a.SIZEID,a.BatchNo,a.Shade,a.REMARKS,a.CurrentStock,a.Styleno,a.countryid,a.Cartonno,a.CTNTYPE,a.CBM,a.ITEMSDESC
  from T_GDELIVERYCHALLANItems a
  where a.Invoiceid=pInvoiceid
  order by GSTOCKITEMSL asc;
END GetGSDeliveryChalanInfo;
/




PROMPT CREATE OR REPLACE Procedure  457:: GetTDWorkOrderList
Create or Replace Procedure GetTDWorkOrderList
(
  data_cursor IN OUT pReturnData.c_Records,
  pBasictypeid varchar2
)
AS
BEGIN
	OPEN data_cursor for
    	Select Basictypeid,Basictypeid || ' ' || DORDERNO as TDORDERNO,ORDERNO,DORDERNO
	from T_workorder where Basictypeid=pBasictypeid ORDER BY TDORDERNO DESC;

END GetTDWorkOrderList;
/


PROMPT CREATE OR REPLACE Procedure  458:: GetAccStockAdjustPosition
Create or Replace Procedure GetAccStockAdjustPosition(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pAccGroup NUMBER,
  pStockDate DATE
)
AS
BEGIN

 /* View the main Stock */
  if pQueryType=2 then
     /* View all group*/
    if(pAccGroup=-1) then
    	open data_cursor for
    	select b.StockID,b.GroupID,b.AccessoriesID,b.GORDERNO, b.OrderNo, b.StyleNo, b.ColourID, r.ColourName, b.code, c.Item, b.Count_Size,b.PUnitOfMeasId,u.UnitOfMeas, sum(b.Quantity*t.AccStockMain) CurrentStock
    	from T_AccStock a, T_AccStockItems b,T_accessories c, T_UnitOfMeas u, T_AccTransactionType t, T_Colour r
    	where  a.StockID=b.StockID and
	t.AccTransTypeID=a.AccTransTypeID and
    	b.AccessoriesID=c.AccessoriesID and
	b.PUnitOfMeasID=u.UnitOfMeasID and
	b.ColourID=r.ColourID and
	StockTransDate<=pStockDate
	group by b.StockID,b.GroupID,b.AccessoriesID,b.Count_Size,c.Item,b.code,b.colourID,r.colourName, b.PUnitOfMeasId, u.UnitOfMeas,b.StyleNo,b.GORDERNO, b.OrderNo
	having  sum(b.Quantity*t.AccStockMain)>0
	order by c.Item  desc,b.code  desc,b.Count_Size desc,b.OrderNo desc,b.StyleNo,b.ORDERNO desc;
    /* View specific group*/
    elsif(pAccGroup<>-1) then
     	open data_cursor for
    	select b.StockID,b.GroupID,b.AccessoriesID,b.GORDERNO, b.OrderNo, b.StyleNo, b.ColourID,r.ColourName, b.code, c.Item, b.Count_Size,b.PUnitOfMeasId,u.UnitOfMeas, sum(b.Quantity*t.AccStockMain) CurrentStock
    	from T_AccStock a, T_AccStockItems b,T_accessories c, T_UnitOfMeas u, T_AccTransactionType t, T_Colour r
    	where  a.StockID=b.StockID and
	t.AccTransTypeID=a.AccTransTypeID and
    	b.AccessoriesID=c.AccessoriesID and
	b.PUnitOfMeasID=u.UnitOfMeasID and
	b.ColourID=r.ColourID and
	b.GroupID=pAccGroup and
	StockTransDate<=pStockDate
	group by b.StockID,b.GroupID,b.AccessoriesID,b.Count_Size,c.Item,b.code,b.colourID,r.colourName, b.PUnitOfMeasId, u.UnitOfMeas, b.StyleNo,b.OrderNo,b.GORDERNO
	having  sum(b.Quantity*t.AccStockMain)>0
	order by  c.Item  desc,b.code  desc,b.Count_Size desc,b.OrderNo desc,b.StyleNo desc;
    end if;
  /* View the sub store Stock */
  elsif pQueryType=3 then
    /* View all group*/
    if(pAccGroup=-1) then
    	open data_cursor for
	select b.StockID,b.LineNo, b.GroupID,b.AccessoriesID,b.GORDERNO, b.OrderNo, b.StyleNo, b.ColourID, r.ColourName, b.code, c.Item, b.Count_Size,b.PUnitOfMeasId,u.UnitOfMeas, sum(b.Quantity*t.AccStockSub) CurrentStock
    	from T_AccStock a, T_AccStockItems b,T_accessories c, T_UnitOfMeas u, T_AccTransactionType t, T_Colour r
    	where  a.StockID=b.StockID and
	t.AccTransTypeID=a.AccTransTypeID and
    	b.AccessoriesID=c.AccessoriesID and
	b.PUnitOfMeasID=u.UnitOfMeasID and
	b.ColourID=r.ColourID and
	StockTransDate<=pStockDate
	group by b.StockID,b.LineNo, b.GroupID,b.AccessoriesID,b.Count_Size,c.Item,b.code,b.colourID,r.colourName, b.PUnitOfMeasId, u.UnitOfMeas,b.StyleNo,b.OrderNo,b.GORDERNO
	having  sum(b.Quantity*t.AccStockSub)>0
	order by c.Item  desc,b.code  desc,b.Count_Size desc,b.OrderNo desc,b.StyleNo desc;
    /* View specific group*/
    elsif(pAccGroup<>-1) then
     	open data_cursor for
    	select b.StockID,b.LineNo, b.GroupID,b.AccessoriesID,b.GORDERNO, b.OrderNo, b.StyleNo, b.ColourID, r.ColourName, b.code, c.Item, b.Count_Size,b.PUnitOfMeasId,u.UnitOfMeas, sum(b.Quantity*t.AccStockSub) CurrentStock
    	from T_AccStock a, T_AccStockItems b,T_accessories c, T_UnitOfMeas u, T_AccTransactionType t, T_Colour r
    	where  a.StockID=b.StockID and
	t.AccTransTypeID=a.AccTransTypeID and
    	b.AccessoriesID=c.AccessoriesID and
	b.PUnitOfMeasID=u.UnitOfMeasID and
	b.ColourID=r.ColourID and
	b.GroupID=pAccGroup and
	StockTransDate<=pStockDate
	group by b.StockID,b.LineNo, b.GroupID,b.AccessoriesID,b.Count_Size,c.Item,b.code,b.colourID,r.colourName, b.PUnitOfMeasId, u.UnitOfMeas,b.StyleNo,b.OrderNo,b.GORDERNO
	having  sum(b.Quantity*t.AccStockSub)>0
	order by c.Item  desc,b.code  desc,b.Count_Size desc,b.OrderNo desc,b.StyleNo desc;
    end if;
  end if;
END GetAccStockAdjustPosition;
/



PROMPT CREATE OR REPLACE Procedure  459:: GetGarmentBillWorkOrderList
CREATE OR REPLACE Procedure GetGarmentBillWorkOrderList
(
  data_cursor IN OUT pReturnData.c_Records,
  pStatus number,
  pClient  VARCHAR2,
  pBasictype varchar2

)
AS
BEGIN
/*if the Value is 0 then retun all the Data */

if pStatus=1 then
  OPEN data_cursor for
   Select a.OrderLineItem,a.GORDERNO,getfncGWOBType(a.GORDERNO) as Gbtype,a.STYLE,a.COUNTRYID,
   a.PRICE,a.Shade,a.REMARKS,
   a.QUANTITY AS ORDQTY,
   NVL((SELECT SUM(QUANTITY) FROM T_DINVOICEITEMS
   WHERE ORDERNO=a.GORDERNO),0) AS DELQTY,
   NVL((SELECT SUM(SQUANTITY) FROM T_DINVOICEITEMS
   WHERE ORDERNO=a.GORDERNO),0) AS DELSQTY,
   NVL((SELECT SUM(BILLITEMSQTY) FROM T_GBILLITEMS
   WHERE GORDERNO=a.GORDERNO AND WOITEMSL=a.WOITEMSL),0) AS  BILLQTY,
  (a.QUANTITY-(NVL((SELECT SUM(BILLITEMSQTY) FROM T_GBILLITEMS
   WHERE GORDERNO=a.GORDERNO AND WOITEMSL=a.WOITEMSL),0))) AS REMQTY,
   a.woitemsl,b.Ordertypeid ,c.UNITOFMEAS as UNIT
   from T_GOrderitems a,t_gworkorder b,T_UnitOfMeas c
   where a.gorderno=b.gorderno and b.clientid=pClient and b.Ordertypeid=pBasictype
   and a.UNITOFMEASID=c.UNITOFMEASID
   and (a.QUANTITY-(NVL((SELECT SUM(BILLITEMSQTY) FROM T_GBILLITEMS
   WHERE GORDERNO=a.GORDERNO AND WOITEMSL=a.WOITEMSL),0)))>0 ;
end if;
END GetGarmentBillWorkOrderList;
/





PROMPT CREATE OR REPLACE Procedure  460:: GetGBillInfo
CREATE OR REPLACE Procedure GetGBillInfo
(
	one_cursor IN OUT pReturnData.c_Records,
	many_cursor IN OUT pReturnData.c_Records,	
	pOrdercode in varchar2,	
	pBillNo in NUMBER
)
AS
BEGIN
	open one_cursor for
	select ORDERCODE,BILLNO,BILLDATE,CLIENTID,BILLDISCOUNT,BILLDISCOMMENTS,BILLDISPERC,KNITTING,DYEING,FABRIC,
	CURRENCYID,CONRATE,CANCELLED,BILLCOMMENTS,EMPLOYEEID from T_GBILL
	where BillNo=pBillNo and ORDERCODE=pOrdercode;

	open many_cursor for
        SELECT  a.ORDERCODE,a.BILLNO,a.BILLITEMSL,a.DORDERCODE,a.DINVOICENO,a.DITEMSL,a.WORDERCODE,a.GORDERNO,               
 		a.WOITEMSL,a.BILLITEMSQTY,a.BILLITEMSUNITPRICE,a.COLORDEPTHID           
        FROM T_GBILLITEMS a,T_GBILL b
        WHERE  a.ordercode=b.ordercode AND a.BILLNO=b.BILLNO AND 
		    a.BILLNO=pBillNo and a.ORDERCODE=pOrdercode 
  		ORDER BY BILLITEMSL;    
END GetGBillInfo;
/




PROMPT CREATE OR REPLACE Procedure  461:: GetGBillPaymentIDs
CREATE OR REPLACE PROCEDURE GetGBillPaymentIDs(
  data_cursor IN OUT pReturnData.c_Records,  
  pbill IN NUMBER,
  pocode in varchar2
)
AS  
BEGIN
  OPEN data_cursor  FOR
  SELECT billno,billpayitemsl,gorderno,billpmtdate,billwopmt,ordercode from T_GBillPayment 
     where billno=pbill and ordercode=pocode order by BILLPAYITEMSL;         
END GetGBillPaymentIDs;
/


PROMPT CREATE OR REPLACE Procedure  462:: getGBillTree
CREATE OR REPLACE Procedure getGBillTree (
  tree_cursor IN OUT pReturnData.c_Records,
  pOrderCode varchar2,
  pGroupID number,
  pStartDate date,
  pEndDate date
)
AS
BEGIN
  /* Order No Assecndig*/
  if pGroupID=0 then
    open tree_cursor for
    select BillNo,Billno as BBillNO
    from T_GBill
    where BillDate between pStartDate and pEndDate and Ordercode=pOrderCode
    order by BILLNO desc;
 /* Order Date */
  elsif pGroupID = 1 then
    open tree_cursor for
    select BillNo,BillDate
    from T_GBill
    where BillDate between pStartDate and pEndDate and Ordercode=pOrderCode
    order by BillDate, BILLNO desc;
 /* Client Name */
  elsif pGroupID = 2 then
    open tree_cursor for
    select BillNo,ClientName
    from T_GBill,T_Client
    where T_GBILL.ClientID=T_Client.ClientID and
    BillDate between pStartDate and pEndDate and Ordercode=pOrderCode
    order by ClientName, BILLNO desc;
  end if;

END getGBillTree;
/


PROMPT CREATE OR REPLACE Procedure  463:: GetGbillWOList
CREATE OR REPLACE PROCEDURE GetGbillWOList(
  data_cursor IN OUT pReturnData.c_Records,  
  pBillno IN NUMBER,
  pOrdercode in varchar2
)
AS  
BEGIN
  OPEN data_cursor  FOR
  SELECT gorderno,GetfncGWOBType(gorderno)as btype
  from T_GBillItems where billno=pBillno and ordercode=pOrdercode group by gorderno order by GetfncGWOBType(gorderno);         
END GetGbillWOList;
/


PROMPT CREATE OR REPLACE Procedure  464:: GetGClientInfo
CREATE OR REPLACE Procedure GetGClientInfo
(
  pStatus number,
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
/*if the Value is 0 then retun all the Data */
if pStatus=0 then
  OPEN data_cursor for
    select CLIENTID, CLIENTNAME,CLIENTSTATUSID,
     CADDRESS,CFACTORYADDRESS,CTELEPHONE,
     CFAX,CEMAIL,CURL,CCONTACTPERSON, CACCCODE,
     CREMARKS,CLIENTGROUPID  from T_Client order by CLIENTNAME;
/*If the Value is 1 then retun as the */
elsif pStatus=1 then
  OPEN data_cursor for
   select CLIENTID, CLIENTNAME,CLIENTSTATUSID,
     CADDRESS,CFACTORYADDRESS,CTELEPHONE,
     CFAX,CEMAIL,CURL,CCONTACTPERSON, CACCCODE,
     CREMARKS,CLIENTGROUPID  from T_Client where
     clientid=pWhereValue order by CLIENTNAME;
end if;
END GetGClientInfo;
/


PROMPT CREATE OR REPLACE Procedure  465:: GetGCurrencyLookUp
CREATE OR REPLACE Procedure GetGCurrencyLookUp
(
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
  OPEN data_cursor for
    Select CurrencyID,CurrencyName,ConRate,eConRate
 from T_Currency order by CurrencyName;
END GetGCurrencyLookUp;
/



PROMPT CREATE OR REPLACE Procedure  466:: GetGFabricType
CREATE OR REPLACE Procedure GetGFabricType
(
  pStatus number,
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
/*if the Value is 0 then retun all the Data */
if pStatus=0 then
  OPEN data_cursor for
  select fabrictypeID,fabrictype from t_fabrictype order by fabrictype;
/*If the Value is 1 then retun as the */
elsif pStatus=1 then
  OPEN data_cursor for
   select fabrictypeID,fabrictype from t_fabrictype
  where fabrictypeID=pWhereValue order by fabrictype;
end if;
END GetGFabricType;
/


PROMPT CREATE OR REPLACE Procedure  467:: GetGGordertypeLookup
CREATE OR REPLACE Procedure GetGGordertypeLookup
(
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
  OPEN data_cursor for
  select ORDERTYPE,DESCRIPTION ||' (' || ORDERTYPE|| ')'  AS DESCRIPTION from t_gordertype;

END GetGGordertypeLookup;
/


PROMPT CREATE OR REPLACE Procedure  468:: getGGWorkorderTree
CREATE OR REPLACE Procedure getGGWorkorderTree (
  tree_cursor IN OUT pReturnData.c_Records,
  pOrdercode varchar2,
  pGroupID number,
  pStartDate date,
  pEndDate date
)
AS
BEGIN
  /* Order No Descending by Date*/
  if pGroupID=0 then
    open tree_cursor for
    select GOrderNo,GdorderNO AS Gdorder
    from T_GWorkOrder
    where GOrderDate between pStartDate and pEndDate and ORDERTYPEID=pOrdercode
    order by GdorderNO desc;
 /* Order Date */
  elsif pGroupID = 1 then
    open tree_cursor for
    select GOrderNo,GdorderNO AS Gdorder, GOrderDate
    from T_GWorkOrder
    where GOrderDate between pStartDate and pEndDate and ORDERTYPEID=pOrdercode
    order by GOrderDate desc;
 /* Client Name */
  elsif pGroupID = 2 then
    open tree_cursor for
    select GOrderNo,GdorderNO AS Gdorder, ClientName
    from T_GWorkOrder, T_Client
    where T_GWorkOrder.ClientID=T_Client.ClientID and
    GOrderDate between pStartDate and pEndDate and ORDERTYPEID=pOrdercode
    order by ClientName,GdorderNO desc;
  /* Sales Person*/
  elsif pGroupID = 3 then
    open tree_cursor for
    select GOrderNo,GdorderNO AS Gdorder, EmployeeName
    from T_GWorkOrder, T_Employee
    where T_GWorkOrder.SalesPersonID=T_Employee.EmployeeID and
    GOrderDate between pStartDate and pEndDate and ORDERTYPEID=pOrdercode
    order by EmployeeName,GdorderNO desc;
  /* Combo Fillup Assecndig*/
  elsif pGroupID=99 then
    open tree_cursor for
    select GOrderNo,GetfncGWOBType(GDOrderNo) as Gdorder
    from T_GWorkOrder
    where GOrderDate between pStartDate and pEndDate
    order by ORDERTYPEID,Gdorderno desc;
  end if;
End getGGWorkorderTree;
/


PROMPT CREATE OR REPLACE Procedure  469:: GetGUnitOfMeasList
CREATE OR REPLACE Procedure GetGUnitOfMeasList
(
  pStatus number,
  pWhereValue varchar2,
  data_cursor IN OUT pReturnData.c_Records
)
AS

BEGIN
/*if the Value is 0 then retun all the Data */
if pStatus=0 then
	OPEN data_cursor for
    Select UnitOfMeas, UnitOfMeasID 
	from T_UnitOfMeas 
	order by UnitOfMeas;
/*If the Value is 1 then retun as the */
elsif pStatus=1 then
	OPEN data_cursor for
    Select 	UnitOfMeas, UnitOfMeasID 
	from 	T_UnitOfMeas
	where 	UnitOfMeasID=pWhereValue 
	order by UnitOfMeas;
elsif pStatus=2 then
	OPEN data_cursor for
    Select UnitOfMeas, UnitOfMeasID 
	from 	T_UnitOfMeas	
	order by UnitOfMeas;
end if;
END GetGUnitOfMeasList;
/


PROMPT CREATE OR REPLACE Procedure  470:: GetGSHADEGROUPNAMEList
CREATE OR REPLACE Procedure GetGSHADEGROUPNAMEList
(
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
    OPEN data_cursor for
    Select SHADEGROUPID,SHADEGROUPNAME  from T_SHADEGROUP order by SHADEGROUPNAME;
END GetGSHADEGROUPNAMEList;
/


PROMPT CREATE OR REPLACE Procedure  471 :: GetscGOrdertypeInfo
CREATE OR REPLACE Procedure GetscGOrdertypeInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  pBasictypeid varchar2
)
AS
BEGIN
    open one_cursor for
    select max(gdorderno) from T_scGWorkOrder where ordertypeid=pBasictypeid ;    
END GetscGOrdertypeInfo;
/

   
PROMPT CREATE OR REPLACE Procedure  472 :: GetSCGWorkorderInfo
CREATE OR REPLACE Procedure GetSCGWorkorderInfo
(
	one_cursor IN OUT pReturnData.c_Records,
	many_cursor IN OUT pReturnData.c_Records,
	basictype_cursor  IN OUT pReturnData.c_Records,
	pOrderNo NUMBER
)
AS
BEGIN
	open one_cursor for
	select SCGORDERNO,GORDERNO,GDORDERNO,ORDERTYPEID,GORDERDATE,CLIENTID,SALESTERMID,CURRENCYID,CONRATE,SALESPERSONID,WCANCELLED,WREVISED,
	ORDERSTATUSID,CONTACTPERSON,CLIENTSREF,DELIVERYPLACE,DELIVERYSTARTDATE,DELIVERYENDDATE,DAILYPRODUCTIONTARGET,
	TERMOFDELIVERY,TERMOFPAYMENT,SEASON,COSTINGREFNO,QUOTEDPRICE,ORDERREMARKS from T_SCGWorkOrder
	where SCGORDERNO=pOrderNo;

	open many_cursor for
	select a.ORDERLINEITEM,a.WOITEMSL, a.SCGORDERNO, a.STYLE, a.COUNTRYID, a.SHADE,a.PRICE,a.UNITOFMEASID,a.QUANTITY,a.CURRENTSTOCK,a.DELIVERYDATE,a.REMARKS,b.ORDERTYPEID,getgsizeDesc(ORDERLINEITEM) as SizeDesc,a.TORDERLINEITEMREF
	from T_SCGOrderItems a,T_SCGWorkOrder b
	where a.SCGORDERNO=b.SCGORDERNO and a.SCGORDERNO=pOrderNo order by WoItemSl;
END GetSCGWorkorderInfo;
/

PROMPT CREATE OR REPLACE Procedure  473 :: GETCopySCGWOLineItems
CREATE OR REPLACE Procedure GETCopySCGWOLineItems(
  pGOrderNo IN NUMBER,
  pGOrderLineItemID IN VARCHAR2,
  pRecsAffected out NUMBER
)
AS
  insertTmpSql VARCHAR2(1000);
  tmpOrderItem NUMBER;
  tmpSlNoSql NUMBER;
BEGIN
   SELECT MAX(to_number(ORDERLINEITEM))+1 into tmpOrderItem from T_SCGORDERITEMS;
   SELECT MAX(WOITEMSL)+1 into tmpSlNoSql from T_SCGORDERITEMS where SCGORDERNO=pGOrderNo;

   insert into T_SCGORDERITEMS (ORDERLINEITEM,WOITEMSL,SCGORDERNO,STYLE,COUNTRYID,SHADE,PRICE,QUANTITY,UNITOFMEASID,DELIVERYDATE,REMARKS)
    select tmpOrderItem,tmpSlNoSql,SCGORDERNO,STYLE,COUNTRYID,SHADE,0,0,UNITOFMEASID,DELIVERYDATE,REMARKS
	from T_SCGORDERITEMS where ORDERLINEITEM=pGOrderLineItemID;  
   pRecsAffected := SQL%ROWCOUNT;

END GETCopySCGWOLineItems;
/

PROMPT CREATE OR REPLACE Procedure  474 :: getSCGWorkorderTree
CREATE OR REPLACE Procedure getSCGWorkorderTree (
  tree_cursor IN OUT pReturnData.c_Records,
  pOrdertype varchar2,
  pGroupID number,
  pStartDate date,
  pEndDate date
)
AS
BEGIN
  /* Order No Assecndig*/
  if pGroupID=0 then
    open tree_cursor for
    select SCGORDERNO,gdorderNO
    from T_SCGWorkOrder
    where GOrderDate between pStartDate and pEndDate and ordertypeid=pOrdertype
    order by GDORDERNO desc;
 /* Order Date */
  elsif pGroupID = 1 then
    open tree_cursor for
    select SCGORDERNO, gdorderNO,GOrderDate
    from T_SCGWorkOrder
    where GOrderDate between pStartDate and pEndDate and ordertypeid=pOrdertype
    order by GOrderDate desc, GDORDERNO desc;

 /* Client Name */
  elsif pGroupID = 2 then
    open tree_cursor for
    select SCGORDERNO,gdorderNO, ClientName
    from T_SCGWorkOrder, T_Client
    where T_SCGWorkOrder.ClientID=T_Client.ClientID and
    GOrderDate between pStartDate and pEndDate and ordertypeid=pOrdertype
    order by ClientName, GDORDERNO desc;

  /* Sales Person*/
  elsif pGroupID = 3 then
    open tree_cursor for
    select SCGORDERNO,gdorderNO, EmployeeName
    from T_SCGWorkOrder, T_Employee
    where T_SCGWorkOrder.SalesPersonID=T_Employee.EmployeeID and
    GOrderDate between pStartDate and pEndDate and ordertypeid=pOrdertype
    order by EmployeeName, GDORDERNO desc;
  end if;
END getSCGWorkorderTree;
/

PROMPT CREATE OR REPLACE Procedure  475 :: GetSCGWOItemList
create or replace Procedure GetSCGWOItemList
(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType number,
  pOrderno number
)
AS
BEGIN
if (pQueryType=1) then
	OPEN data_cursor for
	select a.ORDERLINEITEM,getgsizeDesc(a.ORDERLINEITEM) as SizeDesc,a.WoItemSl,a.GORDERNO,a.STYLE,a.SHADE,
	a.Price,a.DeliveryDate,a.REMARKS,c.COUNTRYNAME,c.COUNTRYID,b.UNITOFMEAS,b.UNITOFMEASID,
    ((a.Quantity)-DECODE((SELECT SUM(NVL(Quantity,0)) FROM T_SCGOrderItems WHERE TORDERLINEITEMREF=a.OrderLineItem),NULL,0,(SELECT SUM(NVL(Quantity,0)) FROM T_SCGOrderItems WHERE TORDERLINEITEMREF=a.OrderLineItem))) AS Quantity
	from T_GORDERITEMS a, t_country c,T_UnitOfMeas b
	WHERE a.UNITOFMEASID=b.UNITOFMEASID and
	a.COUNTRYID=c.COUNTRYID and
	a.GORDERNO=pOrderno;
End If;
END GetSCGWOItemList;
/

PROMPT CREATE OR REPLACE Procedure  476 :: GetSCGordertypeLookup
CREATE OR REPLACE Procedure GetSCGordertypeLookup
(
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
  OPEN data_cursor for
  select ORDERTYPE,DESCRIPTION ||' (' || ORDERTYPE|| ')'  AS DESCRIPTION from t_SCGordertype;

END GetSCGordertypeLookup;
/


PROMPT CREATE OR REPLACE Procedure  477 :: getSCGorderSize
CREATE OR REPLACE Procedure getSCGorderSize
(
  pWhereValue varchar2,
  pOrderType varchar2,
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
  OPEN data_cursor for
  select GSIZEID,SIZEID,QUANTITY,ORDERLINEITEM,ORDERTYPEID from T_GORDERSIZE
  where ORDERTYPEID=pOrderType and
  orderLineItem=pWhereValue;
END getSCGorderSize;
/


PROMPT CREATE OR REPLACE Procedure  478 :: GetSCGPEWorkorderInfo
CREATE OR REPLACE Procedure GetSCGPEWorkorderInfo
(
	one_cursor IN OUT pReturnData.c_Records,
	many_cursor IN OUT pReturnData.c_Records,
	basictype_cursor  IN OUT pReturnData.c_Records,
	pOrderNo NUMBER
)
AS
BEGIN
	open one_cursor for
	select SCGORDERNO,GORDERNO,GDORDERNO,ORDERTYPEID,GORDERDATE,CLIENTID,SALESTERMID,CURRENCYID,CONRATE,SALESPERSONID,WCANCELLED,WREVISED,
	ORDERSTATUSID,CONTACTPERSON,CLIENTSREF,DELIVERYPLACE,DELIVERYSTARTDATE,DELIVERYENDDATE,DAILYPRODUCTIONTARGET,
	TERMOFDELIVERY,TERMOFPAYMENT,SEASON,COSTINGREFNO,QUOTEDPRICE,ORDERREMARKS from T_SCGWorkOrder
	where SCGORDERNO=pOrderNo;

	open many_cursor for
	select a.ORDERLINEITEM,a.WOITEMSL, a.SCGORDERNO, a.STYLE, a.COUNTRYID, a.SHADE,a.PRICE,a.UNITOFMEASID,a.QUANTITY,a.CURRENTSTOCK,
	a.DELIVERYDATE,a.REMARKS,b.ORDERTYPEID,getgsizeDesc(ORDERLINEITEM) as SizeDesc,a.TORDERLINEITEMREF
	from T_SCGOrderItems a,T_SCGWorkOrder b
	where a.SCGORDERNO=b.SCGORDERNO and a.SCGORDERNO=pOrderNo order by WoItemSl;

END GetSCGPEWorkorderInfo;
/


PROMPT CREATE OR REPLACE Procedure  479 :: GETCopySCGPEWOLineItems
CREATE OR REPLACE Procedure GETCopySCGPEWOLineItems(
  pGOrderNo IN NUMBER,
  pGOrderLineItemID IN VARCHAR2,
  pRecsAffected out NUMBER
)
AS
  insertTmpSql VARCHAR2(1000);
  tmpOrderItem NUMBER;
  tmpSlNoSql NUMBER;
BEGIN

   SELECT MAX(to_number(ORDERLINEITEM))+1 into tmpOrderItem from T_SCGORDERITEMS;
   SELECT MAX(WOITEMSL)+1 into tmpSlNoSql from T_SCGORDERITEMS where SCGORDERNO=pGOrderNo;

   insert into T_SCGORDERITEMS (ORDERLINEITEM,WOITEMSL,SCGORDERNO,STYLE,COUNTRYID,SHADE,PRICE,QUANTITY,UNITOFMEASID,DELIVERYDATE,REMARKS)
     select tmpOrderItem,tmpSlNoSql,SCGORDERNO,STYLE,COUNTRYID,SHADE,0,0,UNITOFMEASID,DELIVERYDATE,REMARKS
	 from T_SCGORDERITEMS where ORDERLINEITEM=pGOrderLineItemID; 
    pRecsAffected := SQL%ROWCOUNT;
END GETCopySCGPEWOLineItems;
/



PROMPT CREATE OR REPLACE Procedure  480 :: getSCGPEWorkorderTree
CREATE OR REPLACE Procedure getSCGPEWorkorderTree (
  tree_cursor IN OUT pReturnData.c_Records,
  pOrdertype varchar2,
  pGroupID number,
  pStartDate date,
  pEndDate date
)
AS
BEGIN
  /* Order No Assecndig*/
  if pGroupID=0 then
    open tree_cursor for
    select SCGORDERNO,gdorderNO
    from T_SCGWorkOrder
    where GOrderDate between pStartDate and pEndDate and ordertypeid=pOrdertype
    order by GDORDERNO desc;
 /* Order Date */
  elsif pGroupID = 1 then
    open tree_cursor for
    select SCGORDERNO, gdorderNO,GOrderDate
    from T_SCGWorkOrder
    where GOrderDate between pStartDate and pEndDate and ordertypeid=pOrdertype
    order by GOrderDate desc, GDORDERNO desc;

 /* Client Name */
  elsif pGroupID = 2 then
    open tree_cursor for
    select SCGORDERNO,gdorderNO, ClientName
    from T_SCGWorkOrder, T_Client
    where T_SCGWorkOrder.ClientID=T_Client.ClientID and
    GOrderDate between pStartDate and pEndDate and ordertypeid=pOrdertype
    order by ClientName, GDORDERNO desc;

  /* Sales Person*/
  elsif pGroupID = 3 then
    open tree_cursor for
    select SCGORDERNO,gdorderNO, EmployeeName
    from T_SCGWorkOrder, T_Employee
    where T_SCGWorkOrder.SalesPersonID=T_Employee.EmployeeID and
    GOrderDate between pStartDate and pEndDate and ordertypeid=pOrdertype
    order by EmployeeName, GDORDERNO desc;
  end if;
END getSCGPEWorkorderTree;
/

PROMPT CREATE OR REPLACE Procedure  481 :: GetSCGPEWOItemPickUp
create or replace Procedure GetSCGPEWOItemPickUp
(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType number,
  pOrderno number
)
AS
BEGIN
if (pQueryType=1) then
	OPEN data_cursor for
	select a.ORDERLINEITEM,getgsizeDesc(a.ORDERLINEITEM) as SizeDesc,a.WoItemSl,a.GORDERNO,a.STYLE,a.SHADE,
	a.Price,a.DeliveryDate,a.REMARKS,c.COUNTRYNAME,c.COUNTRYID,b.UNITOFMEAS,b.UNITOFMEASID,
    ((a.Quantity)-DECODE((SELECT SUM(NVL(Quantity,0)) FROM T_SCGOrderItems WHERE TORDERLINEITEMREF=a.OrderLineItem),NULL,0,(SELECT SUM(NVL(Quantity,0)) FROM T_SCGOrderItems WHERE TORDERLINEITEMREF=a.OrderLineItem))) AS Quantity
	from T_GORDERITEMS a, t_country c,T_UnitOfMeas b
	WHERE a.UNITOFMEASID=b.UNITOFMEASID and
	a.COUNTRYID=c.COUNTRYID and
	a.GORDERNO=pOrderno;
End If;
END GetSCGPEWOItemPickUp;
/

PROMPT CREATE OR REPLACE Procedure  482 :: GetSubconIDLookUp
CREATE OR REPLACE Procedure GetSubconIDLookUp
(
    data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
  OPEN data_cursor for
   select SUBCONID,SUBCONNAME
	from t_SUBCONTRACTORS order by SUBCONNAME;
END GetSubconIDLookUp;
/


PROMPT CREATE OR REPLACE Procedure  483 :: GetKStockLoanInfo
CREATE OR REPLACE Procedure GetKStockLoanInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  many_cursor IN OUT pReturnData.c_Records,
  pKnitStockID number
)
AS
BEGIN
    open one_cursor for
    select StockId, KNTITRANSACTIONTYPEID, ReferenceNo, ReferenceDate, StockTransNO, StockTransDATE,
    supplierID,SupplierInvoiceNo,SupplierInvoiceDate,Remarks, SubConId,ClientID
    from T_KnitStock
    where StockId=pKnitStockID;

    open many_cursor for
    select PID,a.ORDERNO,GetfncWOBType(a.OrderNo) as btype,a.STOCKID, KNTISTOCKITEMSL,
    a.YarnCountId, a.YarnTypeId,a.FabricTypeId,a.OrderlineItem,a.Quantity, a.Squantity,a.PunitOfmeasId,a.SUNITOFMEASID,a.REQQUANTITY,
    a.YarnBatchNo,a.Shade,a.REMARKS,a.CurrentStock,a.supplierID,d.SUPPLIERNAME,a.RequisitionNo,
    a.SubConId,a.SHADEGROUPID,'' AS SHADEGROUPNAME,c.KNTITRANSACTIONTYPEID,a.REMAINQTY,a.yarnfor
    from T_KnitStockItems a,T_KnitStock c,T_supplier d
    where a.STOCKID=c.STOCKID and a.supplierID=d.supplierID and
    a.STOCKID=pKnitStockID
    order by KNTISTOCKITEMSL asc;
END GetKStockLoanInfo;
/

PROMPT CREATE OR REPLACE Procedure  484 :: OrderDateWiseTransaction
create or Replace Procedure OrderDateWiseTransaction(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pOrderno NUMBER,
  sDate IN date,
  eDate IN date
)
AS
BEGIN
/*  All Summary Report*/
  if pQueryType=0 then
    open data_cursor for
     select a.STOCKTRANSNO,a.STOCKTRANSDATE AS TDATE,b.YARNBATCHNO,b.squantity as sqty,b.SUNITOFMEASID as sunitid,b.SUPPLIERID,g.SUPPLIERNAME,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,
    YarnType,b.PUnitOfMeasId,j.UnitOfMeas as sunit,f.UnitOfMeas,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,'' AS ORDERLINEITEM,h.SHADEGROUPID,
    h.SHADEGROUPNAME,'' AS SHADE,b.FABRICTYPEID,i.FABRICTYPE,(Quantity) CurrentStock,0 as mainstock,0 as REMAINQTY,b.DYEDLOTNO,'' as reqno,0 as reqqty
    from
	 	T_YarnRequisition a, 
		T_YarnRequisitionItems b, 
		T_YARNREQUISITIONTYPE c, 
		T_YarnCount d,
    	T_YarnType e, 
		T_UnitOfMeas f,
		t_supplier g,
		T_ShadeGroup h,
		T_fabricType i,
		T_UnitOfMeas j
    where 
		a.StockID=b.StockID and
    		b.SUPPLIERID=g.SUPPLIERID(+) and
    		b.SHADEGROUPID=h.SHADEGROUPID and
   		b.FABRICTYPEID=i.FABRICTYPEID and
    		a.YARNREQUISITIONTYPEID=c.YARNREQUISITIONTYPEID and
    		b.YarnCountId=d.YarnCountId and
    		b.YarnTypeId= e.YarnTypeId and
    		b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    		b.SUNITOFMEASID=j.UnitOfMeasID(+) and    
    		a.YARNREQUISITIONTYPEID=1 and
    		B.ORDERNO = pOrderno 
    ORDER BY 
		btype,a.STOCKTRANSNO DESC;

elsif pQueryType=1 then
    open data_cursor for
     select a.STOCKTRANSNO,A.STOCKTRANSDATE AS TDATE,b.YARNBATCHNO,b.squantity as sqty,b.SUNITOFMEASID as sunitid,b.SUPPLIERID,g.SUPPLIERNAME,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,
    YarnType,b.PUnitOfMeasId,j.UnitOfMeas as sunit,f.UnitOfMeas,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,'' AS ORDERLINEITEM,h.SHADEGROUPID,
    h.SHADEGROUPNAME,'' AS SHADE,b.FABRICTYPEID,i.FABRICTYPE,(Quantity) CurrentStock,0 as mainstock,0 as REMAINQTY,b.DYEDLOTNO,'' as reqno,0 as reqqty
    from T_YarnRequisition a, T_YarnRequisitionItems b, T_YARNREQUISITIONTYPE c, T_YarnCount d,
    T_YarnType e, T_UnitOfMeas f,t_supplier g,T_ShadeGroup h,T_fabricType i,T_UnitOfMeas j
    where a.StockID=b.StockID and
    b.SUPPLIERID=g.SUPPLIERID(+) and
    b.SHADEGROUPID=h.SHADEGROUPID and
    b.FABRICTYPEID=i.FABRICTYPEID and
    a.YARNREQUISITIONTYPEID=c.YARNREQUISITIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUNITOFMEASID=j.UnitOfMeasID(+) and    
    a.YARNREQUISITIONTYPEID=4 and
    B.ORDERNO = pOrderno 
    ORDER BY btype,a.STOCKTRANSNO DESC;

elsif pQueryType=2 then
    open data_cursor for
    select a.STOCKTRANSNO,STOCKTRANSDATE AS TDATE,b.squantity as sqty,b.SUNITOFMEASID as sunitid,b.YARNBATCHNO,b.SUPPLIERID,g.SUPPLIERNAME,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,
    YarnType,b.PUnitOfMeasId,j.UnitOfMeas as sunit,f.UnitOfMeas,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,'' AS ORDERLINEITEM,
    h.SHADEGROUPID,h.SHADEGROUPNAME,b.SHADE,b.FABRICTYPEID,i.FABRICTYPE,(Quantity) CurrentStock,0 as mainstock,0 as REMAINQTY ,b.DYEDLOTNO,'' as reqno,0 as reqqty
    from T_YarnRequisition a, T_YarnRequisitionItems b, T_YARNREQUISITIONTYPE c, T_YarnCount d,
    T_YarnType e, T_UnitOfMeas f,t_supplier g,T_ShadeGroup h,T_fabricType i,T_UnitOfMeas j
    where a.StockID=b.StockID and
    b.SUPPLIERID=g.SUPPLIERID(+) and
   b.FABRICTYPEID=i.FABRICTYPEID(+) and
    b.SHADEGROUPID=h.SHADEGROUPID and
    a.YARNREQUISITIONTYPEID=c.YARNREQUISITIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUNITOFMEASID=j.UnitOfMeasID(+) and
    b.orderno= pOrderno  and
    a.YARNREQUISITIONTYPEID=5
    ORDER BY btype,a.STOCKTRANSNO DESC;

elsif pQueryType=3 then
    open data_cursor for
    select a.STOCKTRANSNO,STOCKTRANSDATE AS TDATE,b.squantity as sqty,b.SUNITOFMEASID as sunitid,b.YARNBATCHNO,b.SUPPLIERID,g.SUPPLIERNAME,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,
    YarnType,b.PUnitOfMeasId,j.UnitOfMeas as sunit,f.UnitOfMeas,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,'' AS ORDERLINEITEM,
    h.SHADEGROUPID,h.SHADEGROUPNAME,b.SHADE,b.FABRICTYPEID,i.FABRICTYPE,(Quantity) CurrentStock,0  as mainstock,0 as REMAINQTY,b.DYEDLOTNO,'' as reqno,0 as reqqty 
    from T_YarnRequisition a, T_YarnRequisitionItems b, T_YARNREQUISITIONTYPE c, T_YarnCount d,
    T_YarnType e, T_UnitOfMeas f,t_supplier g,T_ShadeGroup h,T_fabricType i,T_UnitOfMeas j
    where a.StockID=b.StockID and
    b.SUPPLIERID=g.SUPPLIERID(+) and
   b.FABRICTYPEID=i.FABRICTYPEID(+) and
    b.SHADEGROUPID=h.SHADEGROUPID and
    a.YARNREQUISITIONTYPEID=c.YARNREQUISITIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUNITOFMEASID=j.UnitOfMeasID(+) and
    b.orderno= pOrderno  and
    a.YARNREQUISITIONTYPEID=6
    ORDER BY btype,a.STOCKTRANSNO DESC;

elsif pQueryType=4 then
  open data_cursor for
  select a.STOCKTRANSNO,STOCKTRANSDATE AS TDATE,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
    '' AS OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
    j.SHADEGROUPNAME,'' AS Shade,YarnType,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,
    f.UnitOfMeas,'' AS DyedLotno,b.subconid,'' AS subconname,Quantity as CurrentStock,SQuantity as Sqty,0  as mainstock,0 as REMAINQTY,REQUISITIONNO as reqno,REQQUANTITY as reqqty
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier h,T_fabricType i,T_ShadeGroup j,T_UnitOfMeas k
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID(+) and 
    b.SHADEGROUPID=j.SHADEGROUPID and
    b.FABRICTYPEID=i.FABRICTYPEID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUnitOfMeasID=k.UnitOfMeasID(+) and
    a.KNTITRANSACTIONTYPEID=3 and
    B.ORDERNO = pOrderno 
ORDER BY btype,a.STOCKTRANSNO DESC;

elsif pQueryType=5 then
  open data_cursor for
  select a.STOCKTRANSNO,STOCKTRANSDATE AS TDATE,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
    '' AS OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
    j.SHADEGROUPNAME,B. Shade,YarnType,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,
    f.UnitOfMeas,'' AS DyedLotno,b.subconid,'' AS subconname,Quantity as CurrentStock,SQuantity as Sqty,0  as mainstock,0 as REMAINQTY,REQUISITIONNO as reqno,REQQUANTITY as reqqty
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier h,T_fabricType i,T_ShadeGroup j,T_UnitOfMeas k
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID(+) and 
    b.SHADEGROUPID=j.SHADEGROUPID and
    b.FABRICTYPEID=i.FABRICTYPEID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUnitOfMeasID=k.UnitOfMeasID(+) and
    a.KNTITRANSACTIONTYPEID=4 and
    B.ORDERNO = pOrderno 
ORDER BY btype,a.STOCKTRANSNO DESC;

elsif pQueryType=6 then
  open data_cursor for
 select a.STOCKTRANSNO,STOCKTRANSDATE AS TDATE,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
    '' AS OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
    j.SHADEGROUPNAME,B.Shade,YarnType,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,
    f.UnitOfMeas,'' AS DyedLotno,b.subconid,'' AS subconname,Quantity as CurrentStock,SQuantity as Sqty,0  as mainstock,0 as REMAINQTY,REQUISITIONNO as reqno,REQQUANTITY as reqqty
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier h,T_fabricType i,T_ShadeGroup j,T_UnitOfMeas k
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID(+) and 
    b.SHADEGROUPID=j.SHADEGROUPID and
    b.FABRICTYPEID=i.FABRICTYPEID(+) and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUnitOfMeasID=k.UnitOfMeasID(+) and
    a.KNTITRANSACTIONTYPEID=5 and
    B.ORDERNO = pOrderno 
ORDER BY btype,a.STOCKTRANSNO DESC;


elsif pQueryType=7 then
  open data_cursor for
 select a.STOCKTRANSNO,STOCKTRANSDATE AS TDATE,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
    '' AS OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
    j.SHADEGROUPNAME,B.Shade,YarnType,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,
    f.UnitOfMeas,'' AS DyedLotno,b.subconid,'' AS subconname,Quantity as CurrentStock,SQuantity as Sqty,0  as mainstock,0 as REMAINQTY,REQUISITIONNO as reqno,REQQUANTITY as reqqty
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier h,T_fabricType i,T_ShadeGroup j,T_UnitOfMeas k
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID(+) and 
    b.SHADEGROUPID=j.SHADEGROUPID and
    b.FABRICTYPEID=i.FABRICTYPEID(+) and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUnitOfMeasID=k.UnitOfMeasID(+) and
    a.KNTITRANSACTIONTYPEID=12 and
    B.ORDERNO = pOrderno 
ORDER BY btype,a.STOCKTRANSNO DESC;

elsif pQueryType=8 then
  open data_cursor for
 select a.BATCHNO AS STOCKTRANSNO ,A.BATCHDATE AS TDATE, b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,0 AS SUPPLIERID,'' AS SUPPLIERNAME,b.YARNBATCHNO,
    '' AS OrderlineItem,'' AS YARNTYPEID,'' AS YARNCOUNTID,'' AS YarnCount,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
    j.SHADEGROUPNAME,B.Shade,'' AS YarnType,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,
    f.UnitOfMeas,B.DyedLotno,0 AS subconid,'' AS subconname,Quantity as CurrentStock,SQuantity as Sqty,0  as mainstock,0 as REMAINQTY,'' as reqno,0 as reqqty
    from T_DBATCH a, T_DBATCHITEMS b,T_UnitOfMeas f,T_fabricType i,T_ShadeGroup j,T_UnitOfMeas k
    where a.DBATCHID=b.DBATCHID and    
    b.SHADEGROUPID=j.SHADEGROUPID and
    b.FABRICTYPEID=i.FABRICTYPEID(+) and 
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUnitOfMeasID=k.UnitOfMeasID(+) and   
    B.ORDERNO = pOrderno 
ORDER BY btype,STOCKTRANSNO DESC;

elsif pQueryType=9 then
  open data_cursor for
 select a.DINVOICEID,a.INVOICENO,a.INVOICEDATE,a.ORDERNO,getfncWOBType(a.ORDERNO) as btype,FINISHEDDIA,FINISHEDGSM,b.YARNBATCHNO,
    GWT,FWT,DBATCH,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
    j.SHADEGROUPNAME,B.Shade,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,
    f.UnitOfMeas,Quantity,SQuantity as Sqty
    from 
		t_dinvoice a,
 		t_dinvoiceItems b,
		T_UnitOfMeas f,
		T_fabricType i,
		T_ShadeGroup j,
		T_UnitOfMeas k
    where 
		a.DINVOICEID=b.DINVOICEID and    
    		b.SHADEGROUPID=j.SHADEGROUPID and
    		b.FABRICTYPEID=i.FABRICTYPEID(+) and 
    		b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    		b.SUnitOfMeasID=k.UnitOfMeasID(+) and 
			a.INVOICEDATE between sDate and eDate AND
			DTYPE=21 and  
    		a.ORDERNO = pOrderno 
	ORDER BY 
		a.DINVOICEID,btype,a.INVOICENO DESC;

elsif pQueryType=10 then
  open data_cursor for
 select A.STOCKID,a.STOCKTRANSNO,STOCKTRANSDATE AS TDATE,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
    '' AS OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
    j.SHADEGROUPNAME,B.Shade,YarnType,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,
    f.UnitOfMeas,B.DyedLotno,b.subconid,'' AS subconname,Quantity as CurrentStock,SQuantity as Sqty,0  as mainstock,0 as REMAINQTY,REQUISITIONNO as reqno,REQQUANTITY as reqqty
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier h,T_fabricType i,T_ShadeGroup j,T_UnitOfMeas k
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID(+) and 
    b.SHADEGROUPID=j.SHADEGROUPID and
    b.FABRICTYPEID=i.FABRICTYPEID(+) and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUnitOfMeasID=k.UnitOfMeasID(+) and
    a.KNTITRANSACTIONTYPEID=8 and
    B.ORDERNO = pOrderno 
ORDER BY btype,a.STOCKTRANSNO DESC;

elsif pQueryType=11 then
  open data_cursor for
 select A.STOCKID,a.STOCKTRANSNO,STOCKTRANSDATE AS TDATE,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
    '' AS OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
    j.SHADEGROUPNAME,B.Shade,YarnType,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,
    f.UnitOfMeas,B.DyedLotno,b.subconid,'' AS subconname,Quantity as CurrentStock,SQuantity as Sqty,0  as mainstock,0 as REMAINQTY,REQUISITIONNO as reqno,REQQUANTITY as reqqty
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier h,T_fabricType i,T_ShadeGroup j,T_UnitOfMeas k
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID(+) and 
    b.SHADEGROUPID=j.SHADEGROUPID and
    b.FABRICTYPEID=i.FABRICTYPEID(+) and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUnitOfMeasID=k.UnitOfMeasID(+) and
    a.KNTITRANSACTIONTYPEID=13 and
    B.ORDERNO = pOrderno 
ORDER BY btype,a.STOCKTRANSNO DESC;

elsif pQueryType=12 then
  open data_cursor for
 select A.STOCKID,a.STOCKTRANSNO,STOCKTRANSDATE AS TDATE,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
    '' AS OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
    j.SHADEGROUPNAME,B.Shade,YarnType,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,
    f.UnitOfMeas,B.DyedLotno,b.subconid,'' AS subconname,Quantity as CurrentStock,SQuantity as Sqty,0  as mainstock,0 as REMAINQTY,REQUISITIONNO as reqno,REQQUANTITY as reqqty
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier h,T_fabricType i,T_ShadeGroup j,T_UnitOfMeas k
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID(+) and 
    b.SHADEGROUPID=j.SHADEGROUPID and
    b.FABRICTYPEID=i.FABRICTYPEID(+) and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUnitOfMeasID=k.UnitOfMeasID(+) and
    a.KNTITRANSACTIONTYPEID=6 and
    B.ORDERNO = pOrderno 
ORDER BY btype,a.STOCKTRANSNO DESC;

elsif pQueryType=13 then
  open data_cursor for
 select A.STOCKID,a.STOCKTRANSNO,STOCKTRANSDATE AS TDATE,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
    '' AS OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
    j.SHADEGROUPNAME,B.Shade,YarnType,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,
    f.UnitOfMeas,B.DyedLotno,b.subconid,'' AS subconname,Quantity as CurrentStock,SQuantity as Sqty,0  as mainstock,0 as REMAINQTY,REQUISITIONNO as reqno,REQQUANTITY as reqqty
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier h,T_fabricType i,T_ShadeGroup j,T_UnitOfMeas k
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID(+) and 
    b.SHADEGROUPID=j.SHADEGROUPID and
    b.FABRICTYPEID=i.FABRICTYPEID(+) and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUnitOfMeasID=k.UnitOfMeasID(+) and
    a.KNTITRANSACTIONTYPEID=7 and
    B.ORDERNO = pOrderno 
ORDER BY btype,a.STOCKTRANSNO DESC;

elsif pQueryType=14 then
  open data_cursor for
 select A.STOCKID,a.STOCKTRANSNO,STOCKTRANSDATE AS TDATE,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
    '' AS OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
    j.SHADEGROUPNAME,B.Shade,YarnType,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,
    f.UnitOfMeas,B.DyedLotno,b.subconid,'' AS subconname,Quantity as CurrentStock,SQuantity as Sqty,0  as mainstock,0 as REMAINQTY,REQUISITIONNO as reqno,REQQUANTITY as reqqty
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier h,T_fabricType i,T_ShadeGroup j,T_UnitOfMeas k
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID(+) and 
    b.SHADEGROUPID=j.SHADEGROUPID and
    b.FABRICTYPEID=i.FABRICTYPEID(+) and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUnitOfMeasID=k.UnitOfMeasID(+) and
    a.KNTITRANSACTIONTYPEID=24 and
    B.ORDERNO = pOrderno 
ORDER BY btype,a.STOCKTRANSNO DESC;

elsif pQueryType=15 then
  open data_cursor for
 select A.STOCKID,a.STOCKTRANSNO,STOCKTRANSDATE AS TDATE,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
    '' AS OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
    j.SHADEGROUPNAME,B.Shade,YarnType,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,
    f.UnitOfMeas,B.DyedLotno,b.subconid,'' AS subconname,Quantity as CurrentStock,SQuantity as Sqty,0  as mainstock,0 as REMAINQTY,REQUISITIONNO as reqno,REQQUANTITY as reqqty
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier h,T_fabricType i,T_ShadeGroup j,T_UnitOfMeas k
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID(+) and 
    b.SHADEGROUPID=j.SHADEGROUPID and
    b.FABRICTYPEID=i.FABRICTYPEID(+) and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUnitOfMeasID=k.UnitOfMeasID(+) and
    a.KNTITRANSACTIONTYPEID=25 and
    B.ORDERNO = pOrderno 
ORDER BY btype,a.STOCKTRANSNO DESC;


elsif pQueryType=16 then
  open data_cursor for
 select A.STOCKID,a.STOCKTRANSNO,STOCKTRANSDATE AS TDATE,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
    '' AS OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
    j.SHADEGROUPNAME,B.Shade,YarnType,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,
    f.UnitOfMeas,B.DyedLotno,b.subconid,'' AS subconname,Quantity as CurrentStock,SQuantity as Sqty,0  as mainstock,0 as REMAINQTY,REQUISITIONNO as reqno,REQQUANTITY as reqqty
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier h,T_fabricType i,T_ShadeGroup j,T_UnitOfMeas k
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID(+) and 
    b.SHADEGROUPID=j.SHADEGROUPID and
    b.FABRICTYPEID=i.FABRICTYPEID(+) and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUnitOfMeasID=k.UnitOfMeasID(+) and
    a.KNTITRANSACTIONTYPEID=22 and
    B.ORDERNO = pOrderno 
ORDER BY btype,a.STOCKTRANSNO DESC;

elsif pQueryType=17 then
  open data_cursor for
 select A.STOCKID,a.STOCKTRANSNO,STOCKTRANSDATE AS TDATE,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
    '' AS OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
    j.SHADEGROUPNAME,B.Shade,YarnType,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,
    f.UnitOfMeas,B.DyedLotno,b.subconid,'' AS subconname,Quantity as CurrentStock,SQuantity as Sqty,0  as mainstock,0 as REMAINQTY,REQUISITIONNO as reqno,REQQUANTITY as reqqty
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier h,T_fabricType i,T_ShadeGroup j,T_UnitOfMeas k
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID(+) and 
    b.SHADEGROUPID=j.SHADEGROUPID and
    b.FABRICTYPEID=i.FABRICTYPEID(+) and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUnitOfMeasID=k.UnitOfMeasID(+) and
    a.KNTITRANSACTIONTYPEID=23 and
    B.ORDERNO = pOrderno 
ORDER BY btype,a.STOCKTRANSNO DESC;


elsif pQueryType=18 then
    open data_cursor for
    select a.STOCKTRANSNO,STOCKTRANSDATE AS TDATE,b.squantity as sqty,b.SUNITOFMEASID as sunitid,b.YARNBATCHNO,b.SUPPLIERID,g.SUPPLIERNAME,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,
    YarnType,b.PUnitOfMeasId,j.UnitOfMeas as sunit,f.UnitOfMeas,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,'' AS ORDERLINEITEM,
    h.SHADEGROUPID,h.SHADEGROUPNAME,b.SHADE,b.FABRICTYPEID,i.FABRICTYPE,(Quantity) CurrentStock,0 as mainstock,0 as REMAINQTY ,b.DYEDLOTNO,'' as reqno,0 as reqqty
    from T_YarnRequisition a, T_YarnRequisitionItems b, T_YARNREQUISITIONTYPE c, T_YarnCount d,
    T_YarnType e, T_UnitOfMeas f,t_supplier g,T_ShadeGroup h,T_fabricType i,T_UnitOfMeas j
    where a.StockID=b.StockID and
    b.SUPPLIERID=g.SUPPLIERID(+) and
   b.FABRICTYPEID=i.FABRICTYPEID(+) and
    b.SHADEGROUPID=h.SHADEGROUPID and
    a.YARNREQUISITIONTYPEID=c.YARNREQUISITIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUNITOFMEASID=j.UnitOfMeasID(+) and
    b.orderno= pOrderno  and
    a.YARNREQUISITIONTYPEID=2
    ORDER BY btype,a.STOCKTRANSNO DESC;

elsif pQueryType=19 then
    open data_cursor for
    select a.STOCKTRANSNO,STOCKTRANSDATE AS TDATE,b.squantity as sqty,b.SUNITOFMEASID as sunitid,b.YARNBATCHNO,b.SUPPLIERID,g.SUPPLIERNAME,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,
    YarnType,b.PUnitOfMeasId,j.UnitOfMeas as sunit,f.UnitOfMeas,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,'' AS ORDERLINEITEM,
    h.SHADEGROUPID,h.SHADEGROUPNAME,b.SHADE,b.FABRICTYPEID,i.FABRICTYPE,(Quantity) CurrentStock,0  as mainstock,0 as REMAINQTY,b.DYEDLOTNO,'' as reqno,0 as reqqty 
    from T_YarnRequisition a, T_YarnRequisitionItems b, T_YARNREQUISITIONTYPE c, T_YarnCount d,
    T_YarnType e, T_UnitOfMeas f,t_supplier g,T_ShadeGroup h,T_fabricType i,T_UnitOfMeas j
    where a.StockID=b.StockID and
    b.SUPPLIERID=g.SUPPLIERID(+) and
   b.FABRICTYPEID=i.FABRICTYPEID(+) and
    b.SHADEGROUPID=h.SHADEGROUPID and
    a.YARNREQUISITIONTYPEID=c.YARNREQUISITIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUNITOFMEASID=j.UnitOfMeasID(+) and
    b.orderno= pOrderno  and
    a.YARNREQUISITIONTYPEID=7
    ORDER BY btype,a.STOCKTRANSNO DESC;

elsif pQueryType=20 then
  open data_cursor for
 select A.STOCKID,a.STOCKTRANSNO,STOCKTRANSDATE AS TDATE,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
    '' AS OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
    j.SHADEGROUPNAME,B.Shade,YarnType,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,
    f.UnitOfMeas,B.DyedLotno,b.subconid,'' AS subconname,Quantity as CurrentStock,SQuantity as Sqty,0  as mainstock,0 as REMAINQTY,REQUISITIONNO as reqno,REQQUANTITY as reqqty
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier h,T_fabricType i,T_ShadeGroup j,T_UnitOfMeas k
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID(+) and 
    b.SHADEGROUPID=j.SHADEGROUPID and
    b.FABRICTYPEID=i.FABRICTYPEID(+) and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUnitOfMeasID=k.UnitOfMeasID(+) and
    a.KNTITRANSACTIONTYPEID=26 and
    B.ORDERNO = pOrderno 
ORDER BY btype,a.STOCKTRANSNO DESC;

elsif pQueryType=21 then
  open data_cursor for
 select A.STOCKID,a.STOCKTRANSNO,STOCKTRANSDATE AS TDATE,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
    '' AS OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
    j.SHADEGROUPNAME,B.Shade,YarnType,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,
    f.UnitOfMeas,B.DyedLotno,b.subconid,'' AS subconname,Quantity as CurrentStock,SQuantity as Sqty,0  as mainstock,0 as REMAINQTY,REQUISITIONNO as reqno,REQQUANTITY as reqqty
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier h,T_fabricType i,T_ShadeGroup j,T_UnitOfMeas k
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID(+) and 
    b.SHADEGROUPID=j.SHADEGROUPID and
    b.FABRICTYPEID=i.FABRICTYPEID(+) and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUnitOfMeasID=k.UnitOfMeasID(+) and
    a.KNTITRANSACTIONTYPEID=27 and
    B.ORDERNO = pOrderno 
ORDER BY btype,a.STOCKTRANSNO DESC;

elsif pQueryType=22 then
  open data_cursor for
 select A.STOCKID,a.STOCKTRANSNO,STOCKTRANSDATE AS TDATE,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
    '' AS OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
    j.SHADEGROUPNAME,B.Shade,YarnType,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,
    f.UnitOfMeas,B.DyedLotno,b.subconid,'' AS subconname,Quantity as CurrentStock,SQuantity as Sqty,0  as mainstock,0 as REMAINQTY,REQUISITIONNO as reqno,REQQUANTITY as reqqty
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier h,T_fabricType i,T_ShadeGroup j,T_UnitOfMeas k
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID(+) and 
    b.SHADEGROUPID=j.SHADEGROUPID and
    b.FABRICTYPEID=i.FABRICTYPEID(+) and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUnitOfMeasID=k.UnitOfMeasID(+) and
    a.KNTITRANSACTIONTYPEID=44 and
    B.ORDERNO= pOrderno 
ORDER BY btype,a.STOCKTRANSNO DESC;


elsif pQueryType=23 then
  open data_cursor for
 select a.DINVOICEID,a.INVOICENO,a.INVOICEDATE,a.ORDERNO,getfncWOBType(a.ORDERNO) as btype,FINISHEDDIA,FINISHEDGSM,b.YARNBATCHNO,
    GWT,FWT,DBATCH,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
    j.SHADEGROUPNAME,B.Shade,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,
    f.UnitOfMeas,Quantity,SQuantity as Sqty
    from 
		t_dinvoice a,
 		t_dinvoiceItems b,
		T_UnitOfMeas f,
		T_fabricType i,
		T_ShadeGroup j,
		T_UnitOfMeas k
    where 
		a.DINVOICEID=b.DINVOICEID and    
    		b.SHADEGROUPID=j.SHADEGROUPID and
    		b.FABRICTYPEID=i.FABRICTYPEID(+) and 
    		b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    		b.SUnitOfMeasID=k.UnitOfMeasID(+) and
			a.INVOICEDATE between sDate and eDate AND
		    DTYPE=17 and    
    		a.ORDERNO = pOrderno 
	ORDER BY 
		a.DINVOICEID,btype,a.INVOICENO DESC;

elsif pQueryType=24 then
    open data_cursor for
    select a.STOCKTRANSNO,STOCKTRANSDATE AS TDATE,b.squantity as sqty,b.SUNITOFMEASID as sunitid,b.YARNBATCHNO,b.SUPPLIERID,g.SUPPLIERNAME,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,
    YarnType,b.PUnitOfMeasId,j.UnitOfMeas as sunit,f.UnitOfMeas,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,'' AS ORDERLINEITEM,
    h.SHADEGROUPID,h.SHADEGROUPNAME,b.SHADE,b.FABRICTYPEID,i.FABRICTYPE,(Quantity) CurrentStock,0  as mainstock,0 as REMAINQTY,b.DYEDLOTNO,'' as reqno,0 as reqqty 
    from T_YarnRequisition a, T_YarnRequisitionItems b, T_YARNREQUISITIONTYPE c, T_YarnCount d,
    T_YarnType e, T_UnitOfMeas f,t_supplier g,T_ShadeGroup h,T_fabricType i,T_UnitOfMeas j
    where a.StockID=b.StockID and
    b.SUPPLIERID=g.SUPPLIERID(+) and
   b.FABRICTYPEID=i.FABRICTYPEID(+) and
    b.SHADEGROUPID=h.SHADEGROUPID and
    a.YARNREQUISITIONTYPEID=c.YARNREQUISITIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUNITOFMEASID=j.UnitOfMeasID(+) and
    b.orderno= pOrderno  and
    a.YARNREQUISITIONTYPEID=3
    ORDER BY btype,a.STOCKTRANSNO DESC;

elsif pQueryType=25 then
  open data_cursor for
 select A.STOCKID,a.STOCKTRANSNO,STOCKTRANSDATE AS TDATE,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
    '' AS OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
    j.SHADEGROUPNAME,B.Shade,YarnType,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,
    f.UnitOfMeas,B.DyedLotno,b.subconid,'' AS subconname,Quantity as CurrentStock,SQuantity as Sqty,0  as mainstock,0 as REMAINQTY,REQUISITIONNO as reqno,REQQUANTITY as reqqty
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier h,T_fabricType i,T_ShadeGroup j,T_UnitOfMeas k
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID(+) and 
    b.SHADEGROUPID=j.SHADEGROUPID and
    b.FABRICTYPEID=i.FABRICTYPEID(+) and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUnitOfMeasID=k.UnitOfMeasID(+) and
    a.KNTITRANSACTIONTYPEID=18 and
    B.ORDERNO = pOrderno 
ORDER BY btype,a.STOCKTRANSNO DESC;

elsif pQueryType=26 then
  open data_cursor for
 select A.STOCKID,a.STOCKTRANSNO,STOCKTRANSDATE AS TDATE,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
    '' AS OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
    j.SHADEGROUPNAME,B.Shade,YarnType,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,
    f.UnitOfMeas,B.DyedLotno,b.subconid,'' AS subconname,Quantity as CurrentStock,SQuantity as Sqty,0  as mainstock,0 as REMAINQTY,REQUISITIONNO as reqno,REQQUANTITY as reqqty
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier h,T_fabricType i,T_ShadeGroup j,T_UnitOfMeas k
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID(+) and 
    b.SHADEGROUPID=j.SHADEGROUPID and
    b.FABRICTYPEID=i.FABRICTYPEID(+) and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUnitOfMeasID=k.UnitOfMeasID(+) and
    a.KNTITRANSACTIONTYPEID=19 and
    B.ORDERNO = pOrderno 
ORDER BY btype,a.STOCKTRANSNO DESC;

elsif pQueryType=27 then
  open data_cursor for
 select A.STOCKID,a.STOCKTRANSNO,STOCKTRANSDATE AS TDATE,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
    '' AS OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
    j.SHADEGROUPNAME,B.Shade,YarnType,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,
    f.UnitOfMeas,B.DyedLotno,b.subconid,'' AS subconname,Quantity as CurrentStock,SQuantity as Sqty,0  as mainstock,0 as REMAINQTY,REQUISITIONNO as reqno,REQQUANTITY as reqqty
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier h,T_fabricType i,T_ShadeGroup j,T_UnitOfMeas k
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID(+) and 
    b.SHADEGROUPID=j.SHADEGROUPID and
    b.FABRICTYPEID=i.FABRICTYPEID(+) and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUnitOfMeasID=k.UnitOfMeasID(+) and
    a.KNTITRANSACTIONTYPEID=20 and
    B.ORDERNO = pOrderno 
ORDER BY btype,a.STOCKTRANSNO DESC;

elsif pQueryType=28 then 
  open data_cursor for
 select a.DINVOICEID,a.INVOICENO,a.INVOICEDATE,a.ORDERNO,getfncWOBType(a.ORDERNO) as btype,FINISHEDDIA,FINISHEDGSM,b.YARNBATCHNO,
    GWT,FWT,DBATCH,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
    j.SHADEGROUPNAME,B.Shade,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,
    f.UnitOfMeas,Quantity,SQuantity as Sqty
    from 
		t_dinvoice a,
 		t_dinvoiceItems b,
		T_UnitOfMeas f,
		T_fabricType i,
		T_ShadeGroup j,
		T_UnitOfMeas k
    where 
		a.DINVOICEID=b.DINVOICEID and    
    		b.SHADEGROUPID=j.SHADEGROUPID and
    		b.FABRICTYPEID=i.FABRICTYPEID(+) and 
    		b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    		b.SUnitOfMeasID=k.UnitOfMeasID(+) and
		    DTYPE=41 and    
    		a.ORDERNO = pOrderno 
	ORDER BY 
		a.DINVOICEID,btype,a.INVOICENO DESC;
		
elsif pQueryType=29 then
  open data_cursor for
 select A.STOCKID,a.STOCKTRANSNO,STOCKTRANSDATE AS TDATE,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
    '' AS OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
    j.SHADEGROUPNAME,B.Shade,YarnType,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,
    f.UnitOfMeas,B.DyedLotno,b.subconid,'' AS subconname,Quantity as CurrentStock,SQuantity as Sqty,0  as mainstock,0 as REMAINQTY,REQUISITIONNO as reqno,REQQUANTITY as reqqty
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier h,T_fabricType i,T_ShadeGroup j,T_UnitOfMeas k
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID(+) and 
    b.SHADEGROUPID=j.SHADEGROUPID and
    b.FABRICTYPEID=i.FABRICTYPEID(+) and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUnitOfMeasID=k.UnitOfMeasID(+) and
    a.KNTITRANSACTIONTYPEID=11 and
    B.ORDERNO = pOrderno 
ORDER BY btype,a.STOCKTRANSNO DESC;

elsif pQueryType=30 then
  open data_cursor for
 select A.STOCKID,a.STOCKTRANSNO,STOCKTRANSDATE AS TDATE,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
    '' AS OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
    j.SHADEGROUPNAME,B.Shade,YarnType,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,
    f.UnitOfMeas,B.DyedLotno,b.subconid,'' AS subconname,Quantity as CurrentStock,SQuantity as Sqty,0  as mainstock,0 as REMAINQTY,REQUISITIONNO as reqno,REQQUANTITY as reqqty
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier h,T_fabricType i,T_ShadeGroup j,T_UnitOfMeas k
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID(+) and 
    b.SHADEGROUPID=j.SHADEGROUPID and
    b.FABRICTYPEID=i.FABRICTYPEID(+) and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUnitOfMeasID=k.UnitOfMeasID(+) and
    a.KNTITRANSACTIONTYPEID=14 and
    B.ORDERNO = pOrderno 
ORDER BY btype,a.STOCKTRANSNO DESC;

elsif pQueryType=31 then
  open data_cursor for
 select A.STOCKID,a.STOCKTRANSNO,STOCKTRANSDATE AS TDATE,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
    '' AS OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
    j.SHADEGROUPNAME,B.Shade,YarnType,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,
    f.UnitOfMeas,B.DyedLotno,b.subconid,'' AS subconname,Quantity as CurrentStock,SQuantity as Sqty,0  as mainstock,0 as REMAINQTY,REQUISITIONNO as reqno,REQQUANTITY as reqqty
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier h,T_fabricType i,T_ShadeGroup j,T_UnitOfMeas k
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID(+) and 
    b.SHADEGROUPID=j.SHADEGROUPID and
    b.FABRICTYPEID=i.FABRICTYPEID(+) and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUnitOfMeasID=k.UnitOfMeasID(+) and
    a.KNTITRANSACTIONTYPEID=9 and
    B.ORDERNO = pOrderno 
ORDER BY btype,a.STOCKTRANSNO DESC;

elsif pQueryType=32 then
  open data_cursor for
 select A.STOCKID,a.STOCKTRANSNO,STOCKTRANSDATE AS TDATE,b.ORDERNO,getfncWOBType(b.ORDERNO) as btype,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,
    '' AS OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
    j.SHADEGROUPNAME,B.Shade,YarnType,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,
    f.UnitOfMeas,B.DyedLotno,b.subconid,'' AS subconname,Quantity as CurrentStock,SQuantity as Sqty,0  as mainstock,0 as REMAINQTY,REQUISITIONNO as reqno,REQQUANTITY as reqqty
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,t_supplier h,T_fabricType i,T_ShadeGroup j,T_UnitOfMeas k
    where a.StockID=b.StockID and
    b.SUPPLIERID=h.SUPPLIERID(+) and 
    b.SHADEGROUPID=j.SHADEGROUPID and
    b.FABRICTYPEID=i.FABRICTYPEID(+) and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.SUnitOfMeasID=k.UnitOfMeasID(+) and
    a.KNTITRANSACTIONTYPEID=10 and
    B.ORDERNO = pOrderno 
ORDER BY btype,a.STOCKTRANSNO DESC;

elsif pQueryType=33 then
  open data_cursor for
 select a.DINVOICEID,a.INVOICENO,a.INVOICEDATE,a.ORDERNO,getfncWOBType(a.ORDERNO) as btype,FINISHEDDIA,FINISHEDGSM,b.YARNBATCHNO,
    GWT,FWT,DBATCH,b.FABRICTYPEID,i.FABRICTYPE,b.ShadeGroupID,
    j.SHADEGROUPNAME,B.Shade,b.PUnitOfMeasId,b.sunitofmeasid as sunitid,k.unitofmeas as sunit,
    f.UnitOfMeas,CURRENTQTY,RETURNEDQTY,NONRETURNABLE,RETURNABLE,Quantity,SQuantity as Sqty
    from 
		t_dinvoice a,
 		t_dinvoiceItems b,
		T_UnitOfMeas f,
		T_fabricType i,
		T_ShadeGroup j,
		T_UnitOfMeas k
    where 
		a.DINVOICEID=b.DINVOICEID and    
    		b.SHADEGROUPID=j.SHADEGROUPID and
    		b.FABRICTYPEID=i.FABRICTYPEID(+) and 
    		b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    		b.SUnitOfMeasID=k.UnitOfMeasID(+) and 
			a.INVOICEDATE between sDate and eDate AND
			DTYPE=72 and  
    		a.ORDERNO = pOrderno 
	ORDER BY 
		a.DINVOICEID,btype,a.INVOICENO DESC;
end if;
End OrderDateWiseTransaction;
/


PROMPT CREATE OR REPLACE Procedure  486 :: getTreeFabricTypeList
create or replace Procedure getTreeFabricTypeList(
	pQueryType NUMBER,
	pFabId varchar2,
	io_cursor IN OUT pReturnData.c_Records  
)
AS
BEGIN
 /* For Route card id*/
  if pQueryType=0 then
  OPEN io_cursor FOR
    select a.FabricTypeID,a.FabricType from  T_FabricType a
	order by a.FabricType desc;
   end if;
END getTreeFabricTypeList;
/

PROMPT CREATE OR REPLACE Procedure  487 :: GetGTransTypeLookUP
CREATE OR REPLACE Procedure GetGTransTypeLookUP
(
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
  OPEN data_cursor for
  select GTRANSACTIONTYPEID,GTRANSTYPE,GMS,FGFD,CGS
  from T_GTransactionType
  order by GTRANSACTIONTYPEID;
END GetGTransTypeLookUP;
/


PROMPT CREATE OR REPLACE Procedure  488 :: GetAccNameLookUp
CREATE OR REPLACE Procedure GetAccNameLookUp
(
  data_cursor IN OUT pReturnData.c_Records,
  pAccGroupID number
)
AS

BEGIN
  OPEN data_cursor for
     select ACCESSORIESID,ITEM 
	 from T_accessories 
	 Where GROUPID=pAccGroupID
	 order by ITEM;
END GetAccNameLookUp;
/


PROMPT CREATE OR REPLACE Procedure  489 :: GetOverheadInfo
CREATE OR REPLACE PROCEDURE GetOverheadInfo
(
 one_cursor IN OUT pReturnData.c_Records,
 many_cursor1 IN OUT pReturnData.c_Records,
 many_cursor2 IN OUT pReturnData.c_Records,
 many_cursor3 IN OUT pReturnData.c_Records,
 pPID in NUMBER
)
AS
BEGIN
 open one_cursor for
		select PID,OVERHEADNO,YMONTH,KNITTINGHOUR,DYEINGHOUR,FINISHINGHOUR,RMGHOUR
		from T_OVERHEAD
		where PID=pPID ;

 open many_cursor1 for
        SELECT  ID,ITEMSSL,a.PID,OHTYPEID,PARTICULARID,KNITTING,DYEING,FINISHING,RMG,TOTAL
        FROM T_OVERHEADITEMS a,T_OVERHEAD b
        WHERE  OHTYPEID=1 AND a.PID=b.PID AND a.PID=pPID 
		ORDER BY ITEMSSL;
	
 open many_cursor2 for
        SELECT  ID,ITEMSSL,a.PID,OHTYPEID,PARTICULARID,KNITTING,DYEING,FINISHING,RMG,TOTAL
        FROM T_OVERHEADITEMS a,T_OVERHEAD b
        WHERE  OHTYPEID=2 AND a.PID=b.PID AND a.PID=pPID
		ORDER BY ITEMSSL;
	
 open many_cursor3 for
        SELECT  ID,ITEMSSL,a.PID,OHTYPEID,PARTICULARID,KNITTING,DYEING,FINISHING,RMG,TOTAL
        FROM T_OVERHEADITEMS a,T_OVERHEAD b
        WHERE  OHTYPEID=3 AND a.PID=b.PID AND a.PID=pPID
		ORDER BY ITEMSSL;

END GetOverheadInfo;
/

PROMPT CREATE OR REPLACE Procedure  490 :: GetParticularList
CREATE OR REPLACE Procedure GetParticularList
(
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
  OPEN data_cursor for
  select PARTICULARID,PARTICULARNAME
        from T_PARTICULAR order by PARTICULARNAME;
END GetParticularList;
/

PROMPT CREATE OR REPLACE Procedure  491 :: getTreeOverhead
CREATE OR REPLACE PROCEDURE getTreeOverhead(
	io_cursor IN OUT pReturnData.c_Records,
	pQType IN NUMBER
)
AS
BEGIN
  if pQType=0 then
    OPEN io_cursor FOR
    select PID, OVERHEADNO from T_OVERHEAD
    order by OVERHEADNO desc;
	
  elsif pQType=1 then
    OPEN io_cursor FOR
    select PID,OVERHEADNO,YMONTH from T_OVERHEAD
    order by OVERHEADNO desc;
end if;
END getTreeOverhead;
/


PROMPT CREATE OR REPLACE Procedure  492 :: GetKnittingShiftLookUp
CREATE OR REPLACE Procedure GetKnittingShiftLookUp
(
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
  OPEN data_cursor for
  select ShiftID,ShiftID || ' # ' || ShiftingTime as ShiftingTime
  from T_KnittingShift;
END GetKnittingShiftLookUp;
/



PROMPT CREATE OR REPLACE Procedure  493 :: GetKnitMachineGSMwiseLookUp
CREATE OR REPLACE Procedure GetKnitMachineGSMwiseLookUp
(
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
    OPEN data_cursor for
	SELECT b.PID,b.MACHINEID,(a.MACHINENAME ||' ' || b.KNITMCDIA  ||'X'|| b.KNITMCGAUGE ||' '|| b.GSM ||' '||c.FABRICTYPE  ||' '|| d.YARNCOUNT ) as MACHINEDESC,b.PRODUCTIONHRS 
	FROM T_KNITMACHINEINFO a,T_KNITMACHINEINFOITEMS b,T_FABRICTYPE c,T_YARNCOUNT d
	Where a.MACHINEID=b.MACHINEID AND
		  b.FABRICTYPEID=c.FABRICTYPEID AND 
		  b.YARNCOUNTID=d.YARNCOUNTID
	ORDER BY a.MACHINENAME,b.KNITMCDIA,b.KNITMCGAUGE,b.GSM;      
END GetKnitMachineGSMwiseLookUp;
/


PROMPT CREATE OR REPLACE Procedure  494 :: GetCuttingOTransferInfo
CREATE OR REPLACE Procedure GetCuttingOTransferInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  many_cursor IN OUT pReturnData.c_Records,
  pGStockID number
)
AS
BEGIN
    open one_cursor for
    select StockId,ChallanNo, ChallanDate, StockTransNO, StockTransDATE,CUTPIECEREJECT,Jhute,
    ClientID,Remarks, SubConId,Pono,GatepassNo,catid,Fweight,CutWeight,EFFICIENCY,COMPLETE,PRODHOUR
    from T_GStock
    where StockId=pGStockID;

    open many_cursor for
    select a.PID,a.ORDERNO,getfncDispalyorder(a.OrderNo) as btype,fncTransCuttingOrder(a.STOCKID,GSTOCKITEMSL) as TOrderNo,
	a.STOCKID, a.FABWEIGHT,a.Reject, a.REQQUANTITY,a.GSTOCKITEMSL,a.FabricTypeId,a.Quantity,a.Squantity,a.PunitOfmeasId,a.SUNITOFMEASID,a.SIZEID,
	a.cuttingid,a.displayno as cuttingno,a.BatchNo,a.Shade,a.REMARKS,a.CurrentStock,a.subconid,a.FabricDia,a.FabricGSM,a.Styleno,
	a.GTRANSTYPEID,a.countryid,	a.lineno,a.cuttingid, a.bundleno,a.orderlineitem,a.cartonno
    from T_GStockItems a
    where a.GTRANSTYPEID=121 AND a.STOCKID=pGStockID
    order by GSTOCKITEMSL,lineno asc;
END GetCuttingOTransferInfo;
/




PROMPT CREATE OR REPLACE Procedure  495 :: GETCuttingWOTransItemInsert
CREATE OR REPLACE Procedure GETCuttingWOTransItemInsert (
  pStockId IN NUMBER,
  pStrSql1 IN VARCHAR2,
  pStrSql2 IN VARCHAR2,
  pIdentityName IN VARCHAR2,
  pIdentityFld1 IN VARCHAR2,
  pIdentityFld2 IN VARCHAR2,
  pCurIdentityVal OUT NUMBER,
  pRecsAffected out NUMBER
)
AS
  tmpSql VARCHAR2(1000);
  restSql VARCHAR2(1000);
  insertSql VARCHAR2(1000);
  parentIdentityVal  NUMBER;
  tmpPos NUMBER;
  faults EXCEPTION;
BEGIN

/*========================Main Section(121)======================*/
  execute immediate 'select ' || pIdentityName || '.NEXTVAL from sys.dual'
  into pCurIdentityVal;


  parentIdentityVal:=pCurIdentityVal;

  tmpPos := instr(pStrSql1, '(', 1, 1);
  tmpSql := substr(pStrSql1, 1, tmpPos);
  restSql := substr(pStrSql1, tmpPos+1);
  insertSql := tmpSql || pIdentityFld1 || ','|| pIdentityFld2 || ',';

  tmpPos := instr(restSql, ' values (', 1, 1);
  tmpSql := substr(restSql, 1, tmpPos);
  restSql := substr(restSql, tmpPos+9);

  insertSql := insertSql || tmpSql || ' values (' ||
          TO_CHAR(pCurIdentityVal) || ',' ||TO_CHAR(pStockId) || ',' || restSql;

  execute immediate insertSql;
 pRecsAffected := SQL%ROWCOUNT;
/*========================Copy Section(122)======================*/
  execute immediate 'select ' || pIdentityName || '.NEXTVAL from sys.dual'
  into pCurIdentityVal;

  tmpPos := instr(pStrSql2, '(', 1, 1);
  tmpSql := substr(pStrSql2, 1, tmpPos);
  restSql := substr(pStrSql2, tmpPos+1);
  insertSql := tmpSql || pIdentityFld1 || ','|| pIdentityFld2 || ',';

  tmpPos := instr(restSql, ' values (', 1, 1);
  tmpSql := substr(restSql, 1, tmpPos);
  restSql := substr(restSql, tmpPos+9);

  insertSql := insertSql || tmpSql || ' values (' ||
          TO_CHAR(pCurIdentityVal) || ',' ||TO_CHAR(pStockId) || ',' || restSql;

  execute immediate insertSql;
  pRecsAffected := SQL%ROWCOUNT+pRecsAffected;
 /*===============================================================*/
	IF (pRecsAffected=2)
	THEN
        COMMIT;
	ELSE
		RAISE faults;
	END IF;
EXCEPTION
	WHEN faults THEN ROLLBACK;
END GETCuttingWOTransItemInsert;
/



PROMPT CREATE OR REPLACE Procedure  496 :: GetCuttingWFabstock
CREATE OR REPLACE Procedure GetCuttingWFabstock(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pKnitTranTypeID NUMBER,
  pStockDate DATE
)
AS
BEGIN
        /* CGS*/
    if pQueryType=1 then
    open data_cursor for
    select a.ORDERNO, a.FabricTypeId,getfncDispalyorder(a.ORDERNO) as Dorder,a.PunitOfmeasId,a.SUNITOFMEASID as sunitid,f.unitofmeas as punit,g.unitofmeas as sunit,d.fabrictype,
    a.BatchNo,a.Shade,a.SIZEID,s.SIZENAME,a.REMARKS,a.FabricDia,a.FabricGSM,a.Styleno,sum(Quantity*CGS) CurrentStock,sum(SQuantity*CGS) Cursqty
    from T_GStockItems a,T_Gstock b,T_GTransactionType c,T_fabrictype d,T_UnitOfMeas f,T_UnitOfMeas g,T_SIZE s
    where  a.StockID=b.StockID and
	a.SIZEID=s.SIZEID(+) AND
    a.GTRANSTYPEID=c.GTRANSACTIONTYPEID and
    a.fabrictypeid=d.fabrictypeid and 
    a.PUnitOfMeasID=f.UnitOfMeasID(+)  and
    a.SUnitOfMeasID=g.UnitOfMeasID(+) AND
    STOCKTRANSDATE <= pStockDate
    group by a.ORDERNO,a.FabricTypeId,a.PunitOfmeasId,a.SUNITOFMEASID,f.unitofmeas,g.unitofmeas,d.fabrictype,
    a.BatchNo,a.Shade,a.SIZEID,s.SIZENAME,a.REMARKS,a.FabricDia,a.FabricGSM,a.Styleno
    having sum(Quantity*CGS)>0 order by a.orderno asc;      
    
end if;
End GetCuttingWFabstock;
/

PROMPT CREATE OR REPLACE Procedure  497 :: GetTransCuttingWOrderList
CREATE OR REPLACE Procedure GetTransCuttingWOrderList(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pFabricTypeId varchar2
)
AS
BEGIN
        /* CGS*/
    if pQueryType=1 then
    open data_cursor for
    select a.ORDERNO,a.FabricTypeId,getfncDispalyorder(a.ORDERNO) as Dorder,a.PunitOfmeasId,a.SUNITOFMEASID as sunitid,f.unitofmeas as punit,g.unitofmeas as sunit,d.fabrictype,
    a.BatchNo,a.SIZEID,s.SIZENAME,a.Shade,a.REMARKS,a.FabricDia,a.FabricGSM,a.Styleno,sum(Quantity*CGS) CurrentStock,sum(SQuantity*CGS) Cursqty
    from T_GStockItems a,T_Gstock b,T_GTransactionType c,T_fabrictype d,T_UnitOfMeas f,T_UnitOfMeas g,T_SIZE s
    where  a.StockID=b.StockID and
	a.SIZEID=s.SIZEID(+) AND
    a.GTRANSTYPEID=c.GTRANSACTIONTYPEID and
    a.fabrictypeid=d.fabrictypeid and
    a.PUnitOfMeasID=f.UnitOfMeasID(+)  and
    a.SUnitOfMeasID=g.UnitOfMeasID(+) AND
    a.fabrictypeid=pFabricTypeId
    group by a.ORDERNO,a.FabricTypeId,a.PunitOfmeasId,a.SUNITOFMEASID,f.unitofmeas,g.unitofmeas,d.fabrictype,
    a.BatchNo,a.SIZEID,s.SIZENAME,a.Shade,a.REMARKS,a.FabricDia,a.FabricGSM,a.Styleno
    having sum(Quantity*CGS)>0 order by a.orderno asc;          
end if;
End GetTransCuttingWOrderList;
/


PROMPT CREATE OR REPLACE Procedure  498 :: GetGarmentsWOTransferInfo
CREATE OR REPLACE Procedure GetGarmentsWOTransferInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  many_cursor IN OUT pReturnData.c_Records,
  pGStockID number
)
AS
BEGIN

    open one_cursor for
    select StockId,ChallanNo, ChallanDate, StockTransNO, StockTransDATE,CUTPIECEREJECT,Jhute,
    ClientID,Remarks, SubConId,Pono,GatepassNo,catid,Fweight,CutWeight,EFFICIENCY,COMPLETE,PRODHOUR
    from T_GStock
    where StockId=pGStockID;

    open many_cursor for
    select a.PID,a.ORDERNO,getfncDispalyorder(a.OrderNo) as btype,fncTransGarmentsOrder(a.STOCKID,GSTOCKITEMSL) as TOrderNo,
	a.STOCKID, a.FABWEIGHT,a.Reject, a.REQQUANTITY,a.GSTOCKITEMSL,'' AS FabricTypeId,a.Quantity,a.Squantity,a.PunitOfmeasId,a.SUNITOFMEASID,
	a.SIZEID,a.cuttingid,a.displayno as cuttingno,a.BatchNo,a.Shade,a.REMARKS,a.CurrentStock,a.subconid,a.FabricDia,a.FabricGSM,a.Styleno,
	a.GTRANSTYPEID,a.countryid,	a.lineno,a.cuttingid, a.bundleno,a.orderlineitem,a.cartonno
    from T_GStockItems a
    where a.GTRANSTYPEID=111 AND 
	a.STOCKID=pGStockID
    order by GSTOCKITEMSL,lineno asc;
END GetGarmentsWOTransferInfo;
/




PROMPT CREATE OR REPLACE Procedure  499 :: GETGarmentsWOTransInsert
CREATE OR REPLACE Procedure GETGarmentsWOTransInsert (
  pStrSql1 IN VARCHAR2,
  pStrSql2 IN VARCHAR2,
  pIdentityName IN VARCHAR2,
  pIdentityFld1 IN VARCHAR2,
  pIdentityFld2 IN VARCHAR2,
  pCurIdentityVal OUT NUMBER,
  pRecsAffected out NUMBER
)
AS
  tmpSql VARCHAR2(1000);
  restSql VARCHAR2(1000);
  insertSql VARCHAR2(1000);
  parentIdentityVal  NUMBER;
  tmpPos NUMBER;
  faults EXCEPTION;
BEGIN
/*========================Main Section(111)======================*/
  execute immediate 'select ' || pIdentityName || '.NEXTVAL from sys.dual'
  into pCurIdentityVal;

  parentIdentityVal:=pCurIdentityVal;

  tmpPos := instr(pStrSql1, '(', 1, 1);
  tmpSql := substr(pStrSql1, 1, tmpPos);
  restSql := substr(pStrSql1, tmpPos+1);
  insertSql := tmpSql || pIdentityFld1 || ','|| pIdentityFld2 || ',';

  tmpPos := instr(restSql, ' values (', 1, 1);
  tmpSql := substr(restSql, 1, tmpPos);
  restSql := substr(restSql, tmpPos+9);

  insertSql := insertSql || tmpSql || ' values (' ||
          TO_CHAR(pCurIdentityVal) || ',' ||TO_CHAR(pCurIdentityVal) || ',' || restSql;

  execute immediate insertSql;
 pRecsAffected := SQL%ROWCOUNT;
/*========================Copy Section(112)======================*/
  execute immediate 'select ' || pIdentityName || '.NEXTVAL from sys.dual'
  into pCurIdentityVal;
  
  tmpPos := instr(pStrSql2, '(', 1, 1);
  tmpSql := substr(pStrSql2, 1, tmpPos);
  restSql := substr(pStrSql2, tmpPos+1);
  insertSql := tmpSql || pIdentityFld1 || ','|| pIdentityFld2 || ',';

  tmpPos := instr(restSql, ' values (', 1, 1);
  tmpSql := substr(restSql, 1, tmpPos);
  restSql := substr(restSql, tmpPos+9);

  insertSql := insertSql || tmpSql || ' values (' ||
          TO_CHAR(pCurIdentityVal) || ',' ||TO_CHAR(parentIdentityVal) || ',' || restSql;

  execute immediate insertSql;
  pRecsAffected := SQL%ROWCOUNT+pRecsAffected;
/*===============================================================*/
	IF (pRecsAffected=2)
	THEN
        COMMIT;
	ELSE
		RAISE faults;
	END IF;
EXCEPTION
	WHEN faults THEN ROLLBACK;
END GETGarmentsWOTransInsert;
/


PROMPT CREATE OR REPLACE Procedure  500 :: GetGarmentsWFabstock
CREATE OR REPLACE Procedure GetGarmentsWFabstock(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pKnitTranTypeID NUMBER,
  pStockDate DATE
)
AS
BEGIN
        /* FGFD*/
    if pQueryType=1 then
    open data_cursor for
    select a.ORDERNO,'' AS FabricTypeId,getfncDispalyorder(a.ORDERNO) as Dorder,a.PunitOfmeasId,a.SUNITOFMEASID as sunitid,
	f.unitofmeas as punit,g.unitofmeas as sunit,'' AS fabrictype,a.BatchNo,a.Shade,a.SIZEID,s.SIZENAME,a.REMARKS,a.FabricDia,
	a.FabricGSM,a.Styleno,sum(Quantity*FGFD) CurrentStock,sum(SQuantity*FGFD) Cursqty
    from T_GStockItems a,T_Gstock b,T_GTransactionType c,T_UnitOfMeas f,T_UnitOfMeas g,T_SIZE s
    where  b.StockID=a.StockID and
	a.SIZEID=s.SIZEID(+) AND
    a.GTRANSTYPEID=c.GTRANSACTIONTYPEID and
    a.PUnitOfMeasID=f.UnitOfMeasID(+)  and
    a.SUnitOfMeasID=g.UnitOfMeasID(+) AND
    STOCKTRANSDATE <= pStockDate
    group by a.ORDERNO,a.PunitOfmeasId,a.SUNITOFMEASID,f.unitofmeas,g.unitofmeas,
    a.BatchNo,a.SIZEID,s.SIZENAME,a.Shade,a.REMARKS,a.FabricDia,a.FabricGSM,a.Styleno
    having sum(Quantity*FGFD)>0 order by a.orderno asc;      
    
end if;
End GetGarmentsWFabstock;
/


PROMPT CREATE OR REPLACE Procedure  501 :: getMachinePartsWiseTransaction
create or Replace Procedure getMachinePartsWiseTransaction(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pPartID NUMBER,
  sDate IN date,
  eDate IN date
)
AS
BEGIN
if (pQueryType=1) then
    open data_cursor for
select a.StockId, a.StockDate, a.ChallanNo, a.ChallanDate,a.DELIVERYNOTE,b.PARTID,c.PARTNAME,c.DESCRIPTION,c.FOREIGNPART,
	b.CURRENTSTOCK,b.QTY,d.UNITOFMEAS as UNIT,e.partsstatus,b.DeptID
	from T_GMcStock a,T_GMcStockItems b,T_GMcPartsInfo c,T_Unitofmeas d,T_GMCPARTSSTATUS e
    where	a.StockID=b.StockID and
			b.PARTID=c.PARTID and
			e.partsstatusid=b.PARTSSTATUSFROMID and
	        b.PARTID=pPartID and
			a.StockDate between sDate and eDate AND
			a.TexMCSTOCKTYPEID=1 and
			b.UNITOFMEASID=d.UNITOFMEASID
    ORDER BY a.StockId, a.StockDate, a.ChallanNo, a.ChallanDate,a.DELIVERYNOTE,c.PARTNAME,c.DESCRIPTION,c.FOREIGNPART,e.partsstatus,b.DeptID;
	
elsif (pQueryType=2) then
    open data_cursor for
select a.StockId, a.StockDate, a.ChallanNo, a.ChallanDate,a.DELIVERYNOTE,b.PARTID,c.PARTNAME,c.DESCRIPTION,c.FOREIGNPART,
	b.CURRENTSTOCK,b.QTY,d.UNITOFMEAS as UNIT,e.partsstatus,b.DeptID
	from T_GMcStock a,T_GMcStockItems b,T_GMcPartsInfo c,T_Unitofmeas d,T_GMCPARTSSTATUS e
    where	a.StockID=b.StockID and
			b.PARTID=c.PARTID and
			e.partsstatusid=b.PARTSSTATUSFROMID and
	        b.PARTID=pPartID and
			a.StockDate between sDate and eDate AND
			a.TexMCSTOCKTYPEID=2 and
			b.UNITOFMEASID=d.UNITOFMEASID
    ORDER BY a.StockId, a.StockDate, a.ChallanNo, a.ChallanDate,a.DELIVERYNOTE,c.PARTNAME,c.DESCRIPTION,c.FOREIGNPART,e.partsstatus,b.DeptID;
	
elsif (pQueryType=3) then
    open data_cursor for
select a.StockId, a.StockDate, a.ChallanNo, a.ChallanDate,a.DELIVERYNOTE,b.PARTID,c.PARTNAME,c.DESCRIPTION,c.FOREIGNPART,
	b.CURRENTSTOCK,b.QTY,d.UNITOFMEAS as UNIT,e.partsstatus,b.DeptID
	from T_GMcStock a,T_GMcStockItems b,T_GMcPartsInfo c,T_Unitofmeas d,T_GMCPARTSSTATUS e
    where	a.StockID=b.StockID and
			b.PARTID=c.PARTID and
			e.partsstatusid=b.PARTSSTATUSFROMID and
	        b.PARTID=pPartID and
			a.StockDate between sDate and eDate AND
			a.TexMCSTOCKTYPEID=3 and
			b.UNITOFMEASID=d.UNITOFMEASID
    ORDER BY a.StockId, a.StockDate, a.ChallanNo, a.ChallanDate,a.DELIVERYNOTE,c.PARTNAME,c.DESCRIPTION,c.FOREIGNPART,e.partsstatus,b.DeptID;
End If;
END getMachinePartsWiseTransaction;
/


PROMPT CREATE OR REPLACE Procedure  502 :: getPartsNameWiseTransaction
create or Replace Procedure getPartsNameWiseTransaction(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pPartID NUMBER,
  sDate IN date,
  eDate IN date
)
AS
BEGIN
/* MachinePartsName */
if (pQueryType=1) then
    open data_cursor for
select a.StockId, a.StockDate, a.ChallanNo, a.ChallanDate,a.DELIVERYNOTE,b.PARTID,c.PARTNAME,c.DESCRIPTION,c.FOREIGNPART,b.QTY,
d.UNITOFMEAS as UNIT,e.partsstatus,f.MPGroupName
	from T_TexMcStock a,T_TexMcStockItems b,T_TexMcPartsInfo c,T_Unitofmeas d,T_TexMCPARTSSTATUS e,T_MPGroup f
    where	a.StockID=b.StockID and
			b.PARTID=c.PARTID and
			b.MPGroupID=f.MPGroupID and
			e.partsstatusid=b.PARTSSTATUSFROMID and
	        b.PARTID=pPartID and
			a.StockDate between sDate and eDate AND
			a.TexMCSTOCKTYPEID=1 and
			b.UNITOFMEASID=d.UNITOFMEASID
    ORDER BY a.StockId, a.StockDate, a.ChallanNo, a.ChallanDate,a.DELIVERYNOTE,c.PARTNAME,c.DESCRIPTION,c.FOREIGNPART,
	e.partsstatus,f.MPGroupName;
	
elsif (pQueryType=2) then
    open data_cursor for
	select a.StockId, a.StockDate, a.ChallanNo, a.ChallanDate,a.DELIVERYNOTE,b.PARTID,c.PARTNAME,c.DESCRIPTION,c.FOREIGNPART,b.QTY,
	'' as UNIT,e.partsstatus,f.MPGroupName
	from T_TexMcStockReq a,T_TexMcStockItemsReq b,T_TexMcPartsInfo c,T_TexMCPARTSSTATUS e,T_MPGroup f
    where	a.StockID=b.StockID and
			b.PARTID=c.PARTID and
			b.MPGroupID=f.MPGroupID and
			e.partsstatusid=b.PARTSSTATUSFROMID and
	        b.PARTID=pPartID and
			a.StockDate between sDate and eDate AND
			a.TexMCSTOCKTYPEID=2
    ORDER BY a.StockId, a.StockDate, a.ChallanNo, a.ChallanDate,a.DELIVERYNOTE,c.PARTNAME,c.DESCRIPTION,c.FOREIGNPART,
	e.partsstatus,f.MPGroupName;
	
elsif (pQueryType=3) then
    open data_cursor for
select a.StockId, a.StockDate, a.ChallanNo, a.ChallanDate,a.DELIVERYNOTE,b.PARTID,c.PARTNAME,c.DESCRIPTION,c.FOREIGNPART,b.QTY,
'' as UNIT,'' AS partsstatus,f.MPGroupName
	from T_TexMcStock a,T_TexMcStockItems b,T_TexMcPartsInfo c,T_MPGroup f
    where	a.StockID=b.StockID and
			b.PARTID=c.PARTID and
			b.MPGroupID=f.MPGroupID and
	        b.PARTID=pPartID and
			a.StockDate between sDate and eDate AND
			a.TexMCSTOCKTYPEID=2
    ORDER BY a.StockId, a.StockDate, a.ChallanNo, a.ChallanDate,a.DELIVERYNOTE,c.PARTNAME,c.DESCRIPTION,c.FOREIGNPART,f.MPGroupName;

elsif (pQueryType=4) then
    open data_cursor for
select a.StockId, a.StockDate, a.ChallanNo, a.ChallanDate,a.DELIVERYNOTE,b.PARTID,c.PARTNAME,c.DESCRIPTION,c.FOREIGNPART,b.QTY,
'' as UNIT,'' as partsstatus,f.MPGroupName
	from T_TexMcStock a,T_TexMcStockItems b,T_TexMcPartsInfo c,T_MPGroup f
    where	a.StockID=b.StockID and
			b.PARTID=c.PARTID and
			b.MPGroupID=f.MPGroupID and
	        b.PARTID=pPartID and
			a.StockDate between sDate and eDate AND
			a.TexMCSTOCKTYPEID=3
    ORDER BY a.StockId, a.StockDate, a.ChallanNo, a.ChallanDate,a.DELIVERYNOTE,c.PARTNAME,c.DESCRIPTION,c.FOREIGNPART,f.MPGroupName;
End If;
END getPartsNameWiseTransaction;
/


PROMPT CREATE OR REPLACE Procedure  503 :: getKmcPartsNameWiseTransaction
create or Replace Procedure getKmcPartsNameWiseTransaction(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pPartID NUMBER,
  sDate IN date,
  eDate IN date
)
AS
BEGIN
/* MachinePartsName */
if (pQueryType=1) then
    open data_cursor for
select a.StockId,a.ChallanNo, a.ChallanDate,b.PARTID,c.PARTNAME,c.DESCRIPTION,c.FOREIGNPART,b.QTY,e.partsstatus,b.MACHINEID
	from T_KmcPartsTran a,T_KMCPARTSTRANSDETAILS b,t_kmcpartsinfo c,t_kmcpartsstatus e
    where	a.StockID=b.StockID and
			b.PARTID=c.PARTID and
			e.partsstatusid=b.PARTSSTATUSFROMID and
	        b.PARTID=pPartID and
			a.ChallanDate between sDate and eDate AND
			a.KmcStockTypeId=1
    ORDER BY a.StockId,a.ChallanNo, a.ChallanDate,b.PARTID,c.PARTNAME,c.DESCRIPTION,c.FOREIGNPART,e.partsstatus;
	
elsif (pQueryType=2) then
    open data_cursor for
select a.StockId,a.ChallanNo, a.ChallanDate,b.PARTID,c.PARTNAME,c.DESCRIPTION,c.FOREIGNPART,b.QTY,e.partsstatus,b.MACHINEID
	from T_KmcPartsTranRequisition a,T_KMCPARTSTRANSDETAILSReq b,t_kmcpartsinfo c,t_kmcpartsstatus e
    where	a.StockID=b.StockID and
			b.PARTID=c.PARTID and
			e.partsstatusid=b.PARTSSTATUSFROMID and
	        b.PARTID=pPartID and
			a.ChallanDate between sDate and eDate AND
			a.KmcStockTypeId=2
    ORDER BY a.StockId,a.ChallanNo, a.ChallanDate,b.PARTID,c.PARTNAME,c.DESCRIPTION,c.FOREIGNPART,e.partsstatus;
	
elsif (pQueryType=3) then
    open data_cursor for
select a.StockId,a.ChallanNo, a.ChallanDate,b.PARTID,c.PARTNAME,c.DESCRIPTION,c.FOREIGNPART,b.QTY,e.partsstatus,b.MACHINEID
	from T_KmcPartsTran a,T_KMCPARTSTRANSDETAILS b,t_kmcpartsinfo c,t_kmcpartsstatus e
    where	a.StockID=b.StockID and
			b.PARTID=c.PARTID and
			e.partsstatusid=b.PARTSSTATUSFROMID and
	        b.PARTID=pPartID and
			a.ChallanDate between sDate and eDate AND
			a.KmcStockTypeId=2
    ORDER BY a.StockId,a.ChallanNo, a.ChallanDate,b.PARTID,c.PARTNAME,c.DESCRIPTION,c.FOREIGNPART,e.partsstatus;
	
elsif (pQueryType=4) then
    open data_cursor for
select a.StockId,a.ChallanNo, a.ChallanDate,b.PARTID,c.PARTNAME,c.DESCRIPTION,c.FOREIGNPART,b.QTY,e.partsstatus,b.MACHINEID
	from T_KmcPartsTran a,T_KMCPARTSTRANSDETAILS b,t_kmcpartsinfo c,t_kmcpartsstatus e
    where	a.StockID=b.StockID and
			b.PARTID=c.PARTID and
			e.partsstatusid=b.PARTSSTATUSFROMID and
	        b.PARTID=pPartID and
			a.ChallanDate between sDate and eDate AND
			a.KmcStockTypeId=3
    ORDER BY a.StockId,a.ChallanNo, a.ChallanDate,b.PARTID,c.PARTNAME,c.DESCRIPTION,c.FOREIGNPART,e.partsstatus;
	
elsif (pQueryType=5) then
    open data_cursor for
select a.StockId,a.ChallanNo, a.ChallanDate,b.PARTID,c.PARTNAME,c.DESCRIPTION,c.FOREIGNPART,b.QTY,e.partsstatus,b.MACHINEID
	from T_KmcPartsTran a,T_KMCPARTSTRANSDETAILS b,t_kmcpartsinfo c,t_kmcpartsstatus e
    where	a.StockID=b.StockID and
			b.PARTID=c.PARTID and
			e.partsstatusid=b.PARTSSTATUSFROMID and
	        b.PARTID=pPartID and
			a.ChallanDate between sDate and eDate AND
			a.KmcStockTypeId=9
    ORDER BY a.StockId,a.ChallanNo, a.ChallanDate,b.PARTID,c.PARTNAME,c.DESCRIPTION,c.FOREIGNPART,e.partsstatus;
	
elsif (pQueryType=6) then
    open data_cursor for
select a.StockId,a.ChallanNo, a.ChallanDate,b.PARTID,c.PARTNAME,c.DESCRIPTION,c.FOREIGNPART,b.QTY,e.partsstatus,b.MACHINEID
	from T_KmcPartsTran a,T_KMCPARTSTRANSDETAILS b,t_kmcpartsinfo c,t_kmcpartsstatus e
    where	a.StockID=b.StockID and
			b.PARTID=c.PARTID and
			e.partsstatusid=b.PARTSSTATUSFROMID and
	        b.PARTID=pPartID and
			a.ChallanDate between sDate and eDate AND
			a.KmcStockTypeId=11
    ORDER BY a.StockId,a.ChallanNo, a.ChallanDate,b.PARTID,c.PARTNAME,c.DESCRIPTION,c.FOREIGNPART,e.partsstatus;
End If;
END getKmcPartsNameWiseTransaction;
/


PROMPT CREATE OR REPLACE Procedure  504 :: getAuxTypeWiseTransaction
create or Replace Procedure getAuxTypeWiseTransaction(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pAuxID NUMBER,
  sDate IN date,
  eDate IN date
)
AS
BEGIN
/* MachinePartsName */
if (pQueryType=1) then
    open data_cursor for
select a.AuxStockId, a.STOCKINVOICENO, a.STOCKDATE, a.PURCHASEORDERNO,a.PURCHASEORDERDATE,b.AUXTYPEID,c.AUXNAME,c.DYEBASEID,
    d.AuxType,b.AUXID,b.STOCKREQQTY,b.STOCKQTY,b.REMARKS,b.CURRENTSTOCK
	from t_auxStock a, T_AuxStockItem b, T_Auxiliaries c,T_AuxType d
	 where a.AuxStockId=b.AuxStockId and 
	 b.AuxId=c.AuxId and
	 d.AuxTypeId = c.AuxTypeId and
	 b.AuxId=pAuxID AND
	a.StockDate between sDate and eDate AND
    a.AuxStockTypeId=1
	order by a.AuxStockId, a.STOCKINVOICENO, a.STOCKDATE, a.PURCHASEORDERNO,b.AUXTYPEID,c.AUXNAME,c.DYEBASEID,b.AUXID,b.REMARKS;
	
elsif (pQueryType=2) then
    open data_cursor for
select a.AuxStockId, a.STOCKINVOICENO, a.STOCKDATE, a.PURCHASEORDERNO,a.PURCHASEORDERDATE,b.AUXTYPEID,c.AUXNAME,c.DYEBASEID,
    d.AuxType,b.AUXID,b.STOCKREQQTY,b.STOCKQTY,b.REMARKS,b.CURRENTSTOCK
	from t_auxStock a, T_AuxStockItem b, T_Auxiliaries c,T_AuxType d
	 where a.AuxStockId=b.AuxStockId and 
	 b.AuxId=c.AuxId and
	 d.AuxTypeId = c.AuxTypeId and
	 b.AuxId=pAuxID AND
	a.StockDate between sDate and eDate AND
    a.AuxStockTypeId=2
	order by a.AuxStockId, a.STOCKINVOICENO, a.STOCKDATE, a.PURCHASEORDERNO,b.AUXTYPEID,c.AUXNAME,c.DYEBASEID,b.AUXID,b.REMARKS;
	
elsif (pQueryType=3) then
    open data_cursor for
select a.AuxStockId, a.STOCKINVOICENO, a.STOCKDATE, a.PURCHASEORDERNO,a.PURCHASEORDERDATE,b.AUXTYPEID,c.AUXNAME,c.DYEBASEID,
    d.AuxType,b.AUXID,b.STOCKREQQTY,b.STOCKQTY,b.REMARKS,b.CURRENTSTOCK
	from t_auxStock a, T_AuxStockItem b, T_Auxiliaries c,T_AuxType d
	 where a.AuxStockId=b.AuxStockId and 
	 b.AuxId=c.AuxId and
	 d.AuxTypeId = c.AuxTypeId and
	 b.AuxId=pAuxID AND
	a.StockDate between sDate and eDate AND
    a.AuxStockTypeId=3
	order by a.AuxStockId, a.STOCKINVOICENO, a.STOCKDATE, a.PURCHASEORDERNO,b.AUXTYPEID,c.AUXNAME,c.DYEBASEID,b.AUXID,b.REMARKS;
	
elsif (pQueryType=4) then
    open data_cursor for
select a.AuxStockId, a.STOCKINVOICENO, a.STOCKDATE, a.PURCHASEORDERNO,a.PURCHASEORDERDATE,b.AUXTYPEID,c.AUXNAME,c.DYEBASEID,
    d.AuxType,b.AUXID,b.STOCKREQQTY,b.STOCKQTY,b.REMARKS,b.CURRENTSTOCK
	from t_auxStock a, T_AuxStockItem b, T_Auxiliaries c,T_AuxType d
	 where a.AuxStockId=b.AuxStockId and 
	 b.AuxId=c.AuxId and
	 d.AuxTypeId = c.AuxTypeId and
	 b.AuxId=pAuxID AND
	a.StockDate between sDate and eDate AND
    a.AuxStockTypeId=12
	order by a.AuxStockId, a.STOCKINVOICENO, a.STOCKDATE, a.PURCHASEORDERNO,b.AUXTYPEID,c.AUXNAME,c.DYEBASEID,b.AUXID,b.REMARKS;
	
elsif (pQueryType=5) then
    open data_cursor for
select a.AuxStockId, a.STOCKINVOICENO, a.STOCKDATE, a.PURCHASEORDERNO,a.PURCHASEORDERDATE,b.AUXTYPEID,c.AUXNAME,c.DYEBASEID,
    d.AuxType,b.AUXID,b.STOCKREQQTY,b.STOCKQTY,b.REMARKS,b.CURRENTSTOCK
	from t_auxStock a, T_AuxStockItem b, T_Auxiliaries c,T_AuxType d
	 where a.AuxStockId=b.AuxStockId and 
	 b.AuxId=c.AuxId and
	 d.AuxTypeId = c.AuxTypeId and
	 b.AuxId=pAuxID AND
	a.StockDate between sDate and eDate AND
    a.AuxStockTypeId=14
	order by a.AuxStockId, a.STOCKINVOICENO, a.STOCKDATE, a.PURCHASEORDERNO,b.AUXTYPEID,c.AUXNAME,c.DYEBASEID,b.AUXID,b.REMARKS;

elsif (pQueryType=6) then
    open data_cursor for
select a.AuxStockId, a.STOCKINVOICENO, a.STOCKDATE, a.PURCHASEORDERNO,a.PURCHASEORDERDATE,b.AUXTYPEID,c.AUXNAME,c.DYEBASEID,
    d.AuxType,b.AUXID,b.STOCKREQQTY,b.STOCKQTY,b.REMARKS,b.CURRENTSTOCK
	from t_auxStock a, T_AuxStockItem b, T_Auxiliaries c,T_AuxType d
	 where a.AuxStockId=b.AuxStockId and 
	 b.AuxId=c.AuxId and
	 d.AuxTypeId = c.AuxTypeId and
	 b.AuxId=pAuxID AND
	a.StockDate between sDate and eDate AND
    a.AuxStockTypeId=4
	order by a.AuxStockId, a.STOCKINVOICENO, a.STOCKDATE, a.PURCHASEORDERNO,b.AUXTYPEID,c.AUXNAME,c.DYEBASEID,b.AUXID,b.REMARKS;
	
elsif (pQueryType=7) then
    open data_cursor for
select a.AuxStockId, a.STOCKINVOICENO, a.STOCKDATE, a.PURCHASEORDERNO,a.PURCHASEORDERDATE,b.AUXTYPEID,c.AUXNAME,c.DYEBASEID,
    d.AuxType,b.AUXID,b.STOCKREQQTY,b.STOCKQTY,b.REMARKS,b.CURRENTSTOCK
	from t_auxStock a, T_AuxStockItem b, T_Auxiliaries c,T_AuxType d
	 where a.AuxStockId=b.AuxStockId and 
	 b.AuxId=c.AuxId and
	 d.AuxTypeId = c.AuxTypeId and
	 b.AuxId=pAuxID AND
	a.StockDate between sDate and eDate AND
    a.AuxStockTypeId=5
	order by a.AuxStockId, a.STOCKINVOICENO, a.STOCKDATE, a.PURCHASEORDERNO,b.AUXTYPEID,c.AUXNAME,c.DYEBASEID,b.AUXID,b.REMARKS;
	
elsif (pQueryType=8) then
    open data_cursor for
select a.AuxStockId, a.STOCKINVOICENO, a.STOCKDATE, a.PURCHASEORDERNO,a.PURCHASEORDERDATE,b.AUXTYPEID,c.AUXNAME,c.DYEBASEID,
    d.AuxType,b.AUXID,b.STOCKREQQTY,b.STOCKQTY,b.REMARKS,b.CURRENTSTOCK
	from t_auxStock a, T_AuxStockItem b, T_Auxiliaries c,T_AuxType d
	 where a.AuxStockId=b.AuxStockId and 
	 b.AuxId=c.AuxId and
	 d.AuxTypeId = c.AuxTypeId and
	 b.AuxId=pAuxID AND
	a.StockDate between sDate and eDate AND
    a.AuxStockTypeId=6
	order by a.AuxStockId, a.STOCKINVOICENO, a.STOCKDATE, a.PURCHASEORDERNO,b.AUXTYPEID,c.AUXNAME,c.DYEBASEID,b.AUXID,b.REMARKS;
	
elsif (pQueryType=9) then
    open data_cursor for
select a.AuxStockId, a.STOCKINVOICENO, a.STOCKDATE, a.PURCHASEORDERNO,a.PURCHASEORDERDATE,b.AUXTYPEID,c.AUXNAME,c.DYEBASEID,
    d.AuxType,b.AUXID,b.STOCKREQQTY,b.STOCKQTY,b.REMARKS,b.CURRENTSTOCK
	from t_auxStock a, T_AuxStockItem b, T_Auxiliaries c,T_AuxType d
	 where a.AuxStockId=b.AuxStockId and 
	 b.AuxId=c.AuxId and
	 d.AuxTypeId = c.AuxTypeId and
	 b.AuxId=pAuxID AND
	a.StockDate between sDate and eDate AND
    a.AuxStockTypeId=7
	order by a.AuxStockId, a.STOCKINVOICENO, a.STOCKDATE, a.PURCHASEORDERNO,b.AUXTYPEID,c.AUXNAME,c.DYEBASEID,b.AUXID,b.REMARKS;

elsif (pQueryType=10) then
    open data_cursor for
select a.AuxStockId, a.STOCKINVOICENO, a.STOCKDATE, a.PURCHASEORDERNO,a.PURCHASEORDERDATE,b.AUXTYPEID,c.AUXNAME,c.DYEBASEID,
    d.AuxType,b.AUXID,b.STOCKREQQTY,b.STOCKQTY,b.REMARKS,b.CURRENTSTOCK
	from t_auxStock a, T_AuxStockItem b, T_Auxiliaries c,T_AuxType d
	 where a.AuxStockId=b.AuxStockId and 
	 b.AuxId=c.AuxId and
	 d.AuxTypeId = c.AuxTypeId and
	 b.AuxId=pAuxID AND
	a.StockDate between sDate and eDate AND
    a.AuxStockTypeId=8
	order by a.AuxStockId, a.STOCKINVOICENO, a.STOCKDATE, a.PURCHASEORDERNO,b.AUXTYPEID,c.AUXNAME,c.DYEBASEID,b.AUXID,b.REMARKS;
	
elsif (pQueryType=11) then
    open data_cursor for
select a.AuxStockId, a.STOCKINVOICENO, a.STOCKDATE, a.PURCHASEORDERNO,a.PURCHASEORDERDATE,b.AUXTYPEID,c.AUXNAME,c.DYEBASEID,
    d.AuxType,b.AUXID,b.STOCKREQQTY,b.STOCKQTY,b.REMARKS,b.CURRENTSTOCK
	from t_auxStock a, T_AuxStockItem b, T_Auxiliaries c,T_AuxType d
	 where a.AuxStockId=b.AuxStockId and 
	 b.AuxId=c.AuxId and
	 d.AuxTypeId = c.AuxTypeId and
	 b.AuxId=pAuxID AND
	a.StockDate between sDate and eDate AND
    a.AuxStockTypeId=10
	order by a.AuxStockId, a.STOCKINVOICENO, a.STOCKDATE, a.PURCHASEORDERNO,b.AUXTYPEID,c.AUXNAME,c.DYEBASEID,b.AUXID,b.REMARKS;
	
elsif (pQueryType=12) then
    open data_cursor for
select a.AuxStockId, a.STOCKINVOICENO, a.STOCKDATE, a.PURCHASEORDERNO,a.PURCHASEORDERDATE,b.AUXTYPEID,c.AUXNAME,c.DYEBASEID,
    d.AuxType,b.AUXID,b.STOCKREQQTY,b.STOCKQTY,b.REMARKS,b.CURRENTSTOCK
	from t_auxStock a, T_AuxStockItem b, T_Auxiliaries c,T_AuxType d
	 where a.AuxStockId=b.AuxStockId and 
	 b.AuxId=c.AuxId and
	 d.AuxTypeId = c.AuxTypeId and
	 b.AuxId=pAuxID AND
	a.StockDate between sDate and eDate AND
    a.AuxStockTypeId=9
	order by a.AuxStockId, a.STOCKINVOICENO, a.STOCKDATE, a.PURCHASEORDERNO,b.AUXTYPEID,c.AUXNAME,c.DYEBASEID,b.AUXID,b.REMARKS;
	
elsif (pQueryType=13) then
    open data_cursor for
select a.AuxStockId, a.STOCKINVOICENO, a.STOCKDATE, a.PURCHASEORDERNO,a.PURCHASEORDERDATE,b.AUXTYPEID,c.AUXNAME,c.DYEBASEID,
    d.AuxType,b.AUXID,b.STOCKREQQTY,b.STOCKQTY,b.REMARKS,b.CURRENTSTOCK
	from t_auxStock a, T_AuxStockItem b, T_Auxiliaries c,T_AuxType d
	 where a.AuxStockId=b.AuxStockId and 
	 b.AuxId=c.AuxId and
	 d.AuxTypeId = c.AuxTypeId and
	 b.AuxId=pAuxID AND
	a.StockDate between sDate and eDate AND
    a.AuxStockTypeId=13
	order by a.AuxStockId, a.STOCKINVOICENO, a.STOCKDATE, a.PURCHASEORDERNO,b.AUXTYPEID,c.AUXNAME,c.DYEBASEID,b.AUXID,b.REMARKS;
	
elsif (pQueryType=14) then
    open data_cursor for
select a.AuxStockId, a.STOCKINVOICENO, a.STOCKDATE, a.PURCHASEORDERNO,a.PURCHASEORDERDATE,b.AUXTYPEID,c.AUXNAME,c.DYEBASEID,
    d.AuxType,b.AUXID,b.STOCKREQQTY,b.STOCKQTY,b.REMARKS,b.CURRENTSTOCK
	from t_auxStock a, T_AuxStockItem b, T_Auxiliaries c,T_AuxType d
	 where a.AuxStockId=b.AuxStockId and 
	 b.AuxId=c.AuxId and
	 d.AuxTypeId = c.AuxTypeId and
	 b.AuxId=pAuxID AND
	a.StockDate between sDate and eDate AND
    a.AuxStockTypeId=11
	order by a.AuxStockId, a.STOCKINVOICENO, a.STOCKDATE, a.PURCHASEORDERNO,b.AUXTYPEID,c.AUXNAME,c.DYEBASEID,b.AUXID,b.REMARKS;
End If;
END getAuxTypeWiseTransaction;
/


PROMPT CREATE OR REPLACE Procedure  505 :: getMaterialWiseTransaction
create or Replace Procedure getMaterialWiseTransaction(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pStationeryID NUMBER,
  sDate IN date,
  eDate IN date
)
AS
BEGIN
/* Material Description */
if (pQueryType=1) then
    open data_cursor for
select a.STOCKID,a.STOCKTRANSNO,a.STOCKTRANSDATE,a.SUPPLIERINVOICENO,a.SUPPLIERINVOICEDATE,b.STATIONERYID,0 as DEPTID,b.GROUPID,b.BRANDID,b.COUNTRYID,
b.PUNITOFMEASID,b.CURRENTSTOCK,b.QUANTITY,b.REMARKS
 from t_stationerystock a,t_stationerystockItems b
 where a.STOCKID=b.STOCKID and
  b.STATIONERYID=pStationeryID and
  a.STOCKTRANSDATE >=sDate and a.STOCKTRANSDATE <=eDate and
  a.stocktype=1
  order by  a.STOCKID,a.STOCKTRANSNO,a.STOCKTRANSDATE,a.SUPPLIERINVOICENO,a.SUPPLIERINVOICEDATE,b.STATIONERYID,b.GROUPID,b.BRANDID,b.COUNTRYID;	
  
elsif (pQueryType=2) then
    open data_cursor for
select a.STOCKID,a.STOCKTRANSNO,a.STOCKTRANSDATE,a.SUPPLIERINVOICENO,a.SUPPLIERINVOICEDATE,b.DEPTID,b.STATIONERYID,b.GROUPID,b.BRANDID,b.COUNTRYID,
b.PUNITOFMEASID,b.CURRENTSTOCK,b.QUANTITY,b.REMARKS
 from t_stationerystock a,t_stationerystockItems b
 where a.STOCKID=b.STOCKID and
  b.STATIONERYID=pStationeryID and
  a.STOCKTRANSDATE >=sDate and a.STOCKTRANSDATE <=eDate and
  a.stocktype=4
  order by  a.STOCKID,a.STOCKTRANSNO,a.STOCKTRANSDATE,a.SUPPLIERINVOICENO,a.SUPPLIERINVOICEDATE,b.DEPTID,b.STATIONERYID,b.GROUPID,b.BRANDID,b.COUNTRYID;	
End If;
END getMaterialWiseTransaction;
/





PROMPT CREATE OR REPLACE Procedure  506 :: getAccOrderWiseTransaction
create or Replace Procedure getAccOrderWiseTransaction(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pGOrder NUMBER,
  sDate IN date,
  eDate IN date
)
AS
BEGIN
if (pQueryType=1) then
    open data_cursor for	
	select a.StockId,a.StockTransNo,a.StockTransDate,a.ReferenceNo,b.GOrderNo, b.ClientRef,b.ORDERNO,
	b.GroupID, b.AccessoriesID,b.StyleNo,b.ColourID,b.Code,b.Count_Size,b.Quantity,b.PunitOfMeasId,
	b.CurrentStock,b.ReqQuantity,b.Remarks
    from T_AccStock a,T_AccStockItems b
	where a.StockID=b.StockID and
		b.GOrderNo=pGOrder and
		a.StockTransDate>=sDate and a.StockTransDate<=eDate and
		a.AccTransTypeID=1
	order by a.StockId,a.StockTransNo,a.StockTransDate,b.GOrderNo,b.ClientRef,b.ORDERNO,b.GroupID, b.AccessoriesID,b.StyleNo,
		b.ColourID,b.Remarks;
		
elsif (pQueryType=2) then
    open data_cursor for	
	select a.StockId,a.StockTransNo,a.StockTransDate,a.ReferenceNo,b.GOrderNo, b.ClientRef,b.ORDERNO,
	b.GroupID, b.AccessoriesID,b.StyleNo,b.ColourID,b.Code,b.Count_Size,b.Quantity,b.PunitOfMeasId,
	b.CurrentStock,b.ReqQuantity,b.Remarks
    from T_AccStock a,T_AccStockItems b
	where a.StockID=b.StockID and
		b.GOrderNo=pGOrder and
		a.StockTransDate>=sDate and a.StockTransDate<=eDate and
		a.AccTransTypeID=5
	order by a.StockId,a.StockTransNo,a.StockTransDate,b.GOrderNo,b.ClientRef,b.ORDERNO,b.GroupID, b.AccessoriesID,b.StyleNo,
		b.ColourID,b.Remarks;
		
elsif (pQueryType=3) then
    open data_cursor for	
	select a.StockId,a.StockTransNo,a.StockTransDate,a.ReferenceNo,b.GOrderNo, b.ClientRef,b.ORDERNO,
	b.GroupID, b.AccessoriesID,b.StyleNo,b.ColourID,b.Code,b.Count_Size,b.Quantity,b.PunitOfMeasId,
	b.CurrentStock,b.ReqQuantity,b.Remarks
    from T_AccStock a,T_AccStockItems b
	where a.StockID=b.StockID and
		b.GOrderNo=pGOrder and
		a.StockTransDate>=sDate and a.StockTransDate<=eDate and
		a.AccTransTypeID=2
	order by a.StockId,a.StockTransNo,a.StockTransDate,b.GOrderNo,b.ClientRef,b.ORDERNO,b.GroupID, b.AccessoriesID,b.StyleNo,
		b.ColourID,b.Remarks;
		
elsif (pQueryType=4) then
    open data_cursor for	
	select a.StockId,a.StockTransNo,a.StockTransDate,a.ReferenceNo,b.GOrderNo, b.ClientRef,b.ORDERNO,
	b.GroupID, b.AccessoriesID,b.StyleNo,b.ColourID,b.Code,b.Count_Size,b.Quantity,b.PunitOfMeasId,
	b.CurrentStock,b.ReqQuantity,b.Remarks
    from T_AccStock a,T_AccStockItems b
	where a.StockID=b.StockID and
		b.GOrderNo=pGOrder and
		a.StockTransDate>=sDate and a.StockTransDate<=eDate and
		a.AccTransTypeID=4
	order by a.StockId,a.StockTransNo,a.StockTransDate,b.GOrderNo,b.ClientRef,b.ORDERNO,b.GroupID, b.AccessoriesID,b.StyleNo,
		b.ColourID,b.Remarks;
		
elsif (pQueryType=5) then
    open data_cursor for	
	select a.StockId,a.StockTransNo,a.StockTransDate,a.ReferenceNo,b.GOrderNo, b.ClientRef,b.ORDERNO,
	b.GroupID, b.AccessoriesID,b.StyleNo,b.ColourID,b.Code,b.Count_Size,b.Quantity,b.PunitOfMeasId,
	b.CurrentStock,b.ReqQuantity,b.Remarks
    from T_AccStock a,T_AccStockItems b
	where a.StockID=b.StockID and
		b.GOrderNo=pGOrder and
		a.StockTransDate>=sDate and a.StockTransDate<=eDate and
		a.AccTransTypeID=7
	order by a.StockId,a.StockTransNo,a.StockTransDate,b.GOrderNo,b.ClientRef,b.ORDERNO,b.GroupID, b.AccessoriesID,b.StyleNo,
		b.ColourID,b.Remarks;
		
elsif (pQueryType=6) then
    open data_cursor for	
	select a.StockId,a.StockTransNo,a.StockTransDate,a.ReferenceNo,b.GOrderNo, b.ClientRef,b.ORDERNO,
	b.GroupID, b.AccessoriesID,b.StyleNo,b.ColourID,b.Code,b.Count_Size,b.Quantity,b.PunitOfMeasId,
	b.CurrentStock,b.ReqQuantity,b.Remarks
    from T_AccStock a,T_AccStockItems b
	where a.StockID=b.StockID and
		b.AccessoriesID=pGOrder and
		a.StockTransDate>=sDate and a.StockTransDate<=eDate and
		a.AccTransTypeID=1
	order by a.StockId,a.StockTransNo,a.StockTransDate,b.GOrderNo,b.ClientRef,b.ORDERNO,b.GroupID, b.AccessoriesID,b.StyleNo,
		b.ColourID,b.Remarks;
		
elsif (pQueryType=7) then
    open data_cursor for	
	select a.StockId,a.StockTransNo,a.StockTransDate,a.ReferenceNo,b.GOrderNo, b.ClientRef,b.ORDERNO,
	b.GroupID, b.AccessoriesID,b.StyleNo,b.ColourID,b.Code,b.Count_Size,b.Quantity,b.PunitOfMeasId,
	b.CurrentStock,b.ReqQuantity,b.Remarks
    from T_AccStock a,T_AccStockItems b
	where a.StockID=b.StockID and
		b.AccessoriesID=pGOrder and
		a.StockTransDate>=sDate and a.StockTransDate<=eDate and
		a.AccTransTypeID=5
	order by a.StockId,a.StockTransNo,a.StockTransDate,b.GOrderNo,b.ClientRef,b.ORDERNO,b.GroupID, b.AccessoriesID,b.StyleNo,
		b.ColourID,b.Remarks;
		
elsif (pQueryType=8) then
    open data_cursor for	
	select a.StockId,a.StockTransNo,a.StockTransDate,a.ReferenceNo,b.GOrderNo, b.ClientRef,b.ORDERNO,
	b.GroupID, b.AccessoriesID,b.StyleNo,b.ColourID,b.Code,b.Count_Size,b.Quantity,b.PunitOfMeasId,
	b.CurrentStock,b.ReqQuantity,b.Remarks
    from T_AccStock a,T_AccStockItems b
	where a.StockID=b.StockID and
		b.AccessoriesID=pGOrder and
		a.StockTransDate>=sDate and a.StockTransDate<=eDate and
		a.AccTransTypeID=2
	order by a.StockId,a.StockTransNo,a.StockTransDate,b.GOrderNo,b.ClientRef,b.ORDERNO,b.GroupID, b.AccessoriesID,b.StyleNo,
		b.ColourID,b.Remarks;
		
elsif (pQueryType=9) then
    open data_cursor for	
	select a.StockId,a.StockTransNo,a.StockTransDate,a.ReferenceNo,b.GOrderNo, b.ClientRef,b.ORDERNO,
	b.GroupID, b.AccessoriesID,b.StyleNo,b.ColourID,b.Code,b.Count_Size,b.Quantity,b.PunitOfMeasId,
	b.CurrentStock,b.ReqQuantity,b.Remarks
    from T_AccStock a,T_AccStockItems b
	where a.StockID=b.StockID and
		b.AccessoriesID=pGOrder and
		a.StockTransDate>=sDate and a.StockTransDate<=eDate and
		a.AccTransTypeID=4
	order by a.StockId,a.StockTransNo,a.StockTransDate,b.GOrderNo,b.ClientRef,b.ORDERNO,b.GroupID, b.AccessoriesID,b.StyleNo,
		b.ColourID,b.Remarks;
		
elsif (pQueryType=10) then
    open data_cursor for	
	select a.StockId,a.StockTransNo,a.StockTransDate,a.ReferenceNo,b.GOrderNo, b.ClientRef,b.ORDERNO,
	b.GroupID, b.AccessoriesID,b.StyleNo,b.ColourID,b.Code,b.Count_Size,b.Quantity,b.PunitOfMeasId,
	b.CurrentStock,b.ReqQuantity,b.Remarks
    from T_AccStock a,T_AccStockItems b
	where a.StockID=b.StockID and
		b.AccessoriesID=pGOrder and
		a.StockTransDate>=sDate and a.StockTransDate<=eDate and
		a.AccTransTypeID=7
	order by a.StockId,a.StockTransNo,a.StockTransDate,b.GOrderNo,b.ClientRef,b.ORDERNO,b.GroupID, b.AccessoriesID,b.StyleNo,
		b.ColourID,b.Remarks;
End If;
END getAccOrderWiseTransaction;
/



PROMPT CREATE OR REPLACE Procedure  507 :: GetWORateUpdateByBudget
CREATE OR REPLACE Procedure GetWORateUpdateByBudget
(
 pBUDGETID IN NUMBER,
 pRecsAffected out NUMBER
)
AS
 tmpVALUE NUMBER;
 tmpQTYKG NUMBER;
BEGIN
 SELECT LCVALUE INTO tmpVALUE FROM T_BUDGET WHERE BUDGETID=pBUDGETID;

 SELECT DECODE(SUM(TOTALCONSUMPTION),0,1) INTO tmpQTYKG FROM T_FABRICCONSUMPTION WHERE BUDGETID=pBUDGETID;

 IF ((tmpVALUE<>0) OR (tmpQTYKG<>0)) THEN
  UPDATE T_WORKORDER SET PRATE=(tmpVALUE/tmpQTYKG)
  WHERE BUDGETID=pBUDGETID;
  pRecsAffected:=(tmpVALUE/tmpQTYKG);
 ELSE
  pRecsAffected:=100;
 END IF;

END GetWORateUpdateByBudget;
/

PROMPT CREATE OR REPLACE Procedure  508 :: GetGMcPWAvgPrice
CREATE OR REPLACE Procedure GetGMcPWAvgPrice(
  pStockID IN NUMBER,
  pPID IN NUMBER,
  pStockDate DATE, 
  pRecsAffected out NUMBER
)
AS
  tmpConRate NUMBER;
  tmpUPrice NUMBER;
  tmpCheck NUMBER;
  tmpTotQty NUMBER;
  tmpUCheck NUMBER;
  tmpDouble NUMBER;
  tmpcOUNT NUMBER;
  tmpqtycheck NUMBER;
  faults EXCEPTION;

BEGIN
 SELECT CONRATE INTO tmpConRate FROM T_GMcStock WHERE StockID=pStockID;
  SELECT sCOMPLETE INTO tmpCheck FROM T_GMcStock WHERE StockID=pStockID;
  
 	for rec in (select PID,PARTID,QTY,UNITPRICE from T_GMcStockItems where pid=pPID)
        LOOP	
		select count(*) into tmpqtycheck
     		from T_GMcStock a, T_GMcStockItems b, T_GMcStockStatus c
     		where a.StockID=b.StockID and a.TEXMCSTOCKTYPEID=c.TEXMCSTOCKTYPEID and 
     		B.PARTSSTATUSTOID=C.PARTSSTATUSTOID and PARTID=rec.PARTID
     		group by b.PARTID;
		if((tmpqtycheck-1)<>0) then		
			select sum(QTY) into tmpTotQty
				from T_GMcStock a, T_GMcStockItems b
				where a.StockID=b.StockID and PARTID=rec.PARTID and b.pid<rec.pid
				group by b.PARTID;
		else 
			tmpTotQty:=0;
		end if;

		SELECT count(*) into tmpUCheck FROM T_GMcPartsPrice WHERE PARTID=rec.PARTID AND PURCHASEDATE=(SELECT decode(MAX(PURCHASEDATE),null,'01-jan-1900',MAX(PURCHASEDATE)) FROM T_GMcPartsPrice
			WHERE PARTID=rec.PARTID AND PURCHASEDATE<pStockDate);	
			
 		IF (tmpUCheck=1) then
			SELECT UNITPRICE into tmpUPrice FROM T_GMcPartsPrice WHERE PARTID=rec.PARTID AND 
			PURCHASEDATE=(SELECT decode(MAX(PURCHASEDATE),null,'01-jan-1900',MAX(PURCHASEDATE)) FROM T_GMcPartsPrice 
			WHERE PARTID=rec.PARTID AND PURCHASEDATE<pStockDate);
		ELSE
  			tmpUPrice:=0;
 		END IF;
		pRecsAffected := SQL%ROWCOUNT;

		SELECT COUNT(*) into tmpcOUNT FROM T_GMcPartsPrice WHERE PARTID=rec.partid AND PURCHASEDATE=pStockDate AND REFPID=rec.PID;

		IF (tmpcOUNT=0) THEN  /* CHECK INSERT OR UPDATE */
            INSERT INTO T_GMcPartsPrice(PID,PARTID,PURCHASEDATE,UNITPRICE,SUPPLIERNAME,QTY,PPRICE,PQTY,NPRICE,NQTY,REFPID)
			SELECT SEQ_GMcPartsPricePID.Nextval,PARTID,pStockDate,NVL(((rec.QTY*(rec.UNITPRICE*tmpConRate))+tmpTotQty*tmpUPrice)/(rec.QTY+tmpTotQty),0),((select SUPPLIERNAME from T_GMcStock where T_GMcStock.stockid=pStockID)),(rec.QTY+tmpTotQty),tmpUPrice,tmpTotQty,rec.UNITPRICE*tmpConRate,rec.qty,rec.pid
				from T_GMcStockItems WHERE PID=rec.PID;		
		ELSE 
			UPDATE T_GMcPartsPrice SET UNITPRICE=NVL(((rec.QTY*(rec.UNITPRICE*tmpConRate))+tmpTotQty*tmpUPrice)/(rec.QTY+tmpTotQty),0),QTY=(rec.QTY+tmpTotQty),PPRICE=tmpUPrice,PQTY=tmpTotQty,NPRICE=rec.UNITPRICE,NQTY=rec.QTY
				WHERE PARTID=rec.partid AND PURCHASEDATE=pStockDate AND REFPID=rec.PID;
		END IF;
		
		UPDATE T_GMCPARTSINFO 
			SET WAVGPRICE=NVL(((rec.QTY*(rec.UNITPRICE*tmpConRate))+tmpTotQty*tmpUPrice)/(rec.QTY+tmpTotQty),0)
			WHERE PARTID=rec.PARTID;
			
  	    pRecsAffected := SQL%ROWCOUNT+pRecsAffected; 	  
	IF (pRecsAffected=2) THEN
         	COMMIT;
	ELSE
  		RAISE faults;
 	END IF;
        END loop;	
 EXCEPTION
  WHEN faults THEN ROLLBACK;
END GetGMcPWAvgPrice;
/




PROMPT CREATE OR REPLACE Procedure  509 :: GetStationeryWAvgPrice
CREATE OR REPLACE Procedure GetStationeryWAvgPrice(
  pSTOCKID IN NUMBER,
  pPID IN NUMBER,
  pStockDate DATE,
  pRecsAffected out NUMBER
)
AS
  tmpNextPID NUMBER;
  tmpConRate NUMBER;
  tmpUPrice NUMBER;
  tmpPQTY NUMBER;
  tmpUCheck NUMBER;
  tmpcOUNT NUMBER;
  tmpqtycheck NUMBER;
  faults EXCEPTION;
BEGIN
  SELECT CONRATE INTO tmpConRate FROM T_StationeryStock WHERE STOCKID=pSTOCKID;
 	for rec in (select b.PID,b.StationeryID,b.QUANTITY,b.UNITPRICE,a.CURRENCYID,a.CONRATE from T_StationeryStock a,T_StationeryStockItems b 
		where a.STOCKID=b.STOCKID and b.PID=pPID)
        LOOP
		select count(*) into tmpqtycheck
     		from T_StationeryStock a, T_StationeryStockItems b
     		where a.STOCKID=b.STOCKID and b.StationeryID=rec.StationeryID 
     		group by b.StationeryID ;
	if((tmpqtycheck-1)<>0) then	
			SELECT DECODE((select sum(QUANTITY)
     		from T_StationeryStock a, T_StationeryStockItems b
     		where a.STOCKID=b.STOCKID and StationeryID=rec.StationeryID AND B.PID<rec.PID
     		group by b.StationeryID),NULL,0,(select sum(QUANTITY)
     		from T_StationeryStock a, T_StationeryStockItems b
     		where a.STOCKID=b.STOCKID and StationeryID=rec.StationeryID AND B.PID<rec.PID
     		group by b.StationeryID))  into tmpPQTY FROM DUAL;
	else 
		tmpPQTY:=0;
	end if;
		SELECT count(*) into tmpUCheck FROM T_StationeryPrice WHERE StationeryID=rec.StationeryID AND 
		PURCHASEDATE=(SELECT decode(MAX(PURCHASEDATE),null,'01-jan-1900',MAX(PURCHASEDATE)) FROM T_StationeryPrice 
			WHERE StationeryID=rec.StationeryID AND PURCHASEDATE<pStockDate);

 		IF (tmpUCheck=1) then
			SELECT UNITPRICE into tmpUPrice FROM T_StationeryPrice WHERE StationeryID=rec.StationeryID AND 
			PURCHASEDATE=(SELECT decode(MAX(PURCHASEDATE),null,'01-jan-1900',MAX(PURCHASEDATE)) FROM T_StationeryPrice 
			WHERE StationeryID=rec.StationeryID AND PURCHASEDATE<pStockDate);	
		ELSE
  			tmpUPrice:=0;
 		END IF;
		pRecsAffected := SQL%ROWCOUNT;

		SELECT COUNT(*) into tmpcOUNT FROM T_StationeryPrice WHERE StationeryID=rec.StationeryID AND PURCHASEDATE=pStockDate AND REFPID=rec.PID;

		IF (tmpcOUNT=0) THEN  /* CHECK INSERT OR UPDATE */
			SELECT MAX(PID)+1 INTO tmpNextPID from T_StationeryPrice;
					
            INSERT INTO T_StationeryPrice(PID,StationeryID,PURCHASEDATE,UNITPRICE,SUPPLIERID,QTY,PPRICE,PQTY,NPRICE,NQTY,REFPID,CURRENCYID,CONRATE)
 			SELECT tmpNextPID,StationeryID,pStockDate,
 			NVL(((rec.QUANTITY*(rec.UNITPRICE*tmpConRate))+tmpPQTY*tmpUPrice)/(rec.QUANTITY+tmpPQTY),0),
 			(SELECT SUPPLIERID FROM T_StationeryStock WHERE STOCKID=pSTOCKID),
 			(rec.QUANTITY+tmpPQTY),tmpUPrice,tmpPQTY,rec.UNITPRICE*tmpConRate,rec.QUANTITY,rec.PID,rec.CURRENCYID,rec.CONRATE
			from T_StationeryStockItems WHERE PID=rec.PID;
		ELSE
  			UPDATE T_StationeryPrice SET UNITPRICE=NVL(((rec.QUANTITY*(rec.UNITPRICE*tmpConRate))+tmpPQTY*tmpUPrice)/(rec.QUANTITY+tmpPQTY),0),
 			QTY=(rec.QUANTITY+tmpPQTY),PPRICE=tmpUPrice,PQTY=tmpPQTY,NPRICE=rec.UNITPRICE*tmpConRate,NQTY=rec.QUANTITY,CURRENCYID=rec.CURRENCYID,CONRATE=rec.CONRATE
			WHERE StationeryID=rec.StationeryID AND PURCHASEDATE=pStockDate AND REFPID=rec.PID;
 		END IF;

		UPDATE T_Stationery 
			SET WAVGPRICE=NVL(((rec.QUANTITY*(rec.UNITPRICE*tmpConRate))+tmpPQTY*tmpUPrice)/(rec.QUANTITY+tmpPQTY),0)
			WHERE StationeryID=rec.StationeryID;
  	    pRecsAffected := SQL%ROWCOUNT+pRecsAffected;
  	IF (pRecsAffected=2)
  		THEN
         	COMMIT;
	ELSE
  		RAISE faults;
 	END IF;	 
        END loop;
 EXCEPTION
  WHEN faults THEN ROLLBACK;
END GetStationeryWAvgPrice;
/



PROMPT CREATE OR REPLACE Procedure  510 :: GetCopyBudget
CREATE OR REPLACE Procedure GetCopyBudget
(
 pBUDGETID IN NUMBER,
 pOrdertypeid in Varchar2,
 pRecsAffected out NUMBER

)
AS
ID NUMBER;
ID1 Number;
ID2 Number;
bno Varchar2(50);
npid number;

BEGIN
	select max(budgetid)+1 into id from T_Budget;
	select To_char(max(budgetno)+1) into bno from (select to_number(budgetno) as budgetno from T_Budget where ordertypeid=pOrdertypeid);
	pRecsAffected:=100;

	insert into T_Budget(BUDGETID,BUDGETNO,CLIENTID,ORDERNO,ORDERREF,
	ORDERDESC,LCNO,LCRECEIVEDATE,LCEXPIRYDATE,
	SHIPMENTDATE,LCVALUE,QUANTITY,UNITQTY,UNITPRICE,BUDGETPREDATE,ordertypeid,pi,cadrefno,EMPLOYEEID)
	select id,bno,CLIENTID,ORDERNO,ORDERREF,
	ORDERDESC,LCNO,LCRECEIVEDATE,LCEXPIRYDATE,
	SHIPMENTDATE,1,1,1,1,BUDGETPREDATE,ordertypeid,pi,cadrefno,EMPLOYEEID from T_Budget where budgetid=pBUDGETID;

	for rec in(select budgetid,pid,YARNTYPEID,FABRICTYPEID,GSM,CONSUMPTIONPERDOZ,
	WASTAGE,NETCONSUMPTIONPERDOZ,TOTALCONSUMPTION,STAGEID,rpercent,pcs,styleno,SHADEGROUPID from t_fabricconsumption where budgetid=pBUDGETID order by pid)
	loop
		select max(pid)+1 into npid from t_fabricconsumption;

		insert into t_fabricconsumption(BUDGETID,PID,YARNTYPEID,FABRICTYPEID,GSM,CONSUMPTIONPERDOZ,
		WASTAGE,NETCONSUMPTIONPERDOZ,TOTALCONSUMPTION,STAGEID,rpercent,pcs,styleno,SHADEGROUPID)
		values(id,npid,rec.YARNTYPEID,rec.FABRICTYPEID,rec.GSM,0,
		0,0,0,rec.STAGEID,0,0,rec.styleno,rec.SHADEGROUPID);

		for rec1 in(select YARNTYPEID,YARNCOUNTID,SUPPLIERID,QUANTITY,UNITPRICE,TOTALCOST,
		STAGEID,USES,QTY,PROCESSLOSS,FABRICTYPEID from t_yarncost where budgetid=pBUDGETID and ppid=rec.pid order by pid)
		loop
			insert into t_yarncost(BUDGETID,PID,YARNTYPEID,YARNCOUNTID,SUPPLIERID,QUANTITY,
			UNITPRICE,TOTALCOST,STAGEID,USES,QTY,PROCESSLOSS,FABRICTYPEID,PPid)
			values(id,(select max(pid)+1 from t_Yarncost),rec1.YARNTYPEID,rec1.YARNCOUNTID,rec1.SUPPLIERID,0,0,
			0,rec1.STAGEID,rec1.USES,0,0,rec1.FABRICTYPEID,npid);
		end loop;

		for rec2 in(select STAGEID,PARAMID,QUANTITY,UNITPRICE,TOTALCOST,unit from t_kdfcost where budgetid=pBUDGETID and ppid=rec.pid and stageid in(3,4) order by pid)
		loop
			SELECT Seq_kdfPID.NEXTVAL INTO ID1 FROM DUAL;
			insert into t_kdfcost( BUDGETID,PID,STAGEID,PARAMID,QUANTITY,UNITPRICE,TOTALCOST,PPID,unit)
			values(id,id1,rec2.STAGEID,rec2.PARAMID,0,0,0,npid,rec2.unit);
		end loop;
	end loop;

	for rec in(select STAGEID,PARAMID,QUANTITY,UNITPRICE,TOTALCOST from t_kdfcost where budgetid=pBUDGETID and stageid =5 order by pid)
	loop
		SELECT Seq_kdfPID.NEXTVAL INTO ID1 FROM DUAL;
		insert into t_kdfcost( BUDGETID,PID,STAGEID,PARAMID,QUANTITY,UNITPRICE,TOTALCOST)
		values(id,id1,rec.STAGEID,rec.PARAMID,0,0,0);
	end loop;

	for rec in(select STAGEID,PARAMID,SUPPLIERID,CONSUMPTIONPERDOZ,QUNATITY,UNITPRICE,
		TOTALCOST,ACCESSORIESID,GROUPID,UNITOFMEASID,QTY,WASTAGE,
		CONSUMPTION,SUBCONID from t_garmentscost where budgetid=pBUDGETID)
	loop
		SELECT Seq_accesoriesPID.NEXTVAL INTO ID2 FROM DUAL;
		insert into t_garmentscost(BUDGETID,PID,STAGEID,PARAMID,SUPPLIERID,CONSUMPTIONPERDOZ,
		QUNATITY,UNITPRICE,TOTALCOST,ACCESSORIESID,GROUPID,UNITOFMEASID,QTY,WASTAGE,
		CONSUMPTION,SUBCONID)
		values(id,id2,rec.STAGEID,rec.PARAMID,rec.SUPPLIERID,rec.CONSUMPTIONPERDOZ,
		0,0,0,rec.ACCESSORIESID,rec.GROUPID,
		rec.UNITOFMEASID,0,0,0,rec.SUBCONID);
	end loop;
END GetCopyBudget;
/


PROMPT CREATE OR REPLACE Procedure  511 :: GetGCuttingPartsList
CREATE OR REPLACE Procedure GetGCuttingPartsList
(
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN

  OPEN data_cursor for
   select GCPartsID,GCuttingParts from T_GCuttingPartsList;
END GetGCuttingPartsList;
/

PROMPT CREATE OR REPLACE Procedure  512 :: GetDeliveryChalanInfo
CREATE OR REPLACE Procedure GetDeliveryChalanInfo
(
  one_cursor IN OUT pReturnData.c_Records,
  many_cursor IN OUT pReturnData.c_Records,
  pInvoiceid number
)
AS
BEGIN
    open one_cursor for
    select Invoiceid,ChallanNo, ChallanDate, Invoiceno, InvoiceDATE,LOCKNO,
    ClientID,Remarks, SubConId,Pono,GatepassNo,catid,contactperson,deliveryplace,orderno,
	VEHICLENO,DRIVERNAME,DRIVERLICENSENO,DRIVERMOBILENO,TRANSCOMPNAME,CANDFID,DELORDERTYPEID
	from T_GDELIVERYCHALLAN
	where Invoiceid=pInvoiceid;

    open many_cursor for
     select a.PID,a.ORDERNO,a.Invoiceid,a.GSTOCKITEMSL,a.Quantity,a.Squantity,a.PunitOfmeasId,
  a.SUNITOFMEASID,a.SIZEID,a.BatchNo,a.Shade,a.REMARKS,a.CurrentStock,a.Styleno,a.countryid,
  a.Cartonno,a.CTNTYPE,a.CBM,getClientRef(a.ORDERNO) as ClientRef
  from T_GDELIVERYCHALLANItems a
  where a.Invoiceid=pInvoiceid
  order by GSTOCKITEMSL asc;
END GetDeliveryChalanInfo;
/

PROMPT CREATE OR REPLACE Procedure  513 :: GetGDWorkOrderLookUp
CREATE OR REPLACE Procedure GetGDWorkOrderLookUp
(
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN
 OPEN data_cursor for
     Select SCGORDERNO,ORDERTYPEID || ' ' || GDORDERNO as SCGDORDERNO
 from T_SCGWorkOrder where ORDERTYPEID='SCGPE'
 ORDER BY GDORDERNO DESC;
END GetGDWorkOrderLookUp;
/