create or replace package erp_api_dispatch_pkg authid definer as
    function list_requests(p_status varchar2 default null, p_limit number default 25, p_offset number default 0) return clob;
    function request_detail(p_request_id number) return clob;
    function validation_results(p_request_id number) return clob;
    function attachments(p_request_id number) return clob;
end erp_api_dispatch_pkg;
/
