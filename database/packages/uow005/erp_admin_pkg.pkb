create or replace package body erp_admin_pkg as
    procedure assert_admin is
    begin
        erp_principal_pkg.assert_role('SUPPORT_ADMIN');
    end;

    function high_risk_countries return clob is l_json clob;
    begin
        assert_admin();
        select coalesce(json_arrayagg(json_object(
            'countryCode' value country_code, 'effectiveFrom' value to_char(effective_from, 'YYYY-MM-DD'),
            'countryName' value country_name, 'riskLevel' value risk_level,
            'active' value case active_flag when 1 then 'true' else 'false' end format json,
            'effectiveTo' value to_char(effective_to, 'YYYY-MM-DD')
        ) order by country_code, effective_from desc returning clob), to_clob('[]')) into l_json
          from ref_high_risk_country;
        return erp_api_util_pkg.success(l_json);
    end;

    procedure put_high_risk_country(p_country_code varchar2, p_effective_from varchar2, p_body clob, o_status out number, o_body out clob) is
        l_payload json_object_t := erp_input_pkg.parse_object(p_body);
        l_date date := to_date(p_effective_from, 'YYYY-MM-DD');
        l_country_name varchar2(120);
        l_risk_level varchar2(20);
        l_active number := 0;
        l_effective_to date;
        l_actor varchar2(128);
    begin
        assert_admin();
        erp_input_pkg.assert_allowed_keys(l_payload, 'countryName,riskLevel,active,effectiveTo');
        l_country_name := erp_input_pkg.optional_string(l_payload, 'countryName', 120);
        l_risk_level := upper(erp_input_pkg.optional_string(l_payload, 'riskLevel', 20));
        if l_payload.has('active') and l_payload.get_boolean('active') then l_active := 1; end if;
        if l_payload.has('effectiveTo') and not l_payload.get('effectiveTo').is_null then
            l_effective_to := to_date(l_payload.get_string('effectiveTo'), 'YYYY-MM-DD');
        end if;
        l_actor := erp_principal_pkg.subject();
        merge into ref_high_risk_country t using (select upper(p_country_code) code, l_date effective_from from dual) s
        on (t.country_code = s.code and t.effective_from = s.effective_from)
        when matched then update set
            t.country_name = l_country_name,
            t.risk_level = l_risk_level,
            t.active_flag = l_active,
            t.effective_to = l_effective_to,
            t.updated_at = systimestamp, t.updated_by = l_actor
        when not matched then insert (country_code, effective_from, country_name, risk_level, active_flag, effective_to, created_by)
        values (s.code, s.effective_from, l_country_name, l_risk_level,
            l_active, l_effective_to, l_actor);
        commit; o_status := 200; o_body := high_risk_countries();
    exception when others then rollback; o_status := 400; o_body := erp_api_util_pkg.failure('ADMIN_UPDATE_REJECTED', 'High-risk country update was rejected.');
    end;

    function validation_rules return clob is l_json clob;
    begin
        assert_admin();
        select coalesce(json_arrayagg(json_object(
            'ruleCode' value rule_code, 'ruleName' value rule_name,
            'description' value rule_description, 'fieldName' value field_name,
            'severity' value severity, 'blocking' value case is_blocking when 1 then 'true' else 'false' end format json,
            'active' value case active_flag when 1 then 'true' else 'false' end format json
        ) order by rule_code returning clob), to_clob('[]')) into l_json from validation_rules;
        return erp_api_util_pkg.success(l_json);
    end;

    procedure put_validation_rule(p_rule_code varchar2, p_body clob, o_status out number, o_body out clob) is
        l_payload json_object_t := erp_input_pkg.parse_object(p_body);
        l_active number;
        l_actor varchar2(128);
    begin
        assert_admin();
        erp_input_pkg.assert_allowed_keys(l_payload, 'active');
        if not l_payload.has('active') then raise_application_error(-20000, 'ACTIVE_FLAG_REQUIRED'); end if;
        if l_payload.get_boolean('active') then l_active := 1; else l_active := 0; end if;
        l_actor := erp_principal_pkg.subject();
        update validation_rules set active_flag = l_active,
            updated_at = systimestamp, updated_by = l_actor
         where rule_code = upper(p_rule_code);
        if sql%rowcount = 0 then raise no_data_found; end if;
        commit; o_status := 200; o_body := validation_rules();
    exception when no_data_found then rollback; o_status := 404; o_body := erp_api_util_pkg.failure('RULE_NOT_FOUND', 'Validation rule was not found.');
    end;

    function scoring_rules(p_rule_type varchar2 default null) return clob is l_json clob;
    begin
        assert_admin();
        select coalesce(json_arrayagg(json_object(
            'ruleType' value rule_type, 'ruleCode' value rule_code, 'version' value version,
            'ruleName' value rule_name, 'weight' value weight, 'severity' value severity,
            'criticalTrigger' value case critical_trigger_flag when 1 then 'true' else 'false' end format json,
            'active' value case active_flag when 1 then 'true' else 'false' end format json
        ) order by rule_type, rule_code, version returning clob), to_clob('[]')) into l_json
          from ref_scoring_rule where p_rule_type is null or rule_type = upper(p_rule_type);
        return erp_api_util_pkg.success(l_json);
    end;

    procedure put_scoring_rule(p_rule_type varchar2, p_rule_code varchar2, p_version varchar2, p_body clob, o_status out number, o_body out clob) is
        l_payload json_object_t := erp_input_pkg.parse_object(p_body);
        l_number number;
        l_text varchar2(20);
        l_actor varchar2(128);
    begin
        assert_admin();
        erp_input_pkg.assert_allowed_keys(l_payload, 'active,weight,severity,criticalTrigger');
        l_actor := erp_principal_pkg.subject();
        update ref_scoring_rule set updated_at = systimestamp, updated_by = l_actor
         where rule_type = upper(p_rule_type) and rule_code = upper(p_rule_code) and version = p_version;
        if sql%rowcount = 0 then raise no_data_found; end if;
        if l_payload.has('active') then
            if l_payload.get_boolean('active') then l_number := 1; else l_number := 0; end if;
            update ref_scoring_rule set active_flag = l_number
             where rule_type = upper(p_rule_type) and rule_code = upper(p_rule_code) and version = p_version;
        end if;
        if l_payload.has('weight') then
            l_number := null;
            if not l_payload.get('weight').is_null then l_number := l_payload.get_number('weight'); end if;
            update ref_scoring_rule set weight = l_number
             where rule_type = upper(p_rule_type) and rule_code = upper(p_rule_code) and version = p_version;
        end if;
        if l_payload.has('severity') then
            l_text := upper(erp_input_pkg.optional_string(l_payload, 'severity', 20));
            update ref_scoring_rule set severity = l_text
             where rule_type = upper(p_rule_type) and rule_code = upper(p_rule_code) and version = p_version;
        end if;
        if l_payload.has('criticalTrigger') then
            if l_payload.get_boolean('criticalTrigger') then l_number := 1; else l_number := 0; end if;
            update ref_scoring_rule set critical_trigger_flag = l_number
             where rule_type = upper(p_rule_type) and rule_code = upper(p_rule_code) and version = p_version;
        end if;
        commit; o_status := 200; o_body := scoring_rules(p_rule_type);
    exception when no_data_found then rollback; o_status := 404; o_body := erp_api_util_pkg.failure('RULE_NOT_FOUND', 'Scoring rule version was not found.');
    end;

    function business_units return clob is l_json clob;
    begin
        assert_admin();
        select coalesce(json_arrayagg(json_object(
            'businessUnitId' value business_unit_id, 'code' value business_unit_code,
            'name' value business_unit_name, 'fusionMappingCode' value fusion_mapping_code,
            'active' value case active_flag when 1 then 'true' else 'false' end format json
        ) order by business_unit_code returning clob), to_clob('[]')) into l_json from ref_business_unit;
        return erp_api_util_pkg.success(l_json);
    end;

    procedure put_business_unit(p_code varchar2, p_body clob, o_status out number, o_body out clob) is
        l_payload json_object_t := erp_input_pkg.parse_object(p_body);
        l_name varchar2(120);
        l_mapping varchar2(60);
        l_active number := 0;
        l_actor varchar2(128);
    begin
        assert_admin();
        erp_input_pkg.assert_allowed_keys(l_payload, 'name,fusionMappingCode,active');
        l_name := erp_input_pkg.optional_string(l_payload, 'name', 120);
        l_mapping := erp_input_pkg.optional_string(l_payload, 'fusionMappingCode', 60);
        if l_payload.has('active') and l_payload.get_boolean('active') then l_active := 1; end if;
        l_actor := erp_principal_pkg.subject();
        merge into ref_business_unit t using (select upper(p_code) code from dual) s on (t.business_unit_code = s.code)
        when matched then update set t.business_unit_name = l_name,
            t.fusion_mapping_code = l_mapping,
            t.active_flag = l_active,
            t.updated_at = systimestamp, t.updated_by = l_actor
        when not matched then insert (business_unit_code, business_unit_name, fusion_mapping_code, active_flag, created_by)
        values (s.code, l_name, l_mapping, l_active, l_actor);
        commit; o_status := 200; o_body := business_units();
    exception when others then rollback; o_status := 400; o_body := erp_api_util_pkg.failure('ADMIN_UPDATE_REJECTED', 'Business unit update was rejected.');
    end;

    function supplier_types return clob is l_json clob;
    begin
        assert_admin();
        select coalesce(json_arrayagg(json_object(
            'supplierTypeId' value supplier_type_id, 'code' value supplier_type_code,
            'name' value supplier_type_name,
            'taxRequired' value case tax_required_flag when 1 then 'true' else 'false' end format json,
            'active' value case active_flag when 1 then 'true' else 'false' end format json
        ) order by supplier_type_code returning clob), to_clob('[]')) into l_json from ref_supplier_type;
        return erp_api_util_pkg.success(l_json);
    end;

    procedure put_supplier_type(p_code varchar2, p_body clob, o_status out number, o_body out clob) is
        l_payload json_object_t := erp_input_pkg.parse_object(p_body);
        l_name varchar2(120);
        l_tax_required number := 0;
        l_active number := 0;
        l_actor varchar2(128);
    begin
        assert_admin();
        erp_input_pkg.assert_allowed_keys(l_payload, 'name,taxRequired,active');
        l_name := erp_input_pkg.optional_string(l_payload, 'name', 120);
        if l_payload.has('taxRequired') and l_payload.get_boolean('taxRequired') then l_tax_required := 1; end if;
        if l_payload.has('active') and l_payload.get_boolean('active') then l_active := 1; end if;
        l_actor := erp_principal_pkg.subject();
        merge into ref_supplier_type t using (select upper(p_code) code from dual) s on (t.supplier_type_code = s.code)
        when matched then update set t.supplier_type_name = l_name,
            t.tax_required_flag = l_tax_required,
            t.active_flag = l_active,
            t.updated_at = systimestamp, t.updated_by = l_actor
        when not matched then insert (supplier_type_code, supplier_type_name, tax_required_flag, active_flag, created_by)
        values (s.code, l_name, l_tax_required, l_active, l_actor);
        commit; o_status := 200; o_body := supplier_types();
    exception when others then rollback; o_status := 400; o_body := erp_api_util_pkg.failure('ADMIN_UPDATE_REJECTED', 'Supplier type update was rejected.');
    end;
end erp_admin_pkg;
/
