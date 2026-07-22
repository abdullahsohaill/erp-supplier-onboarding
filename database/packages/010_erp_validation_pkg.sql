create or replace package erp_validation_pkg authid definer as
  procedure run(
    p_request_id  number,
    p_run_id      varchar2,
    p_has_blocker out number
  );
  function results_json(p_request_id number) return clob;
end erp_validation_pkg;
/

create or replace package body erp_validation_pkg as
  procedure run(
    p_request_id  number,
    p_run_id      varchar2,
    p_has_blocker out number
  ) is
    l_request supplier_request%rowtype;
    l_count number;
    l_email supplier_request_contact.contact_email%type;

    procedure add_failure(p_rule_code varchar2, p_field varchar2 default null) is
      l_rule validation_rules%rowtype;
    begin
      select * into l_rule
        from validation_rules
       where rule_code = p_rule_code
         and active_flag = 1;

      insert into validation_result (
        request_id, validation_rule_id, run_id, is_current, field_name,
        severity, message, is_blocking, created_at
      ) values (
        p_request_id, l_rule.validation_rule_id, p_run_id, 1,
        nvl(p_field, l_rule.field_name), l_rule.severity,
        l_rule.default_message, l_rule.is_blocking, systimestamp
      );
      if l_rule.is_blocking = 1 then
        p_has_blocker := 1;
      end if;
    exception
      when no_data_found then null;
    end;

  begin
    p_has_blocker := 0;
    select * into l_request from supplier_request where request_id = p_request_id for update;

    update validation_result set is_current = 0
     where request_id = p_request_id and is_current = 1;

    if trim(l_request.supplier_name) is null then add_failure('VAL-001', 'supplierName'); end if;
    if trim(l_request.country_code) is null then add_failure('VAL-002', 'countryCode'); end if;
    if trim(l_request.supplier_type_code) is null then add_failure('VAL-003', 'supplierType'); end if;

    select count(*) into l_count
      from ref_business_unit
     where business_unit_id = l_request.business_unit_id
       and active_flag = 1
       and fusion_mapping_code is not null;
    if l_count = 0 then add_failure('VAL-004', 'businessUnitCode'); end if;

    begin
      select contact_email into l_email
        from supplier_request_contact
       where request_id = p_request_id
       order by contact_id
       fetch first 1 row only;
    exception
      when no_data_found then l_email := null;
    end;
    if l_email is null or not regexp_like(l_email, '^[A-Za-z0-9.!#$%&''*+/=?^_`{|}~-]+@[A-Za-z0-9-]+([.][A-Za-z0-9-]+)+$') then
      add_failure('VAL-005', 'contact.email');
    end if;

    select count(*) into l_count from supplier_request_site where request_id = p_request_id;
    if l_count = 0 then
      add_failure('VAL-007', 'sites');
    else
      select count(*) into l_count
        from supplier_request_site
       where request_id = p_request_id
         and (address_line1 is null or address_line2 is null or city is null or region is null or country_code is null
              or length(address_line1) > 20 or length(address_line2) > 20);
      if l_count > 0 then add_failure('VAL-006', 'sites.address'); end if;
    end if;

    if l_request.tax_registration_number is not null then
      select count(*) into l_count
        from existing_supplier_ref
       where upper(regexp_replace(tax_registration_number, '[^[:alnum:]]', '')) =
             upper(regexp_replace(l_request.tax_registration_number, '[^[:alnum:]]', ''));
      select l_count + count(*) into l_count
        from supplier_request
       where request_id <> p_request_id
         and tax_registration_number is not null
         and upper(regexp_replace(tax_registration_number, '[^[:alnum:]]', '')) =
             upper(regexp_replace(l_request.tax_registration_number, '[^[:alnum:]]', ''));
      if l_count > 0 then add_failure('VAL-008', 'taxRegistrationNumber'); end if;
    end if;

    select count(*) into l_count
      from supplier_request_bank b
     where b.request_id = p_request_id
       and b.bank_provided_flag = 1
       and b.account_hash is not null
       and (
         exists (select 1 from existing_supplier_ref e where e.bank_account_hash = b.account_hash)
         or exists (
           select 1 from supplier_request_bank b2
            where b2.request_id <> p_request_id and b2.account_hash = b.account_hash
         )
       );
    if l_count > 0 then add_failure('VAL-009', 'bank.accountToken'); end if;
  end;

  function results_json(p_request_id number) return clob is
    l_json clob;
  begin
    select coalesce(
      json_arrayagg(
        json_object(
          'validationId' value v.validation_id,
          'ruleCode' value r.rule_code,
          'fieldName' value v.field_name,
          'severity' value v.severity,
          'message' value v.message,
          'isBlocking' value case when v.is_blocking = 1 then 'true' else 'false' end format json,
          'runId' value v.run_id,
          'createdAt' value to_char(v.created_at, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZH:TZM')
        ) returning clob
      ),
      to_clob('[]')
    ) into l_json
      from validation_result v
      join validation_rules r on r.validation_rule_id = v.validation_rule_id
     where v.request_id = p_request_id and v.is_current = 1;
    return l_json;
  end;
end erp_validation_pkg;
/
