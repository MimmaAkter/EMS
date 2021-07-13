ALTER TABLE T_ReportGroup
 ADD 
 CONSTRAINT PK_ReportGroup_ID PRIMARY KEY (ReportGroupId);
 
 ALTER TABLE T_ReportList
 ADD 
	CONSTRAINT PK_ReportList_ReportId PRIMARY KEY (ReportId);
	
 ALTER TABLE T_ReportAccess
 ADD 
	CONSTRAINT PK_ReportAccess PRIMARY KEY (ReportId,EmployeeId);
 
 ALTER TABLE T_Colour
  ADD
    (   
 	constraint pk_T_Colour_ColourID PRIMARY KEY(ColourID)
    );
PROMPT CREATING PRIMARYKEY CONSTRAINT  11 :: T_SCWorkOrder
ALTER TABLE T_SCWorkOrder
  ADD
   (
	constraint pk_SCworkorder_SCOrderno PRIMARY KEY(OrderNo)
   );
   
ALTER TABLE T_SCYarnDesc
  ADD
    (   
 	constraint pk_SCYarnDesc_PID PRIMARY KEY(PID)
    );
ALTER TABLE T_ColourCombination
  ADD
    (   
 	constraint pk_ColourCombination_PID PRIMARY KEY(PID)
    );
PROMPT CREATING PRIMARYKEY CONSTRAINT  13  ::  T_SCOrderItems
ALTER TABLE T_SCOrderItems
  ADD
    (   
 	constraint pk_SCorderitems_orderlineitem PRIMARY KEY(OrderLineItem)
    );
ALTER TABLE T_CANDF
  ADD 
  (
	CONSTRAINT PK_CANDF_CANDFID PRIMARY KEY (CANDFID)
  );

ALTER TABLE T_CTN
  ADD 
    (
	constraint pk_CTN PRIMARY KEY(orderno,CTNType)
    );

ALTER TABLE T_CTNItems 
	ADD 
	(
		CONSTRAINT FK_CTNID_CTNItems FOREIGN KEY (CTNID) 
			REFERENCES T_CTN (CTNID)
	);
	
ALTER TABLE T_processRoutecard
Add constraint T_prcard_cardno UNIQUE(ROUTECARDNO);

ALTER TABLE T_COMBINATION 
	ADD 
	( 
		CONSTRAINT PK_COMBINATION_COMBINATIONID PRIMARY KEY (COMBINATIONID)
	);


PROMPT CREATING PRIMARYKEY CONSTRAINT  1 :: T_Currency 

ALTER TABLE T_Currency
  ADD 
    (
	constraint pk_currency_currencyid PRIMARY KEY(CurrencyID)
    );

PROMPT CREATING PRIMARYKEY CONSTRAINT 2 :: T_BasicType

ALTER TABLE T_BasicType
 ADD
   (
	constraint pk_basictype_basictypeid PRIMARY KEY(BasicTypeID)
   );


PROMPT CREATING PRIMARYKEY CONSTRAINT 3 :: T_OrderStatus

ALTER TABLE T_OrderStatus
  ADD
   (
	constraint pk_orderstatus_orderstatusid PRIMARY KEY(OrderStatusID)
   );


PROMPT CREATING PRIMARYKEY CONSTRAINT 4 :: T_Client

ALTER TABLE T_Client
 ADD
   (
	constraint pk_cLient_clientid PRIMARY KEY(ClientID)
   );

PROMPT CREATING PRIMARYKEY CONSTRAINT 4 :: T_CompanyInfo
ALTER TABLE T_CompanyInfo
 ADD
   (
	constraint pk_CompanyInfo_CompanyID PRIMARY KEY(CompanyID)
   );


ALTER TABLE T_TEXMCSTOCK
	ADD  
	 (
		CONSTRAINT UN_MCSTOCK_STOCKID_STOCKTYPEID UNIQUE (STOCKID,TEXMCSTOCKTYPEID)   
	 );

ALTER TABLE T_KMCPARTSTRAN
	ADD  
	 (
		CONSTRAINT UN_KMCTRAN_STOCKID_STOCKTYPEID UNIQUE (STOCKID,KMCSTOCKTYPEID)   
	 );
PROMPT CREATING PRIMARYKEY CONSTRAINT 5 :: T_SalesTerm

ALTER TABLE T_SalesTerm
 ADD
   (
	constraint pk_salesterm_salestermid PRIMARY KEY(SalesTermID)
   );


PROMPT CREATING PRIMARYKEY CONSTRAINT 6 :: T_EmpGroup

ALTER TABLE T_EmpGroup
  ADD
   (
	constraint pk_empgroup_empgroupid PRIMARY KEY(EmpGroupID)
   );



PROMPT CREATING PRIMARYKEY CONSTRAINT 7 :: T_UnitOfMeas

ALTER TABLE T_UnitOfMeas
  ADD
   (
	constraint pk_unitofmeas_unitofmeasid PRIMARY KEY(UnitOfMeasID)
   );



PROMPT CREATING PRIMARYKEY CONSTRAINT  8 :: T_YarnType

ALTER TABLE T_YarnType
  ADD
   (
	constraint pk_yarntype_yarntypeid PRIMARY KEY(YarnTypeID)
   );



PROMPT CREATING PRIMARYKEY CONSTRAINT  9  ::  T_YarnCount

ALTER TABLE T_YarnCount
  ADD
   (
	constraint pk_yarncount_yarncountid PRIMARY KEY(YarnCountID)
   );

PROMPT CREATING PRIMARYKEY CONSTRAINT  10 ::  T_Designation

ALTER TABLE T_Designation
  ADD
   (
     constraint pk_designation_designationid PRIMARY KEY(DesignationID)
   );

PROMPT CREATING PRIMARYKEY CONSTRAINT  10 ::  T_Employee

ALTER TABLE T_Employee
  ADD
   (
     constraint pk_employee_employeeid PRIMARY KEY(EmployeeID)
   );



PROMPT CREATING PRIMARYKEY CONSTRAINT  11 :: T_WorkOrder

ALTER TABLE T_WorkOrder
  ADD
   (
	constraint pk_workorder_Orderno PRIMARY KEY(OrderNo)
   );

PROMPT CREATING PRIMARYKEY CONSTRAINT  12  ::  T_Basicworkorder

ALTER TABLE T_Basicworkorder
  ADD
    (   
 	constraint pk_basicworkorder PRIMARY KEY(Workorderno, Basictypeid)
    );	

PROMPT CREATING PRIMARYKEY CONSTRAINT  13  ::  T_OrderItems

ALTER TABLE T_OrderItems
  ADD
    (   
 	constraint pk_orderitems_orderlineitem PRIMARY KEY(OrderLineItem)
    );	


PROMPT CREATING PRIMARYKEY CONSTRAINT  14 :: T_FabricType

ALTER TABLE T_FabricType
  ADD
	(
	  constraint pk_fabrictype_fabrictypeid PRIMARY KEY(FABRICTYPEID)
	);


PROMPT CREATING PRIMARYKEY CONSTRAINT  15 :: T_Combination

ALTER TABLE T_Combination
  ADD 
    (
	constraint pk_combination_combinationid PRIMARY KEY(CombinationId)
    );

PROMPT CREATING PRIMARYKEY CONSTRAINT  16 :: T_YarnDesc

ALTER TABLE T_YarnDesc
  ADD 
    (
	constraint pk_YarnDesc_pid PRIMARY KEY(pid)
    );


alter table t_ordertype
ADD
(
	constraint pk_t_ordertype_ordercode PRIMARY KEY(ordercode)
);


ALTER TABLE T_WORKORDER
  ADD 
    (
 	constraint UNIQUE_WORKORDER_BT_DO UNIQUE(DORDERNO,BASICTYPEID)
    );
/

ALTER TABLE T_KNITSTOCK
  ADD 
    (
 	constraint UNIQUE_KNITSTOCK_STOCKID_TNo UNIQUE(STOCKTRANSNO,KNTITRANSACTIONTYPEID)
    );

ALTER TABLE T_YARNREQUISITION
  ADD 
    (
  constraint UNIQUE_KSTOCKREQ_STOCKID_TNo UNIQUE(STOCKTRANSNO,YARNREQUISITIONTYPEID)
    );
//===================Dyes/Chemicals================================================


PROMPT CREATING PRIMARYKEY CONSTRAINT  1 :: T_Auxtype 

ALTER TABLE T_Auxtype
  ADD 
    (
	constraint pk_auxtype_auxtypeid PRIMARY KEY(AuxTypeId)
    );

PROMPT CREATING PRIMARYKEY CONSTRAINT  2 :: T_AuxFor 

ALTER TABLE T_AuxFor
  ADD 
    (
	constraint pk_auxfor_auxforid PRIMARY KEY(AuxForId)
    );


PROMPT CREATING PRIMARYKEY CONSTRAINT  3 :: T_Auxiliaries 

ALTER TABLE T_Auxiliaries
  ADD 
    (
	constraint pk_auxiliaries_auxid PRIMARY KEY(AuxId)
    );


PROMPT CREATING PRIMARYKEY CONSTRAINT  4 :: T_DyeBase 

ALTER TABLE T_DyeBase
  ADD 
    (
	constraint pk_dyeBase_dyeBaseid PRIMARY KEY(DyeBaseId)
    );


PPROMPT CREATING PRIMARYKEY CONSTRAINT  5 :: T_AuxPrice 
ALTER TABLE T_AuxPrice
  ADD 
    (
	constraint pk_auxprice_pid PRIMARY KEY(PID)
    );


//=================habib======================================

PROMPT CREATING PRIMARYKEY CONSTRAINT T_AuxStockType

ALTER TABLE T_AuxStockType
  ADD 
    (
	constraint pk_AuxStockType_AuxStockTypeId PRIMARY KEY(AuxStockTypeId)
    );


PROMPT CREATING PRIMARYKEY CONSTRAINT T_AuxStock

ALTER TABLE T_AuxStock
  ADD 
    (
	constraint pk_AuxStock_AuxStockId PRIMARY KEY(AuxStockId)
    );


PROMPT CREATING PRIMARYKEY CONSTRAINT T_AuxStockItem

ALTER TABLE T_AuxStockItem
  ADD 
    (
	constraint pk_AuxStockItem_PId PRIMARY KEY(PId)
    );

ALTER TABLE T_SUPPLIER 
  ADD 
  (
	CONSTRAINT PK_SUPPLIER_SUPPLIERID PRIMARY KEY (SUPPLIERID)
  );


//=============================For Knitting Machine Parts inventory===========================

ALTER TABLE T_KMCDEPARTMENT 
	ADD
	   (
		CONSTRAINT PK_KMCDEPARTMENT_MCDEPTID PRIMARY KEY (MCDEPTID)
	   );

ALTER TABLE T_KMCPARTSINFO 
	ADD
	   (
		CONSTRAINT PK_KMCPARTSINFO_PARTID PRIMARY KEY (PARTID)   
	   );

ALTER TABLE T_KMCPARTSSTATUS 
	ADD
          (
		CONSTRAINT PK_PARTSSTATUSID PRIMARY KEY (PARTSSTATUSID)
	  );

ALTER TABLE T_KMCPARTSTRAN 
	ADD  
	  (
		CONSTRAINT PK_KMCPARTSTRAN_STOCKID PRIMARY KEY (STOCKID)   
	  );

ALTER TABLE T_KMCSTOCKTYPE 
	ADD  
	  (
		CONSTRAINT PK_KMCSTOCKTYPEID PRIMARY KEY (KMCSTOCKTYPEID)
	  );

ALTER TABLE T_KMCSTOCKSTATUS 
	ADD
	   (
		CONSTRAINT PK_T_KMCSTOCKSTATUS_PID PRIMARY KEY (PID)
	   );

ALTER TABLE T_KNITMACHINEINFO 
	ADD 
	( 
		CONSTRAINT PK_MACHINEID PRIMARY KEY (MACHINEID)
	);
   
ALTER TABLE T_KMCTYPE 
	ADD
	  (
		CONSTRAINT PRI_KMCTYPEID PRIMARY KEY (MCTYPEID)   
	  );

ALTER TABLE T_SPARETYPE 
	ADD
	  (
		CONSTRAINT PK_SPARETYPE_SPARETYPEID PRIMARY KEY (SPARETYPEID)
	  );

ALTER TABLE T_SPARETYPE 
	ADD
	  (
		CONSTRAINT UN_SPARETYPE_SPARETYPE UNIQUE (SPARETYPENAME)
	  );

ALTER TABLE T_STORELOCATION 
	ADD
	 (
		CONSTRAINT PK_LOCATIONID PRIMARY KEY (LOCATIONID)   
	 );

ALTER TABLE T_STORELOCATION 
	ADD  
	 (
		CONSTRAINT UN_STORELOCATION_LOCATION UNIQUE (LOCATION)
	 );

ALTER TABLE T_KMCPARTSTRANSDETAILS 
	ADD  
	  (
		CONSTRAINT PK_KMCPSDETAILS_PID PRIMARY KEY (PID)   
	  );
ALTER TABLE t_kmcpartshistory 
	ADD 
	( 
		CONSTRAINT PK_kmcpartshistory_PID PRIMARY KEY (PID)
	);
//========================For AuxImpLc======================================================

PROMPT alter table T_ImpLcType  
alter table T_ImpLcType 
add (
	constraint pk_T_ImpLcType primary key(LctypeId)
 );


PROMPT alter table T_ImpLCStatus
alter table T_ImpLCStatus
add (
	constraint pk_T_ImpLCStatus primary key(ImpLCStatusId)
);


PROMPT alter table T_AuxImpLC
alter table T_AuxImpLC
add (
	constraint pk_T_AuxImpLC primary key(LCNo)

    );


PROMPT alter table T_AuxImpLCItems
alter table T_AuxImpLCItems
add (
	constraint pk_T_AuxImpLCItems primary key(LCNo,AuxTypeId,AuxId)
);


PROMPT alter table T_LCPayment
alter table T_LCPayment
add (
	constraint pk_T_LCPayment primary key(BasicTypeId,LCNo,LCPayItemSl)
);


PROMPT alter table T_LCInfo
alter table T_LCInfo
add (
	constraint pk_T_LCInfo primary key(BasicTypeId,LCNo)
);


PROMPT alter table T_LCWoLink
alter table T_LCWoLink
add (
	constraint pk_T_LCWolink primary key(BasicTypeId,LCNo,LCItemSl)
);



PROMPT alter table T_LCStatus
alter table T_LCStatus
add (
	constraint pk_T_LCStatus primary key(LCStatusId)
);


PROMPT alter table T_LCBank
alter table T_LCBank
add (
	constraint pk_T_LCBank primary key(BankId)
);

ALTER TABLE T_BASICSUBCONTRACTOR 
  ADD 
  ( 
       CONSTRAINT PK_PID PRIMARY KEY (PID)
  );

//==========================Knit Yarn & Fabric Stock===================================

PROMPT alter table T_KnitStock
alter table T_KnitStock
add (
	constraint pk_T_KnitStock primary key(StockId)
);

PROMPT alter table T_KnitStockItems
alter table T_KnitStockItems
add (
	constraint pk_T_KnitStockItems primary key(PID)
);



PROMPT alter table T_KnitTransactionType
alter table T_KnitTransactionType
add (
	constraint pk_T_KnitTransactionType primary key(KntiTransactionTypeId)
);

//====================Knitting Machine Plane==============================================

ALTER TABLE T_KNITPLAN 
	ADD 
	( 
		CONSTRAINT PK_PLANID PRIMARY KEY (PLANID)
	);
ALTER TABLE T_KNITTINGMERGE 
	ADD 
	( 
		CONSTRAINT PK_MERGEID PRIMARY KEY (MERGEID)
	);

ALTER TABLE T_MCPARTSTYPE 
	ADD 
	( 
		CONSTRAINT PK_MCPTYPE_MCPTYPEID PRIMARY KEY (MCPARTSTYPEID)
	);

ALTER TABLE T_ORDERITEMKNITTINGMERGE 
	ADD 
	( 
		CONSTRAINT PK_MERGE_PID PRIMARY KEY (PID)
	);

ALTER TABLE T_PLANSTATUS ADD 
	( 
		CONSTRAINT PK_PLANSTATUSID PRIMARY KEY (PLANSTATUSID)
	);

ALTER TABLE T_SUBCONTRACTORS 
	ADD 
	( 
		CONSTRAINT PK_SUBCONID PRIMARY KEY (SUBCONID)
	);

ALTER TABLE T_TRANSRPT 
	ADD 
	( 
		CONSTRAINT PK_TRANSRPT_PID PRIMARY KEY (PID)
	);

PROMPT CREATING PRIMARYKEY CONSTRAINT  104 :: T_GWorkOrder

ALTER TABLE T_GWorkOrder
  ADD
   (
	constraint pk_gworkorder_gOrderno PRIMARY KEY(gOrderNo)
   );


PROMPT CREATING PRIMARYKEY CONSTRAINT  105 :: T_GOrderItems

ALTER TABLE T_GOrderItems
  ADD
   (
	constraint pk_GOrderItems_ORDERLINEITEM PRIMARY KEY(ORDERLINEITEM)
   );

PROMPT CREATING PRIMARYKEY CONSTRAINT  106 :: T_GAttachmentRef

ALTER TABLE T_GAttachmentRef
  ADD
   (
	constraint pk_GAttachmentRef_AttachmentID PRIMARY KEY(AttachmentID)
   );


PROMPT CREATING PRIMARYKEY CONSTRAINT  106 :: T_Country

ALTER TABLE T_Country
  ADD
   (
	constraint pk_Country_CountryID PRIMARY KEY(CountryID)
   );


PROMPT CREATING PRIMARYKEY CONSTRAINT  104 :: T_Forms

ALTER TABLE T_Forms
  ADD
   (
	constraint pk_Forms_FormID PRIMARY KEY(FormID)
   );
/



PROMPT CREATING PRIMARYKEY CONSTRAINT  5 :: T_EmpForms

ALTER TABLE T_EmpForms
  ADD 
    (
 	constraint pk_EmpForms PRIMARY KEY(EmployeeID, FormID)
    );
/

ALTER TABLE T_Forms
  ADD
   (
	constraint fk_Forms_EmpId FOREIGN KEY(EmployeeId) 
	references T_Empforms(EmployeeId)
   );

PROMPT CREATING PRIMARYKEY CONSTRAINT  105 :: T_FormGroup 

ALTER TABLE T_FormGroup 
add (
	constraint pk_T_FormGroup primary key(FormGroupId)
);

ALTER TABLE T_CollarCuff
  ADD 
    (
	constraint pk_CollarCuff_CollarCuffId PRIMARY KEY(CollarCuffId)
    );


ALTER TABLE T_OrderItems
  ADD
   (
 	constraint fk_OrderItems_COLLARCUFFID FOREIGN KEY(COLLARCUFFID)
  	references T_CollarCuff(COLLARCUFFID)
   );


alter table t_Gordertype
ADD
(
	constraint pk_t_Gordertype_ordertype PRIMARY KEY(ordertype)
);


ALTER TABLE T_GWORKORDER
ADD
(
	CONSTRAINTS UK_GWORKORDER_GDO_OT UNIQUE(GDORDERNO,ORDERTYPEID)
);
----------------------------------------------------------------------------

PROMPT alter table T_DBatch
alter table T_DBatch
add (
	constraint pk_T_DBatch primary key(DBatchId)
);
ALTER TABLE T_DBATCH
ADD
(
	CONSTRAINTS UK_T_DBATCH_BATCHNO UNIQUE(BATCHNO)
);
PROMPT alter table T_DBatchItems
alter table T_DBatchItems
add (
	constraint pk_T_DBatchItems primary key(PID)
);


PROMPT alter table T_DInvoice
alter table T_DInvoice
add (
	constraint pk_T_DInvoiece primary key(DInvoiceId)
);

PROMPT alter table T_DInvoiceItems
alter table T_DInvoiceItems
add (
	constraint pk_T_DInvoieceItems primary key(PID)
);
-------------------------------------------------------------------------------------

PROMPT alter table : : T_AccGroup

alter table T_AccGroup
add (
	constraint pk_T_AccGroup primary key(GroupID)
);

alter table T_AccSubGroup
add (
	constraint pk_T_AccSubGroup primary key(SubGroupID)
);


alter table T_Accessories
add 
(
	constraint pk_T_Accessories primary key(AccessoriesID)
);


-----------------------------------------------------------------------------------
--For Yarn Requision
-----------------------------------------------------------------------------------
PROMPT alter table T_YarnRequisition
alter table T_YarnRequisition
add (
	constraint pk_T_YarnRequisition primary key(StockId)
);

PROMPT alter table T_YarnRequisitionItems
alter table T_YarnRequisitionItems
add (
	constraint pk_T_YarnRequisitionItems primary key(PID)
);


PROMPT alter table T_YarnRequisitionType
alter table T_YarnRequisitionType
add (
	constraint pk_T_YarnRequisitionType primary key(YarnRequisitionTypeId)
);

PROMPT CREATING PRIMARYKEY CONSTRAINT T_AuxStockTypeRequisition

ALTER TABLE T_AuxStockTypeRequisition
  ADD 
    (
	constraint pk_AuxStockTR_AuxStockTypeId PRIMARY KEY(AuxStockTypeId)
    );


PROMPT CREATING PRIMARYKEY CONSTRAINT T_AuxStockRequisition

ALTER TABLE T_AuxStockRequisition
  ADD 
    (
	constraint pk_AuxStockR_AuxStockId PRIMARY KEY(AuxStockId)
    );


PROMPT CREATING PRIMARYKEY CONSTRAINT T_AuxStockItemRequisition

ALTER TABLE T_AuxStockItemRequisition
  ADD 
    (
	constraint pk_AuxStockItemR_PId PRIMARY KEY(PId)
    );

-----------------------------------------------------------------------------------
--For Aux Stock Requision
-----------------------------------------------------------------------------------

ALTER TABLE t_auxstockRequisition
  ADD
   (
	constraint fk_auxstockR_AUXSTOCKTYPEID FOREIGN KEY(AUXSTOCKTYPEID) 
		references T_AUXSTOCKTYPERequisition(AUXSTOCKTYPEID),
	constraint fk_auxstockR_SUPPLIERID FOREIGN KEY(SUPPLIERID) 
		references T_SUPPLIER(SUPPLIERID)
   );


ALTER TABLE t_auxstockitemRequisition
  ADD
   (
	constraint fk_auxstockitemR_AUXSTOCKID FOREIGN KEY(AUXSTOCKID) 
		references T_AUXSTOCKRequisition(AUXSTOCKID),
	constraint fk_auxstockitemR_AUXTYPEID FOREIGN KEY(AUXTYPEID) 
		references T_AUXTYPE(AUXTYPEID),
	constraint fk_auxstockitemR_AUXID FOREIGN KEY(AUXID) 
		references T_AUXILIARIES(AUXID),
	constraint fk_auxstockitemR_SUPPLIERID FOREIGN KEY(SUPPLIERID) 
		references T_SUPPLIER(SUPPLIERID)
   );

ALTER TABLE T_KMCPARTSTRANRequisition 
	ADD  
	  (
		CONSTRAINT PK_KMCPARTSTRANR_STOCKID PRIMARY KEY (STOCKID)   
	  );

ALTER TABLE T_KMCSTOCKTYPERequisition 
	ADD  
	  (
		CONSTRAINT PK_KMCSTR_KMCSTOCKTYPEID PRIMARY KEY (KMCSTOCKTYPEID)
	  );

ALTER TABLE T_KMCPARTSTRANSDETAILSReq 
	ADD  
	  (
		CONSTRAINT PK_KMCPSDETAILSR_PID PRIMARY KEY (PID)   
	  );

-------------------------------------------------------
--For KMC Parts Stock Requisition
-------------------------------------------------------


ALTER TABLE T_KMCPARTSTRANRequisition
	ADD 
	 (
		CONSTRAINT FK_KMCPARTSTRANR_KmcTypeId FOREIGN KEY (KmcStockTypeID) 
		REFERENCES T_KMCSTOCKTYPERequisition (kMCSTOCKTYPEID)
	 );

ALTER TABLE T_KMCPARTSTRANSDETAILSReq
	ADD 
	 (
		CONSTRAINT FK_KMCPARTSTRANDETR_STOCKID FOREIGN KEY (STOCKID) REFERENCES T_KMCPARTSTRANRequisition (STOCKID),
		CONSTRAINT FK_KMCPARTSTRANDETR_PARTID FOREIGN KEY (PARTID) REFERENCES T_KMCPARTSINFO (PARTID),
		CONSTRAINT FK_KMCPARTSTRANDETR_PTSTID FOREIGN KEY (PARTSSTATUSFROMID) 
			REFERENCES T_KMCPARTSSTATUS (PARTSSTATUSID)
	 );

-------------------------------------------------------
--For Machine Parts Stock Requisition
-------------------------------------------------------
ALTER TABLE T_PROJECT 
	ADD
	   (
		CONSTRAINT PK_T_PROJECT_PROJCODE PRIMARY KEY (PROJCODE)
	   );

ALTER TABLE T_ACCLASS  
	ADD
	   (
		CONSTRAINT PK_T_ACCLASS_CCATACODE PRIMARY KEY (CCATACODE)   
	   );


ALTER TABLE T_TexMCPARTSINFO 
	ADD
	   (
		CONSTRAINT PK_TexMCPARTSINFO_PARTID PRIMARY KEY (PARTID)   
	   );

ALTER TABLE T_TexMcPartsPrice 
	ADD 
	( 
		CONSTRAINT PK_T_TexMcPartsPrice_PID PRIMARY KEY (PID)
	);

ALTER TABLE T_TexMCPARTSSTATUS 
	ADD
          (
		CONSTRAINT PK_TexPARTSSTATUSID PRIMARY KEY (PARTSSTATUSID)
	  );


ALTER TABLE T_TexMCSTOCKTYPE 
	ADD  
	  (
		CONSTRAINT PK_TexMCSTOCKTYPEID PRIMARY KEY (TEXMCSTOCKTYPEID)
	  );

ALTER TABLE T_TexMCSTOCKSTATUS 
	ADD
	   (
		CONSTRAINT PK_TexMCSTOCKSTATUS_PID PRIMARY KEY (PID)
	   );

ALTER TABLE T_TexMcList 
	ADD
	   (
		CONSTRAINT PK_T_TexMcList_McListId PRIMARY KEY (McListId)
	   );

ALTER TABLE T_TexMcStock 
	ADD  
	  (
		CONSTRAINT PK_TexMcStock_STOCKID PRIMARY KEY (STOCKID)   
	  );


ALTER TABLE T_TexMcStockItems
	ADD  
	  (
		CONSTRAINT PK_TexMcStockItems_PID PRIMARY KEY (PID)   
	  );

ALTER TABLE T_TexMCSTOCKTYPEReq
	ADD  
	  (
		CONSTRAINT PK_MCSTTYPER_MCSTOCKTYPEID PRIMARY KEY (TexMCSTOCKTYPEID)
	  );


ALTER TABLE T_TexMcStockReq 
	ADD  
	  (
		CONSTRAINT PK_TexMcStockReq_STOCKID PRIMARY KEY (STOCKID)   
	  );


ALTER TABLE T_TexMcStockItemsReq
	ADD  
	  (
		CONSTRAINT PK_TexMcStockItemsReq_PID PRIMARY KEY (PID)   
	  );


//===============================================================================
//Dyeline
//===============================================================================
PROMPT CREATING PRIMARYKEY CONSTRAINT 1 :: T_DUnitOfMeas

ALTER TABLE T_DUnitOfMeas
  ADD
   (
	constraint pk_Dunitofmeas_unitofmeasid PRIMARY KEY(UnitOfMeasID)
   );

PROMPT CREATING PRIMARYKEY CONSTRAINT 2 :: T_DyelineHead
alter table T_DyelineHead
add (
	constraint pk_T_DyelineHead primary key(HeadId)
);


PROMPT CREATING PRIMARYKEY CONSTRAINT 3 :: T_AuxDyelineHead
alter table T_AuxDyelineHead
add (
	constraint pk_T_AuxDyelineHead primary key(AuxTypeId,AuxId,HeadId)
);



PROMPT CREATING PRIMARYKEY CONSTRAINT 4 :: T_DyelineProfile
alter table T_DyelineProfile
add (
	constraint pk_T_DyelineProfile primary key(HeadId,ProfileId)
);


PROMPT CREATING PRIMARYKEY CONSTRAINT 5 :: T_DProfileItems
alter table T_DProfileItems
add (
	constraint pk_T_DProfileItems primary key(PID)
);


PROMPT CREATING PRIMARYKEY CONSTRAINT 6 :: T_DyelineShift
alter table T_DyelineShift
add (
	constraint pk_T_DyelineShift primary key(ShiftId)
);



PROMPT CREATING PRIMARYKEY CONSTRAINT 7 :: T_Dyeline
alter table T_Dyeline
add (
	constraint pk_T_Dyeline primary key(DyelineId)
);


PROMPT CREATING PRIMARYKEY CONSTRAINT 8 :: T_DSubHeads
alter table T_DSubHeads
add (
	constraint pk_T_DSubHeads primary key(DyelineId,HeadId)
);


PROMPT CREATING PRIMARYKEY CONSTRAINT 9 :: T_DSubItems
alter table T_DSubItems
add (
	constraint pk_T_DSubItems primary key(DSubItemsId)
);


PROMPT CREATING PRIMARYKEY CONSTRAINT 10 :: T_AtoZ
alter table T_AtoZ
add (
	constraint pk_T_AtoZ primary key(AtoZId)
);


PROMPT CREATING PRIMARYKEY CONSTRAINT 11 :: T_DyeMachines
alter table T_DyeMachines
add (
	constraint pk_T_DyeMachines primary key(MachineId)
);



ALTER TABLE T_SHADEGROUP
	ADD 
	( 
		CONSTRAINT PK_SHADEGROUP_SHADEGROUPID PRIMARY KEY (SHADEGROUPID)
	);



//===============================================================================
//Acc
//===============================================================================
PROMPT alter table T_Accessories
alter table T_Accessories
add (
	constraint pk_T_Accessories primary key(ACCESSORIESID)	
);


PROMPT alter table T_AccGroup
alter table T_AccGroup
add (
	constraint pk_T_AccGroup primary key(GROUPID)
);

PROMPT alter table T_Colour
alter table T_Colour
add (
	constraint pk_T_Colour primary key(ColourID)
);



PROMPT CREATING PRIMARYKEY CONSTRAINT  5 :: T_AccPrice 
ALTER TABLE T_AccPrice
  ADD 
    (
	constraint pk_accprice_pid PRIMARY KEY(PID)
    );



PROMPT alter table T_AccRequisitionType
alter table T_AccRequisitionType
add (
	constraint pk_T_AccRequisitionType primary key(AccRequisitionTypeId)
);


PROMPT alter table T_AccRequisition
alter table T_AccRequisition
add (
	constraint pk_T_AccRequisition primary key(RequisitionID)
);

PROMPT alter table T_AccRequisitionItems
alter table T_AccRequisitionItems
add (
	constraint pk_T_AccRequisitionItems primary key(PID)
);



PROMPT alter table T_AccTransactionType
alter table T_AccTransactionType
add (
	constraint pk_T_AccTransactionType primary key(AccTransTypeID)
);


PROMPT alter table T_AccStock
alter table T_AccStock
add (
	constraint pk_T_AccStock primary key(StockId)
);

PROMPT alter table T_AccStockItems
alter table T_AccStockItems
add (
	constraint pk_T_AccStockItems primary key(PID)
);



//====================================================================================
// Exp LC	
//====================================================================================


PROMPT alter table T_LCInfo
alter table T_LCInfo
add (
	constraint pk_T_LCInfo primary key(LCNo)
);


PROMPT alter table T_LCItems
alter table T_LCItems
add (
	constraint pk_T_LCItems primary key(LCItemID)
);

PROMPT alter table T_LCPayment
alter table T_LCPayment
add (
	constraint pk_T_LCPayment primary key(PID)
);

PROMPT alter table T_ExpLCType
alter table T_ExpLCType
add (
	constraint pk_T_ExpLCType primary key(ExpLCTypeID)
);



//====================================================================================
// Imp Lc		
//====================================================================================

PROMPT alter table T_AccImpLC
alter table T_AccImpLC
add (
	constraint pk_T_AccImpLC primary key(LCNo)
);


PROMPT alter table T_AccImpLCItems
alter table T_AccImpLCItems
add (
	constraint pk_T_AccImpLCItems primary key(PID,LCNo,AccessoriesID)
);


PROMPT alter table T_YarnImpLC
alter table T_YarnImpLC
add (
	constraint pk_T_YarnImpLC primary key(LCNo)
);


PROMPT alter table T_YarnImpLCItems
alter table T_YarnImpLCItems
add (
	constraint pk_T_YarnImpLCItems primary key(LCNo,CountID,YarnTypeID)
);


PROMPT alter table T_BTBLCPayment
alter table T_BTBLCPayment
add (
	constraint pk_T_BTBLCPayment primary key(PID)
);


//====================================================================================
// Yarn	
//====================================================================================

PROMPT alter table T_YarnPrice
ALTER TABLE T_YarnPrice
  ADD 
    (
	constraint pk_Yarnrice_pid PRIMARY KEY(PID)
    );

	
	
PROMPT alter table T_YarnPrice // NO NEED NOW
ALTER TABLE T_YarnPrice
  ADD 
    (
	constraint u_T_Yarnrice_typecountbatchSUP unique(YarnTypeID,CountID,YarnBatchNo,PurchaseDate,supplierID)
    );

//====================================================================================
// /*QC Table*/
//====================================================================================


alter table T_QC
add (
	constraint pk_T_Qc primary key(QcId)
);

alter table T_QCItems
add (
	constraint pk_T_QcItems primary key(PID)
);

alter table T_QcStatus
add (
	constraint pk_T_QcStatus primary key(QcStatusID)
);



PROMPT CREATING PRIMARYKEY CONSTRAINT  16 :: T_OrderYarnReq

ALTER TABLE T_OrderYarnReq
  ADD 
    (
	constraint pk_OrderyReq_pid PRIMARY KEY(pid)
    );



//====================================================================================
// Budget
//====================================================================================


PROMPT CREATING PRIMARYKEY CONSTRAINT  1 :: T_Budget
ALTER TABLE T_Budget
  ADD 
    (
	constraint pk_Budget_BudgetID PRIMARY KEY(BudgetID)
    );


PROMPT CREATING PRIMARYKEY CONSTRAINT  2 :: T_FabricConsumption
ALTER TABLE T_FabricConsumption
  ADD 
    (
	constraint pk_FConsumption_PID PRIMARY KEY(PID)
    );


PROMPT CREATING PRIMARYKEY CONSTRAINT  3 :: T_YarnCost
ALTER TABLE T_YarnCost
  ADD 
    (
	constraint pk_YarnCost_PID PRIMARY KEY(PID)
    );

PROMPT CREATING PRIMARYKEY CONSTRAINT  4 :: T_BudgetStages
ALTER TABLE T_BudgetStages
  ADD 
    (
	constraint pk_BudgetStages_StageID PRIMARY KEY(StageID)
    );

PROMPT CREATING PRIMARYKEY CONSTRAINT  5 :: T_KDFCost
ALTER TABLE T_KDFCost
  ADD 
    (
	constraint pk_T_KDFCost_PID PRIMARY KEY(PID)
    );


PROMPT CREATING PRIMARYKEY CONSTRAINT  6 :: T_GarmentsCost
ALTER TABLE T_GarmentsCost
  ADD 
    (
	constraint pk_T_GarmentsCost_PID PRIMARY KEY(PID)
    );

PROMPT CREATING PRIMARYKEY CONSTRAINT  7 :: T_BudgetParameter
ALTER TABLE T_BudgetParameter
  ADD 
    (
	constraint pk_BParameter_paramid PRIMARY KEY(paramid)
    );
PROMPT CREATING PRIMARYKEY CONSTRAINT  8 :: T_BudgetStageParameter
ALTER TABLE T_BudgetStageParameter
  ADD 
    (
	constraint pk_BSParameter_Pid PRIMARY KEY(pid)
    );


PROMPT CREATING PRIMARYKEY CONSTRAINT  9 :: T_SIZE
ALTER TABLE T_SIZE 
	ADD 
	( 
		CONSTRAINT PK_SIZE_SIZEID PRIMARY KEY (SIZEID)
	);


PROMPT CREATING PRIMARYKEY CONSTRAINT  10 ::  T_GORDERSIZE 
ALTER TABLE T_GORDERSIZE 
	ADD 
	( 
		CONSTRAINT PK_GORDERSIZE_GSIZEID PRIMARY KEY (GSIZEID)
	);


ALTER TABLE T_Athurization
  ADD 
    (
	constraint pk_T_Athurization_Pid PRIMARY KEY(pid)
    );
	
PROMPT alter table T_Bill
alter table T_Bill
add (
	constraint pk_T_Bill primary key(ORDERCODE,BillNo)
);



alter table T_BillItems
add (
	constraint pk_T_BillItems primary key(ORDERCODE,BillNo,BillItemSl)
);

PROMPT alter table T_GSampleGatePass
alter table T_GSampleGatePass
add (
	constraint pk_T_GSampleGatePass primary key(GPId)
);


PROMPT alter table T_GSampleGatePassItems
alter table T_GSampleGatePassItems
add (
	constraint pk_T_GSampleGatePassItems primary key(ItemId)
);


PROMPT alter table T_BillPayment
alter table T_BillPayment
add (
	constraint pk_T_BillPayment primary key (ORDERCODE,BillNo,BillPayItemSl),
	constraint fk_T_BillPayment_T_Bill foreign key(ORDERCODE,BillNo) references T_Bill(ORDERCODE,BillNo),
	constraint fk_T_BillPayment_T_WOrder foreign key(OrderNo) references T_WorkOrder(OrderNo)
);

alter table T_KNeedleImpLC
add (
	constraint pk_T_KNeedleImpLC primary key(LCNo)
);
alter table T_KNeedleImpLCItems
add (
	constraint pk_T_KNeedleImpLCItems primary key(PID,LCNo,PartID)
);
ALTER TABLE T_GMCSTOCKTYPE 
	ADD  
	  (
		CONSTRAINT PK_GMCSTOCKTYPEID PRIMARY KEY (TEXMCSTOCKTYPEID)
	  );
ALTER TABLE T_GMCSTOCK
	ADD  
	 (
		CONSTRAINT UN_GMCSTOCK_STOCKID UNIQUE (STOCKID,TEXMCSTOCKTYPEID)   
	 );

ALTER TABLE T_GMcStock 
	ADD  
	  (
		CONSTRAINT PK_GMcStock_STOCKID PRIMARY KEY (STOCKID)   
	  );

ALTER TABLE T_GMcStockItems
	ADD  
	  (
		CONSTRAINT PK_GMcStockItems_PID PRIMARY KEY (PID)   
	  );
	  
ALTER TABLE T_GMCSTOCKTYPEReq
	ADD  
	  (
		CONSTRAINT PK_GMCSTTYPER_MCSTOCKTYPEID PRIMARY KEY (TexMCSTOCKTYPEID)
	  );
	  
ALTER TABLE T_GMcStockReq 
	ADD  
	  (
		CONSTRAINT PK_GMcStockReq_STOCKID PRIMARY KEY (STOCKID)   
	  );
	  
ALTER TABLE T_GMcStockItemsReq
	ADD  
	  (
		CONSTRAINT PK_GMcStockItemsReq_PID PRIMARY KEY (PID)   
	  );

ALTER TABLE T_GMCPARTSINFO 
	ADD
	   (
		CONSTRAINT PK_GMCPARTSINFO_PARTID PRIMARY KEY (PARTID)   
	   );
	   
ALTER TABLE T_GMCPARTSSTATUS 
	ADD
          (
		CONSTRAINT PK_GPARTSSTATUSID PRIMARY KEY (PARTSSTATUSID)
	  );
ALTER TABLE T_GMCSTOCKSTATUS 
	ADD
	   (
		CONSTRAINT PK_GMCSTOCKSTATUS_PID PRIMARY KEY (PID)
	   );
	   
ALTER TABLE T_GMcList 
	ADD
	   (
		CONSTRAINT PK_T_GMcList_McListId PRIMARY KEY (McListId)
	   );
	   
ALTER TABLE T_GMcPartsPrice 
	ADD 
	( 
		CONSTRAINT PK_T_GMcPartsPrice_PID PRIMARY KEY (PID)
	);

	
	
//====================================================================================
// Stationery
//====================================================================================



PROMPT alter table : : T_StationeryGroup
alter table T_StationeryGroup
add (
	constraint pk_T_StationeryGroup primary key(GroupID)
);

alter table T_Stationery
add 
(
	constraint pk_T_Stationery primary key(StationeryID)
);


PROMPT alter table T_StationeryStock
alter table T_StationeryStock
add (
	constraint pk_T_StationeryStock primary key(StockId)
);

PROMPT alter table T_StationeryStockItems
alter table T_StationeryStockItems
add (
	constraint pk_T_StationeryStockItems primary key(PID)
);

PROMPT alter table T_PurchaseReq
alter table T_PurchaseReq
add (
	constraint pk_T_urchaseReq primary key(ReqId)
);

PROMPT alter table T_PurchaseReqItems
alter table T_PurchaseReqItems
add (
	constraint pk_T_PurchaseReqItems primary key(PID)
);

ALTER TABLE T_GMCPurchaseReq 
	ADD  
	  (
		CONSTRAINT PK_T_GMCPurchaseReq_ReqId PRIMARY KEY (ReqId)   
	  );

ALTER TABLE T_GMCPurchaseReqItems
	ADD  
	  (
		CONSTRAINT PK_GMCPurchaseReqItems_PID PRIMARY KEY (PID)   
	  );
	  


alter table T_SQLLOG 
add primary key (Logsequenceid);

alter table T_SQLLOGUPDATE 
add primary key (Logsequenceid);
 
alter table T_UserLogging 
add primary key (UserLoggingId);	

Alter table t_shipmentinfo
add
(
constraints pk_shipmentinfo_pid Primary key(pid)
);

Alter table T_Lcvoucher
add
(
constraints pk_Creditvoucher_pid Primary key(pid)
);

alter table T_MoneyReceipt
add
(
constraint pk_t_moneyrecipt_pid primary key(pid)
);

=================================================Garments==========================================
PROMPT alter table T_GTransactionType
alter table T_GTransactionType
add (
	constraint pk_T_GTransType primary key(GTransactionTypeId)
);

PROMPT alter table T_GStock
alter table T_GStock
add (
	constraint pk_T_GStock primary key(StockId)
);

PROMPT alter table T_GStockItems
alter table T_GStockItems
add (
	constraint pk_T_GStockItems primary key(PID)
);


PROMPT alter table T_GFabricReq
alter table T_GFabricReq
add (
	constraint pk_T_GFabricReq primary key(StockId)
);

PROMPT alter table T_GFabricReqItems
alter table T_GFabricReqItems
add (
	constraint pk_T_GFabricReqItems primary key(PID)
);


PROMPT alter table T_GFabricReqType
alter table T_GFabricReqType
add (
	constraint pk_T_GFabricReqTypeid primary key(GFabricReqTypeId)
);


PROMPT alter table T_GDELIVERYCHALLAN
alter table T_GDELIVERYCHALLAN
add (
	constraint pk_T_Dchallan primary key(Invoiceid)
);


PROMPT alter table T_GDELIVERYCHALLANITEMS
alter table T_GDELIVERYCHALLANItems
add (
	constraint pk_T_DchallanItems primary key(PId)
);


  
Alter Table T_ElectricityBill
add
(
constraints pk_pid_electricitybill Primary key(PID)
);


Alter Table T_ElectricityBill
add
(
constraints fk_pid_electricitybill Foreign key(Customerid) references T_AlliedCustomer(customerid)
);


ALTER TABLE T_MPGroup 
	ADD 
	( 
		CONSTRAINT PK_MPGroup_MPGroupID PRIMARY KEY (MPGroupID)
	);
	
	PROMPT alter table T_GAWorkOrder
alter table T_GAWorkOrder
	add 
	(
		constraint pk_T_GAWorkOrder primary key(OrderNo)
	);

PROMPT alter table T_GAWorkOrderItems
alter table T_GAWorkOrderItems
	add 
	(
		constraint pk_T_GAWorkOrderItems primary key(PID)
	);

	
	PROMPT alter table T_GBill
alter table T_GBill
add (
	constraint pk_T_GBill primary key(ORDERCODE,BillNo)
);
/

PROMPT alter table T_GBillItems
alter table T_GBillItems
add (
	constraint pk_T_GBillItems primary key(ORDERCODE,BillNo,BillItemSl)
);
/

PROMPT alter table T_GBillPayment
alter table T_GBillPayment
add (
	constraint pk_T_GBillPayment primary key (ORDERCODE,BillNo,BillPayItemSl),
	constraint fk_T_GBillPayment_T_GBill foreign key(ORDERCODE,BillNo) references T_GBill(ORDERCODE,BillNo),
	constraint fk_T_GBillPayment_T_WOrder foreign key(GOrderNo) references T_GWorkOrder(GOrderNo)
);
/



 
PROMPT CREATING PRIMARYKEY CONSTRAINT  104 :: T_SCGWORKORDER
   ALTER TABLE T_SCGWORKORDER
   ADD
   (
      CONSTRAINT pk_scgWORKORDER_scgORDERNO PRIMARY KEY(SCGORDERNO)
   );
   
PROMPT CREATING PRIMARYKEY CONSTRAINT  104 :: T_SCGOrderItems
ALTER TABLE T_SCGOrderItems
  ADD
   (
	CONSTRAINT pk_SCGOrderItems_ORDERLINEITEM PRIMARY KEY(ORDERLINEITEM)
   );
    
   ALTER TABLE T_OVERHEADTYPE 
	ADD 
	( 
		CONSTRAINT PK_T_OVERHEADTYPE PRIMARY KEY (OHTYPEID)
	);
	
	
	ALTER TABLE T_KnittingShift
	ADD 
	( 
		CONSTRAINT PK_KShift_SHIFTID PRIMARY KEY (SHIFTID)
	);
	
	ALTER TABLE T_KNITMACHINEINFOITEMS 
	ADD 
	( 
		CONSTRAINT PK_KMINFOITEMS_PID PRIMARY KEY (PID)
	);
	
alter table T_StationeryPrice
add (
	constraint pk_T_StationeryPrice primary key(PID)
);

ALTER TABLE T_GCuttingPartsList
ADD
(   
	constraint pk_GCuttingPartsList_GCPartsID PRIMARY KEY(GCPartsID)
);