-- Page 3: “Currently logged in” Report
select emp_id, type, status, e.name, email, office, phone, status_eff_date, description,
l.name AS lab_name, admin_flag, labdir_flag, execdir_flag, chair_flag
from f15e1_emp e join f15e1_lab l
    on e.f15e1_lab_lab_id = l.lab_id
where emp_id = :P2_EMP;


-- Page 4: “Currently Requested RFEs” Report
select R."RFE_ID", 
R."NAME",
R."EXPLANATION",
R."ALT_PROTECTIONS",
E."NAME" AS "REQUESTOR",
S."STATUS"
from "#OWNER#"."F15E1_RFE" R JOIN "#OWNER#"."F15E1_EMP" E
 on R."F15E1_EMP_EMP_ID" = E."EMP_ID"
 JOIN "#OWNER#"."F15E1_STATUS" S ON 
 S."STATUS_ID" = R."F15E1_STATUS_STATUS_ID"
WHERE EMP_ID = :P2_EMP and 
s."STATUS_ID" <> 9 AND s."STATUS_ID" <> 5;


-- Page 4: “Finalized RFE Requests” Report
select R."RFE_ID", 
R."NAME",
R."EXPLANATION",
R."ALT_PROTECTIONS",
E."NAME" AS "REQUESTOR",
S."STATUS"
from "#OWNER#"."F15E1_RFE" R JOIN "#OWNER#"."F15E1_EMP" E
 on R."F15E1_EMP_EMP_ID" = E."EMP_ID"
 JOIN "#OWNER#"."F15E1_STATUS" S ON 
 S."STATUS_ID" = R."F15E1_STATUS_STATUS_ID"
WHERE EMP_ID = :P2_EMP and 
(s."STATUS_ID" = 9 OR s."STATUS_ID" = 5);


-- Page 6: “Needs Approval” Report
select r."RFE_ID", 
r."NAME" AS "RFE_NAME",
r."EXPLANATION",
r."ALT_PROTECTIONS",
s."STATUS",
e2."NAME" AS "REQUESTED BY"
from "#OWNER#"."F15E1_RFE" r join f15e1_appr_rfe a 
on r.rfe_id = a.f15e1_rfe_rfe_id
join f15e1_emp e on 
a.f15e1_emp_emp_id = e.emp_id
join f15e1_emp e2 on 
e2.emp_id = r.f15e1_emp_emp_id
join f15e1_status s on 
r.f15e1_status_status_id = s.status_id
where a.f15e1_emp_emp_id = :P2_EMP
and s.status_id <> 9; 


-- PAGE 9: “Employees” Report
select e.EMP_ID,
       e.TYPE,
       e.STATUS,
       e.NAME,
       e.EMAIL,
       e.OFFICE,
       e.PHONE,
       e.STATUS_EFF_DATE AS STATUS_EFFECTIVE_DATE,
       e.DESCRIPTION,
       l.name AS LAB_NAME,
       a.right,
       e.ADMIN_FLAG,
       e.LABDIR_FLAG,
       e.EXECDIR_FLAG,
       e.CHAIR_FLAG
  from F15E1_EMP e JOIN F15E1_LAB l
    ON e.f15e1_lab_lab_id = l.lab_id
    join f15e1_auth a on
    e.f15e1_auth_auth_id = a.auth_id;


-- PAGE 10: “chairperson” report
select e.EMP_ID,
       e.STATUS,
       e.NAME,
       e.EMAIL,
       e.OFFICE,
       e.PHONE,
       e.STATUS_EFF_DATE,
       e.DESCRIPTION,
       l.name AS DEPT_NAME,
       a.right
  from F15E1_EMP e JOIN F15E1_LAB l
    ON e.f15e1_lab_lab_id = l.lab_id
    join f15e1_auth a on
    e.f15e1_auth_auth_id = a.auth_id
  where e.type = 'CHAIRPERSON';


-- PAGE 11: “executive director” report 
select e.EMP_ID,
       e.STATUS,
       e.NAME,
       e.EMAIL,
       e.OFFICE,
       e.PHONE,
       e.STATUS_EFF_DATE,
       e.DESCRIPTION,
       l.name AS DEPT_NAME,
       a.right
  from F15E1_EMP e JOIN F15E1_LAB l
    ON e.f15e1_lab_lab_id = l.lab_id
    join f15e1_auth a on
    e.f15e1_auth_auth_id = a.auth_id
  where e.type = 'EXECUTIVE DIRECTOR';


-- PAGE 12: “lab system administrator” report
select e.EMP_ID,
       e.STATUS,
       e.NAME,
       e.EMAIL,
       e.OFFICE,
       e.PHONE,
       e.STATUS_EFF_DATE,
       e.DESCRIPTION,
       l.name AS DEPT_NAME,
       a.right
  from F15E1_EMP e JOIN F15E1_LAB l
    ON e.f15e1_lab_lab_id = l.lab_id
    join f15e1_auth a on
    e.f15e1_auth_auth_id = a.auth_id
  where e.type = 'LAB SYSTEM ADMINISTRATOR';


-- PAGE 13: “lab director” report
select e.EMP_ID,
       e.STATUS,
       e.NAME,
       e.EMAIL,
       e.OFFICE,
       e.PHONE,
       e.STATUS_EFF_DATE,
       e.DESCRIPTION,
       l.name AS DEPT_NAME,
       a.right
  from F15E1_EMP e JOIN F15E1_LAB l
    ON e.f15e1_lab_lab_id = l.lab_id
    join f15e1_auth a on
    e.f15e1_auth_auth_id = a.auth_id
  where e.type = 'LAB DIRECTOR';


-- PAGE 17: “lab” report
select LAB_ID,
       NAME,
       LAB_CODE
  from F15E1_LAB;


-- PAGE 21: “contact” report
select c."CONTACT_RFE_ID", 
e."NAME" AS "CONTACT_NAME", 
c."CREATED" AS "EFFECTIVE DATE"
from "#OWNER#"."F15E1_CONTACT_RFE" c join "#OWNER#"."F15E1_EMP" e
on c."F15E1_EMP_EMP_ID" = e."EMP_ID"
WHERE c.f15e1_rfe_rfe_id = :P21_RFE_ID;


-- PAGE 23: “selected rfe” report
select "RFE_ID", 
"EXPLANATION",
"ALT_PROTECTIONS",
E."NAME" AS "REQUESTOR",
S."STATUS",
S."DESCRIPTION" AS "STATUS DESCRIPTION"
from "#OWNER#"."F15E1_RFE" R JOIN "#OWNER#"."F15E1_EMP" E
 on R."F15E1_EMP_EMP_ID" = E."EMP_ID"
 JOIN "#OWNER#"."F15E1_STATUS" S ON 
 S."STATUS_ID" = R."F15E1_STATUS_STATUS_ID"
where rfe_id = :p23_rfe_id;


-- PAGE 23: “select rfe” report, submit button
select rfe_id
from f15e1_rfe
where rfe_id = :P23_RFE_ID and 
    (f15e1_status_status_id = '1' or f15e1_status_status_id = '4' or f15e1_status_status_id = '3') and
    (f15e1_emp_emp_id = :P2_EMP); 


-- PAGE 23: “select rfe” report, recall button
select rfe_id
from f15e1_rfe
where rfe_id = :P23_RFE_ID and 
    f15e1_status_status_id <> '1' and
    f15e1_status_status_id <> '9' and
    f15e1_status_status_id <> '5' and
    f15e1_status_status_id <> '4' and
    f15e1_emp_emp_id = :P2_EMP;


-- PAGE 23: “select rfe” report, final_approve button
select rfe_id
from f15e1_rfe r join f15e1_appr_rfe a on rfe_id = f15e1_rfe_rfe_id
where rfe_id = :P23_RFE_ID and 
    a.f15e1_emp_emp_id = :P2_EMP and
    r.f15e1_status_status_id = 8


-- PAGE 23: “select rfe” report, approve button
select rfe_id
from f15e1_rfe r join f15e1_appr_rfe a on rfe_id = f15e1_rfe_rfe_id
where rfe_id = :P23_RFE_ID and 
    a.f15e1_emp_emp_id = :P2_EMP and
    r.f15e1_status_status_id <> 8;


-- PAGE 23: “select rfe” report, return button
select rfe_id
from f15e1_rfe r join f15e1_appr_rfe a on rfe_id = f15e1_rfe_rfe_id
where rfe_id = :P23_RFE_ID and 
    a.f15e1_emp_emp_id = :P2_EMP;


-- PAGE 23: “select rfe” report, reject button
select rfe_id
from f15e1_rfe r join f15e1_appr_rfe a on rfe_id = f15e1_rfe_rfe_id
where rfe_id = :P23_RFE_ID and 
    a.f15e1_emp_emp_id = :P2_EMP;


-- PAGE 23: “status history” report
select sh.HIST_ID AS STATUS_HISTORY_ID,
       sh.STATUS,
       sh.DESCRIPTION,
       sh.EFF_DATE AS EFFECTIVE_DATE,
       e.NAME AS ENTERED_BY
  from F15E1_STATHIS sh join f15e1_rfe r
    on sh.f15e1_rfe_rfe_id = r.rfe_id
    join f15e1_emp e on 
    e.emp_id = sh.entered_by_emp
  where f15e1_rfe_rfe_id = :p23_rfe_id 
  order by sh.eff_date desc;


-- PAGE 23: “comments” report
select c."COMMENT_ID", 
c."COMMENTS",
e."NAME" AS "ENTERED_BY",
c."CREATED"
from "#OWNER#"."F15E1_COMMENT" c join "#OWNER#"."F15E1_EMP" e
on c."ENTERED_BY_EMP" = e."EMP_ID"
where c."F15E1_RFE_RFE_ID" = :P23_rfe_id;


-- PAGE 23: “tasks” report
select 
r.name,
t.abbreviation,
t.description
from F15E1_RFE_TASK rt join f15e1_rfe r
on r.rfe_id = rt.f15e1_rfe_rfe_id
join f15e1_task t
on rt.f15e1_task_task_id = t.task_id
where rt.f15e1_rfe_rfe_id = :P23_RFE_ID;


-- PAGE 23: “documents” report
select "DOCUMENT_ID", 
"FILENAME",
"FILE_MIMETYPE",
"FILE_CHARSET",
dbms_lob.getlength("FILE_BLOB") "FILE_BLOB",
"FILE_COMMENTS",
"TAGS",
"CREATED"
from "#OWNER#"."F15E1_DOC" 
where "F15E1_RFE_RFE_ID" = :P23_rfe_id;


-- ALL LIST OF VALUES:


-- all_tasks
select abbreviation as d,
       task_id as r
  from f15e1_task
 order by 1


-- tasks
select abbreviation as d,
       task_id as r
  from f15e1_task
  where task_id not in 
    (select task_id 
     from f15e1_task t join f15e1_rfe_task rt
       on t.task_id = rt.f15e1_task_task_id
       join f15e1_rfe r 
       on r.rfe_id = rt.f15e1_rfe_rfe_id
     where r.rfe_id = :P23_RFE_ID)
 order by 1;


-- contacts
select name as d,
       emp_id as r
  from f15e1_emp
  where emp_id not in 
    (select e.emp_id 
     from f15e1_emp e join f15e1_contact_rfe c
       on e.emp_id = c.f15e1_emp_emp_id
     where c.f15e1_rfe_rfe_id = :P21_RFE_ID)
 order by 1;


-- employees
select name as d,
       emp_id as r
  from f15e1_emp
  where f15e1_lab_lab_id = :P2_LAB
 order by 1;


-- lab
select name as d,
       lab_id as r
  from f15e1_lab
 order by 1;


-- rfes
select r.name as d,
       r.rfe_id as r
  from f15e1_rfe r
  where r.f15e1_emp_emp_id = :P2_EMP
union
select r.name as d,
       r.rfe_id as r
  from f15e1_rfe r join f15e1_contact_rfe c on
      r.rfe_id = c.f15e1_rfe_rfe_id
      join f15e1_emp e on
      e.emp_id = c.f15e1_emp_emp_id 
  where c.f15e1_emp_emp_id = :P2_EMP
union
select r.name as d,
       r.rfe_id as r
  from f15e1_rfe r, f15e1_emp e 
  join f15e1_auth a
  on a.auth_id = e.f15e1_auth_auth_id
  where e.emp_id = :P2_EMP and
  (a.right = 'read' or a.right = 'edit')
order by 1;