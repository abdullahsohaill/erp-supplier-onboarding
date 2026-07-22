create or replace package erp_health_pkg authid definer as
    function health_json return clob;
end erp_health_pkg;
/
