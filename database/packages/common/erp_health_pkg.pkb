create or replace package body erp_health_pkg as
    function health_json return clob is
        l_tables number;
        l_columns number;
        l_fks number;
        l_invalid number;
        l_data json_object_t := json_object_t();
    begin
        select count(*) into l_tables from user_tables;
        select count(*) into l_columns
          from user_tab_columns
         where table_name in (select table_name from user_tables);
        select count(*) into l_fks from user_constraints where constraint_type = 'R';
        select count(*) into l_invalid from user_objects where status <> 'VALID';
        l_data.put('status', case when l_invalid = 0 then 'UP' else 'DEGRADED' end);
        l_data.put('database', sys_context('USERENV', 'DB_NAME'));
        l_data.put('schema', sys_context('USERENV', 'CURRENT_SCHEMA'));
        l_data.put('tables', l_tables);
        l_data.put('columns', l_columns);
        l_data.put('foreignKeys', l_fks);
        l_data.put('invalidObjects', l_invalid);
        return erp_api_util_pkg.success(l_data.to_clob());
    end;
end erp_health_pkg;
/
