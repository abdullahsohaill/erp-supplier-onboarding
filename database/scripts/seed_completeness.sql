set pagesize 500 linesize 240 trimspool on

select table_name, row_count
from (
    select 'AI_SUMMARY' table_name, count(*) row_count from ai_summary union all
    select 'DUPLICATE_MATCH', count(*) from duplicate_match union all
    select 'EXISTING_SUPPLIER_REF', count(*) from existing_supplier_ref union all
    select 'EXISTING_SUPPLIER_SITE_REF', count(*) from existing_supplier_site_ref union all
    select 'INTEGRATION_LOG', count(*) from integration_log union all
    select 'REF_BUSINESS_UNIT', count(*) from ref_business_unit union all
    select 'REF_HIGH_RISK_COUNTRY', count(*) from ref_high_risk_country union all
    select 'REF_SCORING_RULE', count(*) from ref_scoring_rule union all
    select 'REF_SUPPLIER_TYPE', count(*) from ref_supplier_type union all
    select 'RISK_ASSESSMENT', count(*) from risk_assessment union all
    select 'STATUS_HISTORY', count(*) from status_history union all
    select 'SUPPLIER_REQUEST', count(*) from supplier_request union all
    select 'SUPPLIER_REQUEST_BANK', count(*) from supplier_request_bank union all
    select 'SUPPLIER_REQUEST_CONTACT', count(*) from supplier_request_contact union all
    select 'SUPPLIER_REQUEST_DOCUMENT', count(*) from supplier_request_document union all
    select 'SUPPLIER_REQUEST_SITE', count(*) from supplier_request_site union all
    select 'VALIDATION_RESULT', count(*) from validation_result union all
    select 'VALIDATION_RULES', count(*) from validation_rules
)
order by table_name;

select count(*) empty_table_count
from (
    select count(*) row_count from ai_summary union all
    select count(*) from duplicate_match union all
    select count(*) from existing_supplier_ref union all
    select count(*) from existing_supplier_site_ref union all
    select count(*) from integration_log union all
    select count(*) from ref_business_unit union all
    select count(*) from ref_high_risk_country union all
    select count(*) from ref_scoring_rule union all
    select count(*) from ref_supplier_type union all
    select count(*) from risk_assessment union all
    select count(*) from status_history union all
    select count(*) from supplier_request union all
    select count(*) from supplier_request_bank union all
    select count(*) from supplier_request_contact union all
    select count(*) from supplier_request_document union all
    select count(*) from supplier_request_site union all
    select count(*) from validation_result union all
    select count(*) from validation_rules
)
where row_count = 0;

select count(*) retry_invariant_violations
from integration_log l
where nvl(l.retry_count, 0) <>
      (select count(*) from json_table(l.retry_history_json, '$[*]' columns (attempt for ordinality)));
