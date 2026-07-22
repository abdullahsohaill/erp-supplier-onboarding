create or replace package body erp_review_pkg as
    function list_requests(p_status varchar2 default null, p_limit number default 25, p_offset number default 0) return clob is
        l_json clob;
        l_limit number := least(greatest(nvl(p_limit, 25), 1), 100);
        l_offset number := greatest(nvl(p_offset, 0), 0);
    begin
        erp_principal_pkg.assert_role('REVIEWER,SUPPORT_ADMIN');
        select coalesce(json_arrayagg(json_object(
            'requestId' value request_id, 'requestNumber' value request_number,
            'supplierName' value supplier_name, 'status' value status,
            'countryCode' value country_code, 'expectedAnnualSpend' value expected_annual_spend,
            'submittedAt' value to_char(submitted_at, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZH:TZM')
        ) order by submitted_at nulls last returning clob), to_clob('[]')) into l_json
        from (
            select * from supplier_request
             where (p_status is null and status in ('Under Review', 'Approved', 'Integration Failed'))
                or status = p_status
             order by submitted_at nulls last
             offset l_offset rows fetch next l_limit rows only
        );
        return erp_api_util_pkg.success(l_json);
    end;

    function request_detail(p_request_id number) return clob is
    begin
        erp_principal_pkg.assert_role('REVIEWER,SUPPORT_ADMIN');
        return erp_api_util_pkg.success(erp_request_projection_pkg.request_json(p_request_id, false));
    exception when others then return erp_api_util_pkg.failure('REQUEST_NOT_FOUND', 'Request was not found.');
    end;

    function reviewer_dashboard return clob is
        l_json clob;
    begin
        erp_principal_pkg.assert_role('REVIEWER');
        select json_object(
            'underReview' value count(case when status = 'Under Review' then 1 end),
            'approved' value count(case when status = 'Approved' then 1 end),
            'correctionRequested' value count(case when status = 'Correction Requested' then 1 end),
            'markedDuplicate' value count(case when status = 'Marked Duplicate' then 1 end)
            returning clob
        ) into l_json from supplier_request;
        return erp_api_util_pkg.success(l_json);
    end;

    procedure decide(
        p_request_id number,
        p_body clob,
        p_to_status varchar2,
        p_action varchar2,
        p_require_comment boolean,
        p_require_corrections boolean,
        p_require_supplier boolean,
        o_status out number,
        o_body out clob
    ) is
        l_payload json_object_t := erp_input_pkg.parse_object(p_body);
        l_comment varchar2(2000);
        l_actor varchar2(128) := erp_principal_pkg.subject();
        l_status varchar2(30);
        l_envelope json_object_t := json_object_t();
        l_selected json_array_t := json_array_t();
        l_corrections json_array_t := json_array_t();
        l_supplier_number varchar2(80);
        l_action_comment clob;
    begin
        erp_principal_pkg.assert_role('REVIEWER');
        erp_input_pkg.assert_allowed_keys(l_payload, 'comment,selectedRiskFactorCodes,correctionItems,existingSupplierNumber');
        l_comment := erp_input_pkg.optional_string(l_payload, 'comment', 2000);
        if p_require_comment and l_comment is null then raise_application_error(-20000, 'COMMENT_REQUIRED'); end if;
        if l_payload.has('selectedRiskFactorCodes') then
            l_selected := l_payload.get_array('selectedRiskFactorCodes');
            if l_selected.get_size() > 25 then raise_application_error(-20000, 'TOO_MANY_SELECTED_FACTORS'); end if;
        end if;
        if l_payload.has('correctionItems') then
            l_corrections := l_payload.get_array('correctionItems');
            if l_corrections.get_size() > 25 then raise_application_error(-20000, 'TOO_MANY_CORRECTION_ITEMS'); end if;
        end if;
        if p_require_corrections and l_corrections.get_size() = 0 then raise_application_error(-20000, 'CORRECTION_ITEMS_REQUIRED'); end if;
        l_supplier_number := erp_input_pkg.optional_string(l_payload, 'existingSupplierNumber', 80);
        if p_require_supplier and l_supplier_number is null then raise_application_error(-20000, 'EXISTING_SUPPLIER_REQUIRED'); end if;

        select status into l_status from supplier_request where request_id = p_request_id for update;
        if l_status <> 'Under Review' then raise_application_error(-20009, 'REVIEW_DECISION_NOT_ALLOWED'); end if;
        l_envelope.put('schemaVersion', '1.0');
        l_envelope.put('comment', l_comment);
        l_envelope.put('selectedRiskFactorCodes', l_selected);
        l_envelope.put('correctionItems', l_corrections);
        if l_supplier_number is not null then l_envelope.put('existingSupplierNumber', l_supplier_number); end if;
        l_action_comment := l_envelope.to_clob();
        insert into status_history (
            request_id, from_status, to_status, action_code, actor_user,
            action_comment, action_timestamp
        ) values (
            p_request_id, l_status, p_to_status, p_action, l_actor,
            l_action_comment, systimestamp
        );
        update supplier_request set status = p_to_status, last_updated_at = systimestamp where request_id = p_request_id;
        commit;
        o_status := 200;
        o_body := erp_api_util_pkg.success(erp_request_projection_pkg.request_json(p_request_id, false));
    exception
        when no_data_found then rollback; o_status := 404; o_body := erp_api_util_pkg.failure('REQUEST_NOT_FOUND', 'Request was not found.');
        when others then
            rollback;
            if sqlcode between -20099 and -20000 then o_status := 409; o_body := erp_api_util_pkg.failure('DECISION_REJECTED', replace(sqlerrm, 'ORA-20000: ', ''));
            else o_status := 500; o_body := erp_api_util_pkg.failure('INTERNAL_ERROR', 'Decision could not be recorded.'); end if;
    end;

    procedure approve(p_request_id number, p_body clob, o_status out number, o_body out clob) is
    begin decide(p_request_id, p_body, 'Approved', 'APPROVE', false, false, false, o_status, o_body); end;
    procedure reject(p_request_id number, p_body clob, o_status out number, o_body out clob) is
    begin decide(p_request_id, p_body, 'Rejected', 'REJECT', true, false, false, o_status, o_body); end;
    procedure request_correction(p_request_id number, p_body clob, o_status out number, o_body out clob) is
    begin decide(p_request_id, p_body, 'Correction Requested', 'REQUEST_CORRECTION', true, true, false, o_status, o_body); end;
    procedure mark_duplicate(p_request_id number, p_body clob, o_status out number, o_body out clob) is
    begin decide(p_request_id, p_body, 'Marked Duplicate', 'MARK_DUPLICATE', true, false, true, o_status, o_body); end;
end erp_review_pkg;
/
