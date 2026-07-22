whenever sqlerror exit failure rollback

insert into ref_business_unit values (1,'BU-001','Global Operations','FUSION-BU-001',1,systimestamp,'SEED',systimestamp,'SEED');
insert into ref_business_unit values (2,'BU-002','Technology Services','FUSION-BU-002',1,systimestamp,'SEED',systimestamp,'SEED');
insert into ref_business_unit values (3,'BU-INACTIVE','Legacy Business Unit',null,0,systimestamp,'SEED',systimestamp,'SEED');

insert into ref_supplier_type values (1,'SERVICE_PROVIDER','Service Provider',1,1,systimestamp,'SEED',systimestamp,'SEED');
insert into ref_supplier_type values (2,'GOODS_SUPPLIER','Goods Supplier',1,1,systimestamp,'SEED',systimestamp,'SEED');
insert into ref_supplier_type values (3,'INDIVIDUAL','Individual Contractor',0,1,systimestamp,'SEED',systimestamp,'SEED');
insert into ref_supplier_type values (4,'LEGACY','Inactive Legacy Type',0,0,systimestamp,'SEED',systimestamp,'SEED');

insert into ref_high_risk_country values ('XZ',date '2026-01-01','Example Enhanced Review Country','High',1,null,systimestamp,'SEED',systimestamp,'SEED');
insert into ref_high_risk_country values ('YY',date '2025-01-01','Expired Example Country','Medium',0,date '2025-12-31',systimestamp,'SEED',systimestamp,'SEED');

insert into validation_rules values (1,'VAL-001','Supplier name required','Supplier name must be supplied before review.','supplierName','Error','Supplier name is required.',1,1,systimestamp,'SEED',systimestamp,'SEED');
insert into validation_rules values (2,'VAL-002','Country required','Supplier header country must be supplied.','countryCode','Error','Supplier country is required.',1,1,systimestamp,'SEED',systimestamp,'SEED');
insert into validation_rules values (3,'VAL-003','Supplier type required','Supplier type must resolve to an active governed value.','supplierType','Error','Supplier type is required.',1,1,systimestamp,'SEED',systimestamp,'SEED');
insert into validation_rules values (4,'VAL-004','Business unit required and mapped','Business unit must be active and mapped to Fusion.','businessUnitCode','Error','Select an active, mapped business unit.',1,1,systimestamp,'SEED',systimestamp,'SEED');
insert into validation_rules values (5,'VAL-005','Contact email required and valid','At least one syntactically valid contact email is required.','contact.email','Error','Enter a valid contact email.',1,1,systimestamp,'SEED',systimestamp,'SEED');
insert into validation_rules values (6,'VAL-006','Required site fields complete','Both address lines, city, region and country are required; address lines are limited to 20 characters.','sites.address','Error','Complete all required site address fields.',1,1,systimestamp,'SEED',systimestamp,'SEED');
insert into validation_rules values (7,'VAL-007','At least one site required','A supplier request must contain at least one site.','sites','Error','Add at least one supplier site.',1,1,systimestamp,'SEED',systimestamp,'SEED');
insert into validation_rules values (8,'VAL-008','Exact tax duplicate','Exact normalized tax registration duplicates block submission.','taxRegistrationNumber','Error','This tax registration already belongs to an existing or staged supplier.',1,1,systimestamp,'SEED',systimestamp,'SEED');
insert into validation_rules values (9,'VAL-009','Same bank token duplicate','A matching trusted bank token/hash blocks submission.','bank.accountToken','Error','This bank account indicator is already associated with another supplier.',1,1,systimestamp,'SEED',systimestamp,'SEED');

insert into ref_scoring_rule values ('MISSING_TAX','v1','RISK','Missing tax registration',25,'Warning',0,1,systimestamp,'SEED',systimestamp,'SEED');
insert into ref_scoring_rule values ('HIGH_RISK_COUNTRY','v1','RISK','High-risk country',25,'Warning',0,1,systimestamp,'SEED',systimestamp,'SEED');
insert into ref_scoring_rule values ('BANK_COUNTRY_MISMATCH','v1','RISK','Bank-country mismatch',20,'Warning',0,1,systimestamp,'SEED',systimestamp,'SEED');
insert into ref_scoring_rule values ('INCOMPLETE_ADDRESS','v1','RISK','Incomplete address',15,'Warning',0,1,systimestamp,'SEED',systimestamp,'SEED');
insert into ref_scoring_rule values ('INCOMPLETE_BANK_DETAILS','v1','RISK','Incomplete bank metadata',15,'Warning',0,1,systimestamp,'SEED',systimestamp,'SEED');
insert into ref_scoring_rule values ('VAGUE_JUSTIFICATION','v1','RISK','Vague justification',15,'Warning',0,1,systimestamp,'SEED',systimestamp,'SEED');
insert into ref_scoring_rule values ('HIGH_SPEND_WEAK_JUSTIFICATION','v1','RISK','High spend with weak justification',20,'Warning',0,1,systimestamp,'SEED',systimestamp,'SEED');
insert into ref_scoring_rule values ('MISSING_DOCUMENT_METADATA','v1','RISK','Missing required document metadata',10,'Warning',0,1,systimestamp,'SEED',systimestamp,'SEED');
insert into ref_scoring_rule values ('DUPLICATE_SCORE_HIGH','v1','RISK','High duplicate score',25,'Warning',0,1,systimestamp,'SEED',systimestamp,'SEED');
insert into ref_scoring_rule values ('DUPLICATE_SCORE_MEDIUM','v1','RISK','Medium duplicate score',15,'Warning',0,1,systimestamp,'SEED',systimestamp,'SEED');
insert into ref_scoring_rule values ('RISK_HIGH_THRESHOLD','v1','RISK','High risk threshold',70,'Configuration',0,1,systimestamp,'SEED',systimestamp,'SEED');
insert into ref_scoring_rule values ('RISK_MEDIUM_THRESHOLD','v1','RISK','Medium risk threshold',35,'Configuration',0,1,systimestamp,'SEED',systimestamp,'SEED');

insert into ref_scoring_rule values ('DUP_EXACT_TAX','v1','DUPLICATE','Exact tax registration',100,'Critical',1,1,systimestamp,'SEED',systimestamp,'SEED');
insert into ref_scoring_rule values ('DUP_SAME_BANK','v1','DUPLICATE','Same bank token/hash',100,'Critical',1,1,systimestamp,'SEED',systimestamp,'SEED');
insert into ref_scoring_rule values ('DUP_NAME_SIMILARITY','v1','DUPLICATE','Normalized name similarity',30,'Scoring',0,1,systimestamp,'SEED',systimestamp,'SEED');
insert into ref_scoring_rule values ('DUP_SAME_COUNTRY','v1','DUPLICATE','Same country',10,'Scoring',0,1,systimestamp,'SEED',systimestamp,'SEED');
insert into ref_scoring_rule values ('DUP_EMAIL_DOMAIN','v1','DUPLICATE','Same email domain',15,'Scoring',0,1,systimestamp,'SEED',systimestamp,'SEED');
insert into ref_scoring_rule values ('DUP_PHONE','v1','DUPLICATE','Same phone',20,'Scoring',0,1,systimestamp,'SEED',systimestamp,'SEED');
insert into ref_scoring_rule values ('DUP_ADDRESS','v1','DUPLICATE','Same normalized address',20,'Scoring',0,1,systimestamp,'SEED',systimestamp,'SEED');
insert into ref_scoring_rule values ('DUP_BU_SITE','v1','DUPLICATE','Same business unit/site context',5,'Scoring',0,1,systimestamp,'SEED',systimestamp,'SEED');
insert into ref_scoring_rule values ('DUP_HIGH_THRESHOLD','v1','DUPLICATE','High duplicate threshold',70,'Configuration',0,1,systimestamp,'SEED',systimestamp,'SEED');
insert into ref_scoring_rule values ('DUP_MEDIUM_THRESHOLD','v1','DUPLICATE','Medium duplicate threshold',40,'Configuration',0,1,systimestamp,'SEED',systimestamp,'SEED');

insert into existing_supplier_ref values (1,'FUS-1001','SUP-1001','Northstar Facilities Ltd','NORTHSTAR FACILITIES','GB','GB111222333','northstar.example','442055550101','10KINGSTLONDON','HASH-BANK-NORTHSTAR',systimestamp);
insert into existing_supplier_ref values (2,'FUS-1002','SUP-1002','Contoso Office Goods','CONTOSO OFFICE GOODS','US','US999888777','contoso.example','12125550120','500MADISONAVENEWYORK',null,systimestamp);
insert into existing_supplier_ref values (3,'FUS-1003','SUP-1003','Globex Advisory','GLOBEX ADVISORY','AE','AE555444333','globex.example','97145550111','DOWNTOWNDUBAI','HASH-BANK-GLOBEX',systimestamp);

insert into existing_supplier_site_ref values (1,1,'FUS-SITE-1001','London Primary','GB','10KINGSTLONDON','BU-001');
insert into existing_supplier_site_ref values (2,2,'FUS-SITE-1002','New York Primary','US','500MADISONAVENEWYORK','BU-002');
insert into existing_supplier_site_ref values (3,3,'FUS-SITE-1003','Dubai Primary','AE','DOWNTOWNDUBAI','BU-001');

commit;
