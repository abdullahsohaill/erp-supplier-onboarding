select r.request_number, rules.rule_code, v.field_name, v.severity, v.is_blocking, v.message
from ERP_APP.validation_result v
join ERP_APP.supplier_request r on r.request_id = v.request_id
join ERP_APP.validation_rules rules on rules.validation_rule_id = v.validation_rule_id
order by r.request_number, v.validation_id;

select r.request_number, d.candidate_source, d.match_score, d.match_level,
       d.candidate_supplier_number
from ERP_APP.duplicate_match d
join ERP_APP.supplier_request r on r.request_id = d.request_id
order by r.request_number, d.match_id;

select r.request_number, a.risk_score, a.risk_level, a.scoring_version
from ERP_APP.risk_assessment a
join ERP_APP.supplier_request r on r.request_id = a.request_id
order by r.request_number, a.risk_id;

select r.request_number, s.prompt_version, s.provider_name, s.model_name, s.created_by
from ERP_APP.ai_summary s
join ERP_APP.supplier_request r on r.request_id = s.request_id
order by r.request_number, s.summary_id;
