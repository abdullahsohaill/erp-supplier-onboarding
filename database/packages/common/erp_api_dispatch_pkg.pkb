create or replace package body erp_api_dispatch_pkg as
    function list_requests(p_status varchar2 default null, p_limit number default 25, p_offset number default 0) return clob is
    begin
        if erp_principal_pkg.local_role() = 'REQUESTER' then
            return erp_request_query_pkg.list_own(p_status, p_limit, p_offset);
        end if;
        return erp_review_pkg.list_requests(p_status, p_limit, p_offset);
    end;

    function request_detail(p_request_id number) return clob is
    begin
        if erp_principal_pkg.local_role() = 'REQUESTER' then
            return erp_request_query_pkg.own_detail(p_request_id);
        end if;
        return erp_review_pkg.request_detail(p_request_id);
    end;

    function validation_results(p_request_id number) return clob is
    begin
        if erp_principal_pkg.local_role() = 'REQUESTER' then
            return erp_request_query_pkg.own_validation(p_request_id);
        end if;
        return erp_api_util_pkg.success(erp_request_projection_pkg.validation_json(p_request_id));
    end;

    function attachments(p_request_id number) return clob is
    begin
        if erp_principal_pkg.local_role() = 'REQUESTER' then
            return erp_request_query_pkg.own_attachments(p_request_id);
        end if;
        return erp_api_util_pkg.success(erp_request_projection_pkg.attachments_json(p_request_id));
    end;
end erp_api_dispatch_pkg;
/
