-- Library Management System Database Schema

CREATE DATABASE library_management_system;
USE library_management_system;

-- Authors of books
CREATE TABLE Authors (
    author_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- Category of books (e.g., Fiction, Non-Fiction, Science, History)
CREATE TABLE Categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(50) NOT NULL
);

-- Book title info
CREATE TABLE Books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    category_id INT,
    author_id INT,
    published_year YEAR,
    FOREIGN KEY (category_id) REFERENCES Categories(category_id),
    FOREIGN KEY (author_id) REFERENCES Authors(author_id)
);

-- Each physical copy of a book
CREATE TABLE BookCopies (
    copy_id INT PRIMARY KEY AUTO_INCREMENT,
    book_id INT,
    status ENUM('Available', 'Borrowed', 'Lost') DEFAULT 'Available',
    FOREIGN KEY (book_id) REFERENCES Books(book_id)
);

-- Members of library
CREATE TABLE Members (
    member_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15),
    join_date DATE DEFAULT (CURRENT_DATE)
);

-- Loan transactions (track copy, not just book)
CREATE TABLE Loans (
    loan_id INT PRIMARY KEY AUTO_INCREMENT,
    copy_id INT,
    member_id INT,
    loan_date DATE DEFAULT (CURRENT_DATE),
    due_date DATE,
    return_date DATE,
    FOREIGN KEY (copy_id) REFERENCES BookCopies(copy_id),
    FOREIGN KEY (member_id) REFERENCES Members(member_id)
);

-- Log of deleted members
CREATE TABLE DeletedMembersLog (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT,
    name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    deleted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reason VARCHAR(255) NULL
);

