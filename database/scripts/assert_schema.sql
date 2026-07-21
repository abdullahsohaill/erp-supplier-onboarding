declare
    l_tables number;
    l_columns number;
    l_fks number;
begin
    select count(*) into l_tables from user_tables;
    select count(*) into l_columns
      from user_tab_columns
     where table_name in (
        'SUPPLIER_REQUEST','SUPPLIER_REQUEST_SITE','SUPPLIER_REQUEST_CONTACT',
        'SUPPLIER_REQUEST_BANK','SUPPLIER_REQUEST_DOCUMENT','STATUS_HISTORY',
        'VALIDATION_RESULT','DUPLICATE_MATCH','RISK_ASSESSMENT','AI_SUMMARY',
        'EXISTING_SUPPLIER_REF','EXISTING_SUPPLIER_SITE_REF','INTEGRATION_LOG',
        'REF_BUSINESS_UNIT','REF_SUPPLIER_TYPE','REF_HIGH_RISK_COUNTRY',
        'VALIDATION_RULES','REF_SCORING_RULE'
     );
    select count(*) into l_fks from user_constraints where constraint_type = 'R';
    if l_tables <> 18 or l_columns <> 189 or l_fks <> 17 then
        raise_application_error(-20101, 'SCHEMA_PARITY_FAILED:' || l_tables || '/' || l_columns || '/' || l_fks);
    end if;
end;
/
