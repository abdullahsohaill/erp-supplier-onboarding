declare
    l_invalid number;
    l_names varchar2(4000);
begin
    select count(*), listagg(object_name || ':' || object_type, ', ') within group (order by object_name)
      into l_invalid, l_names
      from user_objects
     where status <> 'VALID';
    if l_invalid > 0 then
        raise_application_error(-20102, 'INVALID_OBJECTS:' || substr(l_names, 1, 3500));
    end if;
end;
/
