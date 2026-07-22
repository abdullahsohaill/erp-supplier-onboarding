create or replace package body erp_analysis_pkg as
    procedure run_all(p_request_id number, p_view varchar2, o_status out number, o_body out clob) is
        l_run_id varchar2(64);
        l_blockers number;
        l_data json_object_t := json_object_t();
    begin
        erp_principal_pkg.assert_role('REVIEWER,SUPPORT_ADMIN,SYSTEM_OIC');
        erp_gov_check_port_pkg.run_checks(p_request_id, erp_principal_pkg.subject(), l_run_id, l_blockers);
        commit;
        l_data.put('requestId', p_request_id);
        l_data.put('runId', l_run_id);
        l_data.put('blockingCount', l_blockers);
        if p_view = 'VALIDATION' then
            l_data.put('validationResults', json_element_t.parse(erp_request_projection_pkg.validation_json(p_request_id)));
        elsif p_view = 'DUPLICATE' then
            l_data.put('duplicateMatches', json_element_t.parse(erp_gov_check_port_pkg.duplicate_json(p_request_id)));
        elsif p_view = 'RISK' then
            l_data.put('riskAssessment', json_element_t.parse(erp_gov_check_port_pkg.risk_json(p_request_id)));
        else
            l_data.put('aiSummaries', json_element_t.parse(erp_gov_check_port_pkg.ai_json(p_request_id)));
        end if;
        o_status := 200;
        o_body := erp_api_util_pkg.success(l_data.to_clob());
    exception
        when no_data_found then
            rollback; o_status := 404;
            o_body := erp_api_util_pkg.failure('REQUEST_NOT_FOUND', 'Request was not found.');
        when others then
            rollback; o_status := 500;
            o_body := erp_api_util_pkg.failure('INTERNAL_ERROR', 'Governed analysis could not be completed.');
    end;

    procedure run_validation(p_request_id number, o_status out number, o_body out clob) is
    begin run_all(p_request_id, 'VALIDATION', o_status, o_body); end;

    procedure run_duplicate_check(p_request_id number, o_status out number, o_body out clob) is
    begin run_all(p_request_id, 'DUPLICATE', o_status, o_body); end;

    procedure run_risk_score(p_request_id number, o_status out number, o_body out clob) is
    begin run_all(p_request_id, 'RISK', o_status, o_body); end;

    procedure generate_ai_summary(p_request_id number, o_status out number, o_body out clob) is
    begin run_all(p_request_id, 'AI', o_status, o_body); end;

    function duplicate_matches(p_request_id number) return clob is
    begin erp_principal_pkg.assert_role('REVIEWER,SUPPORT_ADMIN'); return erp_api_util_pkg.success(erp_gov_check_port_pkg.duplicate_json(p_request_id)); end;

    function risk_assessment(p_request_id number) return clob is
    begin erp_principal_pkg.assert_role('REVIEWER,SUPPORT_ADMIN'); return erp_api_util_pkg.success(erp_gov_check_port_pkg.risk_json(p_request_id)); end;

    function ai_summaries(p_request_id number) return clob is
    begin erp_principal_pkg.assert_role('REVIEWER,SUPPORT_ADMIN'); return erp_api_util_pkg.success(erp_gov_check_port_pkg.ai_json(p_request_id)); end;
end erp_analysis_pkg;
/
