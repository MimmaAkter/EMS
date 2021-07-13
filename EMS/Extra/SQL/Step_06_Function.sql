CREATE OR REPLACE FUNCTION fncTransAccGOrder(pStockid in number,pPID in number)
RETURN varchar2
IS
workorder  varchar2(20);
BEGIN
select getfncDispalyorder(GORDERNO) into workorder from T_ACCSTOCKITEMS
 where STOCKID=pStockid  and PID=pPID;
return workorder;

END fncTransAccGOrder;
/


CREATE OR REPLACE FUNCTION fncTransAccOrder(pStockid in number,pPID in number)
RETURN varchar2
IS
workorder  varchar2(20);
BEGIN
select ORDERNO into workorder from T_ACCSTOCKITEMS
 where STOCKID=pStockid  and PID=pPID;
return workorder;

END fncTransAccOrder;
/



create or replace function get_token(the_list  varchar2,the_index number,delim     varchar2 := ',')
return    varchar2
is
   start_pos number;
   end_pos   number;
begin
   if the_index = 1 then
       start_pos := 1;
   else
       start_pos := instr(the_list, delim, 1, the_index - 1);
       if start_pos = 0 then
           return null;
       else
           start_pos := start_pos + length(delim);
       end if;
   end if;
   end_pos := instr(the_list, delim, start_pos, 1);

   if end_pos = 0 then
       return substr(the_list, start_pos);
   else
       return substr(the_list, start_pos, end_pos - start_pos);
   end if;
end get_token;
/

CREATE OR REPLACE function getFncColourCombination(
pOrderLineItem varchar2)
return varchar2
is
cursor c1 is select COLOURNAME || ' = ' || sum(COLOURLENGTH) || ' mm = ' || sum(FEEDERLENGTH) || ' Feeder ' as CC
	from T_ColourCombination a, T_Colour b
	where a.ColourId=b.ColourId and
	orderlineitem= pOrderLineItem
	group by COLOURNAME
	having  (sum(COLOURLENGTH)>0 or sum(FEEDERLENGTH)>0);	
myrec c1%rowtype;
mReturntext varchar2(500);
begin
        for myrec in c1
                loop
                    mReturntext:= mReturntext || ' # '|| myrec.CC;
        end loop;
        return  mReturntext;
end getFncColourCombination;
/

CREATE OR REPLACE function getFncTotalColourCombination(
pOrderNo Number)
return varchar2
is
cursor c1 is select sum(COLOURLENGTH) || ' mm = ' || sum(FEEDERLENGTH) || ' Feeder ' as CC
	from T_ColourCombination a, T_Colour b
	where a.ColourId=b.ColourId and
	orderlineitem in (Select orderlineitem from T_SCorderItems where OrderNo=pOrderNo)
	having  (sum(COLOURLENGTH)>0 or sum(FEEDERLENGTH)>0);	
myrec c1%rowtype;
mReturntext varchar2(500);
begin
        for myrec in c1
                loop
                    mReturntext:= mReturntext || myrec.CC;
        end loop;
        return  mReturntext;
end getFncTotalColourCombination;
/

create or replace function FncSCOrderBasicTypes(
pOrderNo NUMBER
) return varchar2
is
cursor c1 is 
select b.BasicTypeID from T_SCBasicWorkorder a,T_basictype b 
where a.BASICTYPEID=b.BASICTYPEID and WorkorderNo=pOrderNo ORDER BY a.workOrderNo,b.BASICTYPESL;
myrec c1%rowtype;
mReturntext varchar2(200);
begin
        for myrec in c1
        loop
                    mReturntext := mReturntext || myrec.basicTypeID;
        end loop;
        return  mReturntext;

end fncSCOrderBasicTypes;
/ 
create or replace function getFncdSCWorkOrder(pOrderNo varchar2)
return varchar2
is
cursor c1 is
select a.basictypeID from t_SCbasicworkOrder a,t_basicType b
 where a.basictypeID=b.basictypeID and workorderno= pOrderNo order by BASICTYPESL asc;
myrec c1%rowtype;
mReturntext varchar2(500);
begin
 for myrec in c1
  loop
      mReturntext:= mReturntext || getfncBasicType(myrec.basictypeID) ||', ' ;
     end loop;

  return  substr((mReturntext),1,length((mReturntext))-2);
end getFncdSCWorkOrder;
/

create or replace function getFncSCYarnDes(pOrderLineItem varchar2)
return varchar2
is
cursor c1 is select yarnCount || ' ' || yarntype || '-' || yarnpercent || ',' as YP
from T_SCYarnDesc a, T_YarnCount b, T_YarnType c
where a.YarnCountId=b.YarnCountId and
a.YarnTypeId=c.YarnTypeId and
orderlineitem= pOrderLineItem;

myrec c1%rowtype;
mReturntext varchar2(500);
begin
        for myrec in c1
                loop
                    mReturntext:= mReturntext || myrec.YP;
        end loop;
        return  mReturntext;
end getFncSCYarnDes;
/

create or replace FUNCTION getfncSCWOBType(pOrderNo in NUMBER)
RETURN varchar2
IS
WOBTName  T_SCWorkOrder.BASICTYPEID%type;
BEGIN
select basictypeID || ' ' || dOrderNo into WOBTName from T_SCWorkOrder where OrderNo=pOrderNo;
return WOBTName;
END getfncSCWOBType;
/

CREATE OR REPLACE FUNCTION getTmpCombination(YarnTypeID in VARCHAR2)
RETURN varchar2
IS
combinationID  varchar2(20);
BEGIN
select yarnCode into combinationID from dypro.t_knityarnType where yarnTypeID=YarnTypeID;
return combinationID;

END getTmpCombination;
/

CREATE OR REPLACE FUNCTION getDisplayCuttingNo(pCuttingNo in varchar2)
RETURN varchar2
IS
CuttingName  T_GStock.STOCKTRANSNO%type;
BEGIN
	select a.STOCKTRANSNO into CuttingName from T_GStock a 
	where a.STOCKID=to_Number(pCuttingNo);
return CuttingName;
END getDisplayCuttingNo;
/

CREATE OR REPLACE FUNCTION getYarnPrice(YTID in VARCHAR2,YCID in VARCHAR2,PDATE in DATE)
RETURN number
IS
YPRICE  number(20,2);
BEGIN
select round(UNITPRICE,2) into YPRICE from T_yarnprice where CountId=YCID and
    YarnTypeId=YTID and PURCHASEDATE=(select MAX(PURCHASEDATE) from T_yarnprice where CountId=YCID and
    YarnTypeId=YTID and PURCHASEDATE<=PDATE);
return YPRICE;
END  getYarnPrice;
/


CREATE OR REPLACE FUNCTION getTmpFabricType(FID in VARCHAR2)
RETURN varchar2
IS
FAbID  varchar2(20);
BEGIN
select fabricTypeID into FAbID from t_fabrictype where t_fabrictype.fabrictype=FID;
return FAbID;

END  getTmpFabricType;
/

CREATE OR REPLACE FUNCTION gettmpWorkOrder(batype in VARCHAR2,Ordernoref varchar2)
RETURN number
IS
OrderNOD  t_workorder.orderno%type;
BEGIN
	 select orderNO into OrderNOD  from t_WorkOrder
	 where basictypeid=batype and Orderref=Ordernoref;
return OrderNOD;
END gettmpWorkOrder;
/

CREATE OR REPLACE FUNCTION getfncBasicType(basTyID in VARCHAR2)
RETURN varchar2
IS
basictypeNameD  t_basictype.BASICTYPENAME%type;
BEGIN
select basictypeName into basictypeNameD   from t_basictype where BASICTYPEID=basTyID;
return basictypeNameD;

END getfncBasicType;
/
Create or Replace function getFncbasicWorkOrder(
pOrderNo varchar2)
return varchar2

is
cursor c1 is
select a.basictypeID from t_basicworkOrder a,t_basicType b
 where a.basictypeID=b.basictypeID and workorderno= pOrderNo order by BASICTYPESL asc;
myrec c1%rowtype;
mReturntext varchar2(500);
begin
 for myrec in c1
  loop
      mReturntext:= mReturntext || getfncBasicType(myrec.basictypeID) ||' , ' ;
     end loop;

  return  substr(upper(mReturntext),1,length(upper(mReturntext))-3) || ' WORK ORDER';
end getFncbasicWorkOrder;
/

CREATE OR REPLACE FUNCTION getfncClient(ClntID in VARCHAR2)
RETURN varchar2
IS
ClientName  t_client.clientName%type;
BEGIN
	 select clientName into ClientName   from t_client
	 where clientID=ltrim(rtrim(ClntID));
return ClientName;
END getfncClient;
/

CREATE OR REPLACE FUNCTION getfncCombination(combid in VARCHAR2)
RETURN varchar2
IS
combination  t_combination.combination%type;
BEGIN
select combination into combination  from t_combination where combinationid=combid;
return combination;

END getfncCombination;
/


CREATE OR REPLACE FUNCTION getfncCurrency(mstatus number,CurrID in VARCHAR2)
RETURN varchar2
IS
CurrencyNameDesc  t_currency.currencyName%type;
CurrencyrateDesc   t_currency.conrate%type;
BEGIN
select CurrencyName,conrate into CurrencyNameDesc,CurrencyrateDesc   from t_currency where CurrencyID=CurrID;
if mstatus=1 then 
   return CurrencyNameDesc;
elsif mstatus=2 then 
   return CurrencyrateDesc;
end if;
END getfncCurrency;
/

CREATE OR REPLACE FUNCTION getfncEmployee(EmpID in VARCHAR2)
RETURN varchar2
IS
EmployeeName  t_Employee.employeeName%type;
BEGIN
select EmployeeName into EmployeeName   from t_Employee where EmployeeID=EmpID;
return EmployeeName;

END getfncEmployee;
/

CREATE OR REPLACE FUNCTION getfncfabrictype(fabid in VARCHAR2)
RETURN varchar2
IS
fabrictypeDesc  t_fabrictype.fabrictype%type;
BEGIN
select fabrictype into fabrictypeDesc   from t_fabrictype where fabrictypeid=fabid;
return fabrictypeDesc;

END getfncfabrictype;
/

CREATE OR REPLACE FUNCTION getfncOrderStatus(orderStID in VARCHAR2)
RETURN varchar2
IS
orderStatusDesc  t_orderStatus.orderStatus%type;
BEGIN
select orderStatus into orderStatusDesc   from t_orderStatus where orderStatusID=orderStID;
return orderStatusDesc;

END getfncOrderStatus;
/



PROMPT CREATE OR REPLACE Procedure  54 :: getfncTranSactionTWiseQty
CREATE OR REPLACE FUNCTION getfncTranSactionTWiseQty(mTransactionType in VARCHAR2,
pOrderNo in number)
RETURN number
IS
m_Qty  number(12,2) default 0;
m_YIQty  number(12,2) default 0;
m_YRQty  number(12,2) default 0;
aaa  number(12,2) default 0;

BEGIN

/* For Transaction Field*/
if mTransactionType<90 then

   select sum(b.Quantity)  into m_Qty
    from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c, T_ShadeGroup d
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    a.KNTITRANSACTIONTYPEID=mTransactionType and
    b.ShadeGroupID=d.ShadeGroupID and
    b.OrderNo = pOrderNo;

/*Line 3    Knit Yarn Transfer For  AYDL*/
elsif 	mTransactionType=200 then

 select sum(decode(a.KNTITRANSACTIONTYPEID,151,b.Quantity,152,-b.Quantity)) into m_Qty
     from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c, T_ShadeGroup d
     where a.StockID=b.StockID and
     a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
     a.KNTITRANSACTIONTYPEID in (151,152) and
     b.ShadeGroupID=d.ShadeGroupID and
     b.OrderNo = pOrderNo;

/*Line 4  Net Gray  Yarn Issue For AYDL*/
elsif 	mTransactionType=202 then

 select sum(decode(a.KNTITRANSACTIONTYPEID,5,b.Quantity,11,-b.Quantity)) into m_Qty
     from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c, T_ShadeGroup d
     where a.StockID=b.StockID and
     a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
     a.KNTITRANSACTIONTYPEID in (5,11) and
     b.ShadeGroupID=d.ShadeGroupID and
     b.OrderNo = pOrderNo;

/*Line 4  Net Gray Yarn Issue For OTHERS DYEING*/
elsif 	mTransactionType=203 then

   select sum(decode(a.KNTITRANSACTIONTYPEID,12,b.Quantity,14,-b.Quantity))  into m_Qty
    from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c, T_ShadeGroup d
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    a.KNTITRANSACTIONTYPEID in (12,14) and
    b.ShadeGroupID=d.ShadeGroupID and
    b.OrderNo = pOrderNo;

/*Line 6   Yarn Dying Process Loss Surplus AYDL*/
elsif 	mTransactionType=90 then

   select -sum(decode(a.KNTITRANSACTIONTYPEID,5,b.Quantity,8,-b.Quantity))  into m_Qty
    from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c, T_ShadeGroup d
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    a.KNTITRANSACTIONTYPEID in (5,8) and
    b.ShadeGroupID=d.ShadeGroupID and
    b.OrderNo = pOrderNo;

/*Line 6    Yarn Dying Process Loss Surplus Others Factories*/
elsif 	mTransactionType=91 then

   select -sum(decode(a.KNTITRANSACTIONTYPEID,12,b.Quantity,13,-b.Quantity))  into m_Qty
    from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c, T_ShadeGroup d
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    a.KNTITRANSACTIONTYPEID in (12,13) and
    b.ShadeGroupID=d.ShadeGroupID and
    b.OrderNo = pOrderNo;

/*Line 7    Yarn Dying Process Loss Surplus % AYDL*/
elsif 	mTransactionType=92 then

   select -(sum(decode(a.KNTITRANSACTIONTYPEID,5,b.Quantity,-b.Quantity))/sum(decode(a.KNTITRANSACTIONTYPEID,5,b.Quantity,0))*100)  into m_Qty
    from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c, T_ShadeGroup d
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    a.KNTITRANSACTIONTYPEID in (5,8) and
    b.ShadeGroupID=d.ShadeGroupID and
    b.OrderNo = pOrderNo;

/*Line 7   Yarn Dying Process Loss Surplus % Otheres*/
elsif 	mTransactionType=93 then

   select -(sum(decode(a.KNTITRANSACTIONTYPEID,12,b.Quantity,-b.Quantity))/sum(decode(a.KNTITRANSACTIONTYPEID,12,b.Quantity,0))*100)  into m_Qty
    from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c, T_ShadeGroup d
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    a.KNTITRANSACTIONTYPEID in (12,13) and
    b.ShadeGroupID=d.ShadeGroupID and
    b.OrderNo = pOrderNo;

/*Line 10   Gray and Dyed Yarn Issue For Knitting Floor*/
elsif 	mTransactionType=102 then

   select sum(decode(a.KNTITRANSACTIONTYPEID,3,b.Quantity,22,b.Quantity))  into m_Qty
    from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c, T_ShadeGroup d
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    a.KNTITRANSACTIONTYPEID in (3,22) and
    b.ShadeGroupID=d.ShadeGroupID and
    b.OrderNo = pOrderNo;

/*Line 10    Gray and Dyed Yarn Issue For Knitting Others*/
elsif 	mTransactionType=103 then

   select sum(decode(a.KNTITRANSACTIONTYPEID,4,b.Quantity,23,b.Quantity))  into m_Qty
    from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c, T_ShadeGroup d
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    a.KNTITRANSACTIONTYPEID in (4,23) and
    b.ShadeGroupID=d.ShadeGroupID and
    b.OrderNo = pOrderNo;

/*Line 11   Gray and Dyed Yarn Return From Knitting Floor to Main Store*/
elsif 	mTransactionType=104 then

   select sum(decode(a.KNTITRANSACTIONTYPEID,9,b.Quantity,26,b.Quantity))  into m_Qty
    from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c, T_ShadeGroup d
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    a.KNTITRANSACTIONTYPEID in (9,26) and
    b.ShadeGroupID=d.ShadeGroupID and
    b.OrderNo = pOrderNo;

/*Line 11    Gray and Dyed Yarn Return From Knitting Others to Main Store*/
elsif 	mTransactionType=105 then

   select sum(decode(a.KNTITRANSACTIONTYPEID,10,b.Quantity,27,b.Quantity))  into m_Qty
    from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c, T_ShadeGroup d
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    a.KNTITRANSACTIONTYPEID in (10,27) and
    b.ShadeGroupID=d.ShadeGroupID and
    b.OrderNo = pOrderNo;

/*Line 12    Knit Yarn Transfer For Knitting ATL*/
elsif 	mTransactionType=94 then

 select sum(decode(a.KNTITRANSACTIONTYPEID,101,b.Quantity,102,-b.Quantity,111,b.Quantity,112,-b.Quantity)) into m_Qty
     from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c, T_ShadeGroup d
     where a.StockID=b.StockID and
     a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
     a.KNTITRANSACTIONTYPEID in (101,102,111,112) and
     b.ShadeGroupID=d.ShadeGroupID and
     b.OrderNo = pOrderNo;

/*Line 13  Net Gray and Dyed Yarn Issue For Knitting Floor*/
elsif 	mTransactionType=96 then

   select sum(decode(a.KNTITRANSACTIONTYPEID,3,b.Quantity,9,-b.Quantity,101,b.Quantity,102,-b.Quantity,22,b.Quantity,26,-b.Quantity,111,b.Quantity,112,-b.Quantity))  into m_Qty
    from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c, T_ShadeGroup d
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    a.KNTITRANSACTIONTYPEID in (3,9,101,102,22,26,111,112) and
    b.ShadeGroupID=d.ShadeGroupID and
    b.OrderNo = pOrderNo;

/*Line 13   Net Gray and Dyed Yarn Issue For Knitting Others*/
elsif 	mTransactionType=97 then

   select sum(decode(a.KNTITRANSACTIONTYPEID,4,b.Quantity,10,-b.Quantity,23,b.Quantity,27,-b.Quantity))  into m_Qty
    from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c, T_ShadeGroup d
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    a.KNTITRANSACTIONTYPEID in (4,10,23,27) and
    b.ShadeGroupID=d.ShadeGroupID and
    b.OrderNo = pOrderNo;

/*Line 14   Gray Fabric Received From Knitting Floor*/
elsif 	mTransactionType=106 then

   select sum(decode(a.KNTITRANSACTIONTYPEID,6,b.Quantity,24,b.Quantity))  into m_Qty
    from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c, T_ShadeGroup d
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    a.KNTITRANSACTIONTYPEID in (6,24) and
    b.ShadeGroupID=d.ShadeGroupID and
    b.OrderNo = pOrderNo;

/*Line 14    Gray Fabric Received From Knitting Others*/
elsif 	mTransactionType=107 then

   select sum(decode(a.KNTITRANSACTIONTYPEID,7,b.Quantity,25,b.Quantity))  into m_Qty
    from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c, T_ShadeGroup d
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    a.KNTITRANSACTIONTYPEID in (7,25) and
    b.ShadeGroupID=d.ShadeGroupID and
    b.OrderNo = pOrderNo;


/*Line 15   Gray and Dyed Yarn Knitting Process Loss Surplus ATL*/
elsif 	mTransactionType=98 then

  select -sum(decode(a.KNTITRANSACTIONTYPEID,3,b.Quantity,9,-b.Quantity,6,-b.Quantity,101,b.Quantity,102,-b.Quantity,22,b.Quantity,26,-b.Quantity,24,-b.Quantity,111,b.Quantity,112,-b.Quantity))  into m_Qty
    from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c, T_ShadeGroup d
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    a.KNTITRANSACTIONTYPEID in (3,9,6,101,102,22,26,24,111,112) and
    b.ShadeGroupID=d.ShadeGroupID and
    b.OrderNo = pOrderNo;

/*Line 15   Gray and Dyed Yarn Knitting Process Loss Surplus Others Factories*/
elsif 	mTransactionType=99 then

  select -sum(decode(a.KNTITRANSACTIONTYPEID,4,b.Quantity,10,-b.Quantity,7,-b.Quantity,23,b.Quantity,27,-b.Quantity,25,-b.Quantity))  into m_Qty
    from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c, T_ShadeGroup d
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    a.KNTITRANSACTIONTYPEID in (4,10,7,23,27,25) and
    b.ShadeGroupID=d.ShadeGroupID and
    b.OrderNo = pOrderNo;

/*Line 16   Gray and Dyed Yarn Knitting Process Loss Surplus % ATL*/
elsif 	mTransactionType=100 then

   select -(sum(decode(a.KNTITRANSACTIONTYPEID,3,b.Quantity,9,-b.Quantity,6,-b.Quantity,101,b.Quantity,102,-b.Quantity,22,b.Quantity,26,-b.Quantity,24,-b.Quantity,111,b.Quantity,112,-b.Quantity))/sum(decode(a.KNTITRANSACTIONTYPEID,3,b.Quantity,9,-b.Quantity,101,b.Quantity,102,-b.Quantity,22,b.Quantity,26,-b.Quantity,111,b.Quantity,112,-b.Quantity)))*100  into m_Qty
    from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c, T_ShadeGroup d
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    a.KNTITRANSACTIONTYPEID in (3,9,6,101,102,6,22,26,24,111,112) and
    b.ShadeGroupID=d.ShadeGroupID and
    b.OrderNo = pOrderNo;


/*Line 16   Gray and Dyed Yarn Knitting Process Loss Surplus % Others Factories*/
elsif 	mTransactionType=101 then

  select -(sum(decode(a.KNTITRANSACTIONTYPEID,4,b.Quantity,10,-b.Quantity,7,-b.Quantity,23,b.Quantity,27,-b.Quantity,25,-b.Quantity))/sum(decode(a.KNTITRANSACTIONTYPEID,4,b.Quantity,10,-b.Quantity,23,b.Quantity,27,-b.Quantity)))*100  into m_Qty
    from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c, T_ShadeGroup d
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    a.KNTITRANSACTIONTYPEID in (4,10,7,23,27,25) and
    b.ShadeGroupID=d.ShadeGroupID and
    b.OrderNo = pOrderNo;


/*Line 20   Gray Fabric Issued to Batch for Dyeing Floor*/
elsif 	mTransactionType=120 then

   select sum(decode(a.KNTITRANSACTIONTYPEID,18,b.Quantity))  into m_Qty
    from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c, T_ShadeGroup d
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    a.KNTITRANSACTIONTYPEID in (18) and
    b.ShadeGroupID=d.ShadeGroupID and
    b.OrderNo = pOrderNo;

/*Line 20    Gray Fabric Issued to Batch for Dyeing Others*/
elsif 	mTransactionType=121 then

   select sum(decode(a.KNTITRANSACTIONTYPEID,37,b.Quantity))  into m_Qty
    from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c, T_ShadeGroup d
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    a.KNTITRANSACTIONTYPEID in (37) and
    b.ShadeGroupID=d.ShadeGroupID and
    b.OrderNo = pOrderNo;

/*Line 21    Gray Fabric Return from Batching Others*/
elsif 	mTransactionType=123 then

   select sum(decode(a.KNTITRANSACTIONTYPEID,38,b.Quantity))  into m_Qty
    from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c, T_ShadeGroup d
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    a.KNTITRANSACTIONTYPEID in (38) and
    b.ShadeGroupID=d.ShadeGroupID and
    b.OrderNo = pOrderNo;


/*Line 22   Gray Fabric Transferred from Floor*/
elsif 	mTransactionType=124 then

   select sum(decode(a.KNTITRANSACTIONTYPEID,161,b.Quantity,162,-b.Quantity))  into m_Qty
    from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c, T_ShadeGroup d
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    a.KNTITRANSACTIONTYPEID in (161,162) and
    b.ShadeGroupID=d.ShadeGroupID and
    b.OrderNo = pOrderNo;

/*Line 23  Net Gray Fabric Issued to Batch for Dyeing Floor*/
elsif 	mTransactionType=126 then

   select sum(decode(a.KNTITRANSACTIONTYPEID,18,b.Quantity,161,b.Quantity,162,-b.Quantity))  into m_Qty
    from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c, T_ShadeGroup d
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    a.KNTITRANSACTIONTYPEID in (18,161,162) and
    b.ShadeGroupID=d.ShadeGroupID and
    b.OrderNo = pOrderNo;

/*Line 23   Net Gray Fabric Issued to Batch for Dyeing Others*/
elsif 	mTransactionType=127 then

   select sum(decode(a.KNTITRANSACTIONTYPEID,37,b.Quantity,38,b.Quantity))  into m_Qty
    from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c, T_ShadeGroup d
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    a.KNTITRANSACTIONTYPEID in (37,38) and
    b.ShadeGroupID=d.ShadeGroupID and
    b.OrderNo = pOrderNo;

/*Line 24    Dyeing Production  from Floor*/
elsif 	mTransactionType=128 then

   select sum(decode(a.KNTITRANSACTIONTYPEID,19,b.Quantity))  into m_Qty
    from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c, T_ShadeGroup d
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    a.KNTITRANSACTIONTYPEID in (19) and
    b.ShadeGroupID=d.ShadeGroupID and
    b.OrderNo = pOrderNo;

/*Line 24    Dyeing Production from Others*/
elsif 	mTransactionType=129 then

   select sum(decode(a.KNTITRANSACTIONTYPEID,39,b.Quantity))  into m_Qty
    from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c, T_ShadeGroup d
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    a.KNTITRANSACTIONTYPEID in (39) and
    b.ShadeGroupID=d.ShadeGroupID and
    b.OrderNo = pOrderNo;

/*Line 25    Dyeing (Process Loss) /Surplus Floor*/
elsif 	mTransactionType=130 then

   select -sum(decode(a.KNTITRANSACTIONTYPEID,18,b.Quantity,161,b.Quantity,162,-b.Quantity,19,-b.Quantity))  into m_Qty
    from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c, T_ShadeGroup d
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    a.KNTITRANSACTIONTYPEID in (18,161,162,19) and
    b.ShadeGroupID=d.ShadeGroupID and
    b.OrderNo = pOrderNo;

/*Line 25    Dyeing (Process Loss) /Surplus Others*/
elsif 	mTransactionType=131 then

   select -sum(decode(a.KNTITRANSACTIONTYPEID,37,b.Quantity,38,b.Quantity,39,-b.Quantity))  into m_Qty
    from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c, T_ShadeGroup d
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    a.KNTITRANSACTIONTYPEID in (37,38,39) and
    b.ShadeGroupID=d.ShadeGroupID and
    b.OrderNo = pOrderNo;

/*Line 26    Dyeing (Process Loss) /Surplus % Floor*/
elsif 	mTransactionType=132 then

   select -(sum(decode(a.KNTITRANSACTIONTYPEID,18,b.Quantity,161,b.Quantity,162,-b.Quantity,19,-b.Quantity))/sum(decode(a.KNTITRANSACTIONTYPEID,18,b.Quantity,161,b.Quantity,162,-b.Quantity)))*100  into m_Qty
    from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c, T_ShadeGroup d
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    a.KNTITRANSACTIONTYPEID in (18,161,162,19) and
    b.ShadeGroupID=d.ShadeGroupID and
    b.OrderNo = pOrderNo;

/*Line 26    Dyeing (Process Loss) /Surplus % Others*/
elsif 	mTransactionType=133 then

   select -(sum(decode(a.KNTITRANSACTIONTYPEID,37,b.Quantity,38,b.Quantity,39,-b.Quantity))/sum(decode(a.KNTITRANSACTIONTYPEID,37,b.Quantity,38,b.Quantity)))*100  into m_Qty
    from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c, T_ShadeGroup d
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    a.KNTITRANSACTIONTYPEID in (37,38,39) and
    b.ShadeGroupID=d.ShadeGroupID and
    b.OrderNo = pOrderNo;

/*Line 30    Dyed Fabric Received  from Floor*/
elsif 	mTransactionType=150 then

   select sum(decode(a.KNTITRANSACTIONTYPEID,19,b.Quantity))  into m_Qty
    from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c, T_ShadeGroup d
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    a.KNTITRANSACTIONTYPEID in (19) and
    b.ShadeGroupID=d.ShadeGroupID and
    b.OrderNo = pOrderNo;

/*Line 30    Dyed Fabric Received  from Others*/
elsif 	mTransactionType=151 then

   select sum(decode(a.KNTITRANSACTIONTYPEID,39,b.Quantity))  into m_Qty
    from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c, T_ShadeGroup d
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    a.KNTITRANSACTIONTYPEID in (39) and
    b.ShadeGroupID=d.ShadeGroupID and
    b.OrderNo = pOrderNo;

/*Line 31   Dyed Fabric Return from Finishing Others*/
elsif 	mTransactionType=153 then

   select sum(decode(a.KNTITRANSACTIONTYPEID,34,b.Quantity))  into m_Qty
    from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c, T_ShadeGroup d
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    a.KNTITRANSACTIONTYPEID in (34) and
    b.ShadeGroupID=d.ShadeGroupID and
    b.OrderNo = pOrderNo;

/*Line 32    Finished Fabric Transferred from or to*/
elsif 	mTransactionType=154 then

   select sum(decode(a.KNTITRANSACTIONTYPEID,141,b.Quantity,142,-b.Quantity))  into m_Qty
    from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c, T_ShadeGroup d
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    a.KNTITRANSACTIONTYPEID in (141,142) and
    b.ShadeGroupID=d.ShadeGroupID and
    b.OrderNo = pOrderNo;

/*Line 33    Net Finished Fabric Issued to Finishing Floor*/
elsif 	mTransactionType=156 then

   select sum(decode(a.KNTITRANSACTIONTYPEID,19,b.Quantity,141,b.Quantity,142,-b.Quantity))  into m_Qty
    from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c, T_ShadeGroup d
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    a.KNTITRANSACTIONTYPEID in (19,141,142) and
    b.ShadeGroupID=d.ShadeGroupID and
    b.OrderNo = pOrderNo;

/*Line 33   Net Finished Fabric Issued to Finishing Others*/
elsif 	mTransactionType=157 then

   select sum(decode(a.KNTITRANSACTIONTYPEID,39,b.Quantity,34,-b.Quantity))  into m_Qty
    from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c, T_ShadeGroup d
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    a.KNTITRANSACTIONTYPEID in (39,34) and
    b.ShadeGroupID=d.ShadeGroupID and
    b.OrderNo = pOrderNo;

/*Line 34   Finished Fabric Received at Store  from Floor*/
elsif 	mTransactionType=158 then

   select sum(decode(a.KNTITRANSACTIONTYPEID,20,b.Quantity))  into m_Qty
    from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c, T_ShadeGroup d
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    a.KNTITRANSACTIONTYPEID in (20) and
    b.ShadeGroupID=d.ShadeGroupID and
    b.OrderNo = pOrderNo;

/*Line 34   Finished Fabric Received at Store  from Others*/
elsif 	mTransactionType=159 then

   select sum(decode(a.KNTITRANSACTIONTYPEID,40,b.Quantity))  into m_Qty
    from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c, T_ShadeGroup d
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    a.KNTITRANSACTIONTYPEID in (40) and
    b.ShadeGroupID=d.ShadeGroupID and
    b.OrderNo = pOrderNo;

/*Line 35    Finishing (Process Loss) /Surplus Floor*/
elsif 	mTransactionType=160 then

   select -sum(decode(a.KNTITRANSACTIONTYPEID,19,b.Quantity,141,b.Quantity,142,-b.Quantity,20,-b.Quantity))  into m_Qty
    from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c, T_ShadeGroup d
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    a.KNTITRANSACTIONTYPEID in (19,141,142,20) and
    b.ShadeGroupID=d.ShadeGroupID and
    b.OrderNo = pOrderNo;

/*Line 35   Finishing (Process Loss) /Surplus Others*/
elsif 	mTransactionType=161 then

   select -sum(decode(a.KNTITRANSACTIONTYPEID,39,b.Quantity,34,-b.Quantity,40,-b.Quantity))  into m_Qty
    from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c, T_ShadeGroup d
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    a.KNTITRANSACTIONTYPEID in (39,34,40) and
    b.ShadeGroupID=d.ShadeGroupID and
    b.OrderNo = pOrderNo;

/*Line 36    Finishing (Process Loss) /Surplus % Floor*/
elsif 	mTransactionType=162 then

   select -(sum(decode(a.KNTITRANSACTIONTYPEID,19,b.Quantity,141,b.Quantity,142,-b.Quantity,20,-b.Quantity))/sum(decode(a.KNTITRANSACTIONTYPEID,19,b.Quantity,141,b.Quantity,142,-b.Quantity)))*100  into m_Qty
    from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c, T_ShadeGroup d
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    a.KNTITRANSACTIONTYPEID in (19,141,142,20) and
    b.ShadeGroupID=d.ShadeGroupID and
    b.OrderNo = pOrderNo;

/*Line 36   Finishing (Process Loss) /Surplus % Others*/
elsif 	mTransactionType=163 then

   select -(sum(decode(a.KNTITRANSACTIONTYPEID,39,b.Quantity,34,-b.Quantity,40,-b.Quantity))/sum(decode(a.KNTITRANSACTIONTYPEID,39,b.Quantity,34,-b.Quantity)))*100  into m_Qty
    from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c, T_ShadeGroup d
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    a.KNTITRANSACTIONTYPEID in (39,34,40) and
    b.ShadeGroupID=d.ShadeGroupID and
    b.OrderNo = pOrderNo;

/*Line 40    Total Process Loss (kg) Floor*/
elsif 	mTransactionType=164 then

  select -(sum(decode(a.KNTITRANSACTIONTYPEID,5,b.Quantity,8,-b.Quantity,3,b.Quantity,9,-b.Quantity,6,-b.Quantity,101,b.Quantity,102,-b.Quantity,22,b.Quantity,26,-b.Quantity,24,-b.Quantity,111,b.Quantity,112,-b.Quantity,18,b.Quantity,161,b.Quantity,162,-b.Quantity,141,b.Quantity,142,-b.Quantity,20,-b.Quantity)))  into m_Qty
    from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c, T_ShadeGroup d
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    a.KNTITRANSACTIONTYPEID in (5,8,3,9,6,101,102,22,26,24,111,112,18,161,162,141,142,20) and
    b.ShadeGroupID=d.ShadeGroupID and
    b.OrderNo = pOrderNo;

/*Line 40   Total Process Loss (kg) Others*/
elsif 	mTransactionType=165 then
   select -(sum(decode(a.KNTITRANSACTIONTYPEID,12,b.Quantity,13,-b.Quantity,4,b.Quantity,10,-b.Quantity,7,-b.Quantity,23,b.Quantity,27,-b.Quantity,25,-b.Quantity,37,b.Quantity,38,b.Quantity,34,-b.Quantity,40,-b.Quantity)))  into m_Qty
    from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c, T_ShadeGroup d
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    a.KNTITRANSACTIONTYPEID in (12,13,4,10,7,23,27,25,37,38,34,40) and
    b.ShadeGroupID=d.ShadeGroupID and
    b.OrderNo = pOrderNo;

/*Line 41    Total Process Loss (%) Floor*/
elsif 	mTransactionType=166 then

  select -(sum(decode(a.KNTITRANSACTIONTYPEID,5,b.Quantity,8,-b.Quantity,3,b.Quantity,9,-b.Quantity,6,-b.Quantity,101,b.Quantity,102,-b.Quantity,22,b.Quantity,26,-b.Quantity,24,-b.Quantity,111,b.Quantity,112,-b.Quantity,18,b.Quantity,161,b.Quantity,162,-b.Quantity,141,b.Quantity,142,-b.Quantity,20,-b.Quantity))/sum(decode(a.KNTITRANSACTIONTYPEID,5,b.Quantity,11,-b.Quantity,3,b.Quantity,9,-b.Quantity,101,b.Quantity,102,-b.Quantity,22,b.Quantity,26,-b.Quantity,111,b.Quantity,112,-b.Quantity,18,b.Quantity,161,b.Quantity,162,-b.Quantity,19,b.Quantity,141,b.Quantity,142,-b.Quantity)))*100  into m_Qty
    from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c, T_ShadeGroup d
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    a.KNTITRANSACTIONTYPEID in (5,8,3,9,6,101,102,22,26,24,111,112,18,161,162,141,142,20,5,11,3,9,101,102,22,26,111,112,18,161,162,19,141,142) and
    b.ShadeGroupID=d.ShadeGroupID and
    b.OrderNo = pOrderNo;

/*Line 41   Total Process Loss (%) Others*/
elsif 	mTransactionType=167 then
   select -(sum(decode(a.KNTITRANSACTIONTYPEID,12,b.Quantity,13,-b.Quantity,4,b.Quantity,10,-b.Quantity,7,-b.Quantity,23,b.Quantity,27,-b.Quantity,25,-b.Quantity,37,b.Quantity,38,b.Quantity,34,-b.Quantity,40,-b.Quantity))/sum(decode(a.KNTITRANSACTIONTYPEID,12,b.Quantity,14,-b.Quantity,4,b.Quantity,10,-b.Quantity,23,b.Quantity,27,-b.Quantity,37,b.Quantity,38,b.Quantity,39,b.Quantity,34,-b.Quantity)))*100  into m_Qty
    from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c, T_ShadeGroup d
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    a.KNTITRANSACTIONTYPEID in  (12,13,4,10,7,23,27,25,37,38,34,40,12,14,4,10,23,27,37,38,39,34) and
    b.ShadeGroupID=d.ShadeGroupID and
    b.OrderNo = pOrderNo;


/*Line 42   Total Process Loss (%) Others  test*/
elsif 	mTransactionType=168 then
   select -(sum(decode(a.KNTITRANSACTIONTYPEID,5,b.Quantity,8,-b.Quantity,3,b.Quantity,9,-b.Quantity,6,-b.Quantity,101,b.Quantity,102,-b.Quantity,22,b.Quantity,26,-b.Quantity,24,-b.Quantity,111,b.Quantity,112,-b.Quantity,18,b.Quantity,161,b.Quantity,162,-b.Quantity,141,b.Quantity,142,-b.Quantity,20,-b.Quantity,12,b.Quantity,13,-b.Quantity,4,b.Quantity,10,-b.Quantity,7,-b.Quantity,23,b.Quantity,27,-b.Quantity,25,-b.Quantity,37,b.Quantity,38,b.Quantity,34,-b.Quantity,40,-b.Quantity))/sum(decode(a.KNTITRANSACTIONTYPEID,5,b.Quantity,11,-b.Quantity,3,b.Quantity,9,-b.Quantity,101,b.Quantity,102,-b.Quantity,22,b.Quantity,26,-b.Quantity,111,b.Quantity,112,-b.Quantity,18,b.Quantity,161,b.Quantity,162,-b.Quantity,19,b.Quantity,141,b.Quantity,142,-b.Quantity,12,b.Quantity,14,-b.Quantity,4,b.Quantity,10,-b.Quantity,23,b.Quantity,27,-b.Quantity,37,b.Quantity,38,b.Quantity,39,b.Quantity,34,-b.Quantity)))*100  into m_Qty
    from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c, T_ShadeGroup d
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    a.KNTITRANSACTIONTYPEID in  (5,8,3,9,6,101,102,22,26,24,111,112,18,161,162,141,142,20,5,11,3,9,101,102,22,26,111,112,18,161,162,19,141,142,12,13,4,10,7,23,27,25,37,38,34,40,12,14,4,10,23,27,37,38,39,34) and
    b.ShadeGroupID=d.ShadeGroupID and
    b.OrderNo = pOrderNo;


/*Line 42   Total Process Loss (%) Others  test*/
elsif 	mTransactionType=169 then
   select -(sum(decode(a.KNTITRANSACTIONTYPEID,5,b.Quantity,8,-b.Quantity,3,b.Quantity,9,-b.Quantity,6,-b.Quantity,101,b.Quantity,102,-b.Quantity,22,b.Quantity,26,-b.Quantity,24,-b.Quantity,111,b.Quantity,112,-b.Quantity,18,b.Quantity,161,b.Quantity,162,-b.Quantity,141,b.Quantity,142,-b.Quantity,20,-b.Quantity,12,b.Quantity,13,-b.Quantity,4,b.Quantity,10,-b.Quantity,7,-b.Quantity,23,b.Quantity,27,-b.Quantity,25,-b.Quantity,37,b.Quantity,38,b.Quantity,34,-b.Quantity,40,-b.Quantity))/sum(decode(a.KNTITRANSACTIONTYPEID,5,b.Quantity,11,-b.Quantity,3,b.Quantity,9,-b.Quantity,101,b.Quantity,102,-b.Quantity,22,b.Quantity,26,-b.Quantity,111,b.Quantity,112,-b.Quantity,18,b.Quantity,161,b.Quantity,162,-b.Quantity,19,b.Quantity,141,b.Quantity,142,-b.Quantity,12,b.Quantity,14,-b.Quantity,4,b.Quantity,10,-b.Quantity,23,b.Quantity,27,-b.Quantity,37,b.Quantity,38,b.Quantity,39,b.Quantity,34,-b.Quantity)))*100  into m_Qty
    from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c, T_ShadeGroup d
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    a.KNTITRANSACTIONTYPEID in  (5,8,3,9,6,101,102,22,26,24,111,112,18,161,162,141,142,20,5,11,3,9,101,102,22,26,111,112,18,161,162,19,141,142,12,13,4,10,7,23,27,25,37,38,34,40,12,14,4,10,23,27,37,38,39,34) and
    b.ShadeGroupID=d.ShadeGroupID and
    b.OrderNo = pOrderNo;

end if;
		return nvl(m_Qty,0);
END getfncTranSactionTWiseQty;
/




CREATE OR REPLACE FUNCTION getfncyarntype(yrntpid in VARCHAR2)
RETURN varchar2
IS
yarntypeName  t_yarntype.yarntype%type;
BEGIN
select yarntype into yarntypeName   from t_yarntype where yarntypeid=yrntpid;
return yarntypeName;

END getfncyarntype;
/

CREATE OR REPLACE FUNCTION getTmpClient(Clientrefr in VARCHAR2)
RETURN varchar2
IS
pClientID varchar2(40);
BEGIN
select ClientID into pClientID from t_Client where ClientRef=Clientrefr;
return ltrim(rtrim(pClientID));
END getTmpClient;
/


CREATE OR REPLACE FUNCTION getfncWOBType(pOrderNo in NUMBER)
RETURN varchar2
IS
WOBTName  T_WorkOrder.BASICTYPEID%type;
BEGIN
select basictypeID || ' ' || dOrderNo into WOBTName from T_WorkOrder where OrderNo=pOrderNo;
return WOBTName;

END getfncWOBType;
/

CREATE OR REPLACE FUNCTION getfncDispalyorder(pOrderNo in NUMBER)
RETURN varchar2
IS
WOBTName  T_WorkOrder.BASICTYPEID%type;
BEGIN
select ORDERTYPEID || ' ' || GDOrderNo into WOBTName from T_GWorkOrder where GOrderNo=pOrderNo;
return WOBTName;

END getfncDispalyorder;
/

Create or Replace function getFncdWorkOrder(
pOrderNo varchar2)
return varchar2

is
cursor c1 is
select a.basictypeID from t_basicworkOrder a,t_basicType b
 where a.basictypeID=b.basictypeID and workorderno= pOrderNo order by BASICTYPESL asc;
myrec c1%rowtype;
mReturntext varchar2(500);
begin
 for myrec in c1
  loop
      mReturntext:= mReturntext || getfncBasicType(myrec.basictypeID) ||', ' ;
     end loop;

  return  substr((mReturntext),1,length((mReturntext))-2);
end getFncdWorkOrder;
/



CREATE OR REPLACE FUNCTION getfncMachine(mMachineID in number)
RETURN varchar2
IS
pMachineName  varchar2(200);
BEGIN
	 select a.KNITMCDIA ||'/'|| a.KNITMCGAUGE ||'/'|| a.RATEDCAPACITY into pMachineName   from t_knitmachineinfo a
	 where a.MACHINEID=ltrim(rtrim(mMachineID));
return pMachineName;
END getfncMachine;
/

CREATE OR REPLACE FUNCTION getfncSalesTerm(SalID in VARCHAR2)
RETURN varchar2
IS
SalesTermDesc  t_salesterm.salesterm%type;
BEGIN
select salesTerm into SalesTermDesc   from t_salesterm where SalesTermID=SalID;
return SalesTermDesc;

END getfncSalesTerm;
/
CREATE OR REPLACE FUNCTION getfncSubConName(psubConID in VARCHAR2)
RETURN varchar2
IS
pSubConName t_subcontractors.SUBCONNAME%type;
BEGIN
	 select SUBCONNAME into pSubConName   from t_subcontractors
	 where t_subcontractors.SUBCONID=ltrim(rtrim(psubConID));
return pSubConName;
END getfncSubConName;
/


CREATE OR REPLACE FUNCTION getfncunitofmeas(unitid in VARCHAR2)
RETURN varchar2
IS
unitmeas  t_unitofmeas.unitofmeas%type;
BEGIN
select unitofmeas into unitmeas   from t_unitofmeas where unitofmeasid=unitid;
return unitmeas;

END getfncunitofmeas;
/

CREATE OR REPLACE FUNCTION getfncyarncount(yncntid in VARCHAR2)
RETURN varchar2
IS
yarnCountName  t_yarnCount.yarnCount%type;
BEGIN
select yarnCount into yarnCountName   from t_yarnCount where yarncountid=yncntid;
return yarnCountName;

END getfncyarncount;
/


CREATE OR REPLACE function getFncYarnDes(
pOrderLineItem varchar2)
return varchar2

is
cursor c1 is select yarnCount || ' ' || yarntype || '-' || yarnpercent || ',' as YP
from T_YarnDesc a, T_YarnCount b, T_YarnType c
where a.YarnCountId=b.YarnCountId and
a.YarnTypeId=c.YarnTypeId and
orderlineitem= pOrderLineItem;

myrec c1%rowtype;
mReturntext varchar2(500);
begin

        for myrec in c1
                loop
                    mReturntext:= mReturntext || myrec.YP;
        end loop;
        return  mReturntext;
end getFncYarnDes;
/



create or replace function GetOrderBasicTypes(
pOrderNo NUMBER
) return varchar2
is
cursor c1 is 
select b.BasicTypeID from T_BasicWorkorder a,T_basictype b 
where a.BASICTYPEID=b.BASICTYPEID and WorkorderNo=pOrderNo ORDER BY a.workOrderNo,b.BASICTYPESL;
myrec c1%rowtype;
mReturntext varchar2(200);
begin
        for myrec in c1
        loop
                    mReturntext := mReturntext || myrec.basicTypeID;
        end loop;
        return  mReturntext;

end GetOrderBasicTypes;
/    

CREATE OR REPLACE FUNCTION getfncyarntype(yrntpid in VARCHAR2)
RETURN varchar2
IS
yarntypeName  t_yarntype.yarntype%type;
BEGIN
select yarntype into yarntypeName   from t_yarntype where yarntypeid=yrntpid;
return yarntypeName;

END getfncyarntype;
/
CREATE OR REPLACE FUNCTION getTmpClient(Clientrefr in VARCHAR2)
RETURN varchar2
IS
pClientID varchar2(40);
BEGIN
select ClientID into pClientID from t_Client where ClientRef=Clientrefr;
return ltrim(rtrim(pClientID));
END getTmpClient;
/
CREATE OR REPLACE FUNCTION getTmpFabricType(FID in VARCHAR2)
RETURN varchar2
IS
FAbID  varchar2(20);
BEGIN
select fabricTypeID into FAbID from t_fabrictype where t_fabrictype.fabrictype=FID;
return FAbID;

END  getTmpFabricType;
/
CREATE OR REPLACE FUNCTION gettmpWorkOrder(batype in VARCHAR2,Ordernoref varchar2)
RETURN number
IS
OrderNOD  t_workorder.orderno%type;
BEGIN
	 select orderNO into OrderNOD  from t_WorkOrder
	 where basictypeid=batype and Orderref=Ordernoref;
return OrderNOD;
END gettmpWorkOrder;
/

//====================================================================================
// Exp LC	
//====================================================================================

CREATE OR REPLACE FUNCTION getfncGroup(gID in number)
RETURN varchar2
IS
R_GROUPNAME T_Accgroup.GROUPNAME%type;
BEGIN
	 select GROUPNAME into R_GROUPNAME from T_Accgroup
	 where GROUPID=gID;
return R_GROUPNAME;
END getfncGroup;
/


Create or Replace function getAccessories_Name(pLCNo number)
return varchar2

is
cursor c1 is
SELECT b.ITEM ITEM,getfncGroup(b.GROUPID) GroupName
FROM T_AccImpLCItems a,T_Accessories b
WHERE a.ACCESSORIESID=b.ACCESSORIESID AND a.LCNo=pLCNo 
ORDER BY PID;
myrec c1%rowtype;
mReturntext varchar2(5000);
begin
 for myrec in c1
  loop
      mReturntext:= mReturntext ||' '|| myrec.ITEM || ', ' ;
  end loop;

  return  substr(mReturntext,1,length(rtrim(mReturntext))-1);
end getAccessories_Name;
/


Create or Replace function getAux_Name(pLCNo number)
return varchar2

is
cursor c1 is
SELECT getfncAuxeTypeName(a.AUXTYPEID) AuxTypeName,b.AUXNAME AUXNAME,getfncDyeBaseName(b.DYEBASEID) DyeBaseName 
FROM T_AuxImpLCItems a,T_AUXILIARIES b
WHERE a.AUXTYPEID=b.AUXTYPEID AND a.AUXID=b.AUXID
AND a.LCNo=pLCNo 
ORDER BY PID;
myrec c1%rowtype;
mReturntext varchar2(500);
begin
 for myrec in c1
  loop
      mReturntext:= mReturntext || myrec.AUXNAME ||' '|| myrec.DyeBaseName ||' ' || myrec.AuxTypeName || ', ' ;
  end loop;

  return  substr(mReturntext,1,length(rtrim(mReturntext))-1);
end getAux_Name;
/


Create or Replace function getYarn_Count_Type_Name(pLCNo number)
return varchar2

is
cursor c1 is
SELECT CountID,getfncyarncount(countID) AS CountName,YarnTypeID,getfncyarntype(YarnTypeID) AS TypeName
FROM T_YarnImpLCItems
WHERE LCNo=pLCNo 
ORDER BY PID;
myrec c1%rowtype;
mReturntext varchar2(500);
begin
 for myrec in c1
  loop
      mReturntext:= mReturntext || myrec.CountName ||' '|| myrec.TypeName ||', ' ;
  end loop;

  return  substr(mReturntext,1,length(rtrim(mReturntext))-1);
end getYarn_Count_Type_Name;
/


CREATE OR REPLACE FUNCTION getfncAuxeTypeName(pID in number)
RETURN varchar2
IS
AuxTypeNAME T_AUXTYPE.AUXTYPE%type;
BEGIN
	 select AUXTYPE into AuxTypeNAME from T_AUXTYPE
	 where AUXTYPEID=pID;
return AuxTypeNAME;
END getfncAuxeTypeName;
/


CREATE OR REPLACE FUNCTION getfncDyeBaseName(pID in number)
RETURN varchar2
IS
DYEBASENAME T_DyeBase.DYEBASE%type;
BEGIN
	 select DYEBASE into DYEBASENAME from T_DyeBase
	 where DYEBASEID=pID;
return DYEBASENAME;
END getfncDyeBaseName;
/



CREATE OR REPLACE FUNCTION getfncSupplier(sID in number)
RETURN varchar2
IS
SUPPLIERNAME  T_Supplier.SUPPLIERNAME%type;
BEGIN
	 select SUPPLIERNAME into SUPPLIERNAME from T_Supplier
	 where SUPPLIERID=sID;
return SUPPLIERNAME;
END getfncSupplier;
/


CREATE OR REPLACE FUNCTION getClientRef(pOrderNo in NUMBER)
RETURN varchar2
IS
WOBTName  varchar2(400);
BEGIN
select CLIENTSREF into WOBTName from T_GWorkOrder where GOrderNo=pOrderNo;
return WOBTName;

END getClientRef;
/


CREATE OR REPLACE FUNCTION getFabricType1(FID in VARCHAR2)
RETURN varchar2
IS
FAbID  varchar2(200);
BEGIN
	select fabricType into FAbID from t_fabrictype 
	where t_fabrictype.fabrictypeid=FID;
return FAbID;

END  getFabricType1;
/

//====================================================================================
// dyeline		
//====================================================================================
CREATE OR REPLACE FUNCTION getProdHour(
  dStart IN VARCHAR2,
  dEnd IN VARCHAR2
) return VARCHAR2
AS
  vSTime date;
  vETime date;
  vDiff NUMBER;
  vHour NUMBER;
  vMinute NUMBER;
BEGIN

  if (not dStart is NULL) and  (not dEnd is NULL) then
    vSTime := TO_DATE(dStart,'DD/MM/YYYY HH:MI AM');
    vETime := TO_DATE(dEnd,'DD/MM/YYYY HH:MI AM');

    if vSTime < vETime then
      vDiff := (vETime - vSTime)*24;

      vHour := TRUNC(vDiff);
      vMinute := ROUND((vDiff - vHour)*60);

      return TO_CHAR(vHour) || ':' || TO_CHAR(vMinute,'00');
    else
      return 'ERROR';
    end if;
  else
    return NULL;
  end if;

END getProdHour;
/




CREATE OR REPLACE FUNCTION getProdDT(
  dEnd IN VARCHAR2
) return DATE
AS
  vEDATE date;
  vPDATE date;
  shift date;
    faults EXCEPTION;
BEGIN

  if (not dEnd is NULL) then
    vEDATE := TO_DATE(dEnd,'DD/MM/YYYY HH:MI AM');

    shift := TO_DATE(substr(dEnd,1,10) || ' 6:00 am', 'DD/MM/YYYY HH:MI AM');


    if (vEDATE >= shift)  then
      	return (TO_DATE(vEDATE));
    else 
	vPDATE:=(vEDATE-1);
	return (TO_DATE(vPDATE));
    end if;
  else
    return NULL;
  end if;

END getProdDT;
/


CREATE OR REPLACE FUNCTION getProdShift (
  prodDate IN VARCHAR2, 
  dStart IN VARCHAR2,
  eStart IN VARCHAR2
) RETURN VARCHAR2
AS 
  vSTime date;
  shiftA date;
  shiftB date;
  shiftC date;
  dShift VARCHAR2(10);
BEGIN 

  if (not dStart is NULL) then
    vSTime := TO_DATE(dStart,'DD/MM/YYYY HH:MI AM');

    shiftA := TO_DATE(substr(dStart,1,10) || ' 6:00 am', 'DD/MM/YYYY HH:MI AM');
    shiftB := TO_DATE(substr(dStart,1,10) || ' 2:00 pm', 'DD/MM/YYYY HH:MI AM');
    shiftC := TO_DATE(substr(dStart,1,10) || ' 10:00 pm', 'DD/MM/YYYY HH:MI AM');


    if (vSTime >= shiftA)  then
	if (vSTime <= shiftB)  then
        	dShift := 'A';
	elsif (vSTime <= shiftC)  then
		dShift := 'B';
	else
		dShift := 'C';
	end if;
    else 
	dshift :='C';
    end if;
 end if;

  return dShift;

--  dbms_output.put_line(dShift);

END getProdShift;
/


//====================================================================================
// Acc		
//====================================================================================

CREATE OR REPLACE function getgsizeDesc(
pOrderLineItem varchar2)
return varchar2

is
cursor c1 is select b.SIZENAME || '-' || QUANTITY || ', ' as GS
from T_GORDERSIZE a, T_SIZE b
where a.SIZEID=b.SIZEID and
orderlineitem= pOrderLineItem;

myrec c1%rowtype;
mReturntext varchar2(500);
begin

        for myrec in c1
                loop
                    mReturntext:= mReturntext || myrec.GS;
        end loop;
        return  mReturntext;
end getgsizeDesc;
/



//====================================================================================
// Acc		
//====================================================================================

CREATE OR REPLACE function getFncFabricDes(
pOrderNo number)
return varchar2

is
cursor c1 is select DISTINCT(FabricType)  as FType
from T_FabricType a, T_OrderItems b
where a.FabricTypeId=b.FabricTypeId and
b.OrderNo=pOrderNo;

myrec c1%rowtype;
mReturntext varchar2(500);
begin

        for myrec in c1
                loop
                    mReturntext:= mReturntext || ' ' || myrec.FType;
        end loop;
        return  mReturntext;
end getFncFabricDes;
/

Create or Replace FUNCTION getBudgetYQtyKg(pFabpid in number)
RETURN Number
IS
Byqty  t_yarncost.quantity%type;
BEGIN
select sum(b.Quantity) into Byqty from t_budget a,t_yarncost b,t_fabricconsumption c
where a.budgetid=b.budgetid  and b.ppid=c.pid and a.revision=65 and b.ppid=pFabpid;
return Byqty;

END getBudgetYQtyKg;
/
CREATE OR REPLACE FUNCTION BREVCHECK(pBudgetno in varchar2,pOdertypeid in Varchar2)
return varchar2
is
Revno varchar2(50);
Begin
Select count(budgetno)-1 into revno from t_budget 
where budgetno=pBudgetno and ordertypeid=pOdertypeid;
Return Revno;
End BREVCHECK;
/

CREATE OR REPLACE FUNCTION getBudgetYQty(pbudgetid in number)
	RETURN Number
IS
	Bqty  t_yarncost.quantity%type;
BEGIN
select sum(b.totalcost) into Bqty from t_budget a,t_yarncost b,t_fabricconsumption c
	where a.budgetid=b.budgetid  and b.ppid=c.pid and a.revision=65 and b.ppid=pbudgetid;
return Bqty;
END getBudgetYQty;
/


CREATE OR REPLACE FUNCTION getBudgetKcost(psid in number)
RETURN Number
IS
Bqty  t_kdfcost.totalcost%type;
BEGIN
select sum(b.totalcost) into Bqty from t_budget a,t_kdfcost b,t_fabricconsumption c
where a.budgetid=b.budgetid  and b.ppid=c.pid and a.revision=65 and b.ppid=psid and b.stageid=3 ;
return Bqty;

END getBudgetKcost;
/



CREATE OR REPLACE FUNCTION getBudgetDcost(pbudgetid in number)
RETURN Number
IS
Bqty  t_kdfcost.totalcost%type;
BEGIN
select totalcost into Bqty from t_budget a,t_kdfcost b
where a.budgetid=b.budgetid and a.revision=65 and a.budgetid=pbudgetid and b.stageid=4;
return Bqty;

END getBudgetDcost;
/

CREATE OR REPLACE FUNCTION getBudgetFcost(pbudgetid in number)
RETURN Number
IS
Bqty  t_kdfcost.totalcost%type;
BEGIN
select sum(totalcost) into Bqty from t_budget a,t_kdfcost b
where a.budgetid=b.budgetid and a.revision=65 and a.budgetid=pbudgetid and b.stageid=5;
return Bqty;

END getBudgetFcost;
/


CREATE OR REPLACE FUNCTION getBudgetAcost(pbudgetid in number)
RETURN Number
IS
Bqty  t_Garmentscost.totalcost%type;
BEGIN
select sum(totalcost) into Bqty from t_budget a,t_Garmentscost b
where a.budgetid=b.budgetid and a.revision=65 and a.budgetid=pbudgetid and b.stageid=7;
return Bqty;

END getBudgetAcost;
/

CREATE OR REPLACE FUNCTION getBudgetEmbCost(pbudgetid in number)
RETURN Number
IS
Bqty  t_Garmentscost.totalcost%type;
BEGIN
select sum(totalcost) into Bqty from t_budget a,t_Garmentscost b
where a.budgetid=b.budgetid and a.revision=65 and a.budgetid=pbudgetid and b.stageid=8;
return Bqty;

END getBudgetEmbCost;
/

CREATE OR REPLACE FUNCTION getBudgetCmCost(pbudgetid in number)
RETURN Number
IS
Bqty  t_Garmentscost.totalcost%type;
BEGIN
select sum(totalcost) into Bqty from t_budget a,t_Garmentscost b
where a.budgetid=b.budgetid and a.revision=65 and a.budgetid=pbudgetid and b.stageid=9;
return Bqty;

END getBudgetCmCost;
/

CREATE OR REPLACE FUNCTION getBudgetOthCost(pbudgetid in number)
RETURN Number
IS
Bqty  t_Garmentscost.totalcost%type;
BEGIN
select sum(totalcost) into Bqty from t_budget a,t_Garmentscost b
where a.budgetid=b.budgetid and a.revision=65 and a.budgetid=pbudgetid and b.stageid=11;
return Bqty;

END getBudgetOthCost;
/
Create or Replace function BugetworderRef(pBudgetid number)
return varchar2
is
cursor c1 is
SELECT getfncWOBType(a.orderno) texorderno
FROM T_workorder a where a.budgetid=pBudgetid 
ORDER BY orderno;
myrec c1%rowtype;
mReturntext varchar2(500);
begin
 for myrec in c1
  loop
      mReturntext:= mReturntext ||' '|| myrec.texorderno || ', ' ;
  end loop;

  return  substr(mReturntext,1,length(rtrim(mReturntext))-1);
end BugetworderRef;
/

CREATE OR REPLACE FUNCTION getBudgetQty(pbudgetid in number)
RETURN Number
IS
Bqty  t_yarncost.quantity%type;
BEGIN
select sum(b.quantity) into Bqty from t_budget a,t_yarncost b
where a.budgetid=b.budgetid and a.revision=65 and a.budgetid=pbudgetid;
return Bqty;

END getBudgetQty;
/

CREATE OR REPLACE FUNCTION getOrderQty(pgorderno in number)
RETURN Number
IS
Oqty  t_gorderitems.quantity%type;
BEGIN
select sum(a.quantity) into Oqty from t_gorderitems a
where a.gorderno=pgorderno;
return Oqty;

END getOrderQty;
/


CREATE OR REPLACE FUNCTION getTexOrderQty(pgorderno in number)
RETURN Number
IS
texqty  t_orderitems.quantity%type;
BEGIN
select sum(c.quantity) into texqty from t_workorder b,t_orderitems c
where b.orderno=c.orderno and b.orderno=pgorderno;

return texqty;

END getTexOrderQty;
/

create or replace FUNCTION getfncDispalyorder(pOrderNo in NUMBER)
RETURN varchar2
IS
WOBTName  T_WorkOrder.BASICTYPEID%type;
BEGIN
select ORDERTYPEID || ' ' || GDOrderNo into WOBTName from T_GWorkOrder where GOrderNo=pOrderNo;
return WOBTName;

END getfncDispalyorder;
/

CREATE OR REPLACE FUNCTION fncAuxAvgPrice(pAuxID in NUMBER,pAuxTypeID in Number,pDyelineDate in DATE)
RETURN number
IS
AuxPrice  number(20,2);
BEGIN
select nvl(round(a.UNITPRICE,2),0) into AuxPrice 
from T_AuxPrice a
where a.AUXTYPEID=pAuxTypeID and      
      a.AUXID=pAuxID and 
	  a.PURCHASEDATE=(select MAX(PURCHASEDATE) from T_Auxprice where AUXTYPEID=pAuxTypeID and      
      AUXID=pAuxID and PURCHASEDATE<=pDyelineDate);
return AuxPrice;
END  fncAuxAvgPrice;
/

CREATE OR REPLACE FUNCTION fncYarnAvgPrice(pCOUNTID in VARCHAR2,pYARNTYPEID in VARCHAR2,pYARNBATCHNO in VARCHAR2,pDate in DATE)
RETURN number
IS
YarnPrice  number(20,2);
BEGIN
select nvl(round(a.UNITPRICE,2),0) into YarnPrice 
from T_YarnPrice a
where a.COUNTID=pCOUNTID  and
	a.YARNTYPEID=pYARNTYPEID and  
	trim(a.YARNBATCHNO)=trim(pYARNBATCHNO) and   
	a.PURCHASEDATE=(select MAX(PURCHASEDATE) from T_Yarnprice where COUNTID=pCOUNTID  and
	YARNTYPEID=pYARNTYPEID and trim(YARNBATCHNO)=trim(pYARNBATCHNO) and PURCHASEDATE<=pDate);
return YarnPrice;
END  fncYarnAvgPrice;
/
CREATE OR REPLACE FUNCTION fncYarnAvgPricewithSupp(pCOUNTID in VARCHAR2,pYARNTYPEID in VARCHAR2,pYARNBATCHNO in VARCHAR2,pSuppid in NUMBER,pDate in DATE)
RETURN number
IS
YarnPrice  number(20,2);
BEGIN
select nvl(round(a.UNITPRICE,2),0) into YarnPrice 
from T_YarnPrice a
where a.COUNTID=pCOUNTID  and
	a.YARNTYPEID=pYARNTYPEID and 
	a.SupplierID=pSuppid and 
	trim(a.YARNBATCHNO)=trim(pYARNBATCHNO) and   
	a.PURCHASEDATE=(select MAX(PURCHASEDATE) from T_Yarnprice where COUNTID=pCOUNTID  and SupplierID=pSuppid and 
	YARNTYPEID=pYARNTYPEID and trim(YARNBATCHNO)=trim(pYARNBATCHNO) and PURCHASEDATE<=pDate);
return YarnPrice;
END  fncYarnAvgPricewithSupp;
/

Create or Replace Function User_Role(pUserid in varchar2) 
return varchar2
is
empid Varchar2(50);
Begin
 select EMPID into empid   from T_EMPLOYEEASSIGN
  where EMPID=pUserid;
Return empid;
End User_Role;
/

CREATE OR REPLACE FUNCTION getfncAuxAvgPrice(pAUXID in number,pDyelineDate in Date)
RETURN number
IS
 UNITPRICETK  T_AUXPRICE.UNITPRICE%type;
 tmpCheck number DEFAULT 0;
 tmpPURCHASEDATE DATE;
BEGIN
	SELECT count(*) into tmpCheck FROM T_AUXPRICE WHERE AUXID=pAUXID;

if (tmpCheck>0) then
	SELECT MAX(PURCHASEDATE) into tmpPURCHASEDATE FROM T_AUXPRICE 
	WHERE AUXID=pAUXID AND PURCHASEDATE<=pDyelineDate;

	if (tmpPURCHASEDATE<>NULL) then
  		SELECT UNITPRICE into UNITPRICETK FROM T_AUXPRICE WHERE AUXID=pAUXID AND 
		PURCHASEDATE=tmpPURCHASEDATE;
	else
		UNITPRICETK:=0;
	end if;

else
	UNITPRICETK:=0;
end if;
return UNITPRICETK;

END getfncAuxAvgPrice;
/


PROMPT CREATE OR REPLACE Function  B31:: getfncBOType
CREATE OR REPLACE FUNCTION getfncBOType(pbudgetid in NUMBER)
RETURN varchar2
IS
BOName varchar2(100);
BEGIN
select OrdertypeID || ' ' || BudgetNo into BOName from T_Budget where Budgetid=pbudgetid;
return BOName ;
END getfncBOType;
/


CREATE OR REPLACE FUNCTION GETYARNQTY(pbudgetid in number,pFabricTypeID in varchar2)
RETURN Number
IS
	Bqty  T_yarncost.quantity%type;
	BEGIN
	select sum(a.QUANTITY) into Bqty from T_yarncost a,T_Budget b,t_fabricconsumption c
	where a.budgetid=pbudgetid and b.revision=65 and
	a.budgetid=b.budgetid and a.ppid=c.pid AND
	c.FABRICTYPEID=pFabricTypeID;
	return Bqty;
END GETYARNQTY;
/

CREATE OR REPLACE FUNCTION GETFINISHINGQTY(pbudgetid in number)
RETURN Number
IS
Bqty  T_kdfcost.quantity%type;
BEGIN
select sum(A.QUANTITY) into Bqty from T_kdfcost A,T_Budget b
where A.budgetid=pbudgetid and b.revision=65 and A.budgetid=b.budgetid and a.STAGEID=5;
return Bqty;
END GETFINISHINGQTY;
/

CREATE OR REPLACE FUNCTION GETDYEINGQTY(pbudgetid in number,pFabricTypeID in varchar2)
RETURN Number
IS
Bqty  T_kdfcost.quantity%type;
BEGIN
select sum(A.QUANTITY) into Bqty from T_kdfcost A,T_Budget b,T_fabricconsumption c
where A.budgetid=pbudgetid and b.revision=65 and A.budgetid=b.budgetid and a.STAGEID=4 and
      A.budgetid=c.budgetid and c.FABRICTYPEID=pFabricTypeID and c.pid=a.ppid;
return Bqty;
END GETDYEINGQTY;
/

CREATE OR REPLACE FUNCTION GETYARNCONSP(pOrder in number,pFabricTypeID in varchar2)
RETURN Number
IS
Bqty  T_knitstockitems.quantity%type;
BEGIN
select sum(decode(a.KNTITRANSACTIONTYPEID,3,B.QUANTITY,9,-B.QUANTITY,42,-B.QUANTITY,60,B.QUANTITY,101,B.QUANTITY,102,-B.QUANTITY,0)) into Bqty 
     from T_knitstock a, T_knitstockitems b
where A.Stockid=B.Stockid and b.ORDERNO=pOrder and b.FABRICTYPEID=pFabricTypeID and
      a.KNTITRANSACTIONTYPEID in (3,9,42,60,101,102);
return Bqty;
END GETYARNCONSP;
/

CREATE OR REPLACE FUNCTION GETDYEINGCONSP(pOrder in number,pFabricTypeID in varchar2)
RETURN Number
IS
Bqty  T_knitstockitems.quantity%type;
BEGIN
   select sum(decode(a.KNTITRANSACTIONTYPEID,19,b.Quantity))  into Bqty
    from T_Knitstock a, T_KnitStockItems b,T_knitTransactionType c, T_ShadeGroup d
    where a.StockID=b.StockID and
    a.KNTITRANSACTIONTYPEID=c.KNTITRANSACTIONTYPEID and
    a.KNTITRANSACTIONTYPEID in (19) and
	b.FABRICTYPEID=pFabricTypeID and
    b.ShadeGroupID=d.ShadeGroupID and
    b.OrderNo = pOrder;
return Bqty;
END GETDYEINGCONSP;
/

CREATE OR REPLACE FUNCTION GETFABRICCONSP(pOrder in number,pFabricTypeID in varchar2)
RETURN Number
IS
Bqty  T_knitstockitems.quantity%type;
BEGIN
select sum(decode(a.KNTITRANSACTIONTYPEID,24,B.QUANTITY,6,B.QUANTITY,0)) into Bqty 
     from T_knitstock a, T_knitstockitems b
where A.Stockid=B.Stockid and b.ORDERNO=pOrder and b.FABRICTYPEID=pFabricTypeID and
      a.KNTITRANSACTIONTYPEID in (24,6);
return Bqty;
END GETFABRICCONSP;
/

CREATE OR REPLACE FUNCTION GETFINISHINGCONSP(pOrder in number,pFabricTypeID in varchar2)
RETURN Number
IS
Bqty  T_knitstockitems.quantity%type;
BEGIN
select sum(decode(a.KNTITRANSACTIONTYPEID,20,B.QUANTITY,0)) into Bqty 
     from T_knitstock a, T_knitstockitems b
where A.Stockid=B.Stockid and b.ORDERNO=pOrder and b.FABRICTYPEID=pFabricTypeID and
      a.KNTITRANSACTIONTYPEID in (20);
return Bqty;
END GETFINISHINGCONSP;
/

Create or Replace Function LastPuchaseqty(pstatineyid in Number,pReqby in Number,preqdate date)
return number
is
mdate date;
qty Number;
Begin
select sum(quantity) into qty from T_Stationerystock a,T_StationeryStockItems b 
where  a.stockid=b.stockid and 
a.STOCKTRANSDATE=(
select max(STOCKTRANSDATE) from T_Stationerystock a,T_StationeryStockItems b
where  a.stockid=b.stockid and b.STATIONERYID=pstatineyid and b.transtypeid=1 and b.reqby=pReqby)
and b.STATIONERYID=pstatineyid and b.reqby=pReqby and b.transtypeid=1 and a.STOCKTRANSDATE<preqdate
group by b.STATIONERYID ;
return qty;
End;
/



PROMPT create or replace FUNCTION GORDERQTY
CREATE OR REPLACE FUNCTION GORDERQTY(pFtypid in varchar2,pShade in varchar2,pOrderno in Number)
return number
is
tqty Number(12,2);
Begin
select sum(quantity) into tqty from t_orderitems a,t_workorder b,t_gworkorder c
where a.orderno=b.orderno and b.GARMENTSORDERREF=c.gorderno and 
a.fabrictypeid=pFtypid and Trim(INITCAP(a.shade))=INITCAP(pShade) and c.gorderno=pOrderno
Group by a.fabrictypeid,Trim(INITCAP(a.shade)),a.orderno;
return tqty;
End GORDERQTY;
/

create or replace function cuttingno(pstockid in number)
return varchar
is
cuttingno varchar2(50);
Begin
Select distinct(STOCKTRANSNO) into cuttingno from t_gstock a, t_gstockitems b where a.stockid=b.stockid and gtranstypeid=3 and a.stockid=pstockid;
Return cuttingno;
End cuttingno;
/

Create or Replace Function Itemcurstock(pstatineyid in Number,pReqby in Number,preqdate date)
return number
is
qty Number;
Begin
select sum(MAINSTORE*Quantity) into qty from T_Stationerystock a,T_StationeryStockItems b,T_StationeryTransactionType c
 where  a.stockid=b.stockid and b.STATIONERYID=pstatineyid
 and b.reqby=pReqby and b.transtypeid=c.transtypeid  and a.STOCKTRANSDATE<=preqdate group by STATIONERYID;
return qty;
End;
/



Create or Replace function btbamount(pmlcno in Number)
return number
is
accamount Number(15,2);
auxamount Number(15,2);
yarnamount Number(15,2);
chk number;
chk1 number;
chk2 number;
Begin
select count(*) into chk from T_AccImpLC a,T_AccImpLCItems b where a.lcno=b.lcno and a.explcno=pmlcno;
if(chk>0) then
select Nvl(sum(valuefc),0) into accamount from T_AccImpLC a,T_AccImpLCItems b where a.lcno=b.lcno and a.explcno=pmlcno group by pmlcno;
else
accamount:=0.00;
end if;
select count(*) into chk1 from T_AuxImpLC a,T_AuxImpLCItems b where a.lcno=b.lcno and a.explcno=pmlcno;
if(chk1>0) then
select nvl(sum(valuefc),0) into auxamount from T_AuxImpLC a,T_AuxImpLCItems b where a.lcno=b.lcno and a.explcno=pmlcno group by pmlcno;
else
auxamount:=0.00;
end if;
select count(*) into chk2 from T_YarnImpLC a,T_YarnImpLCItems  b where a.lcno=b.lcno and a.explcno=pmlcno;
if(chk2>0) then
select nvl(sum(valuefc),0) into yarnamount from T_YarnImpLC a,T_YarnImpLCItems b where a.lcno=b.lcno and a.explcno=pmlcno group by pmlcno;
else
yarnamount:=0.00;
end if;
return (accamount+auxamount+yarnamount);

End;
/


Create or Replace function btbamounttk(pmlcno in Number)
return number
is
accamount Number(15,2);
auxamount Number(15,2);
yarnamount Number(15,2);
chk number;
chk1 number;
chk2 number;
Begin
select count(*) into chk from T_AccImpLC a,T_AccImpLCItems b where a.lcno=b.lcno and a.explcno=pmlcno;
if(chk!=0) then
select Nvl(sum(TotCost),0) into accamount from T_AccImpLC a,T_AccImpLCItems b where a.lcno=b.lcno and a.explcno=pmlcno group by pmlcno;
else
accamount:=0.00;
end if;
select count(*) into chk1 from T_AuxImpLC a,T_AuxImpLCItems b where a.lcno=b.lcno and a.explcno=pmlcno;
if(chk1!=0) then
select nvl(sum(TotCost),0) into auxamount from T_AuxImpLC a,T_AuxImpLCItems b where a.lcno=b.lcno and a.explcno=pmlcno group by pmlcno;
else
auxamount:=0.00;
end if;
select count(*) into chk2 from T_YarnImpLC a,T_YarnImpLCItems  b where a.lcno=b.lcno and a.explcno=pmlcno;
if(chk2!=0) then
select nvl(sum(TotCost),0) into yarnamount from T_YarnImpLC a,T_YarnImpLCItems b where a.lcno=b.lcno and a.explcno=pmlcno group by pmlcno;
else
yarnamount:=0.00;
end if;
return (accamount+auxamount+yarnamount);

End;
/

Create or Replace function orderkg(pOrderno in number)
return number
is
qty number(10,2);
Begin
select nvl(sum(quantity),0) into qty from t_workorder a,t_orderitems b where a.orderno=b.orderno and 
a.garmentsorderref=pOrderno;
return qty;
end;
/





Create or Replace function cutqty(pOrderno in number,pstyle in varchar2,psizeid in varchar2)
return number
is
qty number(10,2);
Begin
(select Nvl(sum(quantity),0) into qty from t_gstockitems y where y.orderno=pOrderno and y.styleno=pstyle and y.sizeid=psizeid and gtranstypeid=3 group by ORDERNO,sizeid,styleno) as Cutting,
return qty;
end;
/


  
Create or Replace function lcrealisedamt( pLcno in Number)
return Number
IS
  amount  Number(15,4);
Begin
    select sum(PAYRECEIVEAMT) into amount from t_lcpayment where t_lcpayment.lcno=pLcno group by t_lcpayment.lcno;
	return amount;
End;
/
	
	  Create or Replace function lcrealisedamtTk( pLcno in Number)
  return Number
  IS
  amount  Number(15,4);
  Begin
    select sum(PAYRECEIVEAMT*PUREXCHRATE) into amount from t_lcpayment where t_lcpayment.lcno=pLcno group by t_lcpayment.lcno;
	return amount;
	End;
	/
	
	
	  Create or Replace function lcbtbamount( pLcno in Number)
  return Number
  IS
  amount  Number(15,4);
  Begin
    select sum(DFCAMOUNT) into amount from t_lcpayment where t_lcpayment.lcno=pLcno group by t_lcpayment.lcno;
	return amount;
	End;
	/
	
	
	  Create or Replace function lcbtbamountTk( pLcno in Number)
  return Number
  IS
  amount  Number(15,4);
  Begin
    select sum(DFCAMOUNT*PUREXCHRATE) into amount from t_lcpayment where t_lcpayment.lcno=pLcno group by t_lcpayment.lcno;
	return amount;
	End;
	/
	
CREATE OR REPLACE FUNCTION fncTransOrder(pstockid in number,pknitstockitemsl in number)
RETURN varchar2
IS
workorder  varchar2(20);
BEGIN
select GetfncWOBType(OrderNo) into workorder from T_KnitStockItems
 where STOCKID=pstockid and KNTISTOCKITEMSL=pknitstockitemsl;
return workorder;

END fncTransOrder;
/




CREATE OR REPLACE FUNCTION getfncDispalybudgetid(pOrderNo in NUMBER)
RETURN varchar2
IS
WOBTName  T_WorkOrder.BASICTYPEID%type;
BEGIN
select ORDERTYPEID || ' ' || BUDGETNO into WOBTName from T_BUDGET where BUDGETID=pOrderNo;
return WOBTName;

END getfncDispalybudgetid;
/



CREATE OR REPLACE Procedure GetTDWorkOrderList
(
  data_cursor IN OUT pReturnData.c_Records,
  pBasictypeid varchar2
)
AS
BEGIN
	OPEN data_cursor for
    Select Basictypeid,Basictypeid || ' ' || DORDERNO as TDORDERNO,ORDERNO,DORDERNO
	from T_workorder 
	where Basictypeid=pBasictypeid 
	ORDER BY DORDERNO ASC;

END GetTDWorkOrderList;
/

create or replace FUNCTION getfncGSMfromOrderItems(pORDERLINEITEM in VARCHAR2)
RETURN NUMBER
IS
tempGSM NUMBER;
BEGIN
select FINISHEDGSM into tempGSM from T_ORDERITEMS where ORDERLINEITEM=pORDERLINEITEM;
return tempGSM;
END getfncGSMfromOrderItems;
/


CREATE OR REPLACE FUNCTION getfncDateTimeDistance(
  dStart IN TIMESTAMP,
  dEnd IN TIMESTAMP
) return Varchar2 
  IS 
  tmpDis Varchar2(100);
  temp Varchar2(100);
BEGIN
if (not dStart is NULL) and (not dEnd is NULL) and (dEnd>=dStart) then

	SELECT (extract(DAY FROM dEnd-dStart)*24)+ 
	(extract(HOUR FROM dEnd-dStart)) || 'H ' ||
	(extract(MINUTE FROM dEnd-dStart)) || 'M'
	into temp  FROM dual;

	tmpDis:= ltrim(temp);	
	return tmpDis;
else
    return 0;
end if;
END getfncDateTimeDistance;
/

CREATE OR REPLACE FUNCTION getfncDateTimeIntDistance(
  dStart IN TIMESTAMP,
  dEnd IN TIMESTAMP
) return NUMBER
  IS
  tmpDis NUMBER;
  temp NUMBER;
BEGIN
if (not dStart is NULL) and (not dEnd is NULL) and (dEnd>=dStart) then

 SELECT (extract(DAY FROM dEnd-dStart)*24)+
 (extract(HOUR FROM dEnd-dStart)) +
 (extract(MINUTE FROM dEnd-dStart)/60)
 into temp  FROM dual;

 tmpDis:= ltrim(temp);
 return tmpDis;
else
    return 0;
end if;
END getfncDateTimeIntDistance;
/



CREATE OR REPLACE FUNCTION fncTransCuttingOrder(pstockid in number,pgstockitemsl in number)
RETURN varchar2
IS
workorder  varchar2(20);
BEGIN
select getfncDispalyorder(OrderNo) into workorder from T_GStockItems
 where GTRANSTYPEID=122 AND STOCKID=pstockid and GSTOCKITEMSL=pgstockitemsl;
return workorder;

END fncTransCuttingOrder;
/


CREATE OR REPLACE FUNCTION fncTransGarmentsOrder(pstockid in number,pgstockitemsl in number)
RETURN varchar2
IS
workorder  varchar2(20);
BEGIN
select getfncDispalyorder(OrderNo) into workorder from T_GStockItems
 where GTRANSTYPEID=112 AND STOCKID=pstockid and GSTOCKITEMSL=pgstockitemsl;
return workorder;

END fncTransGarmentsOrder;
/


Create or Replace function getfncBudgetGARef(pBudgetid number)
return varchar2
is
cursor c1 is
SELECT ORDERNO as WAOrderNo
FROM T_GAWORKORDER where budgetid=pBudgetid 
ORDER BY orderno;
myrec c1%rowtype;
mReturntext varchar2(500);
begin
 for myrec in c1
  loop
      mReturntext:= mReturntext ||' '|| myrec.WAOrderNo || ', ' ;
  end loop;
  return  substr(mReturntext,1,length(rtrim(mReturntext))-1);
end getfncBudgetGARef;
/



	
CREATE OR REPLACE FUNCTION fncBudgetAcost(pbudgetid in number)
RETURN Number
IS
Bqty  t_Garmentscost.totalcost%type;
BEGIN
	select sum(totalcost) into Bqty from t_budget a,t_Garmentscost b
	where a.budgetid=b.budgetid and a.budgetid=pbudgetid and b.stageid=7;
	return Bqty;
END fncBudgetAcost;
/
	
	
CREATE OR REPLACE FUNCTION fncBudgetCmCost(pbudgetid in number)
RETURN Number
IS
Bqty  t_Garmentscost.totalcost%type;
BEGIN
	select sum(totalcost) into Bqty from t_budget a,t_Garmentscost b
	where a.budgetid=b.budgetid and a.budgetid=pbudgetid and b.stageid=9;
	return Bqty;
END fncBudgetCmCost;
/

CREATE OR REPLACE FUNCTION fncBudgetDcost(psid in number)
RETURN Number
IS
Bqty  t_kdfcost.totalcost%type;
BEGIN
	select sum(totalcost) into Bqty from t_budget a,t_kdfcost b
	where a.budgetid=b.budgetid  and  b.ppid=psid and b.stageid=4
	Group by a.budgetid;
	return Bqty;
END fncBudgetDcost;
/

CREATE OR REPLACE FUNCTION fncBudgetEmbCost(pbudgetid in number)
RETURN Number
IS
Bqty  t_Garmentscost.totalcost%type;
BEGIN
	select sum(totalcost) into Bqty from t_budget a,t_Garmentscost b
	where a.budgetid=b.budgetid and a.budgetid=pbudgetid and b.stageid=8;
	return Bqty;
END fncBudgetEmbCost;
/

CREATE OR REPLACE FUNCTION fncBudgetFcost(pbudgetid in number)
RETURN Number
IS
Bqty  t_kdfcost.totalcost%type;
BEGIN
	select sum(totalcost) into Bqty from t_budget a,t_kdfcost b
	where a.budgetid=b.budgetid and a.budgetid=pbudgetid and b.stageid=5;
return Bqty;
END fncBudgetFcost;
/

CREATE OR REPLACE FUNCTION fncBudgetKcost(psid in number)
RETURN Number
IS
Bqty  t_kdfcost.totalcost%type;
BEGIN
	select sum(b.totalcost) into Bqty from t_budget a,t_kdfcost b,t_fabricconsumption c
	where a.budgetid=b.budgetid  and b.ppid=c.pid and b.ppid=psid and b.stageid=3 ;
return Bqty;
END fncBudgetKcost;
/

CREATE OR REPLACE FUNCTION fncBudgetOthCost(pbudgetid in number)
RETURN Number
IS
Bqty  t_Garmentscost.totalcost%type;
BEGIN
	select sum(totalcost) into Bqty from t_budget a,t_Garmentscost b
	where a.budgetid=b.budgetid and a.budgetid=pbudgetid and b.stageid=11;
return Bqty;
END fncBudgetOthCost;
/

CREATE OR REPLACE FUNCTION fncBudgetYQty(pbudgetid in number)
RETURN Number
IS
Bqty  t_yarncost.quantity%type;
BEGIN
	select sum(b.totalcost) into Bqty from t_budget a,t_yarncost b,t_fabricconsumption c
	where a.budgetid=b.budgetid  and b.ppid=c.pid and b.ppid=pbudgetid;
return Bqty;
END fncBudgetYQty;
/

CREATE OR REPLACE FUNCTION fncBudgetYQtyKg(pFabpid in number)
RETURN Number
IS
Byqty  t_yarncost.quantity%type;
BEGIN
	select sum(b.Quantity) into Byqty from t_budget a,t_yarncost b,t_fabricconsumption c
	where a.budgetid=b.budgetid  and b.ppid=c.pid and b.ppid=pFabpid;
return Byqty;
END fncBudgetYQtyKg;
/


CREATE OR REPLACE FUNCTION fncBudgetYUPPKg(pFabpid in number)
RETURN Number
IS
ByuppKg  t_yarncost.UNITPRICE%type;
BEGIN
	select sum(b.UNITPRICE) into ByuppKg from t_budget a,t_yarncost b,t_fabricconsumption c
	where a.budgetid=b.budgetid  and b.ppid=c.pid and b.ppid=pFabpid;
return ByuppKg;
END fncBudgetYUPPKg;
/

CREATE OR REPLACE FUNCTION fncBudgetKUPPKg(psid in number)
RETURN Number
IS
BkuppKg  t_kdfcost.UNITPRICE%type;
BEGIN
	select sum(b.UNITPRICE) into BkuppKg from t_budget a,t_kdfcost b,t_fabricconsumption c
	where a.budgetid=b.budgetid  and b.ppid=c.pid and b.ppid=psid and b.stageid=3 ;
return BkuppKg;
END fncBudgetKUPPKg;
/

CREATE OR REPLACE FUNCTION fncBudgetDUPPKg(psid in number)
RETURN Number
IS
BduppKg  t_kdfcost.UNITPRICE%type;
BEGIN
	select sum(b.UNITPRICE) into BduppKg from t_budget a,t_kdfcost b,t_fabricconsumption c
	where a.budgetid=b.budgetid and b.ppid=c.pid and b.ppid=psid and b.stageid=4
	Group by a.budgetid;
	return BduppKg;
END fncBudgetDUPPKg;
/



create or replace function fncBudgetYarnDesc(pFabpid in number)
return varchar2
is
cursor c1 is select (YARNCOUNT || ' ' || YARNTYPE) AS YP from T_Yarncost a,T_YARNCOUNT b,T_YARNTYPE c
			where  a.YARNCOUNTID=b.YARNCOUNTID and a.YARNTYPEID=c.YARNTYPEID and a.ppid=pFabpid;
myrec c1%rowtype;
mReturntext varchar2(500);
begin
        for myrec in c1
                loop
                    mReturntext:= mReturntext || myrec.YP;
        end loop;
        return  mReturntext;
end fncBudgetYarnDesc;
/



CREATE OR REPLACE FUNCTION fncBudgetYCQty(pFabpid in number)
RETURN Number
IS
ByuppKg  t_yarncost.QUANTITY%type;
BEGIN
	select sum(b.QUANTITY) into ByuppKg from t_budget a,t_yarncost b,t_fabricconsumption c
	where a.budgetid=b.budgetid  and b.ppid=c.pid and b.ppid=pFabpid;
return ByuppKg;
END fncBudgetYCQty;
/

CREATE OR REPLACE FUNCTION fncBudgetKCQty(psid in number)
RETURN Number
IS
BkuppKg  t_kdfcost.QUANTITY%type;
BEGIN
	select sum(b.QUANTITY) into BkuppKg from t_budget a,t_kdfcost b,t_fabricconsumption c
	where a.budgetid=b.budgetid  and b.ppid=c.pid and b.ppid=psid and b.stageid=3 ;
return BkuppKg;
END fncBudgetKCQty;
/

CREATE OR REPLACE FUNCTION fncBudgetDCQty(psid in number)
RETURN Number
IS
BduppKg  t_kdfcost.QUANTITY%type;
BEGIN
	select sum(b.QUANTITY) into BduppKg from t_budget a,t_kdfcost b,t_fabricconsumption c
	where a.budgetid=b.budgetid and b.ppid=c.pid and b.ppid=psid and b.stageid=4
	Group by a.budgetid;
	return BduppKg;
END fncBudgetDCQty;
/


CREATE OR REPLACE FUNCTION fncBudgetRevenueAmt(pBUDGETID in number)
RETURN number
IS
tfmqty number;
mlcvalue number;
tgcqty number;
tfsqty number;
tfscost Number;
tordercost number;
tyc number;
id5 number;
id6 number;
id7 number;
BEGIN
		Select LCVALUE into mlcvalue from t_budget
		where budgetid=pBUDGETID;

	Select count(*) into id6 from t_Yarncost where budgetid=pBUDGETID;
		if(id6=0) then
			tyc:=0.0;
		else
			Select Nvl((sum(TOTALCOST)),0) into tyc from t_Yarncost where budgetid=pBUDGETID;
		end if;

	Select count(*) into id5 from t_kdfcost
		where budgetid=pBUDGETID and stageid in(3,4,5,6);
		if(id5=0) then
			tfsqty:=0.0;
		else
			Select Nvl((sum(TOTALCOST)),0) into tfsqty from t_kdfcost
			where budgetid=pBUDGETID and stageid in(3,4,5,6);
		end if;

	Select count(*) into id7 from t_kdfcost
		where budgetid=pBUDGETID and stageid=6;
		if(id7=0) then
			tfmqty:=0.0;
		else
			Select Nvl((sum(TOTALCOST)),0) into tfmqty from t_kdfcost
				where budgetid=pBUDGETID and stageid=6;
		end if;
		tfscost:=tyc+tfsqty;

		Select Nvl((sum(TOTALCOST)),0) into tgcqty from t_garmentscost
			where budgetid=pBUDGETID and stageid IN (7,8,9,11);

		tordercost:=tgcqty+tfscost-tfmqty;
		return tordercost;
END fncBudgetRevenueAmt;
/



create or replace FUNCTION getfncTWOQty(pOrderNo in NUMBER)
RETURN number
IS
totalQty  T_orderItems.QUANTITY%type;
BEGIN
select sum(QUANTITY) into totalQty from T_orderItems where OrderNo=pOrderNo;
return totalQty;
END getfncTWOQty;
/


CREATE OR REPLACE function fncTWOfromGWO(
pOrderNo number)
return varchar2
is
cursor c1 is select BASICTYPEID || ' ' || DORDERNO || ' ' as TWO
from T_WORKORDER
where GARMENTSORDERREF=pOrderNo;
myrec c1%rowtype;
mReturntext varchar2(500);
begin
        for myrec in c1
                loop
                    mReturntext:= mReturntext || myrec.TWO;
        end loop;
        return  mReturntext;
end fncTWOfromGWO;
/



CREATE OR REPLACE FUNCTION fncBDyeingCostQty(pbudgetid in number,pFabricTypeID in varchar2)
RETURN Number
IS
	Bqty  T_yarncost.quantity%type;
	BEGIN
	select sum(a.QTY) into Bqty from T_yarncost a,T_Budget b,t_fabricconsumption c
	where a.budgetid=pbudgetid and b.revision=65 and
	a.budgetid=b.budgetid and a.ppid=c.pid AND
	c.FABRICTYPEID=pFabricTypeID;
	return Bqty;
END fncBDyeingCostQty;
/



CREATE OR REPLACE FUNCTION fncBKnittingQty(pbudgetid in number,pFabricTypeID in varchar2)
RETURN Number
IS
Bqty  T_kdfcost.quantity%type;
BEGIN
select sum(A.QUANTITY) into Bqty from T_kdfcost A,T_Budget b,T_fabricconsumption c
where A.budgetid=pbudgetid and b.revision=65 and A.budgetid=b.budgetid and a.STAGEID=3 and
      A.budgetid=c.budgetid and c.FABRICTYPEID=pFabricTypeID and c.pid=a.ppid;
return Bqty;
END fncBKnittingQty;
/