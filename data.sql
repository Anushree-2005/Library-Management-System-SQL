-- Categories
INSERT INTO Categories (category_name) VALUES
('Fiction'),
('Science'),
('History'),
('Technology'),
('Biography');

-- Authors
INSERT INTO Authors (name) VALUES
('George Orwell'),
('Isaac Newton'),
('Yuval Noah Harari'),
('J.K. Rowling'),
('Elon Musk'),
('Agatha Christie'),
('Stephen Hawking'),
('Walter Isaacson');

-- Books
INSERT INTO Books (title, category_id, author_id, published_year) VALUES
('1984', 1, 1, 1949),
('Principia Mathematica', 2, 2, 1901),
('Sapiens', 3, 3, 2011),
('Harry Potter and the Sorcerer''s Stone', 1, 4, 1997),
('Tesla: Inventor of the Modern', 5, 5, 2015),
('Murder on the Orient Express', 1, 6, 1934),
('A Brief History of Time', 2, 7, 1988),
('Steve Jobs', 5, 8, 2011),
('The Hobbit', 1, 1, 1937),
('Cosmos', 2, 7, 1980);

-- BookCopies (each row = one physical copy)
INSERT INTO BookCopies (book_id, status) VALUES
(1, 'Available'), (1, 'Borrowed'), (1, 'Available'),
(2, 'Available'),
(3, 'Available'), (3, 'Borrowed'),
(4, 'Borrowed'), (4, 'Available'), (4, 'Available'),
(5, 'Available'),
(6, 'Available'), (6, 'Borrowed'),
(7, 'Available'), (7, 'Available'),
(8, 'Borrowed'),
(9, 'Available'), (9, 'Available'),
(10, 'Available');

-- Members
INSERT INTO Members (name, email, phone, join_date) VALUES
('Alice Johnson', 'alice@example.com', '9876543210', '2024-01-05'),
('Bob Smith', 'bob@example.com', '8765432109', '2024-02-10'),
('Charlie Brown', 'charlie@example.com', '7654321098', '2024-03-15'),
('Diana Prince', 'diana@example.com', '6543210987', '2024-04-01'),
('Ethan Hunt', 'ethan@example.com', '5432109876', '2024-04-12'),
('Fiona Gallagher', 'fiona@example.com', '4321098765', '2024-05-03'),
('George Martin', 'george@example.com', '3210987654', '2024-06-07'),
('Hannah Lee', 'hannah@example.com', '2109876543', '2024-06-15');

-- Loans (transactions: borrowed books, some returned, some still out)
INSERT INTO Loans (copy_id, member_id, loan_date, due_date, return_date) VALUES
(2, 1, '2024-03-01', '2024-03-15', '2024-03-14'), -- Alice returned
(6, 2, '2024-03-10', '2024-03-24', NULL),         -- Bob still borrowed
(4, 3, '2024-03-12', '2024-03-26', NULL),         -- Charlie still borrowed
(7, 4, '2024-04-05', '2024-04-19', '2024-04-17'), -- Diana returned
(12, 5, '2024-04-15', '2024-04-29', NULL),        -- Ethan overdue
(8, 6, '2024-05-01', '2024-05-15', '2024-05-14'), -- Fiona returned
(15, 7, '2024-06-10', '2024-06-24', NULL),        -- George still borrowed
(9, 8, '2024-06-12', '2024-06-26', NULL),         -- Hannah still borrowed
(3, 1, '2024-07-01', '2024-07-15', '2024-07-14'), -- Alice returned again
(11, 2, '2024-07-05', '2024-07-19', NULL),        -- Bob borrowed again
(13, 4, '2024-07-08', '2024-07-22', NULL),        -- Diana borrowed again
(17, 6, '2024-07-10', '2024-07-24', NULL);        -- Fiona still borrowed
