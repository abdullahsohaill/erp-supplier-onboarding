create or replace package erp_request_projection_pkg authid definer as
    function request_json(p_request_id number, p_requester_safe boolean default true) return clob;
    function validation_json(p_request_id number) return clob;
    function attachments_json(p_request_id number) return clob;
end erp_request_projection_pkg;
/
