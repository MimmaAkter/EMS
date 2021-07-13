

create sequence seq_CTNItem
start with 1
increment by 1
maxvalue 99999999999999999999;

create sequence seq_CTN
start with 1
increment by 1
maxvalue 99999999999999999999;

create sequence seq_OrderLineItem
start with 1
increment by 1
maxvalue 99999999999999999999;


create sequence SEQ_KNITSTOCKID
start with 1
increment by 1
maxvalue 99999999999999999999;

create sequence SEQ_YARNREQSTOCKID
start with 1
increment by 1
maxvalue 99999999999999999999;

create sequence seq_AuxStockItemSl
start with 1
increment by 1
maxvalue 99999999999999999999;



create sequence seq_AuxStockItemPID
start with 1
increment by 1
maxvalue 99999999999999999999;

create sequence seq_kmcpartstrandetsl
start with 50030
increment by 1
maxvalue 99999999999999999999;


create sequence seq_KnitStockItemPID
start with 1
increment by 1
maxvalue 99999999999999999999;


CREATE SEQUENCE SEQ_AUXIMPLCPID 
START WITH 1
INCREMENT BY 1 
MAXVALUE 99999999999999999999;

CREATE SEQUENCE SEQ_AUXSTOCKID 
START WITH 1 
INCREMENT BY 1 
MAXVALUE 99999999999999999999;

CREATE SEQUENCE SEQ_CLIENT 
START WITH 1 
INCREMENT BY 1 
MAXVALUE 99999999999999999999 ;

CREATE SEQUENCE SEQ_FABRICTYPE 
START WITH 1
INCREMENT BY 1 
MAXVALUE 99999999999999999999 ;


CREATE SEQUENCE SEQ_KMCTOCKITEMPID 
START WITH 1 
INCREMENT BY 1 
MAXVALUE 99999999999999999999 ;

CREATE SEQUENCE SEQ_KNITTINGMERGEID 
START WITH 96 
INCREMENT BY 1 
MAXVALUE 99999999999999999999;

CREATE SEQUENCE SEQ_ORDERITEMKNITTINGMERGE 
START WITH 1
INCREMENT BY 1 
MAXVALUE 99999999999999999999;


CREATE SEQUENCE SEQ_PLANID 
START WITH 1
INCREMENT BY 1 
MAXVALUE 99999999999999999999 ;

CREATE SEQUENCE SEQ_YARNCOUNT 
START WITH 1
INCREMENT BY 1 
MAXVALUE 99999999999999999999 ;

CREATE SEQUENCE SEQ_YARNDESC 
START WITH 17402
INCREMENT BY 1 
MAXVALUE 99999999999999999999 ;

CREATE SEQUENCE SEQ_KMCSTOCKID
START WITH 55
INCREMENT BY 1
MAXVALUE 99999999999999999999;

CREATE SEQUENCE SEQ_AUXILIARIESID
START WITH 60
INCREMENT BY 1
MAXVALUE 99999999999999999999;

CREATE SEQUENCE SEQ_DBATCHID
START WITH 2
INCREMENT BY 1
MAXVALUE 99999999999999999999;

create sequence seq_BatchItemPID
start with 1
increment by 1
maxvalue 99999999999999999999;



create sequence seq_DInvoiceID
start with 1
increment by 1
maxvalue 99999999999999999999;


create sequence seq_DInvoiceItemPID
start with 1
increment by 1
maxvalue 99999999999999999999;

create sequence seq_YarnRequisitonItemsPID
start with 5000
increment by 1
maxvalue 99999999999999999999;

create sequence seq_AuxStockItemRequisitionSl
start with 1
increment by 1
maxvalue 99999999999999999999;



CREATE SEQUENCE SEQ_AUXSTOCKRequisitionID 
START WITH 1 
INCREMENT BY 1 
MAXVALUE 99999999999999999999;

create sequence seq_AuxStockItemRequisitionPID
start with 1
increment by 1
maxvalue 99999999999999999999;

CREATE SEQUENCE SEQ_KMCSTOCKREQID
START WITH 1
INCREMENT BY 1
MAXVALUE 99999999999999999999;

create sequence seq_kmcpartstrandetReqsl
start with 1
increment by 1
maxvalue 99999999999999999999;


create sequence Seq_partsHistory
start with 1
increment by 1
maxvalue 99999999999999999999;


create sequence SEQ_NiddleHID
start with 1
increment by 1
maxvalue 99999999999999999999;
-------------------------------------------------------------------------------------------------
--For Machine Stock
-------------------------------------------------------------------------------------------------

create sequence Seq_McPartsPricePID
	start with 1
	increment by 1
	maxvalue 99999999999999999999;

CREATE SEQUENCE SEQ_MachinePartsStockID
	START WITH 1
	INCREMENT BY 1
	MAXVALUE 99999999999999999999;

CREATE SEQUENCE SEQ_MachinePartsStockItemSL
	START WITH 1
	INCREMENT BY 1
	MAXVALUE 99999999999999999999;



CREATE SEQUENCE Seq_MachinePartsStockReqID
	START WITH 1
	INCREMENT BY 1
	MAXVALUE 99999999999999999999;

create sequence Seq_MachinePartsStockItemReqSL
	start with 1
	increment by 1
	maxvalue 99999999999999999999;

create sequence SEQ_TexMcpID
start with 1
increment by 1
maxvalue 99999999999999999999;

create sequence SEQ_GMcPartsPricePID
start with 1
increment by 1
maxvalue 99999999999999999999;

-------------------------------------------------------------------------------------------------
--For Dyeline
-------------------------------------------------------------------------------------------------
create sequence seq_dyeLineID
	start with 1
	increment by 1
	maxvalue 99999999999999999999;




create sequence seq_DYESUBITEMSID
	start with 1
	increment by 1
	maxvalue 99999999999999999999;

-------------------------------------------------------------------------------------------------
--For Acc
-------------------------------------------------------------------------------------------------
CREATE SEQUENCE seq_ACCESSORIESID
START WITH 1
INCREMENT BY 1 
MAXVALUE 99999999999999999999;

Drop SEQUENCE seq_AccRequisitionID;

CREATE SEQUENCE seq_AccRequisitionID
START WITH 1
INCREMENT BY 1 
MAXVALUE 99999999999999999999;

Drop SEQUENCE seq_AccRequisitionItemsPID;
CREATE SEQUENCE seq_AccRequisitionItemsPID
START WITH 1
INCREMENT BY 1 
MAXVALUE 99999999999999999999;

Drop SEQUENCE seq_AccStockId;
CREATE SEQUENCE seq_AccStockId
START WITH 1
INCREMENT BY 1 
MAXVALUE 99999999999999999999;

Drop SEQUENCE seq_AccStockItemsPID;
CREATE SEQUENCE seq_AccStockItemsPID
START WITH 1
INCREMENT BY 1 
MAXVALUE 99999999999999999999;



//====================================================================================
// Exp LC	
//====================================================================================


CREATE SEQUENCE seq_ExpLcLCItemID
START WITH 1
INCREMENT BY 1 
MAXVALUE 99999999999999999999;


CREATE SEQUENCE SEQ_LCInfoLCNo
START WITH 1
INCREMENT BY 1 
MAXVALUE 99999999999999999999;

CREATE SEQUENCE seq_ExpLCPaymentID
START WITH 1
INCREMENT BY 1 
MAXVALUE 99999999999999999999;



//====================================================================================
// Imp Lc		
//====================================================================================


CREATE SEQUENCE seq_AccImpLcPID
START WITH 1
INCREMENT BY 1 
MAXVALUE 99999999999999999999;


CREATE SEQUENCE SEQ_YarnIMPLCPID 
START WITH 1
INCREMENT BY 1 
MAXVALUE 99999999999999999999;

CREATE SEQUENCE seq_BTBLCPaymentID 
START WITH 1
INCREMENT BY 1 
MAXVALUE 99999999999999999999;

//====================================================================================
// Yarn	
//====================================================================================

Drop SEQUENCE seq_YarnPricePID;

CREATE SEQUENCE seq_YarnPricePID
START WITH 1
INCREMENT BY 1 
MAXVALUE 99999999999999999999;


//====================================================================================
// T_QC	
//====================================================================================

create sequence SEQ_QCID 
start with 1 
increment by 1
maxvalue 9999999999999999999999;

/* T_QcItems */
create sequence SEQ_QCPID 
start with 1 
increment by 1
maxvalue 99999999999999999999999;

/* T_QCStatus */
create sequence SEQ_QcStatusId 
start with 1 
increment by 1
maxvalue 9999999999999999999999;


//====================================================================================
// Budget
//====================================================================================
create sequence Seq_BSPID
	start with 1
	increment by 1
	maxvalue 99999999999999999999;

create sequence Seq_accesoriesPID
	start with 1
	increment by 1
	maxvalue 99999999999999999999;

create sequence Seq_kdfPID
	start with 1
	increment by 1
	maxvalue 99999999999999999999;
		
CREATE SEQUENCE SEQ_SampleID
START WITH 1
INCREMENT BY 1 
MAXVALUE 99999999999999999999;

CREATE SEQUENCE SEQ_GPassItem
START WITH 1
INCREMENT BY 1 
MAXVALUE 99999999999999999999;



	
//====================================================================================
// Budget
//====================================================================================

/********************Stationery ****************************************/

CREATE SEQUENCE SEQ_Stationerystcok
START WITH 1
INCREMENT BY 1 
MAXVALUE 99999999999999999999;

CREATE SEQUENCE SEQ_StationerystcokItems
START WITH 1
INCREMENT BY 1 
MAXVALUE 99999999999999999999;



CREATE SEQUENCE SEQ_PurchaseReq
	START WITH 1
	INCREMENT BY 1 
	MAXVALUE 99999999999999999999;

CREATE SEQUENCE SEQ_PurchaseReqItems
	START WITH 1
	INCREMENT BY 1 
	MAXVALUE 99999999999999999999;
	
	
create sequence SEQ_GMCPReq
	start with 1
	increment by 1
	maxvalue 99999999999999999999;

create sequence SEQ_GMCPReqItems
	start with 1
	increment by 1
	maxvalue 99999999999999999999;	
	
create sequence seq_sqllog
	start with 1
	increment by 1
	maxvalue 99999999999999999999;


create sequence seq_logseqid
	start with 1
	increment by 1
	maxvalue 99999999999999999999;

Create sequence Seq_shipmentinfo
start with 1
increment by 1
MAXVALUE 99999999999999999999;

Create sequence Seq_Lcvoucher
start with 1
increment by 1
MAXVALUE 99999999999999999999;
Create sequence Seq_Lcpaymentinfo
start with 1
increment by 1
MAXVALUE 99999999999999999999;
	
create sequence seq_UserLoggingId
	start with 1
	increment by 1
	maxvalue 99999999999999999999;

Create sequence Seq_moneyrecipt
start with 1
increment by 1
MAXVALUE 99999999999999999999;

Create sequence Seq_moneyreciptextile
start with 8
increment by 1
MAXVALUE 99999999999999999999;

Create sequence Seq_moneyreciptaydl
start with 1
increment by 1
MAXVALUE 99999999999999999999;
Create sequence Seq_moneyreciptabl
start with 1
increment by 1
MAXVALUE 99999999999999999999;
Create sequence Seq_moneyreciptae
start with 1
increment by 1
MAXVALUE 99999999999999999999;
Create sequence Seq_moneyreciptoi
start with 1
increment by 1
MAXVALUE 99999999999999999999;

CREATE SEQUENCE SEQ_gStockID
START WITH 1
INCREMENT BY 1 
MAXVALUE 99999999999999999999;

CREATE SEQUENCE SEQ_GStockItemID
START WITH 1
INCREMENT BY 1 
MAXVALUE 99999999999999999999;


CREATE SEQUENCE SEQ_GFabricReqStockID
START WITH 1
INCREMENT BY 1 
MAXVALUE 99999999999999999999;


CREATE SEQUENCE SEQ_GFabricReqItemID
START WITH 1
INCREMENT BY 1 
MAXVALUE 99999999999999999999;


CREATE SEQUENCE SEQ_cuttingid
START WITH 1
INCREMENT BY 1 
MAXVALUE 99999999999999999999;

CREATE SEQUENCE SEQ_cuttingitemid
START WITH 1
INCREMENT BY 1 
MAXVALUE 99999999999999999999;

CREATE SEQUENCE SEQ_invoiceid
START WITH 1
INCREMENT BY 1 
MAXVALUE 99999999999999999999;

CREATE SEQUENCE SEQ_ChallanItemid
START WITH 1
INCREMENT BY 1 
MAXVALUE 99999999999999999999;

CREATE SEQUENCE seq_GAWorkOrderItemPId 
START WITH 1
INCREMENT BY 1 
MAXVALUE 99999999999999999999;


	
CREATE SEQUENCE SEQ_FabricItemsPID
START WITH 1
INCREMENT BY 1 
MAXVALUE 99999999999999999999;
===================Electric Bill==================================

Create sequence Seq_electricitybill
start with 1
increment by 1
MAXVALUE 99999999999999999999;


create sequence Seq_Overhead
start with 1
increment by 1
maxvalue 99999999999999999999;

create sequence Seq_OverheadItems
start with 1
increment by 1
maxvalue 99999999999999999999;