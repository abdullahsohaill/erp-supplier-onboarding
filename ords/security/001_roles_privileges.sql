declare
  procedure ensure_role(p_name varchar2) is
    l_count number;
  begin
    select count(*) into l_count from user_ords_roles where name = p_name;
    if l_count = 0 then
      ords.create_role(p_name);
    end if;
  end;
begin
  ensure_role('erp.requester');
  ensure_role('erp.reviewer');
  ensure_role('erp.support_admin');
  ensure_role('erp.system_oic');
  commit;
end;
/

declare
  procedure remove_access(p_name varchar2) is
    l_count number;
  begin
    select count(*) into l_count from user_ords_privileges where name = p_name;
    if l_count > 0 then
      ords.delete_privilege(p_name => p_name);
    end if;
  end;

  procedure define_access(
    p_name varchar2,
    p_pattern_1 varchar2,
    p_role_1 varchar2,
    p_role_2 varchar2 default null,
    p_role_3 varchar2 default null,
    p_role_4 varchar2 default null,
    p_pattern_2 varchar2 default null
  ) is
    l_roles owa.vc_arr;
    l_patterns owa.vc_arr;
  begin
    l_roles(1) := p_role_1;
    if p_role_2 is not null then l_roles(2) := p_role_2; end if;
    if p_role_3 is not null then l_roles(3) := p_role_3; end if;
    if p_role_4 is not null then l_roles(4) := p_role_4; end if;
    l_patterns(1) := p_pattern_1;
    if p_pattern_2 is not null then l_patterns(2) := p_pattern_2; end if;
    ords.define_privilege(
      p_privilege_name => p_name,
      p_roles          => l_roles,
      p_patterns       => l_patterns,
      p_label          => p_name,
      p_description    => 'Deny-by-default role boundary for supplier onboarding.'
    );
  end;
begin
  remove_access('erp.requester.access');
  remove_access('erp.reviewer.access');
  remove_access('erp.support_admin.access');
  remove_access('erp.system_oic.access');
  remove_access('erp.requests.access');
  remove_access('erp.reference.access');
  remove_access('erp.dashboard.requester.access');
  remove_access('erp.dashboard.reviewer.access');
  remove_access('erp.dashboard.support.access');
  remove_access('erp.admin.access');
  remove_access('erp.integration.access');
  remove_access('erp.internal.access');

  define_access(
    p_name => 'erp.requests.access',
    p_pattern_1 => '/v1/requests/*',
    p_pattern_2 => '/v1/requests',
    p_role_1 => 'erp.requester',
    p_role_2 => 'erp.reviewer',
    p_role_3 => 'erp.support_admin',
    p_role_4 => 'erp.system_oic'
  );
  define_access('erp.reference.access', '/v1/reference/*', 'erp.requester', 'erp.reviewer');
  define_access('erp.dashboard.requester.access', '/v1/dashboard/requester-summary', 'erp.requester');
  define_access('erp.dashboard.reviewer.access', '/v1/dashboard/reviewer-summary', 'erp.reviewer');
  define_access('erp.dashboard.support.access', '/v1/dashboard/support-summary', 'erp.support_admin');
  define_access('erp.admin.access', '/v1/admin-settings/*', 'erp.support_admin');
  define_access(
    p_name => 'erp.integration.access',
    p_pattern_1 => '/v1/integration-logs/*',
    p_pattern_2 => '/v1/integration-logs',
    p_role_1 => 'erp.support_admin'
  );
  define_access('erp.internal.access', '/v1/internal/*', 'erp.system_oic');
  commit;
end;
/
