create or replace package body erp_integration_pkg as
    function log_json(p_log_id number) return clob is
        l_json clob;
    begin
        select json_object(
            'logId' value log_id, 'requestId' value request_id,
            'integrationName' value integration_name, 'oicInstanceId' value oic_instance_id,
            'direction' value direction, 'status' value status,
            'errorCategory' value error_category, 'payloadRef' value payload_ref,
            'responseRef' value response_ref, 'userMessage' value user_message,
            'technicalMessage' value technical_message, 'retryCount' value retry_count,
            'retryEligible' value case retry_eligible_flag when 1 then 'true' else 'false' end format json,
            'lastRetryAt' value to_char(last_retry_at, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZH:TZM'),
            'lastRetryBy' value last_retry_by,
            'retryHistory' value retry_history_json format json,
            'createdAt' value to_char(created_at, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZH:TZM') returning clob
        ) into l_json from integration_log where log_id = p_log_id;
        return l_json;
    end;

    procedure submit_to_fusion(p_request_id number, o_status out number, o_body out clob) is
        l_request supplier_request%rowtype;
        l_log_id number;
        l_oic_id varchar2(100) := 'OIC-MOCK-' || p_request_id || '-' || to_char(systimestamp, 'YYYYMMDDHH24MISSFF3');
        l_supplier_number varchar2(80);
    begin
        erp_principal_pkg.assert_role('SUPPORT_ADMIN,SYSTEM_OIC');
        select * into l_request from supplier_request where request_id = p_request_id for update;
        if l_request.status <> 'Approved' then raise_application_error(-20009, 'REQUEST_NOT_APPROVED'); end if;
        if l_request.fusion_supplier_number is not null then raise_application_error(-20009, 'SUPPLIER_ALREADY_CREATED'); end if;
        update supplier_request set status = 'Submitted to Fusion', last_updated_at = systimestamp where request_id = p_request_id;
        insert into status_history (request_id, from_status, to_status, action_code, actor_user, action_comment, action_timestamp)
        values (p_request_id, 'Approved', 'Submitted to Fusion', 'SUBMIT_TO_FUSION', erp_principal_pkg.subject(), 'Submitted to deterministic local Fusion mock.', systimestamp);

        l_supplier_number := 'SUP-MOCK-' || lpad(p_request_id, 6, '0');
        insert into integration_log (
            request_id, integration_name, oic_instance_id, direction, status,
            payload_ref, response_ref, user_message, technical_message,
            retry_count, retry_eligible_flag, retry_history_json, created_at
        ) values (
            p_request_id, 'SUPPLIER_CREATE', l_oic_id, 'OUTBOUND', 'SUCCESS',
            'mock://payloads/' || l_request.request_number,
            'mock://responses/' || l_request.request_number,
            'Supplier created successfully.', null, 0, 0, '[]', systimestamp
        ) returning log_id into l_log_id;
        update supplier_request
           set status = 'Created in Fusion', fusion_supplier_id = 'FUS-MOCK-' || p_request_id,
               fusion_supplier_number = l_supplier_number, fusion_created_at = systimestamp,
               fusion_response_ref = 'mock://responses/' || l_request.request_number,
               last_updated_at = systimestamp
         where request_id = p_request_id;
        insert into status_history (request_id, from_status, to_status, action_code, actor_user, action_comment, action_timestamp)
        values (p_request_id, 'Submitted to Fusion', 'Created in Fusion', 'FUSION_SUCCESS', 'SYSTEM', 'Deterministic local Fusion mock created the supplier.', systimestamp);
        commit;
        o_status := 200;
        o_body := erp_api_util_pkg.success(log_json(l_log_id));
    exception
        when no_data_found then rollback; o_status := 404; o_body := erp_api_util_pkg.failure('REQUEST_NOT_FOUND', 'Request was not found.');
        when others then
            rollback;
            if sqlcode between -20099 and -20000 then o_status := 409; o_body := erp_api_util_pkg.failure('INTEGRATION_REJECTED', replace(sqlerrm, 'ORA-20009: ', ''));
            else o_status := 500; o_body := erp_api_util_pkg.failure('INTERNAL_ERROR', 'Fusion submission could not be completed.'); end if;
    end;

    procedure retry_log(p_log_id number, o_status out number, o_body out clob) is
        l_log integration_log%rowtype;
        l_request supplier_request%rowtype;
        l_history json_array_t;
        l_attempt json_object_t := json_object_t();
        l_actor varchar2(128) := erp_principal_pkg.subject();
        l_oic_id varchar2(100);
        l_history_clob clob;
    begin
        erp_principal_pkg.assert_role('SUPPORT_ADMIN');
        select * into l_log from integration_log where log_id = p_log_id for update;
        select * into l_request from supplier_request where request_id = l_log.request_id for update;
        if l_log.status <> 'FAILED' or l_log.retry_eligible_flag <> 1 then raise_application_error(-20009, 'RETRY_NOT_ELIGIBLE'); end if;
        if l_request.status in ('Rejected', 'Marked Duplicate') or l_request.fusion_supplier_number is not null then raise_application_error(-20009, 'RETRY_NOT_ALLOWED'); end if;
        l_oic_id := 'OIC-MOCK-' || l_log.request_id || '-R' || to_char(nvl(l_log.retry_count, 0) + 1);
        l_history := json_array_t.parse(l_log.retry_history_json);
        l_attempt.put('attempt', nvl(l_log.retry_count, 0) + 1);
        l_attempt.put('actor', l_actor);
        l_attempt.put('timestamp', to_char(systimestamp, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZH:TZM'));
        l_attempt.put('result', 'SUCCESS');
        l_attempt.put('message', 'Deterministic retry completed.');
        l_attempt.put('oicInstanceId', l_oic_id);
        l_history.append(l_attempt);
        l_history_clob := l_history.to_clob();
        update integration_log
           set oic_instance_id = l_oic_id, status = 'SUCCESS', error_category = null,
               response_ref = 'mock://responses/' || l_request.request_number || '/retry',
               user_message = 'Supplier created successfully after retry.', technical_message = null,
               retry_count = nvl(retry_count, 0) + 1, retry_eligible_flag = 0,
               last_retry_at = systimestamp, last_retry_by = l_actor,
               retry_history_json = l_history_clob
         where log_id = p_log_id;
        update supplier_request
           set status = 'Created in Fusion', fusion_supplier_id = 'FUS-MOCK-' || request_id,
               fusion_supplier_number = 'SUP-MOCK-' || lpad(request_id, 6, '0'),
               fusion_created_at = systimestamp,
               fusion_response_ref = 'mock://responses/' || request_number || '/retry',
               last_updated_at = systimestamp
         where request_id = l_log.request_id;
        insert into status_history (request_id, from_status, to_status, action_code, actor_user, action_comment, action_timestamp)
        values (l_log.request_id, l_request.status, 'Created in Fusion', 'INTEGRATION_RETRY_SUCCESS', l_actor, 'Controlled retry created the supplier.', systimestamp);
        commit;
        o_status := 200;
        o_body := erp_api_util_pkg.success(log_json(p_log_id));
    exception
        when no_data_found then rollback; o_status := 404; o_body := erp_api_util_pkg.failure('INTEGRATION_LOG_NOT_FOUND', 'Integration log was not found.');
        when others then rollback; o_status := 409; o_body := erp_api_util_pkg.failure('RETRY_REJECTED', replace(sqlerrm, 'ORA-20009: ', ''));
    end;

    function list_logs(p_request_id number default null, p_status varchar2 default null, p_limit number default 25, p_offset number default 0) return clob is
        l_json clob;
        l_limit number := least(greatest(nvl(p_limit, 25), 1), 100);
        l_offset number := greatest(nvl(p_offset, 0), 0);
    begin
        erp_principal_pkg.assert_role('SUPPORT_ADMIN');
        select coalesce(json_arrayagg(json_object(
            'logId' value log_id, 'requestId' value request_id,
            'integrationName' value integration_name, 'oicInstanceId' value oic_instance_id,
            'status' value status, 'errorCategory' value error_category,
            'retryCount' value retry_count,
            'retryEligible' value case retry_eligible_flag when 1 then 'true' else 'false' end format json,
            'createdAt' value to_char(created_at, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZH:TZM')
        ) order by created_at desc returning clob), to_clob('[]')) into l_json
        from (
            select * from integration_log
             where (p_request_id is null or request_id = p_request_id)
               and (p_status is null or status = p_status)
             order by created_at desc offset l_offset rows fetch next l_limit rows only
        );
        return erp_api_util_pkg.success(l_json);
    end;

    function log_detail(p_log_id number) return clob is
    begin erp_principal_pkg.assert_role('SUPPORT_ADMIN'); return erp_api_util_pkg.success(log_json(p_log_id));
    exception when no_data_found then return erp_api_util_pkg.failure('INTEGRATION_LOG_NOT_FOUND', 'Integration log was not found.');
    end;

    function support_dashboard return clob is
        l_json clob;
    begin
        erp_principal_pkg.assert_role('SUPPORT_ADMIN');
        select json_object(
            'total' value count(*),
            'failed' value count(case when status = 'FAILED' then 1 end),
            'retryEligible' value count(case when retry_eligible_flag = 1 then 1 end),
            'successful' value count(case when status = 'SUCCESS' then 1 end)
            returning clob
        ) into l_json from integration_log;
        return erp_api_util_pkg.success(l_json);
    end;

    function trigger_reference_sync return clob is
        l_data json_object_t := json_object_t();
    begin
        erp_principal_pkg.assert_role('SUPPORT_ADMIN');
        l_data.put('oicInstanceId', 'OIC-MOCK-SYNC-' || to_char(systimestamp, 'YYYYMMDDHH24MISSFF3'));
        l_data.put('status', 'ACCEPTED');
        l_data.put('monitoringLocation', 'mock://oic/monitoring/supplier-reference-sync');
        return erp_api_util_pkg.success(l_data.to_clob());
    end;

    procedure upsert_supplier(p_fusion_supplier_id varchar2, p_body clob, o_status out number, o_body out clob) is
        l_payload json_object_t := erp_input_pkg.parse_object(p_body);
        l_id number;
        l_supplier_number varchar2(80);
        l_supplier_name varchar2(200);
        l_normalized_name varchar2(200);
        l_country_code varchar2(2);
        l_tax_number varchar2(80);
        l_email_domain varchar2(253);
        l_phone_value varchar2(40);
        l_normalized_address varchar2(500);
        l_bank_hash varchar2(128);
    begin
        erp_principal_pkg.assert_role('SYSTEM_OIC');
        erp_input_pkg.assert_no_raw_bank(p_body);
        erp_input_pkg.assert_allowed_keys(l_payload, 'supplierNumber,supplierName,countryCode,taxRegistrationNumber,emailDomain,phoneNormalized,addressNormalized,bankAccountHash');
        l_supplier_number := erp_input_pkg.optional_string(l_payload, 'supplierNumber', 80);
        l_supplier_name := erp_input_pkg.optional_string(l_payload, 'supplierName', 200);
        l_normalized_name := erp_input_pkg.normalized_text(l_supplier_name);
        l_country_code := upper(erp_input_pkg.optional_string(l_payload, 'countryCode', 2));
        l_tax_number := erp_input_pkg.optional_string(l_payload, 'taxRegistrationNumber', 80);
        l_email_domain := lower(erp_input_pkg.optional_string(l_payload, 'emailDomain', 253));
        l_phone_value := erp_input_pkg.optional_string(l_payload, 'phoneNormalized', 40);
        l_normalized_address := erp_input_pkg.normalized_text(erp_input_pkg.optional_string(l_payload, 'addressNormalized', 500));
        l_bank_hash := erp_input_pkg.optional_string(l_payload, 'bankAccountHash', 128);
        merge into existing_supplier_ref t using (
            select p_fusion_supplier_id fusion_id,
                   l_supplier_number supplier_number,
                   l_supplier_name supplier_name,
                   l_normalized_name normalized_name,
                   l_country_code country_code,
                   l_tax_number tax_number,
                   l_email_domain email_domain,
                   l_phone_value phone_value,
                   l_normalized_address address_value,
                   l_bank_hash bank_hash from dual
        ) s on (t.fusion_supplier_id = s.fusion_id)
        when matched then update set t.supplier_number = s.supplier_number, t.supplier_name = s.supplier_name,
            t.normalized_name = s.normalized_name, t.country_code = s.country_code,
            t.tax_registration_number = s.tax_number, t.email_domain = s.email_domain,
            t.phone_normalized = s.phone_value, t.address_normalized = s.address_value,
            t.bank_account_hash = s.bank_hash, t.last_sync_at = systimestamp
        when not matched then insert (fusion_supplier_id, supplier_number, supplier_name, normalized_name,
            country_code, tax_registration_number, email_domain, phone_normalized, address_normalized,
            bank_account_hash, last_sync_at) values (s.fusion_id, s.supplier_number, s.supplier_name,
            s.normalized_name, s.country_code, s.tax_number, s.email_domain,
            s.phone_value, s.address_value, s.bank_hash, systimestamp);
        select supplier_ref_id into l_id from existing_supplier_ref where fusion_supplier_id = p_fusion_supplier_id;
        commit; o_status := 200; o_body := erp_api_util_pkg.success('{"supplierRefId":' || l_id || '}');
    exception when others then rollback; o_status := 400; o_body := erp_api_util_pkg.failure('REFERENCE_UPSERT_FAILED', 'Supplier reference could not be stored.');
    end;

    procedure upsert_supplier_site(p_fusion_supplier_id varchar2, p_fusion_site_id varchar2, p_body clob, o_status out number, o_body out clob) is
        l_payload json_object_t := erp_input_pkg.parse_object(p_body);
        l_supplier_id number;
        l_site_id number;
        l_site_name varchar2(120);
        l_country_code varchar2(2);
        l_address_normalized varchar2(500);
        l_business_unit_code varchar2(30);
    begin
        erp_principal_pkg.assert_role('SYSTEM_OIC');
        erp_input_pkg.assert_allowed_keys(l_payload, 'siteName,countryCode,addressNormalized,businessUnitCode');
        l_site_name := erp_input_pkg.optional_string(l_payload, 'siteName', 120);
        l_country_code := upper(erp_input_pkg.optional_string(l_payload, 'countryCode', 2));
        l_address_normalized := erp_input_pkg.normalized_text(erp_input_pkg.optional_string(l_payload, 'addressNormalized', 500));
        l_business_unit_code := upper(erp_input_pkg.optional_string(l_payload, 'businessUnitCode', 30));
        select supplier_ref_id into l_supplier_id from existing_supplier_ref where fusion_supplier_id = p_fusion_supplier_id;
        merge into existing_supplier_site_ref t using (select p_fusion_site_id site_id from dual) s
        on (t.fusion_site_id = s.site_id)
        when matched then update set t.supplier_ref_id = l_supplier_id,
            t.site_name = l_site_name,
            t.country_code = l_country_code,
            t.address_normalized = l_address_normalized,
            t.business_unit_code = l_business_unit_code
        when not matched then insert (supplier_ref_id, fusion_site_id, site_name, country_code, address_normalized, business_unit_code)
        values (l_supplier_id, s.site_id, l_site_name, l_country_code,
            l_address_normalized, l_business_unit_code);
        select site_ref_id into l_site_id from existing_supplier_site_ref where fusion_site_id = p_fusion_site_id;
        commit; o_status := 200; o_body := erp_api_util_pkg.success('{"siteRefId":' || l_site_id || '}');
    exception when no_data_found then rollback; o_status := 404; o_body := erp_api_util_pkg.failure('SUPPLIER_REFERENCE_NOT_FOUND', 'Supplier reference was not found.');
    end;

    procedure record_integration_result(p_request_id number, p_body clob, o_status out number, o_body out clob) is
        l_payload json_object_t := erp_input_pkg.parse_object(p_body);
        l_status varchar2(30);
        l_log_id number;
        l_supplier_number varchar2(80);
        l_oic_instance_id varchar2(100);
        l_error_category varchar2(40);
        l_payload_ref varchar2(500);
        l_response_ref varchar2(500);
        l_user_message varchar2(2000);
        l_technical_message varchar2(2000);
        l_retry_eligible number := 0;
        l_fusion_supplier_id varchar2(80);
    begin
        erp_principal_pkg.assert_role('SYSTEM_OIC');
        erp_input_pkg.assert_allowed_keys(l_payload, 'oicInstanceId,status,errorCategory,payloadRef,responseRef,userMessage,technicalMessage,retryEligible,fusionSupplierId,fusionSupplierNumber');
        l_status := upper(erp_input_pkg.optional_string(l_payload, 'status', 30));
        l_supplier_number := erp_input_pkg.optional_string(l_payload, 'fusionSupplierNumber', 80);
        l_oic_instance_id := erp_input_pkg.optional_string(l_payload, 'oicInstanceId', 100);
        l_error_category := erp_input_pkg.optional_string(l_payload, 'errorCategory', 40);
        l_payload_ref := erp_input_pkg.optional_string(l_payload, 'payloadRef', 500);
        l_response_ref := erp_input_pkg.optional_string(l_payload, 'responseRef', 500);
        l_user_message := erp_input_pkg.optional_string(l_payload, 'userMessage', 2000);
        l_technical_message := erp_input_pkg.optional_string(l_payload, 'technicalMessage', 2000);
        if l_payload.has('retryEligible') and l_payload.get_boolean('retryEligible') then l_retry_eligible := 1; end if;
        l_fusion_supplier_id := erp_input_pkg.optional_string(l_payload, 'fusionSupplierId', 80);
        insert into integration_log (request_id, integration_name, oic_instance_id, direction, status,
            error_category, payload_ref, response_ref, user_message, technical_message,
            retry_count, retry_eligible_flag, retry_history_json, created_at)
        values (p_request_id, 'SUPPLIER_CREATE', l_oic_instance_id,
            'INBOUND', l_status, l_error_category,
            l_payload_ref, l_response_ref,
            l_user_message, l_technical_message,
            0, l_retry_eligible, '[]', systimestamp)
        returning log_id into l_log_id;
        if l_status = 'SUCCESS' then
            update supplier_request set status = 'Created in Fusion', fusion_supplier_id = l_fusion_supplier_id,
                fusion_supplier_number = l_supplier_number, fusion_created_at = systimestamp,
                fusion_response_ref = l_response_ref, last_updated_at = systimestamp
             where request_id = p_request_id;
        else
            update supplier_request set status = 'Integration Failed', last_updated_at = systimestamp where request_id = p_request_id;
        end if;
        commit; o_status := 200; o_body := erp_api_util_pkg.success(log_json(l_log_id));
    exception when others then rollback; o_status := 400; o_body := erp_api_util_pkg.failure('INTEGRATION_RESULT_REJECTED', 'Integration result could not be recorded.');
    end;
end erp_integration_pkg;
/
