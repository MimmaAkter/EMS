conn system/Manager123@Textile


alter session set "_ORACLE_SCRIPT"=true;

drop user EMS cascade;

PROMPT Creating schema user 'EMS'
Create user EMS
identified by EMS
default tablespace users
temporary tablespace temp
quota unlimited on users;


PROMPT Grant DBA previleges to 'EMS'
grant connect, resource, dba to EMS;

PROMPT Try to connect as 'EMS'
connect EMS/EMS@textile;




conn system/manager@Textile

drop user atlMS1 cascade;

PROMPT Creating schema user 'atlMS1'
Create user atlMS1
identified by atlMS1
default tablespace users
temporary tablespace temp
quota unlimited on users;


PROMPT Grant DBA previleges to 'atlMS1'
grant connect, resource, dba to atlMS1;

PROMPT Try to connect as 'atlMS2'
connect atlMS1/atlMS1@textile;
