create or replace package erp_request_query_pkg authid definer as
    function list_own(p_status varchar2 default null, p_limit number default 25, p_offset number default 0) return clob;
    function own_detail(p_request_id number) return clob;
    function own_validation(p_request_id number) return clob;
    function own_attachments(p_request_id number) return clob;
    function requester_dashboard return clob;
    function business_units return clob;
    function supplier_types return clob;
end erp_request_query_pkg;
/
