alter table T_shipmentinfo
	add constraint fk_shipmentinfo_CURRENCYID foreign key(CURRENCYID) references T_Currency(CURRENCYID);
 ALTER TABLE T_ReportAccess
 ADD 
 (
	CONSTRAINT FK_ReportAccess_ReportId FOREIGN KEY (ReportId) 
	REFERENCES T_ReportList(ReportId),
	CONSTRAINT FK_ReportAccess_EmployeeId FOREIGN KEY (EmployeeId) 
	REFERENCES T_Employee(EmployeeId)
 );
ALTER TABLE T_SCORDERITEMS
  ADD
   (
	constraint fk_SCO_OrderLineItem FOREIGN KEY(OrderLineItem) 
		references T_SCORDERITEMS(OrderLineItem),
	constraint fk_SCO_BASICTYPEID FOREIGN KEY(BASICTYPEID) 
		references T_BASICTYPE(BASICTYPEID),
	constraint fk_SCO_FABRICTYPEID FOREIGN KEY(FABRICTYPEID) 
		references T_FABRICTYPE(FABRICTYPEID),
	constraint fk_SCO_UNITOFMEASID FOREIGN KEY(UNITOFMEASID) 
		references T_UNITOFMEAS(UNITOFMEASID),
	constraint fk_SCO_COLLARCUFFID FOREIGN KEY(COLLARCUFFID) 
		references T_COLLARCUFF(COLLARCUFFID),
	constraint fk_SCO_SHADEGROUPID FOREIGN KEY(SHADEGROUPID) 
		references T_SHADEGROUP(SHADEGROUPID)
   );
ALTER TABLE T_ColourCombination
  ADD
   (
	constraint fk_CC_OrderLineItem FOREIGN KEY(OrderLineItem) 
		references T_SCORDERITEMS(OrderLineItem) ON DELETE CASCADE,
	constraint fk_CC_ColourID FOREIGN KEY(ColourID) 
		references T_Colour(ColourID),
	constraint fk_CC_CUNITOFMEASID FOREIGN KEY(CUNITOFMEASID) 
		references T_UNITOFMEAS(UNITOFMEASID),
	constraint fk_CC_FUNITOFMEASID FOREIGN KEY(FUNITOFMEASID) 
		references T_UNITOFMEAS(UNITOFMEASID)
   );
ALTER TABLE T_ReportList
 ADD CONSTRAINT FK_ReportList_RptGrpId FOREIGN KEY (ReportGroupId) 
	REFERENCES T_ReportGroup(ReportGroupId); 
	
alter table T_SCworkorder
 add constraint fk_SCwo_EMPLOYEEID foreign key (EMPLOYEEID) references T_Employee(EMPLOYEEID); 
ALTER TABLE T_TexMCPARTSINFO 
	ADD 
	(
		CONSTRAINT FK_TexMCPARTSINFO_MPGroupID FOREIGN KEY (MPGroupID) 
			REFERENCES T_MPGroup (MPGroupID),
		CONSTRAINT FK_SCWORKORDER_SUBCONID FOREIGN KEY (SUBCONID) 
			REFERENCES T_SUBCONTRACTORS(SUBCONID)
	);
ALTER TABLE T_TexMcStockItems 
	ADD 
	(
		CONSTRAINT FK_TexMcStockItems_MPGroupID FOREIGN KEY (MPGroupID) 
			REFERENCES T_MPGroup (MPGroupID)
	);
	
	
ALTER TABLE T_TexMcStockItemsReq 
	ADD 
	(
		CONSTRAINT FK_TexMcSItemsReq_GroupID FOREIGN KEY (MPGroupID) 
			REFERENCES T_MPGroup (MPGroupID)
	);

PROMPT CREATING FOREIGNKEY CONSTRAINT 1 :: T_Employee

ALTER TABLE T_Employee
  ADD
   (
	constraint fk_employee_empgroupid FOREIGN KEY(EmpGroupID) 
		references T_EmpGroup(EmpGroupID),
	constraint fk_employee_designationid FOREIGN KEY(DesignationID) 
		references T_Designation(DesignationID)
   );

PROMPT CREATING FOREIGNKEY CONSTRAINT 2 :: T_BasicType

ALTER TABLE T_BasicType
  ADD
   (
	constraint fk_basictyjpe_unitofmeasid FOREIGN KEY(UnitOfMeasID) 
		references T_UnitOfMeas(UnitOfMeasID)
   );


PROMP CREATING FOREIGNKEY CONSTRAINT :: T_BASICWORKORDER
ALTER TABLE T_BASICWORKORDER 
	ADD 
	( 	CONSTRAINT FK_BASICWORDER_WORKORDERNO FOREIGN KEY (WORKORDERNO) 
			REFERENCES T_WORKORDER (ORDERNO) ON DELETE CASCADE,
		CONSTRAINT FK_BASICWROR_BASICTYPEID FOREIGN KEY (BASICTYPEID) 
			REFERENCES T_BASICTYPE (BASICTYPEID)
	);

PROMPT CREATING FOREIGNKEY CONSTRAINT 3 :: T_WorkOrder

ALTER TABLE T_WorkOrder
  ADD
   (
	constraint fk_workorder_basictypeid FOREIGN KEY(BasicTypeID) 
		references T_BasicType(BasicTypeID),
	constraint fk_workorder_clientid FOREIGN KEY(ClientID) 
		references T_Client(ClientID),
	constraint fk_workorder_salestermid FOREIGN KEY(SalesTermID) 
		references T_SalesTerm(SalesTermID),
        constraint fk_workorder_currencyid FOREIGN KEY(CurrencyID) 
		references T_Currency(CurrencyID),
	constraint fk_workorder_salespersonid FOREIGN KEY(SalesPersonID) 
		references T_Employee(EmployeeID),
        constraint fk_workorder_orderstatusid FOREIGN KEY(OrderStatusID) 
		references T_OrderStatus(OrderStatusID)
   );


PROMPT CREATING FOREIGNKEY CONSTRAINT 4 :: T_OrderItems

ALTER TABLE T_OrderItems
  ADD
    (   
	constraint fk_orderitems_orderno FOREIGN KEY(OrderNo) 
		references T_WorkOrder(OrderNo),
	CONSTRAINT fk_orderitems_COMBINATIONID FOREIGN KEY (COMBINATIONID)
		REFERENCES T_COMBINATION(COMBINATIONID),
	constraint fk_orderitems_FABRIC FOREIGN KEY(FabricTypeId) 
		references T_FABRICTYPE(FabricTypeId),
        constraint fk_orderitems_unitofmeas FOREIGN KEY(UnitofmeasID) 
		references T_UnitOfMeas(UnitOfmeasID),
	constraint fk_orderitems_SHADEGROUPID FOREIGN KEY(SHADEGROUPID) 
		references T_SHADEGROUP(SHADEGROUPID)
    );	


PROMPT CREATING FOREIGNKEY CONSTRAINT 5 :: T_YarnDesc

ALTER TABLE T_YarnDesc
  ADD
   (	constraint fk_yarndesc_orderlineitem FOREIGN KEY (OrderLineItem) 
		references T_OrderItems(OrderLineItem) ON DELETE CASCADE,
	constraint fk_yarndesc_yarncountid FOREIGN KEY (YarnCountID) 
		references T_YarnCount(YarnCountID),
	constraint fk_yarndesc_yarntypeid FOREIGN KEY (YarnTypeID) 
		references T_YarnType(YarnTypeID)
   );

ALTER TABLE T_SCYarnDesc
ADD
(constraint fk_SCyarndesc_orderlineitem FOREIGN KEY (OrderLineItem)
	references T_SCOrderItems(OrderLineItem) ON DELETE CASCADE,
constraint fk_SCyarndesc_yarncountid FOREIGN KEY (YarnCountID)
	references T_YarnCount(YarnCountID),
constraint fk_SCyarndesc_yarntypeid FOREIGN KEY (YarnTypeID)
	references T_YarnType(YarnTypeID)
);
//===========================Dyes/Chemicals==================

PROMPT CREATING FOREIGNKEY CONSTRAINT 1 :: T_Auxiliaries

ALTER TABLE T_Auxiliaries
  ADD
	(
	  constraint fk_auxiliaries_auxtypeid FOREIGN KEY(AuxTypeId)
		references T_AuxType(AuxTypeId),
	  constraint fk_auxiliaries_auxforid FOREIGN KEY(AuxForID)
		references T_AuxFor(AuxForId),
	  constraint fk_auxiliaries_dyebaseid FOREIGN KEY(DyeBaseID)
		references T_DyeBase(DyeBaseID),
	  constraint fk_auxiliaries_unitofmeasid FOREIGN KEY(UnitOfMeasID)
		references T_UnitOfMeas(UnitOfMeasID)
	);


PROMPT CREATING FOREIGNKEY CONSTRAINT 1 :: T_AuxPrice

ALTER TABLE T_AuxPrice
  ADD
	(
	  constraint fk_auxprice_auxtypeid FOREIGN KEY(AuxTypeId)
		references T_AuxType(AuxTypeId),
	  constraint fk_auxprice_auxid FOREIGN KEY(AuxID)
		references T_Auxiliaries(AuxId)
	);



//==================habib================================


ALTER TABLE t_auxstock
  ADD
   (
	constraint fk_auxstock_AUXSTOCKTYPEID FOREIGN KEY(AUXSTOCKTYPEID) 
		references T_AUXSTOCKTYPE(AUXSTOCKTYPEID),
	constraint fk_auxstock_SUPPLIERID FOREIGN KEY(SUPPLIERID) 
		references T_SUPPLIER(SUPPLIERID),
	constraint fk_auxstock_CURRENCYID FOREIGN KEY(CURRENCYID) 
		references T_CURRENCY(CURRENCYID)
   );


ALTER TABLE t_auxstockitem
  ADD
   (
	constraint fk_auxstockitem_AUXSTOCKID FOREIGN KEY(AUXSTOCKID) 
		references T_AUXSTOCK(AUXSTOCKID),
	constraint fk_auxstockitem_AUXTYPEID FOREIGN KEY(AUXTYPEID) 
		references T_AUXTYPE(AUXTYPEID),
	constraint fk_auxstockitem_AUXID FOREIGN KEY(AUXID) 
		references T_AUXILIARIES(AUXID),
	constraint fk_auxstockitem_SUPPLIERID FOREIGN KEY(SUPPLIERID) 
		references T_SUPPLIER(SUPPLIERID)
   );

//=================================For Knitting Machine Parts Inventory===================

ALTER TABLE T_STORELOCATION 
	ADD  
	 (
		CONSTRAINT UN_STORELOCATION_LOCATION UNIQUE (LOCATION)   
	 );

ALTER TABLE T_KMCPARTSINFO 
	ADD 
	 (
		CONSTRAINT FK_KMCPARTSINFO_MCTYPEID FOREIGN KEY (MCTYPEID) REFERENCES T_KMCTYPE (MCTYPEID)
	 );

ALTER TABLE T_KMCPARTSINFO 
	ADD 
	 (
		CONSTRAINT FK_KMCPARTSINFO_UNITOFMEASID FOREIGN KEY (UNITOFMEASID) REFERENCES T_UNITOFMEAS (UNITOFMEASID)
	 );

ALTER TABLE T_KMCPARTSINFO 
	ADD 
	 (
		CONSTRAINT FK_KMCPARTSINFO_SPARETYPEID FOREIGN KEY (SPARETYPEID) REFERENCES T_SPARETYPE (SPARETYPEID)
	 );

ALTER TABLE T_KMCPARTSINFO 
	ADD 
	 (
		CONSTRAINT FK_KMCPARTSINFO_KMCDEPTID FOREIGN KEY (KMCDEPARTMENTID) REFERENCES T_KMCDEPARTMENT (MCDEPTID)
	 );


ALTER TABLE T_KMCPARTSINFO 
	ADD 
	( 
		CONSTRAINT FK_KMCPARTSINFO_DEPARTMENTID FOREIGN KEY (KMCDEPARTMENTID) 
			REFERENCES T_KMCDEPARTMENT (KMCDEPARTMENTID),
		CONSTRAINT FK_KMCPARTSINFO_LOCAITONID FOREIGN KEY (LOCATIONID) 
			REFERENCES T_STORELOCATION (LOCATIONID),
		CONSTRAINT FK_KMCPARTSINFO_MCTYPEID FOREIGN KEY (MCTYPEID) 
			REFERENCES T_KMCTYPE (MCTYPEID),
		CONSTRAINT FK_KMCPARTSINFO_SPARETYPEID FOREIGN KEY (SPARETYPEID) 
			REFERENCES T_SPARETYPE (SPARETYPEID),
		CONSTRAINT FK_KMCPARTSINFO_UNITOFMEASID FOREIGN KEY (UNITOFMEASID) 
			REFERENCES T_UNITOFMEAS (UNITOFMEASID)
	);


ALTER TABLE T_KMCPARTSTRAN
	ADD 
	 (
		CONSTRAINT FK_KMCPARTSTRAN_KmcTypeId FOREIGN KEY (KmcStockTypeID) 
			REFERENCES T_KMCSTOCKTYPE (kMCSTOCKTYPEID),
		CONSTRAINT FK_KMCPARTSTRANDET_CURRENCYID FOREIGN KEY (CURRENCYID) 
			REFERENCES t_currency (CURRENCYID)
	 );

ALTER TABLE T_KMCPARTSTRANSDETAILS 
	ADD 
	 (
		CONSTRAINT FK_KMCPARTSTRANDET_STOCKID FOREIGN KEY (STOCKID) REFERENCES T_KMCPARTSTRAN (STOCKID),
		CONSTRAINT FK_KMCPARTSTRANDET_PARTID FOREIGN KEY (PARTID) REFERENCES T_KMCPARTSINFO (PARTID),
		CONSTRAINT FK_KMCPARTSTRANDET_PTSTID FOREIGN KEY (PARTSSTATUSFROMID) 
			REFERENCES T_KMCPARTSSTATUS (PARTSSTATUSID)
	 );




//=====================Knit Yarn & Fabric Stock==============================================

PROMPT alter table T_KnitStock
alter table T_KnitStock
	add 
	(
		constraint fk_T_KnitStock_knitTrantypeid foreign key(KntiTransactionTypeId) references 			T_KnitTransactionType(KntiTransactionTypeId),
		constraint fk_T_KnitStock_subconid foreign key(SubConId) references T_Subcontractors(SubConId),
		constraint fk_KnitStock_SUPPLIERID FOREIGN KEY(SUPPLIERID) 
		references T_SUPPLIER(SUPPLIERID)
	);

PROMPT alter table T_KnitStockItems
alter table T_KnitStockItems
	add 
	(
	constraint fk_T_KnitStockItems_Stockid foreign key(StockId) references T_KnitStock(StockId),
	constraint fk_T_KnitStockItems_Ycid foreign key(YarnCountId) references T_YarnCount(YarnCountId),
	constraint fk_T_KnitStockItems_YtId foreign key(YarnTypeId) references T_YarnType(YarnTypeId),
	constraint fk_T_KnitStockItems_Ftid foreign key(FabricTypeId) references T_FabricType(FabricTypeId),
	constraint fk_T_KnitStockItems_punitid FOREIGN KEY(PUnitOfMeasID) references T_UnitOfMeas(UnitOfMeasID),
	constraint fk_T_KnitStockItems_sunitid FOREIGN KEY(SUnitOfMeasID) references T_UnitOfMeas(UnitOfMeasID),
	constraint fk_KnitStockItems_SUPPLIERID FOREIGN KEY(SUPPLIERID) references T_SUPPLIER(SUPPLIERID),
	constraint fk_KnitStockItems_SUBCONID FOREIGN KEY(SUBCONID) references T_SUBCONTRACTORS(SUBCONID),
	constraint fk_KNITSTOCKItems_SHADEGROUPID FOREIGN KEY(SHADEGROUPID)  references T_SHADEGROUP(SHADEGROUPID),
	constraint fk_T_KnitStockItems_MACHINEID foreign key(MACHINEID) references T_KNITMACHINEINFO(MACHINEID),
	constraint fk_KSI_KMPIDREF FOREIGN KEY(KMACHINEPIDREF) references T_KNITMACHINEINFOITEMS(PID)
	);

//================AuxImpLc==============================================================================

Alter Table T_AuxImpLc
	add
	(
	constraint fk_T_AuxImpLC_T_ImpLcType foreign key(LCTypeId) references T_ImpLcType(LCTypeId),
	constraint fk_T_AuxImpLC_T_Currency foreign key(CurrencyID) references T_Currency(CurrencyId),
	constraint fk_T_AuxImpLC_T_ImpLCStatus foreign key(IMPLCSTATUSID) references T_ImpLCStatus(IMPLCSTATUSID)
	);

Alter table T_AuxImpLcItems
	add
	(
		constraint fk_T_AuxImpLCItems_T_AuxImpLC foreign key(LCNo) references T_AuxImpLC(LCNo),
		constraint fk_T_AuxImpLCItems_T_Auxiliary foreign key(AuxTypeId) references T_Auxiliaries(AuxTypeId),
		constraint fk_T_AuxImpLCItems_T_Auxiliary foreign key(AuxId) references T_Auxiliaries(AuxId)
	);

Alter table T_LCPayment
	add
	(
		constraint fk_T_LCPayment_T_LCInfo foreign key(BasicTypeId,LCNo) references T_LcInfo(BasicTypeId,LCNo),
		constraint fk_T_LCPayment_T_WOrder foreign key(OrderNo) references t_workorder(OrderNo)
	);


alter table T_LCInfo
add 
( 
	constraint fk_T_LCInfo_T_BasicType foreign key(BasicTypeId) references T_BasicType(BasicTypeId),
	constraint fk_T_LCInfo_T_Client foreign key(ClientID) references T_Client(ClientId),
	constraint fk_T_LCInfo_T_Currency foreign key(CurrencyID) references T_Currency(CurrencyId),
	constraint fk_T_LCInfo_T_LCStatus foreign key(LCStatusID) references T_LCStatus(LCStatusId),
	constraint fk_T_LCInfo_T_LCBank foreign key(BankId) references T_LCBank(BankId)
);

Alter table T_LCWolink
	add
	(
		constraint fk_T_LCWolink_T_LCInfo foreign key(BasicTypeId,LCNo) 
			references T_LcInfo(BasicTypeId,LCNo),
		constraint fk_T_LCWolink_T_WOrder foreign key(OrderNo) 
			references T_WOrkOrder(OrderNo)
	);

ALTER TABLE T_BASICSUBCONTRACTOR 
	ADD 
	( 
		CONSTRAINT FK_BASICCONTRACTOR_BASICTYPEID FOREIGN KEY (BASICTYPEID) 
			REFERENCES T_BASICTYPE (BASICTYPEID),
		CONSTRAINT FK_BASICSUBCONTRACTOR_SUBCONID FOREIGN KEY (SUBCONID) 
			REFERENCES T_SUBCONTRACTORS (SUBCONID)
	);

//========================kNTTING STOCK====================================================

ALTER TABLE T_KNITMACHINEINFO 
	ADD 
	( 
		CONSTRAINT FK_KMACHINEINFO_FABRICTYPEID FOREIGN KEY (FABRICTYPEID) 
			REFERENCES T_FABRICTYPE (FABRICTYPEID),
		CONSTRAINT FK_KNITMACHINEINFO_MCTYPEID FOREIGN KEY (MCTYPEID) 
			REFERENCES T_KMCTYPE (MCTYPEID)
	);


PROMPT CREATING FOREIGNKEY CONSTRAINT 3 :: T_GWorkOrder

ALTER TABLE T_GWorkOrder
  ADD
   (
	constraint fk_Gworkorder_clientid FOREIGN KEY(ClientID) 
		references T_Client(ClientID),
	constraint fk_Gworkorder_salestermid FOREIGN KEY(SalesTermID) 
		references T_SalesTerm(SalesTermID),
        constraint fk_Gworkorder_currencyid FOREIGN KEY(CurrencyID) 
		references T_Currency(CurrencyID),
	constraint fk_Gworkorder_salespersonid FOREIGN KEY(SalesPersonID) 
		references T_Employee(EmployeeID),
        constraint fk_Gworkorder_orderstatusid FOREIGN KEY(OrderStatusID) 
		references T_OrderStatus(OrderStatusID)
   );


PROMPT CREATING FOREIGNKEY CONSTRAINT 4 :: T_GOrderItems

ALTER TABLE T_GOrderItems
  ADD
    (
	constraint fk_Gorderitems_orderno FOREIGN KEY(GOrderNo)
		references T_GWorkOrder(GOrderNo),
	constraint fk_Gorderitems_CountryID FOREIGN KEY(CountryID)
		references T_Country(CountryID),
	constraint fk_Gorderitems_unitofmeas FOREIGN KEY(UnitofmeasID)
		references T_UnitOfMeas(UnitOfmeasID)
    );

ALTER TABLE T_WorkOrder
  ADD
   (
 	constraint fk_workorder_GARMENTSORDERREF FOREIGN KEY(GARMENTSORDERREF)
  	references t_gworkorder(GORDERNO)
   );



---------------------------------------------------------------------------------------------
Alter Table T_Dinvoice
add
(
	constraint fk_Dinvoice_clientid FOREIGN KEY(ClientID) 
		references T_Client(ClientID)
);


----------------------------------------------------------------------------------------------

ALTER TABLE T_AccSubGroup
  ADD
	(
	  constraint fk_T_AccSubGroup_groupid FOREIGN KEY(GroupId)
		references T_AccGroup(GroupId)
	);

ALTER TABLE T_Accessories
  ADD
	(
	  constraint fk_Accessories_groupid FOREIGN KEY(GroupId)
		references T_AccGroup(GroupId),
	  constraint fk_Accessories_subgroupid FOREIGN KEY(Subgroupid)
		references T_AccSubGroup(Subgroupid),
	  constraint fk_Accessories_unitofmeasid FOREIGN KEY(UnitOfMeasID)
		references T_UnitOfMeas(UnitOfMeasID)
	);


-------------------------------------------------------------------------------------------------
--For Yarn Requisition
-------------------------------------------------------------------------------------------------

PROMPT alter table T_YarnRequisition
alter table T_YarnRequisition
	add 
	(
		constraint fk_T_YarnReq_YarnTranTypeid foreign key(YarnRequisitionTypeId) 
                references T_YarnRequisitionType(YarnRequisitionTypeId)
		constraint fk_T_YarnReq_subconid foreign key(SubConId) references T_Subcontractors(SubConId),
		constraint fk_T_YarnReq_SUPPLIERID FOREIGN KEY(SUPPLIERID) 
		references T_SUPPLIER(SUPPLIERID)
	);

PROMPT alter table T_YarnRequisitionItems
alter table T_YarnRequisitionItems
	add 
	(
	constraint fk_T_YarnReqItems_Stockid foreign key(StockId) references T_KnitStock(StockId),
	constraint fk_T_YarnReqItems_Ycid foreign key(YarnCountId) references T_YarnCount(YarnCountId),
	constraint fk_T_YarnReqItems_YtId foreign key(YarnTypeId) references T_YarnType(YarnTypeId),
	constraint fk_T_YarnReqItems_Ftid foreign key(FabricTypeId) references T_FabricType(FabricTypeId),
	constraint fk_T_YarnReqItems_punitid FOREIGN KEY(PUnitOfMeasID) references T_UnitOfMeas(UnitOfMeasID),
	constraint fk_T_YarnReqItems_sunitid FOREIGN KEY(SUnitOfMeasID) references T_UnitOfMeas(UnitOfMeasID),
	constraint fk_T_YarnReqItems_SUPPLIERID FOREIGN KEY(SUPPLIERID) references T_SUPPLIER(SUPPLIERID)
	);



-------------------------------------------------------------------------------------------------
--For Machine Parts
-------------------------------------------------------------------------------------------------
PROMPT CREATING FOREIGNKEY CONSTRAINT 1 :: T_TexMCPARTSINFO
ALTER TABLE T_TexMCPARTSINFO 
	ADD 
	(
		CONSTRAINT FK_TexMCPARTSINFO_UNITOFMEASID FOREIGN KEY (UNITOFMEASID) 
			REFERENCES T_UNITOFMEAS (UNITOFMEASID),
		CONSTRAINT FK_TexMCPARTSINFO_PROJCODE FOREIGN KEY (PROJCODE) 
			REFERENCES T_PROJECT(PROJCODE),
		CONSTRAINT FK_TexMCPARTSINFO_CCATACODE FOREIGN KEY (CCATACODE) 
			REFERENCES T_ACCLASS(CCATACODE)
	);

PROMPT CREATING FOREIGNKEY CONSTRAINT 2 :: T_TexMcPartsPrice 
ALTER TABLE T_TexMcPartsPrice 
	ADD 
	( 
		CONSTRAINT FK_T_TexMcPartsPrice_PARTID FOREIGN KEY (PARTID) 
			REFERENCES T_TexMCPARTSINFO(PARTID)
	);

PROMPT CREATING FOREIGNKEY CONSTRAINT 3 :: T_TexMcStock
ALTER TABLE T_TexMcStock
	ADD 
	( 
		CONSTRAINT FK_TexMcStock_TexMCSTOCKTYPEID FOREIGN KEY (TexMCSTOCKTYPEID) 
			REFERENCES T_TexMCSTOCKTYPE(TexMCSTOCKTYPEID),
		CONSTRAINT FK_TexMcStock_CURRENCYID FOREIGN KEY (CURRENCYID) 
			REFERENCES t_currency (CURRENCYID)
	);

PROMPT CREATING FOREIGNKEY CONSTRAINT 4 :: T_TexMcStockItems
ALTER TABLE T_TexMcStockItems
	ADD 
	 (
		CONSTRAINT FK_TexMcStockItems_STOCKID FOREIGN KEY (STOCKID) 
			REFERENCES T_TexMcStock (STOCKID),
		CONSTRAINT FK_TexMcStockItems_PARTID FOREIGN KEY (PARTID) 
			REFERENCES T_TexMCPARTSINFO (PARTID),
		CONSTRAINT FK_TexMcStockItems_PTSTID FOREIGN KEY (PARTSSTATUSFROMID) 
			REFERENCES T_TexMCPARTSSTATUS (PARTSSTATUSID)
	 );



PROMPT CREATING FOREIGNKEY CONSTRAINT 5 :: T_TexMcStockReq
ALTER TABLE T_TexMcStockReq
	ADD 
	 (
		CONSTRAINT FK_McStockR_MCSTOCKTYPEID FOREIGN KEY (TexMCSTOCKTYPEID) 
		REFERENCES T_TexMCSTOCKTYPEReq(TexMCSTOCKTYPEID)
	 );

PROMPT CREATING FOREIGNKEY CONSTRAINT 6 :: T_TexMcStockReq
ALTER TABLE T_TexMcStockItemsReq
	ADD 
	 (
		CONSTRAINT FK_TexMcStockItemsR_STOCKID FOREIGN KEY (STOCKID) 
			REFERENCES T_TexMcStockReq (STOCKID),
		CONSTRAINT FK_TexMcStockItemsR_PARTID FOREIGN KEY (PARTID) 
			REFERENCES T_TexMcPartsInfo(PARTID)
	 );
//=================================Dyeline =================================================================
PROMPT CREATING FOREIGNKEY CONSTRAINT 1 :: T_DyelineHead
alter table T_DyelineHead
add (
	constraint fk_T_DyelineHead_T_AuxType foreign key(AuxTypeId) 
		references T_AuxType(AuxTypeId)
);


PROMPT CREATING FOREIGNKEY CONSTRAINT 2 :: T_AuxDyelineHead
alter table T_AuxDyelineHead
add (
	constraint fk_T_AuxDyelineHead_T_DyelineH foreign key(HeadId) 
		references T_DyelineHead(HeadId),
 	constraint fk_T_AuxDyelineHead_AuxTypeId foreign key(AuxTypeId) 
  		references T_AuxType(AuxTypeId),
 	constraint fk_T_AuxDyelineHead_AuxId foreign key(AuxId) 
  		references T_Auxiliaries(AuxId)
);


PROMPT CREATING FOREIGNKEY CONSTRAINT 3 :: T_DyelineProfile
alter table T_DyelineProfile
add (
	constraint fk_T_DyelineProfile_T_DyelineH  foreign key(HeadId) 
		references T_DyelineHead(HeadId),
	constraint fk_T_DyelineProfile_T_AtoZ foreign key(ProfileId) 
		references T_AtoZ(AtoZId)
);


PROMPT CREATING FOREIGNKEY CONSTRAINT 4 :: T_DProfileItems
alter table T_DProfileItems
add (
	constraint fk_T_DProfileItems_T_DyelinePr foreign key(HeadId,ProfileId) 
		references T_DyelineProfile(HeadId,ProfileId), 
	constraint fk_T_DProfileItems_AuxId foreign key(AuxId) 
		references T_Auxiliaries(AuxId),
	constraint fk_T_DProfileItems_AuxTypeId foreign key(AuxTypeId) 
		references T_AuxType(AuxTypeId)
);


PROMPT CREATING FOREIGNKEY CONSTRAINT 5 :: T_DyelineShift
alter table T_DyelineShift
add (
	constraint fk_T_DyelineShift_T_AtoZ foreign key(ShiftId) 
		references T_AtoZ(AtoZId)
);



PROMPT CREATING FOREIGNKEY CONSTRAINT 6 :: T_Dyeline

alter table T_Dyeline
add (
	constraint fk_T_Dyeline_ShiftId foreign key(DyeingShift) 
		references T_DyelineShift(ShiftId),
	constraint fk_T_Dyeline_BatchID foreign key(DBatchID) 
		references T_DBatch(DBatchID),
	constraint fk_T_Dyeline_MachineId foreign key(MachineId) 
		references T_DyeMachines(MachineId)
);



PROMPT CREATING FOREIGNKEY CONSTRAINT 7 :: T_DSubHeads
alter table T_DSubHeads
add (
	constraint fk_T_DSubHeads_T_Dyeline foreign key(DyelineId) 
		references T_Dyeline(DyelineId),
	constraint fk_T_DSubHeads_T_DyelineHead foreign key(HeadId) 
		references T_DyelineHead(HeadId)
);

PROMPT CREATING FOREIGNKEY CONSTRAINT 8 :: T_DSubItems
alter table T_DSubItems
add (
	constraint fk_T_DSubItems_T_DSubHeads foreign key(DyelineId,HeadId) 
		references T_DSubHeads(DyelineId,HeadId),
	constraint fk_T_DSubItems_AuxId foreign key(AuxId) 
		references T_Auxiliaries(AuxId),
	constraint fk_T_DSubItems_AuxTypeId foreign key(AuxTypeId) 
		references T_AuxType(AuxTypeId),
	constraint fk_T_DSubItems_UnitOfMeasID foreign key(UnitOfMeasID) 
		references T_UnitOfMeas(UnitOfMeasID)
);
//=================================Acc ======================================================
Alter table T_Accessories
add
(
	constraint fk_T_Accessories_T_AccGroup foreign key(GROUPID) references T_AccGroup(GROUPID)	
);


ALTER TABLE T_AccPrice
ADD
(	  
	  constraint fk_accprice_refpid FOREIGN KEY(REFPID) references T_ACCSTOCKITEMS(PID),
          constraint fk_accprice_accid FOREIGN KEY(AccessoriesID) references T_Accessories(AccessoriesID)
);


Alter table T_AccRequisition
add
(
	constraint fk_T_AccReq_T_AccReqType foreign key(AccRequisitionTypeId) references T_AccRequisitionType(AccRequisitionTypeId)	
);
Alter Table T_AccRequisitionItems
add
(
	constraint fk_T_AccReqItems_T_AccReq foreign key(RequisitionID) references T_AccRequisition(RequisitionID),	
	constraint fk_T_AccReqItems_T_Acc foreign key(AccessoriesID) references T_Accessories(AccessoriesID),
	constraint fk_T_AccReqItems_T_PUOM foreign key(PunitOfMeasId) references T_UnitOfMeas(UnitOfMeasID),
	constraint fk_T_AccReqItems_T_SUOM foreign key(SunitOfMeasId) references T_UnitOfMeas(UnitOfMeasID)
);



Alter table T_AccStock
add
(
	constraint fk_T_AccStock_T_AccTransType foreign key(AccTransTypeID) references T_AccTransactionType(AccTransTypeID)	
);
Alter Table T_AccStockItems
add
(
	constraint fk_T_AccStockItems_T_AccStock foreign key(StockID) references T_AccStock(StockID),	
	constraint fk_T_AccStockItems_T_Acc foreign key(AccessoriesID) references T_Accessories(AccessoriesID),
	constraint fk_T_AccStockItems_T_PUOM foreign key(PunitOfMeasId) references T_UnitOfMeas(UnitOfMeasID),
	constraint fk_T_AccStockItems_T_SUOM foreign key(SunitOfMeasId) references T_UnitOfMeas(UnitOfMeasID)
);


//====================================================================================
// Exp LC	
//====================================================================================


alter table T_LCInfo
add 
( 
	constraint fk_T_LCInfo_T_Client foreign key(ClientID) references T_Client(ClientId),
	constraint fk_T_LCInfo_T_Currency foreign key(CurrencyID) references T_Currency(CurrencyId),
	constraint fk_T_LCInfo_T_ExpLCType foreign key(ExpLCTypeID) references T_ExpLCType(ExpLCTypeID)        	
);


Alter table T_LCItems
add
(
	constraint fk_T_LCItems_T_LCInfo foreign key(LCNo) references T_LcInfo(LCNo),
	constraint fk_T_LCItems_T_GWorkOrder foreign key(OrderNo) references T_GWOrkOrder(GOrderNo)
);


Alter table T_LCPayment
add
(
	constraint fk_T_LCPayment_T_LCInfo foreign key(LCNo) references T_LcInfo(LCNo),
	constraint fk_T_LCPayment_T_LCStatus foreign key(LCStatusID) references T_LCStatus(LCStatusID)	
);




//====================================================================================
// Imp Lc		
//====================================================================================


Alter Table T_AccImpLC
add
(
	constraint fk_T_AccImpLC_T_ImpLcType foreign key(IMPLCTypeId) references T_ImpLcType(IMPLCTYPEID),
	constraint fk_T_AccImpLC_T_Currency foreign key(CurrencyID) references T_Currency(CurrencyId),
	constraint fk_T_AccImpLC_T_ImpLCStatus foreign key(IMPLCSTATUSID) references T_ImpLCStatus(IMPLCSTATUSID)
);

Alter table T_AccImpLcItems
add
(
	constraint fk_T_AccImpLCItems_T_AccImpLC foreign key(LCNo) references T_AccImpLC(LCNo),
	constraint fk_T_AccImpLCItems_T_Acc foreign key(AccessoriesID) references T_Accessories(AccessoriesID)
);


Alter Table T_YarnImpLC
add
(
	constraint fk_T_YarnImpLC_T_ImpLcType foreign key(IMPLCTypeId) references T_ImpLcType(IMPLCTYPEID),
	constraint fk_T_YarnImpLC_T_Currency foreign key(CurrencyID) references T_Currency(CurrencyId),
	constraint fk_T_YarnImpLC_T_ImpLCStatus foreign key(IMPLCSTATUSID) references T_ImpLCStatus(IMPLCSTATUSID)
);

Alter table T_YarnImpLcItems
add
(
		constraint fk_T_YarnImpLCItems_YarnImpLC foreign key(LCNo) references T_YarnImpLC(LCNo),
		constraint fk_T_YarnImpLCItems_YarnType foreign key(YarnTypeID) references T_YarnType(YarnTypeId),
		constraint fk_T_YarnImpLCItems_YarnCount foreign key(CountID) references T_YarnCount(YarnCountID)
);




//====================================================================================
// Qc	
//====================================================================================

ALTER TABLE T_QcItems 
ADD
(
	CONSTRAINT FK_T_QcItems_QcId FOREIGN KEY (QcId)
	REFERENCES T_Qc (QcId)
);

ALTER TABLE T_QcItems 
ADD
(
	CONSTRAINT FK_T_QcItems_QcStatusId FOREIGN KEY (QcStatusId)
	REFERENCES T_QcStatus(QcStatusId)
);


ALTER TABLE T_QcItems 
ADD
(
	CONSTRAINT FK_T_QcItems_DBatchId FOREIGN KEY (DBatchId)
	REFERENCES T_DBatch(DBatchId)
);


//====================================================================================
// Acc		
//====================================================================================
PROMPT CREATING FOREIGNKEY CONSTRAINT 5 :: T_OrderYarnReq

ALTER TABLE T_OrderYarnReq
  ADD
   (
	constraint fk_OrderyReq_orderno FOREIGN KEY (Orderno) 
		references T_Workorder(Orderno ),
	constraint fk_OrderyReq_yarncountid FOREIGN KEY (YarnCountID) 
		references T_YarnCount(YarnCountID),
	constraint fk_OrderyReq_yarntypeid FOREIGN KEY (YarnTypeID) 
		references T_YarnType(YarnTypeID)
   );



//====================================================================================
// Budget
//====================================================================================




PROMPT CREATING ForeignKEY CONSTRAINT  1 :: T_FabricConsumption

ALTER TABLE T_FabricConsumption
  ADD 
    (
	constraint fk_FConsumption_BudgetID FOREIGN KEY(BudgetID) 
		references T_Budget(BudgetID),
	constraint fk_FConsumption_ftypeID FOREIGN KEY(FABRICTYPEID) 
		references T_Fabrictype(FABRICTYPEID),
	constraint fk_FConsumption_YtypeID FOREIGN KEY(YARNTYPEID) 
		references T_yarntype(YARNTYPEID)	
    );


PROMPT CREATING FOREIGNKEY CONSTRAINT  2 :: T_YarnCost

ALTER TABLE T_YarnCost
  ADD 
    (
	constraint fk_YarnCost_BudgetID FOREIGN KEY(BudgetID) 
		references T_Budget(BudgetID),
constraint fk_yarncost_YtypeID FOREIGN KEY(YARNTYPEID) 
		references T_yarntype(YARNTYPEID),
constraint fk_FConsumption_YcountID FOREIGN KEY(YARNCOUNTID) 
		references T_yarncount(YARNCOUNTID),
constraint fk_YarnCost_ppID FOREIGN KEY(ppID) 
		references T_Fabricconsumption(PID)
    );

PROMPT CREATING PRIMARYKEY CONSTRAINT  3 :: T_KDFCost
ALTER TABLE T_KDFCost
  ADD 
    (
	constraint fk_KDFCost_BudgetID FOREIGN KEY(BudgetID) 
		references T_Budget(BudgetID),
	constraint fk_KDFCost_StageID FOREIGN KEY(StageID) 
		references T_BudgetStages(StageID),
	constraint fk_KDFCost_ParamID FOREIGN KEY(ParamID) 
		references T_BudgetParameter(ParamID)
    );

PROMPT CREATING  FOREIGNKEY CONSTRAINT 4 :: T_GarmentsCost
ALTER TABLE T_GarmentsCost
  ADD 
    (
	constraint fk_GarmentsCost_BudgetID FOREIGN KEY(BudgetID) 
		references T_Budget(BudgetID),
	constraint fk_GarmentsCost_StageID FOREIGN KEY(StageID) 
		references T_BudgetStages(StageID),	
	constraint fk_GarmentsCost_AccID FOREIGN KEY(Accessoriesid) 
		references T_Accessories(Accessoriesid)
    );

PROMPT CREATING FOREIGNKEY CONSTRAINT  5 :: T_BudgetParameter
ALTER TABLE T_BudgetParameter
  ADD 
    (
	constraint fk_BParameter_UnitofmeasID FOREIGN KEY(UnitofmeasID) 
		references T_UnitofMeas(UnitofmeasID)
    );



PROMPT CREATING  FOREIGNKEY CONSTRAINT 6 :: T_BudgetStageParameter
ALTER TABLE T_BudgetStageParameter
  ADD 
    (	
	constraint fk_BSParameter_StageID FOREIGN KEY(StageID) 
		references T_BudgetStages(StageID),
	constraint fk_BSParameter_ParamID FOREIGN KEY(ParamID) 
		references T_BudgetParameter(ParamID)
    );
PROMPT CREATING  FOREIGNKEY CONSTRAINT 6 :: T_Athurization
ALTER TABLE T_Athurization
  ADD 
    (	
	constraint fk_T_Athurization_EmpID FOREIGN KEY(Employeeid) 
		references T_Employee(Employeeid) ON DELETE CASCADE,
	constraint fk_T_Athurization_FormID FOREIGN KEY(FormID) 
		references T_Forms(FormID) ON DELETE CASCADE
    );
	
PROMPT CREATING  UniqueKey CONSTRAINT 1 :: T_Budget
ALTER TABLE T_Budget
  ADD 
    (
	constraint uk_Budget_budgetNo Unique (BudgetNo,ordertypeid)		
    );

PROMPT CREATING  UniqueKey CONSTRAINT 1 :: T_GORDERSIZE
ALTER TABLE T_GORDERSIZE
  ADD
   (
	CONSTRAINT FK_GORDERSIZE_ORDERLINEITEM FOREIGN KEY(ORDERLINEITEM) 
		REFERENCES T_GORDERITEMS(ORDERLINEITEM),
	CONSTRAINT FK_GORDERSIZE_SIZEID FOREIGN KEY(SIZEID) 
		REFERENCES T_SIZE(SIZEID)	
   );


PROMPT alter table T_Bill
alter table T_Bill
add (
	constraint fk_T_Bill_T_ORDERTYPE foreign key(ORDERCODE) references T_ORDERTYPE(ORDERCODE),
	constraint fk_T_Bill_T_Client foreign key(ClientId) references T_Client(ClientId),
	constraint fk_T_Bill_T_Currency foreign key(CurrencyId) references T_Currency(CurrencyId),
	constraint pk_T_Bill primary key(ORDERCODE,BillNo)
);

alter table t_lcpaymentinfo
add constraint uk_lcpayinfo_invoiceno unique(PAYMENTINVOICENO,LCTYPE);


PROMPT alter table T_BillItems
alter table T_BillItems
add (
	constraint fk_T_BillItems_T_Bill foreign key(ORDERCODE,BillNo) references T_Bill(ORDERCODE,BillNo),
	constraint fk_T_BillItems_T_ORDERTYPE foreign key(WORDERCODE) references T_ORDERTYPE(ORDERCODE),
	constraint fk_billitems_punit foreign key(punit) references T_unitofmeas(unitofmeasid),
    constraint fk_billitems_sunit foreign key(sunit) references T_unitofmeas(unitofmeasid)	
);

PROMPT alter table T_GSampleGatePass
alter table T_GSampleGatePass
	add 
	(			
		constraint fk_GSampleGatePass_preparedby foreign key(Preparedby ) references T_Employee(Employeeid) on delete cascade
	);

PROMPT alter table T_GSampleGatePassItems
alter table T_GSampleGatePassItems
	add 
	(		
	constraint fk_GSitems_unitid FOREIGN KEY(UnitOfMeasID) references T_UnitOfMeas(UnitOfMeasID) on delete cascade,	
	constraint fk_GSitems_GPID FOREIGN KEY(GPID) references T_GSampleGatePass(GPID) on delete cascade,
	constraint fk_GSitems_sampleid FOREIGN KEY(Sampleid) references T_GSampleType(Sampleid) on delete cascade			
	);
	
Alter Table T_KNeedleImpLC
add
(
	constraint fk_T_KNImpLC_T_ImpLcType foreign key(IMPLCTypeId) references T_ImpLcType(IMPLCTYPEID),
	constraint fk_T_KNImpLC_T_Currency foreign key(CurrencyID) references T_Currency(CurrencyId),
	constraint fk_T_KNImpLC_T_ImpLCStatus foreign key(IMPLCSTATUSID) references T_ImpLCStatus(IMPLCSTATUSID)
);

Alter table T_KNeedleImpLcItems
add
(
	constraint fk_T_KNImpLCItems_T_AccImpLC foreign key(LCNo) references T_KNeedleImpLC(LCNo),
	constraint fk_T_ImpLCItems_T_PartsInfo foreign key(PartID) references T_KmcPartsInfo(PARTID)
);

ALTER TABLE T_GMcStock
	ADD 
	( 
		CONSTRAINT FK_GMcStock_GMCSTOCKTYPEID FOREIGN KEY (TexMCSTOCKTYPEID) 
			REFERENCES T_GMCSTOCKTYPE(TexMCSTOCKTYPEID),
		CONSTRAINT FK_GMcStock_CURRENCYID FOREIGN KEY (CURRENCYID) 
			REFERENCES t_currency (CURRENCYID)
	);	  

ALTER TABLE T_GMcStockItems
	ADD 
	 (
		CONSTRAINT FK_GMcStockItems_STOCKID FOREIGN KEY (STOCKID) 
			REFERENCES T_GMcStock (STOCKID),
		CONSTRAINT FK_GMcStockItems_PARTID FOREIGN KEY (PARTID) 
			REFERENCES T_GMCPARTSINFO (PARTID),
		CONSTRAINT FK_GMcStockItems_PTSTID FOREIGN KEY (PARTSSTATUSFROMID) 
			REFERENCES T_GMCPARTSSTATUS (PARTSSTATUSID)
	 );
	 
ALTER TABLE T_GMcStockReq
	ADD 
	 (
		CONSTRAINT FK_GMcStockR_MCSTOCKTYPEID FOREIGN KEY (TexMCSTOCKTYPEID) 
		REFERENCES T_GMCSTOCKTYPEReq(TexMCSTOCKTYPEID)
	 );





ALTER TABLE T_GMcStockItemsReq
	ADD 
	 (
		CONSTRAINT FK_GMcStockItemsR_STOCKID FOREIGN KEY (STOCKID) 
			REFERENCES T_GMcStockReq (STOCKID),
		CONSTRAINT FK_GMcStockItemsR_PARTID FOREIGN KEY (PARTID) 
			REFERENCES T_GMcPartsInfo(PARTID)
	 );

ALTER TABLE T_GMCPARTSINFO 
	ADD 
	(
		CONSTRAINT FK_GMCPARTSINFO_UNITOFMEASID FOREIGN KEY (UNITOFMEASID) 
			REFERENCES T_UNITOFMEAS (UNITOFMEASID),
		CONSTRAINT FK_GMCPARTSINFO_PROJCODE FOREIGN KEY (PROJCODE) 
			REFERENCES T_PROJECT(PROJCODE),
		CONSTRAINT FK_GMCPARTSINFO_CCATACODE FOREIGN KEY (CCATACODE) 
			REFERENCES T_ACCLASS(CCATACODE)
	);

ALTER TABLE T_GMcPartsPrice 
	ADD 
	( 
		CONSTRAINT FK_T_GMcPartsPrice_PARTID FOREIGN KEY (PARTID) 
			REFERENCES T_GMCPARTSINFO(PARTID)
	);

	
	
	
//====================================================================================
// Stationery
//====================================================================================

Alter Table T_StationeryStockItems
add
(
	constraint fk_T_SItems_stockid foreign key(StockID) references T_StationeryStock(StockID),	
	constraint fk_T_SItems_stationneryid foreign key(StationeryId ) references T_Stationery(StationeryId),
	constraint fk_T_SItems_punit foreign key(PunitOfMeasId) references T_UnitOfMeas(UnitOfMeasID),
	constraint fk_T_SItems_sunit foreign key(SunitOfMeasId) references T_UnitOfMeas(UnitOfMeasID),
	constraint fk_T_SItems_transid foreign key(TransTypeID) references T_StationeryTransactionType(TransTypeID)
);

Alter table T_Stationery
add
(
	constraint fk_T_Stationery foreign key(GROUPID) references T_StationeryGroup(GROUPID)	
);

Alter table T_PurchaseReq
add
(
	constraint fk_T_Purchse_Deptid foreign key(DEPTID) references T_DEPARTMENT(DEPTID)		
);


PROMPT alter table T_PurchaseReqItems
alter table T_PurchaseReqItems
add 
(	constraint fk_T_PReqItems_countryid foreign key(Countryid) references T_Country(Countryid),
	constraint fk_T_PReqItems_groupid foreign key(Groupid) references T_StationeryGroup(Groupid)
);

ALTER TABLE T_GMCPurchaseReqItems
	ADD 
	 (
		CONSTRAINT FK_GMCPReq_ReqId FOREIGN KEY (ReqId) 
			REFERENCES T_GMCPurchaseReq (ReqId) 
			/*,
		CONSTRAINT FK_GMCPReq_IssueFor FOREIGN KEY (IssueFor) 
		REFERENCES T_TEXMCLIST (MCLISTID) */
	 );
Alter table t_shipmentinfo
add
(
constraints fk_shipmentinfo_lcno foreign key(lcno) references T_lcinfo(lcno)
);

	 
alter table T_MoneyReceipt
add
(
constraint fk_t_moneyrecipt_partyid foreign key(partyid) references T_party(partyid)
);


======================================Garments=========================================
PROMPT alter table T_GFabricReq
alter table T_GFabricReq
	add 
	(		
		constraint fk_GFabricReq_subconid foreign key(SubConId) references T_Subcontractors(SubConId) on delete cascade,
		constraint fk_GFabricReq_ClientID FOREIGN KEY(ClientID)  
		references T_Client(ClientID) ON DELETE CASCADE
	);

PROMPT alter table T_GFabricReqItems
alter table T_GFabricReqItems
	add 
	(
	constraint fk_T_GFabricReqIems_Transid foreign key(GFabricReqTypeId) references T_GFabricReqType(GFabricReqTypeId) on delete cascade,
	constraint fk_T_GFabricRItems_Stockid foreign key(StockId) references T_GFabricReq(StockId) on delete cascade,	
	constraint fk_T_GFabricRItems_Ftid foreign key(FabricTypeId) references T_FabricType(FabricTypeId) on delete cascade,
	constraint fk_T_GFabricRItems_punitid FOREIGN KEY(PUnitOfMeasID) references T_UnitOfMeas(UnitOfMeasID) on delete cascade,
	constraint fk_T_GFabricRItems_sunitid FOREIGN KEY(SUnitOfMeasID) references T_UnitOfMeas(UnitOfMeasID) on delete cascade,
	constraint fk_T_GFabricRItems_Sizeid FOREIGN KEY(Sizeid) references T_Size(SizeID) on delete cascade
	);



PROMPT alter table T_GStock
alter table T_GStock
	add 
	(		
		constraint fk_T_GStock_subconid foreign key(SubConId) references T_Subcontractors(SubConId) on delete cascade,
		constraint fk_T_GStock_ClientId foreign key(ClientId) references T_Client(ClientId) on delete cascade	
	);

PROMPT alter table T_GStockItems
alter table T_GStockItems
	add 
	(
	constraint fk_T_GStockItems_TransTypeid foreign  key(GTRANSTYPEID) references T_GTransactionType(GTRANSACTIONTYPEID) on delete cascade,
	constraint fk_T_GStockItems_Stockid foreign key(StockId) references T_GStock(StockId) on delete cascade,	
	constraint fk_T_GStockItems_Ftid foreign key(FabricTypeId) references T_FabricType(FabricTypeId) on delete cascade,
	constraint fk_T_GStockItems_punitid FOREIGN KEY(PUnitOfMeasID) references T_UnitOfMeas(UnitOfMeasID) on delete cascade,
	constraint fk_T_GStockItems_sunitid FOREIGN KEY(SUnitOfMeasID) references T_UnitOfMeas(UnitOfMeasID) on delete cascade,	
	constraint fk_T_GstockItems_Sizeid FOREIGN KEY(Sizeid) references T_Size(Sizeid) on delete cascade,
	CONSTRAINT FK_GStockItems_GCPartsID FOREIGN KEY (GCPartsID) REFERENCES T_GCuttingPartsList(GCPartsID)
	);

ALTER TABLE T_GDELIVERYCHALLAN 
	ADD 
	(
		constraint fk_T_GDchallan_subconid foreign key(SubConId) references T_Subcontractors(SubConId) on delete cascade,
		constraint UNIQUE_GDCHALLAN_INVOICENO UNIQUE(INVOICENO,CATID)		
	);
	

PROMPT alter table T_GDELIVERYCHALLANItems
alter table T_GDELIVERYCHALLANItems
	add 
	(	
	constraint fk_T_GDcitems_Invoiceid foreign key(InvoiceId) references T_GDELIVERYCHALLAN(Invoiceid) on delete cascade,	
	constraint fk_T_GDcitems_punitid FOREIGN KEY(PUnitOfMeasID) references T_UnitOfMeas(UnitOfMeasID) on delete cascade,
	constraint fk_T_GDcitems_sunitid FOREIGN KEY(SUnitOfMeasID) references T_UnitOfMeas(UnitOfMeasID) on delete cascade,	
	constraint fk_T_GDcitems_Sizeid FOREIGN KEY(Sizeid) references T_Size(Sizeid) on delete cascade
	);
ALTER TABLE T_CTN
  ADD 
    (
	constraint uk_CTN Unique(CTNID)
    );	

ALTER TABLE T_CTNItems 
	ADD 
	(
		CONSTRAINT FK_Size_CTNItems FOREIGN KEY (SizeID) 
			REFERENCES T_Size (SizeID)
	);

ALTER TABLE T_CTNItems 
	ADD 
	(
		CONSTRAINT FK_pUnit_CTNItems FOREIGN KEY (Punit) 
			REFERENCES T_UnitOfMeas (UNITOFMEASID)
	);
	
	Alter table T_GAWorkOrder
add
(
	constraint fk_gaworkorder_salestermid FOREIGN KEY(SalesTermID) 
		references T_SalesTerm(SalesTermID),
        constraint fk_gaworkorder_currencyid FOREIGN KEY(CurrencyID) 
		references T_Currency(CurrencyID),
	constraint fk_gaworkorder_salespersonid FOREIGN KEY(SalesPersonID) 
		references T_Employee(EmployeeID),
        constraint fk_gaworkorder_orderstatusid FOREIGN KEY(OrderStatusID) 
		references T_OrderStatus(OrderStatusID),
	constraint fk_gworkorder_gOrderno FOREIGN KEY(GOrderNo)
		references T_GWorkOrder(GOrderNo),
	constraint fk_gworkorder_gSupplierId FOREIGN KEY(SupplierId)
		references t_supplier(SupplierId),
	constraint fk_gworkorder_gBudgetID FOREIGN KEY(BudgetID)
		references T_Budget(BudgetID)
);


Alter Table T_GAWorkOrderItems
add
(
	constraint fk_T_GAWOItems_T_GAWOrder foreign key(OrderNo) 
		references T_GAWorkOrder(OrderNo),	
	constraint fk_T_GAWOItems_T_Acc foreign key(AccessoriesID) 
		references T_Accessories(AccessoriesID),
	constraint fk_T_GAWOItems_T_PUOM foreign key(PunitOfMeasId) 
		references T_UnitOfMeas(UnitOfMeasID),
	constraint fk_T_GAWOItems_T_SUOM foreign key(SunitOfMeasId) 
		references T_UnitOfMeas(UnitOfMeasID),
	constraint fk_T_GAWOItems_T_Colour foreign key(ColourID) 
		references T_Colour(ColourID),
	constraint fk_T_GAWOItems_T_AccGroup foreign key(GroupId)
		references T_AccGroup(GroupId)		
);

PROMPT alter table T_GBill
alter table T_GBill
add (
	constraint fk_T_GBill_T_GORDERTYPE foreign key(ORDERCODE) references T_GORDERTYPE(ORDERTYPE),
	constraint fk_T_GBill_T_Client foreign key(ClientId) references T_Client(ClientId),
	constraint fk_T_GBill_T_Currency foreign key(CurrencyId) references T_Currency(CurrencyId)
	);
/

PROMPT alter table T_GBillItems
alter table T_GBillItems
add (
	constraint fk_T_GBillItems_T_GBill foreign key(ORDERCODE,BillNo) 
		references T_GBill(ORDERCODE,BillNo),
	constraint fk_T_GBillItems_T_GORDERTYPE foreign key(WORDERCODE) 
		references T_GORDERTYPE(ORDERTYPE),
	constraint fk_GBillItems_GWORKORDER foreign key(GORDERNO) 
		references T_GWORKORDER(GORDERNO)
);
/
	
	
Alter Table T_scgWorkorder
Add
(
constraint fk_scgWorkorder_scgorderno foreign key(gOrderNo)
	references T_GWorkOrder(gOrderNo),
constraint fk_scgWorkorder_clientid foreign key(ClientId)
	references t_client(ClientId),
constraint fk_scgWorkorder_salestermid foreign key (salestermId)
	references t_Salesterm(salestermId),
constraint fk_scgWorkorder_currencyid FOREIGN KEY(CurrencyID) 
	references T_Currency(CurrencyID),
constraint fk_scgWorkorder_salespersonid FOREIGN KEY(SalesPersonID) 
	references T_Employee(EmployeeID),
constraint fk_scgWorkorder_orderstatusid FOREIGN KEY(OrderStatusID) 
	references T_OrderStatus(OrderStatusID)
);
   
   
ALTER TABLE T_KNITMACHINEINFOITEMS 
	ADD 
	( 
		CONSTRAINT FK_KMINFOITEMS_FABRICTYPEID FOREIGN KEY (FABRICTYPEID) 
			REFERENCES T_FABRICTYPE (FABRICTYPEID),
		constraint FK_KMINFOITEMS_UNITOFMEASID FOREIGN KEY(UNITOFMEASID) 
		references T_UNITOFMEAS(UNITOFMEASID)
	);


Alter Table T_StationeryPrice
add
(
	constraint fk_SPrice_StationeryID foreign key(StationeryID) references T_Stationery(StationeryID),	
	constraint fk_SPrice_SupplierID foreign key(SupplierID ) references T_Supplier(SupplierID),
	constraint fk_SPrice_REFPID foreign key(REFPID) references T_StationeryStockItems(PID)  ON DELETE CASCADE,
	constraint fk_SPrice_CURRENCYID foreign key(CURRENCYID) references T_CURRENCY(CURRENCYID)
);