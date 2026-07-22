create or replace package body erp_request_repo_pkg as
    function request_status(p_request_id number) return varchar2 is
        l_value supplier_request.status%type;
    begin
        select status into l_value from supplier_request where request_id = p_request_id;
        return l_value;
    exception when no_data_found then
        raise_application_error(-20003, 'REQUEST_NOT_FOUND');
    end;

    function request_owner(p_request_id number) return varchar2 is
        l_value supplier_request.requester_user%type;
    begin
        select requester_user into l_value from supplier_request where request_id = p_request_id;
        return l_value;
    exception when no_data_found then
        raise_application_error(-20003, 'REQUEST_NOT_FOUND');
    end;

    procedure replace_children(p_request_id number, p_payload json_object_t) is
        l_array json_array_t;
        l_item json_object_t;
        l_bank json_object_t;
        l_address1 varchar2(20);
        l_address2 varchar2(20);
        l_name varchar2(200);
        l_code varchar2(60);
        l_country varchar2(2);
        l_city varchar2(80);
        l_region varchar2(80);
        l_postal varchar2(20);
        l_business_unit_id number;
        l_flag number;
        l_missing_flag number;
        l_email varchar2(254);
        l_phone varchar2(40);
        l_metadata clob;
        l_hash varchar2(128);
        l_last4 varchar2(4);
        l_masked varchar2(40);
    begin
        if p_payload.has('sites') then
            delete from supplier_request_site where request_id = p_request_id;
            l_array := p_payload.get_array('sites');
            if l_array.get_size() > 20 then raise_application_error(-20000, 'TOO_MANY_SITES'); end if;
            for i in 0 .. l_array.get_size() - 1 loop
                l_item := treat(l_array.get(i) as json_object_t);
                erp_input_pkg.assert_allowed_keys(l_item, 'siteName,countryCode,addressLine1,addressLine2,city,region,postalCode,intendedBusinessUnitId,isPrimary');
                l_address1 := erp_input_pkg.optional_string(l_item, 'addressLine1', 20);
                l_address2 := erp_input_pkg.optional_string(l_item, 'addressLine2', 20);
                l_name := erp_input_pkg.optional_string(l_item, 'siteName', 120);
                l_country := upper(erp_input_pkg.optional_string(l_item, 'countryCode', 2));
                l_city := erp_input_pkg.optional_string(l_item, 'city', 80);
                l_region := erp_input_pkg.optional_string(l_item, 'region', 80);
                l_postal := erp_input_pkg.optional_string(l_item, 'postalCode', 20);
                l_business_unit_id := null;
                if l_item.has('intendedBusinessUnitId') then l_business_unit_id := l_item.get_number('intendedBusinessUnitId'); end if;
                l_flag := 0;
                if l_item.has('isPrimary') and l_item.get_boolean('isPrimary') then l_flag := 1; end if;
                insert into supplier_request_site (
                    request_id, site_name, country_code, address_line1, address_line2,
                    city, region, postal_code, intended_business_unit_id, is_primary
                ) values (
                    p_request_id,
                    l_name,
                    l_country,
                    l_address1, l_address2,
                    l_city,
                    l_region,
                    l_postal,
                    l_business_unit_id,
                    l_flag
                );
            end loop;
        end if;

        if p_payload.has('contacts') then
            delete from supplier_request_contact where request_id = p_request_id;
            l_array := p_payload.get_array('contacts');
            if l_array.get_size() > 20 then raise_application_error(-20000, 'TOO_MANY_CONTACTS'); end if;
            for i in 0 .. l_array.get_size() - 1 loop
                l_item := treat(l_array.get(i) as json_object_t);
                erp_input_pkg.assert_allowed_keys(l_item, 'contactName,contactEmail,phoneNumber');
                l_name := erp_input_pkg.optional_string(l_item, 'contactName', 120);
                l_email := lower(erp_input_pkg.optional_string(l_item, 'contactEmail', 254));
                l_phone := erp_input_pkg.optional_string(l_item, 'phoneNumber', 40);
                insert into supplier_request_contact (
                    request_id, contact_name, contact_email, phone_number, email_domain
                ) values (
                    p_request_id,
                    l_name,
                    l_email,
                    l_phone,
                    lower(regexp_substr(l_email, '@([^@]+)$', 1, 1, null, 1))
                );
            end loop;
        end if;

        if p_payload.has('bank') then
            delete from supplier_request_bank where request_id = p_request_id;
            if not p_payload.get('bank').is_null then
                l_bank := p_payload.get_object('bank');
                erp_input_pkg.assert_allowed_keys(l_bank, 'bankCountryCode,maskedAccountDisplay,accountLast4,accountHash,bankProvided');
                l_country := upper(erp_input_pkg.optional_string(l_bank, 'bankCountryCode', 2));
                l_masked := erp_input_pkg.optional_string(l_bank, 'maskedAccountDisplay', 40);
                l_last4 := erp_input_pkg.optional_string(l_bank, 'accountLast4', 4);
                l_hash := erp_input_pkg.optional_string(l_bank, 'accountHash', 128);
                l_flag := 0;
                if l_bank.has('bankProvided') and l_bank.get_boolean('bankProvided') then l_flag := 1; end if;
                insert into supplier_request_bank (
                    request_id, bank_country_code, masked_account_display,
                    account_last4, account_hash, bank_provided_flag
                ) values (
                    p_request_id,
                    l_country,
                    l_masked,
                    l_last4,
                    l_hash,
                    l_flag
                );
            end if;
        end if;

        if p_payload.has('documents') then
            delete from supplier_request_document where request_id = p_request_id;
            l_array := p_payload.get_array('documents');
            if l_array.get_size() > 50 then raise_application_error(-20000, 'TOO_MANY_DOCUMENTS'); end if;
            for i in 0 .. l_array.get_size() - 1 loop
                l_item := treat(l_array.get(i) as json_object_t);
                erp_input_pkg.assert_allowed_keys(l_item, 'documentType,documentStatus,isRequired,metadata,missing');
                l_code := erp_input_pkg.optional_string(l_item, 'documentType', 60);
                l_name := erp_input_pkg.optional_string(l_item, 'documentStatus', 30);
                l_flag := 0;
                if l_item.has('isRequired') and l_item.get_boolean('isRequired') then l_flag := 1; end if;
                if l_item.has('metadata') then l_metadata := l_item.get('metadata').to_clob(); else l_metadata := to_clob('{}'); end if;
                l_missing_flag := 0;
                if l_item.has('missing') and l_item.get_boolean('missing') then l_missing_flag := 1; end if;
                insert into supplier_request_document (
                    request_id, document_type, document_status, is_required,
                    metadata_json, missing_flag
                ) values (
                    p_request_id,
                    l_code,
                    l_name,
                    l_flag,
                    l_metadata,
                    l_missing_flag
                );
            end loop;
        end if;
    end;
end erp_request_repo_pkg;
/
