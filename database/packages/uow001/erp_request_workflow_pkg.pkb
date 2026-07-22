create or replace package body erp_request_workflow_pkg as
    function safe_error(p_trace varchar2) return clob is
        l_message varchar2(4000) := sqlerrm;
    begin
        if instr(l_message, 'AUTHENTICATION_REQUIRED') > 0 then
            return erp_api_util_pkg.failure('AUTHENTICATION_REQUIRED', 'Authentication is required.', p_trace);
        elsif instr(l_message, 'ROLE_FORBIDDEN') > 0 then
            return erp_api_util_pkg.failure('FORBIDDEN', 'The authenticated role cannot perform this action.', p_trace);
        elsif instr(l_message, 'REQUEST_NOT_FOUND') > 0 then
            return erp_api_util_pkg.failure('REQUEST_NOT_FOUND', 'Request was not found.', p_trace);
        elsif instr(l_message, 'REQUEST_NOT_EDITABLE') > 0 then
            return erp_api_util_pkg.failure('REQUEST_NOT_EDITABLE', 'Request is not editable in its current status.', p_trace);
        elsif sqlcode between -20099 and -20000 then
            return erp_api_util_pkg.failure('INVALID_REQUEST', replace(substr(l_message, instr(l_message, ':') + 1), '_', ' '), p_trace);
        else
            return erp_api_util_pkg.failure('INTERNAL_ERROR', 'The request could not be completed.', p_trace);
        end if;
    end;

    function safe_status return number is
        l_message varchar2(4000) := sqlerrm;
    begin
        if instr(l_message, 'AUTHENTICATION_REQUIRED') > 0 then return 401;
        elsif instr(l_message, 'ROLE_FORBIDDEN') > 0 then return 403;
        elsif instr(l_message, 'REQUEST_NOT_FOUND') > 0 then return 404;
        elsif instr(l_message, 'REQUEST_NOT_EDITABLE') > 0 then return 409;
        elsif sqlcode between -20099 and -20000 then return 400;
        else return 500;
        end if;
    end;

    function business_unit_id(p_payload json_object_t) return number is
        l_id number;
        l_code varchar2(30);
    begin
        if p_payload.has('businessUnitId') and not p_payload.get('businessUnitId').is_null then
            return p_payload.get_number('businessUnitId');
        end if;
        l_code := upper(erp_input_pkg.optional_string(p_payload, 'businessUnitCode', 30));
        if l_code is null then return null; end if;
        select business_unit_id into l_id from ref_business_unit
         where business_unit_code = l_code and active_flag = 1;
        return l_id;
    exception when no_data_found then
        raise_application_error(-20000, 'INVALID_BUSINESS_UNIT');
    end;

    procedure create_request(p_body clob, o_status out number, o_body out clob) is
        l_trace varchar2(64) := erp_api_util_pkg.trace_id();
        l_payload json_object_t;
        l_request_id number;
        l_owner varchar2(128);
        l_business_unit_id number;
        l_supplier_name varchar2(200);
        l_supplier_type_code varchar2(30);
        l_country_code varchar2(2);
        l_business_justification varchar2(4000);
        l_product_service_category varchar2(120);
        l_expected_annual_spend number;
        l_tax_registration_number varchar2(80);
    begin
        erp_principal_pkg.assert_role('REQUESTER');
        l_owner := erp_principal_pkg.subject();
        erp_input_pkg.assert_no_raw_bank(p_body);
        l_payload := erp_input_pkg.parse_object(p_body);
        erp_input_pkg.assert_allowed_keys(
            l_payload,
            'supplierName,supplierTypeCode,countryCode,businessUnitId,businessUnitCode,businessJustification,productServiceCategory,expectedAnnualSpend,taxRegistrationNumber,sites,contacts,bank,documents'
        );
        l_business_unit_id := business_unit_id(l_payload);
        l_supplier_name := erp_input_pkg.optional_string(l_payload, 'supplierName', 200);
        l_supplier_type_code := upper(erp_input_pkg.optional_string(l_payload, 'supplierTypeCode', 30));
        l_country_code := upper(erp_input_pkg.optional_string(l_payload, 'countryCode', 2));
        l_business_justification := erp_input_pkg.optional_string(l_payload, 'businessJustification', 4000);
        l_product_service_category := erp_input_pkg.optional_string(l_payload, 'productServiceCategory', 120);
        if l_payload.has('expectedAnnualSpend') and not l_payload.get('expectedAnnualSpend').is_null then
            l_expected_annual_spend := l_payload.get_number('expectedAnnualSpend');
        end if;
        l_tax_registration_number := erp_input_pkg.optional_string(l_payload, 'taxRegistrationNumber', 80);
        insert into supplier_request (
            request_number, status, supplier_name, supplier_type_code,
            country_code, business_unit_id, requester_user, business_justification,
            product_service_category, expected_annual_spend,
            tax_registration_number, created_at, last_updated_at
        ) values (
            'PENDING', 'Draft',
            l_supplier_name,
            l_supplier_type_code,
            l_country_code,
            l_business_unit_id, l_owner,
            l_business_justification,
            l_product_service_category,
            l_expected_annual_spend,
            l_tax_registration_number,
            systimestamp, systimestamp
        ) returning request_id into l_request_id;
        update supplier_request
           set request_number = 'REQ-' || to_char(sysdate, 'YYYY') || '-' || lpad(l_request_id, 6, '0')
         where request_id = l_request_id;
        erp_request_repo_pkg.replace_children(l_request_id, l_payload);
        insert into status_history (
            request_id, from_status, to_status, action_code,
            actor_user, action_comment, action_timestamp
        ) values (l_request_id, null, 'Draft', 'CREATE_DRAFT', l_owner, 'Draft created.', systimestamp);
        commit;
        o_status := 201;
        o_body := erp_api_util_pkg.success(erp_request_projection_pkg.request_json(l_request_id, true), l_trace);
    exception when others then
        rollback;
        o_status := safe_status();
        o_body := safe_error(l_trace);
    end;

    procedure update_request(p_request_id number, p_body clob, o_status out number, o_body out clob) is
        l_trace varchar2(64) := erp_api_util_pkg.trace_id();
        l_payload json_object_t;
        l_business_unit_id number;
        l_number number;
        l_text varchar2(4000);
    begin
        erp_principal_pkg.assert_role('REQUESTER');
        erp_auth_pkg.assert_editable_owner(p_request_id);
        erp_input_pkg.assert_no_raw_bank(p_body);
        l_payload := erp_input_pkg.parse_object(p_body);
        erp_input_pkg.assert_allowed_keys(
            l_payload,
            'supplierName,supplierTypeCode,countryCode,businessUnitId,businessUnitCode,businessJustification,productServiceCategory,expectedAnnualSpend,taxRegistrationNumber,sites,contacts,bank,documents'
        );
        if l_payload.has('businessUnitId') or l_payload.has('businessUnitCode') then
            l_business_unit_id := business_unit_id(l_payload);
        end if;
        if l_payload.has('supplierName') then
            l_text := erp_input_pkg.optional_string(l_payload, 'supplierName', 200);
            update supplier_request set supplier_name = l_text where request_id = p_request_id;
        end if;
        if l_payload.has('supplierTypeCode') then
            l_text := upper(erp_input_pkg.optional_string(l_payload, 'supplierTypeCode', 30));
            update supplier_request set supplier_type_code = l_text where request_id = p_request_id;
        end if;
        if l_payload.has('countryCode') then
            l_text := upper(erp_input_pkg.optional_string(l_payload, 'countryCode', 2));
            update supplier_request set country_code = l_text where request_id = p_request_id;
        end if;
        if l_payload.has('businessUnitId') or l_payload.has('businessUnitCode') then
            update supplier_request set business_unit_id = l_business_unit_id where request_id = p_request_id;
        end if;
        if l_payload.has('businessJustification') then
            l_text := erp_input_pkg.optional_string(l_payload, 'businessJustification', 4000);
            update supplier_request set business_justification = to_clob(l_text) where request_id = p_request_id;
        end if;
        if l_payload.has('productServiceCategory') then
            l_text := erp_input_pkg.optional_string(l_payload, 'productServiceCategory', 120);
            update supplier_request set product_service_category = l_text where request_id = p_request_id;
        end if;
        if l_payload.has('expectedAnnualSpend') then
            l_number := null;
            if not l_payload.get('expectedAnnualSpend').is_null then
                l_number := l_payload.get_number('expectedAnnualSpend');
            end if;
            update supplier_request set expected_annual_spend = l_number where request_id = p_request_id;
        end if;
        if l_payload.has('taxRegistrationNumber') then
            l_text := erp_input_pkg.optional_string(l_payload, 'taxRegistrationNumber', 80);
            update supplier_request set tax_registration_number = l_text where request_id = p_request_id;
        end if;
        update supplier_request set last_updated_at = systimestamp where request_id = p_request_id;
        erp_request_repo_pkg.replace_children(p_request_id, l_payload);
        commit;
        o_status := 200;
        o_body := erp_api_util_pkg.success(erp_request_projection_pkg.request_json(p_request_id, true), l_trace);
    exception when others then
        rollback;
        o_status := safe_status();
        o_body := safe_error(l_trace);
    end;

    procedure submit_request(p_request_id number, o_status out number, o_body out clob) is
        l_trace varchar2(64) := erp_api_util_pkg.trace_id();
        l_status varchar2(30);
        l_actor varchar2(128);
        l_run_id varchar2(64);
        l_blockers number;
        l_action varchar2(40);
        l_data json_object_t := json_object_t();
    begin
        erp_principal_pkg.assert_role('REQUESTER');
        erp_auth_pkg.assert_editable_owner(p_request_id);
        l_status := erp_request_repo_pkg.request_status(p_request_id);
        l_actor := erp_principal_pkg.subject();
        erp_gov_check_port_pkg.run_checks(p_request_id, l_actor, l_run_id, l_blockers);
        if l_blockers > 0 then
            commit;
            l_data.put('requestId', p_request_id);
            l_data.put('status', l_status);
            l_data.put('runId', l_run_id);
            l_data.put('validationResults', json_element_t.parse(erp_request_projection_pkg.validation_json(p_request_id)));
            o_status := 422;
            o_body := erp_api_util_pkg.failure('VALIDATION_BLOCKED', 'Resolve the blocking findings before submission.', l_trace, l_data.to_clob());
            return;
        end if;
        l_action := case l_status when 'Correction Requested' then 'RESUBMIT' else 'SUBMIT' end;
        insert into status_history (
            request_id, from_status, to_status, action_code, actor_user,
            action_comment, action_timestamp
        ) values (p_request_id, l_status, 'Submitted', l_action, l_actor, 'All blocking checks passed.', systimestamp);
        insert into status_history (
            request_id, from_status, to_status, action_code, actor_user,
            action_comment, action_timestamp
        ) values (p_request_id, 'Submitted', 'Under Review', 'AUTO_ROUTE_TO_REVIEW', 'SYSTEM', 'Routed to Reviewer queue.', systimestamp);
        update supplier_request
           set status = 'Under Review', submitted_at = systimestamp, last_updated_at = systimestamp
         where request_id = p_request_id;
        commit;
        o_status := 200;
        o_body := erp_api_util_pkg.success(erp_request_projection_pkg.request_json(p_request_id, true), l_trace);
    exception when others then
        rollback;
        o_status := safe_status();
        o_body := safe_error(l_trace);
    end;

    procedure maintain_attachment(p_request_id number, p_body clob, o_status out number, o_body out clob) is
        l_trace varchar2(64) := erp_api_util_pkg.trace_id();
        l_payload json_object_t;
        l_document_id number;
        l_document_type varchar2(60);
        l_document_status varchar2(30);
        l_is_required number := 0;
        l_metadata clob;
        l_missing number := 0;
    begin
        erp_principal_pkg.assert_role('REQUESTER');
        erp_auth_pkg.assert_editable_owner(p_request_id);
        l_payload := erp_input_pkg.parse_object(p_body);
        erp_input_pkg.assert_allowed_keys(l_payload, 'documentId,documentType,documentStatus,isRequired,metadata,missing');
        l_document_type := erp_input_pkg.optional_string(l_payload, 'documentType', 60);
        l_document_status := erp_input_pkg.optional_string(l_payload, 'documentStatus', 30);
        if l_payload.has('isRequired') and l_payload.get_boolean('isRequired') then l_is_required := 1; end if;
        if l_payload.has('metadata') then l_metadata := l_payload.get('metadata').to_clob(); end if;
        if l_payload.has('missing') and l_payload.get_boolean('missing') then l_missing := 1; end if;
        if l_payload.has('documentId') and not l_payload.get('documentId').is_null then
            l_document_id := l_payload.get_number('documentId');
            update supplier_request_document
               set document_type = l_document_type,
                   document_status = l_document_status,
                   is_required = l_is_required,
                   metadata_json = case when l_metadata is not null then l_metadata else metadata_json end,
                   missing_flag = l_missing
             where document_id = l_document_id and request_id = p_request_id;
            if sql%rowcount = 0 then raise_application_error(-20003, 'REQUEST_NOT_FOUND'); end if;
        else
            insert into supplier_request_document (
                request_id, document_type, document_status, is_required,
                metadata_json, missing_flag
            ) values (
                p_request_id,
                l_document_type,
                l_document_status,
                l_is_required,
                nvl(l_metadata, to_clob('{}')),
                l_missing
            );
        end if;
        commit;
        o_status := 200;
        o_body := erp_api_util_pkg.success(erp_request_projection_pkg.attachments_json(p_request_id), l_trace);
    exception when others then
        rollback;
        o_status := safe_status();
        o_body := safe_error(l_trace);
    end;
end erp_request_workflow_pkg;
/
