
PROMPT CREATE OR REPLACE Procedure  01 :: GetReportAUXSTOCKDAILY
CREATE OR REPLACE PROCEDURE GetReportAUXSTOCKDAILY(
  data_cursor IN OUT pReturnData.c_Records,
  aType IN VARCHAR2,
  sDate IN VARCHAR2,
  eDate IN VARCHAR2
)
AS
  vSDate date;
  vEDate date;
BEGIN

  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  end if;

  OPEN data_cursor  FOR
  SELECT c.AUXStockTypeId, b.AUXStockType, c.StockInvoiceNo, c.StockDate,
  e.AuxTypeId, f.AuxType, e.AuxId, a.DyeBase, d.AuxName, e.StockQty
  FROM T_DyeBase a, T_AuxStockType b, T_AuxStock c, T_Auxiliaries d,
  T_AuxType f, T_AuxStockItem e
  WHERE d.AuxId = e.AuxId and
  d.AuxTypeId = e.AuxTypeId and
  c.AuxStockId = e.AuxStockId and
  b.AUXStockTypeId = c.AUXStockTypeId and
  a.DyeBaseId(+) = d.DyeBaseId and
  d.AuxTypeId = f.AuxTypeId and
  e.AuxTypeId = aType and
  c.StockDate between decode(vSDate,null,'01-jan-2000',vSDate) and vEDate;

END GetReportAUXSTOCKDAILY;
/

PROMPT CREATE OR REPLACE Procedure  02 :: GetReportGRRAUX
CREATE OR REPLACE PROCEDURE GetReportGRRAUX (
  data_cursor IN OUT pReturnData.c_Records,
  pSDate IN VARCHAR2 DEFAULT NULL,
  pEDate IN VARCHAR2 DEFAULT NULL
)
As

  vSDate DATE;
  vEDate DATE;

BEGIN

  if not pSDate is null then
    vSDate := TO_DATE(pSDate, 'DD/MM/YYYY');
  end if;
  if not pEDate is null then
    vEDate := TO_DATE(pEDate, 'DD/MM/YYYY');
  end if;

  OPEN data_cursor  FOR
  select AuxName,STOCKQTY,b.AuxStockId,StockDate,DYEBASE,
  PURCHASEORDERNO,PURCHASEORDERDATE,b.SUPPLIERID,g.SUPPLIERNAME,g.SADDRESS,
  DELIVERYNOTE,DELIVERYNOTEDATE,REMARKS,STOCKINVOICENO
  from t_auxstockitem a,t_auxstock b,
  T_Auxiliaries c ,T_UnitOfMeas D,T_DyeBase e,t_supplier g
  where a.AUXSTOCKID=b.AUXSTOCKID and
  b.SUPPLIERID =g.SUPPLIERID and 
  a.AUXTYPEID=c.AUXTYPEID  and
  a.AUXID=c.AUXID and
  e.DYEBASEID(+)=c.DYEBASEID and
  c.UnitOfMeasId=d.UnitOfMeasId And
  AUXSTOCKTYPEID=1 And
  b.Stockdate between vSDate And  vEDate;

End GetReportGRRAUX;
/


PROMPT CREATE OR REPLACE Procedure  03 :: GetREPORTKMCMRMPDetails
CREATE OR REPLACE Procedure GetREPORTKMCMRMPDetails (
  data_cursor IN OUT pReturnData.c_Records,
  PStockId IN NUMBER
)
As
Begin
  OPEN data_cursor FOR
  select a.ChallanNo,a.StockDate,a.StockId,b.PartId,d.MCTypeName,
  c.PARTNAME,b.Qty,b.Stockitemsl,c.Description, e.LOCATION
  from T_KmcPartsTran a,T_KmcPartsTransDetails b,T_KmcPartsInfo c,T_KmcType d, T_StoreLocation e
  where a.StockId=b.StockId and
  b.PartId=c.PartId  and
  c.McTypeId=d.McTypeId and
  c.LocationId=e.LocationId and
  B.KmcSTOCKTYPEID=2 And
  a.StockId=PStockId;
End GetREPORTKMCMRMPDetails;
/

PROMPT CREATE OR REPLACE Procedure  04 :: GetReportKmcPartsMRRMPDetail
CREATE OR REPLACE Procedure GetReportKmcPartsMRRMPDetail  (
  data_cursor IN OUT pReturnData.c_Records,
  PStockId IN NUMBER
)
As
Begin
  OPEN data_cursor FOR
  select a.StockDate,a.StockId,b.PartId,c.PARTNAME,b.Qty,
  a.Challanno,b.Stockitemsl,a.PURCHASEORDERNO,
  a.PURCHASEORDERDATE,d.SUPPLIERName,d.SADDRESS,b.REMARKS, c.Description
  from T_KmcPartsTran a,T_KmcPartsTransDetails b,T_KmcPartsInfo c,t_supplier d
  where a.StockId=b.StockId and
  a.supplierID=d.supplierID and
  b.PartId=c.PartId  and
  b.KmcSTOCKTYPEID=1 And
  a.StockId=PStockId
  order by b.Stockitemsl asc;
End GetReportKmcPartsMRRMPDetail;
/

PROMPT CREATE OR REPLACE Procedure  05 :: GetREPORTKMCRETURNMPDetails
CREATE OR REPLACE Procedure GetREPORTKMCRETURNMPDetails (
  data_cursor IN OUT pReturnData.c_Records,
  PStockId IN NUMBER
)
As
Begin
  OPEN data_cursor FOR
  select a.ChallanNo,a.StockDate,a.StockId,b.PartId,d.MCTypeName,
  c.PARTNAME,b.Qty,b.Stockitemsl,c.Description, e.LOCATION
  from T_KmcPartsTran a,T_KmcPartsTransDetails b,T_KmcPartsInfo c,T_KmcType d, T_StoreLocation e
  where a.StockId=b.StockId and
  b.PartId=c.PartId  and
  c.McTypeId=d.McTypeId and
  c.LocationId=e.LocationId and
  B.KmcSTOCKTYPEID=3 And
  a.StockId=PStockId;
End GetREPORTKMCRETURNMPDetails;
/


PROMPT CREATE OR REPLACE Procedure  06 ::GetReportKnitYarnStock
CREATE OR REPLACE Procedure GetReportKnitYarnStock(
  data_cursor IN OUT pReturnData.c_Records,
  pOrderNo IN NUMBER,
  pStockDate DATE
)
AS
BEGIN
    open data_cursor for
    select c.YarnCount, d.YarnType, e.UnitOfMeas, f.KNTITRANSACTIONTYPEID,f.KNITTRANSACTIONTYPE,h.OrderDate,
    i.ClientName,h.OrderNo,BasictypeName,sum(b.Quantity*ATLGYS) sATLGYS,sum(b.Quantity*ATLGFS) sATLGFS,
    sum(b.Quantity*ATLGYF) sATLGYF,sum(b.Quantity*AYDLGYS) sAYDLGYS,sum(b.Quantity*ODSCONGYS) sODSCONGYS,
    sum(b.Quantity*KSCONGYS) sKSCONGYS
    from T_Knitstock a, T_KnitStockItems b, T_YarnCount c, T_YarnType d, T_UnitOfMeas e,
    T_knitTransactionType f, T_OrderItems g, t_WorkOrder h, t_client i,t_Basictype j
    where a.StockID=b.StockID and
    b.yarnCountId=c.yarncountid and
    b.yarntypeid=d.yarntypeid and
    b.PunitOfMeasId=e.UnitOfmeasId and
    a.KNTITRANSACTIONTYPEID=f.KNTITRANSACTIONTYPEID and
    b.OrderLineItem=g.OrderLineItem and
    g.OrderNo=h.OrderNo and
    h.clientID=i.clientID and
    h.BasictypeID=j.BasictypeID and
    STOCKTRANSDATE <= pStockDate and
    h.OrderNo = pOrderNo group by YarnCount, YarnType, UnitOfMeas,f.KNTITRANSACTIONTYPEID,KNITTRANSACTIONTYPE,OrderDate,
    ClientName,h.OrderNo,BasictypeName;
END GetReportKnitYarnStock;
/


PROMPT CREATE OR REPLACE Procedure  07 :: GetReportKnitYarnStockDetails
CREATE OR REPLACE Procedure GetReportKnitYarnStockDetails(
  data_cursor IN OUT pReturnData.c_Records,
  pOrderNo NUMBER
)
AS
BEGIN
open data_cursor for
select b.PID,a.STOCKTRANSDATE,a.STOCKTRANSNO,getfncyarncount(b.YARNCOUNTID)||'-'
||getfncyarntype(B.YARNTYPEID) AS YARNDESCRIPTION,

getFabricType1(B.FABRICTYPEID) AS FABRICTYPE
,getfncClient(e.clientID) as ClientName,b.shade,
getfncSubConName(a.subconid) as SubContractors,

/* YARN DYEING PROCESS [YARN ISSUE FOR YARN DYEING]*/
 decode (a.KNTITRANSACTIONTYPEID,5,b.Quantity,0)as YARN_ISSUE_DYEING_AYDL,
 decode (a.KNTITRANSACTIONTYPEID,12,b.Quantity,0)as YARN_ISSUE_DYEING_OTHERS,
 decode (a.KNTITRANSACTIONTYPEID,5,b.Quantity,12,b.Quantity,0) as YARN_ISSUE_DYEING_TOTAL,

 /* YARN DYEING PROCESS [YARN RECEIVE FROM YARN DYEING]*/

 decode (a.KNTITRANSACTIONTYPEID,8,b.Quantity,0)as YARN_RECEIVE_DYEING_AYDL,
 decode (a.KNTITRANSACTIONTYPEID,13,b.Quantity,0)as YARN_RECEIVE_DYEING_OTHER,
 decode (a.KNTITRANSACTIONTYPEID,8,b.Quantity,13,b.Quantity,0) AS YARN_RECEIVE_DYEING_TOTAL,

/* KNITTING PROCESS [YANR ISSIED FOR KNITTING]*/
 decode (a.KNTITRANSACTIONTYPEID,3,b.Quantity,22,b.Quantity,0)as YARN_Issue_FOR_KNITTING,
 decode (a.KNTITRANSACTIONTYPEID,4,b.Quantity,23,b.Quantity,0)as YARN_Issue_FOR_OTHERS,
 decode (a.KNTITRANSACTIONTYPEID,3,b.Quantity,22,b.Quantity,4,b.Quantity,23,b.Quantity,0) AS YARN_ISSUE_KNITTING_TOTAL,

/* KNITTING PROCESS [YANR RETURN FROM KNITTING ]*/
 decode (a.KNTITRANSACTIONTYPEID,9,b.Quantity,26,b.Quantity,0)as RETURN_FROM_KNITTING_FLOOR,
 decode (a.KNTITRANSACTIONTYPEID,10,b.Quantity,27,b.Quantity,0)as RETURN_FROM_KNITTING_OTHERS,
 decode (a.KNTITRANSACTIONTYPEID,9,b.Quantity,26,b.Quantity,10,b.Quantity,27,b.Quantity,0) AS RETURN_KNITTING_TOTAL,

/* KNITTING PROCESS [TOTAL NET YARN ISSUD FOR KNITTING ]*/
 decode (a.KNTITRANSACTIONTYPEID,3,b.Quantity,9,-b.Quantity,22,b.Quantity,26,-b.Quantity,0) AS NET_YARN_FLOOR,
/* KNITTING PROCESS [TOTAL NET YARN ISSUD FOR OTHERS ]*/
 decode (a.KNTITRANSACTIONTYPEID,4,b.Quantity,10,-b.Quantity,23,b.Quantity,27,-b.Quantity,0) AS NET_YARN_OTHERS,

/* KNITTING PROCESS [TOTAL NET YARN FLOOR AND OTHERS ]*/

 decode (a.KNTITRANSACTIONTYPEID,3,b.Quantity,9,-b.Quantity,4,b.Quantity,10,-b.Quantity,22,b.Quantity,26,-b.Quantity,23,b.Quantity,27,-b.Quantity,0)
AS NET_YARN_GRAND_TOTAL,

/* FABRIC RECEIVED AFTER KNITTING [RECEIVE FROM FLOOR]*/
 decode (a.KNTITRANSACTIONTYPEID,6,b.Quantity,24,b.Quantity,0)as FABRIC_RECEIVE_FROM_FLOOR,
 decode (a.KNTITRANSACTIONTYPEID,3,b.Quantity,9,-b.Quantity,6,-b.Quantity,22,b.Quantity,26,-b.Quantity,24,-b.Quantity,0) AS PROCESS_LOSS_ATL_FAB_AYDL,
 decode (a.KNTITRANSACTIONTYPEID,7,b.Quantity,25,b.Quantity,0) as FABRIC_RECEIVE_FROM_OTHRS,
 decode (a.KNTITRANSACTIONTYPEID,4,b.Quantity,10,-b.Quantity,7,-b.Quantity,23,b.Quantity,27,-b.Quantity,25,-b.Quantity,0) AS PROCESS_LOSS_ATL_FAB_OTHERS,
 decode (a.KNTITRANSACTIONTYPEID,6,b.Quantity,7,-b.Quantity,24,b.Quantity,25,-b.Quantity,0) AS FABRIC_TOTAL_RECEIVE
 from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c,t_workorder e
 where a.StockID=b.StockID and
 a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
 b.ORDERNO=e.ORDERNO and
 b.OrderNo = pOrderNo
 order by STOCKTRANSDATE,a.KNTITRANSACTIONTYPEID,a.STOCKTRANSNO;

END GetReportKnitYarnStockDetails;
/




PROMPT CREATE OR REPLACE Procedure  08 :: GetReportKYAll
CREATE OR REPLACE Procedure GetReportKYAll 
(
   data_cursor IN OUT pReturnData.c_Records,
   pKnitStockID IN NUMBER
)
As
Begin
  OPEN data_cursor  FOR
  select YarnCount, YarnType,FABRICTYPE,a.OrderlineItem,a.Quantity,a.Squantity,
  f.UNITOFMEAS as PUOM,f.UNITOFMEAS as SUOM,YARNBATCHNO,a.SHADE,a.Remarks,b.STOCKID,
  ReferenceNo,ReferenceDate,StockTransNO,StockTransDATE,E.SUPPLIERNAME,E.SADDRESS,SupplierInvoiceNo,
  SupplierInvoiceDate,a.SubConId,b.Remarks as StockRemarks,h.orderNo,i.clientid,j.clientname,
  j.CADDRESS,j.CCONTACTPERSON,j.CLIENTREF,BasicTypeName
  from T_KnitStockItems a,T_KnitStock b,T_YarnCount c ,T_YarnType d,T_SUPPLIER E,t_UnitOfMeas f,
  t_orderitems h,t_WorkOrder i,t_client j,t_BasicType k,T_FabricType l
  where a.STOCKID=b.STOCKID and
  b.supplierId=e.supplierID and
  a.YarnCountID=c.YarnCountID  and
  a.YarnTypeID=d.YarnTypeID  and
  a.FabricTypeID=l.FabricTypeID and
  a.PUNITOFMEASID=f.UNITOFMEASID And
  a.OrderlineItem=h.OrderlineItem And
  h.orderNo=i.OrderNo And
  i.clientid=j.clientid And
  h.BasicTypeID=k.BasicTypeID And
  a.STOCKID=pKnitStockID;

End GetReportKYAll;
/


PROMPT CREATE OR REPLACE Procedure  09 :: GetReportKYAllDetails
CREATE OR REPLACE Procedure GetReportKYAllDetailS (
   data_cursor IN OUT pReturnData.c_Records,
   pQueryType IN NUMBER,
   sDate IN VARCHAR2,
   eDate IN VARCHAR2
)
AS
  vSDate date;
  vEDate date;
BEGIN
  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  else
    vSDate := TO_DATE('01/01/1900', 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  else
    vEDate := TO_DATE('01/01/2300', 'DD/MM/YYYY');
  end if;

  if pQueryType=0 then
/* Report for T92 Yarn MRR Details */
  OPEN data_cursor  FOR
	select YarnCount, YarnType, FABRICTYPEID,OrderlineItem,Quantity, Squantity,f.UNITOFMEAS as PUOM, NVL(a.UNITPRICE,0) as UNITPRICE,
	f.UNITOFMEAS as SUOM,YARNBATCHNO,SHADE,a.Remarks,b.STOCKID,ReferenceNo,ReferenceDate,
	StockTransNO,StockTransDATE,g.SUPPLIERNAME,g.saddress,SupplierInvoiceNo,SupplierInvoiceDate,
	b.SubConId,b.YARNFOR,H.PARTYNAME,a.IMPLCNO
	from T_KnitStockItems a,T_KnitStock b,
	T_YarnCount c ,T_YarnType d,T_KNITTRANSACTIONTYPE e,t_UnitOfMeas f,T_Supplier g,T_YARNPARTY h
	where a.STOCKID=b.STOCKID and
    b.KNTITRANSACTIONTYPEID=e.KNTITRANSACTIONTYPEID and
	b.supplierID=g.supplierID and
	a.YarnCountID=c.YarnCountID  and
	a.YarnTypeID=d.YarnTypeID  and
	b.YARNFOR=h.PID AND
	e.KNTITRANSACTIONTYPEID=1 And
	a.PUNITOFMEASID=f.UNITOFMEASID And
	StockTransDATE between vSDate and vEDate
	ORDER BY StockTransDATE,StockTransNO ASC;

 elsif pQueryType=1 then
/* Report for T93 Yarn MR Details */
  OPEN data_cursor  FOR

    select b.ORDERNO,getfncWOBType(b.ORDERNO) as workorder,a.STOCKTRANSNO,a.STOCKTRANSDATE,b.YARNBATCHNO,c.YarnCount, d.YarnType, e.UnitOfMeas,g.SupplierName,
    sum(b.Quantity*ATLGYS) MainStore, sum(b.Quantity*ATLGYF) Floor,
    sum(b.Quantity*AYDLGYS) AYDL,
    sum(b.Quantity*ODSCONGYS) Others,sum(b.Quantity*KSCONGYS) KnittingSubContractor
    from T_Knitstock a, T_KnitStockItems b,
    T_YarnCount c, T_YarnType d, T_UnitOfMeas e, T_knitTransactionType f, T_Supplier g
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=f.KNTITRANSACTIONTYPEID and
   (f.KNTITRANSACTIONTYPEID=3 or f.KNTITRANSACTIONTYPEID=4 or f.KNTITRANSACTIONTYPEID=5 or f.KNTITRANSACTIONTYPEID=12) and
    b.yarnCountId=c.yarncountid and
    b.yarntypeid=d.yarntypeID and
    b.PunitOfMeasId=e.UnitOfmeasId and
    b.SupplierId=g.SupplierId and
    StockTransDATE between vSDate and vEDate AND b.ORDERNO>0
    group by b.ORDERNO,a.STOCKTRANSNO,a.STOCKTRANSDATE,b.YARNBATCHNO,c.YarnCount, d.YarnType, e.UnitOfMeas,g.SupplierName
	ORDER BY StockTransDATE,StockTransNO ASC;

 elsif pQueryType=2 then
/* Report for T94 Yarn Return Details */
  OPEN data_cursor  FOR

    select b.ORDERNO,getfncWOBType(b.ORDERNO) as workorder,a.STOCKTRANSNO,a.STOCKTRANSDATE,b.YARNBATCHNO,c.YarnCount, d.YarnType,
 e.UnitOfMeas,g.SupplierName,a.KNTITRANSACTIONTYPEID,
    sum(b.Quantity*(ATLGYS)) MainStore, sum(b.Quantity*(-ATLGYF)) Floor,
    sum(b.Quantity*(-AYDLGYS)) AYDL,
    sum(b.Quantity*(-ODSCONGYS)) Others,sum(b.Quantity*(-KSCONGYS)) KnittingSubContractor
    from T_Knitstock a, T_KnitStockItems b,
    T_YarnCount c, T_YarnType d, T_UnitOfMeas e, T_knitTransactionType f, T_Supplier g
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=f.KNTITRANSACTIONTYPEID and
   (f.KNTITRANSACTIONTYPEID=9 or f.KNTITRANSACTIONTYPEID=10 or f.KNTITRANSACTIONTYPEID=11 or f.KNTITRANSACTIONTYPEID=14) and
    b.yarnCountId=c.yarncountid and
    b.yarntypeid=d.yarntypeID and
    b.PunitOfMeasId=e.UnitOfmeasId and
    b.SupplierId=g.SupplierId and
    StockTransDATE between vSDate and vEDate AND b.ORDERNO>0
    group by b.ORDERNO,a.STOCKTRANSNO,a.STOCKTRANSDATE,b.YARNBATCHNO,c.YarnCount, d.YarnType,
e.UnitOfMeas,g.SupplierName,a.KNTITRANSACTIONTYPEID
	ORDER BY StockTransDATE,StockTransNO ASC;

 elsif pQueryType=3 then
/* Report for T95 Dyed Yarn Received Details */
  OPEN data_cursor  FOR

   select b.ORDERNO,getfncWOBType(b.ORDERNO) as workorder,a.STOCKTRANSNO,a.STOCKTRANSDATE,b.YARNBATCHNO,c.YarnCount, d.YarnType,
 e.UnitOfMeas,g.SupplierName,a.KNTITRANSACTIONTYPEID,
    sum(b.Quantity*(ATLGYS)) MainStore, sum(b.Quantity*(-ATLGYF)) Floor,
    sum(b.Quantity*(-AYDLGYS)) AYDL,
    sum(b.Quantity*(-ODSCONGYS)) Others,sum(b.Quantity*(-KSCONGYS)) KnittingSubContractor
    from T_Knitstock a, T_KnitStockItems b,
    T_YarnCount c, T_YarnType d, T_UnitOfMeas e, T_knitTransactionType f, T_Supplier g
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=f.KNTITRANSACTIONTYPEID and
   (f.KNTITRANSACTIONTYPEID=8 or f.KNTITRANSACTIONTYPEID=13) and
    b.yarnCountId=c.yarncountid and
    b.yarntypeid=d.yarntypeID and
    b.PunitOfMeasId=e.UnitOfmeasId and
    b.SupplierId=g.SupplierId and
    StockTransDATE between vSDate and vEDate AND b.ORDERNO>0
    group by b.ORDERNO,a.STOCKTRANSNO,a.STOCKTRANSDATE,b.YARNBATCHNO,c.YarnCount, d.YarnType,
e.UnitOfMeas,g.SupplierName,a.KNTITRANSACTIONTYPEID
	ORDER BY StockTransDATE,StockTransNO ASC;


 elsif pQueryType=4 then
/* Report for T96 Gray Fabric Received Details */
  OPEN data_cursor  FOR

   select b.ORDERNO,getfncWOBType(b.ORDERNO),a.STOCKTRANSNO,a.STOCKTRANSDATE,b.YARNBATCHNO,c.YarnCount, d.YarnType,
 e.UnitOfMeas,g.SupplierName,a.KNTITRANSACTIONTYPEID,h.FabricType,
    sum(b.Quantity*(ATLGYS)) MainStore, sum(b.Quantity*(-ATLGYF)) Floor,
    sum(b.Quantity*(-ATLDYF)) AYDL,sum(b.Quantity*(-KSCONDYS)) Others,sum(b.Quantity*(-KSCONGYS)) KnittingSubContractor
    from T_Knitstock a, T_KnitStockItems b,T_YarnCount c, T_YarnType d, T_UnitOfMeas e,
    T_knitTransactionType f, T_Supplier g,T_FabricType h
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=f.KNTITRANSACTIONTYPEID and
   (f.KNTITRANSACTIONTYPEID=206 or f.KNTITRANSACTIONTYPEID=207 or f.KNTITRANSACTIONTYPEID=224 or f.KNTITRANSACTIONTYPEID=225) and
    b.FabricTypeID=h.FabricTypeID(+) and
    b.yarnCountId=c.yarncountid(+) and
    b.yarntypeid=d.yarntypeID(+) and
    b.PunitOfMeasId=e.UnitOfmeasId(+) and
    b.SupplierId=g.SupplierId(+) and
    StockTransDATE between vSDate and vEDate AND b.ORDERNO>0
    group by b.ORDERNO,a.STOCKTRANSNO,a.STOCKTRANSDATE,b.YARNBATCHNO,c.YarnCount, d.YarnType,
e.UnitOfMeas,g.SupplierName,a.KNTITRANSACTIONTYPEID,h.FabricType
	ORDER BY StockTransDATE,StockTransNO ASC;


 elsif pQueryType=5 then
/* Report for T97 Gray Fabric Issue To ATLGFDF Details */
  OPEN data_cursor  FOR

   select b.ORDERNO,getfncWOBType(b.ORDERNO) as workorder,a.STOCKTRANSNO,a.STOCKTRANSDATE,b.YARNBATCHNO,c.YarnCount, d.YarnType,
 e.UnitOfMeas,a.KNTITRANSACTIONTYPEID,h.FabricType,
    sum(b.Quantity*(ATLGYS)) MainStore, sum(b.Quantity*(-ATLGYF)) Floor,
    sum(b.Quantity*(-AYDLGYS)) AYDL,
    sum(b.Quantity*(-ODSCONGYS)) Others,sum(b.Quantity*(-KSCONGYS)) KnittingSubContractor
    ,sum(b.Quantity*(ATLGFS)) ATLGFS,sum(b.Quantity*(ATLGFDF)) ATLGFDF
    from T_Knitstock a, T_KnitStockItems b,
    T_YarnCount c, T_YarnType d, T_UnitOfMeas e, T_knitTransactionType f,T_FabricType h
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=f.KNTITRANSACTIONTYPEID and
   (f.KNTITRANSACTIONTYPEID=18) and
    b.FabricTypeID=h.FabricTypeID and
    b.yarnCountId=c.yarncountid and
    b.yarntypeid=d.yarntypeID and
    b.PunitOfMeasId=e.UnitOfmeasId and
    StockTransDATE between vSDate and vEDate AND b.ORDERNO>0
    group by b.ORDERNO,a.STOCKTRANSNO,a.STOCKTRANSDATE,b.YARNBATCHNO,c.YarnCount, d.YarnType,
e.UnitOfMeas,a.KNTITRANSACTIONTYPEID,h.FabricType
	ORDER BY StockTransDATE,StockTransNO ASC;

elsif pQueryType=6 then
/* Report for T98 Gray DYED YARN Issue To ATLGFDF Details */
  OPEN data_cursor  FOR

	select b.ORDERNO,getfncWOBType(b.ORDERNO) as workorder,a.STOCKTRANSNO,a.STOCKTRANSDATE,b.YARNBATCHNO,c.YarnCount, d.YarnType,
 	e.UnitOfMeas,g.SupplierName,a.KNTITRANSACTIONTYPEID,
    sum(b.Quantity*(ATLDYF)) AYDL,
    sum(b.Quantity*(KSCONDYS)) Others
    from T_Knitstock a, T_KnitStockItems b,
    T_YarnCount c, T_YarnType d, T_UnitOfMeas e, T_knitTransactionType f, T_Supplier g
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=f.KNTITRANSACTIONTYPEID and
   (f.KNTITRANSACTIONTYPEID=22 or f.KNTITRANSACTIONTYPEID=23) and
    b.yarnCountId=c.yarncountid and
    b.yarntypeid=d.yarntypeID and
    b.PunitOfMeasId=e.UnitOfmeasId and
    b.SupplierId=g.SupplierId and
    StockTransDATE between vSDate and vEDate AND b.ORDERNO>0
    group by b.ORDERNO,a.STOCKTRANSNO,a.STOCKTRANSDATE,b.YARNBATCHNO,c.YarnCount, d.YarnType,
e.UnitOfMeas,g.SupplierName,a.KNTITRANSACTIONTYPEID
	ORDER BY StockTransDATE,StockTransNO ASC;

 elsif pQueryType=7 then
/* Report for F20 Gray Fabric Received/Production duration from floor Report Details*/
  OPEN data_cursor  FOR

   select b.ORDERNO,getfncWOBType(b.ORDERNO),a.STOCKTRANSNO,a.STOCKTRANSDATE,b.YARNBATCHNO,c.YarnCount, d.YarnType,
 e.UnitOfMeas,g.SupplierName,a.KNTITRANSACTIONTYPEID,h.FabricType,i.ClientName,l.ShadeGroupName,b.Shade,K.MACHINENAME,b.ORDERLINEITEM,
	getfncDateTimeIntDistance(b.KSTARTDATETIME,b.KENDDATETIME) as TotalActProdHrs,getfncGSMfromOrderItems(b.ORDERLINEITEM) as GSM,
	l.PRODUCTIONHRS as StdProdPerHrs,
	decode(getfncDateTimeIntDistance(b.KSTARTDATETIME,b.KENDDATETIME),0,0,sum(decode(f.KNTITRANSACTIONTYPEID,6,b.Quantity,24,b.Quantity,0))/getfncDateTimeIntDistance(b.KSTARTDATETIME,b.KENDDATETIME)) as ActProdPerHrs,
	0 as Varience,
	sum(decode(f.KNTITRANSACTIONTYPEID,6,b.Quantity,24,b.Quantity,0)) ProductQty,
    sum(decode(f.KNTITRANSACTIONTYPEID,6,b.SQuantity,24,b.SQuantity,0)) ProductSQty
    from T_Knitstock a, T_KnitStockItems b,T_YarnCount c, T_YarnType d, T_UnitOfMeas e,T_knitTransactionType f,
	T_Supplier g,T_FabricType h,T_Client i, t_workorder j,T_ShadeGroup l,T_KNITMACHINEINFO k,T_KNITMACHINEINFOITEMS l
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=f.KNTITRANSACTIONTYPEID and
   (f.KNTITRANSACTIONTYPEID=6 or f.KNTITRANSACTIONTYPEID=24) and
    b.FabricTypeID=h.FabricTypeID and
    b.ShadeGroupID=l.ShadeGroupID and
    b.ORDERNO=j.ORDERNO and
    j.ClientID=i.ClientID and
    b.yarnCountId=c.yarncountid and
    b.yarntypeid=d.yarntypeID and
    b.PunitOfMeasId=e.UnitOfmeasId and
    b.SupplierId=g.SupplierId and
    b.KMACHINEPIDREF=l.PID and
	l.MACHINEID=k.MACHINEID and
    StockTransDATE between vSDate and vEDate AND b.ORDERNO>0
    group by b.ORDERNO,a.STOCKTRANSNO,a.STOCKTRANSDATE,b.YARNBATCHNO,c.YarnCount, d.YarnType,e.UnitOfMeas,g.SupplierName,a.KNTITRANSACTIONTYPEID,
	b.FabricTypeID,h.FabricType,i.ClientName,l.ShadeGroupName,b.Shade,K.MACHINENAME,b.ORDERLINEITEM,f.KNTITRANSACTIONTYPEID,b.KSTARTDATETIME,b.KENDDATETIME,l.PRODUCTIONHRS
	ORDER BY getfncWOBType(b.ORDERNO) ASC;
 elsif pQueryType=122 then
/* Report for F03A /FO3B Gray Fabric Received/Production from floor Report Details */
  OPEN data_cursor  FOR

   select b.ORDERNO,getfncWOBType(b.ORDERNO),a.STOCKTRANSNO,a.STOCKTRANSDATE,b.YARNBATCHNO,c.YarnCount, d.YarnType,
 e.UnitOfMeas,g.SupplierName,a.KNTITRANSACTIONTYPEID,h.FabricType,i.ClientName,l.ShadeGroupName,b.Shade,K.MACHINENAME,
    sum(decode(f.KNTITRANSACTIONTYPEID,6,b.Quantity,24,b.Quantity,0)) ProductQty,
    sum(decode(f.KNTITRANSACTIONTYPEID,6,b.SQuantity,24,b.SQuantity,0)) ProductSQty
    from T_Knitstock a, T_KnitStockItems b,T_YarnCount c, T_YarnType d, T_UnitOfMeas e,
    T_knitTransactionType f, T_Supplier g,T_FabricType h,T_Client i, t_workorder j,T_ShadeGroup l,T_KNITMACHINEINFO k
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=f.KNTITRANSACTIONTYPEID and
   (f.KNTITRANSACTIONTYPEID=6 or f.KNTITRANSACTIONTYPEID=24) and
    b.FabricTypeID=h.FabricTypeID and
    b.ShadeGroupID=l.ShadeGroupID and
    b.ORDERNO=j.ORDERNO and
    j.ClientID=i.ClientID and
    b.yarnCountId=c.yarncountid and
    b.yarntypeid=d.yarntypeID and
    b.PunitOfMeasId=e.UnitOfmeasId and
    b.SupplierId=g.SupplierId and
    b.MACHINEID=K.MACHINEID and
    StockTransDATE between vSDate and vEDate AND b.ORDERNO>0
    group by b.ORDERNO,a.STOCKTRANSNO,a.STOCKTRANSDATE,b.YARNBATCHNO,c.YarnCount, d.YarnType,e.UnitOfMeas,g.SupplierName,a.KNTITRANSACTIONTYPEID,
	h.FabricType,i.ClientName,l.ShadeGroupName,b.Shade,K.MACHINENAME,f.KNTITRANSACTIONTYPEID
	ORDER BY getfncWOBType(b.ORDERNO) ASC;

 elsif pQueryType=123 then
/* Report for T123 Gray Fabric Received/Production from Sub Contractor Report Details */
  OPEN data_cursor  FOR

   select b.ORDERNO,getfncWOBType(b.ORDERNO),a.STOCKTRANSNO,a.STOCKTRANSDATE,b.YARNBATCHNO,c.YarnCount, d.YarnType,
 e.UnitOfMeas,g.SupplierName,a.KNTITRANSACTIONTYPEID,h.FabricType,i.ClientName,l.ShadeGroupName,b.Shade,K.MACHINENAME,
    sum(decode(f.KNTITRANSACTIONTYPEID,7,b.Quantity,25,b.Quantity,0)) ProductQty,
    sum(decode(f.KNTITRANSACTIONTYPEID,7,b.SQuantity,25,b.SQuantity,0)) ProductSQty
    from T_Knitstock a, T_KnitStockItems b,T_YarnCount c, T_YarnType d, T_UnitOfMeas e,
    T_knitTransactionType f, T_Supplier g,T_FabricType h,T_Client i, t_workorder j,T_ShadeGroup l,T_KNITMACHINEINFO k
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=f.KNTITRANSACTIONTYPEID and
   ( f.KNTITRANSACTIONTYPEID=7 or f.KNTITRANSACTIONTYPEID=25) and
    b.FabricTypeID=h.FabricTypeID and
    b.ShadeGroupID=l.ShadeGroupID and
    b.ORDERNO=j.ORDERNO and
    j.ClientID=i.ClientID and
    b.yarnCountId=c.yarncountid and
    b.yarntypeid=d.yarntypeID and
    b.PunitOfMeasId=e.UnitOfmeasId and
    b.SupplierId=g.SupplierId and
    b.MACHINEID=K.MACHINEID and
    StockTransDATE between vSDate and vEDate AND b.ORDERNO>0
    group by b.ORDERNO,a.STOCKTRANSNO,a.STOCKTRANSDATE,b.YARNBATCHNO,c.YarnCount, d.YarnType,
e.UnitOfMeas,g.SupplierName,a.KNTITRANSACTIONTYPEID,h.FabricType,i.ClientName,l.ShadeGroupName,b.Shade,K.MACHINENAME,f.KNTITRANSACTIONTYPEID
	ORDER BY getfncWOBType(b.ORDERNO) ASC;
elsif pQueryType=151 then
/* Report for T151 Machine Wise Knitting Production*/
  OPEN data_cursor  FOR
   select b.ORDERNO,getfncWOBType(b.ORDERNO),a.STOCKTRANSNO,a.STOCKTRANSDATE,
 e.UnitOfMeas,h.FabricType,i.ClientName,K.MACHINENAME,
    sum(decode(f.KNTITRANSACTIONTYPEID,6,b.Quantity,24,b.Quantity,0)) ProductQty,
    sum(decode(f.KNTITRANSACTIONTYPEID,6,b.SQuantity,24,b.SQuantity,0)) ProductSQty,
	0 as OrderQty
    from T_Knitstock a, T_KnitStockItems b, T_UnitOfMeas e,T_knitTransactionType f,T_FabricType h,
	T_Client i, t_workorder j,T_KNITMACHINEINFO k
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=f.KNTITRANSACTIONTYPEID and
   ( f.KNTITRANSACTIONTYPEID=6 or f.KNTITRANSACTIONTYPEID=24) and
    b.FabricTypeID=h.FabricTypeID(+) and
    b.ORDERNO=j.ORDERNO and
    j.ClientID=i.ClientID and
	b.PunitOfMeasId=e.UnitOfmeasId(+) and
    b.MACHINEID=K.MACHINEID and
    a.StockTransDATE between decode(vSDate,null,'01-jan-2000',vSDate) and vEDate AND b.ORDERNO>0
    group by b.ORDERNO,a.STOCKTRANSNO,a.STOCKTRANSDATE,
e.UnitOfMeas,a.KNTITRANSACTIONTYPEID,h.FabricType,i.ClientName,K.MACHINENAME,f.KNTITRANSACTIONTYPEID
	ORDER BY getfncWOBType(b.ORDERNO),K.MACHINENAME ASC;
   end if;

End GetReportKYAllDetailS;

PROMPT CREATE OR REPLACE Procedure  10 :: GetReportMRALL
CREATE OR REPLACE PROCEDURE GetReportMRALL(
 data_cursor IN OUT pReturnData.c_Records,
  sDate IN VARCHAR2,
  eDate IN VARCHAR2
)
AS
  vSDate date;
  vEDate date;
BEGIN
  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  else
   vSDate := TO_DATE('01/01/1900', 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  else
   vEDate := TO_DATE('01/01/1900', 'DD/MM/YYYY');
  end if;
  OPEN data_cursor  FOR
  select AuxName,SUM(STOCKQTY),b.AuxStockId,StockDate,DYEBASE,
  PURCHASEORDERNO,PURCHASEORDERDATE,f.SUPPLIERNAME,f.SADDRESS,
  DELIVERYNOTE,DELIVERYNOTEDATE,REMARKS,STOCKINVOICENO, AUXUNITPRICE
  from t_auxstockitem a,t_auxstock b,
  T_Auxiliaries c ,T_UnitOfMeas D,T_DyeBase e,t_supplier f
  where a.AUXSTOCKID=b.AUXSTOCKID and
  b.supplierID=f.SupplierID and
  a.AUXTYPEID=c.AUXTYPEID  and
  a.AUXID=c.AUXID and
  e.DYEBASEID(+)=c.DYEBASEID and
  c.UnitOfMeasId=d.UnitOfMeasId And
  AUXSTOCKTYPEID=2 And
  b.StockDate Between VsDate and VeDate 
  GROUP BY AuxName,b.AuxStockId,StockDate,DYEBASE,
  PURCHASEORDERNO,PURCHASEORDERDATE,f.SUPPLIERNAME,f.SADDRESS,
  DELIVERYNOTE,DELIVERYNOTEDATE,REMARKS,STOCKINVOICENO, AUXUNITPRICE;
End GetReportMRALL;
/


PROMPT CREATE OR REPLACE Procedure  11 :: GetReportMRDetails
CREATE OR REPLACE Procedure GetReportMRDetails (
  data_cursor IN OUT pReturnData.c_Records,
  PAUXSTOCKID IN NUMBER
)
As

Begin
 OPEN data_cursor  FOR
 select a.AuxId,c.AuxName,f.AUXTYPE,UnitOfMeas,SUM(STOCKREQQTY),SUM(STOCKQTY),
 DYEBASE,STOCKDATE,REMARKS,STOCKINVOICENO,AUXSTOCKTYPEID
 from t_auxstockitem a,t_auxstock b, T_Auxiliaries c ,
 T_UnitOfMeas D,T_DyeBase e,T_AuxType f
 where a.AUXSTOCKID=b. AUXSTOCKID and
 a.AUXTYPEID=c.AUXTYPEID  and
 a.AUXTYPEID=f.AUXTYPEID  and
 a.AUXID=c.AUXID And
 e.DYEBASEID(+)=c.DYEBASEID and
 c.UnitOfMeasId=d.UnitOfMeasId And
 AUXSTOCKTYPEID=2 And
 a.AUXSTOCKID=PAUXSTOCKID
 GROUP BY a.AuxId,c.AuxName,f.AUXTYPE,UnitOfMeas,DYEBASE,STOCKDATE,REMARKS,STOCKINVOICENO,AUXSTOCKTYPEID;
End GetReportMRDetails;
/




PROMPT CREATE OR REPLACE Procedure  12 :: GetReportMRRALL
CREATE OR REPLACE PROCEDURE GetReportMRRALL(
  data_cursor IN OUT pReturnData.c_Records,
  sDate IN VARCHAR2,
  eDate IN VARCHAR2
)
AS
  vSDate date;
  vEDate date;

BEGIN

  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  else
   vSDate := TO_DATE('01/01/1900', 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  else
   vEDate := TO_DATE('01/01/1900', 'DD/MM/YYYY');
  end if;

  OPEN data_cursor  FOR
  select AuxName,SUM(STOCKQTY),b.AuxStockId,StockDate,DYEBASE,
  PURCHASEORDERNO,PURCHASEORDERDATE,b.SUPPLIERID,f.SUPPLIERNAME,f.SADDRESS,
  DELIVERYNOTE,DELIVERYNOTEDATE,REMARKS,STOCKINVOICENO,WAvgprice
  from t_auxstockitem a,t_auxstock b,
  T_Auxiliaries c ,T_UnitOfMeas D,T_DyeBase e,t_supplier f
  where a.AUXSTOCKID=b.AUXSTOCKID and
  b.SUPPLIERID=f.SUPPLIERID and 
  a.AUXTYPEID=c.AUXTYPEID  and
  a.AUXID=c.AUXID and
  e.DYEBASEID(+)=c.DYEBASEID and
  c.UnitOfMeasId=d.UnitOfMeasId And
  AUXSTOCKTYPEID=1 And
  b.StockDate Between VsDate and VeDate 
  GROUP BY AuxName,b.AuxStockId,StockDate,DYEBASE,
  PURCHASEORDERNO,PURCHASEORDERDATE,b.SUPPLIERID,f.SUPPLIERNAME,f.SADDRESS,
  DELIVERYNOTE,DELIVERYNOTEDATE,REMARKS,STOCKINVOICENO,WAvgprice;

End GetReportMRRALL;
/



PROMPT CREATE OR REPLACE Procedure  13 :: GetReportProdIssue
CREATE OR REPLACE Procedure GetReportProdIssue (
  data_cursor IN OUT pReturnData.c_Records,
  PAUXSTOCKID IN NUMBER
)
As

Begin
 OPEN data_cursor  FOR
 select a.AuxId,AuxName,f.AUXTYPE,UnitOfMeas,SUM(STOCKREQQTY),SUM(STOCKQTY),
 DYEBASE,STOCKDATE,REMARKS,STOCKINVOICENO,AUXSTOCKTYPEID
 from t_auxstockitem a,t_auxstock b, T_Auxiliaries c ,
T_UnitOfMeas D,T_DyeBase e,T_AuxType f
 where a.AUXSTOCKID=b. AUXSTOCKID and
 a.AUXTYPEID=c.AUXTYPEID  and
 a.AUXTYPEID=f.AUXTYPEID  and
 a.AUXID=c.AUXID And
 e.DYEBASEID(+)=c.DYEBASEID and
 c.UnitOfMeasId=d.UnitOfMeasId And
 AUXSTOCKTYPEID=3 And
 a.AUXSTOCKID=PAUXSTOCKID 
 GROUP BY a.AuxId,AuxName,f.AUXTYPE,UnitOfMeas,
 DYEBASE,STOCKDATE,REMARKS,STOCKINVOICENO,AUXSTOCKTYPEID;
End  GetReportProdIssue;
/



PROMPT CREATE OR REPLACE Procedure  14 :: GetReportProdIssueALL
CREATE OR REPLACE PROCEDURE GetReportProdIssueALL(
 data_cursor IN OUT pReturnData.c_Records,
  sDate IN VARCHAR2,
  eDate IN VARCHAR2
)
AS
  vSDate date;
  vEDate date;

BEGIN

  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  else
   vSDate := TO_DATE('01/01/1900', 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  else
   vEDate := TO_DATE('01/01/1900', 'DD/MM/YYYY');
  end if;

  OPEN data_cursor  FOR
  select AuxName,SUM(STOCKQTY),b.AuxStockId,StockDate,DYEBASE,
  PURCHASEORDERNO,PURCHASEORDERDATE,b.SUPPLIERID,f.SUPPLIERNAME,f.SADDRESS,
  DELIVERYNOTE,DELIVERYNOTEDATE,REMARKS,STOCKINVOICENO, AUXUNITPRICE
  from t_auxstockitem a,t_auxstock b,
  T_Auxiliaries c ,T_UnitOfMeas D,T_DyeBase e,t_supplier f
  where a.AUXSTOCKID=b.AUXSTOCKID and
  b.SUPPLIERID =f.SUPPLIERID and
  a.AUXTYPEID=c.AUXTYPEID  and
  a.AUXID=c.AUXID and
  e.DYEBASEID(+)=c.DYEBASEID and
  c.UnitOfMeasId=d.UnitOfMeasId And
  AUXSTOCKTYPEID=3 And
  b.StockDate Between VsDate and VeDate 
  GROUP BY AuxName,b.AuxStockId,StockDate,DYEBASE,
  PURCHASEORDERNO,PURCHASEORDERDATE,b.SUPPLIERID,f.SUPPLIERNAME,f.SADDRESS,
  DELIVERYNOTE,DELIVERYNOTEDATE,REMARKS,STOCKINVOICENO, AUXUNITPRICE;

End GetReportProdIssueALL;
/

PROMPT CREATE OR REPLACE Procedure  15 :: GetReportWorkOrder

CREATE OR REPLACE Procedure GetReportWorkOrder
(
  data_cursor IN OUT pReturnData.c_Records,
  pWhereValue number
)
AS
BEGIN
  OPEN data_cursor for
  select a.orderno,getfncWOBType(a.orderno) as workorder,a.basictypeID,a.orderref,c.clientname as ClientName,
  c.CCONTACTPERSON,d.salesterm as SalesTerm,a.ContactPerson,b.WOITEMSL,a.OrderDate,a.clientsref,h.CurrencyName,
  a.DELIVERYSTARTDATE,a.DELIVERYENDDATE,b.GRAYGSM,B.finishedgsm,b.WIDTH,b.SHRINKAGE,b.Shade,b.RATE,b.QUANTITY,
  f.unitofmeas as unit,b.SQTY,u.unitofmeas as sunit,g.fabrictype as fabrictype,b.orderlineitem,a.DELIVERYPLACE,
  k.shadegroupName,/*(b.QUANTITY* b.RATE) as totalPrice,*/a.ORDERREMARKS,getFncYarnDes(b.ORDERLINEITEM) as YarnDesc,
  getFncbasicWorkOrder(a.orderno)  as BasicWorkOrder,getFncdWorkOrder(a.orderno)  as FCWorkOrder,
  b.Unitofmeasid as UnitID,a.wcancelled,m.EMPLOYEENAME as EMPMANAGER,a.wrevised,KnitMcDiaGauge,getFncDispalyOrder(a.GARMENTSORDERREF) as GDOrderNO,
  COLLARCUFFSIZE,j.EMPLOYEENAME,(n.ORDERTYPEID||' '||n.budgetno) as budgetno,a.WOEXECUTE,a.WOEXECUTEDATE,a.PRATE,a.TOTALPRICE
from t_workOrder a,t_orderItems b ,t_client c,t_salesterm d,t_unitOfmeas f,t_unitOfmeas x,t_unitOfmeas u,
  t_fabrictype g,t_Currency h,T_COLLARCUFF i,T_Employee j,t_Shadegroup k,T_Employee m, t_budget n
where a.orderno =b.orderNo and
  b.shadegroupid=k.shadegroupid and
  c.clientid=a.clientid and
  a.SALESPERSONID=j.EMPLOYEEID and
  d.salestermid=a.salestermid and
  f.unitofmeasid=b.unitofmeasid and
  u.unitofmeasid=b.SUNIT and
  b.sunit=x.unitOfmeasid(+) and
  g.fabrictypeid=b.fabrictypeid and
  a.CURRENCYID=h.CURRENCYID and
  j.EMPMANAGER=m.EMPLOYEEID(+) and
  b.COLLARCUFFID=i.COLLARCUFFID(+) and
  a.budgetid=n.budgetid(+) and
  a.OrderNo=pWhereValue
  order by a.orderno,b.WOITEMSL;
END GetReportWorkOrder;
/


PROMPT CREATE OR REPLACE Procedure  16 :: GetReportNeedleAll
CREATE OR REPLACE Procedure GetReportNeedleAll
(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pKmcStockID IN NUMBER,
  sDate IN VARCHAR2,
  eDate IN VARCHAR2
)
AS
  vSDate date;
  vEDate date;

BEGIN
  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  else
   vSDate := TO_DATE('01/01/1900', 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  else
   vEDate := TO_DATE('01/01/1900', 'DD/MM/YYYY');
  end if;

  if pQueryType=0 then
        open data_cursor for

        select b.PARTID,c.PARTNAME,MCTYPENAME,c.MCPARTSTYPEID,f.MCPARTSTYPE,
           sum(b.QTY * d.MSN) as MainStoreNew,
           sum(b.QTY * d.MSO) as MainStoreOld,
           sum(b.QTY * d.MSB) as MainStoreBroken,
           sum(b.QTY * d.MSR) as MainStoreRejected,
           sum(decode(b.MACHINEID,0,(b.QTY * d.FSN),0)) as FloorNew,
           sum(decode(b.MACHINEID,0,(b.QTY * d.FSO),0)) as FloorOld,
           sum(decode(b.MACHINEID,0,0,(b.QTY * d.FSN))) as MachineNew,
           sum(decode(b.MACHINEID,0,0,(b.QTY * d.FSO))) as MachineOld,
           sum(b.QTY * d.SSN) as SubContractorNew
           from t_kmcpartstransdetails b,t_kmcpartsinfo c,t_kmcstockStatus d,t_kmctype e,T_MCPARTSTYPE f
           where  b.PARTID=c.PARTID and B.KMCSTOCKTYPEID=d.KMCSTOCKTYPEID and
    b.PARTSSTATUSFROMID=d.PARTSSTATUSFROMID and b.PARTSSTATUSTOID=d.PARTSSTATUSTOID and
	c.MCPARTSTYPEID=f.MCPARTSTYPEID and c.MCTYPEID=e.MCTYPEID  and  c.MCPARTSTYPEID=1
           /*T_KmcPartsTran a,a.STOCKID=b.StockId and and a.StockDate Between VsDate and VeDate */
           group by b.PARTID,c.PARTNAME,MCTYPENAME,c.MCPARTSTYPEID,f.MCPARTSTYPE
    order by c.MCPARTSTYPEID,MCTYPENAME,c.PARTNAME asc;

/* For Report Needle MRR Only*/


  elsif pQueryType=1 then

open data_cursor for
    select a.StockId, a.StockDate, a.ChallanNo, a.ChallanDate,a.PURCHASEORDERNO, a.PURCHASEORDERDATE,
    a.SUPPLIERINVOICENO,a.SUPPLIERINVOICEDATE,    
    e.SUPPLIERNAME,e.SADDRESS,c.partsstatus, d.PARTID,d.QTY,b.PARTNAME,b.DESCRIPTION,UNITPRICE,
    d.REMARKS,f.LOCATION,MACHINENAME,d.KMCTYPEID,h.MCPARTSTYPE, x.CurrencyName, a.conrate
    from T_KmcPartsTran a,t_kmcpartsinfo b,t_kmcpartsstatus c,T_KMCPARTSTRANSDETAILS d,T_SUPPLIER e,t_storelocation f,T_KNITMACHINEINFO g, T_MCPARTSTYPE h, T_currency x
    where a.STOCKID=d.StockId(+) and d.PARTID=b.PARTID(+) and b.LOCATIONID=f.LOCATIONID(+) and
    c.partsstatusid(+)=d.PARTSSTATUSFROMID and a.SUPPLIERID=e.SUPPLIERID(+) and d.MACHINEID=g.MACHINEID(+) and
    a.KmcStockTypeId=1 and
    b.MCPARTSTYPEID=h.MCPARTSTYPEID(+) and
    a.CURRENCYID=x.CURRENCYID(+) and
    a.STOCKID=pKMCStockID
    order by d.STOCKITEMSL asc;

/* For Report Needle MR Only*/
  elsif pQueryType=2 then
 open data_cursor for
    select a.StockId, a.StockDate, a.ChallanNo, a.ChallanDate,a.PURCHASEORDERNO, a.PURCHASEORDERDATE,
    c.partsstatus,d.PARTID,d.QTY,b.PARTNAME,b.DESCRIPTION,UNITPRICE,
    d.REMARKS,MACHINENAME,e.MCTYPENAME
    from T_KmcPartsTran a,t_kmcpartsinfo b,t_kmcpartsstatus c,T_KMCPARTSTRANSDETAILS d,t_KMCTYPE e,T_KNITMACHINEINFO g
    where d.STOCKID=a.StockId and d.PARTID=b.PARTID and d.MACHINEID=g.MACHINEID and
    c.partsstatusid=d.PARTSSTATUSFROMID and d.KMCTYPEID=e.MCTYPEID and
    a.KmcStockTypeId=2 and
    a.STOCKID=pKMCStockID
    order by d.STOCKITEMSL asc;

/* For Report Needle Return From Floor Only*/
  elsif pQueryType=3 then
 open data_cursor for
    select a.StockId, a.StockDate, a.ChallanNo, a.ChallanDate,a.PURCHASEORDERNO, a.PURCHASEORDERDATE,
    c.partsstatus,d.PARTID,d.QTY,b.PARTNAME,b.DESCRIPTION,UNITPRICE,
    d.REMARKS,MACHINENAME,e.MCTYPENAME
    from T_KmcPartsTran a,t_kmcpartsinfo b,t_kmcpartsstatus c,T_KMCPARTSTRANSDETAILS d,t_KMCTYPE e,T_KNITMACHINEINFO g
    where d.STOCKID=a.StockId and d.PARTID=b.PARTID and d.MACHINEID=g.MACHINEID and
    c.partsstatusid=d.PARTSSTATUSTOID and d.KMCTYPEID=e.MCTYPEID and
    a.KmcStockTypeId=3 and
    a.STOCKID=pKMCStockID
    order by d.STOCKITEMSL asc;

/* For Report Needle MRequisition Only*/
  elsif pQueryType=4 then
 open data_cursor for
    select a.StockId, a.StockDate, a.ChallanNo, a.ChallanDate,a.PURCHASEORDERNO, a.PURCHASEORDERDATE,
    c.partsstatus,d.PARTID,d.QTY,b.PARTNAME,b.DESCRIPTION,UNITPRICE,
    d.REMARKS,MACHINENAME,e.MCTYPENAME
    from T_KMCPARTSTRANREQUISITION a,t_kmcpartsinfo b,t_kmcpartsstatus c,T_KMCPARTSTRANSDETAILSREQ d,t_KMCTYPE e,T_KNITMACHINEINFO g
    where d.STOCKID=a.StockId and d.PARTID=b.PARTID and d.MACHINEID=g.MACHINEID and
    c.partsstatusid=d.PARTSSTATUSFROMID and d.KMCTYPEID=e.MCTYPEID and
    a.KmcStockTypeId=2 and
    a.STOCKID=pKMCStockID
    order by d.STOCKITEMSL asc;

/* For Report Needle bROKEN From Floor and Machine Only*/
  elsif pQueryType=5 then
 open data_cursor for
	select d.PARTID,b.PARTNAME,e.MCTYPENAME,g.MACHINEID,G.MACHINENAME,sum(d.QTY)
    	from T_KmcPartsTran a,t_kmcpartsinfo b,t_kmcpartsstatus c,T_KMCPARTSTRANSDETAILS d,t_KMCTYPE e,T_KNITMACHINEINFO g
    	where d.STOCKID=a.StockId and d.PARTID=b.PARTID and d.MACHINEID=g.MACHINEID and
    	c.partsstatusid=d.PARTSSTATUSTOID and d.KMCTYPEID=e.MCTYPEID and
    	a.KmcStockTypeId=3 AND d.PARTSSTATUSTOID=3 and
	a.StockDate Between VsDate and VeDate
	group by d.PARTID,b.PARTNAME,e.MCTYPENAME,g.MACHINEID,G.MACHINENAME;

  elsif pQueryType=6 then
 open data_cursor for
        select a.STOCKID,a.STOCKDATE,a.CHALLANNO,a.CHALLANDATE,a.PURCHASEORDERNO,a.PURCHASEORDERDATE,b.PARTID,c.PARTNAME,MCTYPENAME,c.MCPARTSTYPEID,f.MCPARTSTYPE,b.KMCSTOCKTYPEID,b.mACHINEID,
           (b.QTY) as MainIn,0 as Issue2Floor,0 as ReturnFromFloor,0 as Floor2Machine
           from T_KmcPartsTran a,t_kmcpartstransdetails b,t_kmcpartsinfo c,t_kmcstockStatus d,t_kmctype e,T_MCPARTSTYPE f
           where a.STOCKID=b.StockId and b.PARTID=c.PARTID and B.KMCSTOCKTYPEID=d.KMCSTOCKTYPEID and
           b.PARTSSTATUSFROMID=d.PARTSSTATUSFROMID and b.PARTSSTATUSTOID=d.PARTSSTATUSTOID and
	   c.MCPARTSTYPEID=f.MCPARTSTYPEID and c.MCTYPEID=e.MCTYPEID and b.KMCSTOCKTYPEID=1
	union all
        select a.STOCKID,a.STOCKDATE,a.CHALLANNO,a.CHALLANDATE,a.PURCHASEORDERNO,a.PURCHASEORDERDATE,b.PARTID,c.PARTNAME,MCTYPENAME,c.MCPARTSTYPEID,f.MCPARTSTYPE,b.KMCSTOCKTYPEID,b.mACHINEID,
           0 as MainIn,(b.QTY) as Issue2Floor,0 as ReturnFromFloor,0 as Floor2Machine
           from T_KmcPartsTran a,t_kmcpartstransdetails b,t_kmcpartsinfo c,t_kmcstockStatus d,t_kmctype e,T_MCPARTSTYPE f
           where a.STOCKID=b.StockId and b.PARTID=c.PARTID and B.KMCSTOCKTYPEID=d.KMCSTOCKTYPEID and
           b.PARTSSTATUSFROMID=d.PARTSSTATUSFROMID and b.PARTSSTATUSTOID=d.PARTSSTATUSTOID and
	   c.MCPARTSTYPEID=f.MCPARTSTYPEID and c.MCTYPEID=e.MCTYPEID and b.KMCSTOCKTYPEID=2
	union all
        select a.STOCKID,a.STOCKDATE,a.CHALLANNO,a.CHALLANDATE,a.PURCHASEORDERNO,a.PURCHASEORDERDATE,b.PARTID,c.PARTNAME,MCTYPENAME,c.MCPARTSTYPEID,f.MCPARTSTYPE,b.KMCSTOCKTYPEID,b.mACHINEID,
           0 as MainIn,0 as Issue2Floor,(b.QTY) as ReturnFromFloor,0 as Floor2Machine
           from T_KmcPartsTran a,t_kmcpartstransdetails b,t_kmcpartsinfo c,t_kmcstockStatus d,t_kmctype e,T_MCPARTSTYPE f
           where a.STOCKID=b.StockId and b.PARTID=c.PARTID and B.KMCSTOCKTYPEID=d.KMCSTOCKTYPEID and
           b.PARTSSTATUSFROMID=d.PARTSSTATUSFROMID and b.PARTSSTATUSTOID=d.PARTSSTATUSTOID and
	   c.MCPARTSTYPEID=f.MCPARTSTYPEID and c.MCTYPEID=e.MCTYPEID and b.KMCSTOCKTYPEID=3
	union all
        select a.STOCKID,a.STOCKDATE,a.CHALLANNO,a.CHALLANDATE,a.PURCHASEORDERNO,a.PURCHASEORDERDATE,b.PARTID,c.PARTNAME,MCTYPENAME,c.MCPARTSTYPEID,f.MCPARTSTYPE,b.KMCSTOCKTYPEID,b.mACHINEID,
           0 as MainIn,0 as Issue2Floor,(b.QTY) as ReturnFromFloor,0 as Floor2Machine
           from T_KmcPartsTran a,t_kmcpartstransdetails b,t_kmcpartsinfo c,t_kmcstockStatus d,t_kmctype e,T_MCPARTSTYPE f
           where a.STOCKID=b.StockId and b.PARTID=c.PARTID and B.KMCSTOCKTYPEID=d.KMCSTOCKTYPEID and
           b.PARTSSTATUSFROMID=d.PARTSSTATUSFROMID and b.PARTSSTATUSTOID=d.PARTSSTATUSTOID and
	   c.MCPARTSTYPEID=f.MCPARTSTYPEID and c.MCTYPEID=e.MCTYPEID and b.KMCSTOCKTYPEID=9;
  end if;

END GetReportNeedleAll;
/



PROMPT CREATE OR REPLACE Procedure  17 :: GetReportMachineAll
CREATE OR REPLACE Procedure GetReportMachineAll
(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pmcStockID IN NUMBER,
  sDate IN VARCHAR2,
  eDate IN VARCHAR2
)
AS
  vSDate date;
  vEDate date;

BEGIN
  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  else
   vSDate := TO_DATE('01/01/1900', 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  else
   vEDate := TO_DATE('01/01/2300', 'DD/MM/YYYY');
  end if;
  if pQueryType=0 then
        open data_cursor for
        select b.PARTID,c.PARTNAME,MCTYPENAME,c.MCPARTSTYPEID,f.MCPARTSTYPE,
           sum(b.QTY * d.MSN) as MainStoreNew,
           sum(b.QTY * d.MSO) as MainStoreOld,
           sum(b.QTY * d.MSB) as MainStoreBroken,
           sum(b.QTY * d.MSR) as MainStoreRejected,
           sum(decode(b.MACHINEID,0,(b.QTY * d.FSN),0)) as FloorNew,
           sum(decode(b.MACHINEID,0,(b.QTY * d.FSO),0)) as FloorOld,
           sum(decode(b.MACHINEID,0,0,(b.QTY * d.FSN))) as MachineNew,
           sum(decode(b.MACHINEID,0,0,(b.QTY * d.FSO))) as MachineOld,
           sum(b.QTY * d.SSN) as SubContractorNew
           from T_KmcPartsTran a,t_kmcpartstransdetails b,t_kmcpartsinfo c,t_kmcstockStatus d,t_kmctype e,T_MCPARTSTYPE f
           where a.STOCKID=b.StockId and b.PARTID=c.PARTID and B.KMCSTOCKTYPEID=d.KMCSTOCKTYPEID and
    b.PARTSSTATUSFROMID=d.PARTSSTATUSFROMID and b.PARTSSTATUSTOID=d.PARTSSTATUSTOID and
	c.MCPARTSTYPEID=f.MCPARTSTYPEID and c.MCTYPEID=e.MCTYPEID  and  c.MCPARTSTYPEID=1 and
    a.StockDate Between VsDate and VeDate 
    group by b.PARTID,c.PARTNAME,MCTYPENAME,c.MCPARTSTYPEID,f.MCPARTSTYPE
    order by c.MCPARTSTYPEID,MCTYPENAME,c.PARTNAME asc;
/* For Report T39: Parts MRR Only*/
  elsif pQueryType=1 then
open data_cursor for
  select   a.StockDate,a.StockId,b.PartId,c.PARTNAME,b.Qty,a.PURCHASEORDERNO,a.PURCHASEORDERDATE,y.SUPPLIERNAME,
  y.SADDRESS as SUPPLIERADDRESS,a.DELIVERYNOTE,a.Challanno,a.CHALLANDATE,b.Stockitemsl,c.Binno,c.DESCRIPTION,b.REMARKS,
  UnitPrice, x.CURRENCYNAME, a.ConRate
  from T_TexMcStock a,T_TexMcStockItems b,T_TexMcPartsInfo c, T_Currency x,T_SUPPLIER y 
  where a.StockId=b.StockId and
  b.PartId=c.PartId  and
  a.currencyid=x.currencyid and
  a.SUPPLIERID=y.SUPPLIERID(+) and
  a.TEXMCSTOCKTYPEID=1 And 
  a.StockId=pmcStockID ORDER BY b.Stockitemsl;
/* For Report T40: Parts MR Only*/
  elsif pQueryType=2 then
 open data_cursor for
  select   a.StockDate,a.StockId,b.PartId,c.PARTNAME,b.Qty,a.PURCHASEORDERNO,a.PURCHASEORDERDATE,y.SUPPLIERNAME,
  y.SADDRESS as SUPPLIERADDRESS,a.DELIVERYNOTE,a.Challanno,a.CHALLANDATE,b.Stockitemsl,c.Binno,c.DESCRIPTION,b.REMARKS,d.McListName
  from T_TexMcStock a,T_TexMcStockItems b,T_TexMcPartsInfo c,T_TexMclist d,T_SUPPLIER y 
  where a.StockId=b.StockId and
  b.PartId=c.PartId  and
  b.IssueFor=d.McListId(+) and
  a.SUPPLIERID=y.SUPPLIERID(+) and
  a.TEXMCSTOCKTYPEID=2 And 
  a.StockId=pmcStockID ORDER BY b.Stockitemsl;
/* For Report T41: Parts Return Only*/
  elsif pQueryType=3 then
	open data_cursor for
  select   a.StockDate,a.StockId,b.PartId,c.PARTNAME,b.Qty,a.PURCHASEORDERNO,a.PURCHASEORDERDATE,y.SUPPLIERNAME,
  y.SADDRESS as SUPPLIERADDRESS,a.DELIVERYNOTE,a.Challanno,a.CHALLANDATE,b.Stockitemsl,c.Binno,c.DESCRIPTION,b.REMARKS,d.McListName
  from T_TexMcStock a,T_TexMcStockItems b,T_TexMcPartsInfo c,T_TexMclist d,T_SUPPLIER y 
  where a.StockId=b.StockId and
  b.PartId=c.PartId  and
  b.IssueFor=d.McListId(+) and
  a.SUPPLIERID=y.SUPPLIERID(+) and
  a.TEXMCSTOCKTYPEID=3 And 
  a.StockId=pmcStockID ORDER BY b.Stockitemsl;
/* For Report T42: Parts Req Only*/
  elsif pQueryType=4 then
 open data_cursor for
  select   a.StockDate,a.StockId,b.PartId,c.PARTNAME,b.Qty,a.PURCHASEORDERNO,a.PURCHASEORDERDATE,a.SUPPLIERNAME,
  a.SUPPLIERADDRESS,a.DELIVERYNOTE,a.Challanno,a.CHALLANDATE,b.Stockitemsl,c.Binno,c.DESCRIPTION,b.REMARKS,d.McListName
  from T_TexMcStockReq a,T_TexMcStockItemsReq b,T_TexMcPartsInfo c,T_TexMclist d
  where a.StockId=b.StockId and
  b.PartId=c.PartId  and
  b.IssueFor=d.McListId(+) and
  a.TEXMCSTOCKTYPEID=2 And 
  a.StockId=pmcStockID ORDER BY b.Stockitemsl;
  end if;
END GetReportMachineAll;
/



PROMPT CREATE OR REPLACE Procedure  18 :: GetReportKYRRDetailS

CREATE OR REPLACE Procedure GetReportKYRRDetailS (
   data_cursor IN OUT pReturnData.c_Records,
   pKnitStockID IN NUMBER
)
As
Begin
  OPEN data_cursor  FOR
select YarnCount, YarnType, FABRICTYPEID,OrderlineItem,a.Quantity,a.UNITPRICE,nvl(a.Quantity*a.UNITPRICE,0) as totalprice, Squantity,f.UNITOFMEAS as PUOM,
h.UNITOFMEAS as SUOM,YARNBATCHNO,SHADE,a.Remarks,b.STOCKID,ReferenceNo,ReferenceDate,StockTransNO,IMPLCNO,
StockTransDATE,g.SUPPLIERNAME,g.saddress,SupplierInvoiceNo,SupplierInvoiceDate,b.SubConId,b.Remarks as OneRemarks ,x.CURRENCYNAME, b.ConRate
from T_KnitStockItems a,T_KnitStock b,
T_YarnCount c ,T_YarnType d,T_KNITTRANSACTIONTYPE e,t_UnitOfMeas f,T_Supplier g, T_Currency x,t_UnitOfMeas h
where a.STOCKID=b.STOCKID and
b.supplierID=g.supplierID(+) and
a.YarnCountID=c.YarnCountID(+)   and
a.YarnTypeID=d.YarnTypeID(+)   and
b.CURRENCYID=x.CURRENCYID(+)  and
e.KNTITRANSACTIONTYPEID=1 And
a.PUNITOFMEASID=f.UNITOFMEASID(+)  And
a.SUNITOFMEASID=h.UNITOFMEASID(+)  And
a.STOCKID=pKnitStockID
order by YarnCount, YarnType, YARNBATCHNO;

End GetReportKYRRDetails;
/



PROMPT CREATE OR REPLACE Procedure  19 :: GetReportMRRDetails
CREATE OR REPLACE Procedure GetReportMRRDetails (
   data_cursor IN OUT pReturnData.c_Records,
  pAUXSTOCKID IN NUMBER
)
As

Begin
  OPEN data_cursor  FOR
  select c.AuxName,f.AUXTYPE,SUM(a.STOCKQTY),b.AuxStockId,b.StockDate,e.DYEBASE,
  b.STOCKINVOICENO, b.PURCHASEORDERNO, b.PURCHASEORDERDATE, b.SUPPLIERID, g.SUPPLIERNAME, g.SADDRESS
  ,b.DELIVERYNOTE,b.DELIVERYNOTEDATE,a.REMARKS, a.UnitPrice, x.CURRENCYNAME, b.ConRate
  from t_auxstockitem a,t_auxstock b,
  T_Auxiliaries c ,T_UnitOfMeas D,T_DyeBase e,T_AuxType f,t_supplier g, T_Currency x
  where a.AUXSTOCKID=b.AUXSTOCKID and
  b.SUPPLIERID=g.SUPPLIERID and
  a.AUXTYPEID=c.AUXTYPEID  and
  a.AUXTYPEID=f.AUXTYPEID  and
  a.AUXID=c.AUXID and
  e.DYEBASEID(+)=c.DYEBASEID and
  c.UnitOfMeasId=d.UnitOfMeasId And
  b.CURRENCYID=x.CURRENCYID and
  AUXSTOCKTYPEID=1 And
  a.AUXSTOCKID=PAUXSTOCKID
  GROUP BY a.PID,c.AuxName,f.AUXTYPE,b.AuxStockId,b.StockDate,e.DYEBASE,
  b.STOCKINVOICENO,b.PURCHASEORDERNO, b.PURCHASEORDERDATE, b.SUPPLIERID,g.SUPPLIERNAME,g.SADDRESS, b.DELIVERYNOTE, b.DELIVERYNOTEDATE,a.REMARKS,a.UnitPrice,x.CURRENCYNAME, b.ConRate
 Order by a.PID;

End GetReportMRRDetails;
/



PROMPT CREATE OR REPLACE Procedure  20 :: GetYarnStockReport
create or replace Procedure GetYarnStockReport(                                       
  data_cursor IN OUT pReturnData.c_Records,                                     
  pQueryType IN NUMBER,                                                         
  pKnitTranTypeID NUMBER,                                                       
  pStockDate IN VARCHAR2 DEFAULT NULL                                                            
)                                                                               
AS 
vSDate DATE;                                                                             
BEGIN        
 if not pStockDate is null then
    vSDate := TO_DATE(pStockDate, 'DD/MM/YYYY');
  end if;                                                                                                                                            
/*  All Summary Report*/                                                        
  if pQueryType=0 then                                                          
    open data_cursor for     
	
	select b.YARNBATCHNO,YarnCount,YarnType,UnitOfMeas,h.SUPPLIERNAME,x.PartyName as Yarnfor,
	fncYarnAvgPricewithSupp(b.YarnCountId,b.YarnTypeId,b.YARNBATCHNO,b.SUPPLIERID,vSDate) as UnitPrice,
	nvl(sum(decode(a.KNTITRANSACTIONTYPEID,1,Quantity*ATLGYS,0)),0)  as MRR,
	nvl(sum(decode(a.KNTITRANSACTIONTYPEID,3,-Quantity*ATLGYS,0)),0) as ISSUED_KF,
	nvl(sum(decode(a.KNTITRANSACTIONTYPEID,4,-Quantity*ATLGYS,0)),0)  as ISSUED_KS,
	nvl(sum(decode(a.KNTITRANSACTIONTYPEID,5,-Quantity*ATLGYS,0)),0)  as ISSUED_DF,
	nvl(sum(decode(a.KNTITRANSACTIONTYPEID,12,-Quantity*ATLGYS,0)),0)  as ISSUED_DS,
    nvl(sum(Quantity*ATLGYS),0) as MainStore, 
	(case when nvl(sum(Quantity*ATLGYF),0)<0  then 0
        else nvl(sum(Quantity*ATLGYF),0) end) as Floor, 
	(case when nvl(sum(Quantity*AYDLGYS),0)<0 then 0
        else nvl(sum(Quantity*AYDLGYS),0) end) as AYDL, 
	(case when nvl(sum(Quantity*ODSCONGYS),0)<0 then 0
        else nvl(sum(Quantity*ODSCONGYS),0) end) as Others, 
	(case when nvl(sum(Quantity*KSCONGYS),0)<0 then 0
        else nvl(sum(Quantity*KSCONGYS),0) end) as KnittingSubContractor 
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, T_YarnCount d, 
    T_YarnType e, T_UnitOfMeas f,t_supplier h ,T_YarnParty x	
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    b.YarnCountId=d.YarnCountId and
    b.YarnTypeId= e.YarnTypeId and
    b.PUnitOfMeasID=f.UnitOfMeasID and
	b.YARNFOR=x.PID(+) and
	b.SUPPLIERID=h.SUPPLIERID and  
	b.YARNFOR=pKnitTranTypeID and /*It is use for Yarn Party Name*/
	a.STOCKTRANSDATE <=vSDate 
    group by b.YARNBATCHNO,YarnCount,YarnType,UnitOfMeas,h.SUPPLIERNAME,x.PartyName,
	         b.YarnCountId,b.YarnTypeId,b.SUPPLIERID
    having nvl(sum(Quantity*ATLGYS),0)>0 
	ORDER BY YarnCount,YarnType,YARNBATCHNO ASC;
           
    /* ATLGYS*/                                                             
  elsif pQueryType=1 then                                                       
    	open data_cursor for                                                        
    	select b.ORDERNO,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,b.FABRICTYPEID,
    	FABRICTYPE,b.OrderlineItem, b.YARNTYPEID,b.YARNCOUNTID,YarnCount,             
		YarnType,b.PUnitOfMeasId,UnitOfMeas,sum(Quantity*ATLGYS) CurrentStock                                        
    	from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c,
		T_YarnCount d, T_YarnType e, T_UnitOfMeas f,   
    	T_FabricType g,t_supplier h                                                 
    	where a.StockID=b.StockID and                                               
		b.SUPPLIERID=h.SUPPLIERID(+) and                                                  
    	a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and                         
    	b.YarnCountId=d.YarnCountId and                                             
    	b.YarnTypeId= e.YarnTypeId and                                              
    	b.FABRICTYPEID=g.FABRICTYPEID and                                           
    	b.PUnitOfMeasID=f.UnitOfMeasID and                                          
    	STOCKTRANSDATE <= pStockDate                                                
        group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,YarnType,
		b.PUnitOfMeasId,UnitOfMeas,b.FABRICTYPEID,FABRICTYPE,b.YARNBATCHNO,b.SUPPLIERID,h.SUPPLIERNAME    
    	having sum(Quantity*ATLGYS)>0;                                              
                                                                                
/*  ATLGFS*/                                                                    
elsif pQueryType=2 then                                                         
    open data_cursor for                                                        
    select b.ORDERNO,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,b.FABRICTYPEID,
	FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,
	YarnType,b.PUnitOfMeasId,UnitOfMeas, sum(Quantity*ATLGFS) CurrentStock                                           
    	from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
	T_YarnCount d, T_YarnType e, T_UnitOfMeas f,                                                                          
    	T_FabricType g,t_supplier h                                                 
    	where a.StockID=b.StockID and                                               
		b.SUPPLIERID=h.SUPPLIERID(+) and                                                  
    	a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and                         
    	b.YarnCountId=d.YarnCountId and                                             
    	b.YarnTypeId= e.YarnTypeId and                                              
    	b.FABRICTYPEID=g.FABRICTYPEID and                                           
    	b.PUnitOfMeasID=f.UnitOfMeasID and                                          
    	STOCKTRANSDATE <= pStockDate                                                
    	group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,     
    	YarnType,b.PUnitOfMeasId,UnitOfMeas,b.FABRICTYPEID,FABRICTYPE,b.YARNBATCHNO,b.SUPPLIERID,h.SUPPLIERNAME                                                  
    	having sum(Quantity*ATLGFS)>0;    
                                          
        /* ATLGYF */                                                
elsif pQueryType=3 then                                                         
    open data_cursor for                                                        
    select b.ORDERNO,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,b.FABRICTYPEID,
	FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,YarnType,
	b.PUnitOfMeasId,UnitOfMeas,sum(Quantity*ATLGYF) CurrentStock                                           
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, T_YarnCount d,
	T_YarnType e, T_UnitOfMeas f,T_FabricType g,t_supplier h                                                 
    where a.StockID=b.StockID and                                               
	b.SUPPLIERID=h.SUPPLIERID(+) and                                                  
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and                         
    b.YarnCountId=d.YarnCountId and                                             
    b.YarnTypeId= e.YarnTypeId and                                              
    b.FABRICTYPEID=g.FABRICTYPEID and                                           
    b.PUnitOfMeasID=f.UnitOfMeasID and                                          
    STOCKTRANSDATE <= pStockDate                                                
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.FABRICTYPEID,FABRICTYPE,b.YARNBATCHNO,                                                                           
    b.SUPPLIERID,h.SUPPLIERNAME                                                  
    having sum(Quantity*ATLGYF)>0;                                              
                /* AYDLGYS */                                                   
elsif pQueryType=4 then                                                         
    open data_cursor for                                                        
    select b.ORDERNO,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,b.FABRICTYPEID,FABRICTYPE,
b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,YarnType,b.PUnitOfMeasId,UnitOfMeas,                                                         
    sum(Quantity*AYDLGYS) CurrentStock                                          
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, 
    T_YarnCount d, T_YarnType e, T_UnitOfMeas f,                                               
    T_FabricType g,t_supplier h                                                 
    where a.StockID=b.StockID and                                               
	b.SUPPLIERID=h.SUPPLIERID(+) and                                                  
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and                         
    b.YarnCountId=d.YarnCountId and                                             
    b.YarnTypeId= e.YarnTypeId and                                              
    b.FABRICTYPEID=g.FABRICTYPEID and                                           
    b.PUnitOfMeasID=f.UnitOfMeasID and                                          
    STOCKTRANSDATE <= pStockDate                                                
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,
    YarnCount,YarnType,b.PUnitOfMeasId,UnitOfMeas,b.FABRICTYPEID,FABRICTYPE,b.YARNBATCHNO                                                                            
   ,b.SUPPLIERID,h.SUPPLIERNAME                                                 
    having sum(Quantity*AYDLGYS)>0;                                             
                                                                                
                /*ODSCONGYS*/                                                   
elsif pQueryType=5 then                                                         
    open data_cursor for                                                        
    select b.ORDERNO,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,b.FABRICTYPEID,
FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,
YarnType,b.PUnitOfMeasId,UnitOfMeas,                                                         
    sum(Quantity*ODSCONGYS) CurrentStock                                        
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, T_YarnCount
 d, T_YarnType e, T_UnitOfMeas f,                                               
    T_FabricType g,t_supplier h                                                 
    where a.StockID=b.StockID and                                               
	b.SUPPLIERID=h.SUPPLIERID(+) and                                                  
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and                         
    b.YarnCountId=d.YarnCountId and                                             
    b.YarnTypeId= e.YarnTypeId and                                              
    b.FABRICTYPEID=g.FABRICTYPEID and                                           
    b.PUnitOfMeasID=f.UnitOfMeasID and                                          
    STOCKTRANSDATE <= pStockDate                                                
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,     
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.FABRICTYPEID,FABRICTYPE,b.YARNBATCHNO                                                                            
   ,b.SUPPLIERID,h.SUPPLIERNAME                                                 
    having sum(Quantity*ODSCONGYS)>0;                                           
                                                                                                                                                    
                /*KSCONGYS*/                                                    
elsif pQueryType= 6 then                                                        
    open data_cursor for                                                        
    select b.ORDERNO,b.SUPPLIERID,h.SUPPLIERNAME,b.YARNBATCHNO,b.FABRICTYPEID,
FABRICTYPE,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,
YarnType,b.PUnitOfMeasId,UnitOfMeas,                                                         
    sum(Quantity*KSCONGYS) CurrentStock                                         
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, T_YarnCount
 d, T_YarnType e, T_UnitOfMeas f,                                               
    T_FabricType g,t_supplier h                                                 
    where a.StockID=b.StockID and                                               
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and                         
    b.YarnCountId=d.YarnCountId and                                             
	b.SUPPLIERID=h.SUPPLIERID(+) and                                                  
    b.YarnTypeId= e.YarnTypeId and                                              
    b.FABRICTYPEID=g.FABRICTYPEID and                                           
    b.PUnitOfMeasID=f.UnitOfMeasID and                                          
    STOCKTRANSDATE <= pStockDate                                                
    group by b.ORDERNO,b.OrderlineItem,b.YARNTYPEID,b.YARNCOUNTID,YarnCount,     
    YarnType,b.PUnitOfMeasId,UnitOfMeas,b.FABRICTYPEID,FABRICTYPE,b.YARNBATCHNO,b.SUPPLIERID,h.SUPPLIERNAME                                                 
    having sum(Quantity*KSCONGYS)>0; 

/*Yarn Price Report*/
elsif pQueryType=7 then                                                          
    open data_cursor for
    select b.YARNBATCHNO,'' as STOCKTRANSNO,
	'' as STOCKTRANSDATE,g.SupplierName,YarnCount,YarnType,
	nvl(sum(Quantity*ATLGYS),0) as MainStore,h.qty,
	/*fncYarnAvgPricewithSupp(b.YarnCountId,b.YarnTypeId,b.YARNBATCHNO,b.SUPPLIERID,vSDate)*/0 as UNITPRICE
    from T_KnitStock a, T_knitStockItems b, T_KnitTransactionTYpe c, T_YarnCount d, 
    T_YarnType e, T_UnitOfMeas f,t_supplier g,t_yarnprice h
    where a.StockID=b.StockID and
    b.SUPPLIERID=g.SUPPLIERID(+) and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID(+) and
    b.YarnCountId=d.YarnCountId(+) and
    b.YarnTypeId= e.YarnTypeId(+) and
    (
	h.PURCHASEDATE=(select max(PURCHASEDATE) from t_yarnprice x 
	where b.YarnCountId=x.CountId and b.SUPPLIERID=x.SUPPLIERID and
    b.YarnTypeId=x.YarnTypeId and trim(b.YARNBATCHNO)=trim(x.YARNBATCHNO) )) and 	
    b.PUnitOfMeasID=f.UnitOfMeasID(+) and
    b.YarnCountId=h.CountId(+) and
    b.YarnTypeId= h.YarnTypeId(+) and 
	b.SUPPLIERID=h.SUPPLIERID and
    trim(b.YARNBATCHNO)=h.YARNBATCHNO(+)  and
    STOCKTRANSDATE <= vSDate
    group by b.YARNBATCHNO,b.SUPPLIERID,g.SupplierName,YarnCount,YarnType,h.qty,h.REFPID,
	         b.YarnCountId,b.YarnTypeId
    having sum(decode(a.KNTITRANSACTIONTYPEID,1,Quantity*ATLGYS,0))>0
    	order by YarnCount,YarnType,b.YARNBATCHNO;
  end if;                                                                                                                                            
END GetYarnStockReport;
/

PROMPT CREATE OR REPLACE Procedure  21 :: GetReportAccStockPosition2
Create or Replace Procedure GetReportAccStockPosition2(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pGorder in NUMBER,   
  pSupplier in varchar2,   
  sDate IN VARCHAR2,
  eDate IN VARCHAR2 
)
AS
vSDate date;
vEDate date;
BEGIN
  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  end if;
 
/*AccMRRDetailS ORDER BY Supplier WISE*/
 if pQueryType=1 then
   OPEN data_cursor  FOR 
   select m.SupplierName as Group_by,a.StockId, a.StockTransNo,  a.StockTransDate, b.LineNo, b.RequisitionNo, b.ORDERNO, i.item ,a.REFERENCENO,
   b.StyleNo, c.ColourName, b.Code, b.Count_Size, b.CurrentStock, b.ReqQuantity, b.Quantity, b.SQuantity ,
   f.UNITOFMEAS as PUOM, f.UNITOFMEAS as SUOM , b.remarks,m.SupplierName,getfncDispalyorder(b.GORDERNO) as GORDERNO
   from T_AccStock a, T_AccStockItems b,T_AccTransactionType t,T_UnitOfMeas f, T_accessories i, T_Colour c,T_supplier m
   where a.STOCKID=b.STOCKID and
   t.AccTransTypeID=a.AccTransTypeID and
   t.AccTransTypeID=1 And
   (pGorder is null or b.GORDERNO=pGorder) and
   a.SUPPLIERID=m.SUPPLIERID(+) and
   (pSupplier is null or a.SUPPLIERID=pSupplier) and
   i.AccessoriesID=b.AccessoriesID and
   b.PUNITOFMEASID=f.UNITOFMEASID And
   c.colourID=b.colourID and
   a.StockTransDate between decode(vSDate,null,'01-Jan-2007',vSDate) and vEDate
   order by a.StockTransDate;
/*AccMRRDetailS ORDER BY Gorder No WISE*/
 elsif pQueryType=2 then
   OPEN data_cursor  FOR 
   select getfncDispalyorder(b.GORDERNO) as Group_by,a.StockId, a.StockTransNo,  a.StockTransDate, b.LineNo, b.RequisitionNo, b.ORDERNO, i.item ,a.REFERENCENO,
   b.StyleNo, c.ColourName, b.Code, b.Count_Size, b.CurrentStock, b.ReqQuantity, b.Quantity, b.SQuantity ,
   f.UNITOFMEAS as PUOM, f.UNITOFMEAS as SUOM , b.remarks,m.SupplierName,getfncDispalyorder(b.GORDERNO) as GORDERNO
   from T_AccStock a, T_AccStockItems b,T_AccTransactionType t,T_UnitOfMeas f, T_accessories i, T_Colour c,T_supplier m
   where a.STOCKID=b.STOCKID and
   t.AccTransTypeID=a.AccTransTypeID and
   t.AccTransTypeID=1 And
   (pGorder is null or b.GORDERNO=pGorder) and
   a.SUPPLIERID=m.SUPPLIERID(+) and
   (pSupplier is null or a.SUPPLIERID=pSupplier) and   
   i.AccessoriesID=b.AccessoriesID and
   b.PUNITOFMEASID=f.UNITOFMEASID And
   c.colourID=b.colourID and
   a.StockTransDate between decode(vSDate,null,'01-Jan-2007',vSDate) and vEDate
   order by a.StockTransDate;
 end if;
END GetReportAccStockPosition2;
/


PROMPT CREATE OR REPLACE Procedure  22 :: GetReportAccStockPosition3
Create or Replace Procedure GetReportAccStockPosition3(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,  
  pOrder in NUMBER,
  pClient IN VARCHAR2,
  sDate IN VARCHAR2,
  eDate IN VARCHAR2
)
AS
vSDate date;
vEDate date;
BEGIN
  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  end if;
  /*Stock Position*/
  if pQueryType=0 then
    open data_cursor for
select b.OrderNo, b.StyleNo,c.ColourName, b.Code, i.Item,b.Count_Size,n.CLIENTNAME,getfncDispalyorder(b.GORDERNO) as GORDERNO,
sum(decode (a.AccTransTypeID,1,b.Quantity,0)) MainStock,
sum(decode (a.AccTransTypeID,2,b.Quantity,0)) SubStock,
sum(decode (a.AccTransTypeID,4,b.Quantity,0)) returnqty
    from T_AccStock a, T_AccStockItems b, T_AccTransactionType t, T_accessories i, T_colour c,T_GWorkORDER m, T_client n
    where a.StockID=b.StockID and
	t.AccTransTypeID=a.AccTransTypeID and
	a.AccTransTypeID IN (1,2,4) AND
	b.GORDERNO=m.GORDERNO and
	(pOrder is null or b.GORDERNO=pOrder) and
	(pClient is null or m.CLIENTID=pClient) and
	m.CLIENTID=n.CLIENTID(+) and
    b.AccessoriesID=i.AccessoriesID and
	b.ColourID=c.ColourID
	group by b.OrderNo, b.StyleNo,c.ColourName,b.Code, i.Item,b.Count_Size,n.CLIENTNAME,getfncDispalyorder(b.GORDERNO)
	order by OrderNo, StyleNo desc, ColourName desc, code  desc, Item  desc, Count_Size desc;
 end if;
END GetReportAccStockPosition3;
/


PROMPT CREATE OR REPLACE Procedure  23 :: GetReportDyedYarnFabric
Create or Replace Procedure GetReportDyedYarnFabric
(
   data_cursor IN OUT pReturnData.c_Records,
   pKnitStockID IN NUMBER
)
As
Begin
  OPEN data_cursor  FOR
  select b.KNTITRANSACTIONTYPEID,YarnCount,FABRICTYPE,YarnType,a.Quantity,a.Squantity,
  f.UNITOFMEAS as PUOM,f.UNITOFMEAS as SUOM,YARNBATCHNO,a.SHADE,
  a.Remarks,b.STOCKID,b.ReferenceNo,b.ReferenceDate,b.StockTransNO,
  b.StockTransDATE,b.SupplierInvoiceNo,m.shadegroupName,
  b.SupplierInvoiceDate,j.SubConName,h.orderNo,getfncWOBType(h.orderno) as workorder,DyedLotNo
  from T_KnitStockItems a,T_KnitStock b,T_YarnCount c ,
  T_YarnType d,T_FABRICTYPE e,t_UnitOfMeas f,
  t_WorkOrder h, T_Subcontractors j,t_shadegroup m
  where a.STOCKID=b.STOCKID and
  a.shadegroupid=m.shadegroupid and 
  a.YarnCountID=c.YarnCountID and
  a.YarnTypeID=d.YarnTypeID and
  a.PUNITOFMEASID=f.UNITOFMEASID And
  a.orderNo=h.OrderNo And
  a.FABRICTYPEID=e.FABRICTYPEID and
  b.SubconId=j.SubconId And
  a.STOCKID=pKnitStockID;
End GetReportDyedYarnFabric;
/


PROMPT CREATE OR REPLACE Procedure  24 :: GetReportFabricReceived 
CREATE OR REPLACE Procedure GetReportFabricReceived 
(
   data_cursor IN OUT pReturnData.c_Records,
   pKnitStockID IN NUMBER
)
As
Begin
  OPEN data_cursor  FOR
  select YarnCount,FabricType,YarnType,a.Quantity,a.Squantity,
  f.UNITOFMEAS as PUOM,f.UNITOFMEAS as SUOM,YARNBATCHNO,a.SHADE,
  a.Remarks,b.STOCKID,b.ReferenceNo,b.ReferenceDate,b.StockTransNO,
  b.StockTransDATE,E.SUPPLIERNAME,E.SADDRESS,b.SupplierInvoiceNo,
  b.SupplierInvoiceDate,j.SubConName,j.SUBADDRESS,j.SUBCONTACTPERSON,h.orderNo,getfncWOBType(h.orderno) as workorder
  from T_KnitStockItems a,T_KnitStock b,T_YarnCount c ,
  T_YarnType d,T_SUPPLIER E,t_UnitOfMeas f,T_FabricType g,
  t_WorkOrder h,T_Subcontractors j
  where a.STOCKID=b.STOCKID and
  a.supplierId=e.supplierID and
  a.YarnCountID=c.YarnCountID  and
  a.YarnTypeID=d.YarnTypeID  and
  a.FabricTypeID=g.FabricTypeID and
  a.PUNITOFMEASID=f.UNITOFMEASID And
  a.orderNo=h.OrderNo And
  b.SubconId=j.SubconId And
  a.STOCKID=pKnitStockID;
End GetReportFabricReceived ;
/


PROMPT CREATE OR REPLACE Procedure  25 :: GetReportGWorkOrder
CREATE OR REPLACE Procedure GetReportGWorkOrder
(
  data_cursor IN OUT pReturnData.c_Records,
  pWhereValue number
)
AS
BEGIN

  OPEN data_cursor for

  select a.GORDERNO,a.GORDERDATE,getfncDispalyorder(a.GORDERNO) as DOrder,c.ClientName,d.SalesTerm,a.ContactPerson,
  b.WOITEMSL,STYLE,h.COUNTRYNAME,a.CLIENTSREF,g.CurrencyName,b.Shade,b.PRICE,b.QUANTITY,f.unitofmeas as unit,
  b.ORDERLINEITEM,(b.QUANTITY* b.PRICE) as totalPrice,a.ORDERREMARKS, getFncYarnDes(b.ORDERLINEITEM) as YarnDesc,
  getFncbasicWorkOrder(a.GORDERNO)  as BasicWorkOrder,b.Unitofmeasid as UnitID,a.wcancelled,a.wrevised,a.OrderTypeID,
  i.DESCRIPTION as OrderType,b.DELIVERYDATE,j.EMPLOYEENAME,m.EMPLOYEENAME as EMPMANAGER
  from T_GWorkOrder a,T_GOrderItems b ,t_client c,t_salesterm d,t_unitOfmeas f,
  t_Currency g,t_COUNTRY h,t_GOrderType i,T_Employee j,T_Employee m
  where a.GORDERNO =b.GORDERNO and
  c.clientid=a.clientid and
  a.SALESPERSONID=j.EMPLOYEEID and
  d.salestermid=a.salestermid and
  f.unitofmeasid=b.unitofmeasid and
  a.CURRENCYID=g.CURRENCYID and
  B.COUNTRYID=H.COUNTRYID and
  j.EMPMANAGER=m.EMPLOYEEID(+) and
  a.OrderTypeID=i.OrderType and
  a.GORDERNO=pWhereValue
  order by a.GORDERNO,b.WOITEMSL;

END GetReportGWorkOrder;
/


PROMPT CREATE OR REPLACE Procedure  26 :: GetReportGrayYarnRequisition 
CREATE OR REPLACE Procedure GetReportGrayYarnRequisition 
(
   data_cursor IN OUT pReturnData.c_Records,
   pQueryType IN NUMBER,
   pKnitStockID IN NUMBER
)
As
Begin
/*  For Report WOWISE */
  if pQueryType=1 then
  OPEN data_cursor  FOR
  select YarnCount,YARNREQUISITIONTYPE, YarnType,a.Quantity,a.Squantity,
  f.UNITOFMEAS as PUOM,f.UNITOFMEAS as SUOM,YARNBATCHNO,a.DYEDLOTNO,a.SHADE,
  a.Remarks,b.STOCKID,b.ReferenceNo,b.ReferenceDate,b.StockTransNO,
  b.StockTransDATE,b.SupplierInvoiceNo,
  b.SupplierInvoiceDate,j.SubConName,l.clientname,a.orderno,getfncWOBType(a.orderno) as workorder,k.GARMENTSORDERREF,m.shadegroupName
  from T_yarnrequisitionItems a,T_yarnrequisition b,T_YarnCount c ,
  T_YarnType d,T_YARNREQUISITIONTYPE e,t_UnitOfMeas f,
  T_Subcontractors j,T_Workorder k,t_client l,t_shadegroup m
  where a.STOCKID=b.STOCKID and
  a.YarnCountID=c.YarnCountID  and
  a.YarnTypeID=d.YarnTypeID  and
  a.shadegroupid=m.shadegroupid and 
  b.YARNREQUISITIONTYPEID=e.YARNREQUISITIONTYPEID and
  a.PUNITOFMEASID=f.UNITOFMEASID And
  b.SubconId=j.SubconId And
  a.orderno=k.orderno and
  k.clientid=l.clientid and
  e.YARNREQUISITIONTYPEID=1 and
  a.STOCKID=pKnitStockID;
 /* For REPORT CLIENT WISE */
  elsif pQueryType=2 then
  OPEN data_cursor  FOR
  select YarnCount,YARNREQUISITIONTYPE, YarnType,a.Quantity,a.Squantity,
  f.UNITOFMEAS as PUOM,f.UNITOFMEAS as SUOM,YARNBATCHNO,a.DYEDLOTNO,a.SHADE,
  a.Remarks,b.STOCKID,b.ReferenceNo,b.ReferenceDate,b.StockTransNO,
  b.StockTransDATE,b.SupplierInvoiceNo,
  b.SupplierInvoiceDate,j.SubConName,l.clientname,a.orderno,getfncWOBType(a.orderno) as workorder,k.GARMENTSORDERREF
  from T_yarnrequisitionItems a,T_yarnrequisition b,T_YarnCount c ,
  T_YarnType d,T_YARNREQUISITIONTYPE e,t_UnitOfMeas f,
  T_Subcontractors j,T_Workorder k,t_client l
  where a.STOCKID=b.STOCKID and
  a.YarnCountID=c.YarnCountID  and
  a.YarnTypeID=d.YarnTypeID  and
  b.YARNREQUISITIONTYPEID=e.YARNREQUISITIONTYPEID and
  a.PUNITOFMEASID=f.UNITOFMEASID And
  b.SubconId=j.SubconId And
  a.orderno=k.orderno and
  k.clientid=l.clientid and
  e.YARNREQUISITIONTYPEID=2 and
  a.STOCKID=pKnitStockID;
 /* For REPORT CLIENT WISE */
  elsif pQueryType=3 then
  OPEN data_cursor  FOR
  select YarnCount,YARNREQUISITIONTYPE, YarnType,a.Quantity,a.Squantity,
  f.UNITOFMEAS as PUOM,f.UNITOFMEAS as SUOM,YARNBATCHNO,a.DYEDLOTNO,a.SHADE,
  a.Remarks,b.STOCKID,b.ReferenceNo,b.ReferenceDate,b.StockTransNO,
  b.StockTransDATE,b.SupplierInvoiceNo,
  b.SupplierInvoiceDate,j.SubConName,l.clientname,a.orderno,getfncWOBType(a.orderno) as workorder,k.GARMENTSORDERREF
  from T_yarnrequisitionItems a,T_yarnrequisition b,T_YarnCount c ,
  T_YarnType d,T_YARNREQUISITIONTYPE e,t_UnitOfMeas f,
  T_Subcontractors j,T_Workorder k,t_client l
  where a.STOCKID=b.STOCKID and
  a.YarnCountID=c.YarnCountID  and
  a.YarnTypeID=d.YarnTypeID  and
  b.YARNREQUISITIONTYPEID=e.YARNREQUISITIONTYPEID and
  a.PUNITOFMEASID=f.UNITOFMEASID And
  b.SubconId=j.SubconId And
  a.orderno=k.orderno and
  k.clientid=l.clientid and
  e.YARNREQUISITIONTYPEID=3 and
  a.STOCKID=pKnitStockID;
 /* For REPORT CLIENT WISE */
  elsif pQueryType=4 then
  OPEN data_cursor  FOR
  select YarnCount,YARNREQUISITIONTYPE, YarnType,a.Quantity,a.Squantity,
  f.UNITOFMEAS as PUOM,f.UNITOFMEAS as SUOM,YARNBATCHNO,a.DYEDLOTNO,a.SHADE,
  a.Remarks,b.STOCKID,b.ReferenceNo,b.ReferenceDate,b.StockTransNO,
  b.StockTransDATE,b.SupplierInvoiceNo,
  b.SupplierInvoiceDate,j.SubConName,l.clientname,a.orderno,getfncWOBType(a.orderno) as workorder,k.GARMENTSORDERREF,m.shadegroupName
  from T_yarnrequisitionItems a,T_yarnrequisition b,T_YarnCount c ,
  T_YarnType d,T_YARNREQUISITIONTYPE e,t_UnitOfMeas f,
  T_Subcontractors j,T_Workorder k,t_client l,t_shadegroup m
  where a.STOCKID=b.STOCKID and
  a.YarnCountID=c.YarnCountID  and
  a.YarnTypeID=d.YarnTypeID  and
  a.shadegroupid=m.shadegroupid and 
  b.YARNREQUISITIONTYPEID=e.YARNREQUISITIONTYPEID and
  a.PUNITOFMEASID=f.UNITOFMEASID And
  b.SubconId=j.SubconId And
  a.orderno=k.orderno and
  k.clientid=l.clientid and
  e.YARNREQUISITIONTYPEID=4 and
  a.STOCKID=pKnitStockID;
 /* For REPORT CLIENT WISE */
  elsif pQueryType=5 then
  OPEN data_cursor  FOR
  select YarnCount,YARNREQUISITIONTYPE, YarnType,a.Quantity,a.Squantity,
  f.UNITOFMEAS as PUOM,f.UNITOFMEAS as SUOM,YARNBATCHNO,a.DYEDLOTNO,a.SHADE,
  a.Remarks,b.STOCKID,b.ReferenceNo,b.ReferenceDate,b.StockTransNO,
  b.StockTransDATE,b.SupplierInvoiceNo,
  b.SupplierInvoiceDate,j.SubConName,l.clientname,a.orderno,getfncWOBType(a.orderno) as workorder,k.GARMENTSORDERREF,m.shadegroupname
  from T_yarnrequisitionItems a,T_yarnrequisition b,T_YarnCount c ,
  T_YarnType d,T_YARNREQUISITIONTYPE e,t_UnitOfMeas f,
  T_Subcontractors j,T_Workorder k,t_client l,t_shadegroup m
  where a.STOCKID=b.STOCKID and
  a.YarnCountID=c.YarnCountID  and
  a.YarnTypeID=d.YarnTypeID  and
  a.shadegroupid=m.shadegroupid and 
  b.YARNREQUISITIONTYPEID=e.YARNREQUISITIONTYPEID and
  a.PUNITOFMEASID=f.UNITOFMEASID And
  b.SubconId=j.SubconId And
  a.orderno=k.orderno and
  k.clientid=l.clientid and
  e.YARNREQUISITIONTYPEID=5 and
  a.STOCKID=pKnitStockID;
 /* For REPORT CLIENT WISE */
  elsif pQueryType=6 then
  OPEN data_cursor  FOR
  select YarnCount,YARNREQUISITIONTYPE, YarnType,a.Quantity,a.Squantity,
  f.UNITOFMEAS as PUOM,f.UNITOFMEAS as SUOM,YARNBATCHNO,a.DYEDLOTNO,a.SHADE,
  a.Remarks,b.STOCKID,b.ReferenceNo,b.ReferenceDate,b.StockTransNO,
  b.StockTransDATE,b.SupplierInvoiceNo,
  b.SupplierInvoiceDate,j.SubConName,l.clientname,a.orderno,getfncWOBType(a.orderno) as workorder,k.GARMENTSORDERREF,m.shadegroupName
  from T_yarnrequisitionItems a,T_yarnrequisition b,T_YarnCount c ,
  T_YarnType d,T_YARNREQUISITIONTYPE e,t_UnitOfMeas f,
  T_Subcontractors j,T_Workorder k,t_client l,t_shadegroup m
  where a.STOCKID=b.STOCKID and
  a.YarnCountID=c.YarnCountID  and
  a.YarnTypeID=d.YarnTypeID  and
 a.shadegroupid=m.shadegroupid and 
  b.YARNREQUISITIONTYPEID=e.YARNREQUISITIONTYPEID and
  a.PUNITOFMEASID=f.UNITOFMEASID And
  b.SubconId=j.SubconId And
  a.orderno=k.orderno and
  k.clientid=l.clientid and
  e.YARNREQUISITIONTYPEID=6 and
  a.STOCKID=pKnitStockID;
 /* For REPORT CLIENT WISE */

  elsif pQueryType=7 then
  OPEN data_cursor  FOR
  select YarnCount,YARNREQUISITIONTYPE, YarnType,a.Quantity,a.Squantity,
  f.UNITOFMEAS as PUOM,f.UNITOFMEAS as SUOM,YARNBATCHNO,a.DYEDLOTNO,a.SHADE,
  a.Remarks,b.STOCKID,b.ReferenceNo,b.ReferenceDate,b.StockTransNO,
  b.StockTransDATE,b.SupplierInvoiceNo,m.shadegroupName,
  b.SupplierInvoiceDate,j.SubConName,l.clientname,a.orderno,getfncWOBType(a.orderno) as workorder,k.GARMENTSORDERREF
  from T_yarnrequisitionItems a,T_yarnrequisition b,T_YarnCount c ,
  T_YarnType d,T_YARNREQUISITIONTYPE e,t_UnitOfMeas f,
  T_Subcontractors j,T_Workorder k,t_client l,t_shadegroup m
  where a.STOCKID=b.STOCKID and
  a.shadegroupid=m.shadegroupid and 
  a.YarnCountID=c.YarnCountID  and
  a.YarnTypeID=d.YarnTypeID  and
  b.YARNREQUISITIONTYPEID=e.YARNREQUISITIONTYPEID and
  a.PUNITOFMEASID=f.UNITOFMEASID And
  b.SubconId=j.SubconId And
  a.orderno=k.orderno and
  k.clientid=l.clientid and
  e.YARNREQUISITIONTYPEID=7 and
  a.STOCKID=pKnitStockID;
  end if;
End GetReportGrayYarnRequisition;
/


PROMPT CREATE OR REPLACE Procedure  27 :: GetReportIssueToFloor
CREATE OR REPLACE Procedure GetReportIssueToFloor 
(
   data_cursor IN OUT pReturnData.c_Records,
   pKnitStockID IN NUMBER
)
As
Begin
  OPEN data_cursor  FOR
  select YarnCount, YarnType,a.Quantity,a.Squantity,
  f.UNITOFMEAS as PUOM,g.UNITOFMEAS as SUOM,YARNBATCHNO,a.SHADE,
  a.Remarks,b.STOCKID,b.ReferenceNo,b.ReferenceDate,b.StockTransNO,
  b.StockTransDATE,E.SUPPLIERNAME,E.SADDRESS,b.SupplierInvoiceNo,
  b.SupplierInvoiceDate,j.SubConName,h.orderNo,getfncWOBType(h.orderno) as workorder,a.REQUISITIONNO,
  j.SUBCONTACTPERSON,j.SUBADDRESS
from T_KnitStockItems a,T_KnitStock b,T_YarnCount c ,
  T_YarnType d,T_SUPPLIER E,t_UnitOfMeas f,t_UnitOfMeas g,
  t_WorkOrder h, T_Subcontractors j
  where a.STOCKID=b.STOCKID and
  a.supplierId=e.supplierID(+) and
  a.YarnCountID=c.YarnCountID(+)  and
  a.YarnTypeID=d.YarnTypeID(+)  and
  a.PUNITOFMEASID=f.UNITOFMEASID(+) And
  a.SUNITOFMEASID=g.UNITOFMEASID(+) And
  a.orderNo=h.OrderNo And
  b.SubconId=j.SubconId And
  a.STOCKID=pKnitStockID;
End GetReportIssueToFloor;
/




PROMPT CREATE OR REPLACE Procedure  28 :: GetKnitYarnStockDetailsReport
CREATE OR REPLACE Procedure GetKnitYarnStockDetailsReport(
  data_cursor IN OUT pReturnData.c_Records,
  pOrderNo NUMBER
)
AS
BEGIN
open data_cursor for
select b.PID,a.STOCKTRANSDATE,a.STOCKTRANSNO,b.YARNBATCHNO,b.OrderNo,getfncWOBType(b.orderno) as workorder,
decode(e.GARMENTSORDERREF,NULL,'','FG-'||e.GARMENTSORDERREF)as gorder,
getfncyarncount(b.YARNCOUNTID)||'-'
||getfncyarntype(B.YARNTYPEID) AS YARNDESCRIPTION,
getfncClient(e.clientID) as ClientName,b.shade,
getfncSubConName(a.subconid) as SubContractors,

/* YARN DYEING PROCESS [YARN ISSUE FOR YARN DYEING]*/
 decode (a.KNTITRANSACTIONTYPEID,5,b.Quantity,0)as YARN_ISSUE_DYEING_AYDL,
 decode (a.KNTITRANSACTIONTYPEID,12,b.Quantity,0)as YARN_ISSUE_DYEING_OTHERS,
 decode (a.KNTITRANSACTIONTYPEID,5,b.Quantity,0)+
 decode (a.KNTITRANSACTIONTYPEID,12,b.Quantity,0) as YARN_ISSUE_DYEING_TOTAL,

 /* YARN DYEING PROCESS [YARN RECEIVE FROM YARN DYEING]*/

 decode (a.KNTITRANSACTIONTYPEID,8,b.Quantity,0)as YARN_RECEIVE_DYEING_AYDL,
 decode (a.KNTITRANSACTIONTYPEID,13,b.Quantity,0)as YARN_RECEIVE_DYEING_OTHER,
 decode (a.KNTITRANSACTIONTYPEID,8,b.Quantity,0)+
 decode (a.KNTITRANSACTIONTYPEID,13,b.Quantity,0)
AS YARN_RECEIVE_DYEING_TOTAL,

/* Knit Yarn Transfer One to Another */
 decode(a.KNTITRANSACTIONTYPEID,111,b.Quantity) as DY_TRANSFER_FROM,
 decode(a.KNTITRANSACTIONTYPEID,112,b.Quantity) as DY_TRANSFER_TO,

 decode(a.KNTITRANSACTIONTYPEID,111,b.Quantity,112,-b.Quantity,0) as DY_TRANSFER_TOTAL,

/* KNITTING PROCESS [YANR ISSIED FOR KNITTING]*/
 decode (a.KNTITRANSACTIONTYPEID,3,b.Quantity,0)as YARN_Issue_FOR_KNITTING,
 decode (a.KNTITRANSACTIONTYPEID,4,b.Quantity,0)as YARN_Issue_FOR_OTHERS,
 decode (a.KNTITRANSACTIONTYPEID,3,b.Quantity,0) + 
 decode (a.KNTITRANSACTIONTYPEID,4,b.Quantity,0)AS YARN_ISSUE_KNITTING_TOTAL,

/* KNITTING PROCESS [YANR RETURN FROM KNITTING ]*/
 decode (a.KNTITRANSACTIONTYPEID,9,b.Quantity,0)as RETURN_FROM_KNITTING_FLOOR,
 decode (a.KNTITRANSACTIONTYPEID,10,b.Quantity,0)as RETURN_FROM_KNITTING_OTHERS,
 decode (a.KNTITRANSACTIONTYPEID,9,b.Quantity,0) +
 decode (a.KNTITRANSACTIONTYPEID,10,b.Quantity,0)AS RETURN_KNITTING_TOTAL,

/* Knit Yarn Transfer One to Another */
 decode(a.KNTITRANSACTIONTYPEID,101,b.Quantity) as TRANSFER_FROM,
 decode(a.KNTITRANSACTIONTYPEID,102,b.Quantity) as TRANSFER_TO,

 decode(a.KNTITRANSACTIONTYPEID,101,b.Quantity,102,-b.Quantity) as TRANSFER_TOTAL,


/* KNITTING PROCESS [TOTAL NET YARN ISSUD FOR KNITTING ]*/
 decode (a.KNTITRANSACTIONTYPEID,3,b.Quantity,0)-
 decode (a.KNTITRANSACTIONTYPEID,9,b.Quantity,0)+
 decode(a.KNTITRANSACTIONTYPEID,101,b.Quantity,102,-b.Quantity,0) AS NET_YARN_FLOOR,

/* KNITTING PROCESS [TOTAL NET YARN ISSUD FOR OTHERS ]*/
 decode (a.KNTITRANSACTIONTYPEID,4,b.Quantity,0)-
 decode (a.KNTITRANSACTIONTYPEID,10,b.Quantity,0)AS NET_YARN_OTHERS,

/* KNITTING PROCESS [TOTAL NET YARN FLOOR AND OTHERS ]*/

 decode (a.KNTITRANSACTIONTYPEID,3,b.Quantity,0)-
 decode (a.KNTITRANSACTIONTYPEID,9,b.Quantity,0)+
 decode (a.KNTITRANSACTIONTYPEID,4,b.Quantity,0)-
 decode (a.KNTITRANSACTIONTYPEID,10,b.Quantity,0)+
 decode(a.KNTITRANSACTIONTYPEID,101,b.Quantity,102,-b.Quantity,0) AS NET_YARN_GRAND_TOTAL
 from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c,  t_workorder e
 where a.StockID=b.StockID and
 a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and a.KNTITRANSACTIONTYPEID in (3,4,5,8,9,10,12,13,101,102,111,112) and 
 b.orderno=e.orderno and
 b.OrderNo = pOrderNo
 order by STOCKTRANSDATE,a.KNTITRANSACTIONTYPEID,a.STOCKTRANSNO,b.YARNBATCHNO,b.OrderNo,e.GARMENTSORDERREF;

END GetKnitYarnStockDetailsReport;
/






PROMPT CREATE OR REPLACE Procedure  29 :: GetKnitYarnStockDetails
CREATE OR REPLACE Procedure GetKnitYarnStockDetails(
   data_cursor IN OUT pReturnData.c_Records,
   pQueryType IN NUMBER,
   pOrderNo IN NUMBER,
   pClient IN NUMBER DEFAULT NULL, 
   sDate IN VARCHAR2,
   eDate IN VARCHAR2
)
AS
  vSDate date;
  vEDate date;
BEGIN
  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  end if;

if pQueryType=118 then
/* Report for T118 Yarn Stock Details */
open data_cursor for
select b.PID,a.STOCKTRANSDATE,a.STOCKTRANSNO,b.YARNBATCHNO,b.OrderNo,getfncWOBType(b.orderno) as workorder,
decode(e.GARMENTSORDERREF,NULL,'','FG-'||e.GARMENTSORDERREF)as gorder,
getfncyarncount(b.YARNCOUNTID)||'-'
||getfncyarntype(B.YARNTYPEID) AS YARNDESCRIPTION,
getfncClient(e.clientID) as ClientName,b.shade,
getfncSubConName(a.subconid) as SubContractors,
/* YARN DYEING PROCESS [YARN ISSUE FOR YARN DYEING]*/
 (decode (a.KNTITRANSACTIONTYPEID,5,b.Quantity,0)) as YI_FLOOR,
 (decode (a.KNTITRANSACTIONTYPEID,12,b.Quantity,0)) as YI_OTHERS,
 (decode (a.KNTITRANSACTIONTYPEID,5,b.Quantity,0)+
 decode (a.KNTITRANSACTIONTYPEID,12,b.Quantity,0)) as YI_TOTAL,
/* YARN DYEING PROCESS [YARN RETURN FROM YARN DYEING]*/
 (decode (a.KNTITRANSACTIONTYPEID,11,b.Quantity,0)) as YRF_FLOOR,
 (decode (a.KNTITRANSACTIONTYPEID,14,b.Quantity,0)) as YRF_OTHERS,
 (decode (a.KNTITRANSACTIONTYPEID,11,b.Quantity,0)+
 decode (a.KNTITRANSACTIONTYPEID,14,b.Quantity,0)) as YR_TOTAL,
/* Knit Yarn Transfer One to Another */
 (decode(a.KNTITRANSACTIONTYPEID,151,b.Quantity,0)) as YT_FROM,
 (decode(a.KNTITRANSACTIONTYPEID,152,b.Quantity,0)) as YT_TO,
  (decode(a.KNTITRANSACTIONTYPEID,151,b.Quantity,0)-
     decode(a.KNTITRANSACTIONTYPEID,152,b.Quantity,0))  as YT_TOTAL,
 /* YARN DYEING PROCESS [YARN RECEIVED FROM YARN DYEING]*/
 (decode (a.KNTITRANSACTIONTYPEID,8,b.Quantity,0)) as YREC_FLOOR,
 (decode (a.KNTITRANSACTIONTYPEID,13,b.Quantity,0)) as YREC_OTHERS,
 (decode (a.KNTITRANSACTIONTYPEID,8,b.Quantity,0)+
 decode (a.KNTITRANSACTIONTYPEID,13,b.Quantity,0)) AS REC_TOTAL,
 /* KNITTING PROCESS [TOTAL NET YARN ISSUED FOR KNITTING ]*/
  (decode (a.KNTITRANSACTIONTYPEID,5,b.Quantity,0)-
  decode (a.KNTITRANSACTIONTYPEID,11,b.Quantity,0)+
  decode(a.KNTITRANSACTIONTYPEID,151,b.Quantity,0)-
  decode(a.KNTITRANSACTIONTYPEID,152,b.Quantity,0)-
  decode (a.KNTITRANSACTIONTYPEID,8,b.Quantity,0)) AS NET_YARN_FLOOR,
 /* KNITTING PROCESS [TOTAL NET YARN ISSUD FOR OTHERS ]*/
  (decode (a.KNTITRANSACTIONTYPEID,12,b.Quantity,0)-
  decode (a.KNTITRANSACTIONTYPEID,14,b.Quantity,0)-
  decode (a.KNTITRANSACTIONTYPEID,13,b.Quantity,0)) AS NET_YARN_OTHERS,
 /* KNITTING PROCESS [TOTAL NET YARN FLOOR AND OTHERS ]*/
  (decode (a.KNTITRANSACTIONTYPEID,5,b.Quantity,0)-
  decode (a.KNTITRANSACTIONTYPEID,11,b.Quantity,0)+
  decode(a.KNTITRANSACTIONTYPEID,151,b.Quantity,0)-
  decode(a.KNTITRANSACTIONTYPEID,152,b.Quantity,0)-
  decode (a.KNTITRANSACTIONTYPEID,8,b.Quantity,0)+
  decode (a.KNTITRANSACTIONTYPEID,12,b.Quantity,0)-
  decode (a.KNTITRANSACTIONTYPEID,14,b.Quantity,0)-
  decode (a.KNTITRANSACTIONTYPEID,13,b.Quantity,0)) AS NET_YARN_GRAND_TOTAL

 from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c,  t_workorder e,T_Client f
 where a.StockID=b.StockID and
 a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and a.KNTITRANSACTIONTYPEID in (5,8,11,12,13,14,151,152) and 
 b.orderno=e.orderno and e.ClientID=f.ClientID and (pOrderNo is null or b.OrderNo=pOrderNo) and
 (pClient is NULL or e.ClientID=pClient) and
 a.STOCKTRANSDATE between decode(vSDate,null,'01-jan-1900',vSDate) and vEDate
 Order by a.STOCKTRANSDATE,b.OrderNo;

elsif pQueryType=119 then
/* Report for T119 Yarn Stock Details */
open data_cursor for
select b.PID,a.STOCKTRANSDATE,a.STOCKTRANSNO,b.YARNBATCHNO,b.OrderNo,getfncWOBType(b.orderno) as workorder,
decode(e.GARMENTSORDERREF,NULL,'','FG-'||e.GARMENTSORDERREF)as gorder,
getfncyarncount(b.YARNCOUNTID)||'-'
||getfncyarntype(B.YARNTYPEID) AS YARNDESCRIPTION,
getfncClient(e.clientID) as ClientName,b.shade,
getfncSubConName(a.subconid) as SubContractors,
/* YARN DYEING PROCESS [YARN ISSUE FOR YARN DYEING]*/
 (decode (a.KNTITRANSACTIONTYPEID,3,b.Quantity,0)) as YI_FLOOR,
 (decode (a.KNTITRANSACTIONTYPEID,4,b.Quantity,0)) as YI_OTHERS,
 (decode (a.KNTITRANSACTIONTYPEID,3,b.Quantity,0)+
 decode (a.KNTITRANSACTIONTYPEID,4,b.Quantity,0)) as YI_TOTAL,
/* YARN DYEING PROCESS [YARN RETURN FROM YARN DYEING]*/
 (decode (a.KNTITRANSACTIONTYPEID,9,b.Quantity,0)) as YRF_FLOOR,
 (decode (a.KNTITRANSACTIONTYPEID,10,b.Quantity,0)) as YRF_OTHERS,
 (decode (a.KNTITRANSACTIONTYPEID,9,b.Quantity,0)+
 decode (a.KNTITRANSACTIONTYPEID,10,b.Quantity,0)) as YR_TOTAL,
/* Knit Yarn Transfer One to Another */
 (decode(a.KNTITRANSACTIONTYPEID,101,b.Quantity,0)) as YT_FROM,
 (decode(a.KNTITRANSACTIONTYPEID,102,b.Quantity,0)) as YT_TO,
  (decode(a.KNTITRANSACTIONTYPEID,101,b.Quantity,0)-
   decode(a.KNTITRANSACTIONTYPEID,102,b.Quantity,0)) as YT_TOTAL,
 /* YARN DYEING PROCESS [YARN RECEIVED FROM YARN DYEING]*/
 (decode (a.KNTITRANSACTIONTYPEID,6,b.Quantity,0)) as YREC_FLOOR,
 (decode (a.KNTITRANSACTIONTYPEID,7,b.Quantity,0)) as YREC_OTHERS,
 (decode (a.KNTITRANSACTIONTYPEID,6,b.Quantity,0)+
 decode (a.KNTITRANSACTIONTYPEID,7,b.Quantity,0)) AS REC_TOTAL,
 /* KNITTING PROCESS [TOTAL NET YARN ISSUD FOR KNITTING ]*/
  (decode (a.KNTITRANSACTIONTYPEID,3,b.Quantity,0)-
     decode (a.KNTITRANSACTIONTYPEID,9,b.Quantity,0)+
     decode (a.KNTITRANSACTIONTYPEID,101,b.Quantity,0)-
     decode (a.KNTITRANSACTIONTYPEID,102,b.Quantity,0)-
     decode (a.KNTITRANSACTIONTYPEID,6,b.Quantity,0)) AS NET_YARN_FLOOR,
 /* KNITTING PROCESS [TOTAL NET YARN ISSUD FOR OTHERS ]*/
  (decode (a.KNTITRANSACTIONTYPEID,4,b.Quantity,0)-
     decode (a.KNTITRANSACTIONTYPEID,10,b.Quantity,0)-
     decode (a.KNTITRANSACTIONTYPEID,7,b.Quantity,0)) AS NET_YARN_OTHERS,
 /* KNITTING PROCESS [TOTAL NET YARN FLOOR AND OTHERS ]*/
 (decode (a.KNTITRANSACTIONTYPEID,3,b.Quantity,0)-
     decode (a.KNTITRANSACTIONTYPEID,9,b.Quantity,0)+
     decode (a.KNTITRANSACTIONTYPEID,101,b.Quantity,0)-
     decode (a.KNTITRANSACTIONTYPEID,102,b.Quantity,0)-
     decode (a.KNTITRANSACTIONTYPEID,6,b.Quantity,0)+
     decode (a.KNTITRANSACTIONTYPEID,4,b.Quantity,0)-
     decode (a.KNTITRANSACTIONTYPEID,10,b.Quantity,0)-
     decode (a.KNTITRANSACTIONTYPEID,7,b.Quantity,0)) AS NET_YARN_GRAND_TOTAL

 from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c,  t_workorder e,T_Client f
 where a.StockID=b.StockID and
 a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and a.KNTITRANSACTIONTYPEID in (3,4,6,7,9,10,101,102) and 
 b.orderno=e.orderno and e.ClientID=f.ClientID and (pOrderNo is null or b.OrderNo=pOrderNo) and
 (pClient is NULL or e.ClientID=pClient) and
 a.STOCKTRANSDATE between decode(vSDate,null,'01-jan-1900',vSDate) and vEDate
 Order by a.STOCKTRANSDATE,b.OrderNo;

elsif pQueryType=120 then
/* Report for T120 Yarn Stock Details */
open data_cursor for
select b.PID,a.STOCKTRANSDATE,a.STOCKTRANSNO,b.YARNBATCHNO,b.OrderNo,getfncWOBType(b.orderno) as workorder,
decode(e.GARMENTSORDERREF,NULL,'','FG-'||e.GARMENTSORDERREF)as gorder,
getfncyarncount(b.YARNCOUNTID)||'-'
||getfncyarntype(B.YARNTYPEID) AS YARNDESCRIPTION,
getfncClient(e.clientID) as ClientName,b.shade,
getfncSubConName(a.subconid) as SubContractors,
/* YARN DYEING PROCESS [YARN ISSUE FOR YARN DYEING]*/
 (decode (a.KNTITRANSACTIONTYPEID,22,b.Quantity,0)) as YI_FLOOR,
 (decode (a.KNTITRANSACTIONTYPEID,23,b.Quantity,0)) as YI_OTHERS,
 (decode (a.KNTITRANSACTIONTYPEID,22,b.Quantity,0)+
 decode (a.KNTITRANSACTIONTYPEID,23,b.Quantity,0)) as YI_TOTAL,
/* YARN DYEING PROCESS [YARN RETURN FROM YARN DYEING]*/
 (decode (a.KNTITRANSACTIONTYPEID,26,b.Quantity,0)) as YRF_FLOOR,
 (decode (a.KNTITRANSACTIONTYPEID,27,b.Quantity,0)) as YRF_OTHERS,
 (decode (a.KNTITRANSACTIONTYPEID,26,b.Quantity,0)+
 decode (a.KNTITRANSACTIONTYPEID,27,b.Quantity,0)) as YR_TOTAL,
/* Knit Yarn Transfer One to Another */
 (decode(a.KNTITRANSACTIONTYPEID,131,b.Quantity,0)) as YT_FROM,
 (decode(a.KNTITRANSACTIONTYPEID,132,b.Quantity,0)) as YT_TO,
  (decode(a.KNTITRANSACTIONTYPEID,131,b.Quantity,0)-
   decode(a.KNTITRANSACTIONTYPEID,132,b.Quantity,0)) as YT_TOTAL,
 /* YARN DYEING PROCESS [YARN RECEIVED FROM YARN DYEING]*/
 (decode (a.KNTITRANSACTIONTYPEID,24,b.Quantity,0)) as YREC_FLOOR,
 (decode (a.KNTITRANSACTIONTYPEID,25,b.Quantity,0)) as YREC_OTHERS,
 (decode (a.KNTITRANSACTIONTYPEID,24,b.Quantity,0)+
 decode (a.KNTITRANSACTIONTYPEID,25,b.Quantity,0)) AS REC_TOTAL,
 /* KNITTING PROCESS [TOTAL NET YARN ISSUD FOR KNITTING ]*/
  (decode(a.KNTITRANSACTIONTYPEID,22,b.Quantity,0)-
     decode(a.KNTITRANSACTIONTYPEID,26,b.Quantity,0)+
     decode(a.KNTITRANSACTIONTYPEID,131,b.Quantity,0)-
     decode(a.KNTITRANSACTIONTYPEID,132,b.Quantity,0)-
     decode(a.KNTITRANSACTIONTYPEID,24,b.Quantity,0)) AS NET_YARN_FLOOR,
 /* KNITTING PROCESS [TOTAL NET YARN ISSUD FOR OTHERS ]*/
  (decode(a.KNTITRANSACTIONTYPEID,23,b.Quantity,0)-
    decode(a.KNTITRANSACTIONTYPEID,27,b.Quantity,0)-
    decode(a.KNTITRANSACTIONTYPEID,25,b.Quantity,0)) AS NET_YARN_OTHERS,
 /* KNITTING PROCESS [TOTAL NET YARN FLOOR AND OTHERS ]*/
 (decode(a.KNTITRANSACTIONTYPEID,22,b.Quantity,0)-
     decode(a.KNTITRANSACTIONTYPEID,26,b.Quantity,0)+
     decode(a.KNTITRANSACTIONTYPEID,131,b.Quantity,0)-
     decode(a.KNTITRANSACTIONTYPEID,132,b.Quantity,0)-
     decode(a.KNTITRANSACTIONTYPEID,24,b.Quantity,0)+
     decode(a.KNTITRANSACTIONTYPEID,23,b.Quantity,0)-
     decode(a.KNTITRANSACTIONTYPEID,27,b.Quantity,0)-
     decode(a.KNTITRANSACTIONTYPEID,25,b.Quantity,0)) AS NET_YARN_GRAND_TOTAL

 from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c,  t_workorder e,T_Client f
 where a.StockID=b.StockID and
 a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and a.KNTITRANSACTIONTYPEID in (22,23,24,25,26,27,131,132) and 
 b.orderno=e.orderno and e.ClientID=f.ClientID and (pOrderNo is null or b.OrderNo=pOrderNo) and
 (pClient is NULL or e.ClientID=pClient) and
 a.STOCKTRANSDATE between decode(vSDate,null,'01-jan-1900',vSDate) and vEDate
 Order by a.STOCKTRANSDATE,b.OrderNo;


end if;
END GetKnitYarnStockDetails;
/




PROMPT CREATE OR REPLACE Procedure  30 :: GetReportWorkOrderClientWise
CREATE OR REPLACE Procedure GetReportWorkOrderClientWise
(
  data_cursor IN OUT pReturnData.c_Records
)
AS
BEGIN

OPEN data_cursor for
select a.orderno,getfncWOBType(a.orderno) as workorder,sum(b.QUANTITY),a.orderref,c.clientname as ClientName,c.CCONTACTPERSON,
d.salesterm as SalesTerm,a.ContactPerson,i.employeename,
a.OrderDate,a.clientsref,h.CurrencyName,
a.DELIVERYPLACE,a.ORDERREMARKS,j.ORDERSTATUS,
getFncbasicWorkOrder(a.orderno)  as BasicWorkOrder,a.wcancelled,
a.wrevised,a.GARMENTSORDERREF,total.tot,(a.conrate*total.tot) as amnTK
from 
(select a.orderno,sum(quantity*rate)as tot from t_workorder a,t_orderitems b
where a.orderno=b.orderno group by a.orderno ) total,
t_workOrder a,t_orderItems b ,t_client c,t_salesterm d,
t_Currency h,T_Employee i,T_Orderstatus j
where a.orderno =b.orderNo and
c.clientid=a.clientid and
a.SALESPERSONID=i.employeeid and
d.salestermid=a.salestermid and
total.orderno=a.orderno and
j.orderstatusid=a.ORDERSTATUSID and
a.CURRENCYID=h.CURRENCYID
group by a.orderno,a.orderref,c.clientname,c.CCONTACTPERSON,
d.salesterm,a.ContactPerson,i.employeename,
a.OrderDate,a.clientsref,h.CurrencyName,
a.DELIVERYPLACE,
a.ORDERREMARKS,a.wcancelled,
a.wrevised,a.GARMENTSORDERREF,total.tot,a.conrate*total.tot,j.ORDERSTATUS;

END GetReportWorkOrderClientWise;
/


--------------------------------------------
--SP For Aux Stock Report
--------------------------------------------


PROMPT CREATE OR REPLACE Procedure  31 :: GetReportAuxStockPosition
CREATE OR REPLACE PROCEDURE GetReportAuxStockPosition(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pAuxTypeID NUMBER,
  sDate IN VARCHAR2,
  eDate IN VARCHAR2
)
AS
  vSDate date;
  vEDate date;
BEGIN
  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  else
   vSDate := TO_DATE('01/01/1900', 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  else
   vEDate := TO_DATE('01/01/2100', 'DD/MM/YYYY');
  end if; 
if pQueryType=0 then
/* Report for DC */
  OPEN data_cursor  FOR
    Select b.AuxID,g.AuxTypeID,g.AuxType,e.DyeBase, AuxName,nvl(WAVGPRICE,0) as wPrice,
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
    StockDate<=vEDate and
    b.AuxTypeID = pAuxTypeID
    group by b.AuxID,g.AuxTypeID,g.AuxType,e.DyeBase, AuxName,nvl(WAVGPRICE,0),UnitOfMeas
    order by DyeBase, AuxName;
elsif pQueryType=1 then
/* Report for DC */
    OPEN data_cursor  FOR
    Select a.STOCKINVOICENO,a.STOCKDATE,b.AuxTypeid,g.AuxType,e.DyeBase, d.Auxid,AuxName,(StockQty) MainIn,0 AS IssueSub,0 AS IssueBank,
    0 AS Bank2MainIn,0 as AdjustOut,0 as AdjustIn,0 AS LOAN2PARTY,0 AS LOANRFPARTY,0 as LOANFROMPARTY,0 AS LOANR2PARTY
    from T_AuxStock a, T_AuxStockItem b, T_AuxStockTypeDetails c, T_Auxiliaries d,
    T_DyeBase e, T_UnitOfMeas f, T_AuxType g
    where a.AuxStockID=b.AuxStockID and
    a.AuxStockTypeID=c.AuxStockTypeID and
    d.AuxTypeID = g.AuxTypeID and
    B.AUXTYPEID=C.AUXTYPEID AND
    b.AuxID=d.AuxID and
    d.DyeBaseID= e.DyeBaseID (+) and
    d.UnitOfMeasID=f.UnitOfMeasID and
    d.AuxTypeID=g.AuxTypeID and
	StockDate between vSDate and vEDate  and
    a.AUXSTOCKTYPEID = 1
UNION ALL
	Select b.STOCKINVOICENO,b.STOCKDATE,a.AuxTypeid,F.AuxType,e.DyeBase, c.Auxid,AuxName,0 as MainIn,(StockQty) IssueSub,0 AS IssueBank,
    0 AS Bank2MainIn,0 as AdjustOut,0 as AdjustIn,0 AS LOAN2PARTY,0 AS LOANRFPARTY,0 as LOANFROMPARTY,0 AS LOANR2PARTY
	from t_auxstockitem a,t_auxstock b, T_Auxiliaries c ,
	T_UnitOfMeas D,T_DyeBase e,T_AuxType f
	where a.AUXSTOCKID=b. AUXSTOCKID and
	a.AUXTYPEID=c.AUXTYPEID  and
	a.AUXTYPEID=f.AUXTYPEID  and
	a.AUXID=c.AUXID And
	e.DYEBASEID(+)=c.DYEBASEID and
	c.UnitOfMeasId=d.UnitOfMeasId And
	StockDate between vSDate and vEDate  and
	AUXSTOCKTYPEID=2
UNION ALL
	select b.STOCKINVOICENO,b.STOCKDATE,a.AuxTypeid,F.AuxType,e.DyeBase,c.Auxid,AuxName,0 as MainIn,0 AS IssueSub,(StockQty) IssueBank,
    0 AS Bank2MainIn,0 as AdjustOut,0 as AdjustIn,0 AS LOAN2PARTY,0 AS LOANRFPARTY,0 as LOANFROMPARTY,0 AS LOANR2PARTY
	from t_auxstockitem a,t_auxstock b, T_Auxiliaries c ,
	T_UnitOfMeas D,T_DyeBase e,T_AuxType f
	where a.AUXSTOCKID=b. AUXSTOCKID and
	a.AUXTYPEID=c.AUXTYPEID  and
	a.AUXTYPEID=f.AUXTYPEID  and
	a.AUXID=c.AUXID And
	e.DYEBASEID(+)=c.DYEBASEID and
	c.UnitOfMeasId=d.UnitOfMeasId And
	StockDate between vSDate and vEDate  and
	AUXSTOCKTYPEID=4
UNION ALL
	select b.STOCKINVOICENO,b.STOCKDATE,a.AuxTypeid,F.AuxType,e.DyeBase,c.Auxid,AuxName,0 as MainIn,0 AS IssueSub,0 as IssueBank,(StockQty) Bank2MainIn,
    0 as AdjustOut,0 as AdjustIn,0 AS LOAN2PARTY,0 AS LOANRFPARTY,0 as LOANFROMPARTY,0 AS LOANR2PARTY
	from t_auxstockitem a,t_auxstock b, T_Auxiliaries c ,
	T_UnitOfMeas D,T_DyeBase e,T_AuxType f
	where a.AUXSTOCKID=b. AUXSTOCKID and
	a.AUXTYPEID=c.AUXTYPEID  and
	a.AUXTYPEID=f.AUXTYPEID  and
	a.AUXID=c.AUXID And
	e.DYEBASEID(+)=c.DYEBASEID and
	c.UnitOfMeasId=d.UnitOfMeasId And
	StockDate between vSDate and vEDate  and
	AUXSTOCKTYPEID=5
UNION ALL
	select b.STOCKINVOICENO,b.STOCKDATE,a.AuxTypeid,F.AuxType,e.DyeBase,c.Auxid,AuxName,0 as MainIn,0 AS IssueSub,0 as IssueBank,0 as Bank2MainIn,
	(StockQty) AdjustOut,0 as AdjustIn,0 AS LOAN2PARTY,0 AS LOANRFPARTY,0 as LOANFROMPARTY,0 AS LOANR2PARTY
	from t_auxstockitem a,t_auxstock b, T_Auxiliaries c ,
	T_UnitOfMeas D,T_DyeBase e,T_AuxType f
	where a.AUXSTOCKID=b. AUXSTOCKID and
	a.AUXTYPEID=c.AUXTYPEID  and
	a.AUXTYPEID=f.AUXTYPEID  and
	a.AUXID=c.AUXID And
	e.DYEBASEID(+)=c.DYEBASEID and
	c.UnitOfMeasId=d.UnitOfMeasId And
	StockDate between vSDate and vEDate  and
	AUXSTOCKTYPEID=6
UNION ALL
	select b.STOCKINVOICENO,b.STOCKDATE,a.AuxTypeid,F.AuxType,e.DyeBase,c.Auxid,AuxName,0 as MainIn,0 AS IssueSub,0 as IssueBank,0 as Bank2MainIn,
    0 as AdjustOut,(StockQty) AdjustIn,0 AS LOAN2PARTY,0 AS LOANRFPARTY,0 as LOANFROMPARTY,0 AS LOANR2PARTY
	from t_auxstockitem a,t_auxstock b, T_Auxiliaries c ,
	T_UnitOfMeas D,T_DyeBase e,T_AuxType f
	where a.AUXSTOCKID=b. AUXSTOCKID and
	a.AUXTYPEID=c.AUXTYPEID  and
	a.AUXTYPEID=f.AUXTYPEID  and
	a.AUXID=c.AUXID And
	e.DYEBASEID(+)=c.DYEBASEID and
	c.UnitOfMeasId=d.UnitOfMeasId And
	StockDate between vSDate and vEDate  and
	AUXSTOCKTYPEID=11
UNION ALL
	select b.STOCKINVOICENO,b.STOCKDATE,a.AuxTypeid,F.AuxType,e.DyeBase,c.Auxid,AuxName,0 as MainIn,0 AS IssueSub,0 as IssueBank,0 as Bank2MainIn,
    0 as AdjustOut,0 AS AdjustIn,(StockQty) LOAN2PARTY,0 AS LOANRFPARTY,0 as LOANFROMPARTY,0 AS LOANR2PARTY
	from t_auxstockitem a,t_auxstock b, T_Auxiliaries c ,
	T_UnitOfMeas D,T_DyeBase e,T_AuxType f
	where a.AUXSTOCKID=b. AUXSTOCKID and
	a.AUXTYPEID=c.AUXTYPEID  and
	a.AUXTYPEID=f.AUXTYPEID  and
	a.AUXID=c.AUXID And
	e.DYEBASEID(+)=c.DYEBASEID and
	c.UnitOfMeasId=d.UnitOfMeasId And
	StockDate between vSDate and vEDate  and
	AUXSTOCKTYPEID=7
UNION ALL
	select b.STOCKINVOICENO,b.STOCKDATE,a.AuxTypeid,F.AuxType,e.DyeBase,c.Auxid,AuxName,0 as MainIn,0 AS IssueSub,0 as IssueBank,0 as Bank2MainIn,
    0 as AdjustOut,0 AS AdjustIn,0 AS LOAN2PARTY,(StockQty) LOANRFPARTY,0 as LOANFROMPARTY,0 AS LOANR2PARTY
	from t_auxstockitem a,t_auxstock b, T_Auxiliaries c ,
	T_UnitOfMeas D,T_DyeBase e,T_AuxType f
	where a.AUXSTOCKID=b. AUXSTOCKID and
	a.AUXTYPEID=c.AUXTYPEID  and
	a.AUXTYPEID=f.AUXTYPEID  and
	a.AUXID=c.AUXID And
	e.DYEBASEID(+)=c.DYEBASEID and
	c.UnitOfMeasId=d.UnitOfMeasId And
	StockDate between vSDate and vEDate  and
	AUXSTOCKTYPEID=8
UNION ALL
	select b.STOCKINVOICENO,b.STOCKDATE,a.AuxTypeid,F.AuxType,e.DyeBase,c.Auxid,AuxName,0 as MainIn,0 AS IssueSub,0 as IssueBank,0 as Bank2MainIn,
    0 as AdjustOut,0 AS AdjustIn,0 AS LOAN2PARTY,0 AS LOANRFPARTY,(StockQty) LOANFROMPARTY,0 AS LOANR2PARTY
	from t_auxstockitem a,t_auxstock b, T_Auxiliaries c ,
	T_UnitOfMeas D,T_DyeBase e,T_AuxType f
	where a.AUXSTOCKID=b. AUXSTOCKID and
	a.AUXTYPEID=c.AUXTYPEID  and
	a.AUXTYPEID=f.AUXTYPEID  and
	a.AUXID=c.AUXID And
	e.DYEBASEID(+)=c.DYEBASEID and
	c.UnitOfMeasId=d.UnitOfMeasId And
	StockDate between vSDate and vEDate  and
	AUXSTOCKTYPEID=9
UNION ALL
	select b.STOCKINVOICENO,b.STOCKDATE,a.AuxTypeid,F.AuxType,e.DyeBase,c.Auxid,AuxName,0 as MainIn,0 AS IssueSub,0 as IssueBank,0 as Bank2MainIn,
    0 as AdjustOut,0 AS AdjustIn,0 AS LOAN2PARTY,0 AS LOANRFPARTY,0 as LOANFROMPARTY,(StockQty) LOANR2PARTY
    from t_auxstockitem a,t_auxstock b, T_Auxiliaries c ,
	T_UnitOfMeas D,T_DyeBase e,T_AuxType f
	where a.AUXSTOCKID=b. AUXSTOCKID and
	a.AUXTYPEID=c.AUXTYPEID  and
	a.AUXTYPEID=f.AUXTYPEID  and
	a.AUXID=c.AUXID And
	e.DYEBASEID(+)=c.DYEBASEID and
	c.UnitOfMeasId=d.UnitOfMeasId And
	StockDate between vSDate and vEDate  and
	AUXSTOCKTYPEID=10;
elsif pQueryType=2 then
/* Report for DC */
  OPEN data_cursor  FOR
	select a.AUXSTOCKTYPEID,a.STOCKINVOICENO,a.STOCKDATE,b.AuxTypeid,G.AuxType,e.DyeBase,d.Auxid,AuxName,(StockQty) SubIn,0 AS Issue2Production
    from T_AuxStock a, T_AuxStockItem b, T_AuxStockTypeDetails c, T_Auxiliaries d,
    T_DyeBase e, T_UnitOfMeas f, T_AuxType g
    where a.AuxStockID=b.AuxStockID and
    a.AuxStockTypeID=c.AuxStockTypeID and
    d.AuxTypeID = g.AuxTypeID and
    B.AUXTYPEID=C.AUXTYPEID AND
    b.AuxID=d.AuxID and
    d.DyeBaseID= e.DyeBaseID (+) and
    d.UnitOfMeasID=f.UnitOfMeasID and
    d.AuxTypeID=g.AuxTypeID and
    StockDate between vSDate and vEDate and
    a.AUXSTOCKTYPEID = 2
UNION ALL
	select a.AUXSTOCKTYPEID,a.STOCKINVOICENO,a.STOCKDATE,b.AuxTypeid,G.AuxType,e.DyeBase,d.Auxid,AuxName,0 SubIn,(StockQty) Issue2Production
    from T_AuxStock a, T_AuxStockItem b, T_AuxStockTypeDetails c, T_Auxiliaries d,
    T_DyeBase e, T_UnitOfMeas f, T_AuxType g
    where a.AuxStockID=b.AuxStockID and
    a.AuxStockTypeID=c.AuxStockTypeID and
    d.AuxTypeID = g.AuxTypeID and
    B.AUXTYPEID=C.AUXTYPEID AND
    b.AuxID=d.AuxID and
    d.DyeBaseID= e.DyeBaseID (+) and
    d.UnitOfMeasID=f.UnitOfMeasID and
    d.AuxTypeID=g.AuxTypeID and
    StockDate between vSDate and vEDate and
    a.AUXSTOCKTYPEID = 3;
elsif pQueryType=3 then
/* Report for DC10 Consumsion Report */
	OPEN data_cursor  FOR
	Select b.AuxTypeid,g.AuxType,e.DyeBase, d.Auxid,AuxName,nvl(d.WAVGPRICE,0) as WAVGPRICE,
	(Select sum(decode(x.AUXSTOCKTYPEID,1,y.StockQty,2,-y.StockQty,4,-y.StockQty,5,y.StockQty,6,y.StockQty,7,-y.StockQty,8,y.StockQty,9,y.StockQty,10,-y.StockQty,11,y.StockQty,12,y.StockQty,13,-y.StockQty,0))
    from T_AuxStock x, T_AuxStockItem y
    where x.AuxStockID=y.AuxStockID and
    x.AuxStockTypeID in (1,2,4,5,6,7,8,9,10,11,12,13) and
    y.AuxID=d.AuxID and
	x.StockDate<=vEDate 
	Group By y.AuxID) as MainStore,	
	(Select sum(decode(x.AUXSTOCKTYPEID,2,y.StockQty,3,-y.StockQty,12,-y.StockQty,14,y.StockQty,0))
    from T_AuxStock x, T_AuxStockItem y
    where x.AuxStockID=y.AuxStockID and
    x.AuxStockTypeID in (2,3,12,14) and
    y.AuxID=d.AuxID and
	x.StockDate<=vEDate 
	Group By y.AuxID) as SubStore,	
	sum(decode(a.AUXSTOCKTYPEID,3,StockQty,0)) as Consumption
    from T_AuxStock a, T_AuxStockItem b, T_AuxStockTypeDetails c, T_Auxiliaries d,
    T_DyeBase e, T_UnitOfMeas f, T_AuxType g
    where a.AuxStockID=b.AuxStockID and
    a.AuxStockTypeID=c.AuxStockTypeID and
    d.AuxTypeID = g.AuxTypeID and
    B.AUXTYPEID=C.AUXTYPEID AND
	b.AuxTypeID = pAuxTypeID and
    b.AuxID=d.AuxID and
    d.DyeBaseID= e.DyeBaseID (+) and
    d.UnitOfMeasID=f.UnitOfMeasID and
    d.AuxTypeID=g.AuxTypeID and
	StockDate between vSDate and vEDate and
    a.AUXSTOCKTYPEID IN (1,2,3)
	Group By b.AuxTypeid,g.AuxType,e.DyeBase, d.Auxid,AuxName,d.WAVGPRICE
	Having sum(decode(a.AUXSTOCKTYPEID,3,StockQty,0))>0
	Order By e.DyeBase,AuxName;
end if;
END GetReportAuxStockPosition;


PROMPT CREATE OR REPLACE Procedure  32 :: GetReportAuxStockLoan
CREATE OR REPLACE PROCEDURE GetReportAuxStockLoan(
  data_cursor IN OUT pReturnData.c_Records,
  pAuxTypeID NUMBER,
  sDate IN VARCHAR2,
  eDate IN VARCHAR2
)
AS
  vSDate date;
  vEDate date;
BEGIN

  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  end if;


/* Report for SK51  Loan Partywise*/

  OPEN data_cursor  FOR
    select a.AuxStockTypeID,b.AuxID,g.AuxTypeID,g.AuxType,e.DyeBase,AuxName,StockDate,nvl(WAVGPRICE,0) as wPrice,UnitOfMeas,SUBCONNAME,SUBADDRESS,
    decode(a.AuxStockTypeID,7,(-StockQty*c.AuxStockMain),0) LoanToParty,
    decode(a.AuxStockTypeID,8,(StockQty*c.AuxStockMain),0) LoanRetFromParty,
    decode(a.AuxStockTypeID,9,(StockQty*c.AuxStockMain),0) LoanFromParty,
    decode(a.AuxStockTypeID,10,(-StockQty*c.AuxStockMain),0) LoanRetToParty
    from T_AuxStock a, T_AuxStockItem b, T_AuxStockTypeDetails c, T_Auxiliaries d, T_DyeBase e, T_UnitOfMeas f, T_AuxType g,T_SUBCONTRACTORS h
    where a.AuxStockID=b.AuxStockID and
    a.AuxStockTypeID=c.AuxStockTypeID and
    d.AuxTypeID = g.AuxTypeID and
    B.AUXTYPEID=C.AUXTYPEID AND
    b.AuxID=d.AuxID and
    d.DyeBaseID= e.DyeBaseID (+) and
    d.UnitOfMeasID=f.UnitOfMeasID and
    d.AuxTypeID=g.AuxTypeID and
    a.SUBCONID=h.SUBCONID and
    StockDate between decode(vSDate,null,'01-jan-1900',vSDate) and vEDate and
    (decode(a.AuxStockTypeID,7,(-StockQty*c.AuxStockMain),0)>0 or decode(a.AuxStockTypeID,8,(StockQty*c.AuxStockMain),0)>0 or
     decode(a.AuxStockTypeID,9,(StockQty*c.AuxStockMain),0)>0 or decode(a.AuxStockTypeID,10,(-StockQty*c.AuxStockMain),0)>0)
    order by SUBCONNAME,StockDate,a.AuxStockTypeID;

END GetReportAuxStockLoan;
/


PROMPT CREATE OR REPLACE Procedure  33 :: GetReportAuxStokAll
CREATE OR REPLACE Procedure GetReportAuxStokAll (
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  PAUXSTOCKID IN NUMBER
)
As

Begin
  if pQueryType=4 then
 	OPEN data_cursor  FOR
	/*Main Store to Bank*/
 	select a.AuxId,c.AuxName,f.AUXTYPE,UnitOfMeas,STOCKREQQTY,STOCKQTY,
 	DYEBASE,STOCKDATE,REMARKS,STOCKINVOICENO,AUXSTOCKTYPEID
 	from t_auxstockitem a,t_auxstock b, T_Auxiliaries c ,
 	T_UnitOfMeas D,T_DyeBase e,T_AuxType f
 	where a.AUXSTOCKID=b. AUXSTOCKID and
 	a.AUXTYPEID=c.AUXTYPEID  and
 	a.AUXTYPEID=f.AUXTYPEID  and
 	a.AUXID=c.AUXID And
 	e.DYEBASEID(+)=c.DYEBASEID and
 	c.UnitOfMeasId=d.UnitOfMeasId And
 	AUXSTOCKTYPEID=4 And
 	a.AUXSTOCKID=PAUXSTOCKID;

  elsif pQueryType=5 then

 	OPEN data_cursor  FOR
	/* Bank to Main Store */
 	select a.AuxId,c.AuxName,f.AUXTYPE,UnitOfMeas,STOCKREQQTY,STOCKQTY,
 	DYEBASE,STOCKDATE,REMARKS,STOCKINVOICENO,AUXSTOCKTYPEID,PURCHASEORDERNO,
    PURCHASEORDERDATE,SUPPLIERNAME,DELIVERYNOTE,DELIVERYNOTEDATE
 	from t_auxstockitem a,t_auxstock b, T_Auxiliaries c ,
 	T_UnitOfMeas D,T_DyeBase e,T_AuxType f,T_SUPPLIER g
 	where a.AUXSTOCKID=b. AUXSTOCKID and
 	a.AUXTYPEID=c.AUXTYPEID  and
 	a.AUXTYPEID=f.AUXTYPEID  and
 	a.AUXID=c.AUXID And
 	e.DYEBASEID(+)=c.DYEBASEID and
 	c.UnitOfMeasId=d.UnitOfMeasId And
 	AUXSTOCKTYPEID=5 And
	b.SUPPLIERID=g.SUPPLIERID and
 	a.AUXSTOCKID=PAUXSTOCKID;
  elsif pQueryType=6 then
 	OPEN data_cursor  FOR
	/* Adjustment- */
 	select a.AuxId,c.AuxName,f.AUXTYPE,UnitOfMeas,STOCKREQQTY,STOCKQTY,
 	DYEBASE,STOCKDATE,REMARKS,STOCKINVOICENO,AUXSTOCKTYPEID
 	from t_auxstockitem a,t_auxstock b, T_Auxiliaries c ,
 	T_UnitOfMeas D,T_DyeBase e,T_AuxType f
 	where a.AUXSTOCKID=b. AUXSTOCKID and
 	a.AUXTYPEID=c.AUXTYPEID  and
 	a.AUXTYPEID=f.AUXTYPEID  and
 	a.AUXID=c.AUXID And
 	e.DYEBASEID(+)=c.DYEBASEID and
 	c.UnitOfMeasId=d.UnitOfMeasId And
 	AUXSTOCKTYPEID=6 And
 	a.AUXSTOCKID=PAUXSTOCKID;

  elsif pQueryType=7 then

 	OPEN data_cursor  FOR
	/* Loan To Party */
 	 	select a.AuxId,c.AuxName,f.AUXTYPE,UnitOfMeas,STOCKREQQTY,STOCKQTY,
 	DYEBASE,STOCKDATE,REMARKS,STOCKINVOICENO,AUXSTOCKTYPEID,g.SUBCONNAME,g.SUBADDRESS
 	from t_auxstockitem a,t_auxstock b, T_Auxiliaries c ,
 	T_UnitOfMeas D,T_DyeBase e,T_AuxType f,T_SUBCONTRACTORS g
 	where a.AUXSTOCKID=b. AUXSTOCKID and
 	a.AUXTYPEID=c.AUXTYPEID  and
 	a.AUXTYPEID=f.AUXTYPEID  and
 	a.AUXID=c.AUXID And
 	e.DYEBASEID(+)=c.DYEBASEID and
 	c.UnitOfMeasId=d.UnitOfMeasId And
 	AUXSTOCKTYPEID=7 And
	b.SUBCONID=g.SUBCONID and
 	a.AUXSTOCKID=PAUXSTOCKID;
  elsif pQueryType=8 then
 	OPEN data_cursor  FOR
	/* Loan Return From Party */
 	 	select a.AuxId,c.AuxName,f.AUXTYPE,UnitOfMeas,STOCKREQQTY,STOCKQTY,
 	DYEBASE,STOCKDATE,REMARKS,STOCKINVOICENO,AUXSTOCKTYPEID,g.SUBCONNAME,g.SUBADDRESS
 	from t_auxstockitem a,t_auxstock b, T_Auxiliaries c ,
 	T_UnitOfMeas D,T_DyeBase e,T_AuxType f,T_SUBCONTRACTORS g
 	where a.AUXSTOCKID=b. AUXSTOCKID and
 	a.AUXTYPEID=c.AUXTYPEID  and
 	a.AUXTYPEID=f.AUXTYPEID  and
 	a.AUXID=c.AUXID And
 	e.DYEBASEID(+)=c.DYEBASEID and
 	c.UnitOfMeasId=d.UnitOfMeasId And
 	AUXSTOCKTYPEID=8 And
	b.SUBCONID=g.SUBCONID and
 	a.AUXSTOCKID=PAUXSTOCKID;

  elsif pQueryType=9 then

 	OPEN data_cursor  FOR
	/* Loan From Party k*/
 	 	select a.AuxId,c.AuxName,f.AUXTYPE,UnitOfMeas,STOCKREQQTY,STOCKQTY,
 	DYEBASE,STOCKDATE,REMARKS,STOCKINVOICENO,AUXSTOCKTYPEID,g.SUBCONNAME,g.SUBADDRESS
 	from t_auxstockitem a,t_auxstock b, T_Auxiliaries c ,
 	T_UnitOfMeas D,T_DyeBase e,T_AuxType f,T_SUBCONTRACTORS g
 	where a.AUXSTOCKID=b. AUXSTOCKID and
 	a.AUXTYPEID=c.AUXTYPEID  and
 	a.AUXTYPEID=f.AUXTYPEID  and
 	a.AUXID=c.AUXID And
 	e.DYEBASEID(+)=c.DYEBASEID and
 	c.UnitOfMeasId=d.UnitOfMeasId And
 	AUXSTOCKTYPEID=9 And
	b.SUBCONID=g.SUBCONID and
 	a.AUXSTOCKID=PAUXSTOCKID;
  elsif pQueryType=10 then
 	OPEN data_cursor  FOR
	/* Loan Return To Party */
 	 	select a.AuxId,c.AuxName,f.AUXTYPE,UnitOfMeas,STOCKREQQTY,STOCKQTY,
 	DYEBASE,STOCKDATE,REMARKS,STOCKINVOICENO,AUXSTOCKTYPEID,g.SUBCONNAME,g.SUBADDRESS
 	from t_auxstockitem a,t_auxstock b, T_Auxiliaries c ,
 	T_UnitOfMeas D,T_DyeBase e,T_AuxType f,T_SUBCONTRACTORS g
 	where a.AUXSTOCKID=b. AUXSTOCKID and
 	a.AUXTYPEID=c.AUXTYPEID  and
 	a.AUXTYPEID=f.AUXTYPEID  and
 	a.AUXID=c.AUXID And
 	e.DYEBASEID(+)=c.DYEBASEID and
 	c.UnitOfMeasId=d.UnitOfMeasId And
 	AUXSTOCKTYPEID=10 And
	b.SUBCONID=g.SUBCONID and
 	a.AUXSTOCKID=PAUXSTOCKID;

  elsif pQueryType=11 then

 	OPEN data_cursor  FOR
	/* Adjustment+ */
 	select a.AuxId,c.AuxName,f.AUXTYPE,UnitOfMeas,STOCKREQQTY,STOCKQTY,
 	DYEBASE,STOCKDATE,REMARKS,STOCKINVOICENO,AUXSTOCKTYPEID
 	from t_auxstockitem a,t_auxstock b, T_Auxiliaries c ,
 	T_UnitOfMeas D,T_DyeBase e,T_AuxType f
 	where a.AUXSTOCKID=b. AUXSTOCKID and
 	a.AUXTYPEID=c.AUXTYPEID  and
 	a.AUXTYPEID=f.AUXTYPEID  and
 	a.AUXID=c.AUXID And
 	e.DYEBASEID(+)=c.DYEBASEID and
 	c.UnitOfMeasId=d.UnitOfMeasId And
 	AUXSTOCKTYPEID=11 And
 	a.AUXSTOCKID=PAUXSTOCKID;
  elsif pQueryType=12 then

 	OPEN data_cursor  FOR
	/* Return From Substore */
 	select a.AuxId,c.AuxName,f.AUXTYPE,UnitOfMeas,STOCKREQQTY,STOCKQTY,
 	DYEBASE,STOCKDATE,REMARKS,STOCKINVOICENO,AUXSTOCKTYPEID
 	from t_auxstockitem a,t_auxstock b, T_Auxiliaries c ,
 	T_UnitOfMeas D,T_DyeBase e,T_AuxType f
 	where a.AUXSTOCKID=b. AUXSTOCKID and
 	a.AUXTYPEID=c.AUXTYPEID  and
 	a.AUXTYPEID=f.AUXTYPEID  and
 	a.AUXID=c.AUXID And
 	e.DYEBASEID(+)=c.DYEBASEID and
 	c.UnitOfMeasId=d.UnitOfMeasId And
 	AUXSTOCKTYPEID=12 And
 	a.AUXSTOCKID=PAUXSTOCKID;
  elsif pQueryType=13 then

 	OPEN data_cursor  FOR
	/* Sale To Party*/
 	select a.AuxId,c.AuxName,f.AUXTYPE,UnitOfMeas,STOCKREQQTY,STOCKQTY,
 	DYEBASE,STOCKDATE,REMARKS,STOCKINVOICENO,AUXSTOCKTYPEID,g.SUBCONID,g.SUBCONNAME,             
	g.SUBADDRESS,g.SUBFACTORYADDRESS,g.SUBTELEPHONE,SUPPLIERNAME,SADDRESS,a.UnitPrice          
 	from t_auxstockitem a,t_auxstock b, T_Auxiliaries c ,
 	T_UnitOfMeas D,T_DyeBase e,T_AuxType f,T_SUBCONTRACTORS g,T_SUPPLIER h
 	where a.AUXSTOCKID=b. AUXSTOCKID and
 	a.AUXTYPEID=c.AUXTYPEID  and
 	a.AUXTYPEID=f.AUXTYPEID  and
 	a.AUXID=c.AUXID And
	b.SUBCONID=g.SUBCONID(+) And
	b.SUPPLIERID=h.SUPPLIERID(+) AND 
 	e.DYEBASEID=c.DYEBASEID and
 	c.UnitOfMeasId=d.UnitOfMeasId(+) And
 	AUXSTOCKTYPEID=13 And
 	a.AUXSTOCKID=PAUXSTOCKID;
  elsif pQueryType=14 then

 	OPEN data_cursor  FOR
	/* AdjustmentSubStore+*/
 	select a.AuxId,c.AuxName,f.AUXTYPE,UnitOfMeas,STOCKREQQTY,STOCKQTY,
 	DYEBASE,STOCKDATE,REMARKS,STOCKINVOICENO,AUXSTOCKTYPEID
 	from t_auxstockitem a,t_auxstock b, T_Auxiliaries c ,
 	T_UnitOfMeas D,T_DyeBase e,T_AuxType f
 	where a.AUXSTOCKID=b. AUXSTOCKID and
 	a.AUXTYPEID=c.AUXTYPEID  and
 	a.AUXTYPEID=f.AUXTYPEID  and
 	a.AUXID=c.AUXID And
 	e.DYEBASEID(+)=c.DYEBASEID and
 	c.UnitOfMeasId=d.UnitOfMeasId And
 	AUXSTOCKTYPEID=14 And
 	a.AUXSTOCKID=PAUXSTOCKID;
  end if;
End GetReportAuxStokAll;
/


PROMPT CREATE OR REPLACE Procedure  34 :: GetDyedYarnReturnReport
CREATE OR REPLACE Procedure GetDyedYarnReturnReport
(
   data_cursor IN OUT pReturnData.c_Records,
   pKnitStockID IN NUMBER
)
As
Begin
 OPEN data_cursor  FOR
 select YarnCount,YarnType,a.Quantity,a.Squantity,
 f.UNITOFMEAS as PUOM,f.UNITOFMEAS as SUOM,YARNBATCHNO,a.SHADE,
 a.Remarks,b.STOCKID,b.ReferenceNo,b.ReferenceDate,b.StockTransNO,
 b.StockTransDATE,E.SUPPLIERNAME,E.SADDRESS,b.SupplierInvoiceNo,
 b.SupplierInvoiceDate,j.SubConName,h.orderNo,getfncWOBType(h.orderno) as workorder,DyedLotNo,k.clientname,m.shadegroupName,n.fabrictype
 from T_KnitStockItems a,T_KnitStock b,T_YarnCount c ,
 T_YarnType d,T_SUPPLIER E,t_UnitOfMeas f,
 t_WorkOrder h,T_Subcontractors j,t_client k, t_workorder l,t_shadegroup m,t_fabrictype n
 where a.STOCKID=b.STOCKID and
 a.shadegroupid=m.shadegroupid and 
  a.fabrictypeid=n.fabrictypeid and 
 a.supplierId=e.supplierID and
 a.YarnCountID=c.YarnCountID and
 a.YarnTypeID=d.YarnTypeID and
 a.PUNITOFMEASID=f.UNITOFMEASID And
 a.orderNo=h.OrderNo And
 b.SubconId=j.SubconId And
 l.clientid=k.clientid and
 l.orderno=a.orderno and
  a.STOCKID=pKnitStockID;
End GetDyedYarnReturnReport;
/


   
PROMPT CREATE OR REPLACE Procedure  35 :: getDY57DyelineDetails
CREATE OR REPLACE Procedure getDY57DyelineDetails (
 data_cursor IN OUT pReturnData.c_Records,
  pUDyelineId IN VARCHAR2
)
AS
BEGIN
 OPEN data_cursor FOR
 select a.DYELINEID,a.DBATCHID,h.BATCHNO,a.UDYELINEID,a.DYELINENO,a.DYELINEDATE,
  e.MACHINENAME,a.DLIQUOR,a.DWEIGHT,a.PACKAGECOUNT,a.DYEINGPROGRAM,a.DLIQUORRATIO,
  a.PRODDATE,a.DSTARTDATETIME,a.DENDDATETIME,a.FINISHEDWEIGHT,DSTARTDATETIME as DSTARTTIME,DENDDATETIME as DENDTIME,
  a.DYEINGSHIFT,a.DCOMMENTS,a.DPARENT,a.DRECOUNT,a.DCOMPLETE,a.DREDYEINGCOUNT,
  a.BPOSTEDTOSTOCK,b.HEADID,f.HEADNAME,b.HEADORDER,b.HEADCOMMENTS,c.DSUBITEMSID,
  c.AUXTYPEID,i.DyeBase,c.AUXID,g.AUXNAME,c.AUXQTY,d.UNITOFMEASID,d.UNITOFMEAS,
  c.AUXINCDECBY,c.AUXADDITION,c.AUXADDCOUNT,c.AUXTOTQTYPERC,c.AUXTOTQTYGM,a.EMPLOYEEID || EMPLOYEENAME as EMPNAME
        from T_DYELINE a,T_DSUBHEADS b,T_DSUBITEMS c,T_DUnitOfMeas d,T_DyeMachines e,
 T_DyelineHead f,T_Auxiliaries g,T_DBATCH h,T_DyeBase i,T_EMPLOYEE j
 where a.DYELINEID=b.DYELINEID and b.DYELINEID=c.DYELINEID and a.EMPLOYEEID=j.EMPLOYEEID and
 b.HEADID=c.HEADID and c.UNITOFMEASID=d.UNITOFMEASID and i.DyeBaseId (+)= g.DyeBaseId and
 a.MACHINEID=e.MACHINEID and f.HEADID=b.HEADID and c.AUXID=g.AUXID and
 a.DBATCHID=h.DBATCHID and a.UDYELINEID=pUDyelineId
 order by c.DSUBITEMSID asc;

END getDY57DyelineDetails;
/


PROMPT CREATE OR REPLACE Procedure  36 :: getDY57DyelineDetailsSub
CREATE OR REPLACE Procedure getDY57DyelineDetailsSub (
 data_cursor IN OUT pReturnData.c_Records,
  pBATCHNO IN VARCHAR2
)
AS
BEGIN
 OPEN data_cursor FOR
 select GetfncWOBType(b.OrderNo) as DOrderNo,a.DBATCHID,a.BATCHNO,a.BATCHDATE,b.ORDERLINEITEM,
 b.QUANTITY,b.SQUANTITY,b.PUNITOFMEASID,b.SUNITOFMEASID,b.SHADE,b.REMARKS,b.ORDERNO,d.CLIENTNAME,e.FABRICTYPE,
        g.KNITMCDIAGAUGE,g.FINISHEDGSM,g.WIDTH as FDIA,g.GRAYGSM,b.YARNBATCHNO,getFncYarnDes(b.ORDERLINEITEM) as YarnDesc
 from T_DBATCH a,T_DBATCHITEMS b,T_WorkOrder c,T_CLIENT d,T_FABRICTYPE e,T_ORDERITEMS g
 where a.DBATCHID=b.DBATCHID and  b.ORDERNO=c.ORDERNO and b.ORDERLINEITEM=g.ORDERLINEITEM and
 c.CLIENTID=d.CLIENTID and b.FABRICTYPEID=e.FABRICTYPEID and a.BATCHNO=pBATCHNO;

END getDY57DyelineDetailsSub;
/


------------------------------------------------------------- 
-- FINISHED FABRIC Reports: TD01ReportFFD
------------------------------------------------------------- 
PROMPT CREATE OR REPLACE Procedure  37 :: TD01ReportFFD
Create or Replace Procedure TD01ReportFFD
(
   data_cursor IN OUT pReturnData.c_Records,
   pKnitStockID IN NUMBER
)
As
Begin
  OPEN data_cursor  FOR
  select YarnCount,YarnType,a.Quantity,a.Squantity,
  f.UNITOFMEAS as PUOM,f.UNITOFMEAS as SUOM,YARNBATCHNO,a.SHADE,k.FABRICTYPE,
  a.Remarks,b.STOCKID,b.ReferenceNo,b.ReferenceDate,b.StockTransNO,
  b.StockTransDATE,b.SupplierInvoiceNo,
  b.SupplierInvoiceDate,j.SubConName,h.orderNo,getfncWOBType(h.orderno) as workorder,DyedLotNo,
  e.CLIENTNAME,e.CFACTORYADDRESS,e.CCONTACTPERSON,e.CTELEPHONE
  from T_KnitStockItems a,T_KnitStock b,T_YarnCount c ,
  T_YarnType d,T_Client e,t_UnitOfMeas f,t_WorkOrder h, T_Subcontractors j,T_FABRICTYPE k
  where a.STOCKID=b.STOCKID and
  a.YarnCountID=c.YarnCountID and
  a.YarnTypeID=d.YarnTypeID and
  a.PUNITOFMEASID=f.UNITOFMEASID And
  a.orderNo=h.OrderNo And
  h.CLIENTID=e.CLIENTID and
  b.SubconId=j.SubconId And
  a.FABRICTYPEID=k.FABRICTYPEID and
  a.STOCKID=pKnitStockID;
End TD01ReportFFD;
/




PROMPT CREATE OR REPLACE Procedure  38 :: T01ReportWorkOrder
CREATE OR REPLACE Procedure T01ReportWorkOrder(
  data_cursor IN OUT pReturnData.c_Records, 
  pQueryType IN NUMBER,
  pType IN VARCHAR2,
  pClient IN NUMBER DEFAULT NULL, 
  pORDERSTATUSID IN NUMBER  DEFAULT NULL, 
  pSDate IN VARCHAR2  DEFAULT NULL, 
  pEDate IN VARCHAR2  DEFAULT NULL, 
  pORDERNO IN NUMBER  DEFAULT NULL, 
  pEmployee IN VARCHAR2  DEFAULT NULL
) 
AS 
  vSDate date;
  vEDate date;
  vCRate NUMBER(12,4);
BEGIN 

  if not pSDate is null then
    vSDate := TO_DATE(pSDate, 'DD/MM/YYYY');
  end if;
  if not pEDate is null then
    vEDate := TO_DATE(pEDate, 'DD/MM/YYYY');
  end if;

  select CONRATE into vCRate from T_Currency where CurrencyId=2;
/*  For Report WOWISE */
  if pQueryType=2 then
  OPEN data_cursor for 
  SELECT a.BASICTYPEID,getfncWOBType(a.orderno) as Dworkorder, a.ORDERNO, a.ClientId,a.ContactPerson,
  a.ORDERDATE,e.SalesTerm,a.CurrencyId, a.ConRate, a.WCancelled, a.WRevised,a.CLIENTSREF,a.ORDERREMARKS,
  getFncbasicWorkOrder(a.ORDERNO)  as BasicWorkOrder,a.DELIVERYPLACE,a.GARMENTSORDERREF, 
  c.DESCRIPTION as OrderType,d.ClientName,f.CurrencyName, g.Employeename,
  h.ORDERSTATUS, 
  SUM(b.QUANTITY) SumOfWOQty, 
  SUM((b.QUANTITY*NVL(b.RATE,0))/decode(a.CurrencyId, 2, 1,vCRate)) SumOfWOAmt,
  SUM((b.QUANTITY*NVL(b.RATE,0))*a.ConRate) SumOfWOAmtTk
 	FROM T_WorkOrder a,T_OrderItems b ,t_OrderType c,t_client d,t_salesterm e,
	t_Currency f, T_Employee g,T_ORDERSTATUS h
        where a.ORDERNO =b.ORDERNO and
  	a.BASICTYPEID=c.ORDERCODE and
  	e.salestermid=a.salestermid and
  	a.CURRENCYID=f.CURRENCYID and
  	d.clientid=a.clientid and
	g.EmployeeId = a.SALESPERSONID and
        h.ORDERSTATUSID = a.ORDERSTATUSID and
	a.BASICTYPEID=pType and
	a.WCancelled=0 and
  	(pClient is NULL or a.ClientId=pClient) and
  	(pORDERSTATUSID is NULL or a.ORDERSTATUSID=pORDERSTATUSID) and
  	(pSDate is NULL or a.ORDERDATE>=vSDate) and
  	(pEDate is NULL or a.ORDERDATE<=vEDate) and
  	(pORDERNO is NULL or a.ORDERNO=pORDERNO) and
  	(pEmployee is NULL or a.SALESPERSONID=pEmployee)
  	GROUP BY a.BASICTYPEID, a.ORDERNO, a.ClientId,a.ContactPerson,
  a.ORDERDATE,e.SalesTerm,a.CurrencyId, a.ConRate, a.WCancelled, a.WRevised,a.CLIENTSREF,a.ORDERREMARKS,
  a.DELIVERYPLACE,a.GARMENTSORDERREF, 
  c.DESCRIPTION,d.ClientName,f.CurrencyName, g.Employeename, 
  h.ORDERSTATUS 
  ORDER BY a.ORDERNO,a.ORDERDATE;
 /* For REPORT CLIENT WISE */
  elsif pQueryType=3 then
  OPEN data_cursor for 
  SELECT a.BASICTYPEID,getfncWOBType(a.orderno) as Dworkorder, a.ORDERNO, a.ClientId,a.ContactPerson,
  a.ORDERDATE,e.SalesTerm,a.CurrencyId, a.ConRate, a.WCancelled, a.WRevised,a.CLIENTSREF,a.ORDERREMARKS,
  getFncbasicWorkOrder(a.ORDERNO)  as BasicWorkOrder,a.DELIVERYPLACE,a.GARMENTSORDERREF, 
  c.DESCRIPTION as OrderType,d.ClientName,f.CurrencyName, g.Employeename,
  h.ORDERSTATUS, 
  SUM(b.QUANTITY) SumOfWOQty, 
  SUM((b.QUANTITY*NVL(b.RATE,0))/decode(a.CurrencyId, 2, 1,vCRate)) SumOfWOAmt,
  SUM((b.QUANTITY*NVL(b.RATE,0))*a.ConRate) SumOfWOAmtTk
 	FROM T_WorkOrder a,T_OrderItems b ,t_OrderType c,t_client d,t_salesterm e,
	t_Currency f, T_Employee g,T_ORDERSTATUS h
        where a.ORDERNO =b.ORDERNO and
  	a.BASICTYPEID=c.ORDERCODE and
  	e.salestermid=a.salestermid and
  	a.CURRENCYID=f.CURRENCYID and
  	d.clientid=a.clientid and
	g.EmployeeId = a.SALESPERSONID and
        h.ORDERSTATUSID = a.ORDERSTATUSID and
	a.BASICTYPEID=pType and
	a.WCancelled=0 and
  	(pClient is NULL or a.ClientId=pClient) and
  	(pORDERSTATUSID is NULL or a.ORDERSTATUSID=pORDERSTATUSID) and
  	(pSDate is NULL or a.ORDERDATE>=vSDate) and
  	(pEDate is NULL or a.ORDERDATE<=vEDate) and
  	(pORDERNO is NULL or a.ORDERNO=pORDERNO) and
  	(pEmployee is NULL or a.SALESPERSONID=pEmployee)
  	GROUP BY a.BASICTYPEID, a.ORDERNO, a.ClientId,a.ContactPerson,
  a.ORDERDATE,e.SalesTerm,a.CurrencyId, a.ConRate, a.WCancelled, a.WRevised,a.CLIENTSREF,a.ORDERREMARKS,
  a.DELIVERYPLACE,a.GARMENTSORDERREF,
  c.DESCRIPTION,d.ClientName,f.CurrencyName, g.Employeename, 
  h.ORDERSTATUS 
  ORDER BY d.ClientName,a.ORDERNO;

 /* For REPORT DATE WISE */
  elsif pQueryType=4 then
  OPEN data_cursor for 
  SELECT a.BASICTYPEID,getfncWOBType(a.orderno) as Dworkorder, a.ORDERNO, a.ClientId,a.ContactPerson,
  a.ORDERDATE,e.SalesTerm,a.CurrencyId, a.ConRate, a.WCancelled, a.WRevised,a.CLIENTSREF,a.ORDERREMARKS,
  getFncbasicWorkOrder(a.ORDERNO)  as BasicWorkOrder,a.DELIVERYPLACE,a.GARMENTSORDERREF,
  c.DESCRIPTION as OrderType,d.ClientName,f.CurrencyName, g.Employeename,
  h.ORDERSTATUS, 
  SUM(b.QUANTITY) SumOfWOQty, 
  SUM((b.QUANTITY*NVL(b.RATE,0))/decode(a.CurrencyId, 2, 1,vCRate)) SumOfWOAmt,
  SUM((b.QUANTITY*NVL(b.RATE,0))*a.ConRate) SumOfWOAmtTk
 	FROM T_WorkOrder a,T_OrderItems b ,t_OrderType c,t_client d,t_salesterm e,
	t_Currency f, T_Employee g,T_ORDERSTATUS h
        where a.ORDERNO =b.ORDERNO and
  	a.BASICTYPEID=c.ORDERCODE and
  	e.salestermid=a.salestermid and
  	a.CURRENCYID=f.CURRENCYID and
  	d.clientid=a.clientid and
	g.EmployeeId = a.SALESPERSONID and
        h.ORDERSTATUSID = a.ORDERSTATUSID and
	a.BASICTYPEID=pType and
	a.WCancelled=0 and
  	(pClient is NULL or a.ClientId=pClient) and
  	(pORDERSTATUSID is NULL or a.ORDERSTATUSID=pORDERSTATUSID) and
  	(pSDate is NULL or a.ORDERDATE>=vSDate) and
  	(pEDate is NULL or a.ORDERDATE<=vEDate) and
  	(pORDERNO is NULL or a.ORDERNO=pORDERNO) and
  	(pEmployee is NULL or a.SALESPERSONID=pEmployee)
  	GROUP BY a.BASICTYPEID, a.ORDERNO, a.ClientId,a.ContactPerson,
  a.ORDERDATE,e.SalesTerm,a.CurrencyId, a.ConRate, a.WCancelled, a.WRevised,a.CLIENTSREF,a.ORDERREMARKS,
  a.DELIVERYPLACE,a.GARMENTSORDERREF, 
  c.DESCRIPTION,d.ClientName,f.CurrencyName, g.Employeename, 
  h.ORDERSTATUS 
  ORDER BY a.ORDERDATE,a.ORDERNO;
 /* For REPORT SALESPERSONWISE */
  elsif pQueryType=5 then
  OPEN data_cursor for 
  SELECT a.BASICTYPEID,getfncWOBType(a.orderno) as Dworkorder, a.ORDERNO, a.ClientId,a.ContactPerson,
  a.ORDERDATE,e.SalesTerm,a.CurrencyId, a.ConRate, a.WCancelled, a.WRevised,a.CLIENTSREF,a.ORDERREMARKS,
  getFncbasicWorkOrder(a.ORDERNO)  as BasicWorkOrder,a.DELIVERYPLACE,a.GARMENTSORDERREF, 
  c.DESCRIPTION as OrderType,d.ClientName,f.CurrencyName, g.Employeename,
  h.ORDERSTATUS, 
  SUM(b.QUANTITY) SumOfWOQty, 
  SUM((b.QUANTITY*NVL(b.RATE,0))/decode(a.CurrencyId, 2, 1,vCRate)) SumOfWOAmt,
  SUM((b.QUANTITY*NVL(b.RATE,0))*a.ConRate) SumOfWOAmtTk
 	FROM T_WorkOrder a,T_OrderItems b ,t_OrderType c,t_client d,t_salesterm e,
	t_Currency f, T_Employee g,T_ORDERSTATUS h
        where a.ORDERNO =b.ORDERNO and
  	a.BASICTYPEID=c.ORDERCODE and
  	e.salestermid=a.salestermid and
  	a.CURRENCYID=f.CURRENCYID and
  	d.clientid=a.clientid and
	g.EmployeeId = a.SALESPERSONID and
        h.ORDERSTATUSID = a.ORDERSTATUSID and
	a.BASICTYPEID=pType and
	a.WCancelled=0 and
  	(pClient is NULL or a.ClientId=pClient) and
  	(pORDERSTATUSID is NULL or a.ORDERSTATUSID=pORDERSTATUSID) and
  	(pSDate is NULL or a.ORDERDATE>=vSDate) and
  	(pEDate is NULL or a.ORDERDATE<=vEDate) and
  	(pORDERNO is NULL or a.ORDERNO=pORDERNO) and
  	(pEmployee is NULL or a.SALESPERSONID=pEmployee)
  	GROUP BY a.BASICTYPEID, a.ORDERNO, a.ClientId,a.ContactPerson,
  a.ORDERDATE,e.SalesTerm,a.CurrencyId, a.ConRate, a.WCancelled, a.WRevised,a.CLIENTSREF,a.ORDERREMARKS,
  a.DELIVERYPLACE,a.GARMENTSORDERREF, 
  c.DESCRIPTION,d.ClientName,f.CurrencyName, g.Employeename, 
  h.ORDERSTATUS 
  ORDER BY g.Employeename,a.ORDERNO;
  end if;
END T01ReportWorkOrder; 
/  



PROMPT CREATE OR REPLACE Procedure  39:: G01ReportGWorkOrder
CREATE OR REPLACE Procedure G01ReportGWorkOrder(
  data_cursor IN OUT pReturnData.c_Records, 
  pQueryType IN NUMBER,
  pType IN VARCHAR2,
  pClient IN NUMBER DEFAULT NULL, 
  pORDERSTATUSID IN NUMBER  DEFAULT NULL, 
  pSDate IN VARCHAR2  DEFAULT NULL, 
  pEDate IN VARCHAR2  DEFAULT NULL, 
  pGORDERNO IN NUMBER  DEFAULT NULL, 
  pEmployee IN VARCHAR2  DEFAULT NULL
) 
AS 
  vSDate date;
  vEDate date;
  vCRate NUMBER(12,4);
BEGIN 

  if not pSDate is null then
    vSDate := TO_DATE(pSDate, 'DD/MM/YYYY');
  end if;
  if not pEDate is null then
    vEDate := TO_DATE(pEDate, 'DD/MM/YYYY');
  end if;

  select CONRATE into vCRate from T_Currency where CurrencyId=2;
/*  For Report WOWISE */
  if pQueryType=2 then
  OPEN data_cursor for 
  SELECT a.OrderTypeID,getfncDispalyorder(a.GORDERNO) as DOrder, a.GORDERNO, a.ClientId,a.ContactPerson,
  a.GORDERDATE,e.SalesTerm,a.CurrencyId, a.ConRate, a.WCancelled, a.WRevised,a.CLIENTSREF,a.ORDERREMARKS,
  getFncbasicWorkOrder(a.GORDERNO)  as BasicWorkOrder,c.DESCRIPTION as OrderType, 
  d.ClientName,f.CurrencyName, g.Employeename, h.ORDERSTATUS, 
  SUM(b.QUANTITY) SumOfWOQty, 
  SUM((b.QUANTITY*NVL(b.PRICE,0))/decode(a.CurrencyId, 2, 1,vCRate)) SumOfWOAmt,
  SUM((b.QUANTITY*NVL(b.PRICE,0))*a.ConRate) SumOfWOAmtTk
  	FROM T_GWorkOrder a,T_GOrderItems b ,t_GOrderType c,t_client d,t_salesterm e,
	t_Currency f, T_Employee g,T_ORDERSTATUS h
        where a.GORDERNO =b.GORDERNO and
  	a.OrderTypeID=c.OrderType and
  	e.salestermid=a.salestermid and
  	a.CURRENCYID=f.CURRENCYID and
  	d.clientid=a.clientid and
	g.EmployeeId = a.SALESPERSONID and
        h.ORDERSTATUSID = a.ORDERSTATUSID and
  	a.OrderTypeID=pType and
	a.WCancelled=0 and
  	(pClient is NULL or a.ClientId=pClient) and
  	(pORDERSTATUSID is NULL or a.ORDERSTATUSID=pORDERSTATUSID) and
  	(pSDate is NULL or a.GORDERDATE>=vSDate) and
  	(pEDate is NULL or a.GORDERDATE<=vEDate) and
  	(pGORDERNO is NULL or a.GORDERNO=pGORDERNO) and
  	(pEmployee is NULL or a.SALESPERSONID=pEmployee)
  	GROUP BY a.OrderTypeID, a.GORDERNO, a.ClientId,a.ContactPerson,
  	a.GORDERDATE,e.SalesTerm,a.CurrencyId, a.ConRate, a.WCancelled, a.WRevised,a.CLIENTSREF,a.ORDERREMARKS,
  	c.DESCRIPTION,d.ClientName,f.CurrencyName, g.Employeename, h.ORDERSTATUS
	ORDER BY a.GORDERNO,a.GORDERDATE;
 /* For REPORT CLIENT WISE */
  elsif pQueryType=3 then
  OPEN data_cursor for 
  SELECT a.OrderTypeID,getfncDispalyorder(a.GORDERNO) as DOrder, a.GORDERNO, a.ClientId,a.ContactPerson,
  a.GORDERDATE,e.SalesTerm,a.CurrencyId, a.ConRate, a.WCancelled, a.WRevised,a.CLIENTSREF,a.ORDERREMARKS,
  getFncbasicWorkOrder(a.GORDERNO)  as BasicWorkOrder,c.DESCRIPTION as OrderType, 
  d.ClientName,f.CurrencyName, g.Employeename, h.ORDERSTATUS, 
  SUM(b.QUANTITY) SumOfWOQty, 
  SUM((b.QUANTITY*NVL(b.PRICE,0))/decode(a.CurrencyId, 2, 1,vCRate)) SumOfWOAmt,
  SUM((b.QUANTITY*NVL(b.PRICE,0))*a.ConRate) SumOfWOAmtTk
  	FROM T_GWorkOrder a,T_GOrderItems b ,t_GOrderType c,t_client d,t_salesterm e,
	t_Currency f, T_Employee g,T_ORDERSTATUS h
        where a.GORDERNO =b.GORDERNO and
  	a.OrderTypeID=c.OrderType and
  	e.salestermid=a.salestermid and
  	a.CURRENCYID=f.CURRENCYID and
  	d.clientid=a.clientid and
	g.EmployeeId = a.SALESPERSONID and
        h.ORDERSTATUSID = a.ORDERSTATUSID and
  	a.OrderTypeID=pType and
	a.WCancelled=0 and
  	(pClient is NULL or a.ClientId=pClient) and
  	(pORDERSTATUSID is NULL or a.ORDERSTATUSID=pORDERSTATUSID) and
  	(pSDate is NULL or a.GORDERDATE>=vSDate) and
  	(pEDate is NULL or a.GORDERDATE<=vEDate) and
  	(pGORDERNO is NULL or a.GORDERNO=pGORDERNO) and
  	(pEmployee is NULL or a.SALESPERSONID=pEmployee)
  	GROUP BY a.OrderTypeID, a.GORDERNO, a.ClientId,a.ContactPerson,
  	a.GORDERDATE,e.SalesTerm,a.CurrencyId, a.ConRate, a.WCancelled, a.WRevised,a.CLIENTSREF,a.ORDERREMARKS,
  	c.DESCRIPTION,d.ClientName,f.CurrencyName, g.Employeename, h.ORDERSTATUS
	ORDER BY d.ClientName,a.GORDERNO;
 /* For REPORT DATE WISE */
  elsif pQueryType=4 then
  OPEN data_cursor for 
  SELECT a.OrderTypeID,getfncDispalyorder(a.GORDERNO) as DOrder, a.GORDERNO, a.ClientId,a.ContactPerson,
  a.GORDERDATE,e.SalesTerm,a.CurrencyId, a.ConRate, a.WCancelled, a.WRevised,a.CLIENTSREF,a.ORDERREMARKS,
  getFncbasicWorkOrder(a.GORDERNO)  as BasicWorkOrder,c.DESCRIPTION as OrderType, 
  d.ClientName,f.CurrencyName, g.Employeename, h.ORDERSTATUS, 
  SUM(b.QUANTITY) SumOfWOQty, 
  SUM((b.QUANTITY*NVL(b.PRICE,0))/decode(a.CurrencyId, 2, 1,vCRate)) SumOfWOAmt,
  SUM((b.QUANTITY*NVL(b.PRICE,0))*a.ConRate) SumOfWOAmtTk
  	FROM T_GWorkOrder a,T_GOrderItems b ,t_GOrderType c,t_client d,t_salesterm e,
	t_Currency f, T_Employee g,T_ORDERSTATUS h
        where a.GORDERNO =b.GORDERNO and
  	a.OrderTypeID=c.OrderType and
  	e.salestermid=a.salestermid and
  	a.CURRENCYID=f.CURRENCYID and
  	d.clientid=a.clientid and
	g.EmployeeId = a.SALESPERSONID and
        h.ORDERSTATUSID = a.ORDERSTATUSID and
  	a.OrderTypeID=pType and
	a.WCancelled=0 and
  	(pClient is NULL or a.ClientId=pClient) and
  	(pORDERSTATUSID is NULL or a.ORDERSTATUSID=pORDERSTATUSID) and
  	(pSDate is NULL or a.GORDERDATE>=vSDate) and
  	(pEDate is NULL or a.GORDERDATE<=vEDate) and
  	(pGORDERNO is NULL or a.GORDERNO=pGORDERNO) and
  	(pEmployee is NULL or a.SALESPERSONID=pEmployee)
  	GROUP BY a.OrderTypeID, a.GORDERNO, a.ClientId,a.ContactPerson,
  	a.GORDERDATE,e.SalesTerm,a.CurrencyId, a.ConRate, a.WCancelled, a.WRevised,a.CLIENTSREF,a.ORDERREMARKS,
  	c.DESCRIPTION,d.ClientName,f.CurrencyName, g.Employeename, h.ORDERSTATUS
	ORDER BY a.GORDERDATE,a.GORDERNO;
 /* For REPORT SALESPERSONWISE */
  elsif pQueryType=5 then
  OPEN data_cursor for 
  SELECT a.OrderTypeID,getfncDispalyorder(a.GORDERNO) as DOrder, a.GORDERNO, a.ClientId,a.ContactPerson,
  a.GORDERDATE,e.SalesTerm,a.CurrencyId, a.ConRate, a.WCancelled, a.WRevised,a.CLIENTSREF,a.ORDERREMARKS,
  getFncbasicWorkOrder(a.GORDERNO)  as BasicWorkOrder,c.DESCRIPTION as OrderType, 
 d.ClientName,f.CurrencyName, g.Employeename, h.ORDERSTATUS, 
  SUM(b.QUANTITY) SumOfWOQty, 
  SUM((b.QUANTITY*NVL(b.PRICE,0))/decode(a.CurrencyId, 2, 1,vCRate)) SumOfWOAmt,
  SUM((b.QUANTITY*NVL(b.PRICE,0))*a.ConRate) SumOfWOAmtTk
  	FROM T_GWorkOrder a,T_GOrderItems b ,t_GOrderType c,t_client d,t_salesterm e,
	t_Currency f, T_Employee g,T_ORDERSTATUS h,t_unitOfmeas j
        where a.GORDERNO =b.GORDERNO and
  	a.OrderTypeID=c.OrderType and
  	e.salestermid=a.salestermid and
  	a.CURRENCYID=f.CURRENCYID and
  	d.clientid=a.clientid and
	g.EmployeeId = a.SALESPERSONID and
        h.ORDERSTATUSID = a.ORDERSTATUSID and
  	a.OrderTypeID=pType and
	a.WCancelled=0 and
  	(pClient is NULL or a.ClientId=pClient) and
  	(pORDERSTATUSID is NULL or a.ORDERSTATUSID=pORDERSTATUSID) and
  	(pSDate is NULL or a.GORDERDATE>=vSDate) and
  	(pEDate is NULL or a.GORDERDATE<=vEDate) and
  	(pGORDERNO is NULL or a.GORDERNO=pGORDERNO) and
  	(pEmployee is NULL or a.SALESPERSONID=pEmployee)
  	GROUP BY a.OrderTypeID, a.GORDERNO, a.ClientId,a.ContactPerson,
  	a.GORDERDATE,e.SalesTerm,a.CurrencyId, a.ConRate, a.WCancelled, a.WRevised,a.CLIENTSREF,a.ORDERREMARKS,
  	 c.DESCRIPTION,d.ClientName,f.CurrencyName, g.Employeename, h.ORDERSTATUS
	ORDER BY g.Employeename,a.GORDERNO;
 /* For REPORT Delivery Datewise */
  elsif pQueryType=6 then
  OPEN data_cursor for

  SELECT a.OrderTypeID,getfncDispalyorder(a.GORDERNO) as DOrder, a.GORDERNO, a.ClientId,a.ContactPerson,
  a.GORDERDATE,e.SalesTerm,a.CurrencyId, a.ConRate, a.WCancelled, a.WRevised,a.CLIENTSREF,a.ORDERREMARKS,
  getFncbasicWorkOrder(a.GORDERNO)  as BasicWorkOrder,c.DESCRIPTION as OrderType,b.DELIVERYDATE,
 d.ClientName,f.CurrencyName, g.Employeename, h.ORDERSTATUS,
  SUM(b.QUANTITY) SumOfWOQty,
  SUM((b.QUANTITY*NVL(b.PRICE,0))/decode(a.CurrencyId, 2, 1,vCRate)) SumOfWOAmt,
  SUM((b.QUANTITY*NVL(b.PRICE,0))*a.ConRate) SumOfWOAmtTk
  	FROM T_GWorkOrder a,T_GOrderItems b ,t_GOrderType c,t_client d,t_salesterm e,
	t_Currency f, T_Employee g,T_ORDERSTATUS h,t_unitOfmeas j
        where a.GORDERNO =b.GORDERNO and
  	a.OrderTypeID=c.OrderType and
  	e.salestermid=a.salestermid and
  	a.CURRENCYID=f.CURRENCYID and
  	d.clientid=a.clientid and
	g.EmployeeId = a.SALESPERSONID and
        h.ORDERSTATUSID = a.ORDERSTATUSID and
  	a.OrderTypeID=pType and
	a.WCancelled=0 and
  	(pClient is NULL or a.ClientId=pClient) and
  	(pORDERSTATUSID is NULL or a.ORDERSTATUSID=pORDERSTATUSID) and
  	(pSDate is NULL or b.DELIVERYDATE>=vSDate) and
  	(pEDate is NULL or b.DELIVERYDATE<=vEDate) and
  	(pGORDERNO is NULL or a.GORDERNO=pGORDERNO) and
  	(pEmployee is NULL or a.SALESPERSONID=pEmployee)
  	GROUP BY a.OrderTypeID, a.GORDERNO, a.ClientId,a.ContactPerson,
  	a.GORDERDATE,e.SalesTerm,a.CurrencyId, a.ConRate, a.WCancelled, a.WRevised,a.CLIENTSREF,a.ORDERREMARKS,
  	c.DESCRIPTION,d.ClientName,f.CurrencyName, g.Employeename, h.ORDERSTATUS,b.DELIVERYDATE
	ORDER BY b.DELIVERYDATE,a.GORDERNO;
  end if;

END G01ReportGWorkOrder; 
/  


PROMPT CREATE OR REPLACE Procedure  40 :: TD01ReportDeliveryInvoice
Create or Replace Procedure TD01ReportDeliveryInvoice
(
   data_cursor IN OUT pReturnData.c_Records,
   pDINVOICEID IN NUMBER,
   pDTYPE IN VARCHAR2
)
As
Begin
  OPEN data_cursor  FOR
  select a.DINVOICEID,a.INVOICENO,a.INVOICEDATE,a.CONTACTPERSON,a.DELIVERYPLACE,a.GATEPASSNO,getfncWOBType(A.Orderno) as mainorderno,
  a.MREMARKS,b.DINVOICEITEMSL,b.ORDERLINEITEM,b.QUANTITY,b.SQUANTITY,b.PUNITOFMEASID,b.SUNITOFMEASID,b.ITEMDESC,b.CURRENTQTY,b.RETURNABLE,b.RETURNEDQTY,b.NONRETURNABLE,
 b.SHADE,b.REMARKS,b.ORDERNO,getfncWOBType(b.ORDERNO) as workorder,b.DBATCH,b.FINISHEDDIA,p.unitofmeas as punit,x.unitofmeas as sunit,
 b.FINISHEDGSM,b.GWT,b.FWT,c.CLIENTName,c.CFACTORYADDRESS,c.CCONTACTPERSON,c.CTELEPHONE,d.FABRICTYPE,b.YARNBATCHNO,
        a.DINVOICECOMMENTS,a.DTYPE,f.COLLARCUFFSIZE,
       (select sum(quantity) from T_ORDERITEMS where orderno=(select orderno from T_DINVOICE where DINVOICEID=pDINVOICEID)) as OrderQty,
       (select NVL(sum(quantity),0) from T_DINVOICEITEMS where orderno=(select orderno from T_DINVOICE where DINVOICEID=pDINVOICEID)) as deliveryQty
  from T_DINVOICE a,T_DINVOICEITEMS b,T_Client c,T_FABRICTYPE d, T_ORDERITEMS e,T_COLLARCUFF f,T_unitOfmeas p,T_unitOfmeas x
        where a.DINVOICEID=b.DINVOICEID and
        a.DTYPE=pDTYPE and
		a.CLIENTID=c.CLIENTID(+) and
		b.FABRICTYPEID=d.FABRICTYPEID(+) and
        b.ORDERLINEITEM=e.ORDERLINEITEM(+) and
        e.COLLARCUFFID=f.COLLARCUFFID(+) and
		b.PunitOfMeasId=p.UNITOFMEASID(+) and
		b.SunitOfMeasId=x.UNITOFMEASID(+) and
 a.DINVOICEID=pDINVOICEID;
End TD01ReportDeliveryInvoice;
/



PROMPT CREATE OR REPLACE Procedure  41 :: GetDB01ReportDyeingBatch
CREATE OR REPLACE Procedure GetDB01ReportDyeingBatch
(
  data_cursor IN OUT pReturnData.c_Records,
  pDBatchID number
)
AS
BEGIN
    OPEN data_cursor FOR
    select a.DBatchId, a.BatchNo, a.BatchDate,a.Execute,getfncWOBType(b.orderno) as Dworkorder,
    b.ORDERNO,GetfncWOBType(b.ORDERNO) as btype,c.FabricType,b.OrderlineItem,b.currentStock,
    b.Quantity, b.Squantity,d.UnitOfmeas,b.SUNITOFMEASID,b.Shade,b.REMARKS
    from T_DBatch a,T_DBatchItems b,T_FabricType c,T_UnitOfMeas d
    where a.DBatchId=b.DBatchID and
	b.FabricTypeId=c.FabricTypeId and
	b.PunitOfmeasId=d.unitOfmeasId and
	b.DBatchId=pDBatchID
    	order by BatchITEMSL asc;
END GetDB01ReportDyeingBatch;
/



PROMPT CREATE OR REPLACE Procedure  42 :: GetFR01ReportFabricReceived
Create or Replace Procedure GetFR01ReportFabricReceived
(
   data_cursor IN OUT pReturnData.c_Records,
   pQueryType IN NUMBER,
   pKnitStockID IN NUMBER
)
As
Begin
/*  For Report FR01 Fabric Received From Gray Floor*/
  if pQueryType=6 then
  OPEN data_cursor  FOR
  select YarnCount,FABRICTYPE,YarnType,a.Quantity,a.Squantity,getfncDateTimeDistance(a.KSTARTDATETIME, a.KENDDATETIME) KDURATION,
  f.UNITOFMEAS as PUOM,f.UNITOFMEAS as SUOM,YARNBATCHNO,a.SHADE,
  a.Remarks,b.STOCKID,b.ReferenceNo,b.ReferenceDate,b.StockTransNO,
  b.StockTransDATE,b.SupplierInvoiceNo,k.shadegroupName,a.KSTARTDATETIME,a.KENDDATETIME,
  b.SupplierInvoiceDate,j.SubConName,h.orderNo,getfncWOBType(h.orderno) as workorder,DyedLotNo,l.MACHINENAME
  from T_KnitStockItems a,T_KnitStock b,T_YarnCount c ,
  T_YarnType d,T_FABRICTYPE e,t_UnitOfMeas f,
  t_WorkOrder h, T_Subcontractors j,t_shadegroup k,T_KNITMACHINEINFO l
  where a.STOCKID=b.STOCKID(+) and
  a.MACHINEID=l.MACHINEID(+) and
  a.shadegroupid=k.shadegroupid(+) and 
  a.YarnCountID=c.YarnCountID(+) and
  a.YarnTypeID=d.YarnTypeID(+) and
  KNTITRANSACTIONTYPEID=6 and
  a.PUNITOFMEASID=f.UNITOFMEASID(+) And
  a.orderNo=h.OrderNo(+) And
  a.FABRICTYPEID=e.FABRICTYPEID(+) and
  b.SubconId=j.SubconId(+) And
  a.STOCKID=pKnitStockID;
/*  For Report FR01 Fabric Received From Gray SubContractor*/
  elsif pQueryType=7 then
  OPEN data_cursor  FOR
  select YarnCount,FABRICTYPE,YarnType,a.Quantity,a.Squantity,getfncDateTimeDistance(a.KSTARTDATETIME, a.KENDDATETIME) KDURATION,
  f.UNITOFMEAS as PUOM,f.UNITOFMEAS as SUOM,YARNBATCHNO,a.SHADE,
  a.Remarks,b.STOCKID,b.ReferenceNo,b.ReferenceDate,b.StockTransNO,
  b.StockTransDATE,b.SupplierInvoiceNo,k.shadegroupName,a.KSTARTDATETIME,a.KENDDATETIME,
  b.SupplierInvoiceDate,j.SubConName,h.orderNo,getfncWOBType(h.orderno) as workorder,DyedLotNo,l.MACHINENAME
  from T_KnitStockItems a,T_KnitStock b,T_YarnCount c ,
  T_YarnType d,T_FABRICTYPE e,t_UnitOfMeas f,
  t_WorkOrder h, T_Subcontractors j,t_shadegroup k,T_KNITMACHINEINFO l
  where a.STOCKID=b.STOCKID(+) and
  a.MACHINEID=l.MACHINEID(+) and
  a.shadegroupid=k.shadegroupid(+) and 
  a.YarnCountID=c.YarnCountID(+) and
  a.YarnTypeID=d.YarnTypeID(+) and
  KNTITRANSACTIONTYPEID=7 and
  a.PUNITOFMEASID=f.UNITOFMEASID(+) And
  a.orderNo=h.OrderNo(+) And
  a.FABRICTYPEID=e.FABRICTYPEID(+) and
  b.SubconId=j.SubconId(+) And
  a.STOCKID=pKnitStockID;
/*  For Report FR01 Fabric Received From Dyed Floor */
  elsif pQueryType=24 then
  OPEN data_cursor  FOR
  select YarnCount,FABRICTYPE,YarnType,a.Quantity,a.Squantity,getfncDateTimeDistance(a.KSTARTDATETIME, a.KENDDATETIME) KDURATION,
  f.UNITOFMEAS as PUOM,f.UNITOFMEAS as SUOM,YARNBATCHNO,a.SHADE,
  a.Remarks,b.STOCKID,b.ReferenceNo,b.ReferenceDate,b.StockTransNO,
  b.StockTransDATE,b.SupplierInvoiceNo,k.shadegroupName,a.KSTARTDATETIME,a.KENDDATETIME,
  b.SupplierInvoiceDate,j.SubConName,h.orderNo,getfncWOBType(h.orderno) as workorder,DyedLotNo,l.MACHINENAME
  from T_KnitStockItems a,T_KnitStock b,T_YarnCount c ,
  T_YarnType d,T_FABRICTYPE e,t_UnitOfMeas f,
  t_WorkOrder h, T_Subcontractors j,t_shadegroup k,T_KNITMACHINEINFO l
  where a.STOCKID=b.STOCKID(+) and
  a.MACHINEID=l.MACHINEID(+) and
  a.shadegroupid=k.shadegroupid(+) and 
  a.YarnCountID=c.YarnCountID(+) and
  a.YarnTypeID=d.YarnTypeID(+) and
  KNTITRANSACTIONTYPEID=24 and
  a.PUNITOFMEASID=f.UNITOFMEASID(+) And
  a.orderNo=h.OrderNo(+) And
  a.FABRICTYPEID=e.FABRICTYPEID(+) and
  b.SubconId=j.SubconId(+) And
  a.STOCKID=pKnitStockID;
/*  For Report FR01 Fabric Received From Dyed SubContractor */
  elsif pQueryType=25 then
  OPEN data_cursor  FOR
  select YarnCount,FABRICTYPE,YarnType,a.Quantity,a.Squantity,getfncDateTimeDistance(a.KSTARTDATETIME, a.KENDDATETIME) KDURATION,
  f.UNITOFMEAS as PUOM,f.UNITOFMEAS as SUOM,YARNBATCHNO,a.SHADE,
  a.Remarks,b.STOCKID,b.ReferenceNo,b.ReferenceDate,b.StockTransNO,
  b.StockTransDATE,b.SupplierInvoiceNo,k.shadegroupName,a.KSTARTDATETIME,a.KENDDATETIME,
  b.SupplierInvoiceDate,j.SubConName,h.orderNo,getfncWOBType(h.orderno) as workorder,DyedLotNo,l.MACHINENAME
  from T_KnitStockItems a,T_KnitStock b,T_YarnCount c ,
  T_YarnType d,T_FABRICTYPE e,t_UnitOfMeas f,
  t_WorkOrder h, T_Subcontractors j,t_shadegroup k,T_KNITMACHINEINFO l
  where a.STOCKID=b.STOCKID(+) and
  a.MACHINEID=l.MACHINEID(+) and
  a.shadegroupid=k.shadegroupid(+) and 
  a.YarnCountID=c.YarnCountID(+) and
  a.YarnTypeID=d.YarnTypeID(+) and
  KNTITRANSACTIONTYPEID=25 and
  a.PUNITOFMEASID=f.UNITOFMEASID(+) And
  a.orderNo=h.OrderNo(+) And
  a.FABRICTYPEID=e.FABRICTYPEID(+) and
  b.SubconId=j.SubconId(+) And
  a.STOCKID=pKnitStockID;
  end if;
End GetFR01ReportFabricReceived;
/

PROMPT CREATE OR REPLACE Procedure  43 :: GetRptSCWorkOrder

CREATE OR REPLACE Procedure GetRptSCWorkOrder
(
  data_cursor IN OUT pReturnData.c_Records,
  pOrderNo number
)
AS
BEGIN
  OPEN data_cursor for
  select a.orderno,getfncWOBType(a.Torderno) as TRefDorder,a.basictypeID,a.orderref,u.SUBCONNAME as ClientName,SUBCONTACTPERSON as CCONTACTPERSON,
  d.salesterm as SalesTerm,a.ContactPerson,b.WOITEMSL,getfncSCWOBType(a.orderno) as Dorderno,a.OrderDate,a.clientsref,h.CurrencyName,
  a.DELIVERYSTARTDATE,a.DELIVERYENDDATE, b.GRAYGSM,B.finishedgsm,b.WIDTH,b.SHRINKAGE,b.Shade,b.RATE,b.QUANTITY,f.unitofmeas as unit, 
  g.fabrictype as fabrictype, b.orderlineitem,SUBFACTORYADDRESS as DELIVERYPLACE,k.shadegroupName,(b.QUANTITY* b.RATE) as totalPrice,
  a.ORDERREMARKS,getFncSCYarnDes(b.ORDERLINEITEM) as YarnDesc,getFncdSCWorkOrder(a.orderno) as FCWorkOrder,h.CONRATE, b.Unitofmeasid as UnitID,
  a.wcancelled,j.EMPLOYEENAME as authorizedperson, a.wrevised,KnitMcDiaGauge,COLLARCUFFSIZE,j.EMPLOYEENAME, b.sqty,x.unitofmeas as sunit,
  u.SUBCONNAME as buyername,b.STITCHLENGTH,getFncColourCombination(b.ORDERLINEITEM) as ColourCombination,getFncTotalColourCombination(a.orderno) as TotalColourCombination
from T_SCworkOrder a,T_SCorderItems b ,T_Salesterm d,T_unitOfmeas f,T_unitOfmeas x,
  T_fabrictype g,T_Currency h,T_COLLARCUFF i,T_Employee j,T_Shadegroup k,T_workOrder t,T_SUBCONTRACTORS u
where a.orderno =b.orderNo(+) and
  b.shadegroupid=k.shadegroupid(+) and
  a.SALESPERSONID=j.EMPLOYEEID(+) and
  a.salestermid=d.salestermid(+) and
  b.unitofmeasid=f.unitofmeasid(+) and
  b.sunit=x.unitOfmeasid(+) and
  b.fabrictypeid=g.fabrictypeid(+) and
  a.CURRENCYID=h.CURRENCYID(+) and
  b.COLLARCUFFID=i.COLLARCUFFID(+) and
  a.Torderno=t.orderno and
  a.SUBCONID=u.SUBCONID(+) and 
  a.OrderNo=pOrderNo
  order by a.orderno,b.WOITEMSL;
END GetRptSCWorkOrder;
/




PROMPT CREATE OR REPLACE Procedure  44 :: GetKnitYarnStockSummary
CREATE OR REPLACE Procedure GetKnitYarnStockSummary(
   data_cursor IN OUT pReturnData.c_Records,
   pQueryType IN NUMBER,
   pClient IN NUMBER DEFAULT NULL,
   sDate IN VARCHAR2,
   eDate IN VARCHAR2
)
AS
  vSDate date;
  vEDate date;
BEGIN
  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  end if;

if pQueryType=114 then
/* Report for T114 Yarn Stock Summary */
open data_cursor for
select b.OrderNo,getfncWOBType(b.orderno) as workorder,e.ORDERDATE,f.ClientName,e.basictypeid,
/* YARN DYEING PROCESS [YARN ISSUE FOR YARN DYEING]*/
 SUM(decode (a.KNTITRANSACTIONTYPEID,5,b.Quantity,0)) as YI_FLOOR,
 SUM(decode (a.KNTITRANSACTIONTYPEID,12,b.Quantity,0)) as YI_OTHERS,
 SUM(decode (a.KNTITRANSACTIONTYPEID,5,b.Quantity,0)+
 decode (a.KNTITRANSACTIONTYPEID,12,b.Quantity,0)) as YI_TOTAL,
/* YARN DYEING PROCESS [YARN RETURN FROM YARN DYEING]*/
 SUM(decode (a.KNTITRANSACTIONTYPEID,11,b.Quantity,0)) as YRF_FLOOR,
 SUM(decode (a.KNTITRANSACTIONTYPEID,14,b.Quantity,0)) as YRF_OTHERS,
 SUM(decode (a.KNTITRANSACTIONTYPEID,11,b.Quantity,0)+
 decode (a.KNTITRANSACTIONTYPEID,14,b.Quantity,0)) as YR_TOTAL,
/* Knit Yarn Transfer One to Another */
 SUM(decode(a.KNTITRANSACTIONTYPEID,151,b.Quantity)) as YT_FROM,
 SUM(decode(a.KNTITRANSACTIONTYPEID,152,b.Quantity)) as YT_TO,
 SUM(decode(a.KNTITRANSACTIONTYPEID,151,b.Quantity,152,-b.Quantity,0)) as YT_TOTAL,
 /* YARN DYEING PROCESS [YARN RECEIVED FROM YARN DYEING]*/
 SUM(decode (a.KNTITRANSACTIONTYPEID,8,b.Quantity,0)) as YREC_FLOOR,
 SUM(decode (a.KNTITRANSACTIONTYPEID,13,b.Quantity,0)) as YREC_OTHERS,
 SUM(decode (a.KNTITRANSACTIONTYPEID,8,b.Quantity,0)+
 decode (a.KNTITRANSACTIONTYPEID,13,b.Quantity,0)) AS REC_TOTAL,
 /* KNITTING PROCESS [TOTAL NET YARN ISSUD FOR KNITTING ]*/
  SUM(decode (a.KNTITRANSACTIONTYPEID,5,b.Quantity,0)-
  decode (a.KNTITRANSACTIONTYPEID,11,b.Quantity,0)+
  decode(a.KNTITRANSACTIONTYPEID,151,b.Quantity,0)-
  decode(a.KNTITRANSACTIONTYPEID,152,b.Quantity,0)-
  decode (a.KNTITRANSACTIONTYPEID,8,b.Quantity,0)) AS NET_YARN_FLOOR,
 /* KNITTING PROCESS [TOTAL NET YARN ISSUD FOR OTHERS ]*/
  SUM(decode (a.KNTITRANSACTIONTYPEID,12,b.Quantity,0)-
  decode (a.KNTITRANSACTIONTYPEID,13,b.Quantity,0)-
  decode (a.KNTITRANSACTIONTYPEID,14,b.Quantity,0)) AS NET_YARN_OTHERS,
 /* KNITTING PROCESS [TOTAL NET YARN FLOOR AND OTHERS ]*/
  SUM(decode (a.KNTITRANSACTIONTYPEID,5,b.Quantity,0)-
  decode (a.KNTITRANSACTIONTYPEID,11,b.Quantity,0)+
  decode(a.KNTITRANSACTIONTYPEID,151,b.Quantity,0)-
  decode(a.KNTITRANSACTIONTYPEID,152,b.Quantity,0)-
  decode (a.KNTITRANSACTIONTYPEID,8,b.Quantity,0)+
  decode (a.KNTITRANSACTIONTYPEID,12,b.Quantity,0)-
  decode (a.KNTITRANSACTIONTYPEID,13,b.Quantity,0)-
  decode (a.KNTITRANSACTIONTYPEID,14,b.Quantity,0)) AS NET_YARN_GRAND_TOTAL

 from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c,  t_workorder e,T_Client f
 where a.StockID=b.StockID and
 a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and a.KNTITRANSACTIONTYPEID in (5,8,11,12,13,14,151,152) and
 b.orderno=e.orderno and e.ClientID=f.ClientID and
 (pClient is NULL or e.ClientID=pClient) and
 e.ORDERDATE between decode(vSDate,null,'01-jan-1900',vSDate) and vEDate
GROUP BY b.OrderNo,e.ORDERDATE,f.ClientName,e.basictypeid
ORDER BY getfncWOBType(b.orderno);

elsif pQueryType=115 then
/* Report for T115 Yarn Stock Summary */
open data_cursor for
select b.OrderNo,getfncWOBType(b.orderno) as workorder,e.ORDERDATE,f.ClientName,e.basictypeid,
/* YARN DYEING PROCESS [YARN ISSUE FOR YARN DYEING]*/
 SUM(decode (a.KNTITRANSACTIONTYPEID,3,b.Quantity,0)) as YI_FLOOR,
 SUM(decode (a.KNTITRANSACTIONTYPEID,4,b.Quantity,0)) as YI_OTHERS,
 SUM(decode (a.KNTITRANSACTIONTYPEID,3,b.Quantity,0)+
 decode (a.KNTITRANSACTIONTYPEID,4,b.Quantity,0)) as YI_TOTAL,
/* YARN DYEING PROCESS [YARN RETURN FROM YARN DYEING]*/
 SUM(decode (a.KNTITRANSACTIONTYPEID,9,b.Quantity,0)) as YRF_FLOOR,
 SUM(decode (a.KNTITRANSACTIONTYPEID,10,b.Quantity,0)) as YRF_OTHERS,
 SUM(decode (a.KNTITRANSACTIONTYPEID,9,b.Quantity,0)+
 decode (a.KNTITRANSACTIONTYPEID,10,b.Quantity,0)) as YR_TOTAL,
/* Knit Yarn Transfer One to Another */
 SUM(decode(a.KNTITRANSACTIONTYPEID,101,b.Quantity)) as YT_FROM,
 SUM(decode(a.KNTITRANSACTIONTYPEID,102,b.Quantity)) as YT_TO,
 SUM(decode(a.KNTITRANSACTIONTYPEID,101,b.Quantity,102,-b.Quantity,0)) as YT_TOTAL,
 /* YARN DYEING PROCESS [YARN RECEIVED FROM YARN DYEING]*/
 SUM(decode (a.KNTITRANSACTIONTYPEID,6,b.Quantity,0)) as YREC_FLOOR,
 SUM(decode (a.KNTITRANSACTIONTYPEID,7,b.Quantity,0)) as YREC_OTHERS,
 SUM(decode (a.KNTITRANSACTIONTYPEID,6,b.Quantity,0)+
 decode (a.KNTITRANSACTIONTYPEID,7,b.Quantity,0)) AS REC_TOTAL,
 /* KNITTING PROCESS [TOTAL NET YARN ISSUD FOR KNITTING ]*/
  SUM(decode (a.KNTITRANSACTIONTYPEID,3,b.Quantity,0)-
  decode (a.KNTITRANSACTIONTYPEID,9,b.Quantity,0)+
  decode(a.KNTITRANSACTIONTYPEID,101,b.Quantity,0)-
  decode(a.KNTITRANSACTIONTYPEID,102,b.Quantity,0)-
  decode (a.KNTITRANSACTIONTYPEID,6,b.Quantity,0)) AS NET_YARN_FLOOR,
 /* KNITTING PROCESS [TOTAL NET YARN ISSUD FOR OTHERS ]*/
  SUM(decode (a.KNTITRANSACTIONTYPEID,4,b.Quantity,0)-
  decode (a.KNTITRANSACTIONTYPEID,10,b.Quantity,0)-
  decode (a.KNTITRANSACTIONTYPEID,7,b.Quantity,0))AS NET_YARN_OTHERS,
 /* KNITTING PROCESS [TOTAL NET YARN FLOOR AND OTHERS ]*/
  SUM(decode (a.KNTITRANSACTIONTYPEID,3,b.Quantity,0)-
  decode (a.KNTITRANSACTIONTYPEID,9,b.Quantity,0)+
  decode(a.KNTITRANSACTIONTYPEID,101,b.Quantity,0)-
  decode(a.KNTITRANSACTIONTYPEID,102,b.Quantity,0)-
  decode (a.KNTITRANSACTIONTYPEID,6,b.Quantity,0)+
  decode (a.KNTITRANSACTIONTYPEID,4,b.Quantity,0)-
  decode (a.KNTITRANSACTIONTYPEID,10,b.Quantity,0)-
  decode (a.KNTITRANSACTIONTYPEID,7,b.Quantity,0))AS NET_YARN_GRAND_TOTAL

 from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c,  t_workorder e,T_Client f
 where a.StockID=b.StockID and
 a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and a.KNTITRANSACTIONTYPEID in (3,4,6,7,9,10,101,102) and
 b.orderno=e.orderno and e.ClientID=f.ClientID and
 (pClient is NULL or e.ClientID=pClient) and
 e.ORDERDATE between decode(vSDate,null,'01-jan-1900',vSDate) and vEDate
GROUP BY b.OrderNo,e.ORDERDATE,f.ClientName,e.basictypeid
ORDER BY getfncWOBType(b.orderno);

elsif pQueryType=116 then
/* Report for T116 Yarn Stock Summary */
open data_cursor for
select b.OrderNo,getfncWOBType(b.orderno) as workorder,e.ORDERDATE,f.ClientName,e.basictypeid,
/* YARN DYEING PROCESS [YARN ISSUE FOR YARN DYEING]*/
 SUM(decode (a.KNTITRANSACTIONTYPEID,22,b.Quantity,0)) as YI_FLOOR,
 SUM(decode (a.KNTITRANSACTIONTYPEID,23,b.Quantity,0)) as YI_OTHERS,
 SUM(decode (a.KNTITRANSACTIONTYPEID,22,b.Quantity,0)+
 decode (a.KNTITRANSACTIONTYPEID,23,b.Quantity,0)) as YI_TOTAL,
/* YARN DYEING PROCESS [YARN RETURN FROM YARN DYEING]*/
 SUM(decode (a.KNTITRANSACTIONTYPEID,26,b.Quantity,0)) as YRF_FLOOR,
 SUM(decode (a.KNTITRANSACTIONTYPEID,27,b.Quantity,0)) as YRF_OTHERS,
 SUM(decode (a.KNTITRANSACTIONTYPEID,26,b.Quantity,0)+
 decode (a.KNTITRANSACTIONTYPEID,27,b.Quantity,0)) as YR_TOTAL,
/* Knit Yarn Transfer One to Another */
 SUM(decode(a.KNTITRANSACTIONTYPEID,131,b.Quantity)) as YT_FROM,
 SUM(decode(a.KNTITRANSACTIONTYPEID,132,b.Quantity)) as YT_TO,
 SUM(decode(a.KNTITRANSACTIONTYPEID,131,b.Quantity))-
 SUM(decode(a.KNTITRANSACTIONTYPEID,132,b.Quantity)) as YT_TOTAL,	
 /*SUM(decode(a.KNTITRANSACTIONTYPEID,131,b.Quantity,132,-b.Quantity,0)) as YT_TOTAL,*/

 /* YARN DYEING PROCESS [YARN RECEIVED FROM YARN DYEING]*/
 SUM(decode (a.KNTITRANSACTIONTYPEID,24,b.Quantity,0)) as YREC_FLOOR,
 SUM(decode (a.KNTITRANSACTIONTYPEID,25,b.Quantity,0)) as YREC_OTHERS,
 SUM(decode (a.KNTITRANSACTIONTYPEID,24,b.Quantity,0)+
 decode (a.KNTITRANSACTIONTYPEID,25,b.Quantity,0)) AS REC_TOTAL,
 /* KNITTING PROCESS [TOTAL NET YARN ISSUD FOR KNITTING ]*/
  SUM(decode (a.KNTITRANSACTIONTYPEID,22,b.Quantity,0)-
  decode (a.KNTITRANSACTIONTYPEID,26,b.Quantity,0)+
  decode(a.KNTITRANSACTIONTYPEID,131,b.Quantity,0)-
  decode(a.KNTITRANSACTIONTYPEID,132,b.Quantity,0)-
  decode (a.KNTITRANSACTIONTYPEID,24,b.Quantity,0)) AS NET_YARN_FLOOR,
 /* KNITTING PROCESS [TOTAL NET YARN ISSUD FOR OTHERS ]*/
  SUM(decode (a.KNTITRANSACTIONTYPEID,23,b.Quantity,0)-
  decode (a.KNTITRANSACTIONTYPEID,27,b.Quantity,0)-  
  decode (a.KNTITRANSACTIONTYPEID,25,b.Quantity,0)) AS NET_YARN_OTHERS,  

 /* KNITTING PROCESS [TOTAL NET YARN FLOOR AND OTHERS ]*/
   SUM(decode (a.KNTITRANSACTIONTYPEID,22,b.Quantity,0)-
  decode (a.KNTITRANSACTIONTYPEID,26,b.Quantity,0)+
  decode(a.KNTITRANSACTIONTYPEID,131,b.Quantity,0)-
  decode(a.KNTITRANSACTIONTYPEID,132,b.Quantity,0)-
  decode (a.KNTITRANSACTIONTYPEID,24,b.Quantity,0))+
  SUM(decode (a.KNTITRANSACTIONTYPEID,23,b.Quantity,0)-
  decode (a.KNTITRANSACTIONTYPEID,27,b.Quantity,0)-  
  decode (a.KNTITRANSACTIONTYPEID,25,b.Quantity,0)) AS NET_YARN_GRAND_TOTAL

 from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c,  t_workorder e,T_Client f
 where a.StockID=b.StockID and
 a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and a.KNTITRANSACTIONTYPEID in (22,23,24,25,26,27,131,132) and
 b.orderno=e.orderno and e.ClientID=f.ClientID and
 (pClient is NULL or e.ClientID=pClient) and
 e.ORDERDATE between decode(vSDate,null,'01-jan-1900',vSDate) and vEDate
GROUP BY b.OrderNo,e.ORDERDATE,f.ClientName,e.basictypeid
ORDER BY getfncWOBType(b.orderno);

elsif pQueryType=15 then
/* Report for T15 Yarn Stock Summary */
open data_cursor for
select b.OrderNo,getfncWOBType(b.orderno) as workorder,e.ORDERDATE,e.ClientID,g.fabrictype,e.basictypeid,
/* YARN DYEING PROCESS [YARN ISSUE FOR YARN DYEING]*/
 SUM(decode (a.KNTITRANSACTIONTYPEID,3,b.Quantity,0)) as YI_FLOOR,
 SUM(decode (a.KNTITRANSACTIONTYPEID,4,b.Quantity,0)) as YI_OTHERS,
 SUM(decode (a.KNTITRANSACTIONTYPEID,3,b.Quantity,0)+
 decode (a.KNTITRANSACTIONTYPEID,4,b.Quantity,0)) as YI_TOTAL,
/* YARN DYEING PROCESS [YARN RETURN FROM YARN DYEING]*/
 SUM(decode (a.KNTITRANSACTIONTYPEID,9,b.Quantity,0)) as YRF_FLOOR,
 SUM(decode (a.KNTITRANSACTIONTYPEID,10,b.Quantity,0)) as YRF_OTHERS,
 SUM(decode (a.KNTITRANSACTIONTYPEID,9,b.Quantity,0)+
 decode (a.KNTITRANSACTIONTYPEID,10,b.Quantity,0)) as YR_TOTAL,
/* Knit Yarn Transfer One to Another */
 SUM(decode(a.KNTITRANSACTIONTYPEID,101,b.Quantity)) as YT_FROM,
 SUM(decode(a.KNTITRANSACTIONTYPEID,102,b.Quantity)) as YT_TO,
 SUM(decode(a.KNTITRANSACTIONTYPEID,101,b.Quantity,102,-b.Quantity,0)) as YT_TOTAL,
 /* YARN DYEING PROCESS [YARN RECEIVED FROM YARN DYEING]*/
 SUM(decode (a.KNTITRANSACTIONTYPEID,6,b.Quantity,0)) as YREC_FLOOR,
 SUM(decode (a.KNTITRANSACTIONTYPEID,7,b.Quantity,0)) as YREC_OTHERS,
 SUM(decode (a.KNTITRANSACTIONTYPEID,6,b.Quantity,0)+
 decode (a.KNTITRANSACTIONTYPEID,7,b.Quantity,0)) AS REC_TOTAL,
 /* KNITTING PROCESS [TOTAL NET YARN ISSUD FOR KNITTING ]*/
  SUM(decode (a.KNTITRANSACTIONTYPEID,3,b.Quantity,0)-
  decode (a.KNTITRANSACTIONTYPEID,9,b.Quantity,0)+
  decode(a.KNTITRANSACTIONTYPEID,101,b.Quantity,0)-
  decode(a.KNTITRANSACTIONTYPEID,102,b.Quantity,0)-
  decode (a.KNTITRANSACTIONTYPEID,6,b.Quantity,0)) AS NET_YARN_FLOOR,
 /* KNITTING PROCESS [TOTAL NET YARN ISSUD FOR OTHERS ]*/
  SUM(decode (a.KNTITRANSACTIONTYPEID,4,b.Quantity,0)-
  decode (a.KNTITRANSACTIONTYPEID,10,b.Quantity,0)-
  decode (a.KNTITRANSACTIONTYPEID,7,b.Quantity,0))AS NET_YARN_OTHERS,
 /* KNITTING PROCESS [TOTAL NET YARN FLOOR AND OTHERS ]*/
  SUM(decode (a.KNTITRANSACTIONTYPEID,3,b.Quantity,0)-
  decode (a.KNTITRANSACTIONTYPEID,9,b.Quantity,0)+
  decode(a.KNTITRANSACTIONTYPEID,101,b.Quantity,0)-
  decode(a.KNTITRANSACTIONTYPEID,102,b.Quantity,0)-
  decode (a.KNTITRANSACTIONTYPEID,6,b.Quantity,0)+
  decode (a.KNTITRANSACTIONTYPEID,4,b.Quantity,0)-
  decode (a.KNTITRANSACTIONTYPEID,10,b.Quantity,0)-
  decode (a.KNTITRANSACTIONTYPEID,7,b.Quantity,0))AS NET_YARN_GRAND_TOTAL
 from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c,  t_workorder e,T_Client f,t_fabrictype g
 where a.StockID=b.StockID and
 b.FABRICTYPEID=g.FABRICTYPEID and
 a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and a.KNTITRANSACTIONTYPEID in (3,4,6,7,9,10,101,102) and
 b.orderno=e.orderno and e.ClientID=f.ClientID and
 g.fabrictypeid=b.fabrictypeid and
 (pClient is NULL or e.ClientID=pClient) and
 e.ORDERDATE between decode(vSDate,null,'01-jan-1900',vSDate) and vEDate
GROUP BY b.OrderNo,e.ORDERDATE,e.ClientID,g.fabrictype,e.basictypeid
ORDER BY getfncWOBType(b.orderno);

elsif pQueryType=16 then
/* Report for T16 Yarn Stock Summary */
open data_cursor for
select b.OrderNo,getfncWOBType(b.orderno) as workorder,e.ORDERDATE,e.ClientID,g.fabrictype,e.basictypeid,
/* YARN DYEING PROCESS [YARN ISSUE FOR YARN DYEING]*/
 SUM(decode (a.KNTITRANSACTIONTYPEID,22,b.Quantity,0)) as YI_FLOOR,
 SUM(decode (a.KNTITRANSACTIONTYPEID,23,b.Quantity,0)) as YI_OTHERS,
 SUM(decode (a.KNTITRANSACTIONTYPEID,22,b.Quantity,0)+
 decode (a.KNTITRANSACTIONTYPEID,23,b.Quantity,0)) as YI_TOTAL,
/* YARN DYEING PROCESS [YARN RETURN FROM YARN DYEING]*/
 SUM(decode (a.KNTITRANSACTIONTYPEID,26,b.Quantity,0)) as YRF_FLOOR,
 SUM(decode (a.KNTITRANSACTIONTYPEID,27,b.Quantity,0)) as YRF_OTHERS,
 SUM(decode (a.KNTITRANSACTIONTYPEID,26,b.Quantity,0)+
 decode (a.KNTITRANSACTIONTYPEID,27,b.Quantity,0)) as YR_TOTAL,
/* Knit Yarn Transfer One to Another */
 SUM(decode(a.KNTITRANSACTIONTYPEID,131,b.Quantity)) as YT_FROM,
 SUM(decode(a.KNTITRANSACTIONTYPEID,132,b.Quantity)) as YT_TO,
 SUM(decode(a.KNTITRANSACTIONTYPEID,131,b.Quantity))-
 SUM(decode(a.KNTITRANSACTIONTYPEID,132,b.Quantity)) as YT_TOTAL,	
 /*SUM(decode(a.KNTITRANSACTIONTYPEID,131,b.Quantity,132,-b.Quantity,0)) as YT_TOTAL,*/

 /* YARN DYEING PROCESS [YARN RECEIVED FROM YARN DYEING]*/
 SUM(decode (a.KNTITRANSACTIONTYPEID,24,b.Quantity,0)) as YREC_FLOOR,
 SUM(decode (a.KNTITRANSACTIONTYPEID,25,b.Quantity,0)) as YREC_OTHERS,
 SUM(decode (a.KNTITRANSACTIONTYPEID,24,b.Quantity,0)+
 decode (a.KNTITRANSACTIONTYPEID,25,b.Quantity,0)) AS REC_TOTAL,
 /* KNITTING PROCESS [TOTAL NET YARN ISSUD FOR KNITTING ]*/
  SUM(decode (a.KNTITRANSACTIONTYPEID,22,b.Quantity,0)-
  decode (a.KNTITRANSACTIONTYPEID,26,b.Quantity,0)+
  decode(a.KNTITRANSACTIONTYPEID,131,b.Quantity,0)-
  decode(a.KNTITRANSACTIONTYPEID,132,b.Quantity,0)-
  decode (a.KNTITRANSACTIONTYPEID,24,b.Quantity,0)) AS NET_YARN_FLOOR,
 /* KNITTING PROCESS [TOTAL NET YARN ISSUD FOR OTHERS ]*/
  SUM(decode (a.KNTITRANSACTIONTYPEID,23,b.Quantity,0)-
  decode (a.KNTITRANSACTIONTYPEID,27,b.Quantity,0)-  
  decode (a.KNTITRANSACTIONTYPEID,25,b.Quantity,0)) AS NET_YARN_OTHERS,  

 /* KNITTING PROCESS [TOTAL NET YARN FLOOR AND OTHERS ]*/
   SUM(decode (a.KNTITRANSACTIONTYPEID,22,b.Quantity,0)-
  decode (a.KNTITRANSACTIONTYPEID,26,b.Quantity,0)+
  decode(a.KNTITRANSACTIONTYPEID,131,b.Quantity,0)-
  decode(a.KNTITRANSACTIONTYPEID,132,b.Quantity,0)-
  decode (a.KNTITRANSACTIONTYPEID,24,b.Quantity,0))+
  SUM(decode (a.KNTITRANSACTIONTYPEID,23,b.Quantity,0)-
  decode (a.KNTITRANSACTIONTYPEID,27,b.Quantity,0)-  
  decode (a.KNTITRANSACTIONTYPEID,25,b.Quantity,0)) AS NET_YARN_GRAND_TOTAL

 from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c,  t_workorder e,T_Client f,t_fabrictype g
 where a.StockID=b.StockID and
 a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and a.KNTITRANSACTIONTYPEID in (22,23,24,25,26,27,131,132) and
 b.orderno=e.orderno and e.ClientID=f.ClientID and
 (pClient is NULL or e.ClientID=pClient) and
 g.fabrictypeid=b.fabrictypeid and
 e.ORDERDATE between decode(vSDate,null,'01-jan-1900',vSDate) and vEDate
GROUP BY b.OrderNo,e.ORDERDATE,e.ClientID,g.fabrictype,e.basictypeid
ORDER BY getfncWOBType(b.orderno),g.fabrictype;


end if;
END GetKnitYarnStockSummary;
/

PROMPT CREATE OR REPLACE Procedure  45 :: GetReportAccStockPosition

Create or Replace Procedure GetReportAccStockPosition(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pAccGroup IN NUMBER,
  sDate IN VARCHAR2,
  eDate IN VARCHAR2
)
AS
vSDate date;
vEDate date;
BEGIN
  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  end if;
  /*Stock Position*/
  if pQueryType=0 then
    open data_cursor for
select b.OrderNo, b.StyleNo,c.ColourName, b.Code, i.Item,b.Count_Size,
sum(decode (a.AccTransTypeID,1,b.Quantity,0)) MainStock,
sum(decode (a.AccTransTypeID,2,b.Quantity,0)) SubStock,
sum(decode (a.AccTransTypeID,4,b.Quantity,0)) returnqty
    from T_AccStock a, T_AccStockItems b, T_AccTransactionType t, T_accessories i, T_colour c
    where a.StockID=b.StockID and
	t.AccTransTypeID=a.AccTransTypeID and
	a.AccTransTypeID IN (1,2,4) AND
    b.AccessoriesID=i.AccessoriesID and
	b.ColourID=c.ColourID
	group by b.OrderNo, b.StyleNo,c.ColourName,b.Code, i.Item,b.Count_Size
	order by OrderNo, StyleNo desc, ColourName desc, code  desc, Item  desc, Count_Size desc;

 /* Stock*/
 elsif pQueryType=1 then
    open data_cursor for
    select i.Item, b.Count_Size, sum(b.Quantity*t.AccStockMain) CurrentStock
    from T_AccStock a, T_AccStockItems b, T_AccTransactionType t, T_accessories i
    where a.StockID=b.StockID and
	t.AccTransTypeID=a.AccTransTypeID and
    	b.AccessoriesID=i.AccessoriesID and
        StockTransDate between decode(vSDate,null,'01-Jan-1901',vSDate) and vEDate
    group by i.Item, b.Count_Size
	having sum(b.Quantity*t.AccStockMain)>0 
    order by i.Item  desc, b.Count_Size desc;
/*Main Stock*/
 elsif pQueryType=2 then
    open data_cursor for
    select a.StockTransNo,a.StockTransDate,i.item,(Quantity) MainIn,0 AS IssueSub, 0 as subtomain
    from T_AccStock a, T_AccStockItems b, T_accessories i
    where a.StockID=b.StockID and
    b.AccessoriesID=i.AccessoriesID and
    StockTransDate<=vEDate and
    a.AccTransTypeID = 1
    UNION ALL
    select a.StockTransNo,a.StockTransDate,i.item,0 AS MainIn,(Quantity) IssueSub, 0 as subtomain
    from T_AccStock a, T_AccStockItems b, T_accessories i
    where a.StockID=b.StockID and
    b.AccessoriesID=i.AccessoriesID and
    StockTransDate<=vEDate and
    a.AccTransTypeID = 2
    UNION ALL
    select a.StockTransNo,a.StockTransDate,i.item,0 AS MainIn,0 as  IssueSub, (Quantity) subtomain
    from T_AccStock a, T_AccStockItems b, T_accessories i
    where a.StockID=b.StockID and
    b.AccessoriesID=i.AccessoriesID and
    StockTransDate<=vEDate and
    a.AccTransTypeID = 4;
/*Sub Stock*/
 elsif pQueryType=3 then
    open data_cursor for
    select b.LineNo, a.StockTransNo,a.StockTransDate,i.item,(Quantity) IssueSub, 0 as IssueProduction, 0 as subtomain
    from T_AccStock a, T_AccStockItems b, T_accessories i
    where a.StockID=b.StockID and
    b.AccessoriesID=i.AccessoriesID and
    StockTransDate<=vEDate and
    a.AccTransTypeID = 2
    UNION ALL
    select b.LineNo, a.StockTransNo,a.StockTransDate,i.item,0 as  IssueSub, (Quantity) IssueProduction, 0 as subtomain
    from T_AccStock a, T_AccStockItems b, T_accessories i
    where a.StockID=b.StockID and
    b.AccessoriesID=i.AccessoriesID and
    StockTransDate<=vEDate and
    a.AccTransTypeID = 3
    UNION ALL
    select b.LineNo, a.StockTransNo,a.StockTransDate,i.item,0 as  IssueSub, 0 as  IssueProduction, (Quantity) subtomain
    from T_AccStock a, T_AccStockItems b, T_accessories i
    where a.StockID=b.StockID and
    b.AccessoriesID=i.AccessoriesID and
    StockTransDate<=vEDate and
    a.AccTransTypeID = 4;

/*AccMRRDetailS ORDER BY CHALLAN DATE WISE*/
 elsif pQueryType=4 then
   OPEN data_cursor  FOR

   select a.StockTransNo as Group_by,a.StockId, a.StockTransNo,  a.StockTransDate, b.LineNo, b.RequisitionNo, b.ORDERNO, i.item ,a.REFERENCENO,
   b.StyleNo, c.ColourName, b.Code, b.Count_Size, b.CurrentStock, b.ReqQuantity, b.Quantity, b.SQuantity ,
   f.UNITOFMEAS as PUOM, f.UNITOFMEAS as SUOM , b.remarks
   from T_AccStock a, T_AccStockItems b,T_AccTransactionType t,T_UnitOfMeas f, T_accessories i, T_Colour c
   where a.STOCKID=b.STOCKID and
   t.AccTransTypeID=1 And
   i.AccessoriesID=b.AccessoriesID and
   b.PUNITOFMEASID=f.UNITOFMEASID And
   c.colourID=b.colourID and
   a.StockTransDate between decode(vSDate,null,'01-Jan-1901',vSDate) and vEDate
   order by a.StockTransDate;

/*AccMRRDetailS ORDER BY Count_Size WISE*/
 elsif pQueryType=5 then
   OPEN data_cursor  FOR 

   select b.Count_Size as Group_by,a.StockId, a.StockTransNo,  a.StockTransDate, b.LineNo, b.RequisitionNo, b.ORDERNO, i.item ,a.REFERENCENO,
   b.StyleNo, c.ColourName, b.Code, b.Count_Size, b.CurrentStock, b.ReqQuantity, b.Quantity, b.SQuantity ,
   f.UNITOFMEAS as PUOM, f.UNITOFMEAS as SUOM , b.remarks
   from T_AccStock a, T_AccStockItems b,T_AccTransactionType t,T_UnitOfMeas f, T_accessories i, T_Colour c
   where a.STOCKID=b.STOCKID and
   t.AccTransTypeID=1 And
   i.AccessoriesID=b.AccessoriesID and
   b.PUNITOFMEASID=f.UNITOFMEASID And
   c.colourID=b.colourID and
   a.StockTransDate between decode(vSDate,null,'01-Jan-1901',vSDate) and vEDate
   order by a.StockTransDate;

/*AccMRRDetailS ORDER BY ColourName WISE*/
 elsif pQueryType=6 then
   OPEN data_cursor  FOR 

   select c.ColourName as Group_by,a.StockId, a.StockTransNo,  a.StockTransDate, b.LineNo, b.RequisitionNo, b.ORDERNO, i.item ,a.REFERENCENO,
   b.StyleNo, c.ColourName, b.Code, b.Count_Size, b.CurrentStock, b.ReqQuantity, b.Quantity, b.SQuantity ,
   f.UNITOFMEAS as PUOM, f.UNITOFMEAS as SUOM , b.remarks
   from T_AccStock a, T_AccStockItems b,T_AccTransactionType t,T_UnitOfMeas f, T_accessories i, T_Colour c
   where a.STOCKID=b.STOCKID and
   t.AccTransTypeID=a.AccTransTypeID and
   t.AccTransTypeID=1 And
   i.AccessoriesID=b.AccessoriesID and
   b.PUNITOFMEASID=f.UNITOFMEASID And
   c.colourID=b.colourID and
   a.StockTransDate between decode(vSDate,null,'01-Jan-1901',vSDate) and vEDate
   order by a.StockTransDate;

/*AccMRRDetailS ORDER BY LineNo WISE*/
 elsif pQueryType=7 then
   OPEN data_cursor  FOR 

   select b.LineNo as Group_by,a.StockId, a.StockTransNo,  a.StockTransDate, b.LineNo, b.RequisitionNo, b.ORDERNO, i.item ,a.REFERENCENO,
   b.StyleNo, c.ColourName, b.Code, b.Count_Size, b.CurrentStock, b.ReqQuantity, b.Quantity, b.SQuantity ,
   f.UNITOFMEAS as PUOM, f.UNITOFMEAS as SUOM , b.remarks
   from T_AccStock a, T_AccStockItems b,T_AccTransactionType t,T_UnitOfMeas f, T_accessories i, T_Colour c
   where a.STOCKID=b.STOCKID and
   t.AccTransTypeID=a.AccTransTypeID and
   t.AccTransTypeID=1 And
   i.AccessoriesID=b.AccessoriesID and
   b.PUNITOFMEASID=f.UNITOFMEASID And
   c.colourID=b.colourID and
   a.StockTransDate between decode(vSDate,null,'01-Jan-1901',vSDate) and vEDate
   order by a.StockTransDate;


/*AccMRDetailS ORDER BY CHALLAN DATE WISE*/
 elsif pQueryType=8 then
   OPEN data_cursor  FOR

   select a.StockTransNo as Group_by,a.StockId, a.StockTransNo,  a.StockTransDate, b.LineNo, b.RequisitionNo, b.ORDERNO, i.item ,a.REFERENCENO,
   b.StyleNo, c.ColourName, b.Code, b.Count_Size, b.CurrentStock, b.ReqQuantity, b.Quantity, b.SQuantity ,
   f.UNITOFMEAS as PUOM, f.UNITOFMEAS as SUOM , b.remarks
   from T_AccStock a, T_AccStockItems b,T_AccTransactionType t,T_UnitOfMeas f, T_accessories i, T_Colour c
   where a.STOCKID=b.STOCKID and
   t.AccTransTypeID=a.AccTransTypeID and
   t.AccTransTypeID=2 And
   i.AccessoriesID=b.AccessoriesID and
   b.PUNITOFMEASID=f.UNITOFMEASID And
   c.colourID=b.colourID and
   a.StockTransDate between decode(vSDate,null,'01-Jan-1901',vSDate) and vEDate
   order by a.StockTransDate;

/*AccMRDetailS ORDER BY Count_Size WISE*/
 elsif pQueryType=9 then
   OPEN data_cursor  FOR 

   select b.Count_Size as Group_by,a.StockId, a.StockTransNo,  a.StockTransDate, b.LineNo, b.RequisitionNo, b.ORDERNO, i.item ,a.REFERENCENO,
   b.StyleNo, c.ColourName, b.Code, b.Count_Size, b.CurrentStock, b.ReqQuantity, b.Quantity, b.SQuantity ,
   f.UNITOFMEAS as PUOM, f.UNITOFMEAS as SUOM , b.remarks
   from T_AccStock a, T_AccStockItems b,T_AccTransactionType t,T_UnitOfMeas f, T_accessories i, T_Colour c
   where a.STOCKID=b.STOCKID and
   t.AccTransTypeID=a.AccTransTypeID and
   t.AccTransTypeID=2 And
   i.AccessoriesID=b.AccessoriesID and
   b.PUNITOFMEASID=f.UNITOFMEASID And
   c.colourID=b.colourID and
   a.StockTransDate between decode(vSDate,null,'01-Jan-1901',vSDate) and vEDate
   order by a.StockTransDate;

/*AccMRDetailS ORDER BY ColourName WISE*/
 elsif pQueryType=10 then
   OPEN data_cursor  FOR 

   select c.ColourName as Group_by,a.StockId, a.StockTransNo,  a.StockTransDate, b.LineNo, b.RequisitionNo, b.ORDERNO, i.item ,a.REFERENCENO,
   b.StyleNo, c.ColourName, b.Code, b.Count_Size, b.CurrentStock, b.ReqQuantity, b.Quantity, b.SQuantity ,
   f.UNITOFMEAS as PUOM, f.UNITOFMEAS as SUOM , b.remarks
   from T_AccStock a, T_AccStockItems b,T_AccTransactionType t,T_UnitOfMeas f, T_accessories i, T_Colour c
   where a.STOCKID=b.STOCKID and
   t.AccTransTypeID=a.AccTransTypeID and
   t.AccTransTypeID=2 And
   i.AccessoriesID=b.AccessoriesID and
   b.PUNITOFMEASID=f.UNITOFMEASID And
   c.colourID=b.colourID and
   a.StockTransDate between decode(vSDate,null,'01-Jan-1901',vSDate) and vEDate
   order by a.StockTransDate;

/*AccMRDetailS ORDER BY LineNo WISE*/
 elsif pQueryType=11 then
   OPEN data_cursor  FOR 

   select b.LineNo as Group_by,a.StockId, a.StockTransNo,  a.StockTransDate, b.LineNo, b.RequisitionNo, b.ORDERNO, i.item ,a.REFERENCENO,
   b.StyleNo, c.ColourName, b.Code, b.Count_Size, b.CurrentStock, b.ReqQuantity, b.Quantity, b.SQuantity ,
   f.UNITOFMEAS as PUOM, f.UNITOFMEAS as SUOM , b.remarks
   from T_AccStock a, T_AccStockItems b,T_AccTransactionType t,T_UnitOfMeas f, T_accessories i, T_Colour c
   where a.STOCKID=b.STOCKID and
   t.AccTransTypeID=a.AccTransTypeID and
   t.AccTransTypeID=2 And
   i.AccessoriesID=b.AccessoriesID and
   b.PUNITOFMEASID=f.UNITOFMEASID And
   c.colourID=b.colourID and
   a.StockTransDate between decode(vSDate,null,'01-Jan-1901',vSDate) and vEDate
   order by a.StockTransDate;


/*Acc RETURN TO MAIN STORE ORDER BY CHALLAN DATE WISE*/
 elsif pQueryType=12 then
   OPEN data_cursor  FOR

   select a.StockTransNo as Group_by,a.StockId, a.StockTransNo,  a.StockTransDate, b.LineNo, b.RequisitionNo, b.ORDERNO, i.item ,a.REFERENCENO,
   b.StyleNo, c.ColourName, b.Code, b.Count_Size, b.CurrentStock, b.ReqQuantity, b.Quantity, b.SQuantity ,
   f.UNITOFMEAS as PUOM, f.UNITOFMEAS as SUOM , b.remarks
   from T_AccStock a, T_AccStockItems b,T_AccTransactionType t,T_UnitOfMeas f, T_accessories i, T_Colour c
   where a.STOCKID=b.STOCKID and
   t.AccTransTypeID=a.AccTransTypeID and
   a.AccTransTypeID=4 And
   i.AccessoriesID=b.AccessoriesID and
   b.PUNITOFMEASID=f.UNITOFMEASID And
   c.colourID=b.colourID and
   a.StockTransDate between decode(vSDate,null,'01-Jan-1901',vSDate) and vEDate
   order by a.StockTransDate;

/*Acc  RETURN TO MAIN STORE ORDER BY Count_Size WISE*/
 elsif pQueryType=13 then
   OPEN data_cursor  FOR 

   select b.Count_Size as Group_by,a.StockId, a.StockTransNo,  a.StockTransDate, b.LineNo, b.RequisitionNo, b.ORDERNO, i.item ,a.REFERENCENO,
   b.StyleNo, c.ColourName, b.Code, b.Count_Size, b.CurrentStock, b.ReqQuantity, b.Quantity, b.SQuantity ,
   f.UNITOFMEAS as PUOM, f.UNITOFMEAS as SUOM , b.remarks
   from T_AccStock a, T_AccStockItems b,T_AccTransactionType t,T_UnitOfMeas f, T_accessories i, T_Colour c
   where a.STOCKID=b.STOCKID and
   t.AccTransTypeID=a.AccTransTypeID and
   a.AccTransTypeID=4 And
   i.AccessoriesID=b.AccessoriesID and
   b.PUNITOFMEASID=f.UNITOFMEASID And
   c.colourID=b.colourID and
   a.StockTransDate between decode(vSDate,null,'01-Jan-1901',vSDate) and vEDate
   order by a.StockTransDate;

/*Acc RETURN TO MAIN STORE ORDER BY ColourName WISE*/
 elsif pQueryType=14 then
   OPEN data_cursor  FOR 

   select c.ColourName as Group_by,a.StockId, a.StockTransNo,  a.StockTransDate, b.LineNo, b.RequisitionNo, b.ORDERNO, i.item ,a.REFERENCENO,
   b.StyleNo, c.ColourName, b.Code, b.Count_Size, b.CurrentStock, b.ReqQuantity, b.Quantity, b.SQuantity ,
   f.UNITOFMEAS as PUOM, f.UNITOFMEAS as SUOM , b.remarks
   from T_AccStock a, T_AccStockItems b,T_AccTransactionType t,T_UnitOfMeas f, T_accessories i, T_Colour c
   where a.STOCKID=b.STOCKID and
   t.AccTransTypeID=a.AccTransTypeID and
   a.AccTransTypeID=4 And
   i.AccessoriesID=b.AccessoriesID and
   b.PUNITOFMEASID=f.UNITOFMEASID And
   c.colourID=b.colourID and
   a.StockTransDate between decode(vSDate,null,'01-Jan-1901',vSDate) and vEDate
   order by a.StockTransDate;

/*Acc RETURN TO MAIN STORE ORDER BY LineNo WISE*/
 elsif pQueryType=15 then
   OPEN data_cursor  FOR 

   select b.LineNo as Group_by,a.StockId, a.StockTransNo,  a.StockTransDate, b.LineNo, b.RequisitionNo, b.ORDERNO, i.item ,a.REFERENCENO,
   b.StyleNo, c.ColourName, b.Code, b.Count_Size, b.CurrentStock, b.ReqQuantity, b.Quantity, b.SQuantity ,
   f.UNITOFMEAS as PUOM, f.UNITOFMEAS as SUOM , b.remarks
   from T_AccStock a, T_AccStockItems b,T_AccTransactionType t,T_UnitOfMeas f, T_accessories i, T_Colour c
   where a.STOCKID=b.STOCKID and
   t.AccTransTypeID=a.AccTransTypeID and
   a.AccTransTypeID=4 And
   i.AccessoriesID=b.AccessoriesID and
   b.PUNITOFMEASID=f.UNITOFMEASID And
   c.colourID=b.colourID and
   a.StockTransDate between decode(vSDate,null,'01-Jan-1901',vSDate) and vEDate
   order by a.StockTransDate;
 end if;
END GetReportAccStockPosition;
/


PROMPT CREATE OR REPLACE Procedure  46 :: GetReportAccMRRDetailS
CREATE OR REPLACE Procedure GetReportAccMRRDetailS (
   data_cursor IN OUT pReturnData.c_Records,
   pAccStockID IN NUMBER
)
As
Begin
  OPEN data_cursor  FOR
 select b.StockId, b.AccTransTypeID, b.ReferenceNo, b.ReferenceDate, b.StockTransNo, b.StockTransDate, g.SUPPLIERNAME,
 b.SupplierInvoiceNo, b.SupplierInvoiceDate, a.ImpLCNO,getfncDispalyorder(a.GORDERNO) as GORDERNO, a.ORDERNO, i.item ,j.GroupName,
 a.StyleNo, c.ColourName, a.Code, a.Count_Size,a.ReqQuantity, a.Quantity , a.SQuantity , f.UNITOFMEAS as PUOM, f.UNITOFMEAS as SUOM , a.remarks,
 a.unitprice, x.CurrencyName, b.conrate,getfncGAOrderNoFromPIDRef(PIDREF) AS GAORDERNOREF
  from T_AccStockItems a,T_AccStock b, T_AccTransactionType e,t_UnitOfMeas f,T_Supplier g, T_accessories i,T_AccGroup j, T_Colour c, T_currency x
  where a.STOCKID=b.STOCKID and
 b.supplierID=g.supplierID(+) and
 e.AccTransTypeID=1 And
 i.AccessoriesID=a.AccessoriesID(+) and
 j.GroupID=a.GroupID and
 a.PUNITOFMEASID=f.UNITOFMEASID(+) And
 a.colourID=c.colourID(+) and
 b.CURRENCYID=x.CURRENCYID(+) and
 a.STOCKID=pAccStockID;
End GetReportAccMRRDetailS;
/


PROMPT CREATE OR REPLACE Procedure  47 :: GetReportAccMRDetailS
CREATE OR REPLACE Procedure GetReportAccMRDetailS (
   data_cursor IN OUT pReturnData.c_Records,
   pAccStockID IN NUMBER
)
As
Begin
  OPEN data_cursor  FOR 
select a.StockId, a.StockTransNo,  a.StockTransDate, b.LineNo, b.RequisitionNo, b.ORDERNO, i.item , b.StyleNo, c.ColourName, b.Code, b.Count_Size, b.CurrentStock, b.ReqQuantity, b.Quantity as IssueQty, b.SQuantity , f.UNITOFMEAS as PUOM, f.UNITOFMEAS as SUOM , b.remarks
from T_AccStock a, T_AccStockItems b,T_AccTransactionType t,T_UnitOfMeas f, T_accessories i, T_Colour c
where a.STOCKID=b.STOCKID and
t.AccTransTypeID=1 And
i.AccessoriesID=b.AccessoriesID and
b.PUNITOFMEASID=f.UNITOFMEASID And
c.colourID=b.colourID and
b.STOCKID=pAccStockID;
End GetReportAccMRDetailS;
/


PROMPT CREATE OR REPLACE Procedure  48 :: getReportAccRequisitionDetails
CREATE OR REPLACE Procedure getReportAccRequisitionDetails
(
  data_cursor IN OUT pReturnData.c_Records,
  pRequisitionID IN NUMBER
)
AS
BEGIN
    open data_cursor for
    select a.RequisitionID, a.RequisitionNo, a.RequisitionTransDate, b.OrderNo, i.item,  b.StyleNo, c.ColourName,  b.Code,  b.Count_Size,  b.CurrentStock, b.Quantity , b.SQuantity ,f.UNITOFMEAS as PUOM, f.UNITOFMEAS as SUOM , b.Remarks 
    from T_AccRequisition a, T_AccRequisitionItems b,T_UnitOfMeas f, T_accessories i, T_Colour c    
    where a.RequisitionID=b.RequisitionID and    
    i.AccessoriesID=b.AccessoriesID and
    b.PUNITOFMEASID=f.UNITOFMEASID And
    c.colourID=b.colour and
    b.RequisitionID=pRequisitionID
    order by PID;
END getReportAccRequisitionDetails;
/


PROMPT CREATE OR REPLACE Procedure  49 :: GetReportAccSSDetailS
CREATE OR REPLACE Procedure GetReportAccSSDetailS (
   data_cursor IN OUT pReturnData.c_Records,
   pAccStockID IN NUMBER
)
As
Begin
  OPEN data_cursor  FOR 
select a.StockId, a.StockTransNo,  a.StockTransDate, a.AccTransTypeID, b.LineNo, b.ORDERNO, i.item , b.StyleNo, c.ColourName, b.Code, b.Count_Size, b.CurrentStock, b.Quantity, b.SQuantity , f.UNITOFMEAS as PUOM, f.UNITOFMEAS as SUOM , b.remarks
from T_AccStock a, T_AccStockItems b, T_UnitOfMeas f, T_accessories i, T_Colour c
where a.STOCKID=b.STOCKID and
i.AccessoriesID=b.AccessoriesID and
b.PUNITOFMEASID=f.UNITOFMEASID And
c.colourID=b.colourID and
b.STOCKID=pAccStockID;
End GetReportAccSSDetailS;
/



PROMPT CREATE OR REPLACE Procedure  50 :: GetB02DBatchStatus
CREATE OR REPLACE Procedure GetB02DBatchStatus
(
   data_cursor IN OUT pReturnData.c_Records,
   pQueryType IN NUMBER,
   pOrderNo IN NUMBER,
   pClient IN NUMBER DEFAULT NULL, 
   pDBatchID IN NUMBER DEFAULT NULL, 
   sDate IN VARCHAR2,
   eDate IN VARCHAR2
)
AS
  vSDate date;
  vEDate date;
BEGIN
  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  end if;
if pQueryType=2 then
/* Report for TB02 Batch Status */
	open data_cursor for
    	select a.DBatchId, a.BatchNo, a.BatchDate,a.Execute,b.ORDERNO,GetfncWOBType(b.ORDERNO) as DORDERNO,
	e.FabricType,b.OrderlineItem,b.currentStock,
        b.Squantity,b.PunitOfmeasId,b.SUNITOFMEASID,b.YARNBATCHNO,b.DYEDLOTNO,b.Shade,sum(b.Quantity) as Quantity
    	from T_DBatch a,T_DBatchItems b,T_Client c,t_workorder d,T_FabricType e
    	where a.DBatchId=b.DBatchID and d.ClientID=c.ClientID and 
	b.OrderNo=d.OrderNo and b.FabricTypeID=e.FabricTypeID and
	(pClient is NULL or d.ClientID=pClient) and
	(pOrderNo is null or b.OrderNo=pOrderNo) and
	(pDBatchID is null or a.DBatchId=pDBatchID) and
 	a.BatchDate between decode(vSDate,null,'01-jan-1900',vSDate) and vEDate 
group by a.DBatchId, a.BatchNo, a.BatchDate,a.Execute,b.ORDERNO,
	e.FabricType,b.OrderlineItem,b.currentStock,
        b.Squantity,b.PunitOfmeasId,b.SUNITOFMEASID,b.YARNBATCHNO,b.DYEDLOTNO,b.Shade
 	Order by a.BatchNo;

end if;
END GetB02DBatchStatus;
/



PROMPT CREATE OR REPLACE Procedure  51 :: GetDY01DyelineStatus
CREATE OR REPLACE Procedure GetDY01DyelineStatus
(
   data_cursor IN OUT pReturnData.c_Records,
   pQueryType IN NUMBER,
   pOrderNo IN NUMBER,
   pClient IN NUMBER DEFAULT NULL, 
   pDYELINEID IN NUMBER DEFAULT NULL, 
   sDate IN VARCHAR2,
   eDate IN VARCHAR2
)
AS
  vSDate date;
  vEDate date;
BEGIN
  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  end if;
if pQueryType=1 then
/* Report for DY01 Dyeline Status Report*/
	open data_cursor for
  	select a.DYELINEID,a.DBATCHID,a.UDYELINEID,a.DYELINENO,a.DYELINEDATE,
  	a.MACHINEID,a.DLIQUOR,a.DWEIGHT,a.DLIQUORRATIO,a.PACKAGECOUNT,a.DYEINGPROGRAM,
  	a.PRODDATE,a.DSTARTDATETIME,a.DENDDATETIME,a.FINISHEDWEIGHT,
  	a.DYEINGSHIFT,a.DCOMMENTS,a.DPARENT,a.DRECOUNT,a.DCOMPLETE,a.DREDYEINGCOUNT,
  	a.BPOSTEDTOSTOCK,a.EMPLOYEEID,f.FabricType,d.CLIENTNAME,GetfncWOBType(c.ORDERNO) as DORDERNO
	from T_DYELINE a,T_DBatch b,T_DBatchItems c,T_Client d,t_workorder e,T_FabricType f
	where a.DBatchId=b.DBatchID and b.DBatchId=c.DBatchID and e.ClientID=d.ClientID and 
	c.OrderNo=e.OrderNo and 
	c.FabricTypeID=f.FabricTypeID and
	(pClient is NULL or e.ClientID=pClient) and
	(pOrderNo is null or c.OrderNo=pOrderNo) and
	(pDYELINEID is null or a.DYELINEID=pDYELINEID) and
 	a.DYELINEDATE between decode(vSDate,null,'01-jan-1900',vSDate) and vEDate
 	Order by a.DYELINEID;
elsif pQueryType=2 then
/* Report for DY02 Incomplete Dyeline Report*/
	open data_cursor for
  	select a.DYELINEID,a.DBATCHID,a.UDYELINEID,a.DYELINENO,a.DYELINEDATE,
  	a.MACHINEID,a.DLIQUOR,a.DWEIGHT,a.DLIQUORRATIO,a.PACKAGECOUNT,a.DYEINGPROGRAM,
  	a.PRODDATE,a.DSTARTDATETIME,a.DENDDATETIME,a.FINISHEDWEIGHT,
  	a.DYEINGSHIFT,a.DCOMMENTS,a.DPARENT,a.DRECOUNT,a.DCOMPLETE,a.DREDYEINGCOUNT,
  	a.BPOSTEDTOSTOCK,a.EMPLOYEEID,f.FabricType,d.CLIENTNAME,GetfncWOBType(c.ORDERNO) as DORDERNO
	from T_DYELINE a,T_DBatch b,T_DBatchItems c,T_Client d,t_workorder e,T_FabricType f
	where a.DBatchId=b.DBatchID and b.DBatchId=c.DBatchID and e.ClientID=d.ClientID and 
	c.OrderNo=e.OrderNo and 
	c.FabricTypeID=f.FabricTypeID and a.DCOMPLETE=0 and
	(pClient is NULL or e.ClientID=pClient) and
	(pOrderNo is null or c.OrderNo=pOrderNo) and
	(pDYELINEID is null or a.DYELINEID=pDYELINEID) and
 	a.DYELINEDATE between decode(vSDate,null,'01-jan-1900',vSDate) and vEDate
 	Order by a.DYELINEID;
end if;
END GetDY01DyelineStatus;
/




PROMPT CREATE OR REPLACE Procedure  52 :: GetDyedYarnReportKMR
Create or Replace Procedure GetDyedYarnReportKMR
(
   data_cursor IN OUT pReturnData.c_Records,
   pKnitStockID IN NUMBER
)
As
Begin
  OPEN data_cursor  FOR
  select YarnCount,YarnType,a.Quantity,a.Squantity,
  f.UNITOFMEAS as PUOM,G.UNITOFMEAS as SUOM,YARNBATCHNO,a.SHADE,
  a.Remarks,b.STOCKID,b.ReferenceNo,b.ReferenceDate,b.StockTransNO,
  b.StockTransDATE,b.SupplierInvoiceNo,
  b.SupplierInvoiceDate,j.SubConName,h.orderNo,getfncWOBType(h.orderno) as workorder,
  DyedLotNo,k.shadegroupName,l.fabrictype
  from T_KnitStockItems a,T_KnitStock b,T_YarnCount c ,
	T_YarnType d,t_UnitOfMeas f,t_UnitOfMeas G,
	t_WorkOrder h, T_Subcontractors j,t_shadegroup k,t_fabrictype l
  where a.STOCKID=b.STOCKID and
  a.YarnCountID=c.YarnCountID and
  a.shadegroupid=k.shadegroupid and 
  a.fabrictypeid=l.fabrictypeid and 
  a.YarnTypeID=d.YarnTypeID and
  a.PUNITOFMEASID=f.UNITOFMEASID(+) And
  a.SUNITOFMEASID=G.UNITOFMEASID(+) And
  a.orderNo=h.OrderNo And
  b.SubconId=j.SubconId And
  a.STOCKID=pKnitStockID;
End GetDyedYarnReportKMR;
/


PROMPT CREATE OR REPLACE Procedure  53 :: GetDyedYarnRequisition 
CREATE OR REPLACE Procedure GetDyedYarnRequisition 
(
   data_cursor IN OUT pReturnData.c_Records,
   pKnitStockID IN NUMBER
)
As
Begin
  OPEN data_cursor  FOR
  select l.clientname,YarnCount,YarnType,a.Quantity,a.Squantity,
  f.UNITOFMEAS as PUOM,f.UNITOFMEAS as SUOM,YARNBATCHNO,a.SHADE,
  a.Remarks,b.STOCKID,b.ReferenceNo,b.ReferenceDate,b.StockTransNO,
  b.StockTransDATE,E.SUPPLIERNAME,E.SADDRESS,b.SupplierInvoiceNo,m.shadegroupName,
  b.SupplierInvoiceDate,j.SubConName,h.orderNo,getfncWOBType(h.orderno) as workorder,DyedLotNo
  from T_yarnrequisitionitems a,t_yarnrequisition b,T_YarnCount c ,
  T_YarnType d,T_SUPPLIER E,t_UnitOfMeas f,
  t_WorkOrder h,T_Subcontractors j,T_workorder k,T_client l,t_shadegroup m
  where a.STOCKID=b.STOCKID and
  a.shadegroupid=m.shadegroupid(+) and
  a.supplierId=e.supplierID(+) and
  a.YarnCountID=c.YarnCountID(+) and
  a.YarnTypeID=d.YarnTypeID(+) and
  a.PUNITOFMEASID=f.UNITOFMEASID(+) And
  a.orderNo=h.OrderNo And
  b.SubconId=j.SubconId(+) And
  a.orderno=k.orderno and
  k.clientid=l.clientid(+) and
  a.STOCKID=pKnitStockID;
End GetDyedYarnRequisition;
/


PROMPT CREATE OR REPLACE Procedure  54 :: DI005
CREATE OR REPLACE Procedure DI005( 
  data_cursor IN OUT pReturnData.c_Records, 
  pSDate IN VARCHAR2,
  pEDate  IN VARCHAR2
)
AS   
  vSDate date;
  vEDate date;  
BEGIN
  if not pSDate is null then
    vSDate := TO_DATE(pSDate, 'DD/MM/YYYY');
  else
    vSDate := TO_DATE('01-JAN-2000', 'DD/MM/YYYY');
  end if;
  if not pEDate is null then
    vEDate := TO_DATE(pEDate, 'DD/MM/YYYY');
  else
    vEDate := TO_DATE('01-JAN-2050', 'DD/MM/YYYY');
  end if; 
  
  open data_cursor for
    select a.INVOICENO,a.INVOICEDATE,getfncWOBType(a.ORDERNO) as dorderno,c.ClientName,a.DTYPE,
		d.FABRICTYPE,QUANTITY,e.UNITOFMEAS as PUNIT,FINISHEDDIA,FINISHEDGSM,GWT,FWT,SQUANTITY,f.UNITOFMEAS as SUNIT,SHADE,DBATCH,YARNBATCHNO            
    from T_Dinvoice a,T_DinvoiceItems b,T_Client c,T_FABRICTYPE d,T_Unitofmeas e,T_Unitofmeas f
    where a.DINVOICEID=b.DINVOICEID and
		a.CLIENTID=c.CLIENTID and
		b.FABRICTYPEID=d.FABRICTYPEID and
		b.PUNITOFMEASID=e.UNITOFMEASID and
		b.SUNITOFMEASID=f.UNITOFMEASID and
		a.INVOICEDATE between vSDate and vEDate;   
END DI005;
/



PROMPT CREATE OR REPLACE Procedure  55 :: GetReportKnitYarnStockSummary
CREATE OR REPLACE Procedure GetReportKnitYarnStockSummary(
  data_cursor IN OUT pReturnData.c_Records,
  pOrderNo NUMBER
)
AS
BEGIN
open data_cursor for
/* here we calculate the Reportint Procedure*/
select groupID,PID,getfncWOBType(porderno) as workorder,getFncFabricDes(porderno) as Fabric,transname,getfncTranSactionTWiseQty(ownfac,pOrderNo) as AYDL,
getfncTranSactionTWiseQty(othfac,pOrderNo) as otherfactories from 
t_transrpt order by pid; 

end GetReportKnitYarnStockSummary;
/





PROMPT CREATE OR REPLACE Procedure  56 :: GetDyedYarnStockSummaryReport
create or replace Procedure GetDyedYarnStockSummaryReport(                                       
  data_cursor IN OUT pReturnData.c_Records,                                     
  pQueryType IN NUMBER,                                                                                                   
  pStockDate DATE                                                               
)                                                                               
AS                                                                              
BEGIN                                                                           
                                                                                
                                                                                
/*  All Summary Report*/                                                        
  if pQueryType=0 then                                                          
    open data_cursor for                                                        
    select decode(h.GARMENTSORDERREF,NULL,'','FG-'||h.GARMENTSORDERREF)as gorder,b.YARNBATCHNO,
    b.orderno,c.YarnCount,d.YarnType, e.UnitOfMeas,g.SupplierName,b.DyedLotNo,
    sum(b.Quantity*ATLDYS) DyedYarnMainStock, sum(b.Quantity*ATLDYF) DyedYarnFloor, 
    sum(b.Quantity*KSCONDYS) SubContractorDyedYarn
    from T_Knitstock a, T_KnitStockItems b, 
    T_YarnCount c, T_YarnType d, T_UnitOfMeas e, T_knitTransactionType f, 
    T_Supplier g,t_workorder h
    where a.StockID=b.StockID and 
    a.KNTITRANSACTIONTYPEID=f.KNTITRANSACTIONTYPEID and                                                     
    b.yarnCountId=c.yarncountid and                                             
    b.yarntypeid=d.yarntypeID and
    b.orderno=h.orderno and                                       
    b.PunitOfMeasId=e.UnitOfmeasId and
    b.SupplierId=g.SupplierId and                                    
    STOCKTRANSDATE <= pStockDate
    group by h.GARMENTSORDERREF,b.orderno,b.YARNBATCHNO,c.YarnCount, d.YarnType, e.UnitOfMeas,g.SupplierName,b.DyedLotNo
    having sum(Quantity*ATLDYS)>0 or sum(Quantity*ATLDYF)>0 or sum(b.Quantity*KSCONDYS)>0;
 end if;                                                                       
END GetDyedYarnStockSummaryReport;
/



PROMPT CREATE OR REPLACE Procedure  57 :: GetFabricReqReport
CREATE OR REPLACE Procedure GetFabricReqReport
(
   data_cursor IN OUT pReturnData.c_Records,
   pKnitStockID IN NUMBER
)
As
Begin
  OPEN data_cursor  FOR
  select YarnCount,YarnType,FABRICTYPE,a.Quantity,a.Squantity,
  f.UNITOFMEAS as PUOM,f.UNITOFMEAS as SUOM,YARNBATCHNO,a.SHADE,
  a.Remarks,b.STOCKID,b.ReferenceNo,b.ReferenceDate,b.StockTransNO,
  b.StockTransDATE,b.SupplierInvoiceNo,
  b.SupplierInvoiceDate,j.SubConName,h.orderNo,getfncWOBType(h.orderno) as workorder,DyedLotNo,l.clientname,m.shadegroupName
  from T_yarnrequisitionitems a,t_yarnrequisition b,T_YarnCount c ,
  T_YarnType d,t_UnitOfMeas f,
  t_WorkOrder h,T_FabricType i, T_Subcontractors j,T_workorder k,T_client l,t_shadegroup m
  where a.STOCKID=b.STOCKID and
a.shadegroupid=m.shadegroupid and 
  a.YarnCountID=c.YarnCountID and
  a.YarnTypeID=d.YarnTypeID and
  a.FabricTypeID=i.FabricTypeID and
  a.PUNITOFMEASID=f.UNITOFMEASID And
  a.orderNo=h.OrderNo And
  b.SubconId=j.SubconId And
  a.orderno=k.orderno and
  k.clientid=l.clientid and
  a.STOCKID=pKnitStockID;
End GetFabricReqReport;
/



PROMPT CREATE OR REPLACE Procedure  58 :: GetReportMRequisition
CREATE OR REPLACE Procedure GetReportMRequisition(
  data_cursor IN OUT pReturnData.c_Records,
  PAUXSTOCKID IN NUMBER
)
As

Begin
 OPEN data_cursor  FOR
 select a.AuxId,c.AuxName,f.AUXTYPE,UnitOfMeas,SUM(STOCKREQQTY),SUM(STOCKQTY),
 DYEBASE,STOCKDATE,REMARKS,STOCKINVOICENO,AUXSTOCKTYPEID
 from t_auxstockitemRequisition a,t_auxstockRequisition b, T_Auxiliaries c ,
 T_UnitOfMeas D,T_DyeBase e,T_AuxType f
 where a.AUXSTOCKID=b. AUXSTOCKID and
 a.AUXTYPEID=c.AUXTYPEID  and
 a.AUXTYPEID=f.AUXTYPEID  and
 a.AUXID=c.AUXID And
 e.DYEBASEID(+)=c.DYEBASEID and
 c.UnitOfMeasId=d.UnitOfMeasId And
 AUXSTOCKTYPEID=1 And
 a.AUXSTOCKID=PAUXSTOCKID
 GROUP BY a.AuxId,c.AuxName,f.AUXTYPE,UnitOfMeas,DYEBASE,STOCKDATE,REMARKS,STOCKINVOICENO,AUXSTOCKTYPEID;
End GetReportMRequisition;
/


PROMPT CREATE OR REPLACE Procedure  59 :: getTexSPSPoSummary
CREATE OR REPLACE Procedure getTexSPSPoSummary (
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  PeDate IN VARCHAR2
) 
AS 
  vEDate date;
  LastBalanceDate DATE;
  prevMonth NUMBER;
  prevYear NUMBER;
BEGIN 

  if not PEDate is null then
    vEDate := TO_DATE(PeDate, 'DD/MM/YYYY');
  else
    vEDate := TO_DATE('01/01/2300', 'DD/MM/YYYY');
  end if;

/* For Report MachineType Wise*/
if pQueryType=1 then
 OPEN data_cursor  FOR
    select b.PARTID,c.PARTNAME,a.PARTSSTATUS,c.FOREIGNPART,c.MACHINETYPE,c.DESCRIPTION,b.UNITPRICE,
        b.PARTSSTATUSTOID AS PARTSSTATUSFROMID,e.UNITOFMEAS,c.Binno,SUM(b.QTY * d.MSN) as Total
        from T_TEXMCPARTSSTATUS a,T_TexMcStockItems b,T_TEXMCPARTSINFO c,T_TEXMCSTOCKSTATUS d,t_UnitOfMeas e
	where  b.PARTID=c.PARTID and
        b.PARTSSTATUSTOID=a.PARTSSTATUSID and
        B.TEXMCSTOCKTYPEID=d.TEXMCSTOCKTYPEID and b.PARTSSTATUSFROMID=d.PARTSSTATUSFROMID and
        b.PARTSSTATUSTOID=d.PARTSSTATUSTOID and c.UNITOFMEASID=e.UNITOFMEASID
        group by  b.PARTID,c.PARTNAME,a.PARTSSTATUS,c.FOREIGNPART,c.MACHINETYPE,c.DESCRIPTION,b.UNITPRICE,
        b.PARTSSTATUSTOID,e.UNITOFMEAS,c.Binno
        having sum(b.Qty*d.MSN)>0
  order by MachineType;

/* For Report Binno wise*/
  elsif pQueryType=5 then
      OPEN data_cursor  FOR
    select b.PARTID,c.PARTNAME,a.PARTSSTATUS,c.FOREIGNPART,c.MACHINETYPE,c.DESCRIPTION,b.UNITPRICE,
        b.PARTSSTATUSTOID AS PARTSSTATUSFROMID,e.UNITOFMEAS,c.Binno,SUM(b.QTY * d.MSN) as Total
        from T_TEXMCPARTSSTATUS a,T_TexMcStockItems b,T_TEXMCPARTSINFO c,T_TEXMCSTOCKSTATUS d,t_UnitOfMeas e
	where  b.PARTID=c.PARTID and
        b.PARTSSTATUSTOID=a.PARTSSTATUSID and
        B.TEXMCSTOCKTYPEID=d.TEXMCSTOCKTYPEID and b.PARTSSTATUSFROMID=d.PARTSSTATUSFROMID and
        b.PARTSSTATUSTOID=d.PARTSSTATUSTOID and c.UNITOFMEASID=e.UNITOFMEASID
        group by  b.PARTID,c.PARTNAME,a.PARTSSTATUS,c.FOREIGNPART,c.MACHINETYPE,c.DESCRIPTION,b.UNITPRICE,
        b.PARTSSTATUSTOID,e.UNITOFMEAS,c.Binno
        having sum(b.Qty*d.MSN)>0
  order by c.Binno;

/* For Report PartName wise*/
  elsif pQueryType=6 then
      OPEN data_cursor  FOR
    select b.PARTID,c.PARTNAME,a.PARTSSTATUS,c.FOREIGNPART,c.MACHINETYPE,c.DESCRIPTION,b.UNITPRICE,
        b.PARTSSTATUSTOID AS PARTSSTATUSFROMID,e.UNITOFMEAS,c.Binno,SUM(b.QTY * d.MSN) as Total
        from T_TEXMCPARTSSTATUS a,T_TexMcStockItems b,T_TEXMCPARTSINFO c,T_TEXMCSTOCKSTATUS d,t_UnitOfMeas e
	where  b.PARTID=c.PARTID and
        b.PARTSSTATUSTOID=a.PARTSSTATUSID and
        B.TEXMCSTOCKTYPEID=d.TEXMCSTOCKTYPEID and b.PARTSSTATUSFROMID=d.PARTSSTATUSFROMID and
        b.PARTSSTATUSTOID=d.PARTSSTATUSTOID and c.UNITOFMEASID=e.UNITOFMEASID
        group by  b.PARTID,c.PARTNAME,a.PARTSSTATUS,c.FOREIGNPART,c.MACHINETYPE,c.DESCRIPTION,b.UNITPRICE,
        b.PARTSSTATUSTOID,e.UNITOFMEAS,c.Binno
        having sum(b.Qty*d.MSN)>0
        order by c.PARTNAME;

/* For Report PARTID wise*/
  elsif pQueryType=7 then
      OPEN data_cursor  FOR
    select b.PARTID,c.PARTNAME,a.PARTSSTATUS,c.FOREIGNPART,c.MACHINETYPE,c.DESCRIPTION,b.UNITPRICE,
        b.PARTSSTATUSTOID AS PARTSSTATUSFROMID,e.UNITOFMEAS,c.Binno,SUM(b.QTY * d.MSN) as Total
        from T_TEXMCPARTSSTATUS a,T_TexMcStockItems b,T_TEXMCPARTSINFO c,T_TEXMCSTOCKSTATUS d,t_UnitOfMeas e
	where  b.PARTID=c.PARTID and
        b.PARTSSTATUSTOID=a.PARTSSTATUSID and
        B.TEXMCSTOCKTYPEID=d.TEXMCSTOCKTYPEID and b.PARTSSTATUSFROMID=d.PARTSSTATUSFROMID and
        b.PARTSSTATUSTOID=d.PARTSSTATUSTOID and c.UNITOFMEASID=e.UNITOFMEASID
        group by  b.PARTID,c.PARTNAME,a.PARTSSTATUS,c.FOREIGNPART,c.MACHINETYPE,c.DESCRIPTION,b.UNITPRICE,
        b.PARTSSTATUSTOID,e.UNITOFMEAS,c.Binno
        having sum(b.Qty*d.MSN)>0
  order by b.PARTID;

/* For Report ForeignPart wise*/
  elsif pQueryType=8 then
      OPEN data_cursor  FOR
    select b.PARTID,c.PARTNAME,a.PARTSSTATUS,c.FOREIGNPART,c.MACHINETYPE,c.DESCRIPTION,b.UNITPRICE,
        b.PARTSSTATUSTOID AS PARTSSTATUSFROMID,e.UNITOFMEAS,c.Binno,SUM(b.QTY * d.MSN) as Total
        from T_TEXMCPARTSSTATUS a,T_TexMcStockItems b,T_TEXMCPARTSINFO c,T_TEXMCSTOCKSTATUS d,t_UnitOfMeas e
	where  b.PARTID=c.PARTID and
        b.PARTSSTATUSTOID=a.PARTSSTATUSID and
        B.TEXMCSTOCKTYPEID=d.TEXMCSTOCKTYPEID and b.PARTSSTATUSFROMID=d.PARTSSTATUSFROMID and
        b.PARTSSTATUSTOID=d.PARTSSTATUSTOID and c.UNITOFMEASID=e.UNITOFMEASID
        group by  b.PARTID,c.PARTNAME,a.PARTSSTATUS,c.FOREIGNPART,c.MACHINETYPE,c.DESCRIPTION,b.UNITPRICE,
        b.PARTSSTATUSTOID,e.UNITOFMEAS,c.Binno
        having sum(b.Qty*d.MSN)>0
  order by ForeignPart;
  end if;
END getTexSPSPoSummary; 
/



PROMPT CREATE OR REPLACE Procedure  60 :: getTEXSPSPoDetails
CREATE OR REPLACE Procedure getTEXSPSPoDetails(
  data_cursor IN OUT pReturnData.c_Records,
  PsDate IN VARCHAR2,
  pEDate IN VARCHAR2,
  pPROJCODE IN Number,
  pCCATACODE in Number
) 
AS 
  vSDate date;
  LastBalanceDate DATE;
  vEDate DATE;
BEGIN 


  if not pSDate is null then
    vSDate := TO_DATE(pSDate, 'DD/MM/YYYY');
  else
    vSDate := TO_DATE('01/01/1900', 'DD/MM/YYYY');
  end if;
  if not pEDate is null then
    vEDate := TO_DATE(pEDate, 'DD/MM/YYYY');
  else
    vEDate := TO_DATE('01/01/2300', 'DD/MM/YYYY');
  end if;

 OPEN data_cursor  FOR
  select MachineType,PartName,Vsdate StockDate,'Opening' ChallanNo,
  a.PARTID,ForeignPart,ReorderQty,
  Description,'Store' BinNo,UNITOFMEAS,
  Sum(nvl(decode(d.TEXMCSTOCKTYPEID,1,QTY,3,QTY),0)) Receive,
  Sum(nvl(decode(d.TEXMCSTOCKTYPEID,2,QTY),0)) Issue
  from T_TexMcPartsInfo a,T_UnitOfMeas b,T_TexMcStockItems c,T_TexMcStock d,T_TexMcStockType e
  where b.UnitOfMeasId=a.UnitOfMeasId and
  c.StockId=d.StockId and 
  e.TEXMCSTOCKTYPEID=d.TEXMCSTOCKTYPEID and
  a.PARTID=c.PARTID and
  StockDate <= vSDate And
  (pPROJCODE is Null or PROJCODE=pPROJCODE) And
  (pCCATACODE is Null or pCCATACODE=CCATACODE)
  group by MachineType,PartName,
  a.PARTID,ForeignPart,ReorderQty,
  Description,UNITOFMEAS
  Union all
  select MachineType,PartName,StockDate,ChallanNo,
  a.PARTID,ForeignPart,ReorderQty,
  Description,BinNo,UNITOFMEAS,
  nvl(decode(d.TEXMCSTOCKTYPEID,1,QTY,3,QTY),0) Receive,
  nvl(decode(d.TEXMCSTOCKTYPEID,2,QTY),0) Issue
  from T_TexMcPartsInfo a,T_UnitOfMeas b,T_TexMcStockItems c,T_TexMcStock d,T_TexMcStockType e
  where b.UnitOfMeasId=a.UnitOfMeasId and
  c.StockId=d.StockId and 
  e.TEXMCSTOCKTYPEID=d.TEXMCSTOCKTYPEID and
  a.PARTID=c.PARTID and
  StockDate Between vSDate And vEDate And
  (pPROJCODE is Null or PROJCODE=pPROJCODE) And
  (pCCATACODE is Null or pCCATACODE=CCATACODE);
 
END getTEXSPSPoDetails; 
/


PROMPT CREATE OR REPLACE Procedure  61 :: getTEXSPStockVal
CREATE OR REPLACE Procedure getTEXSPStockVal(
  data_cursor IN OUT pReturnData.c_Records,
  PeDate IN VARCHAR2
) 
AS 
  vEDate date;
  LastBalanceDate DATE;
  prevMonth NUMBER;
  prevYear NUMBER;
BEGIN 

  if not PEDate is null then
    vEDate := TO_DATE(PeDate, 'DD/MM/YYYY');
  else
    vEDate := TO_DATE('01/01/2300', 'DD/MM/YYYY');
  end if;


  OPEN data_cursor  FOR
  select MachineType,a.PARTID,ForeignPart,PartName,
  UnitOfMeas,MACAVGPRICE,MachineNo,
  sum(decode(d.TEXMCSTOCKTYPEID,1,QTY,2,-QTY,3,QTY)) Total
  from T_TexMcPartsInfo a,T_UnitOfMeas b,T_TexMcStockItems c,
  T_TexMcStock d,T_TexMcStockType e,T_TexMACHINEWAVGPRICE f
  where b.UnitOfMeasId=a.UnitOfMeasId and
  c.StockId=d.StockId and 
  e.TEXMCSTOCKTYPEID=d.TEXMCSTOCKTYPEID and
  a.PARTID=c.PARTID And
  a.PARTID=f.PARTID(+) And
  StockDate <= vEDate
  group by MachineType,a.PARTID,ForeignPart,
  PartName,UnitOfMeas,MACAVGPRICE,MachineNo;
END getTEXSPStockVal; 
/


PROMPT CREATE OR REPLACE Procedure  62 :: getTexSPConsumption
CREATE OR REPLACE Procedure  getTexSPConsumption (
  data_cursor IN OUT pReturnData.c_Records,
  PsDate IN VARCHAR2,
  pEDate IN VARCHAR2,
  PMACHINENO in Number DEFAULT NULL
) 
AS 
  vSDate date;
  LastBalanceDate DATE;
  vEDate DATE;
BEGIN 

  if not pSDate is null then
    vSDate := TO_DATE(pSDate, 'DD/MM/YYYY');
  else
    vSDate := TO_DATE('01/01/1900', 'DD/MM/YYYY');
  end if;
  if not pEDate is null then
    vEDate := TO_DATE(pEDate, 'DD/MM/YYYY');
  else
    vEDate := TO_DATE('01/01/2300', 'DD/MM/YYYY');
  end if;

  OPEN data_cursor  FOR
  select MACHINENO,MachineType,PartName,ChallanNo,StockDate,MCLISTNAME,
  nvl(decode(e.TEXMCSTOCKTYPEID,2,QTY),0) Issue,
  a.PARTID,UnitOfMeas,ISSUEFOR,MACAVGPRICE
  from T_TexMcPartsInfo a,T_UnitOfMeas b,T_TexMcStockItems c,T_TexMcList d,
  T_TexMcStock e,T_TexMcStockType f,T_TexMACHINEWAVGPRICE g
  where b.UnitOfMeasId=a.UnitOfMeasId and
  c.StockId=e.StockId and 
  f.TEXMCSTOCKTYPEID=e.TEXMCSTOCKTYPEID and
  a.PARTID=c.PARTID and
  a.PARTID=g.PARTID(+) And
  d.McListId=c.IssueFor and
  e.TEXMCSTOCKTYPEID=2 And
  StockDate Between vSDate And vEDate And
  (PMACHINENO is Null or MCLISTID=pMACHINENO);
END  getTexSPConsumption;
/
---------------------------------------------------------------------------------
-- Textile Machine Parts Reports:TMP1,TMP2,TMP3,TMP4,TMP5,TMP6,TMP7,TMP8
---------------------------------------------------------------------------------



PROMPT CREATE OR REPLACE Procedure  63 :: getTexMcStockDet
CREATE OR REPLACE Procedure getTexMcStockDet (
 data_cursor IN OUT pReturnData.c_Records,
  pPartId IN NUMBER DEFAULT NULL,
  sDate IN VARCHAR2 DEFAULT NULL, 
  eDate IN VARCHAR2 DEFAULT NULL
) 
AS 
  vSDate date;
  vEDate date;
  pYear VARCHAR2(4);
  pMonth VARCHAR2(2);
  FirstDayMonth DATE;
BEGIN 

  vSDate := TO_DATE('01/01/1900', 'DD/MM/YYYY');
  vEDate := TO_DATE('01/01/2999', 'DD/MM/YYYY');
  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  end if;

  OPEN data_cursor  FOR
      SELECT 0 as StockId, vSDate StockDate, 
      '(Previous Balance)' ChallanNo, PartName,
      sum(DECODE(a.TEXMCSTOCKTYPEID,1,b.Qty,0)) StockIn,
      sum(DECODE(a.TEXMCSTOCKTYPEID,3,b.Qty,0)) StockOut
      FROM T_TexMcStock a, T_TexMcStockItems b,T_TexMcPartsInfo c
      WHERE a.StockId = b.StockId and
      b.partid=c.partid And
      a.StockDate < vSDate and
      b.PartId=pPartId
      Group by Partname
      union all
      SELECT a.StockId, a.StockDate, a.ChallanNo,c.PartName, 
      DECODE(a.TEXMCSTOCKTYPEID,1,b.Qty,0) StockIn,
      DECODE(a.TEXMCSTOCKTYPEID,3,b.Qty,0) StockOut
      FROM T_TexMcStock a, T_TexMcStockItems b,T_TexMcPartsInfo c
      WHERE a.StockId = b.StockId and
      b.partid=c.partid And
      a.StockDate>=vSDate and a.StockDate<=vEDate and
      b.PartId=pPartId;

END getTexMcStockDet; 
/  

------------------------------------------------------------- 
-- END of Textile Machine Parts Reports
------------------------------------------------------------- 

-- for report WL8, WL9  
-- get workorder items information
-- 8 input parameters, first one is REF CURSOR, last 6 can be null

PROMPT CREATE OR REPLACE Procedure  64 :: getGLWoItemsList 
CREATE OR REPLACE Procedure getGLWoItemsList (
  data_cursor IN OUT pReturnData.c_Records, 
  pType IN VARCHAR2, 
  pClient IN NUMBER DEFAULT NULL, 
  pWStatus IN NUMBER  DEFAULT NULL, 
  pSDate IN VARCHAR2  DEFAULT NULL, 
  pEDate IN VARCHAR2  DEFAULT NULL, 
  pWoNumber IN NUMBER  DEFAULT NULL, 
  pEmployee IN VARCHAR2  DEFAULT NULL
) 
AS 
  vSDate date;
  vEDate date;
BEGIN 

  if not pSDate is null then
    vSDate := TO_DATE(pSDate, 'DD/MM/YYYY');
  end if;
  if not pEDate is null then
    vEDate := TO_DATE(pEDate, 'DD/MM/YYYY');
  end if;

  OPEN Data_cursor FOR
  SELECT a.OrderTypeID,getfncDispalyorder(a.GORDERNO) as DOrder, a.GORDERNO, a.ClientId,   a.GORDERDATE,a.SalesTermId,a.Clientsref, a.CurrencyId, a.ConRate, a.WCancelled, a.WRevised,
  b.WoItemSl, b.Shade,b.PRICE,b.QUANTITY,(b.PRICE*b.QUANTITY) AS AMOUNT,(b.PRICE*b.QUANTITY)*a.ConRate AS   EQRATK,c.DESCRIPTION as OrderType, 
  d.ClientName, e.SalesTerm, f.CurrencyName, g.Employeename,h.ORDERSTATUS,k.UnitOfMeas
  FROM T_GWorkOrder a, T_GORDERITEMS b, T_Gordertype c, T_Client d,
  T_SalesTerm e, T_Currency f, T_Employee g, T_ORDERSTATUS h,t_unitOfmeas k
  WHERE a.GORDERNO = B.GORDERNO and
  a.OrderTypeID = c.ORDERTYPE and 
  e.SalesTermId = a.SalesTermId and
  f.CurrencyId = a.CurrencyId and
  d.ClientId = a.ClientId and 
  g.EmployeeId = a.SALESPERSONID and
  h.ORDERSTATUSID = a.ORDERSTATUSID and
  k.unitofmeasid=b.unitofmeasid and
  a.OrderTypeID=pType and
  a.WCancelled=0 and
  (pClient is NULL or a.ClientId=pClient) and
  (pWStatus is NULL or a.ORDERSTATUSID=pWStatus) and
  (pSDate is NULL or a.GORDERDATE>=vSDate) and
  (pEDate is NULL or a.GORDERDATE<=vEDate) and
  (pWoNumber is NULL or a.GORDERNO=pWoNumber) and
  (pEmployee is NULL or a.SALESPERSONID =pEmployee);

END getGLWoItemsList;
/  


-- for report WL8, WL9  
-- get workorder items information
-- 8 input parameters, first one is REF CURSOR, last 6 can be null

PROMPT CREATE OR REPLACE Procedure  65 :: getTWLWoItemsList
CREATE OR REPLACE Procedure getTWLWoItemsList(
  data_cursor IN OUT pReturnData.c_Records, 
  pType IN VARCHAR2,
  pClient IN NUMBER DEFAULT NULL, 
  pORDERSTATUSID IN NUMBER  DEFAULT NULL, 
  pSDate IN VARCHAR2  DEFAULT NULL, 
  pEDate IN VARCHAR2  DEFAULT NULL, 
  pORDERNO IN NUMBER  DEFAULT NULL, 
  pEmployee IN VARCHAR2  DEFAULT NULL
) 
AS 
  vSDate date;
  vEDate date;
BEGIN 

  if not pSDate is null then
    vSDate := TO_DATE(pSDate, 'DD/MM/YYYY');
  end if;
  if not pEDate is null then
    vEDate := TO_DATE(pEDate, 'DD/MM/YYYY');
  end if;

  OPEN Data_cursor FOR
   SELECT a.BASICTYPEID,getfncWOBType(a.orderno) as Dworkorder,a.ORDERNO,a.ClientId,a.ContactPerson,
  a.ORDERDATE,e.SalesTerm,a.CurrencyId, a.ConRate, a.WCancelled, a.WRevised,a.CLIENTSREF,a.ORDERREMARKS,
  getFncbasicWorkOrder(a.ORDERNO)  as BasicWorkOrder,a.DELIVERYPLACE,a.GARMENTSORDERREF,getFncYarnDes(b.ORDERLINEITEM) as YarnDesc,a.CLIENTSREF,
  b.WoItemSl, b.Shade,b.RATE,b.QUANTITY,(b.RATE*b.QUANTITY) AS AMOUNT,(b.RATE*b.QUANTITY)*a.ConRate AS     EQRATK,c.DESCRIPTION as OrderType,d.ClientName, e.SalesTerm,   f.CurrencyName, g.Employeename,h.ORDERSTATUS,k.UnitOfMeas
  FROM T_WorkOrder a, T_ORDERITEMS b, T_ordertype c, T_Client d,
  T_SalesTerm e, T_Currency f, T_Employee g, T_ORDERSTATUS h,t_unitOfmeas k
  where a.ORDERNO =b.ORDERNO and
  a.BASICTYPEID=c.ORDERCODE and
  e.SalesTermId = a.SalesTermId and
  f.CurrencyId = a.CurrencyId and
  d.ClientId = a.ClientId and 
  g.EmployeeId = a.SALESPERSONID and
  h.ORDERSTATUSID = a.ORDERSTATUSID and
  k.unitofmeasid=b.unitofmeasid and
  a.BASICTYPEID=pType and
  a.WCancelled=0 and
  (pClient is NULL or a.ClientId=pClient) and
  (pORDERSTATUSID is NULL or a.ORDERSTATUSID=pORDERSTATUSID) and
  (pSDate is NULL or a.ORDERDATE>=vSDate) and
  (pEDate is NULL or a.ORDERDATE<=vEDate) and
  (pORDERNO is NULL or a.ORDERNO=pORDERNO) and
  (pEmployee is NULL or a.SALESPERSONID =pEmployee);

END getTWLWoItemsList;
/  




-- for report WL8, WL9  
-- get workorder items information
-- 8 input parameters, first one is REF CURSOR, last 6 can be null

PROMPT CREATE OR REPLACE Procedure  66 :: getGL1WoItemsList
CREATE OR REPLACE Procedure getGL1WoItemsList (
  data_cursor IN OUT pReturnData.c_Records, 
  pType IN VARCHAR2, 
  pQueryType IN NUMBER,
  pClient IN NUMBER DEFAULT NULL, 
  pWStatus IN NUMBER  DEFAULT NULL, 
  pSDate IN VARCHAR2  DEFAULT NULL, 
  pEDate IN VARCHAR2  DEFAULT NULL, 
  pWoNumber IN NUMBER  DEFAULT NULL, 
  pEmployee IN VARCHAR2  DEFAULT NULL
) 
AS 
  vSDate date;
  vEDate date;
BEGIN 

  if not pSDate is null then
    vSDate := TO_DATE(pSDate, 'DD/MM/YYYY');
  end if;
  if not pEDate is null then
    vEDate := TO_DATE(pEDate, 'DD/MM/YYYY');
  end if;
  if pQueryType=0 then
  OPEN Data_cursor FOR
  SELECT a.OrderTypeID,getfncDispalyorder(a.GORDERNO) as DOrder, a.GORDERNO, a.ClientId,   a.GORDERDATE,a.SalesTermId,a.Clientsref, a.CurrencyId, a.ConRate, a.WCancelled, a.WRevised,
  b.WoItemSl,b.style,b.Shade,b.PRICE,b.QUANTITY,(b.PRICE*b.QUANTITY) AS AMOUNT,(b.PRICE*b.QUANTITY)*a.ConRate AS   EQRATK,c.DESCRIPTION as OrderType, 
  d.ClientName, e.SalesTerm, f.CurrencyName, g.Employeename,h.ORDERSTATUS,k.UnitOfMeas
  FROM T_GWorkOrder a, T_GORDERITEMS b, T_Gordertype c, T_Client d,
  T_SalesTerm e, T_Currency f, T_Employee g, T_ORDERSTATUS h,t_unitOfmeas k
  WHERE a.GORDERNO = B.GORDERNO and
  a.OrderTypeID = c.ORDERTYPE and 
  e.SalesTermId = a.SalesTermId and
  f.CurrencyId = a.CurrencyId and
  d.ClientId = a.ClientId and 
  g.EmployeeId = a.SALESPERSONID and
  h.ORDERSTATUSID = a.ORDERSTATUSID and
  k.unitofmeasid=b.unitofmeasid and
  a.OrderTypeID=pType and
  a.WCancelled=0 and
  (pClient is NULL or a.ClientId=pClient) and
  (pWStatus is NULL or a.ORDERSTATUSID=pWStatus) and
  (pSDate is NULL or a.GORDERDATE>=vSDate) and
  (pEDate is NULL or a.GORDERDATE<=vEDate) and
  (pWoNumber is NULL or a.GORDERNO=pWoNumber) and
  (pEmployee is NULL or a.SALESPERSONID =pEmployee) order by b.style;

 elsif pQueryType=1 then
  OPEN Data_cursor FOR
  SELECT a.OrderTypeID,getfncDispalyorder(a.GORDERNO) as DOrder, a.GORDERNO, a.ClientId,     a.GORDERDATE,a.SalesTermId,a.Clientsref, a.CurrencyId, a.ConRate, a.WCancelled, a.WRevised,
  b.WoItemSl,b.style,b.Shade,b.PRICE,b.QUANTITY,(b.PRICE*b.QUANTITY) AS AMOUNT,(b.PRICE*b.QUANTITY)*a.ConRate AS     EQRATK,c.DESCRIPTION as OrderType, 
  d.ClientName, e.SalesTerm, f.CurrencyName, g.Employeename,h.ORDERSTATUS,k.UnitOfMeas
  FROM T_GWorkOrder a, T_GORDERITEMS b, T_Gordertype c, T_Client d,
  T_SalesTerm e, T_Currency f, T_Employee g, T_ORDERSTATUS h,t_unitOfmeas k
  WHERE a.GORDERNO = B.GORDERNO and
  a.OrderTypeID = c.ORDERTYPE and 
  e.SalesTermId = a.SalesTermId and
  f.CurrencyId = a.CurrencyId and
  d.ClientId = a.ClientId and 
  g.EmployeeId = a.SALESPERSONID and
  h.ORDERSTATUSID = a.ORDERSTATUSID and
  k.unitofmeasid=b.unitofmeasid and
  a.OrderTypeID=pType and
  a.WCancelled=0 and
  (pClient is NULL or a.ClientId=pClient) and
  (pWStatus is NULL or a.ORDERSTATUSID=pWStatus) and
  (pSDate is NULL or a.GORDERDATE>=vSDate) and
  (pEDate is NULL or a.GORDERDATE<=vEDate) and
  (pWoNumber is NULL or a.GORDERNO=pWoNumber) and
  (pEmployee is NULL or a.SALESPERSONID =pEmployee) order by a.Clientsref;

end if;
END getGL1WoItemsList;
/  

PROMPT CREATE OR REPLACE Procedure  67 :: GetReportBTBLCInfo
CREATE OR REPLACE Procedure GetReportBTBLCInfo
(  
  data_cursor IN OUT pReturnData.c_Records,
  pExpLCNo IN NUMBER  
)
AS	
BEGIN

  OPEN data_cursor for
    with Yarn AS(
    Select a.LCNo,  sum(b.ValueFC) as AmountFC, sum(b.ValueTk) as AmountTk
    from T_YarnImpLC a,T_YarnImpLCItems b
    Where  a.LCNo=b.LCNo and  EXPLCNO=pExpLCNo and  IMPLCTYPEID=3 and Linked=1 
    GROUP BY a.LCNo
  ), Aux AS(
    Select a.LCNo,  sum(b.ValueFC) as AmountFC, sum(b.ValueTk) as AmountTk
    from T_AuxImpLC a,T_AuxImpLCItems b
    Where  a.LCNo=b.LCNo and  EXPLCNO=pExpLCNo and  IMPLCTYPEID=3 and Linked=1 
    GROUP BY a.LCNo
  ), Acc AS(
    Select a.LCNo,  sum(b.ValueFC) as AmountFC, sum(b.ValueTk) as AmountTk
    from T_AccImpLC a,T_AccImpLCItems b
    Where  a.LCNo=b.LCNo and  EXPLCNO=pExpLCNo and  IMPLCTYPEID=3 and Linked=1
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

END GetReportBTBLCInfo;
/


PROMPT CREATE OR REPLACE Procedure  68 :: getDyelineProdReport
CREATE OR REPLACE Procedure getDyelineProdReport (
  data_cursor IN OUT pReturnData.c_Records,
  pSDate IN VARCHAR2, 
  pEDate IN VARCHAR2
) 
AS 
  vSDate date;
  vEDate date;
BEGIN 

  vSDate := TO_DATE(pSDate, 'DD/MM/YYYY');
  vEDate := TO_DATE(pEDate, 'DD/MM/YYYY');

OPEN data_cursor for    
  SELECT d.DBATCHID,d.ProdDate, d.MachineId, e.MachineName,b.ORDERNO,GetfncWOBType(b.OrderNo) as btype,
  f.CLIENTNAME,b.SHADE,d.DyelineId, d.UDyelineId, d.dParent, d.dComplete,
  d.dStartDateTime, d.dEndDateTime,b.QUANTITY AS Qty,
  getProdHour(d.dStartDateTime, d.dEndDateTime) ProdHour, 
  DECODE(d.DyeingShift, 'A', b.QUANTITY,0) ShiftA, /* DECODE(d.DyeingShift, 'A', d.DWEIGHT,0) ShiftA, */
  DECODE(d.DyeingShift, 'B', b.QUANTITY,0) ShiftB, 
  DECODE(d.DyeingShift, 'C', b.QUANTITY,0) ShiftC,
  DECODE(d.DyeingShift, NULL, d.DWEIGHT,0) ShiftOther 
  FROM T_DBATCH a,T_DBATCHITEMS b,T_WorkOrder c,T_knitMachineinfo e,T_Dyeline d,T_CLIENT f
  where  a.DBATCHID=d.DBATCHID and 
  	a.DBATCHID=b.DBATCHID and
	b.ORDERNO=c.ORDERNO AND
  	e.MachineId = d.MachineId and
	f.CLIENTID=c.CLIENTID and 
  	DYELINEDATE between decode(vSDate,null,'01-jan-2000',vSDate) and vEDate;
  
END getDyelineProdReport; 
/  





PROMPT CREATE OR REPLACE Procedure  69 :: getDYReports
CREATE OR REPLACE Procedure getDYReports (
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pSDate IN VARCHAR2 DEFAULT NULL, 
  pEDate IN VARCHAR2 DEFAULT NULL
) 
AS 
  vSDate date;
  vEDate date;
BEGIN 

  if not pSDate is null then
    vSDate := TO_DATE(pSDate, 'DD/MM/YYYY');
  end if;
  if not pEDate is null then
    vEDate := TO_DATE(pEDate, 'DD/MM/YYYY');
  end if;

  if pQueryType=0 then /* DyelineCostingByWO	DY61*/ 
  OPEN data_cursor for  
	
  SELECT d.DBATCHID,d.ProdDate, d.MachineId, e.MachineName,b.ORDERNO,GetfncWOBType(b.OrderNo) as btype,
  f.CLIENTNAME,d.DWEIGHT,d.FINISHEDWEIGHT,b.SHADE,d.DyelineId, d.UDyelineId, d.dParent, d.dComplete,
  d.dStartDateTime, d.dEndDateTime,b.QUANTITY AS Qty,
  getProdHour(d.dStartDateTime, d.dEndDateTime) ProdHour,x.ChemCost as  ChemCost,x.DyeCost as DyeCost,(x.ChemCost+x.DyeCost) as TotalCost
  FROM T_DBATCH a,T_DBATCHITEMS b,T_WorkOrder c,T_Dyeline d,T_knitMachineinfo e,T_CLIENT f,
  (select h.DYELINEID,sum(DECODE(h.AuxTypeId,1,h.AuxTotQtyGm*NVL(g.WAVGPRICE,0)/1000,0)) ChemCost,
	sum(DECODE(h.AuxTypeId,2,h.AuxTotQtyGm*NVL(g.WAVGPRICE,0)/1000,0))  DyeCost
 	from T_AUXILIARIES g,T_DSubItems h
 	where g.AuxTypeId(+) = h.AuxTypeId and
   	g.AuxId(+) = h.AuxId 
	group by h.DYELINEID)  x
  where  a.DBATCHID=d.DBATCHID and 
  	a.DBATCHID=b.DBATCHID and
	b.ORDERNO=c.ORDERNO AND
  	e.MachineId = d.MachineId and
	f.CLIENTID=c.CLIENTID and 
	d.DYELINEID=x.DYELINEID and 
  	DYELINEDATE between decode(vSDate,null,'01-jan-2000',vSDate) and vEDate;

  elsif pQueryType=1 then /* DyelineCostingByWO	 DL06*/ 

  OPEN data_cursor for  

  SELECT d.AuxTypeId, f.AuxType, d.AuxId, a.DyeBase, DECODE(d.AuxTypeId,2,(a.DyeBase || '- '||d.AuxName),d.AuxName) AS AuxName,d.WAVGPRICE,
  Sum(Nvl(z.AuxQty,0)) AuxQty
  FROM T_DyeBase a, T_Auxiliaries d, 
  T_AuxType f, 
  ( select AuxTypeId, AuxId,Sum(AuxTotQtyGM/1000) AuxQty
  from T_Dyeline a,T_DSubItems b
  where a.DyelineID=b.DyelineID  and PRODDATE  between decode(vSDate,null,'01-jan-2000',vSDate) and vEDate
  group by AuxTypeId, AuxId)z
  WHERE
  a.DyeBaseId(+) = d.DyeBaseId and
  d.AuxTypeId = f.AuxTypeId and
  z.AuxTypeId = d.AuxTypeId and
  z.AuxId = d.AuxId 
   group by d.AuxTypeId, f.AuxType, d.AuxId, a.DyeBase, d.AuxName,d.WAVGPRICE;
  end if;
END getDYReports; 
/ 




PROMPT CREATE OR REPLACE Procedure  70 :: T124ReportGFabricSummary

CREATE OR REPLACE Procedure T124ReportGFabricSummary(
  data_cursor IN OUT pReturnData.c_Records, 
  pQueryType IN NUMBER,      
  pORDERNO IN NUMBER  DEFAULT NULL, 
  pFabriTypeID IN VARCHAR2  DEFAULT NULL,  
  pSDate IN VARCHAR2  DEFAULT NULL, 
  pEDate IN VARCHAR2  DEFAULT NULL 
) 
AS 
  vSDate date;
  vEDate date;
 
BEGIN 

  if not pSDate is null then
    vSDate := TO_DATE(pSDate, 'DD/MM/YYYY');
  end if;
  if not pEDate is null then
    vEDate := TO_DATE(pEDate, 'DD/MM/YYYY');
  end if; 

 if pQueryType=124 then
/* Report for T124 Gray Fabric Received/Production from floor by WO wise */
 OPEN data_cursor  FOR
 select b.ORDERNO,getfncWOBType(b.ORDERNO) as workorder,c.YarnCount, d.YarnType,
 a.KNTITRANSACTIONTYPEID,b.FabrictypeID,h.FabricType,i.ClientName,l.ShadeGroupName,
    sum(decode(f.KNTITRANSACTIONTYPEID,6,b.Quantity,24,b.Quantity,0)) ProductQty,
    sum(decode(f.KNTITRANSACTIONTYPEID,6,b.SQuantity,24,b.SQuantity,0)) ProductSQty
    from T_Knitstock a, T_KnitStockItems b,T_YarnCount c, T_YarnType d, T_UnitOfMeas e,
    T_knitTransactionType f, T_Supplier g,T_FabricType h,T_Client i, t_workorder j,T_ShadeGroup l,T_KNITMACHINEINFO k
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=f.KNTITRANSACTIONTYPEID and
   (f.KNTITRANSACTIONTYPEID=6 or f.KNTITRANSACTIONTYPEID=24) and
    b.FabricTypeID=h.FabricTypeID and
    b.ShadeGroupID=l.ShadeGroupID and
    b.ORDERNO=j.ORDERNO and
    j.ClientID=i.ClientID and
    b.yarnCountId=c.yarncountid and
    b.yarntypeid=d.yarntypeID and
    b.PunitOfMeasId=e.UnitOfmeasId and
    b.SupplierId=g.SupplierId and
    b.MACHINEID=K.MACHINEID and
    (pORDERNO is NULL or b.ORDERNO=pORDERNO) and
    (pFabriTypeID is NULL or b.FabrictypeID=pFabriTypeID) and  
    a.STOCKTRANSDATE between decode(vSDate,null,'01-jan-2000',vSDate) and vEDate and	
    b.ORDERNO>0
    group by b.ORDERNO,c.YarnCount, d.YarnType,
 a.KNTITRANSACTIONTYPEID,b.FabrictypeID,h.FabricType,i.ClientName,l.ShadeGroupName
	ORDER BY getfncWOBType(b.ORDERNO) ASC;
 elsif pQueryType=125 then
/* Report for T124 Gray Fabric Received/Production from floor by Fabric Type wise */
  OPEN data_cursor  FOR
 select b.ORDERNO,getfncWOBType(b.ORDERNO) as workorder,c.YarnCount, d.YarnType,
 a.KNTITRANSACTIONTYPEID,b.FabrictypeID,h.FabricType,i.ClientName,l.ShadeGroupName,
    sum(decode(f.KNTITRANSACTIONTYPEID,6,b.Quantity,24,b.Quantity,0)) ProductQty,
    sum(decode(f.KNTITRANSACTIONTYPEID,6,b.SQuantity,24,b.SQuantity,0)) ProductSQty
    from T_Knitstock a, T_KnitStockItems b,T_YarnCount c, T_YarnType d, T_UnitOfMeas e,
    T_knitTransactionType f, T_Supplier g,T_FabricType h,T_Client i, t_workorder j,T_ShadeGroup l,T_KNITMACHINEINFO k
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=f.KNTITRANSACTIONTYPEID and
   (f.KNTITRANSACTIONTYPEID=6 or f.KNTITRANSACTIONTYPEID=24) and
    b.FabricTypeID=h.FabricTypeID and
    b.ShadeGroupID=l.ShadeGroupID and
    b.ORDERNO=j.ORDERNO and
    j.ClientID=i.ClientID and
    b.yarnCountId=c.yarncountid and
    b.yarntypeid=d.yarntypeID and
    b.PunitOfMeasId=e.UnitOfmeasId and
    b.SupplierId=g.SupplierId and
    b.MACHINEID=K.MACHINEID and
    (pORDERNO is NULL or b.ORDERNO=pORDERNO) and
    (pFabriTypeID is NULL or b.FabrictypeID=pFabriTypeID) and    
	a.STOCKTRANSDATE between decode(vSDate,null,'01-jan-2000',vSDate) and vEDate and	
    b.ORDERNO>0
    group by b.ORDERNO,c.YarnCount, d.YarnType,
 a.KNTITRANSACTIONTYPEID,b.FabrictypeID,h.FabricType,i.ClientName,l.ShadeGroupName
	ORDER BY getfncWOBType(b.ORDERNO),h.FabricType ASC;
 elsif pQueryType=126 then
/* Report for T124 Gray Fabric Received/Production from floor by Shade Group wise */
  OPEN data_cursor  FOR
 select b.ORDERNO,getfncWOBType(b.ORDERNO) as workorder,c.YarnCount, d.YarnType,
 a.KNTITRANSACTIONTYPEID,b.FabrictypeID,h.FabricType,i.ClientName,l.ShadeGroupName,
    sum(decode(f.KNTITRANSACTIONTYPEID,6,b.Quantity,24,b.Quantity,0)) ProductQty,
    sum(decode(f.KNTITRANSACTIONTYPEID,6,b.SQuantity,24,b.SQuantity,0)) ProductSQty
    from T_Knitstock a, T_KnitStockItems b,T_YarnCount c, T_YarnType d, T_UnitOfMeas e,
    T_knitTransactionType f, T_Supplier g,T_FabricType h,T_Client i, t_workorder j,T_ShadeGroup l,T_KNITMACHINEINFO k
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=f.KNTITRANSACTIONTYPEID and
   (f.KNTITRANSACTIONTYPEID=6 or f.KNTITRANSACTIONTYPEID=24) and
    b.FabricTypeID=h.FabricTypeID and
    b.ShadeGroupID=l.ShadeGroupID and
    b.ORDERNO=j.ORDERNO and
    j.ClientID=i.ClientID and
    b.yarnCountId=c.yarncountid and
    b.yarntypeid=d.yarntypeID and
    b.PunitOfMeasId=e.UnitOfmeasId and
    b.SupplierId=g.SupplierId and
    b.MACHINEID=K.MACHINEID and
    (pORDERNO is NULL or b.ORDERNO=pORDERNO) and
    (pFabriTypeID is NULL or b.FabrictypeID=pFabriTypeID) and  
    a.STOCKTRANSDATE between decode(vSDate,null,'01-jan-2000',vSDate) and vEDate and		
    b.ORDERNO>0
    group by b.ORDERNO,c.YarnCount, d.YarnType,
 a.KNTITRANSACTIONTYPEID,b.FabrictypeID,h.FabricType,i.ClientName,l.ShadeGroupName
	ORDER BY getfncWOBType(b.ORDERNO),l.ShadeGroupName ASC;
  end if;
END T124ReportGFabricSummary;
/




PROMPT CREATE OR REPLACE Procedure  71 :: T127ReportGFabricSummary

CREATE OR REPLACE Procedure T127ReportGFabricSummary(
  data_cursor IN OUT pReturnData.c_Records, 
  pQueryType IN NUMBER,      
  pORDERNO IN NUMBER  DEFAULT NULL, 
  pFabriTypeID IN VARCHAR2  DEFAULT NULL,  
  pSDate IN VARCHAR2  DEFAULT NULL, 
  pEDate IN VARCHAR2  DEFAULT NULL,
  pSUBCONID IN NUMBER DEFAULT NULL
) 
AS 
  vSDate date;
  vEDate date;
 
BEGIN 

  if not pSDate is null then
    vSDate := TO_DATE(pSDate, 'DD/MM/YYYY');
  end if;
  if not pEDate is null then
    vEDate := TO_DATE(pEDate, 'DD/MM/YYYY');
  end if; 

if pQueryType=127 then
/* Report for T123 Gray Fabric Received/Production from Sub Contractor by WO wise */
 OPEN data_cursor  FOR
 select b.ORDERNO,getfncWOBType(b.ORDERNO) as workorder,c.YarnCount, d.YarnType,
 a.KNTITRANSACTIONTYPEID,b.FabrictypeID,h.FabricType,i.ClientName,l.ShadeGroupName,
    sum(decode(f.KNTITRANSACTIONTYPEID,7,b.Quantity,25,b.Quantity,0)) ProductQty,
    sum(decode(f.KNTITRANSACTIONTYPEID,7,b.SQuantity,25,b.SQuantity,0)) ProductSQty
    from T_Knitstock a, T_KnitStockItems b,T_YarnCount c, T_YarnType d, T_UnitOfMeas e,T_SUBCONTRACTORS s,
    T_knitTransactionType f, T_Supplier g,T_FabricType h,T_Client i, t_workorder j,T_ShadeGroup l,T_KNITMACHINEINFO k
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=f.KNTITRANSACTIONTYPEID and
   (f.KNTITRANSACTIONTYPEID=7 or f.KNTITRANSACTIONTYPEID=25) and
    b.FabricTypeID=h.FabricTypeID and
    b.ShadeGroupID=l.ShadeGroupID and
    b.ORDERNO=j.ORDERNO and
    j.ClientID=i.ClientID and
    b.yarnCountId=c.yarncountid and
    b.yarntypeid=d.yarntypeID and
    b.PunitOfMeasId=e.UnitOfmeasId and
    b.SupplierId=g.SupplierId and
    b.MACHINEID=K.MACHINEID and
    (pORDERNO is NULL or b.ORDERNO=pORDERNO) and
    (pSUBCONID is NULL or s.SUBCONID=pSUBCONID) and
    (pFabriTypeID is NULL or b.FabrictypeID=pFabriTypeID) and    
	a.STOCKTRANSDATE between decode(vSDate,null,'01-jan-2000',vSDate) and decode(vEDate,null,'01-jan-2050',vEDate) and	
    b.ORDERNO>0
    group by b.ORDERNO,c.YarnCount, d.YarnType,
	a.KNTITRANSACTIONTYPEID,b.FabrictypeID,h.FabricType,i.ClientName,l.ShadeGroupName
	ORDER BY getfncWOBType(b.ORDERNO) ASC;
 elsif pQueryType=128 then
/* Report for T123 Gray Fabric Received/Production from Sub Contractor by Fabric Type wise */
  OPEN data_cursor  FOR
 select b.ORDERNO,getfncWOBType(b.ORDERNO) as workorder,c.YarnCount, d.YarnType,
 a.KNTITRANSACTIONTYPEID,b.FabrictypeID,h.FabricType,i.ClientName,l.ShadeGroupName,
    sum(decode(f.KNTITRANSACTIONTYPEID,7,b.Quantity,25,b.Quantity,0)) ProductQty,
    sum(decode(f.KNTITRANSACTIONTYPEID,7,b.SQuantity,25,b.SQuantity,0)) ProductSQty
    from T_Knitstock a, T_KnitStockItems b,T_YarnCount c, T_YarnType d, T_UnitOfMeas e,T_SUBCONTRACTORS s,
    T_knitTransactionType f, T_Supplier g,T_FabricType h,T_Client i, t_workorder j,T_ShadeGroup l,T_KNITMACHINEINFO k
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=f.KNTITRANSACTIONTYPEID and
   (f.KNTITRANSACTIONTYPEID=7 or f.KNTITRANSACTIONTYPEID=25) and
    b.FabricTypeID=h.FabricTypeID and
    b.ShadeGroupID=l.ShadeGroupID and
    b.ORDERNO=j.ORDERNO and
    j.ClientID=i.ClientID and
    b.yarnCountId=c.yarncountid and
    b.yarntypeid=d.yarntypeID and
    b.PunitOfMeasId=e.UnitOfmeasId and
    b.SupplierId=g.SupplierId and
    b.MACHINEID=K.MACHINEID and
    (pORDERNO is NULL or b.ORDERNO=pORDERNO) and
    (pSUBCONID is NULL or s.SUBCONID=pSUBCONID) and
    (pFabriTypeID is NULL or b.FabrictypeID=pFabriTypeID) and 
	a.STOCKTRANSDATE between decode(vSDate,null,'01-jan-2000',vSDate) and decode(vEDate,null,'01-jan-2050',vEDate) and		
    b.ORDERNO>0
    group by b.ORDERNO,c.YarnCount, d.YarnType,
	a.KNTITRANSACTIONTYPEID,b.FabrictypeID,h.FabricType,i.ClientName,l.ShadeGroupName
	ORDER BY getfncWOBType(b.ORDERNO),h.FabricType ASC;
 elsif pQueryType=129 then
/* Report for T123 Gray Fabric Received/Production from Sub Contractor by Shade Group wise */
  OPEN data_cursor  FOR
 select b.ORDERNO,getfncWOBType(b.ORDERNO) as workorder,c.YarnCount, d.YarnType,
	a.KNTITRANSACTIONTYPEID,b.FabrictypeID,h.FabricType,i.ClientName,l.ShadeGroupName,
    sum(decode(f.KNTITRANSACTIONTYPEID,7,b.Quantity,25,b.Quantity,0)) ProductQty,
    sum(decode(f.KNTITRANSACTIONTYPEID,7,b.SQuantity,25,b.SQuantity,0)) ProductSQty
    from T_Knitstock a, T_KnitStockItems b,T_YarnCount c, T_YarnType d, T_UnitOfMeas e,T_SUBCONTRACTORS s,
    T_knitTransactionType f, T_Supplier g,T_FabricType h,T_Client i, t_workorder j,T_ShadeGroup l,T_KNITMACHINEINFO k
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=f.KNTITRANSACTIONTYPEID and
   (f.KNTITRANSACTIONTYPEID=7 or f.KNTITRANSACTIONTYPEID=25) and
    b.FabricTypeID=h.FabricTypeID and
    b.ShadeGroupID=l.ShadeGroupID and
    b.ORDERNO=j.ORDERNO and
    j.ClientID=i.ClientID and
    b.yarnCountId=c.yarncountid and
    b.yarntypeid=d.yarntypeID and
    b.PunitOfMeasId=e.UnitOfmeasId and
    b.SupplierId=g.SupplierId and
    b.MACHINEID=K.MACHINEID and
    (pORDERNO is NULL or b.ORDERNO=pORDERNO) and
    (pSUBCONID is NULL or s.SUBCONID=pSUBCONID) and
    (pFabriTypeID is NULL or b.FabrictypeID=pFabriTypeID) and 
	a.STOCKTRANSDATE between decode(vSDate,null,'01-jan-2000',vSDate) and decode(vEDate,null,'01-jan-2050',vEDate) and		
    b.ORDERNO>0
    group by b.ORDERNO,c.YarnCount, d.YarnType,
	a.KNTITRANSACTIONTYPEID,b.FabrictypeID,h.FabricType,i.ClientName,l.ShadeGroupName
	ORDER BY getfncWOBType(b.ORDERNO),l.ShadeGroupName ASC;
  end if;
END T127ReportGFabricSummary;
/  






PROMPT CREATE OR REPLACE Procedure  72 :: GetReportBill
CREATE OR REPLACE PROCEDURE GetReportBill(
  data_cursor IN OUT pReturnData.c_Records,  
  pBillNo IN NUMBER,
  pOrdercode in varchar2,
  pInWordsnumber IN VARCHAR2  
)
AS  
BEGIN
  OPEN data_cursor  FOR
  SELECT DISTINCT A.ORDERCODE,getfncWOBType(b.ORDERNO) as workorder,A.BILLNO,A.BILLDATE,C.CLIENTNAME,A.BILLDISCOUNT,
  A.BILLDISCOMMENTS,A.BILLDISPERC,c.CADDRESS,c.CTELEPHONE,e.shade,c.CCONTACTPERSON,x.EMPLOYEENAME,y.EMPLOYEENAME as Managername,
  D.CURRENCYNAME,A.CONRATE,A.CANCELLED,A.BILLCOMMENTS,B.BILLITEMSL,B.DORDERCODE,B.DINVOICENO,f.fabrictype ,getFncYarnDes(e.ORDERLINEITEM) as YarnDesc,
  B.DITEMSL,B.WORDERCODE,B.ORDERNO,B.WOITEMSL,nvl(B.BILLITEMSQTY,0) as BILLITEMSQTY,B.BILLITEMSUNITPRICE,g.ClientsRef,a.knitting,a.dyeing,a.fabric,
  NVL(B.SQTY,0) as SQTY,M.UNITOFMEAS AS PUNIT,N.UNITOFMEAS AS SUNIT  
  FROM T_BILL A,T_BILLITEMS B,T_CLIENT C,T_CURRENCY D,t_ORDeritems e,T_fabrictype f,
       t_workorder g,T_EMPLOYEE x,T_EMPLOYEE y,T_UNITOFMEAS M,T_UNITOFMEAS N
  WHERE A.ORDERCODE=B.ORDERCODE AND
        A.CLIENTID=C.CLIENTID(+) AND
        A.CURRENCYID=D.CURRENCYID(+) AND  
        b.WOITEMSL=e.WOITEMSL and  
        e.fabrictypeid=f.fabrictypeid(+) and 
        B.ORDERNO=E.ORDERNO AND 
        A.BILLNO=B.BILLNO AND 
        B.BILLNO=pBillNo AND
		A.ORDERCODE=pOrdercode and	
		B.PUNIT=M.UNITOFMEASID(+) AND
		B.SUNIT=N.UNITOFMEASID(+) AND
		a.EMPLOYEEID=x.EMPLOYEEID(+) and
        x.EMPMANAGER=y.EMPLOYEEID(+) and
	B.ORDERNO=g.ORDERNO;        
END GetReportBill;
/


PROMPT CREATE OR REPLACE Procedure  73 :: GetReportFIS 
CREATE OR REPLACE Procedure GetReportFIS 
(
   data_cursor IN OUT pReturnData.c_Records,
   pKnitStockID IN NUMBER
)
As
Begin
  OPEN data_cursor  FOR
  select YarnCount,YarnType,a.Quantity,a.Squantity,b.KNTITRANSACTIONTYPEID,
  f.UNITOFMEAS as PUOM,f.UNITOFMEAS as SUOM,YARNBATCHNO,a.SHADE,
  a.Remarks,a.REQUISITIONNO,b.STOCKID,b.ReferenceNo,b.ReferenceDate,b.StockTransNO,l.fabrictype,
  b.StockTransDATE,b.SupplierInvoiceNo,   b.SupplierInvoiceDate,j.SubConName,j.SUBADDRESS,j.SUBCONTACTPERSON,
	h.orderNo,getfncWOBType(h.orderno) as workorder,k.shadegroupName,a.DYEDLOTNO ,substr(x.clientname,0,15) as clientname      
  from T_KnitStockItems a,T_KnitStock b,T_YarnCount c ,
  T_YarnType d,t_UnitOfMeas f,
  t_WorkOrder h,T_Subcontractors j,t_shadegroup k, t_fabrictype l,T_client x
  where a.STOCKID=b.STOCKID and
  a.shadegroupid=k.shadegroupid(+) and 
  a.YarnCountID=c.YarnCountID(+)  and
  a.YarnTypeID=d.YarnTypeID(+)  and
  a.PUNITOFMEASID=f.UNITOFMEASID(+) And
  a.orderNo=h.OrderNo And
  h.CLIENTID=x.CLIENTID(+) and
  a.FABRICTYPEID=l.FABRICTYPEID(+) and
  b.SubconId=j.SubconId And
  a.STOCKID=pKnitStockID;
End GetReportFIS;
/


PROMPT CREATE OR REPLACE Procedure  74 :: GetReportDYR01
Create or Replace Procedure GetReportDYR01
(
   data_cursor IN OUT pReturnData.c_Records,
   pKnitStockID IN NUMBER
)
As
Begin
  OPEN data_cursor  FOR
  select b.KNTITRANSACTIONTYPEID,YarnCount,YarnType,a.Quantity,a.Squantity,
  f.UNITOFMEAS as PUOM,f.UNITOFMEAS as SUOM,YARNBATCHNO,a.SHADE,
  a.Remarks,b.STOCKID,b.ReferenceNo,b.ReferenceDate,b.StockTransNO,
  b.StockTransDATE,b.SupplierInvoiceNo,m.shadegroupName,
  b.SupplierInvoiceDate,j.SubConName,h.orderNo,getfncWOBType(h.orderno) as workorder,DyedLotNo
  from T_KnitStockItems a,T_KnitStock b,T_YarnCount c ,
  T_YarnType d,t_UnitOfMeas f,
  t_WorkOrder h, T_Subcontractors j,t_shadegroup m
  where a.STOCKID=b.STOCKID and
  a.shadegroupid=m.shadegroupid and 
  a.YarnCountID=c.YarnCountID and
  a.YarnTypeID=d.YarnTypeID and
  a.PUNITOFMEASID=f.UNITOFMEASID And
  a.orderNo=h.OrderNo And 
  b.SubconId=j.SubconId And
  a.STOCKID=pKnitStockID;
End GetReportDYR01;
/


PROMPT CREATE OR REPLACE Procedure  75 :: getReportDeliveredFRFClient
Create or Replace Procedure getReportDeliveredFRFClient
(
   data_cursor IN OUT pReturnData.c_Records,
   pKnitStockID number
)
As
Begin
  OPEN data_cursor  FOR
 	select a.StockId,a.KNTITRANSACTIONTYPEID, a.ReferenceNo, a.ReferenceDate, 
        a.StockTransNO, a.StockTransDATE,a.supplierID,a.SupplierInvoiceNo,a.SupplierInvoiceDate,a.Remarks,
        a.SubConId,d.clientname,b.ORDERNO,getfncWOBType(b.ORDERNO) as WorkOrder,
		b.YarnCountId, b.YarnTypeId,b.FabricTypeId,b.OrderlineItem,e. FABRICTYPE, 
        b.Quantity, b.Squantity,b.PunitOfmeasId,b.SUNITOFMEASID,b.YarnBatchNo,
		b.shadegroupid, f.SHADEGROUPNAME,b.KNTISTOCKITEMSL,b.Shade,b.REMARKS as KSIRemarks,
    	b.CurrentStock,b.DYEDLOTNO,b.MACHINEID,d.CCONTACTPERSON,d.CTELEPHONE 
 	from T_KnitStock a,T_KnitStockItems b,t_workorder c,t_client d,T_FABRICTYPE e, t_shadegroup f 	
	where a.StockId=pKnitStockID and 
		a.CLIENTID=d.CLIENTID and
  		a.STOCKID=b.STOCKID and
		b.FabricTypeId=e.FabricTypeId and
		b.SHADEGROUPID=f.SHADEGROUPID;

End getReportDeliveredFRFClient;
/



PROMPT CREATE OR REPLACE Procedure  76 :: GetREPORTWOTRANSFER
CREATE OR REPLACE Procedure GetREPORTWOTRANSFER(
  data_cursor IN OUT pReturnData.c_Records,
  PStockId IN NUMBER
)
As
Begin
  OPEN data_cursor FOR
  SELECT  A.StockId, A.KNTITRANSACTIONTYPEID, A.ReferenceNo, A.ReferenceDate, A.StockTransNO, A.StockTransDATE,
    A.supplierID,A.SupplierInvoiceNo,A.SupplierInvoiceDate,A.Remarks, A.SubConId,B.ORDERNO,GetfncWOBType(B.OrderNo) as WORKORDERTO,
    B.KNTISTOCKITEMSL,e.YARNCOUNT, f.YARNTYPE,B.FabricTypeId,D.FABRICTYPE,B.OrderlineItem,B.Quantity, B.Squantity,
    B.PunitOfmeasId,B.SUNITOFMEASID,B.REQQUANTITY,B.YarnBatchNo,B.Shade,B.REMARKS AS REMARKSMANY,B.CurrentStock,
    B.RequisitionNo,B.SHADEGROUPID,C.SHADEGROUPNAME,GetfncWOBType(x.OrderNo) as WORKORDERFROM
  from T_KnitStock a,T_KnitStockItems b,T_ShadeGroup c,T_FABRICTYPE D,T_YARNCOUNT E,T_YARNTYPE F,
       T_KnitStockItems x 
  WHERE x.STOCKID!=x.PARENTSTOCKID and	
        x.PARENTSTOCKID=PStockId and
        a.stockid=b.stockid and a.stockid =PStockId and
        a.PARENTSTOCKID=b.PARENTSTOCKID and        
        B.SHADEGROUPID=C.SHADEGROUPID AND        
        B.YarnCountId=E.YarnCountId AND
        B.YARNTYPEID=F.YARNTYPEID AND           
        B.FABRICTYPEID=D.FABRICTYPEID;
End GetREPORTWOTRANSFER;
/



PROMPT CREATE OR REPLACE Procedure  77 :: GetReportFRRDetailS
CREATE OR REPLACE Procedure GetReportFRRDetailS(
   data_cursor IN OUT pReturnData.c_Records,
   pKnitStockID IN NUMBER
)
As
Begin
  OPEN data_cursor  FOR
select c.YarnCount, d.YarnType, z.FABRICTYPE,a.OrderlineItem,a.Quantity, a.Squantity,
f.UNITOFMEAS as PUOM,y.UNITOFMEAS as SUOM,g.SHADEGROUPNAME,
a.YARNBATCHNO,a.SHADE,a.Remarks,b.STOCKID,
b.ReferenceNo,b.ReferenceDate,b.StockTransNO,b.StockTransDATE,
b.SupplierInvoiceNo,b.SupplierInvoiceDate,b.SubConId,
b.Remarks as OneRemarks ,a.Unitprice ,b.ConRate
from T_KnitStockItems a,T_KnitStock b,t_SHADEGROUP g,
T_YarnCount c ,T_YarnType d,t_UnitOfMeas f,t_UnitOfMeas y,T_fabrictype z
where a.STOCKID=b.STOCKID and
a.YarnCountID=c.YarnCountID  and
a.FABRICTYPEID=z.FABRICTYPEID and
a.SHADEGROUPID=g.SHADEGROUPID and
a.YarnTypeID=d.YarnTypeID  and
a.PUNITOFMEASID=f.UNITOFMEASID(+) And
a.SUNITOFMEASID=y.UNITOFMEASID(+) And
a.STOCKID=pKnitStockID;      

End GetReportFRRDetailS;
/


PROMPT CREATE OR REPLACE Procedure  78 :: GetReportKYWODetailS
CREATE OR REPLACE Procedure GetReportKYWODetailS (
   data_cursor IN OUT pReturnData.c_Records,
   pQueryType IN NUMBER,
   sDate IN VARCHAR2,
   eDate IN VARCHAR2
)
AS
  vSDate date;
  vEDate date;
BEGIN

  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  end if;

if pQueryType=1 then
/* Report for T093 Yarn MR Details WO wise*/
  OPEN data_cursor  FOR

    select b.ORDERNO,getfncWOBType(b.ORDERNO) as workorder,a.STOCKTRANSNO,a.STOCKTRANSDATE,b.YARNBATCHNO,c.YarnCount, d.YarnType, e.UnitOfMeas,g.SupplierName,
    h.SUBCONNAME,z.Quantity as AuthoQty,
    sum(b.Quantity*ATLGYS) MainStore, (sum(b.Quantity*ATLGYF)+sum(b.Quantity*AYDLGYS)) as Issued     
    from T_Knitstock a, T_KnitStockItems b, T_yarnRequisition y,T_yarnRequisitionitems z,
    T_YarnCount c, T_YarnType d, T_UnitOfMeas e, T_knitTransactionType f, T_Supplier g,T_subcontractors h
    where a.StockID=b.StockID and 
     a.SUBCONID= h.SUBCONID and h.SUBCONID IN (1,7) and
    a.KNTITRANSACTIONTYPEID=f.KNTITRANSACTIONTYPEID and
    f.KNTITRANSACTIONTYPEID IN (3,4,5,12) and                                                       
    b.yarnCountId=c.yarncountid and                                             
    b.yarntypeid=d.yarntypeID and  
    b.requisitionno=y.stocktransno and y.stockid=z.stockid and 
    /*b.yarnCountId=z.yarnCountId and b.yarnTypeId=z.yarnTypeId and b.fabrictypeId=z.fabrictypeId and  */
    b.yarnbatchno=z.yarnbatchno and
    b.PunitOfMeasId=e.UnitOfmeasId and    
    b.SupplierId=g.SupplierId and                                    
    a.StockTransDATE between decode(vSDate,null,'01-jan-1900',vSDate) and vEDate AND b.ORDERNO>0
    group by b.ORDERNO,a.STOCKTRANSNO,a.STOCKTRANSDATE,b.YARNBATCHNO,c.YarnCount, d.YarnType, e.UnitOfMeas,g.SupplierName,h.SUBCONNAME,z.Quantity
	ORDER BY StockTransDATE,StockTransNO ASC;

  
elsif pQueryType=2 then
/* Report for T094 Yarn MR Details WO wise subcon name*/
  OPEN data_cursor  FOR

    select b.ORDERNO,getfncWOBType(b.ORDERNO) as workorder,a.STOCKTRANSNO,a.STOCKTRANSDATE,b.YARNBATCHNO,c.YarnCount, d.YarnType, e.UnitOfMeas,g.SupplierName,
    h.SUBCONNAME,z.Quantity as AuthoQty,
    sum(b.Quantity*ATLGYS) MainStore, (sum(b.Quantity*ATLGYF)+sum(b.Quantity*AYDLGYS)) as Issued     
    from T_Knitstock a, T_KnitStockItems b, T_yarnRequisition y,T_yarnRequisitionitems z, 
    T_YarnCount c, T_YarnType d, T_UnitOfMeas e, T_knitTransactionType f, T_Supplier g,T_subcontractors h
    where a.StockID=b.StockID and 
     a.SUBCONID= h.SUBCONID and h.SUBCONID NOT IN (1,7) and
    a.KNTITRANSACTIONTYPEID=f.KNTITRANSACTIONTYPEID and
    f.KNTITRANSACTIONTYPEID IN (3,4,5,12) and                                                       
    b.yarnCountId=c.yarncountid and                                             
    b.yarntypeid=d.yarntypeID and 
    b.requisitionno=y.stocktransno and y.stockid=z.stockid and 
    /*b.yarnCountId=z.yarnCountId and b.yarnTypeId=z.yarnTypeId and b.fabrictypeId=z.fabrictypeId and  */
    b.yarnbatchno=z.yarnbatchno and                                      
    b.PunitOfMeasId=e.UnitOfmeasId and
    b.SupplierId=g.SupplierId and                                    
    a.StockTransDATE between decode(vSDate,null,'01-jan-1900',vSDate) and vEDate AND b.ORDERNO>0
    group by b.ORDERNO,a.STOCKTRANSNO,a.STOCKTRANSDATE,b.YARNBATCHNO,c.YarnCount, d.YarnType, e.UnitOfMeas,g.SupplierName,h.SUBCONNAME,z.Quantity
	ORDER BY StockTransDATE,StockTransNO ASC;

elsif pQueryType=131 then
/* Report for T131 Yarn MR Details WO wise*/
  OPEN data_cursor  FOR

    select b.ORDERNO,getfncWOBType(b.ORDERNO) as workorder,b.YARNBATCHNO,c.YarnCount, d.YarnType,i.FabricType, e.UnitOfMeas,g.SupplierName,
    h.SUBCONNAME,(select sum(Quantity) from T_OrderItems where ORDERNO=b.ORDERNO) as AuthoQty,
    sum(b.Quantity*ATLGYS) MainStore, (sum(b.Quantity*ATLGYF)+sum(b.Quantity*AYDLGYS)) as Issued     
    from T_Knitstock a, T_KnitStockItems b,T_YarnCount c, T_YarnType d, T_UnitOfMeas e, T_knitTransactionType f, 
    T_Supplier g,T_subcontractors h,T_FabricType i
    where a.StockID=b.StockID and 
     a.SUBCONID= h.SUBCONID and h.SUBCONID IN (1,7) and
    a.KNTITRANSACTIONTYPEID=f.KNTITRANSACTIONTYPEID and
    f.KNTITRANSACTIONTYPEID IN (3,4,5,12) and                                                       
    b.yarnCountId=c.yarncountid and                                             
    b.yarntypeid=d.yarntypeID and  
    b.FabricTypeID=i.FabricTypeID and
    b.PunitOfMeasId=e.UnitOfmeasId and    
    b.SupplierId=g.SupplierId AND b.ORDERNO>0
    group by b.ORDERNO,b.YARNBATCHNO,c.YarnCount, d.YarnType,i.FabricType, e.UnitOfMeas,g.SupplierName,h.SUBCONNAME
	ORDER BY b.YARNBATCHNO ASC;

   end if;

End GetReportKYWODetailS;
/



PROMPT CREATE OR REPLACE Procedure  79 :: GetREPORTMasterLC
CREATE OR REPLACE Procedure GetREPORTMasterLC (
  data_cursor IN OUT pReturnData.c_Records,
  pLCNumber IN NUMBER,
  sDate IN VARCHAR2,
  eDate IN VARCHAR2
)
AS
  vSDate date;
  vEDate date;
BEGIN

  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  end if;
  
  OPEN data_cursor FOR
  select F.RECEIVEDATE,f.BankLCno as MasterLC,g.ClientName as ClientName,f.ReceiveDate as MDate,f.LCOrderAmt as MAmt,
  f.LCOrderQty as MQty,d.CurrencyName as CurName,H.BANKNAME AS BANKNAME,
  f.ConRate as ConRate,a.BankLCNo as BLCNo,a.OpeningDate as LCDate,c.SUPPLIERNAME as Supplier,   
  sum(b.Qty*b.UnitPrice) as Amount,sum(b.TotCost) as AmountTK,'Accessories' as impLCType
  from T_AccImpLC a,T_AccImpLCItems b, T_supplier c,T_CURRENCY d,T_LCInfo f,T_client g,T_LCBANK H
  where (pLCNumber is null or f.LCNo=pLCNumber) and 
        a.ExpLCNo=f.LCNo and 
        a.LCNo=b.LCNo and
        f.clientid=g.clientid and   
        a.SupplierID=c.SupplierID and
        F.BANKID=H.BANKID(+) AND
        f.CURRENCYID=d.CURRENCYID AND
		a.OpeningDate between decode(vSDate,null,'01-jan-2000',vSDate) and vEDate
  group by F.RECEIVEDATE,f.BankLCno,g.ClientName,f.ReceiveDate,f.LCOrderAmt,f.LCOrderQty,d.CurrencyName,H.BANKNAME, f.ConRate,
  a.BankLCNo,a.OpeningDate,c.SUPPLIERNAME
  
  UNION
  select F.RECEIVEDATE,f.BankLCno as MasterLC,g.ClientName as ClientName,f.ReceiveDate as MDate,f.LCOrderAmt as MAmt,
 f.LCOrderQty as MQty,d.CurrencyName as CurName,H.BANKNAME AS BANKNAME,
  f.ConRate as ConRate,a.BankLCNo as BLCNo,a.OpeningDate as LCDate,c.SUPPLIERNAME as Supplier,   
  sum(b.Qty*b.UnitPrice) as Amount,sum(b.TotCost) as AmountTK,'Auxiliaries' as impLCType
  from T_AuxImpLC a,T_AuxImpLCItems b, T_supplier c,T_CURRENCY d,T_LCInfo f,T_client g,T_LCBANK H
  where (pLCNumber is null or f.LCNo=pLCNumber) and 
        a.ExpLCNo=f.LCNo and 
        a.LCNo=b.LCNo and
        f.clientid=g.clientid and
        F.BANKID=H.BANKID(+) AND
        a.SupplierID=c.SupplierID and
        f.CURRENCYID=d.CURRENCYID AND
		a.OpeningDate between decode(vSDate,null,'01-jan-2000',vSDate) and vEDate
  group by F.RECEIVEDATE,f.BankLCno,g.ClientName,f.ReceiveDate,f.LCOrderAmt,f.LCOrderQty,d.CurrencyName,H.BANKNAME, f.ConRate,
  a.BankLCNo,a.OpeningDate,c.SUPPLIERNAME
  UNION
  select F.RECEIVEDATE,f.BankLCno as MasterLC,g.ClientName as ClientName,f.ReceiveDate as MDate,f.LCOrderAmt as MAmt,
  f.LCOrderQty as MQty,d.CurrencyName as CurName,H.BANKNAME AS BANKNAME,
  f.ConRate as ConRate,a.BankLCNo as BLCNo,a.OpeningDate as LCDate,c.SUPPLIERNAME as Supplier,   
  sum(b.Qty*b.UnitPrice) as Amount,sum(b.TotCost) as AmountTK,'Yarn' as impLCType
  from T_YarnImpLC a,T_YarnImpLCItems b, T_supplier c,T_CURRENCY d,T_LCInfo f,T_client g,T_LCBANK H
  where (pLCNumber is null or f.LCNo=pLCNumber) and 
        a.ExpLCNo=f.LCNo and 
        a.LCNo=b.LCNo and
        f.clientid=g.clientid and   
        a.SupplierID=c.SupplierID and
        F.BANKID=H.BANKID(+) AND
        f.CURRENCYID=d.CURRENCYID AND
		a.OpeningDate between decode(vSDate,null,'01-jan-2000',vSDate) and vEDate
  group by F.RECEIVEDATE,f.BankLCno,g.ClientName,f.ReceiveDate,f.LCOrderAmt,f.LCOrderQty,d.CurrencyName,H.BANKNAME, f.ConRate,
  a.BankLCNo,a.OpeningDate,c.SUPPLIERNAME;  

End GetREPORTMasterLC;
/




PROMPT CREATE OR REPLACE Procedure  80 :: GetGrayYarnReturnToSupplier
CREATE OR REPLACE Procedure GetGrayYarnReturnToSupplier 
(
   data_cursor IN OUT pReturnData.c_Records,
   pKnitStockID IN NUMBER
)
As
Begin
  OPEN data_cursor  FOR
select YarnCount, YarnType,a.Quantity,a.Squantity,
f.UNITOFMEAS as PUOM,g.UNITOFMEAS as SUOM,YARNBATCHNO,a.SHADE,
a.Remarks,b.STOCKID,b.ReferenceNo,b.ReferenceDate,b.StockTransNO,
b.StockTransDATE,E.SUPPLIERNAME,E.SADDRESS,b.SupplierInvoiceNo,
b.SupplierInvoiceDate,j.SubConName,a.REQUISITIONNO
from T_KnitStockItems a,T_KnitStock b,T_YarnCount c ,
T_YarnType d,T_SUPPLIER E,t_UnitOfMeas f,t_UnitOfMeas g,
T_Subcontractors j
where a.STOCKID=b.STOCKID and
a.supplierId=e.supplierID and
a.YarnCountID=c.YarnCountID  and
a.YarnTypeID=d.YarnTypeID  and
a.PUNITOFMEASID=f.UNITOFMEASID(+) And
a.SUNITOFMEASID=g.UNITOFMEASID(+) And
b.SubconId=j.SubconId And
a.STOCKID=pKnitStockID;
End GetGrayYarnReturnToSupplier;
/



PROMPT CREATE OR REPLACE Procedure  81 :: GetGrayYarnSellToClient
CREATE OR REPLACE Procedure GetGrayYarnSellToClient 
(
   data_cursor IN OUT pReturnData.c_Records,
   pKnitStockID IN NUMBER
)
As
Begin
  OPEN data_cursor  FOR
select YarnCount, YarnType,a.Quantity,a.Squantity,
f.UNITOFMEAS as PUOM,g.UNITOFMEAS as SUOM,YARNBATCHNO,a.SHADE,
a.Remarks,b.STOCKID,b.ReferenceNo,b.ReferenceDate,b.StockTransNO,
b.StockTransDATE,E.CLIENTNAME as SUPPLIERNAME,E.CADDRESS as SADDRESS,b.SupplierInvoiceNo,
b.SupplierInvoiceDate,j.SubConName,a.REQUISITIONNO
from T_KnitStockItems a,T_KnitStock b,T_YarnCount c ,
T_YarnType d,T_Client E,t_UnitOfMeas f,t_UnitOfMeas g,
T_Subcontractors j
where a.STOCKID=b.STOCKID and
b.ClientId=e.ClientID and
a.YarnCountID=c.YarnCountID  and
a.YarnTypeID=d.YarnTypeID  and
a.PUNITOFMEASID=f.UNITOFMEASID(+) And
a.SUNITOFMEASID=g.UNITOFMEASID(+) And
b.SubconId=j.SubconId And
a.STOCKID=pKnitStockID;
End GetGrayYarnSellToClient;
/


PROMPT CREATE OR REPLACE Procedure  82 :: GetReportOrderQuantity
CREATE OR REPLACE PROCEDURE GetReportOrderQuantity (
  data_cursor IN OUT pReturnData.c_Records,
  pbtype IN VARCHAR2,
  pSDate IN VARCHAR2 DEFAULT NULL,
  pEDate IN VARCHAR2 DEFAULT NULL
)
As
  vSDate DATE;
  vEDate DATE;
BEGIN
  if not pSDate is null then
    vSDate := TO_DATE(pSDate, 'DD/MM/YYYY');
  end if;
  if not pEDate is null then
    vEDate := TO_DATE(pEDate, 'DD/MM/YYYY');
  end if;
  OPEN data_cursor  FOR
 	select Decode(a.budgetno,Null,0,a.budgetno) as budgetno,getfncDispalyorder(d.orderno) as borderno,
 	getBudgetQty(a.budgetid) as bqty,
 	getOrderQty(d.GARMENTSORDERREF) as aqty,getTexOrderQty(d.orderno) as Texqty,
 	getfncDispalyorder(d.GARMENTSORDERREF) as DOrder,getfncWOBType(d.orderno) as Dworkorder,
 	a.SHIPMENTDATE,c.CLIENTNAME,d.DELIVERYSTARTDATE,d.ORDERDATE
from t_budget a,t_workorder d, t_client c
where (pSDate is NULL or d.ORDERDATE>=vSDate) and
	(pEDate is NULL or d.ORDERDATE<=vEDate) and
	a.revision(+)=65 and
    a.CLIENTID=c.CLIENTID(+) and
    d.budgetid=a.budgetid(+) and 
	d.basictypeid=pbtype
group by a.budgetno,d.orderno,a.budgetid,d.GARMENTSORDERREF,a.SHIPMENTDATE,c.CLIENTNAME,DELIVERYSTARTDATE,d.ORDERDATE
ORDER BY to_number(a.budgetno);
End GetReportOrderQuantity;
/



PROMPT CREATE OR REPLACE Procedure  83 :: GetReportOrderQuantity1
CREATE OR REPLACE PROCEDURE GetReportOrderQuantity1 (
  data_cursor IN OUT pReturnData.c_Records,
  pSDate IN VARCHAR2 DEFAULT NULL,
  pEDate IN VARCHAR2 DEFAULT NULL
)
As

  vSDate DATE;
  vEDate DATE;

BEGIN

  if not pSDate is null then
    vSDate := TO_DATE(pSDate, 'DD/MM/YYYY');
  end if;
  if not pEDate is null then
    vEDate := TO_DATE(pEDate, 'DD/MM/YYYY');
  end if;

  OPEN data_cursor  FOR
 select Decode(a.budgetno,Null,0,a.budgetno) as budgetno,'' as gorderno,getBudgetQty(a.budgetid) as bqty ,
 100 as aqty,getTexWOQty(d.orderno) as Texqty,
 '' as DOrder,getfncWOBType(d.orderno) as Dworkorder
 from t_workorder d,t_budget a
where  d.budgetid=a.budgetid(+) and d.basictypeid='FS' AND
 ORDERDATE BETWEEN decode(vSDate,null,'01-jan-2000',vSDate) and vEDate
order by dorderno ;
End GetReportOrderQuantity1;
/


PROMPT CREATE OR REPLACE Procedure  84 :: WOSummaryReport
CREATE OR REPLACE Procedure WOSummaryReport(
   data_cursor IN OUT pReturnData.c_Records,
   porderno varchar2,
   pbasictype varchar2,
   sDate IN VARCHAR2,
   eDate IN VARCHAR2
)
AS
vSDate date;
vEDate date;
BEGIN
  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  else
   vSDate := TO_DATE('01/01/1900', 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  else
   vEDate := TO_DATE('01/01/2300', 'DD/MM/YYYY');
  end if;  

open data_cursor for
	select b.OrderNo,getfncWOBType(b.orderno) as workorder,e.ORDERDATE,f.ClientName,nvl(getfncTWOQty(b.orderno),0) as woqty,
	getFncFabricDes(b.orderno) as Fabric,e.BASICTYPEID,
	SUM(decode (a.KNTITRANSACTIONTYPEID,3,b.Quantity,4,b.Quantity,5,b.Quantity,12,b.Quantity,9,-b.Quantity,10,-b.Quantity,11,-b.Quantity,14,-b.Quantity,0)) as YI_FLOOR
	from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c,  t_workorder e,T_Client f
	where a.StockID=b.StockID and
	a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and 
	a.KNTITRANSACTIONTYPEID in (3,4,5,12,9,10,11,14) and
	b.orderno=e.orderno and
	e.ClientID=f.ClientID and
	(porderno is null or b.orderno=porderno) and
	(pbasictype is null or e.BASICTYPEID=pbasictype) and
	e.ORDERDATE between vSDate and vEDate
	GROUP BY b.OrderNo,e.ORDERDATE,f.ClientName,e.BASICTYPEID
	ORDER BY getfncWOBType(b.orderno);
END WOSummaryReport;
/




PROMPT CREATE OR REPLACE Procedure  85 :: GetREPORTWO03
CREATE OR REPLACE Procedure GetREPORTWO03 (
  data_cursor IN OUT pReturnData.c_Records,
  Porderno IN NUMBER
)
As
Begin
  OPEN data_cursor FOR
  select A.STOCKID,A.STOCKTRANSNO,A.STOCKTRANSDATE,A.KNTITRANSACTIONTYPEID,E.YARNTYPE,D.YARNCOUNT,F.FABRICTYPE,getfncWOBType(b.orderno) as ORDERNO,
    DECODE(A.KNTITRANSACTIONTYPEID,4,B.QUANTITY,0) AS DELQTY,DECODE(A.KNTITRANSACTIONTYPEID,10,B.QUANTITY,0) AS RETQTY,
    DECODE(A.KNTITRANSACTIONTYPEID,7,B.QUANTITY,0) AS RECQTY,DECODE(A.KNTITRANSACTIONTYPEID,4,B.SQUANTITY,0) AS DELSQTY,
    DECODE(A.KNTITRANSACTIONTYPEID,10,B.SQUANTITY,0) AS RETSQTY,DECODE(A.KNTITRANSACTIONTYPEID,7,B.SQUANTITY,0) AS RECSQTY,
    G.UNITOFMEAS AS UNIT,H.UNITOFMEAS AS SUNIT,DECODE(A.KNTITRANSACTIONTYPEID,4,'A',10,'A',7,'B') as ktType
  FROM T_KNITSTOCK A, T_KNITSTOCKITEMS B, T_KNITTRANSACTIONTYPE C,T_YARNCOUNT D,T_YARNTYPE E,T_FABRICTYPE F,T_UNITOFMEAS G,
      T_UNITOFMEAS H
  WHERE b.orderno=porderno and
        B.STOCKID=A.STOCKID AND	
        B.YARNTYPEID=E.YARNTYPEID AND
        B.YARNCOUNTID=D.YARNCOUNTID AND    
        B.FABRICTYPEID=F.FABRICTYPEID(+) AND
        B.PUNITOFMEASID=G.UNITOFMEASID AND
        B.SUNITOFMEASID=H.UNITOFMEASID AND
        A.KNTITRANSACTIONTYPEID=C.KNTITRANSACTIONTYPEID and
        DECODE(A.KNTITRANSACTIONTYPEID,4,B.QUANTITY,7,B.QUANTITY,10,B.QUANTITY,4,B.SQUANTITY,7,B.SQUANTITY,10,B.SQUANTITY,0)>0
        order by A.STOCKTRANSDATE;  
End GetREPORTWO03;
/


PROMPT CREATE OR REPLACE Procedure  86 :: GETKnitYarnstocksummary16
CREATE OR REPLACE Procedure GETKnitYarnstocksummary16(
   data_cursor IN OUT pReturnData.c_Records,
   pQueryType IN NUMBER,
   pClient IN NUMBER DEFAULT NULL,
   sDate IN VARCHAR2,
   eDate IN VARCHAR2
)
AS
  vSDate date;
  vEDate date;
BEGIN
  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  end if;
if pQueryType=14 then
/* Report for T14 Yarn Stock Summary */
open data_cursor for
select b.OrderNo,getfncWOBType(b.orderno) as workorder,e.ORDERDATE,e.ClientID,e.basictypeid,g.yarncount,h.yarntype,
/* YARN DYEING PROCESS [YARN ISSUE FOR YARN DYEING]*/
 SUM(decode (a.KNTITRANSACTIONTYPEID,5,b.Quantity,0)) as YI_FLOOR,
 SUM(decode (a.KNTITRANSACTIONTYPEID,12,b.Quantity,0)) as YI_OTHERS,
 SUM(decode (a.KNTITRANSACTIONTYPEID,5,b.Quantity,0)+
 decode (a.KNTITRANSACTIONTYPEID,12,b.Quantity,0)) as YI_TOTAL,
/* YARN DYEING PROCESS [YARN RETURN FROM YARN DYEING]*/
SUM(decode (a.KNTITRANSACTIONTYPEID,11,b.Quantity,0)) as YRF_FLOOR,
 SUM(decode (a.KNTITRANSACTIONTYPEID,14,b.Quantity,0)) as YRF_OTHERS,
 SUM(decode (a.KNTITRANSACTIONTYPEID,11,b.Quantity,0)+
 decode (a.KNTITRANSACTIONTYPEID,14,b.Quantity,0)) as YR_TOTAL,
/* Knit Yarn Transfer One to Another */
 SUM(decode(a.KNTITRANSACTIONTYPEID,151,b.Quantity)) as YT_FROM,
 SUM(decode(a.KNTITRANSACTIONTYPEID,152,b.Quantity)) as YT_TO,
 SUM(decode(a.KNTITRANSACTIONTYPEID,151,b.Quantity,152,-b.Quantity,0)) as YT_TOTAL,
 /* YARN DYEING PROCESS [YARN RECEIVED FROM YARN DYEING]*/
 SUM(decode (a.KNTITRANSACTIONTYPEID,8,b.Quantity,0)) as YREC_FLOOR,
 SUM(decode (a.KNTITRANSACTIONTYPEID,13,b.Quantity,0)) as YREC_OTHERS,
 SUM(decode (a.KNTITRANSACTIONTYPEID,8,b.Quantity,0)+
 decode (a.KNTITRANSACTIONTYPEID,13,b.Quantity,0)) AS REC_TOTAL,
 /* KNITTING PROCESS [TOTAL NET YARN ISSUD FOR KNITTING ]*/
  SUM(decode (a.KNTITRANSACTIONTYPEID,5,b.Quantity,0)-
  decode (a.KNTITRANSACTIONTYPEID,11,b.Quantity,0)+
  decode(a.KNTITRANSACTIONTYPEID,151,b.Quantity,0)-
  decode(a.KNTITRANSACTIONTYPEID,152,b.Quantity,0)-
  decode (a.KNTITRANSACTIONTYPEID,8,b.Quantity,0)) AS NET_YARN_FLOOR,
 /* KNITTING PROCESS [TOTAL NET YARN ISSUD FOR OTHERS ]*/
  SUM(decode (a.KNTITRANSACTIONTYPEID,12,b.Quantity,0)-
  decode (a.KNTITRANSACTIONTYPEID,13,b.Quantity,0)-
  decode (a.KNTITRANSACTIONTYPEID,14,b.Quantity,0)) AS NET_YARN_OTHERS,
 /* KNITTING PROCESS [TOTAL NET YARN FLOOR AND OTHERS ]*/
  SUM(decode (a.KNTITRANSACTIONTYPEID,5,b.Quantity,0)-
  decode (a.KNTITRANSACTIONTYPEID,11,b.Quantity,0)+
  decode(a.KNTITRANSACTIONTYPEID,151,b.Quantity,0)-
  decode(a.KNTITRANSACTIONTYPEID,152,b.Quantity,0)-
  decode (a.KNTITRANSACTIONTYPEID,8,b.Quantity,0)+
  decode (a.KNTITRANSACTIONTYPEID,12,b.Quantity,0)-
  decode (a.KNTITRANSACTIONTYPEID,13,b.Quantity,0)-
  decode (a.KNTITRANSACTIONTYPEID,14,b.Quantity,0)) AS NET_YARN_GRAND_TOTAL
 from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c,  t_workorder e,T_Client f,t_yarncount g,t_yarntype h
 where a.StockID=b.StockID and
 a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and a.KNTITRANSACTIONTYPEID in (5,8,11,12,13,14,151,152) and
 b.orderno=e.orderno and e.ClientID=f.ClientID and
 b.yarncountid=g.yarncountid and b.yarntypeid=h.yarntypeid and
 (pClient is NULL or e.ClientID=pClient) and
 e.ORDERDATE between decode(vSDate,null,'01-jan-1900',vSDate) and vEDate
GROUP BY b.OrderNo,e.ORDERDATE,e.ClientID,e.basictypeid,g.yarncount,h.yarntype
ORDER BY getfncWOBType(b.orderno);

end if;
END GETKnitYarnstocksummary16;
/




PROMPT CREATE OR REPLACE Procedure  87 :: GetReportAD01
CREATE OR REPLACE PROCEDURE GetReportAD01(
  data_cursor IN OUT pReturnData.c_Records,
  pKnitStockID number
)
As
BEGIN

  OPEN data_cursor  FOR
  select a.StockId,a.KNTITRANSACTIONTYPEID,a.ReferenceNo,a.ReferenceDate,a.StockTransNO,a.StockTransDATE,
    a.Remarks,getfncWOBType(b.ORDERNO) as workorder,c.YarnCount,d.YarnType,e.FabricType,b.OrderlineItem,b.CurrentStock,
    (b.CurrentStock+b.Quantity) AS PhysicalQty,
    b.Quantity, b.Squantity,f.unitOfmeas as punit,g.unitOfmeas as sunit,b.YarnBatchNo,b.Shade,b.UnitPrice
  from T_KnitStock a,T_KnitStockItems b, t_yarncount c,t_yarntype d,t_fabrictype e,t_unitofmeas f,t_unitofmeas g
  where a.StockId=b.StockId(+) and
        b.yarncountid=c.yarncountid(+) and 
        b.PunitOfmeasId=f.unitOfmeasId(+) and  
        b.SUNITOFMEASID=g.unitOfmeasId(+) and   
        b.yarntypeid=d.yarntypeid(+) and
        b.fabrictypeid=e.fabrictypeid(+) and
        a.StockId=pKnitStockID order by b.KNTISTOCKITEMSL asc;
End GetReportAD01;
/


PROMPT CREATE OR REPLACE Procedure  88 :: GetReportAD02
CREATE OR REPLACE PROCEDURE GetReportAD02(
  data_cursor IN OUT pReturnData.c_Records,
  pKnitStockID number
)
As
BEGIN

  OPEN data_cursor  FOR
  select a.StockId,a.StockTransNO,a.StockTransDATE,getfncWOBType(a.ORDERNO) as workorder,
    c.YarnCount,d.YarnType,e.FabricType,b.OrderlineItem,b.CurrentStock,
    (b.CurrentStock+b.Quantity) AS PhysicalQty,
    b.Quantity, b.Squantity,f.unitOfmeas as punit,g.unitOfmeas as sunit,b.YarnBatchNo,h.SHADEGROUPNAME,b.UnitPrice
  from T_KnitStock a,T_KnitStockItems b, t_yarncount c,t_yarntype d,t_fabrictype e,t_unitofmeas f,t_unitofmeas g,T_shadegroup h
  where a.StockId=b.StockId(+) and
        a.ORDERNO=b.ORDERNO(+) and
        b.yarncountid=c.yarncountid(+) and 
        b.PunitOfmeasId=f.unitOfmeasId(+) and  
        b.SUNITOFMEASID=g.unitOfmeasId(+) and   
        b.yarntypeid=d.yarntypeid(+) and
        b.shadegroupid=h.shadegroupid and
        b.fabrictypeid=e.fabrictypeid(+) and
        a.StockId=pKnitStockID order by b.KNTISTOCKITEMSL asc;
End GetReportAD02;
/


PROMPT CREATE OR REPLACE Procedure  89 :: GetReportAD03
CREATE OR REPLACE PROCEDURE GetReportAD03(
  data_cursor IN OUT pReturnData.c_Records,
  pKnitStockID number
)
As
BEGIN

  OPEN data_cursor  FOR
  select a.StockId,a.StockTransNO,a.StockTransDATE,getfncWOBType(a.ORDERNO) as workorder,
    c.YarnCount,d.YarnType,e.FabricType,b.OrderlineItem,b.CurrentStock,
    (b.CurrentStock+b.Quantity) AS PhysicalQty,b.Shade,b.DYEDLOTNO,
    b.Quantity, b.Squantity,f.unitOfmeas as punit,g.unitOfmeas as sunit,b.YarnBatchNo,h.SHADEGROUPNAME,b.UnitPrice
  from T_KnitStock a,T_KnitStockItems b, t_yarncount c,t_yarntype d,t_fabrictype e,t_unitofmeas f,t_unitofmeas g,T_shadegroup h
  where a.StockId=b.StockId(+) and
        a.ORDERNO=b.ORDERNO(+) and
        b.yarncountid=c.yarncountid(+) and 
        b.PunitOfmeasId=f.unitOfmeasId(+) and  
        b.SUNITOFMEASID=g.unitOfmeasId(+) and   
        b.yarntypeid=d.yarntypeid(+) and
        b.shadegroupid=h.shadegroupid and
        b.fabrictypeid=e.fabrictypeid(+) and
        a.StockId=pKnitStockID order by b.KNTISTOCKITEMSL asc;
End GetReportAD03;
/


PROMPT CREATE OR REPLACE Procedure  90 :: R001Report
CREATE OR REPLACE Procedure R001Report
(
  one_cursor IN OUT pReturnData.c_Records,
  pKnitStockID number
)
AS
BEGIN
    open one_cursor for
    select
    a.StockId,a.StockTransNO,a.StockTransDATE,b.ORDERNO,GetfncWOBType(b.OrderNo) as btype,
    c.YarnCount,d.YarnType,e.FabricType,b.YarnBatchNo,b.Shade,b.REMARKS,
    b.Quantity, f.unitOfmeas
    from 
    T_KnitStock a,T_KnitStockItems b,T_YarnCount c,T_YarnType d,T_FabricType e,T_unitOfmeas f
    where 
    a.STOCKID=b.STOCKID and
    b.YarnCountId=c.YarnCountId(+) and 
    b.YarnTypeId=d.YarnTypeId(+) and
    b.FabricTypeId=e.FabricTypeId(+) and
    b.PunitOfmeasId=f.unitOfmeasId(+) and
    a.StockId=pKnitStockID
    order by
    KNTISTOCKITEMSL asc; 
END R001Report;
/



PROMPT CREATE OR REPLACE Procedure  91 :: R002Report
CREATE OR REPLACE Procedure R002Report
(
  one_cursor IN OUT pReturnData.c_Records,
  pKnitStockID number
)
AS
BEGIN
    open one_cursor for
    select
    a.StockId,a.StockTransNO,a.StockTransDATE,b.ORDERNO,GetfncWOBType(b.OrderNo) as btype,
    c.YarnCount,d.YarnType,e.FabricType,b.YarnBatchNo,g.Shadegroupname,b.REMARKS,
    b.Quantity, f.unitOfmeas
    from 
    T_KnitStock a,T_KnitStockItems b,T_YarnCount c,T_YarnType d,T_FabricType e,T_unitOfmeas f,T_shadegroup g
    where 
    a.STOCKID=b.STOCKID and
    b.YarnCountId=c.YarnCountId(+) and 
    b.YarnTypeId=d.YarnTypeId(+) and
    b.FabricTypeId=e.FabricTypeId(+) and
    b.shadegroupid=g.shadegroupid(+) and
    b.PunitOfmeasId=f.unitOfmeasId(+) and
    a.StockId=pKnitStockID
    order by
    KNTISTOCKITEMSL asc; 
END R002Report;
/


PROMPT CREATE OR REPLACE Procedure  92 :: R003Report
CREATE OR REPLACE Procedure R003Report
(
  one_cursor IN OUT pReturnData.c_Records,
  pKnitStockID number
)
AS
BEGIN
    open one_cursor for
    select
    a.StockId,a.StockTransNO,a.StockTransDATE,b.ORDERNO,GetfncWOBType(b.OrderNo) as btype,
    c.YarnCount,d.YarnType,e.FabricType,b.YarnBatchNo,g.Shadegroupname,b.REMARKS,
    b.Quantity, f.unitOfmeas,b.Shade,b.DYEDLOTNO
    from 
    T_KnitStock a,T_KnitStockItems b,T_YarnCount c,T_YarnType d,T_FabricType e,T_unitOfmeas f,T_shadegroup g
    where 
    a.STOCKID=b.STOCKID and
    b.YarnCountId=c.YarnCountId(+) and 
    b.YarnTypeId=d.YarnTypeId(+) and
    b.FabricTypeId=e.FabricTypeId(+) and
    b.shadegroupid=g.shadegroupid(+) and
    b.PunitOfmeasId=f.unitOfmeasId(+) and
    a.StockId=pKnitStockID
    order by
    KNTISTOCKITEMSL asc; 
END R003Report;
/


PROMPT CREATE OR REPLACE Procedure  93 :: R004Report
CREATE OR REPLACE Procedure R004Report
(
  one_cursor IN OUT pReturnData.c_Records,
  pKnitStockID number
)
AS
BEGIN
    open one_cursor for
    select
    a.StockId,a.StockTransNO,a.StockTransDATE,b.ORDERNO,GetfncWOBType(b.OrderNo) as btype,
    c.YarnCount,d.YarnType,e.FabricType,b.YarnBatchNo,g.Shadegroupname,b.REMARKS,
    b.Quantity, f.unitOfmeas,b.Shade,b.DYEDLOTNO
    from 
    T_KnitStock a,T_KnitStockItems b,T_YarnCount c,T_YarnType d,T_FabricType e,T_unitOfmeas f,T_shadegroup g
    where 
    a.STOCKID=b.STOCKID and
    b.YarnCountId=c.YarnCountId(+) and 
    b.YarnTypeId=d.YarnTypeId(+) and
    b.FabricTypeId=e.FabricTypeId(+) and
    b.shadegroupid=g.shadegroupid(+) and
    b.PunitOfmeasId=f.unitOfmeasId(+) and
    a.StockId=pKnitStockID
    order by
    KNTISTOCKITEMSL asc; 
END R004Report;
/


PROMPT CREATE OR REPLACE Procedure  94 :: DI01Summary
Create or Replace Procedure DI01Summary
(
   data_cursor IN OUT pReturnData.c_Records,   
   pDTYPE IN VARCHAR2,
   sDate IN VARCHAR2,
   eDate IN VARCHAR2
)
As
  vSDate date;
  vEDate date;
Begin
  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  end if;
  
  OPEN data_cursor  FOR
 	select a.INVOICENO,a.INVOICEDATE,a.CONTACTPERSON,c.CLIENTName,a.DELIVERYPLACE,getfncWOBType(A.Orderno) as mainorderno,     
 	b.QUANTITY,b.SQUANTITY,g.UNITOFMEAS as Punit,h.UNITOFMEAS as Sunit,j.BASICTYPEID,
	b.REMARKS,b.ORDERNO,getfncWOBType(b.ORDERNO) as workorder,b.DBATCH,d.FABRICTYPE,f.COLLARCUFFSIZE,
       (select sum(quantity) from T_ORDERITEMS where orderno=(select orderno from T_DINVOICE where DINVOICEID=A.DINVOICEID)) as OrderQty,
	   (select sum(sqty) from T_ORDERITEMS where orderno=(select orderno from T_DINVOICE where DINVOICEID=A.DINVOICEID)) as OrderSQty,
       (select NVL(sum(quantity),0) from T_DINVOICEITEMS where orderno=(select orderno from T_DINVOICE where DINVOICEID=A.DINVOICEID)) as deliveryQty,
       (select NVL(sum(squantity),0) from T_DINVOICEITEMS where orderno=(select orderno from T_DINVOICE where DINVOICEID=A.DINVOICEID)) as deliverySQty               	   
 	from T_DINVOICE a,T_DINVOICEITEMS b,T_Client c,T_FABRICTYPE d,T_ORDERITEMS e,T_COLLARCUFF f,T_Unitofmeas g,
        T_Unitofmeas h, T_WorkOrder j
        where a.DINVOICEID=b.DINVOICEID and 
        a.DTYPE=pDTYPE and
            A.Orderno=j.Orderno and
	    a.CLIENTID=c.CLIENTID(+) and
		b.ORDERLINEITEM=e.ORDERLINEITEM(+) and 
  	    b.FABRICTYPEID=d.FABRICTYPEID(+) and        
        e.COLLARCUFFID=f.COLLARCUFFID(+) and
		b.punitofmeasid=g.unitofmeasid(+) and
		b.sunitofmeasid=h.unitofmeasid(+) and
		a.INVOICEDATE between decode(vSDate,null,'01-jan-2000',vSDate) and vEDate
		order by a.INVOICEDATE,a.INVOICENO;
End DI01Summary;
/  


PROMPT CREATE OR REPLACE Procedure  95 :: GetREPORTMasterLCSum

CREATE OR REPLACE Procedure GetREPORTMasterLCSum (
  data_cursor IN OUT pReturnData.c_Records,
  pLCNumber IN NUMBER,
  pExplctype in number,
  sDate IN VARCHAR2,
  eDate IN VARCHAR2
)
AS
  vSDate date;
  vEDate date;
BEGIN

  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  end if;
  
  OPEN data_cursor FOR
  select F.RECEIVEDATE,f.BankLCno as MasterLC,substr(g.ClientName,0,25) as ClientName,
  f.ReceiveDate as MDate,f.LCOrderAmt as MAmt,
  f.LCOrderQty as MQty,d.CurrencyName as CurName,H.BANKNAME AS BANKNAME,  
  f.ConRate as ConRate,f.explctypeid ,LCMATURITYPERIOD,d.CURRENCYID,d.ConRate as MConRate,
  decode(explctypeid,1,Nvl(LCMATURITYPERIOD,'Adsight'),2,Nvl(LCMATURITYPERIOD,'TT'),3,Nvl(LCMATURITYPERIOD,'TT')) as mm
  from T_CURRENCY d,T_LCInfo f,T_client g,T_LCBANK H
  where (pLCNumber is null or f.LCNo=pLCNumber) and   
		(pExplctype is null or f.Explctypeid=pExplctype) and    
        f.clientid=g.clientid and         
        F.BANKID=H.BANKID(+) AND	
        f.CURRENCYID=d.CURRENCYID AND
		F.RECEIVEDATE between decode(vSDate,null,'01-jan-2000',vSDate) and vEDate ; 
End GetREPORTMasterLCSum;
/ 



PROMPT CREATE OR REPLACE Procedure  96 :: GetFabricLossSummary
CREATE OR REPLACE Procedure GetFabricLossSummary(
   data_cursor IN OUT pReturnData.c_Records,
   pQueryType IN NUMBER,
   pClient IN NUMBER DEFAULT NULL,
   sDate IN VARCHAR2,
   eDate IN VARCHAR2
   )
AS
  vSDate date;
  vEDate date;
BEGIN
  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  end if;
if pQueryType=1 then
open data_cursor for
select b.OrderNo,getfncWOBType(b.orderno) as workorder,e.ORDERDATE,f.ClientName,e.basictypeid,
    /* Fabric stock in Batching, Dyeing and Finishing Floor*/
    nvl(sum(b.quantity*ATLGFDF),0) as BatchFloor,
    nvl(sum(b.quantity*ATLDFDS),0) as DyeinfFloor,
    nvl(sum(b.quantity*ATLFFS),0) as FinishFloor,
	/* Fabric Issue in Batching, Dyeing and Finishing Floor*/ 
	sum(decode(a.KNTITRANSACTIONTYPEID,19,b.quantity,0)) as IBFtoDF,
	sum(decode(a.KNTITRANSACTIONTYPEID,20,b.quantity,0)) as IDFtoFF,
	/* Fabric rejected in Batching, Dyeing and Finishing Floor*/   
	sum(decode(a.KNTITRANSACTIONTYPEID,58,b.quantity,0)) as RJDFloor,
	sum(decode(a.KNTITRANSACTIONTYPEID,59,b.quantity,0)) as RJFFloor,
	/* finishing Fabric Transfer and Receive*/    
    sum(decode(a.KNTITRANSACTIONTYPEID,141,b.quantity,0)) as FFRecFrm,
    sum(decode(a.KNTITRANSACTIONTYPEID,142,b.quantity,0)) as FFTrnTo,
	/* Net fabric received in dyeing and finishing from subcontractor*/    
    sum(decode(a.KNTITRANSACTIONTYPEID,39,b.quantity,0)) as DFOthers,
    sum(decode(a.KNTITRANSACTIONTYPEID,32,b.quantity,40,b.quantity,0)) as FFOthers,
    /* Fabric delivery in Batching, Dyeing and Finishing Floor*/    
    sum(decode(a.KNTITRANSACTIONTYPEID,41,b.quantity,0)) as DIDFloor,
    sum(decode(a.KNTITRANSACTIONTYPEID,21,b.quantity,0)) as DIFFloor
from T_Knitstock a,T_KnitStockItems b,T_knitTransactionType c,T_workorder e,T_Client f
where a.StockID=b.StockID and
   a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and /*a.KNTITRANSACTIONTYPEID in (3,4,6,7,9,10,22,23,24,25,26,27,42,43,44,53,54,101,102,131,132) and*/
   b.orderno=e.orderno and e.ClientID=f.ClientID and
   (pClient is NULL or e.ClientID=pClient) and
   e.ORDERDATE between decode(vSDate,null,'01-jan-1900',vSDate) and vEDate
GROUP BY b.OrderNo,e.ORDERDATE,f.ClientName,e.basictypeid
ORDER BY getfncWOBType(b.orderno);
end if;
END GetFabricLossSummary;
/




PROMPT CREATE OR REPLACE Procedure  97 :: GetREPORTAccImpLC
CREATE OR REPLACE Procedure GetREPORTAccImpLC (
  data_cursor IN OUT pReturnData.c_Records,
  pLCNumber IN NUMBER
)
As
Begin
  OPEN data_cursor FOR
  select a.LCNo,a.BankLCNo,a.OpeningDate,c.SUPPLIERNAME,c.SADDRESS,c.STELEPHONE,c.SCONTACTPERSON,d.CurrencyName,a.ConRate,
  f.BankLCNo as MasterLCNo,a.ShipmentDate,
  a.DocRecDate,a.DocRelDate,a.GoodsRecDate,a.ImpLCStatusId,a.BankCharge,a.Insurance,
  a.TruckFair,a.CNFValue,a.OtherCharge,a.Remarks,a.ShipDate,a.Cancelled,a.Lcmaturityperiod,a.ImpLctypeid,
  b.PID,g.Item,b.Qty,b.UnitPrice,b.ValueFC,b.ValueTk,b.ValueBank,
  b.ValueInsurance,b.ValueTruck,b.ValueCNF,b.ValueOther,b.TotCost,b.UnitCost,e.GROUPNAME
  from T_AccImpLC a,T_AccImpLCItems b, T_supplier c,t_CURRENCY d,T_accGroup e,T_LCInfo f,T_Accessories g 
  where a.LCNo=b.LCNo and
        a.ExpLCNo=f.LCNo(+) and
        a.SupplierID=c.SupplierID and
        a.CURRENCYID=d.CURRENCYID and
        a.LCNo=pLCNumber and
        b.GROUPID=e.GROUPID and
        b.AccessoriesId=g.AccessoriesId
  order by b.PID;
End GetREPORTAccImpLC;
/


PROMPT CREATE OR REPLACE Procedure  98 :: GetREPORTAUXImpLC
CREATE OR REPLACE Procedure GetREPORTAUXImpLC (
  data_cursor IN OUT pReturnData.c_Records,
  pLCNumber IN NUMBER
)
As
Begin
  OPEN data_cursor FOR
  select a.LCNo, a.BankLCNo, a.OpeningDate,c.SUPPLIERNAME,c.SADDRESS,c.STELEPHONE,c.SCONTACTPERSON, d.CurrencyName, a.ConRate,f.BankLCNo as MasterLC, a.ShipmentDate,
  a.DocRecDate, a.DocRelDate, a.GoodsRecDate, a.ImpLCStatusId, a.BankCharge, a.Insurance,
  a.TruckFair, a.CNFValue, a.OtherCharge, a.Remarks, a.ShipDate, a.Cancelled,a.Lcmaturityperiod,a.ImpLctypeid,
  b.PID,e.AuxType, g.DyeBaseID ,g.AuxName,
  b.Qty, b.UnitPrice, b.ValueFC, b.ValueTk, b.ValueBank,
  b.ValueInsurance, b.ValueTruck, b.ValueCNF, b.ValueOther, b.TotCost, b.UnitCost
  from T_AuxImpLC a,T_AuxImpLCItems b, T_supplier c,T_CURRENCY d,T_LCInfo f,T_Auxiliaries g,T_AuxType e 
  where a.LCNo=b.LCNo and
        a.ExpLCNo=f.LCNo(+) and
        a.SupplierID=c.SupplierID and
        a.CURRENCYID=d.CURRENCYID and
        a.LCNo=pLCNumber and                
        b.AuxId=g.AuxId and 
        g.AuxTypeId=e.AuxTypeId and
        b.AuxTypeId=e.AuxTypeId
  order by b.PID;
End GetREPORTAUXImpLC;
/


PROMPT CREATE OR REPLACE Procedure  99 :: GetREPORTYarnImpLC
CREATE OR REPLACE Procedure GetREPORTYarnImpLC (
  data_cursor IN OUT pReturnData.c_Records,
  pLCNumber IN NUMBER
)
As
Begin
  OPEN data_cursor FOR
  select a.LCNo,a.BankLCNo,a.OpeningDate,c.SUPPLIERNAME,c.SADDRESS,c.STELEPHONE,c.SCONTACTPERSON,d.CurrencyName,a.ConRate,
  f.BankLCNo as MasterLCNo,a.ShipmentDate,
  a.DocRecDate,a.DocRelDate,a.GoodsRecDate,a.ImpLCStatusId,a.BankCharge,a.Insurance,
  a.TruckFair,a.CNFValue,a.OtherCharge,a.Remarks,a.ShipDate,a.Cancelled,a.Lcmaturityperiod,a.ImpLctypeid,
  b.PID,b.YARNIMPLCITEMSSL,g.YarnType,h.yarncount, b.Qty, b.UnitPrice, b.ValueFC,b.ValueTk, b.ValueBank,
  b.ValueInsurance, b.ValueTruck, b.ValueCNF, b.ValueOther, b.TotCost, b.UnitCost
  from T_YarnImpLC a,T_YarnImpLCItems b, T_supplier c,t_CURRENCY d,T_LCInfo f,T_Yarntype g, t_yarncount h 
  where a.LCNo=b.LCNo and
        a.ExpLCNo=f.LCNo(+) and
        a.SupplierID=c.SupplierID and
        a.CURRENCYID=d.CURRENCYID and
        a.LCNo=pLCNumber and
        b.YarnTypeId=g.YarnTypeId and
        b.countid=h.yarncountid
  order by b.PID;
End GetREPORTYarnImpLC;
/



PROMPT CREATE OR REPLACE Procedure  100 :: OFS001
CREATE OR REPLACE Procedure OFS001(
   data_cursor IN OUT pReturnData.c_Records,
   pOrderno IN NUMBER DEFAULT NULL,
   pClient IN NUMBER DEFAULT NULL,
   sDate IN VARCHAR2,
   eDate IN VARCHAR2
)
AS
  vSDate date;
  vEDate date;
BEGIN
  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  end if;
open data_cursor for
select e.OrderNo,f.ClientName,g.FABRICTYPEID,h.FABRICTYPE,getfncWOBType(e.orderno) as workorder,substr(e.CLIENTSREF,0,50) as CLIENTSREF, 
   /* order quantity*/   
  sum(QUANTITY) as OrderQty,
 /* yarn stock Budget*/
  0 AS NET_YARN_STOCK,   
  /* KNITTING PROCESS [TOTAL NET YARN FLOOR AND OTHERS ]*/
  pp.KQTY AS NET_KNITTING_STOCK,
  /* Dyeing stock ATLDFDS(+)*/
  qq.DQTY AS NET_DYEING_STOCK,
  /* finishing production ATLFFS*/
  rr.FFQTY AS NET_FINISHING_STOCK,
  /* delivered to garments -ATLFFS*/
  ss.DGQTY as DELV_GARM,
  /* delivery quantity -ATLFFS*/
  0 as DELV_QTY,
  /* Garments Production*/
  0 as GMT_PROD_QTY,
  /* Shipment Quantity*/
  0 as SHIP_QTY,
  /* Balance Shipment Quantity*/
  0 as BAL_SHIP_QTY
 from  t_workorder e,T_Client f,T_orderitems g,T_fabrictype h,
 (select y.OrderNo,y.FABRICTYPEID,SUM(decode (x.KNTITRANSACTIONTYPEID,3,y.Quantity,9,-y.Quantity,101,y.Quantity,102,-y.Quantity,6,-y.Quantity,4,y.Quantity,10,-y.Quantity,7,-y.Quantity,0)) as KQTY
 from T_Knitstock x, T_KnitStockItems y,T_knitTransactionType z
 where x.StockID=y.StockID and  x.KNTITRANSACTIONTYPEID=z.KNTITRANSACTIONTYPEID and 
 x.KNTITRANSACTIONTYPEID in (3,4,6,7,9,10,101,102) GROUP BY y.OrderNo,y.FABRICTYPEID) pp,
 (select y.OrderNo,y.FABRICTYPEID,SUM(decode (x.KNTITRANSACTIONTYPEID,18,y.Quantity,19,-y.Quantity,161,y.Quantity,162,-y.Quantity,45,-y.Quantity,41,-y.Quantity,48,-y.Quantity,37,y.Quantity,38,-y.Quantity,39,-y.Quantity,0)) as DQTY
 from T_Knitstock x, T_KnitStockItems y,T_knitTransactionType z
 where x.StockID=y.StockID and  x.KNTITRANSACTIONTYPEID=z.KNTITRANSACTIONTYPEID and 
 x.KNTITRANSACTIONTYPEID in (18,19,161,162,45,41,48,37,38,39) GROUP BY y.OrderNo,y.FABRICTYPEID) qq,
 (select y.OrderNo,y.FABRICTYPEID,SUM(decode (x.KNTITRANSACTIONTYPEID,19,y.Quantity,141,y.Quantity,142,-y.Quantity,20,-y.Quantity,39,y.Quantity,34,-y.Quantity,40,-y.Quantity,0)) as FFQTY
 from T_Knitstock x, T_KnitStockItems y,T_knitTransactionType z
 where x.StockID=y.StockID and  x.KNTITRANSACTIONTYPEID=z.KNTITRANSACTIONTYPEID and 
 x.KNTITRANSACTIONTYPEID in (19,141,142,20,39,34,40) GROUP BY y.OrderNo,y.FABRICTYPEID) rr, 
 (select y.OrderNo,y.FABRICTYPEID,SUM(decode (x.KNTITRANSACTIONTYPEID,21,y.Quantity,0)) as DGQTY
 from T_Knitstock x, T_KnitStockItems y,T_knitTransactionType z
 where x.StockID=y.StockID and  x.KNTITRANSACTIONTYPEID=z.KNTITRANSACTIONTYPEID and 
 x.KNTITRANSACTIONTYPEID in (21) GROUP BY y.OrderNo,y.FABRICTYPEID) ss
 where e.ORDERNO=g.ORDERNO and  (pOrderno is null or e.ORDERNO=pOrderno) and
 g.FABRICTYPEID=h.FABRICTYPEID(+) and /*g.orderno=2546 */ 
 e.ClientID=f.ClientID(+) and (pClient is NULL or e.ClientID=pClient) and
 e.ORDERDATE  between decode(vSDate,null,'01-jan-1900',vSDate) and vEDate and 
 g.FABRICTYPEID=pp.FABRICTYPEID(+) and g.ORDERNO=pp.ORDERNO(+) and
 g.FABRICTYPEID=qq.FABRICTYPEID(+) and g.ORDERNO=qq.ORDERNO(+) and 
 g.FABRICTYPEID=rr.FABRICTYPEID(+) and g.ORDERNO=rr.ORDERNO(+) and
 g.FABRICTYPEID=ss.FABRICTYPEID(+) and g.ORDERNO=ss.ORDERNO(+)
 group by e.OrderNo,f.ClientName,g.FABRICTYPEID,h.FABRICTYPE,e.CLIENTSREF,pp.KQTY,qq.DQTY,rr.FFQTY,ss.DGQTY
ORDER BY getfncWOBType(e.orderno);
END OFS001;
/



PROMPT CREATE OR REPLACE Procedure  101 :: DPS001
CREATE OR REPLACE PROCEDURE DPS001(
  data_cursor IN OUT pReturnData.c_Records,  
  pDyelineid in number,
  pclientid in varchar2,
  pOrderno IN NUMBER,
  sDate IN VARCHAR2,
  eDate IN VARCHAR2
)
AS
  vSDate date;
  vEDate date;
BEGIN
  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  end if;
OPEN data_cursor  FOR
SELECT A.DYELINEID,A.DYELINENO,B.BATCHNO,A.DYELINEDATE,C.SHADE,D.SHADEGROUPNAME,E.FABRICTYPE,GETFNCWOBTYPE(F.ORDERNO) AS WORKORDER,G.CLIENTNAME,
       sum(C.QUANTITY) AS PRODQTY,
	   (sum(C.QUANTITY)*(SELECT nvl(SUM(J.AUXQTY*nvl(fncAuxAvgPrice(j.AuxID,j.AuxTypeID,A.DYELINEDATE),0)),0) 
	        FROM T_DSUBITEMS J 
       WHERE J.DYELINEID=A.DYELINEID AND J.AUXTYPEID=1)/(select sum(quantity) from T_DBATCHITEMS where dbatchid=(select dbatchid from t_dyeline where DYELINEID=A.DYELINEID))) AS CHAMAMT,
	   (sum(C.QUANTITY)*(SELECT nvl(SUM(Y.AUXQTY*nvl(fncAuxAvgPrice(y.AuxID,y.AuxTypeID,A.DYELINEDATE),0)),0) 
	       FROM T_DSUBITEMS Y 
       WHERE Y.DYELINEID=A.DYELINEID AND Y.AUXTYPEID=2)/(select sum(quantity) from T_DBATCHITEMS where dbatchid=(select dbatchid from t_dyeline where DYELINEID=A.DYELINEID))) AS DYEAMT,
       0 as FinCost
FROM T_DYELINE A,T_DBATCH B,T_DBATCHITEMS C,T_SHADEGROUP D,T_FABRICTYPE E,T_WORKORDER F,T_CLIENT G      
WHERE 
   A.DBATCHID=B.DBATCHID AND
   B.DBATCHID=C.DBATCHID AND   
   (pDyelineid is null or A.DYELINEID=pDyelineid) and
   (pclientid is null or F.CLIENTID=pclientid) and
   C.SHADEGROUPID=D.SHADEGROUPID(+) AND
   C.FABRICTYPEID=E.FABRICTYPEID(+) AND  
   (pOrderno is null or C.ORDERNO=pOrderno) and
   C.ORDERNO=F.ORDERNO AND
   F.CLIENTID=G.CLIENTID(+) AND
   A.DYELINEDATE between decode(vSDate,null,'01-jan-2000',vSDate) and vEDate
GROUP BY A.DYELINEID,A.DYELINENO,B.BATCHNO,A.DYELINEDATE,C.SHADE,D.SHADEGROUPNAME,E.FABRICTYPE,F.ORDERNO,G.CLIENTNAME
order by A.DYELINEDATE,G.CLIENTNAME,F.ORDERNO;
END DPS001;
/

PROMPT CREATE OR REPLACE Procedure  102 :: KS001 
CREATE OR REPLACE Procedure KS001 
(
   data_cursor IN OUT pReturnData.c_Records,
   psubconID IN NUMBER,
   sDate IN VARCHAR2,
   eDate IN VARCHAR2
)
As
  vSDate date;
  vEDate date;
BEGIN
  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  end if;
OPEN data_cursor  FOR
select f.SUBCONNAME,d.UNITOFMEAS as unit,e.UNITOFMEAS as sunit,
       sum(decode(a.KNTITRANSACTIONTYPEID,4,b.QUANTITY,23,b.QUANTITY,0)) as Yarn_Issue_Qty,
       sum(decode(a.KNTITRANSACTIONTYPEID,4,b.SQUANTITY,23,b.SQUANTITY,0)) as Yarn_Issue_SQty, 
	   sum(decode(a.KNTITRANSACTIONTYPEID,7,b.QUANTITY,25,b.QUANTITY,0)) as Fab_Rec_Qty,
       sum(decode(a.KNTITRANSACTIONTYPEID,7,b.SQUANTITY,25,b.SQUANTITY,0)) as Fab_Rec_SQty,
	   0 as RFab_Rec_Qty,
       0 as RFab_Rec_SQty,	
       sum(decode(a.KNTITRANSACTIONTYPEID,10,b.QUANTITY,27,b.QUANTITY,0)) as Losse_Rec_Qty,
       sum(decode(a.KNTITRANSACTIONTYPEID,10,b.SQUANTITY,27,b.SQUANTITY,0)) as Losse_Rec_SQty       	   
from T_KnitStock a,T_KnitStockItems b,T_knittransactiontype c,T_unitofmeas d,T_unitofmeas e,
     T_subcontractors f
where (psubconID is null or a.SUBCONID=psubconID) and  
      a.STOCKID=b.STOCKID and
      a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
	  c.KNTITRANSACTIONTYPEID in (4,7,10,23,25,27) and
	  a.SUBCONID=f.SUBCONID(+) and
	  b.PUNITOFMEASID=d.UNITOFMEASID(+) and  
      b.SUNITOFMEASID=e.UNITOFMEASID(+) and
	  a.STOCKTRANSDATE between decode(vSDate,null,'01-jan-2000',vSDate) and decode(vEDate,null,'01-jan-2020',vEDate)
group by f.SUBCONNAME,d.UNITOFMEAS,e.UNITOFMEAS
order by f.SUBCONNAME;
End KS001;
/


PROMPT CREATE OR REPLACE Procedure  103 :: DIS001 
CREATE OR REPLACE Procedure DIS001 
(
   data_cursor IN OUT pReturnData.c_Records,   
   pClientId IN NUMBER,
   pOrderno IN NUMBER,
   sDate IN VARCHAR2,
   eDate IN VARCHAR2
)
As
  vSDate date;
  vEDate date;
BEGIN
  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  end if;
OPEN data_cursor  FOR
    select a.DInvoiceId,a.InvoiceNo,a.InvoiceDate,c.CLIENTNAME,c.CADDRESS,c.CTELEPHONE,
    	a.ContactPerson,a.DeliveryPlace,a.GatePassNo,DType,getfncwobtype(b.orderno) as workorder,
		b.QUANTITY,f.UNITOFMEAS as unit,b.SQUANTITY,g.UNITOFMEAS as sunit,b.Shade,e.fabrictype,
		b.DBatch,b.YARNBATCHNO,b.FINISHEDDIA,b.FINISHEDGSM,b.GWT,b.FWT,b.ORDERLINEITEM
    from T_DInvoice a,T_DinvoiceItems b,T_Client c,T_knittransactiontype d,T_fabrictype e,
	     T_Unitofmeas f,T_Unitofmeas g,T_shadegroup h
    where a.DInvoiceId=b.DInvoiceId and
	    (pOrderno is null or a.orderno=pOrderno) and  
        b.FABRICTYPEID=e.FABRICTYPEID(+) and		
        d.KNTITRANSACTIONTYPEID=a.DType and  a.DType='21' and
        b.PUNITOFMEASID=f.UNITOFMEASID(+) and b.SUNITOFMEASID=g.UNITOFMEASID(+) and		
		(pClientId is null or a.CLIENTID=pClientId) and
	    a.CLIENTID=c.CLIENTID and 
		b.shadegroupid=h.shadegroupid(+) and		
		a.InvoiceDate between decode(vSDate,null,'01-jan-2000',vSDate) and decode(vEDate,null,'01-jan-2020',vEDate)
    order by a.InvoiceNo,a.InvoiceDate,c.CLIENTNAME,getfncwobtype(b.orderno) asc;
End DIS001;
/


PROMPT CREATE OR REPLACE Procedure  104 :: T001ACCMRRDetails
CREATE OR REPLACE Procedure T001ACCMRRDetails (
   data_cursor IN OUT pReturnData.c_Records,
   pQueryType IN NUMBER,
   sDate IN VARCHAR2,
   eDate IN VARCHAR2
)
AS
  vSDate date;
  vEDate date;
BEGIN

if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
end if;
if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
end if;

if pQueryType=0 then
/* Report for T001 Acc MRR Details with all*/
OPEN data_cursor  FOR
SELECT A.StockTransNo,A.StockTransDate,A.ConRate,C.CURRENCYNAME,B.Quantity,D.UNITOFMEAS AS UNIT,
       A.ReferenceNo,A.ReferenceDate,A.SupplierInvoiceNo,A.SupplierInvoiceDate,A.Scomplete,A.Remarks AS MREMARKS,
       B.SQuantity,E.UNITOFMEAS AS SUNIT,B.UnitPrice,getfncDispalyorder(B.GOrderNo) AS GWORKORDER,
	   F.SUPPLIERNAME,F.SADDRESS,F.STELEPHONE,B.ClientRef,B.StyleNo,B.CurrentStock,B.ReqQuantity,   
	   G.ITEM AS ACCITEM,B.ImpLCNO,B.LineNo,H.COLOURNAME,B.Code,B.Count_Size,B.Remarks AS ITEMREMARKS,
	   B.RequisitionNo,J.GROUPNAME
FROM T_AccStock A,T_AccStockItems B,T_CURRENCY C,T_UNITOFMEAS D,T_UNITOFMEAS E,T_SUPPLIER F,
     T_ACCESSORIES G,T_COLOUR H,T_AccGroup J
WHERE a.STOCKID=b.STOCKID and
      A.CURRENCYID=C.CURRENCYID(+) AND 
	  B.PUNITOFMEASID=D.UNITOFMEASID(+) AND
	  B.SUNITOFMEASID=E.UNITOFMEASID(+) AND
	  B.AccessoriesID=G.AccessoriesID(+) AND
	  B.GroupID=J.GroupID(+) AND
	  B.ColourID=H.ColourID AND
	  A.SupplierId=F.SupplierId(+) AND
	  AccTransTypeID=1 AND
      A.StockTransDATE between decode(vSDate,null,'01-jan-1900',vSDate) and vEDate
ORDER BY A.StockTransDate,A.StockTransNo;
elsif pQueryType=1 then
/* Report for T001 Acc MRR Details with all price > zero*/
OPEN data_cursor  FOR
SELECT A.StockTransNo,A.StockTransDate,A.ConRate,C.CURRENCYNAME,B.Quantity,D.UNITOFMEAS AS UNIT,
       A.ReferenceNo,A.ReferenceDate,A.SupplierInvoiceNo,A.SupplierInvoiceDate,A.Scomplete,A.Remarks AS MREMARKS,
       B.SQuantity,E.UNITOFMEAS AS SUNIT,B.UnitPrice,getfncDispalyorder(B.GOrderNo) AS GWORKORDER,
	   F.SUPPLIERNAME,F.SADDRESS,F.STELEPHONE,B.ClientRef,B.StyleNo,B.CurrentStock,B.ReqQuantity,   
	   G.ITEM AS ACCITEM,B.ImpLCNO,B.LineNo,H.COLOURNAME,B.Code,B.Count_Size,B.Remarks AS ITEMREMARKS,
	   B.RequisitionNo,J.GROUPNAME
FROM T_AccStock A,T_AccStockItems B,T_CURRENCY C,T_UNITOFMEAS D,T_UNITOFMEAS E,T_SUPPLIER F,
     T_ACCESSORIES G,T_COLOUR H,T_AccGroup J
WHERE a.STOCKID=b.STOCKID and
      A.CURRENCYID=C.CURRENCYID(+) AND 
	  B.PUNITOFMEASID=D.UNITOFMEASID(+) AND
	  B.SUNITOFMEASID=E.UNITOFMEASID(+) AND
	  B.AccessoriesID=G.AccessoriesID(+) AND
	  B.GroupID=J.GroupID(+) AND
	  B.ColourID=H.ColourID AND
	  B.UnitPrice>0 and
	  A.SupplierId=F.SupplierId(+) AND
	  AccTransTypeID=1 AND
      A.StockTransDATE between decode(vSDate,null,'01-jan-1900',vSDate) and vEDate
ORDER BY A.StockTransDate,A.StockTransNo;
elsif pQueryType=2 then
/* Report for T001 Acc MRR Details with all price <= zero*/
OPEN data_cursor  FOR
SELECT A.StockTransNo,A.StockTransDate,A.ConRate,C.CURRENCYNAME,B.Quantity,D.UNITOFMEAS AS UNIT,
       A.ReferenceNo,A.ReferenceDate,A.SupplierInvoiceNo,A.SupplierInvoiceDate,A.Scomplete,A.Remarks AS MREMARKS,
       B.SQuantity,E.UNITOFMEAS AS SUNIT,B.UnitPrice,getfncDispalyorder(B.GOrderNo) AS GWORKORDER,
	   F.SUPPLIERNAME,F.SADDRESS,F.STELEPHONE,B.ClientRef,B.StyleNo,B.CurrentStock,B.ReqQuantity,   
	   G.ITEM AS ACCITEM,B.ImpLCNO,B.LineNo,H.COLOURNAME,B.Code,B.Count_Size,B.Remarks AS ITEMREMARKS,
	   B.RequisitionNo,J.GROUPNAME
FROM T_AccStock A,T_AccStockItems B,T_CURRENCY C,T_UNITOFMEAS D,T_UNITOFMEAS E,T_SUPPLIER F,
     T_ACCESSORIES G,T_COLOUR H,T_AccGroup J
WHERE a.STOCKID=b.STOCKID and
      A.CURRENCYID=C.CURRENCYID(+) AND 
	  B.PUNITOFMEASID=D.UNITOFMEASID(+) AND
	  B.SUNITOFMEASID=E.UNITOFMEASID(+) AND
	  B.AccessoriesID=G.AccessoriesID(+) AND
	  B.GroupID=J.GroupID(+) AND
	  B.ColourID=H.ColourID AND
	  B.UnitPrice<=0 and
	  A.SupplierId=F.SupplierId(+) AND
	  AccTransTypeID=1 AND
      A.StockTransDATE between decode(vSDate,null,'01-jan-1900',vSDate) and vEDate
ORDER BY A.StockTransDate,A.StockTransNo;
end if;
End T001ACCMRRDetails;
/

PROMPT CREATE OR REPLACE Procedure  105 :: GetGF001
CREATE OR REPLACE Procedure GetGF001(
   data_cursor IN OUT pReturnData.c_Records,
   pQueryType IN NUMBER,
   pOrderNo IN NUMBER,
   pClient IN NUMBER DEFAULT NULL,
   sDate IN VARCHAR2,
   eDate IN VARCHAR2
)
AS
  vSDate date;
  vEDate date;
BEGIN
  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  end if;
if pQueryType=1 then
/* Report for GF001 Yarn Stock Details */
open data_cursor for
select b.PID,a.STOCKTRANSDATE,a.STOCKTRANSNO,b.YARNBATCHNO,b.OrderNo,getfncWOBType(b.orderno) as workorder,
decode(e.GARMENTSORDERREF,NULL,'','FG-'||e.GARMENTSORDERREF)as gorder,e.BASICTYPEID as WOType,
getfncyarncount(b.YARNCOUNTID)||'-'||getfncyarntype(B.YARNTYPEID) AS YARNDESCRIPTION,
getfncClient(e.clientID) as ClientName,b.shade,getfncSubConName(a.subconid) as SubContractors,SUPPLIERNAME as SUPPLIERNAME,
 /*GRAY YARN ISSUE TO KNITTING PROCESS*/
  (decode (a.KNTITRANSACTIONTYPEID,3,b.Quantity,9,-b.Quantity,42,-b.Quantity,101,b.Quantity,102,-b.Quantity,0)) as GYI_FLOOR,
 (decode (a.KNTITRANSACTIONTYPEID,4,b.Quantity,10,-b.Quantity,0)) as GYI_OTHERS,
  /*DYED YARN ISSUE TO KNITTING PROCESS*/
 (decode (a.KNTITRANSACTIONTYPEID,22,b.Quantity,26,-b.Quantity,44,-b.Quantity,111,b.Quantity,112,-b.Quantity,0)) as DYI_FLOOR,
 (decode (a.KNTITRANSACTIONTYPEID,23,b.Quantity,27,-b.Quantity,0)) as DYI_OTHERS,

  /*NET GRAY YARN ISSUE TO KNITTING PROCESS*/
  (decode (a.KNTITRANSACTIONTYPEID,3,b.Quantity,9,-b.Quantity,42,-b.Quantity,101,b.Quantity,102,-b.Quantity,22,b.Quantity,26,-b.Quantity,44,-b.Quantity,111,b.Quantity,112,-b.Quantity,0)) as NET_YI_FLOOR,
 (decode (a.KNTITRANSACTIONTYPEID,4,b.Quantity,10,-b.Quantity,23,b.Quantity,27,-b.Quantity,0)) as NET_YI_OTHERS,
   /*GRAY YARN UNIT PRICE*/
 fncYarnAvgPrice(b.YARNCOUNTID,b.YARNTYPEID,b.YARNBATCHNO,a.STOCKTRANSDATE) AS UnitPrice,
 	/* DY Cost ATL*/
    0 AS DY_COST_ATL,
	/* DY Cost OTHERS*/
    0 AS DY_COST_OTHERS,
	/* GY Cost ATL*/
	(nvl(fncYarnAvgPrice(b.YARNCOUNTID,b.YARNTYPEID,b.YARNBATCHNO,a.STOCKTRANSDATE),0)*(decode (a.KNTITRANSACTIONTYPEID,3,b.Quantity,9,-b.Quantity,42,-b.Quantity,101,b.Quantity,102,-b.Quantity,0)))+(nvl(fncYarnAvgPrice(b.YARNCOUNTID,b.YARNTYPEID,b.YARNBATCHNO,a.STOCKTRANSDATE),0)*(decode (a.KNTITRANSACTIONTYPEID,22,b.Quantity,26,-b.Quantity,44,-b.Quantity,111,b.Quantity,112,-b.Quantity,0))) as GY_COST_ATL,
	/* GY Cost OTHERS*/
    (nvl(fncYarnAvgPrice(b.YARNCOUNTID,b.YARNTYPEID,b.YARNBATCHNO,a.STOCKTRANSDATE),0)*(decode (a.KNTITRANSACTIONTYPEID,4,b.Quantity,10,-b.Quantity,0)))+(nvl(fncYarnAvgPrice(b.YARNCOUNTID,b.YARNTYPEID,b.YARNBATCHNO,a.STOCKTRANSDATE),0)*(decode (a.KNTITRANSACTIONTYPEID,23,b.Quantity,27,-b.Quantity,0))) AS GY_COST_OTHERS,
	/* TOTAL Cost ATL*/
    (nvl(fncYarnAvgPrice(b.YARNCOUNTID,b.YARNTYPEID,b.YARNBATCHNO,a.STOCKTRANSDATE),0)*(decode (a.KNTITRANSACTIONTYPEID,3,b.Quantity,9,-b.Quantity,42,-b.Quantity,101,b.Quantity,102,-b.Quantity,0)))+(nvl(fncYarnAvgPrice(b.YARNCOUNTID,b.YARNTYPEID,b.YARNBATCHNO,a.STOCKTRANSDATE),0)*(decode (a.KNTITRANSACTIONTYPEID,22,b.Quantity,26,-b.Quantity,44,-b.Quantity,111,b.Quantity,112,-b.Quantity,0))) AS TOTAL_COST_ATL,
	/* TOTAL Cost OTHERS*/
    (nvl(fncYarnAvgPrice(b.YARNCOUNTID,b.YARNTYPEID,b.YARNBATCHNO,a.STOCKTRANSDATE),0)*(decode (a.KNTITRANSACTIONTYPEID,4,b.Quantity,10,-b.Quantity,0)))+(nvl(fncYarnAvgPrice(b.YARNCOUNTID,b.YARNTYPEID,b.YARNBATCHNO,a.STOCKTRANSDATE),0)*(decode (a.KNTITRANSACTIONTYPEID,23,b.Quantity,27,-b.Quantity,0))) AS TOTAL_COST_OTHERS

 from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c,t_workorder e,T_Client f,T_Supplier g
 /*,T_FabricType g*/
 where a.StockID=b.StockID and
 a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
 a.KNTITRANSACTIONTYPEID in (3,4,9,10,22,23,26,27,42,101,102,111,112,131,132) and
 b.orderno=e.orderno and e.ClientID=f.ClientID and
 b.SUPPLIERID=g.SUPPLIERID(+) and
 (pOrderNo is null or b.OrderNo=pOrderNo) and
 (pClient is NULL or e.ClientID=pClient) and
 a.STOCKTRANSDATE between decode(vSDate,null,'01-jan-1900',vSDate) and vEDate
  Order by a.STOCKTRANSDATE,b.OrderNo;

elsif pQueryType=2 then
/* Report for GF002 Yarn Stock Details */

open data_cursor for
select b.PID,a.STOCKTRANSDATE,a.STOCKTRANSNO,b.YARNBATCHNO,b.OrderNo,getfncWOBType(b.orderno) as workorder,
decode(e.GARMENTSORDERREF,NULL,'','FG-'||e.GARMENTSORDERREF)as gorder,e.BASICTYPEID as WOType,
getfncyarncount(b.YARNCOUNTID)||'-'||getfncyarntype(B.YARNTYPEID) AS YARNDESCRIPTION,g.Fabrictype,
getfncClient(e.clientID) as ClientName,b.shade,getfncSubConName(a.subconid) as SubContractors,
 /*GRAY YARN ISSUE TO KNITTING PROCESS*/
  (decode (a.KNTITRANSACTIONTYPEID,3,b.Quantity,9,-b.Quantity,42,-b.Quantity,101,b.Quantity,102,-b.Quantity,0)) as GYI_FLOOR,
 (decode (a.KNTITRANSACTIONTYPEID,4,b.Quantity,10,-b.Quantity,0)) as GYI_OTHERS,
  /*DYED YARN ISSUE TO KNITTING PROCESS*/
 (decode (a.KNTITRANSACTIONTYPEID,22,b.Quantity,26,-b.Quantity,44,-b.Quantity,111,b.Quantity,112,-b.Quantity,0)) as DYI_FLOOR,
 (decode (a.KNTITRANSACTIONTYPEID,23,b.Quantity,27,-b.Quantity,0)) as DYI_OTHERS,

  /*NET GRAY YARN ISSUE TO KNITTING PROCESS*/
  (decode (a.KNTITRANSACTIONTYPEID,3,b.Quantity,9,-b.Quantity,42,-b.Quantity,101,b.Quantity,102,-b.Quantity,22,b.Quantity,26,-b.Quantity,44,-b.Quantity,111,b.Quantity,112,-b.Quantity,0)) as NET_YI_FLOOR,
 (decode (a.KNTITRANSACTIONTYPEID,4,b.Quantity,10,-b.Quantity,23,b.Quantity,27,-b.Quantity,0)) as NET_YI_OTHERS,
   /*GRAY YARN UNIT PRICE*/
 fncYarnAvgPriceWithSupp(b.YARNCOUNTID,b.YARNTYPEID,b.YARNBATCHNO,b.SUPPLIERID,a.STOCKTRANSDATE) AS UnitPrice,
  /*GRAY FABRIC RECEIVED FROM KNITTING PROCESS(FLOOR)*/
  (decode (a.KNTITRANSACTIONTYPEID,6,b.Quantity,24,b.Quantity,0)) as GF_REC_FLOOR,
    /*GRAY FABRIC RECEIVED FROM KNITTING PROCESS(OTHERS)*/
 (decode (a.KNTITRANSACTIONTYPEID,7,b.Quantity,25,b.Quantity,0)) as GF_REC_OTHERS,
 	/* DY Cost ATL*/
    0 AS DY_COST_ATL,
	/* DY Cost OTHERS*/
    0 AS DY_COST_OTHERS,
	/* GY Cost ATL*/
	(nvl(fncYarnAvgPricewithSupp(b.YARNCOUNTID,b.YARNTYPEID,b.YARNBATCHNO,b.SUPPLIERID,a.STOCKTRANSDATE),0)*(decode (a.KNTITRANSACTIONTYPEID,3,b.Quantity,9,-b.Quantity,42,-b.Quantity,101,b.Quantity,102,-b.Quantity,0)))+(nvl(fncYarnAvgPricewithSupp(b.YARNCOUNTID,b.YARNTYPEID,b.YARNBATCHNO,b.SUPPLIERID,a.STOCKTRANSDATE),0)*(decode (a.KNTITRANSACTIONTYPEID,22,b.Quantity,26,-b.Quantity,44,-b.Quantity,111,b.Quantity,112,-b.Quantity,0))) as GY_COST_ATL,
	/* GY Cost OTHERS*/
    (nvl(fncYarnAvgPricewithSupp(b.YARNCOUNTID,b.YARNTYPEID,b.YARNBATCHNO,b.SUPPLIERID,a.STOCKTRANSDATE),0)*(decode (a.KNTITRANSACTIONTYPEID,4,b.Quantity,10,-b.Quantity,0)))+(nvl(fncYarnAvgPricewithSupp(b.YARNCOUNTID,b.YARNTYPEID,b.YARNBATCHNO,b.SUPPLIERID,a.STOCKTRANSDATE),0)*(decode (a.KNTITRANSACTIONTYPEID,23,b.Quantity,27,-b.Quantity,0))) AS GY_COST_OTHERS,
	/* TOTAL Cost ATL*/
    (nvl(fncYarnAvgPricewithSupp(b.YARNCOUNTID,b.YARNTYPEID,b.YARNBATCHNO,b.SUPPLIERID,a.STOCKTRANSDATE),0)*(decode (a.KNTITRANSACTIONTYPEID,3,b.Quantity,9,-b.Quantity,42,-b.Quantity,101,b.Quantity,102,-b.Quantity,0)))+(nvl(fncYarnAvgPricewithSupp(b.YARNCOUNTID,b.YARNTYPEID,b.YARNBATCHNO,b.SUPPLIERID,a.STOCKTRANSDATE),0)*(decode (a.KNTITRANSACTIONTYPEID,22,b.Quantity,26,-b.Quantity,44,-b.Quantity,111,b.Quantity,112,-b.Quantity,0))) AS TOTAL_COST_ATL,
	/* TOTAL Cost OTHERS*/
    (nvl(fncYarnAvgPricewithSupp(b.YARNCOUNTID,b.YARNTYPEID,b.YARNBATCHNO,b.SUPPLIERID,a.STOCKTRANSDATE),0)*(decode (a.KNTITRANSACTIONTYPEID,4,b.Quantity,10,-b.Quantity,0)))+(nvl(fncYarnAvgPricewithSupp(b.YARNCOUNTID,b.YARNTYPEID,b.YARNBATCHNO,b.SUPPLIERID,a.STOCKTRANSDATE),0)*(decode (a.KNTITRANSACTIONTYPEID,23,b.Quantity,27,-b.Quantity,0))) AS TOTAL_COST_OTHERS

 from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c,t_workorder e,T_Client f,T_FabricType g
 where a.StockID=b.StockID and
 a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
 a.KNTITRANSACTIONTYPEID in (3,4,6,7,9,10,22,23,24,25,26,27,42,101,102,111,112,131,132) and
 b.orderno=e.orderno and e.ClientID=f.ClientID and
 b.FabrictypeID=g.FabrictypeID and
 (pOrderNo is null or b.OrderNo=pOrderNo) and
 (pClient is NULL or e.ClientID=pClient) and
 a.STOCKTRANSDATE between decode(vSDate,null,'01-jan-1900',vSDate) and vEDate
  Order by a.STOCKTRANSDATE,b.OrderNo;
end if;
END GetGF001;
/


PROMPT CREATE OR REPLACE Procedure  106 :: GetReportAD05
CREATE OR REPLACE PROCEDURE GetReportAD05(
  data_cursor IN OUT pReturnData.c_Records,
  pKnitStockID number
)
As
BEGIN

  OPEN data_cursor  FOR
  select a.StockId,a.StockTransNO,a.StockTransDATE,getfncWOBType(b.ORDERNO) as workorder,
    c.YarnCount,d.YarnType,e.FabricType,b.OrderlineItem,b.CurrentStock,a.KNTITRANSACTIONTYPEID,
    (b.CurrentStock+b.Quantity) AS AdjustQty,b.Shade,b.DYEDLOTNO,
    b.Quantity,f.unitOfmeas as punit,b.YarnBatchNo,h.SHADEGROUPNAME,b.UnitPrice
  from T_KnitStock a,T_KnitStockItems b, t_yarncount c,t_yarntype d,t_fabrictype e,t_unitofmeas f,T_shadegroup h
  where a.StockId=b.StockId(+) and       
        b.yarncountid=c.yarncountid(+) and 
        b.PunitOfmeasId=f.unitOfmeasId(+) and           
        b.yarntypeid=d.yarntypeid(+) and
        b.shadegroupid=h.shadegroupid(+) and
        b.fabrictypeid=e.fabrictypeid(+) and
        a.StockId=pKnitStockID order by b.KNTISTOCKITEMSL asc;
End GetReportAD05;
/



PROMPT CREATE OR REPLACE Procedure  107 :: R005Report
CREATE OR REPLACE PROCEDURE R005Report(
  data_cursor IN OUT pReturnData.c_Records,
  pKnitStockID number
)
As
BEGIN

  OPEN data_cursor  FOR
  select a.StockId,a.StockTransNO,a.StockTransDATE,getfncWOBType(b.ORDERNO) as workorder,j.SUBCONNAME,j.SUBADDRESS,     
    c.YarnCount,d.YarnType,e.FabricType,b.OrderlineItem,b.CurrentStock,a.KNTITRANSACTIONTYPEID,b.Shade,b.DYEDLOTNO,
    b.Quantity,f.unitOfmeas as punit,b.YarnBatchNo,h.SHADEGROUPNAME,b.UnitPrice
  from T_KnitStock a,T_KnitStockItems b, t_yarncount c,t_yarntype d,t_fabrictype e,t_unitofmeas f,T_shadegroup h,T_subcontractors j
  where a.StockId=b.StockId(+) and       
        b.yarncountid=c.yarncountid(+) and 
        b.PunitOfmeasId=f.unitOfmeasId(+) and           
        b.yarntypeid=d.yarntypeid(+) and
        b.shadegroupid=h.shadegroupid(+) and
		a.SUBCONID=j.SUBCONID(+) and
        b.fabrictypeid=e.fabrictypeid(+) and
        a.StockId=pKnitStockID order by b.KNTISTOCKITEMSL asc;
End R005Report;
/

PROMPT CREATE OR REPLACE Procedure  108 :: GetReportSmapleGatepass
CREATE OR REPLACE Procedure GetReportSmapleGatepass
(
  one_cursor IN OUT pReturnData.c_Records,
  pGPID number
)
AS
BEGIN

    open one_cursor for
    select 	a.GPID,a.GPASSNO,a.GPASSDATE,Nvl(a.ORDERNO,'N/A') as dorderno,a.CONTACTPERSON,a.DELIVERYPLACE,a.CTELEPHONE,b.style,
			b.SERIALNO,b.ITEMSDESC,b.QUANTITY,b.UNITOFMEASID,b.RETURNABLE,B.NONRETURNABLE,b.SAMPLEID,a.clientname,d.unitofmeas,e.sampletype,g.employeename 
    from 	T_GSampleGatePass a,
			T_GSampleGatePassItems b,			
			T_Unitofmeas d,	
			T_GSampleType e,				
			T_Employee g			
    where 		a.GPID=B.GPID and			
			b.unitofmeasid=d.unitofmeasid and
			b.sampleid=e.sampleid and			
			a.employeeid=g.employeeid(+) and
			a.GPID=pGPID
    order by b.SERIALNO asc;
END GetReportSmapleGatepass;
/



PROMPT CREATE OR REPLACE Procedure  109 ::GetReportGatepassSum
CREATE OR REPLACE Procedure GetReportGatepassSum
(
  one_cursor IN OUT pReturnData.c_Records,
  pGPID number,
  sDate IN VARCHAR2,
  eDate IN VARCHAR2
)
AS
  vSDate date;
  vEDate date;
BEGIN

  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  end if;

    open one_cursor for
    select 	sum(b.ReturnedQty) as ReturnedQty,sum(b.RETURNABLE) as RETURNABLE,
			sum(b.QUANTITY) as QUANTITY,b.UNITOFMEASID,d.unitofmeas
    from 		T_GSampleGatePass a,
			T_GSampleGatePassItems b,			
			T_Unitofmeas d,						
			T_Employee g			
    where 		a.GPID=B.GPID and			
			b.unitofmeasid=d.unitofmeasid and			
			a.preparedby=g.employeeid(+) and
			( pGPID is null or a.GPID=pGPID) and 
  			a.GPASSDATE between decode(vSDate,null,'01-jan-2000',vSDate) and vEDate
	group by 	b.UNITOFMEASID,d.unitofmeas
    order by 		d.unitofmeas;
END GetReportGatepassSum;
/


PROMPT CREATE OR REPLACE Procedure  110 ::GetReportGatepassSummary
CREATE OR REPLACE Procedure GetReportGatepassSummary
(
  one_cursor IN OUT pReturnData.c_Records,
  pGPID number,
  sDate IN VARCHAR2,
  eDate IN VARCHAR2
)
AS
  vSDate date;
  vEDate date;
BEGIN

  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  end if;

    open one_cursor for
    select 	a.GPASSDATE,g.employeename,sum(b.ReturnedQty) as ReturnedQty,sum(b.RETURNABLE) as RETURNABLE,
			sum(b.QUANTITY) as QUANTITY,b.UNITOFMEASID,d.unitofmeas
    from 		T_GSampleGatePass a,
			T_GSampleGatePassItems b,			
			T_Unitofmeas d,						
			T_Employee g			
    where 		a.GPID=B.GPID and			
			b.unitofmeasid=d.unitofmeasid and			
			a.preparedby=g.employeeid(+) and
			( pGPID is null or a.GPID=pGPID) and 
  			a.GPASSDATE between decode(vSDate,null,'01-jan-2000',vSDate) and vEDate
	group by 	a.GPASSDATE,g.employeename,b.UNITOFMEASID,d.unitofmeas
    order by 		a.GPASSDATE,g.employeename;
END GetReportGatepassSummary;
/

PROMPT CREATE OR REPLACE Procedure  111 :: GetReportSGatepassSummary
CREATE OR REPLACE Procedure GetReportSGatepassSummary
(
  one_cursor IN OUT pReturnData.c_Records,
  pGPID number,
  sDate IN VARCHAR2,
  eDate IN VARCHAR2
)
AS
  vSDate date;
  vEDate date;
BEGIN

  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  end if;

    open one_cursor for
    select 	a.GPID,a.GPASSNO,a.GPASSDATE,Nvl(a.ORDERNO,'N/A') as dorderno,a.CONTACTPERSON,a.DELIVERYPLACE, a.CTELEPHONE,b.style,Nvl(b.ReturnedQty,0) as ReturnedQty,
			b.SERIALNO,b.ITEMSDESC,Nvl(b.QUANTITY,0) as QUANTITY,b.UNITOFMEASID,Nvl(b.RETURNABLE,0) as RETURNABLE,Nvl(B.NONRETURNABLE,0) as NONRETURNABLE,b.SAMPLEID,a.clientname,d.unitofmeas,e.sampletype,g.employeename 
    from 	T_GSampleGatePass a,
			T_GSampleGatePassItems b,			
			T_Unitofmeas d,	
			T_GSampleType e,				
			T_Employee g			
    where 		a.GPID=B.GPID and			
			b.unitofmeasid=d.unitofmeasid and
			b.sampleid=e.sampleid and			
			a.preparedby=g.employeeid(+) and
			( pGPID is null or a.GPID=pGPID) and 
  			a.GPASSDATE between decode(vSDate,null,'01-jan-2000',vSDate) and vEDate
    order by 		b.SERIALNO DESC;
END GetReportSGatepassSummary;
/


PROMPT CREATE OR REPLACE Procedure  112 :: GetReportKMR 
CREATE OR REPLACE Procedure GetReportKMR 
(
   data_cursor IN OUT pReturnData.c_Records,
   pKnitStockID IN NUMBER
)
As
Begin
  OPEN data_cursor  FOR
  select YarnCount,YarnType,a.Quantity,a.Squantity,m.currencyname,b.CONRATE,a.unitprice,
  f.UNITOFMEAS as PUOM,g.UNITOFMEAS as SUOM,YARNBATCHNO,a.SHADE,
  a.Remarks,a.REQUISITIONNO,b.STOCKID,b.ReferenceNo,b.ReferenceDate,b.StockTransNO,
  b.StockTransDATE,E.SUPPLIERNAME,E.SADDRESS,b.SupplierInvoiceNo,b.SupplierInvoiceDate,j.SubConName,j.SUBADDRESS,j.SUBCONTACTPERSON,
 h.orderNo,getfncWOBType(h.orderno) as workorder,k.shadegroupName
  from T_KnitStockItems a,T_KnitStock b,T_YarnCount c ,
  T_YarnType d,T_SUPPLIER E,t_UnitOfMeas f,t_UnitOfMeas g,
  t_WorkOrder h,T_Subcontractors j,t_shadegroup k,T_currency m
  where a.STOCKID=b.STOCKID and
  a.supplierId=e.supplierID(+) and
  a.shadegroupid=k.shadegroupid(+) and 
  a.YarnCountID=c.YarnCountID(+)  and
  a.YarnTypeID=d.YarnTypeID(+)  and
  b.currencyid=m.currencyid(+) and
  a.PUNITOFMEASID=f.UNITOFMEASID(+) And
  a.SUNITOFMEASID=g.UNITOFMEASID(+) And
  a.orderNo=h.OrderNo And
  b.SubconId=j.SubconId And
  a.STOCKID=pKnitStockID;
End GetReportKMR;
/

PROMPT CREATE OR REPLACE Procedure  113 :: GetLossSummary
CREATE OR REPLACE Procedure GetLossSummary(
   data_cursor IN OUT pReturnData.c_Records,
   pQueryType IN NUMBER,
   pClient IN NUMBER DEFAULT NULL,
   sDate IN VARCHAR2,
   eDate IN VARCHAR2
)
AS
  vSDate date;
  vEDate date;
BEGIN
  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  end if;
if pQueryType=1 then
open data_cursor for
select b.OrderNo,getfncWOBType(b.orderno) as workorder,e.ORDERDATE,f.ClientName,e.basictypeid,
/* YARN DYEING and knitting PROCESS [YARN ISSUE FOR YARN DYEING]*/
 SUM(decode (a.KNTITRANSACTIONTYPEID,3,b.Quantity,22,b.Quantity,0)) as YI_FLOOR,
 SUM(decode (a.KNTITRANSACTIONTYPEID,4,b.Quantity,23,b.Quantity,0)) as YI_OTHERS,
 SUM(decode (a.KNTITRANSACTIONTYPEID,3,b.Quantity,4,b.Quantity,22,b.Quantity,23,b.Quantity,0)) as YI_TOTAL,
/* YARN DYEING and knitting PROCESS [YARN RETURN FROM YARN DYEING]*/
 SUM(decode (a.KNTITRANSACTIONTYPEID,9,b.Quantity,26,b.Quantity,0)) as YRF_FLOOR,
 SUM(decode (a.KNTITRANSACTIONTYPEID,10,b.Quantity,27,b.Quantity,0)) as YRF_OTHERS,
 SUM(decode (a.KNTITRANSACTIONTYPEID,9,b.Quantity,10,b.Quantity,26,b.Quantity,27,b.Quantity,0)) as YR_TOTAL,
/* Knit Yarn Transfer One to Another */
 SUM(decode(a.KNTITRANSACTIONTYPEID,101,b.Quantity,131,b.Quantity,0)) as YT_FROM,
 SUM(decode(a.KNTITRANSACTIONTYPEID,102,b.Quantity,132,b.Quantity,0)) as YT_TO,
 SUM(decode(a.KNTITRANSACTIONTYPEID,101,b.Quantity,102,-b.Quantity,131,b.Quantity,132,-b.Quantity,0)) as YT_TOTAL,
 /* YARN DYEING and knitting PROCESS [YARN RECEIVED FROM YARN DYEING]*/
 SUM(decode (a.KNTITRANSACTIONTYPEID,6,b.Quantity,24,b.Quantity,0)) as YREC_FLOOR,
 SUM(decode (a.KNTITRANSACTIONTYPEID,7,b.Quantity,25,b.Quantity,0)) as YREC_OTHERS,
 SUM(decode (a.KNTITRANSACTIONTYPEID,6,b.Quantity,7,b.Quantity,24,b.Quantity,25,b.Quantity,0)) AS REC_TOTAL,
 /*Yarn reject from floor and others*/
 SUM(decode (a.KNTITRANSACTIONTYPEID,42,b.Quantity,43,b.Quantity,44,b.Quantity,0)) as YRJ_FLOOR,
 SUM(decode (a.KNTITRANSACTIONTYPEID,53,b.Quantity,54,b.Quantity,0)) as YRJ_OTHERS,
 SUM(decode (a.KNTITRANSACTIONTYPEID,42,b.Quantity,43,b.Quantity,44,b.Quantity,53,b.Quantity,54,b.Quantity,0)) as YRJ_TOTAL, 
 /* KNITTING PROCESS [TOTAL NET YARN ISSUD FOR KNITTING ]*/
  SUM(decode (a.KNTITRANSACTIONTYPEID,3,b.Quantity,22,b.Quantity,9,-b.Quantity,26,-b.Quantity,101,b.Quantity,131,b.Quantity,
     102,-b.Quantity,132,-b.Quantity,6,-b.Quantity,24,-b.Quantity,42,-b.Quantity,43,-b.Quantity,44,-b.Quantity,0)) AS NET_YARN_FLOOR,
 /* KNITTING PROCESS [TOTAL NET YARN ISSUD FOR OTHERS ]*/
  SUM(decode (a.KNTITRANSACTIONTYPEID,4,b.Quantity,23,b.Quantity,10,-b.Quantity,27,-b.Quantity,
      7,-b.Quantity,25,-b.Quantity,53,-b.Quantity,54,-b.Quantity,0))AS NET_YARN_OTHERS,
 /* KNITTING PROCESS [TOTAL NET YARN FLOOR AND OTHERS ]*/
  SUM(decode (a.KNTITRANSACTIONTYPEID,3,b.Quantity,9,-b.Quantity,101,b.Quantity,102,-b.Quantity,6,-b.Quantity,4,b.Quantity,10,-b.Quantity,
       7,-b.Quantity,42,-b.Quantity,43,-b.Quantity,44,-b.Quantity,53,-b.Quantity,54,-b.Quantity,
      22,b.Quantity,26,-b.Quantity,131,b.Quantity,132,-b.Quantity,24,-b.Quantity,23,b.Quantity,27,-b.Quantity,25,-b.Quantity,0))AS NET_YARN_GRAND_TOTAL
 from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c,  t_workorder e,T_Client f
 where a.StockID=b.StockID and
 a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and a.KNTITRANSACTIONTYPEID in (3,4,6,7,9,10,22,23,24,25,26,27,42,43,44,53,54,101,102,131,132) and
 b.orderno=e.orderno and e.ClientID=f.ClientID and
 (pClient is NULL or e.ClientID=pClient) and
 e.ORDERDATE between decode(vSDate,null,'01-jan-1900',vSDate) and vEDate
GROUP BY b.OrderNo,e.ORDERDATE,f.ClientName,e.basictypeid
ORDER BY getfncWOBType(b.orderno);
end if;
END GetLossSummary;
/


PROMPT CREATE OR REPLACE Procedure  114 :: rptPrintSummary
Create or Replace Procedure rptPrintSummary
(
    one_cursor IN OUT pReturnData.c_Records,
  	pOrderno in number,
	sOrderNo IN number,
  	eOrderno IN number
)
AS
minorder number(10);
maxorder number(10);
BEGIN
open one_cursor for
    select 	getfncDispalyorder(b.ORDERNO) as dorder,b.sizeid,c.sizename,b.styleno,b.shade,
	x.clientname, d.subconname,sum(decode(gtranstypeid,4,quantity,0)) as Send,
	sum(decode(gtranstypeid,5,quantity,0)) as Recvd
    from T_GSTOCK a,
		T_GStockItems b,
		T_size c,
		t_subcontractors d,
		t_client x,
		t_gworkorder y
    where a.stockid=b.stockid and	
		b.orderno=y.gorderno and
		y.clientid=x.clientid(+) and
		b.sizeid=c.sizeid(+)	and 
		a.subconid=d.subconid(+) and
		(pOrderno is null or b.orderno=pOrderno) and	
		b.gtranstypeid in(4,5) and
		(sOrderNo is null or b.ORDERNO>=sOrderNo) and
		(eOrderNo is null or b.ORDERNO<=eOrderNo)
	Group by d.subconname,b.ORDERNO,x.clientname,b.sizeid,c.sizename,b.styleno,shade
	order by dorder desc;
END rptPrintSummary;
/


PROMPT CREATE OR REPLACE Procedure  115 :: rptDIPrintSummary
CREATE OR REPLACE Procedure rptDIPrintSummary
(
  one_cursor IN OUT pReturnData.c_Records,
  pOrderNo in number,  
  sOrderNo in Number,
  eOrderNo in Number,
  sDate IN VARCHAR2,
  eDate IN VARCHAR2
)
AS
vSDate date;
vEDate date;
minorder number(10);
maxorder number(10);
BEGIN
    if not sDate is null then
		vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
	end if;
	if not eDate is null then
		vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
	end if;
open one_cursor for
    select 	a.StockTransNO,a.StockTransDATE,getfncDispalyorder(b.ORDERNO) as dorder,
    		sum(b.Quantity) as quantity,b.Shade,b.Styleno,c.subconname
    from  
		T_GSTOCK a,
		T_GStockItems b,
		t_subcontractors c	
    where
		a.stockid=b.stockid and
		b.GTRANSTYPEID=4 and
		(pOrderNo is null or pOrderNo=b.ORDERNO) and
		a.SUBCONID=c.SUBCONID(+) and
		(sOrderNo is null or b.ORDERNO>=sOrderNo) and
		(eOrderNo is null or b.ORDERNO<=eOrderNo) and
		a.StockTransDATE between decode(vSDate,null,'01-jan-2000',vSDate) and vEDate
	group by a.StockTransNO,a.StockTransDATE,b.ORDERNO,b.Shade,b.Styleno,c.subconname	
    order by getfncDispalyorder(b.ORDERNO),a.StockTransNO,a.StockTransDATE,c.subconname,b.Shade,b.Styleno asc;
END rptDIPrintSummary;
/



PROMPT CREATE OR REPLACE Procedure  116 :: GetReportMoneyRec
CREATE OR REPLACE Procedure GetReportMoneyRec  (
  data_cursor IN OUT pReturnData.c_Records,
  pPID IN NUMBER,
  pInwords in varchar2
)
As
Begin
  OPEN data_cursor FOR
  select a.PID,a.RECEIPTNO,a.RECEIPTDATE,b.RECEIPENTNAME,c.PARTYNAME,a.AMOUNT,a.CASH,a.CHEQUE,a.PAYORDER,       
a.DRAFT,a.PAYMENTNO,a.PAYDATE,a.BILLNO,a.PURPOSE,d.EMPLOYEENAME,a.BRANCH,e.BANKNAME,b.description      
  from T_moneyreceipt a,T_receipent b,T_party c,T_employee d,T_LcBank e
  where a.PID=pPID and
         a.RECEIPTFOR=b.RID(+) and
         a.PARTYID=c.PARTYID(+) and 
		 a.bankid=e.bankid(+) and 
		 a.EMPLOYEEID=d.EMPLOYEEID(+);
End GetReportMoneyRec;
/




PROMPT CREATE OR REPLACE Procedure  117 :: GetReportPermissionCheck
CREATE OR REPLACE Procedure GetReportPermissionCheck(
  data_cursor IN OUT pReturnData.c_Records,
  pEmployeeID in varchar2
)
As
Begin
  OPEN data_cursor FOR
	select a.EMPLOYEEID,a.FORMID,c.EMPLOYEENAME,b.FORMDESC,d.DESIGNATION,e.EMPGROUP as DEPARTMENT,
    decode(a.FORMPERMISSION,1,'Read Only',2,'Full Access',3,'No Access','') as permission,'F' AS FRGroup
    from T_Empforms a,T_Forms b, T_Employee c,t_designation d,  t_empgroup e
    where a.FORMID=b.FORMID and
    a.EMPLOYEEID=c.EMPLOYEEID and
	c.DESIGNATIONID=d.DESIGNATIONID and
	c.EMPGROUPID=e.EMPGROUPID and
    (a.FORMPERMISSION in (1,2)) and
    c.EMPLOYEEID=pEmployeeID	
	UNION ALL
	select a.EMPLOYEEID,a.REPORTID AS FORMID,c.EMPLOYEENAME,b.REPORTTITLE AS FORMDESC,d.DESIGNATION,e.EMPGROUP as DEPARTMENT,
    decode(a.BACCESS,1,'Read Only',2,'Full Access',3,'No Access','') as permission, 'R' AS FRGroup
    from T_REPORTACCESS a,T_REPORTLIST b, T_Employee c ,t_designation d,  t_empgroup e
    where a.REPORTID=b.REPORTID and
    a.EMPLOYEEID=c.EMPLOYEEID and
	c.DESIGNATIONID=d.DESIGNATIONID and
	c.EMPGROUPID=e.EMPGROUPID and
    (a.BACCESS in (1,2)) and
    c.EMPLOYEEID=pEmployeeID
    ORDER BY EMPLOYEEID;
End GetReportPermissionCheck;
/


PROMPT CREATE OR REPLACE Procedure  118 :: GetReportGMachineAll
CREATE OR REPLACE Procedure GetReportGMachineAll
(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pmcStockID IN NUMBER,
  sDate IN VARCHAR2,
  eDate IN VARCHAR2
)
AS
  vSDate date;
  vEDate date;

BEGIN
  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  else
   vSDate := TO_DATE('01/01/1900', 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  else
   vEDate := TO_DATE('01/01/1900', 'DD/MM/YYYY');
  end if;

/* For Report T39: Parts MRR Only*/
  if pQueryType=1 then

open data_cursor for
  select   a.StockDate,a.StockId,b.PartId,c.PARTNAME,b.Qty,a.PURCHASEORDERNO,a.PURCHASEORDERDATE,a.SUPPLIERNAME,
  a.SUPPLIERADDRESS,a.DELIVERYNOTE,a.Challanno,a.CHALLANDATE,b.Stockitemsl,c.Binno,c.DESCRIPTION,b.REMARKS, UnitPrice, x.CURRENCYNAME, a.ConRate
  from T_GMcStock a,T_GMcStockItems b,T_GMcPartsInfo c, T_Currency x 
  where a.StockId=b.StockId and
  b.PartId=c.PartId  and
  a.currencyid=x.currencyid and
  a.TEXMCSTOCKTYPEID=1 And 
  a.StockId=pmcStockID ORDER BY b.Stockitemsl;

/* For Report T40: Parts MR Only*/
  elsif pQueryType=2 then
 open data_cursor for

  select   a.StockDate,a.StockId,b.PartId,c.PARTNAME,b.Qty,a.PURCHASEORDERNO,a.PURCHASEORDERDATE,a.SUPPLIERNAME,
  a.SUPPLIERADDRESS,a.DELIVERYNOTE,a.Challanno,a.CHALLANDATE,b.Stockitemsl,c.Binno,c.DESCRIPTION,b.REMARKS,d.McListName
  from T_GMcStock a,T_GMcStockItems b,T_GMcPartsInfo c,T_GMclist d
  where a.StockId=b.StockId and
  b.PartId=c.PartId  and
  b.IssueFor=d.McListId(+) and
  a.TEXMCSTOCKTYPEID=2 And 
  a.StockId=pmcStockID ORDER BY b.Stockitemsl;

/* For Report T41: Parts Return Only*/
  elsif pQueryType=3 then
 open data_cursor for

  select   a.StockDate,a.StockId,b.PartId,c.PARTNAME,b.Qty,a.PURCHASEORDERNO,a.PURCHASEORDERDATE,a.SUPPLIERNAME,
  a.SUPPLIERADDRESS,a.DELIVERYNOTE,a.Challanno,a.CHALLANDATE,b.Stockitemsl,c.Binno,c.DESCRIPTION,b.REMARKS,d.McListName
  from T_GMcStock a,T_GMcStockItems b,T_GMcPartsInfo c,T_GMclist d
  where a.StockId=b.StockId and
  b.PartId=c.PartId  and
  b.IssueFor=d.McListId(+) and
  a.TEXMCSTOCKTYPEID=3 And 
  a.StockId=pmcStockID ORDER BY b.Stockitemsl;

/* For Report T42: Parts Requisition Only*/
  elsif pQueryType=4 then
 open data_cursor for

  select   a.StockDate,a.StockId,b.PartId,c.PARTNAME,b.Qty,a.PURCHASEORDERNO,a.PURCHASEORDERDATE,a.SUPPLIERNAME,
  a.SUPPLIERADDRESS,a.DELIVERYNOTE,a.Challanno,a.CHALLANDATE,b.Stockitemsl,c.Binno,c.DESCRIPTION,b.REMARKS,d.McListName
  from T_GMcStockReq a,T_GMcStockItemsReq b,T_GMcPartsInfo c,T_GMclist d
  where a.StockId=b.StockId and
  b.PartId=c.PartId  and
  b.IssueFor=d.McListId(+) and
  a.TEXMCSTOCKTYPEID=2 And 
  a.StockId=pmcStockID ORDER BY b.Stockitemsl;
  end if;

END GetReportGMachineAll;
/


PROMPT CREATE OR REPLACE Procedure  119 :: T152RptSubConKnitting
CREATE OR REPLACE Procedure T152RptSubConKnitting(
  data_cursor IN OUT pReturnData.c_Records,     
  pOrderNo IN NUMBER  DEFAULT NULL, 
  pClient IN VARCHAR2  DEFAULT NULL,
  pSDate IN VARCHAR2  DEFAULT NULL, 
  pEDate IN VARCHAR2  DEFAULT NULL 
) 
AS 
  vSDate date;
  vEDate date;
 
BEGIN 
  if not pSDate is null then
    vSDate := TO_DATE(pSDate, 'DD/MM/YYYY');
  end if;
  if not pEDate is null then
    vEDate := TO_DATE(pEDate, 'DD/MM/YYYY');
  end if;  
    OPEN data_cursor  FOR
       SELECT getfncWOBType(A.ORDERNO) AS WORDER,B.ClientName,D.FabricType,E.STOCKTRANSDATE,
		    sum(decode(E.KNTITRANSACTIONTYPEID,4,F.Quantity,5,F.Quantity,10,-F.Quantity,11,-F.Quantity,0)) YarnDel,
			sum(decode(E.KNTITRANSACTIONTYPEID,7,F.Quantity,25,F.Quantity,0)) FabRec			
	   FROM T_WorkOrder A,T_Client B,T_FabricType D,T_Knitstock E, T_KnitStockItems F
	   WHERE E.KNTITRANSACTIONTYPEID IN (4,5,10,11,7,25) AND
	        (pOrderNo IS NULL OR F.ORDERNO=pOrderNo) AND 
			(pClient IS NULL OR A.CLIENTID=pClient) AND
	        A.CLIENTID=B.CLIENTID(+) AND
			F.ORDERNO=A.ORDERNO AND
			E.STOCKID=F.STOCKID(+) and
			F.FABRICTYPEID=D.FABRICTYPEID(+) AND
			E.STOCKTRANSDATE BETWEEN DECODE(vSDate,null,'01-jan-2000',vSDate) AND vEDate
	   GROUP BY getfncWOBType(A.ORDERNO),B.ClientName,D.FabricType,E.STOCKTRANSDATE
	   ORDER BY getfncWOBType(A.ORDERNO),B.ClientName,E.STOCKTRANSDATE; 
END T152RptSubConKnitting;
/  



PROMPT CREATE OR REPLACE Procedure  120 :: GetBG04RPT
CREATE OR REPLACE Procedure GetBG04RPT(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pOrderNo IN VARCHAR2  DEFAULT NULL,
  pClient IN VARCHAR2  DEFAULT NULL,
  pSDate IN VARCHAR2  DEFAULT NULL,
  pEDate IN VARCHAR2  DEFAULT NULL
)
AS
  vSDate date;
  vEDate date;
BEGIN
  if not pSDate is null then
    vSDate := TO_DATE(pSDate, 'DD/MM/YYYY');
  else
	vSDate := TO_DATE('01-JAN-2000', 'DD/MM/YYYY');
  end if;
  if not pEDate is null then
    vEDate := TO_DATE(pEDate, 'DD/MM/YYYY');
  else
	vEDate := TO_DATE('01-JAN-2900', 'DD/MM/YYYY');
  end if;
 if pQueryType=0 then
 /* for BG04.rpt FOR All WO*/
	OPEN data_cursor  FOR
    SELECT getfncWOBType(A.ORDERNO) AS WORDER,(ORDERTYPEID || ' ' || BUDGETNO) as BUDGETNO,B.ClientName,
		F.FABRICTYPEID,D.FabricType,SUM(E.QUANTITY) AS WOQty,
		/*nvl(fncBKnittingQty(F.BUDGETID,F.FABRICTYPEID),0)*/ 
		nvl(GETYARNQTY(F.BUDGETID,E.FABRICTYPEID),0) AS BFabricQty,
		nvl(GETFABRICCONSP(E.ORDERNO,E.FABRICTYPEID),0) as AFabriccon,
		nvl(GETYARNQTY(F.BUDGETID,E.FABRICTYPEID),0) AS BYarnQty,
		nvl(GETYARNCONSP(E.ORDERNO,E.FABRICTYPEID),0) as AYarncon,
		/*nvl(GETDYEINGQTY(F.BUDGETID,F.FABRICTYPEID),0)*/
		nvl(fncBDyeingCostQty(F.BUDGETID,F.FABRICTYPEID),0) as BDyeingQty,
		nvl(GETDYEINGCONSP(E.ORDERNO,E.FABRICTYPEID),0) as ADyeingcon,
		nvl(GETFINISHINGQTY(F.BUDGETID),0) as BFinishingQty,
		nvl(GETFINISHINGCONSP(E.ORDERNO,E.FABRICTYPEID),0) as AFinishingcon
		FROM T_WorkOrder A,T_Client B,T_BUDGET C,T_FabricType D,T_ORDERITEMS E,
	    T_FabricConsumption F
		WHERE /* E.ORDERNO=5111  (pOrderNo IS NULL OR E.ORDERNO=pOrderNo) AND */ 
		(pClient IS NULL OR A.CLIENTID=pClient) AND
		E.FABRICTYPEID=D.FABRICTYPEID AND
	    A.CLIENTID=B.CLIENTID(+) AND
		A.ORDERNO=E.ORDERNO and
		A.BUDGETID=C.BUDGETID AND
		A.BUDGETID=F.BUDGETID AND
		c.revision=65 and
		E.FABRICTYPEID=F.FABRICTYPEID(+) and
		A.ORDERDATE between vSDate AND vEDate
	GROUP BY F.BUDGETID,ORDERTYPEID,BUDGETNO,getfncWOBType(A.ORDERNO),E.ORDERNO,E.FABRICTYPEID,F.FABRICTYPEID,B.ClientName,D.FabricType
	ORDER BY getfncWOBType(A.ORDERNO);
 elsif pQueryType=1 then
 /* for BG04.rpt FOR Selected  WO*/
	OPEN data_cursor  FOR
    SELECT getfncWOBType(A.ORDERNO) AS WORDER,(ORDERTYPEID || ' ' || BUDGETNO) as BUDGETNO,B.ClientName,
		F.FABRICTYPEID,D.FabricType,SUM(E.QUANTITY) AS WOQty,
		nvl(GETYARNQTY(F.BUDGETID,E.FABRICTYPEID),0) AS BFabricQty,
		nvl(GETFABRICCONSP(E.ORDERNO,E.FABRICTYPEID),0) as AFabriccon,
		nvl(GETYARNQTY(F.BUDGETID,E.FABRICTYPEID),0) AS BYarnQty,
		nvl(GETYARNCONSP(E.ORDERNO,E.FABRICTYPEID),0) as AYarncon,
		nvl(fncBDyeingCostQty(F.BUDGETID,F.FABRICTYPEID),0) as BDyeingQty,
		nvl(GETDYEINGCONSP(E.ORDERNO,E.FABRICTYPEID),0) as ADyeingcon,
		nvl(GETFINISHINGQTY(F.BUDGETID),0) as BFinishingQty,
		nvl(GETFINISHINGCONSP(E.ORDERNO,E.FABRICTYPEID),0) as AFinishingcon
	FROM T_WorkOrder A,T_Client B,T_BUDGET C,T_FabricType D,T_ORDERITEMS E,T_FabricConsumption F
	WHERE E.FABRICTYPEID=D.FABRICTYPEID AND
	    A.CLIENTID=B.CLIENTID(+) AND
		A.ORDERNO=E.ORDERNO and
		A.BUDGETID=C.BUDGETID AND
		A.BUDGETID=F.BUDGETID AND
		c.revision=65 and
		E.FABRICTYPEID=F.FABRICTYPEID(+) and
		(E.ORDERNO IN (SELECT ORDERNO FROM T_ORDERITEMS 
			WHERE TO_CHAR(ORDERNO) in (get_token(pOrderNo,1,'|'),get_token(pOrderNo,2,'|'),get_token(pOrderNo,3,'|'),
			get_token(pOrderNo,4,'|'),get_token(pOrderNo,5,'|'),get_token(pOrderNo,6,'|'),
			get_token(pOrderNo,7,'|'),get_token(pOrderNo,8,'|'),get_token(pOrderNo,9,'|'),
			get_token(pOrderNo,10,'|'),get_token(pOrderNo,11,'|'),get_token(pOrderNo,12,'|'),
			get_token(pOrderNo,13,'|'),get_token(pOrderNo,14,'|'),get_token(pOrderNo,15,'|'),
			get_token(pOrderNo,16,'|'),get_token(pOrderNo,17,'|'),get_token(pOrderNo,18,'|'),
			get_token(pOrderNo,19,'|'),get_token(pOrderNo,20,'|'),get_token(pOrderNo,21,'|'),
			get_token(pOrderNo,22,'|'),get_token(pOrderNo,23,'|'),get_token(pOrderNo,24,'|'),
			get_token(pOrderNo,25,'|'),get_token(pOrderNo,26,'|'),get_token(pOrderNo,27,'|'),
			get_token(pOrderNo,28,'|'),get_token(pOrderNo,29,'|'),get_token(pOrderNo,30,'|'),
			get_token(pOrderNo,31,'|'),get_token(pOrderNo,32,'|'),get_token(pOrderNo,33,'|'),
			get_token(pOrderNo,34,'|'),get_token(pOrderNo,35,'|'),get_token(pOrderNo,36,'|'),
			get_token(pOrderNo,37,'|'),get_token(pOrderNo,38,'|'),get_token(pOrderNo,39,'|'),	
			get_token(pOrderNo,40,'|'),get_token(pOrderNo,41,'|'),get_token(pOrderNo,42,'|'),
			get_token(pOrderNo,43,'|'),get_token(pOrderNo,44,'|'),get_token(pOrderNo,45,'|'),
			get_token(pOrderNo,46,'|'),get_token(pOrderNo,47,'|'),get_token(pOrderNo,48,'|'),
			get_token(pOrderNo,49,'|'),get_token(pOrderNo,50,'|'),get_token(pOrderNo,51,'|'),
			get_token(pOrderNo,52,'|'),get_token(pOrderNo,53,'|'),get_token(pOrderNo,54,'|'),
			get_token(pOrderNo,55,'|'),get_token(pOrderNo,56,'|'),get_token(pOrderNo,57,'|'),	
			get_token(pOrderNo,58,'|'),get_token(pOrderNo,59,'|'),get_token(pOrderNo,60,'|'),
			get_token(pOrderNo,61,'|'),get_token(pOrderNo,62,'|'),get_token(pOrderNo,63,'|'),
			get_token(pOrderNo,64,'|'),get_token(pOrderNo,65,'|'),get_token(pOrderNo,66,'|'),
			get_token(pOrderNo,67,'|'),get_token(pOrderNo,68,'|'),get_token(pOrderNo,69,'|'),
			get_token(pOrderNo,70,'|'),get_token(pOrderNo,71,'|'),get_token(pOrderNo,72,'|'),
			get_token(pOrderNo,73,'|'),get_token(pOrderNo,74,'|'),get_token(pOrderNo,75,'|'),	
			get_token(pOrderNo,76,'|'),get_token(pOrderNo,77,'|'),get_token(pOrderNo,78,'|'),
			get_token(pOrderNo,79,'|'),get_token(pOrderNo,80,'|'),get_token(pOrderNo,81,'|'),
			get_token(pOrderNo,82,'|'),get_token(pOrderNo,83,'|'),get_token(pOrderNo,84,'|'),
			get_token(pOrderNo,85,'|'),get_token(pOrderNo,86,'|'),get_token(pOrderNo,87,'|'),
			get_token(pOrderNo,88,'|'),get_token(pOrderNo,89,'|'),get_token(pOrderNo,90,'|'),
			get_token(pOrderNo,91,'|'),get_token(pOrderNo,92,'|'),get_token(pOrderNo,93,'|'),
			get_token(pOrderNo,94,'|'),get_token(pOrderNo,95,'|'),get_token(pOrderNo,96,'|'),
			get_token(pOrderNo,97,'|'),get_token(pOrderNo,98,'|'),get_token(pOrderNo,99,'|'),get_token(pOrderNo,100,'|')) and
			ORDERNO>0))
	GROUP BY F.BUDGETID,ORDERTYPEID,BUDGETNO,getfncWOBType(A.ORDERNO),E.ORDERNO,E.FABRICTYPEID,F.FABRICTYPEID,B.ClientName,D.FabricType
	ORDER BY getfncWOBType(A.ORDERNO); 
 end if; 
END GetBG04RPT;
/



PROMPT CREATE OR REPLACE Procedure  121:: GetRptGMPurReq
CREATE OR REPLACE Procedure GetRptGMPurReq (
  data_cursor IN OUT pReturnData.c_Records,
  pReqID IN NUMBER
)
As
Begin
  OPEN data_cursor FOR
  select a.REQNO,a.REQDATE ,g.DEPTNAME as AppFor, a.REQUIRMENTDATE,a.REMARKS,h.NAME as Reqby,
          c.PARTNAME,c.DESCRIPTION,c.FOREIGNPART,
          b.UNITPRICE,b.QTY,d.UNITOFMEAS,f.MCLISTNAME as issuefor,e.PROJNAME as dept,b.REMARKS as itemremarks
  from T_GMCPurchaseReq a,T_GMCPurchaseReqItems b,T_GMcPartsInfo c,T_unitofmeas d,
       t_project e,T_GMCLIST f,t_department g,T_purchaseReqBy h
  where a.REQID=b.REQID(+) and  
	b.PARTID=c.PARTID(+) and
	b.DeptID=e.PROJCODE(+) and
	b.ISSUEFOR=f.MCLISTID(+) and
	b.UNITOFMEASID=d.UNITOFMEASID(+) and
	a.Reqby=h.PID(+) and   
	a.DEPTID=g.DEPTID(+) and
	a.REQID=pReqID
	Order by b.PID;
End GetRptGMPurReq;
/



PROMPT CREATE OR REPLACE Procedure  122:: GetRptGMMRR
CREATE OR REPLACE Procedure GetRptGMMRR (
  data_cursor IN OUT pReturnData.c_Records, 
  pStockID IN NUMBER
)
As
Begin
  OPEN data_cursor FOR
	select a.ChallanNo as mrrno,a.STOCKDATE as mrrdate,a.DELIVERYNOTE as challanno, a.ChallanDate,a.PURCHASEORDERNO,
	a.PURCHASEORDERDATE,g.CURRENCYNAME,a.CONRATE,        
	y.SUPPLIERNAME,y.SADDRESS as SUPPLIERADDRESS,c.PARTNAME,c.DESCRIPTION,c.FOREIGNPART,b.QTY,b.UNITPRICE,      
	d.UNITOFMEAS,b.Remarks,e.PROJNAME as dept,f.MCLISTNAME as issuefor
	from T_GMcStock a,T_GMcStockItems b,T_GMcPartsInfo c,T_unitofmeas d,t_project e,T_GMCLIST f,
         T_Currency g,T_SUPPLIER y 
	where a.StockId=b.StockId(+) and
	    b.PARTID=c.PARTID(+) and
		a.SUPPLIERID=y.SUPPLIERID(+) and
		b.UNITOFMEASID=d.UNITOFMEASID(+) and
		b.DEPTID=e.PROJCODE(+) and
		b.ISSUEFOR=f.MCLISTID(+) and
		a.currencyid=g.currencyid(+) and
		a.StockId=pStockID
	order by b.STOCKITEMSL asc;
End GetRptGMMRR;
/


PROMPT CREATE OR REPLACE Procedure  123:: GetRptGMStock
CREATE OR REPLACE Procedure GetRptGMStock (
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType in number,
  pStockID IN NUMBER
)
As
Begin
if pQueryType=1 then
  OPEN data_cursor FOR
  /*MR Req*/
    select a.ChallanNo, a.ChallanDate,c.PARTNAME,c.DESCRIPTION,c.FOREIGNPART,b.QTY,      
	      d.UNITOFMEAS,b.Remarks,e.PROJNAME as dept,f.MCLISTNAME as issuefor
	from T_GMcStock a,T_GMcStockItems b,T_GMcPartsInfo c,T_unitofmeas d,t_project e,T_GMCLIST f  
	where a.StockId=b.StockId(+) and
	    b.PARTID=c.PARTID(+) and
		b.UNITOFMEASID=d.UNITOFMEASID(+) and
		b.DEPTID=e.PROJCODE(+) and
		b.ISSUEFOR=f.MCLISTID(+) and
		a.StockId=pStockID
	order by b.STOCKITEMSL asc;
elsif pQueryType=2 then
 /*MR*/
  OPEN data_cursor FOR
    select a.ChallanNo, a.ChallanDate,c.PARTNAME,c.DESCRIPTION,c.FOREIGNPART,b.QTY,      
	      d.UNITOFMEAS,b.Remarks,e.PROJNAME as dept,f.MCLISTNAME as issuefor
	from T_GMcStock a,T_GMcStockItems b,T_GMcPartsInfo c,T_unitofmeas d,t_project e,T_GMCLIST f  
	where a.StockId=b.StockId(+) and
	    b.PARTID=c.PARTID(+) and
		b.UNITOFMEASID=d.UNITOFMEASID(+) and
		b.DEPTID=e.PROJCODE(+) and
		b.ISSUEFOR=f.MCLISTID(+) and
		a.StockId=pStockID
	order by b.STOCKITEMSL asc;
elsif pQueryType=3 then
 /*MR Return*/
  OPEN data_cursor FOR
    select a.ChallanNo, a.ChallanDate,c.PARTNAME,c.DESCRIPTION,c.FOREIGNPART,b.QTY,      
	      d.UNITOFMEAS,b.Remarks,e.PROJNAME as dept,f.MCLISTNAME as issuefor
	from T_GMcStock a,T_GMcStockItems b,T_GMcPartsInfo c,T_unitofmeas d,t_project e,T_GMCLIST f  
	where a.StockId=b.StockId(+) and
	    b.PARTID=c.PARTID(+) and
		b.UNITOFMEASID=d.UNITOFMEASID(+) and
		b.DEPTID=e.PROJCODE(+) and
		b.ISSUEFOR=f.MCLISTID(+) and
		a.StockId=pStockID
	order by b.STOCKITEMSL asc;	
end if;
End GetRptGMStock;
/



PROMPT CREATE OR REPLACE Procedure  124:: T124GT
CREATE OR REPLACE Procedure T124GT(
  data_cursor IN OUT pReturnData.c_Records, 
  pQueryType IN NUMBER,      
  pORDERNO IN NUMBER  DEFAULT NULL, 
  pFabriTypeID IN VARCHAR2  DEFAULT NULL,  
  pSDate IN VARCHAR2  DEFAULT NULL, 
  pEDate IN VARCHAR2  DEFAULT NULL 
) 
AS 
  vSDate date;
  vEDate date; 
BEGIN 
  if not pSDate is null then
    vSDate := TO_DATE(pSDate, 'DD/MM/YYYY');
  end if;
  if not pEDate is null then
    vEDate := TO_DATE(pEDate, 'DD/MM/YYYY');
  end if; 

 if pQueryType=124 then
/* Report for T124 Summary Grand Total */
 OPEN data_cursor  FOR
 select 
    sum(decode(f.KNTITRANSACTIONTYPEID,6,b.Quantity,0)) GrayQty,
    sum(decode(f.KNTITRANSACTIONTYPEID,6,b.SQuantity,0)) GraySQty,
	 sum(decode(f.KNTITRANSACTIONTYPEID,24,b.Quantity,0)) DyedQty,
    sum(decode(f.KNTITRANSACTIONTYPEID,24,b.SQuantity,0)) DyedSQty,
	 sum(decode(f.KNTITRANSACTIONTYPEID,6,b.Quantity,24,b.Quantity,0)) TotalQty,
    sum(decode(f.KNTITRANSACTIONTYPEID,6,b.SQuantity,24,b.SQuantity,0)) TotalSQty    
	from T_Knitstock a, T_KnitStockItems b,T_YarnCount c, T_YarnType d, T_UnitOfMeas e,
    T_knitTransactionType f, T_Supplier g,T_FabricType h,T_Client i, t_workorder j,T_ShadeGroup l,T_KNITMACHINEINFO k
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=f.KNTITRANSACTIONTYPEID and
   (f.KNTITRANSACTIONTYPEID=6 or f.KNTITRANSACTIONTYPEID=24) and
    b.FabricTypeID=h.FabricTypeID and
    b.ShadeGroupID=l.ShadeGroupID and
    b.ORDERNO=j.ORDERNO and
    j.ClientID=i.ClientID and
    b.yarnCountId=c.yarncountid and
    b.yarntypeid=d.yarntypeID and
    b.PunitOfMeasId=e.UnitOfmeasId and
    b.SupplierId=g.SupplierId and
    b.MACHINEID=K.MACHINEID and
    (pORDERNO is NULL or b.ORDERNO=pORDERNO) and
    (pFabriTypeID is NULL or b.FabrictypeID=pFabriTypeID) and 
    a.STOCKTRANSDATE between decode(vSDate,null,'01-jan-2000',vSDate) and vEDate and		
    b.ORDERNO>0;
	elsif pQueryType=125 then
/* Report for T125 Summary Grand Total */
 OPEN data_cursor  FOR
 select 
    sum(decode(f.KNTITRANSACTIONTYPEID,6,b.Quantity,0)) GrayQty,
    sum(decode(f.KNTITRANSACTIONTYPEID,6,b.SQuantity,0)) GraySQty,
	 sum(decode(f.KNTITRANSACTIONTYPEID,24,b.Quantity,0)) DyedQty,
    sum(decode(f.KNTITRANSACTIONTYPEID,24,b.SQuantity,0)) DyedSQty,
	 sum(decode(f.KNTITRANSACTIONTYPEID,6,b.Quantity,24,b.Quantity,0)) TotalQty,
    sum(decode(f.KNTITRANSACTIONTYPEID,6,b.SQuantity,24,b.SQuantity,0)) TotalSQty    
	from T_Knitstock a, T_KnitStockItems b,T_YarnCount c, T_YarnType d, T_UnitOfMeas e,
    T_knitTransactionType f, T_Supplier g,T_FabricType h,T_Client i, t_workorder j,T_ShadeGroup l,T_KNITMACHINEINFO k
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=f.KNTITRANSACTIONTYPEID and
   (f.KNTITRANSACTIONTYPEID=6 or f.KNTITRANSACTIONTYPEID=24) and
    b.FabricTypeID=h.FabricTypeID and
    b.ShadeGroupID=l.ShadeGroupID and
    b.ORDERNO=j.ORDERNO and
    j.ClientID=i.ClientID and
    b.yarnCountId=c.yarncountid and
    b.yarntypeid=d.yarntypeID and
    b.PunitOfMeasId=e.UnitOfmeasId and
    b.SupplierId=g.SupplierId and
    b.MACHINEID=K.MACHINEID and
    (pORDERNO is NULL or b.ORDERNO=pORDERNO) and
    (pFabriTypeID is NULL or b.FabrictypeID=pFabriTypeID) and 
    a.STOCKTRANSDATE between decode(vSDate,null,'01-jan-2000',vSDate) and vEDate and		
    b.ORDERNO>0;
	elsif pQueryType=126 then
/* Report for T126 Summary Grand Total */
 OPEN data_cursor  FOR
 select 
    sum(decode(f.KNTITRANSACTIONTYPEID,6,b.Quantity,0)) GrayQty,
    sum(decode(f.KNTITRANSACTIONTYPEID,6,b.SQuantity,0)) GraySQty,
	 sum(decode(f.KNTITRANSACTIONTYPEID,24,b.Quantity,0)) DyedQty,
    sum(decode(f.KNTITRANSACTIONTYPEID,24,b.SQuantity,0)) DyedSQty,
	 sum(decode(f.KNTITRANSACTIONTYPEID,6,b.Quantity,24,b.Quantity,0)) TotalQty,
    sum(decode(f.KNTITRANSACTIONTYPEID,6,b.SQuantity,24,b.SQuantity,0)) TotalSQty    
	from T_Knitstock a, T_KnitStockItems b,T_YarnCount c, T_YarnType d, T_UnitOfMeas e,
    T_knitTransactionType f, T_Supplier g,T_FabricType h,T_Client i, t_workorder j,T_ShadeGroup l,T_KNITMACHINEINFO k
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=f.KNTITRANSACTIONTYPEID and
   (f.KNTITRANSACTIONTYPEID=6 or f.KNTITRANSACTIONTYPEID=24) and
    b.FabricTypeID=h.FabricTypeID and
    b.ShadeGroupID=l.ShadeGroupID and
    b.ORDERNO=j.ORDERNO and
    j.ClientID=i.ClientID and
    b.yarnCountId=c.yarncountid and
    b.yarntypeid=d.yarntypeID and
    b.PunitOfMeasId=e.UnitOfmeasId and
    b.SupplierId=g.SupplierId and
    b.MACHINEID=K.MACHINEID and
    (pORDERNO is NULL or b.ORDERNO=pORDERNO) and
    (pFabriTypeID is NULL or b.FabrictypeID=pFabriTypeID) and 
    a.STOCKTRANSDATE between decode(vSDate,null,'01-jan-2000',vSDate) and vEDate and		
    b.ORDERNO>0;
	end if;
END T124GT;
/



PROMPT CREATE OR REPLACE Procedure  125:: N001RetToHO
CREATE OR REPLACE Procedure N001RetToHO
(
  data_cursor IN OUT pReturnData.c_Records,  
  pKmcStockID number
)
AS
BEGIN
    OPEN data_cursor  FOR
    select a.StockId, a.StockDate, a.ChallanNo, a.ChallanDate,
	d.partsstatus, b.STOCKITEMSL,b.PARTID,b.UNITPRICE,b.REMARKS,
 	b.PARTSSTATUSFROMID,b.PARTSSTATUSTOID,b.QTY,b.MACHINEID,b.CURRENTSTOCK,
 	b.KMCTYPEID,c.PARTNAME,c.DESCRIPTION,c.FOREIGNPART
	from T_KmcPartsTran a,T_KMCPARTSTRANSDETAILS b,t_kmcpartsinfo c,t_kmcpartsstatus d
    where a.StockId=b.StockId and
	a.StockId=pKmcStockID and
	b.PARTID=c.PARTID and
    b.PARTSSTATUSFROMID=d.PARTSSTATUSID
    order by b.STOCKITEMSL asc;
END N001RetToHO;
/


PROMPT CREATE OR REPLACE Procedure  126:: T150DailyProduction
CREATE OR REPLACE Procedure T150DailyProduction(
  data_cursor IN OUT pReturnData.c_Records, 
  pQueryType IN NUMBER,      
  pOrderNo IN NUMBER  DEFAULT NULL, 
  pClient IN VARCHAR2  DEFAULT NULL,
  pSDate IN VARCHAR2  DEFAULT NULL, 
  pEDate IN VARCHAR2  DEFAULT NULL 
) 
AS 
  vSDate date;
  vEDate date;
 
BEGIN 
  if not pSDate is null then
    vSDate := TO_DATE(pSDate, 'DD/MM/YYYY');
  end if;
  if not pEDate is null then
    vEDate := TO_DATE(pEDate, 'DD/MM/YYYY');
  end if; 
  /*Report for T155*/
 if pQueryType=0 then
    OPEN data_cursor  FOR
       SELECT getfncWOBType(A.ORDERNO) AS WORDER,B.ClientName,D.FabricType,H.SHADEGROUPNAME,sum(G.QUANTITY) WoQty,	        
		    sum(decode(E.KNTITRANSACTIONTYPEID,6,F.Quantity,24,F.Quantity,0)) KnitQty,
			sum(decode(E.KNTITRANSACTIONTYPEID,19,F.Quantity,0)) DyeingQty,
			sum(decode(E.KNTITRANSACTIONTYPEID,20,F.Quantity,0)) FinishingQty						
	   FROM T_WorkOrder A,T_Client B,T_FabricType D,T_Knitstock E, T_KnitStockItems F,T_Orderitems G,T_SHADEGROUP H
	   WHERE E.KNTITRANSACTIONTYPEID IN (6,19,20,24) AND
	        (pOrderNo IS NULL OR F.ORDERNO=pOrderNo) AND 
			(pClient IS NULL OR A.CLIENTID=pClient) AND
	        A.CLIENTID=B.CLIENTID AND
			G.Orderno=A.Orderno and
			g.SHADEGROUPID=F.SHADEGROUPID and
			g.SHADEGROUPID=H.SHADEGROUPID and
			G.Fabrictypeid=F.Fabrictypeid and
			F.ORDERNO=A.ORDERNO AND
			e.STOCKID=f.STOCKID and
			F.FABRICTYPEID=D.FABRICTYPEID AND
			E.STOCKTRANSDATE BETWEEN DECODE(vSDate,null,'01-jan-2000',vSDate) AND vEDate
	   GROUP BY getfncWOBType(A.ORDERNO),F.ORDERNO,B.ClientName,D.FabricType,F.FABRICTYPEID,H.SHADEGROUPNAME
	   ORDER BY getfncWOBType(A.ORDERNO),B.ClientName,D.FabricType,H.SHADEGROUPNAME;
  elsif pQueryType=150 then
    OPEN data_cursor  FOR
       SELECT getfncWOBType(A.ORDERNO) AS WORDER,B.ClientName,D.FabricType,Sum(G.Quantity) AS WoQty,
	        E.STOCKTRANSDATE,
		    sum(decode(E.KNTITRANSACTIONTYPEID,6,F.Quantity,24,F.Quantity,0)) KnitQty,
			sum(decode(E.KNTITRANSACTIONTYPEID,19,F.Quantity,0)) DyeingQty,
			sum(decode(E.KNTITRANSACTIONTYPEID,20,F.Quantity,0)) FinishingQty,
			NVL((SELECT sum(decode(X.KNTITRANSACTIONTYPEID,6,Y.Quantity,24,Y.Quantity,0)) 
			 FROM T_Knitstock X, T_KnitStockItems Y
			 WHERE X.KNTITRANSACTIONTYPEID IN (6,24) AND
			 Y.ORDERNO=F.ORDERNO AND
			 X.STOCKID=Y.STOCKID and
			 Y.FABRICTYPEID=F.FABRICTYPEID AND
			 X.STOCKTRANSDATE <=E.STOCKTRANSDATE),0) AS CumKQty,
			NVL((SELECT sum(decode(M.KNTITRANSACTIONTYPEID,19,N.Quantity,0)) 
			 FROM T_Knitstock M, T_KnitStockItems N
			 WHERE M.KNTITRANSACTIONTYPEID IN (19) AND
			 N.ORDERNO=F.ORDERNO AND
			 M.STOCKID=N.STOCKID and
			 N.FABRICTYPEID=F.FABRICTYPEID AND
			 M.STOCKTRANSDATE <=E.STOCKTRANSDATE),0) AS CumDQty,
			NVL((SELECT sum(decode(XX.KNTITRANSACTIONTYPEID,20,YY.Quantity,0)) 
			 FROM T_Knitstock XX, T_KnitStockItems YY
			 WHERE XX.KNTITRANSACTIONTYPEID IN (20) AND
			 YY.ORDERNO=F.ORDERNO AND
			 XX.STOCKID=YY.STOCKID and
			 YY.FABRICTYPEID=F.FABRICTYPEID AND
			 XX.STOCKTRANSDATE <=E.STOCKTRANSDATE),0) AS CumFQty
	   FROM T_WorkOrder A,T_Client B,T_FabricType D,T_Knitstock E, T_KnitStockItems F,T_Orderitems G
	   WHERE E.KNTITRANSACTIONTYPEID IN (6,19,20,24) AND
	        (pOrderNo IS NULL OR F.ORDERNO=pOrderNo) AND 
			(pClient IS NULL OR A.CLIENTID=pClient) AND
	        A.CLIENTID=B.CLIENTID AND
			G.OrderNo=A.OrderNo and
			G.Fabrictypeid=F.Fabrictypeid and
			F.ORDERNO=A.ORDERNO AND
			e.STOCKID=f.STOCKID and
			F.FABRICTYPEID=D.FABRICTYPEID AND
			E.STOCKTRANSDATE BETWEEN DECODE(vSDate,null,'01-jan-2000',vSDate) AND vEDate
	   GROUP BY getfncWOBType(A.ORDERNO),F.ORDERNO,G.OrderNo,B.ClientName,D.FabricType,F.FABRICTYPEID,G.FABRICTYPEID,E.STOCKTRANSDATE
	   ORDER BY getfncWOBType(A.ORDERNO),B.ClientName,E.STOCKTRANSDATE;
 end if;
END T150DailyProduction;
/  


PROMPT CREATE OR REPLACE Procedure  127:: T156KPSummary
CREATE OR REPLACE Procedure T156KPSummary (
   data_cursor IN OUT pReturnData.c_Records,
   pQueryType IN NUMBER,
   sDate IN VARCHAR2,
   eDate IN VARCHAR2
)
AS
  vSDate date;
  vEDate date;
BEGIN

  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  end if;
if pQueryType=0 then
/* Report for T151 Machine Wise Knitting Production Summary*/
  OPEN data_cursor  FOR
   select K.MACHINENAME,decode(k.FABRICTYPEID,999,'Circular','Flat') as mtype,
    sum(decode(f.KNTITRANSACTIONTYPEID,6,b.Quantity,24,b.Quantity,0)) ProductQty,
    sum(decode(f.KNTITRANSACTIONTYPEID,6,b.SQuantity,24,b.SQuantity,0)) ProductSQty
    from T_Knitstock a, T_KnitStockItems b, T_UnitOfMeas e,T_knitTransactionType f,T_FabricType h,
	T_Client i, t_workorder j,T_KNITMACHINEINFO k
    where a.StockID=b.StockID and 
    a.KNTITRANSACTIONTYPEID=f.KNTITRANSACTIONTYPEID and
    f.KNTITRANSACTIONTYPEID IN (6,24) and                                             
    b.FabricTypeID=h.FabricTypeID(+) and
    b.ORDERNO=j.ORDERNO and
    j.ClientID=i.ClientID and 
	b.PunitOfMeasId=e.UnitOfmeasId(+) and
    b.MACHINEID=K.MACHINEID and
    a.StockTransDATE between decode(vSDate,null,'01-jan-2000',vSDate) and vEDate AND b.ORDERNO>0
    group by K.MACHINENAME,k.FABRICTYPEID
	ORDER BY K.MACHINENAME ASC;
elsif pQueryType=1 then
/* Report for T151 date Knitting Production Summary*/
  OPEN data_cursor  FOR
   select a.StockTransDATE,
    sum(decode(f.KNTITRANSACTIONTYPEID,6,b.Quantity,24,b.Quantity,0)) ProductQty,
    sum(decode(f.KNTITRANSACTIONTYPEID,6,b.SQuantity,24,b.SQuantity,0)) ProductSQty
    from T_Knitstock a, T_KnitStockItems b, T_UnitOfMeas e,T_knitTransactionType f,T_FabricType h,
	T_Client i, t_workorder j,T_KNITMACHINEINFO k
    where a.StockID=b.StockID and 
    a.KNTITRANSACTIONTYPEID=f.KNTITRANSACTIONTYPEID and
    f.KNTITRANSACTIONTYPEID IN (6,24) and                                             
    b.FabricTypeID=h.FabricTypeID(+) and
    b.ORDERNO=j.ORDERNO and
    j.ClientID=i.ClientID and 
	b.PunitOfMeasId=e.UnitOfmeasId(+) and
    b.MACHINEID=K.MACHINEID and
    a.StockTransDATE between decode(vSDate,null,'01-jan-2000',vSDate) and vEDate AND b.ORDERNO>0
    group by a.StockTransDATE
	ORDER BY a.StockTransDATE ASC;
   end if;
End T156KPSummary;
/



PROMPT CREATE OR REPLACE Procedure  128:: G004Summary
CREATE OR REPLACE Procedure G004Summary(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  PeDate IN VARCHAR2
) 
AS 
  vEDate date;  
BEGIN 
  if not PEDate is null then
    vEDate := TO_DATE(PeDate, 'DD/MM/YYYY');
  else
    vEDate := TO_DATE('01/01/2100', 'DD/MM/YYYY');
  end if;
/* For Report G004 Spare Parts Stock Summary*/
if pQueryType=1 then
 OPEN data_cursor  FOR
    select b.PARTID,c.PARTNAME,a.PARTSSTATUS,c.FOREIGNPART,c.MACHINETYPE,c.DESCRIPTION,0 as UNITPRICE,
        b.PARTSSTATUSTOID AS PARTSSTATUSFROMID,e.UNITOFMEAS,c.Binno,SUM(b.QTY * d.MSN) as Total
       from T_GMCPARTSSTATUS a,T_GMcStockItems b,T_GMCPARTSINFO c,T_GMCSTOCKSTATUS d,t_UnitOfMeas e
	   where  b.PARTID=c.PARTID and
        b.PARTSSTATUSTOID=a.PARTSSTATUSID and
        B.TEXMCSTOCKTYPEID=d.TEXMCSTOCKTYPEID and b.PARTSSTATUSFROMID=d.PARTSSTATUSFROMID and
        b.PARTSSTATUSTOID=d.PARTSSTATUSTOID and c.UNITOFMEASID=e.UNITOFMEASID
       group by  c.MACHINETYPE,b.PARTID,c.PARTNAME,a.PARTSSTATUS,c.FOREIGNPART,c.DESCRIPTION,
        b.PARTSSTATUSTOID,e.UNITOFMEAS,c.Binno
       having sum(b.Qty*d.MSN)>0
  order by MachineType;
end if;
END G004Summary; 
/



PROMPT CREATE OR REPLACE Procedure  129:: TB02PaymentSummary
CREATE OR REPLACE Procedure TB02PaymentSummary(
  data_cursor IN OUT pReturnData.c_Records,
  pOrdercode IN VARCHAR2,
  pBillno in number,
  pClientId in varchar2,  
  pSDate IN VARCHAR2, 
  pEDate IN VARCHAR2 
) 
AS 
  vSDate date;
  vEDate date; 
BEGIN 
  if not pSDate is null then
    vSDate := TO_DATE(pSDate, 'DD/MM/YYYY');
  else
    vSDate := TO_DATE('01-JAN-2000', 'DD/MM/YYYY');
  end if;
  if not pEDate is null then
    vEDate := TO_DATE(pEDate, 'DD/MM/YYYY');
  else
    vEDate := TO_DATE('01-JAN-2050', 'DD/MM/YYYY');
  end if;
OPEN data_cursor  FOR             /*USED FOR SB02*/
    select A.BILLNO,A.ORDERCODE,A.BILLDATE,B.BILLPMTDATE,getfncWOBType(c.ORDERNO) AS WORDER,
	nvl(sum(decode( c.BILLITEMSQTY,0,(c.SQTY*c.BILLITEMSUNITPRICE*A.CONRATE),(c.BILLITEMSQTY*c.BILLITEMSUNITPRICE*A.CONRATE))),0) as billitemsamt,     
    NVL(sum(B.BILLWOPMT),0) AS BILLWOPMT,D.CLIENTNAME,A.CONRATE,E.CURRENCYNAME
    from T_Bill A,T_BILLPAYMENT B,T_BillItems c,T_CLIENT D,T_CURRENCY E 
	where A.BILLNO=B.BILLNO AND	    
        A.ORDERCODE=B.ORDERCODE AND	
		A.BILLNO=c.BILLNO AND	
		B.ORDERNO=c.ORDERNO AND    
        A.ORDERCODE=c.ORDERCODE AND	
		A.CLIENTID=D.CLIENTID(+) AND
		A.CURRENCYID=E.CURRENCYID(+) AND
        (pOrdercode IS NULL OR A.ORDERCODE=pOrdercode) AND	
		(pBillno IS NULL OR A.BILLNO=pBillno) AND	
        (pClientId is null or A.CLIENTID=pClientId) and		
		B.BILLPMTDATE BETWEEN vSDate and vEDate 
	group by A.ORDERCODE,A.BILLNO,A.BILLDATE,D.CLIENTNAME,c.ORDERNO,A.CONRATE,E.CURRENCYNAME,B.BILLPMTDATE
	order by A.ORDERCODE,A.BILLNO,D.CLIENTNAME,getfncWOBType(c.ORDERNO),B.BILLPMTDATE;
END TB02PaymentSummary; 
/



PROMPT CREATE OR REPLACE Procedure  130:: GetReportPurchaseReq
CREATE OR REPLACE Procedure GetReportPurchaseReq
(
  one_cursor IN OUT pReturnData.c_Records,
  pREQID number
)
AS
  vSDate date;
  vEDate date;
BEGIN
    open one_cursor for
    select PID,REQTYPEID,a.REQID,B.REQDATE,a.ITEMID,a.QUANTITY,a.PUNITOFMEASID,a.SQUANTITY,a.SUNITOFMEASID,a.REMARKS,
	a.CURRENTSTOCK,a.UNITPRICE,a.GROUPID,a.SLNO,a.BRANDID,a.COUNTRYID,b.REQNO,b.DEPTID,d.DEPTNAME ,e.countryname,
	f.brandname,g.groupname ,h.ITEM,C.unitofmeas ,b.REQUIRMENTDATE,b.remarks as mainremarks,
	(select max(STOCKTRANSDATE) from T_Stationerystock a,T_StationeryStockItems b
	where  a.stockid=b.stockid and b.STATIONERYID=ITEMID and b.transtypeid=1 and b.reqby=reqby and a.STOCKTRANSDATE<reqdate group by itemid) as lastpdate,
	LastPuchaseqty(a.ITEMID,b.reqby,B.REQDATE) as lastqty,
	Itemcurstock(a.ITEMID,b.reqby,B.REQDATE) as stqty
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
	a.groupid=g.groupid and
	a.countryid=e.countryid(+) and
	a.itemid=h.stationeryid(+) and
	(pREQID is null or a.Reqid=pREQID)
    order by a.PID asc;
END GetReportPurchaseReq;
/



PROMPT CREATE OR REPLACE Procedure  131:: GetReportMoneyRec
CREATE OR REPLACE Procedure GetReportMoneyRec  (
  data_cursor IN OUT pReturnData.c_Records,
  pPID IN NUMBER,
  pInwords in varchar2
)
As
Begin
  OPEN data_cursor FOR
  select a.PID,a.RECEIPTNO,a.RECEIPTDATE,b.RECEIPENTNAME,c.PARTYNAME,a.AMOUNT,a.CASH,a.CHEQUE,a.PAYORDER,       
a.DRAFT,a.PAYMENTNO,a.PAYDATE,a.BILLNO,a.PURPOSE,d.EMPLOYEENAME,a.BRANCH,e.BANKNAME,b.description      
  from T_moneyreceipt a,T_receipent b,T_party c,T_employee d,T_LcBank e
  where a.PID=pPID and
         a.RECEIPTFOR=b.RID(+) and
         a.PARTYID=c.PARTYID(+) and 
		 a.bankid=e.bankid(+) and 
		 a.EMPLOYEEID=d.EMPLOYEEID(+);
End GetReportMoneyRec;
/



PROMPT CREATE OR REPLACE Procedure  132:: MoneyReceiptStatement
CREATE OR REPLACE Procedure MoneyReceiptStatement
(
  one_cursor IN OUT pReturnData.c_Records,  
  sDate IN VARCHAR2,
  eDate IN VARCHAR2,
  pcompanyid Number
)
AS
vSDate date;
vEDate date;

BEGIN
    if not sDate is null then
		vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
	end if;
	if not eDate is null then
		vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
	end if;	
open one_cursor for
    select 	RECEIPTNO,RECEIPTDATE,RECEIPTFOR,AMOUNT,CASH,CHEQUE,PAYORDER,DRAFT,PAYMENTNO,PAYDATE,
	BRANCH,BILLNO,PURPOSE as PURPOSE,b.partyname as name,c. receipentname,c.DESCRIPTION as DESCRIPTION
    from  
		T_MoneyReceipt a,
		T_party b,
		T_receipent c
    where
		a.partyid=b.PARTYID and
		a.RECEIPTFOR=c.rid and
		(pcompanyid is NULL or a.RECEIPTFOR=pcompanyid) and
   (sDate is NULL or a.RECEIPTDATE>=vSDate) and
   (eDate is NULL or a.RECEIPTDATE<=vEDate)
   union
    select 	RECEIPTNO,RECEIPTDATE,RECEIPTFOR,AMOUNT,CASH,CHEQUE,PAYORDER,DRAFT,PAYMENTNO,PAYDATE,
	BRANCH,BILLNO,decode(ELECTRIC,1,'Electric Bill'||' '||'('||d.bmonth||','||d.byear||')','Maintenance Bill'||' '||'('||d.bmonth||','||d.byear||')') as PURPOSE,b.name as name,c. receipentname,c.DESCRIPTION as DESCRIPTION
    from  
		T_MoneyReceipt a,
		t_alliedcustomer b,
		T_receipent c,
		t_electricitybill d
    where
		a.customerid=d.pid and
		d.customerid=b.customerid and
		a.RECEIPTFOR=c.rid and
		(pcompanyid is NULL or a.RECEIPTFOR=pcompanyid) and
   (sDate is NULL or a.RECEIPTDATE>=vSDate) and
   (eDate is NULL or a.RECEIPTDATE<=vEDate)
   
    order by RECEIPTNO asc;
	
END MoneyReceiptStatement;
/

PROMPT CREATE OR REPLACE Procedure  133:: GetReportGMRR
CREATE OR REPLACE Procedure GetReportGMRR
(
  one_cursor IN OUT pReturnData.c_Records,
  pGStockID number
)
AS
BEGIN
    open one_cursor for
    select 	ChallanNo, ChallanDate, StockTransNO, StockTransDATE,
		getfncDispalyorder(b.ORDERNO) as dorder,
    		a.ClientID,a.SubConId,Pono,GatepassNo,
    		b.ORDERNO,b.STOCKID,GSTOCKITEMSL,b.FabricTypeId,Quantity,
   		Squantity,b.PunitOfmeasId,b.SUNITOFMEASID,SIZEID,
    		BatchNo,Shade,b.REMARKS,FabricDia,FabricGSM,Styleno,
    		c.clientname,f.fabrictype,d.unitofmeas as punit,e.unitofmeas as sunit,
		f.fabrictype
    from  
		T_GSTOCK a,
		T_GStockItems b,
		t_client c,
		t_unitofmeas d,
		t_unitofmeas e,
		t_fabrictype f
    where
		a.stockid=b.stockid and
		b.GTRANSTYPEID=1 and
		a.clientid=c.clientid and
		a.STOCKID=pGStockID and
		b.punitofmeasid=d.unitofmeasid(+) and
		b.sunitofmeasid=e.unitofmeasid(+) and
		b.fabrictypeid=f.fabrictypeid
    order 
		by GSTOCKITEMSL asc;
END GetReportGMRR;
/

PROMPT CREATE OR REPLACE Procedure  134:: GetReportGFabRequisition
Create or Replace Procedure GetReportGFabRequisition
(
  one_cursor IN OUT pReturnData.c_Records , 
  pStockID number
)
AS
BEGIN

    open one_cursor for
    select StockTransNO,STOCKTRANSDATE,GSTOCKITEMSL,   
    getfncDispalyorder(b.ORDERNO) as dorder,b.FabricTypeId,Quantity,
    Squantity,b.PunitOfmeasId,b.SUNITOFMEASID,SIZEID,
    BatchNo,Shade,b.REMARKS,FabricDia,FabricGSM,Styleno,
    c.subconname,f.fabrictype,d.unitofmeas as punit,e.unitofmeas as sunit,f.fabrictype
    from  T_GFabricReq a,T_GFabricReqItems b,t_Subcontractors c,t_unitofmeas d,t_unitofmeas e,t_fabrictype f
    where
a.stockid=b.stockid and
a.subconid=c.subconid and
a.STOCKID=pStockID and
b.punitofmeasid=d.unitofmeasid(+) and
b.sunitofmeasid=e.unitofmeasid(+) and
b.fabrictypeid=f.fabrictypeid    
    order by GSTOCKITEMSL asc;
END GetReportGFabRequisition;
/


PROMPT CREATE OR REPLACE Procedure  135:: GetReportGMR
CREATE OR REPLACE Procedure GetReportGMR
(
  one_cursor IN OUT pReturnData.c_Records,
  pGStockID number
)
AS
BEGIN
    open one_cursor for
    select ChallanNo, ChallanDate, StockTransNO, StockTransDATE,getfncDispalyorder(b.ORDERNO) as dorder,
    a.ClientID,a.SubConId,Pono,GatepassNo,
    b.ORDERNO,b.STOCKID,GSTOCKITEMSL,b.FabricTypeId,Quantity,
    Squantity,b.PunitOfmeasId,b.SUNITOFMEASID,SIZEID,
    BatchNo,Shade,b.REMARKS,FabricDia,FabricGSM,Styleno,
    c.clientname,f.fabrictype,d.unitofmeas as punit,e.unitofmeas as sunit,f.fabrictype
    from  T_GSTOCK a,T_GStockItems b,t_client c,t_unitofmeas d,t_unitofmeas e,t_fabrictype f
    where
a.stockid=b.stockid and
b.GTRANSTYPEID=1 and
a.clientid=c.clientid and
a.STOCKID=pGStockID and
b.punitofmeasid=d.unitofmeasid(+) and
b.sunitofmeasid=e.unitofmeasid(+) and
b.fabrictypeid=f.fabrictypeid
    order by GSTOCKITEMSL asc;
END GetReportGMR;
/


PROMPT CREATE OR REPLACE Procedure  136:: GetReportGIssutoCF
CREATE OR REPLACE Procedure GetReportGIssutoCF
(
  one_cursor IN OUT pReturnData.c_Records,
  pGStockID number
)
AS
BEGIN
    open one_cursor for
    select 	ChallanNo, ChallanDate, StockTransNO, StockTransDATE,
		getfncDispalyorder(b.ORDERNO) as dorder,
    		a.SubConId,Pono,GatepassNo,
    		b.ORDERNO,b.STOCKID,GSTOCKITEMSL,b.FabricTypeId,Quantity,
   		Squantity,b.PunitOfmeasId,b.SUNITOFMEASID,SIZEID,
    		BatchNo,Shade,b.REMARKS,FabricDia,FabricGSM,Styleno,
    		f.fabrictype,d.unitofmeas as punit,e.unitofmeas as sunit,
		f.fabrictype
    from  
		T_GSTOCK a,
		T_GStockItems b,		
		t_unitofmeas d,
		t_unitofmeas e,
		t_fabrictype f
    where
		a.stockid=b.stockid and
		b.GTRANSTYPEID=2 and		
		a.STOCKID=pGStockID and
		b.punitofmeasid=d.unitofmeasid(+) and
		b.sunitofmeasid=e.unitofmeasid(+) and
		b.fabrictypeid=f.fabrictypeid
    order 
		by GSTOCKITEMSL asc;
END GetReportGIssutoCF;
/


PROMPT CREATE OR REPLACE Procedure  137:: GetReportFREturnFCF
CREATE OR REPLACE Procedure GetReportFREturnFCF
(
  one_cursor IN OUT pReturnData.c_Records,
  pGStockID number
)
AS
BEGIN
    open one_cursor for
    select 	ChallanNo, ChallanDate, StockTransNO, StockTransDATE,
		getfncDispalyorder(b.ORDERNO) as dorder,
    		a.SubConId,Pono,GatepassNo,
    		b.ORDERNO,b.STOCKID,GSTOCKITEMSL,b.FabricTypeId,Quantity,
   		Squantity,b.PunitOfmeasId,b.SUNITOFMEASID,SIZEID,
    		BatchNo,Shade,b.REMARKS,FabricDia,FabricGSM,Styleno,
    		f.fabrictype,d.unitofmeas as punit,e.unitofmeas as sunit,
		f.fabrictype
    from  
		T_GSTOCK a,
		T_GStockItems b,		
		t_unitofmeas d,
		t_unitofmeas e,
		t_fabrictype f
    where
		a.stockid=b.stockid and
		b.GTRANSTYPEID=21 and		
		a.STOCKID=pGStockID and
		b.punitofmeasid=d.unitofmeasid(+) and
		b.sunitofmeasid=e.unitofmeasid(+) and
		b.fabrictypeid=f.fabrictypeid
    order 
		by GSTOCKITEMSL asc;
END GetReportFREturnFCF;
/


PROMPT CREATE OR REPLACE Procedure  138:: GetReportDailyCutting
CREATE OR REPLACE PROCEDURE GetReportDailyCutting(
  data_cursor IN OUT pReturnData.c_Records,
  pOrderNo in Number,
  sDate IN VARCHAR2,
  eDate IN VARCHAR2  
)
AS
  vSDate date;
  vEDate date;
BEGIN

  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  end if;
/*Daily cutting status*/ 	  
OPEN data_cursor  FOR
	Select B.SHADE,getfncDispalyorder(b.ORDERNO) as btype,b.PUNITOFMEASID as Unitofmeasid,b.SIZEID,'' AS ORDERLINEITEM,a.STOCKTRANSDATE as CUTTINGDATE,B.styleno,
		'' AS PONO,d.clientname,e.sizename,f.unitofmeas,g.countryname,b.ORDERNO,Sum(b.QUANTITY) as qty	
	From T_GSTOCK a,
		T_GStockItems b,
		T_client d,
		T_size e,
		T_unitofmeas f,
		T_country g
	where a.STOCKID=b.STOCKID and
		(pOrderNo is null or B.orderno=pOrderNo) and
		a.clientid=d.clientid(+) and
		b.sizeid=e.sizeid(+) and
		b.GTRANSTYPEID=3 and
		B.countryid=g.countryid(+) and
		b.Punitofmeasid=f.unitofmeasid(+) and
		a.STOCKTRANSDATE between decode(vSDate,null,'01-jan-2000',vSDate) and vEDate
	Group by  B.SHADE,b.PUNITOFMEASID,b.SIZEID,a.STOCKTRANSDATE,B.styleNO,
		d.clientname,e.sizename,f.unitofmeas,g.countryname,b.ORDERNO
	order by B.orderno,styleno;
END GetReportDailyCutting;
/


PROMPT CREATE OR REPLACE Procedure  139:: GetReportProduction
CREATE OR REPLACE PROCEDURE GetReportProduction(
  data_cursor IN OUT pReturnData.c_Records,
  pOrderno in number,
  sDate IN VARCHAR2,
  eDate IN VARCHAR2  
)
AS
  vSDate date;
  vEDate date;
BEGIN

  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  end if;
/*Daily sewing production hourly*/ 	
OPEN data_cursor  FOR
	Select B.SHADE,getfncDispalyorder(b.ORDERNO) as btype,b.PUNITOFMEASID as Unitofmeasid,b.SIZEID,B.styleno,
		e.sizename,f.unitofmeas,g.countryname,b.ORDERNO,A.PRODHOUR,b.lineno,d.description,b.QUANTITY as qty
	from  T_GSTOCK a,
		T_GStockItems b,
		t_productionHOur d,		
		t_size e,
		t_unitofmeas f,
		t_country g
	where a.STOCKID=b.STOCKID and
		b.sizeid=e.sizeid(+) and
		(pOrderno is null or b.ORDERNO=pOrderno) and
		B.countryid=g.countryid(+) and
		b.Punitofmeasid=f.unitofmeasid(+) and
		b.GTRANSTYPEID=7 and
		a.prodhour=d.hid(+) and
		a.STOCKTRANSDATE between decode(vSDate,null,'01-jan-2000',vSDate) and vEDate	
	order by b.ORDERNO,B.styleno;
END GetReportProduction;
/


PROMPT CREATE OR REPLACE Procedure  140:: GetReportDailyProduction
CREATE OR REPLACE PROCEDURE GetReportDailyProduction(
  data_cursor IN OUT pReturnData.c_Records,
  sDate IN VARCHAR2,
  eDate IN VARCHAR2  
)
AS
  vSDate date;
  vEDate date;
BEGIN

  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  end if;
 	
OPEN data_cursor  FOR
		Select B.SHADE,getfncDispalyorder(C.GORDERNO) as btype,b.PUNITOFMEASID as Unitofmeasid,B.styleno,
		f.unitofmeas,g.countryname,C.GORDERNO,A.PRODHOUR,b.lineno,d.description,sum(b.QUANTITY*SGS) as qty
	from 
		T_GSTOCK a,
		T_GStockItems b,
		t_Gworkorder c,	
		t_productionHOur d,
		t_unitofmeas f,
		t_country g,
		t_gtransactiontype i
	where 
		a.STOCKID=b.STOCKID and
		b.GTRANSTYPEID=i.GTRANSACTIONTYPEID and
		B.orderno=c.gorderno and
		B.countryid=g.countryid and
		b.Punitofmeasid=f.unitofmeasid and
		a.prodhour=d.hid and
		b.GTRANSTYPEID=7 and
		a.STOCKTRANSDATE between decode(vSDate,null,'01-jan-2000',vSDate) and vEDate
	Group by 
		B.SHADE,b.PUNITOFMEASID,B.styleno,
		f.unitofmeas,g.countryname,C.GORDERNO,A.PRODHOUR,b.lineno,d.description
	
	order by 
		B.styleno;
END GetReportDailyProduction;
/



PROMPT CREATE OR REPLACE Procedure  141:: GMainStockAll
CREATE OR REPLACE Procedure GMainStockAll
(
    one_cursor IN OUT pReturnData.c_Records,
	pQueryType in Number,
  	pOrderno in number,
	sDate IN VARCHAR2,
  	eDate IN VARCHAR2
)
AS
  	vSDate date;
  	vEDate date;
BEGIN
  	if not sDate is null then
    		vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  	end if;
  	if not eDate is null then
    		vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  	end if; 
/*RMG Fabric Received Summary (Orderwise)*/	
if(pQueryType=1) then
    open one_cursor for
    select 	GORDERQTY(b.FabricTypeId,Trim(INITCAP(b.Shade)),b.ORDERNO) as orderedqty,
		getfncDispalyorder(b.ORDERNO) as dorder,
    	a.ClientID,0 as SubConId,b.ORDERNO,b.FabricTypeId,
   		b.PunitOfmeasId,'' as SUNITOFMEASID,
    	Trim(INITCAP(b.Shade)) as Shade,FabricDia,FabricGSM,Styleno,
    	c.clientname,f.fabrictype,d.unitofmeas as punit,''  as sunit,
		Sum(Quantity) as Quantity, Sum(Squantity) as Squantity
    from T_GSTOCK a,
		T_GStockItems b,
		t_client c,
		t_unitofmeas d,		
		t_fabrictype f
    where
		a.stockid=b.stockid and		
		a.clientid=c.clientid and		
		b.punitofmeasid=d.unitofmeasid(+) and		
		b.fabrictypeid=f.fabrictypeid  and
		(pOrderno is null or b.orderno=pOrderno) and 
		b.gtranstypeid=1 and
		a.STOCKTRANSDATE between decode(vSDate,null,'01-jan-2000',vSDate) and vEDate 
	Group by a.ClientID,b.ORDERNO,b.FabricTypeId,
   		b.PunitOfmeasId,Trim(INITCAP(b.Shade)),FabricDia,FabricGSM,Styleno,
    	c.clientname,f.fabrictype,d.unitofmeas;
/* For Fabric Stock Summary*/
elsif(pQueryType=2) then
    open one_cursor for    
    select 	getfncDispalyorder(b.ORDERNO) as dorder,    		
    	b.ORDERNO,b.FabricTypeId, BatchNo,Trim(INITCAP(b.Shade)) as Shade,FabricDia,FabricGSM,Styleno,
    	f.fabrictype,'' as punit,
		Nvl(sum(Quantity*GMS),0) as mqty,
 		nvl(sum(squantity*GMS),0) as msqty,
		nvl(sum(Quantity*GFCF),0) as cfqty,
 		nvl(sum(sQuantity*GFCF),0) as cfsqty,
		0 as rqty,0 as rsqty,
		Sum(Quantity) as Quantity, Sum(Squantity) as Squantity,
        sum(decode(b.GTRANSTYPEID,1,Quantity,0)) as totalrecv		
    from T_GSTOCK a,
		T_GStockItems b,
		t_fabrictype f,
		T_GTransactionType g
    where a.stockid=b.stockid and		
		b.fabrictypeid=f.fabrictypeid  and
		b.GTRANSTYPEID=g.GTRANSACTIONTYPEID  and 
		(pOrderno is null or b.orderno=pOrderno) and
	    a.STOCKTRANSDATE<=vEDate and b.GTRANSTYPEID in(1,2,21,27)
	Group by b.ORDERNO,b.FabricTypeId,Batchno,Trim(INITCAP(b.Shade)),FabricDia,FabricGSM,Styleno,f.fabrictype
	ORDER BY Trim(INITCAP(b.Shade));	
/* For Orderwise Fabric Received Date AND Orderwise */	
elsif(pQueryType=3) then
    open one_cursor for
    select ChallanNo, ChallanDate, StockTransNO, StockTransDATE,GORDERQTY(b.FabricTypeId,Trim(INITCAP(b.Shade)),b.ORDERNO) as orderedqty,
		getfncDispalyorder(b.ORDERNO) as dorder,a.ClientID,a.SubConId,b.ORDERNO,b.FabricTypeId,
   		b.PunitOfmeasId,b.SUNITOFMEASID,BatchNo,Trim(INITCAP(b.Shade)),FabricDia,FabricGSM,Styleno,
    	c.clientname,f.fabrictype,d.unitofmeas as punit,e.unitofmeas as sunit,
		f.fabrictype,Sum(Quantity) as Quantity, Sum(Squantity) as Squantity
    from  
		T_GSTOCK a,
		T_GStockItems b,
		t_client c,
		t_unitofmeas d,
		t_unitofmeas e,
		t_fabrictype f
    where
		a.stockid=b.stockid and		
		a.clientid=c.clientid and		
		b.punitofmeasid=d.unitofmeasid(+) and
		b.sunitofmeasid=e.unitofmeasid(+) and
		b.fabrictypeid=f.fabrictypeid  and
		(pOrderno is null or b.orderno=pOrderno) and
		a.STOCKTRANSDATE between decode(vSDate,null,'01-jan-2000',vSDate) and vEDate 
	Group by ChallanNo, ChallanDate, StockTransNO, StockTransDATE,		
    	a.ClientID,a.SubConId,b.ORDERNO,b.FabricTypeId,
   		b.PunitOfmeasId,b.SUNITOFMEASID,
    	BatchNo,Trim(INITCAP(b.Shade)),FabricDia,FabricGSM,Styleno,
    	c.clientname,f.fabrictype,d.unitofmeas,e.unitofmeas,
		f.fabrictype;  
/*RMG fabric received summary order and date wise*/		
elsif(pQueryType=4) then
    open one_cursor for
    select 	GORDERQTY(b.FabricTypeId,Shade,b.ORDERNO) as orderedqty,StockTransNO, StockTransDATE,
		getfncDispalyorder(b.ORDERNO) as dorder,a.ClientID,0 as SubConId,b.ORDERNO,b.FabricTypeId,
   		b.PunitOfmeasId,SUNITOFMEASID,Shade,FabricDia,FabricGSM,Styleno,
    	c.clientname,f.fabrictype,d.unitofmeas as punit,e.unitofmeas as sunit,
		f.fabrictype,Sum(Quantity) as Quantity, Sum(Squantity) as Squantity,
		
		(select Nvl(sum(quantity),0) from t_gstock x, t_gstockitems y 
		where x.stockid=y.stockid and y.orderno=b.orderno and 
		y.shade=b.shade and y.styleno=b.styleno
		and y.fabrictypeid=b.fabrictypeid and y.fabricdia=b.fabricdia and 
		y.fabricgsm=b.fabricgsm and gtranstypeid=1 and
		x.STOCKTRANSDATE<a.STOCKTRANSDATE
		group by b.ORDERNO,FabricTypeId,Shade,FabricDia,FabricGSM,Styleno) as totalrecv
		
    from T_GSTOCK a,
		T_GStockItems b,
		t_client c,
		t_unitofmeas d,
		t_unitofmeas e,
		t_fabrictype f
    where
		a.stockid=b.stockid and		
		a.clientid=c.clientid and		
		b.punitofmeasid=d.unitofmeasid(+) and
		b.sunitofmeasid=e.unitofmeasid(+) and
		b.fabrictypeid=f.fabrictypeid  and
		(pOrderno is null or b.orderno=pOrderno) and b.gtranstypeid=1 and
		a.STOCKTRANSDATE between decode(vSDate,null,'01-jan-2000',vSDate) and vEDate 
		Group by 	
    	a.ClientID,b.ORDERNO,b.FabricTypeId,StockTransNO, StockTransDATE,
   		b.PunitOfmeasId,b.SUNITOFMEASID,Shade,FabricDia,FabricGSM,Styleno,
    	c.clientname,f.fabrictype,d.unitofmeas,e.unitofmeas,
		f.fabrictype;    
/* For Datewise Cutting Summary*/
   elsif(pQueryType=5) then
    open one_cursor for
    select 	StockTransDATE,getfncDispalyorder(b.ORDERNO) as dorder,
    		a.ClientID,b.ORDERNO,b.PunitOfmeasId,trim(Shade) as Shade,Styleno,
    		c.clientname,d.unitofmeas as punit,Sum(Quantity) as Quantity,
			
		Nvl((select Nvl(sum(quantity),0) from t_gorderitems y 
		where y.gorderno=b.orderno and 
		trim(y.shade)=trim(b.shade) and y.STYLE=b.styleno
		group by GORDERNO,trim(y.shade),Style),0) as orderqty,
		
		Nvl((select Nvl(sum(quantity),0) from t_gstock x, t_gstockitems y 
		where x.stockid=y.stockid and y.orderno=b.orderno and 
		y.shade=b.shade and y.styleno=b.styleno
	    and gtranstypeid=3 and x.STOCKTRANSDATE<a.STOCKTRANSDATE
		group by b.ORDERNO,Shade,Styleno),0) as Prvcutting
		
    from  T_GSTOCK a,
		T_GStockItems b,
		t_client c,
		t_unitofmeas d		
    where a.stockid=b.stockid and		
		a.clientid=c.clientid and		
		b.punitofmeasid=d.unitofmeasid(+) and		
		(pOrderno is null or b.orderno=pOrderno) and b.gtranstypeid=3 and
		a.STOCKTRANSDATE between decode(vSDate,null,'01-jan-2000',vSDate) and vEDate 
	Group by a.ClientID,b.ORDERNO, StockTransDATE,
   		b.PunitOfmeasId,b.shade,Styleno, c.clientname,d.unitofmeas;			
/* For  Order Followup Report */
elsif(pQueryType=6) then
    open one_cursor for
    select 	getfncDispalyorder(b.ORDERNO) as dorder,    		
		Nvl(sum(quantity),0) as oqtypc,
		orderkg(b.orderno) as oqtykg,
		sum(decode(gtranstypeid,1,quantity,0)) as Recvkg,
		sum(decode(gtranstypeid,3,quantity,0)) as Cutting,
		sum(decode(gtranstypeid,7,quantity,0)) as Sewing,
		sum(decode(gtranstypeid,14,quantity,0)) as Finishing,
		sum(decode(gtranstypeid,24,quantity,0)) as Packing,
		sum(decode(gtranstypeid,20,quantity,0)) as ctn,
		sum(decode(gtranstypeid,25,quantity,0)) as shipped
    from  T_GSTOCK a,T_GStockItems b		
    where a.stockid=b.stockid and
		b.GTRANSTYPEID in (1,3,7,14,24,20,25) and
		(pOrderno is null or b.orderno=pOrderno) 
	Group by b.ORDERNO
	order by dorder desc;    
/* For  RMG production status report */
elsif(pQueryType=7) then
    open one_cursor for
    select 	getfncDispalyorder(b.ORDERNO) as dorder,b.sizeid,c.sizename,b.styleno,'' as shade,
	    x.clientname,sum(decode(gtranstypeid,3,quantity,0)) as Cutting,
		sum(decode(gtranstypeid,6,quantity,0)) as SInput,
		sum(decode(gtranstypeid,7,quantity,0)) as Sewing,
		sum(decode(gtranstypeid,13,quantity,0)) as FInput,
		sum(decode(gtranstypeid,14,quantity,0)) as Finishing,
		sum(decode(gtranstypeid,24,quantity,0)) as Packing,
		sum(decode(gtranstypeid,20,quantity,0)) as ctn,
		sum(decode(gtranstypeid,25,quantity,0)) as shipped
		
    from T_GSTOCK a,
		T_GStockItems b,
		T_size c,
        t_client x,
        t_gworkorder y 		
    where a.stockid=b.stockid and	
		b.sizeid=c.sizeid	and 
		b.orderno=y.gorderno and
		b.GTRANSTYPEID in (3,6,7,13,14,24,20,25) and
		y.clientid=x.clientid and
		(pOrderno is null or b.orderno=pOrderno) and	
		a.STOCKTRANSDATE=vEDate 
		Group by 	
    	x.clientname,b.ORDERNO,b.sizeid,c.sizename,b.styleno
		order by dorder desc;	
end if;
END GMainStockAll;
/


PROMPT CREATE OR REPLACE Procedure  142:: RptMEBillSummary003
Create or Replace Procedure RptMEBillSummary003(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,  
  pCustomerId in NUMBER,
  sDate IN VARCHAR2,
  eDate IN VARCHAR2
)
AS
vSDate date;
vEDate date;
BEGIN
  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  else
    vSDate:=TO_DATE('01-JAN-2008', 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  else
    vEDate := TO_DATE('01-DEC-2050', 'DD/MM/YYYY');
  end if;
  
/*Maintenance Bill for Allied*/
if pQueryType=0 then
    open data_cursor for
	select distinct a.SERIALNO as billno,a.BILLMONTH,a.ISSUEDATE,a.CURRENTREADING,a.CURRENTREADINGDATE,     
	a.PREVREADING,a.PREVDATE,a.USENCEUNIT,round(nvl(a.PAYABLEAMOUNT,0)) as PAYABLEAMOUNT,a.BMONTH,a.BYEAR,
	decode(b.RECEIPTFOR,5,b.RECEIPTNO,'') as RECEIPTNO,decode(b.RECEIPTFOR,5,b.RECEIPTDATE,'') as RECEIPTDATE,
	decode(b.RECEIPTFOR,5,round(nvl(b.AMOUNT,0)),0) as AMOUNT,a.CUSTOMERID,
	c.NAME,c.OFFICENO,c.CONTACTNO,c.COATACTPERSON       
    from T_ELECTRICITYBILL a, T_Moneyreceipt b,T_AlliedCustomer c
    where a.BILLTYPE=2 and /*Maintenance bill type=2*/		  
		  a.PID=b.CUSTOMERID(+) and /*Customer id of money receipt=bill id of electric bill*/
		  a.CUSTOMERID=c.CUSTOMERID(+) and
		  a.CUSTOMERID=pCustomerId and
		  /* b.RECEIPTFOR=5 and for Allied */	
		  a.ISSUEDATE between vSDate and vEDate
	order by a.CUSTOMERID,a.ISSUEDATE;
/*Electric Bill for Allied*/	
elsif pQueryType=1 then
    open data_cursor for
	select distinct a.SERIALNO as billno,a.BILLMONTH,a.ISSUEDATE,a.CURRENTREADING,a.CURRENTREADINGDATE,     
	a.PREVREADING,a.PREVDATE,a.USENCEUNIT,round(nvl(a.PAYABLEAMOUNT,0)) as PAYABLEAMOUNT,a.BMONTH,a.BYEAR,
	decode(b.RECEIPTFOR,5,b.RECEIPTNO,'') as RECEIPTNO,decode(b.RECEIPTFOR,5,b.RECEIPTDATE,'') as RECEIPTDATE,
	decode(b.RECEIPTFOR,5,round(nvl(b.AMOUNT,0)),0) as AMOUNT,a.CUSTOMERID,
	c.NAME,c.OFFICENO,c.CONTACTNO,c.COATACTPERSON  	       
    from T_ELECTRICITYBILL a, T_Moneyreceipt b,T_AlliedCustomer c
    where a.BILLTYPE=1 and /*Electric bill type=1*/		  
		  a.PID=b.CUSTOMERID(+) and /*Customer id of money receipt=bill id of electric bill*/
		  a.CUSTOMERID=c.CUSTOMERID(+) and
		  a.CUSTOMERID=pCustomerId and
		  /*b.RECEIPTFOR=5 and for Allied */	
		  a.ISSUEDATE between vSDate and vEDate
	order by a.CUSTOMERID,a.ISSUEDATE;
end if;
END RptMEBillSummary003;
/
  
  
  
PROMPT CREATE OR REPLACE Procedure  143:: DC001Stock  
CREATE OR REPLACE Procedure DC001Stock(
  data_cursor IN OUT pReturnData.c_Records, 
  pQuerytype in number, 
  pParameter in number,
  sDate IN VARCHAR2,
  eDate IN VARCHAR2
)
AS 
  vSDate date;
  vEDate date;
BEGIN  
  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  else
    vSDate := TO_DATE('01-JAN-2000', 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  else
    vEDate := TO_DATE('01-JAN-2050', 'DD/MM/YYYY');
  end if;  
/*Supplier wise report of MRR between date*/
if(pQuerytype=1) then 
  OPEN data_cursor FOR
  select a.STOCKINVOICENO,a.STOCKDATE,c.SUPPLIERNAME,b.STOCKQTY,
		d.AUXTYPE,e.AUXNAME
  from T_AuxStock a,T_AuxStockItem b,T_Supplier c,
		T_AuxType d,T_Auxiliaries e
  where a.AUXSTOCKID=b.AUXSTOCKID and 
		a.AUXSTOCKTYPEID=1 and
		b.AUXTYPEID=d.AUXTYPEID and
		b.AUXID=e.AUXID and          
		(pParameter is null or a.SUPPLIERID=pParameter) and
		a.SUPPLIERID=c.SUPPLIERID and
		a.STOCKDATE between vSDate and vEDate   
  Order by a.STOCKINVOICENO,a.STOCKDATE,c.SUPPLIERNAME,d.AUXTYPE,e.AUXNAME;
/*Chemical wise report of Stock between date*/
elsif(pQuerytype=2) then
  OPEN data_cursor FOR
  select a.STOCKINVOICENO,a.STOCKDATE,c.SUPPLIERNAME,
        decode(a.AUXSTOCKTYPEID,1,b.STOCKQTY,0) as MainStockQty,
		decode(a.AUXSTOCKTYPEID,2,b.STOCKQTY,0) as SubStockQty,
		decode(a.AUXSTOCKTYPEID,3,b.STOCKQTY,0) as ProductionQty,
		d.AUXTYPE,e.AUXNAME
  from T_AuxStock a,T_AuxStockItem b,T_Supplier c,
		T_AuxType d,T_Auxiliaries e
  where a.AUXSTOCKID=b.AUXSTOCKID and 
		a.AUXSTOCKTYPEID in (1,2,3) and
		b.AUXTYPEID=d.AUXTYPEID and
		b.AUXID=e.AUXID and          
		(pParameter is null or b.AUXID=pParameter) and
		a.SUPPLIERID=c.SUPPLIERID and
		a.STOCKDATE between vSDate and vEDate 
  Order by a.STOCKINVOICENO,a.STOCKDATE,c.SUPPLIERNAME,d.AUXTYPE,e.AUXNAME;
End if;
End DC001Stock;
/



PROMPT CREATE OR REPLACE Procedure  144:: rptGI003 
Create or Replace Procedure rptGI003
(
 data_cursor IN OUT pReturnData.c_Records,
 pStokid Number
)
AS
BEGIN
 OPEN data_cursor  FOR
  SELECT a.STOCKID,a.STOCKTRANSNO,a.STOCKTRANSDATE,c.DEPTNAME,d.COUNTRYNAME,
        b.QUANTITY,e.Unitofmeas,f.ITEM,g.BRANDNAME,b.REMARKS	
  from T_Stationerystock a,T_StationerystockItems b,T_Department c,T_Country d,
		T_Unitofmeas e,T_Stationery f,T_Brand g
  where a.Stockid=b.Stockid and
		b.DEPTID=c.DEPTID(+) and
		b.COUNTRYID=d.COUNTRYID(+) and
		b.PUNITOFMEASID=e.UNITOFMEASID(+) and
		b.STATIONERYID=f.STATIONERYID(+) and
		b.BRANDID=g.BRANDID(+) and
		a.Stockid=pStokid;
END rptGI003;
/


PROMPT CREATE OR REPLACE Procedure  145:: FinishingProduction 
CREATE OR REPLACE Procedure FinishingProduction
(
  one_cursor IN OUT pReturnData.c_Records,
	pQueryType in Number,
  	pOrderno in number,
	sDate IN VARCHAR2,
  	eDate IN VARCHAR2  
)

AS
  	vSDate date;
  	vEDate date;
BEGIN

  	if not sDate is null then
    		vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  	end if;
  	if not eDate is null then
    		vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  	end if; 	


if(pQueryType=1) then
    open one_cursor for
    
 select 	
		getfncDispalyorder(b.ORDERNO) as dorder,b.SIZEID,c.SIZENAME,substr(e.clientname,1,16) as clientname,    		
    		b.ORDERNO,b.PunitOfmeasId,Styleno,d.unitofmeas as punit,
		Nvl(sum(DECODE(b.GTRANSTYPEID,13,nvl((Quantity*GIF),0))),0) as Ironinput,
 		nvl(sum(DECODE(b.GTRANSTYPEID,14,nvl((quantity*FGS),0))),0) as IronOutput,
		nvl(sum(DECODE(b.GTRANSTYPEID,19,nvl((Quantity*POLY),0))),0) as Polyinput,
 		nvl(sum(DECODE(b.GTRANSTYPEID,24,nvl((quantity*CTN),0))),0) as Polyout,
		nvl(sum(DECODE(b.GTRANSTYPEID,20,nvl((Quantity*FGFD),0))),0) as rqty 		
    from  
		T_GSTOCK a,
		T_GStockItems b,
		T_Size c,		
		t_unitofmeas d,	
		t_client e,
		t_gworkorder f,		
		T_GTransactionType g
    where
		a.stockid=b.stockid and					
		b.punitofmeasid=d.unitofmeasid(+) and		
		b.sizeid=c.sizeid  and
		b.GTRANSTYPEID=g.GTRANSACTIONTYPEID and
		b.orderno=f.gorderno and 
		f.clientid=e.clientid 
Group by		
    		b.ORDERNO,b.sizeid,
   		b.PunitOfmeasId,Styleno,
    		d.unitofmeas,b.SIZEID,c.SIZENAME,e.clientname 
HAVING Nvl(sum(DECODE(b.GTRANSTYPEID,13,nvl((Quantity*GIF),0))),0)>0 AND
nvl(sum(DECODE(b.GTRANSTYPEID,19,nvl((Quantity*POLY),0))),0)>0;

   
end if;
END FinishingProduction;
/


PROMPT CREATE OR REPLACE Procedure  146:: GetReportSewingInput 
CREATE OR REPLACE PROCEDURE GetReportSewingInput(
  data_cursor IN OUT pReturnData.c_Records,
  sDate IN VARCHAR2,
  eDate IN VARCHAR2  
)
AS
  vSDate date;
  vEDate date;
BEGIN

  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  end if;
 	
OPEN data_cursor  FOR
		Select B.SHADE,getfncDispalyorder(C.GORDERNO) as btype,b.PUNITOFMEASID as Unitofmeasid,b.SIZEID,B.styleno,
		e.sizename,f.unitofmeas,g.countryname,C.GORDERNO,b.lineno,j.clientname,
		NVL(Sum(DECODE(b.GTRANSTYPEID,6,(b.QUANTITY*CGSL))),0) as issueqty
	from 
		T_GSTOCK a,
		T_GStockItems b,
		t_Gworkorder c,		
		t_size e,
		t_unitofmeas f,
		t_country g,
		t_gtransactiontype i,
		t_client j
	where 
		a.STOCKID=b.STOCKID and
		b.GTRANSTYPEID=i.GTRANSACTIONTYPEID and
		B.orderno=c.gorderno and		
		b.sizeid=e.sizeid and
		B.countryid=g.countryid and
		b.Punitofmeasid=f.unitofmeasid and
		c.clientid=j.clientid and		
		a.STOCKTRANSDATE between decode(vSDate,null,'01-jan-2000',vSDate) and vEDate
	group by 
		B.SHADE,b.PUNITOFMEASID,b.SIZEID,B.styleno,
		e.sizename,f.unitofmeas,g.countryname,C.GORDERNO,b.lineno,j.clientname
having NVL(Sum(DECODE(b.GTRANSTYPEID,6,(b.QUANTITY*CGSL))),0)>0
	
	order by 
		B.styleno;
END GetReportSewingInput;
/



PROMPT CREATE OR REPLACE Procedure  147:: IssueforPrint 
CREATE OR REPLACE Procedure IssueforPrint
(
  one_cursor IN OUT pReturnData.c_Records,
  pGStockID number
)
AS
BEGIN
    open one_cursor for
    select  ChallanNo, ChallanDate, StockTransNO, StockTransDATE,
    getfncDispalyorder(b.ORDERNO) as dorder, g.CLIENTNAME,
    (Select ORDERTYPEID || ' ' || GDORDERNO from T_SCGWorkOrder where SCGORDERNO=a.GDORDERNO and ORDERTYPEID='SCGPE') as SCGDORDERNO,
    a.SubConId,GatepassNo,cuttingno(b.cuttingid) as cuttingno,a.DELIVERYPLACE,
    b.ORDERNO,b.STOCKID,GSTOCKITEMSL,b.FabricTypeId,Quantity,
    Squantity,b.PunitOfmeasId,b.SUNITOFMEASID,getClientRef(b.ORDERNO) as ClientRef,
    Shade,a.REMARKS,FabricDia,FabricGSM,Styleno,
    c.SUBCONNAME,d.unitofmeas as punit,e.unitofmeas as sunit,f.sizename,GCUTTINGPARTS
    from  T_GSTOCK a,T_GStockItems b,t_subcontractors c,t_unitofmeas d,t_unitofmeas e,t_size f,t_client g,T_GCUTTINGPARTSLIST h
    where a.stockid=b.stockid and
	/*b.GTRANSTYPEID=4 and*/
	a.SUBCONID=c.SUBCONID and
	a.CLIENTID=g.CLIENTID(+) and
	a.STOCKID=pGStockID and
	b.punitofmeasid=d.unitofmeasid(+) and
	b.sunitofmeasid=e.unitofmeasid(+) and
	b.sizeid=f.sizeid(+) and
	b.GCPARTSID=h.GCPARTSID(+)
    order  by GSTOCKITEMSL asc;
END IssueforPrint;
/



PROMPT CREATE OR REPLACE Procedure  148:: ReceiveformPrint 
CREATE OR REPLACE Procedure ReceiveformPrint
(
  one_cursor IN OUT pReturnData.c_Records,
  pGStockID number
)
AS
BEGIN
    open one_cursor for
    select  ChallanNo, ChallanDate, StockTransNO, StockTransDATE,
	getfncDispalyorder(b.ORDERNO) as dorder,getClientRef(b.ORDERNO) as ClientRef,
    a.SubConId,GatepassNo,cuttingno(b.cuttingid) as cuttingno,
    b.ORDERNO,b.STOCKID,GSTOCKITEMSL,b.FabricTypeId,Quantity,
    Squantity,b.PunitOfmeasId,b.SUNITOFMEASID,
    Shade,b.REMARKS,FabricDia,FabricGSM,Styleno,c.SUBCONNAME,
	d.unitofmeas as punit,e.unitofmeas as sunit,f.sizename,GCUTTINGPARTS
    from
	T_GSTOCK a,
	T_GStockItems b,
	t_subcontractors c,
	t_unitofmeas d,
	t_unitofmeas e,
	t_size f,
	T_GCUTTINGPARTSLIST h
    where
	a.stockid=b.stockid and
	/*b.GTRANSTYPEID=5 and*/
	a.SUBCONID=c.SUBCONID and
	a.STOCKID=pGStockID and
	b.punitofmeasid=d.unitofmeasid(+) and
	b.sunitofmeasid=e.unitofmeasid(+) and
	b.sizeid=f.sizeid(+) AND
	b.GCPARTSID=h.GCPARTSID(+)
    order by GSTOCKITEMSL asc;
END ReceiveformPrint;
/



PROMPT CREATE OR REPLACE Procedure  149:: rptDIPrintSummary 
CREATE OR REPLACE Procedure rptDIPrintSummary
(
  one_cursor IN OUT pReturnData.c_Records,
  pOrderNo in number,  
  sOrderNo in Number,
  eOrderNo in Number,
  sDate IN VARCHAR2,
  eDate IN VARCHAR2
)
AS
vSDate date;
vEDate date;
minorder number(10);
maxorder number(10);
BEGIN
    if not sDate is null then
		vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
	end if;
	if not eDate is null then
		vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
	end if;
	select min(orderno) into minorder from t_gstockitems ;
	select max(orderno) into maxorder from t_gstockitems ;
open one_cursor for
    select 	a.StockTransNO,a.StockTransDATE,getfncDispalyorder(b.ORDERNO) as dorder,
    		sum(b.Quantity) as quantity,b.Shade,b.Styleno,c.subconname
    from  
		T_GSTOCK a,
		T_GStockItems b,
		t_subcontractors c	
    where
		a.stockid=b.stockid and
		b.GTRANSTYPEID=4 and
		(pOrderNo is null or pOrderNo=b.ORDERNO) and
		a.SUBCONID=c.SUBCONID and		
		(b.ORDERNO between decode(sOrderNo,null,minorder,sOrderNo) and decode(eOrderNo,null,maxorder,eOrderNo)) and
		a.StockTransDATE between decode(vSDate,null,'01-jan-2000',vSDate) and vEDate
	group by a.StockTransNO,a.StockTransDATE,b.ORDERNO,b.Shade,b.Styleno,c.subconname	
    order by getfncDispalyorder(b.ORDERNO),a.StockTransNO,a.StockTransDATE,c.subconname,b.Shade,b.Styleno asc;
END rptDIPrintSummary;
/



PROMPT CREATE OR REPLACE Procedure  150:: GetReportNeedleMPType 
CREATE OR REPLACE Procedure GetReportNeedleMPType
(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,  
  pMCPARTSTYPEID in number,  
  pMACHINEID in number,
  sDate IN VARCHAR2,
  eDate IN VARCHAR2
)
AS
  vSDate date;
  vEDate date;

BEGIN
  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  else
   vSDate := TO_DATE('01/01/1900', 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  else
   vEDate := TO_DATE('01/01/2100', 'DD/MM/YYYY');
  end if;

  if pQueryType=0 then
        open data_cursor for

        select b.PARTID,c.PARTNAME,MCTYPENAME,c.MCPARTSTYPEID,f.MCPARTSTYPE,
           sum(b.QTY * d.MSN) as MainStoreNew,
           sum(b.QTY * d.MSO) as MainStoreOld,
           sum(b.QTY * d.MSB) as MainStoreBroken,
           sum(b.QTY * d.MSR) as MainStoreRejected,
           sum(decode(b.MACHINEID,0,(b.QTY * d.FSN),0)) as FloorNew,
           sum(decode(b.MACHINEID,0,(b.QTY * d.FSO),0)) as FloorOld,
           sum(decode(b.MACHINEID,0,0,(b.QTY * d.FSN))) as MachineNew,
           sum(decode(b.MACHINEID,0,0,(b.QTY * d.FSO))) as MachineOld,
           sum(b.QTY * d.SSN) as SubContractorNew
       from   t_kmcPartsstatus a,t_kmcpartstransdetails b,t_kmcpartsinfo c,t_kmcstockStatus d,t_kmctype e,t_MCPARTSTYPE f,T_KmcPartsTran x
        where  b.PARTID=c.PARTID and b.stockid=x.stockid(+) and
        c.MCTYPEID=e.MCTYPEID and
        b.PARTSSTATUSTOID=a.PARTSSTATUSID and
        B.KMCSTOCKTYPEID=d.KMCSTOCKTYPEID and 
		b.PARTSSTATUSFROMID=d.PARTSSTATUSFROMID and
        b.PARTSSTATUSTOID=d.PARTSSTATUSTOID  and
		c.MCPARTSTYPEID=f.MCPARTSTYPEID and
		(pMACHINEID is null or b.MACHINEID=pMACHINEID) and
		(pMCPARTSTYPEID is null or c.MCPARTSTYPEID=pMCPARTSTYPEID) and			
		x.STOCKDATE<=vEDate	
        group by b.PARTID,c.PARTNAME,c.MCTYPEID,e.MCTYPENAME,c.MCPARTSTYPEID,f.MCPARTSTYPE
    order by c.MCPARTSTYPEID,MCTYPENAME,c.PARTNAME asc;

/* For Report Needle bROKEN From Floor and Machine Only*/
  elsif pQueryType=1 then
 open data_cursor for
	select d.PARTID,b.PARTNAME,e.MCTYPENAME,g.MACHINEID,G.MACHINENAME,sum(d.QTY)
    	from T_KmcPartsTran a,t_kmcpartsinfo b,t_kmcpartsstatus c,T_KMCPARTSTRANSDETAILS d,t_KMCTYPE e,T_KNITMACHINEINFO g
    	where d.STOCKID=a.StockId and d.PARTID=b.PARTID and d.MACHINEID=g.MACHINEID and
    	c.partsstatusid=d.PARTSSTATUSTOID and d.KMCTYPEID=e.MCTYPEID and
    	a.KmcStockTypeId=3 AND d.PARTSSTATUSTOID=3 and
		b.MCPARTSTYPEID=pMCPARTSTYPEID and  
		(pMACHINEID is null or d.MACHINEID=pMACHINEID) and
		a.StockDate Between decode(VsDate,null,'01-JAN-2000',VsDate) and VeDate
	group by d.PARTID,b.PARTNAME,e.MCTYPENAME,g.MACHINEID,G.MACHINENAME;

  elsif pQueryType=2 then
 open data_cursor for
        select a.STOCKID,a.STOCKDATE,a.CHALLANNO,a.CHALLANDATE,a.PURCHASEORDERNO,a.PURCHASEORDERDATE,b.PARTID,c.PARTNAME,MCTYPENAME,c.MCPARTSTYPEID,f.MCPARTSTYPE,b.KMCSTOCKTYPEID,b.mACHINEID,
           (b.QTY) as MainIn,0 as Issue2Floor,0 as ReturnFromFloor,0 as Floor2Machine
           from T_KmcPartsTran a,t_kmcpartstransdetails b,t_kmcpartsinfo c,t_kmcstockStatus d,t_kmctype e,T_MCPARTSTYPE f
           where a.STOCKID=b.StockId and b.PARTID=c.PARTID and B.KMCSTOCKTYPEID=d.KMCSTOCKTYPEID and
           b.PARTSSTATUSFROMID=d.PARTSSTATUSFROMID and b.PARTSSTATUSTOID=d.PARTSSTATUSTOID and
	   c.MCPARTSTYPEID=f.MCPARTSTYPEID and c.MCTYPEID=e.MCTYPEID and b.KMCSTOCKTYPEID=1 and
	   c.MCPARTSTYPEID=pMCPARTSTYPEID and 
	   (pMACHINEID is null or b.MACHINEID=pMACHINEID) and
	   a.StockDate Between decode(VsDate,null,'01-JAN-2000',VsDate) and VeDate
	union all
        select a.STOCKID,a.STOCKDATE,a.CHALLANNO,a.CHALLANDATE,a.PURCHASEORDERNO,a.PURCHASEORDERDATE,b.PARTID,c.PARTNAME,MCTYPENAME,c.MCPARTSTYPEID,f.MCPARTSTYPE,b.KMCSTOCKTYPEID,b.mACHINEID,
           0 as MainIn,(b.QTY) as Issue2Floor,0 as ReturnFromFloor,0 as Floor2Machine
           from T_KmcPartsTran a,t_kmcpartstransdetails b,t_kmcpartsinfo c,t_kmcstockStatus d,t_kmctype e,T_MCPARTSTYPE f
           where a.STOCKID=b.StockId and b.PARTID=c.PARTID and B.KMCSTOCKTYPEID=d.KMCSTOCKTYPEID and
           b.PARTSSTATUSFROMID=d.PARTSSTATUSFROMID and b.PARTSSTATUSTOID=d.PARTSSTATUSTOID and
	   c.MCPARTSTYPEID=f.MCPARTSTYPEID and c.MCTYPEID=e.MCTYPEID and b.KMCSTOCKTYPEID=2 and
	   c.MCPARTSTYPEID=pMCPARTSTYPEID and 
	   (pMACHINEID is null or b.MACHINEID=pMACHINEID) and
	   a.StockDate Between decode(VsDate,null,'01-JAN-2000',VsDate) and VeDate
	union all
        select a.STOCKID,a.STOCKDATE,a.CHALLANNO,a.CHALLANDATE,a.PURCHASEORDERNO,a.PURCHASEORDERDATE,b.PARTID,c.PARTNAME,MCTYPENAME,c.MCPARTSTYPEID,f.MCPARTSTYPE,b.KMCSTOCKTYPEID,b.mACHINEID,
           0 as MainIn,0 as Issue2Floor,(b.QTY) as ReturnFromFloor,0 as Floor2Machine
           from T_KmcPartsTran a,t_kmcpartstransdetails b,t_kmcpartsinfo c,t_kmcstockStatus d,t_kmctype e,T_MCPARTSTYPE f
           where a.STOCKID=b.StockId and b.PARTID=c.PARTID and B.KMCSTOCKTYPEID=d.KMCSTOCKTYPEID and
           b.PARTSSTATUSFROMID=d.PARTSSTATUSFROMID and b.PARTSSTATUSTOID=d.PARTSSTATUSTOID and
	   c.MCPARTSTYPEID=f.MCPARTSTYPEID and c.MCTYPEID=e.MCTYPEID and b.KMCSTOCKTYPEID=3 and
	   c.MCPARTSTYPEID=pMCPARTSTYPEID and 
	   (pMACHINEID is null or b.MACHINEID=pMACHINEID) and
	   a.StockDate Between decode(VsDate,null,'01-JAN-2000',VsDate) and VeDate
	union all
        select a.STOCKID,a.STOCKDATE,a.CHALLANNO,a.CHALLANDATE,a.PURCHASEORDERNO,a.PURCHASEORDERDATE,b.PARTID,c.PARTNAME,MCTYPENAME,c.MCPARTSTYPEID,f.MCPARTSTYPE,b.KMCSTOCKTYPEID,b.mACHINEID,
           0 as MainIn,0 as Issue2Floor,(b.QTY) as ReturnFromFloor,0 as Floor2Machine
           from T_KmcPartsTran a,t_kmcpartstransdetails b,t_kmcpartsinfo c,t_kmcstockStatus d,t_kmctype e,T_MCPARTSTYPE f
           where a.STOCKID=b.StockId and b.PARTID=c.PARTID and B.KMCSTOCKTYPEID=d.KMCSTOCKTYPEID and
           b.PARTSSTATUSFROMID=d.PARTSSTATUSFROMID and b.PARTSSTATUSTOID=d.PARTSSTATUSTOID and
	   c.MCPARTSTYPEID=f.MCPARTSTYPEID and c.MCTYPEID=e.MCTYPEID and b.KMCSTOCKTYPEID=9 and
	   c.MCPARTSTYPEID=pMCPARTSTYPEID and 
	   (pMACHINEID is null or b.MACHINEID=pMACHINEID) and
	   a.StockDate Between decode(VsDate,null,'01-JAN-2000',VsDate) and VeDate;
  end if;

END GetReportNeedleMPType;
/



PROMPT CREATE OR REPLACE Procedure  151:: S001GStationeryStock 
CREATE OR REPLACE Procedure S001GStationeryStock (
  data_cursor IN OUT pReturnData.c_Records,  
  eDate IN VARCHAR2
)
AS 
  vEDate date;
BEGIN  
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  end if;  
  
  OPEN data_cursor FOR
  select b.Item,c.UNITOFMEAS,g.GROUPNAME,e.DEPTNAME,f.COUNTRYNAME,d.BRANDNAME,j.NAME as Reqby,
  		 sum(decode(a.TRANSTYPEID,1,a.QUANTITY,0)) as RecvQty ,
		 sum(decode(a.TRANSTYPEID,1,a.QUANTITY,4,-a.QUANTITY,0))as StockQty,
		 sum(decode(a.TRANSTYPEID,4,a.QUANTITY,0)) as IssueQty        
  from T_StationeryStockItems a,T_Stationery b,T_Unitofmeas c,T_Brand d,
        T_Department e,T_Country f,T_StationeryGroup g,T_StationeryStock h,
		T_PURCHASEREQBY j
  where  a.STOCKID=h.STOCKID and
		 a.STATIONERYID=b.STATIONERYID(+) and
		 a.PUNITOFMEASID=c.Unitofmeasid(+) and
		 a.BRANDID=d.BRANDID(+) and
		 a.DEPTID=e.DEPTID(+) and
		 a.COUNTRYID=f.COUNTRYID(+) and
		 a.GROUPID=g.GROUPID(+) and
		 a.REQBY=j.PID(+) and
		 h.STOCKTRANSDATE <= decode(vEDate,null,'01-JAN-2050',vEDate)
  group by j.NAME,b.Item,g.GROUPNAME,e.DEPTNAME,f.COUNTRYNAME,d.BRANDNAME,c.UNITOFMEAS
  Order by j.NAME,b.Item,g.GROUPNAME,e.DEPTNAME,f.COUNTRYNAME,d.BRANDNAME,c.UNITOFMEAS;
End S001GStationeryStock;
/



PROMPT CREATE OR REPLACE Procedure  152:: GetRptKmcPBrok004 
CREATE OR REPLACE Procedure GetRptKmcPBrok004
(
	data_cursor IN OUT pReturnData.c_Records, 
	pMCPARTSTYPEID in number,  
	pMACHINEID in number,	
	eDate IN VARCHAR2
)
AS
	vSDate date;
	vEDate date;
BEGIN	
	if not eDate is null then
		vSDate := TO_Date('01/01/'||eDate,'DD/MM/YYYY');
		vEDate := TO_Date('31/12/'||eDate,'DD/MM/YYYY');	
	end if;
open data_cursor for  
select b.MACHINENAME,
		nvl(sum(decode(to_char(d.STOCKDATE,'MM'),'01',a.Qty,0)),0) as Jan,
		nvl(sum(decode(to_char(d.STOCKDATE,'MM'),'02',a.Qty,0)),0) as Feb,
		nvl(sum(decode(to_char(d.STOCKDATE,'MM'),'03',a.Qty,0)),0) as Mar,
		nvl(sum(decode(to_char(d.STOCKDATE,'MM'),'04',a.Qty,0)),0) as Apr,
		nvl(sum(decode(to_char(d.STOCKDATE,'MM'),'05',a.Qty,0)),0) as May,
		nvl(sum(decode(to_char(d.STOCKDATE,'MM'),'06',a.Qty,0)),0) as Jun,
		nvl(sum(decode(to_char(d.STOCKDATE,'MM'),'07',a.Qty,0)),0) as July,
		nvl(sum(decode(to_char(d.STOCKDATE,'MM'),'08',a.Qty,0)),0) as Aug,
		nvl(sum(decode(to_char(d.STOCKDATE,'MM'),'09',a.Qty,0)),0) as Sep,
		nvl(sum(decode(to_char(d.STOCKDATE,'MM'),'10',a.Qty,0)),0) as Octo,
		nvl(sum(decode(to_char(d.STOCKDATE,'MM'),'11',a.Qty,0)),0) as Nov,
		nvl(sum(decode(to_char(d.STOCKDATE,'MM'),'12',a.Qty,0)),0) as Decem
	from T_KMCPARTSTRANSDETAILS a,T_KNITMACHINEINFO b,t_kmcpartsinfo c,T_KmcPartsTran d
    where a.MACHINEID=b.MACHINEID and
	    a.StockID=d.StockID and 
		a.PARTSSTATUSTOID=3 and /*Broken*/
		a.PartID=c.PartID and
		c.MCPARTSTYPEID=1 and  /*Needle*/
		(pMACHINEID is null or a.MACHINEID=pMACHINEID) and 
		d.STOCKDATE between vSDate and vEDate
	group by b.MACHINENAME
	Order By b.MACHINENAME;
END GetRptKmcPBrok004;
/


PROMPT CREATE OR REPLACE Procedure  153:: AL001ElectricityBill 

CREATE OR REPLACE Procedure AL001ElectricityBill
(
  one_cursor IN OUT pReturnData.c_Records, 
  pWhere number,
  pInwordPayable varchar2,
  pInwordstotal varchar2
)
AS
BEGIN
    open one_cursor for
    select  PID,a.CUSTOMERID,CURRENTREADING,CURRENTREADINGDATE,USENCEUNIT,UNITRATE,ISSUEDATE,PAYMENTDATE,USENCECOST,             
 GOVTDUTY,SERVICECHARGE ,DEMANDCHARGE, VAT,round(DUEAMOUNT) as DUEAMOUNT,round(PAYABLEAMOUNT) as PAYABLEAMOUNT,round(TOTALAMOUNT) as TOTALAMOUNT ,PAID,SERIALNO, a.EMPLOYEEID,BILLMONTH,b.OFFICESIZE,             
b.MAINTENENCEACCOUNTS, PREVREADING,PREVDATE,PAIDAMOUNT,b.meterno,b.officeno ,b.name,a.bmonth,a.byear,c.employeename        
    from T_ElectricityBill a, T_AlliedCustomer b,T_Employee c
    where a.CUSTOMERID=b.customerid and a.employeeid=c.employeeid and PID=pWhere;   
END AL001ElectricityBill;
/



PROMPT CREATE OR REPLACE Procedure  154 :: AL002Received
CREATE OR REPLACE Procedure AL002Received
(
  one_cursor IN OUT pReturnData.c_Records, 
  pWhere number,
  sDate IN VARCHAR2,
  eDate IN VARCHAR2
)
AS
vSDate date;
vEDate date;

BEGIN
    if not sDate is null then
		vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
	end if;
	if not eDate is null then
		vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
	end if;	
    open one_cursor for
    select  PID,a.CUSTOMERID,CURRENTREADING,CURRENTREADINGDATE,USENCEUNIT,UNITRATE,ISSUEDATE,PAYMENTDATE,USENCECOST,             
 GOVTDUTY,SERVICECHARGE ,DEMANDCHARGE, VAT,DUEAMOUNT,PAYABLEAMOUNT,TOTALAMOUNT,PAID,SERIALNO, EMPLOYEEID,BILLMONTH,
 PREVREADING,PREVDATE,PAIDAMOUNT,b.meterno,b.officeno ,b.name            
    from 
			T_ElectricityBill a, 
			T_AlliedCustomer b
    where 
			a.CUSTOMERID=b.customerid and a.paid=1 and
			(pWhere is NULL or a.pid=pWhere) and
			(sDate is NULL or a.PaidDate>=vSDate) and
			(eDate is NULL or a.PaidDate<=vEDate)
			ORDER BY SERIALNO;
END AL002Received;
/


PROMPT CREATE OR REPLACE Procedure  155 :: AL003Receiveable
CREATE OR REPLACE Procedure AL003Receiveable
(
  one_cursor IN OUT pReturnData.c_Records, 
  pWhere number,
  sDate IN VARCHAR2,
  eDate IN VARCHAR2
)
AS
vSDate date;
vEDate date;

BEGIN
    if not sDate is null then
		vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
	end if;
	if not eDate is null then
		vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
	end if;	
    open one_cursor for
    select  PID,a.CUSTOMERID,CURRENTREADING,CURRENTREADINGDATE,USENCEUNIT,UNITRATE,ISSUEDATE,PAYMENTDATE,USENCECOST,             
 GOVTDUTY,SERVICECHARGE ,DEMANDCHARGE, VAT,DUEAMOUNT,PAYABLEAMOUNT,TOTALAMOUNT,PAID,SERIALNO, EMPLOYEEID,BILLMONTH,
 PREVREADING,PREVDATE,PAIDAMOUNT,b.meterno,b.officeno ,b.name            
    from 
			T_ElectricityBill a, 
			T_AlliedCustomer b
    where 
			a.CUSTOMERID=b.customerid and a.paid=0 and
			(pWhere is NULL or a.pid=pWhere) and
			(sDate is NULL or a.PaidDate>=vSDate) and
			(eDate is NULL or a.PaidDate<=vEDate)
			ORDER BY SERIALNO;
END AL003Receiveable;
/


PROMPT CREATE OR REPLACE Procedure  156 :: AL004Moneyrecipt
CREATE OR REPLACE Procedure AL004Moneyrecipt(
  data_cursor IN OUT pReturnData.c_Records,
  pPID IN NUMBER,
  pInwords in varchar2
)
As
Begin
  OPEN data_cursor FOR
  select a.PID,a.RECEIPTNO,a.RECEIPTDATE,b.RECEIPENTNAME,c.name,a.AMOUNT,a.CASH,a.CHEQUE,a.PAYORDER,       
a.DRAFT,a.PAYMENTNO,a.PAYDATE,a.BILLNO,a.PURPOSE,d.EMPLOYEENAME,a.BRANCH,e.BANKNAME,b.description ,
c.officeno,c.meterno ,f.serialno,decode(ELECTRIC,1,'Electric Bill','Maintenance Bill') as accountof,bmonth,byear 
  from T_moneyreceipt a,T_receipent b,T_AlliedCustomer c,T_employee d,T_LcBank e,t_electricitybill f
  where a.PID=pPID and
         a.RECEIPTFOR=b.RID(+) and
		 a.customerid=f.pid and
         f.customerid=c.customerid(+) and 
		 a.bankid=e.bankid(+) and 
		 a.EMPLOYEEID=d.EMPLOYEEID(+);
End AL004Moneyrecipt;
/



PROMPT CREATE OR REPLACE Procedure  157:: GetREPORTMasterLCfrm
CREATE OR REPLACE Procedure GetREPORTMasterLCfrm (
  data_cursor IN OUT pReturnData.c_Records,
  pLCNumber IN NUMBER
)
AS
BEGIN
  OPEN data_cursor FOR
  select F.RECEIVEDATE,f.BankLCno as MasterLC,g.ClientName as ClientName,f.ReceiveDate as MDate,f.LCOrderAmt as MAmt,
  f.LCOrderQty as MQty,d.CurrencyName as CurName,H.BANKNAME AS BANKNAME,
  f.ConRate as ConRate,a.BankLCNo as BLCNo,a.OpeningDate as LCDate,c.SUPPLIERNAME as Supplier,
nvl(sum(b.Qty*b.UnitPrice),0) as Amount,sum(b.TotCost) as AmountTK,'Accessories' as impLCType,
I.IFDBCNO,I.IFDBCDATE,I.IFDBCAMOUNT,I.DUEDATE,I.PAYMENTDATE,nvl(I.PAIDAMOUNT,0) as PAIDAMOUNT,btbamount(f.lcno) as btbamount,btbamounttk(f.lcno) as btbamounttk
  from T_AccImpLC a,
T_AccImpLCItems b, 
T_supplier c,T_CURRENCY d,
T_LCInfo f,
T_client g,
T_LCBANK H,
T_BTBLCPAYMENT I
  where (pLCNumber is null or f.LCNo=pLCNumber) and
        a.ExpLCNo=f.LCNo and
        a.LCNo=b.LCNo and
        f.clientid=g.clientid and
        a.SupplierID=c.SupplierID and
        F.BANKID=H.BANKID(+) AND
        f.CURRENCYID=d.CURRENCYID AND 
		a.LCNo=i.lcno (+) and a.implctypeid=i.LCCATEGORY(+)
  group by F.RECEIVEDATE,f.BankLCno,g.ClientName,f.ReceiveDate,f.LCOrderAmt,f.LCOrderQty,d.CurrencyName,H.BANKNAME, f.ConRate,
  a.BankLCNo,a.OpeningDate,c.SUPPLIERNAME,
I.IFDBCNO,I.IFDBCDATE,I.IFDBCAMOUNT,I.DUEDATE,I.PAYMENTDATE,I.PAIDAMOUNT,f.lcno
  UNION
  select F.RECEIVEDATE,f.BankLCno as MasterLC,g.ClientName as ClientName,f.ReceiveDate as MDate,f.LCOrderAmt as MAmt,
 f.LCOrderQty as MQty,d.CurrencyName as CurName,H.BANKNAME AS BANKNAME,
  f.ConRate as ConRate,a.BankLCNo as BLCNo,a.OpeningDate as LCDate,c.SUPPLIERNAME as Supplier,
nvl(sum(b.Qty*b.UnitPrice),0) as Amount,sum(b.TotCost) as AmountTK,'Auxiliaries' as impLCType,
I.IFDBCNO,I.IFDBCDATE,I.IFDBCAMOUNT,I.DUEDATE,I.PAYMENTDATE,nvl(I.PAIDAMOUNT,0) as PAIDAMOUNT,btbamount(f.lcno) as btbamount,btbamounttk(f.lcno) as btbamounttk
  from 
  T_AuxImpLC a,
  T_AuxImpLCItems b,
  T_supplier c,
  T_CURRENCY d,
  T_LCInfo f,
  T_client g,
  T_LCBANK H,
  T_BTBLCPAYMENT I
  where (pLCNumber is null or f.LCNo=pLCNumber) and
        a.ExpLCNo=f.LCNo and
        a.LCNo=b.LCNo and
        f.clientid=g.clientid and
        F.BANKID=H.BANKID(+) AND
        a.SupplierID=c.SupplierID and
        f.CURRENCYID=d.CURRENCYID AND 
	    a.LCNo=i.lcno (+) and a.implctypeid=i.LCCATEGORY(+)
  group by F.RECEIVEDATE,f.BankLCno,g.ClientName,f.ReceiveDate,f.LCOrderAmt,f.LCOrderQty,d.CurrencyName,H.BANKNAME,
 f.ConRate,a.BankLCNo,a.OpeningDate,c.SUPPLIERNAME,
I.IFDBCNO,I.IFDBCDATE,I.IFDBCAMOUNT,I.DUEDATE,I.PAYMENTDATE,I.PAIDAMOUNT,f.lcno
  UNION
  select F.RECEIVEDATE,f.BankLCno as MasterLC,g.ClientName as ClientName,f.ReceiveDate as MDate,f.LCOrderAmt as MAmt,f.LCOrderQty as MQty,d.CurrencyName as CurName,H.BANKNAME AS BANKNAME,
  f.ConRate as ConRate,a.BankLCNo as BLCNo,a.OpeningDate as LCDate,c.SUPPLIERNAME as Supplier,
 nvl(sum(b.Qty*b.UnitPrice),0) as Amount,sum(b.TotCost) as AmountTK,'Yarn' as impLCType,
I.IFDBCNO,I.IFDBCDATE,I.IFDBCAMOUNT,I.DUEDATE,I.PAYMENTDATE,nvl(I.PAIDAMOUNT,0) as PAIDAMOUNT,btbamount(f.lcno) as btbamount,btbamounttk(f.lcno) as btbamounttk
  from T_YarnImpLC a,
T_YarnImpLCItems b, 
T_supplier c,
T_CURRENCY d,
T_LCInfo f,
T_client g,
T_LCBANK H,
T_BTBLCPAYMENT I
  where (pLCNumber is null or f.LCNo=pLCNumber) and
        a.ExpLCNo=f.LCNo and
        a.LCNo=b.LCNo and
        f.clientid=g.clientid and
        a.SupplierID=c.SupplierID and
        F.BANKID=H.BANKID(+) AND
	f.CURRENCYID=d.CURRENCYID AND 
	a.LCNo=i.lcno (+) and a.implctypeid=i.LCCATEGORY(+)
  group by F.RECEIVEDATE,f.BankLCno,g.ClientName,f.ReceiveDate,f.LCOrderAmt,f.LCOrderQty,
d.CurrencyName,H.BANKNAME, f.ConRate,a.BankLCNo,a.OpeningDate,c.SUPPLIERNAME,
I.IFDBCNO,I.IFDBCDATE,I.IFDBCAMOUNT,I.DUEDATE,I.PAYMENTDATE,I.PAIDAMOUNT,f.lcno;
End GetREPORTMasterLCfrm;
/



PROMPT CREATE OR REPLACE Procedure  158:: LC010LCExportPayment
CREATE OR REPLACE Procedure LC010LCExportPayment(
  data_cursor IN OUT pReturnData.c_Records,
 sDate IN VARCHAR2,
  eDate IN VARCHAR2,
  pLctype in Number
)
AS
  vSDate date;
  vEDate date;
BEGIN

  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  end if;
OPEN data_cursor  FOR
    SELECT C.BANKLCNO,B.EXPBILLAMT as invoicevalue,c.CLIENTID,d.clientname,a.PINVOICETDATE,
	c.EXPLCTYPEID,c.BANKID,e.bankname,c.LCEXPIRYDATE,             
		B.PAYRECEIVEAMT as receivedamt,  
		B.INVOICENO,B.INVOICEDATE
    FROM T_LCPAYMENTINFO A,T_LCPAYMENT B,T_LCINFO C,T_Client d,t_lcbank e	 	
    WHERE A.PID=B.SPID AND	
		B.LCNO=C.LCNO and
		c.clientid=d.clientid(+)	and
		c.bankid=e.bankid(+) and c.EXPLCTYPEID in (1,2) and (pLctype is null or c.EXPLCTYPEID=pLctype) and 
		a.PINVOICETDATE between decode(vSDate,null,'01-jan-2000',vSDate) and vEDate		
	order by C.BANKLCNO;
END LC010LCExportPayment; 
/



PROMPT CREATE OR REPLACE Procedure  159:: ShipmentTree
CREATE OR REPLACE Procedure ShipmentTree (
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


PROMPT CREATE OR REPLACE Procedure  160:: LcvoucherTree

CREATE OR REPLACE Procedure LcvoucherTree (
  io_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER, 
  sDate IN date,
  eDate IN date
)
AS
BEGIN

  if pQueryType=0 then
    OPEN io_cursor FOR
    select pid,refno from T_Lcvoucher
    where refdate>=SDate and refdate<=EDate 
    order by (refno) desc;

  elsif pQueryType=1 then
    OPEN io_cursor FOR    
    select pid,refno,refdate from T_Lcvoucher 
    where refdate>=SDate and refdate<=EDate 
    order by refdate desc, refno desc;

  end if;

END LcvoucherTree;
/


PROMPT CREATE OR REPLACE Procedure  161:: RmgProduction
CREATE OR REPLACE Procedure RmgProduction
(
  one_cursor IN OUT pReturnData.c_Records,
	pQueryType in Number,
  	pOrderno in number,
	sDate IN VARCHAR2,
  	eDate IN VARCHAR2  
)

AS
  	vSDate date;
  	vEDate date;
BEGIN

  	if not sDate is null then
    		vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  	end if;
  	if not eDate is null then
    		vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  	end if; 	


if(pQueryType=1) then
    open one_cursor for
    
 select 	A.STOCKTRANSDATE,		
		Nvl(sum(DECODE(b.GTRANSTYPEID,1,Quantity,0)),0) as SFabRQty,
		nvl(sum(DECODE(b.GTRANSTYPEID,2,nvl((quantity*GFCF),0))),0) as CuttingFQTy,
		nvl(sum(DECODE(b.GTRANSTYPEID,3,nvl((quantity*CGS),0))),0) as cuttingprod,
		nvl(sum(DECODE(b.GTRANSTYPEID,7,nvl((quantity*SGS),0))),0) as sewingprod,		
 		nvl(sum(DECODE(b.GTRANSTYPEID,14,nvl((quantity*FGS),0))),0) as Ironprod,		
 		nvl(sum(DECODE(b.GTRANSTYPEID,24,nvl((quantity*CTN),0))),0) as polyprod			
    from  
		T_GSTOCK a,
		T_GStockItems b,
		T_Size c,		
		t_unitofmeas d,	
		t_client e,
		t_gworkorder f,		
		T_GTransactionType g
    where
		a.stockid=b.stockid and					
		b.punitofmeasid=d.unitofmeasid(+) and		
		b.sizeid=c.sizeid  and
		b.GTRANSTYPEID=g.GTRANSACTIONTYPEID and
		b.orderno=f.gorderno and 
		f.clientid=e.clientid 
Group by		
    		A.STOCKTRANSDATE;
   
end if;
END RmgProduction;
/



PROMPT CREATE OR REPLACE Procedure  162:: LC009LCPAYMENT
CREATE OR REPLACE Procedure LC009LCPAYMENT(
  data_cursor IN OUT pReturnData.c_Records,
  pPID IN NUMBER 
) 
AS  
BEGIN  
OPEN data_cursor  FOR
    SELECT A.PAYMENTINVOICENO,A.PINVOICETDATE,A.PINVOICEVALUE,C.BANKLCNO,
        B.LCSTATUSID,B.LCRECEIVEDATE,B.SHIPMENTDATE,B.PARTYACCEPTDATE,B.SUBMITTEDTOBANKDATE,
		B.BANKACCEPTANCEDATE,B.DOCPURCHASEDATE,B.PAYREALISEDDATE,B.FDBC,B.IFDBP,B.EXPBILLAMT,             
		B.PAYRECEIVEAMT,B.PURCHASEDATE,B.LCAMOUNT,B.BTBLCAMOUNT,B.DFCAMOUNT,B.BUYERCOMMISION,         
		B.ERQACCOUNT,B.PARTYACCOUNT,B.PUREXCHRATE,B.AMOUNTTK,B.SSIACCOUNT,B.STEX,B.COMMISIONTK,            
		B.POSTAGECHARGE,B.FDRBTBACCOUNT,B.OURACCOUNT,B.FCC,B.PAYLESSTK,B.PAYLESSFC,B.RATE,B.STAMP,                  
		B.DISCOUNT,B.USANCEPERIOD,B.DUEDATE,B.TOTALINVVALUE,B.MARGIN,B.REFEREDSUNDRYAC,        
		B.ORDERNO,B.PACKINGCOST,B.INVOICENO,B.INVOICEDATE,B.PAYEXRATE 	   
    FROM T_LCPAYMENTINFO A,T_LCPAYMENT B,T_LCINFO C 	
    WHERE A.PID=B.SPID AND
        (pPID IS NULL OR A.PID=pPID) AND	
		B.LCNO=C.LCNO		  
	order by C.BANKLCNO;
END LC009LCPAYMENT; 
/



PROMPT CREATE OR REPLACE Procedure  163:: LC007ExpDocSbm
CREATE OR REPLACE Procedure LC007ExpDocSbm(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pLCno in NUMBER,
  pLCstatus in number,
  pSDate IN VARCHAR2, 
  pEDate IN VARCHAR2 
) 
AS 
  vSDate date;
  vEDate date; 
BEGIN 
  if not pSDate is null then
    vSDate := TO_DATE(pSDate, 'DD/MM/YYYY');
  end if;
  if not pEDate is null then
    vEDate := TO_DATE(pEDate, 'DD/MM/YYYY');
  end if;  
/* For Report STATEMENT OF EXPORT DOCUMENTS SUBMITTED TO BANK*/
if pQueryType=1 then
 OPEN data_cursor  FOR
    select A.IFDBP AS FDBC,A.INVOICENO,A.LCNO,A.EXPBILLAMT,A.PURCHASEDATE,C.CLIENTNAME,B.EXPLCTYPEID,
           B.LCMATURITYPERIOD,A.DUEDATE,A.PAYRECEIVEAMT,B.BANKLCNO,
           DECODE(B.EXPLCTYPEID,1,'EXPORT L/C',2,'CONTRACT L/C',3,'LOCAL L/C','') AS EXPLCTYPE		   
        from T_LCPAYMENT A,T_LCINFO B,T_CLIENT C
	    where A.LCNO=B.LCNO AND  
		      B.EXPLCTYPEID in (1,2) and
	         (pLCno IS NULL OR A.LCNO=pLCno) AND	
			 B.CLIENTID=C.CLIENTID(+) AND	
			 (pLCstatus IS NULL OR A.LCSTATUSID=pLCstatus)
	    order by A.LCNO;
elsif pQueryType=2 then
 OPEN data_cursor  FOR
    select A.FDBC,A.IFDBP,A.LCNO,A.EXPBILLAMT,A.PURCHASEDATE,C.CLIENTNAME,B.EXPLCTYPEID,A.TOTALINVVALUE AS INVOICEVALUE,
           B.LCMATURITYPERIOD,A.DUEDATE,A.PAYRECEIVEAMT,B.BANKLCNO,
           DECODE(B.EXPLCTYPEID,1,'EXPORT L/C',2,'CONTRACT L/C',3,'LOCAL L/C','') AS EXPLCTYPE		   
        from T_LCPAYMENT A,T_LCINFO B,T_CLIENT C
	    where A.LCNO=B.LCNO AND 
		      B.EXPLCTYPEID=3 and
	         (pLCno IS NULL OR A.LCNO=pLCno) AND	
			 B.CLIENTID=C.CLIENTID(+) AND	
			 (pLCstatus IS NULL OR A.LCSTATUSID=pLCstatus)
	    order by A.LCNO;
end if;
END LC007ExpDocSbm; 
/


PROMPT CREATE OR REPLACE Procedure  164:: LC13DeemedExport
CREATE OR REPLACE Procedure LC13DeemedExport
	(
	data_cursor IN OUT pReturnData.c_Records,
	pLCNumber IN NUMBER,
	sDate IN VARCHAR2,
    eDate IN VARCHAR2
	)	
	AS
  vSDate date;
  vEDate date;
	BEGIN

  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  end if;
	OPEN data_cursor FOR
	select F.RECEIVEDATE,f.BankLCno as MasterLC,f.ReceiveDate as MDate,f.LCORDERQTY,
	f.LCOrderAmt as MAmtFC,f.explctypeid,invoiceno,invoicedate,ExpBillAmt,FDBC,PurchaseDate,
	d.CurrencyName as CurName,f.ConRate as ConRate,LCMATURITYPERIOD,IFDBP,a.duedate as duedate,a.totalinvvalue as invoicevalue
	from   
	T_CURRENCY d,
	T_LCInfo f,
T_lcpayment a	
	where (pLCNumber is null or f.LCNo=pLCNumber) and  
        f.CURRENCYID=d.CURRENCYID AND  f.explctypeid=3 and a.lcno=f.lcno and
		F.RECEIVEDATE between decode(vSDate,null,'01-jan-2000',vSDate) and vEDate;	
End LC13DeemedExport;
/


PROMPT CREATE OR REPLACE Procedure  165:: ReportShipmentInfo	
CREATE OR REPLACE Procedure ReportShipmentInfo
	(
	data_cursor IN OUT pReturnData.c_Records,
	pEXPNO IN Varchar2,
	sDate IN VARCHAR2,
    eDate IN VARCHAR2,
	PLcno IN Number
	)	
	AS
  vSDate date;
  vEDate date;
	BEGIN

  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  end if;
	OPEN data_cursor FOR
	Select PID,EXPNO,EXPDATE,GOODSDESC,QUANTITYPCS,BLNO,BLDATE,INVOICENO,INVOICEDATE,SHIPPINBILLNO ,SHIPPINGBILLDATE,
	SHIPPINGBILLQTY,GSPNO,GSPDATE,GSPQTY ,INVOICEVALUE ,b.banklcno,orderno,b.BANKLCNO,b.LCMATURITYPERIOD,b.explctypeid,'01-jul-2009' as docsubdate,(DOCSUBDATE + b.LCMATURITYPERIOD) as duedate
from 
t_shipmentinfo a,
t_lcinfo b
where 
a.lcno=b.lcno and	
(pEXPNO is null or Expno=pEXPNO) and
(pLcno is null or a.lcno=pLcno) and b.explctypeid in(1,2) and
a.INVOICEDATE between decode(vSDate,null,'01-jan-2000',vSDate) and vEDate
order by expno;			
End ReportShipmentInfo;
/

PROMPT CREATE OR REPLACE Procedure  166:: ReportLcvoucher	
CREATE OR REPLACE Procedure ReportLcvoucher
	(
	data_cursor IN OUT pReturnData.c_Records,
	pvoucherno IN Number,
	pInwords in varchar2	
	)	
	AS
 
	BEGIN
	OPEN data_cursor FOR
	Select PID,REFNO,REFDATE,IBPNO,IBPAMOUNT,INTTACNO,INTTAMOUNT,CDAC,CDACAMOUNT,TOTALAMOUNT,GENERALACNO,CURRENTACNO,           
PONO,PODATE,COMPANYID,BANKID,COMMAC,COMMACAMOUNT,BILLAMOUNT,PURCHASEAMOUNTFC,PURCHASEAMOUNTTK,PURCHASEDATE,          
EXCHANGERATE,PTACNO,VOUCHERTYPE,PTAMMOUNT,b.description                
from 
t_lcvoucher a,
T_receipent b
where 
a.COMPANYID=b.RID(+) and
(pvoucherno is null or PID=pvoucherno) 
order by REFNO;			
End ReportLcvoucher;
/
	
PROMPT CREATE OR REPLACE Procedure  167:: MasterLCSummmary	
CREATE OR REPLACE Procedure MasterLCSummmary
	(
	data_cursor IN OUT pReturnData.c_Records,
	pLCNumber IN NUMBER,
	sDate IN VARCHAR2,
    eDate IN VARCHAR2
	)	
	AS
  vSDate date;
  vEDate date;
	BEGIN

  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  end if;
	OPEN data_cursor FOR
	select F.RECEIVEDATE,f.BankLCno as MasterLC,f.ReceiveDate as MDate,
	f.LCOrderAmt as MAmtFC,f.explctypeid,
	d.CurrencyName as CurName,f.ConRate as ConRate,
    ((select count(a.lcno) from T_AccImpLC a where a.explcno=f.lcno)+ 
	(select count(a.lcno) from T_AuxImpLC a where  a.explcno=f.lcno)+
	 (select count(a.lcno) from T_YarnImpLC a where a.explcno=f.lcno)) as nofobtblc,
	 (Nvl((select sum(valuefc) from T_AccImpLC a,T_AccImpLCItems b where a.lcno=b.lcno and a.explcno=f.lcno group by f.lcno),0)+ 
	Nvl((select sum(valuefc) from T_AuxImpLC a,T_AuxImpLCItems b where a.lcno=b.lcno and a.explcno=f.lcno group by f.lcno),0)+
	Nvl((select sum(valuefc) from T_YarnImpLC a,T_YarnImpLCItems b where a.lcno=b.lcno and a.explcno=f.lcno group by f.lcno),0)) as btbfc,
	Nvl((select sum(DFCAMOUNT) from t_lcpayment where lcno=f.lcno group by f.lcno),0) as btbpaid,
	Nvl((select sum(EXPBILLAMT) from t_lcpayment where lcno=f.lcno group by f.lcno),0) as expamount,
	Nvl((select sum(PAYRECEIVEAMT) from t_lcpayment where lcno=f.lcno group by f.lcno),0) as mpaymentrecved,
	(Nvl((select sum(Paidamount) from t_lcinfo a,T_AccImpLC b,T_btblcpayment c 
	where a.lcno=b.explcno and b.lcno=c.lcno and a.lcno=f.lcno group by f.lcno),0) +
	Nvl((select sum(Paidamount) from t_lcinfo a,T_AuxImpLC b,T_btblcpayment c 
	where a.lcno=b.explcno and b.lcno=c.lcno and a.lcno=f.lcno group by f.lcno),0) +
	Nvl((select sum(Paidamount) from t_lcinfo a,T_YarnImpLC b,T_btblcpayment c 
	where a.lcno=b.explcno and b.lcno=c.lcno and a.lcno=f.lcno group by f.lcno),0) )
	as BPaid
	from   
	T_CURRENCY d,
	T_LCInfo f	
	where (pLCNumber is null or f.LCNo=pLCNumber) and  
        f.CURRENCYID=d.CURRENCYID AND  f.explctypeid in(1,2) and
		F.RECEIVEDATE between decode(vSDate,null,'01-jan-2000',vSDate) and vEDate;	
End MasterLCSummmary;
/




	
PROMPT CREATE OR REPLACE Procedure  168:: GetREPORTMasterLCSummmary	
CREATE OR REPLACE Procedure GetREPORTMasterLCSummmary
	(
	data_cursor IN OUT pReturnData.c_Records,
	pLCNumber IN NUMBER
	)
  AS
	BEGIN
  OPEN data_cursor FOR
  select F.RECEIVEDATE,f.BankLCno as MasterLC,f.ReceiveDate as MDate,
  f.LCOrderAmt as MAmtFC,
  f.LCOrderAmt*f.ConRate as MAmtTK, 
  d.CurrencyName as CurName,f.ConRate as ConRate,
  lcrealisedamt(f.lcno) as ramount,
  lcbtbamount( f.lcno) as btbpaid,
  lcrealisedamtTk(f.lcno) as ramounttk,
  lcbtbamountTk( f.lcno) as btbpaidtk,
  (select SUM(BUYERCOMMISION*PUREXCHRATE) from t_lcpayment where lcno=f.lcno group by f.lcno) as bcomtk,
  (select SUM(ERQACCOUNT*PUREXCHRATE) from t_lcpayment where lcno=f.lcno group by f.lcno) as erqtk,
  (select SUM(SSIACCOUNT*PUREXCHRATE) from t_lcpayment where lcno=f.lcno group by f.lcno) as ssitk,
  (select SUM(Decode(POSTAGECHARGE,0,0,POSTAGECHARGE/PUREXCHRATE)) from t_lcpayment where lcno=f.lcno group by f.lcno) as postfc,
  (select SUM(Decode(FDRBTBACCOUNT,0,0,FDRBTBACCOUNT/PUREXCHRATE)) from t_lcpayment where lcno=f.lcno group by f.lcno) as fdrfc,
  (select SUM(Decode(STAMP,0,0,STAMP/PUREXCHRATE)) from t_lcpayment where lcno=f.lcno group by f.lcno) as stampfc,
  (select SUM(Decode(PACKINGCOST,0,0,PACKINGCOST/PUREXCHRATE)) from t_lcpayment where lcno=f.lcno group by f.lcno) as packfc,
  (select SUM(Decode(STEX,0,0,STEX/PUREXCHRATE)) from t_lcpayment where lcno=f.lcno group by f.lcno) as stexfc,
  (select SUM(Decode(COMMISIONTK,0,0,COMMISIONTK/PUREXCHRATE)) from t_lcpayment where lcno=f.lcno group by f.lcno) as commfc,
  (select SUM(Decode(OURACCOUNT,0,0,OURACCOUNT/PUREXCHRATE)) from t_lcpayment where lcno=f.lcno group by f.lcno) as Netactk,
  BTBLCAMOUNT,SUM(BUYERCOMMISION) AS Tbcom,SUM(ERQACCOUNT) as totralerq,sum(SSIACCOUNT) as totalssi,     
  sum(STEX) as totalstex,sum(COMMISIONTK) as tcomtk,sum(POSTAGECHARGE) as tpostcharge,sum(FDRBTBACCOUNT) as totalfdr,sum(STAMP) as totalstamp,sum(PACKINGCOST)  as totalpack ,sum(OURACCOUNT) as ourac      
  from   
  T_CURRENCY d,
  T_LCInfo f,
  T_Lcpayment a
  where (pLCNumber is null or f.LCNo=pLCNumber) and         
        a.LCNo=f.LCNo and   
        f.CURRENCYID=d.CURRENCYID AND  a.LCSTATUSID in(6) 
	Group by F.RECEIVEDATE,f.BankLCno,f.ReceiveDate,f.lcno,BTBLCAMOUNT,
  f.LCOrderAmt,
  f.LCOrderAmt*f.ConRate, 
  d.CurrencyName,f.ConRate;		
End GetREPORTMasterLCSummmary;
/




	
PROMPT CREATE OR REPLACE Procedure  169:: GetREPORTMasterLCPayment
CREATE OR REPLACE Procedure GetREPORTMasterLCPayment
(
  data_cursor IN OUT pReturnData.c_Records,
  pLCNumber IN NUMBER
  )
  AS
BEGIN
  OPEN data_cursor FOR
  select F.RECEIVEDATE,f.BankLCno as MasterLC,f.ReceiveDate as MDate,f.LCOrderAmt as MAmtFC,f.LCOrderAmt*f.ConRate as MAmtTK,
  f.ConRate as ConRate,c.INVOICENO,c.invoicedate,c.PAYRECEIVEAMT as payfc,(c.PAYRECEIVEAMT*PUREXCHRATE) as payTk 
  from     
  T_Lcpayment c,
  T_LCInfo f 
  where (pLCNumber is null or f.LCNo=pLCNumber) and 
        c.lcno=f.LCNo ; 
End GetREPORTMasterLCPayment;
/


PROMPT CREATE OR REPLACE Procedure  170:: GetRptLCSupplier	
CREATE OR REPLACE Procedure GetRptLCSupplier (
  data_cursor IN OUT pReturnData.c_Records,
  pLCNumber in number,
  pSupplierID IN NUMBER,
  sDate IN VARCHAR2,
  eDate IN VARCHAR2
)
AS
  vSDate date;
  vEDate date;
BEGIN
  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  end if;
  
  OPEN data_cursor FOR
  select f.BankLCno as MasterLC,f.ReceiveDate as MDate,a.BankLCNo as BLCNo,a.OpeningDate as LCDate,c.SUPPLIERNAME as Supplier,   
  b.Qty,b.UnitPrice,(b.Qty*b.UnitPrice) as Amount,b.TotCost as AmountTK,'Accessories' as impLCType,g.ITEM as description,d.CurrencyName 
  from T_AccImpLC a,T_AccImpLCItems b, T_supplier c,T_Currency d,T_LCInfo f,T_accessories g
  where (pLCNumber is null or a.LCNo=pLCNumber) and
        a.ExpLCNo=f.LCNo and 
        a.LCNo=b.LCNo and
		a.CURRENCYID=d.CURRENCYID and
		b.ACCESSORIESID=g.ACCESSORIESID and       
		(pSupplierID is null or a.SupplierID=pSupplierID) and
        a.SupplierID=c.SupplierID and
        a.OpeningDate between decode(vSDate,null,'01-jan-2000',vSDate) and vEDate  		
  UNION
  select f.BankLCno as MasterLC,f.ReceiveDate as MDate,a.BankLCNo as BLCNo,a.OpeningDate as LCDate,c.SUPPLIERNAME as Supplier,   
  b.Qty,b.UnitPrice,(b.Qty*b.UnitPrice) as Amount,b.TotCost as AmountTK,'Auxiliaries' as impLCType,g.AUXNAME as description,d.CurrencyName  
  from T_AuxImpLC a,T_AuxImpLCItems b, T_supplier c,T_Currency d,T_LCInfo f,t_auxiliaries g
  where (pLCNumber is null or a.LCNo=pLCNumber) and 
        a.ExpLCNo=f.LCNo and 
        a.LCNo=b.LCNo and 
		a.CURRENCYID=d.CURRENCYID and
        b.AUXID=g.AUXID and		
		(pSupplierID is null or a.SupplierID=pSupplierID) and
        a.SupplierID=c.SupplierID and
		a.OpeningDate between decode(vSDate,null,'01-jan-2000',vSDate) and vEDate  
  UNION
  select f.BankLCno as MasterLC,f.ReceiveDate as MDate,a.BankLCNo as BLCNo,a.OpeningDate as LCDate,c.SUPPLIERNAME as Supplier,   
  b.Qty,b.UnitPrice,(b.Qty*b.UnitPrice) as Amount,b.TotCost as AmountTK,'Yarn' as impLCType,g.YARNTYPE as description,d.CurrencyName  
  from T_YarnImpLC a,T_YarnImpLCItems b, T_supplier c,T_Currency d,T_LCInfo f,T_yarntype g
  where (pLCNumber is null or a.LCNo=pLCNumber) and 
        a.ExpLCNo=f.LCNo and 
        a.LCNo=b.LCNo and 
		a.CURRENCYID=d.CURRENCYID and
		b.YARNTYPEID=g.YARNTYPEID and
		(pSupplierID is null or a.SupplierID=pSupplierID) and		
        a.SupplierID=c.SupplierID and
		a.OpeningDate between decode(vSDate,null,'01-jan-2000',vSDate) and vEDate; 
End GetRptLCSupplier;
/


PROMPT CREATE OR REPLACE Procedure  171:: AL005ElectricityBillSum
CREATE OR REPLACE Procedure AL005ElectricityBillSum
(
  one_cursor IN OUT pReturnData.c_Records,  
  psSERIALNO number,
  peSERIALNO number,
  pBILLTYPE number
)
AS
BEGIN
    open one_cursor for
    select  PID,a.CUSTOMERID,CURRENTREADING,CURRENTREADINGDATE,USENCEUNIT,UNITRATE,ISSUEDATE,PAYMENTDATE,USENCECOST,             
 GOVTDUTY,SERVICECHARGE ,DEMANDCHARGE, VAT,round(DUEAMOUNT) as DUEAMOUNT,round(PAYABLEAMOUNT) as PAYABLEAMOUNT,
 round(TOTALAMOUNT) as TOTALAMOUNT,PAID,SERIALNO, a.EMPLOYEEID,BILLMONTH,b.OFFICESIZE,BMONTH,BYEAR,payableinwords,totalpayableinwords,             
b.MAINTENENCEACCOUNTS, PREVREADING,PREVDATE,PAIDAMOUNT,b.meterno,b.officeno ,b.name,c.employeename           
    from T_ElectricityBill a, T_AlliedCustomer b,T_employee c
    where a.CUSTOMERID=b.customerid and a.employeeid=c.employeeid and (SERIALNO between psSERIALNO and peSERIALNO) and
	BILLTYPE=pBILLTYPE
	Order by SERIALNO;   
END AL005ElectricityBillSum;
/


PROMPT CREATE OR REPLACE Procedure  172:: AL006AlliedStatement
CREATE OR REPLACE Procedure AL006AlliedStatement
(
  one_cursor IN OUT pReturnData.c_Records,
  sDate IN VARCHAR2,
  eDate IN VARCHAR2
)
AS
vSDate date;
vEDate date;

BEGIN
  if not sDate is null then
  vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
 end if;
 if not eDate is null then
  vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
 end if;

    open one_cursor for
select  bmonth,byear,sum(decode(billtype,1,PAYABLEAMOUNT)) as EPAYABLEAMOUNT,
sum(decode(billtype,2,PAYABLEAMOUNT)) as MPAYABLEAMOUNT,
sum(decode(billtype,1,TOTALAMOUNT)) as ETOTALAMOUNT,
sum(decode(billtype,2,TOTALAMOUNT)) as MTOTALAMOUNT,
Electricbillreceived( a.bmonth,a.byear) as Ereceived,
Maintenancebillreceived( a.bmonth,a.byear) as Mreceived
    from
   T_ElectricityBill a
    where
   (sDate is NULL or a.billmonth>=vSDate) and
   (eDate is NULL or a.billmonth<=vEDate)
 Group by  bmonth,byear
   ORDER BY bmonth,byear;
END AL006AlliedStatement;
/



PROMPT CREATE OR REPLACE Procedure  173:: G012Cutting
CREATE OR REPLACE Procedure G012Cutting
(
  data_cursor IN OUT pReturnData.c_Records,
  pStockID IN Number
)
AS
BEGIN
  OPEN data_cursor for
  select a.STOCKID,a.STOCKTRANSNO,a.STOCKTRANSDATE,c.CLIENTNAME,a.FWEIGHT,a.CUTWEIGHT,a.EFFICIENCY,     
		a.CUTPIECEREJECT,a.JHUTE,a.REMARKS,a.PONO,a.GATEPASSNO,e.DESCRIPTION as PRODHOUR,
		f.SUBCONNAME,b.SHADE,b.STYLENO,d.FABRICTYPE,g.SIZENAME,b.QUANTITY,h.UNITOFMEAS,
		getfncDispalyorder(b.ORDERNO) as orderno
  from T_GStock a,T_GstockItems b,T_Client c,T_Fabrictype d,T_PRODUCTIONHOUR e,T_Subcontractors f,
        T_Size g,T_UNITOFMEAS h 
  where a.STOCKID=b.STOCKID and
		a.CLIENTID=c.CLIENTID(+) and
		a.PRODHOUR=e.HID(+) and
		a.SUBCONID=f.SUBCONID(+) and
		b.FABRICTYPEID=d.FABRICTYPEID(+) and
		b.SIZEID=g.SIZEID(+) and
		b.PUNITOFMEASID=h.UNITOFMEASID(+) and
		a.STOCKID=pStockID
  ORDER BY b.GSTOCKITEMSL;
END G012Cutting;
/



PROMPT CREATE OR REPLACE Procedure  174:: G014Report
CREATE OR REPLACE Procedure G014Report (
  data_cursor IN OUT pReturnData.c_Records,
  pGStockId IN NUMBER
)
As
Begin
  OPEN data_cursor FOR
  select a.STOCKTRANSNO,a.STOCKTRANSDATE,b.LINENO,b.DISPLAYNO,b.SHADE,b.REMARKS,  
	b.STYLENO,c.SIZENAME,b.QUANTITY,d.UNITOFMEAS,getfncDispalyorder(b.ORDERNO)  as dorder 
  from T_Gstock a, T_Gstockitems b,T_Size c, T_Unitofmeas d
  where a.STOCKID=b.STOCKID and
        b.SIZEID=c.SIZEID and
		b.PUNITOFMEASID=d.UNITOFMEASID and
		a.STOCKID=pGStockId;
End G014Report;
/


PROMPT CREATE OR REPLACE Procedure  175 ::GetReportBudget
CREATE OR REPLACE Procedure GetReportBudget
(
  one_cursor IN OUT pReturnData.c_Records,
  pBUDGETID number
)
AS
BEGIN
    open one_cursor for
    Select  a.BUDGETID,a.BUDGETNO,getfncBOType(a.BUDGETID) as BNo,a.ORDERNO,a.ORDERREF,a.ORDERDESC,a.LCNO,a.LCRECEIVEDATE,
    a.LCEXPIRYDATE,a.SHIPMENTDATE,a.LCVALUE,a.QUANTITY,a.UNITQTY,a.UNITPRICE,a.BUDGETPREDATE,b.clientname,
	c.GDORDERNO,getfncDispalyorder(a.ORDERNO) as DOrder,a.complete,a.revision,a.postdate,a.ordertypeid,cadRefno,d.employeename,
	BugetworderRef(a.budgetid) as WorderRef,decode(a.revision,65,BREVCHECK(a.budgetno,a.ordertypeid),a.revision-66) as Budgetrevno
	from t_Budget a,t_client b,t_gworkorder c,t_employee d
	where a.clientid=b.clientid(+) and
	a.orderno=c.gorderno(+) and a.employeeid=d.employeeid(+) and
	a.budgetid=pBUDGETID;
END GetReportBudget;
/


PROMPT CREATE OR REPLACE Procedure  176 ::GetReportFc
CREATE OR REPLACE Procedure GetReportFc
(
  one_cursor IN OUT pReturnData.c_Records,
  pBUDGETID number
)
AS
BEGIN
    open one_cursor for
    Select a.STAGEID,a.GSM,a.CONSUMPTIONPERDOZ,a.NETCONSUMPTIONPERDOZ,a.TOTALCONSUMPTION,d.SHADEGROUPNAME,
    a.WASTAGE,b.stagename,c.fabrictype,'' as yarntype,a.rpercent,a.pcs,a.styleno,
	((SELECT SUM(CONSUMPTIONPERDOZ) FROM T_FabricConsumption x WHERE x.BUDGETID=a.BUDGETID GROUP BY x.BUDGETID)/(12*e.UNITQTY)) AS WeightPPcs
	from T_FabricConsumption a,T_BudgetStages b, T_Fabrictype c,T_Shadegroup d,T_Budget e
	where a.STAGEID=b.STAGEID and a.fabrictypeid=c.fabrictypeid(+) and 
	a.SHADEGROUPID=d.SHADEGROUPID(+) and a.BUDGETID=e.BUDGETID and 
	a.budgetid=pBUDGETID
	order by a.pid,a.fabrictypeid;
END GetReportFc;
/




PROMPT CREATE OR REPLACE Procedure  177 ::GetReportYC
Create or Replace Procedure GetReportYC
(
  one_cursor IN OUT pReturnData.c_Records,
  pBUDGETID number
)
AS
tyqty  number;
BEGIN
	select (sum(totalcost)) into tyqty from t_yarncost where budgetid=pBUDGETID;
    open one_cursor for
    select a.STAGEID,a.QUANTITY,a.fabrictypeid,a.ppid,a.UNITPRICE,a.TOTALCOST,a.USES,a.QTY as ycqty,a.PROCESSLOSS,
		b.stagename,c.YARNTYPE,d.QUANTITY as mqty,d.UNITPRICE as munitp,d.LCVALUE,tyqty,e.yarncount,f.fabrictype
		from t_Yarncost a,t_budgetstages b, t_Yarntype c,t_budget d,t_yarncount e,t_fabrictype f,t_fabricconsumption g
		where a.STAGEID=b.STAGEID and a.YARNTYPEID=c.YARNTYPEID
			and a.budgetid=d.budgetid and g.fabrictypeid=f.fabrictypeid and a.ppid=g.pid and
			a.yarncountid=e.yarncountid and  a.budgetid=pBUDGETID
		order by a.PPID,a.fabrictypeid;
END GetReportYC;
/



PROMPT CREATE OR REPLACE Procedure  178 ::GetReportKDF
Create or Replace Procedure GetReportKDF
(
	one_cursor IN OUT pReturnData.c_Records,
	pBUDGETID number
)
AS
	tyc number;
	tqty number;
	tqty1 number;
	tqty2 number;
	tqty3 number;
	tq number;
	ts number;
	tqq number;
	fsqty number;
	unitp number(10,4);
	fsunit number(10,4);
	fmunit number(12,4);
	tmqty number;
	tmvalue number(15,4);
	id number;
	id1 number;
	id2 number;
	id3 number;
	id4 number;
	id5 number;
	id6 number;
	id7 number;
	id8 number;
BEGIN
	select (quantity) into tmqty from t_budget where budgetid=pBUDGETID;
	select (LCVALUE) into tmvalue from t_budget where budgetid=pBUDGETID;
	select count(*) into id1 from t_fabricconsumption where budgetid=pBUDGETID;
	if(id1=0) then
		tq:=0.0;
	else
		select nvl((sum(TOTALCONSUMPTION)),Null) into tq from t_Fabricconsumption where budgetid=pBUDGETID;
	end if;
	select count(*) into id2 from t_KDFcost where budgetid=pBUDGETID and stageid in(3,4,5);
	if(id2=0) then
		ts:=0.0;
	else
		select Nvl((sum(TOTALCOST)),0) into ts from t_KDFcost where budgetid=pBUDGETID and stageid in(3,4,5);
	end if;
	select count(*) into id3 from t_Yarncost where budgetid=pBUDGETID;
	if(id3=0) then
		tyc:=0.0;
	else
		select Nvl((sum(TOTALCOST)),0) into tyc from t_Yarncost where budgetid=pBUDGETID;
	end if;
	tqq:=ts+tyc;
	unitp:=tqq/tq;
	select count(*) into id4  from t_KDFcost where budgetid=pBUDGETID and stageid=3;
	if(id4=0) then
		tqty:=0.0;
	else
		select Nvl((sum(TOTALCOST)),0) into tqty from t_KDFcost where budgetid=pBUDGETID and stageid=3;
	end if;
	select count(*) into id5  from t_KDFcost where budgetid=pBUDGETID and stageid=4;
	if(id5=0) then
		tqty1:=0.0;
	else
		select Nvl((sum(TOTALCOST)),0) into tqty1 from t_KDFcost where budgetid=pBUDGETID and stageid=4;
	end if;
	select count(*) into id6  from t_KDFcost where budgetid=pBUDGETID and stageid=5;
	if(id6=0) then
		tqty2:=0.0;
	else
		select Nvl((sum(TOTALCOST)),0) into tqty2 from t_KDFcost where budgetid=pBUDGETID and stageid=5;
	end if;
	select count(*) into id7  from t_KDFcost where budgetid=pBUDGETID and stageid=6;
	if(id7=0) then
		tqty3:=0.0;
	else
		select Nvl((sum(TOTALCOST)),0) into tqty3 from t_KDFcost where budgetid=pBUDGETID and stageid=6;
	end if;
	select count(*) into id from t_KDFcost where budgetid=pBUDGETID and stageid=6;
	if(id=0) then
		fmunit:=0.0;
	else
		select unitprice into fmunit from t_KDFcost where budgetid=pBUDGETID and stageid=6;
	end if;
	fsqty:=tqq+tqty3;
	fsunit:=unitp+fmunit;
	select count(PPID) into id8 from t_KDFcost where budgetid=pBUDGETID and stageid=4;
	if(id8<>0) then
	open one_cursor for
		select 	a.STAGEID,a.PARAMID, a.QUANTITY,a.UNITPRICE,TOTALCOST,g.unitofmeas,e.SHADEGROUPID,
			b.stagename,c.PARAMETERNAME,tqty,tqty1,tqty2,tqty3,tyc,d.quantity as mqty,d.lcvalue as mamount,
			f.fabrictype
		from t_kdfcost a, t_budgetstages b, t_budgetparameter c, t_budget d,
			t_fabricconsumption e, t_fabrictype f, t_unitofmeas g, t_shadegroup h
		where  a.STAGEID=b.STAGEID and
    		a.budgetid=d.budgetid and 
			a.ppid=e.pid(+) and 
			e.fabrictypeid=f.fabrictypeid and
			a.paramid=c.paramid and 
			a.unit=g.unitofmeasid(+) and
			e.SHADEGROUPID=h.SHADEGROUPID(+) and
			a.budgetid=pBUDGETID and a.stageid in(3,4) 
		union
		select 	a.STAGEID,a.PARAMID, a.QUANTITY,a.UNITPRICE,TOTALCOST,'' as unitofmeas,500 as SHADEGROUPID,
			b.stagename,c.PARAMETERNAME,tqty,tqty1,tqty2,tqty3,tyc,d.quantity as mqty,d.lcvalue as mamount,
			'' as fabrictype
		from  t_kdfcost a, t_budgetstages b, t_budgetparameter c, t_budget d
		where a.STAGEID=b.STAGEID and
    		a.budgetid=d.budgetid and
			a.paramid=c.paramid and
			a.budgetid=pBUDGETID and a.stageid=5
		union
		select 	distinct 111 as STAGEID,0 as PARAMID, tq as QUANTITY ,unitp as UNITPRICE,tqq as TOTALCOST,'' as unitofmeas,
			500 as SHADEGROUPID,'Total Fabric Cost' as stagename,'' as PARAMETERNAME,0 as tqty,0 as tqty1,0 as tqty2,
			0 as tqty3,0 as tyc,tmqty as mqty,tmvalue as mamount,'' as fabrictype
		from  t_kdfcost a, t_budgetstages b, t_budgetparameter c, t_budget d
		where a.STAGEID=b.STAGEID and
    		a.budgetid=d.budgetid and
			a.paramid=c.paramid and
    		a.UNITPRICE<>0.00
 union
   select 	a.STAGEID,a.PARAMID, a.QUANTITY,a.UNITPRICE,TOTALCOST,'' as unitofmeas,500 as SHADEGROUPID,
   		b.stagename,c.PARAMETERNAME,tqty,tqty1,tqty2,tqty3,tyc,d.quantity as mqty,d.lcvalue as mamount,
		'' as fabrictype
   from 
		t_kdfcost a,
		t_budgetstages b, 
		t_budgetparameter c,
		t_budget d
   where 
		a.STAGEID=b.STAGEID and
    		a.budgetid=d.budgetid and
  		a.paramid=c.paramid and
   		a.budgetid=pBUDGETID and a.stageid=6
  union
	SELECT  6 as STAGEID,b.PARAMID as PARAMID, 0 as QUANTITY ,0 as UNITPRICE,0 as TOTALCOST,'' as unitofmeas,
		500 as SHADEGROUPID,'Fabric Mark up' as stagename,c.PARAMETERNAME as PARAMETERNAME,0 as tqty,0 as tqty1,
		0 as tqty2,0 as tqty3,0 as tyc,tmqty  as mqty,tmvalue as mamount,'' as fabrictype
  FROM 		
		T_BUDGETSTAGEPARAMETER b,
		t_budgetparameter c
 WHERE 		b.PARAMID NOT IN(SELECT PARAMID FROM t_kdfcost WHERE  BUDGETID=pBUDGETID AND STAGEID=6) and b.paramid=c.paramid and stageid=6

 union
    select 	555 as STAGEID,0 as PARAMID, 0 as QUANTITY ,fsunit as UNITPRICE,fsqty as TOTALCOST,'' as unitofmeas,
		500 as SHADEGROUPID,'Fabric Selling Price' as stagename,'' as PARAMETERNAME,0 as tqty,0 as tqty1,0 as tqty2,
		0 as tqty3,0 as tyc,tmqty as mqty,tmvalue as mamount,'' as fabrictype
   from 
		t_kdfcost a,
		t_budgetstages b, 
		t_budgetparameter c,
		t_budget d
   where 	a.STAGEID=b.STAGEID and
    		a.budgetid=d.budgetid and
   		a.paramid=c.paramid ; 
else
open one_cursor for

  select 	a.STAGEID,a.PARAMID, a.QUANTITY,a.UNITPRICE,TOTALCOST,g.unitofmeas,e.SHADEGROUPID,
   		b.stagename,c.PARAMETERNAME,tqty,tqty1,tqty2,tqty3,tyc,d.quantity as mqty,d.lcvalue as mamount,
		f.fabrictype
   from 	
		t_kdfcost a,
		t_budgetstages b, 
		t_budgetparameter c,
		t_budget d,
		t_fabricconsumption e,
		t_fabrictype f,
		t_unitofmeas g,
		t_shadegroup h
   where 
		a.STAGEID=b.STAGEID and
    		a.budgetid=d.budgetid and 
		a.ppid=e.pid(+) and 
		e.fabrictypeid=f.fabrictypeid and
   		a.paramid=c.paramid 
		and a.unit=g.unitofmeasid(+) and
		e.SHADEGROUPID=h.SHADEGROUPID(+) and
   		a.budgetid=pBUDGETID and a.stageid=3

  union
    select 	a.STAGEID,a.PARAMID, a.QUANTITY,a.UNITPRICE,TOTALCOST,'' as unitofmeas,500 as SHADEGROUPID,
  		 b.stagename,c.PARAMETERNAME,tqty,tqty1,tqty2,tqty3,tyc,d.quantity as mqty,d.lcvalue as mamount,
		'' as fabrictype
   from 
		t_kdfcost a,
		t_budgetstages b, 
		t_budgetparameter c,
		t_budget d
   where 
		a.STAGEID=b.STAGEID and
    		a.budgetid=d.budgetid and
   		a.paramid=c.paramid and
   		a.budgetid=pBUDGETID and a.stageid in(4,5)
  union
    select 	distinct 111 as STAGEID,0 as PARAMID, tq as QUANTITY ,unitp as UNITPRICE,tqq as TOTALCOST,'' as unitofmeas,
		500 as SHADEGROUPID,'Total Fabric Cost' as stagename,'' as PARAMETERNAME,0 as tqty,0 as tqty1,0 as tqty2,
		0 as tqty3,0 as tyc,tmqty as mqty,tmvalue as mamount,'' as fabrictype
   from 	
		t_kdfcost a,
		t_budgetstages b, 
		t_budgetparameter c,
		t_budget d
   where 	
		a.STAGEID=b.STAGEID and
    		a.budgetid=d.budgetid and
  		a.paramid=c.paramid and
    		a.UNITPRICE<>0.00
 union
   select 	a.STAGEID,a.PARAMID, a.QUANTITY,a.UNITPRICE,TOTALCOST,'' as unitofmeas,500 as SHADEGROUPID,
   		b.stagename,c.PARAMETERNAME,tqty,tqty1,tqty2,tqty3,tyc,d.quantity as mqty,d.lcvalue as mamount,
		'' as fabrictype
   from 
		t_kdfcost a,
		t_budgetstages b, 
		t_budgetparameter c,
		t_budget d
   where 
		a.STAGEID=b.STAGEID and
    		a.budgetid=d.budgetid and
  		a.paramid=c.paramid and
   		a.budgetid=pBUDGETID and a.stageid=6
  union
	SELECT  6 as STAGEID,b.PARAMID as PARAMID, 0 as QUANTITY ,0 as UNITPRICE,0 as TOTALCOST,'' as unitofmeas,
		500 as SHADEGROUPID,'Fabric Mark up' as stagename,c.PARAMETERNAME as PARAMETERNAME,0 as tqty,0 as tqty1,
		0 as tqty2,0 as tqty3,0 as tyc,tmqty  as mqty,tmvalue as mamount,'' as fabrictype
  FROM 		
		T_BUDGETSTAGEPARAMETER b,
		t_budgetparameter c
 WHERE 		b.PARAMID NOT IN(SELECT PARAMID FROM t_kdfcost WHERE  BUDGETID=pBUDGETID AND STAGEID=6) and b.paramid=c.paramid and stageid=6

 union
    select 	555 as STAGEID,0 as PARAMID, 0 as QUANTITY ,fsunit as UNITPRICE,fsqty as TOTALCOST,'' as unitofmeas,
		500 as SHADEGROUPID,'Fabric Selling Price' as stagename,'' as PARAMETERNAME,0 as tqty,0 as tqty1,0 as tqty2,
		0 as tqty3,0 as tyc,tmqty as mqty,tmvalue as mamount,'' as fabrictype
   from 
		t_kdfcost a,
		t_budgetstages b, 
		t_budgetparameter c,
		t_budget d
   where 	a.STAGEID=b.STAGEID and
    		a.budgetid=d.budgetid and
   		a.paramid=c.paramid ; 
end if;

END GetReportKDF;
/



PROMPT CREATE OR REPLACE Procedure  179 ::GetReportGarments
Create or Replace Procedure GetReportGarments
(
  one_cursor IN OUT pReturnData.c_Records,
  pBUDGETID number
)
AS
tmqty number;
tfmqty number;
munit number(10,4);
mlcvalue number;
tgac number;
tgem number;
taqty number;
temqty number;
tcmqty number;
tgmqty number;
toqty number;
tgcqty number;
gstqty number;
unit number(10,2);
fsunit number(10,2);
fmunit number(10,2);
tfsqty number;
tfscost Number;
tgscost Number;
tordercost number;
tprofit number;
tyc number;

id number;
id1 number;
id2 number;
id3 number;
id4 number;
id5 number;
id6 number;
id7 number;


BEGIN
select QUANTITY into tmqty from t_budget
where budgetid=pBUDGETID;
select LCVALUE into mlcvalue from t_budget
where budgetid=pBUDGETID;
select UNITPRICE into munit from t_budget
where budgetid=pBUDGETID;

select count(*) into id6 from t_Yarncost where budgetid=pBUDGETID;
if(id6=0) then
tyc:=0.0;
else
select Nvl((sum(TOTALCOST)),0) into tyc from t_Yarncost where budgetid=pBUDGETID;
end if;



select count(*) into id5 from t_kdfcost
where budgetid=pBUDGETID and stageid in(3,4,5,6);
if(id5=0) then
tfsqty:=0.0;
else
select Nvl((sum(TOTALCOST)),0) into tfsqty from t_kdfcost
where budgetid=pBUDGETID and stageid in(3,4,5,6);
end if;

select count(*) into id7 from t_kdfcost
where budgetid=pBUDGETID and stageid=6;
if(id7=0) then
tfmqty:=0.0;
else
select Nvl((sum(TOTALCOST)),0) into tfmqty from t_kdfcost
where budgetid=pBUDGETID and stageid=6;
end if;


tfscost:=tyc+tfsqty;


select count(*) into id4 from t_garmentscost
where budgetid=pBUDGETID and stageid=7;
if(id4=0) then
taqty:=0.0;
else
select nvl((sum(TOTALCOST)),0) into taqty from t_garmentscost
where budgetid=pBUDGETID and stageid=7;
end if;


select count(*) into id from t_garmentscost
where budgetid=pBUDGETID and stageid=8;
if(id=0) then
temqty:=0.0;
else
select Nvl((sum(TOTALCOST)),0) into temqty from t_garmentscost
 where budgetid=pBUDGETID and stageid=8;
end if;

select count(*) into id1 from t_garmentscost
where budgetid=pBUDGETID and stageid=9;
if(id1=0) then
tcmqty:=0.0;
else
select Nvl((sum(TOTALCOST)),0) into tcmqty from t_garmentscost
 where budgetid=pBUDGETID and stageid=9;
end if;

select count(*) into id2 from t_garmentscost
where budgetid=pBUDGETID and stageid=10;
if(id2=0) then
tgmqty:=0.0;
else
select Nvl((sum(TOTALCOST)),0) into tgmqty from t_garmentscost
 where budgetid=pBUDGETID and stageid=10;
end if;

select count(*) into id3 from t_garmentscost
where budgetid=pBUDGETID and stageid=11;
if(id3=0) then
toqty:=0.0;
else
select Nvl((sum(TOTALCOST)),0) into toqty from t_garmentscost
where budgetid=pBUDGETID and stageid=11;
end if;



tgcqty:=taqty+temqty+tcmqty+toqty;
gstqty:=taqty+temqty+tcmqty+toqty+tgmqty;

tgscost:=gstqty+toqty;

tordercost:=tgcqty+tfscost-tfmqty;

tprofit:=mlcvalue-tordercost;

    open one_cursor for
    select a.ACCESSORIESID,a.STAGEID,a.PARAMID,a.SUPPLIERID,0 as subconid,'' as subconname,g.suppliername,a.CONSUMPTION,a.WASTAGE,a.CONSUMPTIONPERDOZ,                  a.QUNATITY,a.QTY,a.UNITPRICE,TOTALCOST,b.stagename,f.ITEM as PARAMETERNAME,taqty,temqty,
   tcmqty,tgmqty,toqty,d.QUANTITY as mqty,d.UNITPRICE as munitp,d.LCVALUE,e.UNITOFMEAS
   from t_garmentscost a,t_budgetstages b,t_budget d,t_unitofmeas e,t_accessories f,t_supplier g
   where a.STAGEID=b.STAGEID and a.unitofmeasid=e.unitofmeasid(+) and  a.ACCESSORIESID=f.ACCESSORIESID and a.supplierid=g.supplierid(+)
   and a.budgetid=pBUDGETID and a.BUDGETID=d.BUDGETID and a.PARAMID is Null
union
    select a.ACCESSORIESID,a.STAGEID,a.PARAMID,0 as SUPPLIERID,a.subconid as subconid ,f.subconname as subconname ,'' as suppliername,0 as CONSUMPTION,0 as wastage,a.CONSUMPTIONPERDOZ,               a.QUNATITY,a.QTY,a.UNITPRICE,TOTALCOST,b.stagename,c.PARAMETERNAME,taqty,temqty,
  tcmqty,tgmqty,toqty,d.QUANTITY as mqty,d.UNITPRICE as munitp,d.LCVALUE,'' as UNITOFMEAS
   from t_garmentscost a,t_budgetstages b, t_budgetparameter c,t_budget d,t_unitofmeas e,t_subcontractors f
   where a.STAGEID=b.STAGEID and a.paramid=c.paramid(+) and c.unitofmeasid=e.unitofmeasid(+)
   and a.budgetid=pBUDGETID and a.BUDGETID=d.BUDGETID and a.stageid=8 and a.subconid=f.subconid(+)
union
    select a.ACCESSORIESID,a.STAGEID,a.PARAMID,0 as SUPPLIERID,0 as subconid,'' as subconname,'' as suppliername,0 as CONSUMPTION,0 as wastage,a.CONSUMPTIONPERDOZ,               a.QUNATITY,a.QTY,a.UNITPRICE,TOTALCOST,b.stagename,c.PARAMETERNAME,taqty,temqty,
  tcmqty,tgmqty,toqty,d.QUANTITY as mqty,d.UNITPRICE as munitp,d.LCVALUE,'' as UNITOFMEAS
   from t_garmentscost a,t_budgetstages b, t_budgetparameter c,t_budget d,t_unitofmeas e
   where a.STAGEID=b.STAGEID and a.paramid=c.paramid and c.unitofmeasid=e.unitofmeasid
   and a.budgetid=pBUDGETID and a.BUDGETID=d.BUDGETID and a.stageid=9
union
    select 0 as ACCESSORIESID,500 as STAGEID,0 as PARAMID,0 as SUPPLIERID,0 as subconid,'' as subconname,'' as suppliername,0 as CONSUMPTION,0 as wastage,0 as CONSUMPTIONPERDOZ,0 as QUNATITY,'' as QTY,0 as UNITPRICE,tgcqty as TOTALCOST,'Total Garments Cost' as stagename,'' as PARAMETERNAME,0 as taqty,0 as temqty,
 0 as tcmqty,0 as tgmqty,0 as toqty,tmqty as mqty,munit as  munitp,mlcvalue as LCVALUE,'' as UNITOFMEAS
   from t_garmentscost a,t_budgetstages b, t_budgetparameter c,t_budget d,t_unitofmeas e
   where a.STAGEID=b.STAGEID and a.paramid=c.paramid and c.unitofmeasid=e.unitofmeasid
   and a.BUDGETID=d.BUDGETID and  a.UNITPRICE<>0.00
union
select a.ACCESSORIESID,a.STAGEID,a.PARAMID,0 as SUPPLIERID,0 as subconid,'' as subconname,'' as suppliername,0 as CONSUMPTION,0 as wastage,a.CONSUMPTIONPERDOZ,             a.QUNATITY,a.QTY,a.UNITPRICE,TOTALCOST,b.stagename,c.PARAMETERNAME,taqty,temqty,
tcmqty,tgmqty,toqty,d.QUANTITY as mqty,d.UNITPRICE as munitp,d.LCVALUE,'' as UNITOFMEAS
   from t_garmentscost a,t_budgetstages b, t_budgetparameter c,t_budget d,t_unitofmeas e
   where a.STAGEID=b.STAGEID and a.paramid=c.paramid and c.unitofmeasid=e.unitofmeasid
   and a.budgetid=pBUDGETID and a.BUDGETID=d.BUDGETID and a.stageid=10
union
SELECT 0 as ACCESSORIESID,10 as STAGEID,b.PARAMID as PARAMID,0 as SUPPLIERID,0 as subconid,'' as subconname,'' as suppliername,0 as CONSUMPTION,0 as wastage, 0 as CONSUMPTIONPERDOZ,0 as QUNATITY,'' as QTY,0 as UNITPRICE,0 as TOTALCOST,'Garments Mark up ' as stagename,c.parametername as PARAMETERNAME,0 as taqty,0 as temqty,
 0 as tcmqty,0 as tgmqty,0 as toqty,tmqty as mqty,munit as munitp,mlcvalue as LCVALUE,'' as UNITOFMEAS
FROM T_BUDGETSTAGEPARAMETER b,t_budgetparameter c
 WHERE b.PARAMID NOT IN(SELECT PARAMID FROM t_garmentscost WHERE  BUDGETID=pBUDGETID AND STAGEID=10) and b.paramid=c.paramid and stageid=10
union
    select 0 as ACCESSORIESID,1000 as STAGEID,0 as PARAMID,0 as SUPPLIERID,0 as subconid,'' as subconname,'' as suppliername,0 as CONSUMPTION,0 as wastage,0 as CONSUMPTIONPERDOZ,0 as QUNATITY,'' as QTY,0 as UNITPRICE,gstqty as TOTALCOST,'Garments Selling Price ' as stagename,'' as PARAMETERNAME,0 as taqty,0 as temqty,
 0 as tcmqty,0 as tgmqty,0 as toqty,tmqty as mqty,munit as munitp,mlcvalue as LCVALUE,'' as UNITOFMEAS
   from t_garmentscost a,t_budgetstages b, t_budgetparameter c,t_budget d,t_unitofmeas e
   where a.STAGEID=b.STAGEID and a.paramid=c.paramid and c.unitofmeasid=e.unitofmeasid
   and a.budgetid=pBUDGETID and a.BUDGETID=d.BUDGETID
union
select a.ACCESSORIESID,a.STAGEID,a.PARAMID,0 as SUPPLIERID,0 as subconid,'' as subconname,'' as suppliername,0 as CONSUMPTION,0 as wastage,a.CONSUMPTIONPERDOZ,             a.QUNATITY,a.QTY,a.UNITPRICE,TOTALCOST,b.stagename,c.PARAMETERNAME,taqty,temqty,
tcmqty,tgmqty,toqty,d.QUANTITY as mqty,d.UNITPRICE as munitp,d.LCVALUE,'' as UNITOFMEAS
   from t_garmentscost a,t_budgetstages b, t_budgetparameter c,t_budget d,t_unitofmeas e
   where a.STAGEID=b.STAGEID and a.paramid=c.paramid and c.unitofmeasid=e.unitofmeasid
   and a.budgetid=pBUDGETID and a.BUDGETID=d.BUDGETID and a.stageid=11 and a.TOTALCOST<>0.00
union
    select 0 as ACCESSORIESID,2000 as STAGEID,0 as PARAMID,0 as SUPPLIERID,0 as subconid,'' as subconname,'' as suppliername,0 as CONSUMPTION,0 as wastage,0 as CONSUMPTIONPERDOZ,0 as QUNATITY,'' as QTY,0 as UNITPRICE,tordercost as TOTALCOST,'Total Order Cost ' as stagename,'' as PARAMETERNAME,0 as taqty,0 as temqty,
 0 as tcmqty,0 as tgmqty,0 as toqty,tmqty as mqty,munit as munitp,mlcvalue as LCVALUE,'' as UNITOFMEAS
   from t_garmentscost a,t_budgetstages b, t_budgetparameter c,t_budget d,t_unitofmeas e
   where a.STAGEID=b.STAGEID and a.paramid=c.paramid and c.unitofmeasid=e.unitofmeasid
   and a.BUDGETID=d.BUDGETID
union
    select 0 as ACCESSORIESID,3000 as STAGEID,0 as PARAMID,0 as SUPPLIERID,0 as subconid,'' as subconname,'' as suppliername,0 as CONSUMPTION,0 as wastage,0 as CONSUMPTIONPERDOZ,0 as QUNATITY,'' as QTY,0 as UNITPRICE,tprofit as TOTALCOST,'Reserved Fund/Profit' as stagename,'' as PARAMETERNAME,0 as taqty,0 as temqty,
 0 as tcmqty,0 as tgmqty,0 as toqty,tmqty as mqty,munit as munitp,mlcvalue as LCVALUE,'' as UNITOFMEAS
   from t_garmentscost a,t_budgetstages b, t_budgetparameter c,t_budget d,t_unitofmeas e
   where a.STAGEID=b.STAGEID and a.paramid=c.paramid and c.unitofmeasid=e.unitofmeasid
   and a.BUDGETID=d.BUDGETID
  order by ACCESSORIESID;

END GetReportGarments;
/



PROMPT CREATE OR REPLACE Procedure  180 ::GetReportFS
Create or Replace Procedure GetReportFS
(
  one_cursor IN OUT pReturnData.c_Records,
  pBUDGETID number
)
AS
tmqty number;
tfmqty number;
munit number(10,4);
mlcvalue number;
tgac number;
tgem number;
taqty number;
temqty number;
tcmqty number;
tgmqty number;
toqty number;
tgcqty number;
gstqty number;
unit number(10,2);
fsunit number(10,2);
fmunit number(10,2);
tfsqty number;
tfscost Number;
tordercost number;
tprofit number;
tyc number;

id number;
id3 number;
id5 number;
id6 number;


BEGIN
select QUANTITY into tmqty from t_budget
where budgetid=pBUDGETID;
select LCVALUE into mlcvalue from t_budget
where budgetid=pBUDGETID;
select UNITPRICE into munit from t_budget
where budgetid=pBUDGETID;

select count(*) into id6 from t_Yarncost where budgetid=pBUDGETID;
if(id6=0) then
tyc:=0.0;
else
select (sum(TOTALCOST)) into tyc from t_Yarncost where budgetid=pBUDGETID;
end if;



select count(*) into id5 from t_kdfcost
where budgetid=pBUDGETID and stageid in(3,4,5);
if(id5=0) then
tfsqty:=0.0;
else
select (sum(TOTALCOST)) into tfsqty from t_kdfcost
where budgetid=pBUDGETID and stageid in(3,4,5);
end if;

tfscost:=tyc+tfsqty;

select count(*) into id3 from t_garmentscost
where budgetid=pBUDGETID and stageid=11;
if(id3=0) then
toqty:=0.0;
else
select (sum(TOTALCOST)) into toqty from t_garmentscost
where budgetid=pBUDGETID and stageid=11;
end if;



tgcqty:=toqty;

tordercost:=tgcqty+tfscost;

tprofit:=mlcvalue-tordercost;

open one_cursor for
 
select a.STAGEID,a.PARAMID,0 as CONSUMPTION,0 as wastage,a.CONSUMPTIONPERDOZ, a.QUNATITY,a.QTY,a.UNITPRICE,TOTALCOST,b.stagename,c.PARAMETERNAME,taqty,temqty,
tcmqty,tgmqty,toqty,d.QUANTITY as mqty,d.UNITPRICE as munitp,d.LCVALUE,'' as UNITOFMEAS
   from t_garmentscost a,t_budgetstages b, t_budgetparameter c,t_budget d,t_unitofmeas e
   where a.STAGEID=b.STAGEID and a.paramid=c.paramid and c.unitofmeasid=e.unitofmeasid
   and a.budgetid=pBUDGETID and a.BUDGETID=d.BUDGETID and a.stageid=11
union
    select 2000 as STAGEID,0 as PARAMID,0 as CONSUMPTION,0 as wastage,0 as CONSUMPTIONPERDOZ,0 as QUNATITY,'' as QTY,0 as UNITPRICE,tordercost as TOTALCOST,'Total Order Cost ' as stagename,'' as PARAMETERNAME,0 as taqty,0 as temqty,
 0 as tcmqty,0 as tgmqty,0 as toqty,tmqty as mqty,munit as munitp,mlcvalue as LCVALUE,'' as UNITOFMEAS
   from t_garmentscost a,t_budgetstages b, t_budgetparameter c,t_budget d,t_unitofmeas e
   where a.STAGEID=b.STAGEID and a.paramid=c.paramid and c.unitofmeasid=e.unitofmeasid
   and a.BUDGETID=d.BUDGETID
union
    select 3000 as STAGEID,0 as PARAMID,0 as CONSUMPTION,0 as wastage,0 as CONSUMPTIONPERDOZ,0 as QUNATITY,'' as QTY,0 as UNITPRICE,tprofit as TOTALCOST,'Profit for the Order ' as stagename,'' as PARAMETERNAME,0 as taqty,0 as temqty,
 0 as tcmqty,0 as tgmqty,0 as toqty,tmqty as mqty,munit as munitp,mlcvalue as LCVALUE,'' as UNITOFMEAS
   from t_garmentscost a,t_budgetstages b, t_budgetparameter c,t_budget d,t_unitofmeas e
   where a.STAGEID=b.STAGEID and a.paramid=c.paramid and c.unitofmeasid=e.unitofmeasid
   and a.BUDGETID=d.BUDGETID;

END GetReportFS;
/



PROMPT CREATE OR REPLACE Procedure  181 ::GetReportBudgetSummary
CREATE OR REPLACE Procedure GetReportBudgetSummary
(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pSDate IN VARCHAR2 DEFAULT NULL,
  pEDate IN VARCHAR2 DEFAULT NULL,
  pOrderType IN VARCHAR2,
  pClientID IN VARCHAR2 
)
As
  vSDate DATE;
  vEDate DATE;
BEGIN
  if not pSDate is null then
    vSDate := TO_DATE(pSDate, 'DD/MM/YYYY');
  else
    vSDate := TO_DATE('01/01/1900', 'DD/MM/YYYY');
  end if;
  if not pEDate is null then
    vEDate := TO_DATE(pEDate, 'DD/MM/YYYY');
  else
    vEDate := TO_DATE('01/01/2300', 'DD/MM/YYYY');
  end if;
  
  if pQueryType=0 then
	/* for BG01.rpt FOR G WO*/
  	OPEN data_cursor  FOR
  	select  distinct a.BUDGETID,e.PID,substr(b.clientname,1,40) as clientname,a.BUDGETNO,c.gorderno,a.QUANTITY,(fncBudgetYarnDesc(e.pid) || '-'|| h.fabrictype) AS fabrictype,
	getfncBOType(a.BUDGETID) as BNo,getfncDispalyorder(a.ORDERNO) as DOrder,BugetworderRef(a.budgetid) as WorderRef,
	LCVALUE,nvl(fncBudgetRevenueAmt(a.BUDGETID),0) AS BudgetRevenueAmt,(LCVALUE-nvl(fncBudgetRevenueAmt(a.BUDGETID),0)) AS BProfit,e.totalconsumption as Fabric,	
	1 AS TempSL,
	fncBudgetYarnDesc(e.pid) as YarnDesc,
	(SELECT COUNT(*) FROM T_Fabricconsumption x WHERE x.BUDGETID=a.BUDGETID GROUP BY x.BUDGETID) AS COUNTROW,
	'Latest Budget' AS Rev,
	nvl(fncBudgetYQtyKg(e.pid),0) as yqty,	
	nvl(fncBudgetYCQty(e.pid),0) as ycqty,
	nvl(fncBudgetYUPPKg(e.pid),0) as yuppkg,
	nvl(fncBudgetYQty(e.pid),0) as ycost,
	nvl(fncBudgetKCQty(e.pid),0) as kcqty,
	nvl(fncBudgetKUPPKg(e.pid),0) as kuppkg,
	nvl(fncBudgetKcost(e.pid),0) as kcost,
	nvl(fncBudgetDCQty(e.pid),0) as dcqty,
	nvl(fncBudgetDUPPKg(e.pid),0) as duppkg,
	nvl(fncBudgetDcost(e.pid),0) as dcost,
	nvl(fncBudgetFcost(a.budgetid),0) as fcost,
	nvl(fncBudgetAcost(a.budgetid),0) as accost,
	nvl(fncBudgetEmbCost(a.budgetid),0) as embcost,
	nvl(fncBudgetCmCost(a.budgetid),0) as cmcost,
	nvl(fncBudgetOthCost(a.budgetid),0) as othercost
	from T_Budget a,t_client b,t_gworkorder c,t_employee d,t_fabricconsumption e,t_fabrictype h
   	where a.clientid=b.clientid(+) and
   	a.orderno=c.gorderno(+) and
    a.employeeid=d.employeeid(+) and
  	a.budgetid=e.budgetid and
   	a.revision=65 and
	a.ordertypeid=pOrderType and
	e.fabrictypeid=h.fabrictypeid and 
	(pClientID is NULL or a.ClientID=pClientID) and
	a.BUDGETNO in (SELECT BUDGETNO FROM T_Budget WHERE revision IN (65,66) AND
					(pSDate is NULL or a.BUDGETPREDATE>=vSDate) and
					(pEDate is NULL or a.BUDGETPREDATE<=vEDate))
	ORDER BY getfncBOType(a.BUDGETID);
 elsif pQueryType=1 then
	/* for BGO3.rpt FOR G WO*/
  	OPEN data_cursor  FOR
  	select  distinct a.BUDGETID,e.PID,substr(b.clientname,1,40) as clientname,a.BUDGETNO,c.gorderno,a.QUANTITY,(fncBudgetYarnDesc(e.pid) || '-'|| h.fabrictype) AS fabrictype,
	getfncBOType(a.BUDGETID) as BNo,getfncDispalyorder(a.ORDERNO) as DOrder,BugetworderRef(a.budgetid) as WorderRef,
	LCVALUE,nvl(fncBudgetRevenueAmt(a.BUDGETID),0) AS BudgetRevenueAmt,(LCVALUE-nvl(fncBudgetRevenueAmt(a.BUDGETID),0)) AS BProfit,e.totalconsumption as Fabric,	
	DECODE(a.revision,65,100,66,1,67,2,68,3,69,4,70,5,71,6,72,7,73,8,74,9,99) AS TempSL,
	fncBudgetYarnDesc(e.pid) as YarnDesc,
	DECODE(a.revision,65,'A Latest Budget',66,'B 1st Budget',67,'C 2nd Budget',68,'D 3rd Budget',69,'E 4th Budget',70,'F 5th Budget',71,'G 6th Budget',72,'H 7th Budget',73,'I 8th Budget',74,'I 9th Budget','0') AS Rev,
	nvl(fncBudgetYQtyKg(e.pid),0) as yqty,	
	nvl(fncBudgetYCQty(e.pid),0) as ycqty,
	nvl(fncBudgetYUPPKg(e.pid),0) as yuppkg,
	nvl(fncBudgetYQty(e.pid),0) as ycost,
	nvl(fncBudgetKCQty(e.pid),0) as kcqty,
	nvl(fncBudgetKUPPKg(e.pid),0) as kuppkg,
	nvl(fncBudgetKcost(e.pid),0) as kcost,
	nvl(fncBudgetDCQty(e.pid),0) as dcqty,
	nvl(fncBudgetDUPPKg(e.pid),0) as duppkg,
	nvl(fncBudgetDcost(e.pid),0) as dcost,
	nvl(fncBudgetFcost(a.budgetid),0) as fcost,
	nvl(fncBudgetAcost(a.budgetid),0) as accost,
	nvl(fncBudgetEmbCost(a.budgetid),0) as embcost,
	nvl(fncBudgetCmCost(a.budgetid),0) as cmcost,
	nvl(fncBudgetOthCost(a.budgetid),0) as othercost
	from T_Budget a,t_client b,t_gworkorder c,t_employee d,t_fabricconsumption e,t_fabrictype h
   	where a.clientid=b.clientid(+) and
   	a.orderno=c.gorderno(+) and
    a.employeeid=d.employeeid(+) and
  	a.budgetid=e.budgetid and
   	/*a.revision=65 and*/
	a.ordertypeid=pOrderType and
	e.fabrictypeid=h.fabrictypeid and 
	(pClientID is NULL or a.ClientID=pClientID) and
	a.BUDGETNO in (SELECT BUDGETNO FROM T_Budget WHERE revision IN (65,66) AND
					(pSDate is NULL or a.BUDGETPREDATE>=vSDate) and
					(pEDate is NULL or a.BUDGETPREDATE<=vEDate))
	ORDER BY e.PID,DECODE(a.revision,65,100,66,1,67,2,68,3,69,4,70,5,71,6,72,7,73,8,74,9,99);
  elsif pQueryType=2 then
	/* for BS02BugetsummaryFS.rpt FOR FS WO*/
  	OPEN data_cursor  FOR
    select  distinct a.BUDGETID,b.clientname,a.BUDGETNO,c.orderno,a.QUANTITY,h.fabrictype,
	getfncBOType(a.BUDGETID) as BNo,getfncWOBType(a.ORDERNO) as DOrder,BugetworderRef(a.budgetid) as WorderRef,
	LCVALUE,nvl(fncBudgetRevenueAmt(a.BUDGETID),0) AS BudgetRevenueAmt,(LCVALUE-nvl(fncBudgetRevenueAmt(a.BUDGETID),0)) AS BProfit,e.totalconsumption as Fabric,
	getBudgetYQtyKg(e.pid) as yqty,
	getBudgetYQty(e.pid) as ycost,
	getBudgetKcost(e.pid) as kcost,
	getBudgetDcost(a.budgetid) as dcost,
	getBudgetFcost(a.budgetid) as fcost,
	getBudgetOthCost(a.budgetid) as othercost
	from t_Budget a,t_client b,t_workorder c,t_employee d,t_fabricconsumption e,t_fabrictype h
   	where a.clientid=b.clientid(+) and
   	a.orderno=c.orderno(+) and
    a.employeeid=d.employeeid(+) and
  	a.budgetid=e.budgetid and
   	a.revision=65 and a.ordertypeid=pOrderType and
	e.fabrictypeid=h.fabrictypeid and
	(pSDate is NULL or a.BUDGETPREDATE>=vSDate) and
 	(pEDate is NULL or a.BUDGETPREDATE<=vEDate)
 	order by to_number(a.budgetno);
   elsif pQueryType=3 then
	/* for BS01BugetsummaryG.rpt FOR G WO*/
  	OPEN data_cursor  FOR
  	select  distinct a.BUDGETID,substr(b.clientname,1,12) as clientname,a.BUDGETNO,c.gorderno,a.QUANTITY,h.fabrictype,
	getfncBOType(a.BUDGETID) as BNo,getfncDispalyorder(a.ORDERNO) as DOrder,BugetworderRef(a.budgetid) as WorderRef,
	LCVALUE,nvl(fncBudgetRevenueAmt(a.BUDGETID),0) AS BudgetRevenueAmt,(LCVALUE-nvl(fncBudgetRevenueAmt(a.BUDGETID),0)) AS BProfit,e.totalconsumption as Fabric,
	nvl(getBudgetYQtyKg(e.pid),0) as yqty,
	nvl(getBudgetYQty(e.pid),0) as ycost,
	nvl(getBudgetKcost(e.pid),0) as kcost,
	nvl(getBudgetDcost(a.budgetid),0) as dcost,
	nvl(getBudgetFcost(a.budgetid),0) as fcost,
	nvl(getBudgetAcost(a.budgetid),0) as accost,
	nvl(getBudgetEmbCost(a.budgetid),0) as embcost,
	nvl(getBudgetCmCost(a.budgetid),0) as cmcost,
	nvl(getBudgetOthCost(a.budgetid),0) as othercost
	from T_Budget a,t_client b,t_gworkorder c,t_employee d,t_fabricconsumption e,t_fabrictype h
   	where a.clientid=b.clientid(+) and
   	a.orderno=c.gorderno(+) and
    a.employeeid=d.employeeid(+) and
  	a.budgetid=e.budgetid and
   	a.revision=65 and a.ordertypeid=pOrderType and
	e.fabrictypeid=h.fabrictypeid and
	(pSDate is NULL or a.BUDGETPREDATE>=vSDate) and
 	(pEDate is NULL or a.BUDGETPREDATE<=vEDate)
 	order by to_number(a.budgetno);
	
	elsif pQueryType=10 then
	/* for BG01C.rpt FOR G WO*/
  	OPEN data_cursor  FOR
select  distinct a.BUDGETID,e.PID,substr(b.clientname,1,40) as clientname,a.BUDGETNO,c.gorderno,a.QUANTITY,(fncBudgetYarnDesc(e.pid) || '-'|| h.fabrictype) AS fabrictype,
	getfncBOType(a.BUDGETID) as BNo,getfncDispalyorder(a.ORDERNO) as DOrder,BugetworderRef(a.budgetid) as WorderRef,
	LCVALUE,nvl(fncBudgetRevenueAmt(a.BUDGETID),0) AS BudgetRevenueAmt,(LCVALUE-nvl(fncBudgetRevenueAmt(a.BUDGETID),0)) AS BProfit,e.totalconsumption as Fabric,	
	1 AS TempSL,
	fncBudgetYarnDesc(e.pid) as YarnDesc,
	(SELECT COUNT(*) FROM T_Fabricconsumption x WHERE x.BUDGETID=a.BUDGETID GROUP BY x.BUDGETID) AS COUNTROW,
	'Latest Budget' AS Rev,
	nvl(fncBudgetYQtyKg(e.pid),0) as yqty,	
	nvl(fncBudgetYCQty(e.pid),0) as ycqty,
	nvl(fncBudgetYUPPKg(e.pid),0) as yuppkg,
	nvl(fncBudgetYQty(e.pid),0) as ycost,
	nvl(fncBudgetKCQty(e.pid),0) as kcqty,
	nvl(fncBudgetKUPPKg(e.pid),0) as kuppkg,
	nvl(fncBudgetKcost(e.pid),0) as kcost,
	nvl(fncBudgetDCQty(e.pid),0) as dcqty,
	nvl(fncBudgetDUPPKg(e.pid),0) as duppkg,
	nvl(fncBudgetDcost(e.pid),0) as dcost,
	nvl(fncBudgetFcost(a.budgetid),0) as fcost,
	nvl(fncBudgetAcost(a.budgetid),0) as accost,
	nvl(fncBudgetEmbCost(a.budgetid),0) as embcost,
	nvl(fncBudgetCmCost(a.budgetid),0) as cmcost,
	nvl(fncBudgetOthCost(a.budgetid),0) as othercost
	from T_Budget a,t_client b,t_gworkorder c,t_employee d,t_fabricconsumption e,t_fabrictype h
   	where a.clientid=b.clientid(+) and
   	a.orderno=c.gorderno(+) and
    a.employeeid=d.employeeid(+) and
  	a.budgetid=e.budgetid and
   	a.revision=65 and
	a.ordertypeid=pOrderType and
	e.fabrictypeid=h.fabrictypeid and 
	(pClientID is NULL or a.ClientID=pClientID) and
	a.BUDGETNO in (SELECT BUDGETNO FROM T_Budget WHERE revision IN (65,66) AND
					(pSDate is NULL or a.BUDGETPREDATE>=vSDate) and
					(pEDate is NULL or a.BUDGETPREDATE<=vEDate));
end if;
END GetReportBudgetSummary;
/


PROMPT CREATE OR REPLACE Procedure  182 ::GetReportBudgetTex
Create or Replace Procedure GetReportBudgetTex
(
  one_cursor IN OUT pReturnData.c_Records,
  pBUDGETID number
)
AS
BEGIN
    open one_cursor for
    select  a.BUDGETID,a.BUDGETNO,getfncBOType(a.BUDGETID) as BNo,a.ORDERNO,a.ORDERREF,a.ORDERDESC,a.LCNO,a.LCRECEIVEDATE,
    a.LCEXPIRYDATE,a.SHIPMENTDATE,a.LCVALUE,a.QUANTITY,a.UNITPRICE,a.BUDGETPREDATE,b.clientname,
   c.DORDERNO,getfncWOBType(a.ORDERNO) as DOrder,a.complete,a.revision,a.postdate,a.ordertypeid,PI,cadRefno,d.employeename,
   BugetworderRef(a.budgetid) as WorderRef,BREVCHECK(a.budgetno,a.ordertypeid) as Budgetrevno
   from t_Budget a,t_client b,t_workorder c,t_employee d
   where a.clientid=b.clientid(+) and
  a.orderno=c.orderno(+) and a.employeeid=d.employeeid(+) and 
  a.budgetid=pBUDGETID;
   END GetReportBudgetTex;
/



PROMPT CREATE OR REPLACE Procedure  183 ::getKnitProdSum
CREATE OR REPLACE Procedure getKnitProdSum(
  data_cursor IN OUT pReturnData.c_Records, 
  pQType in number,  
  pSDate IN VARCHAR2  DEFAULT NULL, 
  pEDate IN VARCHAR2  DEFAULT NULL 
) 
AS 
  vSDate date;
  vEDate date; 
BEGIN 
  if not pSDate is null then
    vSDate := TO_DATE(pSDate, 'DD/MM/YYYY');
  end if;
  if not pEDate is null then
    vEDate := TO_DATE(pEDate, 'DD/MM/YYYY');
  end if;
 if (pQType=1) then /*In house F15.rpt*/
 OPEN data_cursor  FOR
 select to_char(a.STOCKTRANSDATE,'MM') as Smonth,to_char(a.STOCKTRANSDATE,'YYYY') as SYear,to_char(a.STOCKTRANSDATE,'MONTH')||'-'||to_char(a.STOCKTRANSDATE,'YYYY') as MonthYear,
    sum(decode(d.BASICTYPEID,'FC',(decode(a.KNTITRANSACTIONTYPEID,6,b.Quantity,0)),0)) FCGrayQty,    
	sum(decode(d.BASICTYPEID,'FC',(decode(a.KNTITRANSACTIONTYPEID,24,b.Quantity,0)),0)) FCDyedQty,    
	sum(decode(d.BASICTYPEID,'FC',(decode(a.KNTITRANSACTIONTYPEID,6,b.Quantity,24,b.Quantity,0)),0)) FCTotalQty, 
    sum(decode(d.BASICTYPEID,'FS',(decode(a.KNTITRANSACTIONTYPEID,6,b.Quantity,0)),0)) FSGrayQty,    
	sum(decode(d.BASICTYPEID,'FS',(decode(a.KNTITRANSACTIONTYPEID,24,b.Quantity,0)),0)) FSDyedQty,    
	sum(decode(d.BASICTYPEID,'FS',(decode(a.KNTITRANSACTIONTYPEID,6,b.Quantity,24,b.Quantity,0)),0)) FSTotalQty,
    sum(decode(d.BASICTYPEID,'FG',(decode(a.KNTITRANSACTIONTYPEID,6,b.Quantity,0)),0)) FGGrayQty,    
	sum(decode(d.BASICTYPEID,'FG',(decode(a.KNTITRANSACTIONTYPEID,24,b.Quantity,0)),0)) FGDyedQty,    
	sum(decode(d.BASICTYPEID,'FG',(decode(a.KNTITRANSACTIONTYPEID,6,b.Quantity,24,b.Quantity,0)),0)) FGTotalQty,	
	sum(decode(d.BASICTYPEID,'SF',(decode(a.KNTITRANSACTIONTYPEID,6,b.Quantity,0)),0)) SFGrayQty,    
	sum(decode(d.BASICTYPEID,'SF',(decode(a.KNTITRANSACTIONTYPEID,24,b.Quantity,0)),0)) SFDyedQty,    
	sum(decode(d.BASICTYPEID,'SF',(decode(a.KNTITRANSACTIONTYPEID,6,b.Quantity,24,b.Quantity,0)),0)) SFTotalQty,
	sum(decode(a.KNTITRANSACTIONTYPEID,6,b.Quantity,24,b.Quantity,0)) TotalQty,
	DECODE(to_char(a.STOCKTRANSDATE,'MM'),1,'1ST_SIX',2,'1ST_SIX',3,'1ST_SIX',4,'1ST_SIX',5,'1ST_SIX',6,'1ST_SIX',7,'2ND_SIX',8,'2ND_SIX',9,'2ND_SIX',10,'2ND_SIX',11,'2ND_SIX',12,'2ND_SIX') AS SIX_MONTH
	from T_Knitstock a, T_KnitStockItems b,t_workorder d
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID in (6,24) and    
    b.ORDERNO=d.ORDERNO and
    a.STOCKTRANSDATE between decode(vSDate,null,'01-jan-2000',vSDate) and vEDate and
    b.ORDERNO>0
	group by to_char(a.STOCKTRANSDATE,'YYYY'),to_char(a.STOCKTRANSDATE,'MM'),to_char(a.STOCKTRANSDATE,'MONTH')
	order by to_char(a.STOCKTRANSDATE,'YYYY'),to_char(a.STOCKTRANSDATE,'MM');
elsif (pQType=2) then /*Outside  F16.rpt*/
OPEN data_cursor  FOR
 select to_char(a.STOCKTRANSDATE,'MM') as Smonth,to_char(a.STOCKTRANSDATE,'YYYY') as SYear,to_char(a.STOCKTRANSDATE,'MONTH')||'-'||to_char(a.STOCKTRANSDATE,'YYYY') as MonthYear,
    sum(decode(d.BASICTYPEID,'FC',(decode(a.KNTITRANSACTIONTYPEID,7,b.Quantity,0)),0)) FCGrayQty,    
	sum(decode(d.BASICTYPEID,'FC',(decode(a.KNTITRANSACTIONTYPEID,25,b.Quantity,0)),0)) FCDyedQty,    
	sum(decode(d.BASICTYPEID,'FC',(decode(a.KNTITRANSACTIONTYPEID,7,b.Quantity,25,b.Quantity,0)),0)) FCTotalQty, 
    sum(decode(d.BASICTYPEID,'FS',(decode(a.KNTITRANSACTIONTYPEID,7,b.Quantity,0)),0)) FSGrayQty,    
	sum(decode(d.BASICTYPEID,'FS',(decode(a.KNTITRANSACTIONTYPEID,25,b.Quantity,0)),0)) FSDyedQty,    
	sum(decode(d.BASICTYPEID,'FS',(decode(a.KNTITRANSACTIONTYPEID,7,b.Quantity,25,b.Quantity,0)),0)) FSTotalQty,
    sum(decode(d.BASICTYPEID,'FG',(decode(a.KNTITRANSACTIONTYPEID,7,b.Quantity,0)),0)) FGGrayQty,    
	sum(decode(d.BASICTYPEID,'FG',(decode(a.KNTITRANSACTIONTYPEID,25,b.Quantity,0)),0)) FGDyedQty,    
	sum(decode(d.BASICTYPEID,'FG',(decode(a.KNTITRANSACTIONTYPEID,7,b.Quantity,25,b.Quantity,0)),0)) FGTotalQty,	
	sum(decode(d.BASICTYPEID,'SF',(decode(a.KNTITRANSACTIONTYPEID,7,b.Quantity,0)),0)) SFGrayQty,    
	sum(decode(d.BASICTYPEID,'SF',(decode(a.KNTITRANSACTIONTYPEID,25,b.Quantity,0)),0)) SFDyedQty,    
	sum(decode(d.BASICTYPEID,'SF',(decode(a.KNTITRANSACTIONTYPEID,7,b.Quantity,25,b.Quantity,0)),0)) SFTotalQty,
	sum(decode(a.KNTITRANSACTIONTYPEID,7,b.Quantity,24,b.Quantity,0)) TotalQty,
	DECODE(to_char(a.STOCKTRANSDATE,'MM'),1,'1ST_SIX',2,'1ST_SIX',3,'1ST_SIX',4,'1ST_SIX',5,'1ST_SIX',6,'1ST_SIX',7,'2ND_SIX',8,'2ND_SIX',9,'2ND_SIX',10,'2ND_SIX',11,'2ND_SIX',12,'2ND_SIX') AS SIX_MONTH
	from T_Knitstock a, T_KnitStockItems b,t_workorder d
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID in (7,25) and    
    b.ORDERNO=d.ORDERNO and
    a.STOCKTRANSDATE between decode(vSDate,null,'01-jan-2000',vSDate) and vEDate and
    b.ORDERNO>0
	group by to_char(a.STOCKTRANSDATE,'YYYY'),to_char(a.STOCKTRANSDATE,'MM'),to_char(a.STOCKTRANSDATE,'MONTH')
	order by to_char(a.STOCKTRANSDATE,'YYYY'),to_char(a.STOCKTRANSDATE,'MM');
End if;
END getKnitProdSum;
/



PROMPT CREATE OR REPLACE Procedure  184 ::RptSewing015
CREATE OR REPLACE PROCEDURE RptSewing015(
  data_cursor IN OUT pReturnData.c_Records,
  sDate IN VARCHAR2,
  eDate IN VARCHAR2  
)
AS
  vSDate date;
  vEDate date;
BEGIN

  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  end if; 	
OPEN data_cursor  FOR
	Select (b.lineno), sum(Decode(A.PRODHOUR,1,b.QUANTITY,0)) as prod1,
	       sum(Decode(A.PRODHOUR,2,b.QUANTITY,0)) as prod2,
		   sum(Decode(A.PRODHOUR,3,b.QUANTITY,0)) as prod3,
		   sum(Decode(A.PRODHOUR,4,b.QUANTITY,0)) as prod4,
		   sum(Decode(A.PRODHOUR,5,b.QUANTITY,0)) as prod5,
		   sum(Decode(A.PRODHOUR,6,b.QUANTITY,0)) as prod6,
		   sum(Decode(A.PRODHOUR,7,b.QUANTITY,0)) as prod7,
		   sum(Decode(A.PRODHOUR,8,b.QUANTITY,0)) as prod8,
		   sum(Decode(A.PRODHOUR,9,b.QUANTITY,0)) as prod9,
		   sum(Decode(A.PRODHOUR,10,b.QUANTITY,0)) as prod10,
		   sum(Decode(A.PRODHOUR,11,b.QUANTITY,0)) as prod11,
		   sum(Decode(A.PRODHOUR,12,b.QUANTITY,0)) as prod12,
		   sum(Decode(A.PRODHOUR,13,b.QUANTITY,0)) as prod13,
		   sum(Decode(A.PRODHOUR,1,b.QUANTITY,2,b.QUANTITY,3,b.QUANTITY,4,b.QUANTITY,5,b.QUANTITY,
		   6,b.QUANTITY,7,b.QUANTITY,8,b.QUANTITY,9,b.QUANTITY,10,b.QUANTITY,11,b.QUANTITY,12,b.QUANTITY,13,b.QUANTITY,0)) as totprod
	from 
		T_GSTOCK a,
		T_GStockItems b
	where 
		a.STOCKID=b.STOCKID and
		b.GTRANSTYPEID=7 and
		a.STOCKTRANSDATE between decode(vSDate,null,'01-jan-2000',vSDate) and vEDate
    group by b.lineno		
	order by to_number(b.lineno);
END RptSewing015;
/



PROMPT CREATE OR REPLACE Procedure  185 ::getAccConsumpMonthly
CREATE OR REPLACE Procedure getAccConsumpMonthly(
  data_cursor IN OUT pReturnData.c_Records,
  pQType in number,
  pSDate IN VARCHAR2  DEFAULT NULL,
  pEDate IN VARCHAR2  DEFAULT NULL
)
AS
  vSDate date;
  vEDate date;
BEGIN
   if not pSDate is null then
    vSDate := TO_DATE(pSDate, 'DD/MM/YYYY');
  else
    vSDate := TO_DATE('01/07/2010', 'DD/MM/YYYY');
  end if;
  if not pEDate is null then
    vEDate := TO_DATE(pEDate, 'DD/MM/YYYY');
  else
    vEDate := TO_DATE('31/12/2010', 'DD/MM/YYYY');
  end if;  
  
 if (pQType=1) then /*Accessories consumption report GA09D*/
 OPEN data_cursor  FOR
 select c.UNITOFMEAS as PUnit,b.ACCESSORIESID,d.ITEM,nvl(d.WAVGPRICE,0) as UnitPrice,getfncDispalyorder(b.GORDERNO) as gorder,
	case when nvl((Select sum(decode(x.ACCTRANSTYPEID,1,y.QUANTITY,2,-y.QUANTITY,4,y.QUANTITY,0))
	from T_ACCSTOCK x, T_ACCSTOCKITEMS y
    where x.STOCKID=y.STOCKID and
	x.ACCTRANSTYPEID in (1,2,4) and
	y.ACCESSORIESID=b.ACCESSORIESID and
	y.GORDERNO=b.GORDERNO and
	x.STOCKTRANSDATE<vEDate
	group by y.ACCESSORIESID),0)<0  then 0
  else nvl((Select sum(decode(x.ACCTRANSTYPEID,1,y.QUANTITY,2,-y.QUANTITY,4,y.QUANTITY,0))
	from T_ACCSTOCK x, T_ACCSTOCKITEMS y
    where x.STOCKID=y.STOCKID and
	x.ACCTRANSTYPEID in (1,2,4) and
	y.ACCESSORIESID=b.ACCESSORIESID and
	y.GORDERNO=b.GORDERNO and
	x.STOCKTRANSDATE<vEDate
	group by y.ACCESSORIESID),0)
  end as MainStockQty,
    sum(decode(a.ACCTRANSTYPEID,2,b.QUANTITY,0)) as MRQty,
	sum(decode(a.ACCTRANSTYPEID,4,b.QUANTITY,0)) as RetQty,
	sum(decode(a.ACCTRANSTYPEID,2,b.QUANTITY,4,-b.QUANTITY,0)) as ConQty
	from T_ACCSTOCK a, T_ACCSTOCKITEMS b,T_UNITOFMEAS c,T_Accessories d
    where a.STOCKID=b.STOCKID and
	a.ACCTRANSTYPEID in (1,2,4) and
	b.ACCESSORIESID=d.ACCESSORIESID and
	b.PUNITOFMEASID=c.UNITOFMEASID and
    a.STOCKTRANSDATE between vSDate and vEDate
	group by b.ACCESSORIESID,b.GORDERNO,c.UNITOFMEAS,d.ITEM,d.WAVGPRICE
	Having sum(decode(a.ACCTRANSTYPEID,2,b.QUANTITY,0))>0
	order by b.GORDERNO,d.ITEM,c.UNITOFMEAS;
 
elsif (pQType=2) then /*Accessories consumption report monthly workorder wise*/

 OPEN data_cursor  FOR
 select b.ACCESSORIESID,c.UNITOFMEAS as PUnit,d.ITEM,
    nvl(d.WAVGPRICE,0) as UnitPrice,getfncDispalyorder(b.GORDERNO) as gorder,
	case when nvl((Select sum(decode(x.ACCTRANSTYPEID,1,y.QUANTITY,2,-y.QUANTITY,4,y.QUANTITY,0))
	from T_ACCSTOCK x, T_ACCSTOCKITEMS y
    where x.STOCKID=y.STOCKID and
	x.ACCTRANSTYPEID in (1,2,4) and
	y.ACCESSORIESID=b.ACCESSORIESID and
	y.GORDERNO=b.GORDERNO and
	x.STOCKTRANSDATE<vEDate
	group by y.ACCESSORIESID),0)<0  then 0
  else nvl((Select sum(decode(x.ACCTRANSTYPEID,1,y.QUANTITY,2,-y.QUANTITY,4,y.QUANTITY,0))
	from T_ACCSTOCK x, T_ACCSTOCKITEMS y
    where x.STOCKID=y.STOCKID and
	x.ACCTRANSTYPEID in (1,2,4) and
	y.ACCESSORIESID=b.ACCESSORIESID and
	y.GORDERNO=b.GORDERNO and
	x.STOCKTRANSDATE<vEDate
	group by y.ACCESSORIESID),0)
  end as MainStockQty,
    sum(decode(a.ACCTRANSTYPEID,2,b.QUANTITY,0)) as MRQty,
	sum(decode(a.ACCTRANSTYPEID,4,b.QUANTITY,0)) as RetQty,
	sum(decode(a.ACCTRANSTYPEID,2,b.QUANTITY,4,-b.QUANTITY,0)) as ConQty
	from T_ACCSTOCK a, T_ACCSTOCKITEMS b,T_UNITOFMEAS c,T_Accessories d
    where a.STOCKID=b.STOCKID and
	a.ACCTRANSTYPEID in (1,2,4) and
	b.ACCESSORIESID=d.ACCESSORIESID and
	b.PUNITOFMEASID=c.UNITOFMEASID and
    a.STOCKTRANSDATE between vSDate and vEDate
	group by b.ACCESSORIESID,c.UNITOFMEAS,b.GORDERNO,d.ITEM,d.WAVGPRICE
	order by b.GORDERNO,d.ITEM,c.UNITOFMEAS;
	
 elsif (pQType=3) then /*Accessories consumption report GA09D*/
 OPEN data_cursor  FOR
 select a.STOCKTRANSNO,a.STOCKTRANSDATE,c.UNITOFMEAS as PUnit,b.ACCESSORIESID,d.ITEM,nvl(d.WAVGPRICE,0) as UnitPrice,getfncDispalyorder(b.GORDERNO) as gorder,
	case when nvl((Select sum(decode(x.ACCTRANSTYPEID,1,y.QUANTITY,2,-y.QUANTITY,4,y.QUANTITY,0))
	from T_ACCSTOCK x, T_ACCSTOCKITEMS y
    where x.STOCKID=y.STOCKID and
	x.ACCTRANSTYPEID in (1,2,4) and
	y.ACCESSORIESID=b.ACCESSORIESID and
	y.GORDERNO=b.GORDERNO and
	x.STOCKTRANSDATE<vEDate
	group by y.ACCESSORIESID),0)<0  then 0
  else nvl((Select sum(decode(x.ACCTRANSTYPEID,1,y.QUANTITY,2,-y.QUANTITY,4,y.QUANTITY,0))
	from T_ACCSTOCK x, T_ACCSTOCKITEMS y
    where x.STOCKID=y.STOCKID and
	x.ACCTRANSTYPEID in (1,2,4) and
	y.ACCESSORIESID=b.ACCESSORIESID and
	y.GORDERNO=b.GORDERNO and
	x.STOCKTRANSDATE<vEDate
	group by y.ACCESSORIESID),0)
  end as MainStockQty,
    sum(decode(a.ACCTRANSTYPEID,2,b.QUANTITY,0)) as MRQty,
	sum(decode(a.ACCTRANSTYPEID,4,b.QUANTITY,0)) as RetQty,
	sum(decode(a.ACCTRANSTYPEID,2,b.QUANTITY,4,-b.QUANTITY,0)) as ConQty
	from T_ACCSTOCK a, T_ACCSTOCKITEMS b,T_UNITOFMEAS c,T_Accessories d
    where a.STOCKID=b.STOCKID and
	a.ACCTRANSTYPEID in (1,2,4) and
	b.ACCESSORIESID=d.ACCESSORIESID and 
	b.PUNITOFMEASID=c.UNITOFMEASID and
    a.STOCKTRANSDATE between vSDate and vEDate
	group by a.STOCKTRANSNO,a.STOCKTRANSDATE,b.ACCESSORIESID,b.GORDERNO,c.UNITOFMEAS,d.ITEM,d.WAVGPRICE
	Having sum(decode(a.ACCTRANSTYPEID,2,b.QUANTITY,0))>0
	order by b.GORDERNO,d.ITEM,c.UNITOFMEAS;
End if;
END getAccConsumpMonthly;
/


PROMPT CREATE OR REPLACE Procedure  186 ::TG10ReportRet
CREATE OR REPLACE Procedure TG10ReportRet
(
  one_cursor IN OUT pReturnData.c_Records,
  pGStockID number
)
AS
BEGIN
    open one_cursor for
    select 	StockTransNO, StockTransDATE,getfncDispalyorder(b.ORDERNO) as dorder,
    		Pono,GatepassNo,b.ORDERNO,GSTOCKITEMSL,b.FabricTypeId,Quantity,
   		Squantity,b.PunitOfmeasId,b.SUNITOFMEASID,SIZEID,
    		BatchNo,Shade,b.REMARKS,FabricDia,FabricGSM,Styleno,
    		f.fabrictype,d.unitofmeas as punit,e.unitofmeas as sunit
    from  
		T_GSTOCK a,T_GStockItems b,t_unitofmeas d,
		t_unitofmeas e,t_fabrictype f
    where
		a.stockid=b.stockid and				
		a.STOCKID=pGStockID and
		b.punitofmeasid=d.unitofmeasid(+) and
		b.sunitofmeasid=e.unitofmeasid(+) and
		b.fabrictypeid=f.fabrictypeid
    order 
		by GSTOCKITEMSL asc;
END TG10ReportRet;
/



PROMPT CREATE OR REPLACE Procedure  187 ::GetBudgetSumWoWise
CREATE OR REPLACE Procedure GetBudgetSumWoWise
(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pOrderType IN VARCHAR2,
  pOrderno IN VARCHAR2,
  pClient  IN VARCHAR2,
  pSDate IN VARCHAR2 DEFAULT NULL,
  pEDate IN VARCHAR2 DEFAULT NULL
)
As
  vSDate DATE;
  vEDate DATE;
BEGIN
  if not pSDate is null then
    vSDate := TO_DATE(pSDate, 'DD/MM/YYYY');
  else
    vSDate := TO_DATE('01/01/1900', 'DD/MM/YYYY');
  end if;
  if not pEDate is null then
    vEDate := TO_DATE(pEDate, 'DD/MM/YYYY');
  else
    vEDate := TO_DATE('01/01/2300', 'DD/MM/YYYY');
  end if;
  
  if pQueryType=1 then
	/* FOR BS01G.rpt ALL GARMENTS WORK ORDER*/
  	OPEN data_cursor  FOR
  	select  distinct a.BUDGETID,b.clientname,a.BUDGETNO,c.gorderno,a.QUANTITY,h.fabrictype,
	getfncBOType(a.BUDGETID) as BNo,getfncDispalyorder(c.GORDERNO) as DOrder,
	nvl(e.totalconsumption,0) as Fabric,
	nvl(getBudgetYQtyKg(e.pid),0) as yqty,
	nvl(getBudgetYQty(e.pid),0) as ycost,
	nvl(getBudgetKcost(e.pid),0) as kcost,
	nvl(getBudgetDcost(a.budgetid),0) as dcost,
	nvl(getBudgetFcost(a.budgetid),0) as fcost,
	nvl(getBudgetAcost(a.budgetid),0) as accost,
	nvl(getBudgetEmbCost(a.budgetid),0) as embcost,
	nvl(getBudgetCmCost(a.budgetid),0) as cmcost,
	nvl(getBudgetOthCost(a.budgetid),0) as othercost
	from t_Budget a,t_client b,t_gworkorder c,t_fabricconsumption e,t_fabrictype h
   	where a.clientid=b.clientid and
	(pClient IS NULL OR A.CLIENTID=pClient) AND
	C.GORDERNO=A.ORDERNO AND
	C.ORDERTYPEID=pOrderType AND /* IN ('G','S') AND*/
  	a.budgetid=e.budgetid and
   	a.revision=65 and
	e.fabrictypeid=h.fabrictypeid and
	(pSDate is NULL or a.BUDGETPREDATE>=vSDate) and
 	(pEDate is NULL or a.BUDGETPREDATE<=vEDate)
 	order by to_number(a.budgetno);
 elsif pQueryType=2 then
	/* FOR BS01G.rpt SELECTED GARMENTS WORK ORDER*/
  	OPEN data_cursor  FOR
  	select  distinct a.BUDGETID,b.clientname,a.BUDGETNO,c.gorderno,a.QUANTITY,h.fabrictype,
	getfncBOType(a.BUDGETID) as BNo,getfncDispalyorder(c.GORDERNO) as DOrder,
	nvl(e.totalconsumption,0) as Fabric,
	nvl(getBudgetYQtyKg(e.pid),0) as yqty,
	nvl(getBudgetYQty(e.pid),0) as ycost,
	nvl(getBudgetKcost(e.pid),0) as kcost,
	nvl(getBudgetDcost(a.budgetid),0) as dcost,
	nvl(getBudgetFcost(a.budgetid),0) as fcost,
	nvl(getBudgetAcost(a.budgetid),0) as accost,
	nvl(getBudgetEmbCost(a.budgetid),0) as embcost,
	nvl(getBudgetCmCost(a.budgetid),0) as cmcost,
	nvl(getBudgetOthCost(a.budgetid),0) as othercost
	from t_Budget a,t_client b,t_gworkorder c,t_fabricconsumption e,t_fabrictype h
   	where a.clientid=b.clientid and
	(pClient IS NULL OR A.CLIENTID=pClient) AND
	C.GORDERNO=A.ORDERNO AND
	C.ORDERTYPEID=pOrderType AND /* IN ('G','S') AND*/
   	C.GORDERNO in (get_token(pOrderno,1,'|'),get_token(pOrderno,2,'|'),get_token(pOrderno,3,'|'),
	 get_token(pOrderno,4,'|'),get_token(pOrderno,5,'|'),get_token(pOrderno,6,'|'),
	 get_token(pOrderno,7,'|'),get_token(pOrderno,8,'|'),get_token(pOrderno,9,'|'),
	 get_token(pOrderno,10,'|'),get_token(pOrderno,11,'|'),get_token(pOrderno,12,'|'),
	 get_token(pOrderno,13,'|'),get_token(pOrderno,14,'|'),get_token(pOrderno,15,'|')) and
  	a.budgetid=e.budgetid and
   	a.revision=65 and
	e.fabrictypeid=h.fabrictypeid and
	(pSDate is NULL or a.BUDGETPREDATE>=vSDate) and
 	(pEDate is NULL or a.BUDGETPREDATE<=vEDate)
 	order by to_number(a.budgetno);
  elsif pQueryType=3 then
	/*FOR BS01T.rpt ALL TEXTILE WORK ORDER WITHOUT FC WORK ORDER*/
  	OPEN data_cursor  FOR
    select  distinct a.BUDGETID,b.clientname,a.BUDGETNO,c.orderno,a.QUANTITY,h.fabrictype,
	getfncBOType(a.BUDGETID) as BNo,getfncWOBType(c.ORDERNO) as DOrder,
	nvl(e.totalconsumption,0) as Fabric,
	nvl(getBudgetYQty(e.pid),0) as ycost,
	nvl(getBudgetKcost(e.pid),0) as kcost,
	nvl(getBudgetDcost(a.budgetid),0) as dcost,
	nvl(getBudgetFcost(a.budgetid),0) as fcost,
	nvl(getBudgetOthCost(a.budgetid),0) as othercost
	from t_Budget a,t_client b,t_workorder c,t_fabricconsumption e,t_fabrictype h
   	where a.clientid=b.clientid and
	(pClient IS NULL OR A.CLIENTID=pClient) AND
	A.BUDGETID=C.BUDGETID AND
	C.BASICTYPEID=pOrderType AND   /*('FG','FS','SF') AND*/
  	a.budgetid=e.budgetid and
   	a.revision=65 and
	e.fabrictypeid=h.fabrictypeid and
	(pSDate is NULL or a.BUDGETPREDATE>=vSDate) and
 	(pEDate is NULL or a.BUDGETPREDATE<=vEDate)
 	order by to_number(a.budgetno);
elsif pQueryType=4 then
	/*FOR SELECTED TEXTILE WORK ORDER WITHOUT FC WORK ORDER*/
  	OPEN data_cursor  FOR
    select  distinct a.BUDGETID,b.clientname,a.BUDGETNO,c.orderno,a.QUANTITY,h.fabrictype,
	getfncBOType(a.BUDGETID) as BNo,getfncWOBType(c.ORDERNO) as DOrder,
	nvl(e.totalconsumption,0) as Fabric,
	nvl(getBudgetYQty(e.pid),0) as ycost,
	nvl(getBudgetKcost(e.pid),0) as kcost,
	nvl(getBudgetDcost(a.budgetid),0) as dcost,
	nvl(getBudgetFcost(a.budgetid),0) as fcost,
	nvl(getBudgetOthCost(a.budgetid),0) as othercost
	from t_Budget a,t_client b,t_workorder c,t_fabricconsumption e,t_fabrictype h
   	where a.clientid=b.clientid and
	(pClient IS NULL OR A.CLIENTID=pClient) AND
	A.BUDGETID=C.BUDGETID AND
	C.BASICTYPEID=pOrderType  AND /*('FG','FS','SF') AND*/
   	C.ORDERNO in (get_token(pOrderno,1,'|'),get_token(pOrderno,2,'|'),get_token(pOrderno,3,'|'),
	 get_token(pOrderno,4,'|'),get_token(pOrderno,5,'|'),get_token(pOrderno,6,'|'),
	 get_token(pOrderno,7,'|'),get_token(pOrderno,8,'|'),get_token(pOrderno,9,'|'),
	 get_token(pOrderno,10,'|'),get_token(pOrderno,11,'|'),get_token(pOrderno,12,'|'),
	 get_token(pOrderno,13,'|'),get_token(pOrderno,14,'|'),get_token(pOrderno,15,'|')) and
  	a.budgetid=e.budgetid and
   	a.revision=65 and
	e.fabrictypeid=h.fabrictypeid and
	(pSDate is NULL or a.BUDGETPREDATE>=vSDate) and
 	(pEDate is NULL or a.BUDGETPREDATE<=vEDate)
 	order by to_number(a.budgetno);
end if;
END GetBudgetSumWoWise;
/



PROMPT CREATE OR REPLACE Procedure  188 ::RptMEBillMonthly004
Create or Replace Procedure RptMEBillMonthly004(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,  
  sDate IN VARCHAR2,
  eDate IN VARCHAR2
)
AS
vSDate date;
vEDate date;
BEGIN
  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  else
    vSDate:=TO_DATE('01-JAN-2008', 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  else
    vEDate := TO_DATE('01-DEC-2050', 'DD/MM/YYYY');
  end if;  
/*Monthly Bill and collection amount*/
if pQueryType=0 then
    OPEN data_cursor for
    select aa.BMONTH,aa.BYEAR,bmyear,bb.RecEBILL,bb.RecMBILL,aa.EBILLAMOUNT,aa.MBILLAMOUNT
       from (select a.BMONTH,a.BYEAR,to_char(add_months(a.ISSUEDATE,-1),'MM-YYYY') as bmyear,
	        sum(decode(a.BILLTYPE,1,a.PAYABLEAMOUNT,0)) as EBILLAMOUNT,	       
			sum(decode(a.BILLTYPE,2,a.PAYABLEAMOUNT,0)) as MBILLAMOUNT
			from T_ELECTRICITYBILL a
			where (add_months(a.ISSUEDATE,-1) between vSDate and vEDate)	
			group by a.BMONTH,a.BYEAR,to_char(add_months(a.ISSUEDATE,-1),'MM-YYYY')
			order by to_char(add_months(a.ISSUEDATE,-1),'MM-YYYY')) aa ,
		(select to_char(add_months(x.RECEIPTDATE,-1),'MM-YYYY') as myesr,
			sum(decode(x.Electric,1,x.Amount,0)) as RecEBILL,
			sum(decode(x.Maintenence,1,x.Amount,0)) as RecMBILL		
			from T_Moneyreceipt x 
			where x.RECEIPTFOR=5 and
			(add_months(x.RECEIPTDATE,-1) between vSDate and vEDate)
			group by to_char(add_months(x.RECEIPTDATE,-1),'MM-YYYY')
			order by to_char(add_months(x.RECEIPTDATE,-1),'MM-YYYY')) bb		 
	where aa.bmyear=bb.myesr;
end if;
END RptMEBillMonthly004;
/



PROMPT CREATE OR REPLACE Procedure  189 ::GD001ShipmentRpt
Create or Replace Procedure GD001ShipmentRpt
(
  data_cursor IN OUT pReturnData.c_Records,
  pInvoiceId IN NUMBER
)
As
Begin
  OPEN data_cursor FOR
  select a.INVOICENO,a.INVOICEDATE,a.GATEPASSNO,a.LOCKNO,getfncDispalyorder(b.ORDERNO) as Dorder,getClientRef(b.ORDERNO) as ClientRef,
  a.CONTACTPERSON,a.DELIVERYPLACE,a.VEHICLENO,a.DRIVERNAME,a.DRIVERLICENSENO,a.DRIVERMOBILENO,a.TRANSCOMPNAME,
  c.CLIENTNAME,d.CANDFNAME,b.QUANTITY as CTNQty,b.Remarks,e.CLIENTSREF as PONo,b.CBM,getfncGDDesc(b.ORDERNO,b.CTNTYPE) as CTNDesc,
  (select SUM(y.QUANTITY)  from T_CTN x,T_CTNItems y
      where x.CTNID=y.CTNID and x.ORDERNO=b.ORDERNO and x.CTNTYPE=b.CTNTYPE group by
   x.ORDERNO,x.CTNTYPE) as PcsQty
  from T_GDELIVERYCHALLAN a,T_GDELIVERYCHALLANItems b,T_Client c,T_CandF d,T_GWorkOrder e
  where a.INVOICEID=pInvoiceId and
        a.INVOICEID=b.INVOICEID and
  b.ORDERNO=e.GORDERNO and
        a.CATID=14 and
  a.CANDFID=d.CANDFID(+) and
  a.CLIENTID=c.CLIENTID(+)
  order by GSTOCKITEMSL;
End GD001ShipmentRpt;
/



PROMPT CREATE OR REPLACE Procedure  190 ::SH001
CREATE OR REPLACE Procedure SH001
(
  data_cursor IN OUT pReturnData.c_Records,
  pQtype in number,
  plctype IN NUMBER,
  sDate IN VARCHAR2,
  eDate IN VARCHAR2
)
AS
vSDate date;
vEDate date;
BEGIN
  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  else
 vSDate := TO_DATE('01-JAN-2000', 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  else
 vEDate := TO_DATE('01-JAN-2020', 'DD/MM/YYYY');
  end if;
  /*Export LC*/
    if(pQtype=1) then
    open data_cursor for
    select  a.EXPNO,a.EXPDATE,a.GOODSDESC,a.QUANTITYPCS,a.BLNO,a.INVOICENO,a.INVOICEDATE,a.SHIPPINBILLNO ,
  a.SHIPPINGBILLDATE, a.SHIPPINGBILLQTY ,a.GSPNO,a.GSPDATE ,a.GSPQTY ,b.BANKLCNO,a.BLDATE,a.INVOICEVALUE,
  a.orderno,a.docsubdate,nvl(c.PayReceiveAmt,0) as PayReceiveAmt,D.CLIENTNAME
    from T_Shipmentinfo a,T_lcinfo b,T_LCPayment c,T_CLIENT D
    where a.lcno=b.lcno and
   a.PID=c.REFID(+) and
  B.CLIENTID=D.CLIENTID(+) AND
  b.explctypeid=plctype and
  b.explctypeid in (1,2) and
  docsubdate between vSDate and vEDate;
 elsif(pQtype=2) then
 open data_cursor for
    select  a.EXPNO,a.EXPDATE,a.GOODSDESC,a.QUANTITYPCS,a.BLNO,a.INVOICENO,a.INVOICEDATE,a.SHIPPINBILLNO ,
  a.SHIPPINGBILLDATE, a.SHIPPINGBILLQTY ,a.GSPNO,a.GSPDATE ,a.GSPQTY ,b.BANKLCNO,a.BLDATE,a.INVOICEVALUE,
  a.orderno,a.docsubdate,nvl(c.PayReceiveAmt,0) as PayReceiveAmt,D.CLIENTNAME
    from T_Shipmentinfo a,T_lcinfo b,T_LCPayment c,T_CLIENT D
    where a.lcno=b.lcno and
     B.CLIENTID=D.CLIENTID(+) AND
	 a.PID=c.REFID(+) and
	 b.explctypeid=plctype and
	 b.explctypeid in (1,2) and
	 A.INVOICEDATE between vSDate and vEDate
  ORDER BY a.INVOICENO,a.INVOICEDATE;
  End If;   
END SH001;
/


PROMPT CREATE OR REPLACE Procedure  191 ::LC11and12
CREATE OR REPLACE Procedure LC11and12
(
  data_cursor IN OUT pReturnData.c_Records,
  pQtype in number,  
  sDate IN VARCHAR2,
  eDate IN VARCHAR2
)
AS
vSDate date;
vEDate date;
BEGIN
  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  else
	vSDate := TO_DATE('01-JAN-2000', 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  else
	vEDate := TO_DATE('01-JAN-2050', 'DD/MM/YYYY');
  end if;
  /*Export LC*/
  if(pQtype=1) then
    open data_cursor for
    select  a.EXPNO,a.EXPDATE,a.GOODSDESC,a.QUANTITYPCS,a.BLNO,a.INVOICENO,a.INVOICEDATE,a.SHIPPINBILLNO ,
		a.SHIPPINGBILLDATE, a.SHIPPINGBILLQTY ,a.GSPNO,a.GSPDATE ,a.GSPQTY ,b.BANKLCNO,a.BLDATE,a.INVOICEVALUE,
		a.orderno,a.docsubdate,D.CLIENTNAME
    from T_Shipmentinfo a,T_lcinfo b,T_CLIENT D
    where a.lcno=b.lcno and   
		B.CLIENTID=D.CLIENTID(+) AND
		b.explctypeid=1 and		
		A.INVOICEDATE between vSDate and vEDate
	order by a.INVOICENO,a.INVOICEDATE;
	/*Contract LC*/
	elsif(pQtype=2) then
    open data_cursor for
    select  a.EXPNO,a.EXPDATE,a.GOODSDESC,a.QUANTITYPCS,a.BLNO,a.INVOICENO,a.INVOICEDATE,a.SHIPPINBILLNO ,
		a.SHIPPINGBILLDATE, a.SHIPPINGBILLQTY ,a.GSPNO,a.GSPDATE ,a.GSPQTY ,b.BANKLCNO,a.BLDATE,a.INVOICEVALUE,
		a.orderno,a.docsubdate,D.CLIENTNAME
    from T_Shipmentinfo a,T_lcinfo b,T_CLIENT D
    where a.lcno=b.lcno and   
		B.CLIENTID=D.CLIENTID(+) AND
		b.explctypeid=2 and		
		A.INVOICEDATE between vSDate and vEDate
	order by a.INVOICENO,a.INVOICEDATE;
  End If;   
END LC11and12;
/


PROMPT CREATE OR REPLACE Procedure  192 ::LC14
CREATE OR REPLACE Procedure LC14
(
  data_cursor IN OUT pReturnData.c_Records,
  pQtype in number,  
  sDate IN VARCHAR2,
  eDate IN VARCHAR2
)
AS
vSDate date;
vEDate date;
BEGIN
  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  else
	vSDate := TO_DATE('01-JAN-2000', 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  else
	vEDate := TO_DATE('01-JAN-2050', 'DD/MM/YYYY');
  end if;
  /*Local LC (FS)*/
  if(pQtype=14) then
    open data_cursor for
    select  a.BANKLCNO,b.CLIENTNAME,e.CurrencyName,a.RECEIVEDATE,a.LCEXPIRYDATE,a.LCORDERQTY,a.LCORDERAMT,
        c.InvoiceDate,c.INVOICENO,c.FDBC,c.PARTYACCEPTDATE,c.IFDBP,c.PURCHASEDATE,
		c.PARTYACCOUNT,c.PUREXCHRATE,c.AMOUNTTK,d.BANKNAME,c.PAYRECEIVEAMT    
    from T_lcinfo a,T_CLIENT b,T_LcPayment c,T_LCBank d,T_Currency e
    where a.LCNO=c.LCNO(+) and 
	    a.CLIENTID=b.CLIENTID(+) AND
	    a.BANKID=d.BANKID(+) and
		a.CURRENCYID=e.CURRENCYID(+) and
		a.explctypeid=1 and		
		a.RECEIVEDATE between vSDate and vEDate
	order by a.BANKLCNO;	
  End If;   
END LC14;
/

PROMPT CREATE OR REPLACE Procedure  193 ::TB03Payment
CREATE OR REPLACE Procedure TB03Payment(
  data_cursor IN OUT pReturnData.c_Records,
  pOrdercode IN VARCHAR2,
  pBillno in number,
  pClientId in varchar2,  
  pSDate IN VARCHAR2, 
  pEDate IN VARCHAR2   
) 
AS 
  vSDate date;
  vEDate date; 
BEGIN 
  if not pSDate is null then
    vSDate := TO_DATE(pSDate, 'DD/MM/YYYY');
  else
    vSDate := TO_DATE('01-JAN-2000', 'DD/MM/YYYY');
  end if;
  if not pEDate is null then
    vEDate := TO_DATE(pEDate, 'DD/MM/YYYY');
  else
    vEDate := TO_DATE('01-JAN-2900', 'DD/MM/YYYY');
  end if;
OPEN data_cursor  FOR        /*USED FOR SB03*/
    select A.BILLNO,A.ORDERCODE,A.BILLDATE,getfncWOBType(c.ORDERNO) AS WORDER,
	nvl(sum(DECODE(c.BILLITEMSQTY,0,(c.SQTY*c.BILLITEMSUNITPRICE*a.conrate),(c.BILLITEMSQTY*c.BILLITEMSUNITPRICE*a.conrate))),0) as billitemsamt,     
    nvl((select NVL(sum(B.BILLWOPMT),0) from T_BILLPAYMENT b 
		where A.BILLNO=b.BILLNO AND	A.ORDERCODE=b.ORDERCODE AND b.ORDERNO=c.ORDERNO
		group by A.ORDERCODE,A.BILLNO),0) AS BILLWOPMT,
		D.CLIENTNAME,A.CONRATE,E.CURRENCYNAME	
    from T_Bill A,T_BillItems c,T_CLIENT D,T_CURRENCY E 
	where A.BILLNO=c.BILLNO AND	    
        A.ORDERCODE=c.ORDERCODE AND	
		A.CLIENTID=D.CLIENTID(+) AND
		A.CURRENCYID=E.CURRENCYID(+) AND
        (pOrdercode IS NULL OR A.ORDERCODE=pOrdercode) AND	
		(pBillno IS NULL OR A.BILLNO=pBillno) AND	
        (pClientId is null or A.CLIENTID=pClientId) and		
		A.BILLDATE BETWEEN vSDate and vEDate 
	group by A.ORDERCODE,A.BILLNO,A.BILLDATE,D.CLIENTNAME,c.ORDERNO,A.CONRATE,E.CURRENCYNAME
	order by A.ORDERCODE,A.BILLNO,D.CLIENTNAME,getfncWOBType(c.ORDERNO);
END TB03Payment; 
/




PROMPT CREATE OR REPLACE Procedure  194 ::getKDFGProdSummary
CREATE OR REPLACE Procedure getKDFGProdSummary(
  data_cursor IN OUT pReturnData.c_Records, 
  pQType in number,  
  pSDate IN VARCHAR2  DEFAULT NULL, 
  pEDate IN VARCHAR2  DEFAULT NULL 
) 
AS 
  vSDate date;
  vEDate date; 
BEGIN 
  if not pSDate is null then
    vSDate := TO_DATE(pSDate, 'DD/MM/YYYY');
  end if;
  if not pEDate is null then
    vEDate := TO_DATE(pEDate, 'DD/MM/YYYY');
  end if;
 if (pQType=1) then /*In house F17.rpt*/
 OPEN data_cursor  FOR
  select a.STOCKTRANSNO,a.STOCKTRANSDATE,to_char(a.STOCKTRANSDATE,'MM') as Smonth,to_char(a.STOCKTRANSDATE,'YYYY') as SYear,to_char(a.STOCKTRANSDATE,'MONTH')||'-'||to_char(a.STOCKTRANSDATE,'YYYY') as MonthYear,
    d.BASICTYPEID,getfncWOBType(b.ORDERNO) as Dworkorder,
 sum(decode(a.KNTITRANSACTIONTYPEID,6,b.Quantity,24,b.Quantity,0)) FabKnittingProdQty,
 sum(decode(a.KNTITRANSACTIONTYPEID,19,b.Quantity,0)) FabDyeingProdQty,
 sum(decode(a.KNTITRANSACTIONTYPEID,20,b.Quantity,0)) FabFinishingProdQty,
 0 as  FabRMGProdQty,
 sum(decode(a.KNTITRANSACTIONTYPEID,6,b.Quantity,24,b.Quantity,19,b.Quantity,20,b.Quantity,0)) TotalProdQty,
 DECODE(to_char(a.STOCKTRANSDATE,'MM'),1,'1ST_SIX',2,'1ST_SIX',3,'1ST_SIX',4,'1ST_SIX',5,'1ST_SIX',6,'1ST_SIX',7,'2ND_SIX',8,'2ND_SIX',9,'2ND_SIX',10,'2ND_SIX',11,'2ND_SIX',12,'2ND_SIX') AS SIX_MONTH
 from T_Knitstock a, T_KnitStockItems b,T_workorder d
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID in (6,24,19,20) and
    b.ORDERNO=d.ORDERNO and
    a.STOCKTRANSDATE between decode(vSDate,null,'01-JAN-2000',vSDate) and vEDate and
    b.ORDERNO>0
    group by a.STOCKTRANSNO,a.STOCKTRANSDATE,to_char(a.STOCKTRANSDATE,'MM'),to_char(a.STOCKTRANSDATE,'YYYY'),to_char(a.STOCKTRANSDATE,'MONTH')||'-'||to_char(a.STOCKTRANSDATE,'YYYY'),
    d.BASICTYPEID,b.ORDERNO
    order by to_char(a.STOCKTRANSDATE,'YYYY'),to_char(a.STOCKTRANSDATE,'MM');
	
 elsif (pQType=2) then /*In house F18.rpt*/
 
 OPEN data_cursor  FOR
  select a.STOCKTRANSDATE,to_char(a.STOCKTRANSDATE,'MM') as Smonth,to_char(a.STOCKTRANSDATE,'YYYY') as SYear,to_char(a.STOCKTRANSDATE,'MONTH')||'-'||to_char(a.STOCKTRANSDATE,'YYYY') as MonthYear,
    d.BASICTYPEID,getfncWOBType(b.ORDERNO) as Dworkorder,
 sum(decode(a.KNTITRANSACTIONTYPEID,6,b.Quantity,24,b.Quantity,0)) FabKnittingProdQty,
 sum(decode(a.KNTITRANSACTIONTYPEID,19,b.Quantity,0)) FabDyeingProdQty,
 sum(decode(a.KNTITRANSACTIONTYPEID,20,b.Quantity,0)) FabFinishingProdQty,
 0 as  FabRMGProdQty,
 sum(decode(a.KNTITRANSACTIONTYPEID,6,b.Quantity,24,b.Quantity,19,b.Quantity,20,b.Quantity,0)) TotalProdQty,
 DECODE(to_char(a.STOCKTRANSDATE,'MM'),1,'1ST_SIX',2,'1ST_SIX',3,'1ST_SIX',4,'1ST_SIX',5,'1ST_SIX',6,'1ST_SIX',7,'2ND_SIX',8,'2ND_SIX',9,'2ND_SIX',10,'2ND_SIX',11,'2ND_SIX',12,'2ND_SIX') AS SIX_MONTH
 from T_Knitstock a, T_KnitStockItems b,T_workorder d
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID in (6,24,19,20) and
    b.ORDERNO=d.ORDERNO and
    a.STOCKTRANSDATE between decode(vSDate,null,'01-JAN-2000',vSDate) and vEDate and
    b.ORDERNO>0
    group by a.STOCKTRANSDATE,to_char(a.STOCKTRANSDATE,'MM'),to_char(a.STOCKTRANSDATE,'YYYY'),to_char(a.STOCKTRANSDATE,'MONTH')||'-'||to_char(a.STOCKTRANSDATE,'YYYY'),
    d.BASICTYPEID,b.ORDERNO
    order by to_char(a.STOCKTRANSDATE,'YYYY'),to_char(a.STOCKTRANSDATE,'MM');
	
elsif (pQType=3) then /*In house F19.rpt*/
 
 OPEN data_cursor  FOR
  select to_char(a.STOCKTRANSDATE,'MM') as Smonth,to_char(a.STOCKTRANSDATE,'YYYY') as SYear,to_char(a.STOCKTRANSDATE,'MONTH')||'-'||to_char(a.STOCKTRANSDATE,'YYYY') as MonthYear,
    d.BASICTYPEID,getfncWOBType(b.ORDERNO) as Dworkorder,
 sum(decode(a.KNTITRANSACTIONTYPEID,6,b.Quantity,24,b.Quantity,0)) FabKnittingProdQty,
 sum(decode(a.KNTITRANSACTIONTYPEID,19,b.Quantity,0)) FabDyeingProdQty,
 sum(decode(a.KNTITRANSACTIONTYPEID,20,b.Quantity,0)) FabFinishingProdQty,
 0 as  FabRMGProdQty,
 sum(decode(a.KNTITRANSACTIONTYPEID,6,b.Quantity,24,b.Quantity,19,b.Quantity,20,b.Quantity,0)) TotalProdQty,
 DECODE(to_char(a.STOCKTRANSDATE,'MM'),1,'1ST_SIX',2,'1ST_SIX',3,'1ST_SIX',4,'1ST_SIX',5,'1ST_SIX',6,'1ST_SIX',7,'2ND_SIX',8,'2ND_SIX',9,'2ND_SIX',10,'2ND_SIX',11,'2ND_SIX',12,'2ND_SIX') AS SIX_MONTH
 from T_Knitstock a, T_KnitStockItems b,T_workorder d
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID in (6,24,19,20) and
    b.ORDERNO=d.ORDERNO and
    a.STOCKTRANSDATE between decode(vSDate,null,'01-JAN-2000',vSDate) and vEDate and
    b.ORDERNO>0
    group by to_char(a.STOCKTRANSDATE,'MM'),to_char(a.STOCKTRANSDATE,'YYYY'),to_char(a.STOCKTRANSDATE,'MONTH')||'-'||to_char(a.STOCKTRANSDATE,'YYYY'),
    d.BASICTYPEID,b.ORDERNO
    order by to_char(a.STOCKTRANSDATE,'YYYY'),to_char(a.STOCKTRANSDATE,'MM');
End if;
END getKDFGProdSummary;
/



PROMPT CREATE OR REPLACE Procedure  195 ::FD03
create or replace Procedure FD03(
  data_cursor IN OUT pReturnData.c_Records,
  pQtype in number,
  pSDate IN VARCHAR2,
  pEDate  IN VARCHAR2
)
AS
  vSDate date;
  vEDate date;
BEGIN
  if not pSDate is null then
    vSDate := TO_DATE(pSDate, 'DD/MM/YYYY');
  else
    vSDate := TO_DATE('01-JAN-2000', 'DD/MM/YYYY');
  end if;
  if not pEDate is null then
    vEDate := TO_DATE(pEDate, 'DD/MM/YYYY');
  else
    vEDate := TO_DATE('01-JAN-2050', 'DD/MM/YYYY');
  end if;
if(pQtype=1) then
  open data_cursor for
    select to_char(a.INVOICEDATE,'MM') as smonth,to_char(a.INVOICEDATE,'YYYY') as syear,
       to_char(a.INVOICEDATE,'MONTH')||'-'||to_char(a.INVOICEDATE,'YYYY') as MonthYear,
     sum(decode(a.DTYPE,17,b.QUANTITY,0)) as GFDQTY,
        sum(decode(a.DTYPE,21,b.QUANTITY,0)) as FFDQTY,
     sum(decode(a.DTYPE,41,b.QUANTITY,0)) as DFDQTY,
     sum(decode(a.DTYPE,41,a.DTYPE,17,a.DTYPE,21,b.QUANTITY,0)) as TOTQTY,
     sum(decode(a.DTYPE,17,b.SQUANTITY,0)) as GFDSQTY,
        sum(decode(a.DTYPE,21,b.SQUANTITY,0)) as FFDSQTY,
     sum(decode(a.DTYPE,41,b.SQUANTITY,0)) as DFDSQTY,
     sum(decode(a.DTYPE,41,a.DTYPE,17,a.DTYPE,21,b.SQUANTITY,0)) as TOTSQTY
    from T_Dinvoice a,T_DinvoiceItems b
    where a.DINVOICEID=b.DINVOICEID and
  a.INVOICEDATE between vSDate and vEDate
 group by to_char(a.INVOICEDATE,'MM'),to_char(a.INVOICEDATE,'YYYY'),
       to_char(a.INVOICEDATE,'MONTH')||'-'||to_char(a.INVOICEDATE,'YYYY')
 order by to_char(a.INVOICEDATE,'YYYY'),to_char(a.INVOICEDATE,'MM');
end if;
END FD03;
/


PROMPT CREATE OR REPLACE Procedure  196 ::getFD03
CREATE OR REPLACE Procedure getFD03(
  data_cursor IN OUT pReturnData.c_Records, 
  pQType in number,  
  pSDate IN VARCHAR2  DEFAULT NULL, 
  pEDate IN VARCHAR2  DEFAULT NULL 
) 
AS 
  vSDate date;
  vEDate date; 
BEGIN 
  if not pSDate is null then
    vSDate := TO_DATE(pSDate, 'DD/MM/YYYY');
  end if;
  if not pEDate is null then
    vEDate := TO_DATE(pEDate, 'DD/MM/YYYY');
  end if;
 if (pQType=4) then /*Fabric Delivery to Outside FD04.rpt*/
 OPEN data_cursor  FOR
  select to_char(a.STOCKTRANSDATE,'MM') as Smonth,to_char(a.STOCKTRANSDATE,'YYYY') as SYear,to_char(a.STOCKTRANSDATE,'MONTH')||'-'||to_char(a.STOCKTRANSDATE,'YYYY') as MonthYear,
 d.BASICTYPEID,
 sum(decode(a.KNTITRANSACTIONTYPEID,17,b.Quantity,0)) GrayFabricDelPQty,
 sum(decode(a.KNTITRANSACTIONTYPEID,17,b.SQuantity,0)) GrayFabricDelSQty,
 sum(decode(a.KNTITRANSACTIONTYPEID,41,b.Quantity,0)) DyedFabricDelPQty,
 sum(decode(a.KNTITRANSACTIONTYPEID,41,b.SQuantity,0)) DyedFabricDelSQty,
 sum(decode(a.KNTITRANSACTIONTYPEID,21,b.Quantity,0)) FinishFabricDelPQty, 
 sum(decode(a.KNTITRANSACTIONTYPEID,21,b.SQuantity,0)) FinishFabricDelSQty,
 sum(decode(a.KNTITRANSACTIONTYPEID,17,b.Quantity,41,b.Quantity,21,b.Quantity,0)) TotalFabricDeliveryPQty,
 sum(decode(a.KNTITRANSACTIONTYPEID,17,b.SQuantity,41,b.SQuantity,21,b.SQuantity,0)) TotalFabricDeliverySQty,
 DECODE(to_char(a.STOCKTRANSDATE,'MM'),1,'1ST_SIX',2,'1ST_SIX',3,'1ST_SIX',4,'1ST_SIX',5,'1ST_SIX',6,'1ST_SIX',7,'2ND_SIX',8,'2ND_SIX',9,'2ND_SIX',10,'2ND_SIX',11,'2ND_SIX',12,'2ND_SIX') AS SIX_MONTH
 from T_Knitstock a, T_KnitStockItems b,T_workorder d
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID in (17,41,21) and
    b.ORDERNO=d.ORDERNO and
    a.STOCKTRANSDATE between decode(vSDate,null,'01-JAN-2000',vSDate) and vEDate and
    b.ORDERNO>0
    group by to_char(a.STOCKTRANSDATE,'MM'),to_char(a.STOCKTRANSDATE,'YYYY'),to_char(a.STOCKTRANSDATE,'MONTH')||'-'||to_char(a.STOCKTRANSDATE,'YYYY'),
    d.BASICTYPEID
    order by to_char(a.STOCKTRANSDATE,'YYYY'),to_char(a.STOCKTRANSDATE,'MM');	
elsif(pQType=5) then  /*Fabric Delivery to ATL RMG FD05.rpt*/
 OPEN data_cursor  FOR
  select to_char(a.STOCKTRANSDATE,'MM') as Smonth,to_char(a.STOCKTRANSDATE,'YYYY') as SYear,to_char(a.STOCKTRANSDATE,'MONTH')||'-'||to_char(a.STOCKTRANSDATE,'YYYY') as MonthYear,
    '' as ORDERTYPEID,getfncDispalyorder(b.ORDERNO) as Dworkorder,getfncWOBType(e.ORDERNO) as TWorkorder,
 0 as GrayFabricDelPQty,
 0 as GrayFabricDelSQty,
 0 as DyedFabricDelPQty,
 0 as DyedFabricDelSQty,
 sum(decode(b.GTRANSTYPEID,1,b.Quantity,27,-b.Quantity,0)) FinishFabricDelPQty, 
 sum(decode(b.GTRANSTYPEID,1,b.SQuantity,27,-b.SQuantity,0)) FinishFabricDelSQty,
 sum(decode(b.GTRANSTYPEID,1,b.Quantity,27,-b.Quantity,0)) TotalFabricDeliveryPQty,
 sum(decode(b.GTRANSTYPEID,1,b.SQuantity,27,-b.SQuantity,0)) TotalFabricDeliverySQty,
 DECODE(to_char(a.STOCKTRANSDATE,'MM'),1,'1ST_SIX',2,'1ST_SIX',3,'1ST_SIX',4,'1ST_SIX',5,'1ST_SIX',6,'1ST_SIX',7,'2ND_SIX',8,'2ND_SIX',9,'2ND_SIX',10,'2ND_SIX',11,'2ND_SIX',12,'2ND_SIX') AS SIX_MONTH
 from T_GSTOCK a, T_GSTOCKITEMS b,T_GWorkorder d, T_Workorder e
    where a.StockID=b.StockID and
    b.GTRANSTYPEID in (1,27) and
    b.ORDERNO=d.GORDERNO and
	b.ORDERNO=e.GARMENTSORDERREF and
    a.STOCKTRANSDATE between decode(vSDate,null,'01-JAN-2000',vSDate) and vEDate and
    b.ORDERNO>0
    group by to_char(a.STOCKTRANSDATE,'MM'),to_char(a.STOCKTRANSDATE,'YYYY'),to_char(a.STOCKTRANSDATE,'MONTH')||'-'||to_char(a.STOCKTRANSDATE,'YYYY'),
    d.ORDERTYPEID,b.ORDERNO,e.ORDERNO
    order by to_char(a.STOCKTRANSDATE,'YYYY'),to_char(a.STOCKTRANSDATE,'MM');	
end if;
END getFD03;
/


PROMPT CREATE OR REPLACE Procedure  197 ::GetKN05
CREATE OR REPLACE Procedure GetKN05
(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pPARTID IN number,
  sDate IN VARCHAR2,
  eDate IN VARCHAR2
)
AS
  vSDate date;
  vEDate date;
BEGIN
  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  else
   vSDate := TO_DATE('01/01/1900', 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  else
   vEDate := TO_DATE('01/01/2100', 'DD/MM/YYYY');
  end if;
if pQueryType=5 then
	open data_cursor for
            select a.STOCKID,a.STOCKDATE,a.CHALLANNO,a.CHALLANDATE,a.PURCHASEORDERNO,a.PURCHASEORDERDATE,
			b.PARTID,c.PARTNAME,MCTYPENAME,c.MCPARTSTYPEID,f.MCPARTSTYPE,b.KMCSTOCKTYPEID,b.mACHINEID,
			(b.QTY) as MainIn,0 as Issue2Floor,0 as ReturnFromFloor,0 as Floor2Machine,0 as BR_Return2HO
			from T_KmcPartsTran a,t_kmcpartstransdetails b,t_kmcpartsinfo c,t_kmcstockStatus d,t_kmctype e,
			T_MCPARTSTYPE f
			where a.STOCKID=b.StockId and b.PARTID=c.PARTID and B.KMCSTOCKTYPEID=d.KMCSTOCKTYPEID and
			b.PARTSSTATUSFROMID=d.PARTSSTATUSFROMID and b.PARTSSTATUSTOID=d.PARTSSTATUSTOID and
			c.MCPARTSTYPEID=f.MCPARTSTYPEID and c.MCTYPEID=e.MCTYPEID and b.KMCSTOCKTYPEID=1 and
	        b.PARTID=pPARTID and
            /*c.MCPARTSTYPEID=pMCPARTSTYPEID and  (pMACHINEID is null or b.MACHINEID=pMACHINEID) and*/
           a.StockDate Between decode(VsDate,null,'01-JAN-2000',VsDate) and decode(VeDate,null,'01-JAN-2050',VeDate)
	union all
            select a.STOCKID,a.STOCKDATE,a.CHALLANNO,a.CHALLANDATE,a.PURCHASEORDERNO,a.PURCHASEORDERDATE,
			b.PARTID,c.PARTNAME,MCTYPENAME,c.MCPARTSTYPEID,f.MCPARTSTYPE,b.KMCSTOCKTYPEID,b.mACHINEID,
		   0 as MainIn,(b.QTY) as Issue2Floor,0 as ReturnFromFloor,0 as Floor2Machine,0 as BR_Return2HO
            from T_KmcPartsTran a,t_kmcpartstransdetails b,t_kmcpartsinfo c,t_kmcstockStatus d,t_kmctype e,
			T_MCPARTSTYPE f
            where a.STOCKID=b.StockId and b.PARTID=c.PARTID and B.KMCSTOCKTYPEID=d.KMCSTOCKTYPEID and
		    b.PARTSSTATUSFROMID=d.PARTSSTATUSFROMID and b.PARTSSTATUSTOID=d.PARTSSTATUSTOID and
            c.MCPARTSTYPEID=f.MCPARTSTYPEID and c.MCTYPEID=e.MCTYPEID and b.KMCSTOCKTYPEID=2 and
		    b.PARTID=pPARTID and
            a.StockDate Between decode(VsDate,null,'01-JAN-2000',VsDate) and VeDate
	union all
            select a.STOCKID,a.STOCKDATE,a.CHALLANNO,a.CHALLANDATE,a.PURCHASEORDERNO,a.PURCHASEORDERDATE,
			b.PARTID,c.PARTNAME,MCTYPENAME,c.MCPARTSTYPEID,f.MCPARTSTYPE,b.KMCSTOCKTYPEID,b.mACHINEID,
		    0 as MainIn,0 as Issue2Floor,(b.QTY) as ReturnFromFloor,0 as Floor2Machine,0 as BR_Return2HO
            from T_KmcPartsTran a,t_kmcpartstransdetails b,t_kmcpartsinfo c,
			t_kmcstockStatus d,t_kmctype e,	T_MCPARTSTYPE f
            where a.STOCKID=b.StockId and b.PARTID=c.PARTID and B.KMCSTOCKTYPEID=d.KMCSTOCKTYPEID and
		    b.PARTSSTATUSFROMID=d.PARTSSTATUSFROMID and b.PARTSSTATUSTOID=d.PARTSSTATUSTOID and
		    c.MCPARTSTYPEID=f.MCPARTSTYPEID and c.MCTYPEID=e.MCTYPEID and b.KMCSTOCKTYPEID=3 and
		    b.PARTID=pPARTID and a.StockDate Between decode(VsDate,null,'01-JAN-2000',VsDate) and
			decode(VeDate,null,'01-JAN-2050',VeDate)
	union all
			select a.STOCKID,a.STOCKDATE,a.CHALLANNO,a.CHALLANDATE,a.PURCHASEORDERNO,a.PURCHASEORDERDATE,
			b.PARTID,c.PARTNAME,MCTYPENAME,c.MCPARTSTYPEID,f.MCPARTSTYPE,b.KMCSTOCKTYPEID,b.mACHINEID,
			0 as MainIn,0 as Issue2Floor,(b.QTY) as ReturnFromFloor,0 as Floor2Machine,0 as BR_Return2HO
			from T_KmcPartsTran a,t_kmcpartstransdetails b,t_kmcpartsinfo c,t_kmcstockStatus d,t_kmctype e,
			T_MCPARTSTYPE f
			where a.STOCKID=b.StockId and b.PARTID=c.PARTID and B.KMCSTOCKTYPEID=d.KMCSTOCKTYPEID and
			b.PARTSSTATUSFROMID=d.PARTSSTATUSFROMID and b.PARTSSTATUSTOID=d.PARTSSTATUSTOID and
			c.MCPARTSTYPEID=f.MCPARTSTYPEID and c.MCTYPEID=e.MCTYPEID and b.KMCSTOCKTYPEID=9 and
			b.PARTID=pPARTID and a.StockDate Between decode(VsDate,null,'01-JAN-2000',VsDate) and
			decode(VeDate,null,'01-JAN-2050',VeDate)
	union all
            select a.STOCKID,a.STOCKDATE,a.CHALLANNO,a.CHALLANDATE,a.PURCHASEORDERNO,a.PURCHASEORDERDATE,
			b.PARTID,c.PARTNAME,MCTYPENAME,c.MCPARTSTYPEID,f.MCPARTSTYPE,b.KMCSTOCKTYPEID,b.mACHINEID,
			0 as MainIn,0 as Issue2Floor,0 as ReturnFromFloor,0 as Floor2Machine,(b.QTY)as BR_Return2HO
			from T_KmcPartsTran a,t_kmcpartstransdetails b,t_kmcpartsinfo c,t_kmcstockStatus d,t_kmctype e,
			T_MCPARTSTYPE f
			where a.STOCKID=b.StockId and b.PARTID=c.PARTID and B.KMCSTOCKTYPEID=d.KMCSTOCKTYPEID and
			b.PARTSSTATUSFROMID=d.PARTSSTATUSFROMID and b.PARTSSTATUSTOID=d.PARTSSTATUSTOID and
			c.MCPARTSTYPEID=f.MCPARTSTYPEID and c.MCTYPEID=e.MCTYPEID and b.KMCSTOCKTYPEID=11 and
			b.PARTID=pPARTID and 
			a.StockDate Between decode(VsDate,null,'01-JAN-2000',VsDate) and decode(VeDate,null,'01-JAN-2050',VeDate);
elsif pQueryType=6 then
	/* for KN06.rpt FOR Consumption*/
  	OPEN data_cursor  FOR
           Select b.PARTID,c.PARTNAME,DESCRIPTION,WAVGPRICE,MCTYPENAME,c.MCPARTSTYPEID,f.MCPARTSTYPE,
			(Select sum(decode(y.KMCSTOCKTYPEID,1,y.QTY,2,-y.QTY,3,y.QTY,4,-y.QTY,5,y.QTY,6,y.QTY,7,-y.QTY,8,-y.QTY,11,-y.QTY,0))
			from T_KmcPartsTran x,T_kmcpartstransdetails y
			where x.STOCKID=y.StockId and 
			y.PARTID=b.PARTID and 
			y.KMCSTOCKTYPEID in (1,2,3,4,5,6,7,8,9,11) And
			x.StockDate<=vEDate 
			Group By y.PARTID) as MainStock,
			/*sum(decode(b.KMCSTOCKTYPEID,2,b.QTY,3,-b.QTY,0)) as Consumption,*/
			nvl((Select sum(decode(y.KMCSTOCKTYPEID,3,y.QTY,0))
			from T_KmcPartsTran x,T_kmcpartstransdetails y
			where x.STOCKID=y.StockId and 
			y.PARTID=b.PARTID and 
			y.KMCSTOCKTYPEID in (3) And
			y.PARTSSTATUSTOID in (3,4) and
			x.StockDate Between VsDate and VeDate
			Group By y.PARTID),0) as Consumption,
			(nvl((Select sum(decode(y.KMCSTOCKTYPEID,3,y.QTY,0))
			from T_KmcPartsTran x,T_kmcpartstransdetails y
			where x.STOCKID=y.StockId and 
			y.PARTID=b.PARTID and 
			y.KMCSTOCKTYPEID in (3) And
			y.PARTSSTATUSTOID in (3,4) and
			x.StockDate Between VsDate and VeDate
			Group By y.PARTID),0)*WAVGPRICE) as TotalVal,
			sum(decode(b.KMCSTOCKTYPEID,1,b.QTY,0)) as MainIn,
			sum(decode(b.KMCSTOCKTYPEID,2,b.QTY,0)) as Issue2Floor,
			sum(decode(b.KMCSTOCKTYPEID,3,b.QTY,0)) as ReturnFromFloor,
			sum(decode(b.KMCSTOCKTYPEID,8,b.QTY,0)) as Floor2Machine,
			sum(decode(b.KMCSTOCKTYPEID,11,b.QTY,0)) as BR_Return2HO
			from T_KmcPartsTran a,T_kmcpartstransdetails b,T_kmcpartsinfo c,
			t_kmcstockStatus d,t_kmctype e,T_MCPARTSTYPE f
			where a.STOCKID=b.StockId and b.PARTID=c.PARTID and 
			B.KMCSTOCKTYPEID=d.KMCSTOCKTYPEID and
			b.PARTSSTATUSFROMID=d.PARTSSTATUSFROMID and 
			b.PARTSSTATUSTOID=d.PARTSSTATUSTOID and
			c.MCPARTSTYPEID=f.MCPARTSTYPEID and 
			c.MCTYPEID=e.MCTYPEID and 
			b.KMCSTOCKTYPEID in (1,2,3,9,11) and
			c.MCPARTSTYPEID=pPARTID and  /* pPARTID just like MCPARTSTYPEID*/
			a.StockDate Between VsDate and VeDate
		    Group By b.PARTID,c.PARTNAME,DESCRIPTION,WAVGPRICE,MCTYPENAME,c.MCPARTSTYPEID,f.MCPARTSTYPE	
			Order By c.PARTNAME;
  end if;
END GetKN05;
/


PROMPT CREATE OR REPLACE Procedure  198 ::GetGA002

Create or Replace Procedure GetGA002(
  data_cursor IN OUT pReturnData.c_Records,  
  pAccessoriesID IN NUMBER,
  sDate IN VARCHAR2,
  eDate IN VARCHAR2
)
AS
vSDate date;
vEDate date;
BEGIN
  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  end if;
/*Sub Stock*/
    open data_cursor for	
    select b.LineNo, a.StockTransNo,a.StockTransDate,i.item,(Quantity) MainStore,0 AS IssueToFloorSub, 0 as Production,0 as ReturnToMainStore,0 as AdjustmentPlus,0 as AdjustmentMinus,0 as ReturnToSupplier
    from T_AccStock a, T_AccStockItems b, T_accessories i
    where a.StockID=b.StockID and
    b.AccessoriesID=i.AccessoriesID and
    StockTransDate<=vEDate and
    a.AccTransTypeID = 1 and 
	b.AccessoriesID=pAccessoriesID
	UNION ALL
    select b.LineNo, a.StockTransNo,a.StockTransDate,i.item,0 AS MainStore,(Quantity) IssueToFloorSub, 0 as Production,0 as ReturnToMainStore,0 as AdjustmentPlus,0 as AdjustmentMinus,0 as ReturnToSupplier
    from T_AccStock a, T_AccStockItems b, T_accessories i
    where a.StockID=b.StockID and
    b.AccessoriesID=i.AccessoriesID and
    StockTransDate<=vEDate and
    a.AccTransTypeID = 2 and 
	b.AccessoriesID=pAccessoriesID
    UNION ALL
    select b.LineNo, a.StockTransNo,a.StockTransDate,i.item, 0 as MainStore, 0 AS IssueToFloorSub, (Quantity) Production, 0 as ReturnToMainStore,0 as AdjustmentPlus,0 as AdjustmentMinus,0 as ReturnToSupplier
    from T_AccStock a, T_AccStockItems b, T_accessories i
    where a.StockID=b.StockID and
    b.AccessoriesID=i.AccessoriesID and
    StockTransDate<=vEDate and
    a.AccTransTypeID = 3 and 
	b.AccessoriesID=pAccessoriesID
    UNION ALL
    select b.LineNo, a.StockTransNo,a.StockTransDate,i.item, 0 as MainStore, 0 AS IssueToFloorSub, 0 as Production, (Quantity) ReturnToMainStore,0 as AdjustmentPlus,0 as AdjustmentMinus,0 as ReturnToSupplier
    from T_AccStock a, T_AccStockItems b, T_accessories i
    where a.StockID=b.StockID and
    b.AccessoriesID=i.AccessoriesID and
    StockTransDate<=vEDate and
    a.AccTransTypeID = 4 and 
	b.AccessoriesID=pAccessoriesID	
	UNION ALL
    select b.LineNo, a.StockTransNo,a.StockTransDate,i.item,  0 as MainStore, 0 AS IssueToFloorSub, 0 as Production,0 as ReturnToMainStore, (Quantity) AdjustmentPlus,0 as AdjustmentMinus,0 as ReturnToSupplier
    from T_AccStock a, T_AccStockItems b, T_accessories i
    where a.StockID=b.StockID and
    b.AccessoriesID=i.AccessoriesID and
    StockTransDate<=vEDate and
    a.AccTransTypeID = 5 and 
	b.AccessoriesID=pAccessoriesID
	UNION ALL
    select b.LineNo, a.StockTransNo,a.StockTransDate,i.item, 0 as MainStore, 0 AS IssueToFloorSub, 0 as Production,0 as ReturnToMainStore,0 as AdjustmentPlus, (Quantity) AdjustmentMinus, 0 as ReturnToSupplier
    from T_AccStock a, T_AccStockItems b, T_accessories i
    where a.StockID=b.StockID and
    b.AccessoriesID=i.AccessoriesID and
    StockTransDate<=vEDate and
    a.AccTransTypeID = 6 and 
	b.AccessoriesID=pAccessoriesID
	UNION ALL
    select b.LineNo, a.StockTransNo,a.StockTransDate,i.item, 0 as MainStore, 0 AS IssueToFloorSub, 0 as Production,0 as ReturnToMainStore,0 as AdjustmentPlus,0 as AdjustmentMinus, (Quantity) ReturnToSupplier
    from T_AccStock a, T_AccStockItems b, T_accessories i
    where a.StockID=b.StockID and
    b.AccessoriesID=i.AccessoriesID and
    StockTransDate<=vEDate and
    a.AccTransTypeID = 7 and 
	b.AccessoriesID=pAccessoriesID; 
END GetGA002;
/


PROMPT CREATE OR REPLACE Procedure  199 :: GetGS02

Create or Replace Procedure GetGS02(
  data_cursor IN OUT pReturnData.c_Records,  
  pPartID IN NUMBER,
  sDate IN VARCHAR2,
  eDate IN VARCHAR2
)
AS
vSDate date;
vEDate date;
BEGIN
  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  end if;
/*Sub Stock*/
    open data_cursor for	
    select a.CHALLANNO,a.CHALLANDATE, i.PartID, i.PARTNAME, (QTY) MRR, 0 as MR, 0 as ReturnFromFloor, 0 as LoantoParty, 0 as LoanReturnFromParty, 0 as LoanFromParty, 0 as LoanReturnToParty, 0 as Rejection, 0 as FloorToMachine
    from T_GMcStock a, T_GMcStockItems b, T_GMcPartsInfo i
    where a.StockID=b.StockID and
    b.PartID=i.PartID and
    CHALLANDATE<=vEDate and
    a.TEXMCSTOCKTYPEID = 1 and 
	b.PartID=pPartID	
	UNION ALL
    select a.CHALLANNO,a.CHALLANDATE,i.PartID,i.PARTNAME, 0 as MRR, (QTY) MR, 0 as ReturnFromFloor, 0 as LoantoParty, 0 as LoanReturnFromParty, 0 as LoanFromParty, 0 as LoanReturnToParty, 0 as Rejection, 0 as FloorToMachine
    from T_GMcStock a, T_GMcStockItems b, T_GMcPartsInfo i
    where a.StockID=b.StockID and
    b.PartID=i.PartID and
    CHALLANDATE<=vEDate and
    a.TEXMCSTOCKTYPEID = 2 and 
	b.PartID=pPartID	
    UNION ALL
    select a.CHALLANNO,a.CHALLANDATE,i.PartID,i.PARTNAME, 0 as MRR, 0 as MR, (QTY) ReturnFromFloor, 0 as LoantoParty, 0 as LoanReturnFromParty, 0 as LoanFromParty, 0 as LoanReturnToParty, 0 as Rejection, 0 as FloorToMachine
    from T_GMcStock a, T_GMcStockItems b, T_GMcPartsInfo i
    where a.StockID=b.StockID and
    b.PartID=i.PartID and
    CHALLANDATE<=vEDate and
    a.TEXMCSTOCKTYPEID = 3 and 
	b.PartID=pPartID	
    UNION ALL
    select a.CHALLANNO,a.CHALLANDATE,i.PartID,i.PARTNAME, 0 as MRR, 0 as MR, 0 as ReturnFromFloor, (QTY) LoantoParty, 0 as LoanReturnFromParty, 0 as LoanFromParty, 0 as LoanReturnToParty, 0 as Rejection, 0 as FloorToMachine 
    from T_GMcStock a, T_GMcStockItems b, T_GMcPartsInfo i
    where a.StockID=b.StockID and
    b.PartID=i.PartID and
    CHALLANDATE<=vEDate and
    a.TEXMCSTOCKTYPEID = 4 and 
	b.PartID=pPartID	
	UNION ALL
    select a.CHALLANNO,a.CHALLANDATE,i.PartID,i.PARTNAME, 0 as MRR, 0 as MR, 0 as ReturnFromFloor, 0 as LoantoParty, (QTY) LoanReturnFromParty, 0 as LoanFromParty, 0 as LoanReturnToParty, 0 as Rejection, 0 as FloorToMachine  
    from T_GMcStock a, T_GMcStockItems b, T_GMcPartsInfo i
    where a.StockID=b.StockID and
    b.PartID=i.PartID and
    CHALLANDATE<=vEDate and
    a.TEXMCSTOCKTYPEID = 5 and 
	b.PartID=pPartID	
	UNION ALL
    select a.CHALLANNO,a.CHALLANDATE,i.PartID,i.PARTNAME, 0 as MRR, 0 as MR, 0 as ReturnFromFloor, 0 as LoantoParty, 0 as LoanReturnFromParty, (QTY) LoanFromParty, 0 as LoanReturnToParty, 0 as Rejection, 0 as FloorToMachine
    from T_GMcStock a, T_GMcStockItems b, T_GMcPartsInfo i
    where a.StockID=b.StockID and
    b.PartID=i.PartID and
    CHALLANDATE<=vEDate and
    a.TEXMCSTOCKTYPEID = 6 and 
	b.PartID=pPartID	
	UNION ALL
    select a.CHALLANNO,a.CHALLANDATE,i.PartID,i.PARTNAME,  0 as MRR, 0 as MR, 0 as ReturnFromFloor, 0 as LoantoParty, 0 as LoanReturnFromParty, 0 as LoanFromParty, (QTY) LoanReturnToParty, 0 as Rejection, 0 as FloorToMachine
    from T_GMcStock a, T_GMcStockItems b, T_GMcPartsInfo i
    where a.StockID=b.StockID and
    b.PartID=i.PartID and
    CHALLANDATE<=vEDate and
    a.TEXMCSTOCKTYPEID = 7 and 
	b.PartID=pPartID	
	UNION ALL
    select a.CHALLANNO,a.CHALLANDATE,i.PartID,i.PARTNAME, 0 as MRR, 0 as MR, 0 as ReturnFromFloor, 0 as LoantoParty, 0 as LoanReturnFromParty, 0 as LoanFromParty, 0 as LoanReturnToParty, (QTY) Rejection, 0 as FloorToMachine
    from T_GMcStock a, T_GMcStockItems b, T_GMcPartsInfo i
    where a.StockID=b.StockID and
    b.PartID=i.PartID and
    CHALLANDATE<=vEDate and
    a.TEXMCSTOCKTYPEID = 8 and 
	b.PartID=pPartID	
	UNION ALL
    select a.CHALLANNO,a.CHALLANDATE,i.PartID,i.PARTNAME, 0 as MRR, 0 as MR, 0 as ReturnFromFloor, 0 as LoantoParty, 0 as LoanReturnFromParty, 0 as LoanFromParty, 0 as LoanReturnToParty, 0 as Rejection, (QTY) FloorToMachine
    from T_GMcStock a, T_GMcStockItems b, T_GMcPartsInfo i
    where a.StockID=b.StockID and
    b.PartID=i.PartID and
    CHALLANDATE<=vEDate and
    a.TEXMCSTOCKTYPEID = 9 and 
	b.PartID=pPartID
	order by CHALLANDATE; 
END GetGS02;
/


PROMPT CREATE OR REPLACE Procedure  200 :: GETTEMP13
CREATE OR REPLACE Procedure GETTEMP13(
  data_cursor IN OUT pReturnData.c_Records,
  pPartsID IN NUMBER,
  PsDate IN VARCHAR2,
  pEDate IN VARCHAR2
) 
AS 
  vSDate DATE;
  vEDate DATE;

  
 BEGIN 
   if not pSDate is null then
    vSDate := TO_DATE(pSDate, 'DD/MM/YYYY');
  else
    vSDate := TO_DATE('01/01/1900', 'DD/MM/YYYY');
  end if;
  if not pEDate is null then
    vEDate := TO_DATE(pEDate, 'DD/MM/YYYY');
  else
    vEDate := TO_DATE('01/01/2300', 'DD/MM/YYYY');
  end if;

 OPEN data_cursor  FOR
			
			select MachineType,PartName,StockDate,CHALLANNO,CHALLANDATE,a.PARTID,ForeignPart,Description,UNITOFMEAS,  
			QTY as Receive,0 as issue,0 as Ret
			from T_TexMcPartsInfo a,T_UnitOfMeas b,T_TexMcStockItems c,T_TexMcStock d,T_TexMcStockType e
			where b.UnitOfMeasId=a.UnitOfMeasId and
			c.StockId=d.StockId and 
			d.TEXMCSTOCKTYPEID=1 and
			e.TEXMCSTOCKTYPEID=d.TEXMCSTOCKTYPEID and
			a.PARTID=c.PARTID and
			a.PARTID=pPartsID and
			StockDate Between decode(VsDate,null,'01-JAN-2000',VsDate) and decode(VeDate,null,'01-JAN-2050',VeDate)	
	union all			
			select MachineType,PartName,StockDate,CHALLANNO,CHALLANDATE,a.PARTID,ForeignPart,Description,UNITOFMEAS, 
			0 as Receive,QTY as issue,0 as Ret
			from T_TexMcPartsInfo a,T_UnitOfMeas b,T_TexMcStockItems c,T_TexMcStock d,T_TexMcStockType e
			where b.UnitOfMeasId=a.UnitOfMeasId and
			c.StockId=d.StockId and 
			d.TEXMCSTOCKTYPEID=2 and
			e.TEXMCSTOCKTYPEID=d.TEXMCSTOCKTYPEID and
			a.PARTID=c.PARTID and
			a.PARTID=pPartsID and
			StockDate Between decode(VsDate,null,'01-JAN-2000',VsDate) and decode(VeDate,null,'01-JAN-2050',VeDate)			
         union all
			select MachineType,PartName,StockDate,CHALLANNO,CHALLANDATE,a.PARTID,ForeignPart,Description,UNITOFMEAS, 
			0 as Receive,0 as issue,QTY as Ret
			from T_TexMcPartsInfo a,T_UnitOfMeas b,T_TexMcStockItems c,T_TexMcStock d,T_TexMcStockType e
			where b.UnitOfMeasId=a.UnitOfMeasId and
			c.StockId=d.StockId and 
			d.TEXMCSTOCKTYPEID=3 and
			e.TEXMCSTOCKTYPEID=d.TEXMCSTOCKTYPEID and
			a.PARTID=c.PARTID and
			a.PARTID=pPartsID and
			StockDate Between decode(VsDate,null,'01-JAN-2000',VsDate) and decode(VeDate,null,'01-JAN-2050',VeDate);
			
  
END GETTEMP13; 
/




/* Genearl Stock Item wise Search " S002GStationeryStock"  Naim */
PROMPT CREATE OR REPLACE Procedure  201 :: S002GStationeryStock
CREATE OR REPLACE Procedure S002GStationeryStock (
  data_cursor IN OUT pReturnData.c_Records,
  pStationaryID in number,
  sDate IN VARCHAR2,
  eDate IN VARCHAR2
)
AS
  vSDate date;
  vEDate date;
  BEGIN
  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  else
   vSDate := TO_DATE('01/01/1900', 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  else
   vEDate := TO_DATE('01/01/2100', 'DD/MM/YYYY');
  end if;
  OPEN data_cursor FOR
		Select h.REQID as STOCKID,REQNO as STOCKTRANSNO,h.REQDATE as STOCKTRANSDATE,'' AS DEPTNAME,'' AS COUNTRYNAME,
		e.Unitofmeas,h.GROUPNAME,f.ITEM,0 as STATIONERYID,g.BRANDNAME,
		0 as ReceiveQty,
		0 as IssueQty,
		sum(i.QUANTITY)  as PurchseQty
		from T_Unitofmeas e,T_Stationery f,T_Brand g,T_PurchaseReq h,T_PurchaseReqItems i,T_STATIONERYGROUP h
		where h.REQID= i.REQID   and
		i.GroupID=h.GroupID and
		i.ITEMID=f.STATIONERYID(+) and
		i.PUNITOFMEASID=e.UNITOFMEASID(+) and
		i.BRANDID=g.BRANDID(+) and
		(pStationaryID is NULL or i.ITEMID=pStationaryID) and
		h.REQDATE  between vSDate and vEDate
		Group By h.REQID,REQNO,h.REQDATE,
		e.Unitofmeas,h.GROUPNAME,f.ITEM,g.BRANDNAME
		Having sum(i.QUANTITY)>0 
  union all  
		SELECT a.STOCKID,a.STOCKTRANSNO,a.STOCKTRANSDATE,c.DEPTNAME,d.COUNTRYNAME,
		e.Unitofmeas,h.GROUPNAME,f.ITEM,f.STATIONERYID,g.BRANDNAME,
        SUM(decode (b.TRANSTYPEID,1,b.QUANTITY,0)) as ReceiveQty,
		SUM(decode (b.TRANSTYPEID,4,b.QUANTITY,0)) as IssueQty,
		0 as PurchseQty		
	from T_Stationerystock a,T_StationerystockItems b,T_Department c,T_Country d,T_Unitofmeas e,T_Stationery f,T_Brand g,T_STATIONERYGROUP h
	where a.Stockid=b.Stockid and
	f.GroupID=h.GroupID and
	b.DEPTID=c.DEPTID(+) and
	b.COUNTRYID=d.COUNTRYID(+) and
	b.PUNITOFMEASID=e.UNITOFMEASID(+) and
	b.STATIONERYID=f.STATIONERYID(+) and
	b.BRANDID=g.BRANDID(+) and
	b.TRANSTYPEID in (1,4) and
	(pStationaryID is NULL or b.STATIONERYID=pStationaryID) and
	a.STOCKTRANSDATE between vSDate and vEDate
	Group by a.STOCKID,a.STOCKTRANSNO,a.STOCKTRANSDATE,c.DEPTNAME,d.COUNTRYNAME,
	e.Unitofmeas,h.GROUPNAME,f.ITEM,f.STATIONERYID,g.BRANDNAME
	Having SUM(decode (b.TRANSTYPEID,1,b.QUANTITY,0))>0 or SUM(decode (b.TRANSTYPEID,4,b.QUANTITY,0))>0;
  End S002GStationeryStock;
  /


PROMPT CREATE OR REPLACE Procedure  202 :: GetKN05
CREATE OR REPLACE Procedure GetKN05
(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,  
  pMCPARTSTYPEID in number,  
  pMACHINEID in number,
  pPARTID IN number,
  sDate IN VARCHAR2,
  eDate IN VARCHAR2
)
AS
  vSDate date;
  vEDate date;

BEGIN
  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  else
   vSDate := TO_DATE('01/01/1900', 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  else
   vEDate := TO_DATE('01/01/2100', 'DD/MM/YYYY');
  end if;

if pQueryType=5 then
 open data_cursor for
            select a.STOCKID,a.STOCKDATE,a.CHALLANNO,a.CHALLANDATE,a.PURCHASEORDERNO,a.PURCHASEORDERDATE,b.PARTID,c.PARTNAME,MCTYPENAME,c.MCPARTSTYPEID,f.MCPARTSTYPE,b.KMCSTOCKTYPEID,b.mACHINEID,
            (b.QTY) as MainIn,0 as Issue2Floor,0 as ReturnFromFloor,0 as Floor2Machine,0 as BR_Return2HO
            from T_KmcPartsTran a,t_kmcpartstransdetails b,t_kmcpartsinfo c,t_kmcstockStatus d,t_kmctype e,T_MCPARTSTYPE f
            where a.STOCKID=b.StockId and b.PARTID=c.PARTID and B.KMCSTOCKTYPEID=d.KMCSTOCKTYPEID and
            b.PARTSSTATUSFROMID=d.PARTSSTATUSFROMID and b.PARTSSTATUSTOID=d.PARTSSTATUSTOID and
			c.MCPARTSTYPEID=f.MCPARTSTYPEID and c.MCTYPEID=e.MCTYPEID and b.KMCSTOCKTYPEID=1 and
			c.MCPARTSTYPEID=pMCPARTSTYPEID and 
	        b.PARTID=pPARTID and
	        /*(pMACHINEID is null or b.MACHINEID=pMACHINEID) and*/
			a.StockDate Between decode(VsDate,null,'01-JAN-2000',VsDate) and decode(VeDate,null,'01-JAN-2050',VeDate)
	union all
            select a.STOCKID,a.STOCKDATE,a.CHALLANNO,a.CHALLANDATE,a.PURCHASEORDERNO,a.PURCHASEORDERDATE,b.PARTID,c.PARTNAME,MCTYPENAME,c.MCPARTSTYPEID,f.MCPARTSTYPE,b.KMCSTOCKTYPEID,b.mACHINEID,
            0 as MainIn,(b.QTY) as Issue2Floor,0 as ReturnFromFloor,0 as Floor2Machine,0 as BR_Return2HO
            from T_KmcPartsTran a,t_kmcpartstransdetails b,t_kmcpartsinfo c,t_kmcstockStatus d,t_kmctype e,T_MCPARTSTYPE f
            where a.STOCKID=b.StockId and b.PARTID=c.PARTID and B.KMCSTOCKTYPEID=d.KMCSTOCKTYPEID and
            b.PARTSSTATUSFROMID=d.PARTSSTATUSFROMID and b.PARTSSTATUSTOID=d.PARTSSTATUSTOID and
	        c.MCPARTSTYPEID=f.MCPARTSTYPEID and c.MCTYPEID=e.MCTYPEID and b.KMCSTOCKTYPEID=2 and
	        c.MCPARTSTYPEID=pMCPARTSTYPEID and 
			b.PARTID=pPARTID and
			a.StockDate Between decode(VsDate,null,'01-JAN-2000',VsDate) and VeDate
	union all
            select a.STOCKID,a.STOCKDATE,a.CHALLANNO,a.CHALLANDATE,a.PURCHASEORDERNO,a.PURCHASEORDERDATE,b.PARTID,c.PARTNAME,MCTYPENAME,c.MCPARTSTYPEID,f.MCPARTSTYPE,b.KMCSTOCKTYPEID,b.mACHINEID,
            0 as MainIn,0 as Issue2Floor,(b.QTY) as ReturnFromFloor,0 as Floor2Machine,0 as BR_Return2HO
            from T_KmcPartsTran a,t_kmcpartstransdetails b,t_kmcpartsinfo c,t_kmcstockStatus d,t_kmctype e,T_MCPARTSTYPE f
			where a.STOCKID=b.StockId and b.PARTID=c.PARTID and B.KMCSTOCKTYPEID=d.KMCSTOCKTYPEID and
            b.PARTSSTATUSFROMID=d.PARTSSTATUSFROMID and b.PARTSSTATUSTOID=d.PARTSSTATUSTOID and
			c.MCPARTSTYPEID=f.MCPARTSTYPEID and c.MCTYPEID=e.MCTYPEID and b.KMCSTOCKTYPEID=3 and
			c.MCPARTSTYPEID=pMCPARTSTYPEID and 
	   	    b.PARTID=pPARTID and
			a.StockDate Between decode(VsDate,null,'01-JAN-2000',VsDate) and decode(VeDate,null,'01-JAN-2050',VeDate)
	union all
			select a.STOCKID,a.STOCKDATE,a.CHALLANNO,a.CHALLANDATE,a.PURCHASEORDERNO,a.PURCHASEORDERDATE,b.PARTID,c.PARTNAME,MCTYPENAME,c.MCPARTSTYPEID,f.MCPARTSTYPE,b.KMCSTOCKTYPEID,b.mACHINEID,
			0 as MainIn,0 as Issue2Floor,(b.QTY) as ReturnFromFloor,0 as Floor2Machine,0 as BR_Return2HO
			from T_KmcPartsTran a,t_kmcpartstransdetails b,t_kmcpartsinfo c,t_kmcstockStatus d,t_kmctype e,T_MCPARTSTYPE f
			where a.STOCKID=b.StockId and b.PARTID=c.PARTID and B.KMCSTOCKTYPEID=d.KMCSTOCKTYPEID and
			b.PARTSSTATUSFROMID=d.PARTSSTATUSFROMID and b.PARTSSTATUSTOID=d.PARTSSTATUSTOID and
			c.MCPARTSTYPEID=f.MCPARTSTYPEID and c.MCTYPEID=e.MCTYPEID and b.KMCSTOCKTYPEID=9 and
			c.MCPARTSTYPEID=pMCPARTSTYPEID and 
			b.PARTID=pPARTID and
			(pMACHINEID is null or b.MACHINEID=pMACHINEID) and
			a.StockDate Between decode(VsDate,null,'01-JAN-2000',VsDate) and decode(VeDate,null,'01-JAN-2050',VeDate)
	union all
			select a.STOCKID,a.STOCKDATE,a.CHALLANNO,a.CHALLANDATE,a.PURCHASEORDERNO,a.PURCHASEORDERDATE,b.PARTID,c.PARTNAME,MCTYPENAME,c.MCPARTSTYPEID,f.MCPARTSTYPE,b.KMCSTOCKTYPEID,b.mACHINEID,
			0 as MainIn,0 as Issue2Floor,0 as ReturnFromFloor,0 as Floor2Machine,(b.QTY) as BR_Return2HO
			from T_KmcPartsTran a,t_kmcpartstransdetails b,t_kmcpartsinfo c,t_kmcstockStatus d,t_kmctype e,T_MCPARTSTYPE f
			where a.STOCKID=b.StockId and b.PARTID=c.PARTID and B.KMCSTOCKTYPEID=d.KMCSTOCKTYPEID and
			b.PARTSSTATUSFROMID=d.PARTSSTATUSFROMID and b.PARTSSTATUSTOID=d.PARTSSTATUSTOID and
			c.MCPARTSTYPEID=f.MCPARTSTYPEID and c.MCTYPEID=e.MCTYPEID and b.KMCSTOCKTYPEID=11 and
			c.MCPARTSTYPEID=pMCPARTSTYPEID and 
			b.PARTID=pPARTID and
			a.StockDate Between decode(VsDate,null,'01-JAN-2000',VsDate) and decode(VeDate,null,'01-JAN-2050',VeDate);
  end if;

END GetKN05;
/



PROMPT CREATE OR REPLACE Procedure  203 :: GetDC08
CREATE OR REPLACE PROCEDURE GetDC08(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pAuxTypeID NUMBER,
  pAuxID NUMBER,
  sDate IN VARCHAR2,
  eDate IN VARCHAR2
)
AS
  vSDate date;
  vEDate date;
BEGIN

  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  end if;

if pQueryType=1 then
/* Report for SK48 */
  OPEN data_cursor  FOR
  select a.STOCKINVOICENO,a.STOCKDATE,b.AuxTypeid,g.AuxType,e.DyeBase, d.Auxid,AuxName,(StockQty) MainIn,0 AS IssueSub,0 AS IssueBank,
        0 AS Bank2MainIn,0 as AdjustOut,0 as AdjustIn,0 AS LOAN2PARTY,0 AS LOANRFPARTY,0 as LOANFROMPARTY,0 AS LOANR2PARTY
    from T_AuxStock a, T_AuxStockItem b, T_AuxStockTypeDetails c, T_Auxiliaries d,
         T_DyeBase e, T_UnitOfMeas f, T_AuxType g
    where a.AuxStockID=b.AuxStockID and
    a.AuxStockTypeID=c.AuxStockTypeID and
    d.AuxTypeID = g.AuxTypeID and
    B.AUXTYPEID=C.AUXTYPEID AND
    b.AuxID=d.AuxID and
	d.AuxID=pAuxID and
    d.DyeBaseID= e.DyeBaseID (+) and
    d.UnitOfMeasID=f.UnitOfMeasID and
    d.AuxTypeID=g.AuxTypeID and
	StockDate between decode(vSDate,null,'01-JAN-2000',vSDate) and vEDate  and  
    a.AUXSTOCKTYPEID = 1
UNION ALL
select b.STOCKINVOICENO,b.STOCKDATE,a.AuxTypeid,F.AuxType,e.DyeBase, c.Auxid,AuxName,0 as MainIn,(StockQty) IssueSub,0 AS IssueBank,
        0 AS Bank2MainIn,0 as AdjustOut,0 as AdjustIn,0 AS LOAN2PARTY,0 AS LOANRFPARTY,0 as LOANFROMPARTY,0 AS LOANR2PARTY
  from t_auxstockitem a,t_auxstock b, T_Auxiliaries c ,
 T_UnitOfMeas D,T_DyeBase e,T_AuxType f
 where a.AUXSTOCKID=b. AUXSTOCKID and
 a.AUXTYPEID=c.AUXTYPEID  and
 a.AUXTYPEID=f.AUXTYPEID  and
 a.AUXID=c.AUXID And
 c.AuxID=pAuxID and
 e.DYEBASEID(+)=c.DYEBASEID and
 c.UnitOfMeasId=d.UnitOfMeasId And
 StockDate between decode(vSDate,null,'01-JAN-2000',vSDate) and vEDate  and  
 AUXSTOCKTYPEID=2
UNION ALL
select b.STOCKINVOICENO,b.STOCKDATE,a.AuxTypeid,F.AuxType,e.DyeBase,c.Auxid,AuxName,0 as MainIn,0 AS IssueSub,(StockQty) IssueBank,
        0 AS Bank2MainIn,0 as AdjustOut,0 as AdjustIn,0 AS LOAN2PARTY,0 AS LOANRFPARTY,0 as LOANFROMPARTY,0 AS LOANR2PARTY
  from t_auxstockitem a,t_auxstock b, T_Auxiliaries c ,
 T_UnitOfMeas D,T_DyeBase e,T_AuxType f
 where a.AUXSTOCKID=b. AUXSTOCKID and
 a.AUXTYPEID=c.AUXTYPEID  and
 a.AUXTYPEID=f.AUXTYPEID  and
 a.AUXID=c.AUXID And
 c.AuxID=pAuxID and
 e.DYEBASEID(+)=c.DYEBASEID and
 c.UnitOfMeasId=d.UnitOfMeasId And
 StockDate between decode(vSDate,null,'01-JAN-2000',vSDate) and vEDate  and 
 AUXSTOCKTYPEID=4
UNION ALL
select b.STOCKINVOICENO,b.STOCKDATE,a.AuxTypeid,F.AuxType,e.DyeBase,c.Auxid,AuxName,0 as MainIn,0 AS IssueSub,0 as IssueBank,(StockQty) Bank2MainIn,
        0 as AdjustOut,0 as AdjustIn,0 AS LOAN2PARTY,0 AS LOANRFPARTY,0 as LOANFROMPARTY,0 AS LOANR2PARTY
  from t_auxstockitem a,t_auxstock b, T_Auxiliaries c ,
 T_UnitOfMeas D,T_DyeBase e,T_AuxType f
 where a.AUXSTOCKID=b. AUXSTOCKID and
 a.AUXTYPEID=c.AUXTYPEID  and
 a.AUXTYPEID=f.AUXTYPEID  and
 a.AUXID=c.AUXID And
 c.AuxID=pAuxID and
 e.DYEBASEID(+)=c.DYEBASEID and
 c.UnitOfMeasId=d.UnitOfMeasId And
 StockDate between decode(vSDate,null,'01-JAN-2000',vSDate) and vEDate and   
 AUXSTOCKTYPEID=5
UNION ALL
select b.STOCKINVOICENO,b.STOCKDATE,a.AuxTypeid,F.AuxType,e.DyeBase,c.Auxid,AuxName,0 as MainIn,0 AS IssueSub,0 as IssueBank,0 as Bank2MainIn,
 (StockQty) AdjustOut,0 as AdjustIn,0 AS LOAN2PARTY,0 AS LOANRFPARTY,0 as LOANFROMPARTY,0 AS LOANR2PARTY
  from t_auxstockitem a,t_auxstock b, T_Auxiliaries c , T_UnitOfMeas D,T_DyeBase e,T_AuxType f
 where a.AUXSTOCKID=b. AUXSTOCKID and
 a.AUXTYPEID=c.AUXTYPEID  and
 a.AUXTYPEID=f.AUXTYPEID  and
 a.AUXID=c.AUXID And
 c.AuxID=pAuxID and
 e.DYEBASEID(+)=c.DYEBASEID and
 c.UnitOfMeasId=d.UnitOfMeasId And
 StockDate between decode(vSDate,null,'01-JAN-2000',vSDate) and vEDate  and  
 AUXSTOCKTYPEID=6
UNION ALL
select b.STOCKINVOICENO,b.STOCKDATE,a.AuxTypeid,F.AuxType,e.DyeBase,c.Auxid,AuxName,0 as MainIn,0 AS IssueSub,0 as IssueBank,0 as Bank2MainIn,
        0 as AdjustOut,(StockQty) AdjustIn,0 AS LOAN2PARTY,0 AS LOANRFPARTY,0 as LOANFROMPARTY,0 AS LOANR2PARTY
  from t_auxstockitem a,t_auxstock b, T_Auxiliaries c ,
 T_UnitOfMeas D,T_DyeBase e,T_AuxType f
 where a.AUXSTOCKID=b. AUXSTOCKID and
 a.AUXTYPEID=c.AUXTYPEID  and
 a.AUXTYPEID=f.AUXTYPEID  and
 a.AUXID=c.AUXID And
 c.AuxID=pAuxID and
 e.DYEBASEID(+)=c.DYEBASEID and
 c.UnitOfMeasId=d.UnitOfMeasId And
 StockDate between decode(vSDate,null,'01-JAN-2000',vSDate) and vEDate and   
 AUXSTOCKTYPEID=11
UNION ALL
select b.STOCKINVOICENO,b.STOCKDATE,a.AuxTypeid,F.AuxType,e.DyeBase,c.Auxid,AuxName,0 as MainIn,0 AS IssueSub,0 as IssueBank,0 as Bank2MainIn,
        0 as AdjustOut,0 AS AdjustIn,(StockQty) LOAN2PARTY,0 AS LOANRFPARTY,0 as LOANFROMPARTY,0 AS LOANR2PARTY
  from t_auxstockitem a,t_auxstock b, T_Auxiliaries c ,
 T_UnitOfMeas D,T_DyeBase e,T_AuxType f
 where a.AUXSTOCKID=b. AUXSTOCKID and
 a.AUXTYPEID=c.AUXTYPEID  and
 a.AUXTYPEID=f.AUXTYPEID  and
 a.AUXID=c.AUXID And
 c.AuxID=pAuxID and
 e.DYEBASEID(+)=c.DYEBASEID and
 c.UnitOfMeasId=d.UnitOfMeasId And
 StockDate between decode(vSDate,null,'01-JAN-2000',vSDate) and vEDate  and  
 AUXSTOCKTYPEID=7
UNION ALL
select b.STOCKINVOICENO,b.STOCKDATE,a.AuxTypeid,F.AuxType,e.DyeBase,c.Auxid,AuxName,0 as MainIn,0 AS IssueSub,0 as IssueBank,0 as Bank2MainIn,
        0 as AdjustOut,0 AS AdjustIn,0 AS LOAN2PARTY,(StockQty) LOANRFPARTY,0 as LOANFROMPARTY,0 AS LOANR2PARTY
  from t_auxstockitem a,t_auxstock b, T_Auxiliaries c ,
 T_UnitOfMeas D,T_DyeBase e,T_AuxType f
 where a.AUXSTOCKID=b. AUXSTOCKID and
 a.AUXTYPEID=c.AUXTYPEID  and
 a.AUXTYPEID=f.AUXTYPEID  and
 a.AUXID=c.AUXID And
 c.AuxID=pAuxID and
 e.DYEBASEID(+)=c.DYEBASEID and
 c.UnitOfMeasId=d.UnitOfMeasId And
 StockDate between decode(vSDate,null,'01-JAN-2000',vSDate) and vEDate  and  
 AUXSTOCKTYPEID=8
UNION ALL
select b.STOCKINVOICENO,b.STOCKDATE,a.AuxTypeid,F.AuxType,e.DyeBase,c.Auxid,AuxName,0 as MainIn,0 AS IssueSub,0 as IssueBank,0 as Bank2MainIn,
        0 as AdjustOut,0 AS AdjustIn,0 AS LOAN2PARTY,0 AS LOANRFPARTY,(StockQty) LOANFROMPARTY,0 AS LOANR2PARTY
  from t_auxstockitem a,t_auxstock b, T_Auxiliaries c ,
 T_UnitOfMeas D,T_DyeBase e,T_AuxType f
 where a.AUXSTOCKID=b. AUXSTOCKID and
 a.AUXTYPEID=c.AUXTYPEID  and
 a.AUXTYPEID=f.AUXTYPEID  and
 a.AUXID=c.AUXID And
 c.AuxID=pAuxID and
 e.DYEBASEID(+)=c.DYEBASEID and
 c.UnitOfMeasId=d.UnitOfMeasId And
 StockDate between decode(vSDate,null,'01-JAN-2000',vSDate) and vEDate and   
 AUXSTOCKTYPEID=9
UNION ALL
select b.STOCKINVOICENO,b.STOCKDATE,a.AuxTypeid,F.AuxType,e.DyeBase,c.Auxid,AuxName,0 as MainIn,0 AS IssueSub,0 as IssueBank,0 as Bank2MainIn,
        0 as AdjustOut,0 AS AdjustIn,0 AS LOAN2PARTY,0 AS LOANRFPARTY,0 as LOANFROMPARTY,(StockQty) LOANR2PARTY
       from t_auxstockitem a,t_auxstock b, T_Auxiliaries c ,
 T_UnitOfMeas D,T_DyeBase e,T_AuxType f
 where a.AUXSTOCKID=b. AUXSTOCKID and
 a.AUXTYPEID=c.AUXTYPEID  and
 a.AUXTYPEID=f.AUXTYPEID  and
 a.AUXID=c.AUXID And
 c.AuxID=pAuxID and
 e.DYEBASEID(+)=c.DYEBASEID and
 c.UnitOfMeasId=d.UnitOfMeasId And
 StockDate between decode(vSDate,null,'01-JAN-2000',vSDate) and vEDate  and  
 AUXSTOCKTYPEID=10; 
end if;
END GetDC08;
/







PROMPT CREATE OR REPLACE Procedure  204 :: GetBudgetAndProduction
CREATE OR REPLACE Procedure GetBudgetAndProduction(
  data_cursor IN OUT pReturnData.c_Records, 
  pQType in number,
  pOrderTypeID in VARCHAR2,
  pOrderNo IN VARCHAR2,
  pSDate IN VARCHAR2,
  pEDate IN VARCHAR2
)
AS
vSDate date;
vEDate date;
BEGIN
  if not pSDate is null then
    vSDate := TO_DATE(pSDate, 'DD/MM/YYYY');
  else
 vSDate := TO_DATE('01-JAN-2000', 'DD/MM/YYYY');
  end if;
  if not pEDate is null then
    vEDate := TO_DATE(pEDate, 'DD/MM/YYYY');
  else
 vEDate := TO_DATE('01-JAN-2900', 'DD/MM/YYYY');
  end if;
if (pQType=0) then  /* For Report All Work order*/
	OPEN data_cursor  FOR
	select c.BASICTYPEID,getfncWOBType(b.ORDERNO) as Dworkorder, getfncBOTypeName(d.BUDGETID) AS BUDGET_NO,getfncFabricTypeFromBudget(d.BUDGETID) as style,
	sum(decode(a.KNTITRANSACTIONTYPEID,6,b.Quantity,24,b.Quantity,0)) FabKnittingProdQty,e.CLIENTNAME,
	(SELECT SUM(TOTALCONSUMPTION) FROM t_fabricconsumption WHERE BUDGETID=d.BUDGETID AND d.REVISION='65') as BudgetQtyA, 
	(SELECT SUM(TOTALCONSUMPTION) FROM t_fabricconsumption
	WHERE BUDGETID=(SELECT BUDGETID	FROM t_budget WHERE BUDGETNO=d.BUDGETNO AND REVISION='66' AND ORDERTYPEID=d.ORDERTYPEID)) as BudgetQtyB,
	(SELECT SUM(TOTALCONSUMPTION) FROM t_fabricconsumption
	WHERE BUDGETID=(SELECT BUDGETID	FROM t_budget WHERE BUDGETNO=d.BUDGETNO AND REVISION='67' AND ORDERTYPEID=d.ORDERTYPEID)) as BudgetQtyC,
	(SELECT SUM(TOTALCONSUMPTION) FROM t_fabricconsumption
	WHERE BUDGETID=(SELECT BUDGETID	FROM t_budget WHERE BUDGETNO=d.BUDGETNO AND REVISION='68' AND ORDERTYPEID=d.ORDERTYPEID)) as BudgetQtyD
	from T_Knitstock a, T_KnitStockItems b,T_workorder c,t_budget d,t_client e
    where a.StockID=b.StockID and
	a.KNTITRANSACTIONTYPEID in (6,24) and
    b.ORDERNO=c.ORDERNO and
	e.CLIENTID=c.CLIENTID and
    c.BUDGETID=d.BUDGETID and 
	c.BASICTYPEID=pOrderTypeID and 
	a.STOCKTRANSDATE between decode(vSDate,null,'01-JAN-2000',vSDate) and vEDate and
    b.ORDERNO>0
    group by c.BASICTYPEID,b.ORDERNO,d.BUDGETID,d.ORDERTYPEID,d.REVISION,d.BUDGETNO,e.CLIENTNAME
    order by getfncWOBType(b.ORDERNO);
elsif (pQType=1) then  /* For Report Selected Work order*/
	OPEN data_cursor  FOR
	select c.BASICTYPEID,getfncWOBType(b.ORDERNO) as Dworkorder, getfncBOTypeName(d.BUDGETID) AS BUDGET_NO,getfncFabricTypeFromBudget(d.BUDGETID) as style,
	sum(decode(a.KNTITRANSACTIONTYPEID,6,b.Quantity,24,b.Quantity,0)) FabKnittingProdQty,e.CLIENTNAME,
	(SELECT SUM(TOTALCONSUMPTION) FROM t_fabricconsumption WHERE BUDGETID=d.BUDGETID AND d.REVISION='65') as BudgetQtyA, 
	(SELECT SUM(TOTALCONSUMPTION) FROM t_fabricconsumption
	WHERE BUDGETID=(SELECT BUDGETID	FROM t_budget WHERE BUDGETNO=d.BUDGETNO AND REVISION='66' AND ORDERTYPEID=d.ORDERTYPEID)) as BudgetQtyB,
	(SELECT SUM(TOTALCONSUMPTION) FROM t_fabricconsumption
	WHERE BUDGETID=(SELECT BUDGETID	FROM t_budget WHERE BUDGETNO=d.BUDGETNO AND REVISION='67' AND ORDERTYPEID=d.ORDERTYPEID)) as BudgetQtyC,
	(SELECT SUM(TOTALCONSUMPTION) FROM t_fabricconsumption
	WHERE BUDGETID=(SELECT BUDGETID	FROM t_budget WHERE BUDGETNO=d.BUDGETNO AND REVISION='68' AND ORDERTYPEID=d.ORDERTYPEID)) as BudgetQtyD
	from T_Knitstock a, T_KnitStockItems b,T_workorder c,t_budget d,t_client e
    where a.StockID=b.StockID and
	a.KNTITRANSACTIONTYPEID in (6,24) and
    b.ORDERNO=c.ORDERNO and
	e.CLIENTID=c.CLIENTID and
    c.BUDGETID=d.BUDGETID and 
	c.BASICTYPEID=pOrderTypeID and
	a.STOCKTRANSDATE between decode(vSDate,null,'01-JAN-2000',vSDate) and vEDate and
	TO_CHAR(b.ORDERNO) in (get_token(pOrderno,1,'|'),get_token(pOrderno,2,'|'),get_token(pOrderno,3,'|'),
	 get_token(pOrderno,4,'|'),get_token(pOrderno,5,'|'),get_token(pOrderno,6,'|'),
	 get_token(pOrderno,7,'|'),get_token(pOrderno,8,'|'),get_token(pOrderno,9,'|'),
	 get_token(pOrderno,10,'|'),get_token(pOrderno,11,'|'),get_token(pOrderno,12,'|'),
	 get_token(pOrderno,13,'|'),get_token(pOrderno,14,'|'),get_token(pOrderno,15,'|')) and
    b.ORDERNO>0
    group by c.BASICTYPEID,b.ORDERNO,d.BUDGETID,d.ORDERTYPEID,d.REVISION,d.BUDGETNO,e.CLIENTNAME
    order by getfncWOBType(b.ORDERNO);
End if;
END GetBudgetAndProduction;
/





PROMPT CREATE OR REPLACE Procedure  205 :: GetReportGBill
CREATE OR REPLACE PROCEDURE GetReportGBill(
  data_cursor IN OUT pReturnData.c_Records,  
  pBillNo IN NUMBER,
  pOrdercode in varchar2,
  pInWordsnumber IN VARCHAR2  
)
AS  
BEGIN
  OPEN data_cursor  FOR
  SELECT DISTINCT A.ORDERCODE,getfncGWOBType(G.GORDERNO) as Gworkorder,A.BILLNO,A.BILLDATE,C.CLIENTNAME,A.BILLDISCOUNT,
  A.BILLDISCOMMENTS,A.BILLDISPERC,c.CADDRESS,c.CTELEPHONE,e.shade,c.CCONTACTPERSON,x.EMPLOYEENAME,
  y.EMPLOYEENAME as Managername,D.CURRENCYNAME,A.CONRATE,A.CANCELLED,A.BILLCOMMENTS,B.BILLITEMSL,B.DORDERCODE,
  B.DINVOICENO,getFncYarnDes(e.ORDERLINEITEM) as YarnDesc,B.DITEMSL,B.WORDERCODE,B.GORDERNO,B.WOITEMSL,
  B.BILLITEMSQTY,B.BILLITEMSUNITPRICE,g.ClientsRef,a.knitting,a.dyeing,a.fabric 
  FROM T_GBILL A,T_GBILLITEMS B,T_CLIENT C,T_CURRENCY D,t_GORDeritems e,t_Gworkorder g,T_EMPLOYEE x,T_EMPLOYEE y
  WHERE A.ORDERCODE=B.ORDERCODE AND
        A.CLIENTID=C.CLIENTID(+) AND
        A.CURRENCYID=D.CURRENCYID(+) AND  
        b.WOITEMSL=e.WOITEMSL and  
        B.GORDERNO=E.GORDERNO AND 
        A.BILLNO=B.BILLNO AND 
        B.BILLNO=pBillNo AND
		A.ORDERCODE=pOrdercode and		
		a.EMPLOYEEID=x.EMPLOYEEID(+) and
        x.EMPMANAGER=y.EMPLOYEEID(+) and
	B.GORDERNO=g.GORDERNO;        
END GetReportGBill;
/



PROMPT CREATE OR REPLACE Procedure  206 :: GetReportAccAdjustmentDetailS
CREATE OR REPLACE Procedure GetReportAccAdjustmentDetailS (
   data_cursor IN OUT pReturnData.c_Records,
   pAccStockID IN NUMBER
)
As
Begin
  OPEN data_cursor  FOR 
select a.StockId, a.StockTransNo,  a.StockTransDate, b.LineNo, b.RequisitionNo, b.ORDERNO, i.item , b.StyleNo, c.ColourName, b.Code, b.Count_Size, b.CurrentStock, b.ReqQuantity, b.Quantity as IssueQty, b.SQuantity , f.UNITOFMEAS as PUOM, f.UNITOFMEAS as SUOM , b.remarks
from T_AccStock a, T_AccStockItems b,T_AccTransactionType t,T_UnitOfMeas f, T_accessories i, T_Colour c
where a.STOCKID=b.STOCKID and
t.AccTransTypeID=1 And
i.AccessoriesID=b.AccessoriesID and
b.PUNITOFMEASID=f.UNITOFMEASID And
c.colourID=b.colourID and
b.STOCKID=pAccStockID;
End GetReportAccAdjustmentDetailS;
/



PROMPT CREATE OR REPLACE Procedure  207 :: GetReportSCGWorkOrder
CREATE OR REPLACE Procedure GetReportSCGWorkOrder
(
  data_cursor IN OUT pReturnData.c_Records,
  pWhereValue number
)
AS
BEGIN
  OPEN data_cursor for
  select a.SCGORDERNO,a.GDORDERNO,a.GORDERDATE,c.ClientName,d.SalesTerm,a.ContactPerson,a.COSTINGREFNO,a.CONRATE,
  b.WOITEMSL,b.STYLE,h.COUNTRYNAME,a.CLIENTSREF,getfncDispalyorder(a.GOrderno) as SCGRefOrder,g.CurrencyName,b.Shade,b.PRICE,b.QUANTITY,f.unitofmeas as unit,
  b.ORDERLINEITEM,(b.CURRENTSTOCK* b.PRICE) as totalPrice,a.ORDERREMARKS, getgsizeDesc(b.ORDERLINEITEM) as SizeDesc,b.CURRENTSTOCK,
  b.Unitofmeasid as UnitID,a.WCANCELLED,a.WREVISED,a.OrderTypeID,i.DESCRIPTION as OrderType,b.DELIVERYDATE
  from T_SCGWorkOrder a,T_SCGOrderItems b ,t_client c,t_salesterm d,t_unitOfmeas f,
  t_Currency g,t_COUNTRY h,t_SCGordertype i
  where a.SCGORDERNO =b.SCGORDERNO and
  c.clientid=a.clientid and
  d.salestermid=a.salestermid and
  f.unitofmeasid=b.unitofmeasid and
  a.CURRENCYID=g.CURRENCYID and
  B.COUNTRYID=H.COUNTRYID and
  a.OrderTypeID=i.OrderType and
  a.SCGORDERNO=pWhereValue
  order by a.SCGORDERNO,b.WOITEMSL;

END GetReportSCGWorkOrder;
/




PROMPT CREATE OR REPLACE Procedure  208 :: GetReportSCGPEWorkOrder
CREATE OR REPLACE Procedure GetReportSCGPEWorkOrder
(
  data_cursor IN OUT pReturnData.c_Records,
  pWhereValue number
)
AS
BEGIN
  OPEN data_cursor for
  select a.SCGORDERNO,a.GDORDERNO,a.GORDERDATE,c.ClientName,d.SalesTerm,a.ContactPerson,a.COSTINGREFNO,a.CONRATE,
  b.WOITEMSL,b.STYLE,h.COUNTRYNAME,a.CLIENTSREF,getfncDispalyorder(a.GOrderno) as SCGRefOrder,g.CurrencyName,b.Shade,b.PRICE,b.QUANTITY,f.unitofmeas as unit,
  b.ORDERLINEITEM,(b.CURRENTSTOCK* b.PRICE) as totalPrice,a.ORDERREMARKS, getgsizeDesc(b.ORDERLINEITEM) as SizeDesc,b.CURRENTSTOCK,
  b.Unitofmeasid as UnitID,a.WCANCELLED,a.WREVISED,a.OrderTypeID,i.DESCRIPTION as OrderType,b.DELIVERYDATE
  from T_SCGWorkOrder a,T_SCGOrderItems b ,t_client c,t_salesterm d,t_unitOfmeas f,
  t_Currency g,t_COUNTRY h,t_SCGordertype i
  where a.SCGORDERNO =b.SCGORDERNO and
  c.clientid=a.clientid and
  d.salestermid=a.salestermid and
  f.unitofmeasid=b.unitofmeasid and
  a.CURRENCYID=g.CURRENCYID and
  B.COUNTRYID=H.COUNTRYID and
  a.OrderTypeID=i.OrderType and
  a.SCGORDERNO=pWhereValue
  order by a.SCGORDERNO,b.WOITEMSL;

END GetReportSCGPEWorkOrder;
/

PROMPT CREATE OR REPLACE Procedure  209 :: RptKnitStockLoanPosition
CREATE OR REPLACE Procedure RptKnitStockLoanPosition(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pKnitTranTypeID NUMBER,
  pStockID NUMBER,
  pStockDate DATE
)
AS
BEGIN
if pQueryType=1 then
    open data_cursor for
	select c.StockId, c.StockTransNO, c.StockTransDATE,e.CLIENTNAME,YarnCount,YarnType,UnitOfMeas,  
	a.YarnCountId, a.YarnTypeId,a.FabricTypeId,a.OrderlineItem,a.Quantity, a.Squantity,a.PunitOfmeasId,a.SUNITOFMEASID,a.REQQUANTITY,
    a.YarnBatchNo,a.Shade,a.REMARKS,a.CurrentStock,a.supplierID,d.SUPPLIERNAME,a.RequisitionNo,
    a.SubConId,a.SHADEGROUPID,'' AS SHADEGROUPNAME,c.KNTITRANSACTIONTYPEID,a.REMAINQTY,a.yarnfor,i.PARTYNAME
    from T_KnitStockItems a,T_KnitStock c,T_supplier d,T_CLIENT e,T_YarnCount f,T_YarnType g, T_UnitOfMeas h,T_YARNPARTY i
    where a.STOCKID=c.STOCKID and
	a.supplierID=d.supplierID and
	a.YarnCountId=f.YarnCountId and
	a.PID=i.PID(+) and
	a.YarnTypeId=g.YarnTypeId and
	a.PunitOfmeasId=h.unitOfmeasId and
	c.CLIENTID=e.CLIENTID(+) and
	STOCKTRANSDATE <= pStockDate and
    c.STOCKID=pStockID
    order by KNTISTOCKITEMSL asc;
	
elsif pQueryType=2 then
    open data_cursor for
	select c.StockId, c.StockTransNO, c.StockTransDATE,e.CLIENTNAME,YarnCount,YarnType,UnitOfMeas,   
	a.YarnCountId, a.YarnTypeId,a.FabricTypeId,a.OrderlineItem,a.Quantity, a.Squantity,a.PunitOfmeasId,a.SUNITOFMEASID,a.REQQUANTITY,
    a.YarnBatchNo,a.Shade,a.REMARKS,a.CurrentStock,a.supplierID,d.SUPPLIERNAME,a.RequisitionNo,
    a.SubConId,a.SHADEGROUPID,'' AS SHADEGROUPNAME,c.KNTITRANSACTIONTYPEID,a.REMAINQTY,a.yarnfor,i.PARTYNAME
    from T_KnitStockItems a,T_KnitStock c,T_supplier d,T_CLIENT e,T_YarnCount f,T_YarnType g, T_UnitOfMeas h,T_YARNPARTY i
    where a.STOCKID=c.STOCKID and
	a.supplierID=d.supplierID and
	a.YarnCountId=f.YarnCountId and
	a.PID=i.PID(+) and
	a.YarnTypeId=g.YarnTypeId and
	a.PunitOfmeasId=h.unitOfmeasId and
	c.CLIENTID=e.CLIENTID(+) and
	STOCKTRANSDATE <= pStockDate and
    c.STOCKID=pStockID
    order by KNTISTOCKITEMSL asc;
elsif pQueryType=3 then
    open data_cursor for
	select c.StockId, c.StockTransNO, c.StockTransDATE,e.CLIENTNAME,YarnCount,YarnType,UnitOfMeas,   
	a.YarnCountId, a.YarnTypeId,a.FabricTypeId,a.OrderlineItem,a.Quantity, a.Squantity,a.PunitOfmeasId,a.SUNITOFMEASID,a.REQQUANTITY,
    a.YarnBatchNo,a.Shade,a.REMARKS,a.CurrentStock,a.supplierID,d.SUPPLIERNAME,a.RequisitionNo,
    a.SubConId,a.SHADEGROUPID,'' AS SHADEGROUPNAME,c.KNTITRANSACTIONTYPEID,a.REMAINQTY,a.yarnfor,i.PARTYNAME
    from T_KnitStockItems a,T_KnitStock c,T_supplier d,T_CLIENT e,T_YarnCount f,T_YarnType g, T_UnitOfMeas h,T_YARNPARTY i
    where a.STOCKID=c.STOCKID and
	a.supplierID=d.supplierID and
	a.YarnCountId=f.YarnCountId and
	a.PID=i.PID(+) and
	a.YarnTypeId=g.YarnTypeId and
	a.PunitOfmeasId=h.unitOfmeasId and
	c.CLIENTID=e.CLIENTID(+) and
	STOCKTRANSDATE <= pStockDate and
    c.STOCKID=pStockID
    order by KNTISTOCKITEMSL asc;
elsif pQueryType=4 then
    open data_cursor for
	select c.StockId, c.StockTransNO, c.StockTransDATE,e.CLIENTNAME,YarnCount,YarnType,UnitOfMeas,   
	a.YarnCountId, a.YarnTypeId,a.FabricTypeId,a.OrderlineItem,a.Quantity, a.Squantity,a.PunitOfmeasId,a.SUNITOFMEASID,a.REQQUANTITY,
    a.YarnBatchNo,a.Shade,a.REMARKS,a.CurrentStock,a.supplierID,d.SUPPLIERNAME,a.RequisitionNo,
    a.SubConId,a.SHADEGROUPID,'' AS SHADEGROUPNAME,c.KNTITRANSACTIONTYPEID,a.REMAINQTY,a.yarnfor,i.PARTYNAME
    from T_KnitStockItems a,T_KnitStock c,T_supplier d,T_CLIENT e,T_YarnCount f,T_YarnType g, T_UnitOfMeas h,T_YARNPARTY i
    where a.STOCKID=c.STOCKID and
	a.supplierID=d.supplierID and
	a.YarnCountId=f.YarnCountId and
	a.PID=i.PID(+) and
	a.YarnTypeId=g.YarnTypeId and
	a.PunitOfmeasId=h.unitOfmeasId and
	c.CLIENTID=e.CLIENTID(+) and
	STOCKTRANSDATE <= pStockDate and
    c.STOCKID=pStockID
    order by KNTISTOCKITEMSL asc;	
end if;
END RptKnitStockLoanPosition;
/



PROMPT CREATE OR REPLACE Procedure  210 :: GETRPTOverheadInfo
CREATE OR REPLACE Procedure GETRPTOverheadInfo
(
  data_cursor IN OUT pReturnData.c_Records,
  pPID in number
)
AS
BEGIN
		open data_cursor for
			SELECT  ID,ITEMSSL,a.PID,a.OHTYPEID,d.OHTYPENAME,a.PARTICULARID,c.PARTICULARNAME,KNITTING,DYEING,FINISHING,RMG,TOTAL,b.OVERHEADNO,
			b.YMONTH,b.KNITTINGHOUR,b.DYEINGHOUR,b.FINISHINGHOUR,b.RMGHOUR
			FROM T_OVERHEADITEMS a,T_OVERHEAD b,T_PARTICULAR c,T_OVERHEADTYPE d
			WHERE  a.OHTYPEID in (1,2,3) AND a.PID=b.PID AND a.PARTICULARID=c.PARTICULARID(+) AND a.OHTYPEID=d.OHTYPEID(+) and
			a.PID=pPID
			ORDER BY ITEMSSL;
End GETRPTOverheadInfo;
/


PROMPT CREATE OR REPLACE Procedure  211 :: GetRptCuttingWOTransfer
CREATE OR REPLACE Procedure GetRptCuttingWOTransfer
(
  data_cursor IN OUT pReturnData.c_Records,
  pGStockID number
)
AS
BEGIN

    open data_cursor for
	select a.StockId,a.ChallanNo, a.ChallanDate, a.StockTransNO, a.StockTransDATE, b.PID,b.ORDERNO,getfncDispalyorder(b.OrderNo) as btype,
	fncTransCuttingOrder(b.STOCKID,GSTOCKITEMSL) as TOrderNo, b.FabricTypeId,d.fabrictype,b.Quantity,b.Squantity,p.unitofmeas as punit,x.unitofmeas as sunit,b.cuttingid,
	b.displayno as cuttingno,b.SIZEID,s.SIZENAME,b.BatchNo,b.Shade,	b.CurrentStock,b.subconid,b.FabricDia,b.FabricGSM,b.Styleno,b.GTRANSTYPEID,b.orderlineitem,b.REMARKS
from T_GStock a, T_GStockItems b, T_fabrictype d, T_unitOfmeas p,T_unitOfmeas x,T_SIZE s
where a.STOCKID=b.STOCKID(+) and
	b.SIZEID=s.SIZEID(+) AND
	b.GTRANSTYPEID=121 AND
	b.fabrictypeid=d.fabrictypeid and
	b.PunitOfMeasId=p.UNITOFMEASID(+) and
	b.SunitOfMeasId=x.UNITOFMEASID(+) and
	a.STOCKID=pGStockID
    order by b.GSTOCKITEMSL;
END GetRptCuttingWOTransfer;
/


PROMPT CREATE OR REPLACE Procedure  212 :: GetRptGarmentsWOTransfer
CREATE OR REPLACE Procedure GetRptGarmentsWOTransfer
(
  data_cursor IN OUT pReturnData.c_Records,
  pGStockID number
)
AS
BEGIN

    open data_cursor for
	select a.StockId,a.ChallanNo, a.ChallanDate, a.StockTransNO, a.StockTransDATE, b.PID,b.ORDERNO,getfncDispalyorder(b.OrderNo) as btype,
	fncTransGarmentsOrder(b.STOCKID,GSTOCKITEMSL) as TOrderNo, b.Quantity,b.Squantity,p.unitofmeas as punit,x.unitofmeas as sunit,b.cuttingid,
	b.displayno as cuttingno,b.SIZEID,s.SIZENAME,b.Shade,b.CurrentStock,b.subconid,b.FabricDia,b.FabricGSM,b.Styleno,b.GTRANSTYPEID,b.orderlineitem,b.REMARKS
from T_GStock a, T_GStockItems b, T_unitOfmeas p,T_unitOfmeas x,T_SIZE s
where a.STOCKID=b.STOCKID(+) and
	b.SIZEID=s.SIZEID(+) AND
	b.GTRANSTYPEID=111 AND
	b.PunitOfMeasId=p.UNITOFMEASID(+) and
	b.SunitOfMeasId=x.UNITOFMEASID(+) and
	a.STOCKID=pGStockID
    order by b.GSTOCKITEMSL;
END GetRptGarmentsWOTransfer;
/

PROMPT CREATE OR REPLACE Procedure  213 :: getTSPConsumption
CREATE OR REPLACE Procedure getTSPConsumption(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  PsDate IN VARCHAR2,
  pEDate IN VARCHAR2,
  PMACHINENO in Number DEFAULT NULL
)
AS
  vSDate date;
  LastBalanceDate DATE;
  vEDate DATE;
BEGIN
  if not pSDate is null then
    vSDate := TO_DATE(pSDate, 'DD/MM/YYYY');
  else
    vSDate := TO_DATE('01/01/1900', 'DD/MM/YYYY');
  end if;
  if not pEDate is null then
    vEDate := TO_DATE(pEDate, 'DD/MM/YYYY');
  else
    vEDate := TO_DATE('01/01/2300', 'DD/MM/YYYY');
  end if;
  if pQueryType=0 then
	OPEN data_cursor  FOR
	Select To_char(e.STOCKDATE,'YYYY')||to_char(e.STOCKDATE,'MM') as mont,to_char(e.STOCKDATE,'MONTH')||'-'||to_char(e.STOCKDATE,'YYYY') as MonthYear,
	a.PARTID,PartName,MACHINENO,MachineType,MCLISTNAME,nvl(WAVGPRICE,0) as MACAVGPRICE,
	(Select sum(decode(x.TEXMCSTOCKTYPEID,1,y.QTY,2,-y.QTY,3,y.QTY,0))
	from T_TexMcStock x,T_TexMcStockItems y
	where x.StockId=y.StockId and
	y.PARTID=a.PARTID and
	x.TEXMCSTOCKTYPEID in (1,2,3) And
	x.StockDate<=vEDate 
	Group By y.PARTID) as Balance,
	sum(nvl(decode(e.TEXMCSTOCKTYPEID,1,QTY,0),0)) as Recevied,
	sum(nvl(decode(e.TEXMCSTOCKTYPEID,2,QTY,0),0)) as Issue,
	sum(nvl(decode(e.TEXMCSTOCKTYPEID,3,QTY,0),0)) as ReturnToMS,
    sum(nvl(decode(e.TEXMCSTOCKTYPEID,2,QTY,3,-QTY,0),0)) as Consumption,
	nvl((sum(nvl(decode(e.TEXMCSTOCKTYPEID,2,QTY,3,-QTY,0),0))*WAVGPRICE),0) as AmountTk
	from T_TexMcPartsInfo a,T_TexMcStockItems c,T_TexMcList d,
	T_TexMcStock e,T_TexMcStockType f
	where c.StockId=e.StockId and
	f.TEXMCSTOCKTYPEID=e.TEXMCSTOCKTYPEID and
	a.PARTID=c.PARTID and
	/*a.PARTID=g.PARTID(+) And  ,T_TexMACHINEWAVGPRICE g*/
	d.McListId=c.IssueFor and
	e.TEXMCSTOCKTYPEID in (1,2,3) And
	StockDate between vSDate and vEDate And
	(PMACHINENO is Null or MCLISTID=pMACHINENO)
	Group By To_char(e.STOCKDATE,'YYYY'),to_char(e.STOCKDATE,'MM'),to_char(e.STOCKDATE,'MONTH'),
	a.PARTID,PartName,MACHINENO,MachineType,MCLISTNAME,WAVGPRICE
	having  sum(nvl(decode(e.TEXMCSTOCKTYPEID,2,QTY,3,-QTY,0),0))>0
	Order By to_char(e.STOCKDATE,'YYYY'),to_char(e.STOCKDATE,'MM'),PartName;
  end if;
END getTSPConsumption;
/

PROMPT CREATE OR REPLACE Procedure  213 :: getRptGarmentsDelivery
CREATE OR REPLACE Procedure getRptGarmentsDelivery
(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pClientId IN NUMBER,
  pOrderNo IN NUMBER,
  sDate IN VARCHAR2,
  eDate IN VARCHAR2
)
AS
  	vSDate date;
  	vEDate date;
BEGIN
  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  else
   vSDate := TO_DATE('01/01/1900', 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  else
   vEDate := TO_DATE('01/01/2100', 'DD/MM/YYYY');
  end if;
  
    /* For Report GP17 Garments Consumption Report*/
if pQueryType=1 then
  OPEN data_cursor FOR
  
	Select a.INVOICENO,a.INVOICEDATE,a.GATEPASSNO,getfncDispalyorder(b.ORDERNO) as Dorder,
	a.CONTACTPERSON,a.DELIVERYPLACE,a.VEHICLENO,a.DRIVERNAME,a.DRIVERLICENSENO,a.DRIVERMOBILENO,a.TRANSCOMPNAME,
	c.CLIENTNAME,e.CLIENTSREF as PONo,
	(select SUM(n.QUANTITY)  from T_GWorkOrder m,T_GOrderItems n
      where m.GOrderNo=n.GOrderNo and m.GOrderNo=b.ORDERNO group by	m.GOrderNo) as OrderQty,	
	(select Sum(q.QUANTITY*y.QUANTITY)   from T_GDELIVERYCHALLAN p,T_GDELIVERYCHALLANITEMS q,T_CTN x,T_CTNItems y
      where p.INVOICEID=q.INVOICEID and x.CTNID=y.CTNID and 
		x.CTNTYPE=q.CTNTYPE and x.ORDERNO=q.ORDERNO and x.ORDERNO=b.ORDERNO and	p.INVOICEDATE <=vEDate) as Cumulative,
	SUM(b.QUANTITY) as CTNQty,
	(select Sum(q.QUANTITY*y.QUANTITY)   from T_GDELIVERYCHALLAN p,T_GDELIVERYCHALLANITEMS q,T_CTN x,T_CTNItems y
      where p.INVOICEID=q.INVOICEID and p.INVOICEID=b.INVOICEID and x.CTNID=y.CTNID and 
		x.CTNTYPE=q.CTNTYPE and x.ORDERNO=q.ORDERNO and x.ORDERNO=b.ORDERNO and	
		p.INVOICEDATE between vSDate and vEDate) as PcsQty 
	from T_GDELIVERYCHALLAN a,T_GDELIVERYCHALLANITEMS b,T_Client c,T_GWorkOrder e
	where a.INVOICEID=b.INVOICEID and
	b.ORDERNO=e.GORDERNO and
	a.CATID=14 and
	a.CLIENTID=c.CLIENTID(+) and
	(pClientId is null or A.CLIENTID=pClientId) and
   (pOrderNo is null or b.ORDERNO=pOrderNo) and
    a.INVOICEDATE between vSDate and vEDate
	Group By b.INVOICEID,a.INVOICENO,a.INVOICEDATE,a.GATEPASSNO,getfncDispalyorder(b.ORDERNO),
	a.CONTACTPERSON,a.DELIVERYPLACE,a.VEHICLENO,a.DRIVERNAME,a.DRIVERLICENSENO,a.DRIVERMOBILENO,a.TRANSCOMPNAME,
	c.CLIENTNAME,e.CLIENTSREF,b.ORDERNO
	order by a.INVOICEDATE;  
  end if;
  
End getRptGarmentsDelivery;
/



PROMPT CREATE OR REPLACE Procedure  214 :: GetGISConsumption
CREATE OR REPLACE Procedure GetGISConsumption(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pStationaryID in number,
  sDate IN VARCHAR2,
  eDate IN VARCHAR2
)
AS
  vSDate date;
  vEDate date;
  BEGIN
  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  else
   vSDate := TO_DATE('01/01/1900', 'DD/MM/YYYY');
  end if;
  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  else
   vEDate := TO_DATE('01/01/2100', 'DD/MM/YYYY');
  end if;

  /* For Report GS03 Garments Machine parts Consumption Report*/
if pQueryType=1 then
 OPEN data_cursor FOR
 SELECT e.Unitofmeas,f.ITEM,f.STATIONERYID,g.BRANDNAME,nvl(f.WAVGPRICE,0) as WAVGPRICE,
 sum(decode(b.TRANSTYPEID,1,b.QUANTITY,0)) MainStore,
  sum(decode(b.TRANSTYPEID,4,b.QUANTITY,0)) as Consumption,
 (sum(decode(b.TRANSTYPEID,4,b.QUANTITY,0))*nvl(f.WAVGPRICE,0)) as TotalVal
 from T_Stationerystock a,T_StationerystockItems b,T_Unitofmeas e,T_Stationery f,T_Brand g
 where a.Stockid=b.Stockid and
 f.UNITOFMEASID=e.UNITOFMEASID(+) and
 b.STATIONERYID=f.STATIONERYID(+) and
 b.BRANDID=g.BRANDID(+) and
 b.TRANSTYPEID in (1,2,3,4) and
 /*b.STATIONERYID=pStationaryID and*/
 a.STOCKTRANSDATE between vSDate and vEDate
 Group By e.Unitofmeas,f.ITEM,f.STATIONERYID,g.BRANDNAME,nvl(f.WAVGPRICE,0)
 Having sum(decode(b.TRANSTYPEID,4,b.QUANTITY,0))>0
 order by f.ITEM;
end if;
End GetGISConsumption;
/

PROMPT CREATE OR REPLACE Procedure  215 :: GetGMPConsumption
CREATE OR REPLACE Procedure GetGMPConsumption(
  data_cursor IN OUT pReturnData.c_Records,
  pQueryType IN NUMBER,
  pPartID IN NUMBER,
  sDate IN VARCHAR2,
  eDate IN VARCHAR2
)
AS
  vSDate date;
  vEDate date;
BEGIN
  if not sDate is null then
    vSDate := TO_DATE(sDate, 'DD/MM/YYYY');
  else
   vSDate := TO_DATE('01/01/1900', 'DD/MM/YYYY');
  end if;

  if not eDate is null then
    vEDate := TO_DATE(eDate, 'DD/MM/YYYY');
  else
   vEDate := TO_DATE('01/01/2100', 'DD/MM/YYYY');
  end if;
/* For Report GS03 Garments Machine parts Consumption Report*/
if pQueryType=1 then
 OPEN data_cursor  FOR
 Select i.PartID,i.PARTNAME,i.DESCRIPTION,i.FOREIGNPART,i.MACHINETYPE,nvl(i.WAVGPRICE,0) as WAVGPRICE,i.UNITOFMEASID,i.BINNO,
 sum(decode(a.TEXMCSTOCKTYPEID,1,b.Qty,0)) MainStore,
 sum(decode(a.TEXMCSTOCKTYPEID,3,b.Qty,0)) as ReturnFromfloor,
  sum(decode(a.TEXMCSTOCKTYPEID,2,b.Qty,3,-b.Qty,0)) as Consumption,
 (sum(decode(a.TEXMCSTOCKTYPEID,2,b.Qty,3,-b.Qty,0))*nvl(i.WAVGPRICE,0)) as TotalVal
    from T_GMcStock a, T_GMcStockItems b, T_GMcPartsInfo i
    where a.StockID=b.StockID and
    b.PartID=i.PartID and
    a.TEXMCSTOCKTYPEID in (1,2,3) and
 /*b.PartID=pPartID and */
 a.STOCKDATE between vSDate and vEDate
 Group By i.PartID,i.PARTNAME,i.DESCRIPTION,i.FOREIGNPART,i.MACHINETYPE,i.WAVGPRICE,i.UNITOFMEASID,i.BINNO
 Having sum(decode(a.TEXMCSTOCKTYPEID,2,b.Qty,3,-b.Qty,0))>0
 order by i.PARTNAME;
end if;
END GetGMPConsumption;
/




PROMPT CREATE OR REPLACE Procedure  216 :: GetRptStationeryGRcv
CREATE OR REPLACE Procedure GetRptStationeryGRcv (
  data_cursor IN OUT pReturnData.c_Records,
  PStockId IN NUMBER
)
As
Begin
  OPEN data_cursor FOR
  select A.STOCKTRANSNO,A.STOCKTRANSDATE,C.SUPPLIERNAME,C.SADDRESS,A.SUPPLIERINVOICENO,A.SUPPLIERINVOICEDATE,
         B.QUANTITY,B.UNITPRICE,D.UNITOFMEAS,B.REMARKS,B.REQNO,E.ITEM,F.GROUPNAME,G.COUNTRYNAME,H.BRANDNAME
  from T_Stationerystock A,T_StationerystockItems B,T_SUPPLIER C,T_UNITOFMEAS D,T_STATIONERY E,
       T_STATIONERYGROUP F,T_COUNTRY G,T_BRAND H
  where A.StockId=B.StockId and
        A.SUPPLIERID=C.SUPPLIERID(+) AND
        B.PUNITOFMEASID=D.UNITOFMEASID(+) AND
        B.STATIONERYID=E.STATIONERYID(+) AND
  B.GROUPID=F.GROUPID(+) AND
  B.COUNTRYID=G.COUNTRYID(+) AND
  B.BRANDID=H.BRANDID(+) AND
        A.StockId=PStockId
  ORDER BY B.PID;
End GetRptStationeryGRcv;
/



