create or replace package erp_analysis_pkg authid definer as
    procedure run_validation(p_request_id number, o_status out number, o_body out clob);
    procedure run_duplicate_check(p_request_id number, o_status out number, o_body out clob);
    procedure run_risk_score(p_request_id number, o_status out number, o_body out clob);
    procedure generate_ai_summary(p_request_id number, o_status out number, o_body out clob);
    function duplicate_matches(p_request_id number) return clob;
    function risk_assessment(p_request_id number) return clob;
    function ai_summaries(p_request_id number) return clob;
end erp_analysis_pkg;
/
