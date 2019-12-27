-- This is a comment. Use comments to make notes to yourself!
-- 1. (I do) Create your first database. After typing your command, select the line and execute.
CREATE SCHEMA students;

-- 2. (I do) Change to your newly created database
USE students;


-- 3. (I do) Create your first table. 
--    Use the DROP TABLE command to start over if you make a mistake.
--    DDL, DML, or DCL?
DROP TABLE IF EXISTS Student;
CREATE TABLE Student (
stdid INTEGER NOT NULL,
stdFirstName VARCHAR(50) NOT NULL,
stdLastName VARCHAR(50) NOT NULL,
stdStreet VARCHAR(50) NOT NULL,
stdCity VARCHAR(50) NOT NULL,
stdState CHAR(2) NOT NULL,
stdPhone CHAR(12) NULL,
CONSTRAINT PRIMARY KEY (stdid));


  
-- 4. (I do) Insert data into your table. We will learn more about insert a little later!
--    Use the TRUNCATE TABLE command to start over if you make a mistake
--    Note that we don't have a phone number for Justin
TRUNCATE TABLE Student;

INSERT Student VALUES (100,'Cindy','Beach','4883 Veltry Dr','Anchorage','AK','907-244-0468');
INSERT Student VALUES (101,'Constance','Reilly','3725 White Oak Dr','Peculiar','MO','816-758-9498');
INSERT Student VALUES (102,'Steven','Brown','1888 Twin House Ln','Nevada','MO','417-448-3269');
INSERT Student VALUES (103,'Carol','Fisher','1319 Five Points','Hanover','MD','443-216-1389');
INSERT Student VALUES (104,'Justin','Tracy','2102 Gore St','Sugar Land','TX',NULL);

-- 5. (I do) Write your first query. We will learn more complicated queries later!
SELECT * FROM Student;

-- 6. (I do) Let's try to insert a record with a duplicate student ID and see what happens
--    What type of integrity does a primary key constraint enforce?
INSERT Student VALUES (101,'Constance','Reilly','3725 White Oak Dr','Peculiar','MO','816-758-9498');


-- 7. (We do) Create a table to represent different majors
--    You will need at least one column (used to hold the description of the major, such as 'MIS', etc)
--    What else will you need?
DROP TABLE IF EXISTS Major;
CREATE TABLE Major (
majorID INT NOT NULL PRIMARY KEY,
majorDesc VARCHAR(50) UNIQUE NOT NULL);
  
-- 8. (We do) Write insert statements to add each major
TRUNCATE TABLE Major;
INSERT Major VALUES (1, 'MIS');
INSERT Major VALUES (2, 'Accounting');
INSERT Major VALUES (3, 'Marketing');


-- 9. (We do) Write a simple query to view the table of majors
SELECT * FROM Major;

-- 10. (I do) Create a table to represent the relationship between students and majors
--     What name do we give to this type of table?
CREATE TABLE Student_Major (
stdid INT NOT NULL,
majorID INT NOT NULL,
PRIMARY KEY (stdid, majorID),
FOREIGN KEY (stdid) REFERENCES Student (stdid),
FOREIGN KEY (majorID) REFERENCES Major (majorID));

  
  
  
  
  
  
# UPDATING - same employee number, but turn John Smith from above into Patricia
UPDATE employees
SET first_name = 'Pat',
last_name = 'Stel',
birth_date = '2002-02-02',
gender = 'F'
WHERE emp_no = 999901;
  
  
  
  
  
-- 11. (We do) Write insert statements to create the relationship between students and majors



-- 12. (We do) Try to insert a record in the student/major table for a student or major that doesn't exist. 
--     What happens? What type of integrity does a Foreign Key constraint enforce?




-- 13. (You do) Now we want to track enrollment of students in a particular offering of a course. Write
--     the SQL to create a CourseOffering table. Each row of this table will represent 1 offering
--     of a particular course (ex. "IDSC 3103, Sec1, Spring 2016"). Column ideas include course ("IDSC 3103"),
--     Section (1,2,etc), Term ("Spring 2016"), Start Date, and End Date
--     Think about what the primary key should be. Use MyU class search if you need ideas!
--     Be sure to define your constraints!

  
-- 14. (You do) Add some data to your CourseOffering table
  
-- 15. (You do) Now write the SQL to keep track of which students are enrolled in which offerings. \
--     What will the table name be?
--     What will the columns be?
--     Be sure to properly define your constraints!

  
-- 16. (You do) Finally, write some statements to enroll some students in some courses.


  
