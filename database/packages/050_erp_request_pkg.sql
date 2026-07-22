create or replace package erp_request_pkg authid definer as
  function get_string(p_obj json_object_t, p_key varchar2) return varchar2;
  function get_number(p_obj json_object_t, p_key varchar2) return number;
  function get_flag(p_obj json_object_t, p_key varchar2, p_default number default 0) return number;
  procedure create_request(p_body clob, p_actor varchar2, p_result out clob, p_status out number);
  procedure update_request(p_request_id number, p_body clob, p_actor varchar2, p_result out clob, p_status out number);
  procedure submit_request(p_request_id number, p_actor varchar2, p_result out clob, p_status out number);
  procedure upsert_attachment(p_request_id number, p_body clob, p_actor varchar2, p_result out clob, p_status out number);
  function request_json(p_request_id number, p_actor varchar2) return clob;
  function requests_json(p_actor varchar2) return clob;
  function attachments_json(p_request_id number, p_actor varchar2) return clob;
end erp_request_pkg;
/

create or replace package body erp_request_pkg as
  function get_string(p_obj json_object_t, p_key varchar2) return varchar2 is
  begin
    if p_obj is null or not p_obj.has(p_key) or p_obj.get(p_key).is_null then return null; end if;
    return p_obj.get_string(p_key);
  exception when others then return null;
  end;

  function get_number(p_obj json_object_t, p_key varchar2) return number is
  begin
    if p_obj is null or not p_obj.has(p_key) or p_obj.get(p_key).is_null then return null; end if;
    return p_obj.get_number(p_key);
  exception when others then return null;
  end;

  function get_flag(p_obj json_object_t, p_key varchar2, p_default number default 0) return number is
  begin
    if p_obj is null or not p_obj.has(p_key) or p_obj.get(p_key).is_null then return p_default; end if;
    return case when p_obj.get_boolean(p_key) then 1 else 0 end;
  exception when others then return p_default;
  end;

  function resolve_bu(p_code varchar2) return number is
    l_id number;
  begin
    if p_code is null then return null; end if;
    select business_unit_id into l_id from ref_business_unit
     where business_unit_code = p_code and active_flag = 1;
    return l_id;
  exception when no_data_found then return null;
  end;

  procedure replace_contact(p_request_id number, p_obj json_object_t) is
    l_email varchar2(320);
    l_domain varchar2(255);
  begin
    delete from supplier_request_contact where request_id = p_request_id;
    if p_obj is null then return; end if;
    l_email := get_string(p_obj, 'email');
    if instr(l_email, '@') > 0 then l_domain := lower(substr(l_email, instr(l_email, '@') + 1)); end if;
    insert into supplier_request_contact (request_id, contact_name, contact_email, phone_number, email_domain)
    values (p_request_id, get_string(p_obj, 'name'), l_email, get_string(p_obj, 'phone'), l_domain);
  end;

  procedure add_site(p_request_id number, p_obj json_object_t, p_primary number) is
    l_bu number;
  begin
    l_bu := resolve_bu(get_string(p_obj, 'businessUnitCode'));
    if l_bu is null then
      select business_unit_id into l_bu from supplier_request where request_id = p_request_id;
    end if;
    insert into supplier_request_site (
      request_id, site_name, country_code, address_line1, address_line2,
      city, region, postal_code, intended_business_unit_id, is_primary
    ) values (
      p_request_id, get_string(p_obj, 'siteName'), get_string(p_obj, 'countryCode'),
      get_string(p_obj, 'addressLine1'), get_string(p_obj, 'addressLine2'),
      get_string(p_obj, 'city'), get_string(p_obj, 'region'), get_string(p_obj, 'postalCode'),
      l_bu, p_primary
    );
  end;

  procedure replace_sites(p_request_id number, p_root json_object_t) is
    l_array json_array_t;
    l_obj json_object_t;
  begin
    delete from supplier_request_site where request_id = p_request_id;
    if p_root.has('sites') and not p_root.get('sites').is_null then
      l_array := p_root.get_array('sites');
      for i in 0 .. l_array.get_size - 1 loop
        l_obj := treat(l_array.get(i) as json_object_t);
        add_site(p_request_id, l_obj, case when i = 0 then 1 else get_flag(l_obj, 'isPrimary', 0) end);
      end loop;
    elsif p_root.has('site') and not p_root.get('site').is_null then
      add_site(p_request_id, p_root.get_object('site'), 1);
    end if;
  end;

  procedure replace_bank(p_request_id number, p_obj json_object_t) is
    l_last4 varchar2(4);
  begin
    delete from supplier_request_bank where request_id = p_request_id;
    if p_obj is null then return; end if;
    if p_obj.has('accountNumber') then raise_application_error(-20040, 'FULL_BANK_ACCOUNT_NOT_ALLOWED'); end if;
    l_last4 := get_string(p_obj, 'accountLast4');
    insert into supplier_request_bank (
      request_id, bank_country_code, masked_account_display,
      account_last4, account_hash, bank_provided_flag
    ) values (
      p_request_id, get_string(p_obj, 'bankCountryCode'),
      case when l_last4 is not null then '****' || l_last4 else null end,
      l_last4, get_string(p_obj, 'accountToken'), 1
    );
  end;

  procedure replace_documents(p_request_id number, p_array json_array_t) is
    l_obj json_object_t;
    l_meta json_element_t;
  begin
    delete from supplier_request_document where request_id = p_request_id;
    if p_array is null then return; end if;
    for i in 0 .. p_array.get_size - 1 loop
      l_obj := treat(p_array.get(i) as json_object_t);
      l_meta := case when l_obj.has('metadata') then l_obj.get('metadata') else json_object_t() end;
      insert into supplier_request_document (
        request_id, document_type, document_status, is_required, metadata_json, missing_flag
      ) values (
        p_request_id, get_string(l_obj, 'documentType'), get_string(l_obj, 'documentStatus'),
        get_flag(l_obj, 'isRequired', 0), json(l_meta.to_clob), get_flag(l_obj, 'missing', 0)
      );
    end loop;
  end;

  procedure create_request(p_body clob, p_actor varchar2, p_result out clob, p_status out number) is
    l_root json_object_t;
    l_request_id number;
    l_request_number varchar2(40);
    l_bu number;
  begin
    l_root := json_object_t.parse(p_body);
    l_bu := resolve_bu(get_string(l_root, 'businessUnitCode'));
    l_request_number := 'REQ-' || to_char(systimestamp, 'YYYYMMDDHH24MISSFF3') || '-' || substr(rawtohex(sys_guid()), 1, 4);

    insert into supplier_request (
      request_number, status, supplier_name, supplier_type_code, country_code,
      business_unit_id, requester_user, business_justification,
      product_service_category, expected_annual_spend, tax_registration_number,
      created_at, last_updated_at
    ) values (
      l_request_number, 'Draft', get_string(l_root, 'supplierName'), get_string(l_root, 'supplierType'),
      get_string(l_root, 'countryCode'), l_bu, lower(p_actor), get_string(l_root, 'businessJustification'),
      get_string(l_root, 'productServiceCategory'), get_number(l_root, 'expectedAnnualSpend'),
      get_string(l_root, 'taxRegistrationNumber'), systimestamp, systimestamp
    ) returning request_id into l_request_id;

    if l_root.has('contact') then replace_contact(l_request_id, l_root.get_object('contact')); end if;
    if l_root.has('site') or l_root.has('sites') then replace_sites(l_request_id, l_root); end if;
    if l_root.has('bank') then replace_bank(l_request_id, l_root.get_object('bank')); end if;
    if l_root.has('documents') then replace_documents(l_request_id, l_root.get_array('documents')); end if;

    insert into status_history (request_id, from_status, to_status, action_code, actor_user, action_comment, action_timestamp)
    values (l_request_id, null, 'Draft', 'CREATE_DRAFT', lower(p_actor), 'Draft created.', systimestamp);
    commit;
    p_status := 201;
    select erp_api_pkg.success(json_object(
      'requestId' value l_request_id, 'requestNumber' value l_request_number, 'status' value 'Draft'
      returning clob)) into p_result from dual;
  exception
    when others then
      rollback;
      p_status := case when sqlcode in (-20040, -40441, -40587) then 400 else 500 end;
      p_result := erp_api_pkg.error('REQUEST', case when p_status = 400 then 'INVALID_REQUEST_PAYLOAD' else 'REQUEST_CREATE_FAILED' end,
        case when p_status = 400 then 'The request payload is invalid.' else 'The request could not be created.' end);
  end;

  procedure update_request(p_request_id number, p_body clob, p_actor varchar2, p_result out clob, p_status out number) is
    l_root json_object_t;
    l_bu number;
  begin
    erp_security_pkg.assert_editable_owner(p_request_id, p_actor);
    l_root := json_object_t.parse(p_body);
    if l_root.has('status') or l_root.has('requesterUser') or l_root.has('fusionSupplierNumber') then
      raise_application_error(-20041, 'SERVER_FIELD_NOT_WRITABLE');
    end if;
    if l_root.has('businessUnitCode') then l_bu := resolve_bu(get_string(l_root, 'businessUnitCode')); end if;
    update supplier_request set
      supplier_name = case when l_root.has('supplierName') then get_string(l_root, 'supplierName') else supplier_name end,
      supplier_type_code = case when l_root.has('supplierType') then get_string(l_root, 'supplierType') else supplier_type_code end,
      country_code = case when l_root.has('countryCode') then get_string(l_root, 'countryCode') else country_code end,
      business_unit_id = case when l_root.has('businessUnitCode') then l_bu else business_unit_id end,
      business_justification = case when l_root.has('businessJustification') then to_clob(get_string(l_root, 'businessJustification')) else business_justification end,
      product_service_category = case when l_root.has('productServiceCategory') then get_string(l_root, 'productServiceCategory') else product_service_category end,
      expected_annual_spend = case when l_root.has('expectedAnnualSpend') then get_number(l_root, 'expectedAnnualSpend') else expected_annual_spend end,
      tax_registration_number = case when l_root.has('taxRegistrationNumber') then get_string(l_root, 'taxRegistrationNumber') else tax_registration_number end,
      last_updated_at = systimestamp
    where request_id = p_request_id;

    if l_root.has('contact') then replace_contact(p_request_id, l_root.get_object('contact')); end if;
    if l_root.has('site') or l_root.has('sites') then replace_sites(p_request_id, l_root); end if;
    if l_root.has('bank') then replace_bank(p_request_id, l_root.get_object('bank')); end if;
    if l_root.has('documents') then replace_documents(p_request_id, l_root.get_array('documents')); end if;
    commit;
    p_status := 200;
    p_result := erp_api_pkg.success(request_json(p_request_id, p_actor));
  exception
    when others then
      rollback;
      p_status := case when sqlcode = -20004 then 404 when sqlcode = -20009 then 409
                       when sqlcode in (-20040, -20041, -40441, -40587) then 400 else 500 end;
      p_result := erp_api_pkg.error('REQUEST', case p_status when 404 then 'REQUEST_NOT_FOUND' when 409 then 'INVALID_STATUS_TRANSITION'
        when 400 then 'INVALID_REQUEST_PAYLOAD' else 'REQUEST_UPDATE_FAILED' end,
        case p_status when 404 then 'Request not found.' when 409 then 'The request is not editable in its current status.'
        when 400 then 'The request payload is invalid.' else 'The request could not be updated.' end);
  end;

  procedure submit_request(p_request_id number, p_actor varchar2, p_result out clob, p_status out number) is
    l_from_status varchar2(40);
    l_run_id varchar2(64) := lower(rawtohex(sys_guid()));
    l_blocked number;
  begin
    erp_security_pkg.assert_editable_owner(p_request_id, p_actor);
    select status into l_from_status from supplier_request where request_id = p_request_id;
    erp_validation_pkg.run(p_request_id, l_run_id, l_blocked);
    erp_duplicate_pkg.run(p_request_id, l_run_id);
    erp_risk_pkg.run(p_request_id, l_run_id);
    if l_blocked = 1 then
      commit;
      p_status := 422;
      select json_object(
        'success' value 'false' format json,
        'status' value l_from_status,
        'submitted' value 'false' format json,
        'findings' value erp_validation_pkg.results_json(p_request_id) format json,
        'traceId' value lower(rawtohex(sys_guid())) returning clob) into p_result from dual;
      return;
    end if;

    insert into status_history (request_id, from_status, to_status, action_code, actor_user, action_comment, action_timestamp)
    values (p_request_id, l_from_status, 'Submitted', case when l_from_status = 'Draft' then 'SUBMIT' else 'RESUBMIT' end,
            lower(p_actor), 'Request passed blocking checks.', systimestamp);
    insert into status_history (request_id, from_status, to_status, action_code, actor_user, action_comment, action_timestamp)
    values (p_request_id, 'Submitted', 'Under Review', 'ENTER_REVIEW', 'SYSTEM', 'Request entered the Reviewer queue.', systimestamp);
    update supplier_request set status = 'Under Review', submitted_at = nvl(submitted_at, systimestamp), last_updated_at = systimestamp
     where request_id = p_request_id;
    commit;
    p_status := 200;
    select erp_api_pkg.success(json_object('requestId' value p_request_id, 'status' value 'Under Review',
      'submitted' value 'true' format json returning clob)) into p_result from dual;
  exception
    when others then
      rollback;
      p_status := case when sqlcode = -20004 then 404 when sqlcode = -20009 then 409 else 500 end;
      p_result := erp_api_pkg.error('REQUEST', case p_status when 404 then 'REQUEST_NOT_FOUND' when 409 then 'INVALID_STATUS_TRANSITION'
        else 'SUBMISSION_FAILED' end, case p_status when 404 then 'Request not found.' when 409 then 'The request cannot be submitted in its current status.'
        else 'Submission could not be completed.' end);
  end;

  function request_json(p_request_id number, p_actor varchar2) return clob is
    l_root clob;
    l_timeline clob;
    l_sites clob;
    l_contacts clob;
    l_documents clob;
    l_obj json_object_t;
  begin
    if erp_security_pkg.is_privileged_actor(p_actor) = 0 then
      erp_security_pkg.assert_request_owner(p_request_id, p_actor);
    end if;
    select json_object(
      'requestId' value request_id, 'requestNumber' value request_number, 'status' value status,
      'supplierName' value supplier_name, 'supplierType' value supplier_type_code, 'countryCode' value country_code,
      'businessUnitId' value business_unit_id, 'businessJustification' value business_justification,
      'productServiceCategory' value product_service_category, 'expectedAnnualSpend' value expected_annual_spend,
      'taxRegistrationNumber' value tax_registration_number,
      'fusionSupplierNumber' value fusion_supplier_number,
      'createdAt' value to_char(created_at, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZH:TZM'),
      'submittedAt' value to_char(submitted_at, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZH:TZM'),
      'lastUpdatedAt' value to_char(last_updated_at, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZH:TZM') returning clob
    ) into l_root from supplier_request where request_id = p_request_id;

    select coalesce(json_arrayagg(json_object(
      'fromStatus' value from_status, 'toStatus' value to_status, 'actionCode' value action_code,
      'actor' value actor_user,
      'comment' value case when action_comment is json then to_clob(json_value(action_comment, '$.comment')) else action_comment end,
      'existingSupplierNumber' value case when action_comment is json then json_value(action_comment, '$.existingSupplierNumber') end,
      'timestamp' value to_char(action_timestamp, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZH:TZM')
    ) order by action_timestamp returning clob), to_clob('[]')) into l_timeline from status_history where request_id = p_request_id;

    select coalesce(json_arrayagg(json_object(
      'siteId' value site_id, 'siteName' value site_name, 'countryCode' value country_code,
      'addressLine1' value address_line1, 'addressLine2' value address_line2, 'city' value city,
      'region' value region, 'postalCode' value postal_code, 'isPrimary' value case when is_primary = 1 then 'true' else 'false' end format json
    ) returning clob), to_clob('[]')) into l_sites from supplier_request_site where request_id = p_request_id;

    select coalesce(json_arrayagg(json_object(
      'contactId' value contact_id, 'name' value contact_name, 'email' value contact_email, 'phone' value phone_number
    ) returning clob), to_clob('[]')) into l_contacts from supplier_request_contact where request_id = p_request_id;

    l_documents := attachments_json(p_request_id, p_actor);
    l_obj := json_object_t.parse(l_root);
    l_obj.put('timeline', json_array_t.parse(l_timeline));
    l_obj.put('sites', json_array_t.parse(l_sites));
    l_obj.put('contacts', json_array_t.parse(l_contacts));
    l_obj.put('documents', json_array_t.parse(l_documents));
    return l_obj.to_clob;
  end;

  function requests_json(p_actor varchar2) return clob is
    l_json clob;
  begin
    select coalesce(json_arrayagg(json_object(
      'requestId' value request_id, 'requestNumber' value request_number,
      'supplierName' value supplier_name, 'status' value status,
      'fusionSupplierNumber' value fusion_supplier_number,
      'createdAt' value to_char(created_at, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZH:TZM'),
      'lastUpdatedAt' value to_char(last_updated_at, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZH:TZM')
    ) order by last_updated_at desc returning clob), to_clob('[]')) into l_json
      from supplier_request
     where erp_security_pkg.is_privileged_actor(p_actor) = 1 or lower(requester_user) = lower(p_actor);
    return l_json;
  end;

  function attachments_json(p_request_id number, p_actor varchar2) return clob is
    l_json clob;
  begin
    if erp_security_pkg.is_privileged_actor(p_actor) = 0 then erp_security_pkg.assert_request_owner(p_request_id, p_actor); end if;
    select coalesce(json_arrayagg(json_object(
      'documentId' value document_id, 'documentType' value document_type,
      'documentStatus' value document_status,
      'isRequired' value case when is_required = 1 then 'true' else 'false' end format json,
      'metadata' value metadata_json,
      'missing' value case when missing_flag = 1 then 'true' else 'false' end format json
    ) returning clob), to_clob('[]')) into l_json from supplier_request_document where request_id = p_request_id;
    return l_json;
  end;

  procedure upsert_attachment(p_request_id number, p_body clob, p_actor varchar2, p_result out clob, p_status out number) is
    l_obj json_object_t := json_object_t.parse(p_body);
    l_meta json_element_t;
    l_id number;
  begin
    erp_security_pkg.assert_editable_owner(p_request_id, p_actor);
    if l_obj.has('metadata') then
      l_meta := l_obj.get('metadata');
    else
      l_meta := json_object_t();
    end if;
    insert into supplier_request_document (request_id, document_type, document_status, is_required, metadata_json, missing_flag)
    values (p_request_id, get_string(l_obj, 'documentType'), get_string(l_obj, 'documentStatus'),
      get_flag(l_obj, 'isRequired', 0), json(l_meta.to_clob), get_flag(l_obj, 'missing', 0))
    returning document_id into l_id;
    commit;
    p_status := 200;
    select erp_api_pkg.success(json_object('documentId' value l_id returning clob)) into p_result from dual;
  exception when others then
    rollback; p_status := case when sqlcode = -20004 then 404 when sqlcode = -20009 then 409 else 400 end;
    p_result := erp_api_pkg.error('REQUEST', 'ATTACHMENT_METADATA_REJECTED', 'Document metadata could not be saved.');
  end;
end erp_request_pkg;
/
