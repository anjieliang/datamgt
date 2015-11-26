DROP SEQUENCE F15E1_RFE_seq; 
create sequence F15E1_RFE_seq 
start with 100 
increment by 1 
nomaxvalue;

DROP VIEW F15E1_RFE_View;

CREATE VIEW F15E1_RFE_View as 
SELECT r.*, c.comments, t.f15e1_task_task_id
FROM F15E1_RFE r JOIN F15E1_Comment c ON r.rfe_id = c.f15e1_rfe_rfe_id 
JOIN F15E1_RFE_Task t ON t.f15e1_rfe_rfe_id = r.rfe_id;


CREATE OR REPLACE TRIGGER F15E1_RFE_View_Trig
INSTEAD OF INSERT ON F15E1_RFE_View
DECLARE
    new_rfe_id NUMBER;
    current_date DATE;
BEGIN
    current_date := SYSDATE;
    new_rfe_id := F15E1_RFE_seq.nextval;
    
    INSERT INTO F15E1_RFE (RFE_ID, NAME, EXPLANATION, ALT_PROTECTIONS, APPR_REVIEW_DATE, F15E1_STATUS_STATUS_ID, F15E1_EMP_EMP_ID) VALUES
        (new_rfe_id, :NEW.name, :NEW.explanation, :NEW.alt_protections, :NEW.appr_review_date, 1, v('P2_EMP'));

    INSERT INTO F15E1_StatHis (HIST_ID, F15E1_RFE_RFE_ID, STATUS, DESCRIPTION, EFF_DATE, ENTERED_BY_EMP) VALUES
        (1, new_rfe_id, 'Entered', 'The RFE has been created but has not yet been submitted for approval.', current_date, v('P2_EMP'));

    IF :NEW.comments IS NOT NULL THEN
        INSERT INTO F15E1_Comment (COMMENT_ID, ENTRY_DATE, ENTERED_BY_EMP, F15E1_RFE_RFE_ID, COMMENTS) VALUES
            (1, current_date, v('P2_EMP'), new_rfe_id, :NEW.comments);
    END IF;

    IF :NEW.f15e1_task_task_id IS NOT NULL THEN
        INSERT INTO F15E1_RFE_Task (RFE_TASK_ID, F15E1_RFE_RFE_ID, F15E1_TASK_TASK_ID) VALUES
            (1, new_rfe_id, :NEW.f15e1_task_task_id);
    END IF;
 
END F15E1_RFE_View_Trig;
/

CREATE OR REPLACE TRIGGER F15E1_RFE_Trig1
BEFORE UPDATE OF f15e1_status_status_id ON F15E1_RFE
FOR EACH ROW
BEGIN
    IF :NEW.F15E1_STATUS_STATUS_ID = 0 THEN
        IF :OLD.F15E1_STATUS_STATUS_ID = 2 THEN
            :NEW.F15E1_STATUS_STATUS_ID := 6;
        ELSIF :OLD.F15E1_STATUS_STATUS_ID = 6 THEN
            :NEW.F15E1_STATUS_STATUS_ID := 7;
        ELSIF :OLD.F15E1_STATUS_STATUS_ID = 7 THEN
            :NEW.F15E1_STATUS_STATUS_ID := 8;
        ELSIF :OLD.F15E1_STATUS_STATUS_ID = 8 THEN
            :NEW.F15E1_STATUS_STATUS_ID := 9;
        END IF;
    END IF;
END F15E1_RFE_Trig1;
/
        

CREATE OR REPLACE TRIGGER F15E1_RFE_Trig2
AFTER UPDATE OF f15e1_status_status_id ON F15E1_RFE
FOR EACH ROW
DECLARE
    new_status_id NUMBER;
    new_status VARCHAR2(30);
    new_description VARCHAR2(500);
    current_lab_id NUMBER;
    approver NUMBER;
    prev_approver_rfe NUMBER;
    auto_comment VARCHAR2(4000);
    current_date DATE;
BEGIN   
    new_status_id := :NEW.f15e1_status_status_id;
    current_date := SYSDATE;
    
    SELECT status INTO new_status FROM f15e1_status WHERE status_id = :NEW.f15e1_status_status_id;
    SELECT description INTO new_description FROM f15e1_status WHERE status_id = :NEW.f15e1_status_status_id;

    INSERT INTO F15E1_StatHis (HIST_ID, F15E1_RFE_RFE_ID, STATUS, DESCRIPTION, EFF_DATE, ENTERED_BY_EMP) VALUES
        (1, :NEW.rfe_id, new_status, new_description, current_date, v('P2_EMP'));

    IF new_status_id = 2 THEN
        /* Submitted */
        SELECT emp_id INTO approver FROM f15e1_emp WHERE f15e1_lab_lab_id = v('P2_LAB') AND admin_flag = 'Y';
    ELSIF new_status_id = 6 THEN
        /* SA Approved */
        SELECT emp_id INTO approver FROM f15e1_emp WHERE f15e1_lab_lab_id = v('P2_LAB') AND labdir_flag = 'Y';
    ELSIF new_status_id = 7 THEN
        /* LD Approved */
        approver := 70;
    ELSIF new_status_id = 8 THEN
        /* CH Approved */
        approver := 71;
    ELSIF new_status_id = 3 OR new_status_id = 4 THEN
        /* Returned or Recalled */
        SELECT appr_rfe_id INTO prev_approver_rfe FROM f15e1_appr_rfe WHERE f15e1_rfe_rfe_id = :NEW.rfe_id;
        DELETE f15e1_appr_rfe WHERE appr_rfe_id = prev_approver_rfe;
        DELETE f15e1_contact_rfe WHERE f15e1_rfe_rfe_id = :NEW.rfe_id;

        IF new_status_id = 3 THEN
            auto_comment := 'Returned';
        ELSE
            auto_comment := 'Recalled';
        END IF;
       
    ELSIF new_status_id = 5 THEN
        /* Rejected */
        SELECT appr_rfe_id INTO prev_approver_rfe FROM f15e1_appr_rfe WHERE f15e1_rfe_rfe_id = :NEW.rfe_id;    
        DELETE f15e1_appr_rfe WHERE appr_rfe_id = prev_approver_rfe;
        auto_comment := 'Rejected';
    END IF;
    
    IF auto_comment IS NOT NULL THEN
        INSERT INTO F15E1_Comment (COMMENT_ID, ENTRY_DATE, ENTERED_BY_EMP, F15E1_RFE_RFE_ID, COMMENTS) VALUES
            (1, current_date, v('P2_EMP'), :NEW.rfe_id, auto_comment);
    END IF;

    IF new_status_id >= 6 OR new_status_id = 2 THEN
        IF new_status_id <> 2 THEN
            SELECT appr_rfe_id INTO prev_approver_rfe FROM f15e1_appr_rfe WHERE f15e1_rfe_rfe_id = :NEW.rfe_id;
            DELETE f15e1_appr_rfe WHERE appr_rfe_id = prev_approver_rfe;
        END IF;
        
        IF new_status_id <> 9 THEN
            INSERT INTO F15E1_Contact_RFE (CONTACT_RFE_ID, F15E1_RFE_RFE_ID, F15E1_EMP_EMP_ID) VALUES
                (1, :NEW.rfe_id, approver);
            INSERT INTO F15E1_Appr_RFE (APPR_RFE_ID, F15E1_RFE_RFE_ID, F15E1_EMP_EMP_ID) VALUES
                (1, :NEW.rfe_id, approver);
        END IF;
    END IF;

END F15E1_Status_Trig2;
/

CREATE OR REPLACE PROCEDURE duplicate_RFE
(
  rfe_id_param NUMBER
)
AS
  new_rfe_id NUMBER;
  new_name VARCHAR2(30);
  new_explanation VARCHAR2(4000);
  new_alt_protections VARCHAR2(4000);
  new_emp_id NUMBER;
BEGIN
  new_rfe_id := F15E1_RFE_seq.nextval;
  SELECT name || ' (duplicate)' INTO new_name FROM f15e1_rfe WHERE rfe_id = rfe_id_param;
  SELECT explanation INTO new_explanation FROM f15e1_rfe WHERE rfe_id = rfe_id_param;
  SELECT alt_protections INTO new_alt_protections FROM f15e1_rfe WHERE rfe_id = rfe_id_param;
  SELECT f15e1_emp_emp_id INTO new_emp_id FROM f15e1_rfe WHERE rfe_id = rfe_id_param;

  INSERT INTO F15E1_RFE (RFE_ID, NAME, EXPLANATION, ALT_PROTECTIONS, APPR_REVIEW_DATE, F15E1_STATUS_STATUS_ID, F15E1_EMP_EMP_ID) VALUES
        (new_rfe_id, new_name, new_explanation, new_alt_protections, NULL, 1, new_emp_id);
  INSERT INTO F15E1_StatHis (HIST_ID, F15E1_RFE_RFE_ID, STATUS, DESCRIPTION, EFF_DATE, ENTERED_BY_EMP) VALUES
        (1, new_rfe_id, 'Entered', 'The RFE has been created but has not yet been submitted for approval.', SYSDATE, new_emp_id);
END;
/