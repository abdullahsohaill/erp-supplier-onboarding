create or replace package erp_duplicate_pkg authid definer as
  function normalize_name(p_value varchar2) return varchar2 deterministic;
  function normalize_token(p_value varchar2) return varchar2 deterministic;
  procedure run(p_request_id number, p_run_id varchar2);
  function matches_json(p_request_id number) return clob;
end erp_duplicate_pkg;
/

create or replace package body erp_duplicate_pkg as
  function normalize_token(p_value varchar2) return varchar2 deterministic is
  begin
    return upper(regexp_replace(trim(p_value), '[^[:alnum:]]', ''));
  end;

  function normalize_name(p_value varchar2) return varchar2 deterministic is
    l_value varchar2(4000);
  begin
    l_value := upper(regexp_replace(trim(p_value), '[^[:alnum:] ]', ' '));
    l_value := regexp_replace(l_value, '(^| )(LIMITED|LTD|LLC|INCORPORATED|INC|CORPORATION|CORP|PLC)( |$)', ' ');
    return trim(regexp_replace(l_value, '[[:space:]]+', ' '));
  end;

  function rule_weight(p_code varchar2, p_default number) return number is
    l_weight number;
  begin
    select weight into l_weight from ref_scoring_rule
     where rule_type = 'DUPLICATE' and rule_code = p_code and active_flag = 1
     order by version desc fetch first 1 row only;
    return nvl(l_weight, p_default);
  exception when no_data_found then return 0;
  end;

  procedure run(p_request_id number, p_run_id varchar2) is
    l_request supplier_request%rowtype;
    l_name varchar2(4000);
    l_email varchar2(255);
    l_phone varchar2(80);
    l_address varchar2(1000);
    l_bank_hash varchar2(128);
    l_score number;
    l_level varchar2(20);
    l_critical number;
    l_high number := rule_weight('DUP_HIGH_THRESHOLD', 70);
    l_medium number := rule_weight('DUP_MEDIUM_THRESHOLD', 40);
    l_fields json_array_t;

    procedure add_field(p_code varchar2) is
    begin
      l_fields.append(p_code);
    end;

    procedure persist_match(
      p_source varchar2,
      p_supplier_ref_id number,
      p_supplier_number varchar2,
      p_supplier_name varchar2,
      p_candidate_request_id number
    ) is
    begin
      if l_score <= 0 and l_critical = 0 then return; end if;
      l_level := case when l_critical = 1 then 'Critical'
                      when l_score >= l_high then 'High'
                      when l_score >= l_medium then 'Medium' else 'Low' end;
      insert into duplicate_match (
        request_id, run_id, is_current, candidate_source,
        candidate_supplier_ref_id, candidate_supplier_number, candidate_supplier_name,
        candidate_request_id, match_score, match_level, matched_fields_json,
        explanation, created_at
      ) values (
        p_request_id, p_run_id, 1, p_source,
        p_supplier_ref_id, p_supplier_number, p_supplier_name,
        p_candidate_request_id, least(100, l_score), l_level,
        json(l_fields.to_clob),
        case when l_critical = 1 then 'Critical exact duplicate signal found.'
             else 'Candidate matched one or more configured supplier signals.' end,
        systimestamp
      );
    end;
  begin
    select * into l_request from supplier_request where request_id = p_request_id;
    l_name := normalize_name(l_request.supplier_name);

    begin
      select lower(email_domain), regexp_replace(phone_number, '[^0-9+]', '')
        into l_email, l_phone
        from supplier_request_contact where request_id = p_request_id
        order by contact_id fetch first 1 row only;
    exception when no_data_found then l_email := null; l_phone := null; end;

    begin
      select normalize_token(address_line1 || ' ' || address_line2 || ' ' || city || ' ' || region)
        into l_address from supplier_request_site
       where request_id = p_request_id
       order by is_primary desc, site_id fetch first 1 row only;
    exception when no_data_found then l_address := null; end;

    begin
      select account_hash into l_bank_hash from supplier_request_bank
       where request_id = p_request_id and bank_provided_flag = 1
       order by bank_id fetch first 1 row only;
    exception when no_data_found then l_bank_hash := null; end;

    update duplicate_match set is_current = 0
     where request_id = p_request_id and is_current = 1;

    for c in (select * from existing_supplier_ref) loop
      l_score := 0; l_critical := 0; l_fields := json_array_t();
      if l_request.tax_registration_number is not null and
         normalize_token(l_request.tax_registration_number) = normalize_token(c.tax_registration_number) then
        l_critical := 1; l_score := 100; add_field('DUP_EXACT_TAX');
      end if;
      if l_bank_hash is not null and l_bank_hash = c.bank_account_hash then
        l_critical := 1; l_score := 100; add_field('DUP_SAME_BANK');
      end if;
      if l_name is not null and l_name = c.normalized_name then
        l_score := l_score + rule_weight('DUP_NAME_SIMILARITY', 30); add_field('DUP_NAME_SIMILARITY');
      end if;
      if l_request.country_code = c.country_code then
        l_score := l_score + rule_weight('DUP_SAME_COUNTRY', 10); add_field('DUP_SAME_COUNTRY');
      end if;
      if l_email is not null and l_email = lower(c.email_domain) then
        l_score := l_score + rule_weight('DUP_EMAIL_DOMAIN', 15); add_field('DUP_EMAIL_DOMAIN');
      end if;
      if l_phone is not null and l_phone = c.phone_normalized then
        l_score := l_score + rule_weight('DUP_PHONE', 20); add_field('DUP_PHONE');
      end if;
      if l_address is not null and l_address = c.address_normalized then
        l_score := l_score + rule_weight('DUP_ADDRESS', 20); add_field('DUP_ADDRESS');
      end if;
      persist_match('EXISTING_SUPPLIER', c.supplier_ref_id, c.supplier_number, c.supplier_name, null);
    end loop;

    for c in (
      select r.request_id, r.request_number, r.supplier_name, r.country_code,
             r.tax_registration_number,
             (select lower(email_domain) from supplier_request_contact x where x.request_id = r.request_id fetch first 1 row only) email_domain
        from supplier_request r where r.request_id <> p_request_id
    ) loop
      l_score := 0; l_critical := 0; l_fields := json_array_t();
      if l_request.tax_registration_number is not null and
         normalize_token(l_request.tax_registration_number) = normalize_token(c.tax_registration_number) then
        l_critical := 1; l_score := 100; add_field('DUP_EXACT_TAX');
      end if;
      if l_name is not null and l_name = normalize_name(c.supplier_name) then
        l_score := l_score + rule_weight('DUP_NAME_SIMILARITY', 30); add_field('DUP_NAME_SIMILARITY');
      end if;
      if l_request.country_code = c.country_code then
        l_score := l_score + rule_weight('DUP_SAME_COUNTRY', 10); add_field('DUP_SAME_COUNTRY');
      end if;
      if l_email is not null and l_email = c.email_domain then
        l_score := l_score + rule_weight('DUP_EMAIL_DOMAIN', 15); add_field('DUP_EMAIL_DOMAIN');
      end if;
      persist_match('STAGED_REQUEST', null, c.request_number, c.supplier_name, c.request_id);
    end loop;
  end;

  function matches_json(p_request_id number) return clob is
    l_json clob;
  begin
    select coalesce(json_arrayagg(json_object(
      'matchId' value match_id,
      'candidateSource' value candidate_source,
      'candidateSupplierNumber' value candidate_supplier_number,
      'candidateSupplierName' value candidate_supplier_name,
      'candidateRequestId' value candidate_request_id,
      'matchScore' value match_score,
      'matchLevel' value match_level,
      'matchedFields' value matched_fields_json,
      'explanation' value explanation
    ) returning clob), to_clob('[]')) into l_json
      from duplicate_match where request_id = p_request_id and is_current = 1;
    return l_json;
  end;
end erp_duplicate_pkg;
/
