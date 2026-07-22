create or replace package erp_integration_pkg authid definer as
    procedure submit_to_fusion(p_request_id number, o_status out number, o_body out clob);
    procedure retry_log(p_log_id number, o_status out number, o_body out clob);
    function list_logs(p_request_id number default null, p_status varchar2 default null, p_limit number default 25, p_offset number default 0) return clob;
    function log_detail(p_log_id number) return clob;
    function support_dashboard return clob;
    function trigger_reference_sync return clob;
    procedure upsert_supplier(p_fusion_supplier_id varchar2, p_body clob, o_status out number, o_body out clob);
    procedure upsert_supplier_site(p_fusion_supplier_id varchar2, p_fusion_site_id varchar2, p_body clob, o_status out number, o_body out clob);
    procedure record_integration_result(p_request_id number, p_body clob, o_status out number, o_body out clob);
end erp_integration_pkg;
/
