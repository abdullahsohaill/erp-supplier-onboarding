create or replace package erp_api_pkg authid definer as
  function success(p_data clob) return clob;
  function error(
    p_category       varchar2,
    p_code           varchar2,
    p_message        varchar2,
    p_retry_eligible number default 0
  ) return clob;
  function bool_json(p_value number) return varchar2 deterministic;
  procedure emit(p_body clob);
end erp_api_pkg;
/

create or replace package body erp_api_pkg as
  function bool_json(p_value number) return varchar2 deterministic is
  begin
    return case when nvl(p_value, 0) = 1 then 'true' else 'false' end;
  end;

  function success(p_data clob) return clob is
  begin
    return '{"success":true,"data":' || nvl(p_data, 'null') || '}';
  end;

  function error(
    p_category       varchar2,
    p_code           varchar2,
    p_message        varchar2,
    p_retry_eligible number default 0
  ) return clob is
    l_result clob;
  begin
    select json_object(
      'success' value 'false' format json,
      'error' value json_object(
        'category' value p_category,
        'code' value p_code,
        'message' value p_message,
        'technicalMessage' value null,
        'retryEligible' value case when nvl(p_retry_eligible, 0) = 1 then 'true' else 'false' end format json
      ),
      'traceId' value lower(rawtohex(sys_guid()))
      returning clob
    ) into l_result from dual;
    return l_result;
  end;

  procedure emit(p_body clob) is
  begin
    owa_util.mime_header('application/json; charset=utf-8', false);
    owa_util.http_header_close;
    htp.prn(p_body);
  end;
end erp_api_pkg;
/
