set pagesize 500 linesize 240 trimspool on
select count(*) as application_table_count from user_tables;
select count(*) as application_column_count
  from user_tab_columns
 where table_name in (
    'SUPPLIER_REQUEST','SUPPLIER_REQUEST_SITE','SUPPLIER_REQUEST_CONTACT',
    'SUPPLIER_REQUEST_BANK','SUPPLIER_REQUEST_DOCUMENT','STATUS_HISTORY',
    'VALIDATION_RESULT','DUPLICATE_MATCH','RISK_ASSESSMENT','AI_SUMMARY',
    'EXISTING_SUPPLIER_REF','EXISTING_SUPPLIER_SITE_REF','INTEGRATION_LOG',
    'REF_BUSINESS_UNIT','REF_SUPPLIER_TYPE','REF_HIGH_RISK_COUNTRY',
    'VALIDATION_RULES','REF_SCORING_RULE'
 );
select count(*) as foreign_key_count from user_constraints where constraint_type = 'R';
select table_name, count(*) as columns
  from user_tab_columns
 group by table_name
 order by table_name;
