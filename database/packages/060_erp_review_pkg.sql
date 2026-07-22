create or replace package erp_review_pkg authid definer as
  procedure decide(
    p_request_id number,
    p_action     varchar2,
    p_body       clob,
    p_actor      varchar2,
    p_result     out clob,
    p_status     out number
  );
end erp_review_pkg;
/

create or replace package body erp_review_pkg as
  procedure decide(
    p_request_id number,
    p_action     varchar2,
    p_body       clob,
    p_actor      varchar2,
    p_result     out clob,
    p_status     out number
  ) is
    l_body json_object_t := json_object_t.parse(nvl(p_body, '{}'));
    l_status varchar2(40);
    l_target varchar2(40);
    l_comment varchar2(4000);
    l_existing varchar2(100);
    l_blockers number;
    l_envelope json_object_t := json_object_t();
    l_factors json_array_t := json_array_t();
    l_items json_array_t := json_array_t();
    l_allowed_factors constant varchar2(1000) :=
      ':MISSING_TAX:HIGH_RISK_COUNTRY:BANK_COUNTRY_MISMATCH:INCOMPLETE_ADDRESS:INCOMPLETE_BANK_DETAILS:VAGUE_JUSTIFICATION:HIGH_SPEND_WEAK_JUSTIFICATION:MISSING_DOCUMENT_METADATA:DUPLICATE_SCORE_HIGH:DUPLICATE_SCORE_MEDIUM:';
  begin
    erp_security_pkg.assert_reviewer(p_actor);
    select status into l_status from supplier_request where request_id = p_request_id for update;
    if l_status <> 'Under Review' then raise_application_error(-20009, 'INVALID_STATUS_TRANSITION'); end if;

    l_comment := case when l_body.has('comment') then l_body.get_string('comment') end;
    l_existing := case when l_body.has('existingSupplierNumber') then l_body.get_string('existingSupplierNumber') end;
    l_target := case upper(p_action)
      when 'APPROVE' then 'Approved'
      when 'REJECT' then 'Rejected'
      when 'REQUEST_CORRECTION' then 'Correction Requested'
      when 'MARK_DUPLICATE' then 'Marked Duplicate'
      else null end;
    if l_target is null then raise_application_error(-20042, 'INVALID_DECISION'); end if;

    if upper(p_action) = 'APPROVE' then
      select count(*) into l_blockers from validation_result
       where request_id = p_request_id and is_current = 1 and is_blocking = 1;
      if l_blockers > 0 then raise_application_error(-20043, 'BLOCKING_VALIDATION_REMAINS'); end if;
    elsif l_comment is null then
      raise_application_error(-20044, 'COMMENT_REQUIRED');
    end if;
    if upper(p_action) = 'MARK_DUPLICATE' and l_existing is null then
      raise_application_error(-20045, 'EXISTING_SUPPLIER_REQUIRED');
    end if;

    if l_body.has('selectedRiskFactorCodes') then
      l_factors := l_body.get_array('selectedRiskFactorCodes');
      for i in 0 .. l_factors.get_size - 1 loop
        if instr(l_allowed_factors, ':' || l_factors.get_string(i) || ':') = 0 then
          raise_application_error(-20046, 'INVALID_RISK_FACTOR');
        end if;
      end loop;
    end if;
    if l_body.has('correctionItems') then l_items := l_body.get_array('correctionItems'); end if;

    l_envelope.put('schemaVersion', 1);
    l_envelope.put('comment', l_comment);
    l_envelope.put('selectedRiskFactorCodes', l_factors);
    l_envelope.put('correctionItems', l_items);
    if l_existing is not null then l_envelope.put('existingSupplierNumber', l_existing); end if;

    insert into status_history (
      request_id, from_status, to_status, action_code, actor_user, action_comment, action_timestamp
    ) values (
      p_request_id, l_status, l_target, upper(p_action), lower(p_actor), l_envelope.to_clob, systimestamp
    );
    update supplier_request set status = l_target, last_updated_at = systimestamp where request_id = p_request_id;
    commit;
    p_status := 200;
    select erp_api_pkg.success(json_object('requestId' value p_request_id, 'status' value l_target returning clob))
      into p_result from dual;
  exception
    when no_data_found then
      rollback; p_status := 404;
      p_result := erp_api_pkg.error('REVIEW', 'REQUEST_NOT_FOUND', 'Request not found.');
    when others then
      rollback;
      p_status := case when sqlcode = -20009 then 409 when sqlcode between -20046 and -20042 then 400 else 500 end;
      p_result := erp_api_pkg.error('REVIEW', case
        when sqlcode = -20009 then 'INVALID_STATUS_TRANSITION'
        when sqlcode = -20043 then 'BLOCKING_VALIDATION_REMAINS'
        when sqlcode = -20044 then 'COMMENT_REQUIRED'
        when sqlcode = -20045 then 'EXISTING_SUPPLIER_REQUIRED'
        when sqlcode = -20046 then 'INVALID_RISK_FACTOR'
        else 'DECISION_FAILED' end,
        case when p_status in (400,409) then 'The review decision is not valid for this request.' else 'The decision could not be recorded.' end);
  end;
end erp_review_pkg;
/
