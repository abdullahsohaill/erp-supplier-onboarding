alter table ref_business_unit add constraint uk_ref_bu_code unique (business_unit_code);
alter table ref_supplier_type add constraint uk_ref_supplier_type_code unique (supplier_type_code);
alter table validation_rules add constraint uk_validation_rule_code unique (rule_code);
alter table supplier_request add constraint uk_supplier_request_number unique (request_number);
alter table supplier_request_bank add constraint uk_supplier_request_bank unique (request_id);
alter table existing_supplier_ref add constraint uk_existing_supplier_number unique (supplier_number);

alter table supplier_request add constraint ck_supplier_request_status check (
    status in ('Draft', 'Submitted', 'Under Review', 'Correction Requested', 'Approved',
               'Rejected', 'Marked Duplicate', 'Submitted to Fusion',
               'Created in Fusion', 'Integration Failed')
);
alter table supplier_request add constraint ck_supplier_request_spend check (expected_annual_spend is null or expected_annual_spend >= 0);
alter table supplier_request_site add constraint ck_request_site_primary check (is_primary in (0, 1));
alter table supplier_request_bank add constraint ck_request_bank_provided check (bank_provided_flag in (0, 1));
alter table supplier_request_bank add constraint ck_request_bank_last4 check (account_last4 is null or regexp_like(account_last4, '^[0-9]{4}$'));
alter table supplier_request_document add constraint ck_request_doc_required check (is_required in (0, 1));
alter table supplier_request_document add constraint ck_request_doc_missing check (missing_flag in (0, 1));
alter table supplier_request_document add constraint ck_request_doc_metadata_json check (metadata_json is json);
alter table validation_result add constraint ck_validation_current check (is_current in (0, 1));
alter table validation_result add constraint ck_validation_blocking check (is_blocking in (0, 1));
alter table duplicate_match add constraint ck_duplicate_current check (is_current in (0, 1));
alter table duplicate_match add constraint ck_duplicate_score check (match_score is null or match_score between 0 and 100);
alter table duplicate_match add constraint ck_duplicate_fields_json check (matched_fields_json is json);
alter table duplicate_match add constraint ck_duplicate_source check (candidate_source in ('EXISTING_SUPPLIER', 'STAGED_REQUEST', 'EVIDENCE_ONLY'));
alter table risk_assessment add constraint ck_risk_current check (is_current in (0, 1));
alter table risk_assessment add constraint ck_risk_score check (risk_score is null or risk_score between 0 and 100);
alter table risk_assessment add constraint ck_risk_reasons_json check (risk_reasons_json is json);
alter table ai_summary add constraint ck_ai_summary_json check (summary_json is json);
alter table integration_log add constraint ck_integration_retry_count check (retry_count is null or retry_count >= 0);
alter table integration_log add constraint ck_integration_retryable check (retry_eligible_flag in (0, 1));
alter table integration_log add constraint ck_integration_retry_json check (retry_history_json is json);
alter table ref_business_unit add constraint ck_ref_bu_active check (active_flag in (0, 1));
alter table ref_supplier_type add constraint ck_ref_type_tax check (tax_required_flag in (0, 1));
alter table ref_supplier_type add constraint ck_ref_type_active check (active_flag in (0, 1));
alter table ref_high_risk_country add constraint ck_ref_country_active check (active_flag in (0, 1));
alter table ref_high_risk_country add constraint ck_ref_country_dates check (effective_to is null or effective_to >= effective_from);
alter table validation_rules add constraint ck_validation_rule_severity check (severity in ('ERROR', 'WARNING', 'INFO'));
alter table validation_rules add constraint ck_validation_rule_blocking check (is_blocking in (0, 1));
alter table validation_rules add constraint ck_validation_rule_active check (active_flag in (0, 1));
alter table ref_scoring_rule add constraint ck_scoring_rule_type check (rule_type in ('RISK', 'DUPLICATE'));
alter table ref_scoring_rule add constraint ck_scoring_rule_weight check (weight is null or weight between 0 and 100);
alter table ref_scoring_rule add constraint ck_scoring_rule_critical check (critical_trigger_flag in (0, 1));
alter table ref_scoring_rule add constraint ck_scoring_rule_active check (active_flag in (0, 1));

alter table supplier_request add constraint fk_request_business_unit foreign key (business_unit_id) references ref_business_unit (business_unit_id);
alter table supplier_request add constraint fk_request_supplier_type foreign key (supplier_type_code) references ref_supplier_type (supplier_type_code);
alter table supplier_request_site add constraint fk_site_request foreign key (request_id) references supplier_request (request_id) on delete cascade;
alter table supplier_request_site add constraint fk_site_business_unit foreign key (intended_business_unit_id) references ref_business_unit (business_unit_id);
alter table supplier_request_contact add constraint fk_contact_request foreign key (request_id) references supplier_request (request_id) on delete cascade;
alter table supplier_request_bank add constraint fk_bank_request foreign key (request_id) references supplier_request (request_id) on delete cascade;
alter table supplier_request_document add constraint fk_document_request foreign key (request_id) references supplier_request (request_id) on delete cascade;
alter table status_history add constraint fk_history_request foreign key (request_id) references supplier_request (request_id) on delete cascade;
alter table validation_result add constraint fk_validation_request foreign key (request_id) references supplier_request (request_id) on delete cascade;
alter table validation_result add constraint fk_validation_rule foreign key (validation_rule_id) references validation_rules (validation_rule_id);
alter table duplicate_match add constraint fk_duplicate_request foreign key (request_id) references supplier_request (request_id) on delete cascade;
alter table duplicate_match add constraint fk_duplicate_supplier_ref foreign key (candidate_supplier_ref_id) references existing_supplier_ref (supplier_ref_id);
alter table duplicate_match add constraint fk_duplicate_candidate_request foreign key (candidate_request_id) references supplier_request (request_id);
alter table risk_assessment add constraint fk_risk_request foreign key (request_id) references supplier_request (request_id) on delete cascade;
alter table ai_summary add constraint fk_ai_request foreign key (request_id) references supplier_request (request_id) on delete cascade;
alter table existing_supplier_site_ref add constraint fk_ref_site_supplier foreign key (supplier_ref_id) references existing_supplier_ref (supplier_ref_id) on delete cascade;
alter table integration_log add constraint fk_integration_request foreign key (request_id) references supplier_request (request_id) on delete cascade;
