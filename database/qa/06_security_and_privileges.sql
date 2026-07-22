select owner, table_name, privilege, grantable
from user_tab_privs_recd
where owner = 'ERP_APP'
order by table_name, privilege;

select granted_role, admin_option, default_role
from user_role_privs
order by granted_role;
