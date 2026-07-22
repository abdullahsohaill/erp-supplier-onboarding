select r.request_number, l.oic_instance_id, l.status, l.error_category,
       l.retry_count, l.retry_eligible_flag, l.last_retry_at
from ERP_APP.integration_log l
join ERP_APP.supplier_request r on r.request_id = l.request_id
order by l.log_id;

select status, retry_eligible_flag, count(*) as log_count
from ERP_APP.integration_log
group by status, retry_eligible_flag
order by status, retry_eligible_flag;
