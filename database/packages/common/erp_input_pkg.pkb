create or replace package body erp_input_pkg as
    function parse_object(p_body clob) return json_object_t is
    begin
        if p_body is null or dbms_lob.getlength(p_body) = 0 then
            return json_object_t();
        end if;
        if dbms_lob.getlength(p_body) > 1048576 then
            raise_application_error(-20013, 'BODY_TOO_LARGE');
        end if;
        return json_object_t.parse(p_body);
    exception
        when others then
            if sqlcode between -20099 and -20000 then
                raise;
            end if;
            raise_application_error(-20000, 'MALFORMED_JSON');
    end;

    procedure assert_allowed_keys(p_object json_object_t, p_allowed_csv varchar2) is
        l_keys json_key_list := p_object.get_keys();
    begin
        for i in 1 .. l_keys.count loop
            if instr(',' || lower(p_allowed_csv) || ',', ',' || lower(l_keys(i)) || ',') = 0 then
                raise_application_error(-20000, 'UNKNOWN_FIELD:' || substr(l_keys(i), 1, 80));
            end if;
        end loop;
    end;

    procedure assert_no_raw_bank(p_body clob) is
        l_lower clob;
    begin
        if p_body is null then
            return;
        end if;
        l_lower := lower(p_body);
        if dbms_lob.instr(l_lower, '"accountnumber"') > 0
           or dbms_lob.instr(l_lower, '"iban"') > 0
           or dbms_lob.instr(l_lower, '"routingnumber"') > 0 then
            raise_application_error(-20000, 'RAW_BANK_DATA_PROHIBITED');
        end if;
    end;

    function optional_string(
        p_object json_object_t,
        p_key varchar2,
        p_max_length pls_integer
    ) return varchar2 is
        l_value varchar2(32767);
    begin
        if not p_object.has(p_key) then
            return null;
        end if;
        if p_object.get(p_key).is_null then
            return null;
        end if;
        l_value := trim(p_object.get_string(p_key));
        if length(l_value) > p_max_length then
            raise_application_error(-20000, 'FIELD_TOO_LONG:' || substr(p_key, 1, 80));
        end if;
        return nullif(l_value, '');
    exception
        when value_error then
            raise_application_error(-20000, 'INVALID_FIELD_TYPE:' || substr(p_key, 1, 80));
    end;

    function normalized_text(p_value varchar2) return varchar2 is
    begin
        return trim(regexp_replace(upper(p_value), '[^A-Z0-9]+', ' '));
    end;
end erp_input_pkg;
/
