create or replace package erp_integration_pkg authid definer as
  procedure submit_mock(p_request_id number, p_actor varchar2, p_result out clob, p_status out number);
  procedure retry_mock(p_log_id number, p_actor varchar2, p_result out clob, p_status out number);
  procedure record_result(p_request_id number, p_body clob, p_actor varchar2, p_result out clob, p_status out number);
  function logs_json return clob;
  function log_json(p_log_id number) return clob;
end erp_integration_pkg;
/

create or replace package body erp_integration_pkg as
  procedure append_history(
    p_log_id number, p_actor varchar2, p_result_code varchar2,
    p_message varchar2, p_oic_id varchar2
  ) is
    l_history_clob clob;
    l_history json_array_t;
    l_entry json_object_t := json_object_t();
    l_retry_count number;
  begin
    select json_serialize(retry_history_json returning clob), retry_count
      into l_history_clob, l_retry_count from integration_log where log_id = p_log_id for update;
    l_history := json_array_t.parse(nvl(l_history_clob, '[]'));
    l_entry.put('attemptNumber', l_history.get_size + 1);
    l_entry.put('actorUser', lower(p_actor));
    l_entry.put('attemptedAt', to_char(systimestamp, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZH:TZM'));
    l_entry.put('result', p_result_code);
    l_entry.put('message', p_message);
    l_entry.put('oicInstanceId', p_oic_id);
    l_history.append(l_entry);
    update integration_log set retry_history_json = json(l_history.to_clob),
      retry_count = l_history.get_size, last_retry_at = systimestamp, last_retry_by = lower(p_actor)
     where log_id = p_log_id;
  end;

  procedure submit_mock(p_request_id number, p_actor varchar2, p_result out clob, p_status out number) is
    l_request supplier_request%rowtype;
    l_oic_id varchar2(100) := 'MOCK-OIC-' || substr(rawtohex(sys_guid()), 1, 16);
    l_supplier_number varchar2(100);
    l_log_id number;
  begin
    erp_security_pkg.assert_system_or_admin(p_actor);
    select * into l_request from supplier_request where request_id = p_request_id for update;
    if l_request.fusion_supplier_number is not null then
      p_status := 200;
      select erp_api_pkg.success(json_object('requestId' value p_request_id,
        'status' value l_request.status, 'fusionSupplierNumber' value l_request.fusion_supplier_number returning clob))
        into p_result from dual;
      return;
    end if;
    if l_request.status <> 'Approved' then raise_application_error(-20009, 'INVALID_STATUS_TRANSITION'); end if;

    insert into status_history (request_id, from_status, to_status, action_code, actor_user, action_comment, action_timestamp)
    values (p_request_id, 'Approved', 'Submitted to Fusion', 'SUBMIT_TO_FUSION', lower(p_actor), 'Submitted to deterministic mock Fusion.', systimestamp);
    update supplier_request set status = 'Submitted to Fusion', last_updated_at = systimestamp where request_id = p_request_id;

    if upper(l_request.supplier_name) like '%FAIL%' then
      insert into integration_log (
        request_id, integration_name, oic_instance_id, direction, status, error_category,
        payload_ref, response_ref, user_message, technical_message, retry_count,
        retry_eligible_flag, retry_history_json, created_at
      ) values (
        p_request_id, 'SUPPLIER_CREATE_MOCK', l_oic_id, 'OUTBOUND', 'FAILED', 'TECHNICAL',
        'payload://request/' || p_request_id, 'response://mock/' || l_oic_id,
        'Supplier creation is temporarily unavailable.', 'Deterministic mock timeout.', 0, 1, json('[]'), systimestamp
      ) returning log_id into l_log_id;
      insert into status_history (request_id, from_status, to_status, action_code, actor_user, action_comment, action_timestamp)
      values (p_request_id, 'Submitted to Fusion', 'Integration Failed', 'INTEGRATION_FAILED', 'SYSTEM', 'Mock technical failure.', systimestamp);
      update supplier_request set status = 'Integration Failed', last_updated_at = systimestamp where request_id = p_request_id;
      commit;
      p_status := 200;
      select erp_api_pkg.success(json_object('requestId' value p_request_id, 'status' value 'Integration Failed',
        'logId' value l_log_id, 'retryEligible' value 'true' format json returning clob)) into p_result from dual;
    else
      l_supplier_number := 'SUP-' || lpad(p_request_id, 8, '0');
      insert into integration_log (
        request_id, integration_name, oic_instance_id, direction, status, error_category,
        payload_ref, response_ref, user_message, technical_message, retry_count,
        retry_eligible_flag, retry_history_json, created_at
      ) values (
        p_request_id, 'SUPPLIER_CREATE_MOCK', l_oic_id, 'OUTBOUND', 'SUCCEEDED', null,
        'payload://request/' || p_request_id, 'response://mock/' || l_oic_id,
        'Supplier created successfully.', null, 0, 0, json('[]'), systimestamp
      ) returning log_id into l_log_id;
      insert into status_history (request_id, from_status, to_status, action_code, actor_user, action_comment, action_timestamp)
      values (p_request_id, 'Submitted to Fusion', 'Created in Fusion', 'FUSION_CREATED', 'SYSTEM', 'Mock supplier ' || l_supplier_number || ' created.', systimestamp);
      update supplier_request set status = 'Created in Fusion', fusion_supplier_id = 'MOCK-' || p_request_id,
        fusion_supplier_number = l_supplier_number, fusion_created_at = systimestamp,
        fusion_response_ref = 'response://mock/' || l_oic_id, last_updated_at = systimestamp
       where request_id = p_request_id;
      commit;
      p_status := 200;
      select erp_api_pkg.success(json_object('requestId' value p_request_id, 'status' value 'Created in Fusion',
        'fusionSupplierNumber' value l_supplier_number, 'logId' value l_log_id returning clob)) into p_result from dual;
    end if;
  exception
    when no_data_found then rollback; p_status := 404; p_result := erp_api_pkg.error('INTEGRATION','REQUEST_NOT_FOUND','Request not found.');
    when others then rollback; p_status := case when sqlcode = -20009 then 409 else 500 end;
      p_result := erp_api_pkg.error('INTEGRATION', case when p_status = 409 then 'INVALID_STATUS_TRANSITION' else 'SUBMIT_TO_FUSION_FAILED' end,
        case when p_status = 409 then 'Only an Approved request can be submitted.' else 'Supplier submission could not be started.' end);
  end;

  procedure retry_mock(p_log_id number, p_actor varchar2, p_result out clob, p_status out number) is
    l_request_id number;
    l_status varchar2(40);
    l_retry_eligible number;
    l_fusion_number varchar2(100);
    l_oic_id varchar2(100) := 'MOCK-RETRY-' || substr(rawtohex(sys_guid()), 1, 16);
  begin
    erp_security_pkg.assert_admin(p_actor);
    select l.request_id, r.status, l.retry_eligible_flag, r.fusion_supplier_number
      into l_request_id, l_status, l_retry_eligible, l_fusion_number
      from integration_log l join supplier_request r on r.request_id = l.request_id
     where l.log_id = p_log_id for update;
    if l_retry_eligible <> 1 or l_status in ('Rejected','Marked Duplicate') or l_fusion_number is not null then
      raise_application_error(-20047, 'RETRY_NOT_ELIGIBLE');
    end if;

    append_history(p_log_id, p_actor, 'SUCCEEDED', 'Deterministic mock retry succeeded.', l_oic_id);
    update integration_log set status = 'SUCCEEDED', error_category = null,
      response_ref = 'response://mock/' || l_oic_id, user_message = 'Supplier created successfully after retry.',
      technical_message = null, retry_eligible_flag = 0 where log_id = p_log_id;
    update supplier_request set status = 'Created in Fusion', fusion_supplier_id = 'MOCK-' || l_request_id,
      fusion_supplier_number = 'SUP-' || lpad(l_request_id, 8, '0'), fusion_created_at = systimestamp,
      fusion_response_ref = 'response://mock/' || l_oic_id, last_updated_at = systimestamp
     where request_id = l_request_id;
    insert into status_history (request_id, from_status, to_status, action_code, actor_user, action_comment, action_timestamp)
    values (l_request_id, l_status, 'Created in Fusion', 'INTEGRATION_RETRY_SUCCEEDED', lower(p_actor), 'Mock retry succeeded.', systimestamp);
    commit;
    p_status := 200;
    p_result := erp_api_pkg.success(log_json(p_log_id));
  exception
    when no_data_found then rollback; p_status := 404; p_result := erp_api_pkg.error('INTEGRATION','LOG_NOT_FOUND','Integration log not found.');
    when others then rollback; p_status := case when sqlcode = -20047 then 409 else 500 end;
      p_result := erp_api_pkg.error('INTEGRATION', case when p_status = 409 then 'RETRY_NOT_ELIGIBLE' else 'RETRY_FAILED' end,
        case when p_status = 409 then 'This integration failure is not eligible for retry.' else 'Retry could not be completed.' end);
  end;

  procedure record_result(p_request_id number, p_body clob, p_actor varchar2, p_result out clob, p_status out number) is
    l_obj json_object_t := json_object_t.parse(p_body);
    l_outcome varchar2(40) := l_obj.get_string('status');
    l_supplier_number varchar2(100);
    l_oic_id varchar2(100);
    l_log_id number;
  begin
    erp_security_pkg.assert_system_or_admin(p_actor);
    l_supplier_number := case when l_obj.has('fusionSupplierNumber') then l_obj.get_string('fusionSupplierNumber') end;
    l_oic_id := case when l_obj.has('oicInstanceId') then l_obj.get_string('oicInstanceId') else 'CALLBACK-' || substr(rawtohex(sys_guid()),1,12) end;
    if l_outcome not in ('SUCCEEDED','FAILED') then raise_application_error(-20048,'INVALID_INTEGRATION_RESULT'); end if;
    insert into integration_log (request_id, integration_name, oic_instance_id, direction, status,
      error_category, payload_ref, response_ref, user_message, technical_message,
      retry_count, retry_eligible_flag, retry_history_json, created_at)
    values (p_request_id, 'SUPPLIER_CREATE_CALLBACK', l_oic_id, 'INBOUND', l_outcome,
      case when l_outcome = 'FAILED' then 'TECHNICAL' end, null,
      case when l_obj.has('responseRef') then l_obj.get_string('responseRef') end,
      case when l_outcome = 'SUCCEEDED' then 'Supplier created successfully.' else 'Supplier creation failed.' end,
      null, 0, case when l_outcome = 'FAILED' then 1 else 0 end, json('[]'), systimestamp)
    returning log_id into l_log_id;
    update supplier_request set status = case when l_outcome = 'SUCCEEDED' then 'Created in Fusion' else 'Integration Failed' end,
      fusion_supplier_number = case when l_outcome = 'SUCCEEDED' then l_supplier_number else fusion_supplier_number end,
      fusion_created_at = case when l_outcome = 'SUCCEEDED' then systimestamp else fusion_created_at end,
      last_updated_at = systimestamp where request_id = p_request_id;
    commit; p_status := 200;
    select erp_api_pkg.success(json_object('logId' value l_log_id returning clob)) into p_result from dual;
  exception when others then rollback; p_status := 400;
    p_result := erp_api_pkg.error('INTEGRATION','INVALID_INTEGRATION_RESULT','The integration result payload is invalid.');
  end;

  function logs_json return clob is l_json clob;
  begin
    select coalesce(json_arrayagg(json_object(
      'logId' value log_id, 'requestId' value request_id, 'integrationName' value integration_name,
      'oicInstanceId' value oic_instance_id, 'status' value status, 'errorCategory' value error_category,
      'retryCount' value retry_count, 'retryEligible' value case when retry_eligible_flag=1 then 'true' else 'false' end format json,
      'createdAt' value to_char(created_at,'YYYY-MM-DD"T"HH24:MI:SS.FF3TZH:TZM')
    ) order by created_at desc returning clob),to_clob('[]')) into l_json from integration_log;
    return l_json;
  end;

  function log_json(p_log_id number) return clob is l_json clob;
  begin
    select json_object(
      'logId' value log_id, 'requestId' value request_id, 'integrationName' value integration_name,
      'oicInstanceId' value oic_instance_id, 'direction' value direction, 'status' value status,
      'errorCategory' value error_category, 'payloadRef' value payload_ref, 'responseRef' value response_ref,
      'userMessage' value user_message, 'technicalMessage' value technical_message,
      'retryCount' value retry_count, 'retryEligible' value case when retry_eligible_flag=1 then 'true' else 'false' end format json,
      'lastRetryAt' value to_char(last_retry_at,'YYYY-MM-DD"T"HH24:MI:SS.FF3TZH:TZM'),
      'lastRetryBy' value last_retry_by, 'retryHistory' value retry_history_json,
      'createdAt' value to_char(created_at,'YYYY-MM-DD"T"HH24:MI:SS.FF3TZH:TZM') returning clob
    ) into l_json from integration_log where log_id = p_log_id;
    return l_json;
  exception when no_data_found then return 'null'; end;
end erp_integration_pkg;
/
