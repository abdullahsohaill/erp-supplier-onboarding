whenever sqlerror exit failure rollback

delete from integration_log;
delete from ai_summary;
delete from risk_assessment;
delete from duplicate_match;
delete from validation_result;
delete from status_history;
delete from supplier_request_document;
delete from supplier_request_bank;
delete from supplier_request_contact;
delete from supplier_request_site;
delete from existing_supplier_site_ref;
delete from existing_supplier_ref;
delete from supplier_request;
delete from validation_rules;
delete from ref_scoring_rule;
delete from ref_high_risk_country;
delete from ref_supplier_type;
delete from ref_business_unit;
commit;
