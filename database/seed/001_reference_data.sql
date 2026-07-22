merge into ref_business_unit t
using (
    select 1 id, 'PK-OPS' code, 'Pakistan Operations' name, 'FUSION_BU_PK' mapping from dual union all
    select 2, 'GCC-OPS', 'GCC Operations', 'FUSION_BU_GCC' from dual union all
    select 3, 'GLOBAL-HQ', 'Global Headquarters', 'FUSION_BU_HQ' from dual
) s on (t.business_unit_code = s.code)
when not matched then insert (
    business_unit_id, business_unit_code, business_unit_name, fusion_mapping_code,
    active_flag, created_by
) values (s.id, s.code, s.name, s.mapping, 1, 'SEED');

merge into ref_supplier_type t
using (
    select 1 id, 'CORPORATE' code, 'Corporate Supplier' name, 1 tax_required from dual union all
    select 2, 'INDIVIDUAL', 'Individual Supplier', 0 from dual union all
    select 3, 'GOVERNMENT', 'Government Entity', 0 from dual
) s on (t.supplier_type_code = s.code)
when not matched then insert (
    supplier_type_id, supplier_type_code, supplier_type_name, tax_required_flag,
    active_flag, created_by
) values (s.id, s.code, s.name, s.tax_required, 1, 'SEED');

merge into ref_high_risk_country t
using (
    select 'AF' country_code, date '2026-01-01' effective_from,
           'Afghanistan' country_name, 'HIGH' risk_level, 1 active_flag, cast(null as date) effective_to from dual union all
    select 'IR', date '2026-01-01', 'Iran', 'HIGH', 1, cast(null as date) from dual union all
    select 'XZ', date '2025-01-01', 'Retired Demo Territory', 'MEDIUM', 0, date '2025-12-31' from dual
) s on (t.country_code = s.country_code and t.effective_from = s.effective_from)
when not matched then insert (
    country_code, effective_from, country_name, risk_level, active_flag,
    effective_to, created_by
) values (
    s.country_code, s.effective_from, s.country_name, s.risk_level,
    s.active_flag, s.effective_to, 'SEED'
);

merge into validation_rules t
using (
    select 1 id, 'VAL-001' code, 'Supplier name required' name, 'supplierName' field_name,
           'Supplier name is required.' message from dual union all
    select 2, 'VAL-002', 'Country required', 'countryCode', 'Supplier country is required.' from dual union all
    select 3, 'VAL-003', 'Supplier type required', 'supplierTypeCode', 'Supplier type is required.' from dual union all
    select 4, 'VAL-004', 'Business unit required and mapped', 'businessUnitCode', 'An active mapped business unit is required.' from dual union all
    select 5, 'VAL-005', 'Contact email required and valid', 'contacts.contactEmail', 'At least one valid contact email is required.' from dual union all
    select 6, 'VAL-006', 'Structured address complete', 'sites.address', 'Address lines, city, region, and country are required; address lines are limited to 20 characters.' from dual union all
    select 7, 'VAL-007', 'Supplier site required', 'sites', 'At least one supplier site is required.' from dual union all
    select 8, 'VAL-008', 'Exact tax duplicate blocked', 'taxRegistrationNumber', 'Tax registration already belongs to an existing or staged supplier.' from dual union all
    select 9, 'VAL-009', 'Same bank token duplicate blocked', 'bank.accountToken', 'Bank token already belongs to an existing or staged supplier.' from dual
) s on (t.rule_code = s.code)
when not matched then insert (
    validation_rule_id, rule_code, rule_name, rule_description, field_name,
    severity, default_message, is_blocking, active_flag, created_by
) values (
    s.id, s.code, s.name, s.name, s.field_name, 'ERROR', s.message, 1, 1, 'SEED'
);

merge into ref_scoring_rule t
using (
    select 'RISK' rule_type, 'MISSING_TAX' code, '1.0' version,
           'Missing expected tax registration' rule_name, 25 weight,
           'MEDIUM' severity, 0 critical, 1 active from dual union all
    select 'RISK', 'HIGH_RISK_COUNTRY', '1.0', 'High-risk country', 25, 'HIGH', 0, 1 from dual union all
    select 'RISK', 'BANK_COUNTRY_MISMATCH', '1.0', 'Bank country mismatch', 20, 'HIGH', 0, 1 from dual union all
    select 'RISK', 'INCOMPLETE_ADDRESS', '1.0', 'Suspicious or incomplete address', 15, 'MEDIUM', 0, 1 from dual union all
    select 'RISK', 'INCOMPLETE_BANK_DETAILS', '1.0', 'Incomplete masked bank metadata', 15, 'MEDIUM', 0, 1 from dual union all
    select 'RISK', 'VAGUE_JUSTIFICATION', '1.0', 'Vague business justification', 15, 'MEDIUM', 0, 1 from dual union all
    select 'RISK', 'HIGH_SPEND_WEAK_JUSTIFICATION', '1.0', 'High spend with weak justification', 20, 'HIGH', 0, 1 from dual union all
    select 'RISK', 'MISSING_DOCUMENT_METADATA', '1.0', 'Required document metadata missing', 10, 'MEDIUM', 0, 1 from dual union all
    select 'RISK', 'DUPLICATE_SCORE_HIGH', '1.0', 'High duplicate score', 25, 'HIGH', 0, 1 from dual union all
    select 'RISK', 'DUPLICATE_SCORE_MEDIUM', '1.0', 'Medium duplicate score', 15, 'MEDIUM', 0, 1 from dual union all
    select 'RISK', 'RISK_HIGH_THRESHOLD', '1.0', 'High risk threshold', 70, 'CONFIG', 0, 1 from dual union all
    select 'RISK', 'RISK_MEDIUM_THRESHOLD', '1.0', 'Medium risk threshold', 35, 'CONFIG', 0, 1 from dual union all
    select 'DUPLICATE', 'DUP_EXACT_TAX', '1.0', 'Exact tax registration match', 100, 'CRITICAL', 1, 1 from dual union all
    select 'DUPLICATE', 'DUP_SAME_BANK', '1.0', 'Exact bank token match', 100, 'CRITICAL', 1, 1 from dual union all
    select 'DUPLICATE', 'DUP_NAME_SIMILARITY', '1.0', 'Normalized name match', 30, 'MEDIUM', 0, 1 from dual union all
    select 'DUPLICATE', 'DUP_SAME_COUNTRY', '1.0', 'Country match', 10, 'LOW', 0, 1 from dual union all
    select 'DUPLICATE', 'DUP_EMAIL_DOMAIN', '1.0', 'Email domain match', 15, 'LOW', 0, 1 from dual union all
    select 'DUPLICATE', 'DUP_PHONE', '1.0', 'Normalized phone match', 20, 'MEDIUM', 0, 1 from dual union all
    select 'DUPLICATE', 'DUP_ADDRESS', '1.0', 'Normalized address match', 20, 'MEDIUM', 0, 1 from dual union all
    select 'DUPLICATE', 'DUP_BU_SITE', '1.0', 'Business unit and site match', 5, 'LOW', 0, 1 from dual union all
    select 'DUPLICATE', 'DUP_HIGH_THRESHOLD', '1.0', 'High duplicate threshold', 70, 'CONFIG', 0, 1 from dual union all
    select 'DUPLICATE', 'DUP_MEDIUM_THRESHOLD', '1.0', 'Medium duplicate threshold', 40, 'CONFIG', 0, 1 from dual
) s on (t.rule_type = s.rule_type and t.rule_code = s.code and t.version = s.version)
when not matched then insert (
    rule_type, rule_code, version, rule_name, weight, severity,
    critical_trigger_flag, active_flag, created_by
) values (
    s.rule_type, s.code, s.version, s.rule_name, s.weight, s.severity,
    s.critical, s.active, 'SEED'
);

commit;
