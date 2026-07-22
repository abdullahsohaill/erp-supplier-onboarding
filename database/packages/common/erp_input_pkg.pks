create or replace package erp_input_pkg authid definer as
    function parse_object(p_body clob) return json_object_t;
    procedure assert_allowed_keys(p_object json_object_t, p_allowed_csv varchar2);
    procedure assert_no_raw_bank(p_body clob);
    function optional_string(
        p_object json_object_t,
        p_key varchar2,
        p_max_length pls_integer
    ) return varchar2;
    function normalized_text(p_value varchar2) return varchar2;
end erp_input_pkg;
/
