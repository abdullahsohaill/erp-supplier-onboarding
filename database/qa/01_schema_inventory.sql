select count(*) as table_count from all_tables where owner = 'ERP_APP';

select count(*) as column_count
from all_tab_columns
where owner = 'ERP_APP'
  and table_name in (select table_name from all_tables where owner = 'ERP_APP');

select constraint_type, count(*) as constraint_count
from all_constraints
where owner = 'ERP_APP'
  and constraint_type in ('P', 'R', 'U', 'C')
group by constraint_type
order by constraint_type;

select object_type, status, count(*) as object_count
from all_objects
where owner = 'ERP_APP'
  and object_type in ('PACKAGE', 'PACKAGE BODY', 'TABLE', 'VIEW')
group by object_type, status
order by object_type, status;
