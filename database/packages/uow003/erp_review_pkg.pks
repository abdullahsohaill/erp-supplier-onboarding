create or replace package erp_review_pkg authid definer as
    function list_requests(p_status varchar2 default null, p_limit number default 25, p_offset number default 0) return clob;
    function request_detail(p_request_id number) return clob;
    function reviewer_dashboard return clob;
    procedure approve(p_request_id number, p_body clob, o_status out number, o_body out clob);
    procedure reject(p_request_id number, p_body clob, o_status out number, o_body out clob);
    procedure request_correction(p_request_id number, p_body clob, o_status out number, o_body out clob);
    procedure mark_duplicate(p_request_id number, p_body clob, o_status out number, o_body out clob);
end erp_review_pkg;
/
