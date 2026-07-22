create or replace package erp_request_repo_pkg authid definer as
    function request_status(p_request_id number) return varchar2;
    function request_owner(p_request_id number) return varchar2;
    procedure replace_children(p_request_id number, p_payload json_object_t);
end erp_request_repo_pkg;
/
