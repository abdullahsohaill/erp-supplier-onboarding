create or replace package erp_auth_pkg authid definer as
    procedure assert_owner(p_request_id number);
    procedure assert_editable_owner(p_request_id number);
end erp_auth_pkg;
/
