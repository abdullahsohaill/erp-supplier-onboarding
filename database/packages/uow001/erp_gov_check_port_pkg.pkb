create or replace package body erp_gov_check_port_pkg as
    procedure add_validation(
        p_request_id number,
        p_run_id varchar2,
        p_rule_code varchar2,
        p_field_name varchar2 default null,
        p_override_message varchar2 default null
    ) is
    begin
        insert into validation_result (
            request_id, validation_rule_id, run_id, is_current, field_name,
            severity, message, is_blocking, created_at
        )
        select p_request_id, validation_rule_id, p_run_id, 1,
               nvl(p_field_name, field_name), severity,
               nvl(p_override_message, dbms_lob.substr(default_message, 4000, 1)),
               is_blocking, systimestamp
          from validation_rules
         where rule_code = p_rule_code and active_flag = 1;
    end;

    function rule_enabled(p_type varchar2, p_code varchar2) return boolean is
        l_count number;
    begin
        select count(*) into l_count
          from ref_scoring_rule
         where rule_type = p_type and rule_code = p_code and active_flag = 1;
        return l_count > 0;
    end;

    procedure run_checks(
        p_request_id number,
        p_actor varchar2,
        o_run_id out varchar2,
        o_blocking_count out number
    ) is
        l_request supplier_request%rowtype;
        l_count number;
        l_contact_domain varchar2(253);
        l_phone varchar2(40);
        l_address varchar2(500);
        l_bank_hash varchar2(128);
        l_bank_country varchar2(2);
        l_bank_provided number;
        l_bank_masked varchar2(40);
        l_score number;
        l_level varchar2(20);
        l_high_threshold number := 70;
        l_medium_threshold number := 40;
        l_risk_high number := 70;
        l_risk_medium number := 35;
        l_risk_score number := 0;
        l_reasons json_array_t := json_array_t();
        l_reason json_object_t;
        l_match_fields json_array_t;
        l_field json_object_t;
        l_ai json_object_t := json_object_t();
        l_json_clob clob;
        l_dup_name_enabled number := 0;
        l_dup_country_enabled number := 0;
        l_dup_email_enabled number := 0;
        l_dup_phone_enabled number := 0;
        l_dup_address_enabled number := 0;

        procedure add_risk(p_code varchar2, p_message varchar2) is
            l_weight number;
            l_severity varchar2(20);
        begin
            select weight, severity into l_weight, l_severity
              from ref_scoring_rule
             where rule_type = 'RISK' and rule_code = p_code and active_flag = 1
             order by version desc fetch first 1 row only;
            l_risk_score := least(100, l_risk_score + nvl(l_weight, 0));
            l_reason := json_object_t();
            l_reason.put('ruleCode', p_code);
            l_reason.put('weight', l_weight);
            l_reason.put('severity', l_severity);
            l_reason.put('explanation', p_message);
            l_reasons.append(l_reason);
        exception when no_data_found then null;
        end;
    begin
        select * into l_request from supplier_request where request_id = p_request_id for update;
        o_run_id := lower(rawtohex(sys_guid()));
        update validation_result set is_current = 0 where request_id = p_request_id and is_current = 1;
        update duplicate_match set is_current = 0 where request_id = p_request_id and is_current = 1;
        update risk_assessment set is_current = 0 where request_id = p_request_id and is_current = 1;

        if l_request.supplier_name is null then add_validation(p_request_id, o_run_id, 'VAL-001'); end if;
        if l_request.country_code is null then add_validation(p_request_id, o_run_id, 'VAL-002'); end if;
        if l_request.supplier_type_code is null then add_validation(p_request_id, o_run_id, 'VAL-003'); end if;
        select count(*) into l_count from ref_business_unit
         where business_unit_id = l_request.business_unit_id and active_flag = 1
           and fusion_mapping_code is not null;
        if l_count = 0 then add_validation(p_request_id, o_run_id, 'VAL-004'); end if;

        select count(*) into l_count from supplier_request_contact
         where request_id = p_request_id
           and regexp_like(contact_email, '^[^@[:space:]]+@[^@[:space:]]+[.][^@[:space:]]+$');
        if l_count = 0 then add_validation(p_request_id, o_run_id, 'VAL-005'); end if;

        select count(*) into l_count from supplier_request_site where request_id = p_request_id;
        if l_count = 0 then
            add_validation(p_request_id, o_run_id, 'VAL-007');
        else
            select count(*) into l_count from supplier_request_site
             where request_id = p_request_id
               and (address_line1 is null or address_line2 is null or city is null
                    or region is null or country_code is null
                    or length(address_line1) > 20 or length(address_line2) > 20);
            if l_count > 0 then add_validation(p_request_id, o_run_id, 'VAL-006'); end if;
        end if;

        begin
            select email_domain, phone_number into l_contact_domain, l_phone
              from supplier_request_contact where request_id = p_request_id
              order by contact_id fetch first 1 row only;
        exception when no_data_found then null;
        end;
        begin
            select erp_input_pkg.normalized_text(
                       address_line1 || ' ' || address_line2 || ' ' || city || ' ' || region || ' ' || country_code
                   ) into l_address
              from supplier_request_site where request_id = p_request_id and is_primary = 1
              fetch first 1 row only;
        exception when no_data_found then null;
        end;
        begin
            select account_hash, bank_country_code, bank_provided_flag, masked_account_display
              into l_bank_hash, l_bank_country, l_bank_provided, l_bank_masked
              from supplier_request_bank where request_id = p_request_id;
        exception when no_data_found then null;
        end;

        select nvl(max(case when rule_code = 'DUP_HIGH_THRESHOLD' then weight end), 70),
               nvl(max(case when rule_code = 'DUP_MEDIUM_THRESHOLD' then weight end), 40)
          into l_high_threshold, l_medium_threshold
          from ref_scoring_rule where rule_type = 'DUPLICATE' and active_flag = 1;

        if rule_enabled('DUPLICATE', 'DUP_NAME_SIMILARITY') then l_dup_name_enabled := 1; end if;
        if rule_enabled('DUPLICATE', 'DUP_SAME_COUNTRY') then l_dup_country_enabled := 1; end if;
        if rule_enabled('DUPLICATE', 'DUP_EMAIL_DOMAIN') then l_dup_email_enabled := 1; end if;
        if rule_enabled('DUPLICATE', 'DUP_PHONE') then l_dup_phone_enabled := 1; end if;
        if rule_enabled('DUPLICATE', 'DUP_ADDRESS') then l_dup_address_enabled := 1; end if;

        for candidate in (
            select e.*,
                   case when l_dup_name_enabled = 1
                             and e.normalized_name = erp_input_pkg.normalized_text(l_request.supplier_name) then 30 else 0 end
                 + case when l_dup_country_enabled = 1
                             and e.country_code = l_request.country_code then 10 else 0 end
                 + case when l_dup_email_enabled = 1
                             and e.email_domain = l_contact_domain then 15 else 0 end
                 + case when l_dup_phone_enabled = 1
                             and e.phone_normalized = l_phone then 20 else 0 end
                 + case when l_dup_address_enabled = 1
                             and e.address_normalized = l_address then 20 else 0 end as fuzzy_score
              from existing_supplier_ref e
        ) loop
            l_match_fields := json_array_t();
            l_score := candidate.fuzzy_score;
            if candidate.normalized_name = erp_input_pkg.normalized_text(l_request.supplier_name) then
                l_field := json_object_t(); l_field.put('field', 'supplierName'); l_field.put('ruleCode', 'DUP_NAME_SIMILARITY'); l_match_fields.append(l_field);
            end if;
            if candidate.country_code = l_request.country_code then
                l_field := json_object_t(); l_field.put('field', 'countryCode'); l_field.put('ruleCode', 'DUP_SAME_COUNTRY'); l_match_fields.append(l_field);
            end if;
            if candidate.email_domain = l_contact_domain then
                l_field := json_object_t(); l_field.put('field', 'emailDomain'); l_field.put('ruleCode', 'DUP_EMAIL_DOMAIN'); l_match_fields.append(l_field);
            end if;
            if candidate.tax_registration_number is not null
               and erp_input_pkg.normalized_text(candidate.tax_registration_number) = erp_input_pkg.normalized_text(l_request.tax_registration_number)
               and rule_enabled('DUPLICATE', 'DUP_EXACT_TAX') then
                l_score := 100;
                l_field := json_object_t(); l_field.put('field', 'taxRegistrationNumber'); l_field.put('ruleCode', 'DUP_EXACT_TAX'); l_match_fields.append(l_field);
                add_validation(p_request_id, o_run_id, 'VAL-008', 'taxRegistrationNumber', 'Tax registration matches supplier ' || candidate.supplier_number || '.');
            end if;
            if l_bank_hash is not null and candidate.bank_account_hash = l_bank_hash
               and rule_enabled('DUPLICATE', 'DUP_SAME_BANK') then
                l_score := 100;
                l_field := json_object_t(); l_field.put('field', 'bank.accountToken'); l_field.put('ruleCode', 'DUP_SAME_BANK'); l_match_fields.append(l_field);
                add_validation(p_request_id, o_run_id, 'VAL-009', 'bank.accountToken', 'Bank token matches an existing supplier.');
            end if;
            if l_score > 0 then
                l_level := case when l_score = 100 then 'CRITICAL' when l_score >= l_high_threshold then 'HIGH' when l_score >= l_medium_threshold then 'MEDIUM' else 'LOW' end;
                l_json_clob := l_match_fields.to_clob();
                insert into duplicate_match (
                    request_id, run_id, is_current, candidate_source,
                    candidate_supplier_ref_id, candidate_supplier_number,
                    candidate_supplier_name, match_score, match_level,
                    matched_fields_json, explanation, created_at
                ) values (
                    p_request_id, o_run_id, 1, 'EXISTING_SUPPLIER',
                    candidate.supplier_ref_id, candidate.supplier_number,
                    candidate.supplier_name, l_score, l_level,
                    l_json_clob, 'Configured normalized supplier comparison.', systimestamp
                );
            end if;
        end loop;

        if l_request.tax_registration_number is not null and rule_enabled('DUPLICATE', 'DUP_EXACT_TAX') then
            for staged in (
                select request_id, request_number, supplier_name from supplier_request
                 where request_id <> p_request_id
                   and tax_registration_number is not null
                   and erp_input_pkg.normalized_text(tax_registration_number) = erp_input_pkg.normalized_text(l_request.tax_registration_number)
            ) loop
                insert into duplicate_match (
                    request_id, run_id, is_current, candidate_source, candidate_request_id,
                    candidate_supplier_number, candidate_supplier_name, match_score,
                    match_level, matched_fields_json, explanation, created_at
                ) values (
                    p_request_id, o_run_id, 1, 'STAGED_REQUEST', staged.request_id,
                    staged.request_number, staged.supplier_name, 100, 'CRITICAL',
                    '[{"field":"taxRegistrationNumber","ruleCode":"DUP_EXACT_TAX"}]',
                    'Exact tax registration matched a staged request.', systimestamp
                );
                add_validation(p_request_id, o_run_id, 'VAL-008', 'taxRegistrationNumber', 'Tax registration matches staged request ' || staged.request_number || '.');
            end loop;
        end if;

        if l_bank_hash is not null and rule_enabled('DUPLICATE', 'DUP_SAME_BANK') then
            for staged_bank in (
                select r.request_id, r.request_number, r.supplier_name
                  from supplier_request_bank b
                  join supplier_request r on r.request_id = b.request_id
                 where b.request_id <> p_request_id and b.account_hash = l_bank_hash
            ) loop
                insert into duplicate_match (
                    request_id, run_id, is_current, candidate_source, candidate_request_id,
                    candidate_supplier_number, candidate_supplier_name, match_score,
                    match_level, matched_fields_json, explanation, created_at
                ) values (
                    p_request_id, o_run_id, 1, 'STAGED_REQUEST', staged_bank.request_id,
                    staged_bank.request_number, staged_bank.supplier_name, 100, 'CRITICAL',
                    '[{"field":"bank.accountToken","ruleCode":"DUP_SAME_BANK"}]',
                    'Exact bank token matched a staged request.', systimestamp
                );
                add_validation(
                    p_request_id, o_run_id, 'VAL-009', 'bank.accountToken',
                    'Bank token matches staged request ' || staged_bank.request_number || '.'
                );
            end loop;
        end if;

        select nvl(max(case when rule_code = 'RISK_HIGH_THRESHOLD' then weight end), 70),
               nvl(max(case when rule_code = 'RISK_MEDIUM_THRESHOLD' then weight end), 35)
          into l_risk_high, l_risk_medium
          from ref_scoring_rule where rule_type = 'RISK' and active_flag = 1;
        select count(*) into l_count from ref_supplier_type
         where supplier_type_code = l_request.supplier_type_code and tax_required_flag = 1;
        if l_count > 0 and l_request.tax_registration_number is null then add_risk('MISSING_TAX', 'Tax registration is expected for this supplier type.'); end if;
        select count(*) into l_count from ref_high_risk_country
         where country_code = l_request.country_code and active_flag = 1
           and trunc(sysdate) between effective_from and nvl(effective_to, date '2999-12-31');
        if l_count > 0 then add_risk('HIGH_RISK_COUNTRY', 'Supplier country is configured as a Reviewer warning.'); end if;
        if l_bank_country is not null and l_bank_country <> l_request.country_code then add_risk('BANK_COUNTRY_MISMATCH', 'Bank and supplier countries differ.'); end if;
        if l_bank_provided = 1 and (l_bank_hash is null or l_bank_masked is null) then add_risk('INCOMPLETE_BANK_DETAILS', 'Captured bank metadata is incomplete.'); end if;
        if length(trim(l_request.business_justification)) < 40 then add_risk('VAGUE_JUSTIFICATION', 'Business justification is brief and requires Reviewer attention.'); end if;
        if nvl(l_request.expected_annual_spend, 0) >= 1000000 and length(trim(l_request.business_justification)) < 100 then add_risk('HIGH_SPEND_WEAK_JUSTIFICATION', 'High spend has limited justification.'); end if;
        select count(*) into l_count from supplier_request_document where request_id = p_request_id and is_required = 1 and missing_flag = 1;
        if l_count > 0 then add_risk('MISSING_DOCUMENT_METADATA', 'A required document is marked missing.'); end if;
        select count(*) into l_count from duplicate_match where request_id = p_request_id and run_id = o_run_id and match_level = 'HIGH';
        if l_count > 0 then add_risk('DUPLICATE_SCORE_HIGH', 'A high duplicate score requires review.'); end if;
        select count(*) into l_count from duplicate_match where request_id = p_request_id and run_id = o_run_id and match_level = 'MEDIUM';
        if l_count > 0 then add_risk('DUPLICATE_SCORE_MEDIUM', 'A medium duplicate score requires review.'); end if;

        l_level := case when l_risk_score >= l_risk_high then 'HIGH' when l_risk_score >= l_risk_medium then 'MEDIUM' else 'LOW' end;
        l_json_clob := l_reasons.to_clob();
        insert into risk_assessment (
            request_id, run_id, is_current, risk_score, risk_level,
            scoring_version, risk_reasons_json, created_at
        ) values (p_request_id, o_run_id, 1, l_risk_score, l_level, '1.0', l_json_clob, systimestamp);

        l_ai.put('advisory', true);
        l_ai.put('summary', 'Deterministic review summary generated from persisted validation, duplicate, and risk facts.');
        l_ai.put('riskLevel', l_level);
        l_ai.put('riskScore', l_risk_score);
        l_ai.put('sourceRunId', o_run_id);
        l_json_clob := l_ai.to_clob();
        insert into ai_summary (
            request_id, prompt_version, provider_name, model_name,
            summary_json, source_facts_hash, created_at, created_by
        ) values (
            p_request_id, 'supplier-review-v1', 'LOCAL_DETERMINISTIC_MOCK',
            'facts-template-v1', l_json_clob,
            standard_hash(to_char(p_request_id) || ':' || o_run_id || ':' || to_char(l_risk_score), 'SHA256'),
            systimestamp, substr(p_actor, 1, 128)
        );
        select count(*) into o_blocking_count from validation_result
         where request_id = p_request_id and run_id = o_run_id and is_blocking = 1;
    end;

    function duplicate_json(p_request_id number) return clob is
        l_json clob;
    begin
        select coalesce(json_arrayagg(json_object(
            'matchId' value match_id, 'candidateSource' value candidate_source,
            'candidateSupplierNumber' value candidate_supplier_number,
            'candidateSupplierName' value candidate_supplier_name,
            'candidateRequestId' value candidate_request_id,
            'matchScore' value match_score, 'matchLevel' value match_level,
            'matchedFields' value matched_fields_json format json,
            'explanation' value explanation
        ) returning clob), to_clob('[]')) into l_json
          from duplicate_match where request_id = p_request_id and is_current = 1;
        return l_json;
    end;

    function risk_json(p_request_id number) return clob is
        l_json clob;
    begin
        select json_object('riskId' value risk_id, 'riskScore' value risk_score,
            'riskLevel' value risk_level, 'scoringVersion' value scoring_version,
            'reasons' value risk_reasons_json format json returning clob)
          into l_json from risk_assessment
         where request_id = p_request_id and is_current = 1
         order by created_at desc fetch first 1 row only;
        return l_json;
    exception when no_data_found then return '{}';
    end;

    function ai_json(p_request_id number) return clob is
        l_json clob;
    begin
        select coalesce(json_arrayagg(json_object(
            'summaryId' value summary_id, 'promptVersion' value prompt_version,
            'providerName' value provider_name, 'modelName' value model_name,
            'summary' value summary_json format json,
            'createdAt' value to_char(created_at, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZH:TZM')
        ) order by created_at desc returning clob), to_clob('[]')) into l_json
          from ai_summary where request_id = p_request_id;
        return l_json;
    end;
end erp_gov_check_port_pkg;
/
