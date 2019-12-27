CREATE DATABASE students;
USE students;

# Create a table
DROP TABLE IF EXISTS Student;

CREATE TABLE Student (
stdid INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY);


# Alter a table
ALTER TABLE Student ADD COLUMN phone CHAR(12) NULL;


# Load file into SQL
LOAD DATA LOCAL INFILE 'vendors.csv'  
INTO TABLE Vendor  
FIELDS TERMINATED BY ',' ENCLOSED BY '"'  
IGNORE 1 LINES;

UPDATE Vendor SET vendor_address1 = NULL WHERE vendor_address1 = '';