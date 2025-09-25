-- 1.All available books (not borrowed right now)
--  Show a list of all books with their author, category, and availability.
CREATE VIEW AvailableBooks AS
SELECT b.book_id, b.title, a.name AS author, c.category_name AS category
FROM Books b
JOIN Authors a ON b.author_id = a.author_id
JOIN Categories c ON b.category_id = c.category_id
WHERE b.book_id IN (
    SELECT book_id FROM BookCopies WHERE status = 'Available'
);

-- 2.Active loans with member details
--  Show which members currently have borrowed books (not returned).
CREATE VIEW ActiveLoans AS
SELECT l.loan_id, m.name AS member, b.title, l.loan_date, l.due_date
FROM Loans l
JOIN Members m ON l.member_id = m.member_id
JOIN BookCopies bc ON l.copy_id = bc.copy_id
JOIN Books b ON bc.book_id = b.book_id
WHERE l.return_date IS NULL;

-- 3.Category-wise book count
--  Show how many books exist per category.
CREATE VIEW CategoryBookCount AS
SELECT c.category_name AS category, COUNT(b.book_id) AS total_books
FROM Books b
JOIN Categories c ON b.category_id = c.category_id
GROUP BY c.category_name;

-- 4.Fine report (if fines are applied)
--  Show members with overdue days and total fines.
CREATE VIEW FineReport AS
SELECT m.name AS member, b.title, DATEDIFF(CURDATE(), l.due_date) AS overdue_days,
       (DATEDIFF(CURDATE(), l.due_date) * 5) AS fine_amount  
FROM Loans l
JOIN Members m ON l.member_id = m.member_id
JOIN BookCopies bc ON l.copy_id = bc.copy_id
JOIN Books b ON bc.book_id = b.book_id
WHERE l.return_date IS NULL
  AND l.due_date < CURDATE();
  
-- 5.Top members by borrowing activity
-- 	List members who borrowed the most books. 
CREATE VIEW TopMembers AS
SELECT m.name, COUNT(*) AS total_borrowed
FROM Loans l
JOIN Members m ON l.member_id = m.member_id
GROUP BY m.name
ORDER BY total_borrowed DESC;

-- 6.Most borrowed books (summary)
-- 	See which books are the most popular. 
CREATE VIEW MostBorrowedBooks AS
SELECT b.title, COUNT(*) AS times_borrowed
FROM Loans l
JOIN BookCopies bc ON l.copy_id = bc.copy_id
JOIN Books b ON bc.book_id = b.book_id
GROUP BY b.title
ORDER BY times_borrowed DESC;

