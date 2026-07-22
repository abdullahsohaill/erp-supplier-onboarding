create or replace package erp_ai_pkg authid definer as
  function generate_summary(p_request_id number, p_actor varchar2) return clob;
  function summaries_json(p_request_id number) return clob;
end erp_ai_pkg;
/

create or replace package body erp_ai_pkg as
  function generate_summary(p_request_id number, p_actor varchar2) return clob is
    l_risk risk_assessment%rowtype;
    l_duplicate_count number;
    l_summary json_object_t := json_object_t();
    l_actions json_array_t := json_array_t();
    l_hash varchar2(128);
    l_json clob;
  begin
    if erp_security_pkg.is_privileged_actor(p_actor) = 0 then raise_application_error(-20003,'FORBIDDEN'); end if;
    select * into l_risk from risk_assessment
     where request_id = p_request_id and is_current = 1
     order by created_at desc fetch first 1 row only;
    select count(*) into l_duplicate_count from duplicate_match
     where request_id = p_request_id and is_current = 1 and match_level in ('Critical','High','Medium');

    l_summary.put('riskLevel', l_risk.risk_level);
    l_summary.put('riskSummary', 'Deterministic mock summary: ' || l_risk.risk_level || ' risk based on current governed factors.');
    l_summary.put('duplicateExplanation', case when l_duplicate_count > 0
      then 'One or more current duplicate candidates require Reviewer inspection.'
      else 'No material duplicate candidate is currently recorded.' end);
    l_summary.put('missingInformation', json_array_t());
    l_actions.append('Review the deterministic validation, duplicate, and risk evidence.');
    l_actions.append('Make the final decision manually; this summary cannot decide or submit.');
    l_summary.put('recommendedActions', l_actions);
    l_summary.put('decisionGuardrail', 'AI recommendation only. Reviewer must make final decision.');
    l_json := l_summary.to_clob;
    select lower(rawtohex(standard_hash(
      to_char(p_request_id) || ':' || l_risk.run_id || ':' || dbms_lob.substr(l_json, 32767, 1),
      'SHA256'
    ))) into l_hash from dual;

    insert into ai_summary (
      request_id, prompt_version, provider_name, model_name, summary_json,
      source_facts_hash, created_at, created_by
    ) values (
      p_request_id, 'mock-v1', 'DETERMINISTIC_MOCK', 'RULE_FACT_SUMMARIZER',
      json(l_json), l_hash, systimestamp, p_actor
    );
    return l_json;
  end;

  function summaries_json(p_request_id number) return clob is
    l_json clob;
  begin
    select coalesce(json_arrayagg(json_object(
      'summaryId' value summary_id,
      'promptVersion' value prompt_version,
      'providerName' value provider_name,
      'modelName' value model_name,
      'summary' value summary_json,
      'sourceFactsHash' value source_facts_hash,
      'createdAt' value to_char(created_at, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZH:TZM'),
      'createdBy' value created_by
    ) order by created_at desc returning clob), to_clob('[]')) into l_json
      from ai_summary where request_id = p_request_id;
    return l_json;
  end;
end erp_ai_pkg;
/
