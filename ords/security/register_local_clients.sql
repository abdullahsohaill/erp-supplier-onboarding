variable requester_a_secret varchar2(256)
variable requester_b_secret varchar2(256)
variable reviewer_secret varchar2(256)
variable support_secret varchar2(256)
variable system_secret varchar2(256)

begin
    :requester_a_secret := '__REQUESTER_A_SECRET__';
    :requester_b_secret := '__REQUESTER_B_SECRET__';
    :reviewer_secret := '__REVIEWER_SECRET__';
    :support_secret := '__SUPPORT_SECRET__';
    :system_secret := '__SYSTEM_SECRET__';
end;
/

declare
    procedure register_client(
        p_name varchar2,
        p_client_id varchar2,
        p_secret varchar2,
        p_role varchar2
    ) is
        l_count number;
    begin
        select count(*) into l_count from user_ords_clients where name = p_name;
        if l_count > 0 then
            ords_security.delete_client(p_name => p_name);
        end if;
        ords_security.import_client(
            p_name => p_name,
            p_client_id => p_client_id,
            p_grant_type => 'client_credentials',
            p_support_email => 'support@example.invalid',
            p_description => 'Deterministic local test client',
            p_origins_allowed => 'http://127.0.0.1:5500',
            p_token_duration => 900
        );
        ords_security.register_client_secret(
            p_name => p_name,
            p_client_secret => p_secret,
            p_revoke_existing => true,
            p_revoke_sessions => true
        );
        ords_security.grant_client_role(
            p_client_name => p_name,
            p_role_name => p_role
        );
    end;
begin
    register_client('requester_a', 'requester_a', :requester_a_secret, 'ERP_REQUESTER');
    register_client('requester_b', 'requester_b', :requester_b_secret, 'ERP_REQUESTER');
    register_client('reviewer_test', 'reviewer_test', :reviewer_secret, 'ERP_REVIEWER');
    register_client('support_admin_test', 'support_admin_test', :support_secret, 'ERP_SUPPORT_ADMIN');
    register_client('system_oic_test', 'system_oic_test', :system_secret, 'ERP_SYSTEM_OIC');
    commit;
end;
/
