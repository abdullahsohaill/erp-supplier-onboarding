select rule_code, rule_name, field_name, active_flag, is_blocking, severity
from ERP_APP.validation_rules
order by rule_code;

select rule_type, rule_code, version, active_flag, weight, severity,
       critical_trigger_flag
from ERP_APP.ref_scoring_rule
order by rule_type, rule_code, version;

select country_code, country_name, risk_level, active_flag, effective_from, effective_to
from ERP_APP.ref_high_risk_country
order by country_code, effective_from;

select business_unit_code, business_unit_name, active_flag
from ERP_APP.ref_business_unit
order by business_unit_code;

select supplier_type_code, supplier_type_name, tax_required_flag, active_flag
from ERP_APP.ref_supplier_type
order by supplier_type_code;
