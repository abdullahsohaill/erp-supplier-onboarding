begin
    ords.define_template('supplier.onboarding.v1', 'requests/:requestId/validate');
    ords.define_handler('supplier.onboarding.v1', 'requests/:requestId/validate', 'POST', ords.source_type_plsql,
        q'~declare l_status number; l_body clob; begin :content_type := 'application/json'; if erp_api_util_pkg.authorize('REVIEWER,SUPPORT_ADMIN,SYSTEM_OIC') = 0 then :status_code := 403; else erp_analysis_pkg.run_validation(:requestId, l_status, l_body); :status_code := l_status; erp_api_util_pkg.emit(l_body); end if; end;~');
    ords.define_template('supplier.onboarding.v1', 'requests/:requestId/duplicate-check');
    ords.define_handler('supplier.onboarding.v1', 'requests/:requestId/duplicate-check', 'POST', ords.source_type_plsql,
        q'~declare l_status number; l_body clob; begin :content_type := 'application/json'; if erp_api_util_pkg.authorize('REVIEWER,SUPPORT_ADMIN,SYSTEM_OIC') = 0 then :status_code := 403; else erp_analysis_pkg.run_duplicate_check(:requestId, l_status, l_body); :status_code := l_status; erp_api_util_pkg.emit(l_body); end if; end;~');
    ords.define_template('supplier.onboarding.v1', 'requests/:requestId/duplicate-matches');
    ords.define_handler('supplier.onboarding.v1', 'requests/:requestId/duplicate-matches', 'GET', ords.source_type_plsql,
        q'~begin :content_type := 'application/json'; if erp_api_util_pkg.authorize('REVIEWER,SUPPORT_ADMIN') = 0 then :status_code := 403; else :status_code := 200; erp_api_util_pkg.emit(erp_analysis_pkg.duplicate_matches(:requestId)); end if; end;~');
    ords.define_template('supplier.onboarding.v1', 'requests/:requestId/risk-score');
    ords.define_handler('supplier.onboarding.v1', 'requests/:requestId/risk-score', 'POST', ords.source_type_plsql,
        q'~declare l_status number; l_body clob; begin :content_type := 'application/json'; if erp_api_util_pkg.authorize('REVIEWER,SUPPORT_ADMIN,SYSTEM_OIC') = 0 then :status_code := 403; else erp_analysis_pkg.run_risk_score(:requestId, l_status, l_body); :status_code := l_status; erp_api_util_pkg.emit(l_body); end if; end;~');
    ords.define_template('supplier.onboarding.v1', 'requests/:requestId/risk-assessment');
    ords.define_handler('supplier.onboarding.v1', 'requests/:requestId/risk-assessment', 'GET', ords.source_type_plsql,
        q'~begin :content_type := 'application/json'; if erp_api_util_pkg.authorize('REVIEWER,SUPPORT_ADMIN') = 0 then :status_code := 403; else :status_code := 200; erp_api_util_pkg.emit(erp_analysis_pkg.risk_assessment(:requestId)); end if; end;~');
    ords.define_template('supplier.onboarding.v1', 'requests/:requestId/ai-summary');
    ords.define_handler('supplier.onboarding.v1', 'requests/:requestId/ai-summary', 'POST', ords.source_type_plsql,
        q'~declare l_status number; l_body clob; begin :content_type := 'application/json'; if erp_api_util_pkg.authorize('REVIEWER,SUPPORT_ADMIN') = 0 then :status_code := 403; else erp_analysis_pkg.generate_ai_summary(:requestId, l_status, l_body); :status_code := l_status; erp_api_util_pkg.emit(l_body); end if; end;~');
    ords.define_template('supplier.onboarding.v1', 'requests/:requestId/ai-summaries');
    ords.define_handler('supplier.onboarding.v1', 'requests/:requestId/ai-summaries', 'GET', ords.source_type_plsql,
        q'~begin :content_type := 'application/json'; if erp_api_util_pkg.authorize('REVIEWER,SUPPORT_ADMIN') = 0 then :status_code := 403; else :status_code := 200; erp_api_util_pkg.emit(erp_analysis_pkg.ai_summaries(:requestId)); end if; end;~');
    commit;
end;
/
