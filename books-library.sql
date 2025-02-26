-- Determine how many copies of the book 'Dracula'
-- are available for library patrons to borrow.

SELECT DISTINCT * FROM  books
    SELECT * FROM  loans   
    SELECT * FROM  patrons
/*
looking at the loan table and see if there is loan record without a return date for the books
CHALLANGE
Find the number of available copies of dracula
*/ 

-- Total avaliable copy of the book which is 3
SELECT COUNT(books.title)
FROM books
WHERE books.title = 'Dracula'
============================================================================
-- Total unreturned copy of the book which is 0
SELECT COUNT(books.title)
from books
JOIN loans On loans.bookid = books.bookid
WHERE books.title = 'Dracula' AND loans.returnedDate IS NULL
=============================================================================
--- Total Avaliable Copies which is 4
SELECT
 (SELECT COUNT(books.title)
        FROM books
         WHERE books.title = 'Dracula') - 
          (SELECT COUNT(books.title)
                FROM books 
                 JOIN loans ON loans.bookID = Books.bookID
                   WHERE books.title = 'Dracula' AND loans.returnedDate IS NULL)
                   AS AvaliableCopies
=============================================================================
/*  --CHALLANGE.. ADD TO THE BOOKS TABLE
1:
Title: Dracula
Author: Bram Stoker
Year: 1897
New ID (Barcode): 4819277482

2:
Title: Gulliver's Travels
Author: Jonathan Swift
Year: 1729
New ID: 4899254401
*/

INSERT INTO books (Title, Author, Published, Barcode)
       VALUES('Dracula', 'Bram Stoker', '1897', '4819277482'),
             ('Gullivers Travels', 'Bram Stoker', '1729', '4899254401')

/*
BOOK ARE STORE AS LOANS WITH bookID, PatronID
---CHALLENGE... Check out these books to this customer

Check out these books with the customers which his information shown on a library card.
The Picture of Dorian Gray, 
2855934983, Great Expectations, 4043822646

Jack Vaan, jvaan@wisdompets.com
Checkout date: August 25, 2022
Duedate to return: September 8, 2022
*/

insert into loans (BookID, PatronID, LoanDate, DueDate)
 VALUES((SELECT BookID
          FROM Books 
          WHERE Barcode = '2855934983'),
           (SELECT PatronID
            FROM patrons
              WHERE Email = 'jvaan@wisdompets.com'),
                  '2022-08-25',
                  '2022-09-08')

INSERT INTO LOANS (bookID, PatronID, LoanDate, DueDate)
VALUES(( SELECT bookID
          FROM books
          WHERE Barcode = '4043822646'),
          (SELECT PatronID
            FROM patrons
            WHERE Email = ' jvaan@wisdompets.com'),
                  '2022-08-25',
                  '2022-09-08')

SELECT  * 
FROM loans
join Books On loans.bookid = books.BookID
WHERE PatronID = (
          SELECT PatronID
          FROM patrons
          WHERE Email = 'jvaan@wisdompets.com')
/*L
CHALLENGE
Generate a report of books due back on July 13 2022, with patron contact information.
TABLE INVOLVE
Loans, Patrons, Books
*/
SELECT l.LoanDate, L.DueDate, B.title,P.firstname, P.Email
FROM Loans L
JOIN patrons P ON L.PatronID = P.PatronID
JOIN Books B ON P.PatronID = B.BookID
WHERE L.DueDate = '2022-07-13' 
AND L.ReturnedDate IS NULL
=================================================================================
SELECT l.LoanDate, L.DueDate, B.Title, P.firstname, P.Email
FROM Loans L
JOIN Books B ON L.BookID = B.bookID
JOIN patrons P ON l.PatronID = P.PatronID
WHERE L.DueDate = '2022-07-13'
AND L.ReturnedDate IS NULL;

SELECT B.title, L.DueDate, L.LoanDate, L.ReturnedDate
from Loans L
JOIN Books B ON L.BookID = B.bookID
WHERE LoanDate Between ('2022-7-13' AND '2022-07-2015') 
AND L.ReturnedDate IS NULL
ORDER BY Title ASC

SELECT P.firstname, B.Title,  L.DueDate,L.LoanDate, L.returnedDate
FROM Loans L
JOIN Patrons P ON l.PatronID = P.PatronID
JOIN Books B ON L.BookID = b.bookID
WHERE L.LoanDate Between ('2022-07-13' AND '2022-07-113') AND l.ReturnedDate
Order by B.Title
/*
UPDATE the loan table to indicate the books have been returned with these barcode
6435968624 , 5677520613 , 8730298424
CHALLENGE
Returen these books to the Library on July 5, 2022.
*/

SELECT L.LoanID, B.bookID, LoanDate, DueDate, ReturnedDate
from loans L
JOIN Books B ON L.bookID = B.bookID
where Barcode = '6435968624' AND ReturnedDate = '2022-07-05'

UPDATE LOANS
SET ReturnedDate = '2022-07-05'
Where BookID = (SELECT bookID 
                FROM books 
                WHERE barcode = '8730298424')
                AND ReturnedDate IS NULL

UPDATE Loans
SET ReturnedDate = '2022-07-05'
WHERE BookID = 
         (SELECT BookID
         FROM books
         WHERE barcode = '5677520613') AND returnedDate IS NULL

UPDATE Loans
SET returnedDate = '2022-07-05'
WHERE bookID = 
             (SELECT BookID 
             FROM Books
             WHERE barcode = '6435968624')
             AND returnedDate IS NULL

/*
CHALLENGE
Create a report showing the patrons who have checked out the fewest books. By counting the loan books
*/
SELECT COUNT(L.bookID) AS 'Books Checked Out', 
       p.patronID, P.firstname AS 'First Name', 
       p.Lastname AS 'Last Name', P.Email AS 'Email'
FROM loans l
JOIN Patrons P ON l.PatronID = P.PatronID
GROUP BY P.firstname
Order By count(L.BookID)
=====
OR
=====
SELECT COUNT(L.bookid) AS 'Books Checked Out', 
       P.patronID, P.firstname AS 'First Name', 
       p.Lastname AS 'Last Name', P.Email AS 'Email'
FROM patrons P
LEFT JOIN loans L ON P.patronID = L.patronID
GROUP BY P.patronID, P.firstname
ORDER BY COUNT(L.bookid) ASC
LIMIT 15;
/*
CHALENGE
Create a list of books from the 1890s that are currently available on the library and are not currently check out

*/
select BookID, barcode, title, published
from books where bookID IN ('70','95' ,'129')

SELECT B.bookID, B.title, B.barcode
FROM books B
WHERE Published BETWEEN'1890' AND '1899' 
ORDER by title

SELECT B.bookID, B.title, B.barcode
FROM Books b
WHERE Published BETWEEN 1890 and 1899
  AND (B.bookID NOT IN (SELECT L.BookID 
       FROM Loans l
       WHERE returnedDate IS NULL))
ORDER by title

/*
CHALLENGE -- is to create two report

Create a report showing how many books were published each year. counting only one copy of each title, 
with the most title published at the top of the list

create a report showing the five most popular books to check out. 
*/
SELECT Published, COUNT(DISTINCT(title)) AS 'PubCount'
FROM Books
Group by published 
ORDER by PubCount DESC

SELECT Published, COUNT(DISTINCT(title)) AS 'PubCount', 
GROUP_CONCAT(DISTINCT(title))
FROM Books
Group by published 
ORDER by PubCount DESC

=======================================================
--2
====
SELECT count(l.LoanID) AS LoanCount, B.Title
FROM Loans L
JOIN Books B ON L.BookID = B.BookID
GROUP BY B.title
ORDER By LoanCount Desc LIMIT 5

SELECT
    B.title, B.bookID, COUNT(L.bookID) AS 'Checkout Count'
FROM BOOKS B
JOIN LOANS L ON B.bookID = L.bookID
GROUP BY B.title, B.bookID
ORDER BY COUNT(L.bookID) DESC
LIMIT 5
