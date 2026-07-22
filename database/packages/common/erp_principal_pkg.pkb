create or replace package body erp_principal_pkg as
    function subject return varchar2 is
        l_subject varchar2(128);
    begin
        l_subject := nullif(trim(owa_util.get_cgi_env('REMOTE_USER')), '');
        if l_subject is null then
            l_subject := nullif(trim(sys_context('USERENV', 'CLIENT_IDENTIFIER')), '');
        end if;
        if l_subject is null then
            raise_application_error(-20001, 'AUTHENTICATION_REQUIRED');
        end if;
        return lower(substr(l_subject, 1, 128));
    exception
        when value_error then
            raise_application_error(-20001, 'AUTHENTICATION_REQUIRED');
    end;

    function local_role return varchar2 is
        l_subject varchar2(128) := subject();
    begin
        if l_subject in ('requester_a', 'requester_b') then return 'REQUESTER'; end if;
        if l_subject = 'reviewer_test' then return 'REVIEWER'; end if;
        if l_subject = 'support_admin_test' then return 'SUPPORT_ADMIN'; end if;
        if l_subject = 'system_oic_test' then return 'SYSTEM_OIC'; end if;
        return 'UNKNOWN';
    end;

    procedure assert_role(p_allowed_csv varchar2) is
        l_role varchar2(30) := local_role();
    begin
        if instr(',' || upper(p_allowed_csv) || ',', ',' || l_role || ',') = 0 then
            raise_application_error(-20004, 'ROLE_FORBIDDEN');
        end if;
    end;
end erp_principal_pkg;
/
