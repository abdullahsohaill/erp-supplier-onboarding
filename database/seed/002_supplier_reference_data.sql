merge into existing_supplier_ref t
using (
    select 1001 id, 'FUS-100884' fusion_id, 'SUP-100884' supplier_number,
           'Al Noor Packaging' supplier_name, 'AL NOOR PACKAGING' normalized_name,
           'PK' country_code, 'PK-NTN-100884' tax_number, 'alnoor.example' email_domain,
           '+9221000100884' phone_number, '12 INDUSTRIAL AREA KARACHI SINDH PK' address_value,
           'sha256:demo-bank-token-100884' bank_hash from dual union all
    select 1002, 'FUS-104284', 'SUP-104284', 'Orion Packaging', 'ORION PACKAGING',
           'AE', 'AE-TRN-104284', 'orion.example', '+9714000104284',
           '4 LOGISTICS CITY DUBAI DUBAI AE', 'sha256:demo-bank-token-104284' from dual
) s on (t.supplier_number = s.supplier_number)
when not matched then insert (
    supplier_ref_id, fusion_supplier_id, supplier_number, supplier_name,
    normalized_name, country_code, tax_registration_number, email_domain,
    phone_normalized, address_normalized, bank_account_hash, last_sync_at
) values (
    s.id, s.fusion_id, s.supplier_number, s.supplier_name, s.normalized_name,
    s.country_code, s.tax_number, s.email_domain, s.phone_number,
    s.address_value, s.bank_hash, systimestamp
);

merge into existing_supplier_site_ref t
using (
    select 2001 id, 1001 supplier_id, 'SITE-100884-1' fusion_site_id,
           'Karachi Primary' site_name, 'PK' country_code,
           '12 INDUSTRIAL AREA KARACHI SINDH PK' address_value, 'PK-OPS' bu from dual union all
    select 2002, 1002, 'SITE-104284-1', 'Dubai Primary', 'AE',
           '4 LOGISTICS CITY DUBAI DUBAI AE', 'GCC-OPS' from dual
) s on (t.fusion_site_id = s.fusion_site_id)
when not matched then insert (
    site_ref_id, supplier_ref_id, fusion_site_id, site_name, country_code,
    address_normalized, business_unit_code
) values (
    s.id, s.supplier_id, s.fusion_site_id, s.site_name, s.country_code,
    s.address_value, s.bu
);

commit;
