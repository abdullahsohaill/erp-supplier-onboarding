create or replace package erp_admin_pkg authid definer as
  function flag(p_obj json_object_t, p_key varchar2, p_default number) return number;
  function str(p_obj json_object_t, p_key varchar2) return varchar2;
  function num(p_obj json_object_t, p_key varchar2, p_default number) return number;
  function business_units_json(p_include_inactive number default 0) return clob;
  function supplier_types_json(p_include_inactive number default 0) return clob;
  function high_risk_countries_json return clob;
  function validation_rules_json return clob;
  function scoring_rules_json(p_rule_type varchar2 default null) return clob;
  procedure update_validation_rule(p_rule_code varchar2, p_body clob, p_actor varchar2, p_result out clob, p_status out number);
  procedure update_scoring_rule(p_rule_type varchar2, p_rule_code varchar2, p_version varchar2, p_body clob, p_actor varchar2, p_result out clob, p_status out number);
  procedure update_business_unit(p_code varchar2, p_body clob, p_actor varchar2, p_result out clob, p_status out number);
  procedure update_supplier_type(p_code varchar2, p_body clob, p_actor varchar2, p_result out clob, p_status out number);
  procedure update_high_risk_country(p_country varchar2, p_effective_from varchar2, p_body clob, p_actor varchar2, p_result out clob, p_status out number);
  function trigger_reference_sync(p_actor varchar2) return clob;
  procedure upsert_supplier(p_fusion_id varchar2, p_body clob, p_actor varchar2, p_result out clob, p_status out number);
  procedure upsert_supplier_site(p_fusion_id varchar2, p_site_id varchar2, p_body clob, p_actor varchar2, p_result out clob, p_status out number);
end erp_admin_pkg;
/

create or replace package body erp_admin_pkg as
  function flag(p_obj json_object_t, p_key varchar2, p_default number) return number is
  begin
    if not p_obj.has(p_key) then return p_default; end if;
    return case when p_obj.get_boolean(p_key) then 1 else 0 end;
  exception when others then return p_default;
  end;

  function str(p_obj json_object_t, p_key varchar2) return varchar2 is
  begin
    if not p_obj.has(p_key) or p_obj.get(p_key).is_null then return null; end if;
    return p_obj.get_string(p_key);
  exception when others then return null;
  end;

  function num(p_obj json_object_t, p_key varchar2, p_default number) return number is
  begin
    if not p_obj.has(p_key) or p_obj.get(p_key).is_null then return p_default; end if;
    return p_obj.get_number(p_key);
  exception when others then return p_default;
  end;

  function business_units_json(p_include_inactive number default 0) return clob is l_json clob;
  begin
    select coalesce(json_arrayagg(json_object(
      'businessUnitId' value business_unit_id, 'businessUnitCode' value business_unit_code,
      'businessUnitName' value business_unit_name, 'fusionMappingCode' value fusion_mapping_code,
      'active' value case when active_flag=1 then 'true' else 'false' end format json
    ) order by business_unit_code returning clob),to_clob('[]')) into l_json from ref_business_unit
     where p_include_inactive=1 or active_flag=1;
    return l_json;
  end;

  function supplier_types_json(p_include_inactive number default 0) return clob is l_json clob;
  begin
    select coalesce(json_arrayagg(json_object(
      'supplierTypeId' value supplier_type_id, 'supplierTypeCode' value supplier_type_code,
      'supplierTypeName' value supplier_type_name,
      'taxRequired' value case when tax_required_flag=1 then 'true' else 'false' end format json,
      'active' value case when active_flag=1 then 'true' else 'false' end format json
    ) order by supplier_type_code returning clob),to_clob('[]')) into l_json from ref_supplier_type
     where p_include_inactive=1 or active_flag=1;
    return l_json;
  end;

  function high_risk_countries_json return clob is l_json clob;
  begin
    select coalesce(json_arrayagg(json_object(
      'countryCode' value country_code, 'effectiveFrom' value to_char(effective_from,'YYYY-MM-DD'),
      'countryName' value country_name, 'riskLevel' value risk_level,
      'active' value case when active_flag=1 then 'true' else 'false' end format json,
      'effectiveTo' value to_char(effective_to,'YYYY-MM-DD')
    ) order by country_code,effective_from returning clob),to_clob('[]')) into l_json from ref_high_risk_country;
    return l_json;
  end;

  function validation_rules_json return clob is l_json clob;
  begin
    select coalesce(json_arrayagg(json_object(
      'validationRuleId' value validation_rule_id, 'ruleCode' value rule_code,
      'ruleName' value rule_name, 'ruleDescription' value rule_description,
      'fieldName' value field_name, 'severity' value severity,
      'defaultMessage' value default_message,
      'isBlocking' value case when is_blocking=1 then 'true' else 'false' end format json,
      'active' value case when active_flag=1 then 'true' else 'false' end format json
    ) order by rule_code returning clob),to_clob('[]')) into l_json from validation_rules;
    return l_json;
  end;

  function scoring_rules_json(p_rule_type varchar2 default null) return clob is l_json clob;
  begin
    select coalesce(json_arrayagg(json_object(
      'ruleCode' value rule_code, 'version' value version, 'ruleType' value rule_type,
      'ruleName' value rule_name, 'weight' value weight, 'severity' value severity,
      'criticalTrigger' value case when critical_trigger_flag=1 then 'true' else 'false' end format json,
      'active' value case when active_flag=1 then 'true' else 'false' end format json
    ) order by rule_type,rule_code,version returning clob),to_clob('[]')) into l_json from ref_scoring_rule
     where p_rule_type is null or rule_type=upper(p_rule_type);
    return l_json;
  end;

  procedure update_validation_rule(p_rule_code varchar2, p_body clob, p_actor varchar2, p_result out clob, p_status out number) is
    l_obj json_object_t:=json_object_t.parse(p_body); l_count number;
  begin
    erp_security_pkg.assert_admin(p_actor);
    update validation_rules set active_flag=flag(l_obj,'active',active_flag),updated_at=systimestamp,updated_by=lower(p_actor)
     where rule_code=p_rule_code;
    l_count:=sql%rowcount; if l_count=0 then raise no_data_found; end if;
    commit; p_status:=200;
    select erp_api_pkg.success(json_object('ruleCode' value p_rule_code returning clob)) into p_result from dual;
  exception when no_data_found then rollback;p_status:=404;p_result:=erp_api_pkg.error('ADMIN','RULE_NOT_FOUND','Validation rule not found.');
    when others then rollback;p_status:=400;p_result:=erp_api_pkg.error('ADMIN','INVALID_SETTING','Validation rule setting is invalid.'); end;

  procedure update_scoring_rule(p_rule_type varchar2,p_rule_code varchar2,p_version varchar2,p_body clob,p_actor varchar2,p_result out clob,p_status out number) is
    l_obj json_object_t:=json_object_t.parse(p_body);l_count number;
  begin
    erp_security_pkg.assert_admin(p_actor);
    if upper(p_rule_type) not in ('RISK','DUPLICATE') then raise_application_error(-20050,'INVALID_RULE_TYPE');end if;
    update ref_scoring_rule set weight=num(l_obj,'weight',weight),severity=nvl(str(l_obj,'severity'),severity),
      critical_trigger_flag=flag(l_obj,'criticalTrigger',critical_trigger_flag),active_flag=flag(l_obj,'active',active_flag),
      updated_at=systimestamp,updated_by=lower(p_actor)
     where rule_type=upper(p_rule_type) and rule_code=p_rule_code and version=p_version;
    l_count:=sql%rowcount;if l_count=0 then raise no_data_found;end if;
    commit;p_status:=200;
    select erp_api_pkg.success(json_object('ruleType' value upper(p_rule_type),'ruleCode' value p_rule_code,'version' value p_version returning clob)) into p_result from dual;
  exception when no_data_found then rollback;p_status:=404;p_result:=erp_api_pkg.error('ADMIN','RULE_NOT_FOUND','Scoring rule not found.');
    when others then rollback;p_status:=400;p_result:=erp_api_pkg.error('ADMIN','INVALID_SETTING','Scoring rule setting is invalid.');end;

  procedure update_business_unit(p_code varchar2,p_body clob,p_actor varchar2,p_result out clob,p_status out number) is
    l_obj json_object_t:=json_object_t.parse(p_body);l_count number;
  begin
    erp_security_pkg.assert_admin(p_actor);
    update ref_business_unit set business_unit_name=nvl(str(l_obj,'businessUnitName'),business_unit_name),
      fusion_mapping_code=nvl(str(l_obj,'fusionMappingCode'),fusion_mapping_code),active_flag=flag(l_obj,'active',active_flag),
      updated_at=systimestamp,updated_by=lower(p_actor) where business_unit_code=p_code;
    l_count:=sql%rowcount;if l_count=0 then raise no_data_found;end if;
    commit;p_status:=200;
    select erp_api_pkg.success(json_object('businessUnitCode' value p_code returning clob)) into p_result from dual;
  exception when no_data_found then rollback;p_status:=404;p_result:=erp_api_pkg.error('ADMIN','BUSINESS_UNIT_NOT_FOUND','Business unit not found.');
    when others then rollback;p_status:=400;p_result:=erp_api_pkg.error('ADMIN','INVALID_SETTING','Business unit setting is invalid.');end;

  procedure update_supplier_type(p_code varchar2,p_body clob,p_actor varchar2,p_result out clob,p_status out number) is
    l_obj json_object_t:=json_object_t.parse(p_body);l_count number;
  begin
    erp_security_pkg.assert_admin(p_actor);
    update ref_supplier_type set supplier_type_name=nvl(str(l_obj,'supplierTypeName'),supplier_type_name),
      tax_required_flag=flag(l_obj,'taxRequired',tax_required_flag),active_flag=flag(l_obj,'active',active_flag),
      updated_at=systimestamp,updated_by=lower(p_actor) where supplier_type_code=p_code;
    l_count:=sql%rowcount;if l_count=0 then raise no_data_found;end if;
    commit;p_status:=200;
    select erp_api_pkg.success(json_object('supplierTypeCode' value p_code returning clob)) into p_result from dual;
  exception when no_data_found then rollback;p_status:=404;p_result:=erp_api_pkg.error('ADMIN','SUPPLIER_TYPE_NOT_FOUND','Supplier type not found.');
    when others then rollback;p_status:=400;p_result:=erp_api_pkg.error('ADMIN','INVALID_SETTING','Supplier type setting is invalid.');end;

  procedure update_high_risk_country(p_country varchar2,p_effective_from varchar2,p_body clob,p_actor varchar2,p_result out clob,p_status out number) is
    l_obj json_object_t:=json_object_t.parse(p_body);l_date date:=to_date(p_effective_from,'YYYY-MM-DD');l_count number;
  begin
    erp_security_pkg.assert_admin(p_actor);
    update ref_high_risk_country set country_name=nvl(str(l_obj,'countryName'),country_name),risk_level=nvl(str(l_obj,'riskLevel'),risk_level),
      active_flag=flag(l_obj,'active',active_flag),effective_to=case when l_obj.has('effectiveTo') then to_date(str(l_obj,'effectiveTo'),'YYYY-MM-DD') else effective_to end,
      updated_at=systimestamp,updated_by=lower(p_actor) where country_code=upper(p_country) and effective_from=l_date;
    l_count:=sql%rowcount;if l_count=0 then raise no_data_found;end if;
    commit;p_status:=200;
    select erp_api_pkg.success(json_object('countryCode' value upper(p_country),'effectiveFrom' value p_effective_from returning clob)) into p_result from dual;
  exception when no_data_found then rollback;p_status:=404;p_result:=erp_api_pkg.error('ADMIN','COUNTRY_PERIOD_NOT_FOUND','High-risk-country period not found.');
    when others then rollback;p_status:=400;p_result:=erp_api_pkg.error('ADMIN','INVALID_SETTING','High-risk-country setting is invalid.');end;

  function trigger_reference_sync(p_actor varchar2) return clob is
    l_result clob;
  begin
    erp_security_pkg.assert_admin(p_actor);
    select json_object('oicInstanceId' value 'MOCK-SYNC-'||substr(rawtohex(sys_guid()),1,16),
      'status' value 'ACCEPTED','monitoringLocation' value 'OIC_MOCK_MONITORING',
      'requestedBy' value lower(p_actor) returning clob) into l_result from dual;
    return l_result;
  end;

  procedure upsert_supplier(p_fusion_id varchar2,p_body clob,p_actor varchar2,p_result out clob,p_status out number) is
    l_obj json_object_t:=json_object_t.parse(p_body);l_id number;
  begin
    erp_security_pkg.assert_system_or_admin(p_actor);
    merge into existing_supplier_ref d using (select p_fusion_id fusion_id from dual) s on (d.fusion_supplier_id=s.fusion_id)
    when matched then update set supplier_number=str(l_obj,'supplierNumber'),supplier_name=str(l_obj,'supplierName'),
      normalized_name=erp_duplicate_pkg.normalize_name(str(l_obj,'supplierName')),country_code=str(l_obj,'countryCode'),
      tax_registration_number=str(l_obj,'taxRegistrationNumber'),email_domain=lower(str(l_obj,'emailDomain')),
      phone_normalized=str(l_obj,'phoneNormalized'),address_normalized=str(l_obj,'addressNormalized'),
      bank_account_hash=str(l_obj,'bankAccountHash'),last_sync_at=systimestamp
    when not matched then insert (fusion_supplier_id,supplier_number,supplier_name,normalized_name,country_code,tax_registration_number,
      email_domain,phone_normalized,address_normalized,bank_account_hash,last_sync_at)
      values(p_fusion_id,str(l_obj,'supplierNumber'),str(l_obj,'supplierName'),erp_duplicate_pkg.normalize_name(str(l_obj,'supplierName')),
      str(l_obj,'countryCode'),str(l_obj,'taxRegistrationNumber'),lower(str(l_obj,'emailDomain')),str(l_obj,'phoneNormalized'),
      str(l_obj,'addressNormalized'),str(l_obj,'bankAccountHash'),systimestamp);
    select supplier_ref_id into l_id from existing_supplier_ref where fusion_supplier_id=p_fusion_id;
    commit;p_status:=200;
    select erp_api_pkg.success(json_object('supplierRefId' value l_id returning clob)) into p_result from dual;
  exception when others then rollback;p_status:=400;p_result:=erp_api_pkg.error('REFERENCE','INVALID_SUPPLIER_REFERENCE','Supplier reference payload is invalid.');end;

  procedure upsert_supplier_site(p_fusion_id varchar2,p_site_id varchar2,p_body clob,p_actor varchar2,p_result out clob,p_status out number) is
    l_obj json_object_t:=json_object_t.parse(p_body);l_supplier_id number;l_id number;
  begin
    erp_security_pkg.assert_system_or_admin(p_actor);
    select supplier_ref_id into l_supplier_id from existing_supplier_ref where fusion_supplier_id=p_fusion_id;
    merge into existing_supplier_site_ref d using(select l_supplier_id supplier_id,p_site_id site_id from dual)s
      on(d.supplier_ref_id=s.supplier_id and d.fusion_site_id=s.site_id)
    when matched then update set site_name=str(l_obj,'siteName'),country_code=str(l_obj,'countryCode'),
      address_normalized=str(l_obj,'addressNormalized'),business_unit_code=str(l_obj,'businessUnitCode')
    when not matched then insert(supplier_ref_id,fusion_site_id,site_name,country_code,address_normalized,business_unit_code)
      values(l_supplier_id,p_site_id,str(l_obj,'siteName'),str(l_obj,'countryCode'),str(l_obj,'addressNormalized'),str(l_obj,'businessUnitCode'));
    select site_ref_id into l_id from existing_supplier_site_ref where supplier_ref_id=l_supplier_id and fusion_site_id=p_site_id;
    commit;p_status:=200;
    select erp_api_pkg.success(json_object('siteRefId' value l_id returning clob)) into p_result from dual;
  exception when no_data_found then rollback;p_status:=404;p_result:=erp_api_pkg.error('REFERENCE','SUPPLIER_REFERENCE_NOT_FOUND','Parent supplier reference not found.');
    when others then rollback;p_status:=400;p_result:=erp_api_pkg.error('REFERENCE','INVALID_SITE_REFERENCE','Supplier site reference payload is invalid.');end;
end erp_admin_pkg;
/
