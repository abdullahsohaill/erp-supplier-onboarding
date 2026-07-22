whenever sqlerror exit failure rollback
set define off

declare
    l_count number;
begin
    select count(*) into l_count from dba_users where username = 'ERP_APP';
    if l_count = 0 then
        execute immediate 'create user ERP_APP identified by "' || :erp_app_password || '" quota unlimited on DATA';
    end if;

    select count(*) into l_count from dba_users where username = 'ERP_VERIFY';
    if l_count = 0 then
        execute immediate 'create user ERP_VERIFY identified by "' || :erp_verify_password || '"';
    end if;
end;
/

grant create session, create table, create sequence, create view, create procedure to ERP_APP;
grant create session to ERP_VERIFY;

begin
    ords_admin.enable_schema(
        p_enabled             => true,
        p_schema              => 'ERP_VERIFY',
        p_url_mapping_type    => 'BASE_PATH',
        p_url_mapping_pattern => 'erp-inspector',
        p_auto_rest_auth      => true
    );
    commit;
end;
/
