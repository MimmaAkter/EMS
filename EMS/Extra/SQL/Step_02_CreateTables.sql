PROMPT create table T_ReportGroup
Create table T_ReportGroup
(	
	ReportGroupId number(4),
	ReportGroup varchar2(50) NOT NULL
);
PROMPT create table T_ReportList
Create table T_ReportList
(
	ReportId varchar2(10),	
	ReportGroupId number(4),
	ReportBy varchar2(50),
	RptOldName varchar2(100),
	ReportTitle varchar2(200)
);
PROMPT create table T_ReportAccess
create table T_ReportAccess
(
	ReportId varchar2(10),
	EmployeeId varchar2(8),
	bAccess number(1)
);

CREATE  TABLE T_SCworkorder
(
	BasicTypeID	VARCHAR2(20),
	OrderNo		number(15) not null,
	TOrderNo		number(15) not null,
	OrderDate 	DATE,
	ClientID	VARCHAR2(20) 
	constraint nn_SCworkorder_clientid,
	SUBCONID NUMBER(6),
	SalesTermID	VARCHAR2(20) 
	constraint nn_SCworkorder_salestermid not null,
	CurrencyID	VARCHAR2(20)
	constraint nn_SCworkorder_currencyid not null,
	ConRate NUMBER(12,4)
	constraint nn_SCworkorder_conrate not null,
	SalesPersonID 	VARCHAR2(20)
	constraint nn_SCworkorder_salespersonid not null,
	Wcancelled	NUMBER(1) default 0
	constraint nn_SCworkorder_wcancelled not null, 	
	WRevised	NUMBER(1) default 0
	constraint nn_SCworkorder_wrevised not null,
	OrderStatusID	VARCHAR2(20)
	constraint nn_SCworkorder_orderstatusid not null,
	ContactPerson	VARCHAR2(100),
	ClientsRef	VARCHAR2(150),
	DeliveryPlace	VARCHAR2(200),
	DeliveryStartDate date,
	DeliveryEndDate date,
	DailyProductionTarget NUMBER(12,2),
	OrderRemarks	VARCHAR2(1000),
	OrderRef	Number(10),
	GarmentsOrderRef varchar(10),
	dorderno number(15),
	Budgetid Number(15),
	EMPLOYEEID VARCHAR2(20)
  );

	
CREATE TABLE T_SCORDERITEMS
(
  ORDERLINEITEM  VARCHAR2(20),
  WOITEMSL       NUMBER(3),
  BASICTYPEID    VARCHAR2(20),
  ORDERNO        NUMBER(15),
  KNITMCDIAGAUGE VARCHAR2(20), 
  FABRICTYPEID   VARCHAR2(20 ) CONSTRAINT NN_T_SCORDERITEMS_FABRIC NOT NULL,  
  COLLARCUFFID	NUMBER(3),
  SHADEGROUPID	NUMBER(3),
  FINISHEDGSM    NUMBER(12,2),
  WIDTH          NUMBER(12,2),
  SHRINKAGE      VARCHAR2(10 ),
  STITCHLENGTH	  VARCHAR2(100),
  SHADE          VARCHAR2(100 ),
  RATE           NUMBER(10,2),
  FEEDERCOUNT    NUMBER(3),
  GRAYGSM        NUMBER(12,2),
  CURRENTQTY NUMBER(12,2) DEFAULT 0,
  QUANTITY       NUMBER(12,2)  DEFAULT 0
  CONSTRAINT NN_T_SCORDERITEMS_QUANTITY NOT NULL,
  UNITOFMEASID   VARCHAR2(20 ) 
  CONSTRAINT NN_T_SCORDERITEMS_UNITOFMEASID NOT NULL,
  SQTY		NUMBER(12,2)  DEFAULT 0,
  SUNIT		VARCHAR2(20),
  TORDERLINEITEMREF VARCHAR2(20),
  REMARKS		VARCHAR2(200),
  BREFPID NUMBER(15)
);

CREATE  TABLE T_SCYarnDesc
(
	PID		varchar2(20),
	OrderLineItem	varchar2(20),
	YarnCountID	varchar2(20)
	constraint nn_scyarndesc_yarncountid not null,
	YarnTypeID 	varchar2(20)
        constraint nn_scyarndesc_yarntypeid not null,
	YARNBATCHNO		VARCHAR2(50),
	StitchLength	NUMBER(12,2),
	YarnPercent 	NUMBER(12,2) default 100
	constraint nn_scyarndesc_yarnPercent not null
);
PROMPT TABLE  15 :: T_SCBasicworkorder
Create Table T_SCBasicworkorder 
  (
	Workorderno 	number(15),
	Basictypeid 	Varchar2(20) 
  );
CREATE  TABLE T_ColourCombination
(
	PID		varchar2(20),
	OrderLineItem	varchar2(20),
	ColourID	varchar2(5),
	ColourLength	NUMBER(12,2)  NOT NULL,
	CUNITOFMEASID   VARCHAR2(20 )
		constraint  NN_T_Colour_CUOMID NOT NULL,
	FeederLength	NUMBER(12,2)  NOT NULL,
	FUNITOFMEASID   VARCHAR2(20 )
		constraint  NN_T_Colour_FUOMID NOT NULL
);

Prompt  Table 1:: T_Accessories
Create table T_Accessories
(
	AccessoriesId number(15),
	Item varchar2(100)	constraint nn_T_Accessories_Item not null,
	UnitOfMeasId VARCHAR2(20)	constraint nn_T_Accessories_UnitOfMeasId not null,
	Qty number(12,2),
	WavgPrice number(12,2),
	Parent number(15),
	GroupId number(3),
	SubGroupId number(3),
	STYLENO   VARCHAR2(50),
    COLOUR  VARCHAR2(50),
    CODE VARCHAR2(50),
    COUNT_SIZE VARCHAR2(50)
);

Prompt  Table 2 :: T_AccGroup

Create table T_AccGroup
(
	GroupId number(3),
	GroupName varchar2(100)
	constraint nn_T_AccGroup_GName not null
	constraint un_T_AccGroup_GName Unique
);

PROMPT  Table 3 :: T_AccImpLC
create table T_AccImpLC
(
	LCNo number(10)	constraint nn_T_AccImpLC_LCNo not null,
	BankLCNo varchar2(200)	constraint nn_T_AccImpLC_BankLCNo not null constraint u_T_AccImpLC_BankLCNo unique,
	OpeningDate date constraint nn_T_AccImpLC_OpeningDate not null,
	CurrencyId varchar2(20) constraint nn_T_AccImpLC_CurrencyId not null,
	ConRate number(12,4) constraint nn_T_AccImpLC_Conrate not null,	
	ShipmentDate date,
	ImpLCStatusId number(2) default 0 constraint nn_T_AccImpLC_ImpLCStatusId not null,
	DocRecDate date,
	DocRelDate date,
	ShipDate date,
	GoodsRecDate date,
	BankCharge number(12,2),
	Insurance number(12,2),
	TruckFair number(12,2),
	CNFValue number(12,2),
	OtherCharge number(12,2),
	Cancelled number(1) default 0 constraint nn_T_AccImpLC_Cancelled not null,
	Remarks varchar2(200),
	IMPLCTYPEID number(3) constraint nn_T_AccImpLC_LcTypeId not null,
	ExpLCNo number,	
	Linked number(2) default 0,
	LCMATURITYPERIOD number(3),
	SUPPLIERID NUMBER(15)
);

PROMPT  table 4 :: T_AccImpLCItems
create table T_AccImpLCItems
(	
	PID number(20),
	LCNo number(10),
	GroupID number(3) constraint nn_T_AccImpLCItems_GroupID not null,	
	AccessoriesID number(15) constraint nn_T_AccImpLCItems_AccID not null,			
	Qty number(12,2) constraint nn_T_AccImpLCItems_Qty not null,
	UnitPrice number(12,2) constraint nn_T_AccImpLCItems_UnitPrice not null,
	ValueFC number(12,2) constraint nn_T_AccImpLCItems_ValueFC not null,
	ValueTk number(12,2) constraint nn_T_AccImpLCItems_ValueTk not null,
	ValueBank number(12,2),
	ValueInsurance number(12,2),
	ValueTruck number(12,2),
	ValueCNF number(12,2),	
	ValueOther number(12,2),
	TotCost number(12,2) constraint nn_T_AccImpLCItems_TotCost not null,	
	UnitCost number(12,2) constraint nn_T_AccImpLCItems_UnitCost not null
);

PROMPT  table 5 :: T_ACCLASS 
CREATE TABLE T_ACCLASS
(
	CCATACODE NUMBER(2) not null, 
	CCATANAME VARCHAR2(30)	constraint nn_T_ACCLASS_CCATANAME not null,
	CCATATYPE NUMBER(10)
);


PROMPT  table 6 :: T_AccPrice
create table T_AccPrice
(
    PID NUMBER(12) not null,
	STOCKID NUMBER(20) NOT NULL,
	ACCESSORIESID NUMBER(15) NOT NULL,
	ORDERNO  VARCHAR2(100) NOT NULL,
	SupplierID number(15),
	PURCHASEDATE  DATE NOT NULL,
	QTY  NUMBER(12,2),
	UNITPRICE NUMBER(12,2) NOT NULL,
    PPRICE NUMBER(12,4),
    PQTY NUMBER(12,4),
	NPRICE NUMBER(12,4),
	NQTY NUMBER(12,4),
	REFPID NUMBER(20),
    CURRENCYID  VARCHAR2(20),
	CONRATE  NUMBER(12,4)
);

PROMPT  table 7 :: T_AccRequisition

create table T_AccRequisition
(		
    RequisitionID number(20) not null,		
	AccRequisitionTypeId number(3) not null,	
	RequisitionNo varchar2(50) not null,
	RequisitionTransDate Date not null,
	ReferenceNo varchar2(150),
	ReferenceDate Date,
	SupplierId number(15),
	SupplierInvoiceNo varchar2(20),
	SupplierInvoiceDate Date,
	Remarks varchar2(200),	
	Execute number(1)
);


PROMPT table 8 :: T_AccRequisitionItems
create table T_AccRequisitionItems
(
	PID number(20),
	RequisitionID number(20) not null,
	OrderNo varchar2(100),	
	GroupID number(3) not null,	
	StyleNo VARCHAR2(50),
	Colour  VARCHAR2(50),
	Code  VARCHAR2(50),
	AccessoriesID number(15) not null,
	Count_Size  VARCHAR2(50),					
	Quantity number(12,2) not null,
	PunitOfMeasId varchar2(20) not null,
	SQuantity number(12,2),	
	SunitOfMeasId varchar2(20),	
	Remarks varchar2(200),		
	CurrentStock number(12,2),
	GORDERNO     NUMBER(20),
	CLIENTREF    VARCHAR2(400)	
);


PROMPT  table 9 :: T_AccRequisitionType
create table T_AccRequisitionType
(
	AccRequisitionTypeId number(3),
	AccRequisitionType varchar2(100) unique not null
);

PROMPT  table 10 :: T_AccStock

create table T_AccStock
(
	StockId number(20) not null,		
	AccTransTypeID number(3) not null,	
	StockTransNo varchar2(50) not null,
	StockTransDate Date not null,
	CurrencyID varchar2(20),
	ConRate number(12,4), 
	ReferenceNo varchar2(150),
	ReferenceDate Date,
	SupplierId number(15),
	SupplierInvoiceNo varchar2(20),
	SupplierInvoiceDate Date,	
	SComplete number(1) default 0,
	Remarks varchar2(200),
	PARENTSTOCKID NUMBER(20)
);


PROMPT  table 11:: T_AccStockItems

create table T_AccStockItems
(
	PID number(20) not null,
	StockID number(20) not null,
	ImpLCNO varchar2(100),	
	OrderNo varchar2(100),		
	StyleNo VARCHAR2(50),	
	Code  VARCHAR2(50),
	AccessoriesID number(15) not null,
	Count_Size  VARCHAR2(50),				
	Quantity number(12,2) not null,
	PunitOfMeasId varchar2(20) not null,
	SQuantity number(12,2),	
	SunitOfMeasId varchar2(20),	
	Remarks varchar2(200),		
	CurrentStock number(12,2),
	ColourID  VARCHAR2(50),
	RequisitionNo varchar2(50),	
	ReqQuantity number(12,2),
	GOrderNo number(15),
	ClientRef varchar2(400),
	lineNo varchar2(50),
	UnitPrice number(12,4),
	GroupId number(3),
	PARENTSTOCKID NUMBER(20)		
);


PROMPT  table 12 :: T_AccTransactionType

create table T_AccTransactionType
(
	AccTransTypeID number(3),
	AccTransTypeName varchar2(100) constraint un_T_AccTransactionType_Name unique constraint nn_T_AccTransactionType_Name not null,	
	AccStockMain NUMBER(3),
	AccStockSub  NUMBER(3) 	
);

PROMPT  table 13 :: T_AlliedCustomer

Create table T_AlliedCustomer
(
customerid Number(6) Primary key,
name varchar2(50),
Officeno varchar2(20),
meterno varchar2(20),
contactno varchar2(50),
fax varchar2(20),
coatactPerson varchar2(50),
status Number(1) default 0,
shop number(1),
office number(1),
officesize Number(6,2),
mrate number(6,2),
maintenenceaccounts varchar2(200)
);

PROMPT  table 14 :: T_Athurization

create table T_Athurization
(
 PID     NUMBER(15),
 EMPLOYEEID   VARCHAR2(20),
 FORMID      VARCHAR2(20),
 PERMISSION  NUMBER(3) 	
);


PROMPT  TABLE 15 :: T_AtoZ
create table T_AtoZ
(
	AtoZId varchar2(3)		
);

PROMPT  TABLE 16 :: T_AuxDyelineHead
create table T_AuxDyelineHead
(
	AuxTypeId number(3),
	AuxId number(15),
	HeadId number(3)
);

PROMPT  table 17:: T_AuxFor

create table T_AuxFor
(
	AuxForId number(3),		
	AuxFor varchar2(25)
		constraint nn_T_AuxFor_AuxFor not null 
		constraint u_T_AuxFor_AuxFor unique
);

PROMPT  table 18 :: T_Auxiliaries

create table T_Auxiliaries
(
	AuxTypeId number(3),		
	AuxId number(15),
	AuxName varchar2(100)
	constraint nn_T_Auxiliaries_AuxName not null
	constraint un_T_Auxiliaries_AuxName unique,
	AuxForId number(15),
	DyeBaseId number(3),		
	UnitOfMeasId VARCHAR2(20) 
	constraint nn_T_Auxiliaries_UnitOfMeasId not null,
	AuxUnitPrice number(12,2),	
	RecipeSheetSeq number(4),
	Qty number(12,2),
	Amount number(12,2),
	WAvgPrice number(12,2)
);


PROMPT  table 19 :: T_AuxImpLC
create table T_AuxImpLC
(
	LCNo number(6) constraint nn_T_AuxImpLC_LCNo not null,
	BankLCNo varchar2(200) constraint nn_T_AuxImpLC_BankLCNo not null,
	OpeningDate date constraint nn_T_AuxImpLC_OpeningDate not null,
	CurrencyId  VARCHAR2(20) constraint nn_T_AuxImpLC_CurrencyId not null,
	ConRate number(12,4) constraint nn_T_AuxImpLC_Conrate not null,	
	ShipmentDate date,
	ImpLCStatusId number(3) default 0 constraint nn_T_AuxImpLC_ImpLCStatusId not null,
	DocRecDate date,
	DocRelDate date,
	ShipDate date,
	GoodsRecDate date,
	BankCharge number(12,2),
	Insurance number(12,2),
	TruckFair number(12,2),
	CNFValue number(12,2),
	OtherCharge number(12,2),
	Cancelled number(1) default 0 constraint nn_T_AuxImpLC_Cancelled not null,
	Remarks varchar2(200),
	IMPLCTYPEID number(3) constraint nn_T_AuxImpLC_LcTypeId not null,
	Linked number(2) default 0,
	ExpLCNo number,	
	LCMATURITYPERIOD number(3),
	SUPPLIERID NUMBER(15)
);


PROMPT  table 20 :: T_AuxImpLCItems
create table T_AuxImpLCItems
(	
	PID number(20),
	LCNo number(10),
	AuxTypeId number(3),		
	AuxId number(15),
	Qty number(12,2) constraint nn_T_AuxImpLCItems_Qty not null,
	UnitPrice number(12,2) constraint nn_T_AuxImpLCItems_UnitPrice not null,
	ValueFC number(12,2) constraint nn_T_AuxImpLCItems_ValueFC not null,
	ValueTk number(12,2) constraint nn_T_AuxImpLCItems_ValueTk not null,
	ValueBank number(12,2),
	ValueInsurance number(12,2),
	ValueTruck number(12,2),
	ValueCNF number(12,2),	
	ValueOther number(12,2),
	TotCost number(12,2) constraint nn_T_AuxImpLCItems_TotCost not null,	
	UnitCost number(12,2) constraint nn_T_AuxImpLCItems_UnitCost not null
);

PROMPT  table 21 :: T_AuxPrice
create table T_AuxPrice
(
	PID NUMBER(12) not null,
	AuxTypeId number(3),		
	AuxId number(15),
	PurchaseDate date,
	SupplierID number(15),
	UnitPrice number(12,2) not null,	
	Qty number(12,2),
	PPRICE NUMBER(12,4),
	PQTY NUMBER(12,4),
	NPRICE NUMBER(12,4),
	NQTY NUMBER(12,4),
	REFPID NUMBER(20),
	CURRENCYID  VARCHAR2(20),
	CONRATE  NUMBER(12,4)
);


PROMPT  table 22 :: T_AuxStock

create table T_AuxStock
(
	AuxStockId number(20),
	AuxStockTypeId number(3) 
	constraint nn_T_AuxStock_StockTypeId not null,
	StockInvoiceNo varchar2(20),
	StockDate date
	constraint nn_T_AuxStock_StockDate not null,
	PurchaseOrderNo varchar2(20),
	PurchaseOrderDate date,
	SupplierID number(15),
	DeliveryNote varchar2(20),
	DeliveryNoteDate date,
	SUBCONID NUMBER(6),
	sCOMPLETE NUMBER(1),
	CURRENCYID VARCHAR2(20),
	CONRATE NUMBER(12,4)
);


PROMPT  table 23 :: T_AuxStockItem

create table T_AuxStockItem
(
	AuxStockId number(20)
	constraint nn_T_AuxSItem_AuxStockId not null,
	AuxStockSL number(3) not null,
	PID number(20) not null,
	AuxTypeId number(3)
	constraint nn_T_AuxSItem_AuxTypeId not null,
	AuxId number(15)
	constraint nn_T_AuxSItem_AuxId not null,
	StockReqQty number(12,4),	
	StockQty number(12,4)
	constraint nn_T_AuxSItem_StockQty not null,
	StoreFolio varchar2(20),
	Remarks varchar2(100),
	UnitPrice number(12,4),
	CurrentStock number(12,2),
	SupplierID number(15)
);

PROMPT  table 24 :: T_AuxStockItemRequisition

create table T_AuxStockItemRequisition
(
	AuxStockId number(20)
	constraint nn_T_AuxSItemR_AuxStockId not null,
	AuxStockSL number(3) not null,
	PID number(20) not null,
	AuxTypeId number(3)
	constraint nn_T_AuxSItemR_AuxTypeId not null,
	AuxId number(15)
	constraint nn_T_AuxSItemR_AuxId not null,
	StockReqQty number(12,4),	
	StockQty number(12,4)
	constraint nn_T_AuxSItemR_StockQty not null,
	StoreFolio varchar2(20),
	Remarks varchar2(100),
	UnitPrice number(12,4),
	CurrentStock number(12,2),
	SupplierID number(15)
);

PROMPT  table 25 :: T_AuxStockRequisition

create table T_AuxStockRequisition
(
	AuxStockId number(20),
	AuxStockTypeId number(3) 
	constraint nn_T_AuxStockR_StockTypeId not null,
	StockInvoiceNo varchar2(20),
	StockDate date
	constraint nn_T_AuxStockR_StockDate not null,
	PurchaseOrderNo varchar2(20),
	PurchaseOrderDate date,
	SupplierID number(15),
	DeliveryNote varchar2(20),
	DeliveryNoteDate date,
	SUBCONID NUMBER(6),
    Executed	NUMBER(1) default 0
	constraint nn_AuxStockReq_Executed not null
);


PROMPT  table 26 ::  T_AuxStockType
create table T_AuxStockType
(
	AuxStockTypeId number(3),		
	AuxStockType varchar2(40)
	constraint nn_T_AuxStockType_StockType not null 
	constraint u_T_AuxStockType_StockType unique
);


PROMPT  table 27 ::  T_AUXSTOCKTYPEDETAILS
CREATE TABLE T_AUXSTOCKTYPEDETAILS
(
  AUXSTOCKTYPEID     NUMBER(3),
  AUXSTOCKTYPE       VARCHAR2(40)
  constraint NN_T_AUXSTOCKTD_AuxSTOCKTYPE NOT NULL,
  AUXTYPEID          NUMBER(3),
  AUXSTOCKBANK       NUMBER(1),
  AUXSTOCKMAIN       NUMBER(1),
  AUXSTOCKSECONDARY  NUMBER(1),
  ASLOANTOPARTY NUMBER(3),
  ASLOANFROMPARTY NUMBER(3)
);


PROMPT  table 28 ::  T_AuxStockTypeRequisition
create table T_AuxStockTypeRequisition
(
	AuxStockTypeId number(3),		
	AuxStockType varchar2(40)
	constraint nn_T_AuxStockTypeR_StockType not null 
	constraint u_T_AuxStockTypeR_StockType unique
);


PROMPT  table 29:: T_AuxType

create table T_AuxType
(
	AuxTypeId number(3),		
	AuxType varchar2(20)
		constraint nn_T_AuxType_AuxType not null 
		constraint u_T_AuxType_AuxType unique
);

PROMPT  table 30:: T_BASICSUBCONTRACTOR

CREATE TABLE T_BASICSUBCONTRACTOR
(
  BASICTYPEID  VARCHAR2(20) constraint nn_BSubcon_BasicTypeId NOT NULL,
  SUBCONID     NUMBER(6) constraint nn_BSubcon_SubConId NOT NULL,
  PID  VARCHAR2(20) constraint nn_BSubcon_PID NOT NULL
);


PROMPT  TABLE  31 :: T_BasicType
CREATE  TABLE T_BasicType
(
	BasicTypeID	VARCHAR2(20),
	BasicTypeName	VARCHAR2(50) constraint nn_basictype_basictypename not null
			 constraint u_basictype_basictypename unique,
	UnitOfMeasID	VARCHAR2(20) constraint nn_basictype_unitofmeasid not null,
	ASICTYPESL  NUMBER(5) NOT NULL
);

PROMPT TABLE 32 :: T_Basicworkorder

Create Table T_Basicworkorder 
  (
	Workorderno 	number(15),
	Basictypeid 	Varchar2(20) 
  );
  
  
PROMPT  table 33 :: T_Bill

create table T_Bill
(
	ORDERCODE  VARCHAR2(10),
	BillNo number(6),
	BillDate date
		constraint nn_T_Bill_BillDate not null,
	CLIENTID   VARCHAR2(20) 
		constraint nn_T_Bill_ClientId not null,
	BillDiscount number(12,2),
	BillDisComments varchar2(50),
	BillDisPerc number(5,2),
	CURRENCYID  VARCHAR2(20)
		constraint nn_T_Bill_CurrencyId not null,		
 	CONRATE     NUMBER(12,4)
		constraint nn_T_Bill_BConRate not null,
	Cancelled number(1) default 0
		constraint nn_T_Bill_Cancelled not null 
		constraint c_T_Bill_Cancelled check(Cancelled in(0,1)),
	BillComments varchar2(1000),
	EMPLOYEEID  VARCHAR2(20),
	KNITTING NUMBER(3),
	DYEING NUMBER(3),
	FABRIC NUMBER(3)
);


PROMPT  table 34 :: T_BillItems

create table T_BillItems
(
	ORDERCODE  VARCHAR2(10),
	BillNo number(6),
	BillItemSl number(3),
	DORDERCODE  VARCHAR2(10),
	DInvoiceNo VARCHAR2(50),/* number(6),*/
	DItemSl number(3),
	WORDERCODE  VARCHAR2(10)
		constraint nn_T_BillItems_WORDERCODE not null,
	ORDERNO   NUMBER(15)
		constraint nn_T_BillItems_ORDERNO not null,
	WoItemSl number(3)
		constraint nn_T_BillItems_WoItemSl not null,
	BillItemsQty number(10,2)
		constraint nn_T_BillItems_BillItemsQty not null,
	BillItemsUnitPrice number(12,4)
		constraint nn_T_BillItems_BillItemsUnitPr not null,
	ColorDepthId number(3),
    punit varchar2(20),
	sqty number(12,2),
	sunit varchar2(20)	
);

PROMPT  table 35 :: T_BillPayment
create table T_BillPayment
(
	ORDERCODE varchar2(10),
	BillNo number(6),
	BillPayItemSl number(3),
	OrderNo number(6)
		constraint nn_T_BillPayment_OrderNo not null,
	BillPmtDate date
		constraint nn_T_BillPayment_BillPmtDate not null,
	BillWoPmt number(10,2)
		constraint nn_T_BillPayment_BillWoPmt not null	
);

PROMPT  table 36 :: T_Brand
CREATE TABLE T_Brand
(
BrandID NUMBER(6) PRIMARY KEY,
BrandName vARCHAR2(100)
);


PROMPT create table 37 :: T_BTBLCPayment
create table T_BTBLCPayment
(	
	PID number(10),
	LCNo number(10)		 constraint nn_T_BTBLCPayment_LCNo not null,
	LCCategory number(2)     constraint nn_T_BTBLCPayment_LCCategory not null,	
	IFDBCNo varchar2(20)     constraint nn_T_BTBLCPayment_IFDBCNo not null,		
	IFDBCDate Date           constraint nn_T_BTBLCPayment_IFDBCDate not null,
	IFDBCAmount number(12,2) constraint nn_T_BTBLCPayment_Amt not null,
    DUEDATE DATE,
    PAYMENTDATE DATE,
    PAIDAMOUNT NUMBER(15,4),
    BALANCE NUMBER(15,4) 	
);

PROMPT  TABLE  38 :: T_Budget

CREATE  TABLE T_Budget
(
	BudgetID Number(15),
	BudgetNo Varchar2(20),
        ClientID VARCHAR2(20),
	Orderno Number(15),
	OrderRef Varchar2(50),
	OrderDesc Varchar2(100),
	LcNo Number(15),
	LcReceiveDate Date,
	LcExpiryDate Date,
	ShipmentDate Varchar2(20),
	LcValue Number(15),
	Quantity Number(15),
	UnitPrice Number(12,4),
        BUDGETPREDATE Date,
 	COMPLETE NUMBER(1),  
 	REVISION NUMBER(3),  
 	POSTDATE VARCHAR2(50),
	ORDERTYPEID VARCHAR2(5),
	PI varchar2(30),
	cadrefno Varchar2(30),
	EMPLOYEEID   VARCHAR2(20),
	AUTHORIZEDID  VARCHAR2(20),
	UNITQTY NUMBER(12,4) DEFAULT 1
);

PROMPT  TABLE  39 :: T_BudgetParameter

CREATE  TABLE T_BudgetParameter
(	
	paramid Number(6),
	ParameterName Varchar2(50),
	ParameterOrder Number(6),
	UnitOfMeasID Varchar2(20)
);	

PROMPT  TABLE 40 :: T_BudgetStageParameter

CREATE  TABLE T_BudgetStageParameter
(	
	PID Number(15),
	Stageid Number(6),
	paramid Number(6),
	ParameterOrder Number(6)	
);	


PROMPT  TABLE  41 :: T_BudgetStages

CREATE  TABLE T_BudgetStages
(
	StageID Number(6),
	StageName Varchar2(50),
	STAGEORDER Number(6)
);


PROMPT  TABLE  42 :: T_CANDF
CREATE TABLE T_CANDF
(
	CANDFID NUMBER(15), 	
	CANDFNAME VARCHAR2(150) 
	constraint nn_T_CANDF_Name NOT NULL, 
	CANDFADDRESS VARCHAR2(500) 
	constraint nn_T_CANDF_Add NOT NULL, 
	TELEPHONE VARCHAR2(100),		 
	REMARKS VARCHAR2(200)
);


PROMPT CREATING TABLE  43 :: T_Client

CREATE  TABLE T_Client
(
	ClientID VARCHAR2(20),
	ClientName VARCHAR2(200) 
		    constraint nn_client_clientname not null
		     constraint u_client_clientname unique,
	ClientStatusID	VARCHAR2(20)  default 1,
	CAddress VARCHAR2(200) 
		   constraint nn_client_caddress not null,
	CFactoryAddress	VARCHAR2(200),
	CTelephone VARCHAR2(100),
	CFax VARCHAR2(100),
	CEmail VARCHAR2(100),
	CURL VARCHAR2(100),
	CContactPerson VARCHAR2(100) 
	constraint nn_client_ccontactperson not null,
	CAccCode VARCHAR2(30),
	CRemarks VARCHAR2(200),
	ClientGroupID VARCHAR2(20) 
	constraint nn_client_cclientgroupid not null,
	clientRef varchar2(20)
);

PROMPT CREATING TABLE  43 :: T_CompanyInfo

CREATE  TABLE T_CompanyInfo
(
	CompanyID VARCHAR2(20),
	CompanyName VARCHAR2(200) 
		    constraint nn_Company_Companyname not null
		     constraint u_Company_Companyname unique,
	CompanyName1 VARCHAR2(200),
	CompanyName2 VARCHAR2(200),
	CompanyName3 VARCHAR2(200),
	CompanyName4 VARCHAR2(200),
	CompanyName5 VARCHAR2(200),
	CompanyName6 VARCHAR2(200),
	CHOAddress VARCHAR2(200) 
		   constraint nn_Company_caddress not null,
	CHOTelephone VARCHAR2(100),
	CHOFax VARCHAR2(100),
	CHOEmail VARCHAR2(100),
	CHOURL VARCHAR2(100),
	CFactoryAddress	VARCHAR2(200),
	CFTelephone VARCHAR2(100),
	CFFax VARCHAR2(100),
	CFEmail VARCHAR2(100),
	CFURL VARCHAR2(100),
	CContactPerson VARCHAR2(100) 
	constraint nn_Company_ccontactperson not null,
	CRemarks VARCHAR2(200)
);

ALTER TABLE T_CompanyInfo
 ADD
   (
	constraint pk_CompanyInfo_CompanyID PRIMARY KEY(CompanyID)
   );


PROMPT  TABLE 44 :: T_CLIENTGROUP

CREATE  TABLE T_CLIENTGROUP
(
	FCLIENTGROUPID   VARCHAR2(20) NOT NULL,
	CLIENTGROUPNAME   VARCHAR2(150)
);


PROMPT  TABLE 45 ::  T__CollarCuff
create table T_CollarCuff
(
	CollarCuffId number(3),		
	CollarCuffSize varchar2(50) not null 
);



PROMPT  table 46 :: T_Colour

create table T_Colour
(
	ColourID varchar2(5) NOT NULL,
	ColourName VARCHAR2(50)  NOT NULL
);

PROMPT TABLE  47 :: T_Combination

CREATE  TABLE T_Combination
(
	CombinationID	VARCHAR2(20) not null,
	Combination	VARCHAR2(200)
    	constraint nn_combination_combination not null
    	constraint u_combination_combination unique
);

PROMPT  table 48 :: T_Count
create table T_Count
(
	CountId number(3),		
	CountName varchar2(10)
		constraint nn_T_Count_CountName not null 
		constraint u_T_Count_CountName unique,
	Ticket varchar2(10),
	CountLength number(10),
	CountWeight number(12,4),
	GrayCost number(12,2),
	FinishedCost number(12,2),
	InOperationId number(1)
		constraint nn_T_Count_InOperationId not null		 
);

PROMPT TABLE  49 :: T_Country

Create Table T_Country
  (
 	CountryID   	Varchar2(6),
 	CountryName     Varchar2(100)
  		CONSTRAINT NN_T_Country_CountryName NOT NULL
  		constraint u_T_Country_CountryName unique
  );
  
  
  PROMPT TABLE  50 ::  T_CTN
  CREATE  TABLE T_CTN
(
	CTNID number(15),
	orderno number(15) not null,
	CTNType varchar2(10),
	CTNSize varchar2(50)
);

PROMPT TABLE  51 ::  T_CTNItems
CREATE  TABLE T_CTNItems
(
	PID number(15),
	SL number(3),
	CTNID number(15),
	Shade	VARCHAR2(100),
	Style VARCHAR2(50),
	SizeID	VARCHAR2(10),
	Quantity number(15),
	Punit varchar2(20)
)

PROMPT TABLE 52 ::  T_Currency

create table T_Currency
(
	CurrencyID	VARCHAR2(20),
	CurrencyName	VARCHAR2(20) 
		constraint nn_currency_currencyName not null 
		constraint u_currency_currencyname unique,
 	ConRate 	NUMBER(12,4)
		constraint nn_currency_conrate not null,
	EConRate	NUMBER(12,4)
);


PROMPT TABLE 53 :: T_DBatch

CREATE TABLE T_DBatch
(
	DBatchId  	number(20),
	BatchNo       	varchar2(150) NOT NULL,
	BatchDate       Date NOT NULL,
	Exucute		number(1)
);


PROMPT TABLE 54 :: T_DBatchItems
CREATE TABLE T_DBatchItems
(
	PID		number(20),
	DBatchId  	number(20)
	constraint nn_T_DBatchItems_DBatchId not null,
	BatchItemSL   	number(3) ,
	FabricTypeId    varchar2(20),
	OrderLineItem	varchar2(20),
	CurrentStock NUMBER(12,2),
	Quantity number(12,2)
	constraint nn_T_DBatchItems_Qty not null,
	SQuantity number(12,2),
	PunitOfMeasId varchar2(20)
	constraint nn_T_DBatchItems_PUOM not null,
	SunitOfMeasId varchar2(20),
	Shade varchar2(100),
	Remarks varchar2(200),
	orderno number(15),
	YARNBATCHNO VARCHAR2(50),
	DYEDLOTNO VARCHAR2(50),
	SHADEGROUPID NUMBER(3)
);

PROMPT TABLE 55 :: T_DEPARTMENT
CREATE TABLE T_DEPARTMENT
(
DEPTID NUMBER(15) PRIMARY KEY,
DEPTNAME vARCHAR2(100)
);

PROMPT TABLE  56 :: T_Designation

CREATE  TABLE T_Designation
(
	DESIGNATIONID	varchar2(20) not null,
	DESIGNATION	varchar2(20)
   	constraint nn_designation_DESIGNATION not null,
	GRADE		NUMBER(3)
	constraint nn_designation_grade not null
);


PROMPT TABLE  57 :: T_DInvoice
create table T_DInvoice
(
	DInvoiceId number(20) constraint nn_T_DInvoice_DId not null,		
	InvoiceNo number(20) constraint nn_T_DInvoice_DINo not null
        constraint u_T_DInvoice_DINo unique,
	InvoiceDate Date
	constraint nn_T_DInvoice_DIDate not null,
	ClientId varchar2(20)
	constraint nn_T_DInvoice_ClientId not null,
	ContactPerson varchar2(100),
	DeliveryPlace varchar2(200),
	GatePassNo number(20),
	DINVOICECOMMENTS VARCHAR2(200),
	DTYPE   VARCHAR2(5),
	ORDERNO NUMBER(15),
	MREMARKS VARCHAR2(200)
);

PROMPT  table 58 :: T_DInvoiceItems

create table T_DInvoiceItems
(
	PID number(20),
	DInvoiceId number(20)
	constraint nn_T_DInvoiceItems_DId not null,		
	DInvoiceItemSL number(3),
	FabricTypeId varchar2(20),
	OrderLineItem varchar2(20),
	Quantity number(12,2)
	constraint nn_T_DInvoiceItems_Qty not null,
	SQuantity number(12,2),
	PunitOfMeasId varchar2(20)
	constraint nn_T_DInvoiceItems_PUOM not null,
	SunitOfMeasId varchar2(20),
	Shade varchar2(100),
	Remarks varchar2(200),
	orderno number(15),
        DBatch varchar2(150),
	FinishedDia varchar2(150),
	FinishedGSM number(12,2),
	GWT number(12,2),
	FWT number(12,2),
    SHADEGROUPID NUMBER(3),
	YARNBATCHNO  VARCHAR2(150),
	ITEMDESC VARCHAR2(200),
	CURRENTQTY NUMBER(12,2),
	RETURNEDQTY NUMBER(12,2),
	NONRETURNABLE NUMBER(15,2)	
);


PROMPT  TABLE 59 :: T_DProfileItems
create table T_DProfileItems
(
	PID NUMBER(15),
	HeadId number(3),
	ProfileId Varchar2(3),
	ProfileItemSl number(6),
	AuxTypeId number(3)
		constraint nn_T_DProfileItems_AuxTypeId not null,
	AuxId number(15)
		constraint nn_T_DProfileItems_AuxId not null,
	AuxQty number(12,4)
		constraint nn_T_DProfileItems_AuxQty not null,
	UnitOfMeasId Varchar2(20)
		constraint nn_T_DProfileItems_UnitId not null
);

PROMPT  TABLE 60 :: T_DSubHeads
create table T_DSubHeads
(
	DyelineId number(20),		
	HeadId number(3),	
	HeadOrder number(3)
		constraint nn_T_DSubHeads_HeadOrder not null,
	HeadComments varchar2(300)	
);



PROMPT  TABLE 61 :: T_DSubItems
create table T_DSubItems
(
	DSubItemsId number(20),		
	DyelineId number(20) 
		constraint nn_T_DSubItems_DyelineId not null,
	HeadId number(3)
		constraint nn_T_DSubItems_HeadId not null,
	AuxTypeId number(3)
		constraint nn_T_DSubItems_AuxTypeId not null,
	AuxId number(15)
		constraint nn_T_DSubItems_AuxId not null,
	AuxQty number(12,4)
		constraint nn_T_DSubItems_AuxQty not null,
	UNITPRICE NUMBER(12,2),
	UnitOfMeasId Varchar2(20)
		constraint nn_T_DSubItems_UnitedId not null,
	AuxIncDecBy number(12,4),
	AuxAddition number(12,4),
	AuxAddCount number(3) default 0
		constraint nn_T_DSubItems_AuxAddCount not null,
	AuxTotQtyPerc number(12,4),
	AuxTotQtyGm number(12,4) default 0
		constraint nn_T_DSubItems_AuxTotQtyGm not null	
);

PROMPT  TABLE 62 ::  T_DUnitOfMeas

CREATE  TABLE T_DUnitOfMeas
(
	UnitOfMeasID	VARCHAR2(20) not null,
	UnitOfMeas	VARCHAR2(20)
	constraint nn_Dunitofmeas_unitofmeas not null
	constraint u_Dunitofmeas_unitofmeas unique
);


PROMPT  table 63 :: T_DyeBase

create table T_DyeBase
(
	DyeBaseId number(3),		
	DyeBase varchar2(30)
		constraint nn_T_DyeBase_DyeBase not null 
		constraint u_T_DyeBase_DyeBase unique,
	AuxForId number(3) 
		constraint nn_T_DyeBase_AuxForId not null,
	bUsedInRecipe number(1) default 0
);

PROMPT TABLE 64 :: T_Dyeline
create table T_Dyeline
(
	DyelineId number(20),	
	DBatchID number(20)
		constraint nn_T_Dyeline_BatchNo not null,	
	UDyelineId varchar2(20) unique
		constraint nn_T_Dyeline_UDyelineId not null, 
	DyelineNo number(6),
	DyelineDate date
		constraint nn_T_Dyeline_DyelineDate not null,
	MachineId number(6)
		constraint nn_T_Dyeline_MachineId not null,
	dLiquor number(12,2)
		constraint nn_T_Dyeline_dLiquor not null,
	dWeight number(12,2)
		constraint nn_T_Dyeline_dWeight not null,
	PackageCount number(12,2),
	DyeingProgram number(12),
	ProdDate date,
	dStartDateTime varchar2(25),
	dEndDateTime varchar2(25),
	FinishedWeight number(12,2),
	DyeingShift varchar2(3),		
	dComments varchar2(200),
	dParent number(20)
		constraint nn_T_Dyeline_dParent not null,
	dReCount number(3) default 0
		constraint nn_T_Dyeline_dReCount not null,
	dComplete number(1) default 0
		constraint nn_T_Dyeline_dComplete not null,
	dReDyeingCount number(3) default 0
		constraint nn_T_Dyeline_dReDyeingCount not null,
	bPostedToStock number(1) default 0
		constraint nn_T_Dyeline_bPostedToStock not null,
	DLIQUORRATIO NUMBER(3),
	EMPLOYEEID VARCHAR2(20)
);


PROMPT TABLE 65 :: T_DyelineHead
create table T_DyelineHead
(
	HeadId number(3),		
	HeadName varchar2(50)
		constraint nn_T_DyelineHead_HeadName not null 
		constraint u_T_DyelineHead_HeadName unique,
	HeadOrder number(3)
		constraint nn_T_DyelineHead_HeadOrder not null,
	AuxTypeId number(3)
		constraint nn_T_DyelineHead_AuxTypeId not null,
	HeadMcWash number(1)	
);

PROMPT TABLE 66 :: T_DyelineProfile
create table T_DyelineProfile
(
	HeadId number(3),		
	ProfileId varchar2(3),		
	ProfileDesc varchar2(50)
		constraint nn_T_DyelineProfile_ProfileDes not null	
);

PROMPT  TABLE 67 :: T_DyelineShift
create table T_DyelineShift
(
	ShiftId varchar2(3),		
	StartTime varchar2(10)
		constraint nn_T_DyelineShift_StartTime not null,
	EndTime varchar2(10)
		constraint nn_T_DyelineShift_EndTime not null		
);

PROMPT  TABLE 68 :: T_DyeMachines
create table T_DyeMachines
(
	MachineId number(6),		
	MachineName varchar2(40)
		constraint nn_T_DyeMachines_MachineName not null 
		constraint u_T_DyeMachines_MachineName unique,
	Liquor number(12,2)
		constraint nn_T_DyeMachines_Liquor not null,
	Capacity number(12,2)
		constraint nn_T_DyeMachines_Capacity not null,
	MinCapacity number(12,2)
		constraint nn_T_DyeMachines_MinCapacity not null,
	MaxCapacity number(12,2)
		constraint nn_T_DyeMachines_MaxCapacity not null,
	BatchCount number(3)
		constraint nn_T_DyeMachines_BatchCount not null,
	Status number(3)
		constraint nn_T_DyeMachines_Status not null,
	Enabled number(1)
		constraint nn_T_DyeMachines_Enabled not null,
	Priority number(3)
		constraint nn_T_DyeMachines_Priority not null
);


PROMPT  TABLE 69 :: T_ElectricityBill
Create Table T_ElectricityBill
(
Pid Number(15),
Serialno Number(15),
billmonth Date,
Customerid Number(6),
Currentreading Number(15),
Currentreadingdate Date,
Prevreading Number(15),
Prevdate Date,
usenceunit number(6),
unitrate Number(10,2),
issuedate Date,
paymentdate Date,
usencecost Number(15,4),
govtduty Number(10,2),
servicecharge Number(10,2),
demandcharge Number(10,2),
vat Number(10,2),
Dueamount Number(15,2),
payableamount Number(15,2),
totalamount Number(15,2),
paid Number(1) default 0,
employeeid varchar2(20),
PAIDAMOUNT Number(15,4),
PaidDate Date,
unlockby varchar2(20),
Billtype number(3),
payableinwords varchar2(200),
totalpayableinwords varchar2(200),
BMonth Varchar2(20),
Byear Varchar2(20)
);


PROMPT TABLE 70 :: T_EmpForms

Create Table T_EmpForms
  (
	EmployeeID 	Varchar2(20),
	FormID 		Varchar2(20),
	FormPermission	Number(2) NOT NULL
  );

  
  PROMPT TABLE  71 :: T_EmpGroup

CREATE  TABLE T_EmpGroup
(
	EmpGroupID	VARCHAR2(20),
    	EmpGroup 	VARCHAR2(100)
	constraint nn_empgroup_empgroup not null
	constraint u_empgroup_empgroup unique
);


PROMPT  TABLE  72  ::  T_Employee

CREATE TABLE T_Employee
(
	EmployeeID	VARCHAR2(20),
	EmployeeName	VARCHAR2(150)
	constraint nn_employee_employeename not null,
	DesignationID	VARCHAR2(20)
	constraint nn_employee_designationid not null,
	EmpGroupID	VARCHAR2(20)
	constraint nn_employee_empgroupid not null,
	EmpStatusID	VARCHAR2(20) default 1
	constraint nn_employee_empstatusid not null,
	EmpPassword	VARCHAR2(8)
	constraint nn_employee_emppassword not null,
	EmpManager	VARCHAR2(8)
	constraint nn_employee_empmanager not null,
	EmpContactNo	VARCHAR2(20),
	EMPPARADDRESS	varchar2(200)
	constraint nn_employee_empparaddress not null,
	EMPPRESADDRESS	varchar2(200)
	constraint nn_employee_emppreddress not null,
	EMPEMAIL	varchar2(20),
	AUTHORIZEDFOR VARCHAR2(3)
);

PROMPT TABLE  73 :: T_EMPLOYEEASSIGN

CREATE  TABLE T_EMPLOYEEASSIGN
(
	EMPID    VARCHAR2(20),
	ROLEID   VARCHAR2(20),
	PID   VARCHAR2(20)
);

PROMPT table 74 :: T_ExpLCType
create table T_ExpLCType
(
	ExpLCTypeID number(3), 
	ExpLCTypeName varchar2(20) constraint nn_T_ExpLCType_ExpLCTypeName not null constraint u_T_ExpLCType_ExpLCTypeName unique
);

PROMPT  TABLE  75 :: T_FabricConsumption

CREATE  TABLE T_FabricConsumption
(
BUDGETID NUMBER(15),
PID NUMBER(15),
YARNTYPEID VARCHAR2(20),
FABRICTYPEID VARCHAR2(20),
GSM NUMBER(12,2),
CONSUMPTIONPERDOZ NUMBER(10,2),
WASTAGE NUMBER(3),
NETCONSUMPTIONPERDOZ NUMBER(12,4),
TOTALCONSUMPTION NUMBER(12,2),
STAGEID NUMBER(6),
RPERCENT NUMBER(3),
PCS NUMBER(12,2),
STYLENO VARCHAR2(50),
SHADEGROUPID  NUMBER(3)
);

PROMPT TABLE 76 :: T_FabricType

CREATE  TABLE T_FabricType
(
	FabricTypeID VARCHAR2(20),
	FabricType VARCHAR2(200) 
	      constraint nn_fabrictype_FabricType not null 
	      constraint u_fabrictype_FabricType unique
);


PROMPT TABLE 77 :: T_FINISHINGPARAMMASTER

CREATE  TABLE T_FINISHINGPARAMMASTER
(
 PARAMETERID    NUMBER(6) NOT NULL,
 PARAMETERNAME     VARCHAR2(100) NOT NULL,
 PARAMETERORDER   NUMBER(6),
 UNITOFMEASID    VARCHAR2(20)
);

PROMPT TABLE 78 :: T_FINISHINGRESULT

CREATE  TABLE T_FINISHINGRESULT
(
 FRID     NUMBER(6) NOT NULL,
 ROUTECARDID   NUMBER(6) NOT NULL,
 FABRICBATCHID   NUMBER(6),
 FINALWIDTH   NUMBER(10,2),
 FINALGSM   NUMBER(6),
 GREYWEIGHT   NUMBER(10,2),
 FINISHEDWEIGHT  NUMBER(10,2),
 NOOFROLLS   NUMBER(6),
 SHRINKAGE_L    NUMBER(10,2),
 SHRINKAGE_W  NUMBER(10,2),
 SPIRALITY   NUMBER(6),
 PROLOSS  NUMBER(10,2),
 PROCESSLOSS   NUMBER(10,2),
 FASTNESS   VARCHAR2(100),
 REMARKS  VARCHAR2(500)
);

PROMPT  TABLE 79 :: T_FINISHINGSTAGEPARAMETER

CREATE  TABLE T_FINISHINGSTAGEPARAMETER
(
 STAGEPARAMETERID   NUMBER(6) NOT NULL,
 STAGEID   NUMBER(6) NOT NULL,
 PARAMETERID    NUMBER(6) NOT NULL,
 PARAMETERORDER     NUMBER(6)
);

PROMPT  TABLE 80 :: T_FINISHINGSTAGESMASTER

CREATE  TABLE T_FINISHINGSTAGESMASTER
(
  STAGEID   NUMBER(6) NOT NULL,
  STAGENAME  VARCHAR2(100),
  STAGEORDER  NUMBER(6)
);

PROMPT  TABLE 81 :: T_FORMGROUP

CREATE  TABLE T_FORMGROUP
( 
	FORMGROUPID  NUMBER(4) NOT NULL,
	FORMGROUP   VARCHAR2(50) NOT NULL
);


PROMPT  TABLE 82 :: T_FORMS

CREATE  TABLE T_FORMS
( 
 FORMID   VARCHAR2(20) NOT NULL,
 FORMDESC  VARCHAR2(300) NOT NULL,
 FORMGROUPID NUMBER(4),
 FORMSERIAL  NUMBER(4)
);


PROMPT  TABLE 83 :: T_GARMENTSCOST

CREATE  TABLE T_GARMENTSCOST
( 
	BUDGETID   NUMBER(15),
	PID     NUMBER(15) NOT NULL,
	STAGEID    NUMBER(6),
	PARAMID   NUMBER(6),
	SUPPLIERID   NUMBER(15),
	CONSUMPTIONPERDOZ  NUMBER(12,2),
	QUNATITY   NUMBER(12,2),
	UNITPRICE    NUMBER(12,4),
	ACCESSORIESID   NUMBER(15),
	GROUPID  NUMBER(3),
	UNITOFMEASID  VARCHAR2(20),
	QTY   VARCHAR2(20),
	WASTAGE    NUMBER(3),
	CONSUMPTION  NUMBER(12),
	TOTALCOST  NUMBER(12,3),
	SUBCONID  NUMBER(6)
);


PROMPT  TABLE 84 :: T_GATTACHMENTREF
CREATE  TABLE T_GATTACHMENTREF
(
	ATTACHMENTID   NUMBER(10) NOT NULL,
	GORDERNO    NUMBER(15) NOT NULL,
	ATTACHLOCATION   VARCHAR2(400) NOT NULL,
	ATTACHDESC  VARCHAR2(400)
);

PROMPT table 85 :: T_GDELIVERYCHALLAN
create table T_GDELIVERYCHALLAN
(	
	InvoiceId number(20)
	constraint nn_T_GDCHALLAN_CId not null,	
	ChallanNo varchar2(150),
	ChallanDate Date,
	Invoiceno varchar2(50)
	constraint nn_T_GDCHALLAN_StockTranNo not null,
	InvoiceDate Date
	constraint nn_T_GDCHALLAN_StockTDate not null,	
	SubConId number(6),	
	Clientid Varchar2(20),
	PoNo varchar2(50),
	GatepassNO varchar2(50),
	Remarks varchar2(300),
	orderno number(15),
	contactperson varchar2(200),
	DeliveryPlace Varchar2(500),
	catid Number(3),
    VEHICLENO VARCHAR2(50),
	DRIVERNAME VARCHAR2(100),
	DRIVERLICENSENO VARCHAR2(100),
	DRIVERMOBILENO VARCHAR2(50),
	TRANSCOMPNAME VARCHAR2(150),
	CANDFID NUMBER(15),
	DELORDERTYPEID VARCHAR2(5) DEFAULT 'G',
	EMPLOYEEID VARCHAR2(20),
	LOCKNO VARCHAR2(100)
);


PROMPT table 86 :: T_GDELIVERYCHALLANITEMS
create table T_GDELIVERYCHALLANITEMS
(	
 PID  NUMBER(20) NOT NULL,
 INVOICEID   NUMBER(20) NOT NULL,
 GSTOCKITEMSL   NUMBER(3),
 QUANTITY   NUMBER(12,2) NOT NULL,
 SQUANTITY   NUMBER(12,2),
 PUNITOFMEASID    VARCHAR2(20) NOT NULL,
 SUNITOFMEASID VARCHAR2(20),
 BATCHNO  VARCHAR2(50),
 SHADE   VARCHAR2(100),
 STYLENO   VARCHAR2(100),
 REMARKS  VARCHAR2(300),
 ORDERNO   NUMBER(15),
 CURRENTSTOCK   NUMBER(12,2),
 SIZEID   VARCHAR2(20),
 CARTONNO  NUMBER(20),
 COUNTRYID   VARCHAR2(20),
 CUTTINGID    VARCHAR2(50),
 CTNTYPE   VARCHAR2(20),
 CBM    NUMBER(10,2),
 SAMPLEID  NUMBER(3),
 RETURNABLE  NUMBER(15,2),
 NONRETURNABLE  NUMBER(15,2),
 RETURNEDQTY   NUMBER(12,2),
 ITEMSDESC VARCHAR2(500)
);

PROMPT table 87 :: T_GFABRICREQ
create table T_GFABRICREQ
(	
 STOCKID    NUMBER(20) NOT NULL,
 CHALLANNO  VARCHAR2(150),
 CHALLANDATE   DATE,
 STOCKTRANSNO   VARCHAR2(50) NOT NULL,
 STOCKTRANSDATE   DATE NOT NULL,
 SUBCONID     NUMBER(6),
 CURRENCYID   VARCHAR2(20),
 CONRATE    NUMBER(12,4),
 CLIENTID    VARCHAR2(20),
 PONO        VARCHAR2(50),
 GATEPASSNO   VARCHAR2(50),
 REMARKS   VARCHAR2(200),
 PARENTSTOCKID   NUMBER(20),
 EXECUTE       NUMBER(1),
 REQTYPE    NUMBER(3)
);

PROMPT table 88 :: T_GFABRICREQITEMS
create table T_GFABRICREQITEMS
(	
 PID   NUMBER(20) NOT NULL,
 GFABRICREQTYPEID    NUMBER(3) NOT NULL,
 STOCKID    NUMBER(20) NOT NULL,
 GSTOCKITEMSL   NUMBER(3),
 FABRICTYPEID   VARCHAR2(20),
 QUANTITY      NUMBER(12,2) NOT NULL,
 SQUANTITY     NUMBER(12,2),
 PUNITOFMEASID    VARCHAR2(20) NOT NULL,
 SUNITOFMEASID   VARCHAR2(20),
 BATCHNO   VARCHAR2(50),
 SHADE    VARCHAR2(100),
 STYLENO     VARCHAR2(100),
 FABRICDIA    VARCHAR2(150),
 FABRICGSM    NUMBER(12,2),
 REMARKS   VARCHAR2(200),
 ORDERNO    NUMBER(15),
 CURRENTSTOCK   NUMBER(12,2),
 REQUISITIONNO   VARCHAR2(50),
 SUBCONID     NUMBER(6),
 ITEMCHALLAN   NUMBER(20),
 BITEMID     NUMBER(15),
 LINENO   VARCHAR2(50),
 PRODHOUR   VARCHAR2(20),
 SIZEID      VARCHAR2(20),
 PIECESTATUS    NUMBER(3),
 BUNDLENO     VARCHAR2(50),
 COUNTRYID   VARCHAR2(20),
 CUTTINGID  VARCHAR2(50)
);


PROMPT  table 89 :: T_GFABRICREQTYPE
create table T_GFABRICREQTYPE
(
	GFABRICREQTYPEID   NUMBER(3) NOT NULL,
	GFABRICREQTYPE   VARCHAR2(100) NOT NULL
);


PROMPT  table 90 :: T_GFORMCATEGORY
create table T_GFORMCATEGORY
(
	Catid Number(3) primary key,
	Description Varchar2(50)
);

PROMPT  table 91 :: T_GMCLIST
create table T_GMCLIST
(
	MCLISTID   NUMBER(6) NOT NULL,
	MCLISTNAME   VARCHAR2(50) NOT NULL
);


PROMPT  table 92 :: T_GMCPARTSINFO
create table T_GMCPARTSINFO
(
 PARTID     NUMBER(15) NOT NULL,
 PARTNAME    VARCHAR2(50) NOT NULL,
 DESCRIPTION     VARCHAR2(100),
 FOREIGNPART       VARCHAR2(30) NOT NULL,
 MACHINETYPE    VARCHAR2(50) NOT NULL,
 UNITOFMEASID    VARCHAR2(20) NOT NULL,
 MACHINENO     NUMBER(5),
 BINNO       VARCHAR2(200) NOT NULL,
 REORDERQTY    NUMBER(5),
 SUPPLIERADDRESS    VARCHAR2(200),
 ORDERLEADTIME   NUMBER(5),
 REMARKS    VARCHAR2(300),
 PROJCODE     NUMBER(2),
 CCATACODE    NUMBER(2),
 WAVGPRICE   NUMBER(12,4)
);


PROMPT  table 93 :: T_GMCPARTSPRICE
create table T_GMCPARTSPRICE
(
 PARTID    NUMBER(15) NOT NULL,
 SUPPLIERNAME    VARCHAR2(30),
 QTY        NUMBER(10) NOT NULL,
 UNITPRICE     NUMBER(10,2) NOT NULL,
 PURCHASEDATE    DATE NOT NULL,
 PID     NUMBER(15) NOT NULL,
 PPRICE   NUMBER(12,4),
 PQTY   NUMBER(12,4),
 NPRICE   NUMBER(12,4),
 NQTY    NUMBER(12,4),
 REFPID  NUMBER(20)
);


PROMPT  table 94 :: T_GMCPARTSSTATUS
CREATE TABLE T_GMCPARTSSTATUS 
(
	PARTSSTATUSID NUMBER(3) not null, 
	PARTSSTATUS VARCHAR2(150) 
	constraint nn_T_GMCPSTATUS_PARTSSTATUS not null
);

PROMPT  table 95 :: T_GMCPURCHASEREQ
CREATE TABLE T_GMCPURCHASEREQ 
(
 REQID    NUMBER(20) NOT NULL,
 REQNO     VARCHAR2(50) NOT NULL, 
 REQDATE    DATE NOT NULL,
 REQBY     NUMBER(3),
 DEPTID    NUMBER(15),
 REQUIRMENTDATE   DATE,
 REMARKS    VARCHAR2(200)
);


PROMPT  table 96 :: T_GMCPURCHASEREQITEMS
CREATE TABLE T_GMCPURCHASEREQITEMS 
(
 PID     NUMBER(20) NOT NULL,
 REQTYPEID    NUMBER(3) NOT NULL,
 REQID    NUMBER(20) NOT NULL,
 SLNO     NUMBER(3) NOT NULL,
 PARTID      NUMBER(15) NOT NULL,
 UNITPRICE    NUMBER(12,2) NOT NULL,
 QTY        NUMBER(12,2) NOT NULL,
 UNITOFMEASID     VARCHAR2(20) NOT NULL,
 ISSUEFOR      NUMBER(6),
 DEPTID      NUMBER(2),
 REMARKS    VARCHAR2(300)
 );
 
 
 
PROMPT  table 97 :: T_GMCSTOCK
CREATE TABLE T_GMCSTOCK 
(
STOCKID   NUMBER(15) NOT NULL,
STOCKDATE   DATE NOT NULL,
CHALLANNO   VARCHAR2(20),
CHALLANDATE    DATE,
PURCHASEORDERNO   VARCHAR2(20),
PURCHASEORDERDATE  DATE,
TEXMCSTOCKTYPEID      NUMBER(15) NOT NULL,
SUPPLIERNAME       VARCHAR2(100),
SUPPLIERADDRESS  VARCHAR2(200),
DELIVERYNOTE        VARCHAR2(20),
CURRENCYID    VARCHAR2(20),
CONRATE     NUMBER(12,4),
SCOMPLETE    NUMBER(1),
SUPPLIERID NUMBER(15)
);

PROMPT  table 98 :: T_GMCSTOCKITEMS
CREATE TABLE T_GMCSTOCKITEMS 
(
STOCKID  NUMBER(15) NOT NULL,
STOCKITEMSL       NUMBER(3) NOT NULL,
PARTID      NUMBER(15) NOT NULL,
UNITPRICE     NUMBER(12,4) NOT NULL,
REMARKS       VARCHAR2(300),
PARTSSTATUSFROMID   NUMBER(3),
QTY      NUMBER(12,2) NOT NULL,
PID       NUMBER(20) NOT NULL,
PARTSSTATUSTOID      NUMBER(3),
ISSUEFOR       NUMBER(6),
TEXMCSTOCKTYPEID     NUMBER(15),
CURRENTSTOCK      NUMBER(12,2),
REQNO       VARCHAR2(20),
DEPTID        NUMBER(2),
UNITOFMEASID      VARCHAR2(20),
REQQTY       NUMBER(12,2)
);


PROMPT  table 99 :: T_GMCSTOCKITEMSREQ
CREATE TABLE T_GMCSTOCKITEMSREQ 
(
STOCKID    NUMBER(15) NOT NULL,
STOCKITEMSL   NUMBER(3) NOT NULL,
PARTID        NUMBER(15) NOT NULL,
UNITPRICE    NUMBER(12,2) NOT NULL,
REMARKS    VARCHAR2(300),
PARTSSTATUSFROMID   NUMBER(3),
QTY      NUMBER(12,2) NOT NULL,
PID      NUMBER(20) NOT NULL,
PARTSSTATUSTOID    NUMBER(3),
ISSUEFOR    NUMBER(6),
TEXMCSTOCKTYPEID  NUMBER(15),
CURRENTSTOCK  NUMBER(12,2),
DEPTID      NUMBER(2),
UNITOFMEASID     VARCHAR2(20)
);


PROMPT  table 100 :: T_GMCSTOCKREQ
CREATE TABLE T_GMCSTOCKREQ 
(
 STOCKID   NUMBER(15) NOT NULL,
 STOCKDATE   DATE NOT NULL,
 CHALLANNO  VARCHAR2(20),
 CHALLANDATE     DATE,
 PURCHASEORDERNO    VARCHAR2(20),
 PURCHASEORDERDATE   DATE,
 TEXMCSTOCKTYPEID    NUMBER(15) NOT NULL,
 SUPPLIERNAME    VARCHAR2(100),
 SUPPLIERADDRESS   VARCHAR2(200),
 DELIVERYNOTE    VARCHAR2(20),
 EXECUTED    NUMBER(1) NOT NULL
);

PROMPT  table 101 :: T_GMCSTOCKSTATUS
CREATE TABLE T_GMCSTOCKSTATUS 
(
  	TexMCSTOCKTYPEID   NUMBER(15) CONSTRAINT NN_GMCSTSTATUS_MCSTTYPEID NOT NULL,
  	PARTSSTATUSFROMID  NUMBER(3) CONSTRAINT NN_GMCSTSTATUS_PARTSSTATU NOT NULL,
  	PARTSSTATUSTOID    NUMBER(3) CONSTRAINT NN_GMCSTSTATUS_PARTSSTATO NOT NULL,
  	MSN                NUMBER(2)                  DEFAULT 0,
  	MSO                NUMBER(2)                  DEFAULT 0,
  	MSB                NUMBER(2)                  DEFAULT 0,
  	MSR                NUMBER(2)                  DEFAULT 0,
  	FSN                NUMBER(2)                  DEFAULT 0,
  	FSO                NUMBER(2)                  DEFAULT 0,
  	PID                NUMBER(20) CONSTRAINT NN_GMCSTOCKSTATUS_PID NOT NULL,
  	SSN                NUMBER(2)
);


PROMPT  table 102 :: T_GMCSTOCKTYPE
CREATE TABLE T_GMCSTOCKTYPE 
(
	TexMCSTOCKTYPEID NUMBER(15)
	constraint nn_T_GMCST_GmcStoTyid not Null, 
	TexMCSTOCKTYPE VARCHAR2(150)
	constraint nn_T_GMCST_GmcStockType not null 
);


PROMPT  table 103 :: T_GMCSTOCKTYPEREQ
CREATE TABLE T_GMCSTOCKTYPEREQ 
(
	TEXMCSTOCKTYPEID  NUMBER(15) NOT NULL,
	TEXMCSTOCKTYPE    VARCHAR2(150) NOT NULL
);


PROMPT TABLE  104 :: T_GOrderItems

CREATE TABLE T_GORDERITEMS
(
	ORDERLINEITEM  	VARCHAR2(20),
	WOITEMSL       	NUMBER(3) NOT NULL,
	GORDERNO        NUMBER(15) CONSTRAINT NN_T_GWorkOrder_GORDERNO NOT NULL,
	STYLE		VARCHAR2(50) CONSTRAINT NN_T_GORDERITEMS_STYLE NOT NULL,
	COUNTRYID	VARCHAR2(6) CONSTRAINT NN_T_Country_CountryID NOT NULL,
	SHADE          	VARCHAR2(100) CONSTRAINT NN_T_GORDERITEMS_SHADE NOT NULL,
	Price 		NUMBER(12,4),
	QUANTITY       	NUMBER(12,2) CONSTRAINT NN_T_GORDERITEMS_QUANTITY NOT NULL,
	UNITOFMEASID   	VARCHAR2(20) CONSTRAINT NN_T_GORDERITEMS_UNITOFMEASID NOT NULL,
	DeliveryDate	date,
	REMARKS        	VARCHAR2(200)
);


PROMPT  TABLE  105 ::  T_GORDERSIZE
CREATE TABLE T_GORDERSIZE
(
	GSIZEID VARCHAR2(50) NOT NULL,
	ORDERLINEITEM VARCHAR2(20) NOT NULL,	
	SIZEID VARCHAR2(10) NOT NULL,
	QUANTITY NUMBER(15,2) NOT NULL
);


PROMPT  TABLE  106 ::  T_GORDERTYPE
CREATE TABLE T_GORDERTYPE
(
	 ORDERTYPE    VARCHAR2(10) NOT NULL,
	DESCRIPTION   VARCHAR2(50)
);

PROMPT  TABLE  107 ::  T_GSAMPLEGATEPASS
CREATE TABLE T_GSAMPLEGATEPASS
(
GPID     NUMBER(20) NOT NULL,
GPASSNO    NUMBER(20),
GPASSDATE    DATE,
CLIENTNAME    VARCHAR2(100),
CONTACTPERSON  VARCHAR2(200),
DELIVERYPLACE   VARCHAR2(500),
PREPAREDBY   VARCHAR2(20),
CTELEPHONE    VARCHAR2(100),
ORDERNO    VARCHAR2(100),
EMPLOYEEID VARCHAR2(20)
);


PROMPT  TABLE  108 ::  T_GSAMPLEGATEPASSITEMS
CREATE TABLE T_GSAMPLEGATEPASSITEMS
(
ITEMID    NUMBER(20) NOT NULL,
SERIALNO    NUMBER(3),
SAMPLEID    NUMBER(3),
ITEMSDESC   VARCHAR2(500),
QUANTITY     NUMBER(15,2),
UNITOFMEASID   VARCHAR2(20),
GPID     NUMBER(20),
RETURNABLE   NUMBER(15,2),
NONRETURNABLE    NUMBER(15,2),
STYLE     VARCHAR2(100),
RETURNEDQTY    NUMBER(12,2),
CLIENTID VARCHAR2(20),
GORDERNO NUMBER(15)
);


PROMPT  TABLE  109 ::  T_GSAMPLETYPE
CREATE TABLE T_GSAMPLETYPE
(
 SAMPLEID   NUMBER(3) NOT NULL,
 SAMPLETYPE     VARCHAR2(200) NOT NULL
);


PROMPT  TABLE  110 ::  T_GSTOCK
CREATE TABLE T_GSTOCK
(
 STOCKID      NUMBER(20) NOT NULL,
CHALLANNO      VARCHAR2(150),
CHALLANDATE      DATE,
STOCKTRANSNO      VARCHAR2(50) NOT NULL,
STOCKTRANSDATE     DATE NOT NULL,
SUBCONID       NUMBER(6),
CLIENTID    VARCHAR2(20),
PONO      VARCHAR2(50),
GATEPASSNO     VARCHAR2(50),
CATID      NUMBER(3),
REMARKS    VARCHAR2(300),
FWEIGHT    NUMBER(12,2),
CUTWEIGHT     NUMBER(12,2),
EFFICIENCY     NUMBER(6,2),
CUTPIECEREJECT     NUMBER(6),
JHUTE      NUMBER(15,2),
COMPLETE    NUMBER(1),
PRODHOUR    NUMBER(3),
ORDERNO    NUMBER(15),
CTNTYPE VARCHAR2(10),
CTNQTY  NUMBER(10)
);


PROMPT  TABLE  111 ::  T_GSTOCKITEMS
CREATE TABLE T_GSTOCKITEMS
(
 PID     NUMBER(20) NOT NULL,
GTRANSTYPEID     NUMBER(3) NOT NULL,
STOCKID      NUMBER(20) NOT NULL,
GSTOCKITEMSL      NUMBER(3),
FABRICTYPEID  VARCHAR2(20),
QUANTITY      NUMBER(12,2) NOT NULL,
REQQUANTITY     NUMBER(12,2),
SQUANTITY     NUMBER(12,2),
PUNITOFMEASID     VARCHAR2(20) NOT NULL,
SUNITOFMEASID     VARCHAR2(20),
BATCHNO      VARCHAR2(50),
SHADE        VARCHAR2(100),
STYLENO     VARCHAR2(100),
FABRICDIA      VARCHAR2(150),
FABRICGSM     NUMBER(12,2),
REMARKS     VARCHAR2(300),
ORDERNO     NUMBER(15),
CURRENTSTOCK    NUMBER(12,2),
REQUISITIONNO    VARCHAR2(50),
SUBCONID    NUMBER(6),
ITEMCHALLAN   NUMBER(20),
LINENO   VARCHAR2(50),
PRODHOUR    NUMBER(3),
SIZEID     VARCHAR2(20),
CARTONNO     VARCHAR2(50),
COUNTRYID     VARCHAR2(20),
BUNDLENO    VARCHAR2(50),
ORDERLINEITEM   VARCHAR2(20),
FABWEIGHT    NUMBER(12,2),
SPOTREF     NUMBER(3),
REJECT     NUMBER(6),
PIECESTATUS     NUMBER(1),
CUTTINGID    VARCHAR2(50),
DISPLAYNO    VARCHAR2(50),
GCPartsID Number(20)
);


PROMPT  TABLE  112 ::  T_GTRANSACTIONTYPE
CREATE TABLE T_GTRANSACTIONTYPE
(
GTRANSACTIONTYPEID    NUMBER(3) NOT NULL,
GTRANSTYPE     VARCHAR2(100) NOT NULL,
GMS     NUMBER(3),
GFCF     NUMBER(3),
CGS        NUMBER(3),
CGSC       NUMBER(3),
CGSL    NUMBER(3),
SGS     NUMBER(3),
GFF       NUMBER(3),
GIF     NUMBER(3),
FGS       NUMBER(3),
GRS     NUMBER(3),
GWF      NUMBER(3),
CTN      NUMBER(3),
FGFD       NUMBER(3),
GWSC      NUMBER(3),
POLY   NUMBER(3),
CGPSC NUMBER(3) DEFAULT 0
);

PROMPT  TABLE  113 ::  T_GWORKORDER
CREATE TABLE T_GWORKORDER
(
	GORDERNO        NUMBER(15) NOT NULL,
GORDERDATE       DATE,
CLIENTID        VARCHAR2(20) NOT NULL,
SALESTERMID      VARCHAR2(20) NOT NULL,
CURRENCYID      VARCHAR2(20) NOT NULL,
CONRATE      NUMBER(12,4) NOT NULL,
SALESPERSONID    VARCHAR2(20) NOT NULL,
WCANCELLED      NUMBER(1) NOT NULL,
WREVISED      NUMBER(1) NOT NULL,
ORDERSTATUSID     VARCHAR2(20) NOT NULL,
CONTACTPERSON    VARCHAR2(100),
CLIENTSREF        VARCHAR2(400) NOT NULL,
DELIVERYPLACE   VARCHAR2(200),
DELIVERYSTARTDATE   DATE,
DELIVERYENDDATE       DATE,
DAILYPRODUCTIONTARGET     NUMBER(12,2),
TERMOFDELIVERY      VARCHAR2(200),
TERMOFPAYMENT     VARCHAR2(50),
SEASON      VARCHAR2(50),
COSTINGREFNO     VARCHAR2(50) NOT NULL,
QUOTEDPRICE    NUMBER(12,4),
ORDERREMARKS    VARCHAR2(500),
GDORDERNO   NUMBER(15),
ORDERTYPEID  VARCHAR2(5)
);


PROMPT  TABLE  114 ::  T_IMPLCSTATUS
CREATE TABLE T_IMPLCSTATUS
(
	IMPLCSTATUSID    NUMBER(3) NOT NULL,
	IMPLCSTATUS   VARCHAR2(25) NOT NULL
);


PROMPT  TABLE  115 ::  T_IMPLCTYPE
CREATE TABLE T_IMPLCTYPE
(
	IMPLCTYPEID    NUMBER(3) NOT NULL,
	IMPLCTYPE   VARCHAR2(15)
);


PROMPT  TABLE  116 ::  T_KDFCOST
CREATE TABLE T_KDFCOST
(
BUDGETID   NUMBER(15),
PID    NUMBER(15) NOT NULL,
STAGEID    NUMBER(6),
PARAMID   NUMBER(6),
QUANTITY  NUMBER(12,2),
UNITPRICE   NUMBER(12,4),
PPID    NUMBER(15),
TOTALCOST   NUMBER(12,3),
UNIT   VARCHAR2(20)
);


PROMPT create table 117 :: T_KMCDEPARTMENT
CREATE TABLE T_KMCDEPARTMENT 
(
	KMCDEPARTMENTID NUMBER(3) not null, 
	KMCDEPARTMENT VARCHAR2(100) 
	constraint nn_T_KMCDEPARTMENT_MCDEPTNAME not null
);

PROMPT create table 118 :: T_KMCPARTSHISTORY
CREATE TABLE T_KMCPARTSHISTORY 
(
	PARTID NUMBER(15), 
	PURCHASEDATE DATE, 
	UNITPRICE NUMBER(12, 2), 
	SUPPLIERNAME VARCHAR2(150) not null, 
	QTY NUMBER(12, 2),
	PID NUMBER(15) not null,
	PPRICE         NUMBER(12,4),
	PQTY           NUMBER(12,4),
	NPRICE         NUMBER(12,4),
	NQTY           NUMBER(12,4),
	REFPID         NUMBER(20)
);


PROMPT create table 119 :: T_KMCPARTSINFO
CREATE TABLE T_KMCPARTSINFO
(
	PARTID NUMBER(15), 
	PARTNAME VARCHAR2(100) 
	constraint nn_T_KMCPARTSINFO_PARTNAME not null, 
	DESCRIPTION VARCHAR2(100), 
	FOREIGNPART VARCHAR2(50),  
	UNITOFMEASID VARCHAR2(20) 
	constraint nn_T_KMCPARTSINFO_UNITOFMEASID not null, 
	REORDERQTY NUMBER(5), 
	ORDERLEADTIME NUMBER(5), 
	SPARETYPEID NUMBER(15) 
	constraint nn_T_KMCPARTSINFO_SPARETYPEID not null,
	REMARKS VARCHAR2(300), 
	LOCATIONID NUMBER(3) 
	constraint nn_T_KMCPARTSINFO_LOCATIONID not null, 
	MCPARTSTYPEID NUMBER(3),
	MCTYPEID NUMBER(3),
	KMCDEPARTMENTID NUMBER(3),
	WAVGPRICE NUMBER(12,4)
);


PROMPT  table 120 :: T_KMCPARTSSTATUS 
  
CREATE TABLE T_KMCPARTSSTATUS 
(
	PARTSSTATUSID NUMBER(3) not null, 
	PARTSSTATUS VARCHAR2(150) 
	constraint nn_T_KMCPSTATUS_PARTSSTATUS not null
);


PROMPT  table 121 :: T_KMCPARTSTRAN 

CREATE TABLE T_KMCPARTSTRAN
(
  STOCKID            NUMBER(15),
  STOCKDATE          DATE,
  CHALLANNO          VARCHAR2(20 ),
  CHALLANDATE        DATE,
  PURCHASEORDERNO    VARCHAR2(20 ),
  PURCHASEORDERDATE  DATE,
  SUPPLIERINVOICENO    VARCHAR2(20),
  SUPPLIERINVOICEDATE      DATE,
  KMCSTOCKTYPEID     NUMBER(15) CONSTRAINT NN_T_KMCPARTSTRANS_KMCSTYPEID NOT NULL,
  SUBCONID           NUMBER(6),
  SUPPLIERID         NUMBER(15),
  CURRENCYID VARCHAR2(20),
  CONRATE  NUMBER(12,4),
  SCOMPLETE NUMBER(1)
);

PROMPT table 122 :: T_KMCPARTSTRANRequisition
CREATE TABLE T_KMCPARTSTRANRequisition
(
  STOCKID            NUMBER(15),
  STOCKDATE          DATE,
  CHALLANNO          VARCHAR2(20 ),
  CHALLANDATE        DATE,
  PURCHASEORDERNO    VARCHAR2(20 ),
  PURCHASEORDERDATE  DATE,
  KMCSTOCKTYPEID     NUMBER(15) CONSTRAINT NN_T_KMCPARTSTRANSR_KMCSTYPEID NOT NULL,
  SUBCONID           NUMBER(6),
  SUPPLIERID         NUMBER(15),
  Executed	NUMBER(1) default 0
  constraint nn_AuxStockReqR_Executed not null
);

PROMPT  table 123 :: T_KMCPARTSTRANSDETAILS 
CREATE TABLE T_KMCPARTSTRANSDETAILS
(
  STOCKID            NUMBER(15) CONSTRAINT NN_KMCPTDETAILS_STOCKID NOT NULL,
  STOCKITEMSL        NUMBER(3) CONSTRAINT NN_KMCPTDETAILS_STOCKITEMSL NOT NULL,
  PARTID             NUMBER(15) CONSTRAINT NN_KMCPTDETAILS_PARTID NOT NULL,
  UNITPRICE          NUMBER(12,2) CONSTRAINT NN_KMCPTDETAILS_UNITPRICE NOT NULL,
  REMARKS            VARCHAR2(300 ),
  PARTSSTATUSFROMID  NUMBER(3),
  QTY                NUMBER(12,2),
  PID                NUMBER(20),
  PARTSSTATUSTOID    NUMBER(3),
  MACHINEID          NUMBER(6),
  KMCSTOCKTYPEID     NUMBER(15),
  KMCTYPEID          NUMBER(3),
  CURRENTSTOCK       NUMBER(12,2)
);

PROMPT table 124 :: T_KMCPARTSTRANSDETAILSReq
CREATE TABLE T_KMCPARTSTRANSDETAILSReq
(
  STOCKID            NUMBER(15) CONSTRAINT NN_KMCPTDETAILSR_STOCKID NOT NULL,
  STOCKITEMSL        NUMBER(3) CONSTRAINT NN_KMCPTDETAILSR_STOCKITEMSL NOT NULL,
  PARTID             NUMBER(15) CONSTRAINT NN_KMCPTDETAILSR_PARTID NOT NULL,
  UNITPRICE          NUMBER(12,2) CONSTRAINT NN_KMCPTDETAILSR_UNITPRICE NOT NULL,
  REMARKS            VARCHAR2(300 ),
  PARTSSTATUSFROMID  NUMBER(3),
  QTY                NUMBER(12,2),
  PID                NUMBER(20),
  PARTSSTATUSTOID    NUMBER(3),
  MACHINEID          NUMBER(6),
  KMCSTOCKTYPEID     NUMBER(15),
  KMCTYPEID          NUMBER(3),
  CURRENTSTOCK       NUMBER(12,2)
);

PROMPT table 125 :: T_KMCSTOCKSTATUS

CREATE TABLE T_KMCSTOCKSTATUS 
(
	KMCSTOCKTYPEID NUMBER(15)
	constraint nn_T_KMCSTOCKstatus_kmcStkTyId not null, 
	PARTSSTATUSFROMID NUMBER(3) not null, 
	PARTSSTATUSTOID  NUMBER(3) NOT NULL,
	MSN  NUMBER(2),
	MSO  NUMBER(2),
	MSB  NUMBER(2),
	MSR  NUMBER(2),
	FSN  NUMBER(2),
	FSO  NUMBER(2),
	PID  NUMBER(20),
	SSN  NUMBER(2)
);

PROMPT  table 126 :: T_KMCSTOCKTYPE
CREATE TABLE T_KMCSTOCKTYPE
(
  KMCSTOCKTYPEID  NUMBER(15)                    
  constraint nn_kmcstockType_KmcSTypeId NOT NULL,
  KMCSTOCKTYPE    VARCHAR2(150)
);

PROMPT  table 127 :: T_KMCSTOCKTYPERequisition
CREATE TABLE T_KMCSTOCKTYPERequisition
(
	KMCSTOCKTYPEID NUMBER(15)
	constraint nn_T_KMCSTOCKTR_kmcStoTyid not Null, 
	KMCSTOCKTYPE VARCHAR2(150)
	constraint nn_T_KMCSTOCKTR_kmcStockType not null 
);

 PROMPT  table 128 :: T_KMCTYPE 

CREATE TABLE T_KMCTYPE
(
  MCTYPEID    NUMBER(3)      
  CONSTRAINT NN_KMCTYPE_MCTYPEID NOT NULL,
  MCTYPENAME  VARCHAR2(100) 
  CONSTRAINT NN_KMCTYPE_MCTYPENAME NOT NULL
); 

PROMPT  table 129 :: T_KNeedleImpLC
create table T_KNeedleImpLC
(
	LCNo number(10)	constraint nn_T_KNeedleImpLC_LCNo not null,
	BankLCNo varchar2(200)	constraint nn_T_KNImpLC_BankLCNo not null constraint u_T_KNImpLC_BankLCNo unique,
	OpeningDate date constraint nn_T_KNeedleImpLC_OpeningDate not null,
	CurrencyId varchar2(20) constraint nn_T_KNeedleImpLC_CurrencyId not null,
	ConRate number(12,4) constraint nn_T_KNeedleImpLC_Conrate not null,	
	ShipmentDate date,
	ImpLCStatusId number(2) default 0 constraint nn_T_KNImpLC_ImpLCSId not null,
	DocRecDate date,
	DocRelDate date,
	ShipDate date,
	GoodsRecDate date,
	BankCharge number(12,2),
	Insurance number(12,2),
	TruckFair number(12,2),
	CNFValue number(12,2),
	OtherCharge number(12,2),
	Cancelled number(1) default 0 constraint nn_T_KNeedleImpLC_Cancelled not null,
	Remarks varchar2(200),
	IMPLCTYPEID number(3) constraint nn_T_KNeedleImpLC_LcTypeId not null,
	ExpLCNo number,	
	Linked number(2) default 0,
	LCMATURITYPERIOD number(3),
	SUPPLIERID NUMBER(15)
);

PROMPT  table 130 :: T_KNeedleImpLCItems
create table T_KNeedleImpLCItems
(	
	PID number(20),
	LCNo number(10),
	GroupID number(3) constraint nn_T_KNImpLCItems_GroupID not null,	
	PARTID number(15) constraint nn_T_KNImpLCItems_PartID not null,			
	Qty number(12,2) constraint nn_T_KNImpLCItems_Qty not null,
	UnitPrice number(12,2) constraint nn_T_KNImpLCItems_UnitPrice not null,
	ValueFC number(12,2) constraint nn_T_KNImpLCItems_ValueFC not null,
	ValueTk number(12,2) constraint nn_T_KNImpLCItems_ValueTk not null,
	ValueBank number(12,2),
	ValueInsurance number(12,2),
	ValueTruck number(12,2),
	ValueCNF number(12,2),	
	ValueOther number(12,2),
	TotCost number(12,2) constraint nn_T_KNImpLCItems_TotCost not null,	
	UnitCost number(12,2) constraint nn_T_KNImpLCItems_UnitCost not null
);


PROMPT  TABLE 131 :: T_KNITMACHINEINFO
CREATE TABLE T_KNITMACHINEINFO
(
  MACHINEID      NUMBER(6)                      
  constraint nn_KnitMInfo_MID NOT NULL,
  MCTYPEID       NUMBER(3)                      
  constraint nn_KnitMInfo_McTypeId NOT NULL,
  FABRICTYPEID   VARCHAR2(20)                   
  constraint nn_KnitMInfo_FabricTypeId NOT NULL,
  KNITMCDIA      VARCHAR2(10)                   
  constraint nn_KnitMInfo_KnitMcDia NOT NULL,
  KNITMCGAUGE    VARCHAR2(10)                   
  constraint nn_KnitMInfo_knitMcGauge NOT NULL,
  MCFEEDER       NUMBER(6)                      
  constraint nn_KnitMInfo_McFeeder NOT NULL,
  RATEDCAPACITY  NUMBER(6)                      
  constraint nn_KnitMInfo_RateDcapacity NOT NULL,
  UNITOFMEASID   VARCHAR2(20)                   
  constraint nn_KnitMInfo_UnitOfmeasid NOT NULL,
  PATTERNS       VARCHAR2(200),
  MACHINENAME    VARCHAR2(200)
);

PROMPT  TABLE 132 :: T_KNITPLAN
CREATE TABLE T_KNITPLAN
(
  PLANID            NUMBER(20)                  
  constraint nn_knitplan_planid NOT NULL,
  MACHINEID         NUMBER(6)                   
  constraint nn_knitplan_MachineId NOT NULL,
  BATCHID           NUMBER(3)                   
  constraint nn_knitplan_Batchid NOT NULL,
  SCHEDULEDATE      DATE                        
  constraint nn_knitplan_sheduleDate NOT NULL,
  SCHEDULEPLANDATE  DATE                        
  constraint nn_knitplan_scheduleplanDate NOT NULL,
  PLANQTY           NUMBER(12,2)                
  constraint nn_knitplan_planqty NOT NULL,
  PLANREMARKS       VARCHAR2(200),
  ORDERNO           NUMBER(15)                  
  constraint nn_knitplan_orderno NOT NULL,
  MERGEID           NUMBER(20),
  PLANSTATUSID      NUMBER(3)
);


PROMPT  TABLE 133 :: T_KnitMachinePlan
create table T_knitplanSubcon
(
	PLANID			NUMBER(20)
	constraint nn_T_KnitMachinePlan_PlanId not null,
	MERGEID         	NUMBER(20)
	constraint nn_T_KnitMachinePlan_MId not null,
	SCHEDULEDATE    	DATE
	constraint nn_T_KnitMachinePlan_SDate not null,
	SCHEDULEPLANDATE        DATE
	constraint nn_T_KnitMachinePlan_SPDate not null,
	SUBCONID                NUMBER(6)
	constraint nn_T_KnitMachinePlan_SubConId not null,
	PLANQTY                 NUMBER(12,2),
	PLANSTATUSID            NUMBER(3)
	constraint nn_T_KnitMachinePlan_PlanSId not null,
	PLANREMARKS             VARCHAR2(200),
	ORDERNO                 NUMBER(15)
	constraint nn_T_KnitMachinePlan_OrderNo not null
);


PROMPT  TABLE 134 :: T_KNITPRODUCTION
CREATE TABLE T_KNITPRODUCTION
(
 PRODUCTIONID       NUMBER(20) NOT NULL,
 PLANID         NUMBER(20) NOT NULL,
 STARTDATETIME       DATE NOT NULL,
 ENDDATETIME        DATE NOT NULL,
 PRODQUANTITY        NUMBER(12,2),
 PRODQUANTITYTOLL      NUMBER(6),
 PRODDIA          NUMBER(6),
 PRODREMARKS         VARCHAR2(200),
 ORDERNO             NUMBER(15) NOT NULL,
 PRODUCTIONDATE      DATE
);

PROMPT  TABLE 135:: T_KNITPRODUCTIONSUBCON
CREATE TABLE T_KNITPRODUCTIONSUBCON
(
 PRODUCTIONID       NUMBER(20) NOT NULL,
 PLANID       NUMBER(20) NOT NULL,
 PRODDATE       DATE NOT NULL,
 PRODQUANTITY       NUMBER(12,2),
 PRODQUANTITYROLL      NUMBER(6),
 PRODDIA        NUMBER(6),
 PRODREMARKS       VARCHAR2(200),
 ORDERNO         NUMBER(20) NOT NULL
);

PROMPT  table 136 :: T_KnitStock
create table T_KnitStock
(
	StockId number(20)
	constraint nn_T_knitStock_SId not null,		
	KntiTransactionTypeId number(3)
	constraint nn_T_Knitstock_knittrantypeid not null,
	ReferenceNo varchar2(150),
	ReferenceDate Date,
	StockTransNo varchar2(50)
	constraint nn_T_Knitstock_StockTranNo not null,
	StockTransDate Date
	constraint nn_T_Knitstock_StockTranDate not null,
	SupplierId number(15),
	SupplierInvoiceNo varchar2(20),
	SupplierInvoiceDate Date,
	Remarks varchar2(200),
	SubConId number(6),
	ParentSTOCKID NUMBER(20),
	CurrencyID varchar2(20),
	ConRate number(12,4),
	sCOMPLETE NUMBER(1),
	ClientID VARCHAR2(20),
	ORDERNO NUMBER(15),
	Yarnfor NUMBER(15) 
);

PROMPT  table 137 :: T_KnitStockItems

create table T_KnitStockItems
(
	PID number(20),
	StockId number(20)
	constraint nn_T_KnitstockItems_StockId not null,		
	KntiStockItemSL number(3),
	YarnCountId varchar2(20)
	constraint nn_T_KnitstockItems_YCountId not null,
	YarnTypeId varchar2(20)
	constraint nn_T_KnitstockItems_YTypeId not null,
	FabricTypeId varchar2(20),
	OrderLineItem varchar2(20),
	Quantity number(12,2)
	constraint nn_T_KnitstockItems_Qty not null,
	REQQUANTITY NUMBER(12,2),
	SQuantity number(12,2),
	PunitOfMeasId varchar2(20)
	constraint nn_T_KnitstockItems_PUOM not null,
	SunitOfMeasId varchar2(20),
	YarnBatchNo varchar2(50),
	Shade varchar2(100),
	Remarks varchar2(200),
	orderno number(15),
	supplierId number(15),
	currentstock number(12,2),
	MergeId number(20),
	DyedLotNo varchar2(50),
	IMPLCNO    VARCHAR2(200),
	RequisitionNo varchar2(50),
	subConId number(6),
	ParentSTOCKID NUMBER(20),
	ITEMCHALLAN NUMBER(20),
	SHADEGROUPID NUMBER(3),
	LYCRA  VARCHAR2(2),
	MACHINEID NUMBER(6),
	UnitPrice number(12,4),
	REMAINQTY NUMBER(12,2),
	Yarnfor NUMBER(15),
	ShiftID varchar2(1),
	KSTARTDATETIME   TIMESTAMP(6),
	KENDDATETIME  TIMESTAMP(6),
	KDURATION  VARCHAR2(25),
	KMACHINEPIDREF NUMBER(20)
);

PROMPT TABLE 138 :: T_KNITTINGMERGE
CREATE TABLE T_KNITTINGMERGE
(
  MERGEID       NUMBER(20)                      
  constraint nn_knitMerge_MergeId NOT NULL,
  FABRICTYPEID  VARCHAR2(20),
  SHADEDETAILS  VARCHAR2(500),
  QTY           NUMBER(12,2),
  ORDERNO       NUMBER(20),
  WOSLNO        NUMBER(3)
);


PROMPT  table 139 :: T_KnitTransactionType
create table T_KnitTransactionType
(
	KntiTransactionTypeId number(3),
	KnitTransactionType varchar2(100)
	constraint un_T_KnitTranType_KTranType unique
	constraint un_T_KnitTransType_KTranType not null,
	ATLGYS number(3),
	ATLGFS number(3),
	ATLGYF number(3),
	AYDLGYS number(3),
	ODSCONGYS number(3),
	KSCONGYS number(3),
	ATLDYS number(3),
	ATLGFDF number(3),
	ATLDFDS number(3),
	ATLFFS number(3),
	SCGFS number(3),
	ATLDYF NUMBER(3),
	KSCONDYS NUMBER(3),
	FSCON NUMBER(3),
	DFSCON NUMBER(3),
	REJECT NUMBER(3),
	GYLTP NUMBER(3),
	GYLFP NUMBER(3)
);

PROMPT  TABLE 140 :: T_KYARNTYPE
CREATE TABLE T_KYARNTYPE
(
  YARNTYPEID     NUMBER(3)
  constraint nn_T_KYarnType_YTypeid not null,
  YARNTYPE       VARCHAR2(80)                   
  constraint nn_KyarnType_YTypeId NOT NULL,
  YARNCODE       VARCHAR2(30)                   
  constraint nn_KyarnType_Ycode NOT NULL,
  INOPERATIONID  NUMBER(1)                      
  constraint nn_KyarnType_Inoperationid NOT NULL
);

PROMPT table 141 :: T_LCBank
create table T_LCBank
(
	BankId number(6)
	constraint nn_T_LcBank_BankId not null, 
	BankName varchar2(200) 
	constraint nn_T_LCBank_BankName not null,
	BranchName varchar2(50)
);

PROMPT table 142 :: T_LCDOCUMENT
create table T_LCDOCUMENT
(
 PID     NUMBER(15) NOT NULL,
 BANKBILLNO   VARCHAR2(100),
 BILLDATE     DATE,
 EXPAMOUNT      NUMBER(15,4),
 RECEVEDAMOUNT       NUMBER(15,4),
 REALIZEDATE      DATE,
 USENCEPERIOD     VARCHAR2(20),
 MATURITYDATE      DATE,
 EXPLCNO     NUMBER(6)
);

PROMPT create table 143 :: T_LCInfo
create table T_LCInfo
(
 LCNO     NUMBER(6) NOT NULL,
 BANKLCNO    VARCHAR2(200) NOT NULL,
 CLIENTID     VARCHAR2(20) NOT NULL,
 RECEIVEDATE     DATE,
 EXPLCTYPEID     NUMBER(3) NOT NULL,
 CURRENCYID     VARCHAR2(20) NOT NULL,
 CONRATE       NUMBER(12,4) NOT NULL,
 LCORDERQTY   NUMBER(12,2) NOT NULL,
 LCORDERAMT       NUMBER(12,2) NOT NULL,
 LCEXPIRYDATE          DATE,
 LCMATURITYPERIOD    VARCHAR2(20),
 PAYDUEDATE         DATE,
 DOCPURCHASEDAMT        NUMBER(12,2),
 BANKID          NUMBER(6),
 BANKBILLNO       VARCHAR2(20),
 PURCHASERATE      NUMBER(12,4),
 PAYEXCHANGERATE      NUMBER(12,4),
 USANCERATE      NUMBER(12,4),
 OVERDUEINTRATE     NUMBER(12,4),
 USANCEADVICE        NUMBER(12,2),
 OVERDUEADVICE      NUMBER(12,2),
 PAYADVICE     NUMBER(12,2),
 PAYADVDATE       DATE,
 REMARKS       VARCHAR2(20),
 BTBLCLIMIT NUMBER(3)
);

PROMPT table 144 :: T_LCItems
create table T_LCItems
(
	LCItemID number(6)	constraint nn_T_LCItems_LCItemID not null,
	LCNo number(6)		constraint nn_T_LCItems_LCNo not null,	
	OrderNo number(15)	constraint nn_T_LCItems_OrderNo not null,
	CLIENTSREF varchar2(400),		
	LCWoQty number(12,2) 	constraint nn_T_LCItems_LCWoQty not null,
	LCWoAmt number(12,2) 	constraint nn_T_LCItems_LCWoAmt not null
);

PROMPT table 145 :: T_LCPayment
create table T_LCPayment
(
	PID number(6) 		constraint nn_T_LCPayment_PID not null,
	LCNo number(6) 		constraint nn_T_LCPayment_LCNo not null,
	LCStatusID number(3) 	constraint nn_T_LCPayment_StatusID not null,
	LCReceiveDate date,
	ShipmentDate date,
	PartyAcceptDate date,
	SubmittedToBankDate date,
	BankAcceptanceDate date,
	DocPurchaseDate date,
	PayRealisedDate date,	
	FDBC varchar2(20),
	IFDBP varchar2(20),
	ExpBillAmt number(12,2),
	PayReceiveAmt number(12,2),
	PurchaseDate	date,
	LCAmount number(12,2),
	BTBLCAmount number(12,2),
	DFCAmount number(12,2),
	BuyerCommision	number(12,2),	
	ERQAccount number(12,2),
	PartyAccount 	number(12,2),
	PurExchRate	number(12,4),
	AmountTk	number(12,2),
	SSIAccount 	number(12,2),
	STex	number(12,2),
	CommisionTk	number(12,2),
	PostageCharge	number(12,2),
	FDRBTBAccount	number(12,2),
	OurAccount	number(12,2),
	FCC	number(12,2),
	PayLessTk	number(12,2),
	PayLessFC	number(12,2),
	Rate	number(12,2),
	Stamp 	number(12,2),
	Discount	number(12,2),
	UsancePeriod	number(3),
	DueDate	date,
	TotalInvValue	number(12,2),
	Margin	number(12,2),
	ReferedSundryAC	number(12,2),
	OrderNo number(15),
	PACKINGCOST  NUMBER(12,4),
    INVOICENO VARCHAR2(25),
    INVOICEDATE DATE,
    PAYEXRATE NUMBER(12,4),
    SPID NUMBER(15),
	REFID NUMBER(15)
);


PROMPT table 146 :: T_LcpaymentInfo
Create  table T_LcpaymentInfo
(
Pid Number(15) primary key,
paymentinvoiceno varchar2(50),
pinvoicetdate date,
Pinvoicevalue Number(15,4),
lctype Number(3),
REMARKS   VARCHAR2(500)
)

PROMPT table 147 :: T_LCStatus
create table T_LCStatus
(
	LCStatusId number(3), 
	LCStatus varchar2(25) 
	constraint nn_T_LCStatus_LCStatus not null
	constraint u_T_LCStatus_LCStatus unique
)

PROMPT table 148 :: T_Lcvoucher
Create table T_Lcvoucher
(
pid Number(15),
refno Varchar2(50),
refdate date,
ibpno varchar2(50),
ibpamount Number(15,4),
inttacno Varchar2(50),
inttamount Number(15,4),
cdac varchar2(50),
cdacamount Number(15,4),
totalamount Number(15,4),
generalacno Varchar2(50),
currentacno varchar2(50),
pono varchar2(50),
podate date,
companyid Number(3),
bankid Varchar2(6),
commac varchar2(50),
commacamount Number(15,4),
billamount Number(15,4),
purchaseamountfc Number(15,4),
purchaseamounttk Number(15,4),
purchasedate Date,
exchangerate Number(12,4),
ptacno varchar2(50),
vouchertype Number(3),
PTAMMOUNT NUMBER(15,4)
);


PROMPT  table 149 :: T_LCWoLink
create table T_LCWoLink
(
	BasicTypeId varchar2(20)
	constraint nn_T_LCWolink_BTypeId not null,
	LCNo number(6)
	constraint nn_T_LCWolink_lcno not null,
	LCItemSl number(3)
	constraint nn_T_LCWolink_LCItemSl not null,
	WBasicTypeId varchar2(3)
	constraint nn_T_LCWoLink_WBasicTypeId not null,
	LCWoQty number(10,2)
	constraint nn_T_LCWoLink_LCWoQty not null,
	LCWoAmt number(10,2)
	constraint nn_T_LCWoLink_LCWoAmt not null,
	OrderNo number(15)	
);


PROMPT TABLE 150 :: T_MCPARTSTYPE
CREATE TABLE T_MCPARTSTYPE
(
  MCPARTSTYPEID  NUMBER(3)                      
  constraint nn_MCPType_McPTypeId NOT NULL,
  MCPARTSTYPE    VARCHAR2(20)
  constraint nn_MCPType_McPType NOT NULL
);

PROMPT TABLE 151 :: T_MoneyReceipt
Create table T_MoneyReceipt
(
Pid Number(15),
receiptno Number(15),
receiptdate Date,
receiptfor Number(3),
partyid varchar2(6),
amount Number(15,4),
cash Number(1),
cheque Number(1),
payorder Number(1),
draft Number(1),
paymentno Varchar2(50),
paydate Date,
bankid Number(6),
branch varchar2(100),
Billno Varchar2(30),
purpose varchar2(200),
employeeid varchar2(20),
status varchar2(20),
posted Number(1),
postdate Date,
Unpostby Varchar2(20),
customerid number(6),
cancel number(1),
reason varchar2(200),
electric number(1),
maintenence number(1)
);

PROMPT TABLE 152 :: T_MPGroup
CREATE  TABLE T_MPGroup
(
	MPGroupID NUMBER(5),
	MPGroupName VARCHAR2(200) 	     
	      constraint u_MP_MPGroupname unique
);

PROMPT TABLE 153 :: T_OBJECT
CREATE  TABLE T_OBJECT
(
 OBJECTID   VARCHAR2(20),
 OBJECTNAME     VARCHAR2(20) NOT NULL,
 OBJECTTYPE     VARCHAR2(20) NOT NULL
);

PROMPT  TABLE 154 :: T_ORDERITEMKNITTINGMERGE
CREATE TABLE T_ORDERITEMKNITTINGMERGE
(
  PID            NUMBER(20)                     
  constraint nn_OrderItemKnitMerge_Pid NOT NULL,
  ORDERLINEITEM  VARCHAR2(20),
  MERGEID        NUMBER(20),
  ORDERNO        NUMBER(20)
);

PROMPT TABLE  155 :: T_OrderItems

CREATE TABLE T_ORDERITEMS
(
  ORDERLINEITEM  VARCHAR2(20),
  WOITEMSL       NUMBER(3),
  BASICTYPEID    VARCHAR2(20),
  ORDERNO        NUMBER(15),
  KNITMCDIAGAUGE VARCHAR2(20) CONSTRAINT NN_T_ORDERITEMS_KNITMCDIAGAUGE NOT NULL, 
  COMBINATIONID  VARCHAR2(20 ),
  FABRICTYPEID   VARCHAR2(20 ) CONSTRAINT NN_T_ORDERITEMS_FABRIC NOT NULL,
  FINISHEDGSM    NUMBER(12,2) CONSTRAINT NN_T_ORDERITEMS_FINISHEDGSM NOT NULL,
  WIDTH          NUMBER(12,2) CONSTRAINT NN_T_ORDERITEMS_WIDTH NOT NULL,
  SHRINKAGE      VARCHAR2(10 ),
  SHADE          VARCHAR2(100 ),
  RATE           NUMBER(10,2) constraint nn_orderitems_rate not null,
  FEEDERCOUNT    NUMBER(3),
  GRAYGSM        NUMBER(12,2),
  PLY            NUMBER(3),
  UNITOFMEASID   VARCHAR2(20 ) CONSTRAINT NN_T_ORDERITEMS_UNITOFMEASID NOT NULL,
  QUANTITY       NUMBER(12,2) CONSTRAINT NN_T_ORDERITEMS_QUANTITY NOT NULL,
  FINISHEDQUALITY	VARCHAR2(20),
  OTHERQUALITY	VARCHAR2(20),
  REMARKS		VARCHAR2(200),
  COLLARCUFFID	NUMBER(3),
  SHADEGROUPID	NUMBER(3),
  PLOSS		NUMBER(5,2),
  PQUANTITY	NUMBER(12,2),
  SQTY		NUMBER(12,2),
  SUNIT		VARCHAR2(20),
  BREFPID		NUMBER(15)
);


PROMPT TABLE  156 :: T_OrderStatus

CREATE  TABLE T_OrderStatus
(
	OrderStatusID	VARCHAR2(20),
	OrderStatus	VARCHAR2(25)
	constraint nn_orderstatus_orderstatus not null
  	constraint u__orderstatus_orderstatus unique
);

PROMPT TABLE  157 :: t_ordertype
create table t_ordertype
(
ordercode varchar2(10),
description varchar2(50)
);

PROMPT TABLE  158 :: T_OrderYarnReq
CREATE  TABLE T_OrderYarnReq
(
	PID		varchar2(20),
	Orderno 	Number(15),
	FABRICTYPEID    VARCHAR2(20),
	SHADEGROUPID    NUMBER(3),
	YarnCountID	varchar2(20)
	constraint nn_OrderyReq_yarncountid not null,
	YarnTypeID 	varchar2(20)
        constraint nn_OrderyReq_yarntypeid not null,
	Reqty		NUMBER(12,2),
 	PLOSS           NUMBER(5,2),
	totalqty 	NUMBER(12,2) 	
);


PROMPT TABLE  159 :: T_Party
Create table T_Party
(
Partyid 			varchar2(6) Primary Key,
Partyname 			VARCHAR2(200),
Paddress            VARCHAR2(200),
PTELEPHONE            VARCHAR2(100),
PFAX                   VARCHAR2(100),
PEMAIL                 VARCHAR2(100),
PURL                   VARCHAR2(100),
PCONTACTPERSON          VARCHAR2(100)
);


PROMPT TABLE 160 :: T_PLANSTATUS
CREATE TABLE T_PLANSTATUS
(
  PLANSTATUSID  NUMBER(3)                       
  constraint nn_PlanStatus_PStatusId NOT NULL,
  PLANSTATUS    VARCHAR2(100)
);

PROMPT TABLE 161 :: T_processRoutecard
create table T_processRoutecard
(
ROUTECARDID  NUMBER(6) NOT NULL,
ROUTECARDNO  VARCHAR2(50),
FABRICBATCHID  NUMBER(6) NOT NULL,
ROUTECARDDATE  DATE,
REMARKS  VARCHAR2(100),
MASTERROUTECARDID  NUMBER(6),
BATCHWEIGHT  NUMBER(10)
);

PROMPT  table 162 :: T_ProductionHOur
create table T_ProductionHOur
(
	hid Number(3) primary key,
	Description Varchar2(50)
);


PROMPT table 163 :: T_PROJECT 
CREATE TABLE T_PROJECT
(
	PROJCODE NUMBER(2) not null, 
	PROJNAME VARCHAR2(20) 
	constraint nn_T_PROJECT_PROJNAME not null
);

PROMPT  table 164 :: T_PurchaseReq
create table T_PurchaseReq
(
	ReqId number(20) not null,
	ReqNo varchar2(50) not null,
	ReqDate Date not null,	
	reqby Number(3),
	DeptId number(15),
	RequirmentDate Date,	
	Remarks varchar2(1000)
);


PROMPT  table 165 :: T_PurchaseReqBy
Create Table T_PurchaseReqBy
(
Pid Number(3) Primary Key,
Name Varchar2(50)
);

PROMPT table 166 :: T_PurchaseReqItems
create table T_PurchaseReqItems
(
	PID number(20) not null,
	ReqTypeID number(3) not null,	
	Reqid number(20) not null,	
	ItemId number(15) ,					
	Quantity number(12,2) ,
	PunitOfMeasId varchar2(20) ,
	SQuantity number(12,2),	
	SunitOfMeasId varchar2(20),	
	Remarks varchar2(500),		
	CurrentStock number(12,2),	
	UnitPrice number(12,4),
	GroupId number(3),
	SlNo Number(3),
 	Brandid Number(6),
	countryid Varchar2(6)
);


PROMPT  table 167 :: T_PurchasReqType
create table T_PurchasReqType
(
	ReqTypeID number(3) primary key,
	Description varchar2(200) constraint un_T_PurchasReqType_Desc unique constraint nn_T_PurchasReqType_Desc not null	
);


PROMPT  table 168 :: T_QC

create table T_QC
(
	QcId number(20),
	QcNo varchar2(100)
		constraint nn_T_Qc_QcNo NOT NULL,
	QcDate date not null,
	QcType number(20)
);


PROMPT  table 169 :: T_QcItems
create table T_QcItems
(
	PID number(20),
	QcItemSL number(3),
	PackingDate Date,
	Remarks varchar2(200),
	DBatchId number(20),	
	QcId number(20) not null,
	QcStatusId number(20)
);

PROMPT  table 170 :: T_QcStatus

create table T_QcStatus
(
	QcStatusId number(20),
	QcStatus varchar2(100)
		constraint nn_T_QcStatus_QcStatus NOT NULL
);


PROMPT  table 171 :: T_receipent
Create table T_receipent
(
rid Number(3) Primary key,
receipentname varchar2(20),
description varchar2(50)
);

PROMPT  table 172 :: T_ROUTECARDPARAMETERS
Create table T_ROUTECARDPARAMETERS
(
PID        NUMBER(6) NOT NULL,
ROUTECARDID     NUMBER(6) NOT NULL,
STAGEID    NUMBER(6) NOT NULL,
PARAMETERID        NUMBER(6) NOT NULL,
PARAMETERORDER   NUMBER(6),
PARAMETERVALUE   VARCHAR2(50)
);

PROMPT  table 173 :: T_ROUTECARDSTAGES
Create table T_ROUTECARDSTAGES
(
ROUTECARDID  NUMBER(6) NOT NULL,
STAGEID    NUMBER(6) NOT NULL,
STAGEINSTRUCTIONS   VARCHAR2(100),
STAGEORDER       NUMBER(6)
);

PROMPT TABLE  174 ::  T_SalesTerm

CREATE  TABLE T_salesterm
(
	SalesTermID 	VARCHAR2(20),
	SalesTerm	VARCHAR2(20)
	constraint nn_salesterm_salesterm not null
	constraint u_salesterm_salesterm unique
);

PROMPT TABLE  175 ::  T_SCBASICWORKORDER

CREATE  TABLE T_SCBASICWORKORDER
(
	WORKORDERNO   NUMBER(15),
	BASICTYPEID   VARCHAR2(20)
);


PROMPT TABLE  176 ::  T_SHADEGROUP
CREATE  TABLE T_SHADEGROUP
(
	SHADEGROUPID	NUMBER(3),
	SHADEGROUPName	VARCHAR2(50)
	constraint u_SHADEGROUP_SHADEGROUPName unique
);

Prompt  Table 177 :: T_Shipmentinfo
Create Table T_Shipmentinfo
(
PID NUMBER(15) NOT NULL,
EXPNO  VARCHAR2(50),
EXPDATE DATE,
GOODSDESC VARCHAR2(500),
QUANTITYPCS NUMBER(15),
BLNO VARCHAR2(50),
INVOICENO VARCHAR2(50),
INVOICEDATE DATE,
SHIPPINBILLNO VARCHAR2(50),
SHIPPINGBILLDATE DATE,
SHIPPINGBILLQTY NUMBER(15),
GSPNO VARCHAR2(50),
GSPDATE DATE,
GSPQTY NUMBER(15),
LCNO NUMBER(15),
BLDATE DATE,
INVOICEVALUE NUMBER(15,4),
ORDERNO VARCHAR2(50),
DOCSUBDATE DATE,
CURRENCYID VARCHAR2(20)
);


PROMPT  TABLE  178 :: T_SIZE
CREATE TABLE T_SIZE
(
	SIZEID VARCHAR2(10) NOT NULL,
	SIZENAME VARCHAR2(20) NOT NULL
);
	
PROMPT  table 179 :: T_SPARETYPE 
  
CREATE TABLE T_SPARETYPE 
(
	SPARETYPEID NUMBER(3) not null, 
	SPARETYPENAME VARCHAR2(100) 
	constraint nn_SPARETYPE_SPARETYPENAME not null
);	

PROMPT  table 180 :: T_SQLLOG
Create table T_SQLLOG
(    
        Logsequenceid number(38),
        Employeeid varchar2(20) not null,
        Terminal varchar2(100) ,
        Logdate date not null, 
        Sql varchar2(3000),
		Copied number(1) not null
);


PROMPT  table 181 :: T_SQLLOGUPDATE
Create table T_SQLLOGUPDATE
(    
        LOGSEQUENCEID number(38),
        EMPLOYEEID varchar2(20) not null,
        Terminal varchar2(100) ,
        Logdate date not null, 
        Sql varchar2(3000),
		UPDATED number(1) not null
);

Prompt  Table 182 :: T_Stationery
Create table T_Stationery
(
	StationeryId number(15),
	Item varchar2(100)
	constraint nn_T_Stationery_Item not null,
	UnitOfMeasId VARCHAR2(20)
	constraint nn_T_Stationery_UnitOfMeasId not null,	
	GroupId number(3),
	WAVGPRICE NUMBER(12,2) DEFAULT 0	
);

Prompt  Table 183 :: T_StationeryGroup
Create table T_StationeryGroup
(
	GroupId number(3),
	GroupName varchar2(100)
	constraint nn_T_StGroup_GName not null
	constraint un_T_StGroup_GName Unique
);

PROMPT table 184 :: T_StationeryStock
create table T_StationeryStock
(
	StockId number(20) not null,
	StockTransNo varchar2(50) not null,
	StockTransDate Date not null,	
	SupplierId number(15),
	SupplierInvoiceNo varchar2(20),
	SupplierInvoiceDate Date,
	Remarks varchar2(200),
	stocktype Number(3),
	CURRENCYID VARCHAR2(20),
	CONRATE NUMBER(12,4)
);

PROMPT  table 185 :: T_StationeryStockItems
create table T_StationeryStockItems
(
	PID number(20) not null,
	TransTypeID number(3) not null,	
	StockID number(20) not null,	
	StationeryId number(15) not null,					
	Quantity number(12,2) not null,
	PunitOfMeasId varchar2(20) not null,
	SQuantity number(12,2),	
	SunitOfMeasId varchar2(20),	
	Remarks varchar2(200),		
	CurrentStock number(12,2),	
	UnitPrice number(12,4),
	GroupId number(3),
	BRANDID Number(6),
	COUNTRYID varchar2(6),
	DEPTID Number(15),
	REQNO varchar2(50),
	Reqby Number(3)
);

PROMPT  table 185 :: T_StationeryPrice
create table T_StationeryPrice
(
	PID NUMBER(12) not null,
	StationeryID number(15) not null,					
	PurchaseDate date,
	SupplierID number(15),
	UnitPrice number(12,2) not null,	
	Qty number(12,2),
	PPRICE NUMBER(12,4),
	PQTY NUMBER(12,4),
	NPRICE NUMBER(12,4),
	NQTY NUMBER(12,4),
	REFPID NUMBER(20),
	CURRENCYID  VARCHAR2(20),
	CONRATE  NUMBER(12,4)
);

PROMPT  table 186 :: T_StationeryTransactionType
create table T_StationeryTransactionType
(
	TransTypeID number(3) primary key,
	StationeryTypeName varchar2(100) constraint un_T_StaTransactionType_Name unique constraint nn_T_StaTransactionType_Name not null,	
	MainStore NUMBER(3),
	SubStore  NUMBER(3) 	
);

PROMPT  table 187 :: T_STORELOCATION 

CREATE TABLE T_STORELOCATION 
(
	LOCATIONID NUMBER(3) not null, 
	LOCATION VARCHAR2(100) 
	constraint nn_STORELOCATION_LOCATION not null
);

PROMPT TABLE 188 :: T_SUBCONTRACTORS
CREATE TABLE T_SUBCONTRACTORS
(
  SUBCONID           NUMBER(6) constraint nn_SubCon_SubConId NOT NULL,
  SUBCONNAME         VARCHAR2(200) constraint nn_SubCon_SubConName NOT NULL,
  SUBCONSTATUS   VARCHAR2(20) constraint nn_SubCon_SubConStatus NOT NULL,
  SUBADDRESS         VARCHAR2(200) constraint nn_SubCon_SubConAdd NOT NULL,
  SUBFACTORYADDRESS  VARCHAR2(200),
  SUBTELEPHONE       VARCHAR2(100),
  SUBFAX             VARCHAR2(100),
  SUBEMAIL           VARCHAR2(100),
  SUBURL             VARCHAR2(100),
  SUBCONTACTPERSON   VARCHAR2(100) constraint nn_SubCon_SubConPerSon NOT NULL,
  SUBACCOUNTCODE     VARCHAR2(30),
  SUBREMARKS         VARCHAR2(200),
  SUBCONGROUPID      NUMBER(6)
);

PROMPT table 189 :: T_SUPPLIER

CREATE TABLE T_SUPPLIER
(
	SUPPLIERID NUMBER(15), 	
	SUPPLIERNAME VARCHAR2(200) 
	constraint nn_T_Supplier_SName NOT NULL, 
	SADDRESS VARCHAR2(200) 
	constraint nn_T_Supplier_SAdd NOT NULL, 
	STELEPHONE VARCHAR2(100), 	
	SFAX VARCHAR2(100), 
	SEMAIL VARCHAR2(100), 
	SURL VARCHAR2(100), 
	SCONTACTPERSON VARCHAR2(100), 
	SREMARKS VARCHAR2(200),
	sgroupid number(10),
	SUPPLIERFOR   VARCHAR2(10)
);  



PROMPT table 190 :: T_SYSTEMCONFIG
CREATE TABLE T_SYSTEMCONFIG
(
	SYSTEMDATA   VARCHAR2(100),
	SYSTEMDATANO  NUMBER(3)
);

PROMPT  table 191 :: T_TexMACHINEWAVGPRICE
CREATE TABLE T_TexMACHINEWAVGPRICE
(
	PARTID NUMBER(15) not null, 
	MACAVGPRICE NUMBER(10)
);

PROMPT table 192 :: T_TexMcList
create table T_TexMcList
(
	McListId number(6),
	McListName varchar2(50)
		constraint nn_T_TexMcList_McListName not null
		constraint u_T_TexMcList_McListName unique	
);

PROMPT  table 193 :: T_TexMcPartsInfo
create table T_TexMcPartsInfo
(
	PARTID NUMBER(15), 
	PARTNAME VARCHAR2(50) 
	constraint nn_TexMcPartInfo_PARTNAME not null, 
	DESCRIPTION VARCHAR2(100), 
	FOREIGNPART VARCHAR2(30)
		constraint nn_TexMcPartInfo_ForeignPart not null, 
	MachineType varchar2(50)
		constraint nn_TexMcPartInfo_MachineType not null, 
	UNITOFMEASID VARCHAR2(20) 
		constraint nn_TexMcPartInfo_UOMID not null, 
	MachineNo number(5),
	BinNo varchar2(200)
		constraint nn_TexMcPartInfo_BinNo not null,
	REORDERQTY NUMBER(5),
	SupplierAddress varchar2(200), 
	ORDERLEADTIME NUMBER(5), 
	REMARKS VARCHAR2(300), 
	PROJCODE NUMBER(2),
	CCATACODE NUMBER(2),
 	WAVGPRICE NUMBER(12,4),
	MPGroupID NUMBER(5)
);

PROMPT table 194 :: T_TexMcPartsPrice
create table T_TexMcPartsPrice
(	
	PartId number(15)
		constraint nn_T_TexMcPartsPrice_PartId not null,
	SupplierName varchar2(30),
	Qty number(10)
		constraint nn_T_TexMcPartsPrice_Qty not null,
	UnitPrice number(10,2)
		constraint nn_T_TexMcPartsPrice_Unitprice not null,
	PurchaseDate date
		constraint nn_T_TexMcPartsPrice_PurDate not null,
	PID            NUMBER(15) not null,
	PPRICE         NUMBER(12,4),
	PQTY           NUMBER(12,4),
	NPRICE         NUMBER(12,4),
	NQTY           NUMBER(12,4),
	REFPID         NUMBER(20)
);

PROMPT  table 195 :: T_TexMCPARTSSTATUS 
CREATE TABLE T_TexMCPARTSSTATUS 
(
	PARTSSTATUSID NUMBER(3) not null, 
	PARTSSTATUS VARCHAR2(150) 
	constraint nn_T_TexMCPSTATUS_PARTSSTATUS not null
);


PROMPT  table 196 :: T_TexMcStock
create table T_TexMcStock
(
  STOCKID            NUMBER(15),
  STOCKDATE          DATE
	constraint nn_T_TexMcStock_StockDate not null,
  CHALLANNO          VARCHAR2(20 ),
  CHALLANDATE        DATE,
  PURCHASEORDERNO    VARCHAR2(20 ),
  PURCHASEORDERDATE  DATE,
  TexMCSTOCKTYPEID   NUMBER(15) 
	CONSTRAINT nn_T_TexMcStock_TexMCSTYPEID NOT NULL,
  SUPPLIERNAME       VARCHAR2(100),
  SUPPLIERADDRESS    VARCHAR2(200),
  DELIVERYNOTE       VARCHAR2(20),
  CURRENCYID VARCHAR2(20),
  CONRATE  NUMBER(12,4),
  SCOMPLETE NUMBER(1),
  SUPPLIERID NUMBER(15)
);

PROMPT table 197 :: T_TexMcStockBalance
create table T_TexMcStockBalance
(
	PartId number(20)		
		constraint nn_T_TexMcStockBal_PartId not null,		
	StockDate date
		constraint nn_T_TexMcStockBal_StockDate not null,
	MainStock number(12,2),
	ProdStock number(12,2)
) ;

PROMPT  table 198 :: T_TexMcStockItems
create table T_TexMcStockItems
(
  STOCKID            NUMBER(15) 
	CONSTRAINT NN_TexMcStockItems_STOCKID NOT NULL,
  STOCKITEMSL        NUMBER(3) 
	CONSTRAINT NN_TexMcStockItems_STOCKITEMSL NOT NULL,
  PARTID             NUMBER(15) 
	CONSTRAINT NN_TexMcStockItems_PARTID NOT NULL,
  UNITPRICE          NUMBER(12,4) 
	CONSTRAINT NN_TexMcStockItems_UNITPRICE NOT NULL,
  REMARKS            VARCHAR2(300 ),
  PARTSSTATUSFROMID  NUMBER(3),
  QTY                NUMBER(12,2)
	constraint nn_T_TexMcStockItems_Qty not null,
  PID                NUMBER(20),
  PARTSSTATUSTOID    NUMBER(3),
  IssueFor          NUMBER(6),
  TexMCSTOCKTYPEID   NUMBER(15),
  CURRENTSTOCK       NUMBER(12,2),
  UNITOFMEASID    VARCHAR2(20),
  MPGroupID NUMBER(5)
);

PROMPT  table 199 :: T_TexMcStockItemsReq
create table T_TexMcStockItemsReq
(
  STOCKID            NUMBER(15) 
	CONSTRAINT NN_TexMcStockItemsReq_STOCKID NOT NULL,
  STOCKITEMSL        NUMBER(3) 
	CONSTRAINT NN_TexMcStockIsR_STOCKITEMSL NOT NULL,
  PARTID             NUMBER(15) 
	CONSTRAINT NN_TexMcStockItemsReq_PARTID NOT NULL,
  UNITPRICE          NUMBER(12,2) 
	CONSTRAINT NN_TexMcStIsReq_UNITPRICE NOT NULL,
  REMARKS            VARCHAR2(300 ),
  PARTSSTATUSFROMID  NUMBER(3),
  QTY                NUMBER(12,2)
	constraint nn_T_TexMcStockItemsReq_Qty not null,
  PID                NUMBER(20),
  PARTSSTATUSTOID    NUMBER(3),
  IssueFor          NUMBER(6),
  TexMCSTOCKTYPEID   NUMBER(15),
  CURRENTSTOCK       NUMBER(12,2),
  MPGroupID NUMBER(5)
);


PROMPT table 200 :: T_TexMcStockReq
create table T_TexMcStockReq
(
  STOCKID            NUMBER(15),
  STOCKDATE          DATE
	constraint nn_TexMcStockReq_StockDate not null,
  CHALLANNO          VARCHAR2(20 ),
  CHALLANDATE        DATE,
  PURCHASEORDERNO    VARCHAR2(20 ),
  PURCHASEORDERDATE  DATE,
  TexMCSTOCKTYPEID   NUMBER(15) 
	CONSTRAINT nn_TexMcStockReq_TexMCSTYPEID NOT NULL,
  SUPPLIERNAME       VARCHAR2(100),
  SUPPLIERADDRESS    VARCHAR2(200),
  DELIVERYNOTE       VARCHAR2(20),
  Executed	NUMBER(1) default 0
  constraint nn_TexMcStockReq_Executed not null
);

PROMPT  table 201 :: T_TexMCSTOCKSTATUS
CREATE TABLE T_TexMCSTOCKSTATUS 
(
  	TexMCSTOCKTYPEID   NUMBER(15) CONSTRAINT NN_TexMCSTSTATUS_MCSTTYPEID NOT NULL,
  	PARTSSTATUSFROMID  NUMBER(3) CONSTRAINT NN_TexMCSTSTATUS_PARTSSTATU NOT NULL,
  	PARTSSTATUSTOID    NUMBER(3) CONSTRAINT NN_TexMCSTSTATUS_PARTSSTATO NOT NULL,
  	MSN                NUMBER(2)                  DEFAULT 0,
  	MSO                NUMBER(2)                  DEFAULT 0,
  	MSB                NUMBER(2)                  DEFAULT 0,
  	MSR                NUMBER(2)                  DEFAULT 0,
  	FSN                NUMBER(2)                  DEFAULT 0,
  	FSO                NUMBER(2)                  DEFAULT 0,
  	PID                NUMBER(20) CONSTRAINT NN_TexMCSTOCKSTATUS_PID NOT NULL,
  	SSN                NUMBER(2)
);


PROMPT  table 202 :: T_TexMCSTOCKTYPE
CREATE TABLE T_TexMCSTOCKTYPE 
(
	TexMCSTOCKTYPEID NUMBER(15)
	constraint nn_T_TexMCST_TexmcStoTyid not Null, 
	TexMCSTOCKTYPE VARCHAR2(150)
	constraint nn_T_TexMCST_TexmcStockType not null 
);

PROMPT  table 203 :: T_TexMCSTOCKTYPEReq
CREATE TABLE T_TexMCSTOCKTYPEReq
(
	TexMCSTOCKTYPEID NUMBER(15)
	constraint nn_TexMCSTR_TexmcStoTyid not Null, 
	TexMCSTOCKTYPE VARCHAR2(150)
	constraint nn_TexMCSTR_TexmcStockType not null 
);

PROMPT  TABLE 204 :: T_TKNITCOUNT
CREATE TABLE T_TKNITCOUNT
(
  COUNTID        NUMBER(6)                      
  constraint nn_TknitCount_TKCount NOT NULL,
  QUALITYNO      VARCHAR2(6)                    
  constraint nn_TKnitCount_QualityNo NOT NULL,
  QUALITYDES     VARCHAR2(200),
  QUALITY        VARCHAR2(100),
  MACHINENNAME   VARCHAR2(100),
  COUNTNAME      VARCHAR2(70),
  DIA            VARCHAR2(10),
  GAUGE          VARCHAR2(10),
  STICHLENGTH    VARCHAR2(30),
  GRAYGSM        VARCHAR2(12),
  FINISHEDGSM    NUMBER(12,4),
  GRAYWIDTH      VARCHAR2(12),
  FINISHEDWIDTH  VARCHAR2(12),
  SHRINKAGE      VARCHAR2(12),
  INOPERATIONID  NUMBER(1),
  ACHIEVEDWIDTH  VARCHAR2(12)
);

PROMPT  TABLE 205 :: T_TKNITWOITEMS
CREATE TABLE T_TKNITWOITEMS
(
  BASICTYPEID       VARCHAR2(3),
  WONUMBER          NUMBER(6),
  WOITEMSL          NUMBER(3),
  UNITID            NUMBER(1)                   
  constraint nn_TKnitWoItems_UnitId NOT NULL,
  SHADE             VARCHAR2(200)               
  constraint nn_TKnitWoItems_Shade NOT NULL,
  COUNTID           NUMBER(6)                   
  constraint nn_TKnitWoItems_CountId NOT NULL,
  YARNTYPEID        NUMBER(3)                   
  constraint nn_TKnitWoItems_YTypeId NOT NULL,
  QUALITY           VARCHAR2(100),
  GSM               NUMBER(12,2),
  WIDTH             VARCHAR2(12),
  SHRINKAGE         VARCHAR2(12),
  WOITEMSQTY        NUMBER(12,2)                
  constraint nn_TKnitWoItems_woitemSqty NOT NULL,
  WOITEMSUNITPRICE  NUMBER(14,3),
  WOITEMSDDATE      DATE,
  WOITEMSCOMMENTS   VARCHAR2(100),
  CBASICTYPEID      VARCHAR2(3),
  CONNUMBER         NUMBER(6),
  CONITEMSL         NUMBER(6),
  YCOUNTID          NUMBER(3),
  YYARNTYPEID       NUMBER(3),
  QUALITYID         NUMBER(6),
  BRANDID           NUMBER(6)
);

PROMPT TABLE 206 :: T_TRANSRPT
CREATE TABLE T_TRANSRPT
(
  PID        NUMBER(3)                          
  constraint nn_TRANSRPT_Pid NOT NULL,
  TRANSNAME  VARCHAR2(50),
  OWNFAC     NUMBER(3),
  OTHFAC     NUMBER(3),
  GROUPID    NUMBER(2),
  STATUS     VARCHAR2(3)
);

PROMPT TABLE  207  ::  T_UnitOfMeas

CREATE  TABLE T_UnitOfMeas
(
	UnitOfMeasID	VARCHAR2(20) not null,
	UnitOfMeas	VARCHAR2(20)
	constraint nn_unitofmeas_unitofmeas not null
	constraint u_unitofmeas_unitofmeas unique
);

PROMPT TABLE  208  ::  T_UserLogging

CREATE  TABLE T_UserLogging
(
	UserLoggingId number(20) not null,
	UserId	varchar2(50) not null,
	LogIn 	DATE not null,
	Terminal	varchar2(100),
	LogOut	DATE
);

PROMPT TABLE   209 :: T_WorkOrder

CREATE  TABLE T_WorkOrder
(
	BasicTypeID	VARCHAR2(20),
	OrderNo		number(15) not null,
	OrderDate 	DATE,
	ClientID	VARCHAR2(20) 
	constraint nn_workorder_clientid not null,
	SalesTermID	VARCHAR2(20) 
	constraint nn_workorder_salestermid not null,
	CurrencyID	VARCHAR2(20)
	constraint nn_workorder_currencyid not null,
	ConRate NUMBER(12,4)
	constraint nn_workorder_conrate not null,
	SalesPersonID 	VARCHAR2(20)
	constraint nn_workorder_salespersonid not null,
	Wcancelled	NUMBER(1) default 0
	constraint nn_workorder_wcancelled not null, 	
	WRevised	NUMBER(1) default 0
	constraint nn_workorder_wrevised not null,
	OrderStatusID	VARCHAR2(20)
	constraint nn_workorder_orderstatusid not null,
	ContactPerson	VARCHAR2(100),
	ClientsRef	VARCHAR2(150),
	DeliveryPlace	VARCHAR2(200),
	DeliveryStartDate date,
	DeliveryEndDate date,
	DailyProductionTarget NUMBER(12,2),
	OrderRemarks	VARCHAR2(1000),
	OrderRef	Number(10),
	GarmentsOrderRef number(15),
	dorderno number(15),
	Budgetid Number(15),
	PPQTY NUMBER(10,4),
	PSQTY NUMBER(10,4),
	PRATE NUMBER(10,4),
	TOTALPRICE NUMBER(10,4)
  );

  
PROMPT  TABLE  210 :: T_YarnCost

CREATE  TABLE T_YarnCost
(
BUDGETID NUMBER(15),
PID      NUMBER(15),
YARNTYPEID VARCHAR2(20),
YARNCOUNTID VARCHAR2(20),
SUPPLIERID NUMBER(15),
QUANTITY  NUMBER(12,2),
UNITPRICE NUMBER(12,4),
TOTALCOST NUMBER(12,3),
STAGEID   NUMBER(3),
USES      NUMBER(3),
QTY       NUMBER(12,2),
PROCESSLOSS NUMBER(3),
FABRICTYPEID VARCHAR2(20),
PPID        NUMBER(15)
);

PROMPT TABLE  211 :: T_YarnCount

CREATE  TABLE T_YarnCount
(
	YarnCountID 	VARCHAR2(20) not null,
	YarnCount	VARCHAR2(50)
	constraint nn_yarncount_yarncount not null
	constraint u_yarncount_yarncount unique 
);

PROMPT TABLE  212 :: T_YarnDesc

CREATE  TABLE T_YarnDesc
(
	PID		varchar2(20),
	OrderLineItem	varchar2(20),
	YarnCountID	varchar2(20)
	constraint nn_yarndesc_yarncountid not null,
	YarnTypeID 	varchar2(20)
        constraint nn_yarndesc_yarntypeid not null,
	StitchLength	NUMBER(12,2),
	YarnPercent 	NUMBER(12,2) default 100
	constraint nn_yarndesc_yarnPercent not null
);

PROMPT table 213 :: T_YarnImpLC
create table T_YarnImpLC
(
	LCNo number(10)	constraint nn_T_YarnImpLC_LCNo not null,
	BankLCNo varchar2(200)	constraint nn_T_YarnImpLC_BankLCNo not null constraint u_T_YarnImpLC_BankLCNo unique,
	OpeningDate date constraint nn_T_YarnImpLC_OpeningDate not null,
	CurrencyId varchar2(20) constraint nn_T_YarnImpLC_CurrencyId not null,
	ConRate number(12,4) constraint nn_T_YarnImpLC_Conrate not null,
	ExpLCNo number,	
	ShipmentDate date,
	ImpLCStatusId number(2) default 0 constraint nn_T_YarnImpLC_ImpLCStatusId not null,
	DocRecDate date,
	DocRelDate date,
	ShipDate date,
	GoodsRecDate date,
	BankCharge number(12,2),
	Insurance number(12,2),
	TruckFair number(12,2),
	CNFValue number(12,2),
	OtherCharge number(12,2),
	Cancelled number(1) default 0 constraint nn_T_YarnImpLC_Cancelled not null,
	Remarks varchar2(200),
	IMPLCTYPEID number(3) constraint nn_T_YarnImpLC_LcTypeId not null,
	Linked number(2) default 0,
	LCMATURITYPERIOD number(3),
	SUPPLIERID NUMBER(15)
);

PROMPT table 214 :: T_YarnImpLCItems
create table T_YarnImpLCItems
(	
	PID number(20),
	LCNo number(10),
	yarnImpLCItemsSL number(3),
	CountID varchar2(20),		
	YarnTypeID varchar2(20),
	Qty number(12,2) constraint nn_T_YarnImpLCItems_Qty not null,
	UnitPrice number(12,2) constraint nn_T_YarnImpLCItems_UnitPrice not null,
	ValueFC number(12,2) constraint nn_T_YarnImpLCItems_ValueFC not null,
	ValueTk number(12,2) constraint nn_T_YarnImpLCItems_ValueTk not null,
	ValueBank number(12,2),
	ValueInsurance number(12,2),
	ValueTruck number(12,2),
	ValueCNF number(12,2),	
	ValueOther number(12,2),
	TotCost number(12,2) constraint nn_T_YarnImpLCItems_TotCost not null,	
	UnitCost number(12,2) constraint nn_T_YarnImpLCItems_UnitCost not null
);
PROMPT table 215 :: T_YARNPARTY
create table T_YARNPARTY
(
	PID    NUMBER(15) NOT NULL,
	PARTYNAME   VARCHAR2(200)
);


PROMPT table 216 :: T_YarnPrice

create table T_YarnPrice
(	
	PID number(12),
	YarnStockId number(20),	
	YarnTypeID	VARCHAR2(20) not null,
	CountID 	VARCHAR2(20) not null,
	YarnBatchNo varchar2(30) not null,
	SUPPLIERID NUMBER(15),	
	PurchaseDate date not null,		
	Qty number(12,2) not null,
	UnitPrice number(12,2) not null,
	PPRICE         NUMBER(12,4),
	PQTY           NUMBER(12,4),
	NPRICE         NUMBER(12,4),
	NQTY           NUMBER(12,4),
	REFPID         NUMBER(20),
	CURRENCYID VARCHAR2(20),
	CONRATE    NUMBER(12,4)
);

PROMPT table 217 :: T_YarnRequisition
create table T_YarnRequisition
(
	StockId number(20) constraint nn_T_YarnReq_SId not null,		
	YarnRequisitionTypeId number(3) constraint nn_T_YarnReq_knittrantypeid not null,
	ReferenceNo varchar2(150),
	ReferenceDate Date,
	StockTransNo varchar2(50) constraint nn_T_YarnReq_StockTranNo not null,
	StockTransDate Date constraint nn_T_YarnReq_StockTranDate not null,
	SupplierId number(15),
	SupplierInvoiceNo varchar2(20),
	SupplierInvoiceDate Date,
	Remarks varchar2(200),
	SubConId number(6),
	Execute number(1),
	PARENTSTOCKID  NUMBER(20)
);

PROMPT  table 218 :: T_YarnRequisitionItems

create table T_YarnRequisitionItems
(
	PID number(20),
	StockId number(20)
	constraint nn_T_YarnReqItems_StockId not null,		
	KntiStockItemSL number(3),
	YarnCountId varchar2(20),
	YarnTypeId varchar2(20),
	FabricTypeId varchar2(20),
	OrderLineItem varchar2(20),
	Quantity number(12,2)
	constraint nn_T_YarnReqItems_Qty not null,
	SQuantity number(12,2),
	PunitOfMeasId varchar2(20)
	constraint nn_T_YarnReqItems_PUOM not null,
	SunitOfMeasId varchar2(20),
	YarnBatchNo varchar2(50),
	Shade varchar2(100),
	Remarks varchar2(200),
	orderno number(15),
	supplierId number(15),
	currentstock number(12,2),
	MergeId number(20),
	DyedLotNo varchar2(50),
	SHADEGROUPID NUMBER(3),
	BUDGETQTY NUMBER(12,2),
	REMAINQTY NUMBER(12,2),
	YARNFOR  NUMBER(15)
);

PROMPT  table 219 :: T_YarnRequisitionType
create table T_YarnRequisitionType
(
	YarnRequisitionTypeId number(3),
	YarnRequisitionType varchar2(100)
	constraint un_T_YarnReq_TranType unique
	constraint nn_T_YarnReq_TranType not null
);

PROMPT TABLE  220 :: T_YarnType

CREATE  TABLE t_yarntype
( 
	YarnTypeID	VARCHAR2(20) not null,
	YarnType	VARCHAR2(100)
    	constraint nn_yarntype_yarntype not null
	constraint u_yarntype_yarntype unique
);

PROMPT TABLE  221 :: T_YDPLANSUBCON

CREATE  TABLE T_YDPLANSUBCON
( 
PLANID    NUMBER(20) NOT NULL,
MERGEID    NUMBER(20) NOT NULL,
SCHEDULEDATE    DATE NOT NULL,
SCHEDULEPLANDATE    DATE NOT NULL,
SUBCONID      NUMBER(6) NOT NULL,
PLANQTY   NUMBER(12,2),
PLANSTATUSID     NUMBER(3) NOT NULL,
PLANREMARKS   VARCHAR2(200),
ORDERNO    NUMBER(15) NOT NULL
);


PROMPT TABLE  222 :: T_YDPRODUCTIONSUBCON

CREATE  TABLE T_YDPRODUCTIONSUBCON
( 
PRODUCTIONID    NUMBER(20) NOT NULL,
PLANID     NUMBER(20) NOT NULL,
PLANDATE     DATE NOT NULL,
PRODQUANTITY     NUMBER(12,2),
PRODREMARKS   VARCHAR2(200),
ORDERNO     NUMBER(15) NOT NULL
);




PROMPT create table 223 :: T_GAWorkOrder  
create table T_GAWorkOrder
(
	OrderNo		number(15) not null,
	OrderDate 	DATE,
	ClientID	VARCHAR2(20), 
	SalesTermID	VARCHAR2(20) 
	constraint nn_gaworkorder_salestermid not null,
	CurrencyID	VARCHAR2(20)
	constraint nn_gaworkorder_currencyid not null,
	ConRate NUMBER(12,4)
	constraint nn_gaworkorder_conrate not null,
	SalesPersonID 	VARCHAR2(20),	
	Wcancelled	NUMBER(1) default 0
	constraint nn_gaworkorder_wcancelled not null, 	
	WRevised	NUMBER(1) default 0
	constraint nn_gaworkorder_wrevised not null,
	OrderStatusID	VARCHAR2(20)
	constraint nn_gaworkorder_orderstatusid not null,
	ContactPerson	VARCHAR2(100),
	ClientsRef	VARCHAR2(150),
	DeliveryPlace	VARCHAR2(200),
	DeliveryStartDate date,
	DeliveryEndDate date,
	DailyProductionTarget NUMBER(12,2),
	OrderRemarks	VARCHAR2(1000),
	OrderRef	Number(10),
	GOrderNo number(15),
	dorderno number(15),
	SupplierId number(15),
	BudgetID Number(15)
);


PROMPT create table 224:: T_GAWorkOrderItems
create table T_GAWorkOrderItems
(
	PID number(20) not null,
	OrderNo number(15) not null,
	GAWOITEMSL       NUMBER(3),
	ImpLCNO varchar2(100),	
	StyleNo VARCHAR2(50),	
	Code  VARCHAR2(50),
	AccessoriesID number(15) not null,
	Count_Size  VARCHAR2(50),				
	Quantity number(12,2) not null,
	PunitOfMeasId varchar2(20) not null,
	SQuantity number(12,2),	
	SunitOfMeasId varchar2(20),	
	Remarks varchar2(200),		
	CurrentStock number(12,2),
	ColourID  VARCHAR2(50),
	GOrderNo number(15),
	ClientRef varchar2(400),
	lineNo varchar2(50),
	UnitPrice number(12,4),
	GroupId number(3),
	PARENTSTOCKID NUMBER(20)		
);




PROMPT create table T_GBill
drop table T_GBill;
create table T_GBill
(
	ORDERCODE  VARCHAR2(10),
	BillNo number(6),
	BillDate date
		constraint nn_T_GBill_BillDate not null,
	CLIENTID   VARCHAR2(20) 
		constraint nn_T_GBill_ClientId not null,
	BillDiscount number(12,2),
	BillDisComments varchar2(50),
	BillDisPerc number(5,2),
	CURRENCYID  VARCHAR2(20)
		constraint nn_T_GBill_CurrencyId not null,		
 	CONRATE     NUMBER(12,4)
		constraint nn_T_GBill_BConRate not null,
	Cancelled number(1) default 0
		constraint nn_T_GBill_Cancelled not null 
		constraint c_T_GBill_Cancelled check(Cancelled in(0,1)),
	BillComments varchar2(1000),
	EMPLOYEEID  VARCHAR2(20),
	KNITTING NUMBER(3),
	DYEING NUMBER(3),
	FABRIC NUMBER(3)
);
/


PROMPT create table T_GBillItems
drop table T_GBillItems;
create table T_GBillItems
(
	ORDERCODE  VARCHAR2(10),
	BillNo number(6),
	BillItemSl number(3),
	DORDERCODE  VARCHAR2(10),
	DInvoiceNo VARCHAR2(50),/* number(6),*/
	DItemSl number(3),
	WORDERCODE  VARCHAR2(10)
		constraint nn_T_GBillItems_WORDERCODE not null,
	GORDERNO   NUMBER(15)
		constraint nn_T_GBillItems_GORDERNO not null,
	WoItemSl number(3)
		constraint nn_T_GBillItems_WoItemSl not null,
	BillItemsQty number(10,2)
		constraint nn_T_GBillItems_BillItemsQty not null,
	BillItemsUnitPrice number(10,2)
		constraint nn_T_GBillItem_BillItemsUnitPr not null,
	ColorDepthId number(3)	
);
/

PROMPT create table T_GBillPayment
drop table T_GBillPayment;
create table T_GBillPayment
(
	ORDERCODE varchar2(10),
	BillNo number(6),
	BillPayItemSl number(3),
	GOrderNo number(6)
		constraint nn_T_GBillPayment_GOrderNo not null,
	BillPmtDate date
		constraint nn_T_GBillPayment_BillPmtDate not null,
	BillWoPmt number(10,2)
		constraint nn_T_GBillPayment_BillWoPmt not null	
);
/



Create TABLE T_SCGWORKORDER
(
SCGORDERNO      NUMBER(15) NOT NULL,
GORDERNO        NUMBER(15) NOT NULL,
GORDERDATE		DATE,
CLIENTID		VARCHAR2(20) NOT NULL,
SALESTERMID		VARCHAR2(20) NOT NULL,
CURRENCYID		VARCHAR2(20) NOT NULL,
CONRATE			NUMBER(12,4) NOT NULL,
SALESPERSONID    VARCHAR2(20) NOT NULL,
WCANCELLED      NUMBER(1) NOT NULL,
WREVISED      NUMBER(1) NOT NULL,
ORDERSTATUSID     VARCHAR2(20) NOT NULL,
CONTACTPERSON    VARCHAR2(100),
CLIENTSREF        VARCHAR2(400) NOT NULL,
DELIVERYPLACE   VARCHAR2(200),
DELIVERYSTARTDATE   DATE,
DELIVERYENDDATE       DATE,
DAILYPRODUCTIONTARGET     NUMBER(12,2),
TERMOFDELIVERY      VARCHAR2(200),
TERMOFPAYMENT     VARCHAR2(50),
SEASON      VARCHAR2(50),
COSTINGREFNO     VARCHAR2(50) NOT NULL,
QUOTEDPRICE    NUMBER(12,4),
ORDERREMARKS    VARCHAR2(500),
GDORDERNO   NUMBER(15),
ORDERTYPEID  VARCHAR2(5)
);




   
Create TABLE T_SCGORDERITEMS(
 ORDERLINEITEM   VARCHAR2(20),
 WOITEMSL        NUMBER(3) NOT NULL,
 SCGORDERNO        NUMBER(15) CONSTRAINT NN_T_SCGWorkOrder_SCGORDERNO NOT NULL,
 STYLE  VARCHAR2(50) CONSTRAINT NN_T_SCGORDERITEMS_STYLE NOT NULL,
 COUNTRYID VARCHAR2(6) CONSTRAINT NN_T_SCGORDERITEMS_CountryID NOT NULL,
 SHADE           VARCHAR2(100) CONSTRAINT NN_T_SCGORDERITEMS_SHADE NOT NULL,
 Price   NUMBER(12,4),
 QUANTITY        NUMBER(12,2) CONSTRAINT NN_T_SCGORDERITEMS_QUANTITY NOT NULL,
 UNITOFMEASID    VARCHAR2(20) CONSTRAINT NN_T_SCGORDERITEMS_UOMEASID NOT NULL,
 DeliveryDate date,
 REMARKS         VARCHAR2(200),
 CURRENTSTOCK NUMBER(12,2),
 TORDERLINEITEMREF VARCHAR2(20)
);




PROMPT TABLE  109 :: T_SCGordertype
Create table T_SCGordertype
(
	ordertype varchar2(10),
	description varchar2(50)
);

INSERT INTO T_SCGordertype(ordertype,description) VALUES('SCG', 'SCG Work Order');
INSERT INTO T_SCGordertype(ordertype,description) VALUES('SCGPE', 'SCG Print and Embroidery  WO');



PROMPT ===================== Costing Module_ ====================================
CREATE TABLE T_Particular
(
	PARTICULARID  NUMBER(20) PRIMARY KEY,
	PARTICULARNAME VARCHAR2(100)
);

CREATE TABLE T_OverheadType
(
	OHTYPEID NUMBER(4),
	OHTYPENAME VARCHAR2(50)
			constraint nn_T_OVERHEADTYPE_OHTYPENAME NOT NULL 
);

CREATE TABLE T_Overhead
(
	PID   NUMBER(6) PRIMARY KEY,
	OVERHEADNO VARCHAR2(50)
			constraint nn_T_OVERHEAD_OVERHEADNO NOT NULL,
	YMONTH DATE 
			constraint nn_T_OVERHEAD_YMONTH NOT NULL,
	KNITTINGHOUR NUMBER(6,2) ,
	DYEINGHOUR  NUMBER(6,2) ,
	FINISHINGHOUR  NUMBER(6,2) ,
	RMGHOUR  NUMBER(6,2) 
);

CREATE TABLE T_OverheadItems
(
	ID  NUMBER(6)  primary key,
	ITEMSSL  NUMBER(3) constraint nn_T_OVERHEADITEMS_ITEMSSL NOT NULL,
	PID  NUMBER(6) references T_OVERHEAD(PID),
	OHTYPEID NUMBER(8) references T_OVERHEADTYPE(OHTYPEID),
	PARTICULARID  NUMBER(5) references T_PARTICULAR(PARTICULARID),
	KNITTING  NUMBER(12,2),
	DYEING  NUMBER(12,2),
	FINISHING  NUMBER(12,2),
	RMG  NUMBER(12,2),
	TOTAL NUMBER(12,2)
);


CREATE TABLE T_KnittingShift
(
	ShiftID	varchar2(1) not null,
	ShiftingTime	varchar2(50)
   	constraint nn_GShift_ShiftingTime not null
);

Insert into T_KnittingShift values ('A', '06.00 AM To 02.00 PM');
Insert into T_KnittingShift values ('B', '02.00 PM To 10.00 PM');
Insert into T_KnittingShift values ('C', '10.00 PM To 06.00 AM');


CREATE TABLE T_KNITMACHINEINFOITEMS
(
  PID number(20),
  MACHINEID  NUMBER(6)                      
  constraint nn_KMInfoItems_MID NOT NULL,  
  FABRICTYPEID   VARCHAR2(20)                   
  constraint nn_KMInfoItems_FabricTypeId NOT NULL,
  KNITMCDIA      VARCHAR2(10)                   
  constraint nn_KMInfoItems_KnitMcDia NOT NULL,
  KNITMCGAUGE    VARCHAR2(10)                   
  constraint nn_KMInfoItems_knitMcGauge NOT NULL,
  GSM number(5) DEFAULT 0,
  ProductionHrs number(12,2) DEFAULT 0,
  PRICE NUMBER(12,4) DEFAULT 0,
  MCFEEDER       NUMBER(6)                      
  constraint nn_KMInfoItems_McFeeder NOT NULL,
  RATEDCAPACITY  NUMBER(6)                      
  constraint nn_KMInfoItems_RateDcapacity NOT NULL,
  UNITOFMEASID   VARCHAR2(20)                   
  constraint nn_KMInfoItems_UnitOfmeasid NOT NULL,
  PATTERNS       VARCHAR2(200),
  Status number(1)
);


CREATE  TABLE T_GCuttingPartsList
(
	GCPartsID		Number(20),
	GCuttingParts	varchar2(200)
	constraint nn_GPartsList_GParts not null
);
