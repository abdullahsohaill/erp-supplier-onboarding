create or replace package body erp_request_projection_pkg as
    function validation_json(p_request_id number) return clob is
        l_json clob;
    begin
        select coalesce(
            json_arrayagg(
                json_object(
                    'ruleCode' value vr.rule_code,
                    'fieldName' value v.field_name,
                    'severity' value v.severity,
                    'message' value v.message,
                    'blocking' value case v.is_blocking when 1 then 'true' else 'false' end format json,
                    'createdAt' value to_char(v.created_at, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZH:TZM')
                ) returning clob
            ),
            to_clob('[]')
        ) into l_json
          from validation_result v
          join validation_rules vr on vr.validation_rule_id = v.validation_rule_id
         where v.request_id = p_request_id and v.is_current = 1;
        return l_json;
    end;

    function attachments_json(p_request_id number) return clob is
        l_json clob;
    begin
        select coalesce(
            json_arrayagg(
                json_object(
                    'documentId' value document_id,
                    'documentType' value document_type,
                    'documentStatus' value document_status,
                    'required' value case is_required when 1 then 'true' else 'false' end format json,
                    'missing' value case missing_flag when 1 then 'true' else 'false' end format json,
                    'metadata' value metadata_json format json
                ) returning clob
            ),
            to_clob('[]')
        ) into l_json
          from supplier_request_document
         where request_id = p_request_id;
        return l_json;
    end;

    function request_json(p_request_id number, p_requester_safe boolean default true) return clob is
        l_data json_object_t := json_object_t();
        l_sites clob;
        l_contacts clob;
        l_timeline clob;
        l_request supplier_request%rowtype;
        l_risk clob;
        l_duplicates clob;
    begin
        select * into l_request from supplier_request where request_id = p_request_id;
        l_data.put('requestId', l_request.request_id);
        l_data.put('requestNumber', l_request.request_number);
        l_data.put('status', l_request.status);
        l_data.put('supplierName', l_request.supplier_name);
        l_data.put('supplierTypeCode', l_request.supplier_type_code);
        l_data.put('countryCode', l_request.country_code);
        l_data.put('businessUnitId', l_request.business_unit_id);
        l_data.put('businessJustification', l_request.business_justification);
        l_data.put('productServiceCategory', l_request.product_service_category);
        l_data.put('expectedAnnualSpend', l_request.expected_annual_spend);
        l_data.put('taxRegistrationNumber', l_request.tax_registration_number);
        l_data.put('fusionSupplierNumber', l_request.fusion_supplier_number);

        select coalesce(json_arrayagg(json_object(
            'siteId' value site_id, 'siteName' value site_name, 'countryCode' value country_code,
            'addressLine1' value address_line1, 'addressLine2' value address_line2,
            'city' value city, 'region' value region, 'postalCode' value postal_code,
            'intendedBusinessUnitId' value intended_business_unit_id,
            'primary' value case is_primary when 1 then 'true' else 'false' end format json
        ) returning clob), to_clob('[]')) into l_sites
          from supplier_request_site where request_id = p_request_id;
        l_data.put('sites', json_element_t.parse(l_sites));

        select coalesce(json_arrayagg(json_object(
            'contactId' value contact_id, 'contactName' value contact_name,
            'contactEmail' value contact_email, 'phoneNumber' value phone_number
        ) returning clob), to_clob('[]')) into l_contacts
          from supplier_request_contact where request_id = p_request_id;
        l_data.put('contacts', json_element_t.parse(l_contacts));
        l_data.put('validationResults', json_element_t.parse(validation_json(p_request_id)));
        l_data.put('attachments', json_element_t.parse(attachments_json(p_request_id)));

        select coalesce(json_arrayagg(json_object(
            'fromStatus' value from_status, 'toStatus' value to_status,
            'actionCode' value action_code, 'actor' value actor_user,
            'comment' value action_comment,
            'timestamp' value to_char(action_timestamp, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZH:TZM')
        ) order by action_timestamp returning clob), to_clob('[]')) into l_timeline
          from status_history where request_id = p_request_id;
        l_data.put('timeline', json_element_t.parse(l_timeline));

        if not p_requester_safe then
            select coalesce(json_arrayagg(json_object(
                'matchId' value match_id, 'candidateSource' value candidate_source,
                'candidateSupplierNumber' value candidate_supplier_number,
                'candidateSupplierName' value candidate_supplier_name,
                'matchScore' value match_score, 'matchLevel' value match_level,
                'matchedFields' value matched_fields_json format json,
                'explanation' value explanation
            ) returning clob), to_clob('[]')) into l_duplicates
              from duplicate_match where request_id = p_request_id and is_current = 1;
            l_data.put('duplicateMatches', json_element_t.parse(l_duplicates));
            begin
                select json_object(
                    'riskScore' value risk_score, 'riskLevel' value risk_level,
                    'scoringVersion' value scoring_version,
                    'reasons' value risk_reasons_json format json returning clob
                ) into l_risk from risk_assessment
                 where request_id = p_request_id and is_current = 1
                 order by created_at desc fetch first 1 row only;
                l_data.put('riskAssessment', json_element_t.parse(l_risk));
            exception when no_data_found then null;
            end;
        end if;
        return l_data.to_clob();
    exception when no_data_found then
        raise_application_error(-20003, 'REQUEST_NOT_FOUND');
    end;
end erp_request_projection_pkg;
/
