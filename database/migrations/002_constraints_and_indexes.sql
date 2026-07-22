whenever sqlerror exit failure rollback

alter table supplier_request add constraint fk_request_business_unit
  foreign key (business_unit_id) references ref_business_unit (business_unit_id);
alter table supplier_request add constraint fk_request_supplier_type
  foreign key (supplier_type_code) references ref_supplier_type (supplier_type_code);
alter table supplier_request_site add constraint fk_site_request
  foreign key (request_id) references supplier_request (request_id);
alter table supplier_request_site add constraint fk_site_business_unit
  foreign key (intended_business_unit_id) references ref_business_unit (business_unit_id);
alter table supplier_request_contact add constraint fk_contact_request
  foreign key (request_id) references supplier_request (request_id);
alter table supplier_request_bank add constraint fk_bank_request
  foreign key (request_id) references supplier_request (request_id);
alter table supplier_request_document add constraint fk_document_request
  foreign key (request_id) references supplier_request (request_id);
alter table status_history add constraint fk_history_request
  foreign key (request_id) references supplier_request (request_id);
alter table validation_result add constraint fk_validation_request
  foreign key (request_id) references supplier_request (request_id);
alter table validation_result add constraint fk_validation_rule
  foreign key (validation_rule_id) references validation_rules (validation_rule_id);
alter table duplicate_match add constraint fk_duplicate_request
  foreign key (request_id) references supplier_request (request_id);
alter table duplicate_match add constraint fk_duplicate_supplier_ref
  foreign key (candidate_supplier_ref_id) references existing_supplier_ref (supplier_ref_id);
alter table duplicate_match add constraint fk_duplicate_candidate_request
  foreign key (candidate_request_id) references supplier_request (request_id);
alter table risk_assessment add constraint fk_risk_request
  foreign key (request_id) references supplier_request (request_id);
alter table ai_summary add constraint fk_ai_request
  foreign key (request_id) references supplier_request (request_id);
alter table existing_supplier_site_ref add constraint fk_supplier_site_ref
  foreign key (supplier_ref_id) references existing_supplier_ref (supplier_ref_id);
alter table integration_log add constraint fk_integration_request
  foreign key (request_id) references supplier_request (request_id);

alter table supplier_request add constraint ck_request_status check (
  status in ('Draft','Submitted','Under Review','Correction Requested','Approved','Rejected','Marked Duplicate','Submitted to Fusion','Created in Fusion','Integration Failed')
);
alter table supplier_request add constraint ck_request_spend check (expected_annual_spend >= 0);
alter table supplier_request_site add constraint ck_site_primary check (is_primary in (0,1));
alter table supplier_request_bank add constraint ck_bank_provided check (bank_provided_flag in (0,1));
alter table supplier_request_bank add constraint ck_bank_last4 check (account_last4 is null or length(account_last4) = 4);
alter table supplier_request_document add constraint ck_document_required check (is_required in (0,1));
alter table supplier_request_document add constraint ck_document_missing check (missing_flag in (0,1));
alter table validation_result add constraint ck_validation_current check (is_current in (0,1));
alter table validation_result add constraint ck_validation_blocking check (is_blocking in (0,1));
alter table duplicate_match add constraint ck_duplicate_current check (is_current in (0,1));
alter table duplicate_match add constraint ck_duplicate_score check (match_score between 0 and 100);
alter table duplicate_match add constraint ck_duplicate_level check (match_level in ('Low','Medium','High','Critical'));
alter table risk_assessment add constraint ck_risk_current check (is_current in (0,1));
alter table risk_assessment add constraint ck_risk_score check (risk_score between 0 and 100);
alter table risk_assessment add constraint ck_risk_level check (risk_level in ('Low','Medium','High','Critical'));
alter table integration_log add constraint ck_integration_retry_count check (retry_count >= 0);
alter table integration_log add constraint ck_integration_retry_flag check (retry_eligible_flag in (0,1));
alter table validation_rules add constraint ck_validation_rules_flags check (is_blocking in (0,1) and active_flag in (0,1));
alter table ref_scoring_rule add constraint ck_scoring_rule_type check (rule_type in ('RISK','DUPLICATE'));
alter table ref_scoring_rule add constraint ck_scoring_weight check (weight >= 0);
alter table ref_scoring_rule add constraint ck_scoring_flags check (
  (critical_trigger_flag is null or critical_trigger_flag in (0,1)) and
  (active_flag is null or active_flag in (0,1))
);
alter table ref_business_unit add constraint ck_business_unit_active check (active_flag in (0,1));
alter table ref_supplier_type add constraint ck_supplier_type_flags check (tax_required_flag in (0,1) and active_flag in (0,1));
alter table ref_high_risk_country add constraint ck_high_risk_active check (active_flag in (0,1));
alter table ref_high_risk_country add constraint ck_high_risk_dates check (effective_to is null or effective_to >= effective_from);

create index ix_request_status on supplier_request (status);
create index ix_request_requester on supplier_request (requester_user);
create index ix_request_country on supplier_request (country_code);
create index ix_request_bu on supplier_request (business_unit_id);
create index ix_request_type on supplier_request (supplier_type_code);
create index ix_request_submitted on supplier_request (submitted_at);
create index ix_request_fusion_number on supplier_request (fusion_supplier_number);
create index ix_site_request on supplier_request_site (request_id);
create index ix_site_country on supplier_request_site (country_code);
create index ix_site_bu on supplier_request_site (intended_business_unit_id);
create unique index ux_site_one_primary on supplier_request_site (case when is_primary = 1 then request_id end);
create index ix_contact_request on supplier_request_contact (request_id);
create index ix_contact_domain on supplier_request_contact (email_domain);
create index ix_bank_request on supplier_request_bank (request_id);
create index ix_bank_hash on supplier_request_bank (account_hash);
create index ix_bank_country on supplier_request_bank (bank_country_code);
create index ix_document_request on supplier_request_document (request_id);
create index ix_document_type on supplier_request_document (document_type);
create index ix_document_missing on supplier_request_document (missing_flag);
create index ix_history_request_time on status_history (request_id, action_timestamp);
create index ix_history_action on status_history (action_code);
create index ix_validation_request on validation_result (request_id);
create index ix_validation_rule on validation_result (validation_rule_id);
create index ix_validation_run on validation_result (run_id);
create index ix_validation_current on validation_result (is_current);
create index ix_validation_blocking on validation_result (is_blocking);
create index ix_duplicate_request on duplicate_match (request_id);
create index ix_duplicate_run on duplicate_match (run_id);
create index ix_duplicate_current on duplicate_match (is_current);
create index ix_duplicate_source on duplicate_match (candidate_source);
create index ix_duplicate_supplier on duplicate_match (candidate_supplier_ref_id);
create index ix_duplicate_candidate_req on duplicate_match (candidate_request_id);
create index ix_duplicate_level_score on duplicate_match (match_level, match_score);
create index ix_risk_request on risk_assessment (request_id);
create index ix_risk_run on risk_assessment (run_id);
create index ix_risk_current on risk_assessment (is_current);
create index ix_risk_level_time on risk_assessment (risk_level, created_at);
create index ix_ai_request on ai_summary (request_id);
create index ix_ai_prompt on ai_summary (prompt_version);
create index ix_ai_facts_hash on ai_summary (source_facts_hash);
create index ix_ai_created on ai_summary (created_at);
create index ix_supplier_fusion_id on existing_supplier_ref (fusion_supplier_id);
create index ix_supplier_name on existing_supplier_ref (normalized_name);
create index ix_supplier_country on existing_supplier_ref (country_code);
create index ix_supplier_tax on existing_supplier_ref (tax_registration_number);
create index ix_supplier_email on existing_supplier_ref (email_domain);
create index ix_supplier_phone on existing_supplier_ref (phone_normalized);
create index ix_supplier_bank on existing_supplier_ref (bank_account_hash);
create index ix_supplier_site_parent on existing_supplier_site_ref (supplier_ref_id);
create index ix_supplier_site_fusion on existing_supplier_site_ref (fusion_site_id);
create index ix_supplier_site_country on existing_supplier_site_ref (country_code);
create index ix_supplier_site_bu on existing_supplier_site_ref (business_unit_code);
create index ix_integration_request on integration_log (request_id);
create index ix_integration_name on integration_log (integration_name);
create index ix_integration_oic on integration_log (oic_instance_id);
create index ix_integration_status on integration_log (status);
create index ix_integration_error on integration_log (error_category);
create index ix_integration_retry on integration_log (retry_eligible_flag);
create index ix_integration_created on integration_log (created_at);
create index ix_validation_rules_active on validation_rules (active_flag);
create index ix_validation_rules_severity on validation_rules (severity);
create index ix_validation_rules_blocking on validation_rules (is_blocking);
create index ix_business_unit_mapping on ref_business_unit (fusion_mapping_code);
create index ix_business_unit_active on ref_business_unit (active_flag);
create index ix_supplier_type_active on ref_supplier_type (active_flag);
create index ix_country_active_dates on ref_high_risk_country (active_flag, effective_to);
create index ix_scoring_active on ref_scoring_rule (rule_type, active_flag);
create index ix_scoring_severity on ref_scoring_rule (severity);
create index ix_scoring_critical on ref_scoring_rule (critical_trigger_flag);
