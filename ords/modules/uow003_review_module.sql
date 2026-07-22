begin
    ords.define_template('supplier.onboarding.v1', 'requests/:requestId/approve');
    ords.define_handler('supplier.onboarding.v1', 'requests/:requestId/approve', 'POST', ords.source_type_plsql,
        q'~declare l_status number; l_body clob; begin :content_type := 'application/json'; if erp_api_util_pkg.authorize('REVIEWER') = 0 then :status_code := 403; else erp_review_pkg.approve(:requestId, :body_text, l_status, l_body); :status_code := l_status; erp_api_util_pkg.emit(l_body); end if; end;~');
    ords.define_template('supplier.onboarding.v1', 'requests/:requestId/reject');
    ords.define_handler('supplier.onboarding.v1', 'requests/:requestId/reject', 'POST', ords.source_type_plsql,
        q'~declare l_status number; l_body clob; begin :content_type := 'application/json'; if erp_api_util_pkg.authorize('REVIEWER') = 0 then :status_code := 403; else erp_review_pkg.reject(:requestId, :body_text, l_status, l_body); :status_code := l_status; erp_api_util_pkg.emit(l_body); end if; end;~');
    ords.define_template('supplier.onboarding.v1', 'requests/:requestId/request-correction');
    ords.define_handler('supplier.onboarding.v1', 'requests/:requestId/request-correction', 'POST', ords.source_type_plsql,
        q'~declare l_status number; l_body clob; begin :content_type := 'application/json'; if erp_api_util_pkg.authorize('REVIEWER') = 0 then :status_code := 403; else erp_review_pkg.request_correction(:requestId, :body_text, l_status, l_body); :status_code := l_status; erp_api_util_pkg.emit(l_body); end if; end;~');
    ords.define_template('supplier.onboarding.v1', 'requests/:requestId/mark-duplicate');
    ords.define_handler('supplier.onboarding.v1', 'requests/:requestId/mark-duplicate', 'POST', ords.source_type_plsql,
        q'~declare l_status number; l_body clob; begin :content_type := 'application/json'; if erp_api_util_pkg.authorize('REVIEWER') = 0 then :status_code := 403; else erp_review_pkg.mark_duplicate(:requestId, :body_text, l_status, l_body); :status_code := l_status; erp_api_util_pkg.emit(l_body); end if; end;~');
    ords.define_template('supplier.onboarding.v1', 'dashboard/reviewer-summary');
    ords.define_handler('supplier.onboarding.v1', 'dashboard/reviewer-summary', 'GET', ords.source_type_plsql,
        q'~begin :content_type := 'application/json'; if erp_api_util_pkg.authorize('REVIEWER') = 0 then :status_code := 403; else :status_code := 200; erp_api_util_pkg.emit(erp_review_pkg.reviewer_dashboard()); end if; end;~');
    commit;
end;
/
