create or replace package erp_principal_pkg authid definer as
    function subject return varchar2;
    function local_role return varchar2;
    procedure assert_role(p_allowed_csv varchar2);
end erp_principal_pkg;
/
