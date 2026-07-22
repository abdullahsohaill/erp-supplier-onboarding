set serveroutput on
whenever sqlerror exit failure rollback

declare
  procedure ensure_client(p_name varchar2, p_role varchar2, p_description varchar2) is
    l_client_count number;
    l_role_count number;
    l_credentials ords_types.t_client_credentials;
  begin
    select count(*) into l_client_count from user_ords_clients where name = p_name;
    if l_client_count = 0 then
      l_credentials := ords_security.register_client(
        p_name          => p_name,
        p_grant_type    => 'client_credentials',
        p_description   => p_description,
        p_client_secret => ords_types.oauth_client_secret(p_stored => true),
        p_support_email => 'local-only@example.invalid'
      );
    end if;

    select count(*) into l_role_count
      from user_ords_client_roles
     where client_name = p_name and role_name = p_role;
    if l_role_count = 0 then
      ords_security.grant_client_role(p_client_name => p_name, p_role_name => p_role);
    end if;
  end;
begin
  ensure_client('local-requester','erp.requester','Local Requester test client');
  ensure_client('local-reviewer','erp.reviewer','Local Reviewer test client');
  ensure_client('local-admin','erp.support_admin','Local Support/Admin test client');
  ensure_client('local-system','erp.system_oic','Local System/OIC test client');
  commit;
  dbms_output.put_line('OAuth clients ensured with generated stored secrets. Retrieve credentials securely from USER_ORDS_CLIENTS.');
end;
/
