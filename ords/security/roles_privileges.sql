declare
    l_roles owa.vc_arr;
    l_patterns owa.vc_arr;
    l_modules owa.vc_arr;
begin
    ords.create_role('ERP_REQUESTER');
    ords.create_role('ERP_REVIEWER');
    ords.create_role('ERP_SUPPORT_ADMIN');
    ords.create_role('ERP_SYSTEM_OIC');

    l_roles(1) := 'ERP_REQUESTER';
    l_roles(2) := 'ERP_REVIEWER';
    l_roles(3) := 'ERP_SUPPORT_ADMIN';
    l_roles(4) := 'ERP_SYSTEM_OIC';
    l_modules(1) := 'supplier.onboarding.v1';
    ords.define_privilege(
        p_privilege_name => 'erp.supplier.onboarding.authenticated',
        p_roles => l_roles,
        p_patterns => l_patterns,
        p_modules => l_modules,
        p_label => 'Supplier Onboarding Authenticated Access',
        p_description => 'Requires an approved application role. PL/SQL applies function and object scope.',
        p_comments => 'Local OAuth2 protection for all supplier.onboarding.v1 handlers.'
    );
    commit;
end;
/
