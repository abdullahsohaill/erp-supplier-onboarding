whenever sqlerror exit failure rollback

insert into supplier_request values (1,'REQ-2026-0001','Draft','Bluebird Cleaning','SERVICE_PROVIDER','GB',1,'local-requester','Facilities cleaning for the regional operations office.','Facilities Services',45000,'GB200300400',null,null,null,null,systimestamp-interval '10' day,null,systimestamp-interval '1' day);
insert into supplier_request values (2,'REQ-2026-0002','Correction Requested','Alpine Consulting','SERVICE_PROVIDER','CH',2,'local-requester','Specialist technology transformation advisory for the ERP program.','Professional Services',90000,null,null,null,null,null,systimestamp-interval '9' day,systimestamp-interval '8' day,systimestamp-interval '2' day);
insert into supplier_request values (3,'REQ-2026-0003','Under Review','Northstar Facility Services','SERVICE_PROVIDER','GB',1,'local-requester','Need help.','Facilities Services',180000,null,null,null,null,null,systimestamp-interval '8' day,systimestamp-interval '7' day,systimestamp-interval '1' day);
insert into supplier_request values (4,'REQ-2026-0004','Draft','Tax Duplicate Example','GOODS_SUPPLIER','GB',1,'local-requester','Office equipment replacement for an approved capital refresh.','Office Supplies',60000,'GB111222333',null,null,null,null,systimestamp-interval '7' day,null,systimestamp-interval '1' day);
insert into supplier_request values (5,'REQ-2026-0005','Draft','Bank Duplicate Example','SERVICE_PROVIDER','AE',1,'local-requester','Local maintenance coverage for the regional site.','Maintenance',75000,'AE123123123',null,null,null,null,systimestamp-interval '6' day,null,systimestamp-interval '1' day);
insert into supplier_request values (6,'REQ-2026-0006','Under Review','Enhanced Review Trading','GOODS_SUPPLIER','XZ',2,'local-requester','Source approved industrial components for the upcoming manufacturing program.','Industrial Components',130000,'XZ200200200',null,null,null,null,systimestamp-interval '6' day,systimestamp-interval '5' day,systimestamp-interval '1' day);
insert into supplier_request values (7,'REQ-2026-0007','Approved','Ready Services','SERVICE_PROVIDER','US',2,'local-requester','Application support services under the approved annual operating plan.','Technology Services',85000,'US300300300',null,null,null,null,systimestamp-interval '5' day,systimestamp-interval '4' day,systimestamp-interval '1' day);
insert into supplier_request values (8,'REQ-2026-0008','Created in Fusion','Created Supplier Demo','GOODS_SUPPLIER','US',1,'local-requester','Supply compliant workplace safety equipment across the operating sites.','Safety Equipment',50000,'US400400400','MOCK-8','SUP-00000008',systimestamp-interval '2' day,'response://mock/seed-success',systimestamp-interval '5' day,systimestamp-interval '4' day,systimestamp-interval '2' day);
insert into supplier_request values (9,'REQ-2026-0009','Integration Failed','Fail Integration Demo','SERVICE_PROVIDER','GB',2,'local-requester','Managed infrastructure monitoring service required for business continuity.','Technology Services',95000,'GB500500500',null,null,null,null,systimestamp-interval '4' day,systimestamp-interval '3' day,systimestamp-interval '1' day);
insert into supplier_request values (10,'REQ-2026-0010','Rejected','Rejected Supplier Demo','INDIVIDUAL','US',1,'local-requester','Temporary consulting engagement outside the approved sourcing policy.','Professional Services',25000,null,null,null,null,null,systimestamp-interval '4' day,systimestamp-interval '3' day,systimestamp-interval '2' day);
insert into supplier_request values (11,'REQ-2026-0011','Marked Duplicate','Northstar Facilities Ltd','SERVICE_PROVIDER','GB',1,'local-requester','Duplicate demo scenario for existing facilities supplier.','Facilities Services',40000,'GB111222333',null,null,null,null,systimestamp-interval '3' day,systimestamp-interval '2' day,systimestamp-interval '1' day);

insert into supplier_request_site values (1,1,'Bluebird London','GB','Office 12','4 King Street','London','Greater London','SW1A 1AA',1,1);
insert into supplier_request_site values (2,2,'Alpine Zurich','CH','Suite 8','10 Lake Road','Zurich','Zurich','8001',2,1);
insert into supplier_request_site values (3,3,'Northstar London','GB','Unit 4','10 King Street','London','Greater London','SW1A 1AA',1,1);
insert into supplier_request_site values (4,4,'Tax Duplicate','GB','Floor 2','20 Market Road','London','Greater London','EC1A 1BB',1,1);
insert into supplier_request_site values (5,5,'Bank Duplicate','AE','Office 5','Downtown Road','Dubai','Dubai','00000',1,1);
insert into supplier_request_site values (6,6,'Enhanced Review','XZ','Building 1','Industrial Zone','Capital City','Central','10001',2,1);
insert into supplier_request_site values (7,7,'Ready New York','US','Suite 200','500 Madison Ave','New York','New York','10022',2,1);
insert into supplier_request_site values (8,8,'Created Chicago','US','Warehouse 4','300 Lake Drive','Chicago','Illinois','60601',1,1);
insert into supplier_request_site values (9,9,'Fail London','GB','Office 7','15 River Road','London','Greater London','SE1 2AB',2,1);
insert into supplier_request_site values (10,10,'Rejected Boston','US','Unit 3','22 Harbor Way','Boston','Massachusetts','02110',1,1);
insert into supplier_request_site values (11,11,'Northstar London','GB','Unit 4','10 King Street','London','Greater London','SW1A 1AA',1,1);

insert into supplier_request_contact values (1,1,'Alice Blue','alice@bluebird.example','+44 20 5555 1001','bluebird.example');
insert into supplier_request_contact values (2,2,'Ada Alpine','ada@alpine.example','+41 44 555 1002','alpine.example');
insert into supplier_request_contact values (3,3,'Nina North','nina@northstar.example','+44 20 5555 0101','northstar.example');
insert into supplier_request_contact values (4,4,'Tom Tax','tom@taxduplicate.example','+44 20 5555 1004','taxduplicate.example');
insert into supplier_request_contact values (5,5,'Ben Bank','ben@bankduplicate.example','+971 4 555 1005','bankduplicate.example');
insert into supplier_request_contact values (6,6,'Erin Review','erin@enhanced.example','+999 555 1006','enhanced.example');
insert into supplier_request_contact values (7,7,'Rae Ready','rae@ready.example','+1 212 555 1007','ready.example');
insert into supplier_request_contact values (8,8,'Casey Created','casey@created.example','+1 312 555 1008','created.example');
insert into supplier_request_contact values (9,9,'Finn Failure','finn@failure.example','+44 20 5555 1009','failure.example');
insert into supplier_request_contact values (10,10,'Riley Rejected','riley@rejected.example','+1 617 555 1010','rejected.example');
insert into supplier_request_contact values (11,11,'Nora North','nora@northstar.example','+44 20 5555 0101','northstar.example');

insert into supplier_request_bank values (1,1,'GB','****1001','1001','HASH-BANK-BLUEBIRD',1);
insert into supplier_request_bank values (2,3,'US','****3003','3003','HASH-BANK-NEW-NORTH',1);
insert into supplier_request_bank values (3,5,'AE','****1003','1003','HASH-BANK-GLOBEX',1);
insert into supplier_request_bank values (4,6,'US','****6006','6006','HASH-BANK-ENHANCED',1);
insert into supplier_request_bank values (5,8,'US','****8008','8008','HASH-BANK-CREATED',1);
insert into supplier_request_bank values (6,9,'GB','****9009','9009','HASH-BANK-FAIL',1);

insert into supplier_request_document values (1,1,'TAX_CERTIFICATE','RECEIVED',1,json('{"fileName":"tax-cert-demo.pdf","classification":"synthetic"}'),0);
insert into supplier_request_document values (2,2,'TAX_CERTIFICATE','MISSING',1,json('{"classification":"synthetic"}'),1);
insert into supplier_request_document values (3,3,'INSURANCE','MISSING',1,json('{"classification":"synthetic"}'),1);
insert into supplier_request_document values (4,4,'TAX_CERTIFICATE','RECEIVED',1,json('{"classification":"synthetic"}'),0);
insert into supplier_request_document values (5,5,'BANK_CONFIRMATION','PENDING',1,json('{"classification":"synthetic"}'),0);
insert into supplier_request_document values (6,6,'ENHANCED_DUE_DILIGENCE','MISSING',1,json('{"classification":"synthetic"}'),1);
insert into supplier_request_document values (7,7,'TAX_CERTIFICATE','RECEIVED',1,json('{"classification":"synthetic"}'),0);
insert into supplier_request_document values (8,8,'TAX_CERTIFICATE','RECEIVED',1,json('{"classification":"synthetic"}'),0);
insert into supplier_request_document values (9,9,'SERVICE_AGREEMENT','RECEIVED',1,json('{"classification":"synthetic"}'),0);
insert into supplier_request_document values (10,10,'POLICY_EXCEPTION','MISSING',1,json('{"classification":"synthetic"}'),1);
insert into supplier_request_document values (11,11,'TAX_CERTIFICATE','RECEIVED',1,json('{"classification":"synthetic"}'),0);

insert into status_history values (1,1,null,'Draft','CREATE_DRAFT','local-requester','Draft created.',systimestamp-interval '10' day);
insert into status_history values (2,2,null,'Draft','CREATE_DRAFT','local-requester','Draft created.',systimestamp-interval '9' day);
insert into status_history values (3,2,'Draft','Under Review','SUBMIT','local-requester','Request submitted.',systimestamp-interval '8' day);
insert into status_history values (4,2,'Under Review','Correction Requested','REQUEST_CORRECTION','local-reviewer',json_object('schemaVersion' value 1,'comment' value 'Provide the missing tax certificate.','selectedRiskFactorCodes' value json_array('MISSING_TAX'),'correctionItems' value json_array(json_object('itemType' value 'DOCUMENT','fieldName' value 'documents','message' value 'Attach tax certificate metadata.')) returning clob),systimestamp-interval '2' day);
insert into status_history values (5,3,null,'Draft','CREATE_DRAFT','local-requester','Draft created.',systimestamp-interval '8' day);
insert into status_history values (6,3,'Draft','Under Review','SUBMIT','local-requester','Request submitted.',systimestamp-interval '7' day);
insert into status_history values (7,4,null,'Draft','CREATE_DRAFT','local-requester','Draft created.',systimestamp-interval '7' day);
insert into status_history values (8,5,null,'Draft','CREATE_DRAFT','local-requester','Draft created.',systimestamp-interval '6' day);
insert into status_history values (9,6,null,'Draft','CREATE_DRAFT','local-requester','Draft created.',systimestamp-interval '6' day);
insert into status_history values (10,6,'Draft','Under Review','SUBMIT','local-requester','Request submitted with warning-only findings.',systimestamp-interval '5' day);
insert into status_history values (11,7,'Under Review','Approved','APPROVE','local-reviewer',json_object('schemaVersion' value 1,'comment' value 'Approved after evidence review.','selectedRiskFactorCodes' value json_array(),'correctionItems' value json_array() returning clob),systimestamp-interval '1' day);
insert into status_history values (12,8,'Submitted to Fusion','Created in Fusion','FUSION_CREATED','SYSTEM','Mock supplier SUP-00000008 created.',systimestamp-interval '2' day);
insert into status_history values (13,9,'Submitted to Fusion','Integration Failed','INTEGRATION_FAILED','SYSTEM','Supplier creation is temporarily unavailable.',systimestamp-interval '1' day);
insert into status_history values (14,10,'Under Review','Rejected','REJECT','local-reviewer',json_object('schemaVersion' value 1,'comment' value 'Request is outside approved sourcing policy.','selectedRiskFactorCodes' value json_array(),'correctionItems' value json_array() returning clob),systimestamp-interval '2' day);
insert into status_history values (15,11,'Under Review','Marked Duplicate','MARK_DUPLICATE','local-reviewer',json_object('schemaVersion' value 1,'comment' value 'Use the existing approved supplier.','selectedRiskFactorCodes' value json_array('DUPLICATE_SCORE_HIGH'),'correctionItems' value json_array(),'existingSupplierNumber' value 'SUP-1001' returning clob),systimestamp-interval '1' day);

insert into validation_result values (2,4,8,'seed-tax-duplicate',1,'taxRegistrationNumber','Error','This tax registration already belongs to an existing supplier.',1,systimestamp-interval '1' day);
insert into validation_result values (3,5,9,'seed-bank-duplicate',1,'bank.accountToken','Error','This bank account indicator is already associated with another supplier.',1,systimestamp-interval '1' day);

insert into duplicate_match values (1,3,'seed-review',1,'EXISTING_SUPPLIER',1,'SUP-1001','Northstar Facilities Ltd',null,55,'Medium',json('["DUP_NAME_SIMILARITY","DUP_SAME_COUNTRY","DUP_EMAIL_DOMAIN"]'),'Similar normalized name, country, and email domain.',systimestamp-interval '1' day);
insert into duplicate_match values (2,4,'seed-tax-duplicate',1,'EXISTING_SUPPLIER',1,'SUP-1001','Northstar Facilities Ltd',null,100,'Critical',json('["DUP_EXACT_TAX"]'),'Exact normalized tax registration match.',systimestamp-interval '1' day);
insert into duplicate_match values (3,5,'seed-bank-duplicate',1,'EXISTING_SUPPLIER',3,'SUP-1003','Globex Advisory',null,100,'Critical',json('["DUP_SAME_BANK"]'),'Same trusted bank token/hash.',systimestamp-interval '1' day);
insert into duplicate_match values (4,11,'seed-final-duplicate',1,'EXISTING_SUPPLIER',1,'SUP-1001','Northstar Facilities Ltd',null,80,'High',json('["DUP_NAME_SIMILARITY","DUP_SAME_COUNTRY","DUP_EMAIL_DOMAIN","DUP_PHONE"]'),'Existing supplier selected by Reviewer.',systimestamp-interval '1' day);

insert into risk_assessment values (1,3,'seed-review',1,55,'Medium','v1',json('[{"code":"MISSING_TAX","severity":"Warning","weight":25,"message":"Tax registration is missing."},{"code":"VAGUE_JUSTIFICATION","severity":"Warning","weight":15,"message":"Business justification is vague."},{"code":"MISSING_DOCUMENT_METADATA","severity":"Warning","weight":10,"message":"Required document metadata is missing."}]'),systimestamp-interval '1' day);
insert into risk_assessment values (2,4,'seed-tax-duplicate',1,25,'Low','v1',json('[{"code":"DUPLICATE_SCORE_HIGH","severity":"Warning","weight":25,"message":"Critical duplicate handled by blocking validation."}]'),systimestamp-interval '1' day);
insert into risk_assessment values (3,5,'seed-bank-duplicate',1,45,'Medium','v1',json('[{"code":"BANK_COUNTRY_MISMATCH","severity":"Warning","weight":20,"message":"Bank country differs."},{"code":"DUPLICATE_SCORE_HIGH","severity":"Warning","weight":25,"message":"Critical duplicate handled by blocking validation."}]'),systimestamp-interval '1' day);
insert into risk_assessment values (4,6,'seed-enhanced-review',1,80,'High','v1',json('[{"code":"HIGH_RISK_COUNTRY","severity":"Warning","weight":25,"message":"Country requires enhanced review."},{"code":"BANK_COUNTRY_MISMATCH","severity":"Warning","weight":20,"message":"Bank country differs."},{"code":"HIGH_SPEND_WEAK_JUSTIFICATION","severity":"Warning","weight":20,"message":"High spend requires stronger justification."},{"code":"MISSING_DOCUMENT_METADATA","severity":"Warning","weight":10,"message":"Required metadata is missing."}]'),systimestamp-interval '1' day);

insert into ai_summary values (1,3,'mock-v1','DETERMINISTIC_MOCK','RULE_FACT_SUMMARIZER',json('{"riskLevel":"Medium","riskSummary":"Medium risk based on current governed factors.","duplicateExplanation":"A similar existing supplier requires review.","missingInformation":["Tax registration","Insurance metadata"],"recommendedActions":["Review duplicate evidence","Request missing information if needed"],"decisionGuardrail":"AI recommendation only. Reviewer must make final decision."}'),'seed-facts-hash-3',systimestamp-interval '1' day,'SYSTEM');

insert into integration_log values (1,8,'SUPPLIER_CREATE_MOCK','MOCK-OIC-SEED-SUCCESS','OUTBOUND','SUCCEEDED',null,'payload://request/8','response://mock/seed-success','Supplier created successfully.',null,0,0,null,null,json('[]'),systimestamp-interval '2' day);
insert into integration_log values (2,9,'SUPPLIER_CREATE_MOCK','MOCK-OIC-SEED-FAIL','OUTBOUND','FAILED','TECHNICAL','payload://request/9','response://mock/seed-failure','Supplier creation is temporarily unavailable.','Synthetic gateway timeout.',1,1,systimestamp-interval '12' hour,'local-admin',json('[{"attemptNumber":1,"actorUser":"local-admin","attemptedAt":"2026-07-20T17:00:00.000+00:00","result":"FAILED","message":"Synthetic timeout during retry.","oicInstanceId":"MOCK-RETRY-SEED-1"}]'),systimestamp-interval '1' day);

commit;
