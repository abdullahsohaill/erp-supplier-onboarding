create or replace package body erp_api_util_pkg as
    function trace_id return varchar2 is
    begin
        return lower(rawtohex(sys_guid()));
    end;

    function success(p_data clob, p_trace_id varchar2 default null) return clob is
        l_envelope json_object_t := json_object_t();
    begin
        l_envelope.put('traceId', nvl(p_trace_id, trace_id()));
        l_envelope.put('success', true);
        if p_data is null then
            l_envelope.put_null('data');
        else
            l_envelope.put('data', json_element_t.parse(p_data));
        end if;
        return l_envelope.to_clob();
    end;

    function failure(
        p_code varchar2,
        p_message varchar2,
        p_trace_id varchar2 default null,
        p_details clob default null
    ) return clob is
        l_envelope json_object_t := json_object_t();
        l_error json_object_t := json_object_t();
    begin
        l_envelope.put('traceId', nvl(p_trace_id, trace_id()));
        l_envelope.put('success', false);
        l_error.put('code', substr(p_code, 1, 80));
        l_error.put('message', substr(p_message, 1, 500));
        if p_details is not null then
            l_error.put('details', json_element_t.parse(p_details));
        end if;
        l_envelope.put('error', l_error);
        return l_envelope.to_clob();
    exception
        when others then
            return '{"success":false,"error":{"code":"INTERNAL_ERROR","message":"The request could not be completed."}}';
    end;

    procedure emit(p_body clob) is
        l_offset pls_integer := 1;
        l_length pls_integer;
    begin
        if p_body is null then
            return;
        end if;
        l_length := dbms_lob.getlength(p_body);
        while l_offset <= l_length loop
            htp.prn(dbms_lob.substr(p_body, 32000, l_offset));
            l_offset := l_offset + 32000;
        end loop;
    end;
end erp_api_util_pkg;
/
