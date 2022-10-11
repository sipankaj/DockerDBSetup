prompt Starting Setup

prompt Check if the ORACLE database is in archive log mode
select log_mode from v$database;

prompt Turn on ARCHIVELOG mode
SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
ALTER DATABASE ARCHIVELOG;
ALTER DATABASE OPEN;

prompt Check if the ORACLE database is in archive log mode
select log_mode from v$database;

prompt Enable supplemental logging for all columns
ALTER SESSION SET CONTAINER=cdb$root;
ALTER DATABASE ADD SUPPLEMENTAL LOG DATA (ALL) COLUMNS;

-- to be run in the CDB
-- credit : https://docs.confluent.io/kafka-connect-oracle-cdc/current
CREATE ROLE C##CDC_GRANTS;
GRANT CREATE SESSION,
EXECUTE_CATALOG_ROLE,
SELECT ANY TRANSACTION,
SELECT ANY DICTIONARY TO C##CDC_GRANTS;
GRANT SELECT ON SYSTEM.LOGMNR_COL$ TO C##CDC_GRANTS;
GRANT SELECT ON SYSTEM.LOGMNR_OBJ$ TO C##CDC_GRANTS;
GRANT SELECT ON SYSTEM.LOGMNR_USER$ TO C##CDC_GRANTS;
GRANT SELECT ON SYSTEM.LOGMNR_UID$ TO C##CDC_GRANTS;

CREATE USER C##sipankaj IDENTIFIED BY password CONTAINER=ALL;
GRANT C##CDC_GRANTS TO C##sipankaj CONTAINER=ALL;
ALTER USER C##sipankaj QUOTA UNLIMITED ON sysaux;
ALTER USER C##sipankaj SET CONTAINER_DATA = (CDB$ROOT, ORCLPDB1) CONTAINER=CURRENT;

ALTER SESSION SET CONTAINER=CDB$ROOT;
GRANT CREATE SESSION, ALTER SESSION, SET CONTAINER, LOGMINING, EXECUTE_CATALOG_ROLE TO C##sipankaj CONTAINER=ALL;
GRANT SELECT ON GV_$DATABASE TO C##sipankaj CONTAINER=ALL;
GRANT SELECT ON V_$LOGMNR_CONTENTS TO C##sipankaj CONTAINER=ALL;
GRANT SELECT ON GV_$ARCHIVED_LOG TO C##sipankaj CONTAINER=ALL;
GRANT CONNECT TO C##sipankaj CONTAINER=ALL;
GRANT CREATE TABLE TO C##sipankaj CONTAINER=ALL;
GRANT CREATE SEQUENCE TO C##sipankaj CONTAINER=ALL;
GRANT CREATE TRIGGER TO C##sipankaj CONTAINER=ALL;

ALTER SESSION SET CONTAINER=cdb$root;
ALTER DATABASE ADD SUPPLEMENTAL LOG DATA (ALL) COLUMNS;

GRANT FLASHBACK ANY TABLE TO C##sipankaj;
GRANT FLASHBACK ANY TABLE TO C##sipankaj container=all;


prompt Create some objects
CREATE TABLE C##SIPANKAJ.users
(
    USER_ID NUMBER(10) NOT NULL PRIMARY KEY,
    FIRST_NAME VARCHAR2(30),
    LAST_NAME VARCHAR2(30), 
    EMAIL VARCHAR(50),
    AGE NUMBER(4),
    CREATED_DATE DATE NOT NULL
) tablespace sysaux;

CREATE SEQUENCE C##SIPANKAJ.users_seq
 START WITH     1
 INCREMENT BY   1
 NOCACHE
 NOCYCLE;
    
INSERT INTO C##SIPANKAJ.users (USER_ID, FIRST_NAME, LAST_NAME, EMAIL, AGE, CREATED_DATE) VALUES(user_seq.NEXTVAL, 'FIRST','LAST','111@yahoo.com',30, TO_DATE('2022-02-11', 'yyyy-mm-dd'));
INSERT INTO C##sipankaj.USERS (USER_ID, FIRST_NAME, LAST_NAME, EMAIL, AGE, CREATED_DATE) VALUES(user_seq.NEXTVAL, 'TEST','TEST1','222@yahoo.com',40, TO_DATE('2022-02-12', 'yyyy-mm-dd'));
INSERT INTO C##sipankaj.USERS (USER_ID, FIRST_NAME, LAST_NAME, EMAIL, AGE, CREATED_DATE) VALUES(user_seq.NEXTVAL, 'DUMMY','DUMMY1','333@yahoo.com',42, TO_DATE('2022-02-13', 'yyyy-mm-dd'));

prompt All Done

exit;
