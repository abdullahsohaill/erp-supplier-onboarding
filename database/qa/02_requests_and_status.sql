select request_number, supplier_name, status, requester_user, last_updated_at
from ERP_APP.supplier_request
order by request_id;

select r.request_number, h.from_status, h.to_status, h.action_code, h.action_timestamp
from ERP_APP.status_history h
join ERP_APP.supplier_request r on r.request_id = h.request_id
order by h.action_timestamp, h.history_id;
