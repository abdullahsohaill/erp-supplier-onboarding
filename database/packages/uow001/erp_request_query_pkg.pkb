create or replace package body erp_request_query_pkg as
    function list_own(p_status varchar2 default null, p_limit number default 25, p_offset number default 0) return clob is
        l_json clob;
        l_limit number := least(greatest(nvl(p_limit, 25), 1), 100);
        l_offset number := greatest(nvl(p_offset, 0), 0);
    begin
        erp_principal_pkg.assert_role('REQUESTER');
        select coalesce(json_arrayagg(json_object(
            'requestId' value request_id, 'requestNumber' value request_number,
            'supplierName' value supplier_name, 'status' value status,
            'nextAction' value next_action, 'fusionSupplierNumber' value fusion_supplier_number,
            'lastUpdatedAt' value to_char(last_updated_at, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZH:TZM')
        ) order by last_updated_at desc returning clob), to_clob('[]')) into l_json
        from (
            select * from v_requester_request_summary
             where lower(requester_user) = erp_principal_pkg.subject()
               and (p_status is null or status = p_status)
             order by last_updated_at desc
             offset l_offset rows fetch next l_limit rows only
        );
        return erp_api_util_pkg.success(l_json);
    end;

    function own_detail(p_request_id number) return clob is
    begin
        erp_principal_pkg.assert_role('REQUESTER');
        erp_auth_pkg.assert_owner(p_request_id);
        return erp_api_util_pkg.success(erp_request_projection_pkg.request_json(p_request_id, true));
    exception when others then
        return erp_api_util_pkg.failure('REQUEST_NOT_FOUND', 'Request was not found.');
    end;

    function own_validation(p_request_id number) return clob is
    begin
        erp_principal_pkg.assert_role('REQUESTER');
        erp_auth_pkg.assert_owner(p_request_id);
        return erp_api_util_pkg.success(erp_request_projection_pkg.validation_json(p_request_id));
    exception when others then return erp_api_util_pkg.failure('REQUEST_NOT_FOUND', 'Request was not found.');
    end;

    function own_attachments(p_request_id number) return clob is
    begin
        erp_principal_pkg.assert_role('REQUESTER');
        erp_auth_pkg.assert_owner(p_request_id);
        return erp_api_util_pkg.success(erp_request_projection_pkg.attachments_json(p_request_id));
    exception when others then return erp_api_util_pkg.failure('REQUEST_NOT_FOUND', 'Request was not found.');
    end;

    function requester_dashboard return clob is
        l_json clob;
    begin
        erp_principal_pkg.assert_role('REQUESTER');
        select json_object(
            'total' value count(*),
            'draft' value count(case when status = 'Draft' then 1 end),
            'correctionRequested' value count(case when status = 'Correction Requested' then 1 end),
            'underReview' value count(case when status = 'Under Review' then 1 end),
            'completed' value count(case when status in ('Created in Fusion', 'Rejected', 'Marked Duplicate') then 1 end)
            returning clob
        ) into l_json from supplier_request where lower(requester_user) = erp_principal_pkg.subject();
        return erp_api_util_pkg.success(l_json);
    end;

    function business_units return clob is
        l_json clob;
    begin
        select coalesce(json_arrayagg(json_object(
            'businessUnitId' value business_unit_id, 'code' value business_unit_code,
            'name' value business_unit_name
        ) order by business_unit_name returning clob), to_clob('[]')) into l_json
          from ref_business_unit where active_flag = 1;
        return erp_api_util_pkg.success(l_json);
    end;

    function supplier_types return clob is
        l_json clob;
    begin
        select coalesce(json_arrayagg(json_object(
            'supplierTypeId' value supplier_type_id, 'code' value supplier_type_code,
            'name' value supplier_type_name,
            'taxRequired' value case tax_required_flag when 1 then 'true' else 'false' end format json
        ) order by supplier_type_name returning clob), to_clob('[]')) into l_json
          from ref_supplier_type where active_flag = 1;
        return erp_api_util_pkg.success(l_json);
    end;
end erp_request_query_pkg;
/
