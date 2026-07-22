create or replace package erp_dashboard_pkg authid definer as
  function requester_summary(p_actor varchar2) return clob;
  function reviewer_summary return clob;
  function support_summary return clob;
end erp_dashboard_pkg;
/

create or replace package body erp_dashboard_pkg as
  function requester_summary(p_actor varchar2) return clob is l_json clob;
  begin
    select json_object(
      'drafts' value count(case when status='Draft' then 1 end),
      'submitted' value count(case when status in ('Submitted','Under Review','Approved','Submitted to Fusion') then 1 end),
      'correctionNeeded' value count(case when status='Correction Requested' then 1 end),
      'createdInFusion' value count(case when status='Created in Fusion' then 1 end) returning clob
    ) into l_json from supplier_request where lower(requester_user)=lower(p_actor);
    return l_json;
  end;
  function reviewer_summary return clob is l_json clob;
  begin
    select json_object(
      'pendingReview' value (select count(*) from supplier_request where status='Under Review'),
      'highRisk' value (select count(distinct request_id) from risk_assessment where risk_level='High' and is_current=1),
      'duplicateRisk' value (select count(distinct request_id) from duplicate_match where match_level in ('Critical','High') and is_current=1),
      'recentlyCreated' value (select count(*) from supplier_request where status='Created in Fusion' and fusion_created_at >= systimestamp - interval '7' day),
      'integrationFailed' value (select count(*) from supplier_request where status='Integration Failed') returning clob
    ) into l_json from dual;
    return l_json;
  end;
  function support_summary return clob is l_json clob;
  begin
    select json_object(
      'integrationFailed' value count(case when status='FAILED' then 1 end),
      'retryEligible' value count(case when retry_eligible_flag=1 then 1 end),
      'businessFailures' value count(case when error_category='BUSINESS' then 1 end),
      'technicalFailures' value count(case when error_category='TECHNICAL' then 1 end) returning clob
    ) into l_json from integration_log;
    return l_json;
  end;
end erp_dashboard_pkg;
/
