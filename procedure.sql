-- 1. Borrow a Book
--  Input: member_id, book_id
--  Steps:
--      1.Find an available copy.
--      2.Insert into Loans.
--      3.Update BookCopies.status = 'Borrowed'.
DELIMITER $$

CREATE PROCEDURE BorrowBook(
    IN p_member_id INT,
    IN p_book_id INT
)
BEGIN
    DECLARE v_copy_id INT;

    -- Step 1: Find an available copy
    SELECT copy_id INTO v_copy_id
    FROM BookCopies
    WHERE book_id = p_book_id AND status = 'Available'
    LIMIT 1;

    -- Step 2: If no copy available, signal error
    IF v_copy_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No available copy for this book';
    ELSE
        -- Step 3: Insert into Loans (due date = 14 days later)
        INSERT INTO Loans (copy_id, member_id, loan_date, due_date)
        VALUES (v_copy_id, p_member_id, CURRENT_DATE, DATE_ADD(CURRENT_DATE, INTERVAL 14 DAY));

        -- Step 4: Update copy status
        UPDATE BookCopies
        SET status = 'Borrowed'
        WHERE copy_id = v_copy_id;
    END IF;
END $$

DELIMITER ;

CALL BorrowBook(9, 6);
----------------------------------------------------------------------------------------------------------------------

-- 2. Return a book
--  Input: loan_id
--  Steps:
--      1.Update Loans.return_date.
--      2.Change BookCopies.status = 'Available'.

DELIMITER $$

CREATE PROCEDURE ReturnBook(
    IN p_loan_id INT
)
BEGIN
    DECLARE v_copy_id INT;

    -- Step 1: Find which copy was borrowed
    SELECT copy_id INTO v_copy_id
    FROM Loans
    WHERE loan_id = p_loan_id;

    -- Step 2: Update loan record
    UPDATE Loans
    SET return_date = CURRENT_DATE
    WHERE loan_id = p_loan_id;

    -- Step 3: Update copy status
    UPDATE BookCopies
    SET status = 'Available'
    WHERE copy_id = v_copy_id;
END $$

DELIMITER ;
 
CALL ReturnBook(3);
----------------------------------------------------------------------------------------------------------------------


-- 3. Add a new book with multiple copies
--  Input: title, author_name, category_name, published_year, num_copies
--  Steps:
--      1.Insert author if not exists
--      2.Insert category if not exists  
--      3.Insert book    
--      4.Insert multiple copies

DELIMITER $$

CREATE PROCEDURE AddNewBook(
    IN p_title VARCHAR(200),
    IN p_author_name VARCHAR(100),
    IN p_category_name VARCHAR(50),
    IN p_published_year YEAR,
    IN p_num_copies INT
)
BEGIN
    DECLARE v_author_id INT;
    DECLARE v_category_id INT;
    DECLARE v_book_id INT;
    DECLARE i INT DEFAULT 1;

    -- Step 1: Insert author if not exists
    SELECT author_id INTO v_author_id
    FROM Authors
    WHERE name = p_author_name
    LIMIT 1;

    IF v_author_id IS NULL THEN
        INSERT INTO Authors (name) VALUES (p_author_name);
        SET v_author_id = LAST_INSERT_ID();
    END IF;

    -- Step 2: Insert category if not exists
    SELECT category_id INTO v_category_id
    FROM Categories
    WHERE category_name = p_category_name
    LIMIT 1;

    IF v_category_id IS NULL THEN
        INSERT INTO Categories (category_name) VALUES (p_category_name);
        SET v_category_id = LAST_INSERT_ID();
    END IF;

    -- Step 3: Insert book
    INSERT INTO Books (title, author_id, category_id, published_year)
    VALUES (p_title, v_author_id, v_category_id, p_published_year);

    SET v_book_id = LAST_INSERT_ID();

    -- Step 4: Insert multiple copies
    WHILE i <= p_num_copies DO
        INSERT INTO BookCopies (book_id, status)
        VALUES (v_book_id, 'Available');
        SET i = i + 1;
    END WHILE;

END $$

DELIMITER ;

CALL AddNewBook('SQL for Data Analytics', 'John Smith', 'Technology', 2023, 3);
----------------------------------------------------------------------------------------------------------------------


-- 4. Search books by keyword
--  Input: keyword
--  Steps: Return all books (title/author/category) that match.

DELIMITER $$

CREATE PROCEDURE SearchBooks(
    IN p_keyword VARCHAR(200)
)
BEGIN
    SELECT b.book_id, b.title, a.name AS author, c.category_name, b.published_year
    FROM Books b
    JOIN Authors a ON b.author_id = a.author_id
    JOIN Categories c ON b.category_id = c.category_id
    WHERE b.title LIKE CONCAT('%', p_keyword, '%')
       OR a.name LIKE CONCAT('%', p_keyword, '%')
       OR c.category_name LIKE CONCAT('%', p_keyword, '%');
END $$

DELIMITER ;

CALL SearchBooks('Harry Potter');


-- 5. Register a new member
--  Input: name, email, phone
--  Steps: Insert into Members.
--  Extra: Check if email already exists (raise error if duplicate).

DELIMITER $$

CREATE PROCEDURE RegisterMember(
    IN p_name VARCHAR(100),
    IN p_email VARCHAR(100),
    IN p_phone VARCHAR(15)
)
BEGIN
    DECLARE v_exists INT;

    -- Step 1: Check if email already exists
    SELECT COUNT(*) INTO v_exists
    FROM Members
    WHERE email = p_email;

    IF v_exists > 0 THEN
        -- Raise error if duplicate
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Email already exists. Please use a different email.';
    ELSE
        -- Step 2: Insert new member
        INSERT INTO Members (name, email, phone, join_date)
        VALUES (p_name, p_email, p_phone, CURRENT_DATE);
    END IF;
END $$

DELIMITER ;

CALL RegisterMember('Viraj Chavan', 'virajchavan@example.com', '8888888888');
----------------------------------------------------------------------------------------------------------------------




