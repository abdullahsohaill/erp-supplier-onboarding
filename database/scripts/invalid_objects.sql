select object_name, object_type, status
  from user_objects
 where status <> 'VALID'
 order by object_type, object_name;
