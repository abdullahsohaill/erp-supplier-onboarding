declare
    l_verify_users number;
begin
    select count(*) into l_verify_users
      from all_users
     where username = 'ERP_VERIFY';

    if l_verify_users = 1 then
        for item in (
            select table_name object_name from user_tables
            union all
            select view_name object_name from user_views
        ) loop
            execute immediate
                'grant select on ' || dbms_assert.sql_object_name(item.object_name)
                || ' to ERP_VERIFY';
        end loop;
    end if;
end;
/
