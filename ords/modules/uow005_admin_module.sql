begin
    ords.define_template('supplier.onboarding.v1', 'admin-settings/high-risk-countries');
    ords.define_handler('supplier.onboarding.v1', 'admin-settings/high-risk-countries', 'GET', ords.source_type_plsql,
        q'~begin :status_code := 200; :content_type := 'application/json'; erp_api_util_pkg.emit(erp_admin_pkg.high_risk_countries()); end;~');
    ords.define_template('supplier.onboarding.v1', 'admin-settings/high-risk-countries/:countryCode/periods/:effectiveFrom');
    ords.define_handler('supplier.onboarding.v1', 'admin-settings/high-risk-countries/:countryCode/periods/:effectiveFrom', 'PUT', ords.source_type_plsql,
        q'~declare l_status number; l_body clob; begin erp_admin_pkg.put_high_risk_country(:countryCode, :effectiveFrom, :body_text, l_status, l_body); :status_code := l_status; :content_type := 'application/json'; erp_api_util_pkg.emit(l_body); end;~');
    ords.define_template('supplier.onboarding.v1', 'admin-settings/validation-rules');
    ords.define_handler('supplier.onboarding.v1', 'admin-settings/validation-rules', 'GET', ords.source_type_plsql,
        q'~begin :status_code := 200; :content_type := 'application/json'; erp_api_util_pkg.emit(erp_admin_pkg.validation_rules()); end;~');
    ords.define_template('supplier.onboarding.v1', 'admin-settings/validation-rules/:ruleCode');
    ords.define_handler('supplier.onboarding.v1', 'admin-settings/validation-rules/:ruleCode', 'PUT', ords.source_type_plsql,
        q'~declare l_status number; l_body clob; begin erp_admin_pkg.put_validation_rule(:ruleCode, :body_text, l_status, l_body); :status_code := l_status; :content_type := 'application/json'; erp_api_util_pkg.emit(l_body); end;~');
    ords.define_template('supplier.onboarding.v1', 'admin-settings/scoring-rules');
    ords.define_handler('supplier.onboarding.v1', 'admin-settings/scoring-rules', 'GET', ords.source_type_plsql,
        q'~begin :status_code := 200; :content_type := 'application/json'; erp_api_util_pkg.emit(erp_admin_pkg.scoring_rules(:ruleType)); end;~');
    ords.define_template('supplier.onboarding.v1', 'admin-settings/scoring-rules/:ruleType/:ruleCode/versions/:version');
    ords.define_handler('supplier.onboarding.v1', 'admin-settings/scoring-rules/:ruleType/:ruleCode/versions/:version', 'PUT', ords.source_type_plsql,
        q'~declare l_status number; l_body clob; begin erp_admin_pkg.put_scoring_rule(:ruleType, :ruleCode, :version, :body_text, l_status, l_body); :status_code := l_status; :content_type := 'application/json'; erp_api_util_pkg.emit(l_body); end;~');
    ords.define_template('supplier.onboarding.v1', 'admin-settings/business-units');
    ords.define_handler('supplier.onboarding.v1', 'admin-settings/business-units', 'GET', ords.source_type_plsql,
        q'~begin :status_code := 200; :content_type := 'application/json'; erp_api_util_pkg.emit(erp_admin_pkg.business_units()); end;~');
    ords.define_template('supplier.onboarding.v1', 'admin-settings/business-units/:businessUnitCode');
    ords.define_handler('supplier.onboarding.v1', 'admin-settings/business-units/:businessUnitCode', 'PUT', ords.source_type_plsql,
        q'~declare l_status number; l_body clob; begin erp_admin_pkg.put_business_unit(:businessUnitCode, :body_text, l_status, l_body); :status_code := l_status; :content_type := 'application/json'; erp_api_util_pkg.emit(l_body); end;~');
    ords.define_template('supplier.onboarding.v1', 'admin-settings/supplier-types');
    ords.define_handler('supplier.onboarding.v1', 'admin-settings/supplier-types', 'GET', ords.source_type_plsql,
        q'~begin :status_code := 200; :content_type := 'application/json'; erp_api_util_pkg.emit(erp_admin_pkg.supplier_types()); end;~');
    ords.define_template('supplier.onboarding.v1', 'admin-settings/supplier-types/:supplierTypeCode');
    ords.define_handler('supplier.onboarding.v1', 'admin-settings/supplier-types/:supplierTypeCode', 'PUT', ords.source_type_plsql,
        q'~declare l_status number; l_body clob; begin erp_admin_pkg.put_supplier_type(:supplierTypeCode, :body_text, l_status, l_body); :status_code := l_status; :content_type := 'application/json'; erp_api_util_pkg.emit(l_body); end;~');
    commit;
end;
/
