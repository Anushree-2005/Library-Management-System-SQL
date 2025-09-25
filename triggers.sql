--1. Automatically update book copy status when a loan is inserted.
-- When a new record is inserted into Loans, automatically set the corresponding BookCopies.status = 'Borrowed'.
DELIMITER $$

CREATE TRIGGER trg_after_loan_insert
AFTER INSERT ON Loans
FOR EACH ROW
BEGIN
    UPDATE BookCopies
    SET status = 'Borrowed'
    WHERE copy_id = NEW.copy_id;
END$$

DELIMITER ;

-- Test the trigger:
INSERT INTO Loans (member_id, copy_id, loan_date, due_date, return_date)
VALUES (1, 14, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 14 DAY), NULL);
-- Trigger will set BookCopies.status = 'Borrowed' for copy_id = 14

-------------------------------------------------------------------------------------------------------------------

-- 2.Automatically update book copy status when a loan is returned
-- When Loans.return_date is updated (not null), automatically set the corresponding BookCopies.status = 'Available'.
DELIMITER $$

CREATE TRIGGER trg_after_loan_update
AFTER UPDATE ON Loans
FOR EACH ROW
BEGIN
    -- Only update if the return_date is now filled
    IF NEW.return_date IS NOT NULL AND OLD.return_date IS NULL THEN
        UPDATE BookCopies
        SET status = 'Available'
        WHERE copy_id = NEW.copy_id;
    END IF;
END$$

DELIMITER ;

-- Test the trigger:
UPDATE Loans
SET return_date = CURDATE()
WHERE loan_id = 2;
-- Trigger will set BookCopies.status = 'Available' for copy_id = 6

-------------------------------------------------------------------------------------------------------------------
 
-- 3.Prevent Members from Borrowing More Than 2 Unreturned Books. 
DELIMITER $$

CREATE TRIGGER trg_limit_member_loans
BEFORE INSERT ON Loans
FOR EACH ROW
BEGIN
    DECLARE v_active_loans INT;

    -- Count how many books this member has not yet returned
    SELECT COUNT(*)
    INTO v_active_loans
    FROM Loans
    WHERE member_id = NEW.member_id
      AND return_date IS NULL;   -- still borrowed

    -- If already 2 or more, block the new loan
    IF v_active_loans >= 2 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT ='Member already has 2 or more unreturned books. Cannot borrow more.';
    END IF;
END$$

DELIMITER ;

-- Test the trigger:
INSERT INTO Loans (member_id, copy_id, loan_date, due_date, return_date)
VALUES (9, 1, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 14 DAY), NULL);
-- This will fail if member_id 9 already has 2 unreturned books.

-------------------------------------------------------------------------------------------------------------------

-- 4.. Log all deletions of members
-- When a member is deleted from Members, insert a record into a separate table DeletedMembersLog with timestamp and member info.
DELIMITER $$

CREATE TRIGGER trg_log_deleted_members
BEFORE DELETE ON Members
FOR EACH ROW
BEGIN
    INSERT INTO DeletedMembersLog (member_id, name, email, phone, reason)
    VALUES (OLD.member_id, OLD.name, OLD.email, OLD.phone, 'Member record deleted');
END$$

DELIMITER ;

-- Test the trigger:
-- Delete a member
DELETE FROM Members WHERE member_id = 10;
-- This will log the deleted member's info into DeletedMembersLog. 

-------------------------------------------------------------------------------------------------------------------

