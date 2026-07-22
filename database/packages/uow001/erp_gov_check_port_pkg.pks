create or replace package erp_gov_check_port_pkg authid definer as
    procedure run_checks(
        p_request_id number,
        p_actor varchar2,
        o_run_id out varchar2,
        o_blocking_count out number
    );
    function duplicate_json(p_request_id number) return clob;
    function risk_json(p_request_id number) return clob;
    function ai_json(p_request_id number) return clob;
end erp_gov_check_port_pkg;
/
