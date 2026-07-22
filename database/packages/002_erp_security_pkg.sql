create or replace package erp_security_pkg authid definer as
  function current_actor return varchar2;
  function is_privileged_actor(p_actor varchar2 default null) return number;
  procedure assert_reviewer(p_actor varchar2 default null);
  procedure assert_admin(p_actor varchar2 default null);
  procedure assert_system_or_admin(p_actor varchar2 default null);
  procedure assert_request_owner(p_request_id number, p_actor varchar2 default null);
  procedure assert_editable_owner(p_request_id number, p_actor varchar2 default null);
end erp_security_pkg;
/

create or replace package body erp_security_pkg as
  function current_actor return varchar2 is
    l_actor varchar2(255);
  begin
    l_actor := owa_util.get_cgi_env('REMOTE_USER');
    if l_actor is null then
      l_actor := sys_context('USERENV', 'CLIENT_IDENTIFIER');
    end if;
    if l_actor is null then
      l_actor := sys_context('USERENV', 'SESSION_USER');
    end if;
    l_actor := lower(l_actor);

    -- Client-credentials requests expose the generated OAuth client ID as
    -- REMOTE_USER. Resolve it to the stable client name used by application
    -- ownership and role checks.
    begin
      select lower(name)
        into l_actor
        from user_ords_clients
       where lower(client_id) = l_actor
          or lower(name) = l_actor
       fetch first 1 row only;
    exception
      when no_data_found then null;
    end;

    return l_actor;
  exception
    when others then
      return lower(sys_context('USERENV', 'SESSION_USER'));
  end;

  function is_privileged_actor(p_actor varchar2 default null) return number is
    l_actor varchar2(255) := lower(nvl(p_actor, current_actor));
  begin
    return case when l_actor in ('local-reviewer', 'local-admin', 'local-system', 'erp_app') then 1 else 0 end;
  end;

  procedure assert_reviewer(p_actor varchar2 default null) is
    l_actor varchar2(255) := lower(nvl(p_actor, current_actor));
  begin
    if l_actor not in ('local-reviewer','erp_app') then raise_application_error(-20003,'FORBIDDEN'); end if;
  end;

  procedure assert_admin(p_actor varchar2 default null) is
    l_actor varchar2(255) := lower(nvl(p_actor, current_actor));
  begin
    if l_actor not in ('local-admin','erp_app') then raise_application_error(-20003,'FORBIDDEN'); end if;
  end;

  procedure assert_system_or_admin(p_actor varchar2 default null) is
    l_actor varchar2(255) := lower(nvl(p_actor, current_actor));
  begin
    if l_actor not in ('local-system','local-admin','erp_app') then raise_application_error(-20003,'FORBIDDEN'); end if;
  end;

  procedure assert_request_owner(p_request_id number, p_actor varchar2 default null) is
    l_count number;
    l_actor varchar2(255) := lower(nvl(p_actor, current_actor));
  begin
    select count(*) into l_count
      from supplier_request
     where request_id = p_request_id
       and lower(requester_user) = l_actor;
    if l_count = 0 then
      raise_application_error(-20004, 'REQUEST_NOT_FOUND');
    end if;
  end;

  procedure assert_editable_owner(p_request_id number, p_actor varchar2 default null) is
    l_status supplier_request.status%type;
    l_actor varchar2(255) := lower(nvl(p_actor, current_actor));
  begin
    select status into l_status
      from supplier_request
     where request_id = p_request_id
       and lower(requester_user) = l_actor
       for update;
    if l_status not in ('Draft', 'Correction Requested') then
      raise_application_error(-20009, 'INVALID_STATUS_TRANSITION');
    end if;
  exception
    when no_data_found then
      raise_application_error(-20004, 'REQUEST_NOT_FOUND');
  end;
end erp_security_pkg;
/
