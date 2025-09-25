-- ==============================
--  CREATE (Insert)
-- ==============================

-- 1. Register a new member “Anu Chavan”.
INSERT INTO Members (name, email, phone, join_date)
VALUES ('Anu Chavan', 'anu.chavan@example.com', '9876543210', current_date());

-- 2. Add 1 new copy of “Harry Potter and the Sorcerer's Stone”
INSERT INTO BookCopies (book_id, status)
SELECT book_id, 'Available'
FROM Books
WHERE title = 'Harry Potter and the Sorcerer''s Stone'
LIMIT 1;

-- ==============================
--  READ (Select)
-- ==============================

-- ---- Basic Queries ----

-- 3. List all books available in the library
SELECT b.book_id, b.title, a.name AS author, c.category_name AS category
FROM Books b
JOIN Authors a ON b.author_id = a.author_id
JOIN Categories c ON b.category_id = c.category_id;

-- 4. Find all available copies of a given book (e.g., 'The Hobbit').
SELECT bc.copy_id, b.title
FROM BookCopies bc
JOIN Books b ON bc.book_id = b.book_id
WHERE b.title = 'The Hobbit' AND bc.status = 'available';

-- 5. Find books borrowed by a specific member (e.g., 'Bob Smith').
SELECT m.name AS member_name, b.title, l.loan_date, l.return_date
FROM Loans l
JOIN Members m ON l.member_id = m.member_id
JOIN BookCopies bc ON l.copy_id = bc.copy_id
JOIN Books b ON bc.book_id = b.book_id
WHERE m.name = 'Bob Smith';

-- 6. Find all books by a specific author (e.g., 'George Orwell').
SELECT b.title, a.name AS author
FROM Books b
JOIN Authors a ON b.author_id = a.author_id
WHERE a.name = 'George Orwell';

-- 7. Find members who have never borrowed a book.
SELECT m.member_id, m.name
FROM Members m
LEFT JOIN Loans l ON m.member_id = l.member_id
WHERE l.loan_id IS NULL;

-- 8. Find books by searching name (partial match).
SELECT * 
FROM Books
WHERE title LIKE '%Harry Potter%';

-- 9. Get all books in a specific genre (e.g., “Science Fiction”).
SELECT b.book_id, b.title, a.name AS author, c.category_name
FROM Books b
JOIN Authors a ON b.author_id = a.author_id
JOIN Categories c ON b.category_id = c.category_id
WHERE c.category_name = 'Science';

-- ---- Intermediate Queries ----

-- 10. Count how many books each member has borrowed.
SELECT m.name, COUNT(l.loan_id) AS borrowed_books
FROM Members m
LEFT JOIN Loans l ON m.member_id = l.member_id
GROUP BY m.member_id, m.name;

-- 11. Find the most borrowed books and their borrow counts.
SELECT b.title, COUNT(l.loan_id) AS borrow_count
FROM Loans l
JOIN BookCopies bc ON l.copy_id = bc.copy_id
JOIN Books b ON bc.book_id = b.book_id
GROUP BY b.book_id, b.title
ORDER BY borrow_count DESC;

-- 12. Find books that are currently borrowed (not yet returned)
SELECT b.title, m.name AS borrowed_by, l.loan_date
FROM Loans l
JOIN BookCopies bc ON l.copy_id = bc.copy_id
JOIN Books b ON bc.book_id = b.book_id
JOIN Members m ON l.member_id = m.member_id
WHERE l.return_date IS NULL;

-- 13. List all books that have never been borrowed (not a single copy)
SELECT b.book_id, b.title, a.name AS author, c.category_name
FROM Books b
JOIN Authors a ON b.author_id = a.author_id
JOIN Categories c ON b.category_id = c.category_id
WHERE NOT EXISTS (
    SELECT 1
    FROM BookCopies bc
    JOIN Loans l ON bc.copy_id = l.copy_id
    WHERE bc.book_id = b.book_id
);

-- 14. Members who never returned any book they borrowed (all of their loans are unreturned)
SELECT m.member_id, m.name
FROM Members m
WHERE NOT EXISTS (
    SELECT 1
    FROM Loans l
    WHERE l.member_id = m.member_id
      AND l.return_date IS NOT NULL
);

-- ---- Advanced Queries ----

-- 15. List all overdue books and the corresponding members with the number of days overdue and the fine amount (assuming 5 Rs per day).
SELECT 
    m.name AS member, 
    b.title, 
    l.due_date,
    DATEDIFF(CURDATE(), l.due_date) AS days_overdue,
    DATEDIFF(CURDATE(), l.due_date) * 5 AS fine_amount
FROM Loans l
JOIN Members m ON l.member_id = m.member_id
JOIN BookCopies bc ON l.copy_id = bc.copy_id
JOIN Books b ON bc.book_id = b.book_id
WHERE l.return_date IS NULL 
  AND l.due_date < CURDATE();

-- 16. List all overdue books for a specific member (e.g., 'George Martin'), including the number of days overdue, fine amount for each book, and the total remaining fine for that member.
SELECT 
    m.member_id,
    m.name AS member_name,
    b.title AS book_title,
    l.loan_date,
    l.due_date,
    l.return_date,
    CASE 
        WHEN l.return_date IS NULL AND l.due_date < CURDATE()
        THEN DATEDIFF(CURDATE(), l.due_date)
        ELSE 0
    END AS days_overdue,
    CASE 
        WHEN l.return_date IS NULL AND l.due_date < CURDATE()
        THEN DATEDIFF(CURDATE(), l.due_date) * 5
        ELSE 0
    END AS fine_amount,
    SUM(
        CASE 
            WHEN l.return_date IS NULL AND l.due_date < CURDATE()
            THEN DATEDIFF(CURDATE(), l.due_date) * 5
            ELSE 0
        END
    ) OVER (PARTITION BY m.member_id) AS total_remaining_fine
FROM Loans l
JOIN Members m ON l.member_id = m.member_id
JOIN BookCopies bc ON l.copy_id = bc.copy_id
JOIN Books b ON bc.book_id = b.book_id
WHERE m.name = 'George Martin'; 

-- 17. Get the most popular genre based on loan counts. (TOP 3)
SELECT c.category_name, COUNT(*) AS total_loans
FROM Loans l
JOIN BookCopies bc ON l.copy_id = bc.copy_id
JOIN Books b ON bc.book_id = b.book_id
JOIN Categories c ON b.category_id = c.category_id
GROUP BY c.category_name
ORDER BY total_loans DESC
LIMIT 3;

-- ==============================
--  UPDATE
-- ==============================

-- 18. Extend due date of LoanID=2 by 7 days (Re-issue)
UPDATE Loans
SET due_date = DATE_ADD(current_date(), INTERVAL 7 DAY)
WHERE loan_id = 2;

-- 19. Update email and phone for MemberID=2
UPDATE Members
SET email = 'new_email@example.com',
    phone = '9123456789'
WHERE member_id = 2;

-- ==============================
--  DELETE
-- ==============================

-- 20. Delete loan records older than 5 years. 
DELETE FROM Loans
WHERE due_date < DATE_SUB(CURRENT_DATE, INTERVAL 5 YEAR);







