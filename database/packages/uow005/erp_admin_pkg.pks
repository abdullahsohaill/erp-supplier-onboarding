create or replace package erp_admin_pkg authid definer as
    function high_risk_countries return clob;
    procedure put_high_risk_country(p_country_code varchar2, p_effective_from varchar2, p_body clob, o_status out number, o_body out clob);
    function validation_rules return clob;
    procedure put_validation_rule(p_rule_code varchar2, p_body clob, o_status out number, o_body out clob);
    function scoring_rules(p_rule_type varchar2 default null) return clob;
    procedure put_scoring_rule(p_rule_type varchar2, p_rule_code varchar2, p_version varchar2, p_body clob, o_status out number, o_body out clob);
    function business_units return clob;
    procedure put_business_unit(p_code varchar2, p_body clob, o_status out number, o_body out clob);
    function supplier_types return clob;
    procedure put_supplier_type(p_code varchar2, p_body clob, o_status out number, o_body out clob);
end erp_admin_pkg;
/
