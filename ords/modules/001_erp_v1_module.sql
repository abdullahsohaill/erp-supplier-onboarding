begin
  ords.define_module(
    p_module_name    => 'erp.v1',
    p_base_path      => '/v1/',
    p_items_per_page => 25,
    p_status         => 'PUBLISHED',
    p_comments       => 'Supplier onboarding v1 API'
  );
  commit;
end;
/

declare
  type template_set is table of boolean index by varchar2(255);
  l_templates template_set;

  procedure add_handler(p_method varchar2, p_pattern varchar2, p_source clob, p_comment varchar2) is
  begin
    -- DEFINE_TEMPLATE replaces an existing template and removes its handlers.
    -- Define each URI once so routes that support multiple methods retain all
    -- of their handlers (for example GET/PATCH and GET/POST).
    if not l_templates.exists(p_pattern) then
      ords.define_template(p_module_name => 'erp.v1', p_pattern => p_pattern, p_comments => p_comment);
      l_templates(p_pattern) := true;
    end if;
    ords.define_handler(
      p_module_name   => 'erp.v1',
      p_pattern       => p_pattern,
      p_method        => p_method,
      p_source_type   => 'plsql/block',
      p_mimes_allowed => 'application/json',
      p_source        => p_source,
      p_comments      => p_comment
    );
  end;
begin
  -- ENDPOINT POST /requests
  add_handler('POST','requests',q'~declare r clob;s number;begin erp_request_pkg.create_request(:body_text,erp_security_pkg.current_actor,r,s);:status_code:=s;erp_api_pkg.emit(r);end;~','Create draft request');
  -- ENDPOINT GET /requests
  add_handler('GET','requests',q'~begin :status_code:=200;erp_api_pkg.emit(erp_api_pkg.success(erp_request_pkg.requests_json(erp_security_pkg.current_actor)));end;~','List role-scoped requests');
  -- ENDPOINT GET /requests/{requestId}
  add_handler('GET','requests/:requestId',q'~begin :status_code:=200;erp_api_pkg.emit(erp_api_pkg.success(erp_request_pkg.request_json(:requestId,erp_security_pkg.current_actor)));exception when others then :status_code:=404;erp_api_pkg.emit(erp_api_pkg.error('REQUEST','REQUEST_NOT_FOUND','Request not found.'));end;~','Get role-safe request detail');
  -- ENDPOINT PATCH /requests/{requestId}
  add_handler('PATCH','requests/:requestId',q'~declare r clob;s number;begin erp_request_pkg.update_request(:requestId,:body_text,erp_security_pkg.current_actor,r,s);:status_code:=s;erp_api_pkg.emit(r);end;~','Update editable request');
  -- ENDPOINT POST /requests/{requestId}/submit
  add_handler('POST','requests/:requestId/submit',q'~declare r clob;s number;begin erp_request_pkg.submit_request(:requestId,erp_security_pkg.current_actor,r,s);:status_code:=s;erp_api_pkg.emit(r);end;~','Submit or resubmit request');
  -- ENDPOINT POST /requests/{requestId}/validate
  add_handler('POST','requests/:requestId/validate',q'~declare b number;run_id varchar2(64):=lower(rawtohex(sys_guid()));begin if erp_security_pkg.is_privileged_actor=0 then raise_application_error(-20003,'FORBIDDEN');end if;erp_validation_pkg.run(:requestId,run_id,b);commit;:status_code:=200;erp_api_pkg.emit(erp_api_pkg.success(erp_validation_pkg.results_json(:requestId)));exception when others then rollback;:status_code:=403;erp_api_pkg.emit(erp_api_pkg.error('AUTHORIZATION','FORBIDDEN','You are not authorized for this action.'));end;~','Run governed validation');
  -- ENDPOINT GET /requests/{requestId}/validation-results
  add_handler('GET','requests/:requestId/validation-results',q'~begin if erp_security_pkg.is_privileged_actor=0 then erp_security_pkg.assert_request_owner(:requestId);end if;:status_code:=200;erp_api_pkg.emit(erp_api_pkg.success(erp_validation_pkg.results_json(:requestId)));exception when others then :status_code:=404;erp_api_pkg.emit(erp_api_pkg.error('REQUEST','REQUEST_NOT_FOUND','Request not found.'));end;~','Get validation findings');
  -- ENDPOINT POST /requests/{requestId}/duplicate-check
  add_handler('POST','requests/:requestId/duplicate-check',q'~begin if erp_security_pkg.is_privileged_actor=0 then raise_application_error(-20003,'FORBIDDEN');end if;erp_duplicate_pkg.run(:requestId,lower(rawtohex(sys_guid())));commit;:status_code:=200;erp_api_pkg.emit(erp_api_pkg.success(erp_duplicate_pkg.matches_json(:requestId)));exception when others then rollback;:status_code:=403;erp_api_pkg.emit(erp_api_pkg.error('AUTHORIZATION','FORBIDDEN','You are not authorized for duplicate evidence.'));end;~','Run duplicate detection');
  -- ENDPOINT GET /requests/{requestId}/duplicate-matches
  add_handler('GET','requests/:requestId/duplicate-matches',q'~begin if erp_security_pkg.is_privileged_actor=0 then raise_application_error(-20003,'FORBIDDEN');end if;:status_code:=200;erp_api_pkg.emit(erp_api_pkg.success(erp_duplicate_pkg.matches_json(:requestId)));exception when others then :status_code:=403;erp_api_pkg.emit(erp_api_pkg.error('AUTHORIZATION','FORBIDDEN','You are not authorized for duplicate evidence.'));end;~','Get duplicate matches');
  -- ENDPOINT POST /requests/{requestId}/risk-score
  add_handler('POST','requests/:requestId/risk-score',q'~begin if erp_security_pkg.is_privileged_actor=0 then raise_application_error(-20003,'FORBIDDEN');end if;erp_risk_pkg.run(:requestId,lower(rawtohex(sys_guid())));commit;:status_code:=200;erp_api_pkg.emit(erp_api_pkg.success(erp_risk_pkg.assessment_json(:requestId)));exception when others then rollback;:status_code:=403;erp_api_pkg.emit(erp_api_pkg.error('AUTHORIZATION','FORBIDDEN','You are not authorized for risk evidence.'));end;~','Calculate risk');
  -- ENDPOINT GET /requests/{requestId}/risk-assessment
  add_handler('GET','requests/:requestId/risk-assessment',q'~begin if erp_security_pkg.is_privileged_actor=0 then raise_application_error(-20003,'FORBIDDEN');end if;:status_code:=200;erp_api_pkg.emit(erp_api_pkg.success(erp_risk_pkg.assessment_json(:requestId)));exception when others then :status_code:=403;erp_api_pkg.emit(erp_api_pkg.error('AUTHORIZATION','FORBIDDEN','You are not authorized for risk evidence.'));end;~','Get current risk assessment');
  -- ENDPOINT POST /requests/{requestId}/ai-summary
  add_handler('POST','requests/:requestId/ai-summary',q'~begin :status_code:=200;erp_api_pkg.emit(erp_api_pkg.success(erp_ai_pkg.generate_summary(:requestId,erp_security_pkg.current_actor)));commit;exception when others then rollback;:status_code:=403;erp_api_pkg.emit(erp_api_pkg.error('AUTHORIZATION','FORBIDDEN','You are not authorized for AI evidence.'));end;~','Generate deterministic mock AI summary');
  -- ENDPOINT GET /requests/{requestId}/ai-summaries
  add_handler('GET','requests/:requestId/ai-summaries',q'~begin if erp_security_pkg.is_privileged_actor=0 then raise_application_error(-20003,'FORBIDDEN');end if;:status_code:=200;erp_api_pkg.emit(erp_api_pkg.success(erp_ai_pkg.summaries_json(:requestId)));exception when others then :status_code:=403;erp_api_pkg.emit(erp_api_pkg.error('AUTHORIZATION','FORBIDDEN','You are not authorized for AI evidence.'));end;~','Get AI summary history');
  -- ENDPOINT GET /requests/{requestId}/attachments
  add_handler('GET','requests/:requestId/attachments',q'~begin :status_code:=200;erp_api_pkg.emit(erp_api_pkg.success(erp_request_pkg.attachments_json(:requestId,erp_security_pkg.current_actor)));end;~','Get document metadata');
  -- ENDPOINT POST /requests/{requestId}/attachment-metadata
  add_handler('POST','requests/:requestId/attachment-metadata',q'~declare r clob;s number;begin erp_request_pkg.upsert_attachment(:requestId,:body_text,erp_security_pkg.current_actor,r,s);:status_code:=s;erp_api_pkg.emit(r);end;~','Add document metadata');
  -- ENDPOINT POST /requests/{requestId}/approve
  add_handler('POST','requests/:requestId/approve',q'~declare r clob;s number;begin erp_review_pkg.decide(:requestId,'APPROVE',:body_text,erp_security_pkg.current_actor,r,s);:status_code:=s;erp_api_pkg.emit(r);end;~','Approve request');
  -- ENDPOINT POST /requests/{requestId}/reject
  add_handler('POST','requests/:requestId/reject',q'~declare r clob;s number;begin erp_review_pkg.decide(:requestId,'REJECT',:body_text,erp_security_pkg.current_actor,r,s);:status_code:=s;erp_api_pkg.emit(r);end;~','Reject request');
  -- ENDPOINT POST /requests/{requestId}/request-correction
  add_handler('POST','requests/:requestId/request-correction',q'~declare r clob;s number;begin erp_review_pkg.decide(:requestId,'REQUEST_CORRECTION',:body_text,erp_security_pkg.current_actor,r,s);:status_code:=s;erp_api_pkg.emit(r);end;~','Request correction');
  -- ENDPOINT POST /requests/{requestId}/mark-duplicate
  add_handler('POST','requests/:requestId/mark-duplicate',q'~declare r clob;s number;begin erp_review_pkg.decide(:requestId,'MARK_DUPLICATE',:body_text,erp_security_pkg.current_actor,r,s);:status_code:=s;erp_api_pkg.emit(r);end;~','Mark duplicate');
  -- ENDPOINT POST /requests/{requestId}/submit-to-fusion
  add_handler('POST','requests/:requestId/submit-to-fusion',q'~declare r clob;s number;begin erp_integration_pkg.submit_mock(:requestId,erp_security_pkg.current_actor,r,s);:status_code:=s;erp_api_pkg.emit(r);end;~','Submit to deterministic mock Fusion');
  -- ENDPOINT POST /integration-logs/{logId}/retry
  add_handler('POST','integration-logs/:logId/retry',q'~declare r clob;s number;begin erp_integration_pkg.retry_mock(:logId,erp_security_pkg.current_actor,r,s);:status_code:=s;erp_api_pkg.emit(r);end;~','Retry eligible integration log');
  -- ENDPOINT GET /dashboard/requester-summary
  add_handler('GET','dashboard/requester-summary',q'~begin :status_code:=200;erp_api_pkg.emit(erp_api_pkg.success(erp_dashboard_pkg.requester_summary(erp_security_pkg.current_actor)));end;~','Requester dashboard counts');
  -- ENDPOINT GET /dashboard/reviewer-summary
  add_handler('GET','dashboard/reviewer-summary',q'~begin erp_security_pkg.assert_reviewer;:status_code:=200;erp_api_pkg.emit(erp_api_pkg.success(erp_dashboard_pkg.reviewer_summary));end;~','Reviewer dashboard counts');
  -- ENDPOINT GET /dashboard/support-summary
  add_handler('GET','dashboard/support-summary',q'~begin erp_security_pkg.assert_admin;:status_code:=200;erp_api_pkg.emit(erp_api_pkg.success(erp_dashboard_pkg.support_summary));end;~','Support dashboard counts');
  -- ENDPOINT GET /integration-logs
  add_handler('GET','integration-logs',q'~begin erp_security_pkg.assert_admin;:status_code:=200;erp_api_pkg.emit(erp_api_pkg.success(erp_integration_pkg.logs_json));end;~','Search integration logs');
  -- ENDPOINT GET /integration-logs/{logId}
  add_handler('GET','integration-logs/:logId',q'~begin erp_security_pkg.assert_admin;:status_code:=200;erp_api_pkg.emit(erp_api_pkg.success(erp_integration_pkg.log_json(:logId)));end;~','Get integration log and retry history');
  -- ENDPOINT GET /reference/business-units
  add_handler('GET','reference/business-units',q'~begin :status_code:=200;erp_api_pkg.emit(erp_api_pkg.success(erp_admin_pkg.business_units_json(0)));end;~','Active business units');
  -- ENDPOINT GET /reference/supplier-types
  add_handler('GET','reference/supplier-types',q'~begin :status_code:=200;erp_api_pkg.emit(erp_api_pkg.success(erp_admin_pkg.supplier_types_json(0)));end;~','Active supplier types');
  -- ENDPOINT GET /admin-settings/high-risk-countries
  add_handler('GET','admin-settings/high-risk-countries',q'~begin erp_security_pkg.assert_admin;:status_code:=200;erp_api_pkg.emit(erp_api_pkg.success(erp_admin_pkg.high_risk_countries_json));end;~','List high-risk-country periods');
  -- ENDPOINT PUT /admin-settings/high-risk-countries/{countryCode}/periods/{effectiveFrom}
  add_handler('PUT','admin-settings/high-risk-countries/:countryCode/periods/:effectiveFrom',q'~declare r clob;s number;begin erp_admin_pkg.update_high_risk_country(:countryCode,:effectiveFrom,:body_text,erp_security_pkg.current_actor,r,s);:status_code:=s;erp_api_pkg.emit(r);end;~','Update high-risk-country period');
  -- ENDPOINT GET /admin-settings/validation-rules
  add_handler('GET','admin-settings/validation-rules',q'~begin erp_security_pkg.assert_admin;:status_code:=200;erp_api_pkg.emit(erp_api_pkg.success(erp_admin_pkg.validation_rules_json));end;~','List validation rules');
  -- ENDPOINT PUT /admin-settings/validation-rules/{ruleCode}
  add_handler('PUT','admin-settings/validation-rules/:ruleCode',q'~declare r clob;s number;begin erp_admin_pkg.update_validation_rule(:ruleCode,:body_text,erp_security_pkg.current_actor,r,s);:status_code:=s;erp_api_pkg.emit(r);end;~','Update validation rule state');
  -- ENDPOINT GET /admin-settings/scoring-rules
  add_handler('GET','admin-settings/scoring-rules',q'~begin erp_security_pkg.assert_admin;:status_code:=200;erp_api_pkg.emit(erp_api_pkg.success(erp_admin_pkg.scoring_rules_json(:ruleType)));end;~','List scoring rules');
  -- ENDPOINT PUT /admin-settings/scoring-rules/{ruleType}/{ruleCode}/versions/{version}
  add_handler('PUT','admin-settings/scoring-rules/:ruleType/:ruleCode/versions/:version',q'~declare r clob;s number;begin erp_admin_pkg.update_scoring_rule(:ruleType,:ruleCode,:version,:body_text,erp_security_pkg.current_actor,r,s);:status_code:=s;erp_api_pkg.emit(r);end;~','Update scoring rule version');
  -- ENDPOINT GET /admin-settings/business-units
  add_handler('GET','admin-settings/business-units',q'~begin erp_security_pkg.assert_admin;:status_code:=200;erp_api_pkg.emit(erp_api_pkg.success(erp_admin_pkg.business_units_json(1)));end;~','List all business units');
  -- ENDPOINT PUT /admin-settings/business-units/{businessUnitCode}
  add_handler('PUT','admin-settings/business-units/:businessUnitCode',q'~declare r clob;s number;begin erp_admin_pkg.update_business_unit(:businessUnitCode,:body_text,erp_security_pkg.current_actor,r,s);:status_code:=s;erp_api_pkg.emit(r);end;~','Update business unit');
  -- ENDPOINT GET /admin-settings/supplier-types
  add_handler('GET','admin-settings/supplier-types',q'~begin erp_security_pkg.assert_admin;:status_code:=200;erp_api_pkg.emit(erp_api_pkg.success(erp_admin_pkg.supplier_types_json(1)));end;~','List all supplier types');
  -- ENDPOINT PUT /admin-settings/supplier-types/{supplierTypeCode}
  add_handler('PUT','admin-settings/supplier-types/:supplierTypeCode',q'~declare r clob;s number;begin erp_admin_pkg.update_supplier_type(:supplierTypeCode,:body_text,erp_security_pkg.current_actor,r,s);:status_code:=s;erp_api_pkg.emit(r);end;~','Update supplier type');
  -- ENDPOINT POST /admin-settings/supplier-reference-sync
  add_handler('POST','admin-settings/supplier-reference-sync',q'~begin :status_code:=202;erp_api_pkg.emit(erp_api_pkg.success(erp_admin_pkg.trigger_reference_sync(erp_security_pkg.current_actor)));end;~','Trigger mock supplier reference sync');
  -- ENDPOINT PUT /internal/supplier-references/{fusionSupplierId}
  add_handler('PUT','internal/supplier-references/:fusionSupplierId',q'~declare r clob;s number;begin erp_admin_pkg.upsert_supplier(:fusionSupplierId,:body_text,erp_security_pkg.current_actor,r,s);:status_code:=s;erp_api_pkg.emit(r);end;~','Idempotent supplier reference upsert');
  -- ENDPOINT PUT /internal/supplier-references/{fusionSupplierId}/sites/{fusionSiteId}
  add_handler('PUT','internal/supplier-references/:fusionSupplierId/sites/:fusionSiteId',q'~declare r clob;s number;begin erp_admin_pkg.upsert_supplier_site(:fusionSupplierId,:fusionSiteId,:body_text,erp_security_pkg.current_actor,r,s);:status_code:=s;erp_api_pkg.emit(r);end;~','Idempotent supplier site reference upsert');
  -- ENDPOINT POST /internal/requests/{requestId}/integration-results
  add_handler('POST','internal/requests/:requestId/integration-results',q'~declare r clob;s number;begin erp_integration_pkg.record_result(:requestId,:body_text,erp_security_pkg.current_actor,r,s);:status_code:=s;erp_api_pkg.emit(r);end;~','Record OIC/Fusion integration result');
  commit;
end;
/
