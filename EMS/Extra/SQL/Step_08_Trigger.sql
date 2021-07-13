create or replace trigger T_A_U_T_GDELIVERYCHALLAN
  after update on T_GDELIVERYCHALLAN
  for each row
declare
begin
  Update T_GSTOCK set STOCKTRANSNO=:new.INVOICENO,
                STOCKTRANSDATE=:new.INVOICEDATE,
				CLIENTID=:new.CLIENTID,
				ORDERNO=:new.ORDERNO
  where  STOCKTRANSNO=:old.INVOICENO and catid in (14,28);
end;
/

create or replace trigger T_A_D_T_GDELIVERYCHALLAN
  after delete on T_GDELIVERYCHALLAN
  for each row
declare
begin
  delete from T_GSTOCK
  where  STOCKTRANSNO=:old.INVOICENO and catid in (14,28);
end;
/
/=================================== May be do not need ================================================
PROMPT create or replace trigger t_a_d_T_Gchallan
create or replace trigger t_a_d_T_Gchallan
  after delete on T_GDELIVERYCHALLAN
  for each row
declare
begin
  delete from T_GSTOCK
  where  STOCKTRANSNO=:old.INVOICENO;
end;
/
/=================================== May be do not need ================================================

PROMPT create or replace trigger t_a_u_T_GChalanItems
create or replace trigger t_a_u_T_GChalanItems
  after update on T_GDELIVERYCHALLANItems
  for each row
declare
begin
  update T_GSTOCKITEMS
  set QUANTITY=:new.QUANTITY ,SQUANTITY=:new.SQUANTITY 
 where ITEMCHALLAN=:old.PID;
end;
/


create or replace trigger T_A_D_T_GDELIVERYCHALLANItems
  after delete on T_GDELIVERYCHALLANItems
  for each row
declare
begin
  delete from T_GSTOCKITEMS
  where  ITEMCHALLAN=:old.PID;
end;
/  


PROMPT create or replace trigger t_a_D_T_GChalanItems
create or replace trigger t_a_D_T_GChalanItems
  after delete on T_GDELIVERYCHALLANItems
  for each row
declare
begin
  delete from T_GSTOCKITEMS
  where  ITEMCHALLAN=:old.PID;
end;
/



PROMPT create or replace trigger t_a_d_T_DInvoice
create or replace trigger t_a_d_T_DInvoice
  after delete on T_DInvoice
  for each row
declare
begin

  delete from T_KNITSTOCK
  where  STOCKTRANSNO=:old.INVOICENO  AND KNTITRANSACTIONTYPEID=:old.dtYPE;
end;
/


PROMPT create or replace trigger t_a_u_T_DInvoiceItems
create or replace trigger t_a_u_T_DInvoiceItems
  after update on T_DInvoiceItems
  for each row
declare
begin

  update T_KNITSTOCKITEMS
  set QUANTITY=:new.QUANTITY ,SQUANTITY=:new.SQUANTITY 
 where ITEMCHALLAN=:old.PID;

end;
/


PROMPT create or replace trigger t_a_d_T_DInvoiceItems
create or replace trigger t_a_d_T_DInvoiceItems
  after delete on T_DInvoiceItems
  for each row
declare
begin

  delete from T_KNITSTOCKITEMS
  where  ITEMCHALLAN=:old.PID;
end;
/




PROMPT create or replace trigger t_b_i_T_Dyeline


create or replace trigger t_b_i_T_Dyeline
  before insert or update on T_Dyeline
  for each row
declare
  tmpDyeline NUMBER;
  tmpProdDate date;
  tmpToday VARCHAR2(20);
  tmpSTime VARCHAR2(20);
  tmpShiftTime date;
  shiftMidnight date;
  shiftBEnd date;
begin

  if updating('dStartDateTime') or updating('dEndDateTime') then
    :new.DYEINGSHIFT:=getProdShift(:new.PRODDATE,:new.dStartDateTime,:new.dEndDateTime);
    if (:new.dStartDateTime is not null) and (:new.dEndDateTime is not null)  then
      :new.dComplete := 1 ;
      :new.PRODDATE:=getProdDT(:new.dEndDateTime);
    else
      :new.dComplete := 0;
      :new.PRODDATE:='';
    end if;  
  end if;
end;
/



create or replace trigger t_a_i_T_DSUBITEMS
   before insert or update on T_DSUBITEMS
   for each row
 declare
 tmpCheck number DEFAULT 0;
 tmpDYELINEDATE DATE;
 tmpUnitPrice number DEFAULT 0;
 begin

	SELECT count(*) into tmpCheck FROM T_AUXPRICE WHERE AUXID=:new.AUXID;
if (tmpCheck>0) then
	SELECT MAX(PURCHASEDATE) into tmpDYELINEDATE FROM T_AUXPRICE WHERE AUXID=:new.AUXID AND 
		PURCHASEDATE<=(SELECT DYELINEDATE FROM T_DYELINE WHERE DYELINEID=:new.DYELINEID);
	
  	SELECT UNITPRICE into tmpUnitPrice FROM T_AUXPRICE WHERE AUXID=:new.AUXID AND 
		PURCHASEDATE=tmpDYELINEDATE;
else
	tmpUnitPrice:=0;
end if;
  	if (INSERTING) OR (UPDATING )then
           :new.UNITPRICE := tmpUnitPrice;
        end if;
 end;
 /
