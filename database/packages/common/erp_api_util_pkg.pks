create or replace package erp_api_util_pkg authid definer as
    function trace_id return varchar2;
    function success(p_data clob, p_trace_id varchar2 default null) return clob;
    function failure(
        p_code varchar2,
        p_message varchar2,
        p_trace_id varchar2 default null,
        p_details clob default null
    ) return clob;
    function authorize(p_allowed_csv varchar2) return number;
    procedure emit(p_body clob);
end erp_api_util_pkg;
/
