set define off
whenever sqlerror exit failure rollback

declare
  l_count number;
begin
  select count(*) into l_count from dba_users where username = 'ERP_APP';
  if l_count = 0 then
    execute immediate 'create user ERP_APP identified by "${ERP_APP_PASSWORD}" quota unlimited on data';
  else
    execute immediate 'alter user ERP_APP identified by "${ERP_APP_PASSWORD}" account unlock';
  end if;
end;
/

grant create session, create table, create procedure, create sequence, create view to ERP_APP;

begin
  ords_admin.enable_schema(
    p_enabled             => true,
    p_schema              => 'ERP_APP',
    p_url_mapping_type    => 'BASE_PATH',
    p_url_mapping_pattern => 'erp',
    p_auto_rest_auth      => true
  );
  commit;
end;
/
