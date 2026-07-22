create or replace package erp_risk_pkg authid definer as
  procedure run(p_request_id number, p_run_id varchar2);
  function assessment_json(p_request_id number) return clob;
end erp_risk_pkg;
/

create or replace package body erp_risk_pkg as
  function rule_weight(p_code varchar2, p_default number) return number is
    l_weight number;
  begin
    select weight into l_weight from ref_scoring_rule
     where rule_type = 'RISK' and rule_code = p_code and active_flag = 1
     order by version desc fetch first 1 row only;
    return nvl(l_weight, p_default);
  exception when no_data_found then return 0;
  end;

  procedure run(p_request_id number, p_run_id varchar2) is
    l_request supplier_request%rowtype;
    l_score number := 0;
    l_high number := rule_weight('RISK_HIGH_THRESHOLD', 70);
    l_medium number := rule_weight('RISK_MEDIUM_THRESHOLD', 35);
    l_level varchar2(20);
    l_count number;
    l_reasons json_array_t := json_array_t();

    procedure add_factor(p_code varchar2, p_message varchar2, p_default number) is
      l_weight number := rule_weight(p_code, p_default);
      l_reason json_object_t := json_object_t();
    begin
      if l_weight <= 0 then return; end if;
      l_score := l_score + l_weight;
      l_reason.put('code', p_code);
      l_reason.put('severity', 'Warning');
      l_reason.put('weight', l_weight);
      l_reason.put('message', p_message);
      l_reasons.append(l_reason);
    end;
  begin
    select * into l_request from supplier_request where request_id = p_request_id;

    select count(*) into l_count from ref_supplier_type
     where supplier_type_code = l_request.supplier_type_code
       and tax_required_flag = 1 and active_flag = 1;
    if l_count > 0 and l_request.tax_registration_number is null then
      add_factor('MISSING_TAX', 'Tax registration is missing where expected.', 25);
    end if;

    select count(*) into l_count from ref_high_risk_country
     where country_code = l_request.country_code and active_flag = 1
       and trunc(sysdate) between effective_from and nvl(effective_to, date '9999-12-31');
    if l_count > 0 then add_factor('HIGH_RISK_COUNTRY', 'Supplier country is configured for enhanced review.', 25); end if;

    select count(*) into l_count from supplier_request_bank
     where request_id = p_request_id and bank_provided_flag = 1
       and bank_country_code is not null and bank_country_code <> l_request.country_code;
    if l_count > 0 then add_factor('BANK_COUNTRY_MISMATCH', 'Bank country differs from supplier country.', 20); end if;

    select count(*) into l_count from supplier_request_site
     where request_id = p_request_id
       and (address_line1 is null or address_line2 is null or city is null or region is null or country_code is null);
    if l_count > 0 then add_factor('INCOMPLETE_ADDRESS', 'Supplier address requires manual completeness review.', 15); end if;

    select count(*) into l_count from supplier_request_bank
     where request_id = p_request_id and bank_provided_flag = 1
       and (masked_account_display is null or account_last4 is null or account_hash is null);
    if l_count > 0 then add_factor('INCOMPLETE_BANK_DETAILS', 'Bank metadata is marked provided but is incomplete.', 15); end if;

    if length(trim(l_request.business_justification)) < 30 then
      add_factor('VAGUE_JUSTIFICATION', 'Business justification is too brief for confident review.', 15);
    end if;

    if nvl(l_request.expected_annual_spend, 0) >= 100000 and length(trim(l_request.business_justification)) < 100 then
      add_factor('HIGH_SPEND_WEAK_JUSTIFICATION', 'High expected spend has limited supporting justification.', 20);
    end if;

    select count(*) into l_count from supplier_request_document
     where request_id = p_request_id and is_required = 1 and missing_flag = 1;
    if l_count > 0 then add_factor('MISSING_DOCUMENT_METADATA', 'Required document metadata indicates a missing document.', 10); end if;

    select count(*) into l_count from duplicate_match
     where request_id = p_request_id and is_current = 1 and match_level = 'High';
    if l_count > 0 then add_factor('DUPLICATE_SCORE_HIGH', 'A current duplicate candidate is High.', 25); end if;

    select count(*) into l_count from duplicate_match
     where request_id = p_request_id and is_current = 1 and match_level = 'Medium';
    if l_count > 0 then add_factor('DUPLICATE_SCORE_MEDIUM', 'A current duplicate candidate is Medium.', 15); end if;

    l_score := least(100, l_score);
    l_level := case when l_score >= l_high then 'High'
                    when l_score >= l_medium then 'Medium' else 'Low' end;

    update risk_assessment set is_current = 0
     where request_id = p_request_id and is_current = 1;
    insert into risk_assessment (
      request_id, run_id, is_current, risk_score, risk_level,
      scoring_version, risk_reasons_json, created_at
    ) values (
      p_request_id, p_run_id, 1, l_score, l_level,
      'v1', json(l_reasons.to_clob), systimestamp
    );
  end;

  function assessment_json(p_request_id number) return clob is
    l_json clob;
  begin
    select json_object(
      'riskId' value risk_id,
      'riskScore' value risk_score,
      'riskLevel' value risk_level,
      'scoringVersion' value scoring_version,
      'reasons' value risk_reasons_json,
      'runId' value run_id,
      'createdAt' value to_char(created_at, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZH:TZM')
      returning clob
    ) into l_json from risk_assessment
     where request_id = p_request_id and is_current = 1
     order by created_at desc fetch first 1 row only;
    return l_json;
  exception when no_data_found then return 'null';
  end;
end erp_risk_pkg;
/
