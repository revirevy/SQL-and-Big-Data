Week 1 - RDMS Model
================
Sam Musch

### Mannino 3.1-3.3 and Visc 1-3

------------------------------------------------------------------------

##### Terms and Overview

    SQL is...   
    Relational - only works with tables  
    Nonprocedural - user says what to do, but not how  
    Unified - everyone thats using SQL use same language

    DDL (Definition) - setting up a database  
    DML (Manipulation) - query the database  
    DCL (Control) - admin control 

    Client (eg mySQL Workbench) accesses a database server  
    DBMS is the software that helps use and maintain DB

    Table-Oriented = end users  
    Set-oriented = academics  
    Record-oriented = info sys professions

    Table = relation = file  
    Row = tuple = record  
    Column = attribute = field

------------------------------------------------------------------------

##### Structuring Tables


    Integrity = up to date, not conflicting, no duplicates

    1. Entity integrity (unique) = each table must have at least one column with unique rows, no nulls in any primary key    
    2. Reference integrity (connections) = for each related table, needs to be a 'matching' column
      Can't create a row in child table if no link to parent table  

    Each table reps 1 subject
    Each table has a primary key
    Each column contains one value, none should be calculated
    Each table should have 0 duplicates

    One to one = each row in parent only related to one row in child  
    One to many = each row in parent related to multiple rows in child  
    Many to many = each row in parent related to many rows in child, and each row in child related back to many rows in parent
      Resolve this issue by creating linking table
      
    Restrict deletion rule = have to delete child rows first if you want to delete parent row (usually default)
    Cascade deletion rule = delete parent row, auto deletes child rows
    Nullify = when deleting child rows, sets foreign keys of those rows as null
    Default = when deleting child rows, sets foreign keys of those rows as its default

    Mandatory participation = to enter rows in the new table, we need to create linking rows in the parent table
    Degree of participation
      Agent (1,1) --> each singer has to have 1 agent
      Singer (0,3) --> agent doesn't have to be assigned, can't have more than 3 singers

------------------------------------------------------------------------

##### Keys

    Superkey = name for the columns with unique values  
    Candidate key = min needed column to keep the unqiues columns still unqiue
      Primary key = special designated candidate key, can't contain null  
        Composite primary key = primary key with more than 1 column
      Foreign key = usually the primary key from parent table. Nulls are okay if foreign was not the primary from the parent  
      

    We can use an existing column as primary key iff..
    Each row reps a single instance of the purpose of the table
    Each row in the unique column has a different + single value
    Won't ever contain unknown values, optional values, values that can be modified

------------------------------------------------------------------------

##### Data Types

    CHAR(L) - fixed length entries, L reps max number of chars
    VARCHAR(L)
    FLOAT(P) - P is the number of sig figs
    DATE/TIME
    DECIMAL(W, R) - W is total digits, R is digits after decimal
    INTEGER
    BOOLEAN 

------------------------------------------------------------------------

##### Basic DDL Commands

Create a database

    CREATE DATABASE students;
    USE students;

Create a table

    DROP TABLE IF EXISTS Student;

    CREATE TABLE Student (
    stdid INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY);

Alter a table

    ALTER TABLE Student ADD COLUMN phone CHAR(12) NULL;

Load file into SQL

    LOAD DATA LOCAL INFILE 'vendors.csv'  
    INTO TABLE Vendor  
    FIELDS TERMINATED BY ',' ENCLOSED BY '"'  
    IGNORE 1 LINES;

    UPDATE Vendor SET vendor_address1 = NULL WHERE vendor_address1 = '';
