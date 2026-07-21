create or replace view v_current_validation_result as
select validation_id, request_id, validation_rule_id, run_id, field_name,
       severity, message, is_blocking, created_at
  from validation_result
 where is_current = 1;

create or replace view v_current_duplicate_match as
select match_id, request_id, run_id, candidate_source, candidate_supplier_ref_id,
       candidate_supplier_number, candidate_supplier_name, candidate_request_id,
       match_score, match_level, matched_fields_json, explanation, created_at
  from duplicate_match
 where is_current = 1;

create or replace view v_current_risk_assessment as
select risk_id, request_id, run_id, risk_score, risk_level, scoring_version,
       risk_reasons_json, created_at
  from risk_assessment
 where is_current = 1;

create or replace view v_requester_request_summary as
select request_id, request_number, status, supplier_name, requester_user,
       case status
           when 'Correction Requested' then 'Edit and Resubmit'
           when 'Draft' then 'Complete and submit request'
           when 'Under Review' then 'Waiting for reviewer'
           when 'Created in Fusion' then 'Supplier created'
           when 'Marked Duplicate' then 'Use existing supplier'
           else 'None'
       end as next_action,
       fusion_supplier_number, created_at, submitted_at, last_updated_at
  from supplier_request;
