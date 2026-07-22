create or replace package body erp_auth_pkg as
    procedure assert_owner(p_request_id number) is
        l_owner supplier_request.requester_user%type;
    begin
        select requester_user into l_owner
          from supplier_request
         where request_id = p_request_id;
        if lower(l_owner) <> erp_principal_pkg.subject() then
            raise_application_error(-20003, 'REQUEST_NOT_FOUND');
        end if;
    exception
        when no_data_found then
            raise_application_error(-20003, 'REQUEST_NOT_FOUND');
    end;

    procedure assert_editable_owner(p_request_id number) is
        l_owner supplier_request.requester_user%type;
        l_status supplier_request.status%type;
    begin
        select requester_user, status into l_owner, l_status
          from supplier_request
         where request_id = p_request_id
         for update;
        if lower(l_owner) <> erp_principal_pkg.subject() then
            raise_application_error(-20003, 'REQUEST_NOT_FOUND');
        end if;
        if l_status not in ('Draft', 'Correction Requested') then
            raise_application_error(-20009, 'REQUEST_NOT_EDITABLE');
        end if;
    exception
        when no_data_found then
            raise_application_error(-20003, 'REQUEST_NOT_FOUND');
    end;
end erp_auth_pkg;
/
