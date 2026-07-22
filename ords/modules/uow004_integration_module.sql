begin
    ords.define_template('supplier.onboarding.v1', 'requests/:requestId/submit-to-fusion');
    ords.define_handler('supplier.onboarding.v1', 'requests/:requestId/submit-to-fusion', 'POST', ords.source_type_plsql,
        q'~declare l_status number; l_body clob; begin erp_integration_pkg.submit_to_fusion(:requestId, l_status, l_body); :status_code := l_status; :content_type := 'application/json'; erp_api_util_pkg.emit(l_body); end;~');
    ords.define_template('supplier.onboarding.v1', 'integration-logs/:logId/retry');
    ords.define_handler('supplier.onboarding.v1', 'integration-logs/:logId/retry', 'POST', ords.source_type_plsql,
        q'~declare l_status number; l_body clob; begin erp_integration_pkg.retry_log(:logId, l_status, l_body); :status_code := l_status; :content_type := 'application/json'; erp_api_util_pkg.emit(l_body); end;~');
    ords.define_template('supplier.onboarding.v1', 'dashboard/support-summary');
    ords.define_handler('supplier.onboarding.v1', 'dashboard/support-summary', 'GET', ords.source_type_plsql,
        q'~begin :status_code := 200; :content_type := 'application/json'; erp_api_util_pkg.emit(erp_integration_pkg.support_dashboard()); end;~');
    ords.define_template('supplier.onboarding.v1', 'integration-logs');
    ords.define_handler('supplier.onboarding.v1', 'integration-logs', 'GET', ords.source_type_plsql,
        q'~begin :status_code := 200; :content_type := 'application/json'; erp_api_util_pkg.emit(erp_integration_pkg.list_logs(:requestId, :status, :limit, :offset)); end;~');
    ords.define_template('supplier.onboarding.v1', 'integration-logs/:logId');
    ords.define_handler('supplier.onboarding.v1', 'integration-logs/:logId', 'GET', ords.source_type_plsql,
        q'~begin :status_code := 200; :content_type := 'application/json'; erp_api_util_pkg.emit(erp_integration_pkg.log_detail(:logId)); end;~');
    ords.define_template('supplier.onboarding.v1', 'admin-settings/supplier-reference-sync');
    ords.define_handler('supplier.onboarding.v1', 'admin-settings/supplier-reference-sync', 'POST', ords.source_type_plsql,
        q'~begin :status_code := 202; :content_type := 'application/json'; erp_api_util_pkg.emit(erp_integration_pkg.trigger_reference_sync()); end;~');
    ords.define_template('supplier.onboarding.v1', 'internal/supplier-references/:fusionSupplierId');
    ords.define_handler('supplier.onboarding.v1', 'internal/supplier-references/:fusionSupplierId', 'PUT', ords.source_type_plsql,
        q'~declare l_status number; l_body clob; begin erp_integration_pkg.upsert_supplier(:fusionSupplierId, :body_text, l_status, l_body); :status_code := l_status; :content_type := 'application/json'; erp_api_util_pkg.emit(l_body); end;~');
    ords.define_template('supplier.onboarding.v1', 'internal/supplier-references/:fusionSupplierId/sites/:fusionSiteId');
    ords.define_handler('supplier.onboarding.v1', 'internal/supplier-references/:fusionSupplierId/sites/:fusionSiteId', 'PUT', ords.source_type_plsql,
        q'~declare l_status number; l_body clob; begin erp_integration_pkg.upsert_supplier_site(:fusionSupplierId, :fusionSiteId, :body_text, l_status, l_body); :status_code := l_status; :content_type := 'application/json'; erp_api_util_pkg.emit(l_body); end;~');
    ords.define_template('supplier.onboarding.v1', 'internal/requests/:requestId/integration-results');
    ords.define_handler('supplier.onboarding.v1', 'internal/requests/:requestId/integration-results', 'POST', ords.source_type_plsql,
        q'~declare l_status number; l_body clob; begin erp_integration_pkg.record_integration_result(:requestId, :body_text, l_status, l_body); :status_code := l_status; :content_type := 'application/json'; erp_api_util_pkg.emit(l_body); end;~');
    commit;
end;
/
