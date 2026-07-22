begin
    ords.enable_schema(
        p_enabled => true,
        p_schema => 'ERP_APP',
        p_url_mapping_type => 'BASE_PATH',
        p_url_mapping_pattern => 'erp',
        p_auto_rest_auth => true
    );
    ords.define_module(
        p_module_name => 'supplier.onboarding.v1',
        p_base_path => 'supplier-onboarding/v1/',
        p_items_per_page => 25,
        p_status => 'PUBLISHED',
        p_comments => 'Versioned Supplier Onboarding API'
    );

    ords.define_template('supplier.onboarding.v1', 'requests');
    ords.define_handler('supplier.onboarding.v1', 'requests', 'POST', ords.source_type_plsql,
        q'~declare l_status number; l_body clob; begin erp_request_workflow_pkg.create_request(:body_text, l_status, l_body); :status_code := l_status; :content_type := 'application/json'; erp_api_util_pkg.emit(l_body); end;~');
    ords.define_handler('supplier.onboarding.v1', 'requests', 'GET', ords.source_type_plsql,
        q'~begin :status_code := 200; :content_type := 'application/json'; erp_api_util_pkg.emit(erp_api_dispatch_pkg.list_requests(:status, :limit, :offset)); end;~');

    ords.define_template('supplier.onboarding.v1', 'requests/:requestId');
    ords.define_handler('supplier.onboarding.v1', 'requests/:requestId', 'GET', ords.source_type_plsql,
        q'~begin :status_code := 200; :content_type := 'application/json'; erp_api_util_pkg.emit(erp_api_dispatch_pkg.request_detail(:requestId)); end;~');
    ords.define_handler('supplier.onboarding.v1', 'requests/:requestId', 'PATCH', ords.source_type_plsql,
        q'~declare l_status number; l_body clob; begin erp_request_workflow_pkg.update_request(:requestId, :body_text, l_status, l_body); :status_code := l_status; :content_type := 'application/json'; erp_api_util_pkg.emit(l_body); end;~');

    ords.define_template('supplier.onboarding.v1', 'requests/:requestId/submit');
    ords.define_handler('supplier.onboarding.v1', 'requests/:requestId/submit', 'POST', ords.source_type_plsql,
        q'~declare l_status number; l_body clob; begin erp_request_workflow_pkg.submit_request(:requestId, l_status, l_body); :status_code := l_status; :content_type := 'application/json'; erp_api_util_pkg.emit(l_body); end;~');

    ords.define_template('supplier.onboarding.v1', 'requests/:requestId/validation-results');
    ords.define_handler('supplier.onboarding.v1', 'requests/:requestId/validation-results', 'GET', ords.source_type_plsql,
        q'~begin :status_code := 200; :content_type := 'application/json'; erp_api_util_pkg.emit(erp_api_dispatch_pkg.validation_results(:requestId)); end;~');

    ords.define_template('supplier.onboarding.v1', 'requests/:requestId/attachments');
    ords.define_handler('supplier.onboarding.v1', 'requests/:requestId/attachments', 'GET', ords.source_type_plsql,
        q'~begin :status_code := 200; :content_type := 'application/json'; erp_api_util_pkg.emit(erp_api_dispatch_pkg.attachments(:requestId)); end;~');

    ords.define_template('supplier.onboarding.v1', 'requests/:requestId/attachment-metadata');
    ords.define_handler('supplier.onboarding.v1', 'requests/:requestId/attachment-metadata', 'POST', ords.source_type_plsql,
        q'~declare l_status number; l_body clob; begin erp_request_workflow_pkg.maintain_attachment(:requestId, :body_text, l_status, l_body); :status_code := l_status; :content_type := 'application/json'; erp_api_util_pkg.emit(l_body); end;~');

    ords.define_template('supplier.onboarding.v1', 'dashboard/requester-summary');
    ords.define_handler('supplier.onboarding.v1', 'dashboard/requester-summary', 'GET', ords.source_type_plsql,
        q'~begin :status_code := 200; :content_type := 'application/json'; erp_api_util_pkg.emit(erp_request_query_pkg.requester_dashboard()); end;~');

    ords.define_template('supplier.onboarding.v1', 'reference/business-units');
    ords.define_handler('supplier.onboarding.v1', 'reference/business-units', 'GET', ords.source_type_plsql,
        q'~begin :status_code := 200; :content_type := 'application/json'; erp_api_util_pkg.emit(erp_request_query_pkg.business_units()); end;~');

    ords.define_template('supplier.onboarding.v1', 'reference/supplier-types');
    ords.define_handler('supplier.onboarding.v1', 'reference/supplier-types', 'GET', ords.source_type_plsql,
        q'~begin :status_code := 200; :content_type := 'application/json'; erp_api_util_pkg.emit(erp_request_query_pkg.supplier_types()); end;~');
    commit;
end;
/
