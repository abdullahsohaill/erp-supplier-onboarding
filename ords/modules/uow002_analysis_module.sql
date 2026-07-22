begin
    ords.define_template('supplier.onboarding.v1', 'requests/:requestId/validate');
    ords.define_handler('supplier.onboarding.v1', 'requests/:requestId/validate', 'POST', ords.source_type_plsql,
        q'~declare l_status number; l_body clob; begin erp_analysis_pkg.run_validation(:requestId, l_status, l_body); :status_code := l_status; :content_type := 'application/json'; erp_api_util_pkg.emit(l_body); end;~');
    ords.define_template('supplier.onboarding.v1', 'requests/:requestId/duplicate-check');
    ords.define_handler('supplier.onboarding.v1', 'requests/:requestId/duplicate-check', 'POST', ords.source_type_plsql,
        q'~declare l_status number; l_body clob; begin erp_analysis_pkg.run_duplicate_check(:requestId, l_status, l_body); :status_code := l_status; :content_type := 'application/json'; erp_api_util_pkg.emit(l_body); end;~');
    ords.define_template('supplier.onboarding.v1', 'requests/:requestId/duplicate-matches');
    ords.define_handler('supplier.onboarding.v1', 'requests/:requestId/duplicate-matches', 'GET', ords.source_type_plsql,
        q'~begin :status_code := 200; :content_type := 'application/json'; erp_api_util_pkg.emit(erp_analysis_pkg.duplicate_matches(:requestId)); end;~');
    ords.define_template('supplier.onboarding.v1', 'requests/:requestId/risk-score');
    ords.define_handler('supplier.onboarding.v1', 'requests/:requestId/risk-score', 'POST', ords.source_type_plsql,
        q'~declare l_status number; l_body clob; begin erp_analysis_pkg.run_risk_score(:requestId, l_status, l_body); :status_code := l_status; :content_type := 'application/json'; erp_api_util_pkg.emit(l_body); end;~');
    ords.define_template('supplier.onboarding.v1', 'requests/:requestId/risk-assessment');
    ords.define_handler('supplier.onboarding.v1', 'requests/:requestId/risk-assessment', 'GET', ords.source_type_plsql,
        q'~begin :status_code := 200; :content_type := 'application/json'; erp_api_util_pkg.emit(erp_analysis_pkg.risk_assessment(:requestId)); end;~');
    ords.define_template('supplier.onboarding.v1', 'requests/:requestId/ai-summary');
    ords.define_handler('supplier.onboarding.v1', 'requests/:requestId/ai-summary', 'POST', ords.source_type_plsql,
        q'~declare l_status number; l_body clob; begin erp_analysis_pkg.generate_ai_summary(:requestId, l_status, l_body); :status_code := l_status; :content_type := 'application/json'; erp_api_util_pkg.emit(l_body); end;~');
    ords.define_template('supplier.onboarding.v1', 'requests/:requestId/ai-summaries');
    ords.define_handler('supplier.onboarding.v1', 'requests/:requestId/ai-summaries', 'GET', ords.source_type_plsql,
        q'~begin :status_code := 200; :content_type := 'application/json'; erp_api_util_pkg.emit(erp_analysis_pkg.ai_summaries(:requestId)); end;~');
    commit;
end;
/
