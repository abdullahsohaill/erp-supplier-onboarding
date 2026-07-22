create or replace package erp_request_workflow_pkg authid definer as
    procedure create_request(p_body clob, o_status out number, o_body out clob);
    procedure update_request(p_request_id number, p_body clob, o_status out number, o_body out clob);
    procedure submit_request(p_request_id number, o_status out number, o_body out clob);
    procedure maintain_attachment(p_request_id number, p_body clob, o_status out number, o_body out clob);
end erp_request_workflow_pkg;
/
